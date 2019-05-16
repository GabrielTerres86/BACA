CREATE OR REPLACE PACKAGE CECRED.cobr_f8n AS

	PROCEDURE pc_busca_config_nome_blt_f8n(pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
										  ,pr_nrdconta IN crapass.nrdconta%TYPE -- nr da conta
										  ,pr_clobxmlc OUT CLOB                 -- XML com informações
										  ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
										  ,pr_dscritic OUT VARCHAR2);           -- Descrição da crítica  IS

    PROCEDURE pc_calc_linha_digitavel_f8n(pr_cdbarras IN  VARCHAR2
										 ,pr_lindigit OUT VARCHAR2);

	PROCEDURE pc_registra_tit_cip_online_f8n (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
	    								 ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
										 ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
										 ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
										 ) ;

    PROCEDURE pc_busca_emails_pagador_f8n (pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                          ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE
										  ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
										  ,pr_dsdemail  OUT VARCHAR2
										  ,pr_des_erro  OUT VARCHAR2
										  ,pr_dscritic  OUT VARCHAR2);

    PROCEDURE pc_busca_nome_imp_blt_f8n (pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
										,pr_nrdconta IN crapass.nrdconta%TYPE -- Nr da conta
										,pr_idseqttl IN crapttl.idseqttl%TYPE -- Seq do Titular
										,pr_nmprimtl OUT VARCHAR2             -- Nome do cooperado será impresso no boleto
										,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
										,pr_dscritic OUT VARCHAR2);           -- Descrição da crí

	PROCEDURE pc_calc_codigo_barras_f8n (pr_dtvencto IN DATE
 									    ,pr_cdbandoc IN INTEGER
									    ,pr_vltitulo IN crapcob.vltitulo%TYPE
									    ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
									    ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
									    ,pr_nrdconta IN crapcob.nrdconta%TYPE
									    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
									    ,pr_cdcartei IN crapcob.cdcartei%TYPE
									    ,pr_cdbarras OUT VARCHAR2);

	PROCEDURE pc_grava_config_nome_blt_f8n (pr_cdcooper  IN crapass.cdcooper%TYPE  -- Cód. cooperativa
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- nr da conta
									       ,pr_tpnome_emissao IN tbcobran_config_boleto.tpnome_emissao%TYPE -- Nome na Emissao do Boleto (1-Nome Razao/ 2-Nome Fantasia)
                                           ,pr_des_erro  OUT VARCHAR2 -- Indicador erro OK/NOK
									       ,pr_dscritic  OUT VARCHAR2);

	/* Procedure para verificar vencimento titulo */
	PROCEDURE pc_verifica_venc_titulo_f8n (pr_cod_cooper      IN INTEGER  --Codigo Cooperativa
                                          ,pr_dt_agendamento  IN DATE     --Data Agendamento
                                          ,pr_dt_vencto       IN DATE     --Data Vencimento
                                          ,pr_critica_data    OUT INTEGER --Critica na validacao
                                          ,pr_cdcritic        OUT INTEGER --Codigo da Critica
                                          ,pr_dscritic        OUT VARCHAR2);

	PROCEDURE pc_retorna_vlr_tit_vencto_f8n (pr_cdcooper      IN INTEGER    -- Cooperativa
										,pr_nrdconta      IN INTEGER    -- Conta
										,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
										,pr_vlfatura      OUT NUMBER    -- Valor da fatura
										,pr_vlrjuros      OUT NUMBER    -- Valor dos juros
										,pr_vlrmulta      OUT NUMBER    -- Valor da multa
										,pr_fltitven      OUT NUMBER    -- Indicador Vencido
										,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
										,pr_dscritic      OUT VARCHAR2);

	PROCEDURE pc_verifica_sacado_DDA_f8n(pr_tppessoa IN VARCHAR2               -- Tipo de pessoa
                                  ,pr_nrcpfcgc IN NUMBER                 -- Cpf ou CNPJ
                                  ,pr_flgsacad OUT INTEGER               -- Indicador se foi sacado
                                  ,pr_dscritic OUT VARCHAR2);            -- Descricao de Erro


    PROCEDURE pc_prep_retorno_cooper_90_f8n (pr_idregcob IN ROWID   --ROWID da cobranca
										  ,pr_cdmotivo IN VARCHAR --Descricao Motivo
										  ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --Banco Centralizador
										  ,pr_cdagectl IN crapcop.cdagectl%TYPE --Agencia Centralizadora
										  ,pr_dtmvtolt IN DATE     --Data Movimento
										  ,pr_cdcritic OUT INTEGER --Codigo Critica
										  ,pr_dscritic OUT VARCHAR2); --Descricao Critica

	 PROCEDURE pc_val_dsnegufds_parprt_f8n(pr_cdcooper    IN NUMBER
											  ,pr_cdufsaca    IN VARCHAR2
											  ,pr_des_erro    OUT VARCHAR2
											  ,pr_dscritic    OUT VARCHAR2);

	 PROCEDURE pc_consulta_periodo_parprt_f8n (pr_cdcooper                 IN NUMBER
									   ,pr_qtlimitemin_tolerancia  OUT INTEGER
									   ,pr_qtlimitemax_tolerancia  OUT INTEGER
									   ,pr_des_erro                OUT VARCHAR2
									   ,pr_dscritic                OUT VARCHAR2);

    -- Carregar os dados para o boleto, chamando a rotina oracle apenas 1 vez
    PROCEDURE pc_carrega_dados_boleto(pr_cdcooper   IN NUMBER
                                     ,pr_nrdconta   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_dtvencto   IN DATE
                                     ,pr_cdbandoc   IN NUMBER
                                     ,pr_vltitulo   IN NUMBER
                                     ,pr_nrcnvcob   IN NUMBER
                                     ,pr_nrcnvceb   IN NUMBER
                                     ,pr_nrdocmto   IN NUMBER
                                     ,pr_cdcartei   IN NUMBER
                                     ,pr_nrcpfcgc   IN NUMBER
                                     ,pr_vlrjuros  OUT NUMBER 
                                     ,pr_vlrmulta  OUT NUMBER 
                                     ,pr_vltitatu  OUT NUMBER 
                                     ,pr_cdbarras  OUT VARCHAR2
                                     ,pr_dslindig  OUT VARCHAR2
                                     ,pr_dsdemail  OUT XMLTYPE
                                     ,pr_dsendere  OUT XMLTYPE
                                     ,pr_cdcritic  OUT NUMBER
                                     ,pr_dscritic  OUT VARCHAR2 );

    -- Executar as rotinas de finalização dos passos para geração de um boleto
    PROCEDURE pc_finaliza_geracao_boleto(pr_cdcooper   IN NUMBER
                                        ,pr_nrdconta   IN NUMBER
                                        ,pr_nrdocmto   IN NUMBER
                                        ,pr_nrcnvcob   IN NUMBER
                                        ,pr_cdmotret   IN VARCHAR2
                                        ,pr_dslogtit   IN VARCHAR2
                                        ,pr_insitdda   IN NUMBER -- Situação do processo DDA
                                        ,pr_inregcip   IN NUMBER -- Indicador de registro na CIP
                                        ,pr_infrmems   IN NUMBER -- Indica a forma de emissão
                                        ,pr_cdcritic  OUT NUMBER
                                        ,pr_dscritic  OUT VARCHAR2 );

END cobr_f8n;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cobr_f8n AS


  PROCEDURE pc_busca_config_nome_blt_f8n (pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
										,pr_nrdconta IN crapass.nrdconta%TYPE -- nr da conta
										,pr_clobxmlc OUT CLOB                 -- XML com informações
										,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
										,pr_dscritic OUT VARCHAR2) IS         -- Descrição da crítica

  BEGIN

	  CECRED.COBR0009.pc_busca_config_nome_blt(pr_cdcooper,pr_nrdconta,pr_clobxmlc,pr_des_erro,pr_dscritic);

  END pc_busca_config_nome_blt_f8n;



  PROCEDURE pc_calc_linha_digitavel_f8n (pr_cdbarras IN  VARCHAR2
									   ,pr_lindigit OUT VARCHAR2) IS
  BEGIN

	  CECRED.COBR0005.pc_calc_linha_digitavel(pr_cdbarras, pr_lindigit);

  END pc_calc_linha_digitavel_f8n;

  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_registra_tit_cip_online_f8n (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
										   ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
										   ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
										   ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
										   ) IS
  BEGIN
	  CECRED.NPCB0002.pc_registra_tit_cip_online(pr_cdcooper, pr_nrdconta, pr_cdcritic, pr_dscritic);

  END pc_registra_tit_cip_online_f8n;

  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_busca_emails_pagador_f8n  (pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                        ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE
										,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
										,pr_dsdemail  OUT VARCHAR2
										,pr_des_erro  OUT VARCHAR2
										,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
	  CECRED.COBR0009.pc_busca_emails_pagador(pr_cdcooper, pr_nrdconta, pr_nrinssac, pr_dsdemail, pr_des_erro, pr_dscritic);

  END pc_busca_emails_pagador_f8n;

  PROCEDURE pc_busca_nome_imp_blt_f8n (pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
									 ,pr_nrdconta IN crapass.nrdconta%TYPE -- Nr da conta
									 ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Seq do Titular
									 ,pr_nmprimtl OUT VARCHAR2             -- Nome do cooperado será impresso no boleto
									 ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
									 ,pr_dscritic OUT VARCHAR2) IS           -- Descrição da crí
  BEGIN
    CECRED.COBR0009.pc_busca_nome_imp_blt(pr_cdcooper, pr_nrdconta, pr_idseqttl, pr_nmprimtl, pr_des_erro, pr_dscritic);

  END pc_busca_nome_imp_blt_f8n;

  PROCEDURE pc_calc_codigo_barras_f8n (pr_dtvencto IN DATE
 									    ,pr_cdbandoc IN INTEGER
									    ,pr_vltitulo IN crapcob.vltitulo%TYPE
									    ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
									    ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
									    ,pr_nrdconta IN crapcob.nrdconta%TYPE
									    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
									    ,pr_cdcartei IN crapcob.cdcartei%TYPE
									    ,pr_cdbarras OUT VARCHAR2) IS


	BEGIN
    CECRED.COBR0005.pc_calc_codigo_barras(pr_dtvencto, pr_cdbandoc, pr_vltitulo, pr_nrcnvcob, pr_nrcnvceb, pr_nrdconta, pr_nrdocmto, pr_cdcartei, pr_cdbarras);

  END pc_calc_codigo_barras_f8n;

  PROCEDURE pc_grava_config_nome_blt_f8n (pr_cdcooper       IN crapass.cdcooper%TYPE                      -- Cód. cooperativa
                                         ,pr_nrdconta       IN crapass.nrdconta%TYPE                      -- nr da conta
									     ,pr_tpnome_emissao IN tbcobran_config_boleto.tpnome_emissao%TYPE -- Nome na Emissao do Boleto (1-Nome Razao/ 2-Nome Fantasia)
                                         ,pr_des_erro       OUT VARCHAR2                                  -- Indicador erro OK/NOK
									     ,pr_dscritic       OUT VARCHAR2) IS

  BEGIN
    CECRED.COBR0009.pc_grava_config_nome_blt(pr_cdcooper, pr_nrdconta, pr_tpnome_emissao, pr_des_erro, pr_dscritic);
  END pc_grava_config_nome_blt_f8n;

  /* Procedure para verificar vencimento titulo */
  PROCEDURE pc_verifica_venc_titulo_f8n (pr_cod_cooper      IN INTEGER  --Codigo Cooperativa
                                          ,pr_dt_agendamento  IN DATE     --Data Agendamento
                                          ,pr_dt_vencto       IN DATE     --Data Vencimento
                                          ,pr_critica_data    OUT INTEGER --Critica na validacao
                                          ,pr_cdcritic        OUT INTEGER --Codigo da Critica
                                          ,pr_dscritic        OUT VARCHAR2) IS

   retorno_table GENE0001.typ_tab_erro;
   critica_data boolean;
  BEGIN

    critica_data := true;
    if (pr_critica_data = 0) then
     critica_data := false;
    end if;

    CECRED.cxon0014.pc_verifica_vencimento_titulo(pr_cod_cooper, 90, pr_dt_agendamento, pr_dt_vencto, critica_data, pr_cdcritic, pr_dscritic, retorno_table);

    if (critica_data) then
      pr_critica_data := 1;
    else
      pr_critica_data := 0;
    end if;


  END pc_verifica_venc_titulo_f8n;

  PROCEDURE pc_retorna_vlr_tit_vencto_f8n (pr_cdcooper      IN INTEGER    -- Cooperativa
 										,pr_nrdconta      IN INTEGER    -- Conta
										,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
										,pr_vlfatura      OUT NUMBER    -- Valor da fatura
										,pr_vlrjuros      OUT NUMBER    -- Valor dos juros
										,pr_vlrmulta      OUT NUMBER    -- Valor da multa
										,pr_fltitven      OUT NUMBER    -- Indicador Vencido
										,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
										,pr_dscritic      OUT VARCHAR2) IS
  BEGIN
    --Está sendo passado valores zeros devido não ser necessário para o cálculo do juros.
	  CECRED.cxon0014.pc_retorna_vlr_tit_vencto(pr_cdcooper, pr_nrdconta, 0, 90, 900, 0, 0, 0, 0, 0, pr_codigo_barras, pr_vlfatura, pr_vlrjuros, pr_vlrmulta, pr_fltitven, pr_des_erro, pr_dscritic);
  END pc_retorna_vlr_tit_vencto_f8n;

  PROCEDURE pc_verifica_sacado_DDA_f8n(pr_tppessoa IN VARCHAR2,               -- Tipo de pessoa
                                   pr_nrcpfcgc IN NUMBER,                 -- Cpf ou CNPJ
                                   pr_flgsacad OUT INTEGER,               -- Indicador se foi sacado
                                   pr_dscritic OUT VARCHAR2) IS
  pr_cdcritic crapcri.cdcritic%TYPE;
  BEGIN
	CECRED.DDDA0001.pc_verifica_sacado_DDA(pr_tppessoa,pr_nrcpfcgc,pr_flgsacad,pr_cdcritic,pr_dscritic);
  END pc_verifica_sacado_DDA_f8n;

     -- Procedure que prepara retorno para cooperado
  PROCEDURE pc_prep_retorno_cooper_90_f8n (pr_idregcob IN ROWID   --ROWID da cobranca
										  ,pr_cdmotivo IN VARCHAR --Descricao Motivo
										  ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --Banco Centralizador
										  ,pr_cdagectl IN crapcop.cdagectl%TYPE --Agencia Centralizadora
										  ,pr_dtmvtolt IN DATE     --Data Movimento
										  ,pr_cdcritic OUT INTEGER --Codigo Critica
										  ,pr_dscritic OUT VARCHAR2) IS --Descricao Critica
	BEGIN
		CECRED.COBR0006.pc_prep_retorno_cooper_90(pr_idregcob,2,pr_cdmotivo,0,pr_cdbcoctl,pr_cdagectl,pr_dtmvtolt,996,0,NULL,pr_cdcritic,pr_dscritic);
	END pc_prep_retorno_cooper_90_f8n;


 PROCEDURE pc_val_dsnegufds_parprt_f8n (pr_cdcooper                IN NUMBER
										,pr_cdufsaca                IN VARCHAR2
										,pr_des_erro                OUT VARCHAR2
										,pr_dscritic                OUT VARCHAR2) IS
  BEGIN
    CECRED.TELA_PARPRT.pc_validar_dsnegufds_parprt(pr_cdcooper,pr_cdufsaca,pr_des_erro,pr_dscritic);
  END pc_val_dsnegufds_parprt_f8n;

  PROCEDURE pc_consulta_periodo_parprt_f8n (pr_cdcooper                 IN NUMBER
										,pr_qtlimitemin_tolerancia  OUT INTEGER
										,pr_qtlimitemax_tolerancia  OUT INTEGER
										,pr_des_erro                OUT VARCHAR2
										,pr_dscritic                OUT VARCHAR2) IS

   BEGIN
	CECRED.TELA_PARPRT.pc_consulta_periodo_parprt(pr_cdcooper,pr_qtlimitemin_tolerancia,pr_qtlimitemax_tolerancia,pr_des_erro,pr_dscritic);
   END pc_consulta_periodo_parprt_f8n;

  -- Carregar os dados para o boleto, chamando a rotina oracle apenas 1 vez
  PROCEDURE pc_carrega_dados_boleto(pr_cdcooper   IN NUMBER
                                   ,pr_nrdconta   IN NUMBER
                                   ,pr_dtmvtolt   IN DATE
                                   ,pr_dtvencto   IN DATE
                                   ,pr_cdbandoc   IN NUMBER
                                   ,pr_vltitulo   IN NUMBER
                                   ,pr_nrcnvcob   IN NUMBER
                                   ,pr_nrcnvceb   IN NUMBER
                                   ,pr_nrdocmto   IN NUMBER
                                   ,pr_cdcartei   IN NUMBER
                                   ,pr_nrcpfcgc   IN NUMBER
                                   ,pr_vlrjuros  OUT NUMBER 
                                   ,pr_vlrmulta  OUT NUMBER 
                                   ,pr_vltitatu  OUT NUMBER 
                                   ,pr_cdbarras  OUT VARCHAR2
                                   ,pr_dslindig  OUT VARCHAR2
                                   ,pr_dsdemail  OUT XMLTYPE
                                   ,pr_dsendere  OUT XMLTYPE
                                   ,pr_cdcritic  OUT NUMBER
                                   ,pr_dscritic  OUT VARCHAR2 ) IS
   
    -- Variáveis
    vr_exc_erro    EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(2000);
    vr_des_erro    VARCHAR2(10);
    vr_idbltvcd    NUMBER; 
    vr_cdbarras    VARCHAR2(100);
    vr_dslindig    VARCHAR2(100);
    vr_vlfatura    NUMBER; 
    vr_vlrjuros    NUMBER := 0; 
    vr_vlrmulta    NUMBER := 0; 
    vr_fltitven    NUMBER; 
    vr_idpessoa    NUMBER; 
    vr_dsdemail    XMLTYPE;
    vr_dsendere    XMLTYPE;
  
  BEGIN
    
    BEGIN
      -- Calcular o código de barras do boleto    
      pc_calc_codigo_barras_f8n (pr_dtvencto => pr_dtvencto
 		           							    ,pr_cdbandoc => pr_cdbandoc
                                ,pr_vltitulo => pr_vltitulo
                                ,pr_nrcnvcob => pr_nrcnvcob
                                ,pr_nrcnvceb => pr_nrcnvceb
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdocmto => pr_nrdocmto
                                ,pr_cdcartei => pr_cdcartei
                                ,pr_cdbarras => vr_cdbarras);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao calcular codigo de barra para o titulo: '||pr_nrdocmto;
        RAISE vr_exc_erro;
    END;
    
    
    BEGIN
      -- Calcular a linha digitavel
      pc_calc_linha_digitavel_f8n (pr_cdbarras => vr_cdbarras
		  							              ,pr_lindigit => vr_dslindig);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao calcular linha digitavel do titulo: '||pr_nrdocmto;
        RAISE vr_exc_erro;
    END;
  
  
    -- Verificar o vencimento do boleto
    pc_verifica_venc_titulo_f8n (pr_cod_cooper      => pr_cdcooper
                                ,pr_dt_agendamento  => pr_dtmvtolt
                                ,pr_dt_vencto       => pr_dtvencto
                                ,pr_critica_data    => vr_idbltvcd
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
    
    -- Se retornar erro
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
              
     
    -- Se o boleto estiver vencido
    IF NVL(vr_idbltvcd,0) = 1 THEN
      -- Calcula valor do vencimento do título
      pc_retorna_vlr_tit_vencto_f8n (pr_cdcooper      => pr_cdcooper
 										                ,pr_nrdconta      => pr_nrdconta
                                    ,pr_codigo_barras => vr_cdbarras
                                    ,pr_vlfatura      => vr_vlfatura
                                    ,pr_vlrjuros      => vr_vlrjuros
                                    ,pr_vlrmulta      => vr_vlrmulta
                                    ,pr_fltitven      => vr_fltitven
                                    ,pr_des_erro      => vr_des_erro
                                    ,pr_dscritic      => vr_dscritic);
    
      -- Se encontrar erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    ELSE
      -- Retorna o valor do titulo recebido
      vr_vlfatura := pr_vltitulo;  
      vr_vlrjuros := 0;
      vr_vlrmulta := 0; 
    END IF;
    
    -- Buscar o id da pessoa                       
    CADA_F8N.pc_retorna_IdPessoa_f8n(pr_nrcpfcgc => pr_nrcpfcgc
                                    ,pr_idpessoa => vr_idpessoa
                                    ,pr_dscritic => vr_dscritic);
    
    -- Se retornar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar o e-mail da pessoa
    CADA_F8N.pc_retorna_pessoa_email_f8n(pr_idpessoa => vr_idpessoa
                                        ,pr_retorno  => vr_dsdemail
                                        ,pr_dscritic => vr_cdcritic);
    
    -- Se retornar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar o endereço da pessoa
    CADA_F8N.pc_retorna_pessoa_endereco_f8n(pr_idpessoa => vr_idpessoa 
                                           ,pr_retorno  => vr_dsendere
                                           ,pr_dscritic => vr_cdcritic);
  
    -- Se retornar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    -- Retornar parametros
    pr_vltitatu := vr_vlfatura;
    pr_cdbarras := vr_cdbarras;
    pr_dslindig := vr_dslindig;
    pr_vlrjuros := vr_vlrjuros;
    pr_vlrmulta := vr_vlrmulta;
    pr_dsdemail := vr_dsdemail;
    pr_dsendere := vr_dsendere;
   
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se receber apenas o código da crítica
      IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      
      -- Retornar as criticas
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
       -- Retornar as criticas
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao carregar dados.';
  END pc_carrega_dados_boleto;
  
  -- Executar as rotinas de finalização dos passos para geração de um boleto
  PROCEDURE pc_finaliza_geracao_boleto(pr_cdcooper   IN NUMBER
                                      ,pr_nrdconta   IN NUMBER
                                      ,pr_nrdocmto   IN NUMBER
                                      ,pr_nrcnvcob   IN NUMBER
                                      ,pr_cdmotret   IN VARCHAR2
                                      ,pr_dslogtit   IN VARCHAR2
                                      ,pr_insitdda   IN NUMBER -- Situação do processo DDA
                                      ,pr_inregcip   IN NUMBER -- Indicador de registro na CIP
                                      ,pr_infrmems   IN NUMBER -- Indica a forma de emissão
                                      ,pr_cdcritic  OUT NUMBER
                                      ,pr_dscritic  OUT VARCHAR2 ) IS
  
    -- Cursores
    -- Buscar dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.cdbcoctl
           , cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rg_crapcop   cr_crapcop%ROWTYPE;
    
    -- Buscar parametros de cobrança
    CURSOR cr_crapcco IS
      SELECT cco.cdagenci
           , cco.cdbccxlt
           , cco.nrdolote
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrcnvcob;
    rg_crapcco   cr_crapcco%ROWTYPE;
    
    -- Buscar os dados dos cooperado
    CURSOR cr_crapass IS
      SELECT ass.nrdctitg
           , ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rg_crapass    cr_crapass%ROWTYPE;
    
    -- Buscar os Rowid do boleto
    CURSOR cr_crapcob IS
      SELECT ROWID dsdrowid
        FROM crapcob c 
       WHERE c.cdcooper = pr_cdcooper 
         AND c.nrcnvcob = pr_nrcnvcob 
         AND c.nrdconta = pr_nrdconta 
         AND c.nrdocmto = pr_nrdocmto;
    
    -- Variáveis
    vr_exc_erro    EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(2000);
    vr_cdmotivo    VARCHAR2(10);
    vr_cdhistor    NUMBER;
    vr_cdhisest    NUMBER;
    vr_vltarifa    NUMBER;
    vr_dtdivulg    DATE;
    vr_dtvigenc    DATE;
    vr_cdfvlcop    NUMBER;
    vr_dsridlat    VARCHAR2(50);
    vr_tab_erro    GENE0001.typ_tab_erro;
    vr_dsdrowid    VARCHAR2(50);
    
  BEGIN
  
    -- Buscar dados da cooperativa
    OPEN  cr_crapcop;
    FETCH cr_crapcop INTO rg_crapcop;
    -- Se não encontrar a cooperativa informada
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      
      vr_dscritic := 'Cooperativa informada nao encontrada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- fechar o cursor
    CLOSE cr_crapcop;
  
    -- Buscar a data do sistema
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar
    CLOSE btch0001.cr_crapdat;
    
    -- Busca o rowid do boleto
    OPEN  cr_crapcob;
    FETCH cr_crapcob INTO vr_dsdrowid;
    -- Se não encontrar o boleto
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      
      vr_dscritic := 'Boleto nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    -- Gerar registro de controle de retorno
    pc_prep_retorno_cooper_90_f8n(pr_idregcob => vr_dsdrowid
                                 ,pr_cdmotivo => pr_cdmotret
                                 ,pr_cdbcoctl => rg_crapcop.cdbcoctl
                                 ,pr_cdagectl => rg_crapcop.cdagectl
                                 ,pr_dtmvtolt => btch0001.rw_crapdat.dtmvtolt
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
    
    -- Se retornar erro
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Verificar se o boleto deve ser registrado eletronicamente
    IF pr_inregcip = 1 THEN
      -- Registrar os boletos do cooperado na CIP    
      pc_registra_tit_cip_online_f8n (pr_cdcooper => pr_cdcooper 
		  								               ,pr_nrdconta => pr_nrdconta
			  							               ,pr_cdcritic => vr_cdcritic
				  						               ,pr_dscritic => vr_dscritic);
    
      -- Se retornar erro
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    END IF;
    
    BEGIN
      -- Insere o registro de log do boleto
      INSERT INTO crapcol(cdcooper
                         ,nrdconta
                         ,nrdocmto
                         ,nrcnvcob
                         ,dslogtit
                         ,cdoperad
                         ,dtaltera
                         ,hrtransa)
                  VALUES (pr_cdcooper                 -- cdcooper
                         ,pr_nrdconta                 -- nrdconta
                         ,pr_nrdocmto                 -- nrdocmto
                         ,pr_nrcnvcob                 -- nrcnvcob
                         ,pr_dslogtit                 -- dslogtit
                         ,'996'                       -- cdoperad
                         ,TRUNC(SYSDATE)              -- dtaltera
                         ,gene0002.fn_busca_time() ); -- hrtransa
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir logs do boleto gerado.';
        RAISE vr_exc_erro;
    END;
    
    -- Buscar os parametros de cobrança
    OPEN  cr_crapcco;
    FETCH cr_crapcco INTO rg_crapcco;
    
    -- Se não encontrar convenio
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      
      vr_dscritic := 'Nao foi possivel localizar o convenio de cobranca.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapcco;
    
    -- Buscar os dados do cooperado
    OPEN  cr_crapass;
    FETCH cr_crapass INTO rg_crapass;
    
    -- Se não encontrar o beneficiario
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      
      vr_dscritic := 'Nao foi possivel localizar o beneficiario.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o cursor 
    CLOSE cr_crapass;
    
    -- Limpar a variável
    vr_cdmotivo := ' ';
    
    -- Verificar o motivo 
    IF rg_crapass.inpessoa IN (1,2) THEN
      -- Se for um sacado DDA
      IF pr_insitdda = 1 THEN
        vr_cdmotivo := vr_cdmotivo||'A4';
      END IF;
      
      -- Se o registro do titulo é online
      IF pr_inregcip = 1 THEN
        vr_cdmotivo := vr_cdmotivo||'R1';
      END IF;
      
      -- Se a forma de emissão é COOPERATIVA EMITE-EXPEDE
      IF pr_infrmems = 3 THEN
        vr_cdmotivo := vr_cdmotivo||'P1';
      END IF;
      
    END IF;
    
    -- Remove o espaço ou recebe null
    vr_cdmotivo := TRIM(vr_cdmotivo);
    
    -- Carregar dados da tarifa (conforme chamada da B1wnet0001 - gravar-boleto)
    TARI0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconven => pr_nrcnvcob
                                         ,pr_dsincide => 'RET'
                                         ,pr_cdocorre => 2
                                         ,pr_cdmotivo => vr_cdmotivo
                                         ,pr_inpessoa => rg_crapass.inpessoa
                                         ,pr_vllanmto => 1 
                                         ,pr_cdprogra => NULL
                                         ,pr_flaputar => 1
                                         ,pr_cdhistor => vr_cdhistor 
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                         
    -- Se retornar erro
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Gerar o lançamento de tarifa
    TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                    ,pr_nrdconta      => pr_nrdconta
                                    ,pr_dtmvtolt      => btch0001.rw_crapdat.dtmvtolt
                                    ,pr_cdhistor      => vr_cdhistor
                                    ,pr_vllanaut      => vr_vltarifa
                                    ,pr_cdoperad      => '996'
                                    ,pr_cdagenci      => rg_crapcco.cdagenci
                                    ,pr_cdbccxlt      => rg_crapcco.cdbccxlt
                                    ,pr_nrdolote      => rg_crapcco.nrdolote
                                    ,pr_tpdolote      => 1
                                    ,pr_nrdocmto      => 0
                                    ,pr_nrdctabb      => pr_nrdconta
                                    ,pr_nrdctitg      => rg_crapass.nrdctitg
                                    ,pr_cdpesqbb      => NULL
                                    ,pr_cdbanchq      => 0
                                    ,pr_cdagechq      => 0
                                    ,pr_nrctachq      => 0
                                    ,pr_flgaviso      => FALSE
                                    ,pr_tpdaviso      => 0
                                    ,pr_cdfvlcop      => vr_cdfvlcop
                                    ,pr_inproces      => 0
                                    ,pr_rowid_craplat => vr_dsridlat
                                    ,pr_tab_erro      => vr_tab_erro
                                    ,pr_cdcritic      => vr_cdcritic
                                    ,pr_dscritic      => vr_dscritic);
    
    -- Se retornar erro
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se receber apenas o código da crítica
      IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      
      -- Retornar as criticas
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
       -- Retornar as criticas
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao finalizar geracao do boleto: '||SQLERRM;
  END pc_finaliza_geracao_boleto;

END cobr_f8n;
/
