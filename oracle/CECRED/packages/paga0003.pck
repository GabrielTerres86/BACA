CREATE OR REPLACE PACKAGE cecred.paga0003 IS

  -- PL/TABLE que contem os dados de pagamentos de DARF/DAS
  TYPE typ_reg_agend_darf_das IS
    RECORD(idlancto           tbpagto_agend_darf_das.idlancto%TYPE       
          ,cdcooper           tbpagto_agend_darf_das.cdcooper%TYPE
          ,nrdconta           tbpagto_agend_darf_das.nrdconta%TYPE
          ,tppagamento        tbpagto_agend_darf_das.tppagamento%TYPE
          ,tpcaptura          tbpagto_agend_darf_das.tpcaptura%TYPE
          ,dsidentif_pagto    tbpagto_agend_darf_das.dsidentif_pagto%TYPE
          ,dsnome_fone        tbpagto_agend_darf_das.dsnome_fone%TYPE
          ,dscod_barras       tbpagto_agend_darf_das.dscod_barras%TYPE
          ,dslinha_digitavel  tbpagto_agend_darf_das.dslinha_digitavel%TYPE
          ,dtapuracao         tbpagto_agend_darf_das.dtapuracao%TYPE
          ,nrcpfcgc           tbpagto_agend_darf_das.nrcpfcgc%TYPE
          ,cdtributo          tbpagto_agend_darf_das.cdtributo%TYPE
          ,nrrefere           tbpagto_agend_darf_das.nrrefere%TYPE
          ,vlprincipal        tbpagto_agend_darf_das.vlprincipal%TYPE
          ,vlmulta            tbpagto_agend_darf_das.vlmulta%TYPE
          ,vljuros            tbpagto_agend_darf_das.vljuros%TYPE
          ,vlreceita_bruta    tbpagto_agend_darf_das.vlreceita_bruta%TYPE
          ,vlpercentual       tbpagto_agend_darf_das.vlpercentual%TYPE
          ,dtvencto           tbpagto_agend_darf_das.dtvencto%TYPE
          ,tpleitura_docto    tbpagto_agend_darf_das.tpleitura_docto%TYPE
          ,idrowid            VARCHAR2(200));
          
  TYPE typ_tab_agend_darf_das IS
    TABLE OF typ_reg_agend_darf_das
		INDEX BY BINARY_INTEGER;

  -- Início -- PRJ406  
  --Tipo de registro de convenio
  TYPE typ_reg_conveni IS RECORD 
    (cdempres tbconv_arrecadacao.cdempres%TYPE
    ,nmextcon crapcon.nmextcon%TYPE); 
  
  --Tabela para tipo de registro de convenio
  TYPE typ_tab_conveni IS TABLE OF typ_reg_conveni INDEX BY PLS_INTEGER;
  -- Fim -- PRJ406

  --> TempTable para armazenar os agendamentos
  TYPE typ_reg_agend_bancoob IS
  RECORD ( nrchave VARCHAR2(100) --
          ,cdcooper NUMBER(2)    --  FORMAT "z9"
          ,dscooper crapcop.nmrescop%TYPE
          ,cdagenci NUMBER(3)    --  FORMAT "zz9"
          ,nrdconta NUMBER       --  FORMAT "zzzz,zzz,9"
          ,nmprimtl crapass.nmprimtl%TYPE --  FORMAT "x(40)"
          ,cdtiptra NUMBER(2)    --  FORMAT "99"
          ,fltiptra BOOLEAN
          ,dstiptra VARCHAR2(20) --  FORMAT "x(20)"
          ,fltipdoc VARCHAR2(10) --  CONVENIO ou TITULO
          ,dstransa craplau.dscedent%TYPE --  FORMAT "x(32)"
          ,vllanaut NUMBER       --  FORMAT "zzz,zzz,zz9.99"
          ,dttransa DATE         --  FORMAT "99/99/9999"
          ,hrtransa VARCHAR2(8)  --  FORMAT "x(8)"
          ,nrdocmto NUMBER       --  FORMAT "zzz,zz9"
          ,dslindig VARCHAR2(55) --  FORMAT "x(55)"
          ,dscritic VARCHAR2(100)  --  FORMAT "x(40)"
          ,nrdrecid ROWID
          ,fldebito NUMBER(1)
          ,dsorigem VARCHAR2(100)
          ,idseqttl NUMBER
          ,nrseqagp NUMBER
          ,dtmvtolt craplau.dtmvtolt%TYPE
          ,nrseqdig craplau.nrseqdig%TYPE
          ,dshistor VARCHAR2(100)
          ,dtagenda DATE
          ,dsdebito VARCHAR2(15)
          ,prorecid NUMBER);

  -- Definicao do tipo de tabela temporária
  TYPE typ_tab_agend_bancoob IS
    TABLE OF typ_reg_agend_bancoob
    INDEX BY VARCHAR2(100);
  
  PROCEDURE pc_valid_dig_GRF (pr_nrrefere   IN VARCHAR2,
                              pr_dscritic  OUT VARCHAR2);
                              
  PROCEDURE pc_valid_pag_menu_trib ( pr_cdbarras  IN VARCHAR2   -- Código de barras da guia
                                    ,pr_flmobile  IN INTEGER    -- identificador mobile
                                    ,pr_tpdaguia  IN INTEGER    -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)  
                                    ,pr_dscritic OUT VARCHAR2); -- retorna critica
  
  PROCEDURE pc_verifica_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
                                ,pr_idorigem IN INTEGER -- Canal de origem da operação
                                ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)
                                ,pr_tpcaptur IN NUMBER -- Tipo de captura da guia (1-Código Barras / 2-Manual)
                                ,pr_lindigi1 IN OUT NUMBER -- Primeiro campo da linha digitável da guia
                                ,pr_lindigi2 IN OUT NUMBER -- Segundo campo da linha digitável da guia
                                ,pr_lindigi3 IN OUT NUMBER -- Terceiro campo da linha digitável da guia
                                ,pr_lindigi4 IN OUT NUMBER -- Quarto campo da linha digitável da guia
                                ,pr_cdbarras IN OUT VARCHAR2 -- Código de barras da guia
                                ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                ,pr_dtapurac IN DATE -- Período de apuração da guia
                                ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                ,pr_cdtribut IN VARCHAR2 -- Código de tributação da guia
                                ,pr_nrrefere IN VARCHAR2 -- Número de referência da guia
                                ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                ,pr_idagenda IN INTEGER -- Indicador de agendamento (1-Nesta Data/2-Agendamento
                                ,pr_dtagenda IN DATE -- Data de agendamento
                                ,pr_indvalid IN INTEGER -- Indicador de controle de validações (1-Operação Online/2-Operação Batch)
								,pr_flmobile IN INTEGER -- Indicador Mobile
                                ,pr_cdseqfat OUT VARCHAR2 -- Código sequencial da guia
                                ,pr_vldocmto OUT NUMBER -- Valor da guia
                                ,pr_nrdigfat OUT NUMBER -- Digito do faturamento
                                ,pr_cdcritic OUT INTEGER -- Código do erro
                                ,pr_dscritic OUT VARCHAR2 -- Descriçao do erro
                                 );

  PROCEDURE pc_paga_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE	-- Código da cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE	-- Número da conta
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE	-- Sequencial de titularidade
                            ,pr_nrcpfope IN NUMBER	-- CPF do operador PJ
                            ,pr_idorigem IN INTEGER	-- Canal de origem da operação
                            ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 – DARF / 2 – DAS)
                            ,pr_tpcaptur IN INTEGER	-- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                            ,pr_cdseqfat IN VARCHAR2 -- Código sequencial da guia
                            ,pr_nrdigfat IN NUMBER  -- Dígito do faturamento
                            ,pr_lindigi1 IN NUMBER	-- Primeiro campo da linha digitável da guia
                            ,pr_lindigi2 IN NUMBER  -- Segundo campo da linha digitável da guia
                            ,pr_lindigi3 IN NUMBER  -- Terceiro campo da linha digitável da guia
                            ,pr_lindigi4 IN NUMBER  -- Quarto campo da linha digitável da guia
                            ,pr_cdbarras IN VARCHAR2	-- Código de barras da guia
                            ,pr_dsidepag IN VARCHAR2	-- Descrição da identificação do pagamento
                            ,pr_vlrtotal IN NUMBER	-- Valor total do pagamento da guia
                            ,pr_dsnomfon IN VARCHAR2	-- Nome e telefone da guia
                            ,pr_dtapurac IN DATE		-- Período de apuração da guia
                            ,pr_nrcpfcgc IN VARCHAR2  -- CPF/CNPJ da guia
                            ,pr_cdtribut IN VARCHAR2  -- Código de tributação da guia
                            ,pr_nrrefere IN VARCHAR2  -- Número de referência da guia
                            ,pr_dtvencto IN DATE		-- Data de vencimento da guia
                            ,pr_vlrprinc IN NUMBER	-- Valor principal da guia
                            ,pr_vlrmulta IN NUMBER	-- Valor da multa da guia
                            ,pr_vlrjuros IN NUMBER	-- Valor dos juros da guia
                            ,pr_vlrecbru IN NUMBER	-- Valor da receita bruta acumulada da guia
                            ,pr_vlpercen IN NUMBER	-- Valor do percentual da guia
                            ,pr_vldocmto IN NUMBER  -- Valor da guia
                            ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 – Nesta Data / 2 – Agendamento)
                            ,pr_tpleitor IN INTEGER	-- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                            ,pr_flgagend INTEGER     DEFAULT 0 /*1-True,0-False*/  --Flag se é uma efetivação de agendamento
                            ,pr_flmobile IN INTEGER  DEFAULT 0    -- Identificador de mobile
                            ,pr_iptransa IN VARCHAR2 DEFAULT NULL -- IP da transação
                            ,pr_iddispos IN VARCHAR2 DEFAULT NULL -- Identificador do dispositivo mobile    
                            ,pr_dsprotoc OUT VARCHAR2 --Descricao Protocolo
                            ,pr_cdcritic OUT INTEGER	-- Código do erro
                            ,pr_dscritic OUT VARCHAR2	-- Descriçao do erro
                            );

	/* Procedimento do internetbank operação 188 - Operar pagamento DARF/DAS */
  PROCEDURE pc_InternetBank188(pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Número da conta
															,pr_nrdconta IN  crapass.nrdconta%TYPE  -- Sequencial de titularidade
															,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- CPF do operador PJ
															,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- Canal de origem da operação
															,pr_dtmvtopg IN  DATE                   -- Data do pagamento
															,pr_idorigem IN  INTEGER                -- Indicador de requisição via canal Mobile
															,pr_flmobile IN  INTEGER                -- Indicador de efetivação da operação de pagamento
															,pr_idefetiv IN  INTEGER                -- Tipo da guia (1 – DARF / 2 – DAS)
															,pr_tpdaguia IN  INTEGER                -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
															,pr_tpcaptur IN  INTEGER                -- Primeiro campo da linha digitável da guia
															,pr_lindigi1 IN  NUMBER                 -- Segundo campo da linha digitável da guia
															,pr_lindigi2 IN  NUMBER                 -- Terceiro campo da linha digitável da guia
															,pr_lindigi3 IN  NUMBER                 -- Quarto campo da linha digitável da guia
															,pr_lindigi4 IN  NUMBER                 -- Código de barras da guia
															,pr_cdbarras IN  VARCHAR2               -- Descrição da identificação do pagamento
															,pr_dsidepag IN  VARCHAR2               -- Valor total do pagamento da guia
															,pr_vlrtotal IN  NUMBER                 -- Nome e telefone da guia
															,pr_dsnomfon IN  VARCHAR2               -- Período de apuração da guia
															,pr_dtapurac IN  DATE                   -- CPF/CNPJ da guia
															,pr_nrcpfcgc IN  VARCHAR2               -- Código de tributação da guia
															,pr_cdtribut IN  VARCHAR2                 -- Número de referência da guia
															,pr_nrrefere IN  VARCHAR2                 -- Data de vencimento da guia
															,pr_dtvencto IN  DATE                   -- Valor principal da guia
															,pr_vlrprinc IN  NUMBER                 -- Valor da multa da guia
															,pr_vlrmulta IN  NUMBER                 -- Valor dos juros da guia
															,pr_vlrjuros IN  NUMBER                 -- Valor da receita bruta acumulada da guia
															,pr_vlrecbru IN  NUMBER                 -- Valor do percentual da guia
															,pr_vlpercen IN  NUMBER                 -- Código sequencial da guia
															,pr_idagenda IN  INTEGER                -- Data de agendamento
															,pr_vlapagar IN  NUMBER                 -- Indicador de validação do saldo em relação ao valor total
															,pr_versaldo IN  INTEGER                -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
															,pr_tpleitor IN  INTEGER                -- Descriçao do erro
															,pr_iptransa IN VARCHAR2 DEFAULT NULL   -- IP da transação
                              ,pr_iddispos IN VARCHAR2 DEFAULT NULL   -- Identificador do dispositivo mobile                                  
															,pr_xml_dsmsgerr    OUT VARCHAR2        -- Retorno XML de critica
                              ,pr_xml_operacao188 OUT CLOB            -- Retorno XML da operação 188
                              								,pr_dsretorn        OUT VARCHAR2 );     -- Retorno de critica (OK ou NOK)

  PROCEDURE pc_cria_agend_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
								  ,pr_cdagenci IN INTEGER               -- PA
								  ,pr_nrdcaixa IN NUMBER                -- Numero do Caixa
								  ,pr_cdoperad IN VARCHAR2              -- Cd Operador
                                  ,pr_nrcpfope IN NUMBER -- CPF do operador PJ
                                  ,pr_idorigem IN INTEGER -- Canal de origem da operação
                                  ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 – DARF / 2 – DAS)
                                  ,pr_tpcaptur IN INTEGER -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                  ,pr_cdhistor IN INTEGER               -- Histórico
                                  ,pr_lindigi1 IN NUMBER -- Primeiro campo da linha digitável da guia
                                  ,pr_lindigi2 IN NUMBER -- Segundo campo da linha digitável da guia
                                  ,pr_lindigi3 IN NUMBER -- Terceiro campo da linha digitável da guia
                                  ,pr_lindigi4 IN NUMBER -- Quarto campo da linha digitável da guia
                                  ,pr_cdbarras IN VARCHAR2 -- Código de barras da guia
                                  ,pr_dsidepag IN VARCHAR2 -- Descrição da identificação do pagamento
                                  ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                  ,pr_dsnomfon IN VARCHAR2 -- Nome e telefone da guia
                                  ,pr_dtapurac IN DATE -- Período de apuração da guia
                                  ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                  ,pr_cdtribut IN VARCHAR2 -- Código de tributação da guia
                                  ,pr_nrrefere IN VARCHAR2 -- Número de referência da guia
                                  ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                  ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                  ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                  ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                  ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                  ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                  ,pr_dtagenda IN DATE -- Data de agendamento
                                  ,pr_cdtrapen IN NUMBER -- Código de sequencial da transação pendente
																	,pr_tpleitor IN INTEGER               -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual) 
                                  ,pr_flmobile IN INTEGER DEFAULT 0     -- Identificador de mobile
                                  ,pr_iptransa IN VARCHAR2 DEFAULT NULL -- IP da transação
                                  ,pr_iddispos IN VARCHAR2 DEFAULT NULL -- Identificador do dispositivo mobile    
                                  ,pr_dsprotoc OUT VARCHAR2 --Protocolo
                                  ,pr_cdcritic OUT INTEGER -- Código do erro
                                  ,pr_dscritic OUT VARCHAR2 -- Descriçao do erro
                                   );

  /* Procedimento do internetbank operação 187 - Consulta de Horario Limite DARF/DAS */
  PROCEDURE pc_InternetBank187(pr_cdcooper IN crapcop.cdcooper%type      -- Codigo Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%type      -- Agencia do Associado
                              ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero caixa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Identificador Sequencial titulo
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data Movimento
                              ,pr_idagenda IN INTEGER                    -- Indicador agenda
                              ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE      -- Data Pagamento
                              ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  -- Valor Lancamento
                              ,pr_cddbanco IN crapcti.cddbanco%TYPE      -- Codigo banco
                              ,pr_cdageban IN crapcti.cdageban%TYPE      -- Codigo Agencia
                              ,pr_nrctatrf IN crapcti.nrctatrf%TYPE      -- Numero Conta Transferencia
                              ,pr_cdtiptra IN INTEGER                    -- 1 - Transferencia / 2 - Pagamento /3 - Credito Salario / 4 - TED
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Codigo Operador
                              ,pr_tpoperac IN INTEGER                    -- 1 - Transferencia intracooperativa /2 - Pagamento /3 - Cobranca /4 - TED / 5 - Transferencia intercooperativa
                              ,pr_flgvalid IN INTEGER                    -- (0- False, 1-True)Indicador validacoes
                              ,pr_dsorigem IN craplau.dsorigem%TYPE      -- Descricao Origem
                              ,pr_nrcpfope IN crapopi.nrcpfope%TYPE      -- CPF operador
                              ,pr_flgctrag IN INTEGER                    -- (0- False, 1-True)controla validacoes na efetivacao de agendamentos
                              ,pr_nmdatela IN VARCHAR2                   -- Nome da Tela
                              ,pr_iptransa IN VARCHAR2                   -- IP da transacao no IBank/mobile
                              ,pr_flmobile IN INTEGER                    -- Indicador se origem é do Mobile
                              ,pr_xml_dsmsgerr    OUT VARCHAR2           -- Retorno XML de critica
                              ,pr_xml_operacao187 OUT CLOB               -- Retorno XML da operação 187
                              ,pr_dsretorn        OUT VARCHAR2);         -- Retorno de critica (OK ou NOK)
       
   PROCEDURE pc_busca_agend_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE                --> Código da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                --> Código do Operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                        ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE                --> Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                        ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                        ,pr_clobxmlc OUT CLOB                                --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2);                          --> Descrição da crítica

  PROCEDURE pc_extrai_cdbarras_fgts_dae (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdbarras IN VARCHAR               --> Codigo de barras
                                          
                                        ---- OUT ----
                                        ,pr_cdempcon OUT NUMBER               --> Retorna numero da empresa conveniada
                                        ,pr_nrinsemp OUT VARCHAR2             --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                        ,pr_nrdocmto OUT NUMBER               --> Numero do documento
                                        ,pr_nrrecolh OUT NUMBER               --> Numero identificado de recolhimento
                                        ,pr_dtcompet OUT DATE                 --> Data da competencia
                                        ,pr_dtvencto OUT DATE                 --> Data de vencimento/validade
                                        ,pr_vldocmto OUT NUMBER               --> Valor do documento
                                        ,pr_nrsqgrde OUT VARCHAR2             --> Sequencial da GRDE 
                                        ,pr_dscritic OUT VARCHAR2);           --> Critica
                                        
  PROCEDURE pc_validacoes_bancoob (pr_cdcooper IN crapcop.cdcooper%type      -- Codigo Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%type      -- Agencia do Associado
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero caixa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Identificador Sequencial titulo
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data Movimento
                                  ,pr_cdbarras IN VARCHAR                    -- Codigo de barras
                                  ,pr_cdempcon IN crapcon.cdempcon%TYPE      -- Codigo Empresa Convenio
                                  ,pr_cdsegmto IN crapcon.cdsegmto%TYPE      -- Codigo Segmento Convenio
                                  ,pr_idagenda IN  INTEGER                   -- Indicador se é agendamento (1 – Nesta Data / 2 – Agendamento) 
                                  ,pr_flgpgag  IN BOOLEAN                    -- Indicador Pagto agendamento                                          
                                  ,pr_cdcritic OUT INTEGER                   -- Retorno codigo de critica
                                  ---- OUT ----                                                                    
                                  ,pr_dscritic OUT VARCHAR2);                -- Retorno de descrição Critica                                         


  --> Procedimento para buscar os debitos agendados de pagamento bancoob
  PROCEDURE pc_obtem_agendeb_bancoob ( pr_cdcooper   IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE             --> Nome resumido da cooperativa
                                       ,pr_dtmvtopg  IN DATE                              --> Data do pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE             --> Indicador do processo
                                       ,pr_tab_agend_bancoob IN OUT typ_tab_agend_bancoob --> Retorna os agendamentos
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2);                        --> descrição da critica
                                       
  --> Procedimento para processar os debitos agendados de pagamento bancoob
  PROCEDURE pc_processa_agend_bancoob ( pr_cdcooper  IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2);                      --> descrição da critica                                       

  -- Rotina responsável por gerar os arquivos de arrecadação dos convênios BANCOOB
  PROCEDURE pc_gera_arrecadacao_bancoob(pr_cdcooper IN  crapcop.cdcooper%TYPE            -- Código da Cooperativa
                                       ,pr_cdconven IN tbconv_arrecadacao.cdempres%TYPE   -- Código do Convênio
                                       ,pr_dscritic OUT VARCHAR2                         -- Descrição do erro retornado
                                       );
  -- Rotina para retornar os convênios de acordo com os parâmetros informados
  PROCEDURE pc_busca_convenios_bcb(pr_cdcooper IN crapcop.cdcooper%TYPE            -- Código da cooperativa
                              ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                              ,pr_des_erro OUT VARCHAR2             	         -- Saida OK/NOK
                              ,pr_clob_ret OUT CLOB                            -- Tabela Historico
                              ,pr_cdcritic OUT PLS_INTEGER                     -- Codigo Erro
                              ,pr_dscritic OUT VARCHAR2                        -- Descricao Erro
                              );
  -- Fim -- PRJ406


PROCEDURE pc_processa_tributos (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Cooperativa
                                 ,pr_nrdconta IN  crapass.nrdconta%TYPE  -- Número da conta
                                 ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                                 ,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- CPF do operador PJ
                                 ,pr_idorigem IN  INTEGER                -- Canal de origem da operação
                                 ,pr_flmobile IN  INTEGER                -- Indicador de requisição via canal Mobile
                                 ,pr_idefetiv IN  INTEGER                -- Indicador de efetivação da operação de pagamento
                                 ,pr_tpdaguia IN  INTEGER                -- Tipo da guia ((3-FGTS/4-DAE)
                                 ,pr_tpcaptur IN  INTEGER                -- Tipo de captura da guia (1 – Código Barras / 2 – Manual: FGTS e DAE só arrecadarão pelo Código de Barras) 
                                 ,pr_lindigi1 IN  NUMBER                 -- Primeiro campo da linha digitável da guia
                                 ,pr_lindigi2 IN  NUMBER                 -- Segundo campo da linha digitável da guia
                                 ,pr_lindigi3 IN  NUMBER                 -- Terceiro campo da linha digitável da guia
                                 ,pr_lindigi4 IN  NUMBER                 -- Quarto campo da linha digitável da guia
                                 ,pr_cdbarras IN  VARCHAR2               -- Código de barras da guia
                                 ,pr_nrcpfcgc IN  VARCHAR2               -- CNPJ/CEI/CPF da guia
                                 ,pr_cdtribut IN  VARCHAR2               -- Código de tributação da guia
                                 ,pr_dtvencto IN  DATE                   -- Data da validade da guia
                                 ,pr_dtapurac IN  DATE                   -- Data de Competência da Guia
                                 ,pr_vlrtotal IN  NUMBER                 -- Valor total do pagamento da guia
                                 ,pr_nrrefere IN  VARCHAR2               -- Número de referência da guia("Identificador" quando FGTS, "Nr. Documento" quando DAE)
                                 ,pr_dsidepag IN  VARCHAR2               -- Descrição da identificação do pagamento
                                 ,pr_dtmvtopg IN  DATE                   -- Data do pagamento
                                 ,pr_idagenda IN  INTEGER                -- Indicador se é agendamento (1 – Nesta Data / 2 – Agendamento) 
                                 ,pr_vlapagar IN  NUMBER                 -- Valor total dos pagamentos
                                 ,pr_versaldo IN  INTEGER                -- Indicador de validação do saldo em relação ao valor total
                                 ,pr_tpleitor IN  INTEGER                -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                                 ,pr_iptransa IN VARCHAR2 DEFAULT NULL   -- IP da transação
                                 ,pr_iddispos IN VARCHAR2 DEFAULT NULL   -- Identificador do dispositivo mobile                                  
                                 ,pr_retxml  OUT CLOB                    -- Retorno XML da operação
                                 ,pr_dscritic OUT VARCHAR2);
                                 
PROCEDURE pc_det_cdbarras_fgts_dae(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_tpdaguia IN INTEGER               --> Tipo de operacao 3-FGTS, 4-DAE
                                    ,pr_cdbarras IN VARCHAR               --> codigo de barras
                                    ,pr_flmobile IN INTEGER DEFAULT 0     --> Identificador canal IB/Mobile
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB);                                 
                                 
END paga0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.paga0003 IS
  
 /*---------------------------------------------------------------------------------------------------------------
  
   Programa: PAGA0003
   Autor   : Dionathan
   Data    : 19/07/2016                        Ultima atualizacao: 18/10/2018
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necessárias para pagamento de guias DARF e DAS
  
   Alteracoes: 
	             
		   22/02/2017 - Alteraçoes para composiçao de comprovante DARF/DAS Modelo Sicredi
					  - Ajustes para correçao de crítica de pagamento DARF/DAS (P.349.2) (Lucas Lunelli)
							 								   
       08/05/2017 - Validar tributo através da tabela crapstb (Lucas Ranghetti #654763)
							 								   
       25/05/2017 - Se DEBSIC ja rodou, nao aceitamos mais agendamento para agendamentos em que o 
                    dia que antecede o final de semana ou feriado nacional(Lucas Ranghetti #671126)
                    
       22/08/2017 - Adicionar parametro para data de agendamento na pc_cria_comprovante_darf_das
                    para tambem gravar este campo no protocolo de agendamentos de DARF/DAS 
                    (Lucas Ranghetti #705465)
                    
       14/09/2017 - Adicionar no campo nrrefere como varchar2 (Lucas Ranghetti #756034)

       11/12/2017 - Alterar campo flgcnvsi por tparrecd.
                            PRJ406-FGTS (Odirlei-AMcom)    	 

       01/11/2017 - Validar corretamente o horario da debsic em caso de agendamentos
                    e também validar data do pagamento menor que o dia atual (Lucas Ranghetti #775900)

       05/01/2018 - Inclusão da rotina pc_gera_arrecadacao_bancoob
                    PRJ406-FGTS.

       14/02/2018 - Projeto Ligeirinho. Alterado para gravar na tabela de lotes (craplot) somente no final
                            da execução do CRPS509 => INTERNET E TAA. (Fabiano Girardi AMcom)
  
       19/02/2018 - Tratamento para validacao do pagamento de darf/das em caso que 
                    for através do processo JOB(Lucas Ranghetti #843167)

       12/04/2018 - Alterada chamada do processo de monitoracao para 
                    AFRA0004.pc_monitora_tributos
                    PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

       09/05/2018 - Incluido a chamada da rotina gen_debitador_unico.pc_qt_hora_prg_debitador
                    para atualizar a quantidade de execuções programadas no debitador
                    Projeto debitador único - Josiane Stiehler (AMcom)
					  
	     23/07/2018 - Fixado nome da cooperativa CECRED (paleativamente) devido problemas no processamento dos mesmos
			              no Bancoob. (Reinert)

	     16/08/2018 - Ajustado cursores da craptab para utilizar o Unique Key Index
                    na procedure pc_gera_arrecadacao_bancoob. (Reinert) 
										
			 18/10/2018 - Ajustado nome dos arquivos de arrecadação do Bancoob para AILOS. 
			            - Alterado layout dos arquivos de arrecadação do Bancoob. (Reinert)
						
	     16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

		 14/05/2019 - INC0015051 - Ajustada e padronizada mensagem de retorno quando uma guia de SEFAZ DARE for inserida nos campos de tributos 
                      indevidamente.
                      (f0032175 - Guilherme Kuhnen).
			 
		   05/06/2019 - Removido tratamento para arrecadar pagamentos de FGTS para apenas PAs com 2 digitos. (Reinert)
  ---------------------------------------------------------------------------------------------------------------*/

  -- Início -- PRJ406
  -- Tipo de registro linha
  TYPE typ_reg_linha IS RECORD
    (ds_registro VARCHAR2(400)
    ,id_rowid    ROWID
    );
  -- Tabela para tip de registro linha
  TYPE typ_tab_arquivo IS TABLE OF typ_reg_linha INDEX BY PLS_INTEGER;
  -- Tabela que contém o arquivo
  vr_index_arq   NUMBER := 0;
  vr_tab_arquivo typ_tab_arquivo;
  -- Fim -- PRJ406

  --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.tplotmov
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdhistor
           ,craplot.cdoperad
           ,craplot.qtcompln
           ,craplot.qtinfoln
           ,craplot.vlcompcr
           ,craplot.vlinfocr
           ,craplot.vlcompdb
           ,craplot.vlinfodb
           ,craplot.cdcooper
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote
    FOR UPDATE NOWAIT;

  rw_craplot cr_craplot%ROWTYPE;
  
  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut(pr_cdcooper IN crapaut.cdcooper%type
                   ,pr_cdagenci IN crapaut.cdagenci%type
                   ,pr_nrdcaixa IN crapaut.nrdcaixa%type
                   ,pr_dtmvtolt IN crapaut.dtmvtolt%type
                   ,pr_nrsequen IN crapaut.nrsequen%type) IS
    SELECT crapaut.cdcooper
          ,crapaut.dtmvtolt
          ,crapaut.cdagenci
          ,crapaut.nrdcaixa
          ,crapaut.vldocmto
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.cdopecxa
          ,crapaut.cdhistor
          ,crapaut.dsprotoc
          ,crapaut.nrdocmto
          ,crapaut.ROWID
    FROM crapaut crapaut
    WHERE crapaut.cdcooper = pr_cdcooper
    AND   crapaut.cdagenci = pr_cdagenci
    AND   crapaut.nrdcaixa = pr_nrdcaixa
    AND   crapaut.dtmvtolt = pr_dtmvtolt
    AND   crapaut.nrsequen = pr_nrsequen;

  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut_rowid(pr_rowid IN ROWID) IS
    SELECT crapaut.cdcooper
          ,crapaut.dtmvtolt
          ,crapaut.cdagenci
          ,crapaut.nrdcaixa
          ,crapaut.vldocmto
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.cdopecxa
          ,crapaut.cdhistor
          ,crapaut.dsprotoc
          ,crapaut.nrdocmto
          ,crapaut.ROWID
    FROM crapaut
    WHERE ROWID = pr_rowid;

  --Selecionar Informacoes Convenios
  CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                    ,pr_cdempcon IN crapcon.cdempcon%type
                    ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
    SELECT crapcon.flginter
          ,crapcon.nmextcon
          ,crapcon.tparrecd
          ,crapcon.cdhistor
          ,crapcon.nmrescon
          ,crapcon.cdsegmto
          ,crapcon.cdempcon
    FROM crapcon
    WHERE crapcon.cdcooper = pr_cdcooper
    AND   crapcon.cdempcon = pr_cdempcon
    AND   crapcon.cdsegmto = pr_cdsegmto;
  
    --Selecionar Cadastro Convenios Sicredi
    CURSOR cr_crapstb (pr_cdtribut IN crapstb.cdtribut%type) IS
      SELECT crapstb.cdtribut
      FROM crapstb
      WHERE crapstb.cdtribut = pr_cdtribut;
    rw_crapstb cr_crapstb%ROWTYPE;
  
 /* PROCEDURE pc_monitoracao_pagamento(pr_cdcooper crapcop.cdcooper%TYPE -- pr_cdcooper
                                    ,pr_nrdconta crapass.nrdconta%TYPE -- pr_nrdconta
                                    ,pr_idseqttl crapttl.idseqttl%TYPE -- pr_idseqttl
                                    ,pr_dtmvtocd crapdat.dtmvtocd%TYPE -- rw_crapdat.dtmvtocd
                                    ,pr_cdagenci crapage.cdagenci%TYPE -- vr_cdagenci
                                    ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 – Nesta Data / 2 – Agendamento)
                                    ,pr_vlfatura IN  NUMBER   -- Valor fatura
                                    ,pr_dscritic OUT VARCHAR2 -- Descriçao do erro
                                    ) IS
    \* .............................................................................

     Programa: pc_monitoracao_pagamento
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Objetivo  : Procedure de monitoração de pagamentos para evitar fraudes.

     Alteracoes: MOVIDA PARA AFRA0004  -- ### TJ
     
    ..............................................................................*\
  \** ------------------------------------------------------------- **
   ** Monitoracao Pagamentos - Antes de alterar verificar com David **
   ** ------------------------------------------------------------- **
   ** Envio de monitoracao sera enviado se for pagto via Internet,  **
   ** se nao for pagto via DDA, se nao for pagto proveniente de     **
   ** agendamento, se nao for boleto de cobranca registrada da      **
   ** cooperativa, se o valor individual ou total pago no dia pelo  **
   ** cooperado for maior que o limite estipulado para cooperativa  **
   ** atraves da tela PARMON no ayllos web.                         **
   ** exemplo: valor inicial monitoracao =   700,00                 **
   **          valor monitoracao IP      = 3.000,00                 **
   ** Será enviado email de monitoracao apenas quando:              **
   ** - Valor pago for maior ou igual a 3.000,00 independente do ip **
   ** - Valor pago for maior ou igual a 700,00 até 2.999,99 será    **
   ** verificado o IP anterior, caso seja diferente, envia email.   **
   ** ------------------------------------------------------------- **\
    
  -- Busca as informações da cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.dsdircop
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.nmrescop
          ,cop.vlinimon
          ,cop.vllmonip
          ,cop.nmextcop
          ,cop.flgofatr
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Selecionar a data de abertura da conta
  CURSOR cr_crapass(pr_cdcooper IN craplgm.cdcooper%TYPE
                   ,pr_nrdconta IN craplgm.nrdconta%type) IS
    SELECT ass.inpessoa
          ,ass.cdagenci
          ,age.nmresage
          ,ass.dtabtcct
      FROM crapass ass
          ,crapage age
     WHERE ass.cdcooper = age.cdcooper
       AND ass.cdagenci = age.cdagenci
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  --Selecionar os telefones do titular
  CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                    ,pr_nrdconta IN craptfc.nrdconta%type) IS
  SELECT tfc.nrdddtfc
        ,tfc.nrtelefo
    FROM craptfc tfc
   WHERE tfc.cdcooper = pr_cdcooper
     AND tfc.nrdconta = pr_nrdconta;
  
  -- Selecionar informacoes do titular
  CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                    ,pr_nrdconta IN crapttl.nrdconta%type
                    ,pr_idseqttl IN crapttl.idseqttl%type) IS
  SELECT ttl.nmextttl
        ,ttl.nrcpfcgc
        ,ttl.idseqttl
    FROM crapttl ttl
   WHERE ttl.cdcooper = pr_cdcooper
     AND ttl.nrdconta = pr_nrdconta
     AND ttl.idseqttl = pr_idseqttl;
  rw_crapttl cr_crapttl%ROWTYPE;
  
  -- Selecionar dados Pessoa Juridica
  CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                    ,pr_nrdconta IN crapjur.nrdconta%type) IS
  SELECT jur.nmextttl
    FROM crapjur jur
   WHERE jur.cdcooper = pr_cdcooper
     AND jur.nrdconta = pr_nrdconta;
  rw_crapjur cr_crapjur%ROWTYPE;
  
  -- Selecionar avalistas
  CURSOR cr_crapavt2(pr_cdcooper IN crapavt.cdcooper%type
                    ,pr_nrdconta IN crapavt.nrdconta%type
                    ,pr_tpctrato IN crapavt.tpctrato%type) IS
  SELECT NVL(ass.nmprimtl,avt.nmdavali) nmprepos -- Nome do Preposto
    FROM crapavt avt
        ,crapass ass
   WHERE avt.cdcooper = ass.cdcooper(+)
     AND avt.nrdctato = ass.nrdconta(+)
     AND avt.cdcooper = pr_cdcooper
     AND avt.nrdconta = pr_nrdconta
     AND avt.tpctrato = pr_tpctrato;

  rw_crapavt cr_crapavt2%ROWTYPE;
  
  -- Cursor para protocolos e lançamentos de DARF/DAS
  CURSOR cr_craplft(pr_cdcooper IN crappro.cdcooper%type
                   ,pr_cdagenci IN crapaut.cdagenci%type
                   ,pr_nrdconta IN crappro.nrdconta%type
                   ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE) IS
    SELECT pro.cdcooper
          ,pro.dtmvtolt
          ,pro.dscedent
          ,pro.dsprotoc
		  ,pro.dsinform##1
          ,pro.dsinform##2
		  ,pro.dsinform##3					
          ,pro.flgagend
          ,lft.vllanmto
          ,lft.cdbarras
		  ,TO_CHAR(lft.cdseqfat) cdseqfat
		  ,lft.dsnomfon
          ,pro.cdtippro
    FROM crappro pro
        ,crapaut aut
        ,craplft lft
   WHERE pro.cdcooper = pr_cdcooper
     AND pro.nrdconta = pr_nrdconta
     AND pro.dtmvtolt = pr_dtmvtolt
     AND pro.cdtippro IN (16, 17, 18, 19, 23, 24)
     
     AND aut.cdcooper = pro.cdcooper
     AND aut.dtmvtolt = pro.dtmvtolt
     AND aut.nrsequen = pro.nrseqaut
     AND UPPER(aut.dsprotoc) = UPPER(pro.dsprotoc)
     AND aut.cdagenci = pr_cdagenci
     AND aut.nrdcaixa = 900
     
     AND lft.cdcooper = aut.cdcooper
     AND lft.dtmvtolt = aut.dtmvtolt
     AND lft.cdagenci = aut.cdagenci
     AND lft.cdbccxlt = 11
     AND lft.nrdolote = 15900
     AND lft.nrseqdig = TO_NUMBER(aut.nrdocmto);
   
  --Selecionar informacoes log transacoes no sistema
  CURSOR cr_craplgm(pr_cdcooper IN craplgm.cdcooper%TYPE
                   ,pr_nrdconta IN craplgm.nrdconta%TYPE
                   ,pr_idseqttl IN craplgm.idseqttl%TYPE
                   ,pr_dttransa IN craplgm.dttransa%TYPE
                   ,pr_dsorigem IN craplgm.dsorigem%TYPE
                   ,pr_cdoperad IN craplgm.cdoperad%TYPE
                   ,pr_flgtrans IN craplgm.flgtrans%TYPE
                   ,pr_dstransa IN craplgm.dstransa%TYPE
                   ,pr_nmdcampo IN craplgi.nmdcampo%TYPE) IS
  SELECT lgm.cdcooper
        ,lgm.nrdconta
        ,lgm.idseqttl
        ,lgm.dttransa
        ,lgm.hrtransa
        ,lgm.nrsequen
        ,lgi.dsdadatu
        ,lgi.nmdcampo
    FROM craplgm lgm
        ,craplgi lgi
   WHERE lgi.cdcooper = lgm.cdcooper
     AND lgi.nrdconta = lgm.nrdconta
     AND lgi.idseqttl = lgm.idseqttl
     AND lgi.nrsequen = lgm.nrsequen
     AND lgi.dttransa = lgm.dttransa
     AND lgi.hrtransa = lgm.hrtransa
     AND lgm.cdcooper = pr_cdcooper
     AND lgm.nrdconta = pr_nrdconta
     AND lgm.idseqttl = pr_idseqttl
     AND lgm.dttransa = pr_dttransa
     AND lgm.dsorigem = pr_dsorigem
     AND lgm.cdoperad = pr_cdoperad
     AND lgm.flgtrans = pr_flgtrans
     AND lgm.dstransa = pr_dstransa
     AND lgi.nmdcampo = pr_nmdcampo
   ORDER BY lgm.progress_recid DESC;
    
  vr_datdodia DATE;
  vr_flgemail BOOLEAN;
  vr_vlpagtos NUMBER;
  vr_qtpagtos NUMBER := 0;
  vr_dspagtos VARCHAR2(4000);
  vr_qtidenti INTEGER;
  vr_dtlimite DATE;
  vr_nrdipatu VARCHAR2(1000);
  vr_nrdipant VARCHAR2(1000);
  vr_exec_lgm EXCEPTION;
  vr_conteudo VARCHAR2(4000);
  vr_des_assunto VARCHAR2(100);
  vr_email_dest  VARCHAR2(100);
  vr_tpcaptur INTEGER;
  
  vr_exc_erro EXCEPTION;
  
  BEGIN

    -- Apenas para pagamentos vis Internet e Nesta Data
    IF pr_cdagenci = 90 AND pr_idagenda = 1 THEN
        
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      --Buscar data do dia
      vr_datdodia:= trunc(sysdate); \*PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);*\
      
      --Flag email recebe true
      vr_flgemail:= TRUE;

      \** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
          esses pagtos para enviar no email **\
      IF vr_flgemail THEN
        --Zerar valor pagamentos
        vr_vlpagtos:= 0;
        vr_dspagtos:= NULL;

        -- Cursor para protocolos e lançamentos de DARF/DAS/FGTS/DAE
        FOR rw_craplft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtocd) LOOP
          --Acumular pagamentos
          vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craplft.vllanmto;
          vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;
          
          IF rw_craplft.cdtippro IN (23,24) THEN
            --Concatenar Descricao Pagamentos
            IF nvl(length(vr_dspagtos),0) < 2400 THEN
              vr_dspagtos:= vr_dspagtos ||
              rw_craplft.dsinform##1 ||' - '|| TRIM(rw_craplft.dsinform##2) || '<BR>' ||
              'Identificacao: ' || rw_craplft.dscedent || '<BR>' ||
              'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')||
              ' - Cod.Barras: '|| rw_craplft.cdbarras ||
              '<BR><BR>';
            END IF;
          
          ELSE
                    
		  vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, rw_craplft.dsinform##3, '#')), ':')));
			
		  IF vr_tpcaptur = 1 THEN  -- CDBARRA/LINDG
		  	--Concatenar Descricao Pagamentos
			IF nvl(length(vr_dspagtos),0) < 2400 THEN
				vr_dspagtos:= vr_dspagtos ||
				rw_craplft.dsinform##1 ||' - '|| TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(5, rw_craplft.dsinform##3, '#')), ':')) || '<BR>' ||
				'Identificacao: ' || TO_CHAR(nvl(rw_craplft.dsnomfon,' ')) || ' ' || rw_craplft.dscedent || '<BR>' ||
				'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')||
				' - Cod.Barras: '|| rw_craplft.cdbarras ||
				'<BR><BR>';
			END IF;
		  ELSE -- DARF Manual
			--Concatenar Descricao Pagamentos
			IF nvl(length(vr_dspagtos),0) < 2400 THEN
				vr_dspagtos:= vr_dspagtos ||
				rw_craplft.dsinform##1 ||' - '|| TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(5, rw_craplft.dsinform##3, '#')), ':')) || '<BR>' ||
				'Identificacao: ' || TO_CHAR(nvl(rw_craplft.dsnomfon,' ')) || ' ' || rw_craplft.dscedent || '<BR>' ||
				'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')  || 														
				' - Cod.Seq: '|| rw_craplft.cdseqfat ||
				'<BR><BR>';
			END IF;
		  END IF;
          END IF;
        END LOOP; --rw_craplft

        \** Verifica se o valor do pagto eh menor que o parametrizado
        e total pago no dia eh menor que o parametrizado**\
        IF pr_vlfatura < rw_crapcop.vlinimon AND
           vr_vlpagtos < rw_crapcop.vlinimon THEN
          --Flag email
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail

      IF vr_flgemail AND (pr_vlfatura < rw_crapcop.vllmonip) THEN
        --Selecionar ultimo log transacao sistema
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        vr_qtidenti:= 0;
        vr_dtlimite:= vr_datdodia;
        BEGIN
          WHILE vr_dtlimite >= rw_crapass.dtabtcct LOOP

            FOR rw_craplgm IN cr_craplgm(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dttransa => vr_dtlimite
                                        ,pr_dsorigem => 'INTERNET'
                                        ,pr_cdoperad => '996'
                                        ,pr_flgtrans => 1
                                        ,pr_dstransa => 'Efetuado login de acesso a conta on-line.'
                                        ,pr_nmdcampo => 'IP') LOOP
                                        
              IF TRIM(vr_nrdipatu) IS NULL THEN
                vr_nrdipatu := rw_craplgm.dsdadatu;
              ELSE
                IF TRIM(vr_nrdipant) IS NOT NULL THEN
                  vr_nrdipant := vr_nrdipant || ';';
                END IF;

                vr_nrdipant := vr_nrdipant || rw_craplgm.dsdadatu;
                vr_qtidenti := vr_qtidenti + 1;

              END IF;

              -- Verificar se foram identificados três IP
              IF vr_qtidenti >= 3 THEN
                RAISE vr_exec_lgm;
              END IF;
                
            END LOOP;-- Loop craplgm

            vr_dtlimite := vr_dtlimite - 1;

          END LOOP; -- Loop da data
        EXCEPTION
          -- Exception para quando encontrar os três registros de IP
          WHEN vr_exec_lgm THEN
            NULL;

          WHEN OTHERS THEN
            NULL;

        END;

        --Verificar se os ultimos IPs sao iguais
        IF GENE0002.fn_existe_valor(pr_base     => vr_nrdipant
                                   ,pr_busca    => vr_nrdipatu
                                   ,pr_delimite => ';') = 'S' THEN
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail

      \** Enviar email para monitoracao se passou pelos filtros **\
      IF vr_flgemail THEN
				
        vr_conteudo:= 'PA: '||rw_crapass.cdagenci||' - '||rw_crapass.nmresage;
        --Adicionar numero da conta na mensagem
        vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
				
        --Se for pessoa fisica
        IF rw_crapass.inpessoa = 1 THEN
          \** Lista todos os titulares **\

          FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl) LOOP
            --Concatenar Conteudo
            vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                       ': '||rw_crapttl.nmextttl|| '<BR>';
          END LOOP;

        ELSE
          \** Lista o nome da empresa **\

          OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          --Se Encontrou
          IF cr_crapjur%FOUND THEN
            --Concatenar o nome da empresa
            vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
          END IF;

          --Fechar Cursor
          CLOSE cr_crapjur;
          --Concatenar Procuradores/Representantes
          vr_conteudo:= vr_conteudo||'<BR><BR>'||
                        'Procuradores/Representantes: <BR>';
          \** Lista os procuradores/representantes **\
          FOR rw_crapavt IN cr_crapavt2 (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_tpctrato => 6) LOOP
              
            --Concatenar nome avalista
            vr_conteudo:= vr_conteudo||rw_crapavt.nmprepos|| '<BR>';

          END LOOP;

        END IF;

        -- Fones
        vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
        --Encontrar numeros de telefone
        FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          --Montar Conteudo
          vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '||
                                     rw_craptfc.nrtelefo|| '<BR>';
        END LOOP;

        --Concatenar Pagamentos
        vr_conteudo:= vr_conteudo|| '<BR>'|| vr_dspagtos;
        vr_conteudo:= vr_conteudo||'Quantidade pagto: '||to_char(vr_qtpagtos,'fm999G990')
                                 ||' Valor total: '||to_char(vr_vlpagtos,'fm999G999G999G999D00');


        --Determinar Assunto
        vr_des_assunto:= 'PAGTO DARF/DAS/FGTS/DAE '||rw_crapcop.nmrescop ||' '||
                         GENE0002.fn_mask_conta(pr_nrdconta)|| ' R$ '||
                         TRIM(to_char(pr_vlfatura,'fm999G999G999G999D00'));

        --Buscar destinatario email
        vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'INTERNETBANK_PAGTO');
        --Se nao encontrou destinatario
        IF vr_email_dest IS NULL THEN
          --Montar mensagem de erro
          pr_dscritic:= 'Nao foi encontrado destinatario para os pagamentos via InternetBank.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Enviar Email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => 'INTERNETBANK' --> Programa conectado
                                  ,pr_des_destino     => vr_email_dest --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                                  ,pr_des_erro        => pr_dscritic);  --> Descricao Erro
        --Se ocorreu erro
        IF pr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;  
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF pr_dscritic IS NULL THEN
        pr_dscritic := 'Erro ao gerar monitoracao de pagamento DARF/DAS.';
      END IF;
  END; */
  
  PROCEDURE pc_cria_comprovante_tributos(pr_cdcooper IN  crapcop.cdcooper%TYPE -- Código da cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Número da conta
                                        --,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                                        ,pr_nmextttl IN crapttl.nmextttl%TYPE  -- Nome do Titular
                                        ,pr_nrcpfope IN NUMBER                 -- CPF do operador PJ
                                        ,pr_nrcpfpre IN NUMBER                 -- Número pré operação
                                        ,pr_nmprepos IN VARCHAR2               -- Nome Preposto
                                        --,pr_tpdaguia IN INTEGER                -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)
                                        ,pr_tpcaptur IN INTEGER                -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                        ,pr_cdtippro IN crappro.cdtippro%TYPE  -- Código do tipo do comprovante
                                        ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE  -- Data de movimento da autenticação
                                        ,pr_hrautent IN crapaut.hrautent%TYPE  -- Horário da autenticação
                                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  -- Número do documento
                                        ,pr_nrseqaut IN crapaut.nrsequen%TYPE  -- Sequencial da autenticação
                                        ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  -- Número do caixa da autenticação
                                        ,pr_idorigem IN INTEGER                -- Indicador de canal de origem  da transação
                                        ,pr_nmconven IN crapcon.nmextcon%TYPE  -- Nome do convênio da guia
                                        ,pr_lindigi1 IN NUMBER                 -- Primeiro campo da linha digitável da guia
                                        ,pr_lindigi2 IN NUMBER                 -- Segundo campo da linha digitável da guia
                                        ,pr_lindigi3 IN NUMBER                 -- Terceiro campo da linha digitável da guia
                                        ,pr_lindigi4 IN NUMBER                 -- Quarto campo da linha digitável da guia
                                        ,pr_cdbarras IN VARCHAR2               -- Código de barras da guia
                                        ,pr_dsidepag IN VARCHAR2               -- Descrição da identificação do pagamento
                                        ,pr_vlrtotal IN NUMBER                 -- Valor total do pagamento da guia
                                        ,pr_dsnomfon IN VARCHAR2               -- Nome e telefone da guia
                                        ,pr_dtapurac IN DATE                   -- Período de apuração da guia
                                        ,pr_nrcpfcgc IN VARCHAR2               -- CPF/CNPJ da guia
                                        ,pr_cdtribut IN VARCHAR2               -- Código de tributação da guia
                                        ,pr_nrrefere IN VARCHAR2               -- Número de referência da guia
                                        ,pr_dtvencto IN DATE                   -- Data de vencimento da guia
                                        ,pr_vlrprinc IN NUMBER                 -- Valor principal da guia
                                        ,pr_vlrmulta IN NUMBER                 -- Valor da multa da guia
                                        ,pr_vlrjuros IN NUMBER                 -- Valor dos juros da guia
                                        ,pr_vlrecbru IN NUMBER                 -- Valor da receita bruta acumulada da guia
                                        ,pr_vlpercen IN NUMBER                 -- Valor do percentual da guia
                                        ,pr_flgagend IN BOOLEAN                -- Indicador de agendamento (TRUE – Agendamento / FALSE – Nesta Data)
                                        ,pr_cdtransa IN VARCHAR2               -- Código da transação por meio de arrecadação do SICREDI
                                        ,pr_dssigemp IN VARCHAR2               -- Descrição resumida de convênio DARF para autenticação modelo SICREDI
                                        ,pr_dtagenda IN DATE DEFAULT NULL      -- Data do agendamento
                                        ,pr_dsprotoc OUT crappro.dsprotoc%TYPE -- Descrição do protocolo do comprovante
                                        ,pr_cdcritic OUT INTEGER               -- Código do erro
                                        ,pr_dscritic OUT VARCHAR2              -- Descriçao do erro
                                        ) IS
    /* .............................................................................

     Programa: pc_cria_comprovante_darf_das
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 03/01/2018

     Objetivo  : Procedure para criação de comprovantes de pagamento de DARF/DAS

     Alteracoes:  22/08/2017 - Adicionar parametro para data de agendamento na pc_cria_comprovante_darf_das
                               para tambem gravar este campo no protocolo de agendamentos de DARF/DAS 
                               (Lucas Ranghetti #705465)
                               
                  03/01/2018 - Renomeado rotina de pc_cria_comprovante_darf_das para pc_cria_comprovante_tributos, e incluido 
                               tratativas para arrecadação de FGTS/DAE. PRJ406-FGTS (Odirlei-AMcom)
                               
    ..............................................................................*/
    
    CURSOR cr_arrec(pr_cddbanco crapagb.cddbanco%TYPE
                   ,pr_cdageban crapagb.cdageban%TYPE) IS
    SELECT ban.cdbccxlt || ' - ' || ban.nmextbcc nmextbcc
          ,to_char(agb.cdageban,'fm0000') || ' - ' || agb.nmageban nmageban
      FROM crapban ban
          ,crapagb agb
     WHERE ban.cdbccxlt = agb.cddbanco
       AND ban.cdbccxlt = pr_cddbanco
       AND agb.cdageban = pr_cdageban;
    rw_arrec cr_arrec%ROWTYPE;
  
		CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
			SELECT cop.cdcooper
						,cop.cdagesic
				FROM crapcop cop
				WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
	vr_inpessoa INTEGER;
	vr_stsnrcal BOOLEAN;		
	vr_cdempcon crapcon.cdempcon%TYPE;
	vr_cdsegmto	crapcon.cdsegmto%TYPE;
    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##2%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;
    vr_dsretorn VARCHAR2(500) := '';
	  vr_dsautsic VARCHAR2(500) := '';
	vr_nrrefere VARCHAR2(500) := '';
    vr_exc_erro EXCEPTION;
  
    vr_nrinsemp VARCHAR2(20);
    vr_nrdocmto NUMBER;
    vr_nrrecolh NUMBER;
    vr_dtcompet DATE;
    vr_dtvencto DATE;
    vr_vldocmto NUMBER;
    vr_nrsqgrde NUMBER;
    
    
  
  BEGIN
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;  
	
	vr_cdempcon := SUBSTR(pr_cdbarras, 16, 4);
    vr_cdsegmto := SUBSTR(pr_cdbarras, 2, 1);
			
	vr_inpessoa := 0;				
    IF LENGTH(pr_nrcpfcgc) = 11 THEN -- CPF
	   vr_inpessoa := 1;
	ELSIF LENGTH(pr_nrcpfcgc) = 14 THEN-- CNPJ
  	   vr_inpessoa := 2; 	
	END IF;
	
    --Título do comprovante
    vr_dsinfor1 := CASE pr_cdtippro
                     WHEN 16 THEN 'DARF'
                     WHEN 17 THEN 'DAS'
                     WHEN 18 THEN 'Agendamento de DARF'
                     WHEN 19 THEN 'Agendamento de DAS'
                     WHEN 23 THEN 'DAE'
                     WHEN 24 THEN 'Recolhimento FGTS'
                     ELSE ''
                    END;
    
    -- Nome do Titular
    vr_dsinfor2 := pr_nmextttl;
    
	IF pr_nrrefere <> '0' THEN
		vr_nrrefere := pr_nrrefere;
	END IF;
    
    
    --################## DADOS DO COMPROVANTE ##################
    
    --> DARF/DAS
    IF pr_cdtippro BETWEEN 16 AND 19 THEN
    
    -- Busca as informações do banco/agencia arrecadador (Sicredi - Matriz)
    OPEN cr_arrec(pr_cddbanco => 748
                 ,pr_cdageban => 0100);
    FETCH cr_arrec INTO rw_arrec;
    CLOSE cr_arrec;
    
    vr_dsinfor3 := vr_dsinfor3 || 'Tpcaptura: '              || TO_CHAR(pr_tpcaptur);
    vr_dsinfor3 := vr_dsinfor3 || '#Solicitante: '            || pr_nmextttl;
    vr_dsinfor3 := vr_dsinfor3 || '#Agente Arrecadador: '    || rw_arrec.nmextbcc;
    vr_dsinfor3 := vr_dsinfor3 || '#Agência: '               || rw_arrec.nmageban;
    vr_dsinfor3 := vr_dsinfor3 || '#Tipo de Documento: '     || pr_nmconven;
    vr_dsinfor3 := vr_dsinfor3 || '#Nome/Telefone: '         || pr_dsnomfon;
    
    -- Se for Captura via Código de Barras
    IF pr_tpcaptur = 1 THEN
    
      vr_dsinfor3 := vr_dsinfor3 || '#Código de Barras: '		|| pr_cdbarras;
      vr_dsinfor3 := vr_dsinfor3 || '#Linha Digitável: '		||  REPLACE(to_char(pr_lindigi1, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi2, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi3, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi4, 'fm00000000000G0'),'.','-');
      
      vr_dsinfor3 := vr_dsinfor3 || '#Data de Vencimento: '		|| TO_CHAR(pr_dtvencto,'DD/MM/YYYY');
			
      --Apenas para DAS
      IF pr_cdtippro IN (17, 19) THEN
         vr_dsinfor3 := vr_dsinfor3 || '#Número Documento (DAS): '	|| SUBSTR(pr_cdbarras,25,17);
	  ELSE
		 -- Apenas para DARF 385
		 IF vr_cdempcon = 385 AND
			 vr_cdsegmto = 5   THEN
			 vr_dsinfor3 := vr_dsinfor3 || '#Número Documento (DARF): '	|| SUBSTR(pr_cdbarras,25,17);
 		 END IF;
      END IF;
      
    -- Se for Captura Manual
    ELSIF pr_tpcaptur = 2 THEN

      vr_dsinfor3 := vr_dsinfor3 || '#Período de Apuração: '    || TO_CHAR(pr_dtapurac,'DD/MM/YYYY');
      vr_dsinfor3 := vr_dsinfor3 || '#Número do CPF ou CNPJ: '  || TO_CHAR(gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,vr_inpessoa));
      vr_dsinfor3 := vr_dsinfor3 || '#Código da Receita: '      || LPAD(pr_cdtribut, 4, '0');
      
      IF pr_cdtribut = '6106' THEN
        vr_dsinfor3 := vr_dsinfor3 || '#Valor da Receita Bruta: ' || TO_CHAR(pr_vlrecbru,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
        vr_dsinfor3 := vr_dsinfor3 || '#Percentual: '             || TO_CHAR(pr_vlpercen,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      ELSE
        vr_dsinfor3 := vr_dsinfor3 || '#Número de Referência: '   || vr_nrrefere;
        vr_dsinfor3 := vr_dsinfor3 || '#Data de Vencimento: '     || TO_CHAR(pr_dtvencto,'DD/MM/YYYY');
      END IF;
      
      vr_dsinfor3 := vr_dsinfor3 || '#Valor Principal: '        || TO_CHAR(pr_vlrprinc,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Valor da Multa: '         || TO_CHAR(pr_vlrmulta,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Valor dos Juros e/ou Encargos DL-1025/69: ' || TO_CHAR(pr_vlrjuros,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      
    END IF;
    
    vr_dsinfor3 := vr_dsinfor3 || '#Valor Total: '            || TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
    vr_dsinfor3 := vr_dsinfor3 || '#Descrição do Pagamento: ' || pr_dsidepag;
    
		-- Composição de autenticação conforme comprovante do modelo do SICREDI
		IF pr_tpcaptur = 2 THEN --Apenas para captura manual (InternetBanking e Tela VERPRO)
				
				vr_dsautsic := 	'BCS'                                                                  ||
							          '000892'                                                               ||
							          LPAD(rw_crapcop.cdagesic, 6, '0')                                      ||
							          'IB'                                                                   ||
							          TO_CHAR(pr_vlrtotal,'FM9G999999999990D00','NLS_NUMERIC_CHARACTERS=.,') ||
							          'RR'                                                                   ||
							          TO_CHAR(pr_dtmvtolt,'DD/MM/YYYY')                                      ||
							          pr_cdtransa                                                            ||										 
							          pr_dssigemp                                                            ;
			  vr_dsinfor3 := vr_dsinfor3 || '#Autenticação Sicredi: ' || vr_dsautsic;
				
		END IF;
    
    -- Caso for agendamento de DARF ou DAS
    IF pr_cdtippro IN(18,19) THEN
      -- Gravar a data do agendamento
      vr_dsinfor3 := vr_dsinfor3 || '#Data do Agendamento: ' || nvl(to_char(pr_dtagenda,'DD/MM/YYYY'),' ');
    END IF;
    
    --> FGTS
    ELSIF pr_cdtippro IN (24) THEN

      -- Busca as informações do banco/agencia arrecadador (756 - BANCO COOPERATIVO DO BRASIL S.A.)
      OPEN cr_arrec(pr_cddbanco => 756
                   ,pr_cdageban => 1);
      FETCH cr_arrec INTO rw_arrec;
      CLOSE cr_arrec;
      
      paga0003.pc_extrai_cdbarras_fgts_dae 
                                     ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                      ,pr_cdbarras => pr_cdbarras --> Codigo de barras
                                              
                                      ---- OUT ----
                                      ,pr_cdempcon => vr_cdempcon --> Retorna numero da empresa conveniada
                                      ,pr_nrinsemp => vr_nrinsemp --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                      ,pr_nrdocmto => vr_nrdocmto --> Numero do documento
                                      ,pr_nrrecolh => vr_nrrecolh --> Numero identificado de recolhimento
                                      ,pr_dtcompet => vr_dtcompet --> Data da competencia
                                      ,pr_dtvencto => vr_dtvencto --> Data de vencimento/validade
                                      ,pr_vldocmto => vr_vldocmto --> Valor do documento
                                      ,pr_nrsqgrde => vr_nrsqgrde --> Sequencial da GRDE 
                                                            
                                      ,pr_dscritic => pr_dscritic); --> Critica
    
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
      vr_dsinfor3 := vr_dsinfor3 || 'Tipo de Documento: '  || pr_nmconven;
      vr_dsinfor3 := vr_dsinfor3 || '#Agente Arrecadador: ' || rw_arrec.nmextbcc;
      vr_dsinfor3 := vr_dsinfor3 || '#Código de Barras: '		|| pr_cdbarras;
      vr_dsinfor3 := vr_dsinfor3 || '#Linha Digitável: '		||  REPLACE(to_char(pr_lindigi1, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi2, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi3, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi4, 'fm00000000000G0'),'.','-');
                                    
      --> Modelo 3
      IF vr_cdempcon NOT IN (0239,0451) THEN
        vr_dsinfor3 := vr_dsinfor3 || '#CNPJ/CEI Empresa: '  || vr_nrinsemp;
      END IF;
      
      vr_dsinfor3 := vr_dsinfor3 || '#Cod. Convênio: '     || vr_cdempcon;
      vr_dsinfor3 := vr_dsinfor3 || '#Data da Validade: '  || TO_CHAR(pr_dtvencto,'DD/MM/YYYY');
      
      --> Modelo 1  
      IF vr_cdempcon IN (0179,0180,0181) THEN
        vr_dsinfor3 := vr_dsinfor3 || '#Competência: '     || to_char(vr_dtcompet,'MM/RRRR');
      
      --> Modelo 2 -GRDE
      ELSIF vr_cdempcon IN (0178,0240) THEN
        vr_dsinfor3 := vr_dsinfor3 || '#Competência: '     || to_char(vr_nrsqgrde,'FM000');
      
      --> Modelo 3
      ELSIF vr_cdempcon IN (0239,0451) THEN
        vr_dsinfor3 := vr_dsinfor3 || '#Identificador: '   || pr_nrrefere;
        
      END IF;
      
      vr_dsinfor3 := vr_dsinfor3 || '#Valor Total: '       || TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Descrição do Pagamento: ' || pr_dsidepag;
      vr_dsinfor3 := vr_dsinfor3 || '#Data do Pagamento: ' || TO_CHAR(pr_dtmvtolt,'DD/MM/YYYY');
      vr_dsinfor3 := vr_dsinfor3 || '#Horario do Pagamento: ' || to_char(to_date(pr_hrautent,'SSSSS'),'HH24:MI:SS');
      vr_dsinfor3 := vr_dsinfor3 || '#Canal de Recebimento: ' || pr_idorigem;
    
    
    --> DAE
    ELSIF pr_cdtippro IN (23) THEN
    
      -- Busca as informações do banco/agencia arrecadador (756 - BANCO COOPERATIVO DO BRASIL S.A.)
      OPEN cr_arrec(pr_cddbanco => 756
                   ,pr_cdageban => 1);
      FETCH cr_arrec INTO rw_arrec;
      CLOSE cr_arrec;
      
      vr_dsinfor3 := vr_dsinfor3 || 'Tipo de Documento: '  || pr_nmconven;
      vr_dsinfor3 := vr_dsinfor3 || '#Agente Arrecadador: ' || 'CNC '||rw_arrec.nmextbcc;
      
      
      vr_dsinfor3 := vr_dsinfor3 || '#Código de Barras: '		|| pr_cdbarras;
      vr_dsinfor3 := vr_dsinfor3 || '#Linha Digitável: '		||  REPLACE(to_char(pr_lindigi1, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi2, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi3, 'fm00000000000G0'),'.','-') || ' ' ||
                                  REPLACE(to_char(pr_lindigi4, 'fm00000000000G0'),'.','-');
                                          
      vr_dsinfor3 := vr_dsinfor3 || '#Número de documento(DAE): '   || pr_nrrefere;
            
      vr_dsinfor3 := vr_dsinfor3 || '#Valor Total: '       || TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Descrição do Pagamento: ' || pr_dsidepag;
      vr_dsinfor3 := vr_dsinfor3 || '#Data do Pagamento: ' || to_char(pr_dtmvtolt,'DD/MM/YYYY');
      vr_dsinfor3 := vr_dsinfor3 || '#Horario do Pagamento: ' || to_char(to_date(pr_hrautent,'SSSSS'),'HH24:MI:SS');
      vr_dsinfor3 := vr_dsinfor3 || '#Canal de Recebimento: ' || pr_idorigem;
    
    END IF; --> Fim IF pr_cdtippro  
    
    --################## FIM DOS DADOS DO COMPROVANTE ##################
    
    -- Procedure para gerar protocolos de segurança com criptografia MD5 */
    gene0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_hrtransa => pr_hrautent
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdocmto => pr_nrdocmto
                                  ,pr_nrseqaut => pr_nrseqaut
                                  ,pr_vllanmto => pr_vlrtotal
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_gravapro => TRUE
                                  ,pr_cdtippro => pr_cdtippro
                                  ,pr_dsinfor1 => vr_dsinfor1
                                  ,pr_dsinfor2 => vr_dsinfor2
                                  ,pr_dsinfor3 => vr_dsinfor3
                                  ,pr_dscedent => pr_dsidepag
                                  ,pr_flgagend => pr_flgagend
                                  ,pr_nrcpfope => pr_nrcpfope
                                  ,pr_nrcpfpre => pr_nrcpfpre
                                  ,pr_nmprepos => pr_nmprepos
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_dscritic => pr_dscritic
                                  ,pr_des_erro => vr_dsretorn);
                                  
    -- Se retornou erro, gera critica
    IF pr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
       IF pr_dscritic IS NULL THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao gerar Comprovante de Pagamento de tributos: '||SQLERRM;
       END IF;
  END pc_cria_comprovante_tributos;

  PROCEDURE pc_valid_pag_menu_trib ( pr_cdbarras  IN VARCHAR2 -- Código de barras da guia
                                    ,pr_flmobile  IN INTEGER  -- identificador mobile
                                    ,pr_tpdaguia  IN INTEGER  -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)  
                                    ,pr_dscritic OUT VARCHAR2 -- retorna critica
                                   ) IS
  /* ..........................................................................

      Programa : pc_valid_pag_menu_trib
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Dezembro/2017                        Ultima atualizacao: 26/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Validar se esta realizando pagamento do tributo na opcao do menu correta.

      Alteracoes: 

    .................................................................................*/
    
    --Variaveis Locais
    vr_cdempcon  crapcon.cdempcon%TYPE; -- Código do convênio
    vr_cdsegmto  crapcon.cdsegmto%TYPE; -- Código do segmento
    vr_tpguibar  INTEGER;               -- tp guia do codbarras
    vr_dstpguia  VARCHAR2(100);
    
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(2000);
  
  BEGIN
  
    -- Obtém o convênio a partir do código de barras
    vr_cdempcon := SUBSTR(pr_cdbarras, 16, 4);
    vr_cdsegmto := SUBSTR(pr_cdbarras, 2, 1);
    vr_tpguibar := 0;
  
    --> Garantir que não considere uma outra modalidade
    IF vr_cdsegmto IN (5) AND 
       SUBSTR(pr_cdbarras, 1, 1) = 8 THEN
    
      --> Identificar o tipo de convenio que consta no codigo de barras
      CASE
        WHEN vr_cdempcon IN (64, 153, 154, 385) THEN
          vr_tpguibar := 1; --> DARF
          vr_dstpguia := 'DARF';
        WHEN vr_cdempcon IN (328) THEN
          vr_tpguibar := 2; --> DAS
          vr_dstpguia := 'DAS';
        WHEN vr_cdempcon IN (0178,0179,0180,0181,0239,0240,0451) THEN
          vr_tpguibar := 3; --> FGTS
          vr_dstpguia := 'FGTS';
        WHEN vr_cdempcon IN (0432) THEN
          vr_tpguibar := 4; --> DAE
          vr_dstpguia := 'DAE';
        ELSE
          vr_tpguibar := 0;
      END CASE;
    END IF;
       
    IF vr_tpguibar <>  pr_tpdaguia THEN
      IF pr_flmobile = 1 THEN -- Canal Mobile
        vr_dscritic := vr_dstpguia ||' deve ser paga na opção ''Tributos - '||vr_dstpguia ||''' do menu de serviços';
      ELSE -- Conta Online
        vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Boletos Diversos'' do menu de serviços.'; --INC0015051
      END IF;
      
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF; 
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel verificar cod. barras: '||SQLERRM;        
      
  END;
  
  PROCEDURE pc_valid_dig_GRF (pr_nrrefere   IN VARCHAR2,
                              pr_dscritic  OUT VARCHAR2)IS
  /* ..........................................................................

      Programa : pc_valid_dig_GRF
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Dezembro/2017                        Ultima atualizacao: 26/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Validar digito do identificador FGTS - GRF.

      Alteracoes: 

    .................................................................................*/
    
    ----------------> CURSORES <---------------    
	
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <---------------   
    vr_nrrefere VARCHAR2(20);
    vr_nrdepeso NUMBER;    
    vr_nrresult NUMBER;
    vr_nrdigito INTEGER;
    
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(2000);
    
    
    FUNCTION fn_calc_parte (pr_nrrefere  IN VARCHAR2,
                            pr_nrdepeso  IN NUMBER
                            ) RETURN NUMBER IS
      vr_numero     NUMBER;
      vr_nrrefere_p VARCHAR2(20);
      vr_nrdepeso_p NUMBER;    
      vr_nrresult_p NUMBER := 0;
      vr_dig        NUMBER;
      
      
    BEGIN
      vr_nrrefere_p := pr_nrrefere;
      vr_nrdepeso_p := pr_nrdepeso;
      
      --> varrer numeros do identidicadore
      FOR i IN 1..length(vr_nrrefere_p) LOOP
        --> extrair numero a numero
        vr_numero := substr(vr_nrrefere_p,i,1);  
      
        vr_nrresult_p := vr_nrresult_p + (vr_numero * vr_nrdepeso_p);
        
        --> peso deverá ser decrementado até atingir peso 2
        --> e deve ser reinicializado em 9
        IF vr_nrdepeso_p = 2 THEN
          vr_nrdepeso_p := 9;
        ELSE         
          vr_nrdepeso_p := vr_nrdepeso_p - 1; 
        END IF;
        
      END LOOP;
      
      --> Resto da divisao por 11
      vr_dig := MOD(vr_nrresult_p, 11); 
      
      -- Cfe manual, caso seja 0 ou 1, deve retornar zero
      IF vr_dig IN (0,1) THEN
        vr_dig := 0;    
      ELSE
        vr_dig := 11 - vr_dig;
      END IF;
      
      RETURN vr_dig;
    
    END fn_calc_parte;
    
  BEGIN
      
    IF TRIM(pr_nrrefere) IS NULL THEN
      vr_dscritic := 'Identificador não informado.';
      RAISE vr_exc_erro;
    END IF; 
   
    --> Extrair as primeiras 14 pos
    vr_nrrefere := substr(lpad(pr_nrrefere,16,0),1,14);
    
    --> CALCULAR PRIMEIRO NUMERO DO DIGITO    
    vr_nrdigito := fn_calc_parte (pr_nrrefere  => vr_nrrefere,
                                  pr_nrdepeso  => 7);--> peso iniciara em 7
    
    
    --> CALCULAR Segundo NUMERO DO DIGITO    
    vr_nrrefere := vr_nrrefere || vr_nrdigito;
    
    vr_nrdigito := fn_calc_parte (pr_nrrefere  => vr_nrrefere,
                                  pr_nrdepeso  => 8);--> peso iniciara em 7
    
                                  
    vr_nrrefere := vr_nrrefere || vr_nrdigito;
    
    IF vr_nrrefere <> pr_nrrefere THEN  
      vr_dscritic := 'Identificador informado é inválido.';
      RAISE vr_exc_erro;
    END IF;  
    
  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao validar dig. GRF: '||SQLERRM;
    
  END pc_valid_dig_GRF;
  
  
  PROCEDURE pc_verifica_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
                                ,pr_idorigem IN INTEGER -- Canal de origem da operação
                                ,pr_tpdaguia IN INTEGER               -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)
                                ,pr_tpcaptur IN NUMBER -- Tipo de captura da guia (1-Código Barras / 2-Manual)
                                ,pr_lindigi1 IN OUT NUMBER -- Primeiro campo da linha digitável da guia
                                ,pr_lindigi2 IN OUT NUMBER -- Segundo campo da linha digitável da guia
                                ,pr_lindigi3 IN OUT NUMBER -- Terceiro campo da linha digitável da guia
                                ,pr_lindigi4 IN OUT NUMBER -- Quarto campo da linha digitável da guia
                                ,pr_cdbarras IN OUT VARCHAR2 -- Código de barras da guia
                                ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                ,pr_dtapurac IN DATE -- Período de apuração da guia
                                ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                ,pr_cdtribut IN VARCHAR2 -- Código de tributação da guia
                                ,pr_nrrefere IN VARCHAR2 -- Número de referência da guia
                                ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                ,pr_idagenda IN INTEGER -- Indicador de agendamento (1-Nesta Data/2-Agendamento
                                ,pr_dtagenda IN DATE -- Data de agendamento
                                ,pr_indvalid IN INTEGER -- Indicador de controle de validações (1-Operação Online/2-Operação Batch)
								                ,pr_flmobile IN INTEGER -- Indicador Mobile
                                ,pr_cdseqfat OUT VARCHAR2 -- Código sequencial da guia
                                ,pr_vldocmto OUT NUMBER -- Valor da guia
                                ,pr_nrdigfat OUT NUMBER -- Digito do faturamento
                                ,pr_cdcritic OUT INTEGER -- Código do erro
                                ,pr_dscritic OUT VARCHAR2 -- Descriçao do erro
                                 ) IS
    /* .............................................................................

     Programa: pc_verifica_tributos
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 19/02/2018

     Objetivo  : Procedure para validação de pagamento de DARF/DAS

     Alteracoes: 08/05/2017 - Validar tributo através da tabela crapstb (Lucas Ranghetti #654763)

     --          31/05/2017 - Regra para alertar o usuário quando tentar pagar um GPS na modalidade de 
     --                       DARF apresentando a seguinte mensagem: GPS deve ser paga na opção 
     --                       Transações - GPS do menu de serviços. (Rafael Monteiro - Mouts)     
       
                 14/09/2017 - Adicionar no campo nrrefere como varchar2 (Lucas Ranghetti #756034)
   
	 --          02/10/2017 - Alteração da mensagem de validação de pagamento GPS (prj 356.2 - Ricardo Linhares)

                 28/12/2017 - Renomeado rotina de .pc_verifica_darf_das  para pc_verifica_tributos,
                              e realizado ajuste para validação depagamento de FGTS/DAE.
                              PRJ406-FGTS (Odirlei-AMcom)
      
               19/02/2018 - Tratamento para validacao do pagamento de darf/das em caso que 
                            for através do processo JOB(Lucas Ranghetti #843167)
                              
               16/07/2019 - Remoção de validação que não permitia agendar DARF com data de apuração
                            anterior a 1 mês (João Mannes - RITM0023757)
    ..............................................................................*/
    
    --Selecionar contas migradas
    CURSOR cr_craptco(pr_cdcopant IN craptco.cdcopant%TYPE
                     ,pr_nrctaant IN craptco.nrctaant%TYPE
                     ,pr_tpctatrf IN craptco.tpctatrf%TYPE) IS
      SELECT craptco.cdcopant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcopant
         AND craptco.nrctaant = pr_nrctaant
         AND craptco.tpctatrf = pr_tpctatrf;
    rw_craptco       cr_craptco%ROWTYPE;
    cr_craptco_found BOOLEAN := FALSE;
  
    --Selecionar Informacoes Convenios
    CURSOR cr_crapcon(pr_cdcooper IN crapcon.cdcooper%TYPE
                     ,pr_cdempcon IN crapcon.cdempcon%TYPE
                     ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
      SELECT crapcon.flginter
            ,crapcon.nmextcon
            ,crapcon.tparrecd
            ,crapcon.cdhistor
            ,crapcon.nmrescon
            ,crapcon.cdsegmto
            ,crapcon.cdempcon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;
    
    --Selecionar erro
    CURSOR cr_craperr (pr_cdcooper IN craperr.cdcooper%type
                      ,pr_cdagenci IN craperr.cdagenci%type
                      ,pr_nrdcaixa IN craperr.nrdcaixa%type) IS
      SELECT craperr.dscritic
      FROM  craperr
      WHERE craperr.cdcooper = pr_cdcooper
      AND   craperr.cdagenci = pr_cdagenci
      AND   craperr.nrdcaixa = pr_nrdcaixa
      ORDER BY craperr.progress_recid ASC;
    rw_craperr cr_craperr%ROWTYPE;
    cr_craperr_found BOOLEAN := FALSE;
    
    -- Busca as transações pendentes com o mesmo sequencial de fatura
    -- OBS: Apenas para quando a captura for através da linha digitavel
    CURSOR cr_trans_pend (pr_dtmvtopg IN DATE
                         ,pr_cdhistor IN NUMBER
                         ,pr_cdseqfat IN NUMBER
						 ,pr_tpdaguia IN NUMBER) IS
    SELECT 1
      FROM tbpagto_darf_das_trans_pend darf_das
          ,tbgen_trans_pend            pend
     WHERE pend.cdtransacao_pendente = darf_das.cdtransacao_pendente
       AND pend.idorigem_transacao = pr_idorigem
       AND pend.idsituacao_transacao IN (1, 5) /* Pendente */
       AND darf_das.tppagamento = pr_tpdaguia
       AND darf_das.cdcooper = pr_cdcooper
       AND darf_das.dtdebito = pr_dtmvtopg
       AND cxon0014.fn_busca_sequencial_fatura(pr_cdhistor
                                              ,darf_das.dscod_barras) = pr_cdseqfat;
    rw_trans_pend cr_trans_pend%ROWTYPE;
    cr_trans_pend_found BOOLEAN := FALSE;
    
    -- Busca as transações pendentes com o mesmo sequencial de fatura
    -- OBS: Apenas para quando a captura for através da linha digitavel
    CURSOR cr_trans_pend_trib ( pr_cdcooper IN INTEGER
                               ,pr_idorigem IN INTEGER   
                               ,pr_dtmvtopg IN DATE
                               ,pr_cdhistor IN NUMBER
                               ,pr_cdseqfat IN NUMBER
                               ,pr_tpdaguia IN NUMBER) IS
    SELECT 1
      FROM tbpagto_tributos_trans_pend trib
          ,tbgen_trans_pend            pend
     WHERE pend.cdtransacao_pendente = trib.cdtransacao_pendente
       AND pend.idorigem_transacao = pr_idorigem
       AND pend.idsituacao_transacao IN (1, 5) -- Pendente 
       AND trib.tppagamento = pr_tpdaguia
       AND trib.cdcooper = pr_cdcooper
       AND trib.dtdebito = pr_dtmvtopg
       AND cxon0014.fn_busca_sequencial_fatura(pr_cdhistor
                                              ,trib.dscod_barras) = pr_cdseqfat
                                              ;
    rw_trans_pend_trib cr_trans_pend_trib%ROWTYPE;
    cr_trans_pend_trib_found BOOLEAN := FALSE;
    
    
    --Selecionar lancamentos automaticos que estiverem pendentes para o mesmo sequencial informado
    CURSOR cr_craplau_pend (pr_cdcooper IN craplau.cdcooper%type
                           ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE
                           ,pr_cdhistor IN crapcon.cdhistor%TYPE
                           ,pr_cdseqfat IN NUMBER) IS
    SELECT 1
      FROM craplau lau
          ,tbpagto_agend_darf_das darf_das
     WHERE lau.idlancto = darf_das.idlancto
       AND lau.cdagenci = 90
       AND lau.cdbccxlt = 100
       AND lau.nrdolote = 11900
       AND lau.insitlau IN (1,2)
       AND LENGTH(lau.dslindig) = 55
       AND lau.cdcooper = pr_cdcooper
       AND lau.dtmvtopg = pr_dtmvtopg
       AND cxon0014.fn_busca_sequencial_fatura(pr_cdhistor
                                              ,darf_das.dscod_barras) = pr_cdseqfat;
    rw_craplau_pend cr_craplau_pend%ROWTYPE;
    cr_craplau_pend_found BOOLEAN := FALSE;
    
    --Selecionar lancamentos automaticos que estiverem pendentes para o mesmo sequencial informado
    CURSOR cr_craplau_trib_pend ( pr_cdcooper IN craplau.cdcooper%type
                                 ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE
                                 ,pr_cdhistor IN crapcon.cdhistor%TYPE
                                 ,pr_cdseqfat IN NUMBER) IS
    SELECT 1
      FROM craplau lau
          ,tbpagto_agend_tributos trib
     WHERE lau.idlancto = trib.idlancto AND
           lau.cdagenci = 90
       AND lau.cdbccxlt = 100
       AND lau.nrdolote = 11900
       AND lau.insitlau IN (1,2)
       AND LENGTH(lau.dslindig) = 55
       AND lau.cdcooper = pr_cdcooper
       AND lau.dtmvtopg = pr_dtmvtopg
       AND cxon0014.fn_busca_sequencial_fatura(pr_cdhistor
                                              ,trib.dscod_barras) = pr_cdseqfat;
    rw_craplau_trib_pend cr_craplau_trib_pend%ROWTYPE;
    cr_craplau_trib_pend_found BOOLEAN := FALSE;
    
    -- Busca as transações pendentes
    -- OBS: Apenas para quando a captura for através da digitação dos campos da guia
    CURSOR cr_trans_pend2(pr_dtmvtopg IN tbpagto_darf_das_trans_pend.dtdebito%TYPE
                         ,pr_cdseqfat IN NUMBER
						 ,pr_tpdaguia IN NUMBER) IS
    SELECT 1
      FROM tbpagto_darf_das_trans_pend darf_das
          ,tbgen_trans_pend            pend
     WHERE pend.cdtransacao_pendente = darf_das.cdtransacao_pendente
       AND pend.idorigem_transacao = pr_idorigem
       AND pend.idsituacao_transacao IN (1, 5) /* Pendente */
       AND darf_das.tppagamento = pr_tpdaguia
       AND darf_das.cdcooper = pr_cdcooper
       AND darf_das.dtdebito = pr_dtmvtopg
       AND cxon0041.fn_busca_sequencial_darf(pr_dtapurac => darf_das.dtapuracao -- Data da Apuracao
                                            ,pr_nrcpfcgc => darf_das.nrcpfcgc -- CPF/CNPJ
                                            ,pr_cdtribut => darf_das.cdtributo -- Codigo do Tributo
                                            ,pr_dtlimite => darf_das.dtvencto -- Data de Limite
                                            ,pr_vlrtotal => darf_das.vlpagamento -- Valor Total
                                            ) = pr_cdseqfat;
    rw_trans_pend2 cr_trans_pend2%ROWTYPE;
    cr_trans_pend2_found BOOLEAN := FALSE;
    
    --Selecionar lancamentos automaticos que estiverem pendentes para o mesmo sequencial informado
    CURSOR cr_craplau_pend2(pr_cdcooper IN craplau.cdcooper%type
                           ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE
                           ,pr_cdseqfat IN NUMBER) IS
    SELECT 1
      FROM craplau lau
          ,tbpagto_agend_darf_das darf_das
     WHERE lau.idlancto = darf_das.idlancto
       AND lau.cdagenci = 90
       AND lau.cdbccxlt = 100
       AND lau.nrdolote = 11900
       AND lau.insitlau IN (1,2)
       AND lau.cdcooper = pr_cdcooper
       AND lau.dtmvtopg = pr_dtmvtopg
       AND cxon0041.fn_busca_sequencial_darf(pr_dtapurac => darf_das.dtapuracao -- Data da Apuracao
                                            ,pr_nrcpfcgc => darf_das.nrcpfcgc -- CPF/CNPJ
                                            ,pr_cdtribut => darf_das.cdtributo -- Codigo do Tributo
                                            ,pr_dtlimite => darf_das.dtvencto -- Data de Limite
                                            ,pr_vlrtotal => lau.vllanaut -- Valor Total
                                            ) = pr_cdseqfat;
    rw_craplau_pend2 cr_craplau_pend%ROWTYPE;
    cr_craplau_pend2_found BOOLEAN := FALSE;
                
    --Variaveis Locais
    vr_cdempcon  crapcon.cdempcon%TYPE; -- Código do convênio
    vr_cdsegmto  crapcon.cdsegmto%TYPE; -- Código do segmento
    vr_flagiptu  BOOLEAN;
    vr_cdoperad  VARCHAR2(100);
    vr_dsblqage  VARCHAR2(100);
    vr_cdagenci  NUMBER;
    vr_nrdcaixa  NUMBER;
    vr_dtmvtopg  DATE;
    vr_datdodia  DATE;
	vr_dttolera  DATE;
    vr_foco      VARCHAR2(3);    
    vr_dtminage  DATE;    
	vr_lindigit  NUMBER;
    vr_nrdigito  INTEGER;
	vr_flgretor  BOOLEAN;
    vr_idagenda  INTEGER;

    --Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
  
  BEGIN
    
    --Seta a Agência e Caixa
    vr_cdagenci := 90; -- InternetBank
    vr_nrdcaixa := 900;
    
    -- Obtém a data de movimento cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
		
	--Se a captura for através do código de barras da guia
    IF pr_tpcaptur = 1 THEN	
	  /* Verifica se foi digitado manualmente ou via leitora de cod. barras */
	  IF trim(pr_cdbarras) IS NULL AND nvl(pr_lindigi1,0) <> 0 AND nvl(pr_lindigi2,0) <> 0 THEN
	    --Montar Codigo Barras
	    pr_cdbarras:= SUBSTR(gene0002.fn_mask(pr_lindigi1,'999999999999'),1,11)||
	                  SUBSTR(gene0002.fn_mask(pr_lindigi2,'999999999999'),1,11)||
	                  SUBSTR(gene0002.fn_mask(pr_lindigi3,'999999999999'),1,11)||
	                  SUBSTR(gene0002.fn_mask(pr_lindigi4,'999999999999'),1,11);
	  ELSIF trim(pr_cdbarras) IS NOT NULL AND nvl(pr_lindigi1,0) = 0 AND nvl(pr_lindigi2,0) = 0 AND
	        nvl(pr_lindigi3,0) = 0 AND nvl(pr_lindigi4,0) = 0 THEN
	
	    /* Monta os campos manuais e pega o digito */
	    FOR idx IN 1..4 LOOP
	
	      --Retornar o valor de cada parametro
	      CASE idx
	        WHEN 1 THEN
	          pr_lindigi1:= TO_NUMBER(SUBSTR(pr_cdbarras,1,11));
	          vr_lindigit:= pr_lindigi1;
	        WHEN 2 THEN
	          pr_lindigi2:= TO_NUMBER(SUBSTR(pr_cdbarras,12,11));
	          vr_lindigit:= pr_lindigi2;
	        WHEN 3 THEN
	          pr_lindigi3:= TO_NUMBER(SUBSTR(pr_cdbarras,23,11));
	          vr_lindigit:= pr_lindigi3;
	        WHEN 4 THEN
	          pr_lindigi4:= TO_NUMBER(SUBSTR(pr_cdbarras,34,11));
	          vr_lindigit:= pr_lindigi4;
	      END CASE;
	
	      --Verificar qual o modulo de calculo do digito
	      IF SUBSTR(pr_cdbarras,3,1) IN ('6','7') THEN
	        /** Verificacao pelo modulo 10**/
	        CXON0000.pc_calc_digito_iptu_samae (pr_valor    => vr_lindigit   --> Valor Calculado
	                                           ,pr_nrdigito => vr_nrdigito   --> Digito Verificador
	                                           ,pr_retorno  => vr_flgretor); --> Retorno digito correto
	      ELSE
	        /** Verificacao pelo modulo 11 **/
	        CXON0014.pc_verifica_digito (pr_nrcalcul => vr_lindigit  --Numero a ser calculado
					                    ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
	                                    ,pr_nrdigito => vr_nrdigito); --Digito verificador
	      END IF;
	
	      --Retornar parametro digitavel
	      CASE idx
	        WHEN 1 THEN
	          pr_lindigi1:= TO_NUMBER(gene0002.fn_mask(pr_lindigi1,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));
	        WHEN 2 THEN
	          pr_lindigi2:= TO_NUMBER(gene0002.fn_mask(pr_lindigi2,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));
	        WHEN 3 THEN
	          pr_lindigi3:= TO_NUMBER(gene0002.fn_mask(pr_lindigi3,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));
	        WHEN 4 THEN
	          pr_lindigi4:= TO_NUMBER(gene0002.fn_mask(pr_lindigi4,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));
	      END CASE;
	    END LOOP;
	  END IF;
	END IF;		
    --Se for Agendamento
    IF pr_idagenda = 2 THEN
    
      /** Verificar se a conta pertence a um PAC migrado **/
      OPEN cr_craptco(pr_cdcopant => pr_cdcooper
                     ,pr_nrctaant => pr_nrdconta
                     ,pr_tpctatrf => 1);
      --Posicionar no proximo registro
      FETCH cr_craptco
        INTO rw_craptco;
      cr_craptco_found := cr_craptco%FOUND;
      CLOSE cr_craptco;
    
      IF cr_craptco_found THEN
        --Buscar data do dia
        vr_datdodia := TRUNC(SYSDATE);
        /** Bloquear agendamentos para conta migrada **/
        vr_dsblqage := gene0001.fn_param_sistema('CRED'
                                                ,pr_cdcooper
                                                ,'DT_BLOQ_AGEN_CTA_MIGRADA');
        --Se nao encontrou
        IF vr_dsblqage IS NULL THEN
          --Montar Critica
          vr_dscritic := 'Parametro de Data de Bloqueio de agendamento de conta migrada não encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Data do dia maior limite
        IF vr_datdodia >= to_date(vr_dsblqage, 'DD/MM/YYYY') AND
           rw_craptco.cdcopant NOT IN (4, 15) THEN
          --Montar Critica
          vr_dscritic := 'Operacao de agendamento bloqueada. Entre em contato com seu PA.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- Seta a data para a data agendada
      vr_dtmvtopg := pr_dtagenda;
    ELSE -- Se não for agendamento
      vr_dtmvtopg := rw_crapdat.dtmvtocd;
    END IF;
  
    --Se a captura for através do código de barras da guia
    IF pr_tpcaptur = 1 THEN
    
      -- Obtém o convênio a partir do código de barras
      vr_cdempcon := SUBSTR(pr_cdbarras, 16, 4);
      vr_cdsegmto := SUBSTR(pr_cdbarras, 2, 1);
            
      -- Se não for uma DARF/DAS/FGTS/DAE  válida
      IF vr_cdempcon NOT IN (64, 153, 154, 328, 385) AND                  -- DARF/DAS
         vr_cdempcon NOT IN (0178,0179,0180,0181,0239,0240,0451,0432) AND -- FGTS/DAE 
         vr_cdsegmto NOT IN (5) THEN
      
        -- GPS -- Convênio 270 e Segmento 5
        IF vr_cdempcon = 270 AND vr_cdsegmto = 5 THEN
					IF pr_flmobile = 1 THEN -- Canal Mobile
												vr_dscritic := 'Pagamento de GPS deve ser pago na opção ''Pagamentos - GPS.';
					ELSE -- Conta Online
									vr_dscritic := 'GPS deve ser paga na opção ''Transações - GPS'' do menu de serviços.';
					END IF;
        
        -- CONVÊNIO - Se o primeiro dígito do código de barras for 8
        ELSIF SUBSTR(pr_cdbarras, 0, 1) = 8 THEN
          vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Boletos Diversos'' do menu de serviços.'; --INC0015051
        
        -- BOLETO - Se não cair em nenhuma condição anterior
        ELSE
          vr_dscritic := 'Boleto deve ser pago na opção ''Transações - Pagamentos'' do menu de serviços';
        END IF;
      
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca o convênio na CRAPCON
      OPEN cr_crapcon(pr_cdcooper => pr_cdcooper
                     ,pr_cdempcon => vr_cdempcon
                     ,pr_cdsegmto => vr_cdsegmto);
      FETCH cr_crapcon
        INTO rw_crapcon;
      CLOSE cr_crapcon;
    
      --Verifica se o convênio existe
      IF rw_crapcon.cdempcon IS NULL THEN
        vr_dscritic := 'Convênio não cadastrado. Procure seu Posto de Atendimento para mais informações.';
        RAISE vr_exc_erro;
      END IF;
    
      --Verifica se o convênio está liberado para pagamento via internet
      IF pr_idorigem = 3 AND rw_crapcon.flginter <> 1 THEN
        vr_dscritic := 'Este convênio não está habilitado para pagamento via internet.';
        RAISE vr_exc_erro;
      END IF;
      
      --> validar se esta pagando tributo na opcao correta. 
      pc_valid_pag_menu_trib ( pr_cdbarras  => pr_cdbarras   -- Código de barras da guia
                              ,pr_flmobile  => pr_flmobile   -- Indicador Mobile
                              ,pr_tpdaguia  => pr_tpdaguia   -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)  
                              ,pr_dscritic  => vr_dscritic); -- retorna critica
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
        END IF;
    
      
      /* DARF PRETO EUROPA */
      IF rw_crapcon.cdempcon IN (64,153) AND rw_crapcon.cdsegmto = 5 THEN /* DARFC0064  ou DARFC0153*/
        /* Validacao Cd. Tributo */
        --Selecionar Cadastro Convenios Sicredi
        OPEN cr_crapstb (pr_cdtribut => TO_NUMBER(SUBSTR(pr_cdbarras,37,4)));
        --Posicionar no proximo registro
        FETCH cr_crapstb INTO rw_crapstb;
        --Se nao encontrar
        IF cr_crapstb%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapstb;
          --Mensagem erro
          vr_dscritic:= 'Tributo nao cadastrado.';          
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapstb;
      END IF;
      
      --> Validar identificador FGTS - GRF
      IF rw_crapcon.cdempcon IN ('0181') AND rw_crapcon.cdsegmto = 5 THEN 
         pc_valid_dig_GRF (pr_nrrefere  => pr_nrrefere,
                           pr_dscritic  => vr_dscritic);
                           
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
         
      END IF;
      
      -- Validação referente aos dias de tolerancia
      cxon0014.pc_verifica_dtlimite_tributo(pr_cdcooper      => pr_cdcooper
                                           ,pr_cdagenci      => vr_cdagenci
                                           ,pr_cdempcon      => rw_crapcon.cdempcon
                                           ,pr_cdsegmto      => rw_crapcon.cdsegmto
                                           ,pr_codigo_barras => pr_cdbarras
                                           ,pr_dtmvtopg      => vr_dtmvtopg
                                           ,pr_flnrtole      => TRUE                                           
										                       ,pr_dttolera      => vr_dttolera
                                           ,pr_cdcritic      => vr_cdcritic
                                           ,pr_dscritic      => vr_dscritic);
                                           
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Obtem o código do operador
      IF pr_idagenda = 2 THEN -- Agendamento
        vr_cdoperad:= '1000';
      ELSIF pr_indvalid = 2 THEN -- Pagto. agendamento
        vr_cdoperad:= '1001';
      ELSE
        vr_cdoperad:= '996';
      END IF;
      
      /* Retornar valores fatura */
      CXON0014.pc_retorna_valores_fatura (pr_cdcooper      => pr_cdcooper  --Codigo Cooperativa
                                         ,pr_nrdconta      => pr_nrdconta     --Numero da Conta
                                         ,pr_idseqttl      => pr_idseqttl     --Sequencial Titular
                                         ,pr_cod_operador  => vr_cdoperad     --Codigo Operador
                                         ,pr_cod_agencia   => vr_cdagenci     --Codigo Agencia
                                         ,pr_nro_caixa     => vr_nrdcaixa     --Numero Caixa
                                         ,pr_fatura1       => pr_lindigi1     --Parte 1 fatura
                                         ,pr_fatura2       => pr_lindigi2     --Parte 2 fatura
                                         ,pr_fatura3       => pr_lindigi3     --Parte 3 fatura
                                         ,pr_fatura4       => pr_lindigi4     --Parte 4 fatura
                                         ,pr_codigo_barras => pr_cdbarras     --Codigo barras                                         
                                         ,pr_cdseqfat      => pr_cdseqfat     --Sequencial faturamento
                                         ,pr_vlfatura      => pr_vldocmto     --Valor Fatura
                                         ,pr_nrdigfat      => pr_nrdigfat     --Digito Faturamento
                                         ,pr_iptu          => vr_flagiptu     --Indicador IPTU
                                         ,pr_cdcritic      => vr_cdcritic     --Codigo do erro
                                         ,pr_dscritic      => vr_dscritic);   --Descricao do erro
      
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        /* verifica o erro retornado */
        --Selecionar primeiro erro
        OPEN cr_craperr (pr_cdcooper => pr_cdcooper
                        ,pr_cdagenci => vr_cdagenci
                        ,pr_nrdcaixa => To_Number(pr_nrdconta||pr_idseqttl));
        FETCH cr_craperr INTO rw_craperr;
        cr_craperr_found := cr_craperr%FOUND;
        CLOSE cr_craperr;
        
        IF cr_craperr_found THEN
          vr_dscritic:= rw_craperr.dscritic;
        ELSE
          vr_dscritic:= 'Não foi possível concluir a validação. Procure seu Posto de Atendimento para mais informações.';
        END IF;
        
        RAISE vr_exc_erro;
      END IF;
      
      --Verifica se o valor informado é diferente do valor do documento
      IF pr_vldocmto <> pr_vlrtotal THEN
         vr_dscritic := 'O valor a pagar informado difere do valor total do documento.';
         RAISE vr_exc_erro;
      END IF;
      
      -- Se for uma operação online
      IF pr_indvalid = 1 THEN
      
        --> Convenio sicredi
        IF rw_crapcon.tparrecd = 1 THEN
      
        --Selecionar transações pendentes de operador jurídico
        OPEN cr_trans_pend(pr_dtmvtopg => vr_dtmvtopg
                          ,pr_cdhistor => rw_crapcon.cdhistor
                          ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat) --Sequencial faturamento
						  ,pr_tpdaguia => pr_tpdaguia); 
        FETCH cr_trans_pend INTO rw_trans_pend;
        cr_trans_pend_found := cr_trans_pend%FOUND;
        CLOSE cr_trans_pend;
        
        --Se encontrar transação pendente dispara exceção
        IF cr_trans_pend_found THEN
          vr_dscritic:= 'Esta guia já foi registrada para aprovação.';
          RAISE vr_exc_erro;
        END IF;
        --> Bancoob  
        ELSIF rw_crapcon.tparrecd = 2 THEN
          --Selecionar transações pendentes de operador jurídico
          OPEN cr_trans_pend_trib( pr_cdcooper => pr_cdcooper
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_dtmvtopg => vr_dtmvtopg
                                  ,pr_cdhistor => rw_crapcon.cdhistor
                                  ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat) --Sequencial faturamento
                                  ,pr_tpdaguia => pr_tpdaguia); 
          FETCH cr_trans_pend_trib INTO rw_trans_pend_trib;
          cr_trans_pend_trib_found := cr_trans_pend_trib%FOUND;
          CLOSE cr_trans_pend_trib;
          
          --Se encontrar transação pendente dispara exceção
          IF cr_trans_pend_trib_found THEN
            vr_dscritic:= 'Esta guia já foi registrada para aprovação.';
            RAISE vr_exc_erro;
      END IF;
      
        END IF;  
        
      END IF;
      
      -- Se for um agendamento
      IF pr_idagenda = 2 THEN
        
        --> Convenio sicredi
        IF rw_crapcon.tparrecd = 1 THEN
        
        -- Verifica se ja existe fatura agendada com o sequencial
        OPEN cr_craplau_pend (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtopg => pr_dtagenda
                             ,pr_cdhistor => rw_crapcon.cdhistor
                             ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat));
        FETCH cr_craplau_pend
        INTO rw_craplau_pend;
        cr_craplau_pend_found := cr_craplau_pend%FOUND;
        CLOSE cr_craplau_pend;
          
        --Se a encontrou agendamento com o mesmo sequencial aborta
        IF cr_craplau_pend_found THEN
          vr_dscritic:= 'O pagamento desta guia já está agendando.';
          RAISE vr_exc_erro;
        END IF;
        
        --> Bancoob  
        ELSIF rw_crapcon.tparrecd = 2 THEN
        
          -- Verifica se ja existe fatura agendada com o sequencial
          OPEN cr_craplau_trib_pend (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtopg => pr_dtagenda
                               ,pr_cdhistor => rw_crapcon.cdhistor
                               ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat));
          FETCH cr_craplau_trib_pend
          INTO rw_craplau_trib_pend;
          cr_craplau_trib_pend_found := cr_craplau_trib_pend%FOUND;
          CLOSE cr_craplau_trib_pend;
            
          --Se a encontrou agendamento com o mesmo sequencial aborta
          IF cr_craplau_trib_pend_found THEN
            vr_dscritic:= 'O pagamento desta guia já está agendando.';
            RAISE vr_exc_erro;
      END IF;
    
        END IF;
      END IF;
    
    ELSIF pr_tpcaptur = 2 THEN -- Se a captura for através da digitação dos campos da guia
      
      -- Verifica se é agendamento
      IF pr_idagenda = 2 THEN
        -- Se a data de agendamento for maior que a data de vencimento dispara exceção
        IF pr_dtagenda > pr_dtvencto THEN
           vr_dscritic := 'A data de efetivação do pagamento não pode ser superior ao vencimento da guia.';
           RAISE vr_exc_erro;
        END IF;
      END IF;
      
      IF pr_indvalid = 2 THEN
        vr_idagenda:= 2; -- se for atraves do processo vamos validar como agendamento
      ELSE
        vr_idagenda:= pr_idagenda;
      END IF;
      
      -- Verificar regras gerais para pagamento da guia
      cxon0041.pc_valida_pagamento_darf(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                       ,pr_cdagenci => vr_cdagenci -- Codigo do PA
                                       ,pr_nrdcaixa => vr_nrdcaixa -- Numero do Caixa
                                       ,pr_cdtribut => pr_cdtribut -- Codigo do Tributo
                                       ,pr_nrcpfcgc => pr_nrcpfcgc -- Numero do CPF/CNPJ
                                       ,pr_dtapurac => pr_dtapurac -- Data de Apuracao
                                       ,pr_dtlimite => pr_dtvencto -- Data Limite
                                       ,pr_cdrefere => pr_nrrefere -- Codigo de Referencia
                                       ,pr_vlrecbru => pr_vlrecbru -- Valor da receita bruta acumulada.
                                       ,pr_vlpercen => pr_vlpercen -- Valor Percentual da guia
                                       ,pr_vllanmto => pr_vlrprinc -- Valor de Lancamento
                                       ,pr_vlrmulta => pr_vlrmulta -- Valor de Multa
                                       ,pr_vlrjuros => pr_vlrjuros -- Valor de Juros
                                       ,pr_idagenda => vr_idagenda -- Indentificador de Agendamento
                                       ,pr_foco     => vr_foco
                                       ,pr_cdseqfat => pr_cdseqfat -- Codigo Sequencial da DARF
                                       ,pr_cdcritic => vr_cdcritic -- Codigo do erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao do erro
      
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN        
        RAISE vr_exc_erro;
      END IF;
      
      -- Se for uma operação online
      IF pr_indvalid = 1 THEN
        -- Verifica se a guia já consta nas transações pendentes do operador de pessoa jurídica
        OPEN cr_trans_pend2(pr_dtmvtopg => vr_dtmvtopg
                           ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat) --Sequencial faturamento
						               ,pr_tpdaguia => pr_tpdaguia); 
        FETCH cr_trans_pend2
        INTO rw_trans_pend2;
        cr_trans_pend2_found := cr_trans_pend2%FOUND;
        CLOSE cr_trans_pend2;
        
        --Se encontrar transação pendente dispara exceção
        IF cr_trans_pend2_found THEN
          vr_dscritic:= 'Esta guia já foi registrada para aprovação.';
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- Se for um agendamento
      IF pr_idagenda = 2 THEN
        -- Verifica se ja existe fatura agendada com o sequencial
        OPEN cr_craplau_pend2(pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtopg => vr_dtmvtopg
                             ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat));
        FETCH cr_craplau_pend2
        INTO rw_craplau_pend2;
        cr_craplau_pend2_found := cr_craplau_pend2%FOUND;
        CLOSE cr_craplau_pend2;
          
        --Se a encontrou agendamento com o mesmo sequencial aborta
        IF cr_craplau_pend2_found THEN
          vr_dscritic:= 'O pagamento desta guia já está agendando.';
          RAISE vr_exc_erro;
        END IF;        
        
      END IF;
      
    END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PAGA0003.pc_verifica_tributos. ' ||
                     SQLERRM;
  END pc_verifica_tributos;

  PROCEDURE pc_paga_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE	-- Código da cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE	-- Número da conta
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE	-- Sequencial de titularidade
                            ,pr_nrcpfope IN NUMBER	-- CPF do operador PJ
                            ,pr_idorigem IN INTEGER	-- Canal de origem da operação
                            ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 – DARF / 2 – DAS / 3-FGTS / 4-DAE )
                            ,pr_tpcaptur IN INTEGER	-- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                            ,pr_cdseqfat IN VARCHAR2 -- Código sequencial da guia
                            ,pr_nrdigfat IN NUMBER  -- Dígito do faturamento
                            ,pr_lindigi1 IN NUMBER	-- Primeiro campo da linha digitável da guia
                            ,pr_lindigi2 IN NUMBER	-- Segundo campo da linha digitável da guia
                            ,pr_lindigi3 IN NUMBER	-- Terceiro campo da linha digitável da guia
                            ,pr_lindigi4 IN NUMBER	-- Quarto campo da linha digitável da guia
                            ,pr_cdbarras IN VARCHAR2	-- Código de barras da guia
                            ,pr_dsidepag IN VARCHAR2	-- Descrição da identificação do pagamento
                            ,pr_vlrtotal IN NUMBER	-- Valor total do pagamento da guia
                            ,pr_dsnomfon IN VARCHAR2	-- Nome e telefone da guia
                            ,pr_dtapurac IN DATE		-- Período de apuração da guia
                            ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                            ,pr_cdtribut IN VARCHAR2  -- Código de tributação da guia
                            ,pr_nrrefere IN VARCHAR2  -- Número de referência da guia
                            ,pr_dtvencto IN DATE		-- Data de vencimento da guia
                            ,pr_vlrprinc IN NUMBER	-- Valor principal da guia
                            ,pr_vlrmulta IN NUMBER	-- Valor da multa da guia
                            ,pr_vlrjuros IN NUMBER	-- Valor dos juros da guia
                            ,pr_vlrecbru IN NUMBER	-- Valor da receita bruta acumulada da guia
                            ,pr_vlpercen IN NUMBER	-- Valor do percentual da guia
                            ,pr_vldocmto IN NUMBER  -- Valor da guia
                            ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 – Nesta Data / 2 – Agendamento)
                            ,pr_tpleitor IN INTEGER	-- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                            ,pr_flgagend INTEGER     DEFAULT 0 /*1-True,0-False*/  --Flag se é uma efetivação de agendamento
                            ,pr_flmobile IN INTEGER  DEFAULT 0    -- Identificador de mobile
                            ,pr_iptransa IN VARCHAR2 DEFAULT NULL -- IP da transação
                            ,pr_iddispos IN VARCHAR2 DEFAULT NULL -- Identificador do dispositivo mobile    
                            ,pr_dsprotoc OUT VARCHAR2 --Descricao Protocolo
                            ,pr_cdcritic OUT INTEGER	-- Código do erro
                            ,pr_dscritic OUT VARCHAR2	-- Descriçao do erro
                            ) IS
    /* .............................................................................

     Programa: pc_paga_tributos
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 03/09/2018

     Objetivo  : Procedure para efetivação de pagamento de DARF/DAS

     Alteracoes: 14/09/2017 - Adicionar no campo nrrefere como varchar2 (Lucas Ranghetti #756034)
     
                 02/01/2018 - Renomeada rotina de pc_paga_darf_das para pc_paga_tributos, 
                              e realizado ajustes para pagamento de FGTS/DAE. 
                              PRJ406-FGTS(Odirlei-AMcom)
                              
                 12/04/2018 - Alterada chamada do processo de monitoracao para 
                              AFRA0004.pc_monitora_tributos
                              (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

			     28/06/2018 - Remover carateceres especiais ao inserir na craplcm, para o campo dscedent.
				              (Alcemir - Mout's) - PRB0040107.

				 03/09/2018 - Correção para remover lote (Jonata - Mouts).
    ..............................................................................*/
    CURSOR cr_crappod(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE)IS
    SELECT pod.cdcooper
          ,pod.nrdconta
          ,pod.nrcpfpro
          ,snh.idseqttl
      FROM crappod pod
          ,crapsnh snh
     WHERE pod.cdcooper = snh.cdcooper
       AND pod.nrdconta = snh.nrdconta
       AND pod.nrcpfpro = snh.nrcpfcgc
       AND pod.cddpoder = 10
       AND pod.flgconju = 1
       AND snh.tpdsenha = 1
       AND pod.cdcooper = pr_cdcooper
       AND pod.nrdconta = pr_nrdconta;
    
		CURSOR cr_crapscn(pr_cdempres crapscn.cdempres%TYPE,
		                  pr_tpmeiarr crapstn.tpmeiarr%TYPE)IS
    SELECT scn.cdempres
		      ,scn.dsnomcnv
		      ,scn.dssigemp
		      ,stn.cdtransa
      FROM crapscn scn,
		       crapstn stn
     WHERE scn.cdempres = pr_cdempres
		   AND stn.cdempres = scn.cdempres
		   AND stn.tpmeiarr = pr_tpmeiarr;
    rw_crapscn cr_crapscn%ROWTYPE;
    
    --Busca o associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_idseqttl crapttl.idseqttl%TYPE) IS
    -- Pessoa Fídica
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,ass.dtabtcct
					,ass.idastcjt
          ,ttl.nmextttl
          ,NULL nrcpfpre
          ,NULL nmprepos
      FROM crapass ass
          ,crapttl ttl
     WHERE ass.cdcooper = ttl.cdcooper
       AND ass.nrdconta = ttl.nrdconta
       AND ass.inpessoa = 1 -- Pessoa Física
       
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl
    UNION ALL
    -- Pessoa Jurídica
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,ass.dtabtcct
					,ass.idastcjt
          ,ass.nmprimtl nmextttl
          ,snh.nrcpfcgc nrcpfpre -- CPF do Preposto
          ,NVL(ass2.nmprimtl,avt.nmdavali) nmprepos -- Nome do Preposto
      FROM crapass ass
          ,crapsnh snh
          ,crapavt avt
          ,crapass ass2
       -- Obtém o registro de senha da internet do primeiro titular
     WHERE snh.cdcooper(+) = ass.cdcooper
       AND snh.nrdconta(+) = ass.nrdconta
       AND snh.idseqttl(+) = 1 -- Primeiro Titular
       AND snh.tpdsenha(+) = 1 -- Internet
       
       -- Obtem o Avalista Jurídico a partir do CPF do primeiro titular
       AND avt.cdcooper(+) = snh.cdcooper
       AND avt.nrdconta(+) = snh.nrdconta
       AND avt.nrcpfcgc(+) = snh.nrcpfcgc
       AND avt.tpctrato(+) = 6 -- Jur
       
       -- Caso o avalista for cooperado, obtém seus dados na tabela CRAPASS
       AND ass2.cdcooper(+) = avt.cdcooper
       AND ass2.nrdconta(+) = avt.nrdctato
       
       AND ass.inpessoa <> 1 -- Pessoa Jurídica
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ROWNUM = 1;
    rw_crapass cr_crapass%ROWTYPE;
    
    rw_crapaut cr_crapaut%ROWTYPE;
    cr_crapaut_found BOOLEAN := FALSE;
    
    rw_crapaut_rowid cr_crapaut_rowid%ROWTYPE;
    cr_crapaut_rowid_found BOOLEAN := FALSE;
    
    rw_crapcon cr_crapcon%ROWTYPE;
    cr_crapcon_found BOOLEAN := FALSE;
    
    --Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000); 
    vr_exc_erro EXCEPTION;
    
    --Variaveis Locais
    vr_cdagenci INTEGER;
    vr_nrdcaixa NUMBER;
	  vr_cdoperad NUMBER;
    vr_cdhistor INTEGER;
    vr_cdhisdeb INTEGER;
    vr_cdtippro INTEGER;
    vr_dsidepag VARCHAR(100);
	vr_dsnomcnv VARCHAR(100);
    vr_foco     VARCHAR2(10);
    vr_sequenci INTEGER;
    vr_nrdrecid ROWID;
    vr_cdpesqbb VARCHAR2(1000);
    vr_flgpagto BOOLEAN;
    vr_cdbarras VARCHAR2(100);
    vr_nrdocmto NUMBER;
    vr_dslitera VARCHAR2(32000);
    vr_datdodia DATE;
    vr_dtvencto DATE;		
	vr_dttolera DATE;
    vr_vlmovweb NUMBER;
    vr_vlmovpgo NUMBER;
    vr_nrautdoc craplcm.nrautdoc%TYPE;
    vr_flgagend BOOLEAN;
	  vr_cdtransa VARCHAR2(80);
	  vr_dssigemp	VARCHAR2(80);
    vr_nrseqdig craplcm.nrseqdig%TYPE :=0;
    vr_idorigem INTEGER;
    vr_idanalise_fraude   INTEGER;
    vr_cdprodut           INTEGER;
    vr_cdoperac           INTEGER;    
    vr_dstransa           VARCHAR2(100);
    vr_agendado           INTEGER;
  
    -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- criar rowtype controle
        rw_craplot_ctl cr_craplot%ROWTYPE;

  BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot_ctl;
            pr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= pr_dscritic||'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote                  
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote                  
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING  craplot.ROWID
                       ,craplot.nrdolote                       
                       ,craplot.cdbccxlt
                       ,craplot.tplotmov
                       ,craplot.dtmvtolt
                       ,craplot.cdagenci
                       ,craplot.cdhistor
                       ,craplot.cdoperad
                       ,craplot.qtcompln
                       ,craplot.qtinfoln
                       ,craplot.vlcompcr
                       ,craplot.vlinfocr
                   INTO rw_craplot_ctl.ROWID
                      , rw_craplot_ctl.nrdolote                      
                      , rw_craplot_ctl.cdbccxlt
                      , rw_craplot_ctl.tplotmov
                      , rw_craplot_ctl.dtmvtolt
                      , rw_craplot_ctl.cdagenci
                      , rw_craplot_ctl.cdhistor
                      , rw_craplot_ctl.cdoperad
                      , rw_craplot_ctl.qtcompln
                      , rw_craplot_ctl.qtinfoln
                      , rw_craplot_ctl.vlcompcr
                      , rw_craplot_ctl.vlinfocr;
        
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot_ctl;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;

  BEGIN
        
    --Seta a Agência e Caixa
    vr_cdagenci := 90; -- InternetBank
    vr_nrdcaixa := 900;
    
    --Historico Debito
    vr_cdhisdeb:= 508;
    
    -- Descrição do Cedente
    vr_dsidepag := NVL(trim(pr_dsidepag), CASE pr_tpdaguia
                                    		WHEN 1 THEN 'DARF'
                                    		    WHEN 2 THEN 'DAS' 
                                            WHEN 3 THEN 'FGTS'
                                            WHEN 4 THEN 'DAE'
                                          END);
    
    -- Obtem o código do operador
    IF pr_idagenda = 2 THEN -- Agendamento
      vr_cdoperad:= '1000';
    ELSE
      vr_cdoperad:= '996';
    END IF;
    
	  vr_cdtransa := '';
	  vr_dssigemp	:= '';
    
    /* Data do sistema */
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
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
    
	-- busca associado
	OPEN cr_crapass(pr_cdcooper => pr_cdcooper
								 ,pr_nrdconta => pr_nrdconta
								 ,pr_idseqttl => pr_idseqttl);
	FETCH cr_crapass INTO rw_crapass;

	IF cr_crapass%NOTFOUND THEN
		CLOSE cr_crapass;
		vr_cdcritic := 9;
		RAISE vr_exc_erro;
	ELSE
		CLOSE cr_crapass;
	END IF;
    
    -- Caso o o código de barras estiver vazio popula com base na linha digitável
    IF TRIM(pr_cdbarras) IS NULL THEN
       --Se possuir linha digitável popula o código de barras
       IF TRIM(pr_lindigi1) IS NOT NULL THEN
         vr_cdbarras := SUBSTR(to_char(pr_lindigi1, 'fm000000000000'), 1, 11) ||
                        SUBSTR(to_char(pr_lindigi2, 'fm000000000000'), 1, 11) ||
                        SUBSTR(to_char(pr_lindigi3, 'fm000000000000'), 1, 11) ||
                        SUBSTR(to_char(pr_lindigi4, 'fm000000000000'), 1, 11);
       END IF;
    ELSE
      vr_cdbarras := pr_cdbarras;
    END IF;
    
    --Savepoint para abortar sem alterar
    SAVEPOINT TRANS_UNDO;
        
    --> Para Tributos de origens InternetBank e Mobile,
    --> Deve ser gerado o registro de analise de fraude antes de
    --> realizar a operacao
    IF pr_idorigem = 3 AND pr_flgagend = 0 THEN
      
      IF pr_flmobile = 1 THEN
        vr_idorigem := 10; --> MOBILE
      ELSE
        vr_idorigem := 3; --> InternetBank
      END IF;
      
      IF pr_tpdaguia IN (1,2) THEN
        vr_cdprodut := 45;  --> Pagamento DARF/DAS
        vr_cdoperac :=  3;  --> Pagamento DARF/DAS
        vr_dstransa := 'Pagamento DARF/DAS';
      ELSIF pr_tpdaguia IN (3,4) THEN
        vr_cdprodut := 46;  --> Pagamento FGTS/DAE
        vr_cdoperac :=  4;  --> Pagamento FGTS/DAE
        vr_dstransa := 'Pagamento FGTS/DAE';
      END IF;
      
     
      vr_idanalise_fraude := NULL;
      --> Rotina para Inclusao do registro de analise de fraude
      AFRA0001.pc_Criar_Analise_Antifraude(pr_cdcooper    => pr_cdcooper
                                          ,pr_cdagenci    => vr_cdagenci
                                          ,pr_nrdconta    => pr_nrdconta
                                          ,pr_cdcanal     => vr_idorigem 
                                          ,pr_iptransacao => pr_iptransa
                                          ,pr_dtmvtolt    => rw_crapdat.dtmvtocd
                                          ,pr_cdproduto   => vr_cdprodut
                                          ,pr_cdoperacao  => vr_cdoperac
                                          ,pr_iddispositivo => pr_iddispos 
                                          ,pr_dstransacao => vr_dstransa
                                          ,pr_tptransacao => 1 --> online 2-Agendamento
                                          ,pr_idanalise_fraude => vr_idanalise_fraude
                                          ,pr_dscritic   => vr_dscritic);
      vr_dscritic := NULL;
    END IF;
    
    
    --Se a captura for através do código de barras da guia
    IF pr_tpcaptur = 1 THEN
      cxon0014.pc_gera_faturas(pr_cdcooper      => pr_cdcooper      -- Codigo Cooperativa
                              ,pr_nrdconta      => pr_nrdconta      -- Numero da Conta
                              ,pr_idseqttl      => pr_idseqttl      -- Sequencial Titular
                              ,pr_cod_operador  => vr_cdoperad      -- Codigo Operador
                              ,pr_cod_agencia   => vr_cdagenci      -- Codigo Agencia
                              ,pr_nro_caixa     => vr_nrdcaixa      -- Numero Caixa
                              ,pr_cdbarras      => vr_cdbarras      -- Codigo barras
                              ,pr_cdseqfat      => pr_cdseqfat      -- Sequencial faturamento
                              ,pr_vlfatura      => pr_vldocmto      -- Valor Fatura
                              ,pr_nrdigfat      => pr_nrdigfat      -- Digito Faturamento
                              ,pr_valorinf      => pr_vlrtotal      -- Valor Informado
                              ,pr_cdcoptfn      => 0                -- Cooperativa do terminal financeiro
                              ,pr_cdagetfn      => 0                -- Agencia do terminal financeiro
                              ,pr_nrterfin      => 0                -- Numero Terminal Financeiro
                              ,pr_tpcptdoc      => pr_tpleitor      -- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                              ,pr_dsnomfon      => pr_dsnomfon      -- Numero do Telefone
                              ,pr_identificador => pr_nrrefere      -- Identificador FGTS/DAE
                              ,pr_idanafrd      => vr_idanalise_fraude -- Identificador de analise de fraude
                              ,pr_histor        => vr_cdhistor      -- Codigo Historico
                              ,pr_pg            => vr_flgpagto      -- Indicador Pago
                              ,pr_docto         => vr_nrdocmto      -- Numero Documento
                              ,pr_literal       => vr_dslitera      -- Literal
                              ,pr_ult_sequencia => vr_sequenci      -- Ultima Sequencia
                              ,pr_cdcritic      => vr_cdcritic
                              ,pr_dscritic      => vr_dscritic);
      
      --Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    ELSIF pr_tpcaptur = 2 THEN -- Se a captura for através da digitação dos campos da guia
      
      cxon0041.pc_paga_darf(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta -- Numero da Conta
                           ,pr_idseqttl => pr_idseqttl -- Sequencial do Titular
                           ,pr_cdagenci => vr_cdagenci -- Codigo do PA
                           ,pr_nrdcaixa => vr_nrdcaixa -- Numero do Caixa
                           ,pr_cdoperad => vr_cdoperad -- Codigo do Operador
                           ,pr_dtapurac => pr_dtapurac -- Data da Apuracao
                           ,pr_nrcpfcgc => pr_nrcpfcgc -- CPF/CNPJ
                           ,pr_cdtribut => pr_cdtribut -- Codigo do Tributo
                           ,pr_cdrefere => pr_nrrefere -- Codigo de Referencia
                           ,pr_dtlimite => pr_dtvencto -- Data de Limite
                           ,pr_vlrecbru => pr_vlrecbru -- Valor da receita bruta acumulada
                           ,pr_vlpercen => pr_vlpercen -- Percentual da guia
                           ,pr_vllanmto => pr_vlrprinc -- Valor da fatura informado
                           ,pr_vlrmulta => pr_vlrmulta -- Valor da multa
                           ,pr_vlrjuros => pr_vlrjuros -- Valor dos juros
                           ,pr_dsnomfon => pr_dsnomfon -- Nome / Telefone
                           ,pr_idanafrd => vr_idanalise_fraude -- Identificador de analise de fraude
                           ,pr_foco     => vr_foco
                           ,pr_dscliter => vr_dslitera -- Literal
                           ,pr_cdultseq => vr_sequenci -- Ultima Sequencia
                           ,pr_cdcritic => vr_cdcritic -- Codigo do erro
                           ,pr_dscritic => vr_dscritic); -- Descricao do erro
      
      --Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    END IF;
    
    /* Pega autenticacao gerada no pagamento para adicionar o protocolo */
    OPEN cr_crapaut(pr_cdcooper => pr_cdcooper
                   ,pr_cdagenci => vr_cdagenci
                   ,pr_nrdcaixa => 900
                   ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                   ,pr_nrsequen => vr_sequenci);
    FETCH cr_crapaut INTO rw_crapaut;
    cr_crapaut_found := cr_crapaut%FOUND;
    CLOSE cr_crapaut;
    
    --Se nao encontrar
    IF NOT cr_crapaut_found THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro da autenticacao nao encontrado.';
      RAISE vr_exc_erro;
    END IF;

    vr_nrseqdig := fn_sequence('CRAPLOT'
                              ,'NRSEQDIG'
                              ,''||rw_crapaut.cdcooper||';'
                                 ||to_char(rw_crapaut.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||rw_crapaut.cdagenci||';'
                                 ||11||';'
                                 ||11900);  
    
       /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
       PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
       se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
       da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
       a agencia do cooperado*/
    if not paga0001.fn_exec_paralelo then 
      
	  -- Controlar criação de lote, com pragma
	  pc_insere_lote (pr_cdcooper => rw_crapaut.cdcooper,
		  			  pr_dtmvtolt => rw_crapaut.dtmvtolt,
					  pr_cdagenci => rw_crapaut.cdagenci,
					  pr_cdbccxlt => 11,
					  pr_nrdolote => 11900,
					  pr_cdoperad => vr_cdoperad,
					  pr_nrdcaixa => rw_crapaut.nrdcaixa,
					  pr_tplotmov => 1,
					  pr_cdhistor => 0,
					  pr_craplot  => rw_craplot,
					  pr_dscritic => vr_dscritic);	  
                           
    else
      paga0001.pc_insere_lote_wrk (pr_cdcooper => rw_crapaut.cdcooper,
                                   pr_dtmvtolt => rw_crapaut.dtmvtolt,
                                   pr_cdagenci => rw_crapaut.cdagenci,
                                   pr_cdbccxlt => 11,
                                   pr_nrdolote => 11900,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_nrdcaixa => rw_crapaut.nrdcaixa,
                                   pr_tplotmov => 1,
                                   pr_cdhistor => 0,
                                   pr_cdbccxpg => null,
                                   pr_nmrotina => 'PAGA0003.PC_PAGA_DARF_DAS');
    
       rw_craplot.cdcooper := rw_crapaut.cdcooper;
       rw_craplot.dtmvtolt := rw_crapaut.dtmvtolt;
       rw_craplot.cdagenci := rw_crapaut.cdagenci;
       rw_craplot.cdbccxlt := 11;
       rw_craplot.nrdolote := 11900;
       rw_craplot.cdoperad := vr_cdoperad;
       rw_craplot.tplotmov := 1;
       rw_craplot.cdhistor := 0;
       
                          

    end if; 

    -- se encontrou erro ao buscar lote, abortar programa
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
   
    -- tipo de guia
		IF pr_tpdaguia = 1 THEN
			
			vr_cdtippro:= 16; -- DARF
				
			IF pr_tpcaptur = 1 THEN -- CD BARRAS									
								
			    -- Pega o nome do convenio
			    OPEN cr_crapcon (pr_cdcooper => pr_cdcooper
			                    ,pr_cdempcon => TO_NUMBER(SUBSTR(vr_cdbarras,16,4))
			                    ,pr_cdsegmto => TO_NUMBER(SUBSTR(vr_cdbarras,2,1)));
			    FETCH cr_crapcon INTO rw_crapcon;
			    cr_crapcon_found := cr_crapcon%FOUND;
			    CLOSE cr_crapcon;
			    
			    --Se nao encontrar
			    IF NOT cr_crapcon_found THEN
			      vr_cdcritic:= 0;
			      vr_dscritic:= 'Convenio nao encontrado.';
			      RAISE vr_exc_erro;
			    END IF;
									
				-- Validação referente aos dias de tolerancia
				cxon0014.pc_verifica_dtlimite_tributo(pr_cdcooper      => pr_cdcooper
																						 ,pr_cdagenci      => vr_cdagenci
																						 ,pr_cdempcon      => rw_crapcon.cdempcon
																						 ,pr_cdsegmto      => rw_crapcon.cdsegmto
																						 ,pr_codigo_barras => vr_cdbarras
																						 ,pr_dtmvtopg      => vr_dtvencto
                                             ,pr_flnrtole      => FALSE                                             
																						 ,pr_dttolera      => vr_dttolera
																						 ,pr_cdcritic      => vr_cdcritic
																						 ,pr_dscritic      => vr_dscritic);				
																
				vr_dsnomcnv := rw_crapcon.nmextcon;
				vr_dtvencto := vr_dttolera;
    
			ELSE -- MANUAL
			  -- Pega o nome do convenio
				OPEN cr_crapscn (pr_cdempres => CASE pr_cdtribut
																		         WHEN '6106' THEN 'D0'
																						 ELSE 'A0' 
																	      END,
												 pr_tpmeiarr => CASE pr_idorigem
																		         WHEN 3 THEN 'D'
																		         ELSE 'C'
																						 END);
				FETCH cr_crapscn INTO rw_crapscn;
				--Se nao encontrar
				IF NOT cr_crapscn%FOUND THEN
					vr_cdcritic:= 0;
					vr_dscritic:= 'Convenio nao encontrado.';
					CLOSE cr_crapscn;
					RAISE vr_exc_erro;
				END IF;
				CLOSE cr_crapscn;
					
				vr_dtvencto := pr_dtvencto;
			  vr_dsnomcnv := rw_crapscn.dsnomcnv;
				vr_cdtransa := rw_crapscn.cdtransa;
				vr_dssigemp	:= rw_crapscn.dssigemp;
								
			END IF;								
		ELSE 
			
      IF pr_tpdaguia = 2 THEN   
        vr_cdtippro := 17; --DAS 
      ELSIF pr_tpdaguia = 3 THEN   
        vr_cdtippro := 24; --FGTS 
      ELSIF pr_tpdaguia = 4 THEN   
        vr_cdtippro := 23; --DAE
      END IF;  

			-- Pega o nome do convenio
			OPEN cr_crapcon (pr_cdcooper => pr_cdcooper
											,pr_cdempcon => TO_NUMBER(SUBSTR(vr_cdbarras,16,4))
											,pr_cdsegmto => TO_NUMBER(SUBSTR(vr_cdbarras,2,1)));
			FETCH cr_crapcon INTO rw_crapcon;
			cr_crapcon_found := cr_crapcon%FOUND;
			CLOSE cr_crapcon;
		    
			--Se nao encontrar
			IF NOT cr_crapcon_found THEN
				vr_cdcritic:= 0;
				vr_dscritic:= 'Convenio nao encontrado.';
				RAISE vr_exc_erro;
			END IF;
			
			vr_dsnomcnv := rw_crapcon.nmextcon;		
      
      IF pr_tpdaguia IN (3,4) THEN
        vr_dtvencto := pr_dtvencto;
      ELSE   
      
			-- Validação referente aos dias de tolerancia
			cxon0014.pc_verifica_dtlimite_tributo(pr_cdcooper      => pr_cdcooper
                                           ,pr_cdagenci      => vr_cdagenci
                                           ,pr_cdempcon      => rw_crapcon.cdempcon
                                           ,pr_cdsegmto      => rw_crapcon.cdsegmto
                                           ,pr_codigo_barras => vr_cdbarras
                                           ,pr_dtmvtopg      => vr_dtvencto
                                           ,pr_flnrtole      => FALSE                        
                                           ,pr_dttolera      => vr_dttolera                        
                                           ,pr_cdcritic      => vr_cdcritic
                               						 ,pr_dscritic => vr_dscritic);
    
			vr_dtvencto := vr_dttolera;
      END IF;  

		END IF;
    
    --Obtem flag de agendamento
    vr_flgagend := CASE pr_idagenda WHEN 2 THEN TRUE ELSE FALSE END;
    
    -- Gera um protocolo para o pagamento
    paga0003.pc_cria_comprovante_tributos(pr_cdcooper => rw_crapaut.cdcooper -- Código da cooperativa
                                         ,pr_nrdconta => pr_nrdconta -- Número da conta
                                         ,pr_nmextttl => rw_crapass.nmextttl -- Nome do Titular
                                         ,pr_nrcpfope => pr_nrcpfope -- CPF do operador PJ
										                     ,pr_nrcpfpre => rw_crapass.nrcpfpre -- Número pré operação
                                         ,pr_nmprepos => rw_crapass.nmprepos -- Nome Preposto
                                         ,pr_tpcaptur => pr_tpcaptur -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                         ,pr_cdtippro => vr_cdtippro -- Código do tipo do comprovante
                                         ,pr_dtmvtolt => rw_crapaut.dtmvtolt -- Data de movimento da autenticação
                                         ,pr_hrautent => rw_crapaut.hrautent -- Horário da autenticação
                                         ,pr_nrdocmto => vr_nrseqdig -- Número do documento
                                         ,pr_nrseqaut => rw_crapaut.nrsequen -- Sequencial da autenticação
                                         ,pr_nrdcaixa => rw_crapaut.nrdcaixa -- Número do caixa da autenticação
                                         ,pr_idorigem => pr_idorigem         -- Indicador de canal de origem  da transação
                                         ,pr_nmconven => vr_dsnomcnv         -- Nome do convênio da guia
                                         ,pr_lindigi1 => pr_lindigi1 -- Primeiro campo da linha digitável da guia
                                         ,pr_lindigi2 => pr_lindigi2 -- Segundo campo da linha digitável da guia
                                         ,pr_lindigi3 => pr_lindigi3 -- Terceiro campo da linha digitável da guia
                                         ,pr_lindigi4 => pr_lindigi4 -- Quarto campo da linha digitável da guia
                                         ,pr_cdbarras => pr_cdbarras -- Código de barras da guia
                                         ,pr_dsidepag => vr_dsidepag -- Descrição da identificação do pagamento
                                         ,pr_vlrtotal => rw_crapaut.vldocmto -- Valor total do pagamento da guia
                                         ,pr_dsnomfon => pr_dsnomfon -- Nome e telefone da guia
                                         ,pr_dtapurac => pr_dtapurac -- Período de apuração da guia
                                         ,pr_nrcpfcgc => pr_nrcpfcgc -- CPF/CNPJ da guia
                                         ,pr_cdtribut => pr_cdtribut -- Código de tributação da guia
                                         ,pr_nrrefere => pr_nrrefere -- Número de referência da guia
                                         ,pr_dtvencto => vr_dtvencto -- Data de vencimento da guia
                                         ,pr_vlrprinc => pr_vlrprinc -- Valor principal da guia
                                         ,pr_vlrmulta => pr_vlrmulta -- Valor da multa da guia
                                         ,pr_vlrjuros => pr_vlrjuros -- Valor dos juros da guia
                                         ,pr_vlrecbru => pr_vlrecbru -- Valor da receita bruta acumulada da guia
                                         ,pr_vlpercen => pr_vlpercen -- Valor do percentual da guia
                                         ,pr_flgagend => vr_flgagend -- Indicador de agendamento (TRUE – Agendamento / FALSE – Nesta Data)
										                     ,pr_cdtransa => vr_cdtransa -- Código da transação por meio de arrecadação do SICREDI
										                     ,pr_dssigemp => vr_dssigemp -- Descrição resumida de convênio DARF para autenticação modelo SICREDI
                                         ,pr_dsprotoc => pr_dsprotoc -- Descrição do protocolo do comprovante
                                         ,pr_cdcritic => vr_cdcritic -- Código do erro
                                         ,pr_dscritic => vr_dscritic -- Descriçao do erro
                                         );
    
    --Se ocorreu erro
		IF nvl(vr_cdcritic,0) > 0 OR
			 TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Armazena protocolo na autenticacao
    BEGIN
      UPDATE crapaut SET crapaut.dsprotoc = pr_dsprotoc
      WHERE crapaut.ROWID = rw_crapaut.ROWID;

    EXCEPTION
      WHEN OTHERS THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro ao atualizar registro da autenticacao. '||sqlerrm;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END;
    
    --Gravar autenticacao Internet
    CXON0000.pc_grava_autenticacao_internet(pr_cooper       => pr_cdcooper          --Codigo Cooperativa
                                           ,pr_nrdconta     => pr_nrdconta          --Numero da Conta
                                           ,pr_idseqttl     => pr_idseqttl          --Sequencial do titular
                                           ,pr_cod_agencia  => rw_crapaut.cdagenci  --Codigo Agencia
                                           ,pr_nro_caixa    => rw_crapaut.nrdcaixa  --Numero do caixa
                                           ,pr_cod_operador => rw_crapaut.cdopecxa  --Codigo Operador
                                           ,pr_valor        => rw_crapaut.vldocmto  --Valor da transacao
                                           ,pr_docto        => vr_nrseqdig  --Numero documento
                                           ,pr_operacao     => TRUE                 --Indicador Operacao Debito
                                           ,pr_status       => '1'                  --Status da Operacao - Online
                                           ,pr_estorno      => FALSE                --Indicador Estorno
                                           ,pr_histor       => vr_cdhisdeb          --Historico Debito
                                           ,pr_data_off     => NULL                 --Data Transacao
                                           ,pr_sequen_off   => 0                    --Sequencia
                                           ,pr_hora_off     => 0                    --Hora transacao
                                           ,pr_seq_aut_off  => 0                    --Sequencia automatica
                                           ,pr_cdempres     => NULL                 --Descricao Observacao
                                           ,pr_literal      => vr_dslitera          --Descricao literal lcm
                                           ,pr_sequencia    => vr_nrautdoc          --Sequencia
                                           ,pr_registro     => vr_nrdrecid          --ROWID do registro debito
                                           ,pr_cdcritic     => vr_cdcritic          --Código do erro
                                           ,pr_dscritic     => vr_dscritic);        --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na autenticacao do pagamento.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
      
    OPEN cr_crapaut_rowid(pr_rowid => vr_nrdrecid);
    FETCH cr_crapaut_rowid
    INTO rw_crapaut;
		--Se nao encontrar
		IF cr_crapaut_rowid%NOTFOUND THEN
			--Fechar Cursor
			CLOSE cr_crapaut;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro da autenticacao nao encontrado.';
			--Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

		--Fechar Cursor
		CLOSE cr_crapaut_rowid;
		
		/** Armazena protocolo na autenticacao **/
    BEGIN
      UPDATE crapaut SET crapaut.dsprotoc = pr_dsprotoc
      WHERE crapaut.ROWID = rw_crapaut.ROWID;
    EXCEPTION
      WHEN OTHERS THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro ao atualizar registro da autenticacao. '||sqlerrm;
      --Levantar Excecao
      RAISE vr_exc_erro;

    END;
    
    --Verificar Origem e determinar codigo pesquisa
    IF pr_idorigem = 4 THEN
      vr_cdpesqbb:= 'TAA - PAGAMENTO ON-LINE ' ||'- CONVENIO ' || vr_dsnomcnv;
    ELSE
      vr_cdpesqbb:= 'INTERNET - PAGAMENTO ON-LINE ' ||'- CONVENIO '|| vr_dsnomcnv;
    END IF;

    -- Cria o lancamento do DEBITO
    BEGIN
      INSERT INTO craplcm
            (craplcm.cdcooper
            ,craplcm.dtmvtolt
            ,craplcm.cdagenci
            ,craplcm.cdbccxlt
            ,craplcm.nrdolote
            ,craplcm.dtrefere
            ,craplcm.hrtransa
            ,craplcm.cdoperad
            ,craplcm.nrdconta
            ,craplcm.nrdctabb
            ,craplcm.nrdctitg
            ,craplcm.nrdocmto
            ,craplcm.nrsequni
            ,craplcm.nrseqdig
            ,craplcm.cdhistor
            ,craplcm.vllanmto
            ,craplcm.nrautdoc
            ,craplcm.dscedent
            ,craplcm.cdcoptfn
            ,craplcm.cdagetfn
            ,craplcm.nrterfin
            ,craplcm.cdpesqbb)
      VALUES
            (rw_crapaut.cdcooper
            ,rw_crapaut.dtmvtolt
            ,rw_crapaut.cdagenci
            ,11
            ,11900
            ,rw_crapaut.dtmvtolt
            ,GENE0002.fn_busca_time
            ,rw_crapaut.cdopecxa
            ,pr_nrdconta
            ,pr_nrdconta
            ,gene0002.fn_mask(pr_nrdconta,'99999999')
            ,vr_nrseqdig
            ,vr_nrseqdig
            ,vr_nrseqdig
            ,rw_crapaut.cdhistor
            ,rw_crapaut.vldocmto
            ,rw_crapaut.nrsequen
            ,GENE0007.fn_caract_acento(vr_dsidepag,1)
            ,0 -- cdcoptfn
            ,0 -- cdagetfn
            ,0 -- nrterfin
            ,vr_cdpesqbb);
        
      IF pr_idorigem <> 4 THEN -- TAA
        /* Cria o registro do movimento da internet */
        
        --Buscar data do dia
        vr_datdodia:= trunc(sysdate); /*PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);*/

        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1  THEN
          vr_vlmovweb:= pr_vlrtotal;
          vr_vlmovpgo:= 0;
        ELSE
          vr_vlmovweb:= 0;
          vr_vlmovpgo:= pr_vlrtotal;
        END IF;

        IF rw_crapass.idastcjt = 0 THEN
          --Atualizar registro movimento da internet
          BEGIN
            UPDATE crapmvi SET crapmvi.vlmovweb = crapmvi.vlmovweb + vr_vlmovweb
                              ,crapmvi.vlmovpgo = crapmvi.vlmovpgo + vr_vlmovpgo
                              ,crapmvi.dttransa = vr_datdodia
             WHERE crapmvi.cdcooper = pr_cdcooper
               AND crapmvi.nrdconta = pr_nrdconta
               AND crapmvi.idseqttl = pr_idseqttl
               AND crapmvi.dtmvtolt = rw_crapaut.dtmvtolt;
              
            --Nao atualizou nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Cria o registro do movimento da internet
              BEGIN
                INSERT INTO crapmvi
                       (crapmvi.cdcooper
                       ,crapmvi.cdoperad
                       ,crapmvi.dtmvtolt
                       ,crapmvi.dttransa
                       ,crapmvi.hrtransa
                       ,crapmvi.idseqttl
                       ,crapmvi.nrdconta
                       ,crapmvi.vlmovweb
                       ,crapmvi.vlmovpgo)
                VALUES (pr_cdcooper
                       ,rw_crapaut.cdopecxa
                       ,rw_crapaut.dtmvtolt
                       ,vr_datdodia
                       ,GENE0002.fn_busca_time
                       ,pr_idseqttl
                       ,pr_nrdconta
                       ,vr_vlmovweb
                       ,vr_vlmovpgo);

              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
                  --Levantar Excecao
                  RAISE vr_exc_erro;

            END;

          END IF;

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        ELSE
          FOR rw_crappod IN cr_crappod(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta) LOOP
            
            --Atualizar registro movimento da internet
            BEGIN
              UPDATE crapmvi SET crapmvi.vlmovweb = crapmvi.vlmovweb + vr_vlmovweb
                                ,crapmvi.vlmovpgo = crapmvi.vlmovpgo + vr_vlmovpgo
                                ,crapmvi.dttransa = vr_datdodia
               WHERE crapmvi.cdcooper = pr_cdcooper
                 AND crapmvi.nrdconta = pr_nrdconta
                 AND crapmvi.idseqttl = rw_crappod.idseqttl
                 AND crapmvi.dtmvtolt = rw_crapaut.dtmvtolt;
                
              --Nao atualizou nenhum registro
              IF SQL%ROWCOUNT = 0 THEN
                -- Cria o registro do movimento da internet
                BEGIN
                  INSERT INTO crapmvi
                         (crapmvi.cdcooper
                         ,crapmvi.cdoperad
                         ,crapmvi.dtmvtolt
                         ,crapmvi.dttransa
                         ,crapmvi.hrtransa
                         ,crapmvi.idseqttl
                         ,crapmvi.nrdconta
                         ,crapmvi.vlmovweb
                         ,crapmvi.vlmovpgo)
                  VALUES (pr_cdcooper
                         ,rw_crapaut.cdopecxa
                         ,rw_crapaut.dtmvtolt
                         ,vr_datdodia
                         ,GENE0002.fn_busca_time
                         ,rw_crappod.idseqttl
                         ,pr_nrdconta
                         ,vr_vlmovweb
                         ,vr_vlmovpgo);

                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                END;
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN Others THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;
    
		-- Monitoração sendo realizada antes das atualizações da craplot para evitar prolongar lock
		-- Executa monitoração de Pagamentos
    -- 12/04/2018 - TJ: modificada chamada devido transporte da rotina para AFRA0004
    IF NVL(vr_idanalise_fraude, 0) = 0 THEN
    
      BEGIN   
         IF pr_idagenda = 1 Then
           vr_agendado := 0;
         Else
           vr_agendado := 1;
         End IF;     
                                 
         AFRA0004.pc_monitora_operacao (pr_cdcooper   => pr_cdcooper   -- Codigo da cooperativa
                                       ,pr_nrdconta   => pr_nrdconta   -- Numero da conta
                                       ,pr_idseqttl   => pr_idseqttl   -- Sequencial titular
                                       ,pr_vlrtotal   => pr_vlrtotal   -- Valor Lancamento
                                       ,pr_flgagend   => vr_agendado   -- Flag agendado /* 1-True, 0-False */ 
                                       ,pr_idorigem   => pr_idorigem   -- Indicador de origem
                                       ,pr_cdoperacao => 3             -- Codigo operacao (tbcc_dominio_campo-CDOPERAC_ANALISE_FRAUDE)
                                       ,pr_idanalis   => NULL          -- ID Analise Fraude
                                       ,pr_lgprowid   => NULL          -- Rowid craplgp
                                       ,pr_cdcritic   => vr_cdcritic   -- Codigo da critica
                                       ,pr_dscritic   => vr_dscritic); -- Descricao da critica
                                          
      EXCEPTION
          WHEN OTHERS THEN NULL;
      END;                                      
	    
      vr_cdcritic := NULL;                             
      vr_dscritic := NULL;                             
        
      END IF;


      EXCEPTION
    WHEN vr_exc_erro THEN
      --rollback do savepoint
      ROLLBACK TO TRANS_UNDO;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      --rollback do savepoint
      ROLLBACK TO TRANS_UNDO;
        
      pr_dscritic := 'Erro na rotina PAGA0003.pc_paga_tributos. ' ||
                     SQLERRM;
  END pc_paga_tributos;
  
/*..............................................................................
  
   Programa: PAGA0003
   Autor   : Lucas Lunelli
   Data    : 19/09/2016                        Ultima atualizacao: 01/11/2017
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necessárias para pagamento de guias DARF e DAS
  
   Alteracoes: 08/11/2016 - Alteração na procedure interna de LOG (Jean Michel).
   
               04/09/2017 - Alteração Projeto Assinatura conjunta (Proj 397), 
               Incluido a variavel que determina se deve gerar pendência de aprovação
               ou efetivar pagamento de acordo com alçada do preposto ou operador.
               
               01/11/2017 - Validar corretamente o horario da debsic em caso de agendamentos
                            e também validar data do pagamento menor que o dia atual (Lucas Ranghetti #775900)
..............................................................................*/  

	/* Procedimento do internetbank operação 188 - Operar pagamento DARF/DAS */
  PROCEDURE pc_InternetBank188( pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Cooperativa
                               ,pr_nrdconta IN  crapass.nrdconta%TYPE  -- Número da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                               ,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- CPF do operador PJ
                               ,pr_dtmvtopg IN  DATE                   -- Data do pagamento
                               ,pr_idorigem IN  INTEGER                -- Canal de origem da operação
                               ,pr_flmobile IN  INTEGER                -- Indicador de requisição via canal Mobile
                               ,pr_idefetiv IN  INTEGER                -- Indicador de efetivação da operação de pagamento
                               ,pr_tpdaguia IN  INTEGER                -- Tipo da guia (1 – DARF / 2 – DAS)
                               ,pr_tpcaptur IN  INTEGER                -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                               ,pr_lindigi1 IN  NUMBER                 -- Primeiro campo da linha digitável da guia
                               ,pr_lindigi2 IN  NUMBER                 -- Segundo campo da linha digitável da guia
                               ,pr_lindigi3 IN  NUMBER                 -- Terceiro campo da linha digitável da guia
                               ,pr_lindigi4 IN  NUMBER                 -- Quarto campo da linha digitável da guia
                               ,pr_cdbarras IN  VARCHAR2               -- Código de barras da guia
                               ,pr_dsidepag IN  VARCHAR2               -- Descrição da identificação do pagamento
                               ,pr_vlrtotal IN  NUMBER                 -- Valor total do pagamento da guia
                               ,pr_dsnomfon IN  VARCHAR2               -- Nome e telefone da guia
                               ,pr_dtapurac IN  DATE                   -- Período de apuração da guia
                               ,pr_nrcpfcgc IN  VARCHAR2               -- CPF/CNPJ da guia
                               ,pr_cdtribut IN  VARCHAR2               -- Código de tributação da guia
                               ,pr_nrrefere IN  VARCHAR2                 -- Número de referência da guia
                               ,pr_dtvencto IN  DATE                   -- Data de vencimento da guia
                               ,pr_vlrprinc IN  NUMBER                 -- Valor principal da guia
                               ,pr_vlrmulta IN  NUMBER                 -- Valor da multa da guia
                               ,pr_vlrjuros IN  NUMBER                 -- Valor dos juros da guia
                               ,pr_vlrecbru IN  NUMBER                 -- Valor da receita bruta acumulada da guia
                               ,pr_vlpercen IN  NUMBER                 -- Valor do percentual da guia
                               ,pr_idagenda IN  INTEGER                -- Indicador de agendamento (1 – Nesta Data / 2 – Agendamento)
                               ,pr_vlapagar IN  NUMBER                 -- Valor total dos pagamentos
                               ,pr_versaldo IN  INTEGER                -- Indicador de validação do saldo em relação ao valor total
                               ,pr_tpleitor IN  INTEGER                -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                               ,pr_iptransa IN VARCHAR2 DEFAULT NULL   -- IP da transação
                               ,pr_iddispos IN VARCHAR2 DEFAULT NULL   -- Identificador do dispositivo mobile                                  
                               ,pr_xml_dsmsgerr    OUT VARCHAR2        -- Retorno XML de critica
                               ,pr_xml_operacao188 OUT CLOB            -- Retorno XML da operação 188
                               ,pr_dsretorn        OUT VARCHAR2 ) IS   -- Retorno de critica (OK ou NOK)
    --Cursores
	  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
	
    CURSOR cr_craphec(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdprogra IN craphec.cdprogra%TYPE) IS
     SELECT MAX(hec.hriniexe) hriniexe
       FROM craphec hec
      WHERE upper(hec.cdprogra) = upper(pr_cdprogra)
        AND hec.cdcooper = pr_cdcooper;
     rw_craphec cr_craphec%ROWTYPE;
  
		--Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_assin_conjunta NUMBER(1);
		vr_des_reto VARCHAR2(03);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
		--Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
		
		--tables
		vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_tab_erro       GENE0001.typ_tab_erro;          --> Tabela com erros
    vr_tab_saldos     EXTR0001.typ_tab_saldos;        --> Tabela de retorno da rotina

    vr_dstransa  VARCHAR2(200) := ''; -- log
		vr_dsmsgope  VARCHAR2(200) := ''; -- msg da operacao
    vr_dstrans1  VARCHAR2(200) := '';		
		vr_vlrvalid  NUMBER;              -- Valor a ser validado pela rotina
		vr_idastcjt  crapass.idastcjt%TYPE;
    vr_nrcpfcgc  VARCHAR2(200) := '';
    vr_nmprimtl  VARCHAR2(500);
    vr_flcartma  INTEGER(1) := 0;
		vr_cdseqfat  VARCHAR2(500);
		vr_vldocmto  NUMBER;
		vr_nrdigfat  NUMBER;
    vr_lindigi1  NUMBER;
    vr_lindigi2  NUMBER;
    vr_lindigi3  NUMBER;
    vr_lindigi4  NUMBER;
    vr_dtmvtopg  DATE;
    vr_lindigit  VARCHAR2(100);
    vr_cdbarras  VARCHAR2(100);
		vr_dsprotoc  VARCHAR2(500);
		vr_dslindig  VARCHAR2(200);
		vr_nrdrowid  ROWID;
    vr_hriniexe  craphec.hriniexe%TYPE;
		
		-- Gerar log
    PROCEDURE pc_proc_geracao_log(pr_flgtrans IN INTEGER) IS
    BEGIN
      
      IF pr_nrcpfope > 0  THEN
        vr_dstransa := vr_dstransa ||' - operador';
      END IF;
        
      -- Gerar log ao cooperado (b1wgen0014 - gera_log) 
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => pr_flgtrans
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
			
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
			 												  pr_nmdcampo => 'Tipo da Guia',
			 												  pr_dsdadant => ' ',
			 												  pr_dsdadatu => CASE pr_tpdaguia WHEN 1 THEN 'DARF'
																							 ELSE 'DAS' END);
										
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Origem',
																pr_dsdadant => ' ',
																pr_dsdadatu => CASE pr_flmobile
																							 WHEN 1 THEN 'MOBILE'
																							 ELSE 'INTERNETBANK' 
																								END);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Guia com Codigo de Barras',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => CASE pr_tpcaptur
                                               WHEN 1 THEN 'SIM'
                                               ELSE 'NAO' END);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Nome/Telefone',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => pr_dsnomfon);

      -- Com codigo de barras
      IF pr_tpcaptur = 1 THEN

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Codigo de Barras',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => pr_cdbarras);

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Linha Digitavel',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_dslindig);

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => (CASE 
                                                   WHEN pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
                                                     'Valor Pago'
                                                   ELSE 'Valor a Pagar'
                                                 END)
                                 ,pr_dsdadant => ' '
                                 ,pr_dsdadatu => TRIM(TO_CHAR(pr_vlrtotal,'9G999G990D00')));

      ELSE -- Sem codigo de barras
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Periodo da Apuracao',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TO_CHAR(pr_dtapurac,'DD/MM/RRRR'));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'CPF/CNPJ',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TO_CHAR(pr_nrcpfcgc));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Codigo da Receita',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TO_CHAR(pr_cdtribut));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Numero de Referencia',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TO_CHAR(pr_nrrefere));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Data do Vencimento',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TO_CHAR(pr_dtvencto,'DD/MM/RRRR'));
          
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Valor Principal',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TRIM(TO_CHAR(pr_vlrprinc,'9G999G990D00')));
          
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Valor da Multa',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TRIM(TO_CHAR(pr_vlrmulta,'9G999G990D00')));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Valor dos Juros',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TRIM(TO_CHAR(pr_vlrjuros,'9G999G990D00')));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Valor de Receita Bruta',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TRIM(TO_CHAR(pr_vlrecbru,'9G999G990D00')));

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Percentual',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => TRIM(TO_CHAR(pr_vlpercen,'9G999G990D00')));
      END IF;
				
      -- se não é agendamento                
      IF pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Data do Pagamento' 
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(nvl(vr_dtmvtopg,pr_dtmvtopg),'DD/MM/RRRR'));

        IF pr_flgtrans = 1 THEN   
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Protocolo' 
                                   ,pr_dsdadant => ' '
                                   ,pr_dsdadatu => vr_dsprotoc);
        END IF;
                           
      ELSE
        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Data do Agendamento' 
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(nvl(vr_dtmvtopg,pr_dtmvtopg),'DD/MM/RRRR')); 
      END IF;
        
      IF pr_nrcpfope > 0  THEN
        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Operador' 
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
      END IF;

      --Se conta exigir Assinatura Multipla
      IF vr_idastcjt = 1 THEN
         gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                   pr_nmdcampo => 'Nome do Representante/Procurador', 
                                   pr_dsdadant => '', 
                                   pr_dsdadatu => vr_nmprimtl);
                                          
         gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                   pr_nmdcampo => 'CPF do Representante/Procurador', 
                                   pr_dsdadant => '', 
                                   pr_dsdadatu => TO_CHAR(vr_nrcpfcgc));
      END IF;
                          
    END pc_proc_geracao_log;		
		
  BEGIN
		-- obtem data
	  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;  
    
    IF pr_idefetiv = 0 THEN -- Validação
			IF pr_idagenda = 1 THEN 
				vr_dstransa := vr_dstransa || 'Valida pagamento ';
			ELSE 
				vr_dstransa := vr_dstransa || 'Valida agendamento de pagamento ';
			END IF;		
		ELSE -- Efetivação
			IF pr_idagenda = 1 THEN 
				vr_dstransa := vr_dstransa || 'Pagamento ';
			ELSE 
				vr_dstransa := vr_dstransa || 'Agendamento para pagamento ';
			END IF;
		END IF;
		
		IF pr_tpdaguia = 1 THEN -- DARF
			vr_dstransa := vr_dstransa || 'de DARF.';
		ELSE -- DAS
			vr_dstransa := vr_dstransa || 'de DAS.';
		END IF;
		
		INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		--Verifica se conta for conta PJ e se exige assinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmprimtl => vr_nmprimtl
                                       ,pr_flcartma => vr_flcartma
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro; 
    END IF;					
		
		-- se for para verificar o saldo
    IF pr_versaldo = 1 AND pr_nrcpfope = 0 AND vr_idastcjt = 0 THEN

      -- busca associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      -- obter do saldo da conta
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => rw_crapdat,
                                  pr_cdagenci   => 90,
                                  pr_nrdcaixa   => 900,
                                  pr_cdoperad   => '996',
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_vllimcre   => rw_crapass.vllimcre,
                                  pr_tipo_busca => 'A',  -- Usar data anterior  
                                  pr_dtrefere   => rw_crapdat.dtmvtocd,
                                  pr_des_reto   => vr_des_reto,
                                  pr_tab_sald   => vr_tab_saldos,
                                  pr_tab_erro   => vr_tab_erro);

       -- Verifica se deu erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel verificar Saldo.'; 
        END IF;
        
        RAISE vr_exc_erro;
      END IF; 
      
      -- se não encontrar nenhum registro
      IF vr_tab_saldos.exists(vr_tab_saldos.first) = FALSE THEN
        vr_dscritic := 'Nao foi possivel consultar o saldo para a operacao.'; 
        RAISE vr_exc_erro;  
      END IF;
      
      -- Verificar se possui saldo disponivel para realizar o pagamento
      IF nvl(pr_vlapagar,0) > (  vr_tab_saldos(vr_tab_saldos.first).vlsddisp 
                               + vr_tab_saldos(vr_tab_saldos.first).vllimcre) THEN 
        vr_dscritic := 'Nao ha saldo suficiente para a operacao.';
        RAISE vr_exc_erro;
      END IF;  
      
    END IF; -- Fim IF verificar saldo
						
    -- Antes de efeivar, envia o valor somado de todos os pagamentos do lote (vlapagar)
    vr_vlrvalid := CASE WHEN pr_idefetiv = 0 THEN nvl(pr_vlapagar,0) ELSE nvl(pr_vlrtotal,0) END;

		-- inicializar variaveis
    vr_lindigi1 := pr_lindigi1;
    vr_lindigi2 := pr_lindigi2;
    vr_lindigi3 := pr_lindigi3;
    vr_lindigi4 := pr_lindigi4;
    vr_cdbarras := pr_cdbarras;
    vr_dtmvtopg := pr_dtmvtopg;						
    ------
		
		-- alimenta linha digitável (para log) caso tenha sido informada
		IF TRIM(pr_lindigi1) IS NOT NULL THEN
		   vr_dslindig := SUBSTR(to_char(vr_lindigi1,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi1,'fm000000000000'),12,1) ||' '||

		                  SUBSTR(to_char(vr_lindigi2,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi2,'fm000000000000'),12,1) ||' '||

                      SUBSTR(to_char(vr_lindigi3,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi3,'fm000000000000'),12,1) ||' '||

		                  SUBSTR(to_char(vr_lindigi4,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi4,'fm000000000000'),12,1);
		END IF;
		
		vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
																							 pr_dtmvtolt => pr_dtmvtopg, 
																							 pr_tipo     => 'A');

    -- Se for um agendamento vamos verificar se ja esgotou horario DEBSIC
    IF pr_idagenda = 2 THEN
    -- busca ultimo horario da debsic
    OPEN cr_craphec(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => 'DEBSIC');
    FETCH cr_craphec INTO rw_craphec;

    IF cr_craphec%NOTFOUND THEN
      CLOSE cr_craphec;
      vr_hriniexe:= 0;
    ELSE
      CLOSE cr_craphec;
      vr_hriniexe:= rw_craphec.hriniexe;
    END IF;
    
    -- Se DEBSIC ja rodou, nao aceitamos mais agendamento para agendamentos em que o dia
    -- que antecede o final de semana ou feriado nacional
       
      IF TRUNC(SYSDATE) > vr_dtmvtopg  THEN   
      IF pr_tpdaguia = 1 THEN -- DARF
        vr_dscritic := 'Agendamento de DARF permitido apenas para o proximo dia util.'; 
      ELSE -- DAS
        vr_dscritic := 'Agendamento de DAS permitido apenas para o proximo dia util.'; 
      END IF;
        RAISE vr_exc_erro;    
      ELSIF TRUNC(SYSDATE) = vr_dtmvtopg AND to_char(SYSDATE,'sssss') >= vr_hriniexe THEN
      
        IF pr_tpdaguia = 1 THEN -- DARF
          vr_dscritic := 'Agendamento de DARF permitido apenas para o proximo dia util.'; 
        ELSE -- DAS
          vr_dscritic := 'Agendamento de DAS permitido apenas para o proximo dia util.'; 
        END IF;        
      RAISE vr_exc_erro;     
       
    END IF;
    END IF;

		-- Procedure para validar limites para transacoes
    INET0001.pc_verifica_operacao (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                                  ,pr_cdagenci     => 90                  --> Agencia do Associado
                                  ,pr_nrdcaixa     => 900                 --> Numero caixa
                                  ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                                  ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                                  ,pr_dtmvtolt     => rw_crapdat.dtmvtocd --> Data Movimento
                                  ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                                  ,pr_dtmvtopg     => vr_dtmvtopg         --> Data Pagamento
                                  ,pr_vllanmto     => vr_vlrvalid         --> Valor a ser Validado
                                  ,pr_cddbanco     => 0                   --> Codigo banco
                                  ,pr_cdageban     => 0                   --> Codigo Agencia
                                  ,pr_nrctatrf     => 0                   --> Numero Conta Transferencia
                                  ,pr_cdtiptra     => 10                   --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                                  ,pr_cdoperad     => 996                 --> Codigo Operador
                                  ,pr_tpoperac     => 10
                                  ,pr_flgvalid     => TRUE                --> Indicador validacoes
                                  ,pr_dsorigem     => 'INTERNET'          --> Descricao Origem
                                  ,pr_nrcpfope     => pr_nrcpfope --(CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN 0 ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do responsavel legal quando conta exigir assinatura multipla
                                  ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                                  ,pr_nmdatela     => 'INTERNETBANK'      --> Nome da tela/programa que esta chamando a rotina
                                  ,pr_dstransa     => vr_dstrans1         --> Descricao da transacao
                                  ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                  ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                  ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                                  ,pr_dscritic     => vr_dscritic         --> Descricao do erro
                                  ,pr_assin_conjunta => vr_assin_conjunta);   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		PAGA0003.pc_verifica_tributos( pr_cdcooper => pr_cdcooper,
																	 pr_nrdconta => pr_nrdconta,
																	 pr_idseqttl => pr_idseqttl,
																	 pr_idorigem => pr_idorigem,
                                   pr_tpdaguia => pr_tpdaguia,
																	 pr_tpcaptur => pr_tpcaptur,
																	 pr_lindigi1 => vr_lindigi1,
																	 pr_lindigi2 => vr_lindigi2,
																	 pr_lindigi3 => vr_lindigi3,
																	 pr_lindigi4 => vr_lindigi4,
																	 pr_cdbarras => vr_cdbarras,
																	 pr_vlrtotal => pr_vlrtotal,
																	 pr_dtapurac => pr_dtapurac,
																	 pr_nrcpfcgc => pr_nrcpfcgc,
																	 pr_cdtribut => pr_cdtribut,
																	 pr_nrrefere => pr_nrrefere,
																	 pr_dtvencto => pr_dtvencto,
																	 pr_vlrprinc => pr_vlrprinc,
																	 pr_vlrmulta => pr_vlrmulta,
																	 pr_vlrjuros => pr_vlrjuros,
																	 pr_vlrecbru => pr_vlrecbru,
																	 pr_vlpercen => pr_vlpercen,
																	 pr_idagenda => pr_idagenda,
																	 pr_dtagenda => vr_dtmvtopg,
																	 pr_indvalid => 1,
																	 pr_flmobile => pr_flmobile, 
																	 pr_cdseqfat => vr_cdseqfat,
																	 pr_vldocmto => vr_vldocmto,
																	 pr_nrdigfat => vr_nrdigfat,
																	 pr_cdcritic => vr_cdcritic,
																	 pr_dscritic => vr_dscritic);																	 
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro; 
    END IF;
		
		-- linha digitavel
		vr_dslindig := SUBSTR(to_char(vr_lindigi1,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi1,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi2,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi2,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi3,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi3,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi4,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi4,'fm000000000000'),12,1);
		
		-- efetivar
		IF pr_idefetiv = 1 THEN
			
		  -- Mobile seguir regra antiga, IB nova regra por limites
      --     IF pr_nrcpfope > 0 OR vr_idastcjt = 1 THEN
      IF vr_assin_conjunta = 1 THEN
				INET0002.pc_cria_trans_pend_darf_das( pr_cdcooper => pr_cdcooper,
																							pr_nrdcaixa => 900,
																							pr_cdoperad => 996,
																							pr_nmdatela => 'INTERNETBANK',
																							pr_cdagenci => 90,
																							pr_nrdconta => pr_nrdconta,
																							pr_idseqttl => pr_idseqttl,
																							pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END), --> Numero do cpf do representante legal
																							pr_cdcoptfn => 0,
																							pr_cdagetfn => 0,
																							pr_nrterfin => 0,
																							pr_nrcpfope => pr_nrcpfope,
																							pr_idorigem => pr_idorigem,
																							pr_dtmvtolt => rw_crapdat.dtmvtocd,
																							pr_tpdaguia => pr_tpdaguia,
																							pr_tpcaptur => pr_tpcaptur,
																							pr_lindigi1 => vr_lindigi1,
																							pr_lindigi2 => vr_lindigi2,
																							pr_lindigi3 => vr_lindigi3,
																							pr_lindigi4 => vr_lindigi4,
																							pr_cdbarras => vr_cdbarras,
																							pr_dsidepag => pr_dsidepag,
																							pr_vlrtotal => pr_vlrtotal,
																							pr_dsnomfon => pr_dsnomfon,
																							pr_dtapurac => pr_dtapurac,
																							pr_nrcpfcgc => pr_nrcpfcgc,
																							pr_cdtribut => pr_cdtribut,
																							pr_nrrefere => pr_nrrefere,
																							pr_dtvencto => pr_dtvencto,
																							pr_vlrprinc => pr_vlrprinc,
																							pr_vlrmulta => pr_vlrmulta,
																							pr_vlrjuros => pr_vlrjuros,
																							pr_vlrecbru => pr_vlrecbru,
																							pr_vlpercen => pr_vlpercen,
																							pr_dtagenda => vr_dtmvtopg,
																							pr_idastcjt => vr_idastcjt,
																							pr_idagenda => pr_idagenda,
																							pr_tpleitur => pr_tpleitor,
																							pr_cdcritic => vr_cdcritic,
																							pr_dscritic => vr_dscritic);
				IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro; 
				END IF;
				
			ELSE -- Efetiva, nao exige assinatura multipla
					
			-- Nesta data
			IF  pr_idagenda = 1 THEN 
				
				PAGA0003.pc_paga_tributos( pr_cdcooper => pr_cdcooper,
																	 pr_nrdconta => pr_nrdconta,
																	 pr_idseqttl => pr_idseqttl,
																	 pr_nrcpfope => pr_nrcpfope,
																	 pr_idorigem => pr_idorigem,
                                   pr_tpdaguia => pr_tpdaguia,
																	 pr_tpcaptur => pr_tpcaptur,
																	 pr_cdseqfat => vr_cdseqfat,
																	 pr_nrdigfat => vr_nrdigfat,
																	 pr_lindigi1 => vr_lindigi1,
																	 pr_lindigi2 => vr_lindigi2,
																	 pr_lindigi3 => vr_lindigi3,
																	 pr_lindigi4 => vr_lindigi4,
																	 pr_cdbarras => vr_cdbarras,
																	 pr_dsidepag => pr_dsidepag,
																	 pr_vlrtotal => pr_vlrtotal,
																	 pr_dsnomfon => pr_dsnomfon,
																	 pr_dtapurac => pr_dtapurac,
																	 pr_nrcpfcgc => pr_nrcpfcgc,
																	 pr_cdtribut => pr_cdtribut,
																	 pr_nrrefere => pr_nrrefere,
																	 pr_dtvencto => pr_dtvencto,
																	 pr_vlrprinc => pr_vlrprinc,
																	 pr_vlrmulta => pr_vlrmulta,
																	 pr_vlrjuros => pr_vlrjuros,
																	 pr_vlrecbru => pr_vlrecbru,
																	 pr_vlpercen => pr_vlpercen,
																	 pr_vldocmto => vr_vldocmto,
																	 pr_idagenda => pr_idagenda,
																	 pr_tpleitor => pr_tpleitor,
                                   pr_flmobile => pr_flmobile, -- Identificador de mobile
                                   pr_iptransa => pr_iptransa, -- IP da transação
                                   pr_iddispos => pr_iddispos, -- Identificador do dispositivo mobile                                
																	 pr_dsprotoc => vr_dsprotoc,
																	 pr_cdcritic => vr_cdcritic,
																	 pr_dscritic => vr_dscritic);			
												 
			  IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
												
			-- se for agendamento  
      ELSIF pr_idagenda = 2 THEN
				
				pc_cria_agend_tributos( pr_cdcooper => pr_cdcooper,
																pr_nrdconta => pr_nrdconta,
																pr_idseqttl => pr_idseqttl,
																pr_cdagenci => 90,
																pr_nrdcaixa => 900,
																pr_cdoperad => 996,
																pr_nrcpfope => pr_nrcpfope,
																pr_idorigem => pr_idorigem,
																pr_tpdaguia => pr_tpdaguia,
																pr_tpcaptur => pr_tpcaptur,
																pr_cdhistor => 508,
																pr_lindigi1 => vr_lindigi1,
																pr_lindigi2 => vr_lindigi2,
																pr_lindigi3 => vr_lindigi3,
																pr_lindigi4 => vr_lindigi4,
																pr_cdbarras => vr_cdbarras,
																pr_dsidepag => pr_dsidepag,
																pr_vlrtotal => pr_vlrtotal,
																pr_dsnomfon => pr_dsnomfon,
																pr_dtapurac => pr_dtapurac,
																pr_nrcpfcgc => pr_nrcpfcgc,
																pr_cdtribut => pr_cdtribut,
																pr_nrrefere => pr_nrrefere,
																pr_dtvencto => pr_dtvencto,
																pr_vlrprinc => pr_vlrprinc,
																pr_vlrmulta => pr_vlrmulta,
																pr_vlrjuros => pr_vlrjuros,
																pr_vlrecbru => pr_vlrecbru,
																pr_vlpercen => pr_vlpercen,
																pr_dtagenda => vr_dtmvtopg,
																pr_cdtrapen => 0,
																pr_tpleitor => pr_tpleitor,
                                pr_flmobile => pr_flmobile, -- Identificador de mobile
                                pr_iptransa => pr_iptransa, -- IP da transação
                                pr_iddispos => pr_iddispos, -- Identificador do dispositivo mobile                                																	 
																pr_dsprotoc => vr_dsprotoc,
																pr_cdcritic => vr_cdcritic,
																pr_dscritic => vr_dscritic);
																
        IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
				
			END IF;
			
			END IF;

			
			-- compor mensagem de retorno da operacao
			
			-- Nesta data
			IF pr_idagenda = 1 THEN
				
				--Representante COM assinatura conjunta
				IF vr_idastcjt = 1 THEN					
					vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso. Aguardando aprovação do(s) preposto(s)';
				--Representante SEM assinatura conjunta
				ELSE 
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
						vr_dsmsgope := 'Pagamento registrado com sucesso. Aguardando aprovação do registro pelo preposto.';
					--titular
					ELSE
						vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso.';
				  END IF;
										
				END IF;
				
			-- agendamento
			ELSE
				
				--Representante COM assinatura conjunta
				IF vr_idastcjt = 1 THEN					
          vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso. Aguardando aprovação do(s) preposto(s)';
          -- 18/04/2018 - TJ
					-- vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprovação do registro pelos demais responsáveis.';
				--Representante SEM assinatura conjunta
				ELSE					
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
            -- ### TJ
						vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprovação do registro pelo preposto.';
					--titular
					ELSE
            vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso.';
            -- 18/04/2018 - TJ
						-- vr_dsmsgope := 'Pagamento agendado com sucesso para o dia ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
				  END IF;
				END IF;
				
			END IF;
			
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_xml_operacao188, TRUE);
			dbms_lob.open(pr_xml_operacao188, dbms_lob.lob_readwrite);

			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao188
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<raiz>
														                        <DADOS_PAGAMENTO>
																										      <dsmsgope>'|| nvl(vr_dsmsgope,' ') ||'</dsmsgope>
																													<idastcjt>'|| nvl(TO_CHAR(vr_idastcjt),' ') ||'</idastcjt>
																													<dsprotoc>'|| NVL(TRIM(vr_dsprotoc),'')    ||'</dsprotoc>
																									  </DADOS_PAGAMENTO>');
			-- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao188
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</raiz>' 
														 ,pr_fecha_xml      => TRUE);
			
      --Gravar mensagem na VERLOG
			vr_dscritic := vr_dsmsgope;
		  pc_proc_geracao_log(pr_flgtrans => 1 /* TRUE */);
      pr_dsretorn := 'OK';
						
		ELSE --validação
		
		  -- houve alteração de data por nao ser um dia útil
		  IF vr_dtmvtopg <> pr_dtmvtopg THEN
			   vr_dsmsgope := 'O agendamento será registrado para débito em ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
			END IF;
		
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_xml_operacao188, TRUE);
			dbms_lob.open(pr_xml_operacao188, dbms_lob.lob_readwrite);

			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao188
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<raiz>'); 
	    
			-- Insere dados
			gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao188
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<DADOS_PAGAMENTO>
																												<lindigi1>'|| vr_lindigi1           ||'</lindigi1>
																												<lindigi2>'|| vr_lindigi2           ||'</lindigi2>
																												<lindigi3>'|| vr_lindigi3           ||'</lindigi3>
																												<lindigi4>'|| vr_lindigi4           ||'</lindigi4>
																												<dslindig>'|| vr_dslindig           ||'</dslindig>
																												<cdbarras>'|| vr_cdbarras           ||'</cdbarras> 
																												<dtmvtopg>'|| to_char(vr_dtmvtopg,'DD/MM/RRRR')||'</dtmvtopg>
																												<vlrtotal>'|| pr_vlrtotal            ||'</vlrtotal>
																												<cdseqfat>'|| vr_cdseqfat            ||'</cdseqfat>
																												<nrdigfat>'|| vr_nrdigfat            ||'</nrdigfat>
																												<dttransa>'|| to_char(SYSDATE,'DD/MM/RRRR') ||'</dttransa>
																												<dsmsgope>'|| nvl(vr_dsmsgope,' ')   ||'</dsmsgope>																												
																											</DADOS_PAGAMENTO>');  
                                                                                                         
			-- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_xml_operacao188
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</raiz>' 
														 ,pr_fecha_xml      => TRUE);
      pr_dsretorn := 'OK';
					
		END IF;		

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);          
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';       
			
			pc_proc_geracao_log(pr_flgtrans => 0 /* false */ );  
                                
    WHEN OTHERS THEN
      
      vr_dscritic := 'Não foi possivel validar pagamento DARF/DAS. ' ||SQLERRM; 
			pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
			
			vr_dscritic := vr_dscritic || SQLERRM; 
      pr_dsretorn := 'NOK';
			
			pc_proc_geracao_log(pr_flgtrans => 0 /* false */ );
			
  END pc_InternetBank188;
  
  PROCEDURE pc_cria_agend_tributos(pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
                                  ,pr_cdagenci IN INTEGER               -- PA
                                  ,pr_nrdcaixa IN NUMBER                -- Numero do Caixa
                                  ,pr_cdoperad IN VARCHAR2              -- Cd Operador
                                  ,pr_nrcpfope IN NUMBER -- CPF do operador PJ
                                  ,pr_idorigem IN INTEGER -- Canal de origem da operação
                                  ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE)
                                  ,pr_tpcaptur IN INTEGER -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                  ,pr_cdhistor IN INTEGER               -- Histórico
                                  ,pr_lindigi1 IN NUMBER -- Primeiro campo da linha digitável da guia
                                  ,pr_lindigi2 IN NUMBER -- Segundo campo da linha digitável da guia
                                  ,pr_lindigi3 IN NUMBER -- Terceiro campo da linha digitável da guia
                                  ,pr_lindigi4 IN NUMBER -- Quarto campo da linha digitável da guia
                                  ,pr_cdbarras IN VARCHAR2 -- Código de barras da guia
                                  ,pr_dsidepag IN VARCHAR2 -- Descrição da identificação do pagamento
                                  ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                  ,pr_dsnomfon IN VARCHAR2 -- Nome e telefone da guia
                                  ,pr_dtapurac IN DATE -- Período de apuração da guia
                                  ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                  ,pr_cdtribut IN VARCHAR2 -- Código de tributação da guia
                                  ,pr_nrrefere IN VARCHAR2 -- Número de referência da guia
                                  ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                  ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                  ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                  ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                  ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                  ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                  ,pr_dtagenda IN DATE -- Data de agendamento
                                  ,pr_cdtrapen IN NUMBER -- Código de sequencial da transação pendente
                                  ,pr_tpleitor IN INTEGER               -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                                  ,pr_flmobile IN INTEGER DEFAULT 0     -- Identificador de mobile
                                  ,pr_iptransa IN VARCHAR2 DEFAULT NULL -- IP da transação
                                  ,pr_iddispos IN VARCHAR2 DEFAULT NULL -- Identificador do dispositivo mobile    
                                  ,pr_dsprotoc OUT VARCHAR2 -- Protocolo
                                  ,pr_cdcritic OUT INTEGER -- Código do erro
                                  ,pr_dscritic OUT VARCHAR2) IS -- Descriçao do erro                                   
		/* .............................................................................

     Programa: pc_cria_agend_darf_das
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 03/09/2018

     Objetivo  : Procedure para criação dos agendamentos de pagamento de DARF/DAS

     Alteracoes:  22/08/2017 - Adicionar parametro para data de agendamento na pc_cria_comprovante_darf_das
                               para tambem gravar este campo no protocolo de agendamentos de DARF/DAS 
                               (Lucas Ranghetti #705465)
                               
                  14/09/2017 - Adicionar no campo nrrefere como varchar2 (Lucas Ranghetti #756034)
                  
                  03/01/2017 - Renomeado rotina de para pc_cria_agend_tributos e realizado
                               ajustes para arrecadação de FGTS/DAE.
                               PRJ406-FGTS (Odirlei-AMcom)

				  03/09/2018 - Correção para remover lote (Jonata - Mouts).

    ..............................................................................*/															 

		rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
		rw_craplau craplau%ROWTYPE;
		
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper,
			       ass.nrdconta,
             ass.nmprimtl,
             ass.idastcjt
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
		rw_crabass cr_crapass%ROWTYPE;
		
	CURSOR cr_crapass_titular(pr_cdcooper crapass.cdcooper%TYPE
							 ,pr_nrdconta crapass.nrdconta%TYPE
							 ,pr_idseqttl crapttl.idseqttl%TYPE) IS
    -- Pessoa Fídica
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,ass.dtabtcct
          ,ass.idastcjt
          ,ttl.nmextttl
      FROM crapass ass
          ,crapttl ttl
     WHERE ass.cdcooper = ttl.cdcooper
       AND ass.nrdconta = ttl.nrdconta
       AND ass.inpessoa = 1 -- Pessoa Física

       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl
    UNION ALL
    -- Pessoa Jurídica
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,ass.dtabtcct
          ,ass.idastcjt
          ,ass.nmprimtl nmextttl
      FROM crapass ass
     WHERE ass.inpessoa <> 1 -- Pessoa Jurídica
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ROWNUM = 1;
	  rw_crapass cr_crapass_titular%ROWTYPE;

    CURSOR cr_crapcon (pr_cdcooper  crapcon.cdcooper%TYPE,
                       pr_cdempcon  crapcon.cdempcon%TYPE,
                       pr_cdsegmto  crapcon.cdsegmto%TYPE ) IS
      SELECT crapcon.cdcooper
			      ,crapcon.flginter
						,crapcon.nmextcon
						,crapcon.tparrecd
						,crapcon.cdhistor
						,crapcon.nmrescon
						,crapcon.cdsegmto
						,crapcon.cdempcon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto
				 AND crapcon.tparrecd IN (1,2); --> Sicredi
    rw_crapcon cr_crapcon%ROWTYPE;
		
		CURSOR cr_crapscn (pr_cdempcon IN crapscn.cdempcon%TYPE
											,pr_cdsegmto IN crapscn.cdsegmto%TYPE) IS
			 SELECT crapscn.cdsegmto
						 ,crapscn.cdempcon
				 FROM crapscn
			 WHERE crapscn.cdempcon = pr_cdempcon AND
						 crapscn.cdsegmto = pr_cdsegmto;
     rw_crapscn cr_crapscn%ROWTYPE;
		 
		CURSOR cr_crapscn2(pr_cdempres crapscn.cdempres%TYPE,
		                   pr_tpmeiarr crapstn.tpmeiarr%TYPE)IS
			SELECT scn.cdempres
						,scn.dsnomcnv
					  ,scn.dssigemp
					  ,stn.cdtransa
			FROM crapscn scn,
			     crapstn stn
		 WHERE scn.cdempres = pr_cdempres
		   AND stn.cdempres = scn.cdempres
			 AND stn.tpmeiarr = pr_tpmeiarr;
			rw_crapscn2 cr_crapscn2%ROWTYPE;
		 
    CURSOR cr_tbarrec (pr_cdempcon IN crapscn.cdempcon%TYPE
									    ,pr_cdsegmto IN crapscn.cdsegmto%TYPE) IS
			 SELECT arr.cdsegmto
						 ,arr.cdempcon
				 FROM tbconv_arrecadacao arr
			 WHERE arr.cdempcon = pr_cdempcon 
         AND arr.cdsegmto = pr_cdsegmto;
     rw_tbarrec cr_tbarrec%ROWTYPE;
      
		CURSOR cr_crapsnh (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.cdcooper,
             crapsnh.nrcpfcgc,
             crapsnh.nrdconta
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.idseqttl = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;
		
		-- buscar dados avalista terceiro
    CURSOR cr_crapavt (pr_cdcooper  crapsnh.cdcooper%TYPE,
                       pr_nrdconta  crapsnh.nrdconta%TYPE,
                       pr_nrcpfcgc  crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper,
             crapavt.nrdctato,
             crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE;
																	 
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
  
	vr_dtagenda DATE;
	vr_dtvencto DATE;
	vr_dttolera DATE;
	vr_dsnomcnv VARCHAR2(200);
	vr_dsidepag VARCHAR(100);
	vr_nrdolote NUMBER;
	vr_dslindig VARCHAR2(200);
	vr_tpdvalor INTEGER;
	vr_nrcpfpre NUMBER;
	vr_cdbarras VARCHAR2(100);
	vr_nmprepos VARCHAR2(200);
	vr_dsorigem VARCHAR2(200);
	vr_flgagend BOOLEAN;
	vr_cdtippro INTEGER;
	vr_dsprotoc VARCHAR2(80);
	vr_cdtransa VARCHAR2(80);
	vr_dssigemp	VARCHAR2(80);
  vr_idorigem INTEGER;
  vr_idanalise_fraude   INTEGER;
  vr_cdprodut           INTEGER;
  vr_cdoperac           INTEGER;    
  vr_dstransa           VARCHAR2(100);
  vr_nrseqdig craplcm.nrseqdig%TYPE :=0;
  
  -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- criar rowtype controle
        rw_craplot_ctl cr_craplot%ROWTYPE;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot_ctl;
            pr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= pr_dscritic||'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;
  
        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;
		
        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote                  
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote                  
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING  craplot.ROWID
                       ,craplot.nrdolote                       
                       ,craplot.cdbccxlt
                       ,craplot.tplotmov
                       ,craplot.dtmvtolt
                       ,craplot.cdagenci
                       ,craplot.cdhistor
                       ,craplot.cdoperad
                       ,craplot.qtcompln
                       ,craplot.qtinfoln
                       ,craplot.vlcompcr
                       ,craplot.vlinfocr
                   INTO rw_craplot_ctl.ROWID
                      , rw_craplot_ctl.nrdolote                      
                      , rw_craplot_ctl.cdbccxlt
                      , rw_craplot_ctl.tplotmov
                      , rw_craplot_ctl.dtmvtolt
                      , rw_craplot_ctl.cdagenci
                      , rw_craplot_ctl.cdhistor
                      , rw_craplot_ctl.cdoperad
                      , rw_craplot_ctl.qtcompln
                      , rw_craplot_ctl.qtinfoln
                      , rw_craplot_ctl.vlcompcr
                      , rw_craplot_ctl.vlinfocr;
        
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot_ctl;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;
  
		
  BEGIN
	  -- Busca a data da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;	
	
		-- Descrição do Cedente
    vr_dsidepag := NVL(trim(pr_dsidepag), CASE pr_tpdaguia
                                          WHEN 1 THEN 'DARF'
                                            WHEN 2 THEN 'DAS' 
                                            WHEN 3 THEN 'FGTS'
                                            WHEN 4 THEN 'DAE' 
                                          END);

		vr_dtagenda := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
                                               pr_dtmvtolt => pr_dtagenda, 
                                               pr_tipo     => 'A');
		-- Buscar dados do associado
    OPEN cr_crapass_titular (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
							 pr_idseqttl => pr_idseqttl);
    FETCH cr_crapass_titular INTO rw_crapass;
		
    IF cr_crapass_titular%NOTFOUND THEN
      CLOSE cr_crapass_titular;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass_titular;
    END IF;
		
		-- Convênios Sicredi/Bancoob
    IF pr_tpdaguia in (1,2) THEN -- DARF/DAS
		  vr_tpdvalor := 1; --> Sicredi 
    ELSIF pr_tpdaguia in (3,4) THEN -- FGTS/DAE
      vr_tpdvalor := 2; --> Bancoob
    END IF;
		vr_cdtransa := '';
		vr_dssigemp	:= '';
		vr_nrdolote := 11000 + pr_nrdcaixa;
		
		-- Compor linha digitável
		vr_dslindig := SUBSTR(to_char(pr_lindigi1,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(pr_lindigi1,'fm000000000000'),12,1) ||' '||
                       
									 SUBSTR(to_char(pr_lindigi2,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(pr_lindigi2,'fm000000000000'),12,1) ||' '||
                       
									 SUBSTR(to_char(pr_lindigi3,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(pr_lindigi3,'fm000000000000'),12,1) ||' '||
                       
									 SUBSTR(to_char(pr_lindigi4,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(pr_lindigi4,'fm000000000000'),12,1);
		
		IF pr_tpcaptur = 1 THEN --cdbarras
		-- Verificar convenio
		OPEN cr_crapcon (pr_cdcooper => pr_cdcooper,
										 pr_cdempcon => SUBSTR(to_char(pr_lindigi2,'fm000000000000'),5,4),
										 pr_cdsegmto => SUBSTR(to_char(pr_lindigi1,'fm000000000000'),2,1));
		FETCH cr_crapcon INTO rw_crapcon;

		IF cr_crapcon%FOUND THEN
			CLOSE cr_crapcon; 
									
        IF rw_crapcon.tparrecd = 1 THEN						
			-- Verificar registro de convenio sicredi
			OPEN cr_crapscn (pr_cdempcon  => rw_crapcon.cdempcon
										  ,pr_cdsegmto  => rw_crapcon.cdsegmto);
			FETCH cr_crapscn INTO rw_crapscn;
			
			IF cr_crapscn%NOTFOUND THEN				
				CLOSE cr_crapscn; 
			  vr_dscritic := 'Convenio sicredi nao encontrado.';
				RAISE vr_exc_erro;
			END IF;
          CLOSE cr_crapscn; 
        ELSIF rw_crapcon.tparrecd = 2 THEN

          -- Verificar registro de convenio bancoob
          OPEN cr_tbarrec (pr_cdempcon  => rw_crapcon.cdempcon
                          ,pr_cdsegmto  => rw_crapcon.cdsegmto);
          FETCH cr_tbarrec INTO rw_crapscn;
    			
          IF cr_tbarrec%NOTFOUND THEN				
            CLOSE cr_tbarrec; 
            vr_dscritic := 'Convenio bancoob nao encontrado.';
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_tbarrec;
        END IF;
														
			vr_dsnomcnv := rw_crapcon.nmextcon;											
		ELSE 
			CLOSE cr_crapcon; 
			vr_dscritic := 'Convenio nao encontrado.';
      RAISE vr_exc_erro;			
			END IF;
		
		ELSE --manual				
			OPEN cr_crapscn2 (pr_cdempres => CASE pr_cdtribut
																					WHEN '6106' THEN 'D0'
												ELSE 'A0' 
																				END,
												pr_tpmeiarr => 	CASE pr_idorigem
																					WHEN 3 THEN 'D'
																					ELSE 'C'
												END);
			FETCH cr_crapscn2 INTO rw_crapscn2;
					    
			--Se nao encontrar
			IF NOT cr_crapscn2%FOUND THEN
				vr_cdcritic:= 0;
				vr_dscritic:= 'Convenio nao encontrado.';
				CLOSE cr_crapscn2;
				RAISE vr_exc_erro;
			END IF;
			
		  CLOSE cr_crapscn2;
			vr_dsnomcnv := rw_crapscn2.dsnomcnv;			
			vr_cdtransa := rw_crapscn2.cdtransa;
			vr_dssigemp	:= rw_crapscn2.dssigemp;
		END IF;
		
    vr_nrseqdig := fn_sequence('CRAPLOT'
                              ,'NRSEQDIG'
                              ,''||pr_cdcooper||';'
                                 ||to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')||';'
                                 ||pr_cdagenci||';'
                                 ||100||';'
                                 ||vr_nrdolote);  
     /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
       PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
       se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
       da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
       a agencia do cooperado*/
			
    if not PAGA0001.fn_exec_paralelo then 
      
	  -- Controlar criação de lote, com pragma
	  pc_insere_lote (pr_cdcooper => pr_cdcooper,
		  			  pr_dtmvtolt => rw_crapdat.dtmvtocd,
					  pr_cdagenci => pr_cdagenci,
					  pr_cdbccxlt => 100,
					  pr_nrdolote => vr_nrdolote,
					  pr_cdoperad => pr_cdoperad,
					  pr_nrdcaixa => pr_nrdcaixa,
					  pr_tplotmov => 12,
					  pr_cdhistor => 0,
					  pr_craplot  => rw_craplot,
					  pr_dscritic => vr_dscritic);	
  			
			
      ELSE
        paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                     pr_cdagenci => pr_cdagenci,
                                     pr_cdbccxlt => 100,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_nrdcaixa => pr_nrdcaixa,
                                     pr_tplotmov => 12,
                                     pr_cdhistor => 0,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'PAGA0003.PC_PAGA_DARF_DAS');
                                      
        rw_craplot.cdcooper := pr_cdcooper;
        rw_craplot.dtmvtolt := rw_crapdat.dtmvtocd;
        rw_craplot.cdagenci := pr_cdagenci;
        rw_craplot.nrdolote := vr_nrdolote;
        rw_craplot.cdoperad := pr_cdoperad;
        rw_craplot.tplotmov := 12;
        rw_craplot.cdhistor := 0;
        
      END IF;
      
			IF pr_idorigem = 3 THEN -- INTERNET
				
				IF rw_crapass.idastcjt = 0 THEN
					
          -- buscar dados do preposto
          OPEN cr_crapsnh (pr_cdcooper  => pr_cdcooper,
                           pr_nrdconta  => pr_nrdconta);
          FETCH cr_crapsnh INTO rw_crapsnh;

          IF cr_crapsnh%FOUND THEN
            CLOSE cr_crapsnh;
            vr_nrcpfpre := rw_crapsnh.nrcpfcgc;
            
            -- buscar dados avalista terceiro
            OPEN cr_crapavt (pr_cdcooper => rw_crapsnh.cdcooper,
                             pr_nrdconta => rw_crapsnh.nrdconta,
                             pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);
            FETCH cr_crapavt INTO rw_crapavt;

            IF cr_crapavt%FOUND THEN							
              CLOSE cr_crapavt;
              
              -- buscar da conta do avalista
              OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => rw_crapavt.nrdctato);
              FETCH cr_crapass INTO rw_crabass;

              IF cr_crapass%FOUND THEN
                vr_nmprepos := rw_crabass.nmprimtl;
              ELSE
                vr_nmprepos := rw_crapavt.nmdavali;
              END IF;
							
              CLOSE cr_crapass;
							
            ELSE
              CLOSE cr_crapavt;
							
            END IF;
            
          ELSE
            CLOSE cr_crapsnh;
						
          END IF;
          -- fim - busca dados do preposto          
        END IF;				
			END IF;
			
      
      --> Para Tributos de origens InternetBank e Mobile,
      --> Deve ser gerado o registro de analise de fraude antes de
      --> realizar a operacao
      IF pr_idorigem = 3 THEN
        
        IF pr_flmobile = 1 THEN
          vr_idorigem := 10; --> MOBILE
        ELSE
          vr_idorigem := 3; --> InternetBank
        END IF;
        
        IF pr_tpdaguia IN (1,2) THEN
          vr_cdprodut := 45;  --> Pagamento DARF/DAS
          vr_cdoperac :=  3;  --> Pagamento DARF/DAS
          vr_dstransa := 'Agendamento DARF/DAS';
        ELSIF pr_tpdaguia IN (3,4) THEN
          vr_cdprodut := 46;  --> Pagamento FGTS/DAE
          vr_cdoperac :=  4;  --> Pagamento FGTS/DAE
          vr_dstransa := 'Agendamento FGTS/DAE';
        END IF;       
       
        vr_idanalise_fraude := NULL;
        --> Rotina para Inclusao do registro de analise de fraude
        AFRA0001.pc_Criar_Analise_Antifraude(pr_cdcooper    => pr_cdcooper
                                            ,pr_cdagenci    => pr_cdagenci
                                            ,pr_nrdconta    => pr_nrdconta
                                            ,pr_cdcanal     => vr_idorigem 
                                            ,pr_iptransacao => pr_iptransa
                                            ,pr_dtmvtolt    => rw_crapdat.dtmvtocd
                                            ,pr_cdproduto   => vr_cdprodut
                                            ,pr_cdoperacao  => vr_cdoperac
                                            ,pr_iddispositivo => pr_iddispos 
                                            ,pr_dstransacao => vr_dstransa
                                            ,pr_tptransacao => 2 --> 2-Agendamento
                                            ,pr_idanalise_fraude => vr_idanalise_fraude
                                            ,pr_dscritic   => vr_dscritic);
        vr_dscritic := NULL;
			END IF;
			
			
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
			
			-- inserção na craplau
			BEGIN
        INSERT INTO craplau
                    (craplau.cdcooper
                    ,craplau.nrdconta
                    ,craplau.idseqttl
                    ,craplau.dttransa
                    ,craplau.hrtransa
                    ,craplau.dtmvtolt
                    ,craplau.cdagenci
                    ,craplau.cdbccxlt
                    ,craplau.nrdolote
                    ,craplau.nrseqdig
                    ,craplau.nrdocmto
                    ,craplau.cdhistor
                    ,craplau.dsorigem
                    ,craplau.insitlau
                    ,craplau.cdtiptra
                    ,craplau.dscedent
                    ,craplau.dscodbar
                    ,craplau.dslindig
                    ,craplau.dtmvtopg
                    ,craplau.vllanaut
                    ,craplau.dtvencto
                    ,craplau.cddbanco
                    ,craplau.cdageban
                    ,craplau.nrctadst
                    ,craplau.cdcoptfn
                    ,craplau.cdagetfn
                    ,craplau.nrterfin
                    ,craplau.nrcpfope
                    ,craplau.nrcpfpre
                    ,craplau.nmprepos
                    ,craplau.idtitdda
                    ,craplau.tpdvalor
					          ,craplau.flmobile
					          ,craplau.idtipcar
					          ,craplau.nrcartao
                    ,craplau.idanafrd)
             VALUES ( pr_cdcooper               -- craplau.cdcooper
                     ,pr_nrdconta               -- craplau.nrdconta
                     ,pr_idseqttl               -- craplau.idseqttl
                     ,SYSDATE                   -- craplau.dttransa
                     ,gene0002.fn_busca_time    -- craplau.hrtransa
                     ,rw_crapdat.dtmvtocd       -- craplau.dtmvtolt
                     ,pr_cdagenci               -- craplau.cdagenci
                     ,rw_craplot.cdbccxlt       -- craplau.cdbccxlt
                     ,rw_craplot.nrdolote       -- craplau.nrdolote
                     ,vr_nrseqdig               -- craplau.nrseqdig
                     ,vr_nrseqdig               -- craplau.nrdocmto
                     ,pr_cdhistor               -- craplau.cdhistor
                     ,vr_dsorigem               -- craplau.dsorigem
                     ,1  /** PENDENTE  **/      -- craplau.insitlau
                     ,(CASE pr_tpdaguia 
                          WHEN 1 THEN 10 --> DARF/DAS
                          WHEN 2 THEN 10 --> DARF/DAS 
                          WHEN 3 THEN 12 --> FGTS
                          WHEN 4 THEN 13 --> DAE
                          ELSE 10
                       END)                     -- craplau.cdtiptra
                     ,vr_dsidepag               -- craplau.dscedent
                     ,pr_cdbarras               -- craplau.dscodbar
                     ,nvl(vr_dslindig,' ')      -- craplau.dslindig
                     ,pr_dtagenda               -- craplau.dtmvtopg
                     ,pr_vlrtotal               -- craplau.vllanaut
                     ,pr_dtvencto               -- craplau.dtvencto
                     ,0                         -- craplau.cddbanco
                     ,0                         -- craplau.cdageban
                     ,0                         -- craplau.nrctadst
                     ,0                         -- craplau.cdcoptfn
                     ,0                         -- craplau.cdagetfn
                     ,0                         -- craplau.nrterfin
                     ,pr_nrcpfope               -- craplau.nrcpfope
                     ,vr_nrcpfpre               -- craplau.nrcpfpre
                     ,nvl(vr_nmprepos,' ')      -- craplau.nmprepos
                     ,0                         -- craplau.idtitdda
                     ,nvl(vr_tpdvalor,0)        -- craplau.tpdvalor
					           ,0                         -- craplau.flmobile
                     ,0                         -- craplau.idtipcar
                     ,0                         -- craplau.nrcartao
                     ,nullif(vr_idanalise_fraude,0)) -- craplau.idanafrd
						RETURNING craplau.idlancto,
						          craplau.dtmvtolt,
											craplau.hrtransa,
											craplau.nrdocmto,
											craplau.vllanaut,
											craplau.cdtiptra
						     INTO rw_craplau.idlancto,
                      rw_craplau.dtmvtolt,
                      rw_craplau.hrtransa,
                      rw_craplau.nrdocmto,
											rw_craplau.vllanaut,
											rw_craplau.cdtiptra;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lançamento automatico DARF/DAS: '||SQLERRM;
          RAISE vr_exc_erro; 
      END;
			
      --> se Sicredi
      IF rw_craplau.cdtiptra = 10 THEN

			-- inserção dados detalhados DARF/DAS
			BEGIN
        INSERT INTO tbpagto_agend_darf_das
                    (tbpagto_agend_darf_das.idlancto
                    ,tbpagto_agend_darf_das.cdcooper
                    ,tbpagto_agend_darf_das.nrdconta
                    ,tbpagto_agend_darf_das.tppagamento
                    ,tbpagto_agend_darf_das.tpcaptura
                    ,tbpagto_agend_darf_das.dsidentif_pagto
                    ,tbpagto_agend_darf_das.dsnome_fone
                    ,tbpagto_agend_darf_das.dscod_barras
                    ,tbpagto_agend_darf_das.dslinha_digitavel
                    ,tbpagto_agend_darf_das.dtapuracao
                    ,tbpagto_agend_darf_das.nrcpfcgc
                    ,tbpagto_agend_darf_das.cdtributo
                    ,tbpagto_agend_darf_das.nrrefere
                    ,tbpagto_agend_darf_das.vlprincipal
                    ,tbpagto_agend_darf_das.vlmulta
                    ,tbpagto_agend_darf_das.vljuros
                    ,tbpagto_agend_darf_das.vlreceita_bruta
                    ,tbpagto_agend_darf_das.vlpercentual
                    ,tbpagto_agend_darf_das.dtvencto
                    ,tbpagto_agend_darf_das.tpleitura_docto)
             VALUES (rw_craplau.idlancto
						        ,pr_cdcooper
										,pr_nrdconta
										,pr_tpdaguia
										,pr_tpcaptur
										,vr_dsidepag
										,pr_dsnomfon
										,pr_cdbarras
										,nvl(vr_dslindig,' ')
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
										,pr_tpleitor
						         );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lançamento automatico DARF/DAS: '||SQLERRM;
          RAISE vr_exc_erro; 
      END;
			
      --> se Bancoob
      ELSIF rw_craplau.cdtiptra IN (12,13) THEN
        -- Inserção dados do tributo
        BEGIN
          INSERT INTO  tbpagto_agend_tributos
                      (idlancto,         
                       cdcooper,         
                       nrdconta,         
                       tpleitura_docto,  
                       tppagamento,      
                       dscod_barras,     
                       dslinha_digitavel,
                       nridentificacao,  
                       cdtributo,        
                       dtvalidade,       
                       dtcompetencia,    
                       nrseqgrde,        
                       nridentificador,  
                       dsidenti_pagto)
               VALUES (rw_craplau.idlancto            -- idlancto
                      ,pr_cdcooper                    -- cdcooper
                      ,pr_nrdconta                    -- nrdconta
                      ,pr_tpcaptur                    -- tpleitura_docto
                      ,pr_tpdaguia                    -- tppagamento
                      ,pr_cdbarras                    -- dscod_barras
                      ,nvl(vr_dslindig,' ')           -- dslinha_digitavel
                      ,pr_nrcpfcgc                    -- nridentificacao
                      ,pr_cdtribut                    -- cdtributo
                      ,pr_dtvencto                    -- dtvalidade
                      ,pr_dtapurac                    -- dtcompetencia
                      ,(CASE 
                          WHEN rw_crapcon.cdempcon IN (0178,0240) THEN SUBSTR(pr_cdbarras, 26,3)
                          ELSE NULL
                        END)                          -- nrseqgrde            
                      ,trim(pr_nrrefere)              -- nridentificador 
                      ,vr_dsidepag                    -- dsidenti_pagto
                      );
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir lançamento automatico FGTS/DAE: '||SQLERRM;
            RAISE vr_exc_erro; 
        END;
      
      END IF;
      
      -- gerar protocolo de agendamento apenas para DARF/DAS
      IF pr_tpdaguia IN (1,2) THEN
        
				IF pr_tpcaptur = 1 THEN -- CD BARRAS
					-- Caso o o código de barras estiver vazio popula com base na linha digitável
					IF TRIM(pr_cdbarras) IS NULL THEN
						 --Se possuir linha digitável popula o código de barras
						 IF TRIM(pr_lindigi1) IS NOT NULL THEN
							 vr_cdbarras := SUBSTR(to_char(pr_lindigi1, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi2, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi3, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi4, 'fm000000000000'), 1, 11);
						 END IF;
					ELSE
						vr_cdbarras := pr_cdbarras;
					END IF;
					
					-- Validação referente aos dias de tolerancia
					cxon0014.pc_verifica_dtlimite_tributo(pr_cdcooper      => pr_cdcooper
                                               ,pr_cdagenci      => pr_cdagenci
                                               ,pr_cdempcon      => rw_crapcon.cdempcon
                                               ,pr_cdsegmto      => rw_crapcon.cdsegmto
                                               ,pr_codigo_barras => vr_cdbarras
                                               ,pr_dtmvtopg      => vr_dtvencto
                                               ,pr_flnrtole      => FALSE                                               
                                               ,pr_dttolera      => vr_dttolera
                                               ,pr_cdcritic      => vr_cdcritic
                                               ,pr_dscritic      => vr_dscritic);

					vr_dtvencto := vr_dttolera;					
				ELSE -- MANUAL
					vr_dtvencto := pr_dtvencto;
				END IF;
								
		    -- tipo do protocolo
	      vr_cdtippro := CASE pr_tpdaguia
	                     WHEN 1 THEN 18
	                     ELSE 19
	                    END;
    
	      --Obtem flag de agendamento
	      vr_flgagend := TRUE;
			
        -- Gera um protocolo para o pagamento
        paga0003.pc_cria_comprovante_tributos(pr_cdcooper => rw_crapass.cdcooper -- Código da cooperativa
                                             ,pr_nrdconta => rw_crapass.nrdconta -- Número da conta
                                             ,pr_nmextttl => rw_crapass.nmextttl -- Nome do Titular
                                             ,pr_nrcpfope => pr_nrcpfope         -- CPF do operador PJ
                                             ,pr_nrcpfpre => vr_nrcpfpre         -- Número pré operação
                                             ,pr_nmprepos => nvl(vr_nmprepos,' ')-- Nome Preposto
                                             ,pr_tpcaptur => pr_tpcaptur         -- Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                             ,pr_cdtippro => vr_cdtippro         -- Código do tipo do comprovante
                                             ,pr_dtmvtolt => rw_craplau.dtmvtolt -- Data de movimento da autenticação
                                             ,pr_hrautent => rw_craplau.hrtransa -- Horário da autenticação
                                             ,pr_nrdocmto => rw_craplau.nrdocmto -- Número do documento
                                             ,pr_nrseqaut => rw_craplau.idlancto -- Sequencial da autenticação
                                             ,pr_nrdcaixa => pr_nrdcaixa         -- Número do caixa da autenticação
                                             ,pr_idorigem => pr_idorigem         -- Indicador de canal de origem  da transação
                                             ,pr_nmconven => vr_dsnomcnv         -- Nome do convênio da guia
                                             ,pr_lindigi1 => pr_lindigi1         -- Primeiro campo da linha digitável da guia
                                             ,pr_lindigi2 => pr_lindigi2         -- Segundo campo da linha digitável da guia
                                             ,pr_lindigi3 => pr_lindigi3         -- Terceiro campo da linha digitável da guia
                                             ,pr_lindigi4 => pr_lindigi4         -- Quarto campo da linha digitável da guia
                                             ,pr_cdbarras => pr_cdbarras         -- Código de barras da guia
                                             ,pr_dsidepag => vr_dsidepag         -- Descrição da identificação do pagamento
                                             ,pr_vlrtotal => rw_craplau.vllanaut -- Valor total do pagamento da guia
                                             ,pr_dsnomfon => pr_dsnomfon         -- Nome e telefone da guia
                                             ,pr_dtapurac => pr_dtapurac         -- Período de apuração da guia
                                             ,pr_nrcpfcgc => pr_nrcpfcgc         -- CPF/CNPJ da guia
                                             ,pr_cdtribut => pr_cdtribut         -- Código de tributação da guia
                                             ,pr_nrrefere => pr_nrrefere         -- Número de referência da guia
                                             ,pr_dtvencto => vr_dtvencto         -- Data de vencimento da guia
                                             ,pr_vlrprinc => pr_vlrprinc         -- Valor principal da guia
                                             ,pr_vlrmulta => pr_vlrmulta         -- Valor da multa da guia
                                             ,pr_vlrjuros => pr_vlrjuros         -- Valor dos juros da guia
                                             ,pr_vlrecbru => pr_vlrecbru         -- Valor da receita bruta acumulada da guia
                                             ,pr_vlpercen => pr_vlpercen         -- Valor do percentual da guia
                                             ,pr_flgagend => vr_flgagend         -- Indicador de agendamento (TRUE – Agendamento / FALSE – Nesta Data)
                                             ,pr_cdtransa => vr_cdtransa         -- Código da transação por meio de arrecadação do SICREDI
                                             ,pr_dssigemp => vr_dssigemp         -- Descrição resumida de convênio DARF para autenticação modelo SICREDI
                                             ,pr_dtagenda => pr_dtagenda         -- Data do Agendamento
                                             ,pr_dsprotoc => vr_dsprotoc         -- Descrição do protocolo do comprovante
                                             ,pr_cdcritic => vr_cdcritic         -- Código do erro
                                             ,pr_dscritic => vr_dscritic);       -- Descriçao do erro
																					 	    
			--Se ocorreu erro
			IF nvl(vr_cdcritic,0) > 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
						
			pr_dsprotoc := vr_dsprotoc;
    END IF; --> FIM IF pr_tpdaguia IN (1,2)

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
			ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PAGA0003.pc_cria_agend_tributos. ' ||SQLERRM;
			ROLLBACK;
  END pc_cria_agend_tributos;
  
  /* Procedimento do internetbank operação 187 - Consulta de Horario Limite DARF/DAS */
  PROCEDURE pc_InternetBank187(pr_cdcooper IN crapcop.cdcooper%type      -- Codigo Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%type      -- Agencia do Associado
                              ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero caixa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Identificador Sequencial titulo
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data Movimento
                              ,pr_idagenda IN INTEGER                    -- Indicador agenda
                              ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE      -- Data Pagamento
                              ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  -- Valor Lancamento
                              ,pr_cddbanco IN crapcti.cddbanco%TYPE      -- Codigo banco
                              ,pr_cdageban IN crapcti.cdageban%TYPE      -- Codigo Agencia
                              ,pr_nrctatrf IN crapcti.nrctatrf%TYPE      -- Numero Conta Transferencia
                              ,pr_cdtiptra IN INTEGER                    -- 1 - Transferencia / 2 - Pagamento /3 - Credito Salario / 4 - TED
                              ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Codigo Operador
                              ,pr_tpoperac IN INTEGER                    -- 1 - Transferencia intracooperativa /2 - Pagamento /3 - Cobranca /4 - TED / 5 - Transferencia intercooperativa
                              ,pr_flgvalid IN INTEGER                    -- (0- False, 1-True)Indicador validacoes
                              ,pr_dsorigem IN craplau.dsorigem%TYPE      -- Descricao Origem
                              ,pr_nrcpfope IN crapopi.nrcpfope%TYPE      -- CPF operador
                              ,pr_flgctrag IN INTEGER                    -- (0- False, 1-True)controla validacoes na efetivacao de agendamentos
                              ,pr_nmdatela IN VARCHAR2                   -- Nome da Tela
                              ,pr_iptransa IN VARCHAR2                   -- IP da transacao no IBank/mobile
                              ,pr_flmobile IN INTEGER                    -- Indicador se origem é do Mobile
                              ,pr_xml_dsmsgerr    OUT VARCHAR2           -- Retorno XML de critica
                              ,pr_xml_operacao187 OUT CLOB               -- Retorno XML da operação 187
                              ,pr_dsretorn        OUT VARCHAR2) IS       -- Retorno de critica (OK ou NOK)

    --Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    vr_tab_limite     CLOB;
    vr_tab_internet   CLOB;

    vr_dstransa VARCHAR2(100) := '';
    vr_vllanmto NUMBER(20,5);
    vr_tpdaguia VARCHAR2(100) := '';    
  BEGIN

    vr_vllanmto := pr_vllanmto;
    vr_tpdaguia := '<tpdaguia>' || TO_CHAR(pr_tpoperac) || '</tpdaguia>';

    INET0001.pc_verifica_operacao_prog(pr_cdcooper => pr_cdcooper 
                                      ,pr_cdagenci => pr_cdagenci 
                                      ,pr_nrdcaixa => pr_nrdcaixa 
                                      ,pr_nrdconta => pr_nrdconta 
                                      ,pr_idseqttl => pr_idseqttl 
                                      ,pr_dtmvtolt => pr_dtmvtolt 
                                      ,pr_idagenda => pr_idagenda 
                                      ,pr_dtmvtopg => pr_dtmvtopg 
                                      ,pr_vllanmto => vr_vllanmto 
                                      ,pr_cddbanco => pr_cddbanco 
                                      ,pr_cdageban => pr_cdageban 
                                      ,pr_nrctatrf => pr_nrctatrf 
                                      ,pr_cdtiptra => pr_cdtiptra 
                                      ,pr_cdoperad => pr_cdoperad 
                                      ,pr_tpoperac => 10 
                                      ,pr_flgvalid => pr_flgvalid 
                                      ,pr_dsorigem => pr_dsorigem 
                                      ,pr_nrcpfope => pr_nrcpfope 
                                      ,pr_flgctrag => pr_flgctrag 
                                      ,pr_nmdatela => pr_nmdatela 
                                      ,pr_dstransa =>     vr_dstransa
                                      ,pr_tab_limite =>   vr_tab_limite  
                                      ,pr_tab_internet => vr_tab_internet
                                      ,pr_cdcritic =>     vr_cdcritic
                                      ,pr_dscritic =>     vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		--remover <?xml version="1.0" encoding="ISO-8859-1"?>
		IF INSTR(vr_tab_limite, '<?xml') > 0 THEN 
			vr_tab_limite := SUBSTR(vr_tab_limite,(INSTR(vr_tab_limite, '>') + 1));
	  END IF;
    
    IF INSTR(vr_tab_limite, '</limite>') > 0 THEN
      vr_tab_limite := REPLACE(vr_tab_limite,'</limite></raiz>',vr_tpdaguia||'</limite></raiz>');
    END IF;
    
    pr_xml_operacao187 := vr_tab_limite;
    pr_dsretorn := 'OK';
		
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';        
                                
    WHEN OTHERS THEN
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a consulta. Tente novamente ou contacte seu PA</dsmsgerr>' || sqlerrm;
      pr_dsretorn := 'NOK'; 
  END pc_InternetBank187;
  
  PROCEDURE pc_busca_agend_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE                --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE                --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE                --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                   ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                   ,pr_cdcritic OUT INTEGER                             --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                                   ,pr_tab_agend_darf_das OUT PAGA0003.typ_tab_agend_darf_das) IS   --> Tabela com os dados da DARF/DAS

   BEGIN                               
   /* .............................................................................

     Programa: pc_busca_agend_darf_das
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de agendamento DARF/DAS.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/                        
    
    DECLARE
  
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_saida EXCEPTION;
            
      -- Declaração da tabela que conterá os dados de DARF/DAS
      vr_tab_agend_darf_das PAGA0003.typ_tab_agend_darf_das;
      vr_ind_agend_darf_das PLS_INTEGER := 0;

      -- Seleciona registro de DARF/DAS    
      CURSOR cr_darfdas(pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE) IS 
        SELECT darf.idlancto
              ,darf.cdcooper
              ,darf.nrdconta
              ,darf.tppagamento
              ,darf.tpcaptura
              ,darf.dsidentif_pagto
              ,darf.dsnome_fone
              ,darf.dscod_barras
              ,darf.dslinha_digitavel
              ,darf.dtapuracao
              ,darf.nrcpfcgc
              ,darf.cdtributo
              ,darf.nrrefere
              ,darf.vlprincipal
              ,darf.vlmulta
              ,darf.vljuros
              ,darf.vlreceita_bruta
              ,darf.vlpercentual
              ,darf.dtvencto
              ,darf.tpleitura_docto
              ,ROWID
          FROM tbpagto_agend_darf_das darf
         WHERE darf.idlancto = pr_idlancto OR pr_idlancto = 0;

      rw_darfdas cr_darfdas%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      -- Para cada registro de DARF/DAS
      FOR rw_darfdas IN cr_darfdas(pr_idlancto => pr_idlancto) LOOP      

        -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
        vr_ind_agend_darf_das := vr_tab_agend_darf_das.COUNT() + 1;

        vr_tab_agend_darf_das(vr_ind_agend_darf_das).idlancto          := rw_darfdas.idlancto;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).cdcooper          := rw_darfdas.cdcooper;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).nrdconta          := rw_darfdas.nrdconta;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).tppagamento       := rw_darfdas.tppagamento;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).tpcaptura         := rw_darfdas.tpcaptura;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dsidentif_pagto   := rw_darfdas.dsidentif_pagto;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dsnome_fone       := rw_darfdas.dsnome_fone;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dscod_barras      := rw_darfdas.dscod_barras;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dslinha_digitavel := rw_darfdas.dslinha_digitavel;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dtapuracao        := rw_darfdas.dtapuracao;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).nrcpfcgc          := rw_darfdas.nrcpfcgc;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).cdtributo         := rw_darfdas.cdtributo;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).nrrefere          := rw_darfdas.nrrefere;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).vlprincipal       := rw_darfdas.vlprincipal;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).vlmulta           := rw_darfdas.vlmulta;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).vljuros           := rw_darfdas.vljuros;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).vlreceita_bruta   := rw_darfdas.vlreceita_bruta;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).vlpercentual      := rw_darfdas.vlpercentual;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).dtvencto          := rw_darfdas.dtvencto;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).tpleitura_docto   := rw_darfdas.tpleitura_docto;
        vr_tab_agend_darf_das(vr_ind_agend_darf_das).idrowid           := rw_darfdas.ROWID;
      
      END LOOP; -- FOR rw_darfdas

      -- Alimenta parâmetro com a PL/Table gerada
      pr_tab_agend_darf_das := vr_tab_agend_darf_das;
            
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
        pr_dscritic := 'Erro nao tratado na PAGA0003.pc_busca_agend_darf_das: ' || SQLERRM;
    END;
  END pc_busca_agend_darf_das;

  
  
  PROCEDURE pc_busca_agend_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE                --> Código da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                --> Código do Operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                        ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE                --> Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                        ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                        ,pr_clobxmlc OUT CLOB                                --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2) IS                        --> Descrição da crítica

    BEGIN
   /* .............................................................................

     Programa: pc_busca_agend_darf_das_car
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de agendamento DARF/DAS

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
      vr_tab_agend_darf_das PAGA0003.typ_tab_agend_darf_das;
      vr_ind_agend_darf_das PLS_INTEGER := 0;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
      -- Procedure para buscar informações da aplicação
      PAGA0003.pc_busca_agend_darf_das(pr_cdcooper => pr_cdcooper                 --> Código da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad                       --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela                       --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem                       --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                      ,pr_nrdconta => pr_nrdconta                       --> Número da Conta
                                      ,pr_idseqttl => pr_idseqttl                       --> Titular da Conta     
                                      ,pr_idlancto => pr_idlancto                       --> Codigo da Transacao                             
                                      ,pr_cdcritic => vr_cdcritic                       --> Código da crítica
                                      ,pr_dscritic => vr_dscritic                       --> Descrição da crítica
                                      ,pr_tab_agend_darf_das => vr_tab_agend_darf_das); --> Tabela com os dados de agendamento DARF/DAS
                                          
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
      
      IF vr_tab_agend_darf_das.count() > 0 THEN
        -- Percorre todas as DARF/DAS
        FOR vr_contador IN vr_tab_agend_darf_das.FIRST..vr_tab_agend_darf_das.LAST LOOP
          -- Montar XML com registros de DARF/DAS
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<darf>'
                                                         || '<idlancto>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).idlancto)           || '</idlancto>'   
                                                         || '<cdcooper>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).cdcooper)           || '</cdcooper>'
                                                         || '<nrdconta>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).nrdconta)           || '</nrdconta>'
                                                         || '<tppagamento>'       || TO_CHAR(vr_tab_agend_darf_das(vr_contador).tppagamento)        || '</tppagamento>'
                                                         || '<tpcaptura>'         || TO_CHAR(vr_tab_agend_darf_das(vr_contador).tpcaptura)          || '</tpcaptura>'
                                                         || '<dsidentif_pagto>'   || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dsidentif_pagto)    || '</dsidentif_pagto>'
                                                         || '<dsnome_fone>'       || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dsnome_fone)        || '</dsnome_fone>'
                                                         || '<dscod_barras>'      || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dscod_barras)       || '</dscod_barras>'
                                                         || '<dslinha_digitavel>' || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dslinha_digitavel)  || '</dslinha_digitavel>'
                                                         || '<dtapuracao>'        || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dtapuracao)         || '</dtapuracao>'
                                                         || '<nrcpfcgc>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).nrcpfcgc)           || '</nrcpfcgc>'
                                                         || '<cdtributo>'         || TO_CHAR(vr_tab_agend_darf_das(vr_contador).cdtributo)          || '</cdtributo>'
                                                         || '<nrrefere>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).nrrefere)           || '</nrrefere>'
                                                         || '<vlprincipal>'       || TO_CHAR(vr_tab_agend_darf_das(vr_contador).vlprincipal)        || '</vlprincipal>'
                                                         || '<vlmulta>'           || TO_CHAR(vr_tab_agend_darf_das(vr_contador).vlmulta)            || '</vlmulta>'
                                                         || '<vljuros>'           || TO_CHAR(vr_tab_agend_darf_das(vr_contador).vljuros)            || '</vljuros>'
                                                         || '<vlreceita_bruta>'   || TO_CHAR(vr_tab_agend_darf_das(vr_contador).vlreceita_bruta)    || '</vlreceita_bruta>'
                                                         || '<vlpercentual>'      || TO_CHAR(vr_tab_agend_darf_das(vr_contador).vlpercentual)       || '</vlpercentual>'
                                                         || '<dtvencto>'          || TO_CHAR(vr_tab_agend_darf_das(vr_contador).dtvencto)           || '</dtvencto>'
                                                         || '<tpleitura_docto>'   || TO_CHAR(vr_tab_agend_darf_das(vr_contador).tpleitura_docto)    || '</tpleitura_docto>'
                                                         || '<idrowid>'           || TO_CHAR(vr_tab_agend_darf_das(vr_contador).idrowid)            || '</idrowid>'        
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
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes PAGA0003.pc_busca_agend_darf_das_car: ' || SQLERRM;

    END;
  END pc_busca_agend_darf_das_car;
  
  FUNCTION fn_data_format_ccc (pr_nrdedata IN NUMBER) RETURN DATE IS
    vr_data DATE;
  BEGIN
    --> Data de referencia inicial 01/1967 = 001
    vr_data := add_months(to_date('01/1967','MM/RRRR'),pr_nrdedata-1);
    
    RETURN vr_data;
  EXCEPTION  
    WHEN OTHERS THEN
      RETURN NULL;    
  END fn_data_format_ccc;
  
  
  PROCEDURE pc_extrai_cdbarras_fgts_dae (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdbarras IN VARCHAR               --> Codigo de barras
                                          
                                        ---- OUT ----
                                        ,pr_cdempcon OUT NUMBER               --> Retorna numero da empresa conveniada
                                        ,pr_nrinsemp OUT VARCHAR2             --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                        ,pr_nrdocmto OUT NUMBER               --> Numero do documento
                                        ,pr_nrrecolh OUT NUMBER               --> Numero identificado de recolhimento
                                        ,pr_dtcompet OUT DATE                 --> Data da competencia
                                        ,pr_dtvencto OUT DATE                 --> Data de vencimento/validade
                                        ,pr_vldocmto OUT NUMBER               --> Valor do documento
                                        ,pr_nrsqgrde OUT VARCHAR2             --> Sequencial da GRDE 
        
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Critica
    /* ..........................................................................

      Programa : pc_extrai_cdbarras_fgts_dae
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Dezembro/2017                        Ultima atualizacao: 26/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Rotina para extrair dados de fgts do codigo de barras

      Alteracoes: 

    .................................................................................*/
    
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <---------------    
     vr_exc_erro      EXCEPTION;
     vr_dscritic      VARCHAR2(2000);
     
     
     
     vr_nrdigito      INTEGER;
     
     vr_cdempcon      VARCHAR2(4);
     vr_dsdtcomp      VARCHAR2(44);
     vr_tpidempr      INTEGER;
     vr_nrinsemp      VARCHAR2(20);
     vr_dtcompet      DATE;
     vr_dtvencto      DATE;
     vr_inanocal      NUMBER;
     vr_nrrecolh      NUMBER;
     vr_vldocmto      NUMBER;
     vr_nrdocmto      NUMBER;
     vr_nrsqgrde      VARCHAR2(44);
		 vr_stsnrcal      BOOLEAN;
     
     
    BEGIN
    
      --> Identificação da empresa/convênio 
      vr_cdempcon := SUBSTR(pr_cdbarras, 16,4);      
      --> Tipo de Identificação do Empregador 
      vr_tpidempr := SUBSTR(pr_cdbarras, 32, 1);
      --> Inscrição da empresa – CNPJ/CEI/CPF 
      vr_nrinsemp := SUBSTR(pr_cdbarras,33,12); 
    
      --> CNPJ/CEI/ CPF
      IF vr_cdempcon IN ('0178','0240') THEN 
        IF vr_tpidempr IN (1)THEN
          vr_nrdigito:= GENE0005.fn_retorna_digito_cnpj(pr_nrcalcul => vr_nrinsemp); 
          vr_nrinsemp:= vr_nrinsemp || GENE0002.fn_mask(vr_nrdigito,'99');
        ELSIF vr_tpidempr IN (2) THEN
          --> valor ja esta atribuido na variavel vr_nrinsemp, apenas para detalhar regra
          NULL;
        ELSE
          vr_dscritic := 'Cod.Barras invalido.';
          RAISE vr_exc_erro;        
        END IF;
      
      ELSIF vr_cdempcon IN ('0179','0180','0181') THEN 
      
        --> CNPJ
        IF vr_tpidempr IN (0,4,6,8) THEN
        
          vr_nrdigito:= GENE0005.fn_retorna_digito_cnpj(pr_nrcalcul => vr_nrinsemp); 
          vr_nrinsemp:= vr_nrinsemp || GENE0002.fn_mask(vr_nrdigito,'99');
        
        --> CEI
        ELSIF vr_tpidempr IN (3,5,7) THEN
          --> valor ja esta atribuido na variavel vr_nrinsemp, apenas para detalhar regra
          NULL;
				--> CEI ou CPF
        ELSIF vr_tpidempr = 9 THEN
          --> Verificar se é CPF
          gene0005.pc_valida_cpf(pr_nrcalcul => to_number(trim(vr_nrinsemp))
					                      ,pr_stsnrcal => vr_stsnrcal);
          -- Se for cpf
          IF vr_stsnrcal THEN
						-- Retiramos a primeira posição
						vr_nrinsemp := substr(vr_nrinsemp, 2, 11);
					END IF;
        
        ELSE
          vr_dscritic := 'Cod.Barras invalido.';
          RAISE vr_exc_erro;
        END IF;
        
      END IF;

      
      --> IDENTIFICADOR
      IF vr_cdempcon IN ( '0239') THEN
        vr_nrrecolh := SUBSTR(pr_cdbarras, 28, 17);
      ELSIF vr_cdempcon IN ('0451') THEN
        vr_nrrecolh := SUBSTR(pr_cdbarras, 30, 15);
      ELSIF vr_cdempcon IN ( '0178','0240') THEN
        --> SEQUENCIAL DA GRDE 
        vr_nrsqgrde := SUBSTR(pr_cdbarras, 26, 3);
      
      ELSE
        --> COMPETÊNCIA
        --Data de competência (CCC)
        vr_dsdtcomp := SUBSTR(pr_cdbarras, 26, 3);
        vr_dtcompet := fn_data_format_ccc(pr_nrdedata => vr_dsdtcomp);
        
      END IF;
      

      -->  DATA DE VALIDADE
      BEGIN
        --> Extrair data de vencimento, conforme o convenio
        IF vr_cdempcon IN ( '0178','0179','0180','0181','0240') THEN
          vr_dtvencto := to_date(SUBSTR(pr_cdbarras,20,6),'RRMMDD');      
          
        ELSIF vr_cdempcon IN ('0239','0451') THEN
          vr_dtvencto := to_date(SUBSTR(pr_cdbarras,20,8),'RRRRMMDD');
          
        --> DAE  
        ELSIF vr_cdempcon IN ('0432') THEN
          
          --Retornar ano
          vr_inanocal := CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,2))
                                                         ,pr_darfndas => TRUE);
          --Retornar data dias
          vr_dtvencto := CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,22,3)) --Numero de Dias
                                                      ,pr_inanocal => vr_inanocal);                       --Indicador do Ano
          
        ELSE 
          --> demais tipos de convenio podem vir sem data de vencimeto.
          BEGIN
            vr_dtvencto := to_date(SUBSTR(pr_cdbarras,20,8),'RRRRMMDD');        
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;     
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel extrair data de vencimento: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --> Valor
      BEGIN
        --> para DAE      
        IF vr_cdempcon IN ('0432') THEN
          vr_vldocmto := SUBSTR(pr_cdbarras,5,11);
        --> FGTS  
        ELSE
          vr_vldocmto := SUBSTR(pr_cdbarras,5,11);      
        END IF;  
        
        --> Calcular decimais
        vr_vldocmto := vr_vldocmto/100;
        
      EXCEPTION
        WHEN OTHERS THEN  
          vr_dscritic := 'Não foi possivel extrair valor: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --> Numero Documento
      BEGIN
        --> para DAE      
        IF vr_cdempcon IN ('0432') THEN
          vr_nrdocmto := SUBSTR(pr_cdbarras,25,17);            
        END IF;  
        
      EXCEPTION
        WHEN OTHERS THEN  
          vr_dscritic := 'Não foi possivel extrair numero do documento: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      
      
      --> RETORNAR CAMPOS DAE
      IF vr_cdempcon IN ('0432') THEN
         --> Cod. Convênio
         pr_cdempcon := vr_cdempcon;
         
         --> Data da Validade
         pr_dtvencto := vr_dtvencto;
         
         --> Número do documento 
         pr_nrdocmto := vr_nrdocmto;
         
         --> Valor
         pr_vldocmto := vr_vldocmto;
         
      ELSE
        
        --> CNPJ/CEI/ CPF 
        pr_nrinsemp := vr_nrinsemp;
        
        --> Cod. Convênio 
        pr_cdempcon := vr_cdempcon;
        
        --> Data da Validade 
        pr_dtvencto := vr_dtvencto;
        
        --> Competência 
        pr_dtcompet := vr_dtcompet;
        
        --> Identificador  
        pr_nrrecolh := vr_nrrecolh;
        
        --> Valor
        pr_vldocmto := vr_vldocmto;
        
        --> Sequencial da GRDE 
        pr_nrsqgrde := vr_nrsqgrde;
        
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
      
        pr_dscritic := 'Erro geral na rotina pc_extrai_cdbarras_fgts_dae: '||SQLERRM;
        
    END pc_extrai_cdbarras_fgts_dae;
  
  --> Rotina para extrair detalhes do codigo de barras - FGTS/DAE
  PROCEDURE pc_det_cdbarras_fgts_dae(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_tpdaguia IN INTEGER               --> Tipo de operacao 3-FGTS, 4-DAE
                                    ,pr_cdbarras IN VARCHAR               --> codigo de barras
                                    ,pr_flmobile IN INTEGER DEFAULT 0     --> Identificador canal IB/Mobile
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   OUT CLOB) IS             --> Retorno dos dados em xml
    /* ..........................................................................

      Programa : pc_det_cdbarras_fgts_dae
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Dezembro/2017                        Ultima atualizacao: 26/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Rotina para extrair detalhes do codigo de barras - FGTS/DAS

      Alteracoes: 

    .................................................................................*/
    
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <---------------    
     vr_exc_saida   EXCEPTION;
     vr_dsempcon    NUMBER;
     vr_dssegmto    VARCHAR2(1);
     vr_qtexpr      NUMBER;
     vr_xml_temp    VARCHAR2(32726) := '';
     vr_dscritic    VARCHAR2(4000);
     
     vr_nrinsemp    VARCHAR2(20);
     vr_nrdocmto    NUMBER;
     vr_nrrecolh    NUMBER;
     vr_dtcompet    DATE  ;
     vr_dtvencto    DATE  ;
     vr_vldocmto    NUMBER;
     vr_nrsqgrde    VARCHAR2(44);
     
     vr_dstxtxml    VARCHAR2(2000);
     
     
    BEGIN

      pr_cdcritic := 0;
      
      -- Validações do Código de Barras
      IF SUBSTR(pr_cdbarras,0,1) <> '8' THEN
        IF pr_flmobile = 1 THEN
          vr_dscritic := 'Boleto deve ser pago na opção ''Pagamentos - Boletos e Convênios''.';
        ELSE
          vr_dscritic := 'Boleto deve ser pago na opção ''Pagamentos'' do menu de serviços.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      vr_dsempcon := to_char(TO_NUMBER(SUBSTR(pr_cdbarras, 16,4)));
      vr_dssegmto := to_char(TO_NUMBER(SUBSTR(pr_cdbarras, 2,1)));

      IF vr_dsempcon = '328' AND vr_dssegmto = '5' THEN
        IF pr_flmobile = 1 THEN
          vr_dscritic := 'DAS deve ser pago na opção ''Pagamentos - DAS''.';
        ELSE
          vr_dscritic := 'DAS deve ser pago na opção ''Pagamentos - Tributos - DAS'' do menu de serviços.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      SELECT REGEXP_INSTR (vr_dsempcon, '64|153|154|385') INTO vr_qtexpr
      FROM dual;

      IF vr_qtexpr > 0 AND vr_dssegmto = 5 THEN
        IF pr_flmobile = 1 THEN
        vr_dscritic := 'DARF deve ser pago na opção ''Pagamentos - DARF''.';
        ELSE
          vr_dscritic := 'DARF deve ser pago na opção ''Pagamentos - Tributos - DARF'' do menu de serviços.';
        END IF;
        RAISE vr_exc_saida;
      END IF;
      
      -- GPS -- Convênio 270 e Segmento 5
      IF vr_dsempcon = 270 AND vr_dssegmto = 5 THEN
        IF pr_flmobile = 1 THEN -- Canal Mobile
          vr_dscritic := 'Pagamento de GPS deve ser pago na opção ''Pagamentos - GPS.';
        ELSE -- Conta Online
          vr_dscritic := 'GPS deve ser paga na opção ''Pagamentos - Tributos - GPS'' do menu de serviços.';
        END IF;
      END IF; 
      
      IF NOT(vr_dsempcon IN(0178,0179,0180,0181,0239,0240,0451,0432) AND vr_dssegmto = '5') THEN
         IF pr_flmobile = 1 THEN
            vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Boletos e Convênios''';
         ELSE
            vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Boletos Diversos'' do menu de serviços.'; --INC0015051
         END IF;
         RAISE vr_exc_saida;
      END IF;  
            
      --> Se for pagamento de FGTS
      IF pr_tpdaguia = 3 THEN
      
        --> testar se esta tentando pargar um DAE
        IF vr_dsempcon = 432 AND vr_dssegmto = '5' THEN
          IF pr_flmobile = 1 THEN
            vr_dscritic := 'Convênio deve ser pago na opção ''Transações - DAE''';
          ELSE
            vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Tributos - DAE'' do menu de serviços.';
          END IF;
          RAISE vr_exc_saida;
        END IF;
      
      --> Se for pagamento de DAE
      ELSIF pr_tpdaguia = 4 THEN
      
        
        --> Testar se esta tentando pagar um FGTS
        IF vr_dsempcon IN (0179,0180,0181,0178,0240,0239,0451) AND 
               vr_dssegmto = '5' THEN
          IF pr_flmobile = 1 THEN
            vr_dscritic := 'Convênio deve ser pago na opção ''Transações - FGTS''';
          ELSE
            vr_dscritic := 'Convênio deve ser pago na opção ''Pagamentos - Tributos - FGTS'' do menu de serviços.';
          END IF;
          RAISE vr_exc_saida;
        END IF;
      
      END IF;
      
      
      --> Extrair Dados
      pc_extrai_cdbarras_fgts_dae (pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                                  ,pr_cdbarras => pr_cdbarras   --> Codigo de barras
                                          
                                  ---- OUT ----
                                  ,pr_cdempcon => vr_dsempcon   --> Retorna numero da empresa conveniada
                                  ,pr_nrinsemp => vr_nrinsemp   --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                  ,pr_nrdocmto => vr_nrdocmto   --> Numero do documento
                                  ,pr_nrrecolh => vr_nrrecolh   --> Numero identificado de recolhimento
                                  ,pr_dtcompet => vr_dtcompet   --> Data da competencia
                                  ,pr_dtvencto => vr_dtvencto   --> Data de vencimento/validade
                                  ,pr_vldocmto => vr_vldocmto   --> Valor do documento
                                  ,pr_nrsqgrde => vr_nrsqgrde   --> Sequencial da GRDE 
                                  
                                  ,pr_dscritic => vr_dscritic); --> Critica
      
      IF trim(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
	  IF vr_dsempcon = '0239' THEN
         vr_nrrecolh := lpad(vr_nrrecolh,17,'0');
      ELSE
         vr_nrrecolh := lpad(vr_nrrecolh,15,'0');
      END IF;

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Root><CDBARRAS>');   
      
      --> Adicionar campos em comun                          
      vr_dstxtxml := '<tpdaguia>'        || pr_tpdaguia                       ||'</tpdaguia>'       ||
                     '<nridentificacao>' || vr_nrinsemp                       ||'</nridentificacao>'||
                     '<cdtributo>'       || vr_dsempcon                       ||'</cdtributo>'      ||
                     '<dtvalidade>'      || to_char(vr_dtvencto,'DD/MM/RRRR') ||'</dtvalidade>'     ||
                     '<competencia>'     || to_char(vr_dtcompet,'DD/MM/RRRR') ||'</competencia>'    ||
                     '<nrseqgrde>'       || vr_nrsqgrde                       ||'</nrseqgrde>'      ||
                     '<identificador>'   || vr_nrrecolh                       ||'</identificador>'  ||      
                     '<nrdocumento>'     || lpad(vr_nrdocmto,17,'0')          ||'</nrdocumento>'    ||      
                     '<vlrtotal>'        || to_char(vr_vldocmto,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vlrtotal>';
                     
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dstxtxml);
      
                               
      --> Fechar XML e Buffer 
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                          ,pr_texto_completo => vr_xml_temp
                          ,pr_texto_novo     => '</CDBARRAS></Root>'
                          ,pr_fecha_xml      => TRUE);                                  
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_det_cdbarras_fgts_dae: '||SQLERRM;
    END pc_det_cdbarras_fgts_dae;
    
  --> Rotina para processar pagamento de tributos
  PROCEDURE pc_processa_tributos (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Cooperativa
                                 ,pr_nrdconta IN  crapass.nrdconta%TYPE  -- Número da conta
                                 ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                                 ,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- CPF do operador PJ
                                 ,pr_idorigem IN  INTEGER                -- Canal de origem da operação
                                 ,pr_flmobile IN  INTEGER                -- Indicador de requisição via canal Mobile
                                 ,pr_idefetiv IN  INTEGER                -- Indicador de efetivação da operação de pagamento
                                 ,pr_tpdaguia IN  INTEGER                -- Tipo da guia ((3-FGTS/4-DAE)
                                 ,pr_tpcaptur IN  INTEGER                -- Tipo de captura da guia (1 – Código Barras / 2 – Manual: FGTS e DAE só arrecadarão pelo Código de Barras) 
                                 ,pr_lindigi1 IN  NUMBER                 -- Primeiro campo da linha digitável da guia
                                 ,pr_lindigi2 IN  NUMBER                 -- Segundo campo da linha digitável da guia
                                 ,pr_lindigi3 IN  NUMBER                 -- Terceiro campo da linha digitável da guia
                                 ,pr_lindigi4 IN  NUMBER                 -- Quarto campo da linha digitável da guia
                                 ,pr_cdbarras IN  VARCHAR2               -- Código de barras da guia
                                 ,pr_nrcpfcgc IN  VARCHAR2               -- CNPJ/CEI/CPF da guia
                                 ,pr_cdtribut IN  VARCHAR2               -- Código de tributação da guia
                                 ,pr_dtvencto IN  DATE                   -- Data da validade da guia
                                 ,pr_dtapurac IN  DATE                   -- Data de Competência da Guia
                                 ,pr_vlrtotal IN  NUMBER                 -- Valor total do pagamento da guia
                                 ,pr_nrrefere IN  VARCHAR2               -- Número de referência da guia("Identificador" quando FGTS, "Nr. Documento" quando DAE)
                                 ,pr_dsidepag IN  VARCHAR2               -- Descrição da identificação do pagamento
                                 ,pr_dtmvtopg IN  DATE                   -- Data do pagamento
                                 ,pr_idagenda IN  INTEGER                -- Indicador se é agendamento (1 – Nesta Data / 2 – Agendamento) 
                                 ,pr_vlapagar IN  NUMBER                 -- Valor total dos pagamentos
                                 ,pr_versaldo IN  INTEGER                -- Indicador de validação do saldo em relação ao valor total
                                 ,pr_tpleitor IN  INTEGER                -- Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual)
                                 ,pr_iptransa IN VARCHAR2 DEFAULT NULL   -- IP da transação
                                 ,pr_iddispos IN VARCHAR2 DEFAULT NULL   -- Identificador do dispositivo mobile                                  
                                 ,pr_retxml  OUT CLOB                    -- Retorno XML da operação
                                 ,pr_dscritic OUT VARCHAR2) IS           -- Retorno de critica
    /* ..........................................................................

      Programa : pc_processa_tributos
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Dezembro/2017                        Ultima atualizacao: 26/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Rotina para processar pagamento de tributos

      Alteracoes: 

    .................................................................................*/
    
    ----------------> CURSORES <---------------    
	  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
	
    CURSOR cr_craphec(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdprogra IN craphec.cdprogra%TYPE) IS
     SELECT MAX(hec.hriniexe) hriniexe
       FROM craphec hec
      WHERE upper(hec.cdprogra) = upper(pr_cdprogra)
        AND hec.cdcooper = pr_cdcooper;
     rw_craphec cr_craphec%ROWTYPE;
  
    --Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <---------------    
  --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_assin_conjunta NUMBER(1);
		vr_des_reto VARCHAR2(03);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
		--Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
		
		--tables
		vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_tab_erro       GENE0001.typ_tab_erro;          --> Tabela com erros
    vr_tab_saldos     EXTR0001.typ_tab_saldos;        --> Tabela de retorno da rotina

    vr_dstransa  VARCHAR2(200) := ''; -- log
		vr_dsmsgope  VARCHAR2(200) := ''; -- msg da operacao
    vr_dstrans1  VARCHAR2(200) := '';		
		vr_vlrvalid  NUMBER;              -- Valor a ser validado pela rotina
		vr_idastcjt  crapass.idastcjt%TYPE;
    vr_nrcpfcgc  VARCHAR2(200) := '';
    vr_nmprimtl  VARCHAR2(500);
    vr_flcartma  INTEGER(1) := 0;
		vr_cdseqfat  VARCHAR2(500);
		vr_vldocmto  NUMBER;
		vr_nrdigfat  NUMBER;
    vr_lindigi1  NUMBER;
    vr_lindigi2  NUMBER;
    vr_lindigi3  NUMBER;
    vr_lindigi4  NUMBER;
    vr_dtmvtopg  DATE;
    vr_lindigit  VARCHAR2(100);
    vr_cdbarras  VARCHAR2(100);
		vr_dsprotoc  VARCHAR2(500);
		vr_dslindig  VARCHAR2(200);
		vr_nrdrowid  ROWID;
    vr_hriniexe  craphec.hriniexe%TYPE;
    vr_dsprogra  VARCHAR2(100);
		
		-- Gerar log
    PROCEDURE pc_proc_geracao_log(pr_flgtrans IN INTEGER) IS
    BEGIN
      
      IF pr_nrcpfope > 0  THEN
        vr_dstransa := vr_dstransa ||' - operador';
      END IF;
        
      -- Gerar log ao cooperado (b1wgen0014 - gera_log) 
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => pr_flgtrans
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
			
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
			 												  pr_nmdcampo => 'Tipo da Guia',
			 												  pr_dsdadant => ' ',
			 												  pr_dsdadatu => CASE pr_tpdaguia 
                                                 WHEN 3 THEN 'FGTS'
                                                 WHEN 4 THEN 'DAE'
																							 ELSE '' END);
										
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Origem',
																pr_dsdadant => ' ',
																pr_dsdadatu => CASE pr_flmobile
																							 WHEN 1 THEN 'MOBILE'
																							 ELSE 'INTERNETBANK' 
																								END);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Guia com Codigo de Barras',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => CASE pr_tpcaptur
                                               WHEN 1 THEN 'SIM'
                                               ELSE 'NAO' END);

      
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Codigo de Barras',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => pr_cdbarras);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Linha Digitavel',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => vr_dslindig);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => (CASE 
                                                 WHEN pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
                                                   'Valor Pago'
                                                 ELSE 'Valor a Pagar'
                                               END)
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => TRIM(TO_CHAR(pr_vlrtotal,'9G999G990D00')));

				
      -- se não é agendamento                
      IF pr_idagenda = 1 AND pr_nrcpfope = 0 THEN
        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Data do Pagamento' 
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(nvl(vr_dtmvtopg,pr_dtmvtopg),'DD/MM/RRRR'));

        IF pr_flgtrans = 1 THEN   
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Protocolo' 
                                   ,pr_dsdadant => ' '
                                   ,pr_dsdadatu => vr_dsprotoc);
        END IF;
                           
      ELSE
        GENE0001.pc_gera_log_item
                      (pr_nrdrowid => vr_nrdrowid
                      ,pr_nmdcampo => 'Data do Agendamento' 
                      ,pr_dsdadant => ' '
                      ,pr_dsdadatu => to_char(nvl(vr_dtmvtopg,pr_dtmvtopg),'DD/MM/RRRR')); 
      END IF;
        
      IF pr_nrcpfope > 0  THEN
        GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_nrdrowid
                        ,pr_nmdcampo => 'Operador' 
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
      END IF;

      --Se conta exigir Assinatura Multipla
      IF vr_idastcjt = 1 THEN
         gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                   pr_nmdcampo => 'Nome do Representante/Procurador', 
                                   pr_dsdadant => '', 
                                   pr_dsdadatu => vr_nmprimtl);
                                          
         gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                   pr_nmdcampo => 'CPF do Representante/Procurador', 
                                   pr_dsdadant => '', 
                                   pr_dsdadatu => TO_CHAR(vr_nrcpfcgc));
      END IF;
                          
    END pc_proc_geracao_log;		
		
  BEGIN
		-- obtem data
	  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;  
    
    IF pr_idefetiv = 0 THEN -- Validação
			IF pr_idagenda = 1 THEN 
				vr_dstransa := vr_dstransa || 'Valida pagamento ';
			ELSE 
				vr_dstransa := vr_dstransa || 'Valida agendamento de pagamento ';
			END IF;		
		ELSE -- Efetivação
			IF pr_idagenda = 1 THEN 
				vr_dstransa := vr_dstransa || 'Pagamento ';
			ELSE 
				vr_dstransa := vr_dstransa || 'Agendamento para pagamento ';
			END IF;
		END IF;
		
		IF pr_tpdaguia = 3 THEN -- FGTS
			vr_dstransa := vr_dstransa || 'de FGTS.';
		ELSIF pr_tpdaguia = 4 THEN -- DAE
			vr_dstransa := vr_dstransa || 'de DAE.';
		END IF;
		
		INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		--Verifica se conta for conta PJ e se exige assinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmprimtl => vr_nmprimtl
                                       ,pr_flcartma => vr_flcartma
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro; 
    END IF;					
		
		-- se for para verificar o saldo
    IF pr_versaldo = 1 AND pr_nrcpfope = 0 AND vr_idastcjt = 0 THEN

      -- busca associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      -- obter do saldo da conta
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => rw_crapdat,
                                  pr_cdagenci   => 90,
                                  pr_nrdcaixa   => 900,
                                  pr_cdoperad   => '996',
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_vllimcre   => rw_crapass.vllimcre,
                                  pr_tipo_busca => 'A',  -- Usar data anterior  
                                  pr_dtrefere   => rw_crapdat.dtmvtocd,
                                  pr_des_reto   => vr_des_reto,
                                  pr_tab_sald   => vr_tab_saldos,
                                  pr_tab_erro   => vr_tab_erro);

       -- Verifica se deu erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel verificar Saldo.'; 
        END IF;
        
        RAISE vr_exc_erro;
      END IF; 
      
      -- se não encontrar nenhum registro
      IF vr_tab_saldos.exists(vr_tab_saldos.first) = FALSE THEN
        vr_dscritic := 'Nao foi possivel consultar o saldo para a operacao.'; 
        RAISE vr_exc_erro;  
      END IF;
      
      -- Verificar se possui saldo disponivel para realizar o pagamento
      IF nvl(pr_vlapagar,0) > (  vr_tab_saldos(vr_tab_saldos.first).vlsddisp 
                               + vr_tab_saldos(vr_tab_saldos.first).vllimcre) THEN 
        vr_dscritic := 'Nao ha saldo suficiente para a operacao.';
        RAISE vr_exc_erro;
      END IF;  
      
    END IF; -- Fim IF verificar saldo
    
						
    -- Antes de efeivar, envia o valor somado de todos os pagamentos do lote (vlapagar)
    vr_vlrvalid := CASE WHEN pr_idefetiv = 0 THEN nvl(pr_vlapagar,0) ELSE nvl(pr_vlrtotal,0) END;

		-- inicializar variaveis
    vr_lindigi1 := pr_lindigi1;
    vr_lindigi2 := pr_lindigi2;
    vr_lindigi3 := pr_lindigi3;
    vr_lindigi4 := pr_lindigi4;
    vr_cdbarras := pr_cdbarras;
    vr_dtmvtopg := pr_dtmvtopg;						
    ------
		
		-- alimenta linha digitável (para log) caso tenha sido informada
		IF TRIM(pr_lindigi1) IS NOT NULL THEN
		   vr_dslindig := SUBSTR(to_char(vr_lindigi1,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi1,'fm000000000000'),12,1) ||' '||

		                  SUBSTR(to_char(vr_lindigi2,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi2,'fm000000000000'),12,1) ||' '||

                      SUBSTR(to_char(vr_lindigi3,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi3,'fm000000000000'),12,1) ||' '||

		                  SUBSTR(to_char(vr_lindigi4,'fm000000000000'),1,11) ||'-'||
		                  SUBSTR(to_char(vr_lindigi4,'fm000000000000'),12,1);
		END IF;
		
		vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
																							 pr_dtmvtolt => pr_dtmvtopg, 
																							 pr_tipo     => 'A');

    -- Se for um agendamento vamos verificar se ja esgotou horario DEBSIC
    IF pr_idagenda = 2 THEN
    
      IF pr_tpdaguia IN (3,4) THEN -- FGTS/DAS
        vr_dsprogra := 'DEBBAN';
      END IF;
    
      -- busca ultimo horario da debsic
      OPEN cr_craphec(pr_cdcooper => pr_cdcooper
                     ,pr_cdprogra => vr_dsprogra);
      FETCH cr_craphec INTO rw_craphec;

      IF cr_craphec%NOTFOUND THEN
        CLOSE cr_craphec;
        vr_hriniexe := 0;
      ELSE
        CLOSE cr_craphec;
        vr_hriniexe := rw_craphec.hriniexe;
      END IF;
      
      -- Se rotina de efetivacao ja rodou, nao aceitamos mais agendamento para agendamentos em que o dia
      -- que antecede o final de semana ou feriado nacional
      IF to_char(SYSDATE,'sssss') >= vr_hriniexe  AND 
         rw_crapdat.dtmvtolt = vr_dtmvtopg THEN
         
        IF pr_tpdaguia = 3 THEN -- FGTS
          vr_dscritic := 'Agendamento de FGTS permitido apenas para o proximo dia util.'; 
        ELSIF pr_tpdaguia = 4 THEN -- DAE
          vr_dscritic := 'Agendamento de DAE permitido apenas para o proximo dia util.'; 
        ELSE
          vr_dscritic := 'Agendamento deste tributo permitido apenas para o proximo dia util.'; 
        END IF;
        
        RAISE vr_exc_erro;     
      END IF;
    END IF;


		-- Procedure para validar limites para transacoes
    INET0001.pc_verifica_operacao (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                                  ,pr_cdagenci     => 90                  --> Agencia do Associado
                                  ,pr_nrdcaixa     => 900                 --> Numero caixa
                                  ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                                  ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                                  ,pr_dtmvtolt     => rw_crapdat.dtmvtocd --> Data Movimento
                                  ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                                  ,pr_dtmvtopg     => vr_dtmvtopg         --> Data Pagamento
                                  ,pr_vllanmto     => vr_vlrvalid         --> Valor a ser Validado
                                  ,pr_cddbanco     => 0                   --> Codigo banco
                                  ,pr_cdageban     => 0                   --> Codigo Agencia
                                  ,pr_nrctatrf     => 0                   --> Numero Conta Transferencia
                                  ,pr_cdtiptra     => NULL           
                                  ,pr_cdoperad     => 996                 --> Codigo Operador
                                  ,pr_tpoperac     => (CASE pr_tpdaguia 
                                                         WHEN 3 THEN 12 -- FGTS
                                                         WHEN 4 THEN 13 -- DAE
                                                         ELSE 12
                                                       END   )
                                  ,pr_flgvalid     => TRUE                --> Indicador validacoes
                                  ,pr_dsorigem     => 'INTERNET'          --> Descricao Origem
                                  ,pr_nrcpfope     => pr_nrcpfope         --> (CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN 0 ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do responsavel legal quando conta exigir assinatura multipla
                                  ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos 
                                  ,pr_nmdatela     => 'INTERNETBANK'      --> Nome da tela/programa que esta chamando a rotina
                                  ,pr_dstransa     => vr_dstrans1         --> Descricao da transacao
                                  ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                  ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                  ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                                  ,pr_dscritic     => vr_dscritic         --> Descricao do erro
                                  ,pr_assin_conjunta => vr_assin_conjunta);   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		PAGA0003.pc_verifica_tributos( pr_cdcooper => pr_cdcooper,
																	 pr_nrdconta => pr_nrdconta,
																	 pr_idseqttl => pr_idseqttl,
																	 pr_idorigem => pr_idorigem,
                                   pr_tpdaguia => pr_tpdaguia,
																	 pr_tpcaptur => pr_tpcaptur,
																	 pr_lindigi1 => vr_lindigi1,
																	 pr_lindigi2 => vr_lindigi2,
																	 pr_lindigi3 => vr_lindigi3,
																	 pr_lindigi4 => vr_lindigi4,
																	 pr_cdbarras => vr_cdbarras,
																	 pr_vlrtotal => pr_vlrtotal,
																	 pr_dtapurac => pr_dtapurac,
																	 pr_nrcpfcgc => pr_nrcpfcgc,
																	 pr_cdtribut => pr_cdtribut,
																	 pr_nrrefere => pr_nrrefere,
																	 pr_dtvencto => pr_dtvencto,
																	 pr_vlrprinc => 0,
																	 pr_vlrmulta => 0,
																	 pr_vlrjuros => 0,
																	 pr_vlrecbru => 0,
																	 pr_vlpercen => 0,
																	 pr_idagenda => pr_idagenda,
																	 pr_dtagenda => vr_dtmvtopg,
																	 pr_indvalid => 1,
																	 pr_flmobile => pr_flmobile, 
																	 pr_cdseqfat => vr_cdseqfat,
																	 pr_vldocmto => vr_vldocmto,
																	 pr_nrdigfat => vr_nrdigfat,
																	 pr_cdcritic => vr_cdcritic,
																	 pr_dscritic => vr_dscritic);																	 
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro; 
    END IF;
		
		-- linha digitavel
		vr_dslindig := SUBSTR(to_char(vr_lindigi1,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi1,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi2,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi2,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi3,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi3,'fm000000000000'),12,1) ||' '||

									 SUBSTR(to_char(vr_lindigi4,'fm000000000000'),1,11) ||'-'||
									 SUBSTR(to_char(vr_lindigi4,'fm000000000000'),12,1);
		
		-- efetivar
		IF pr_idefetiv = 1 THEN
			
		  -- Mobile seguir regra antiga, IB nova regra por limites
      --     IF pr_nrcpfope > 0 OR vr_idastcjt = 1 THEN
      IF vr_assin_conjunta = 1 THEN
        --> DARF,DAS
        IF pr_tpdaguia IN (1,2) THEN
      
          INET0002.pc_cria_trans_pend_darf_das( pr_cdcooper => pr_cdcooper,
                                                pr_nrdcaixa => 900,
                                                pr_cdoperad => 996,
                                                pr_nmdatela => 'INTERNETBANK',
                                                pr_cdagenci => 90,
                                                pr_nrdconta => pr_nrdconta,
                                                pr_idseqttl => pr_idseqttl,
                                                pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END), --> Numero do cpf do representante legal
                                                pr_cdcoptfn => 0,
                                                pr_cdagetfn => 0,
                                                pr_nrterfin => 0,
                                                pr_nrcpfope => pr_nrcpfope,
                                                pr_idorigem => pr_idorigem,
                                                pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                                pr_tpdaguia => pr_tpdaguia,
                                                pr_tpcaptur => pr_tpcaptur,
                                                pr_lindigi1 => vr_lindigi1,
                                                pr_lindigi2 => vr_lindigi2,
                                                pr_lindigi3 => vr_lindigi3,
                                                pr_lindigi4 => vr_lindigi4,
                                                pr_cdbarras => vr_cdbarras,
                                                pr_dsidepag => pr_dsidepag,
                                                pr_vlrtotal => pr_vlrtotal,
                                                pr_dsnomfon => ' ',
                                                pr_dtapurac => pr_dtapurac,
                                                pr_nrcpfcgc => pr_nrcpfcgc,
                                                pr_cdtribut => pr_cdtribut,
                                                pr_nrrefere => pr_nrrefere,
                                                pr_dtvencto => pr_dtvencto,
                                                pr_vlrprinc => 0,
                                                pr_vlrmulta => 0,
                                                pr_vlrjuros => 0,
                                                pr_vlrecbru => 0,
                                                pr_vlpercen => 0,
                                                pr_dtagenda => vr_dtmvtopg,
                                                pr_idastcjt => vr_idastcjt,
                                                pr_idagenda => pr_idagenda,
                                                pr_tpleitur => pr_tpleitor,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) <> 0 OR
            TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro; 
          END IF;
        
        --> FGTS,DAE
        ELSIF pr_tpdaguia IN (3,4) THEN 
          INET0002.pc_cria_trans_pend_tributos( pr_cdcooper => pr_cdcooper,
                                                pr_nrdcaixa => 900,
                                                pr_cdoperad => 996,
                                                pr_nmdatela => 'INTERNETBANK',
                                                pr_cdagenci => 90,
                                                pr_nrdconta => pr_nrdconta,
                                                pr_idseqttl => pr_idseqttl,
                                                pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END), --> Numero do cpf do representante legal
                                                pr_cdcoptfn => 0,
                                                pr_cdagetfn => 0,
                                                pr_nrterfin => 0,
                                                pr_nrcpfope => pr_nrcpfope,
                                                pr_idorigem => pr_idorigem,
                                                pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                                pr_tpdaguia => pr_tpdaguia,
                                                pr_tpcaptur => pr_tpcaptur,
                                                pr_lindigi1 => vr_lindigi1,
                                                pr_lindigi2 => vr_lindigi2,
                                                pr_lindigi3 => vr_lindigi3,
                                                pr_lindigi4 => vr_lindigi4,
                                                pr_cdbarras => vr_cdbarras,
                                                pr_dsidepag => pr_dsidepag,
                                                pr_vlrtotal => pr_vlrtotal,                                    
                                                pr_dtapurac => pr_dtapurac,
                                                pr_nrsqgrde => (CASE 
                                                                WHEN pr_cdtribut IN (0178,0240) THEN 
                                                                     SUBSTR(pr_cdbarras, 26,3)
                                                                   ELSE NULL
                                                                END),
                                                pr_nrcpfcgc => pr_nrcpfcgc,
                                                pr_cdtribut => pr_cdtribut,
                                                pr_identifi => pr_nrcpfcgc,
                                                pr_dtvencto => pr_dtvencto,
                                                pr_identificador => pr_nrrefere,
                                                pr_dtagenda => vr_dtmvtopg,
                                                pr_idastcjt => vr_idastcjt,
                                                pr_idagenda => pr_idagenda,
                                                pr_tpleitur => pr_tpleitor,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic); 
          IF nvl(vr_cdcritic,0) <> 0 OR
            TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro; 
          END IF;
        END IF;
				
			ELSE -- Efetiva, nao exige assinatura multipla
					
			-- Nesta data
			IF  pr_idagenda = 1 THEN 
				
				PAGA0003.pc_paga_tributos( pr_cdcooper => pr_cdcooper,
																	 pr_nrdconta => pr_nrdconta,
																	 pr_idseqttl => pr_idseqttl,
																	 pr_nrcpfope => pr_nrcpfope,
																	 pr_idorigem => pr_idorigem,
                                   pr_tpdaguia => pr_tpdaguia,
																	 pr_tpcaptur => pr_tpcaptur,
																	 pr_cdseqfat => vr_cdseqfat,
																	 pr_nrdigfat => vr_nrdigfat,
																	 pr_lindigi1 => vr_lindigi1,
																	 pr_lindigi2 => vr_lindigi2,
																	 pr_lindigi3 => vr_lindigi3,
																	 pr_lindigi4 => vr_lindigi4,
																	 pr_cdbarras => vr_cdbarras,
																	 pr_dsidepag => pr_dsidepag,
																	 pr_vlrtotal => pr_vlrtotal,
																	 pr_dsnomfon => ' ',
																	 pr_dtapurac => pr_dtapurac,
																	 pr_nrcpfcgc => pr_nrcpfcgc,
																	 pr_cdtribut => pr_cdtribut,
																	 pr_nrrefere => pr_nrrefere,
																	 pr_dtvencto => pr_dtvencto,
																	 pr_vlrprinc => 0,
																	 pr_vlrmulta => 0,
																	 pr_vlrjuros => 0,
																	 pr_vlrecbru => 0,
																	 pr_vlpercen => 0,
																	 pr_vldocmto => vr_vldocmto,
																	 pr_idagenda => pr_idagenda,
																	 pr_tpleitor => pr_tpleitor,
                                   pr_flmobile => pr_flmobile, -- Identificador de mobile
                                   pr_iptransa => pr_iptransa, -- IP da transação
                                   pr_iddispos => pr_iddispos, -- Identificador do dispositivo mobile                                																	 
																	 pr_dsprotoc => vr_dsprotoc,
																	 pr_cdcritic => vr_cdcritic,
																	 pr_dscritic => vr_dscritic);			
												 
			  IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
												
			-- se for agendamento  
      ELSIF pr_idagenda = 2 THEN
				
				pc_cria_agend_tributos( pr_cdcooper => pr_cdcooper,
																pr_nrdconta => pr_nrdconta,
																pr_idseqttl => pr_idseqttl,
																pr_cdagenci => 90,
																pr_nrdcaixa => 900,
																pr_cdoperad => 996,
																pr_nrcpfope => pr_nrcpfope,
																pr_idorigem => pr_idorigem,
																pr_tpdaguia => pr_tpdaguia,
																pr_tpcaptur => pr_tpcaptur,
																pr_cdhistor => 508,
																pr_lindigi1 => vr_lindigi1,
																pr_lindigi2 => vr_lindigi2,
																pr_lindigi3 => vr_lindigi3,
																pr_lindigi4 => vr_lindigi4,
																pr_cdbarras => vr_cdbarras,
																pr_dsidepag => pr_dsidepag,
																pr_vlrtotal => pr_vlrtotal,
																pr_dsnomfon => ' ',
																pr_dtapurac => pr_dtapurac,
																pr_nrcpfcgc => pr_nrcpfcgc,
																pr_cdtribut => pr_cdtribut,
																pr_nrrefere => pr_nrrefere,
																pr_dtvencto => pr_dtvencto,
																pr_vlrprinc => 0,
																pr_vlrmulta => 0,
																pr_vlrjuros => 0,
																pr_vlrecbru => 0,
																pr_vlpercen => 0,
																pr_dtagenda => vr_dtmvtopg,
																pr_cdtrapen => 0,
																pr_tpleitor => pr_tpleitor,
                                pr_flmobile => pr_flmobile, -- Identificador de mobile
                                pr_iptransa => pr_iptransa, -- IP da transação
                                pr_iddispos => pr_iddispos, -- Identificador do dispositivo mobile                                																	 
																pr_dsprotoc => vr_dsprotoc,
																pr_cdcritic => vr_cdcritic,
																pr_dscritic => vr_dscritic);
																
        IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
				
			END IF;
			
			END IF;

			
			-- compor mensagem de retorno da operacao
			
			-- Nesta data
			IF pr_idagenda = 1 THEN
				
				--Representante COM assinatura conjunta
				IF vr_assin_conjunta = 1 THEN					
          vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso. Aguardando aprovação do(s) preposto(s)';
          -- 18/04/2018 - TJ
					--vr_dsmsgope := 'Pagamento registrado com sucesso. Aguardando aprovação do registro pelos demais responsáveis.';
				--Representante SEM assinatura conjunta
				ELSE 
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
            -- ### TJ
						vr_dsmsgope := 'Pagamento registrado com sucesso. Aguardando aprovação do registro pelo preposto.';
					--titular
					ELSE
            vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso.';
            -- 18/04/2018 - TJ
						--vr_dsmsgope := 'Pagamento efetuado com sucesso.';
				  END IF;
										
				END IF;
				
			-- agendamento
			ELSE
				
				--Representante COM assinatura conjunta
				IF vr_assin_conjunta = 1 THEN					
          vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso. Aguardando aprovação do(s) preposto(s)';
          -- 18/04/2018 - TJ
					-- vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprovação do registro pelos demais responsáveis.';
				--Representante SEM assinatura conjunta
				ELSE					
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
            -- ### TJ
						vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprovação do registro pelo preposto.';
					--titular
					ELSE
            -- 18/04/2018 - TJ
						-- vr_dsmsgope := 'Pagamento agendado com sucesso para o dia ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
            vr_dsmsgope := 'Transação(ões) registrada(s) com sucesso.';
				  END IF;
				END IF;
				
			END IF;
			
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_retxml, TRUE);
			dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_retxml
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<raiz>
														                        <DADOS_PAGAMENTO>
                                                          <tpdaguia>'|| nvl(pr_tpdaguia,0) ||'</tpdaguia>
																										      <dsmsgope>'|| nvl(vr_dsmsgope,' ') ||'</dsmsgope>
																													<idastcjt>'|| nvl(TO_CHAR(vr_idastcjt),' ') ||'</idastcjt>
																													<dsprotoc>'|| NVL(TRIM(vr_dsprotoc),'')    ||'</dsprotoc>
																									  </DADOS_PAGAMENTO>');
			-- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_retxml
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</raiz>' 
														 ,pr_fecha_xml      => TRUE);
			
      --Gravar mensagem na VERLOG
			vr_dscritic := vr_dsmsgope;
		  pc_proc_geracao_log(pr_flgtrans => 1); --> true
						
		ELSE --validação
		
		  -- houve alteração de data por nao ser um dia útil
		  IF vr_dtmvtopg <> pr_dtmvtopg THEN
			   vr_dsmsgope := 'O agendamento será registrado para débito em ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
			END IF;
		
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_retxml, TRUE);
			dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_retxml
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<raiz>'); 
	    
			-- Insere dados
			gene0002.pc_escreve_xml(pr_xml            => pr_retxml
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<DADOS_PAGAMENTO>
																												<tpdaguia>'|| nvl(pr_tpdaguia,0)  ||'</tpdaguia>
                                                        <lindigi1>'|| vr_lindigi1           ||'</lindigi1>
																												<lindigi2>'|| vr_lindigi2           ||'</lindigi2>
																												<lindigi3>'|| vr_lindigi3           ||'</lindigi3>
																												<lindigi4>'|| vr_lindigi4           ||'</lindigi4>
																												<dslindig>'|| vr_dslindig           ||'</dslindig>
																												<cdbarras>'|| vr_cdbarras           ||'</cdbarras> 
																												<dtmvtopg>'|| to_char(vr_dtmvtopg,'DD/MM/RRRR')||'</dtmvtopg>
																												<vlrtotal>'|| TO_CHAR(pr_vlrtotal,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.') ||'</vlrtotal>
																												<cdseqfat>'|| vr_cdseqfat            ||'</cdseqfat>
																												<nrdigfat>'|| vr_nrdigfat            ||'</nrdigfat>
																												<dttransa>'|| to_char(SYSDATE,'DD/MM/RRRR') ||'</dttransa>
																												<dsmsgope>'|| nvl(vr_dsmsgope,' ')   ||'</dsmsgope>																												
																											</DADOS_PAGAMENTO>');  
                                                     
			-- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_retxml
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</raiz>' 
														 ,pr_fecha_xml      => TRUE);
      		
		END IF;		

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);          
      END IF; 
      pr_dscritic := vr_dscritic;
			
			pc_proc_geracao_log(pr_flgtrans => 0 );   --> false
                                
    WHEN OTHERS THEN
      
      vr_dscritic := 'Não foi possivel validar pagamento tributos. ' ||SQLERRM;       
      pr_dscritic := vr_dscritic;

			pc_proc_geracao_log(pr_flgtrans => 0 ); --> false
			
  END pc_processa_tributos;
  
  PROCEDURE pc_validacoes_bancoob (pr_cdcooper IN crapcop.cdcooper%type      -- Codigo Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%type      -- Agencia do Associado
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero caixa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Identificador Sequencial titulo
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data Movimento
                                  ,pr_cdbarras IN VARCHAR                    -- Codigo de barras
                                  ,pr_cdempcon IN crapcon.cdempcon%TYPE      -- Codigo Empresa Convenio
                                  ,pr_cdsegmto IN crapcon.cdsegmto%TYPE      -- Codigo Segmento Convenio
                                  ,pr_idagenda IN  INTEGER                   -- Indicador se é agendamento (1 – Nesta Data / 2 – Agendamento) 
                                  ,pr_flgpgag  IN BOOLEAN                    -- Indicador Pagto agendamento                                          
                                  ---- OUT ----                                                                    
                                  ,pr_cdcritic OUT INTEGER                   -- Retorno codigo de critica
                                  ,pr_dscritic OUT VARCHAR2) IS              -- Retorno de descrição Critica 
                                  
    /* ..........................................................................

      Programa : pc_validacoes_bancoob
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Janeiro/2018                        Ultima atualizacao: 02/01/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Rotina para validações dos convenios bancoob

      Alteracoes: 

    .................................................................................*/
    ----------------> CURSORES <---------------  
    --> Buscar dados da agencia  
    CURSOR cr_crapage( pr_cdcooper crapage.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT age.cdagefgt           
        FROM crapage age,
             crapass ass
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci  
         AND ass.cdcooper = pr_cdcooper
         and ass.nrdconta = pr_nrdconta
         ;
    rw_crapage cr_crapage%ROWTYPE;
 
    --> Buscar dados da cooperativa
    CURSOR cr_crapcop( pr_cdcooper crapage.cdcooper%TYPE) IS
      SELECT cop.nrtelsac             
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
 
    --> Arrecadacao
    CURSOR cr_tbarrecd (pr_cdcooper crapage.cdcooper%TYPE,
                        pr_cdempcon tbconv_arrecadacao.cdempcon%TYPE,
                        pr_cdsegmto tbconv_arrecadacao.cdsegmto%TYPE,
                        pr_tparrecd tbconv_arrecadacao.tparrecadacao%TYPE) IS
      SELECT arr.nrdias_tolerancia,
             arr.cdempcon,
             arr.cdsegmto,
             con.cdhistor
        FROM tbconv_arrecadacao arr,
             crapcon con
       WHERE arr.cdempcon = con.cdempcon
         AND arr.cdsegmto = con.cdsegmto
         AND con.cdcooper = pr_cdcooper 
         AND arr.cdempcon = pr_cdempcon
         AND arr.cdsegmto = pr_cdsegmto
         AND arr.dtencemp IS NULL
         AND arr.tparrecadacao = pr_tparrecd;
    rw_tbarrecd cr_tbarrecd%ROWTYPE;
    
    --> verificar se registro ja foi pago
    CURSOR cr_lft_ult_pag (pr_cdcooper      IN craplft.cdcooper%type
                          ,pr_codigo_barras IN VARCHAR2
                          ,pr_cdhistor      IN craplft.cdhistor%TYPE) IS
      SELECT /*+index (lft CRAPLFT##CRAPLFT5) */
             lft.dtvencto
        FROM craplft lft
       WHERE lft.cdcooper = pr_cdcooper
         AND UPPER(lft.cdbarras) = pr_codigo_barras -- UPPER necessário pois o index lft5 está com upper
         AND lft.cdhistor = pr_cdhistor
         AND lft.dtvencto > ADD_MONTHS(SYSDATE,-60) -- Verifica apenas os últimos 5 anos pois o sicredi também
                                                    -- valida os pagamentos feitos em até 5 anos.
      ORDER BY lft.dtvencto DESC;
      
    rw_lft_ult_pag cr_lft_ult_pag%ROWTYPE;        
    
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <---------------    
     vr_exc_erro      EXCEPTION;
     vr_dscritic      VARCHAR2(2000);
     vr_cdcritic      INTEGER;
     
     vr_dstextab      craptab.dstextab%TYPE;
     
     vr_hrinipag      NUMBER;           
     vr_hrfimpag      NUMBER;
     
     vr_dttolera      DATE;
     vr_nrdocdae      VARCHAR2(44);
     vr_dvnrodae      VARCHAR2(44);
     vr_digito        VARCHAR2(44);
     vr_poslimit      INTEGER;
     vr_flginval      BOOLEAN;     
     
     
  BEGIN
    
      --> Nao permitir para demais agencias
      IF pr_cdagenci <> 90 THEN
        vr_dscritic := 'Convênio não disponível para esse meio de arrecadação';
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar dados da agencia do cooperado
      rw_crapage := NULL;
      OPEN cr_crapage( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapage INTO rw_crapage;
      CLOSE cr_crapage;
     
      
      IF pr_cdempcon IN (0178,0179,0180,0181,0239,0240,0451) AND
         nvl(rw_crapage.cdagefgt,0) = 0 THEN
        vr_dscritic := 'Operação indisponível. Favor entrar em contato com seu PA.';
        RAISE vr_exc_erro;
      END IF;
      
			IF pr_idagenda <> 2 THEN
      --Selecionar Horarios Limites Internet
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'HRPGBANCOOB'
                                              ,pr_tpregist => pr_cdagenci);

      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic := 'Tabela (HRPGBANCOOB) nao cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Hora de inicio
        vr_hrinipag:= GENE0002.fn_busca_entrada(1,vr_dstextab,' ');
        --Hora Fim
        vr_hrfimpag:= GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
      END IF;
      
      --Se estiver dentro horario inicial e final
      IF GENE0002.fn_busca_time NOT BETWEEN vr_hrinipag AND vr_hrfimpag THEN
        --Se for TAA ou Iternet
        IF pr_cdagenci IN (90,91) THEN
          --Montar mensagem erro
          vr_cdcritic := 0;
          vr_dscritic := 'Esse convenio e aceito ate as ' || GENE0002.fn_converte_time_data(vr_hrfimpag)||
                         'hs. O pagamento pode ser agendado para o proximo dia util.';
        ELSE
          --Montar mensagem erro
          vr_cdcritic := 676;
          vr_dscritic := NULL;
        END IF;
        
        RAISE vr_exc_erro;
      END IF;
			END IF;
      
      BEGIN
        vr_flginval := FALSE;
        IF pr_cdempcon IN (0179,0180,0181) THEN
          --convenio 181 digito deve ser 9
          IF pr_cdempcon IN (0181) AND 
             SUBSTR(pr_cdbarras,3,1) <> 9 THEN      
            vr_flginval := TRUE;
          --demais deve ser 8  
          ELSIF pr_cdempcon NOT IN (0181) AND 
                SUBSTR(pr_cdbarras,3,1) <> 8 THEN  
            vr_flginval := TRUE;
          ELSIF SUBSTR(pr_cdbarras,32,1) IN (1,2) THEN  
            vr_flginval := TRUE;
          END IF;
          
        ELSIF pr_cdempcon IN (0178,0240) THEN
        
          IF SUBSTR(pr_cdbarras,3,1) <> 8 THEN  
            vr_flginval := TRUE;
          ELSIF SUBSTR(pr_cdbarras,29,2) NOT IN (22,25) THEN  
            vr_flginval := TRUE;
          ELSIF SUBSTR(pr_cdbarras,31,1) NOT IN (0,3,6) THEN  
            vr_flginval := TRUE;
          ELSIF SUBSTR(pr_cdbarras,32,1) NOT IN (1,2) THEN  
            vr_flginval := TRUE;
          END IF;
          
       ELSIF pr_cdempcon IN (0239,0451) THEN
        
        IF SUBSTR(pr_cdbarras,3,1) <> 8 THEN  
          vr_flginval := TRUE;
        END IF;
       END IF; 
       
       IF vr_flginval THEN 
         vr_dscritic := 'Codigo de barras invalido.';
         RAISE vr_exc_erro;
       END IF;
        
      EXCEPTION 
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao validar cod.Barras: '||SQLERRM;
          RAISE vr_exc_erro;
        
      END;
      
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Buscar dados arrecadacao
      OPEN cr_tbarrecd (pr_cdcooper => pr_cdcooper,
                        pr_cdempcon => pr_cdempcon,
                        pr_cdsegmto => pr_cdsegmto,
                        pr_tparrecd => 2);
      FETCH cr_tbarrecd INTO rw_tbarrecd;
      IF cr_tbarrecd%NOTFOUND THEN
        CLOSE cr_tbarrecd;
         vr_cdcritic := 0;
         vr_dscritic := 'Convenio de não aceito pela cooperativa.';
         RAISE vr_exc_erro;
        
      ELSE
        CLOSE cr_tbarrecd;
      END IF;
      
      --> Nao repete validacao ja realizada se for Agendamento
      IF pr_idagenda <> 2 THEN
        --> Validação referente aos dias de tolerancia 
        cxon0014.pc_verifica_dtlimite_tributo( pr_cdcooper      => pr_cdcooper
                                              ,pr_cdagenci      => pr_cdagenci
                                              ,pr_cdempcon      => pr_cdempcon
                                              ,pr_cdsegmto      => pr_cdsegmto
                                              ,pr_codigo_barras => pr_cdbarras
                                              ,pr_dtmvtopg      => rw_crapdat.dtmvtocd
                                              ,pr_flnrtole      => TRUE                                    
                                              ,pr_dttolera      => vr_dttolera
                                              ,pr_cdcritic      => vr_cdcritic
                                              ,pr_dscritic      => vr_dscritic);
        
        IF vr_cdcritic IS NOT NULL OR 
           vr_dscritic IS NOT NULL THEN
          
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      
      -- Se nao for Agendamento nem Pagto de Agendamento
      IF pr_idagenda <> 2 AND NOT pr_flgpgag THEN
        -- DAE
        IF rw_tbarrecd.cdempcon = '0432' AND 
           rw_tbarrecd.cdsegmto = 5 THEN
  					
          vr_nrdocdae := SUBSTR(pr_cdbarras, 25, 16);
          vr_dvnrodae := TO_NUMBER(SUBSTR(pr_cdbarras, 41, 1));
  				
          CXON0014.pc_verifica_digito (pr_nrcalcul => vr_nrdocdae  --Numero a ser calculado
                                      ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                      ,pr_nrdigito => vr_digito);  --Digito verificador
          IF vr_digito <> vr_dvnrodae THEN						
            vr_cdcritic := 8;
            vr_dscritic := NULL;
            
            --Levantar Excecao
            RAISE vr_exc_erro;
            
          END IF;
  				
          FOR idx IN 42..44 LOOP
  					
            vr_poslimit := idx;
  					
            vr_dvnrodae := TO_NUMBER(SUBSTR(pr_cdbarras, vr_poslimit, 1));
            vr_poslimit := (vr_poslimit - 5);
            vr_nrdocdae := (SUBSTR(pr_cdbarras, 1, 3) || 
                            SUBSTR(pr_cdbarras, 5, vr_poslimit));
  					
            CXON0014.pc_verifica_digito (pr_nrcalcul => vr_nrdocdae  --Numero a ser calculado
                                        ,pr_poslimit => vr_poslimit  --Utilizado para validação de dígito adicional de DAS
                                        ,pr_nrdigito => vr_digito);  --Digito verificador
            IF vr_digito <> vr_dvnrodae THEN													
              vr_cdcritic := 8;
              vr_dscritic := NULL;
              
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
  					
          END LOOP;
  				
        END IF; -- Fim IF DAE
      END IF;
      
      --Selecionar lancamentos de fatura
      OPEN cr_lft_ult_pag (pr_cdcooper      => pr_cdcooper
                          ,pr_codigo_barras => pr_cdbarras
                          ,pr_cdhistor      => rw_tbarrecd.cdhistor);
      --Posicionar no proximo registro
      FETCH cr_lft_ult_pag INTO rw_lft_ult_pag;

      -- Se encontrar fatura já paga
      IF cr_lft_ult_pag%FOUND THEN

        CLOSE cr_lft_ult_pag;

        vr_cdcritic := 0;
        vr_dscritic := 'Fatura ja arrecadada dia ' ||
                       to_char(rw_lft_ult_pag.dtvencto,'dd/mm/RRRR') || '.';

        -- se o pagamento for no caixa on-line gerar a crítica
        IF pr_cdagenci NOT IN (90,91) THEN
          vr_dscritic := vr_dscritic ||  ' Para consultar o canal de recebimento, verificar na tela PESQTI.';
        ELSE -- senao, é internet/mobile (cdagenci = 90) ou TA (cdagenci = 91)
          IF pr_flgpgag = FALSE THEN
            --> Buscar dados da agencia 
            rw_crapcop := NULL;
            OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
            FETCH cr_crapcop INTO rw_crapcop;
            CLOSE cr_crapcop;  
          
            vr_dscritic := vr_dscritic || ' Duvidas entrar em contato com o SAC pelo telefone ' ||
                           rw_crapcop.nrtelsac || '.';
          END IF;
        END IF;

        RAISE vr_exc_erro;

      ELSE
        CLOSE cr_lft_ult_pag;
      END IF;
      
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
        
    WHEN OTHERS THEN
      
      pr_dscritic := 'Erro geral na rotina pc_validacoes_bancoob: '||SQLERRM;
        
  END pc_validacoes_bancoob;
    
  --> Procedimento para buscar os debitos agendados de pagamento bancoob
  PROCEDURE pc_obtem_agendeb_bancoob (  pr_cdcooper  IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                       ,pr_nmrescop  IN crapcop.nmrescop%TYPE             --> Nome resumido da cooperativa
                                       ,pr_dtmvtopg  IN DATE                              --> Data do pagamento
                                       ,pr_inproces  IN crapdat.inproces%TYPE             --> Indicador do processo
                                       ,pr_tab_agend_bancoob IN OUT typ_tab_agend_bancoob --> Retorna os agendamentos
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS                      --> descrição da critica
  /*-------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_agendeb_bancoob 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018                       Ultima atualizacao: 10/01/2018
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que chamado
   Objetivo  : Procedimento para buscar os debitos agendados de pagamento bancoob
  
    Alterações: 
  --------------------------------------------------------------------------------------------------------------- */

    -- Cursor de agendamentos 
    CURSOR cr_craplau ( pr_cdcooper IN craplau.cdcooper%TYPE,
                        pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
      SELECT craplau.cdcooper
             ,craplau.cdagenci
             ,craplau.dtmvtopg
             ,craplau.cdtiptra
             ,craplau.vllanaut
             ,craplau.dttransa
             ,craplau.nrdocmto
             ,craplau.dslindig
             ,craplau.dsorigem
             ,craplau.idseqttl
             ,craplau.nrdconta
             ,craplau.dscedent
             ,craplau.hrtransa
             ,craplau.cdhistor
             ,craphis.cdhistor||'-'||craphis.dshistor dshistor
             ,craplau.nrseqagp
             ,craplau.dtmvtolt
             ,craplau.nrseqdig
             ,craplau.ROWID
             ,craplau.progress_recid
      FROM   craplau,
             craphis
      WHERE craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND craplau.cdcooper = pr_cdcooper
        AND craplau.dtmvtopg = pr_dtmvtopg
        AND craplau.insitlau = 1
        AND craplau.tpdvalor = 2;
      rw_craplau cr_craplau%ROWTYPE;

    -- Transferencias entre cooperativas
    CURSOR cr_craptco (pr_nrdconta IN  craptco.nrctaant%TYPE) IS
      SELECT craptco.cdcopant
      FROM   craptco
      WHERE  craptco.cdcopant = pr_cdcooper
      AND    craptco.nrctaant = pr_nrdconta
      AND    craptco.tpctatrf = 1;
    rw_craptco cr_craptco%ROWTYPE;

    -- Informações dos associados
    CURSOR cr_crapass (pr_nrdconta IN  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.cdagenci
      FROM   crapass
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    vr_exc_erro  EXCEPTION;
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(2000);
    
    vr_fltiptra  BOOLEAN;
    vr_dstiptra  VARCHAR2(100);
    vr_fltipdoc  VARCHAR2(10);
    vr_dstransa  craplau.dscedent%TYPE;
    vr_chave     VARCHAR2(100);

    vr_dtmovini  craplau.dtmvtopg%TYPE;

  BEGIN
    -- Limpando a tabela temporária
    pr_tab_agend_bancoob.delete;

    -- Abrindo e navegando no cursor de lançamentos
    FOR rw_craplau IN cr_craplau ( pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtopg => pr_dtmvtopg) LOOP

      vr_fltipdoc := '';

      -- se é pagamento
      IF  rw_craplau.cdtiptra = 2  THEN /** Pagamento **/
        -- Tipo de transação
        vr_fltiptra := FALSE;
        -- Descrição do tipo de transação
        vr_dstiptra := 'Pagamento';

        -- se o tamanho da linha digitável é de 55 posições é convênio
        IF rw_craplau.nrseqagp <> 0 THEN
          vr_fltipdoc := 'GPS'; /** GPS - Guia Previdencia Social **/
        ELSIF  LENGTH(rw_craplau.dslindig) = 55 THEN
          vr_fltipdoc := 'CONVENIOS'; /** Convenio **/
        ELSE
          vr_fltipdoc := 'TITULO'; /** Titulo   **/
        END IF;
        
        -- Cedente
        vr_dstransa := rw_craplau.dscedent;
      -- se é pagamento FGTS
      ELSIF  rw_craplau.cdtiptra = 12  THEN 
        -- Tipo de transação
        vr_fltiptra := FALSE;
        -- Descrição do tipo de transação
        vr_dstiptra := 'Pagamento FGTS';        
        vr_fltipdoc := 'CONVENIOS';
        
        -- Cedente
        vr_dstransa := rw_craplau.dscedent;
        
      -- se é pagamento DAE
      ELSIF  rw_craplau.cdtiptra = 13  THEN 
        -- Tipo de transação
        vr_fltiptra := FALSE;
        -- Descrição do tipo de transação
        vr_dstiptra := 'Pagamento DAE';
        vr_fltipdoc := 'CONVENIOS';
        
        -- Cedente
        vr_dstransa := rw_craplau.dscedent;
      END IF;

      IF rw_craplau.cdhistor = 1019 THEN
        vr_dstiptra := 'Debito Aut.';
        vr_dstransa := rw_craplau.dscedent;
      END IF;

      -- Verifica se a conta existe
      OPEN cr_crapass( pr_nrdconta => rw_craplau.nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      -- Se a conta não existe aborta a execução e gera crítida
      IF  cr_crapass%NOTFOUND THEN
        -- Fecha o cursor para as próximas iterações
        CLOSE cr_crapass;
        -- Gerando a crítica
        vr_cdcritic := 9;
        vr_dscritic := 'Erro em  paga0003.pc_obtem_agendeb_bancoob. Conta '||rw_craplau.nrdconta||' não existe.';
        -- gerando exceção
        RAISE vr_exc_erro;
      ELSE
        -- fecha o cursor para as próximas iterações
        CLOSE cr_crapass;
      END IF;

      -- Montando a chave para ordenação
      SELECT lpad(pr_cdcooper,5,'0')||
             lpad(rw_craplau.nrdconta,10,'0')||
             to_char(rw_craplau.dttransa,'dd/mm/yyyy')||
             lpad(rw_craplau.nrdocmto,25,'0')||
             rw_craplau.cdhistor ||
             rw_craplau.rowid  INTO vr_chave
      FROM dual;

      -- Carregando os agendamentos
      pr_tab_agend_bancoob(vr_chave).nrchave  := vr_chave;
      pr_tab_agend_bancoob(vr_chave).cdcooper := pr_cdcooper;
      pr_tab_agend_bancoob(vr_chave).dscooper := pr_nmrescop;
      pr_tab_agend_bancoob(vr_chave).nrdconta := rw_craplau.nrdconta;
      pr_tab_agend_bancoob(vr_chave).nmprimtl := rw_crapass.nmprimtl;
      pr_tab_agend_bancoob(vr_chave).cdagenci := rw_crapass.cdagenci;
      pr_tab_agend_bancoob(vr_chave).cdtiptra := rw_craplau.cdtiptra;
      pr_tab_agend_bancoob(vr_chave).fltiptra := vr_fltiptra;
      pr_tab_agend_bancoob(vr_chave).dstiptra := vr_dstiptra;
      pr_tab_agend_bancoob(vr_chave).fltipdoc := vr_fltipdoc;
      pr_tab_agend_bancoob(vr_chave).dstransa := vr_dstransa;
      pr_tab_agend_bancoob(vr_chave).vllanaut := rw_craplau.vllanaut;
      pr_tab_agend_bancoob(vr_chave).dttransa := rw_craplau.dttransa;
      pr_tab_agend_bancoob(vr_chave).hrtransa := rw_craplau.hrtransa;
      pr_tab_agend_bancoob(vr_chave).nrdocmto := rw_craplau.nrdocmto;
      pr_tab_agend_bancoob(vr_chave).dslindig := rw_craplau.dslindig;
      pr_tab_agend_bancoob(vr_chave).dscritic := '';
      pr_tab_agend_bancoob(vr_chave).nrdrecid := rw_craplau.rowid;
      pr_tab_agend_bancoob(vr_chave).fldebito := 0;
      pr_tab_agend_bancoob(vr_chave).dsorigem := rw_craplau.dsorigem;
      pr_tab_agend_bancoob(vr_chave).idseqttl := rw_craplau.idseqttl;
      pr_tab_agend_bancoob(vr_chave).dtagenda := pr_dtmvtopg;
      pr_tab_agend_bancoob(vr_chave).dsdebito := 'NAO EFETUADOS';
      pr_tab_agend_bancoob(vr_chave).prorecid := rw_craplau.progress_recid;
      pr_tab_agend_bancoob(vr_chave).dtmvtolt := rw_craplau.dtmvtolt;
      pr_tab_agend_bancoob(vr_chave).nrseqdig := rw_craplau.nrseqdig;
      pr_tab_agend_bancoob(vr_chave).dshistor := rw_craplau.dshistor;

      IF rw_craplau.cdhistor = 1019 THEN
        pr_tab_agend_bancoob(vr_chave).dsorigem := 'DEBITO AUTOMATICO';
      ELSE
        pr_tab_agend_bancoob(vr_chave).dsorigem := rw_craplau.dsorigem;
      END IF;

    END LOOP; --FOR rw_craplau IN cr_craplau

  EXCEPTION
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado em paga0003.pc_obtem_agendeb_bancoob --> '||SQLERRM;
  END pc_obtem_agendeb_bancoob;

  
  --> Procedimento para processar os debitos agendados de pagamento bancoob
  PROCEDURE pc_processa_agend_bancoob ( pr_cdcooper  IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS                      --> descrição da critica
  /*-------------------------------------------------------------------------------------------------------------
    Programa : pc_processa_agend_bancoob 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018                       Ultima atualizacao: 09/05/2018
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que chamado
   Objetivo  : Procedimento para processar os debitos agendados de pagamento bancoob
  
    Alterações: 09/05/2018 - Incluido a chamada da rotina gen_debitador_unico.pc_qt_hora_prg_debitador
                             para atualizar a quantidade de execuções programadas no debitador
                             Projeto debitador único - Josiane Stiehler (AMcom)
  --------------------------------------------------------------------------------------------------------------- */

    ----------------> CURSORES <---------------  
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    ----------------> TEMPTABLE  <---------------
   
    ----------------> VARIAVEIS <--------------- 
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(2000);
    
    -- Código do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'DEBBAN';
    
    -- Variáveis diversas
    vr_cdagenci     crapage.cdagenci%TYPE;
    vr_idorigem     INTEGER;
    vr_dtmvtopg     DATE;
    vr_tab_agendamentos paga0003.typ_tab_agend_bancoob;
    vr_tab_agen_relat   paga0003.typ_tab_agend_bancoob;
    vr_dstransa     VARCHAR2(4000);
    vr_flultexe     INTEGER;
    vr_qtdexec      INTEGER;
    vr_ind          VARCHAR2(100);
    vr_ind_aux      VARCHAR2(100);
    
    --> variaveis relatorio
    vr_cdcooper     NUMBER;
    vr_path_arquivo VARCHAR2(1000);
    vr_dspathcop    VARCHAR2(4000);
    vr_nmrelato     VARCHAR2(40);
    vr_cdrelato     NUMBER;
    vr_des_xml         CLOB;  
    vr_texto_completo  VARCHAR2(32600); 
      
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;


  BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'DEBBAN'
                                ,pr_action => null);

  
    -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := NULL;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := NULL;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      vr_dtmvtopg:= rw_crapdat.dtmvtolt;
      
      -- atualiza a quantidade de execuções que estão agendadas no debitador unico
      gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper   --Cooperativa
                                                  ,pr_cdprocesso => 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                  ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      
      --> Verificar/controlar a execução da DEBNET e DEBSIC 
      SICR0001.pc_controle_exec_deb (  pr_cdcooper  => pr_cdcooper        --> Código da coopertiva
                                      ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento                                
                                      ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa                                  
                                      ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF; 
      
      --> Commit para garantir a gravação do parametro de 
      --> controle de execução do programa DEBBAN CTRL_DEBBAN_EXEC
      COMMIT;
      
      -- Busca os lançamentos de agendamento de convenios Bancoob
      pc_obtem_agendeb_bancoob ( pr_cdcooper => pr_cdcooper                 --> Informações da cooperativa
                                ,pr_nmrescop => rw_crapcop.nmrescop         --> Nome resumido da cooperativa
                                ,pr_dtmvtopg => vr_dtmvtopg                 --> Data da efetivação do débito
                                ,pr_inproces => rw_crapdat.inproces         --> Indicador do processo
                                ,pr_tab_agend_bancoob => vr_tab_agendamentos--> Retorna os agendamentos
                                ,pr_cdcritic => vr_cdcritic                 --> Codigo da critica de erro
                                ,pr_dscritic => vr_dscritic);               --> Descrição do erro
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_erro;
      END IF;
      
      
      IF vr_tab_agendamentos.count > 0 THEN
        -- Posiciona no primeiro registro
        vr_ind := vr_tab_agendamentos.FIRST;
        
        WHILE vr_ind IS NOT NULL LOOP
        
          -- verifica se origem é TAA ou INTERNET
          CASE vr_tab_agendamentos(vr_ind).dsorigem
            WHEN 'INTERNET' THEN 
              vr_cdagenci := 90; 
              vr_idorigem := 3; /* INTERNET */
            WHEN 'TAA'      THEN 
              vr_cdagenci := 91; 
              vr_idorigem := 4; /* TAA */
            WHEN 'CAIXA'    THEN 
              vr_cdagenci :=  vr_tab_agendamentos(vr_ind).cdagenci; 
              vr_idorigem := 2; /* CAIXA */
            ELSE
              vr_cdagenci := NULL;
              vr_idorigem := 1;
          END CASE;
              
          -- Executa o débito dos agendamentos
          PAGA0001.pc_debita_agendto_pagto( pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                           ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                           ,pr_nrdcaixa => 900           --Numero Caixa
                                           ,pr_cdoperad => '996'         --Operador
                                           ,pr_nmdatela => vr_cdprogra   --Nome programa
                                           ,pr_idorigem => vr_idorigem   --origem (TAA ou Internet)
                                           ,pr_dtmvtolt => vr_dtmvtopg   --Data pagamento
                                           ,pr_inproces => rw_crapdat.inproces   --Indicador Processo
                                           ,pr_flsgproc => 1   --Flag segundo processamento
                                           ,pr_craplau_progress_recid  => vr_tab_agendamentos(vr_ind).prorecid --Recid lancamento automatico
                                           ,pr_cdcritic => pr_cdcritic   --Codigo da Critica
                                         ,pr_dscritic => vr_dscritic); -- Descrição do erro ou motivo do não débito

          -- Verifica se deu erro no processamento do débito
          IF vr_dscritic IS NOT NULL THEN
            -- Registra o erro ocorrido no registro
            vr_tab_agendamentos(vr_ind).dscritic := upper(substr(vr_dscritic,1,100));
          ELSE
            -- informa que o débito foi efetuado com sucesso
            vr_tab_agendamentos(vr_ind).fldebito := 1;
            vr_tab_agendamentos(vr_ind).dsdebito := 'EFETUADOS';
          END IF;
          
          
          -- Montando a chave auxiliar baseada nos registros atualizados
          -- e utilizando novo índice para geração do relatório
          SELECT vr_tab_agendamentos(vr_ind).dsorigem||
                 vr_tab_agendamentos(vr_ind).fldebito||
                 nvl(vr_tab_agendamentos(vr_ind).dstiptra,'#########')||
                 nvl(vr_tab_agendamentos(vr_ind).fltipdoc,'########')||
                 lpad(vr_tab_agendamentos(vr_ind).cdcooper,5,'0')||
                 lpad(vr_tab_agendamentos(vr_ind).cdagenci,3,'0')||
                 lpad(vr_tab_agendamentos(vr_ind).nrdconta,10,'0')||
                 vr_tab_agendamentos(vr_ind).nrdrecid INTO vr_ind_aux
          FROM dual;

          -- Recarregando a tabela temporária por causa da mudança do índice          
          vr_tab_agen_relat(vr_ind_aux)          :=  vr_tab_agendamentos(vr_ind);
          vr_tab_agen_relat(vr_ind_aux).nrchave  := vr_ind_aux;
          
          -- commit a cada registro
          COMMIT;
        
          -- Buscar o proximo registro da tabela
          vr_ind := vr_tab_agendamentos.NEXT(vr_ind);
        END LOOP;
        
        
        -->>> GERACAO DO RELATORIO <<<--
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -------------------------------------------
        -- Iniciando a geração do XML
        -------------------------------------------
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl736>');
        -- Posiciona no primeiro registro
        vr_ind := vr_tab_agen_relat.FIRST;

        -- Inicia o laço do loop
        LOOP
          -- Sai quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;

          -- se é o primeiro registro, guarda o código da cooperativa para geração do arquivo
          IF vr_ind = vr_tab_agen_relat.FIRST THEN
            vr_cdcooper := vr_tab_agen_relat(vr_ind).cdcooper;
          END IF;

          pc_escreve_xml( '<chave nrchave="'||vr_tab_agen_relat(vr_ind).nrchave||'">'||
                                '<cdcooper>'||vr_tab_agen_relat(vr_ind).cdcooper||'</cdcooper>'||
                                '<dscooper>'||vr_tab_agen_relat(vr_ind).dscooper||'</dscooper>'||
                                '<nrdconta>'||GENE0002.fn_mask_conta(vr_tab_agen_relat(vr_ind).nrdconta)||'</nrdconta>'||
                                '<nmprimtl>'||vr_tab_agen_relat(vr_ind).nmprimtl||'</nmprimtl>'||
                                '<cdagenci>'||vr_tab_agen_relat(vr_ind).cdagenci||'</cdagenci>'||
                                '<cdtiptra>'||vr_tab_agen_relat(vr_ind).cdtiptra||'</cdtiptra>'||
                                '<dstiptra>'||vr_tab_agen_relat(vr_ind).dstiptra||'</dstiptra>'||
                                '<fltipdoc>'||vr_tab_agen_relat(vr_ind).fltipdoc||'</fltipdoc>'||
                                '<dstransa>'||vr_tab_agen_relat(vr_ind).dstransa||'</dstransa>'||
                                '<vllanaut>'||vr_tab_agen_relat(vr_ind).vllanaut||'</vllanaut>'||
                                '<dttransa>'||vr_tab_agen_relat(vr_ind).dttransa||'</dttransa>'||
                                '<hrtransa>'||vr_tab_agen_relat(vr_ind).hrtransa||'</hrtransa>'||
                                '<nrdocmto>'||vr_tab_agen_relat(vr_ind).nrdocmto||'</nrdocmto>'||
                                '<dslindig>'||vr_tab_agen_relat(vr_ind).dslindig||'</dslindig>'||
                                '<dscritic><![CDATA['||gene0007.fn_caract_acento(vr_tab_agen_relat(vr_ind).dscritic)||']]></dscritic>'||
                                '<nrdrecid>'||vr_tab_agen_relat(vr_ind).nrdrecid||'</nrdrecid>'||
                                '<fldebito>'||vr_tab_agen_relat(vr_ind).fldebito||'</fldebito>'||
                                '<dsorigem>'||vr_tab_agen_relat(vr_ind).dsorigem||'</dsorigem>'||
                                '<idseqttl>'||vr_tab_agen_relat(vr_ind).idseqttl||'</idseqttl>'||
                                '<dtagenda>'||to_char(vr_tab_agen_relat(vr_ind).dtagenda,'dd/mm/yyyy')||'</dtagenda>'||
                                '<dsdebito>'||vr_tab_agen_relat(vr_ind).dsdebito||'</dsdebito>'||
                                '<dtmvtolt>'||to_char(vr_tab_agen_relat(vr_ind).dtmvtolt,'dd/mm/yyyy') ||'</dtmvtolt>'||
                                '<nrseqdig>'||vr_tab_agen_relat(vr_ind).nrseqdig ||'</nrseqdig>'||
                                '<dshistor>'||vr_tab_agen_relat(vr_ind).dshistor ||'</dshistor>'||
                          '</chave>');

          -- Buscar o próximo registro da tabela
          vr_ind := vr_tab_agen_relat.NEXT(vr_ind);

        END LOOP;
        -- Finalizando o arquivo xml
        pc_escreve_xml('</crrl736>',TRUE);
        
        -- Busca do diretório base da cooperativa e a subpasta de relatórios
        vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'rl'); --> Gerado no diretorio /rl


        -- Durante o processo gera o 642
        vr_nmrelato := 'crrl736_' || to_char( gene0002.fn_busca_time ) || '.lst';
        vr_cdrelato := 736;

        -- gerar copia em rlnsv
        vr_dspathcop := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rlnsv'); --> Gerado no diretorio /rlnsv

        -- Gerando o relatório nas pastas /rl e /rlnsv
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/crrl736'
                                   ,pr_dsjasper  => 'crrl736.jasper'
                                   ,pr_dsparams  => ''
                                   ,pr_dsarqsaid => vr_path_arquivo ||'/'|| vr_nmrelato
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 234
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => vr_cdrelato
                                   ,pr_flg_impri => 'S'
                                   ,pr_nmformul  => '234col'
                                   ,pr_nrcopias  => 1
                                   ,pr_dspathcop => vr_dspathcop
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_des_erro  => vr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      END IF;
      
      COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado em paga0003.pc_processa_agend_bancoob --> '||SQLERRM;
  END pc_processa_agend_bancoob;

    -- Início -- PRJ406
    -- Rotina responsável por gerar os arquivos de arrecadação dos convênios BANCOOB
    PROCEDURE pc_gera_arrecadacao_bancoob(pr_cdcooper IN  crapcop.cdcooper%TYPE            -- Código da Cooperativa
                                         ,pr_cdconven IN  tbconv_arrecadacao.cdempres%TYPE -- Código do Convênio
                                         ,pr_dscritic OUT VARCHAR2                         -- Descrição do erro retornado
                                         ) IS
       /* .............................................................................
       
       Programa: pc_gera_arrecadacao_bancoob
       Autor   : Supero
       Data    : Janeiro/2018.                    Ultima atualizacao: 

       Objetivo  : Procedure para geração dos arquivos de arrecadação Bancoob

       Alteracoes:  
                                 
      ..............................................................................*/
      -- Busca cooperativas
      CURSOR cr_cooper(pr_cdcooper crapcop.cdcooper%TYPE
                    ) IS
        SELECT cdcooper
              ,nmrescop
              ,cdagectl
              ,cdagebcb
          FROM crapcop
         WHERE cdcooper <> 3
           AND cdcooper  = DECODE(pr_cdcooper, 0, cdcooper, pr_cdcooper);
      --
      rw_cooper cr_cooper%ROWTYPE;
      
      -- Busca dos dados da cooperativa central
      CURSOR cr_crapcop_central (pr_cdcooper INTEGER) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.cdagebcb 
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;     
      rw_crapcop_central cr_crapcop_central%ROWTYPE;   
      
      -- Busca convênios
      CURSOR cr_conven(pr_cdconven tbconv_arrecadacao.cdempres%TYPE
                      ,pr_cdcooper crapcon.cdcooper%TYPE
                      ,pr_dtmvtolt craplft.dtvencto%TYPE
                      ) IS
        SELECT craplft.cdcooper
              ,tbconv_arrecadacao.cdempres
              ,tbconv_arrecadacao.cdempcon
              ,tbconv_arrecadacao.cdsegmto
              ,tbconv_arrecadacao.vltarifa_internet
              ,tbconv_arrecadacao.vltarifa_taa
              ,tbconv_arrecadacao.vltarifa_caixa
              ,tbconv_arrecadacao.nrlayout
              ,crapcon.nmextcon
              ,craplft.dtvencto
              ,craplft.cdbarras
              ,craplft.vllanmto
              ,craplft.cdagenci
              ,craplft.nrautdoc
              ,craplft.nrrefere
              ,craplft.nrdconta
              ,craplft.rowid
          FROM tbconv_arrecadacao
              ,crapcon
              ,craplft
         WHERE crapcon.cdcooper = pr_cdcooper
           AND crapcon.cdempcon = tbconv_arrecadacao.cdempcon
           AND crapcon.cdsegmto = tbconv_arrecadacao.cdsegmto
           AND crapcon.tparrecd = tbconv_arrecadacao.tparrecadacao
           AND crapcon.cdcooper = craplft.cdcooper
           AND crapcon.cdempcon = craplft.cdempcon
           AND crapcon.cdsegmto = craplft.cdsegmto
           AND crapcon.cdhistor = craplft.cdhistor
           AND craplft.dtvencto = pr_dtmvtolt
           AND crapcon.tparrecd = 2
           AND craplft.insitfat = 1
           AND tbconv_arrecadacao.cdempres      = DECODE(pr_cdconven, 0, cdempres, pr_cdconven)
      ORDER BY craplft.cdcooper, tbconv_arrecadacao.cdempres;
      --
      rw_conven cr_conven%ROWTYPE;
      -- Busca a data do movimento atual
      CURSOR cr_dtmvtolt(pr_cdcooper crapdat.cdcooper%TYPE
                        ) IS
        SELECT dtmvtolt
          FROM crapdat
         WHERE cdcooper = pr_cdcooper;
      --
      rw_dtmvtolt cr_dtmvtolt%ROWTYPE;
      -- Variável do arquivo log
      vr_input_log  utl_file.file_type;
      --
      vr_dscritic   VARCHAR2(4000);
      vr_exc_errcon EXCEPTION;
      vr_exc_erro   EXCEPTION;
      vr_nmarqtxt   VARCHAR2(4000);
      --
      vr_qtregist   NUMBER;
      vr_vltotrec   NUMBER;
      vr_vltrftot   NUMBER;
      --
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_nmrescop crapcop.nmrescop%TYPE;
      vr_cdagectl crapcop.cdagectl%TYPE;
      vr_cdconven tbconv_arrecadacao.cdempres%TYPE;
      vr_cdempcon tbconv_arrecadacao.cdempcon%TYPE;
      vr_nrrefere craplft.nrrefere%TYPE;
      vr_cdagebcb crapcop.cdagebcb%TYPE;
      vr_cdagebcb2 crapcop.cdagebcb%TYPE;
			vr_cdagenci crapass.cdagenci%TYPE;
      vr_trocaarq BOOLEAN;
      vr_procearq BOOLEAN;
      vr_linha    VARCHAR2(400);
      -- Função para retornar o nome do arquivo
      FUNCTION fn_nm_arquivo(pr_cdagebcb IN crapcop.cdagebcb%TYPE
                            ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_nmcopcen IN crapcop.nmrescop%TYPE
                            ,pr_nrnsa    IN NUMBER
                            ) RETURN VARCHAR2 IS
        --
      BEGIN
        --
        --RETURN lpad(pr_cdagectl, 4, '0') || '-' || 'EG'|| lpad(pr_cdempres, 10, '0') || to_char(pr_dtmvtolt, 'YYYYMMDD') || '.CNV';
        RETURN lpad(pr_cdagebcb, 4, '0') || '-' || 'FC'|| lpad(pr_cdempres, 10, '0') || 
               to_char(pr_dtmvtolt, 'YYYYMMDD') || '.' || lpad(pr_nrnsa, 3, '0')|| '.' || pr_nmcopcen;
        --
      END fn_nm_arquivo;
      
      -- Função para buscar a descrição do cadastro de bancos
      FUNCTION fn_busca_desc_banco(pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                                  ) RETURN VARCHAR2 IS
        --
        vr_nmextbcc crapban.nmextbcc%TYPE;
        --
      BEGIN
        --
        SELECT nmextbcc
          INTO vr_nmextbcc
          FROM crapban
         WHERE cdbccxlt = pr_cdbccxlt;
        --
        RETURN vr_nmextbcc;
        --
      EXCEPTION
        WHEN OTHERS THEN
          RETURN '';
      END fn_busca_desc_banco;
      
      -- Função para buscar número sequencial do arquivo (NSA)
      FUNCTION fn_busca_nsa(pr_cdcooper IN craptab.cdcooper%TYPE
                           ,pr_cdconven IN craptab.cdempres%TYPE
                           ) RETURN VARCHAR2 IS
        --
        vr_dstextab craptab.dstextab%TYPE;
        --
      BEGIN
        --
        SELECT dstextab
          INTO vr_dstextab
          FROM craptab
         WHERE upper(nmsistem) = 'CRED'
           AND upper(tptabela) = 'GENERI'
           AND cdempres = pr_cdconven
           AND upper(cdacesso) = 'ARQBANCOOB'
           AND tpregist = 00
           AND cdcooper = pr_cdcooper;
        --
        RETURN vr_dstextab;
        --
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 0;
      END fn_busca_nsa;
      
      -- Função para validar se o arquivo já foi gerado
      FUNCTION fn_valida_mvto(pr_dstextab IN craptab.dstextab%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ) RETURN BOOLEAN IS
        --
      BEGIN
        --
        IF substr(pr_dstextab, 8, 8) = to_char(pr_dtmvtolt, 'DDMMYYYY') THEN
          --
          RETURN FALSE;
          --
        ELSE
          --
          RETURN TRUE;
          --
        END IF;
        --
      END fn_valida_mvto;
      
      -- Busca agência do cooperado
      FUNCTION fn_busca_agencia(pr_cdcooper IN crapass.cdcooper%TYPE
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ) RETURN NUMBER IS
        --
        vr_cdagenci crapass.cdagenci%TYPE;
        --
      BEGIN
        --
        SELECT crapass.cdagenci
          INTO vr_cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
        --
        RETURN vr_cdagenci;
        --
      END fn_busca_agencia;
      
      -- Busca o código de cadastro da agência na Caixa Economica Federal para pagemto de FGTS
      FUNCTION fn_busca_age_cef(pr_cdcooper IN crapage.cdcooper%TYPE
                               ,pr_cdagenci IN crapage.cdagenci%TYPE
                               ) RETURN NUMBER IS
        --
        vr_cdagefgt crapage.cdagefgt%TYPE;
        --
      BEGIN
        --
        SELECT crapage.cdagefgt
          INTO vr_cdagefgt
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
        --
        RETURN vr_cdagefgt;
        --
      END fn_busca_age_cef;
      
      -- Rotina para criar registro na tabela GNCONTR para armazenar os detalhes do processamento de cada arquivo gerado
      PROCEDURE pc_gera_trilha(pr_cdcooper IN  gncontr.cdcooper%TYPE
                              ,pr_cdconven IN  gncontr.cdconven%TYPE
                              ,pr_dtmvtolt IN  gncontr.dtmvtolt%TYPE
                              ,pr_nrsequen IN  gncontr.nrsequen%TYPE
                              ,pr_nmarquiv IN  gncontr.nmarquiv%TYPE
                              ,pr_qtdoctos IN  gncontr.qtdoctos%TYPE
                              ,pr_vldoctos IN  gncontr.vldoctos%TYPE
                              ,pr_vltarifa IN  gncontr.vltarifa%TYPE
                              ,pr_dscritic OUT VARCHAR2
                              ) IS
      BEGIN
        --
        INSERT INTO gncontr( cdcooper
                            ,tpdcontr
                            ,cdconven
                            ,dtmvtolt
                            ,dtcredit
                            ,nmarquiv
                            ,qtdoctos
                            ,vldoctos
                            ,vltarifa
                            ,vlapagar
                            ,nrsequen
                            ,vldocto2
                            ,flgmigra
                            ,cdsitret)
                     VALUES(pr_cdcooper               -- cdcooper
                           ,6                         -- tpdcontr
                           ,pr_cdconven               -- cdconven
                           ,pr_dtmvtolt               -- dtmvtolt
                           ,NULL                      -- dtcredit
                           ,pr_nmarquiv               -- nmarquiv
                           ,pr_qtdoctos               -- qtdoctos
                           ,pr_vldoctos               -- vldoctos
                           ,pr_vltarifa               -- vltarifa
                           ,pr_vldoctos - pr_vltarifa -- vlapagar
                           ,pr_nrsequen               -- nrsequen
                           ,0                         -- vldocto2
                           ,0                         -- flgmigra
                           ,1  );                     -- cdsitret 
                           
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir na gncontr: ' || SQLERRM;
        --
      END pc_gera_trilha;
      
      -- Rotina para incrementar número sequencial do arquivo (NSA)
      PROCEDURE pc_incrementa_nsa(pr_cdcooper IN  craptab.cdcooper%TYPE
                                 ,pr_cdconven IN  craptab.cdempres%TYPE
                                 ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                                 ,pr_dscritic OUT VARCHAR2
                                 ) IS
        --
      BEGIN
        --
        /* Desenvolvimento feito para atender o manual do FGTS da Caixa Economica para os convênios 0239 e 0451.
           Porém o BANCOOB informou posteriormente que devemos seguir um sequencial único para cada convênio.
        IF pr_cdconven IN(0239, 0451) THEN
          --
          UPDATE craptab
             SET dstextab = to_number(dstextab) + 1
           WHERE nmsistem = 'CRED'
             AND tptabela = 'GENERI'
             AND cdempres IN(0239, 0451)
             AND cdacesso = 'ARQBANCOOB'
             AND tpregist = 00
             AND cdcooper = pr_cdcooper;
          --
        ELSE
        */
          --
          UPDATE craptab
             SET dstextab = lpad(to_number(substr(dstextab,1,6)) + 1, 6, '0') || ' ' || to_char(pr_dtmvtolt, 'DDMMYYYY')
           WHERE upper(nmsistem) = 'CRED'
             AND upper(tptabela) = 'GENERI'
             AND cdempres = pr_cdconven
             AND upper(cdacesso) = 'ARQBANCOOB'
             AND tpregist = 00
             AND cdcooper = pr_cdcooper;
          --
        --END IF;
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar craptab.dstextab: ' || SQLERRM;
      END pc_incrementa_nsa;
      
      -- Atualiza o registro da CRAPLFT como processado
      PROCEDURE pc_atualiza_craplft(pr_dtdenvio  IN  craplft.dtdenvio%TYPE
                                   ,pr_rowid     IN  ROWID
                                   ,pr_dscritic  OUT VARCHAR2
                                   ) IS
      BEGIN
        --
        UPDATE craplft
           SET craplft.insitfat = 2
              ,craplft.dtdenvio = pr_dtdenvio
         WHERE craplft.rowid    = pr_rowid;
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar a craplft: ' || SQLERRM;
      END pc_atualiza_craplft;
      
      -- Rotina de geração do cabeçalho
      PROCEDURE pc_gera_cabecalho(pr_dtmvtolt  IN  crapdat.dtmvtolt%TYPE
                                 ,pr_dstextab  IN  craptab.dstextab%TYPE
                                 ,pr_cdempres  IN  tbconv_arrecadacao.cdempres%TYPE
                                 ,pr_nrlayout  IN  tbconv_arrecadacao.nrlayout%TYPE
                                 ,pr_nmextcon  IN  crapcon.nmextcon%TYPE
                                 ,pr_cabecalho OUT VARCHAR2
                                 ,pr_dscritic  OUT VARCHAR2
                                 ) IS
        --
      BEGIN
        -- Código do registro
        pr_cabecalho := 'A';
        -- Código de remessa
        pr_cabecalho := pr_cabecalho || '2';
        -- Código do convênio
        pr_cabecalho := pr_cabecalho || RPAD(nvl(pr_cdempres, ' '), 20, ' ');
        -- Nome da Empresa/Órgão
        pr_cabecalho := pr_cabecalho || RPAD(pr_nmextcon, 20, ' ');
        -- Código da Instituição Financeira
        pr_cabecalho := pr_cabecalho || '085';
        -- Nome da Instituição Financeira
        pr_cabecalho := pr_cabecalho || RPAD(nvl(substr(fn_busca_desc_banco(pr_cdbccxlt => 085
                                                                           ), 0, 20), ' '), 20, ' ');
        -- Data da geração do arquivo
        pr_cabecalho := pr_cabecalho || to_char(pr_dtmvtolt, 'YYYYMMDD');
        -- Número seqüencial do arquivo (NSA)
        pr_cabecalho := pr_cabecalho || LPAD(substr(nvl(pr_dstextab, '0'), 0, 6), 6, '0');
        -- Versão do layout
        pr_cabecalho := pr_cabecalho || LPAD(nvl(pr_nrlayout, '0'), 2, '0');
        -- Fixo
        pr_cabecalho := pr_cabecalho || RPAD('CODIGO DE BARRAS', 17, ' ');
        -- Reservado para o futuro (filler)
        pr_cabecalho := pr_cabecalho || RPAD(' ', 52, ' ');
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao gerar o cabeçalho: ' || SQLERRM;
      END pc_gera_cabecalho;
      
      -- Rotina de geração do detalhe
      PROCEDURE pc_gera_detalhe(pr_dtvencto IN  craplft.dtvencto%TYPE
                               ,pr_cdbarras IN  craplft.cdbarras%TYPE
                               ,pr_vllanmto IN  craplft.vllanmto%TYPE
                               ,pr_nrseqreg IN  NUMBER
                               ,pr_cdagebcb IN  crapcop.cdagebcb%TYPE
                               ,pr_cdageaut IN  crapcop.cdagebcb%TYPE
                               ,pr_nrautdoc IN  craplft.nrautdoc%TYPE
                               ,pr_nrrefere IN  craplft.nrrefere%TYPE
															 ,pr_cdagenci IN  craplft.cdagenci%TYPE
                               ,pr_detalhe  OUT VARCHAR2
                               ,pr_dscritic OUT VARCHAR2
                               ) IS
        --
        vr_dsautdoc   VARCHAR2(50);
        
      BEGIN
        -- Código do registro
        pr_detalhe := 'G';
        -- Identificação da agência/conta/dígito creditada
        pr_detalhe := pr_detalhe || RPAD(nvl(pr_nrrefere, ' '), 20, ' ');
        -- Data de pagamento
        pr_detalhe := pr_detalhe || to_char(pr_dtvencto, 'YYYYMMDD');
        -- Data de crédito
        pr_detalhe := pr_detalhe || RPAD(' ', 8, ' ');
        -- Código de Barras
        pr_detalhe := pr_detalhe || RPAD(pr_cdbarras, 44, ' ');
        -- Valor recebido
        pr_detalhe := pr_detalhe || lpad(replace(trim(to_char(pr_vllanmto, '9999999990D90')), ',', ''), 12, '0');
        -- Valor da tarifa
        pr_detalhe := pr_detalhe || lpad(replace(trim(to_char(0, '9999999990D90')), ',', ''), 7, '0');
        -- NSR - Número Seqüencial de Registro
        pr_detalhe := pr_detalhe || lpad(pr_nrseqreg, 8, '0');
        -- Código da agência arrecadadora
        pr_detalhe := pr_detalhe || to_char(pr_cdageaut, 'fm0000')
				                         || to_char(pr_cdagenci, 'fm0000'); 
				
        -- Forma de arrecadação
        pr_detalhe := pr_detalhe || '2';
        
        -- Número de autenticação caixa ou código de transação
        vr_dsautdoc := to_char(pr_cdageaut,'fm0000') ||
                       --> quando liberar pagamento BANCOOB no TAA e CX.Online, deverá gravar PA do terminal e número do terminal
                       '0000'   || --> Terminal fixo "0000"
                        to_char(pr_nrautdoc,'fm00000000');
                        
        pr_detalhe := pr_detalhe || lpad(vr_dsautdoc,16,'0');
        -- Valor Desconto
        pr_detalhe := pr_detalhe ||RPAD('0', 8, '0');
        -- Valor Multa/Juros
        pr_detalhe := pr_detalhe || RPAD('0', 9, '0');
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao gerar o detalhe: ' || SQLERRM;
      END pc_gera_detalhe;
      
      -- Rotina de geração do trailler
      PROCEDURE pc_gera_trailler(pr_nrseqreg IN  NUMBER
                                ,pr_vltotreg IN  NUMBER
                                ,pr_trailler OUT VARCHAR2
                                ,pr_dscritic OUT VARCHAR2
                                ) IS
        --
      BEGIN
        -- Código do registro
        pr_trailler := 'Z';
        -- Total de registros do arquivo
        pr_trailler := pr_trailler || lpad((pr_nrseqreg + 2), 6, '0'); -- Somado 2 para considerar as linhas referentes ao header e trailler.
        -- Valor total recebido dos registros do arquivo
        pr_trailler := pr_trailler || lpad(replace(trim(to_char(pr_vltotreg, '999999999999990D90')), ',', ''), 17, '0');
        -- Reservado para o futuro (filler)
        pr_trailler := pr_trailler || RPAD(' ', 126, ' ');
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao gerar o trailler: ' || SQLERRM;
      END pc_gera_trailler;
      
      -- Rotina que insere uma linha na tabela em memória
      PROCEDURE pc_insere_linha(pr_linha IN VARCHAR2
                               ,pr_rowid IN ROWID
                               ) IS
      BEGIN
        --
        vr_index_arq := vr_index_arq + 1;
        --
        vr_tab_arquivo(vr_index_arq).ds_registro := pr_linha;
        --
        IF pr_rowid IS NOT NULL THEN
          --
          vr_tab_arquivo(vr_index_arq).id_rowid := pr_rowid;
          --
        END IF;
        --
      END pc_insere_linha;
      
      -- Rotina que grava o arquivo gerado em memória nos diretórios
      PROCEDURE pc_grava_arquivo(pr_cdagebcb IN  crapcop.cdagebcb%TYPE
                                ,pr_cdempres IN  tbconv_arrecadacao.cdempres%TYPE
                                ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                                ,pr_cdcooper IN  crapcop.cdcooper%TYPE
                                ,pr_dtvencto IN  craplft.dtvencto%TYPE
                                ,pr_qtregist IN  NUMBER
                                ,pr_vltotrec IN  NUMBER
                                ,pr_vltrftot IN  NUMBER
                                ,pr_nmcopcen IN crapcop.nmrescop%TYPE
                                ,pr_nmarqtxt OUT VARCHAR2
                                ,pr_dscritic OUT VARCHAR2
                                ) IS
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- Variável do arquivo texto
        vr_input_file utl_file.file_type;
        vr_nmdirtxt   VARCHAR2(4000);
        --
        vr_comando    VARCHAR2(4000);
        vr_typ_saida  VARCHAR2(3);
        --
        vr_exc_errcon EXCEPTION;
        --
      BEGIN
        --
        IF vr_tab_arquivo.count > 0 THEN
          -- Busca o nome do arquivo
          pr_nmarqtxt := fn_nm_arquivo(pr_cdagebcb => pr_cdagebcb -- IN
                                      ,pr_cdempres => pr_cdempres -- IN
                                      ,pr_dtmvtolt => pr_dtmvtolt -- IN
                                      ,pr_nmcopcen => pr_nmcopcen -- IN
                                      ,pr_nrnsa    => substr(fn_busca_nsa(pr_cdcooper => pr_cdcooper -- IN
                                                                                        ,pr_cdconven => pr_cdempres -- IN
                                                                         ), 0, 6) -- IN
                                      );
          -- Busca do diretório base da cooperativa
          vr_nmdirtxt := gene0001.fn_diretorio(pr_tpdireto => 'C'         -- IN -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper -- IN
                                              ,pr_nmsubdir => '/salvar'   -- IN -- /salvar
                                              );
          -- Cria registro na tabela GNCONTR para armazenar os detalhes do processamento de cada arquivo gerado
          pc_gera_trilha(pr_cdcooper => pr_cdcooper                 -- IN
                        ,pr_cdconven => pr_cdempres                 -- IN
                        ,pr_dtmvtolt => pr_dtvencto                 -- IN
                        ,pr_nrsequen => substr(fn_busca_nsa(pr_cdcooper => pr_cdcooper -- IN
                                                           ,pr_cdconven => pr_cdempres -- IN
                                                           ), 0, 6) -- IN
                        ,pr_nmarquiv => pr_nmarqtxt                 -- IN
                        ,pr_qtdoctos => pr_qtregist                 -- IN
                        ,pr_vldoctos => pr_vltotrec                 -- IN
                        ,pr_vltarifa => pr_vltrftot                 -- IN
                        ,pr_dscritic => pr_dscritic                 -- OUT
                        );
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_errcon;
            --
          END IF;
          -- Abre o arquivo de dados em modo de gravação
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                                  ,pr_nmarquiv => pr_nmarqtxt   -- IN -- Nome do arquivo
                                  ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                                  ,pr_des_erro => pr_dscritic   -- IN -- Erro
                                  );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_errcon;
            --
          END IF;
          -- Busca o primeiro registro
          vr_index_arq := vr_tab_arquivo.first;
          -- Percorre todos os registros
          WHILE vr_index_arq IS NOT NULL LOOP
            -- Escrever o registro no arquivo
            gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file                            -- Handle do arquivo aberto
                                          ,pr_des_text  => vr_tab_arquivo(vr_index_arq).ds_registro -- Texto para escrita
                                          );
            --
            IF vr_tab_arquivo(vr_index_arq).id_rowid IS NOT NULL THEN
              -- Atualiza o registro na tabela craplft para a situação de processado
              pc_atualiza_craplft(pr_dtdenvio  => pr_dtmvtolt                           -- IN
                                 ,pr_rowid     => vr_tab_arquivo(vr_index_arq).id_rowid -- IN
                                 ,pr_dscritic  => pr_dscritic                           -- OUT
                                 );
              --
              IF pr_dscritic IS NOT NULL THEN
                --
                RAISE vr_exc_errcon;
                --
              END IF;
              --
            END IF;
            -- Próximo registro
            vr_index_arq := vr_tab_arquivo.next(vr_index_arq);
            --
          END LOOP;
          -- Fechar Arquivo dados
          BEGIN
            --
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            --
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Problema ao fechar o arquivo <' || vr_nmdirtxt || '/' || pr_nmarqtxt || '>: ' || SQLERRM;
              RAISE vr_exc_errcon;
          END;
          -- Copiar arquivo para o diretorio enviados
          vr_comando:= 'cp ' || vr_nmdirtxt || '/' || pr_nmarqtxt || ' /usr/sistemas/bancoob/convenios/enviados';
          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => pr_dscritic);
          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            --
            pr_dscritic := 'Não foi possível executar comando unix. ' || vr_comando || ' Erro: ' || pr_dscritic;
            RAISE vr_exc_errcon;
            --
          END IF;
          -- Copiar arquivo para o diretorio envia
          vr_comando:= 'cp ' || vr_nmdirtxt || '/' || pr_nmarqtxt || ' /usr/connect/bancoob/envia';
          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => pr_dscritic);
          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            --
            pr_dscritic := 'Não foi possível executar comando unix. ' || vr_comando || ' Erro: ' || pr_dscritic;
            RAISE vr_exc_errcon;
            --
          END IF;
          -- Incrementar o numero do arquivo na craptab
          pc_incrementa_nsa(pr_cdcooper => pr_cdcooper -- IN
                           ,pr_cdconven => pr_cdempres -- IN
                           ,pr_dtmvtolt => pr_dtmvtolt -- IN
                           ,pr_dscritic => pr_dscritic -- OUT
                           );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_errcon;
            --
          END IF;
          --
        END IF;
        --
        COMMIT;
        --
      EXCEPTION
        WHEN vr_exc_errcon THEN
          ROLLBACK;
      END pc_grava_arquivo;
      --
    BEGIN
      -- Inicializa as variáveis
      vr_qtregist := 0;
      vr_vltotrec := 0;
      vr_vltrftot := 0;
      vr_cdcooper := 0;
      vr_nmrescop := NULL;
      vr_cdconven := 0;
      vr_cdempcon := 0;
      vr_trocaarq := FALSE;
      vr_linha    := NULL;
      vr_procearq := TRUE;
      -- Abre o arquivo de log em modo de gravação
      gene0001.pc_abre_arquivo(pr_nmdireto => gene0001.fn_diretorio(pr_tpdireto => 'C'    -- IN
                                                                   ,pr_cdcooper => 3      -- IN
                                                                   ,pr_nmsubdir => '/log' -- IN
                                                                   ) -- IN -- Diretório do arquivo
                              ,pr_nmarquiv => 'prccon_b.log'         -- IN -- Nome do arquivo
                              ,pr_tipabert => 'A'                    -- IN -- Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_log           -- IN -- Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic            -- IN -- Erro
                              );
      --
      IF vr_dscritic IS NOT NULL THEN
        --
        RAISE vr_exc_erro;
        --
      END IF;
      
      
      -- Busca dos dados da cooperativa central
      OPEN cr_crapcop_central (pr_cdcooper => 3);
      FETCH cr_crapcop_central INTO rw_crapcop_central;
      IF cr_crapcop_central%NOTFOUND THEN
        CLOSE cr_crapcop_central;
        vr_dscritic := 'Cooperativa central nao encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop_central;
      END IF;
      
      
      --
      OPEN cr_cooper(pr_cdcooper);
      --
      LOOP
        --
        FETCH cr_cooper INTO rw_cooper;
        EXIT WHEN cr_cooper%NOTFOUND;
        
        
        -- Escrever o log no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                    ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || 
                                                     ' - pc_gera_arrecadacao_bancoob'||
                                                     ' - '|| rw_cooper.nmrescop ||
                                                     ' --> Iniciada geração dos arquivos de arrecadação do BANCOOB.'   -- Texto para escrita
                                    );
      
        
        -- Busca a data do movimento atual
        OPEN cr_dtmvtolt(rw_cooper.cdcooper);
        --
        FETCH cr_dtmvtolt INTO rw_dtmvtolt;
        --
        IF cr_dtmvtolt%FOUND THEN
          --
          OPEN cr_conven(pr_cdconven
                        ,rw_cooper.cdcooper
                        ,rw_dtmvtolt.dtmvtolt);
          --
          LOOP
            --
            vr_linha := NULL;
            --
            FETCH cr_conven INTO rw_conven;
            EXIT WHEN cr_conven%NOTFOUND;
            --
            BEGIN
              -- Verifica se precisa inicializar um novo arquivo
              IF vr_cdcooper <> rw_cooper.cdcooper OR
                 vr_cdconven <> rw_conven.cdempres THEN
                -- Verifica se finaliza o arquivo anterior
                IF vr_procearq THEN
                  --
                  IF vr_qtregist > 0 THEN
                    --
                    vr_linha := NULL;
                    -- Gera a linha de trailler
                    pc_gera_trailler(pr_nrseqreg => vr_qtregist -- IN 
                                    ,pr_vltotreg => vr_vltotrec -- IN
                                    ,pr_trailler => vr_linha    -- OUT
                                    ,pr_dscritic => vr_dscritic -- OUT
                                    );
                    --	
                    IF vr_dscritic IS NOT NULL THEN
                      -- Escrever o log no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                                    ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Convênio ' || lpad(vr_cdconven, 10, '0') || '/' || lpad(vr_cdempcon, 4, '0') || ' não processado devido ao ERRO: ' || vr_dscritic -- Texto para escrita
                                                    );
                      --
                    ELSE
                      --
                      pc_insere_linha(pr_linha => vr_linha -- IN
                                     ,pr_rowid => NULL     -- IN
                                     );
                      -- Se não ocorreu nenhum erro durante o processamento dos movimentos, grava o arquivo nos diretórios
                      pc_grava_arquivo(pr_cdagebcb => vr_cdagebcb2          -- IN
                                      ,pr_cdempres => vr_cdconven          -- IN
                                      ,pr_dtmvtolt => rw_dtmvtolt.dtmvtolt -- IN
                                      ,pr_cdcooper => vr_cdcooper          -- IN
                                      ,pr_dtvencto => rw_dtmvtolt.dtmvtolt -- IN
                                      ,pr_qtregist => vr_qtregist          -- IN
                                      ,pr_vltotrec => vr_vltotrec          -- IN
                                      ,pr_vltrftot => vr_vltrftot          -- IN
                                      ,pr_nmcopcen => rw_crapcop_central.nmrescop -- IN
                                      ,pr_nmarqtxt => vr_nmarqtxt          -- OUT
                                      ,pr_dscritic => vr_dscritic          -- OUT
                                      );
                      --
                      IF vr_dscritic IS NOT NULL THEN
                        -- Escrever o log no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                                      ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Convênio ' || lpad(vr_cdconven, 10, '0') || '/' || lpad(vr_cdempcon, 4, '0') || ' não processado devido ao ERRO: ' || vr_dscritic -- Texto para escrita
                                                      );
                        --
                      ELSE
                        -- Verifica se deve finalizar o arquivo
                        IF vr_nmarqtxt IS NOT NULL THEN
                          -- Escrever o log no arquivo
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                                        ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Gerado o arquivo ' || vr_nmarqtxt || ' com sucesso.' -- Texto para escrita
                                                        );
                          --
                        END IF;
                        --
                      END IF;
                      --
                    END IF;
                    --
                    vr_index_arq   := 0;
                    vr_tab_arquivo.delete;
                    --
                    vr_qtregist := 0;
                    vr_vltotrec := 0;
                    vr_vltrftot := 0;
                    vr_cdcooper := 0;
                    vr_nmrescop := NULL;
                    vr_cdconven := 0;
                    vr_cdempcon := 0;
                    vr_trocaarq := FALSE;
                    vr_procearq := TRUE;
                    --
                  END IF;
                  --
                END IF;
                --
                vr_cdcooper := rw_cooper.cdcooper;
                vr_nmrescop := rw_cooper.nmrescop;
                vr_cdagectl := rw_cooper.cdagectl;
                vr_cdagebcb2 := rw_cooper.cdagebcb;
                vr_cdconven := rw_conven.cdempres;
                vr_cdempcon := rw_conven.cdempcon;
                vr_trocaarq := TRUE;
                vr_procearq := TRUE;
                --
              END IF;
              -- Se trocou o arquivo
              IF vr_trocaarq THEN
                -- Verifica se o arquivo já foi gerado
                IF NOT fn_valida_mvto(pr_dstextab => fn_busca_nsa(pr_cdcooper => rw_conven.cdcooper -- IN
                                                                 ,pr_cdconven => rw_conven.cdempres -- IN
                                                                 )        -- IN
                                     ,pr_dtmvtolt => rw_dtmvtolt.dtmvtolt -- IN
                                     ) THEN
                   --
                   vr_dscritic := 'Convênio ' || rw_conven.cdempres || ' já processado nesta data.';
                   vr_procearq := FALSE;
                   --
                   IF vr_dscritic IS NOT NULL THEN
                     --
                     RAISE vr_exc_errcon;
                     --
                   END IF;
                   --
                END IF;
                --
              END IF;
              -- Verifica se precisa pular o arquivo
              IF vr_procearq THEN
                -- Gera o arquivo com as arrecadações para a cooperativa e convênio informados
                -- Incrementa a quantidade de registros processados
                vr_qtregist := vr_qtregist + 1;
                -- Somatório dos valores processados
                vr_vltotrec := vr_vltotrec + rw_conven.vllanmto;
                -- Somatório das tarifas
                IF rw_conven.cdagenci = 90 THEN
                  --
                  vr_vltrftot := vr_vltrftot + rw_conven.vltarifa_internet;
                  --
                ELSIF rw_conven.cdagenci = 91 THEN
                  --
                  vr_vltrftot := vr_vltrftot + rw_conven.vltarifa_taa;
                  --
                ELSE
                  --
                  vr_vltrftot := vr_vltrftot + rw_conven.vltarifa_caixa;
                  --
                END IF;
                -- Se for o primeiro registro, gerar o cabeçalho
                IF vr_qtregist = 1  THEN
                  --
                  vr_linha := NULL;
                  -- Gera a linha de cabeçalho
                  pc_gera_cabecalho(pr_dtmvtolt  => rw_dtmvtolt.dtmvtolt -- IN
                                   ,pr_dstextab  => fn_busca_nsa(pr_cdcooper => rw_conven.cdcooper -- IN
                                                                ,pr_cdconven => rw_conven.cdempres -- IN
                                                                )        -- IN
                                   ,pr_cdempres	 => rw_conven.cdempres   -- IN
                                   ,pr_nrlayout  => rw_conven.nrlayout   -- IN
                                   ,pr_nmextcon  => rw_conven.nmextcon   -- IN
                                   ,pr_cabecalho => vr_linha             -- OUT
                                   ,pr_dscritic  => vr_dscritic          -- OUT
                                   );
                  --
                  IF vr_dscritic IS NOT NULL THEN
                    --
                    RAISE vr_exc_errcon;
                    --
                  ELSE
                    --
                    pc_insere_linha(pr_linha => vr_linha -- IN
                                   ,pr_rowid => NULL     -- IN
                                   );
                    --
                  END IF;
                  --
                END IF;
                --
                vr_linha := NULL;
                -- Para o convênio 181, deverá enviar o código identificador informado pelo cooperado no pagamento da fatura
                IF rw_conven.cdempcon = 181 THEN
                  --
                  vr_nrrefere := rw_conven.nrrefere;
                  --
                ELSE
                  --
                  vr_nrrefere := NULL;
                  --
                END IF;
								/* Inicialmente BANCOOB solicitou que informassemos o número CAF para 
								 convênios FGTS, mas durante a homologação pediram para enviar sempre
								 a agência da singular no BANCOOB */ 
								
                /*-- Somente para convênios FGTS (0178,0179,0180,0181,0239,0240 e 0451), deverá informar o número CAF do PA do cooperado
                IF rw_conven.cdempcon IN (0178, 0179, 0180, 0181, 0239, 0240, 0451) THEN
                  --
                  vr_cdagebcb := fn_busca_age_cef(pr_cdcooper => rw_cooper.cdcooper
                                                 ,pr_cdagenci => fn_busca_agencia(pr_cdcooper => rw_cooper.cdcooper
                                                                                 ,pr_nrdconta => rw_conven.nrdconta
                                                                                 )
                                                 );
                  --
                ELSE*/
                  vr_cdagebcb := rw_cooper.cdagebcb;
                  --
                --END IF;
								-- Buscar PA do cooperado
								vr_cdagenci := fn_busca_agencia(pr_cdcooper => rw_cooper.cdcooper
                                               ,pr_nrdconta => rw_conven.nrdconta);
											
                -- Gera a linha de detalhe
                pc_gera_detalhe(pr_dtvencto => rw_conven.dtvencto -- IN
                               ,pr_cdbarras => rw_conven.cdbarras -- IN
                               ,pr_vllanmto => rw_conven.vllanmto -- IN
                               ,pr_nrseqreg => vr_qtregist        -- IN
                               ,pr_cdagebcb => vr_cdagebcb        -- IN
                               ,pr_cdageaut => rw_cooper.cdagebcb -- IN
                               ,pr_nrautdoc => rw_conven.nrautdoc -- IN
                               ,pr_nrrefere => vr_nrrefere        -- IN
															 ,pr_cdagenci => vr_cdagenci        -- IN
                               ,pr_detalhe  => vr_linha           -- OUT
                               ,pr_dscritic => vr_dscritic        -- OUT
                               );
                --
                IF vr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_errcon;
                  --
                ELSE
                  --
                  pc_insere_linha(pr_linha => vr_linha        -- IN
                                 ,pr_rowid => rw_conven.rowid -- IN
                                 );
                  --
                END IF;
                --
              END IF;
              --
            EXCEPTION
              WHEN vr_exc_errcon THEN
                -- Escrever o log no arquivo
                gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                              ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || rw_cooper.nmrescop || ' - Convênio ' || lpad(rw_conven.cdempres, 10, '0') || '/' ||lpad(rw_conven.cdempcon, 4, '0') || ' não processado devido ao ERRO: ' || vr_dscritic -- Texto para escrita
                                              );
            END;
            --
          END LOOP;
          --
          IF vr_qtregist > 0 THEN
            --
            vr_linha := NULL;
            -- Gera a linha de trailler
            pc_gera_trailler(pr_nrseqreg => vr_qtregist -- IN
                            ,pr_vltotreg => vr_vltotrec -- IN
                            ,pr_trailler => vr_linha    -- OUT
                            ,pr_dscritic => vr_dscritic -- OUT
                            );
            --	
            IF vr_dscritic IS NOT NULL THEN
              -- Escrever o log no arquivo
              gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                            ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Convênio ' || lpad(rw_conven.cdempres, 10, '0') || '/' ||lpad(rw_conven.cdempcon, 4, '0') || ' não processado devido ao ERRO: ' || vr_dscritic -- Texto para escrita
                                            );
              --
            ELSE
              --
              pc_insere_linha(pr_linha => vr_linha -- IN
                             ,pr_rowid => NULL     -- IN
                             );
              -- Se não ocorreu nenhum erro durante o processamento dos movimentos, grava o arquivo nos diretórios
              pc_grava_arquivo(pr_cdagebcb => vr_cdagebcb2          -- IN
                              ,pr_cdempres => vr_cdconven          -- IN
                              ,pr_dtmvtolt => rw_dtmvtolt.dtmvtolt -- IN
                              ,pr_cdcooper => vr_cdcooper          -- IN
                              ,pr_dtvencto => rw_dtmvtolt.dtmvtolt -- IN
                              ,pr_qtregist => vr_qtregist          -- IN
                              ,pr_vltotrec => vr_vltotrec          -- IN
                              ,pr_vltrftot => vr_vltrftot          -- IN
                              ,pr_nmcopcen => rw_crapcop_central.nmrescop -- IN
                              ,pr_nmarqtxt => vr_nmarqtxt          -- OUT
                              ,pr_dscritic => vr_dscritic          -- OUT
                              );
              --
              IF vr_dscritic IS NOT NULL THEN
                -- Escrever o log no arquivo
                gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                              ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Convênio ' || lpad(rw_conven.cdempres, 10, '0') || '/' ||lpad(rw_conven.cdempcon, 4, '0') || ' não processado devido ao ERRO: ' || vr_dscritic -- Texto para escrita
                                              );
                --
              ELSE
                -- Verifica se deve finalizar o arquivo
                IF vr_nmarqtxt IS NOT NULL THEN
                  -- Escrever o log no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                                ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || vr_nmrescop || ' - Gerado o arquivo ' || vr_nmarqtxt || ' com sucesso.' -- Texto para escrita
                                                );
                  --
                END IF;
                --
              END IF;
              --
            END IF;
            --
            vr_index_arq   := 0;
            vr_tab_arquivo.delete;
            --
            vr_qtregist := 0;
            vr_vltotrec := 0;
            vr_vltrftot := 0;
            vr_cdcooper := 0;
            vr_nmrescop := NULL;
            vr_cdconven := 0;
            vr_cdempcon := 0;
            vr_trocaarq := FALSE;
            vr_procearq := TRUE;
            --
          END IF;
          --
          CLOSE cr_conven;
          --
        ELSE
          -- Trata erro
          vr_dscritic := 'Erro ao buscar a data do movimento atual: ' || SQLERRM;
          -- Escrever o log no arquivo
          gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                        ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> ' || rw_cooper.nmrescop || ' - Arquivo nao gerado devido ao erro: ' || vr_dscritic -- Texto para escrita
                                        );
          --
        END IF;
        --
        CLOSE cr_dtmvtolt;
        
        -- Escrever o log no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                      ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || 
                                                       ' - pc_gera_arrecadacao_bancoob'||
                                                       ' - '|| rw_cooper.nmrescop ||
                                                       ' --> Finalizada geração dos arquivos de arrecadação do BANCOOB.' -- Texto para escrita
                                      );
        --
      END LOOP;
      --
      CLOSE cr_cooper;
      
      -- Fechar Arquivo log
      BEGIN
        --
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_log); --> Handle do arquivo aberto;
        --
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao fechar o log </usr/coop/cecred/log/prccon_b.log>: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Escrever o log no arquivo
        pr_dscritic := to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_gera_arrecadacao_bancoob --> Erro durante a geração dos arquivos de arrecadação do BANCOOB: ' || vr_dscritic; -- Texto para escrita
    END pc_gera_arrecadacao_bancoob;
    
    -- Rotina para retornar os convênios de acordo com os parâmetros informados
    PROCEDURE pc_busca_convenios_bcb(pr_cdcooper IN crapcop.cdcooper%TYPE            -- Código da cooperativa
                                ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                                ,pr_des_erro OUT VARCHAR2             	         -- Saida OK/NOK
                                ,pr_clob_ret OUT CLOB                            -- Tabela Historico
                                ,pr_cdcritic OUT PLS_INTEGER                     -- Codigo Erro
                                ,pr_dscritic OUT VARCHAR2                        -- Descricao Erro
                                ) IS
      /* .............................................................................
       
       Programa: pc_busca_convenios_bcb
       Autor   : Supero
       Data    : Janeiro/2018.                    Ultima atualizacao: 

       Objetivo  : Procedure para listar os convenios Bancoob

       Alteracoes:  
                                 
      ..............................................................................*/
      CURSOR cr_conven(pr_cdempres tbconv_arrecadacao.cdempres%TYPE
                      ,pr_cdcooper crapcon.cdcooper%TYPE
                      ) IS
        SELECT tbconv_arrecadacao.cdempres cdempres
              ,crapcon.nmextcon            nmextcon
          FROM tbconv_arrecadacao
              ,crapcon
         WHERE tbconv_arrecadacao.cdempcon      = crapcon.cdempcon
           AND tbconv_arrecadacao.cdsegmto      = crapcon.cdsegmto
           AND tbconv_arrecadacao.tparrecadacao = 2
           AND tbconv_arrecadacao.cdempres      = decode(pr_cdempres, 0, tbconv_arrecadacao.cdempres, pr_cdempres)
           AND crapcon.cdcooper                 = decode(pr_cdcooper, 0, 1, pr_cdcooper);
      -- Variáveis Arquivo Dados
      vr_dstexto VARCHAR2(32767);
      vr_string  VARCHAR2(32767);
      --
      rw_conven cr_conven%ROWTYPE;
      --
      vr_index       NUMBER := 0;
      vr_tab_conveni paga0003.typ_tab_conveni;
      --
    BEGIN
      --
      OPEN cr_conven(pr_cdempres
                    ,pr_cdcooper
                    );
      --
      LOOP
        --
        FETCH cr_conven INTO rw_conven;
        EXIT WHEN cr_conven%NOTFOUND;
        --
        vr_index:= vr_index + 1;
        --
        vr_tab_conveni(vr_index).cdempres := rw_conven.cdempres;
        vr_tab_conveni(vr_index).nmextcon := rw_conven.nmextcon;
        --
      END LOOP;
      --
      CLOSE cr_conven;
      --Montar CLOB
      IF vr_tab_conveni.count > 0 THEN        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro historico
        vr_index:= vr_tab_conveni.FIRST;
        
        --Percorrer todos os historicos
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<convenio>'||
                      '<cdempres>'||NVL(TO_CHAR(vr_tab_conveni(vr_index).cdempres),'0')|| '</cdempres>'||
                      '<nmextcon>'||NVL(TO_CHAR(vr_tab_conveni(vr_index).nmextcon),'0')|| '</nmextcon>'||
                      '</convenio>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_conveni.NEXT(vr_index);          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);                                                   
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';
      --
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';        
        pr_cdcritic:= 0;
        
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na paga0003.pc_busca_convenios_bcb --> '|| SQLERRM;
    END pc_busca_convenios_bcb;
    -- Fim -- PRJ406
  
END paga0003;
/
