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

  PROCEDURE pc_verifica_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
                                ,pr_idorigem IN INTEGER -- Canal de origem da opera��o
                                ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                                ,pr_tpcaptur IN NUMBER -- Tipo de captura da guia (1-C�digo Barras / 2-Manual)
                                ,pr_lindigi1 IN OUT NUMBER -- Primeiro campo da linha digit�vel da guia
                                ,pr_lindigi2 IN OUT NUMBER -- Segundo campo da linha digit�vel da guia
                                ,pr_lindigi3 IN OUT NUMBER -- Terceiro campo da linha digit�vel da guia
                                ,pr_lindigi4 IN OUT NUMBER -- Quarto campo da linha digit�vel da guia
                                ,pr_cdbarras IN OUT VARCHAR2 -- C�digo de barras da guia
                                ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                ,pr_dtapurac IN DATE -- Per�odo de apura��o da guia
                                ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                ,pr_cdtribut IN VARCHAR2 -- C�digo de tributa��o da guia
                                ,pr_nrrefere IN NUMBER -- N�mero de refer�ncia da guia
                                ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                ,pr_idagenda IN INTEGER -- Indicador de agendamento (1-Nesta Data/2-Agendamento
                                ,pr_dtagenda IN DATE -- Data de agendamento
                                ,pr_indvalid IN INTEGER -- Indicador de controle de valida��es (1-Opera��o Online/2-Opera��o Batch)
								,pr_flmobile IN INTEGER -- Indicador Mobile
                                ,pr_cdseqfat OUT VARCHAR2 -- C�digo sequencial da guia
                                ,pr_vldocmto OUT NUMBER -- Valor da guia
                                ,pr_nrdigfat OUT NUMBER -- Digito do faturamento
                                ,pr_cdcritic OUT INTEGER -- C�digo do erro
                                ,pr_dscritic OUT VARCHAR2 -- Descri�ao do erro
                                 );

  PROCEDURE pc_paga_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE	-- C�digo da cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE	-- N�mero da conta
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE	-- Sequencial de titularidade
                            ,pr_nrcpfope IN NUMBER	-- CPF do operador PJ
                            ,pr_idorigem IN INTEGER	-- Canal de origem da opera��o
                            ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                            ,pr_tpcaptur IN INTEGER	-- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                            ,pr_cdseqfat IN VARCHAR2 -- C�digo sequencial da guia
                            ,pr_nrdigfat IN NUMBER  -- D�gito do faturamento
                            ,pr_lindigi1 IN NUMBER	-- Primeiro campo da linha digit�vel da guia
                            ,pr_lindigi2 IN NUMBER  -- Segundo campo da linha digit�vel da guia
                            ,pr_lindigi3 IN NUMBER  -- Terceiro campo da linha digit�vel da guia
                            ,pr_lindigi4 IN NUMBER  -- Quarto campo da linha digit�vel da guia
                            ,pr_cdbarras IN VARCHAR2	-- C�digo de barras da guia
                            ,pr_dsidepag IN VARCHAR2	-- Descri��o da identifica��o do pagamento
                            ,pr_vlrtotal IN NUMBER	-- Valor total do pagamento da guia
                            ,pr_dsnomfon IN VARCHAR2	-- Nome e telefone da guia
                            ,pr_dtapurac IN DATE		-- Per�odo de apura��o da guia
                            ,pr_nrcpfcgc IN VARCHAR2  -- CPF/CNPJ da guia
                            ,pr_cdtribut IN VARCHAR2  -- C�digo de tributa��o da guia
                            ,pr_nrrefere IN NUMBER  -- N�mero de refer�ncia da guia
                            ,pr_dtvencto IN DATE		-- Data de vencimento da guia
                            ,pr_vlrprinc IN NUMBER	-- Valor principal da guia
                            ,pr_vlrmulta IN NUMBER	-- Valor da multa da guia
                            ,pr_vlrjuros IN NUMBER	-- Valor dos juros da guia
                            ,pr_vlrecbru IN NUMBER	-- Valor da receita bruta acumulada da guia
                            ,pr_vlpercen IN NUMBER	-- Valor do percentual da guia
                            ,pr_vldocmto IN NUMBER  -- Valor da guia
                            ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 � Nesta Data / 2 � Agendamento)
                            ,pr_tpleitor IN INTEGER	-- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual)
                            ,pr_dsprotoc OUT VARCHAR2 --Descricao Protocolo
                            ,pr_cdcritic OUT INTEGER	-- C�digo do erro
                            ,pr_dscritic OUT VARCHAR2	-- Descri�ao do erro
                            );

	/* Procedimento do internetbank opera��o 188 - Operar pagamento DARF/DAS */
  PROCEDURE pc_InternetBank188(pr_cdcooper IN  crapcop.cdcooper%TYPE  -- N�mero da conta
															,pr_nrdconta IN  crapass.nrdconta%TYPE  -- Sequencial de titularidade
															,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- CPF do operador PJ
															,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- Canal de origem da opera��o
															,pr_dtmvtopg IN  DATE                   -- Data do pagamento
															,pr_idorigem IN  INTEGER                -- Indicador de requisi��o via canal Mobile
															,pr_flmobile IN  INTEGER                -- Indicador de efetiva��o da opera��o de pagamento
															,pr_idefetiv IN  INTEGER                -- Tipo da guia (1 � DARF / 2 � DAS)
															,pr_tpdaguia IN  INTEGER                -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
															,pr_tpcaptur IN  INTEGER                -- Primeiro campo da linha digit�vel da guia
															,pr_lindigi1 IN  NUMBER                 -- Segundo campo da linha digit�vel da guia
															,pr_lindigi2 IN  NUMBER                 -- Terceiro campo da linha digit�vel da guia
															,pr_lindigi3 IN  NUMBER                 -- Quarto campo da linha digit�vel da guia
															,pr_lindigi4 IN  NUMBER                 -- C�digo de barras da guia
															,pr_cdbarras IN  VARCHAR2               -- Descri��o da identifica��o do pagamento
															,pr_dsidepag IN  VARCHAR2               -- Valor total do pagamento da guia
															,pr_vlrtotal IN  NUMBER                 -- Nome e telefone da guia
															,pr_dsnomfon IN  VARCHAR2               -- Per�odo de apura��o da guia
															,pr_dtapurac IN  DATE                   -- CPF/CNPJ da guia
															,pr_nrcpfcgc IN  VARCHAR2               -- C�digo de tributa��o da guia
															,pr_cdtribut IN  VARCHAR2                 -- N�mero de refer�ncia da guia
															,pr_nrrefere IN  NUMBER                 -- Data de vencimento da guia
															,pr_dtvencto IN  DATE                   -- Valor principal da guia
															,pr_vlrprinc IN  NUMBER                 -- Valor da multa da guia
															,pr_vlrmulta IN  NUMBER                 -- Valor dos juros da guia
															,pr_vlrjuros IN  NUMBER                 -- Valor da receita bruta acumulada da guia
															,pr_vlrecbru IN  NUMBER                 -- Valor do percentual da guia
															,pr_vlpercen IN  NUMBER                 -- C�digo sequencial da guia
															,pr_idagenda IN  INTEGER                -- Data de agendamento
															,pr_vlapagar IN  NUMBER                 -- Indicador de valida��o do saldo em rela��o ao valor total
															,pr_versaldo IN  INTEGER                -- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual)
															,pr_tpleitor IN  INTEGER                -- Descri�ao do erro
															,pr_xml_dsmsgerr    OUT VARCHAR2        -- Retorno XML de critica
                              ,pr_xml_operacao188 OUT CLOB            -- Retorno XML da opera��o 188
                              								,pr_dsretorn        OUT VARCHAR2 );     -- Retorno de critica (OK ou NOK)

  PROCEDURE pc_cria_agend_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
								  ,pr_cdagenci IN INTEGER               -- PA
								  ,pr_nrdcaixa IN NUMBER                -- Numero do Caixa
								  ,pr_cdoperad IN VARCHAR2              -- Cd Operador
                                  ,pr_nrcpfope IN NUMBER -- CPF do operador PJ
                                  ,pr_idorigem IN INTEGER -- Canal de origem da opera��o
                                  ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                                  ,pr_tpcaptur IN INTEGER -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                                  ,pr_cdhistor IN INTEGER               -- Hist�rico
                                  ,pr_lindigi1 IN NUMBER -- Primeiro campo da linha digit�vel da guia
                                  ,pr_lindigi2 IN NUMBER -- Segundo campo da linha digit�vel da guia
                                  ,pr_lindigi3 IN NUMBER -- Terceiro campo da linha digit�vel da guia
                                  ,pr_lindigi4 IN NUMBER -- Quarto campo da linha digit�vel da guia
                                  ,pr_cdbarras IN VARCHAR2 -- C�digo de barras da guia
                                  ,pr_dsidepag IN VARCHAR2 -- Descri��o da identifica��o do pagamento
                                  ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                  ,pr_dsnomfon IN VARCHAR2 -- Nome e telefone da guia
                                  ,pr_dtapurac IN DATE -- Per�odo de apura��o da guia
                                  ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                  ,pr_cdtribut IN VARCHAR2 -- C�digo de tributa��o da guia
                                  ,pr_nrrefere IN NUMBER -- N�mero de refer�ncia da guia
                                  ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                  ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                  ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                  ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                  ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                  ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                  ,pr_dtagenda IN DATE -- Data de agendamento
                                  ,pr_cdtrapen IN NUMBER -- C�digo de sequencial da transa��o pendente
																	,pr_tpleitor IN INTEGER               -- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual) 
                                  ,pr_dsprotoc OUT VARCHAR2 --Protocolo
                                  ,pr_cdcritic OUT INTEGER -- C�digo do erro
                                  ,pr_dscritic OUT VARCHAR2 -- Descri�ao do erro
                                   );

  /* Procedimento do internetbank opera��o 187 - Consulta de Horario Limite DARF/DAS */
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
                              ,pr_flmobile IN INTEGER                    -- Indicador se origem � do Mobile
                              ,pr_xml_dsmsgerr    OUT VARCHAR2           -- Retorno XML de critica
                              ,pr_xml_operacao187 OUT CLOB               -- Retorno XML da opera��o 187
                              ,pr_dsretorn        OUT VARCHAR2);         -- Retorno de critica (OK ou NOK)
       
   PROCEDURE pc_busca_agend_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE                --> C�digo da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                --> C�digo do Operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                        ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE                --> N�mero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                        ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                        ,pr_clobxmlc OUT CLOB                                --> XML com informa��es de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                         --> C�digo da cr�tica
                                        ,pr_dscritic OUT VARCHAR2);                          --> Descri��o da cr�tica
END paga0003;
/
/*..............................................................................
  
   Programa: PAGA0003
   Autor   : Dionathan
   Data    : 19/07/2016                        Ultima atualizacao: 08/05/2017
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necess�rias para pagamento de guias DARF e DAS
  
   Alteracoes: 
	             
		   22/02/2017 - Altera�oes para composi�ao de comprovante DARF/DAS Modelo Sicredi
					        - Ajustes para corre�ao de cr�tica de pagamento DARF/DAS (P.349.2) (Lucas Lunelli)
							 
       08/05/2017 - Validar tributo atrav�s da tabela crapstb (Lucas Ranghetti #654763)
							 								   
..............................................................................*/
CREATE OR REPLACE PACKAGE BODY CECRED.paga0003 IS

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
          ,crapcon.flgcnvsi
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
  
  PROCEDURE pc_monitoracao_pagamento(pr_cdcooper crapcop.cdcooper%TYPE -- pr_cdcooper
                                    ,pr_nrdconta crapass.nrdconta%TYPE -- pr_nrdconta
                                    ,pr_idseqttl crapttl.idseqttl%TYPE -- pr_idseqttl
                                    ,pr_dtmvtocd crapdat.dtmvtocd%TYPE -- rw_crapdat.dtmvtocd
                                    ,pr_cdagenci crapage.cdagenci%TYPE -- vr_cdagenci
                                    ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 � Nesta Data / 2 � Agendamento)
                                    ,pr_vlfatura IN  NUMBER   -- Valor fatura
                                    ,pr_dscritic OUT VARCHAR2 -- Descri�ao do erro
                                    ) IS
    /* .............................................................................

     Programa: pc_monitoracao_pagamento
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Objetivo  : Procedure de monitora��o de pagamentos para evitar fraudes.

     Alteracoes: 
    ..............................................................................*/
  /** ------------------------------------------------------------- **
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
   ** Ser� enviado email de monitoracao apenas quando:              **
   ** - Valor pago for maior ou igual a 3.000,00 independente do ip **
   ** - Valor pago for maior ou igual a 700,00 at� 2.999,99 ser�    **
   ** verificado o IP anterior, caso seja diferente, envia email.   **
   ** ------------------------------------------------------------- **/
    
  -- Busca as informa��es da cooperativa conectada
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
  
  -- Cursor para protocolos e lan�amentos de DARF/DAS
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
    FROM crappro pro
        ,crapaut aut
        ,craplft lft
   WHERE pro.cdcooper = pr_cdcooper
     AND pro.nrdconta = pr_nrdconta
     AND pro.dtmvtolt = pr_dtmvtolt
     AND pro.cdtippro IN (16, 17, 18, 19)
     
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
      vr_datdodia:= trunc(sysdate); /*PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);*/
      
      --Flag email recebe true
      vr_flgemail:= TRUE;

      /** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
          esses pagtos para enviar no email **/
      IF vr_flgemail THEN
        --Zerar valor pagamentos
        vr_vlpagtos:= 0;
        vr_dspagtos:= NULL;

        -- Cursor para protocolos e lan�amentos de DARF/DAS
        FOR rw_craplft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtocd) LOOP
          --Acumular pagamentos
          vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craplft.vllanmto;
          vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;
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
        END LOOP; --rw_craplft

        /** Verifica se o valor do pagto eh menor que o parametrizado
        e total pago no dia eh menor que o parametrizado**/
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

              -- Verificar se foram identificados tr�s IP
              IF vr_qtidenti >= 3 THEN
                RAISE vr_exec_lgm;
              END IF;
                
            END LOOP;-- Loop craplgm

            vr_dtlimite := vr_dtlimite - 1;

          END LOOP; -- Loop da data
        EXCEPTION
          -- Exception para quando encontrar os tr�s registros de IP
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

      /** Enviar email para monitoracao se passou pelos filtros **/
      IF vr_flgemail THEN
				
        vr_conteudo:= 'PA: '||rw_crapass.cdagenci||' - '||rw_crapass.nmresage;
        --Adicionar numero da conta na mensagem
        vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
				
        --Se for pessoa fisica
        IF rw_crapass.inpessoa = 1 THEN
          /** Lista todos os titulares **/

          FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl) LOOP
            --Concatenar Conteudo
            vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                       ': '||rw_crapttl.nmextttl|| '<BR>';
          END LOOP;

        ELSE
          /** Lista o nome da empresa **/

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
          /** Lista os procuradores/representantes **/
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
        vr_des_assunto:= 'PAGTO DARF/DAS '||rw_crapcop.nmrescop ||' '||
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
                                  ,pr_des_destino     => vr_email_dest --> Um ou mais detinat�rios separados por ';' ou ','
                                  ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio ser� do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endere�o para resposta ao e-mail
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
  END;
  
  PROCEDURE pc_cria_comprovante_darf_das(pr_cdcooper IN  crapcop.cdcooper%TYPE -- C�digo da cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  -- N�mero da conta
                                        --,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                                        ,pr_nmextttl IN crapttl.nmextttl%TYPE  -- Nome do Titular
                                        ,pr_nrcpfope IN NUMBER                 -- CPF do operador PJ
                                        ,pr_nrcpfpre IN NUMBER                 -- N�mero pr� opera��o
                                        ,pr_nmprepos IN VARCHAR2               -- Nome Preposto
                                        --,pr_tpdaguia IN INTEGER                -- Tipo da guia (1 � DARF / 2 � DAS)
                                        ,pr_tpcaptur IN INTEGER                -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                                        ,pr_cdtippro IN crappro.cdtippro%TYPE  -- C�digo do tipo do comprovante
                                        ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE  -- Data de movimento da autentica��o
                                        ,pr_hrautent IN crapaut.hrautent%TYPE  -- Hor�rio da autentica��o
                                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  -- N�mero do documento
                                        ,pr_nrseqaut IN crapaut.nrsequen%TYPE  -- Sequencial da autentica��o
                                        ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  -- N�mero do caixa da autentica��o
                                        ,pr_nmconven IN crapcon.nmextcon%TYPE  -- Nome do conv�nio da guia
                                        ,pr_lindigi1 IN NUMBER                 -- Primeiro campo da linha digit�vel da guia
                                        ,pr_lindigi2 IN NUMBER                 -- Segundo campo da linha digit�vel da guia
                                        ,pr_lindigi3 IN NUMBER                 -- Terceiro campo da linha digit�vel da guia
                                        ,pr_lindigi4 IN NUMBER                 -- Quarto campo da linha digit�vel da guia
                                        ,pr_cdbarras IN VARCHAR2               -- C�digo de barras da guia
                                        ,pr_dsidepag IN VARCHAR2               -- Descri��o da identifica��o do pagamento
                                        ,pr_vlrtotal IN NUMBER                 -- Valor total do pagamento da guia
                                        ,pr_dsnomfon IN VARCHAR2               -- Nome e telefone da guia
                                        ,pr_dtapurac IN DATE                   -- Per�odo de apura��o da guia
                                        ,pr_nrcpfcgc IN VARCHAR2               -- CPF/CNPJ da guia
                                        ,pr_cdtribut IN VARCHAR2               -- C�digo de tributa��o da guia
                                        ,pr_nrrefere IN VARCHAR2               -- N�mero de refer�ncia da guia
                                        ,pr_dtvencto IN DATE                   -- Data de vencimento da guia
                                        ,pr_vlrprinc IN NUMBER                 -- Valor principal da guia
                                        ,pr_vlrmulta IN NUMBER                 -- Valor da multa da guia
                                        ,pr_vlrjuros IN NUMBER                 -- Valor dos juros da guia
                                        ,pr_vlrecbru IN NUMBER                 -- Valor da receita bruta acumulada da guia
                                        ,pr_vlpercen IN NUMBER                 -- Valor do percentual da guia
                                        ,pr_flgagend IN BOOLEAN                -- Indicador de agendamento (TRUE � Agendamento / FALSE � Nesta Data)
					                    ,pr_cdtransa IN VARCHAR2               -- C�digo da transa��o por meio de arrecada��o do SICREDI
					                    ,pr_dssigemp IN VARCHAR2               -- Descri��o resumida de conv�nio DARF para autentica��o modelo SICREDI
                                        ,pr_dsprotoc OUT crappro.dsprotoc%TYPE -- Descri��o do protocolo do comprovante
                                        ,pr_cdcritic OUT INTEGER               -- C�digo do erro
                                        ,pr_dscritic OUT VARCHAR2              -- Descri�ao do erro
                                        ) IS
    /* .............................................................................

     Programa: pc_cria_comprovante_darf_das
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Objetivo  : Procedure para cria��o de comprovantes de pagamento de DARF/DAS

     Alteracoes: 
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
	
    --T�tulo do comprovante
    vr_dsinfor1 := CASE pr_cdtippro
                     WHEN 16 THEN 'DARF'
                     WHEN 17 THEN 'DAS'
                     WHEN 18 THEN 'Agendamento de DARF'
                     WHEN 19 THEN 'Agendamento de DAS'
                     ELSE ''
                    END;
    
    -- Nome do Titular
    vr_dsinfor2 := pr_nmextttl;
    
	IF pr_nrrefere <> '0' THEN
		vr_nrrefere := pr_nrrefere;
	END IF;
    
    -- Busca as informa��es do banco/agencia arrecadador (Sicredi - Matriz)
    OPEN cr_arrec(pr_cddbanco => 748
                 ,pr_cdageban => 0100);
    FETCH cr_arrec INTO rw_arrec;
    CLOSE cr_arrec;
    
    --################## DADOS DO COMPROVANTE ##################
    vr_dsinfor3 := vr_dsinfor3 || 'Tpcaptura: '              || TO_CHAR(pr_tpcaptur);
    vr_dsinfor3 := vr_dsinfor3 || '#Solicitante: '            || pr_nmextttl;
    vr_dsinfor3 := vr_dsinfor3 || '#Agente Arrecadador: '    || rw_arrec.nmextbcc;
    vr_dsinfor3 := vr_dsinfor3 || '#Ag�ncia: '               || rw_arrec.nmageban;
    vr_dsinfor3 := vr_dsinfor3 || '#Tipo de Documento: '     || pr_nmconven;
    vr_dsinfor3 := vr_dsinfor3 || '#Nome/Telefone: '         || pr_dsnomfon;
    
    -- Se for Captura via C�digo de Barras
    IF pr_tpcaptur = 1 THEN
    
      vr_dsinfor3 := vr_dsinfor3 || '#C�digo de Barras: '		|| pr_cdbarras;
      vr_dsinfor3 := vr_dsinfor3 || '#Linha Digit�vel: '		||  REPLACE(to_char(pr_lindigi1, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi2, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi3, 'fm00000000000G0'),'.','-') || ' ' ||
																	REPLACE(to_char(pr_lindigi4, 'fm00000000000G0'),'.','-');
      
      vr_dsinfor3 := vr_dsinfor3 || '#Data de Vencimento: '		|| TO_CHAR(pr_dtvencto,'DD/MM/YYYY');
			
      --Apenas para DAS
      IF pr_cdtippro IN (17, 19) THEN
         vr_dsinfor3 := vr_dsinfor3 || '#N�mero Documento (DAS): '	|| SUBSTR(pr_cdbarras,25,17);
	  ELSE
		 -- Apenas para DARF 385
		 IF vr_cdempcon = 385 AND
			 vr_cdsegmto = 5   THEN
			 vr_dsinfor3 := vr_dsinfor3 || '#N�mero Documento (DARF): '	|| SUBSTR(pr_cdbarras,25,17);
 		 END IF;
      END IF;
      
    -- Se for Captura Manual
    ELSIF pr_tpcaptur = 2 THEN

      vr_dsinfor3 := vr_dsinfor3 || '#Per�odo de Apura��o: '    || TO_CHAR(pr_dtapurac,'DD/MM/YYYY');
      vr_dsinfor3 := vr_dsinfor3 || '#N�mero do CPF ou CNPJ: '  || TO_CHAR(gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,vr_inpessoa));
      vr_dsinfor3 := vr_dsinfor3 || '#C�digo da Receita: '      || LPAD(pr_cdtribut, 4, '0');
      
      IF pr_cdtribut = '6106' THEN
        vr_dsinfor3 := vr_dsinfor3 || '#Valor da Receita Bruta: ' || TO_CHAR(pr_vlrecbru,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
        vr_dsinfor3 := vr_dsinfor3 || '#Percentual: '             || TO_CHAR(pr_vlpercen,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      ELSE
        vr_dsinfor3 := vr_dsinfor3 || '#N�mero de Refer�ncia: '   || vr_nrrefere;
        vr_dsinfor3 := vr_dsinfor3 || '#Data de Vencimento: '     || TO_CHAR(pr_dtvencto,'DD/MM/YYYY');
      END IF;
      
      vr_dsinfor3 := vr_dsinfor3 || '#Valor Principal: '        || TO_CHAR(pr_vlrprinc,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Valor da Multa: '         || TO_CHAR(pr_vlrmulta,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      vr_dsinfor3 := vr_dsinfor3 || '#Valor dos Juros e/ou Encargos DL-1025/69: ' || TO_CHAR(pr_vlrjuros,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
      
    END IF;
    
    vr_dsinfor3 := vr_dsinfor3 || '#Valor Total: '            || TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
    vr_dsinfor3 := vr_dsinfor3 || '#Descri��o do Pagamento: ' || pr_dsidepag;
    
		-- Composi��o de autentica��o conforme comprovante do modelo do SICREDI
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
			  vr_dsinfor3 := vr_dsinfor3 || '#Autentica��o Sicredi: ' || vr_dsautsic;
				
		END IF;
    
    --################## FIM DOS DADOS DO COMPROVANTE ##################
    
    -- Procedure para gerar protocolos de seguran�a com criptografia MD5 */
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
         pr_dscritic := 'Erro ao gerar Comprovante de Pagamento de DARF/DAS';
       END IF;
  END pc_cria_comprovante_darf_das;

  PROCEDURE pc_verifica_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
                                ,pr_idorigem IN INTEGER -- Canal de origem da opera��o
                                ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                                ,pr_tpcaptur IN NUMBER -- Tipo de captura da guia (1-C�digo Barras / 2-Manual)
                                ,pr_lindigi1 IN OUT NUMBER -- Primeiro campo da linha digit�vel da guia
                                ,pr_lindigi2 IN OUT NUMBER -- Segundo campo da linha digit�vel da guia
                                ,pr_lindigi3 IN OUT NUMBER -- Terceiro campo da linha digit�vel da guia
                                ,pr_lindigi4 IN OUT NUMBER -- Quarto campo da linha digit�vel da guia
                                ,pr_cdbarras IN OUT VARCHAR2 -- C�digo de barras da guia
                                ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                ,pr_dtapurac IN DATE -- Per�odo de apura��o da guia
                                ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                ,pr_cdtribut IN VARCHAR2 -- C�digo de tributa��o da guia
                                ,pr_nrrefere IN NUMBER -- N�mero de refer�ncia da guia
                                ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                ,pr_idagenda IN INTEGER -- Indicador de agendamento (1-Nesta Data/2-Agendamento
                                ,pr_dtagenda IN DATE -- Data de agendamento
                                ,pr_indvalid IN INTEGER -- Indicador de controle de valida��es (1-Opera��o Online/2-Opera��o Batch)
								                ,pr_flmobile IN INTEGER -- Indicador Mobile
                                ,pr_cdseqfat OUT VARCHAR2 -- C�digo sequencial da guia
                                ,pr_vldocmto OUT NUMBER -- Valor da guia
                                ,pr_nrdigfat OUT NUMBER -- Digito do faturamento
                                ,pr_cdcritic OUT INTEGER -- C�digo do erro
                                ,pr_dscritic OUT VARCHAR2 -- Descri�ao do erro
                                 ) IS
    /* .............................................................................

     Programa: pc_verifica_darf_das
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 08/05/2017

     Objetivo  : Procedure para valida��o de pagamento de DARF/DAS

     Alteracoes: 08/05/2017 - Validar tributo atrav�s da tabela crapstb (Lucas Ranghetti #654763)
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
            ,crapcon.flgcnvsi
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
    
    -- Busca as transa��es pendentes com o mesmo sequencial de fatura
    -- OBS: Apenas para quando a captura for atrav�s da linha digitavel
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
    
    -- Busca as transa��es pendentes
    -- OBS: Apenas para quando a captura for atrav�s da digita��o dos campos da guia
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
    vr_cdempcon  crapcon.cdempcon%TYPE; -- C�digo do conv�nio
    vr_cdsegmto  crapcon.cdsegmto%TYPE; -- C�digo do segmento
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
    
    --Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
  
  BEGIN
    
    --Seta a Ag�ncia e Caixa
    vr_cdagenci := 90; -- InternetBank
    vr_nrdcaixa := 900;
    
    -- Obt�m a data de movimento cadastrada
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
  
		
	--Se a captura for atrav�s do c�digo de barras da guia
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
					                    ,pr_poslimit => 0            --Utilizado para valida��o de d�gito adicional de DAS
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
          vr_dscritic := 'Parametro de Data de Bloqueio de agendamento de conta migrada n�o encontrado.';
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
    ELSE -- Se n�o for agendamento
      vr_dtmvtopg := rw_crapdat.dtmvtocd;
    END IF;
  
    --Se a captura for atrav�s do c�digo de barras da guia
    IF pr_tpcaptur = 1 THEN
    
      -- Obt�m o conv�nio a partir do c�digo de barras
      vr_cdempcon := SUBSTR(pr_cdbarras, 16, 4);
      vr_cdsegmto := SUBSTR(pr_cdbarras, 2, 1);
            
      -- Busca o conv�nio na CRAPCON
      OPEN cr_crapcon(pr_cdcooper => pr_cdcooper
                     ,pr_cdempcon => vr_cdempcon
                     ,pr_cdsegmto => vr_cdsegmto);
      FETCH cr_crapcon
        INTO rw_crapcon;
      CLOSE cr_crapcon;
    
      --Verifica se o conv�nio existe
      IF rw_crapcon.cdempcon IS NULL THEN
        vr_dscritic := 'Conv�nio n�o cadastrado. Procure seu Posto de Atendimento para mais informa��es.';
        RAISE vr_exc_erro;
      END IF;
    
      --Verifica se o conv�nio est� liberado para pagamento via internet
      IF pr_idorigem = 3 AND rw_crapcon.flginter <> 1 THEN
        vr_dscritic := 'Este conv�nio n�o est� habilitado para pagamento via internet.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Se n�o for uma DARF/DAS v�lida
      IF vr_cdempcon NOT IN (64, 153, 154, 328, 385) OR vr_cdsegmto NOT IN (5) THEN
      
        -- GPS -- Conv�nio 270 e Segmento 5
        IF vr_cdempcon = 270 AND vr_cdsegmto = 5 THEN
					IF pr_flmobile = 1 THEN -- Canal Mobile
						vr_dscritic := 'Pagamento de GPS n�o dispon�vel, utilize a Conta Online.';
					ELSE -- Conta Online
									vr_dscritic := 'GPS deve ser paga na op��o ''Transa��es - GPS'' do menu de servi�os.';
					END IF;
        
        -- CONV�NIO - Se o primeiro d�gito do c�digo de barras for 8
        ELSIF SUBSTR(pr_cdbarras, 0, 1) = 8 THEN
          vr_dscritic := 'Conv�nio deve ser pago na op��o ''Transa��es - Pagamentos'' do menu de servi�os';
        
        -- BOLETO - Se n�o cair em nenhuma condi��o anterior
        ELSE
          vr_dscritic := 'Boleto deve ser pago na op��o ''Transa��es - Pagamentos'' do menu de servi�os';
        END IF;
      
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Se for DARF sendo paga como DAS, ou vice-versa
      IF pr_tpdaguia = 1 AND vr_cdempcon IN (328) THEN -- DAS sendo paga como DARF
				IF pr_flmobile = 1 THEN -- Canal Mobile
					vr_dscritic := 'DAS deve ser paga na op��o ''Tributos - DAS'' do menu de servi�os';
				ELSE -- Conta Online
					vr_dscritic := 'DAS deve ser paga na op��o ''Transa��es - DAS'' do menu de servi�os';
      	END IF;
    
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSIF pr_tpdaguia = 2 AND vr_cdempcon IN (64, 153, 154, 385) THEN -- DARF sendo paga como DAS
				IF pr_flmobile = 1 THEN -- Canal Mobile
					vr_dscritic := 'DARF deve ser paga na op��o ''Tributos - DARF'' do menu de servi�os';
				ELSE -- Conta Online
					vr_dscritic := 'DARF deve ser paga na op��o ''Transa��es - DARF'' do menu de servi�os';
        END IF;
    
        --Levantar Excecao
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
      -- Valida��o referente aos dias de tolerancia
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
      
      -- Obtem o c�digo do operador
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
          vr_dscritic:= 'N�o foi poss�vel concluir a valida��o. Procure seu Posto de Atendimento para mais informa��es.';
        END IF;
        
        RAISE vr_exc_erro;
      END IF;
      
      --Verifica se o valor informado � diferente do valor do documento
      IF pr_vldocmto <> pr_vlrtotal THEN
         vr_dscritic := 'O valor a pagar informado difere do valor total do documento.';
         RAISE vr_exc_erro;
      END IF;
      
      -- Se for uma opera��o online
      IF pr_indvalid = 1 THEN
        --Selecionar transa��es pendentes de operador jur�dico
        OPEN cr_trans_pend(pr_dtmvtopg => vr_dtmvtopg
                          ,pr_cdhistor => rw_crapcon.cdhistor
                          ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat) --Sequencial faturamento
						  ,pr_tpdaguia => pr_tpdaguia); 
        FETCH cr_trans_pend INTO rw_trans_pend;
        cr_trans_pend_found := cr_trans_pend%FOUND;
        CLOSE cr_trans_pend;
        
        --Se encontrar transa��o pendente dispara exce��o
        IF cr_trans_pend_found THEN
          vr_dscritic:= 'Esta guia j� foi registrada para aprova��o.';
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- Se for um agendamento
      IF pr_idagenda = 2 THEN
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
          vr_dscritic:= 'O pagamento desta guia j� est� agendando.';
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
    ELSIF pr_tpcaptur = 2 THEN -- Se a captura for atrav�s da digita��o dos campos da guia
      
      -- Verifica se � agendamento
      IF pr_idagenda = 2 THEN
        -- Se a data de agendamento for maior que a data de vencimento dispara exce��o
        IF pr_dtagenda > pr_dtvencto THEN
           vr_dscritic := 'A data de efetiva��o do pagamento n�o pode ser superior ao vencimento da guia.';
           RAISE vr_exc_erro;
        END IF;
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
                                       ,pr_idagenda => pr_idagenda -- Indentificador de Agendamento
                                       ,pr_foco     => vr_foco
                                       ,pr_cdseqfat => pr_cdseqfat -- Codigo Sequencial da DARF
                                       ,pr_cdcritic => vr_cdcritic -- Codigo do erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao do erro
      
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN        
        RAISE vr_exc_erro;
      END IF;
      
      -- Se for uma opera��o online
      IF pr_indvalid = 1 THEN
        -- Verifica se a guia j� consta nas transa��es pendentes do operador de pessoa jur�dica
        OPEN cr_trans_pend2(pr_dtmvtopg => vr_dtmvtopg
                           ,pr_cdseqfat => TO_NUMBER(pr_cdseqfat) --Sequencial faturamento
						               ,pr_tpdaguia => pr_tpdaguia); 
        FETCH cr_trans_pend2
        INTO rw_trans_pend2;
        cr_trans_pend2_found := cr_trans_pend2%FOUND;
        CLOSE cr_trans_pend2;
        
        --Se encontrar transa��o pendente dispara exce��o
        IF cr_trans_pend2_found THEN
          vr_dscritic:= 'Esta guia j� foi registrada para aprova��o.';
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
          vr_dscritic:= 'O pagamento desta guia j� est� agendando.';
          RAISE vr_exc_erro;
        END IF;        
        
        -- Obt�m a data de apura��o m�nima para agendamento        
        vr_dtminage := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtocd,'MM'),-1);        
        
        IF pr_dtapurac < vr_dtminage THEN
          vr_dscritic := 'DARF com data de apura��o inferior a #dtminage# n�o pode ser agendada.';
		  vr_dscritic := REPLACE(vr_dscritic, '#dtminage#', TO_CHAR(vr_dtminage,'fmMonth/YYYY','nls_date_language =''brazilian portuguese'''));					
          RAISE vr_exc_erro;
        END IF;        
        
      END IF;
      
    END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PAGA0003.pc_verifica_darf_das. ' ||
                     SQLERRM;
  END pc_verifica_darf_das;

  PROCEDURE pc_paga_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE	-- C�digo da cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE	-- N�mero da conta
                            ,pr_idseqttl IN crapttl.idseqttl%TYPE	-- Sequencial de titularidade
                            ,pr_nrcpfope IN NUMBER	-- CPF do operador PJ
                            ,pr_idorigem IN INTEGER	-- Canal de origem da opera��o
                            ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                            ,pr_tpcaptur IN INTEGER	-- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                            ,pr_cdseqfat IN VARCHAR2 -- C�digo sequencial da guia
                            ,pr_nrdigfat IN NUMBER  -- D�gito do faturamento
                            ,pr_lindigi1 IN NUMBER	-- Primeiro campo da linha digit�vel da guia
                            ,pr_lindigi2 IN NUMBER	-- Segundo campo da linha digit�vel da guia
                            ,pr_lindigi3 IN NUMBER	-- Terceiro campo da linha digit�vel da guia
                            ,pr_lindigi4 IN NUMBER	-- Quarto campo da linha digit�vel da guia
                            ,pr_cdbarras IN VARCHAR2	-- C�digo de barras da guia
                            ,pr_dsidepag IN VARCHAR2	-- Descri��o da identifica��o do pagamento
                            ,pr_vlrtotal IN NUMBER	-- Valor total do pagamento da guia
                            ,pr_dsnomfon IN VARCHAR2	-- Nome e telefone da guia
                            ,pr_dtapurac IN DATE		-- Per�odo de apura��o da guia
                            ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                            ,pr_cdtribut IN VARCHAR2  -- C�digo de tributa��o da guia
                            ,pr_nrrefere IN NUMBER  -- N�mero de refer�ncia da guia
                            ,pr_dtvencto IN DATE		-- Data de vencimento da guia
                            ,pr_vlrprinc IN NUMBER	-- Valor principal da guia
                            ,pr_vlrmulta IN NUMBER	-- Valor da multa da guia
                            ,pr_vlrjuros IN NUMBER	-- Valor dos juros da guia
                            ,pr_vlrecbru IN NUMBER	-- Valor da receita bruta acumulada da guia
                            ,pr_vlpercen IN NUMBER	-- Valor do percentual da guia
                            ,pr_vldocmto IN NUMBER  -- Valor da guia
                            ,pr_idagenda IN INTEGER	-- Indicador de agendamento (1 � Nesta Data / 2 � Agendamento)
                            ,pr_tpleitor IN INTEGER	-- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual)
                            ,pr_dsprotoc OUT VARCHAR2 --Descricao Protocolo
                            ,pr_cdcritic OUT INTEGER	-- C�digo do erro
                            ,pr_dscritic OUT VARCHAR2	-- Descri�ao do erro
                            ) IS
    /* .............................................................................

     Programa: pc_paga_darf_das
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Objetivo  : Procedure para efetiva��o de pagamento de DARF/DAS

     Alteracoes: 
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
    -- Pessoa F�dica
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
       AND ass.inpessoa = 1 -- Pessoa F�sica
       
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl
    UNION ALL
    -- Pessoa Jur�dica
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
       -- Obt�m o registro de senha da internet do primeiro titular
     WHERE snh.cdcooper(+) = ass.cdcooper
       AND snh.nrdconta(+) = ass.nrdconta
       AND snh.idseqttl(+) = 1 -- Primeiro Titular
       AND snh.tpdsenha(+) = 1 -- Internet
       
       -- Obtem o Avalista Jur�dico a partir do CPF do primeiro titular
       AND avt.cdcooper(+) = snh.cdcooper
       AND avt.nrdconta(+) = snh.nrdconta
       AND avt.nrcpfcgc(+) = snh.nrcpfcgc
       AND avt.tpctrato(+) = 6 -- Jur
       
       -- Caso o avalista for cooperado, obt�m seus dados na tabela CRAPASS
       AND ass2.cdcooper(+) = avt.cdcooper
       AND ass2.nrdconta(+) = avt.nrdctato
       
       AND ass.inpessoa <> 1 -- Pessoa Jur�dica
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
    
    rw_craplot lote0001.cr_craplot%ROWTYPE;
    rw_craplot_rowid lote0001.cr_craplot_rowid%ROWTYPE;
    
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
  
  BEGIN
        
    --Seta a Ag�ncia e Caixa
    vr_cdagenci := 90; -- InternetBank
    vr_nrdcaixa := 900;
    
    --Historico Debito
    vr_cdhisdeb:= 508;
    
    -- Descri��o do Cedente
    vr_dsidepag := NVL(trim(pr_dsidepag), CASE pr_tpdaguia
                                    		WHEN 1 THEN 'DARF'
                                    		WHEN 2 THEN 'DAS' END);
    
    -- Obtem o c�digo do operador
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
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
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
    
    -- Caso o o c�digo de barras estiver vazio popula com base na linha digit�vel
    IF TRIM(pr_cdbarras) IS NULL THEN
       --Se possuir linha digit�vel popula o c�digo de barras
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
        
    --Se a captura for atrav�s do c�digo de barras da guia
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

    ELSIF pr_tpcaptur = 2 THEN -- Se a captura for atrav�s da digita��o dos campos da guia
      
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
    
    -- Procedimento para inserir o lote e n�o deixar tabela lockada
    lote0001.pc_insere_lote(pr_cdcooper => rw_crapaut.cdcooper
                           ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                           ,pr_cdagenci => rw_crapaut.cdagenci
                           ,pr_cdbccxlt => 11
                           ,pr_nrdolote => 11900
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nrdcaixa => rw_crapaut.nrdcaixa
                           ,pr_tplotmov => 1
                           ,pr_cdhistor => 0
                           ,pr_craplot  => rw_craplot
                           ,pr_dscritic => vr_dscritic);

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
									
				-- Valida��o referente aos dias de tolerancia
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
		ELSE  -- DAS
      		vr_cdtippro := 17;
			
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
			
			-- Valida��o referente aos dias de tolerancia
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
    
			vr_dsnomcnv := rw_crapcon.nmextcon;		
			vr_dtvencto := vr_dttolera;
			
		END IF;
    
    --Obtem flag de agendamento
    vr_flgagend := CASE pr_idagenda WHEN 2 THEN TRUE ELSE FALSE END;
    
    -- Gera um protocolo para o pagamento
    paga0003.pc_cria_comprovante_darf_das(pr_cdcooper => rw_crapaut.cdcooper -- C�digo da cooperativa
                                         ,pr_nrdconta => pr_nrdconta -- N�mero da conta
                                         ,pr_nmextttl => rw_crapass.nmextttl -- Nome do Titular
                                         ,pr_nrcpfope => pr_nrcpfope -- CPF do operador PJ
										                     ,pr_nrcpfpre => rw_crapass.nrcpfpre -- N�mero pr� opera��o
                                         ,pr_nmprepos => rw_crapass.nmprepos -- Nome Preposto
                                         ,pr_tpcaptur => pr_tpcaptur -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                                         ,pr_cdtippro => vr_cdtippro -- C�digo do tipo do comprovante
                                         ,pr_dtmvtolt => rw_crapaut.dtmvtolt -- Data de movimento da autentica��o
                                         ,pr_hrautent => rw_crapaut.hrautent -- Hor�rio da autentica��o
                                         ,pr_nrdocmto => rw_craplot.nrseqdig -- N�mero do documento
                                         ,pr_nrseqaut => rw_crapaut.nrsequen -- Sequencial da autentica��o
                                         ,pr_nrdcaixa => rw_crapaut.nrdcaixa -- N�mero do caixa da autentica��o
                                         ,pr_nmconven => vr_dsnomcnv         -- Nome do conv�nio da guia
                                         ,pr_lindigi1 => pr_lindigi1 -- Primeiro campo da linha digit�vel da guia
                                         ,pr_lindigi2 => pr_lindigi2 -- Segundo campo da linha digit�vel da guia
                                         ,pr_lindigi3 => pr_lindigi3 -- Terceiro campo da linha digit�vel da guia
                                         ,pr_lindigi4 => pr_lindigi4 -- Quarto campo da linha digit�vel da guia
                                         ,pr_cdbarras => pr_cdbarras -- C�digo de barras da guia
                                         ,pr_dsidepag => vr_dsidepag -- Descri��o da identifica��o do pagamento
                                         ,pr_vlrtotal => rw_crapaut.vldocmto -- Valor total do pagamento da guia
                                         ,pr_dsnomfon => pr_dsnomfon -- Nome e telefone da guia
                                         ,pr_dtapurac => pr_dtapurac -- Per�odo de apura��o da guia
                                         ,pr_nrcpfcgc => pr_nrcpfcgc -- CPF/CNPJ da guia
                                         ,pr_cdtribut => pr_cdtribut -- C�digo de tributa��o da guia
                                         ,pr_nrrefere => pr_nrrefere -- N�mero de refer�ncia da guia
                                         ,pr_dtvencto => vr_dtvencto -- Data de vencimento da guia
                                         ,pr_vlrprinc => pr_vlrprinc -- Valor principal da guia
                                         ,pr_vlrmulta => pr_vlrmulta -- Valor da multa da guia
                                         ,pr_vlrjuros => pr_vlrjuros -- Valor dos juros da guia
                                         ,pr_vlrecbru => pr_vlrecbru -- Valor da receita bruta acumulada da guia
                                         ,pr_vlpercen => pr_vlpercen -- Valor do percentual da guia
                                         ,pr_flgagend => vr_flgagend -- Indicador de agendamento (TRUE � Agendamento / FALSE � Nesta Data)
										                     ,pr_cdtransa => vr_cdtransa -- C�digo da transa��o por meio de arrecada��o do SICREDI
										                     ,pr_dssigemp => vr_dssigemp -- Descri��o resumida de conv�nio DARF para autentica��o modelo SICREDI
                                         ,pr_dsprotoc => pr_dsprotoc -- Descri��o do protocolo do comprovante
                                         ,pr_cdcritic => vr_cdcritic -- C�digo do erro
                                         ,pr_dscritic => vr_dscritic -- Descri�ao do erro
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
                                           ,pr_docto        => rw_craplot.nrseqdig  --Numero documento
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
                                           ,pr_cdcritic     => vr_cdcritic          --C�digo do erro
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
            ,rw_craplot.nrseqdig
            ,rw_craplot.nrseqdig
            ,rw_craplot.nrseqdig
            ,rw_crapaut.cdhistor
            ,rw_crapaut.vldocmto
            ,rw_crapaut.nrsequen
            ,vr_dsidepag
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
    
		-- Monitora��o sendo realizada antes das atualiza��es da craplot para evitar prolongar lock
		-- Executa monitora��o de Pagamentos
		pc_monitoracao_pagamento(pr_cdcooper => pr_cdcooper
														,pr_nrdconta => pr_nrdconta
														,pr_idseqttl => pr_idseqttl
														,pr_dtmvtocd => rw_crapdat.dtmvtocd
														,pr_cdagenci => vr_cdagenci
														,pr_idagenda => pr_idagenda
														,pr_vlfatura => pr_vlrtotal
														,pr_dscritic => vr_dscritic
														);
	    
		-- se encontrou erro ao buscar lote, abortar programa
		IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;	
    
    /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
    FOR i IN 1..100 LOOP
      BEGIN
        -- Leitura do lote
        OPEN lote0001.cr_craplot_rowid(pr_rowid  => rw_craplot.rowid);
        FETCH lote0001.cr_craplot_rowid INTO rw_craplot_rowid;
        CLOSE lote0001.cr_craplot_rowid;
        vr_dscritic := NULL;
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
           IF lote0001.cr_craplot_rowid%ISOPEN THEN
             CLOSE lote0001.cr_craplot_rowid;
           END IF;
           -- setar critica caso for o ultimo
           IF i = 100 THEN
             vr_dscritic:= 'Registro de lote '||rw_craplot.nrdolote||' em uso. Tente novamente.';
           END IF;
           -- aguardar 0,5 seg. antes de tentar novamente
           sys.dbms_lock.sleep(0.1);
      END;
    END LOOP;
      
    -- se encontrou erro ao buscar lote, abortar programa
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
    -- Atualiza o lote na craplot
    BEGIN
      UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                        ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                        ,craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + nvl(rw_crapaut.vldocmto,0)
                        ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + nvl(rw_crapaut.vldocmto,0)
      WHERE craplot.ROWID = rw_craplot.ROWID
      RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;

    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic := 'Erro ao atualizar tabela craplot. (lote:'||rw_craplot.nrdolote||')'||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;
      
    -- se for pagemento pela INTERNET deve atualizar o lote referente a
    -- cria��o do titulo, estrategia utilizada para diminuir o tempo de lock do lote
    IF vr_cdagenci = 90 THEN --> INTERNET
      rw_craplot := NULL;
      /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1..100 LOOP
        BEGIN
          -- Leitura do lote
          OPEN lote0001.cr_craplot(pr_cdcooper  => pr_cdcooper,
                                   pr_dtmvtolt  => rw_crapdat.dtmvtocd,
                                   pr_cdagenci  => vr_cdagenci,
                                   pr_cdbccxlt  => 11,
                                   pr_nrdolote  => 15900); --> Lote fixo, pois na chamada da CXON0014 as informa��es estao fixas
          FETCH lote0001.cr_craplot INTO rw_craplot;
          CLOSE lote0001.cr_craplot;
          vr_dscritic := NULL;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
            IF lote0001.cr_craplot%ISOPEN THEN
              CLOSE lote0001.cr_craplot;
            END IF;
            -- setar critica caso for o ultimo
            IF i = 100 THEN
              vr_dscritic:= 'Registro de lote '||rw_craplot.nrdolote||' em uso. Tente novamente.';
            END IF;
            -- aguardar 0,5 seg. antes de tentar novamente
            sys.dbms_lock.sleep(0.1);
        END;
      END LOOP;
        
      -- se encontrou erro ao buscar lote, abortar programa
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualizar lote de cria��o da Tit, deixado por ultimo para diminuir tempo de lock
      BEGIN
        UPDATE craplot SET craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                          ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                          ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_vlrtotal
                          ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_vlrtotal
        WHERE craplot.ROWID = rw_craplot.ROWID
        RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    END IF; -- IF vr_cdagenci = 90 --INTERNET
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      --rollback do savepoint
      ROLLBACK TO TRANS_UNDO;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      --rollback do savepoint
      ROLLBACK TO TRANS_UNDO;
        
      pr_dscritic := 'Erro na rotina PAGA0003.pc_paga_darf_das. ' ||
                     SQLERRM;
  END pc_paga_darf_das;
  
/*..............................................................................
  
   Programa: PAGA0003
   Autor   : Lucas Lunelli
   Data    : 19/09/2016                        Ultima atualizacao: 08/11/2016
  
   Dados referentes ao programa: 
  
   Objetivo  : Package com as procedures necess�rias para pagamento de guias DARF e DAS
  
   Alteracoes: 08/11/2016 - Altera��o na procedure interna de LOG (Jean Michel).
..............................................................................*/  

	/* Procedimento do internetbank opera��o 188 - Operar pagamento DARF/DAS */
  PROCEDURE pc_InternetBank188( pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Cooperativa
                               ,pr_nrdconta IN  crapass.nrdconta%TYPE  -- N�mero da conta
                               ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial de titularidade
                               ,pr_nrcpfope IN  crapopi.nrcpfope%TYPE  -- CPF do operador PJ
                               ,pr_dtmvtopg IN  DATE                   -- Data do pagamento
                               ,pr_idorigem IN  INTEGER                -- Canal de origem da opera��o
                               ,pr_flmobile IN  INTEGER                -- Indicador de requisi��o via canal Mobile
                               ,pr_idefetiv IN  INTEGER                -- Indicador de efetiva��o da opera��o de pagamento
                               ,pr_tpdaguia IN  INTEGER                -- Tipo da guia (1 � DARF / 2 � DAS)
                               ,pr_tpcaptur IN  INTEGER                -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                               ,pr_lindigi1 IN  NUMBER                 -- Primeiro campo da linha digit�vel da guia
                               ,pr_lindigi2 IN  NUMBER                 -- Segundo campo da linha digit�vel da guia
                               ,pr_lindigi3 IN  NUMBER                 -- Terceiro campo da linha digit�vel da guia
                               ,pr_lindigi4 IN  NUMBER                 -- Quarto campo da linha digit�vel da guia
                               ,pr_cdbarras IN  VARCHAR2               -- C�digo de barras da guia
                               ,pr_dsidepag IN  VARCHAR2               -- Descri��o da identifica��o do pagamento
                               ,pr_vlrtotal IN  NUMBER                 -- Valor total do pagamento da guia
                               ,pr_dsnomfon IN  VARCHAR2               -- Nome e telefone da guia
                               ,pr_dtapurac IN  DATE                   -- Per�odo de apura��o da guia
                               ,pr_nrcpfcgc IN  VARCHAR2               -- CPF/CNPJ da guia
                               ,pr_cdtribut IN  VARCHAR2               -- C�digo de tributa��o da guia
                               ,pr_nrrefere IN  NUMBER                 -- N�mero de refer�ncia da guia
                               ,pr_dtvencto IN  DATE                   -- Data de vencimento da guia
                               ,pr_vlrprinc IN  NUMBER                 -- Valor principal da guia
                               ,pr_vlrmulta IN  NUMBER                 -- Valor da multa da guia
                               ,pr_vlrjuros IN  NUMBER                 -- Valor dos juros da guia
                               ,pr_vlrecbru IN  NUMBER                 -- Valor da receita bruta acumulada da guia
                               ,pr_vlpercen IN  NUMBER                 -- Valor do percentual da guia
                               ,pr_idagenda IN  INTEGER                -- Indicador de agendamento (1 � Nesta Data / 2 � Agendamento)
                               ,pr_vlapagar IN  NUMBER                 -- Valor total dos pagamentos
                               ,pr_versaldo IN  INTEGER                -- Indicador de valida��o do saldo em rela��o ao valor total
                               ,pr_tpleitor IN  INTEGER                -- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual)
                               ,pr_xml_dsmsgerr    OUT VARCHAR2        -- Retorno XML de critica
                               ,pr_xml_operacao188 OUT CLOB            -- Retorno XML da opera��o 188
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
	
		--Tipo de registro de data
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
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
				
      -- se n�o � agendamento                
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
    
    IF pr_idefetiv = 0 THEN -- Valida��o
			IF pr_idagenda = 1 THEN 
				vr_dstransa := vr_dstransa || 'Valida pagamento ';
			ELSE 
				vr_dstransa := vr_dstransa || 'Valida agendamento de pagamento ';
			END IF;		
		ELSE -- Efetiva��o
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
      
      -- se n�o encontrar nenhum registro
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
		
		-- alimenta linha digit�vel (para log) caso tenha sido informada
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
                                  ,pr_nrcpfope     => (CASE WHEN vr_idastcjt = 1 AND pr_nrcpfope = 0 THEN nvl(vr_nrcpfcgc,0) ELSE nvl(pr_nrcpfope,0) END) --> CPF operador ou do responsavel legal quando conta exigir assinatura multipla
                                  ,pr_flgctrag     => TRUE                --> controla validacoes na efetivacao de agendamentos */
                                  ,pr_nmdatela     => 'INTERNETBANK'      --> Nome da tela/programa que esta chamando a rotina
                                  ,pr_dstransa     => vr_dstrans1         --> Descricao da transacao
                                  ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                  ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                  ,pr_cdcritic     => vr_cdcritic         --> Codigo do erro
                                  ,pr_dscritic     => vr_dscritic);       --> Descricao do erro
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
		PAGA0003.pc_verifica_darf_das( pr_cdcooper => pr_cdcooper,
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
			
		  --CPF operador PJ ou responsavel legal da conta exigir assinatura multipla
		  IF pr_nrcpfope <> 0 OR vr_idastcjt = 1 THEN
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
				
				PAGA0003.pc_paga_darf_das( pr_cdcooper => pr_cdcooper,
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
																	 pr_dsprotoc => vr_dsprotoc,
																	 pr_cdcritic => vr_cdcritic,
																	 pr_dscritic => vr_dscritic);			
												 
			  IF nvl(vr_cdcritic,0) <> 0 OR
					TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
												
			-- se for agendamento  
      ELSIF pr_idagenda = 2 THEN
				
				pc_cria_agend_darf_das( pr_cdcooper => pr_cdcooper,
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
					vr_dsmsgope := 'Pagamento registrado com sucesso. Aguardando aprova��o do registro pelos demais respons�veis.';
				--Representante SEM assinatura conjunta
				ELSE 
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
						vr_dsmsgope := 'Pagamento registrado com sucesso. Aguardando aprova��o do registro pelo preposto.';
					--titular
					ELSE
						vr_dsmsgope := 'Pagamento efetuado com sucesso.';
				  END IF;
										
				END IF;
				
			-- agendamento
			ELSE
				
				--Representante COM assinatura conjunta
				IF vr_idastcjt = 1 THEN					
					vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprova��o do registro pelos demais respons�veis.';
				--Representante SEM assinatura conjunta
				ELSE					
					--CPF operador PJ
				  IF pr_nrcpfope <> 0 THEN
						vr_dsmsgope := 'Agendamento de pagamento registrado com sucesso. Aguardando aprova��o do registro pelo preposto.';
					--titular
					ELSE
						vr_dsmsgope := 'Pagamento agendado com sucesso para o dia ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
				  END IF;
				END IF;
				
			END IF;
			
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_xml_operacao188, TRUE);
			dbms_lob.open(pr_xml_operacao188, dbms_lob.lob_readwrite);

			-- Insere o cabe�alho do XML 
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
						
		ELSE --valida��o
		
		  -- houve altera��o de data por nao ser um dia �til
		  IF vr_dtmvtopg <> pr_dtmvtopg THEN
			   vr_dsmsgope := 'O agendamento ser� registrado para d�bito em ' || to_char(vr_dtmvtopg,'DD/MM/RRRR');
			END IF;
		
			-- Montar xml de retorno dos dados
			dbms_lob.createtemporary(pr_xml_operacao188, TRUE);
			dbms_lob.open(pr_xml_operacao188, dbms_lob.lob_readwrite);

			-- Insere o cabe�alho do XML 
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
      -- se possui codigo, por�m n�o possui descri��o     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descri��o
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);          
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';       
			
			pc_proc_geracao_log(pr_flgtrans => 0 /* false */ );  
                                
    WHEN OTHERS THEN
      
      vr_dscritic := 'N�o foi possivel validar pagamento DARF/DAS. ' ||SQLERRM; 
			pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
			
			vr_dscritic := vr_dscritic || SQLERRM; 
      pr_dsretorn := 'NOK';
			
			pc_proc_geracao_log(pr_flgtrans => 0 /* false */ );
			
  END pc_InternetBank188;
  
  PROCEDURE pc_cria_agend_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial de titularidade
								  ,pr_cdagenci IN INTEGER               -- PA
								  ,pr_nrdcaixa IN NUMBER                -- Numero do Caixa
								  ,pr_cdoperad IN VARCHAR2              -- Cd Operador
                                  ,pr_nrcpfope IN NUMBER -- CPF do operador PJ
                                  ,pr_idorigem IN INTEGER -- Canal de origem da opera��o
                                  ,pr_tpdaguia IN INTEGER -- Tipo da guia (1 � DARF / 2 � DAS)
                                  ,pr_tpcaptur IN INTEGER -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
                                  ,pr_cdhistor IN INTEGER               -- Hist�rico
                                  ,pr_lindigi1 IN NUMBER -- Primeiro campo da linha digit�vel da guia
                                  ,pr_lindigi2 IN NUMBER -- Segundo campo da linha digit�vel da guia
                                  ,pr_lindigi3 IN NUMBER -- Terceiro campo da linha digit�vel da guia
                                  ,pr_lindigi4 IN NUMBER -- Quarto campo da linha digit�vel da guia
                                  ,pr_cdbarras IN VARCHAR2 -- C�digo de barras da guia
                                  ,pr_dsidepag IN VARCHAR2 -- Descri��o da identifica��o do pagamento
                                  ,pr_vlrtotal IN NUMBER -- Valor total do pagamento da guia
                                  ,pr_dsnomfon IN VARCHAR2 -- Nome e telefone da guia
                                  ,pr_dtapurac IN DATE -- Per�odo de apura��o da guia
                                  ,pr_nrcpfcgc IN VARCHAR2 -- CPF/CNPJ da guia
                                  ,pr_cdtribut IN VARCHAR2 -- C�digo de tributa��o da guia
                                  ,pr_nrrefere IN NUMBER -- N�mero de refer�ncia da guia
                                  ,pr_dtvencto IN DATE -- Data de vencimento da guia
                                  ,pr_vlrprinc IN NUMBER -- Valor principal da guia
                                  ,pr_vlrmulta IN NUMBER -- Valor da multa da guia
                                  ,pr_vlrjuros IN NUMBER -- Valor dos juros da guia
                                  ,pr_vlrecbru IN NUMBER -- Valor da receita bruta acumulada da guia
                                  ,pr_vlpercen IN NUMBER -- Valor do percentual da guia
                                  ,pr_dtagenda IN DATE -- Data de agendamento
                                  ,pr_cdtrapen IN NUMBER -- C�digo de sequencial da transa��o pendente
								  ,pr_tpleitor IN INTEGER               -- Indicador de captura atrav�s de leitora de c�digo de barras (1 � Leitora / 2 � Manual)
								,pr_dsprotoc OUT VARCHAR2 -- Protocolo
                                  ,pr_cdcritic OUT INTEGER -- C�digo do erro
                                  ,pr_dscritic OUT VARCHAR2 -- Descri�ao do erro
                                   ) IS
																	 
		rw_craplot LOTE0001.cr_craplot%ROWTYPE;
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
    -- Pessoa F�dica
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
       AND ass.inpessoa = 1 -- Pessoa F�sica

       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl
    UNION ALL
    -- Pessoa Jur�dica
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,ass.dtabtcct
          ,ass.idastcjt
          ,ass.nmprimtl nmextttl
      FROM crapass ass
     WHERE ass.inpessoa <> 1 -- Pessoa Jur�dica
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
						,crapcon.flgcnvsi
						,crapcon.cdhistor
						,crapcon.nmrescon
						,crapcon.cdsegmto
						,crapcon.cdempcon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto
				 AND crapcon.flgcnvsi = 1;
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
		
  BEGIN
	  -- Busca a data da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;	
	
		-- Descri��o do Cedente
    vr_dsidepag := NVL(trim(pr_dsidepag), CASE pr_tpdaguia
                                          WHEN 1 THEN 'DARF'
                                          WHEN 2 THEN 'DAS' END);

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
		
		-- Conv�nios Sicredi
		vr_tpdvalor := 1;
		vr_cdtransa := '';
		vr_dssigemp	:= '';
		vr_nrdolote := 11000 + pr_nrdcaixa;
		
		-- Compor linha digit�vel
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
									
			-- Verificar registro de convenio sicredi
			OPEN cr_crapscn (pr_cdempcon  => rw_crapcon.cdempcon
										  ,pr_cdsegmto  => rw_crapcon.cdsegmto);
			FETCH cr_crapscn INTO rw_crapscn;
			
			IF cr_crapscn%NOTFOUND THEN				
				CLOSE cr_crapscn; 
			  vr_dscritic := 'Convenio sicredi nao encontrado.';
				RAISE vr_exc_erro;
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
		
		-- cria��o lote 
		LOTE0001.pc_insere_lote(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => vr_nrdolote
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_tplotmov => 12
                           ,pr_cdhistor => 0
                           ,pr_craplot  => rw_craplot
                           ,pr_dscritic => vr_dscritic);
			
			-- Atualizar informa��es no lote
      BEGIN
        UPDATE craplot
           SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
               craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
               /* DEBITO */
               craplot.vlinfodb = nvl(craplot.vlinfodb,0) + pr_vlrtotal,
               craplot.vlcompdb = nvl(craplot.vlcompdb,0) + pr_vlrtotal
         WHERE craplot.rowid = rw_craplot.rowid
         RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig; 
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o craplot: '||SQLERRM;
          RAISE vr_exc_erro;  
      END;
			
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
			
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
			
			-- inser��o na craplau
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
					          ,craplau.nrcartao)
             VALUES ( pr_cdcooper               -- craplau.cdcooper
                     ,pr_nrdconta               -- craplau.nrdconta
                     ,pr_idseqttl               -- craplau.idseqttl
                     ,SYSDATE                   -- craplau.dttransa
                     ,gene0002.fn_busca_time    -- craplau.hrtransa
                     ,rw_crapdat.dtmvtocd       -- craplau.dtmvtolt
                     ,pr_cdagenci               -- craplau.cdagenci
                     ,rw_craplot.cdbccxlt       -- craplau.cdbccxlt
                     ,rw_craplot.nrdolote       -- craplau.nrdolote
                     ,rw_craplot.nrseqdig       -- craplau.nrseqdig
                     ,rw_craplot.nrseqdig       -- craplau.nrdocmto
                     ,pr_cdhistor               -- craplau.cdhistor
                     ,vr_dsorigem               -- craplau.dsorigem
                     ,1  /** PENDENTE  **/      -- craplau.insitlau
                     ,10                        -- craplau.cdtiptra
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
                     ,0)
						RETURNING craplau.idlancto,
						          craplau.dtmvtolt,
											craplau.hrtransa,
											craplau.nrdocmto,
											craplau.vllanaut
						     INTO rw_craplau.idlancto,
                      rw_craplau.dtmvtolt,
                      rw_craplau.hrtransa,
                      rw_craplau.nrdocmto,
											rw_craplau.vllanaut;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lan�amento automatico DARF/DAS: '||SQLERRM;
          RAISE vr_exc_erro; 
      END;
			

			
			-- inser��o dados detalhados DARF/DAS
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
          vr_dscritic := 'Erro ao inserir lan�amento automatico DARF/DAS: '||SQLERRM;
          RAISE vr_exc_erro; 
      END;
			
				IF pr_tpcaptur = 1 THEN -- CD BARRAS
					-- Caso o o c�digo de barras estiver vazio popula com base na linha digit�vel
					IF TRIM(pr_cdbarras) IS NULL THEN
						 --Se possuir linha digit�vel popula o c�digo de barras
						 IF TRIM(pr_lindigi1) IS NOT NULL THEN
							 vr_cdbarras := SUBSTR(to_char(pr_lindigi1, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi2, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi3, 'fm000000000000'), 1, 11) ||
															SUBSTR(to_char(pr_lindigi4, 'fm000000000000'), 1, 11);
						 END IF;
					ELSE
						vr_cdbarras := pr_cdbarras;
					END IF;
					
					-- Valida��o referente aos dias de tolerancia
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
			paga0003.pc_cria_comprovante_darf_das(pr_cdcooper => rw_crapass.cdcooper -- C�digo da cooperativa
																					 ,pr_nrdconta => rw_crapass.nrdconta -- N�mero da conta
																					 ,pr_nmextttl => rw_crapass.nmextttl -- Nome do Titular
																					 ,pr_nrcpfope => pr_nrcpfope         -- CPF do operador PJ
																					 ,pr_nrcpfpre => vr_nrcpfpre         -- N�mero pr� opera��o
                                           ,pr_nmprepos => nvl(vr_nmprepos,' ')-- Nome Preposto
																					 ,pr_tpcaptur => pr_tpcaptur         -- Tipo de captura da guia (1 � C�digo Barras / 2 � Manual)
																					 ,pr_cdtippro => vr_cdtippro         -- C�digo do tipo do comprovante
																					 ,pr_dtmvtolt => rw_craplau.dtmvtolt -- Data de movimento da autentica��o
																					 ,pr_hrautent => rw_craplau.hrtransa -- Hor�rio da autentica��o
																					 ,pr_nrdocmto => rw_craplau.nrdocmto -- N�mero do documento
																					 ,pr_nrseqaut => rw_craplau.idlancto -- Sequencial da autentica��o
																					 ,pr_nrdcaixa => pr_nrdcaixa         -- N�mero do caixa da autentica��o
																					 ,pr_nmconven => vr_dsnomcnv         -- Nome do conv�nio da guia
																					 ,pr_lindigi1 => pr_lindigi1         -- Primeiro campo da linha digit�vel da guia
																					 ,pr_lindigi2 => pr_lindigi2         -- Segundo campo da linha digit�vel da guia
																					 ,pr_lindigi3 => pr_lindigi3         -- Terceiro campo da linha digit�vel da guia
																					 ,pr_lindigi4 => pr_lindigi4         -- Quarto campo da linha digit�vel da guia
																					 ,pr_cdbarras => pr_cdbarras         -- C�digo de barras da guia
																					 ,pr_dsidepag => vr_dsidepag         -- Descri��o da identifica��o do pagamento
																					 ,pr_vlrtotal => rw_craplau.vllanaut -- Valor total do pagamento da guia
																					 ,pr_dsnomfon => pr_dsnomfon         -- Nome e telefone da guia
																					 ,pr_dtapurac => pr_dtapurac         -- Per�odo de apura��o da guia
																					 ,pr_nrcpfcgc => pr_nrcpfcgc         -- CPF/CNPJ da guia
																					 ,pr_cdtribut => pr_cdtribut         -- C�digo de tributa��o da guia
																					 ,pr_nrrefere => pr_nrrefere         -- N�mero de refer�ncia da guia
																					 ,pr_dtvencto => vr_dtvencto         -- Data de vencimento da guia
																					 ,pr_vlrprinc => pr_vlrprinc         -- Valor principal da guia
																					 ,pr_vlrmulta => pr_vlrmulta         -- Valor da multa da guia
																					 ,pr_vlrjuros => pr_vlrjuros         -- Valor dos juros da guia
																					 ,pr_vlrecbru => pr_vlrecbru         -- Valor da receita bruta acumulada da guia
																					 ,pr_vlpercen => pr_vlpercen         -- Valor do percentual da guia
																					 ,pr_flgagend => vr_flgagend         -- Indicador de agendamento (TRUE � Agendamento / FALSE � Nesta Data)
																					 ,pr_cdtransa => vr_cdtransa         -- C�digo da transa��o por meio de arrecada��o do SICREDI
																					 ,pr_dssigemp => vr_dssigemp         -- Descri��o resumida de conv�nio DARF para autentica��o modelo SICREDI
																					 ,pr_dsprotoc => vr_dsprotoc         -- Descri��o do protocolo do comprovante
																					 ,pr_cdcritic => vr_cdcritic         -- C�digo do erro
																					 ,pr_dscritic => vr_dscritic         -- Descri�ao do erro
																					 );	    
			--Se ocorreu erro
			IF nvl(vr_cdcritic,0) > 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
						
			pr_dsprotoc := vr_dsprotoc;
						
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PAGA0003.pc_cria_agend_darf_das. ' ||SQLERRM;
			
  END pc_cria_agend_darf_das;
  
  /* Procedimento do internetbank opera��o 187 - Consulta de Horario Limite DARF/DAS */
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
                              ,pr_flmobile IN INTEGER                    -- Indicador se origem � do Mobile
                              ,pr_xml_dsmsgerr    OUT VARCHAR2           -- Retorno XML de critica
                              ,pr_xml_operacao187 OUT CLOB               -- Retorno XML da opera��o 187
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
  BEGIN

    vr_vllanmto := pr_vllanmto;

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
                                      ,pr_tpoperac => pr_tpoperac 
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
    
    pr_xml_operacao187 := vr_tab_limite;
    pr_dsretorn := 'OK';
		
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- se possui codigo, por�m n�o possui descri��o     
      IF nvl(vr_cdcritic,0) > 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descri��o
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
  
  PROCEDURE pc_busca_agend_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE                --> C�digo da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE                --> C�digo do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE                --> N�mero da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                   ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                   ,pr_cdcritic OUT INTEGER                             --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2                            --> Descri��o da cr�tica
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
  
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_saida EXCEPTION;
            
      -- Declara��o da tabela que conter� os dados de DARF/DAS
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
      
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      -- Para cada registro de DARF/DAS
      FOR rw_darfdas IN cr_darfdas(pr_idlancto => pr_idlancto) LOOP      

        -- Buscar qual a quantidade atual de registros na tabela para posicionar na pr�xima
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

      -- Alimenta par�metro com a PL/Table gerada
      pr_tab_agend_darf_das := vr_tab_agend_darf_das;
            
    EXCEPTION
      WHEN vr_exc_saida THEN
        
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com as cr�ticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na PAGA0003.pc_busca_agend_darf_das: ' || SQLERRM;
    END;
  END pc_busca_agend_darf_das;

  PROCEDURE pc_busca_agend_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE                --> C�digo da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                --> C�digo do Operador
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                --> Nome da Tela
                                        ,pr_idorigem IN INTEGER                              --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE                --> N�mero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                --> Titular da Conta
                                        ,pr_idlancto IN tbpagto_agend_darf_das.idlancto%TYPE --> Codigo do Lancamento de Agendamento
                                        ,pr_clobxmlc OUT CLOB                                --> XML com informa��es de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                         --> C�digo da cr�tica
                                        ,pr_dscritic OUT VARCHAR2) IS                        --> Descri��o da cr�tica

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

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declara��o da tabela que conter� os dados de DARF/DAS
      vr_tab_agend_darf_das PAGA0003.typ_tab_agend_darf_das;
      vr_ind_agend_darf_das PLS_INTEGER := 0;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
      -- Procedure para buscar informa��es da aplica��o
      PAGA0003.pc_busca_agend_darf_das(pr_cdcooper => pr_cdcooper                 --> C�digo da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad                       --> C�digo do Operador
                                      ,pr_nmdatela => pr_nmdatela                       --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem                       --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                      ,pr_nrdconta => pr_nrdconta                       --> N�mero da Conta
                                      ,pr_idseqttl => pr_idseqttl                       --> Titular da Conta     
                                      ,pr_idlancto => pr_idlancto                       --> Codigo da Transacao                             
                                      ,pr_cdcritic => vr_cdcritic                       --> C�digo da cr�tica
                                      ,pr_dscritic => vr_dscritic                       --> Descri��o da cr�tica
                                      ,pr_tab_agend_darf_das => vr_tab_agend_darf_das); --> Tabela com os dados de agendamento DARF/DAS
                                          
      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

      -- Insere o cabe�alho do XML 
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
  
END paga0003;
/
