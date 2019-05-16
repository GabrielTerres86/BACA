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

END cobr_f8n;
/
