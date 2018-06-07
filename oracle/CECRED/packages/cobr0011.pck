create or replace package cecred.cobr0011 is
/*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cobr0011
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Supero
  --  Data     : Mar�o/2018.                   Ultima atualiza��o: 
  --
  -- Dados referentes ao programa:
  --
  -- Freq��ncia: Sempre que chamado
  -- Objetivo  : Procedimentos para Retorno Instru��es banc�rias - Cecred/IEPTB
  --
  -- Altera��es: 
  --
---------------------------------------------------------------------------------------------------------------*/
  
  -- Public type declarations
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
									 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
									 ,pr_cdagenci IN craplot.cdagenci%TYPE
									 ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
									 ,pr_nrdolote IN craplot.nrdolote%TYPE
									 ) IS
		SELECT craplot.nrdolote
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
					,craplot.rowid
			FROM craplot
		 WHERE craplot.cdcooper = pr_cdcooper
			 AND craplot.dtmvtolt = pr_dtmvtolt
			 AND craplot.cdagenci = pr_cdagenci
			 AND craplot.cdbccxlt = pr_cdbccxlt
			 AND craplot.nrdolote = pr_nrdolote;		 
  -- Public variable declarations

  -- Public function and procedure declarations
  
  -- Gera o nome do arquivo da remessa
  FUNCTION fn_gera_nome_arquivo_remessa(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2;
  
  -- Gera o nome do arquivo de confirmacao
  FUNCTION fn_gera_nome_arq_confirmacao(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2;
  
  -- Gera o nome do arquivo de retorno
  FUNCTION fn_gera_nome_arquivo_retorno(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2;
  
  -- Gera o nome do arquivo da desist�ncia
  FUNCTION fn_gera_nome_arq_desistencia(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2;

  -- Gera o nome do arquivo de cancelamento
  FUNCTION fn_gera_nome_arq_cancelamento(pr_cdbandoc IN crapcob.cdbandoc%TYPE
		                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                        ) RETURN VARCHAR2;
  
	FUNCTION fn_busca_dados_conta_destino(pr_idoption IN NUMBER
		                                   ) RETURN VARCHAR2;
	
  FUNCTION fn_busca_dtmvtolt(pr_cdcooper IN crapdat.cdcooper%TYPE
		                        ) RETURN DATE;
	
	PROCEDURE pc_enviar_ted_IEPTB (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
																,pr_cdagenci IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_debitada%TYPE  --> Agencia Remetente
																,pr_nrdconta IN TBFIN_RECURSOS_MOVIMENTO.dsconta_debitada%TYPE  --> Conta Remetente
																,pr_tppessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE  --> Tipo de pessoa Remetente
			                          
																,pr_origem  IN INTEGER -- > 3. pr_idorigem ser� internet banking? R: Se o processo for autom�tico (JOB ou pc_crpsXXX), ent�o o pr_idorigem ser� "7". Sen�o, ser� "1" - AYLLOS.
			                          
																,pr_nrispbif IN TBFIN_RECURSOS_MOVIMENTO.nrispbif%TYPE  --> Banco destino
																,pr_cdageban IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_creditada%TYPE  --> Agencia destino
																,pr_nrctatrf IN TBFIN_RECURSOS_MOVIMENTO.dsconta_creditada%TYPE  --> Conta destino                          
																,pr_nmtitula IN TBFIN_RECURSOS_MOVIMENTO.nmtitular_creditada%TYPE  --> nome do titular destino

																,pr_nrcpfcgc IN TBFIN_RECURSOS_MOVIMENTO.nrcnpj_creditada%TYPE  --> CPF do titular destino
																,pr_intipcta IN TBFIN_RECURSOS_MOVIMENTO.tpconta_creditada%TYPE  --> Tipo de conta destino
																,pr_inpessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE --> Tipo de pessoa destino

																,pr_vllanmto IN TBFIN_RECURSOS_MOVIMENTO.vllanmto%TYPE  --> Valor do lan�amento
																,pr_cdfinali IN INTEGER                --> Finalidade TED
			                          
																,pr_operador IN VARCHAR2               --> C�digo do operador que est� realizando a opera��o (1:Job;xxx:Outros)

																,pr_cdhistor IN TBFIN_RECURSOS_MOVIMENTO.cdhistor%TYPE --> C�digo do hist�rico da TBFIN_RECURSOS_MOVIMENTO.cdhistor

																-- saida
																,pr_idlancto OUT TBFIN_RECURSOS_MOVIMENTO.IDLANCTO%TYPE --> ID do lan�amento
																,pr_nrdocmto OUT INTEGER               --> Documento TED
																,pr_cdcritic OUT INTEGER               --> Codigo do erro
																,pr_dscritic OUT VARCHAR2);
	
	-- 2: Protestado (9)
  PROCEDURE pc_proc_baixa(pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                         ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                         ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamentp
                         ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamentp
                         ,pr_dtocorre IN DATE                     -- data da ocorrencia
                         ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                         ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                         ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                         ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                         ,pr_vltarifa IN NUMBER                   -- Valor tarifa
                         ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                         ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                          /* parametros de erro */
                         ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                         ,pr_dscritic OUT VARCHAR2
                         );
  -- 4: Sustado (24)
  PROCEDURE pc_proc_retirada_cartorio(pr_cdcooper IN crapcop.cdcooper%TYPE                           -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                                           -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                                            -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                                          -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                                          -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                                         -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                                        -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype                     -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                                        -- Codigo Operador
																		 ,pr_cdbanpag IN INTEGER                                         -- codigo do banco de pagamento
                                     ,pr_cdagepag IN INTEGER                                         -- codigo da agencia de pagamento
                                     ,pr_ret_nrremret OUT INTEGER                                    -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                                        -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);
  -- 6: Devolvido pelo cart�rio por irregularidade - Com custas (28)
  PROCEDURE pc_proc_deb_tarifas_custas (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                       ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                       ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                                       ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                                       --,pr_vloutcre IN NUMBER                   -- Valor credito
                                       --,pr_vloutdeb IN NUMBER                   -- Valor debito
                                       ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                       ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                       ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                       ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                       ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                       ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                       ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                       ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                       ,pr_cdhistor            IN  NUMBER                              -- C�digo de hist�rico
                                        /* parametros de erro */
                                       ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2);
  --
	PROCEDURE pc_proc_outros_creditos(pr_cdcooper            IN  crapcop.cdcooper%TYPE               -- Codigo da cooperativa
                                   ,pr_idtabcob            IN  ROWID                               -- Rowid da Cobranca
																	 ,pr_cdbanpag            IN  INTEGER                             -- codigo do banco de pagamento
																	 ,pr_cdagepag            IN  INTEGER                             -- codigo da agencia de pagamento
																	 ,pr_vloutcre            IN  NUMBER                              -- Valor de cr�dito
																	 ,pr_dtocorre            IN  DATE                                -- data da ocorrencia
																	 ,pr_cdocorre            IN  INTEGER                             -- Codigo Ocorrencia
																	 ,pr_dsmotivo            IN  VARCHAR2                            -- Descricao Motivo
																	 ,pr_crapdat             IN  BTCH0001.cr_crapdat%rowtype         -- Data movimento
																	 ,pr_cdoperad            IN  VARCHAR2                            -- Codigo Operador
																	 ,pr_ret_nrremret        OUT INTEGER                             -- Numero Remessa Retorno Cooperado
																	 ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
																	 ,pr_cdhistor            IN  NUMBER                              -- C�digo de hist�rico
																	 /* parametros de erro */
																	 ,pr_cdcritic            OUT INTEGER                             -- Codigo da critica
																	 ,pr_dscritic            OUT VARCHAR2                            -- Descricao critica
																	 );
	--
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
														pr_dscritic OUT VARCHAR2
														);
	--
	PROCEDURE pc_proc_devolucao(pr_idtabcob IN ROWID                    -- Rowid da Cobranca
														 ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
														 ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
														 ,pr_dtocorre IN DATE                     -- data da ocorrencia
														 ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
														 ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
														 ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
														 ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
														 ,pr_vltarifa IN NUMBER                   -- Valor tarifa
														 ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
															/* parametros de erro */
														 ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
														 ,pr_dscritic OUT VARCHAR2                -- Descricao critica
														 );
											 
	PROCEDURE pc_atualiza_saldo(pr_cdcooper IN  tbfin_recursos_saldo.cdcooper%TYPE       -- C�digo da cooperativa
		                         ,pr_nrdconta IN  tbfin_recursos_saldo.nrdconta%TYPE       -- N�mero da conta
														 ,pr_dtmvtolt IN  tbfin_recursos_saldo.dtmvtolt%TYPE       -- Data do movimento
														 ,pr_vllanmto IN  tbfin_recursos_saldo.vlsaldo_final%TYPE  -- Valor do lan�amento
														 ,pr_dsdebcre IN  tbfin_recursos_movimento.dsdebcre%TYPE   -- Identifica se o lan�amento � de [C]r�dito ou [D]�bito
														 ,pr_dscritic OUT VARCHAR2                                 -- Retornoda descri��o do erro
		                         );
	
	/* Gerar registro de Retorno = 23 - Remessa a cart�rio */
  PROCEDURE pc_proc_remessa_cartorio (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
		                                 ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
														         ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);
	--
	PROCEDURE pc_processa_estorno(pr_cdcooper IN  craplot.cdcooper%TYPE
		                           ,pr_dtmvtolt IN  craplot.dtmvtolt%TYPE
															 ,pr_nrdconta IN  crapcob.nrdconta%TYPE
															 ,pr_nrcnvcob IN  crapcob.nrcnvcob%TYPE
															 ,pr_nrdocmto IN  crapcob.nrdocmto%TYPE
															 ,pr_vllanmto IN  craplcm.vllanmto%TYPE
															 ,pr_dscritic OUT VARCHAR2
		                           );
	-- Gera o lote e o lan�amento
	PROCEDURE pc_processa_lancamento(pr_cdcooper IN  craplot.cdcooper%TYPE
                                  ,pr_nrdconta IN  tbfin_recursos_movimento.nrdconta%TYPE
		                              ,pr_dtmvtolt IN  craplot.dtmvtolt%TYPE
																	,pr_cdagenci IN  craplot.cdagenci%TYPE
																	,pr_cdoperad IN  craplot.cdoperad%TYPE
																	,pr_cdhistor IN  craplot.cdhistor%TYPE
																	,pr_vllanmto IN  craplcm.vllanmto%TYPE
																	,pr_nmarqtxt IN  VARCHAR2
																	,pr_craplot  OUT cobr0011.cr_craplot%ROWTYPE
																	,pr_dscritic OUT VARCHAR2
		                              );
	-- Gera log em tabelas
  PROCEDURE pc_gera_log(pr_cdcooper     IN crapcop.cdcooper%type DEFAULT 3 -- Cooperativa
                       ,pr_dstiplog     IN VARCHAR2                        -- Tipo de Log
                       ,pr_dscritic     IN VARCHAR2 DEFAULT NULL           -- Descri��o do Log
                       ,pr_tpocorrencia IN VARCHAR2 dEFAULT 4              -- Tipo de Ocorr�ncia
                       );
  --
	PROCEDURE pc_gera_movimento_pagamento(pr_dscritic OUT VARCHAR2
		                                   );
  --
	PROCEDURE pc_enviar_email_teds (pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_dscritic OUT VARCHAR2);
	--
END cobr0011;
/
create or replace package body cecred.cobr0011 IS
/*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cobr0011
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Supero
  --  Data     : Mar�o/2018.                   Ultima atualiza��o: 
  --
  -- Dados referentes ao programa:
  --
  -- Freq��ncia: Sempre que chamado
  -- Objetivo  : Procedimentos para Retorno Instru��es banc�rias - Cecred/IEPTB
  --
  -- Altera��es: 
  --
---------------------------------------------------------------------------------------------------------------*/

  -- Private type declarations
	-- Tipo de registro cooperativa
	TYPE typ_reg_coop IS RECORD
		(cdcooper crapcop.cdcooper%TYPE
    ,nrdconta tbfin_recursos_movimento.nrdconta%TYPE
		,vlpagmto NUMBER
		);
	-- Tabela de tipo cooperativa
	TYPE typ_tab_coop IS TABLE OF typ_reg_coop INDEX BY PLS_INTEGER;
	-- Tabela que contem as cooperativas
	vr_tab_coop typ_tab_coop;
  
  -- Private constant declarations

  -- Private variable declarations
  --Selecionar registro cobranca
  CURSOR cr_crapcob (pr_rowid IN ROWID) IS
    SELECT  crapcob.cdcooper
           ,crapcob.nrdconta
           ,crapcob.cdbandoc
           ,crapcob.nrdctabb
           ,crapcob.nrcnvcob
           ,crapcob.nrdocmto
           ,crapcob.flgregis
           ,crapcob.flgcbdda
           ,crapcob.insitpro
           ,crapcob.nrnosnum
           ,crapcob.vltitulo
           ,crapcob.incobran
           ,crapcob.dtvencto
           ,crapcob.dsdoccop
           ,crapcob.vlabatim
           ,crapcob.vldescto
           ,crapcob.flgdprot
           ,crapcob.idopeleg
           ,crapcob.insitcrt
           ,crapcob.cdagepag
           ,crapcob.cdbanpag
           ,crapcob.cdtitprt
           ,crapcob.dtdbaixa
           ,crapcob.dtsitcrt
           ,crapcob.nrdident
           ,crapcob.rowid
     FROM crapcob
    WHERE crapcob.ROWID = pr_rowid;
  rw_crapcob cr_crapcob%ROWTYPE;

  -- Function and procedure implementations
  
  -- Gera o nome do arquivo da remessa
  FUNCTION fn_gera_nome_arquivo_remessa(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2 IS
    --
    vr_nome_arquivo VARCHAR2(400);
    --
  BEGIN
    --
    vr_nome_arquivo := 'B'                        -- Arquivo gerado pelo portador -- Fixo
                    || lpad(pr_cdbandoc, 3, '0')  -- C�digo de compensa��o do banco/portador
                    || to_char(pr_dtmvtolt, 'DD') -- Dia do envio do arquivo
                    || to_char(pr_dtmvtolt, 'MM') -- M�s do envio do arquivo
                    || '.'                        
                    || to_char(pr_dtmvtolt, 'YY') -- Ano do envio do arquivo
                    || '1'                        -- N�mero sequencial da remessa -- REVISAR
                    ;
    --
    RETURN vr_nome_arquivo;
    --
  END fn_gera_nome_arquivo_remessa;
  
  -- Gera o nome do arquivo de confirmacao
  FUNCTION fn_gera_nome_arq_confirmacao(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2 IS
    --
    vr_nome_arquivo VARCHAR2(400);
    --
  BEGIN
    --
    vr_nome_arquivo := 'C'                        -- Arquivo gerado pelo portador -- Fixo
                    || lpad(pr_cdbandoc, 3, '0')  -- C�digo de compensa��o do banco/portador
                    || to_char(pr_dtmvtolt, 'DD') -- Dia do envio do arquivo
                    || to_char(pr_dtmvtolt, 'MM') -- M�s do envio do arquivo
                    || '.'                        
                    || to_char(pr_dtmvtolt, 'YY') -- Ano do envio do arquivo
                    || '1'                        -- N�mero sequencial da remessa -- REVISAR
                    ;
    --
    RETURN vr_nome_arquivo;
    --
  END fn_gera_nome_arq_confirmacao;
  
  -- Gera o nome do arquivo de retorno
  FUNCTION fn_gera_nome_arquivo_retorno(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2 IS
    --
    vr_nome_arquivo VARCHAR2(400);
    --
  BEGIN
    --
    vr_nome_arquivo := 'R'                        -- Arquivo gerado pelo portador -- Fixo
                    || lpad(pr_cdbandoc, 3, '0')  -- C�digo de compensa��o do banco/portador
                    || to_char(pr_dtmvtolt, 'DD') -- Dia do envio do arquivo
                    || to_char(pr_dtmvtolt, 'MM') -- M�s do envio do arquivo
                    || '.'                        
                    || to_char(pr_dtmvtolt, 'YY') -- Ano do envio do arquivo
                    || '1'                        -- N�mero sequencial da remessa -- REVISAR
                    ;
    --
    RETURN vr_nome_arquivo;
    --
  END fn_gera_nome_arquivo_retorno;
  
  -- Gera o nome do arquivo da desist�ncia
  FUNCTION fn_gera_nome_arq_desistencia(pr_cdbandoc IN crapcob.cdbandoc%TYPE
                                       ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                       ) RETURN VARCHAR2 IS
    --
    vr_nome_arquivo VARCHAR2(400);
    --
  BEGIN
    --
    vr_nome_arquivo := 'DP'                       -- Desist�ncia do protesto -- Fixo
                    || lpad(pr_cdbandoc, 3, '0')  -- C�digo do apresentante -- REVISAR
                    || to_char(pr_dtmvtolt, 'DD') -- Dia do envio do arquivo
                    || to_char(pr_dtmvtolt, 'MM') -- M�s do envio do arquivo
                    || '.'                        
                    || to_char(pr_dtmvtolt, 'YY') -- Ano do envio do arquivo
                    || '1'                        -- N�mero sequencial da desist�ncia -- REVISAR
                    ;
    --
    RETURN vr_nome_arquivo;
    --
  END fn_gera_nome_arq_desistencia;
  
  -- Gera o nome do arquivo de cancelamento
  FUNCTION fn_gera_nome_arq_cancelamento(pr_cdbandoc IN crapcob.cdbandoc%TYPE
		                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE
                                        ) RETURN VARCHAR2 IS
    --
    vr_nome_arquivo VARCHAR2(400);
    --
  BEGIN
    --
    vr_nome_arquivo := 'CP'                       -- Cancelamento do protesto -- Fixo
                    || lpad(pr_cdbandoc, 3, '0')  -- C�digo do apresentante -- REVISAR
                    || to_char(pr_dtmvtolt, 'DD') -- Dia do envio do arquivo
                    || to_char(pr_dtmvtolt, 'MM') -- M�s do envio do arquivo
                    || '.'                        
                    || to_char(pr_dtmvtolt, 'YY') -- Ano do envio do arquivo
                    || '1'                        -- N�mero sequencial do cancelamento -- REVISAR
                    ;
    --
    RETURN vr_nome_arquivo;
    --
  END fn_gera_nome_arq_cancelamento;
	
	FUNCTION fn_busca_dados_conta_destino(pr_idoption IN  NUMBER
		                                   ) RETURN VARCHAR2 IS
		--
		vr_dsvlrprm crapprm.dsvlrprm%TYPE;
		vr_result   crapprm.dsvlrprm%TYPE;
		vr_posini   NUMBER;
		vr_posfim   NUMBER;
		--
	BEGIN
		--
		BEGIN
			--
			SELECT crapprm.dsvlrprm
				INTO vr_dsvlrprm
				FROM crapprm
			 WHERE crapprm.nmsistem = 'CRED'
				 AND crapprm.cdcooper = 3
				 AND crapprm.cdacesso = 'CONTA_IEPTB';
			--
		EXCEPTION
			WHEN OTHERS THEN
				raise_application_error(-20010, 'Erro ao buscar o parametro de conta destino: ' || SQLERRM);
		END;
		--
		CASE
			-- Banco destino
			WHEN pr_idoption = 1 THEN
				--
				vr_posini := 0;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 1)-1;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
				--
				BEGIN
					--
					SELECT crapban.nrispbif
					  INTO vr_result
						FROM crapban
					 WHERE crapban.cdbccxlt = vr_result;
				  --
				EXCEPTION
					WHEN OTHERS THEN
						vr_result := NULL;
						raise_application_error(-20012, 'Erro ao buscar o nr ISPB do banco: ' || SQLERRM);
				END;
			-- Agencia destino
			WHEN pr_idoption = 2 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 1)+1;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 2)-vr_posini;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
			-- Conta destino
			WHEN pr_idoption = 3 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 2)+1;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 3)-vr_posini;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
			-- Nome titular destino
			WHEN pr_idoption = 4 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 3)+1;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 4)-vr_posini;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
			-- CNPJ titular destino
			WHEN pr_idoption = 5 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 4)+1;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 5)-vr_posini;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
			-- Tipo conta destino
			WHEN pr_idoption = 6 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 5)+1;
				vr_posfim := INSTR(vr_dsvlrprm, ';', 1, 6)-vr_posini;
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
			-- Tipo pessoa destino
			WHEN pr_idoption = 7 THEN
				--
				vr_posini := INSTR(vr_dsvlrprm, ';', 1, 6)+1;
				vr_posfim := LENGTH(vr_dsvlrprm);
				vr_result := SUBSTR(vr_dsvlrprm, vr_posini, vr_posfim);
				--
		END CASE;
		--
		RETURN vr_result;
		--
	EXCEPTION
		WHEN OTHERS THEN
			raise_application_error(-20011, 'Erro ao executar a fn_busca_dados_conta_destino: ' || SQLERRM);
	END fn_busca_dados_conta_destino;	
	--
	FUNCTION fn_busca_dtmvtolt(pr_cdcooper IN crapdat.cdcooper%TYPE
		                        ) RETURN DATE IS
		--
		vr_qtdregis NUMBER;
		vr_dtmvtolt DATE;
		--
	BEGIN
		--
		BEGIN
			--
			SELECT COUNT(1)
				INTO vr_qtdregis
				FROM tbcobran_param_protesto
			 WHERE to_date( hrenvio_arquivo, 'SSSSS') > to_date(to_char( SYSDATE, 'SSSSS' ), 'SSSSS')
				 AND cdcooper = pr_cdcooper;
			--
		EXCEPTION
			WHEN OTHERS THEN
				raise_application_error(-20001, 'Erro ao buscar o parametro de limite de horario: ' || SQLERRM);
		END;
		--
		BEGIN
			--
			SELECT DECODE(vr_qtdregis, 0, crapdat.dtmvtopr, crapdat.dtmvtolt)
				INTO vr_dtmvtolt
				FROM crapdat
			 WHERE crapdat.cdcooper = pr_cdcooper;
			--
		EXCEPTION
			WHEN OTHERS THEN
				raise_application_error(-20001, 'Erro ao buscar o parametro de limite de horario: ' || SQLERRM);
		END;
		--
		RETURN vr_dtmvtolt;
		--
	EXCEPTION
		WHEN OTHERS THEN
			raise_application_error(-20001, 'Erro na fn_busca_dtmvtolt: ' || SQLERRM);
	END fn_busca_dtmvtolt;
	--
	PROCEDURE pc_enviar_ted_IEPTB (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
                          ,pr_cdagenci IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_debitada%TYPE  --> Agencia Remetente
                          ,pr_nrdconta IN TBFIN_RECURSOS_MOVIMENTO.dsconta_debitada%TYPE  --> Conta Remetente
                          ,pr_tppessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE  --> Tipo de pessoa Remetente
                          
                          ,pr_origem  IN INTEGER -- > 3. pr_idorigem ser� internet banking? R: Se o processo for autom�tico (JOB ou pc_crpsXXX), ent�o o pr_idorigem ser� "7". Sen�o, ser� "1" - AYLLOS.
                          
                          ,pr_nrispbif IN TBFIN_RECURSOS_MOVIMENTO.nrispbif%TYPE  --> Banco destino
                          ,pr_cdageban IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_creditada%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN TBFIN_RECURSOS_MOVIMENTO.dsconta_creditada%TYPE  --> Conta destino                          
                          ,pr_nmtitula IN TBFIN_RECURSOS_MOVIMENTO.nmtitular_creditada%TYPE  --> nome do titular destino

                          ,pr_nrcpfcgc IN TBFIN_RECURSOS_MOVIMENTO.nrcnpj_creditada%TYPE  --> CPF do titular destino
                          ,pr_intipcta IN TBFIN_RECURSOS_MOVIMENTO.tpconta_creditada%TYPE  --> Tipo de conta destino
                          ,pr_inpessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE --> Tipo de pessoa destino

                          ,pr_vllanmto IN TBFIN_RECURSOS_MOVIMENTO.vllanmto%TYPE  --> Valor do lan�amento
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          
                          ,pr_operador IN VARCHAR2               --> C�digo do operador que est� realizando a opera��o (1:Job;xxx:Outros)

                          ,pr_cdhistor IN TBFIN_RECURSOS_MOVIMENTO.cdhistor%TYPE --> C�digo do hist�rico da TBFIN_RECURSOS_MOVIMENTO.cdhistor

                          -- saida
                          ,pr_idlancto OUT TBFIN_RECURSOS_MOVIMENTO.IDLANCTO%TYPE --> ID do lan�amento
                          ,pr_nrdocmto OUT INTEGER               --> Documento TED
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro

      -- Buscar informa��es das contas administradoras de recursos
      CURSOR cr_tbfin_rec_con(pr_cdcooper tbfin_recursos_conta.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
                             ,pr_cdagenci tbfin_recursos_conta.cdagenci%TYPE) IS
        SELECT rc.cdcooper
              ,rc.nrdconta
              ,rc.cdagenci
              ,rc.flgativo
              ,rc.tpconta
              ,rc.nmtitular
          FROM tbfin_recursos_conta rc
         WHERE rc.cdcooper = pr_cdcooper
           AND rc.nrdconta = pr_nrdconta
           AND rc.cdagenci = pr_cdagenci
           AND rc.flgativo = 1;
      rw_tbfin_rec_con cr_tbfin_rec_con%ROWTYPE;
      
      -- Buscar informa��es do banco da conta administradora de recursos
      CURSOR cr_crapban(pr_nrispbif crapban.nrispbif%TYPE) IS
        SELECT rb.cdbccxlt
          FROM crapban rb
        WHERE rb.nrispbif = pr_nrispbif;
       rw_crapban cr_crapban%ROWTYPE;

      -- Buscar registro de saldo do dia atual das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.dtmvtolt
              ,rs.vlsaldo_inicial
              ,rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = pr_dtmvtolt;
      rw_tbfin_rec_sal cr_tbfin_rec_sal%ROWTYPE;


      -- Buscar registro saldo do dia anterior das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal_ant(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = (pr_dtmvtolt - 1);
      rw_tbfin_rec_sal_ant cr_tbfin_rec_sal_ant%ROWTYPE;
      
      -- Buscar informa��es da cooperativa
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
             SELECT c.nmrescop, c.flgoppag, c.flgopstr, c.cdagectl
             FROM crapcop c
             WHERE c.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
			CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
											 ,pr_cdhistor craphis.cdhistor%TYPE
											 ) IS
				SELECT craphis.indebcre
					FROM craphis
				 WHERE craphis.cdcooper = pr_cdcooper
					 AND craphis.cdhistor = pr_cdhistor; 
			--
			rw_craphis cr_craphis%ROWTYPE;
      ---
      
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_exc_erro EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      
      vr_nrseqted crapmat.nrseqted%type;
      vr_aux_flgreccon BOOLEAN;
      vr_aux_flgrecsal BOOLEAN;
      vr_nrctrlif VARCHAR2(500);
      vr_aux_nrseqdig VARCHAR2(500);
      vr_aux_dtmvtolt VARCHAR2(500);
      vr_aux_sal_ant tbfin_recursos_saldo.vlsaldo_final%type;      
      vr_aux_cdhistor tbfin_recursos_movimento.cdhistor%type;
      
      vr_indebcre craphis.indebcre%TYPE;
			vr_cddbanco INTEGER;

      -------------------- Programa Principal -----------------
      BEGIN        

        --> Buscar dados cooperativa
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
          
        --> verificar se encontra registro
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_cdcritic := 651;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapcop;
        END IF;

        -- Validar data cooper
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        -- Se n�o encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
           CLOSE btch0001.cr_crapdat;

          vr_cdcritic := 0;
          vr_dscritic := 'Sistema sem data de movimento.';
          RAISE vr_exc_erro;
        ELSE
           CLOSE btch0001.cr_crapdat;
        END IF;
        
        IF rw_crapcop.flgoppag = 0 /*FALSE*/ AND  -- N�o operando com o pag. (camara de compensacao) 
           rw_crapcop.flgopstr = 0 /*FALSE*/ THEN -- N�o opera com o str. 
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa nao esta operando no SPB.';
          RAISE vr_exc_erro;
        END IF;
				
				OPEN cr_craphis(pr_cdcooper => pr_cdcooper
											 ,pr_cdhistor => pr_cdhistor
											 );
				--
				FETCH cr_craphis INTO rw_craphis;
				--
				IF cr_craphis%NOTFOUND THEN
					--
					vr_cdcritic := 0;
          vr_dscritic := 'Hist�rico n�o encontrado!';
					--
          RAISE vr_exc_erro;
					--
				ELSE
					--
					vr_indebcre := rw_craphis.indebcre;
					--
				END IF;
				--
				CLOSE cr_craphis;
        
        /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
        vr_nrseqted := fn_sequence( 'CRAPMAT'
                                   ,'NRSEQTED'
                                   ,pr_cdcooper
                                   ,'N');
                                   
        -- Busca a proxima sequencia do campo TBFIN_RECURSOS_MOVIMENTO.idlancto
        pr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
                                  ,pr_nmdcampo => 'IDLANCTO'
                                  ,pr_dsdchave => 'IDLANCTO'
                                  );
                                  
        -- retornar numero do documento
        pr_nrdocmto := vr_nrseqted;
        
				-- Se alterar numero de controle, ajustar procedure atualiza-doc-ted
        vr_nrctrlif := '9'||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                          ||to_char(rw_crapcop.cdagectl,'fm0000')
                          ||to_char(pr_nrdocmto,'fm00000000')
													|| 'P';

        /* Verifica se a TED � destinada a uma conta administradora de recursos */
        OPEN cr_tbfin_rec_con(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdagenci => pr_cdagenci);                            
                              
                              
        FETCH cr_tbfin_rec_con
        INTO rw_tbfin_rec_con;
        -- Se encontrar
        IF cr_tbfin_rec_con%FOUND THEN
          vr_aux_flgreccon := TRUE; 
        END IF;
        CLOSE cr_tbfin_rec_con;

        IF vr_aux_flgreccon THEN
               
          vr_aux_nrseqdig := fn_sequence('tbfin_recursos_movimento',
                         'nrseqdig',''||rw_crapdat.dtmvtocd
                         ||';'||pr_nrdconta||';'||to_char(vr_aux_dtmvtolt,'dd/mm/yyyy')||'');
                                                        
          -- Gerar lan�amento em conta (confirmar)
          BEGIN
            INSERT INTO tbfin_recursos_movimento
                (cdcooper
                ,nrdconta
                ,dtmvtolt
                ,nrdocmto
                ,nrseqdig
                ,cdhistor
                ,dsdebcre
                ,vllanmto
                ,nrcnpj_creditada
                ,nmtitular_creditada
                ,tpconta_creditada
                ,cdagenci_creditada
                ,dsconta_creditada
                ,hrtransa
                ,cdoperad
                ,idlancto)
            VALUES
               (pr_cdcooper
               ,pr_nrdconta
               ,rw_crapdat.dtmvtocd
               ,pr_nrdocmto -- vr_nrctrlif
               ,vr_aux_nrseqdig
               ,pr_cdhistor -- vr_aux_cdhistor
               ,vr_indebcre
               ,pr_vllanmto
               ,pr_nrcpfcgc
               ,pr_nmtitula
               ,pr_intipcta
               ,pr_cdageban
               ,pr_nrctatrf
               ,to_char(sysdate,'sssss')
               ,'1'
               ,pr_idlancto);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_movimento --> ' || SQLERRM;
             -- Sair da rotina
             RAISE vr_exc_saida;
          END;

          OPEN cr_tbfin_rec_sal(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtolt => rw_crapdat.dtmvtocd);
          FETCH cr_tbfin_rec_sal
          INTO rw_tbfin_rec_sal;

          -- Se encontrar
          IF cr_tbfin_rec_sal%FOUND THEN
            vr_aux_flgrecsal := TRUE;
          END IF;
          CLOSE cr_tbfin_rec_sal;

          -- Alterar saldo do dia, caso houver
          IF vr_aux_flgrecsal THEN

            BEGIN
              UPDATE tbfin_recursos_saldo
              SET vlsaldo_final = vlsaldo_final - pr_vllanmto
              WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao editar a tabela tbfin_recursos_saldo --> ' || SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
            END;

          -- Sen�o... Alterar saldo do dia anterior  
          ELSE

            OPEN cr_tbfin_rec_sal_ant(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtocd);
            FETCH cr_tbfin_rec_sal_ant
            INTO rw_tbfin_rec_sal_ant;
            -- Se encontrar
            IF cr_tbfin_rec_sal_ant%FOUND THEN
              vr_aux_sal_ant := rw_tbfin_rec_sal_ant.vlsaldo_final;
            END IF;
            CLOSE cr_tbfin_rec_sal_ant;

            BEGIN
              INSERT INTO tbfin_recursos_saldo
                 (cdcooper
                  ,nrdconta
                  ,dtmvtolt
                  ,vlsaldo_inicial
                  ,vlsaldo_final)
              VALUES
                 (pr_cdcooper
                 ,pr_nrdconta
                 ,rw_crapdat.dtmvtocd
                 ,vr_aux_sal_ant
                 ,(vr_aux_sal_ant - pr_vllanmto));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_saldo --> ' || SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
            END;
          END IF;

        ELSE
          vr_dscritic := 'Conta de administra��o de recursos n�o encontrada';
          -- Sair da rotina
          RAISE vr_exc_saida;
        END IF;
        
        OPEN cr_crapban(pr_nrispbif);
        FETCH cr_crapban
        INTO rw_crapban;

        IF cr_crapban%FOUND THEN
          vr_cddbanco := rw_crapban.cdbccxlt;
        ELSE
          vr_dscritic := 'Banco da conta de administra��o de recursos n�o encontrado';
          -- Sair da rotina
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapban;
        
        SSPB0001.pc_proc_envia_tec_ted
                          (pr_cdcooper => pr_cdcooper -- INTEGER
                          ,pr_cdagenci => pr_cdagenci -- INTEGER
                          ,pr_nrdcaixa => 1           -- INTEGER
                          ,pr_cdoperad => pr_operador -- VARCHAR2
                          ,pr_titulari => FALSE       -- BOOLEAN            -- Mesma titularidade
                          ,pr_vldocmto => pr_vllanmto -- NUMBER
                          ,pr_nrctrlif => vr_nrctrlif -- VARCHAR2
                          ,pr_nrdconta => pr_nrdconta -- INTEGER
                          ,pr_cdbccxlt => vr_cddbanco -- INTEGER
                          ,pr_cdagenbc => pr_cdageban -- INTEGER
                          ,pr_nrcctrcb => pr_nrctatrf -- NUMBER
                          ,pr_cdfinrcb => pr_cdfinali -- INTEGER
                          ,pr_tpdctadb => 1 -- CC     -- INTEGER
                          ,pr_tpdctacr => 1 -- CC     -- INTEGER
                          ,pr_nmpesemi => rw_tbfin_rec_con.nmtitular -- VARCHAR2
                          ,pr_nmpesde1 => NULL        -- VARCHAR2             -- Nome de 2TTL
                          ,pr_cpfcgemi => pr_nrcpfcgc -- NUMBER
                          ,pr_cpfcgdel => 0           -- NUMBER             -- CPF sec TTL
                          ,pr_nmpesrcb => pr_nmtitula -- VARCHAR2
                          ,pr_nmstlrcb => NULL        -- VARCHAR2             -- Nome para 2TTL
                          ,pr_cpfcgrcb => pr_nrcpfcgc -- NUMBER
                          ,pr_cpstlrcb => 0           -- NUMBER             -- CPF para 2TTL
													,pr_tppesemi => pr_tppessoa -- INTEGER             
                          ,pr_tppesrec => pr_inpessoa -- INTEGER 
													,pr_flgctsal => FALSE       -- BOOLEAN             -- CC Sal
                          ,pr_cdidtran => ''          -- VARCHAR2
													,pr_cdorigem => pr_origem   -- INTEGER
                          ,pr_dtagendt => NULL        -- DATE             -- Data agendamento
                          ,pr_nrseqarq => 0           -- INTEGER             -- Nr. seq arq.
                          ,pr_cdconven => 0           -- INTEGER             -- Cod convenio
                          ,pr_dshistor => pr_cdhistor -- VARCHAR2
                          ,pr_hrtransa => to_number(to_char(sysdate,'sssss')) -- INTEGER -- Hora transacao
                          ,pr_cdispbif => pr_nrispbif -- INTEGER
													
                          -- SAIDA
                          ,pr_cdcritic =>  vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic =>  vr_dscritic);   --> Descricao do erro

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'N�o foi possivel enviar a TED: ' || nvl(vr_dscritic, SQLERRM);

  END pc_enviar_ted_IEPTB;
  
  PROCEDURE pc_prep_lcm_mot_consolidada ( pr_idtabcob IN ROWID         -- ROWID da cobranca
                                         ,pr_cdocorre IN INTEGER       -- Codigo Ocorrencia
                                         ,pr_dsmotivo IN VARCHAR2      -- Descri��o do motivo
                                         ,pr_tplancto IN VARCHAR       -- Tipo Lancamento
                                         ,pr_vltarifa IN NUMBER        -- Valor Tarifa
                                         ,pr_cdhistor IN INTEGER       -- Codigo Historico
                                         ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada
                                         ,pr_cdcritic OUT INTEGER      -- Codigo Critica
                                         ,pr_dscritic OUT VARCHAR2) IS -- Descricao Critica
    /* .........................................................................
    --
    --  Programa : pc_prep_lcm_mot_consolidada
    --  Sistema  : Cred
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Mar�o/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure que gera dados para tt-lcm-consolidada
    --   Altera��es:
    --
......................................................................... */         

    --Variaveis Locais
    vr_vltarifa NUMBER;
    vr_cdhistor INTEGER;
    --Variaveis rotina tarifa
    vr_tar_cdhistor INTEGER;
    vr_tar_cdhisest INTEGER;
    vr_tar_vltarifa NUMBER;
    vr_tar_dtdivulg DATE;
    vr_tar_dtvigenc DATE;
    vr_tar_cdfvlcop INTEGER;

    --Variavel Indice tabela
    vr_index VARCHAR2(40);
    --Tabela de memoria de erros
    vr_tab_erro GENE0001.typ_tab_erro;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Mensagem Erro
      vr_dscritic:= 'Registro de Cobranca nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    --Se for lancamento tarifa
    IF  pr_tplancto = 'T' THEN

      --Buscar dados tarifa
      TARI0001.pc_busca_dados_tarifa (pr_cdcooper  => rw_crapcob.cdcooper    --Codigo Cooperativa
                                     ,pr_nrdconta  => rw_crapcob.nrdconta    --Codigo da Conta
                                     ,pr_nrconven  => rw_crapcob.nrcnvcob    --Numero Convenio
                                     ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                     ,pr_cdocorre  => pr_cdocorre            --Codigo Ocorrencia
                                     ,pr_cdmotivo  => pr_dsmotivo            --Codigo Motivo
                                     ,pr_idtabcob  => pr_idtabcob            --Tipo Pessoa
                                     ,pr_flaputar  => 1                      --Deve apurar tarifa
                                     ,pr_cdhistor  => vr_tar_cdhistor        --Codigo Historico
                                     ,pr_cdhisest  => vr_tar_cdhisest        --Historico Estorno
                                     ,pr_vltarifa  => vr_tar_vltarifa        --Valor Tarifa
                                     ,pr_dtdivulg  => vr_tar_dtdivulg        --Data Divulgacao
                                     ,pr_dtvigenc  => vr_tar_dtvigenc        --Data Vigencia
                                     ,pr_cdfvlcop  => vr_tar_cdfvlcop        --Codigo Cooperativa
                                     ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                     ,pr_dscritic  => vr_dscritic            --Descricao Critica
                                     ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Zerar tarifa e historico
        vr_vltarifa:= 0;
        vr_cdhistor:= 0;
      ELSE
        vr_vltarifa:= vr_tar_vltarifa;
        vr_cdhistor:= vr_tar_cdhistor;
      END IF;
    END IF;

    --Se Encontrou tarifa
    IF vr_vltarifa > 0 THEN
      --Montar indice para acessar tabela
      vr_index:= LPad(rw_crapcob.cdcooper,10,'0')||
                 LPad(rw_crapcob.nrdconta,10,'0')||
                 LPad(rw_crapcob.nrcnvcob,10,'0')||
                 LPad(pr_cdocorre,5,'0')||
                 LPad(vr_cdhistor,5,'0');
      --Verificar se a chave existe na tabela
      IF NOT pr_tab_lcm_consolidada.EXISTS(vr_index) THEN
        --Criar registro tabela lancamentos consolidada
        pr_tab_lcm_consolidada(vr_index).cdcooper:= rw_crapcob.cdcooper;
        pr_tab_lcm_consolidada(vr_index).nrdconta:= rw_crapcob.nrdconta;
        pr_tab_lcm_consolidada(vr_index).nrconven:= rw_crapcob.nrcnvcob;
        pr_tab_lcm_consolidada(vr_index).cdocorre:= pr_cdocorre;
        pr_tab_lcm_consolidada(vr_index).cdhistor:= vr_cdhistor;
        pr_tab_lcm_consolidada(vr_index).vllancto:= vr_vltarifa;
        pr_tab_lcm_consolidada(vr_index).tplancto:= pr_tplancto;
        pr_tab_lcm_consolidada(vr_index).qtdregis:= 1;
        pr_tab_lcm_consolidada(vr_index).cdfvlcop:= vr_tar_cdfvlcop;
      ELSE
        --Incrementar valor tarifa
        pr_tab_lcm_consolidada(vr_index).vllancto:= Nvl(pr_tab_lcm_consolidada(vr_index).vllancto,0) + vr_vltarifa;
        --Incrementar quantidade registros
        pr_tab_lcm_consolidada(vr_index).qtdregis:= Nvl(pr_tab_lcm_consolidada(vr_index).qtdregis,0) + 1;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_prep_lcm_mot_consolidada. '||sqlerrm;
  END pc_prep_lcm_mot_consolidada;
  
  -- 2: Protestado (9)
  PROCEDURE pc_proc_baixa  (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                           ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                           ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
                           ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                           ,pr_dtocorre IN DATE                     -- data da ocorrencia
                           ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                           ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                           ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                           ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                           ,pr_vltarifa IN NUMBER                   -- Valor tarifa
                           ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
                           ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                            /* parametros de erro */
                           ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                           ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_baixa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Mar�o/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 09 - Baixa
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;   
  BEGIN
    -- Inicializar variaveis retorno
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    -- Selecionar registro cobranca
    OPEN cr_crapcob(pr_rowid => pr_idtabcob);
    -- Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    -- Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      -- Fechar Cursor
      CLOSE cr_crapcob;
      -- Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Fechar Cursor
    CLOSE cr_crapcob;
    -- Gerar motivos de ocorrencia
    paga0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    IF TRIM(pr_dsmotivo) = '14' THEN
      rw_crapcob.insitcrt := 5;
      rw_crapcob.dtsitcrt := pr_crapdat.dtmvtolt;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.incobran = 3, /* Baixado */
             crapcob.cdbanpag = pr_cdbanpag,
             crapcob.cdagepag = pr_cdagepag,
             crapcob.dtdbaixa = pr_crapdat.dtmvtolt,
             crapcob.indpagto = 0, /* compensa��o - COMPE */
             crapcob.insitcrt = rw_crapcob.insitcrt,
             crapcob.dtsitcrt = rw_crapcob.dtsitcrt
       WHERE crapcob.rowid  = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => pr_dsmotivo         --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --
    paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutdes => pr_vltarifa
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		--
        
    -- se o boleto for DDA/NPC, baixar da CIP
    IF rw_crapcob.nrdident > 0 THEN
      -- Executa procedimentos do DDA-JD
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad => 'B'                       --Tipo Operacao
                                       ,pr_tpdbaixa => '3'                       --Envio para protesto
                                       ,pr_dtvencto => rw_crapcob.dtvencto       --Data Vencimento
                                       ,pr_vldescto => rw_crapcob.vldescto       --Valor Desconto
                                       ,pr_vlabatim => rw_crapcob.vlabatim       --Valor Abatimento
                                       ,pr_flgdprot => rw_crapcob.flgdprot       --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic => vr_cdcritic               --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);             --Descricao Critica
                                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao realizar procedimento DDA: ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;                                             
    END IF;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_proc_baixa. '||sqlerrm;
  END pc_proc_baixa;
  
  -- 4: Sustado (24)
  PROCEDURE pc_proc_retirada_cartorio(pr_cdcooper IN crapcop.cdcooper%TYPE                           -- Codigo da cooperativa
                                     ,pr_idtabcob IN ROWID                                           -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                                            -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                                          -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                                          -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                                         -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                                        -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype                     -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                                        -- Codigo Operador
																		 ,pr_cdbanpag IN INTEGER                                         -- codigo do banco de pagamento
                                     ,pr_cdagepag IN INTEGER                                         -- codigo da agencia de pagamento
                                     ,pr_ret_nrremret OUT INTEGER                                    -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                                        -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS                                   -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_retirada_cartorio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Mar�o/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 24 - Retirada de cart�rio e manuten��o em carteira
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN (2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    --variavel de descri��o para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;       
  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 4, /* sustado */
             crapcob.dtsitcrt = pr_dtocorre,
             crapcob.dtbloque = NULL
       WHERE crapcob.rowid    = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    IF nvl(pr_vltarifa,0) > 0 THEN
      /* Gerar dados para tt-lcm-consolidada */
      PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                          ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
                                          ,pr_tplancto => 'C'              --Tipo Lancamento  /* tplancto = "C" Cartorio */
                                          ,pr_vltarifa => pr_vltarifa      --Valor Tarifa
                                          ,pr_cdhistor => pr_cdhistor      --Codigo Historico
                                          ,pr_cdmotivo => NULL             --Codigo motivo
                                          ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                          ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);    --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
		
		PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
																				,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
																				,pr_tplancto => 'T'              --Tipo Lancamento  /* tplancto = "C" Cartorio */
																				,pr_vltarifa => 0                --Valor Tarifa
																				,pr_cdhistor => 0                --Codigo Historico
																				,pr_cdmotivo => NULL             --Codigo motivo
																				,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
																				,pr_cdcritic => vr_cdcritic      --Codigo Critica
																				,pr_dscritic => vr_dscritic);    --Descricao Critica

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		--
		paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutdes => pr_vltarifa
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

		-- verificar se existe alguma instrucao de baixa 
    OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_dtmvtolt => pr_crapdat.dtmvtolt);
    FETCH cr_craprem INTO rw_craprem;

		-- Criar Log Cobranca 
		vr_dsmotivo:= 'Retirado de cart�rio';
		PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
																 ,pr_cdoperad => pr_cdoperad        --Operador
																 ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
																 ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
																 ,pr_des_erro => vr_des_erro        --Indicador erro
																 ,pr_dscritic => vr_dscritic);      --Descricao erro
		--Se ocorreu erro
		IF vr_des_erro = 'NOK' THEN
			--Levantar Excecao
			RAISE vr_exc_erro;
		END IF;
		
		-- Verifica se precisa realizar a baixa.
		IF cr_craprem%FOUND THEN
			--
			cobr0010.pc_grava_instr_boleto(pr_cdcooper => rw_crapcob.cdcooper
			                              ,pr_dtmvtolt => pr_crapdat.dtmvtolt
																		,pr_cdoperad => pr_cdoperad
																		,pr_cdinstru => 2 -- Instru��o de baixa
																		,pr_nrdconta => rw_crapcob.nrdconta
																		,pr_nrcnvcob => rw_crapcob.nrcnvcob
																		,pr_nrdocmto => rw_crapcob.nrdocmto
																		,pr_vlabatim => 0
																		,pr_dtvencto => NULL
																		,pr_qtdiaprt => NULL
																		,pr_cdcritic => vr_cdcritic
																		,pr_dscritic => vr_dscritic
																		);
			-- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
				CLOSE cr_craprem;
        RAISE vr_exc_erro;
      END IF;
			--
		END IF;
		--
		CLOSE cr_craprem;
    
    -- se boleto foi rejeitado pelo cartorio, atualizar situacao DDA/NPC
    IF rw_crapcob.nrdident > 0 THEN
      -- Executa procedimentos do DDA-JD
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad => 'A'                       --Tipo Operacao
                                       ,pr_tpdbaixa => ''                        --Envio para protesto
                                       ,pr_dtvencto => rw_crapcob.dtvencto       --Data Vencimento
                                       ,pr_vldescto => rw_crapcob.vldescto       --Valor Desconto
                                       ,pr_vlabatim => rw_crapcob.vlabatim       --Valor Abatimento
                                       ,pr_flgdprot => rw_crapcob.flgdprot       --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic => vr_cdcritic               --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);             --Descricao Critica
                                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao realizar procedimento DDA: ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;                                             
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_proc_retirada_cartorio '||sqlerrm;
  END pc_proc_retirada_cartorio;
  
  -- 6: Devolvido pelo cart�rio por irregularidade - Com custas (28)
  PROCEDURE pc_proc_deb_tarifas_custas(pr_cdcooper            IN  crapcop.cdcooper%TYPE               -- Codigo da cooperativa
                                      ,pr_idtabcob            IN  ROWID                               -- Rowid da Cobranca
                                      ,pr_cdbanpag            IN  INTEGER                             -- codigo do banco de pagamento
                                      ,pr_cdagepag            IN  INTEGER                             -- codigo da agencia de pagamento
                                      ,pr_vltarifa            IN  NUMBER                              -- Valor da tarifa
                                      ,pr_dtocorre            IN  DATE                                -- data da ocorrencia
                                      ,pr_cdocorre            IN  INTEGER                             -- Codigo Ocorrencia
                                      ,pr_dsmotivo            IN  VARCHAR2                            -- Descricao Motivo
                                      ,pr_crapdat             IN  BTCH0001.cr_crapdat%rowtype         -- Data movimento
                                      ,pr_cdoperad            IN  VARCHAR2                            -- Codigo Operador
                                      ,pr_ret_nrremret        OUT INTEGER                             -- Numero Remessa Retorno Cooperado
                                      ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      ,pr_cdhistor            IN  NUMBER                              -- C�digo de hist�rico
                                       /* parametros de erro */
                                      ,pr_cdcritic            OUT INTEGER                             -- Codigo da critica
                                      ,pr_dscritic            OUT VARCHAR2                            -- Descricao critica
                                      ) IS
  /* ..........................................................................
    --
    --  Programa : pc_proc_deb_tarifas_custas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 28 - Debito de tarifas/custas
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN (2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;
		
		CURSOR cr_crapoco(pr_cdcooper crapmot.cdcooper%TYPE
		                 ,pr_cdocorre crapmot.cdocorre%TYPE
										 ,pr_dsmotivo crapmot.dsmotivo%TYPE
		                 ) IS
		  SELECT crapmot.dsmotivo
			  FROM crapoco
				    ,crapmot
			 WHERE crapmot.cdcooper = crapoco.cdcooper
			   AND crapmot.cddbanco = crapoco.cddbanco
				 AND crapmot.cdocorre = crapoco.cdocorre
				 AND crapmot.tpocorre = crapoco.tpocorre
				 AND crapmot.cddbanco = 85 -- Fixo
				 AND crapmot.cdcooper = pr_cdcooper
				 AND crapmot.cdocorre = pr_cdocorre
				 AND crapmot.tpocorre = 2 -- Fixo
				 AND crapmot.cdmotivo = pr_dsmotivo;
	  rw_crapoco cr_crapoco%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    --variavel de descri��o para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;
    vr_cdhistor craphis.cdhistor%type :=0;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob         --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo         --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic         --Descricao Critica
                                     );
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Gerar dados para tt-lcm-consolidada 
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid  --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre       --Codigo Ocorrencia 
                                        ,pr_tplancto => 'C'               --Tipo Lancamento   C=Cartorio
                                        ,pr_vltarifa => nvl(pr_vltarifa,0)--Valor Tarifa
                                        ,pr_cdhistor => pr_cdhistor       --Codigo Historico
                                        ,pr_cdmotivo => NULL              --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic       --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);     --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		
		paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutdes => pr_vltarifa
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

		-- Criar Log Cobranca 
		OPEN cr_crapoco(pr_cdcooper => pr_cdcooper
		               ,pr_cdocorre => pr_cdocorre
									 ,pr_dsmotivo => pr_dsmotivo
		               );
	  --
		FETCH cr_crapoco INTO rw_crapoco;
		--
		CLOSE cr_crapoco;
		--
		vr_dsmotivo:= rw_crapoco.dsmotivo;
		PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
																 ,pr_cdoperad => pr_cdoperad        --Operador
																 ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
																 ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
																 ,pr_des_erro => vr_des_erro        --Indicador erro
																 ,pr_dscritic => vr_dscritic);      --Descricao erro
		--Se ocorreu erro
		IF vr_des_erro = 'NOK' THEN
			--Levantar Excecao
			RAISE vr_exc_erro;
		END IF;
		--
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_proc_deb_tarifas_custas: '||sqlerrm;
  END pc_proc_deb_tarifas_custas;
	
	PROCEDURE pc_proc_outros_creditos(pr_cdcooper            IN  crapcop.cdcooper%TYPE               -- Codigo da cooperativa
                                   ,pr_idtabcob            IN  ROWID                               -- Rowid da Cobranca
																	 ,pr_cdbanpag            IN  INTEGER                             -- codigo do banco de pagamento
																	 ,pr_cdagepag            IN  INTEGER                             -- codigo da agencia de pagamento
																	 ,pr_vloutcre            IN  NUMBER                              -- Valor de cr�dito
																	 ,pr_dtocorre            IN  DATE                                -- data da ocorrencia
																	 ,pr_cdocorre            IN  INTEGER                             -- Codigo Ocorrencia
																	 ,pr_dsmotivo            IN  VARCHAR2                            -- Descricao Motivo
																	 ,pr_crapdat             IN  BTCH0001.cr_crapdat%rowtype         -- Data movimento
																	 ,pr_cdoperad            IN  VARCHAR2                            -- Codigo Operador
																	 ,pr_ret_nrremret        OUT INTEGER                             -- Numero Remessa Retorno Cooperado
																	 ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
																	 ,pr_cdhistor            IN  NUMBER                              -- C�digo de hist�rico
																	 /* parametros de erro */
																	 ,pr_cdcritic            OUT INTEGER                             -- Codigo da critica
																	 ,pr_dscritic            OUT VARCHAR2                            -- Descricao critica
																	 ) IS
  /* ..........................................................................
    --
    --  Programa : pc_proc_outros_creditos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 89 - Rejei��o Cartor�ria
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN (2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;
		
		CURSOR cr_crapoco(pr_cdcooper crapmot.cdcooper%TYPE
		                 ,pr_cdocorre crapmot.cdocorre%TYPE
										 ,pr_dsmotivo crapmot.dsmotivo%TYPE
		                 ) IS
		  SELECT crapmot.dsmotivo
			  FROM crapoco
				    ,crapmot
			 WHERE crapmot.cdcooper = crapoco.cdcooper
			   AND crapmot.cddbanco = crapoco.cddbanco
				 AND crapmot.cdocorre = crapoco.cdocorre
				 AND crapmot.tpocorre = crapoco.tpocorre
				 AND crapmot.cddbanco = 85 -- Fixo
				 AND crapmot.cdcooper = pr_cdcooper
				 AND crapmot.cdocorre = pr_cdocorre
				 AND crapmot.tpocorre = 2 -- Fixo
				 AND crapmot.cdmotivo = pr_dsmotivo;
	  rw_crapoco cr_crapoco%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);
    --variavel de descri��o para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;
    vr_cdhistor craphis.cdhistor%type :=0;

  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /* Gerar motivos de ocorrencia  */
    PAGA0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob         --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo         --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic         --Descricao Critica
                                     );
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Gerar dados para tt-lcm-consolidada 
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid  --ROWID da cobranca
                                        ,pr_cdocorre => pr_cdocorre       --Codigo Ocorrencia 
                                        ,pr_tplancto => 'C'               --Tipo Lancamento   C=Cartorio
                                        ,pr_vltarifa => nvl(pr_vloutcre,0)--Valor Tarifa
                                        ,pr_cdhistor => pr_cdhistor       --Codigo Historico
                                        ,pr_cdmotivo => NULL              --Codigo motivo
                                        ,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
                                        ,pr_cdcritic => vr_cdcritic       --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);     --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		
		paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutcre => pr_vloutcre
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

		-- Criar Log Cobranca 
		OPEN cr_crapoco(pr_cdcooper => pr_cdcooper
		               ,pr_cdocorre => pr_cdocorre
									 ,pr_dsmotivo => pr_dsmotivo
		               );
	  --
		FETCH cr_crapoco INTO rw_crapoco;
		--
		CLOSE cr_crapoco;
		--
		vr_dsmotivo:= rw_crapoco.dsmotivo;
		PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
																 ,pr_cdoperad => pr_cdoperad        --Operador
																 ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
																 ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
																 ,pr_des_erro => vr_des_erro        --Indicador erro
																 ,pr_dscritic => vr_dscritic);      --Descricao erro
		--Se ocorreu erro
		IF vr_des_erro = 'NOK' THEN
			--Levantar Excecao
			RAISE vr_exc_erro;
		END IF;
		--
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_proc_deb_tarifas_custas: '||sqlerrm;
  END pc_proc_outros_creditos;
	
	-- Procedimento para inserir o lote e n�o deixar tabela lockada
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
														pr_dscritic OUT VARCHAR2
														)IS
    /* ..........................................................................
    --
    --  Programa : pc_insere_lote
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar a CRAPLOT
    -- ..........................................................................*/
		
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
							,craplot.nrseqdig
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
							,1  -- craplot.nrseqdig
							,pr_tplotmov
							,pr_cdoperad
							,pr_cdhistor
							,pr_nrdcaixa
							,pr_cdoperad)
				 RETURNING  craplot.ROWID
									 ,craplot.nrdolote
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
							 INTO rw_craplot_ctl.ROWID
									, rw_craplot_ctl.nrdolote
									, rw_craplot_ctl.nrseqdig
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
		ELSE
			-- ou atualizar o nrseqdig para reservar posi��o
			UPDATE craplot
				 SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
			 WHERE craplot.ROWID = rw_craplot_ctl.ROWID
			 RETURNING craplot.nrseqdig INTO rw_craplot_ctl.nrseqdig;
		END IF;

		CLOSE cr_craplot;

		-- retornar informa��es para o programa chamador
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
	
	PROCEDURE pc_proc_devolucao(pr_idtabcob IN ROWID                    -- Rowid da Cobranca
														 ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
														 ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
														 ,pr_dtocorre IN DATE                     -- data da ocorrencia
														 ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
														 ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
														 ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
														 ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
														 ,pr_vltarifa IN NUMBER                   -- Valor tarifa
														 ,pr_ret_nrremret OUT INTEGER             -- Numero remetente
															/* parametros de erro */
														 ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
														 ,pr_dscritic OUT VARCHAR2                -- Descricao critica
														 ) IS
    /* ..........................................................................
    --
    --  Programa : pc_proc_devolucao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar retorno de devolu��o por irregularidade
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;      
  BEGIN
    -- Inicializar variaveis retorno
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    -- Selecionar registro cobranca
    OPEN cr_crapcob(pr_rowid => pr_idtabcob);
    -- Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    -- Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      -- Fechar Cursor
      CLOSE cr_crapcob;
      -- Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Fechar Cursor
    CLOSE cr_crapcob;
    -- Gerar motivos de ocorrencia
    paga0001.pc_proc_motivos_retorno (pr_idtabcob => pr_idtabcob   --Rowid da cobranca
                                     ,pr_cdocorre => pr_cdocorre   --Codigo Ocorrencia
                                     ,pr_dsmotivo => pr_dsmotivo   --Descricao Motivo
                                     ,pr_dtmvtolt => pr_crapdat.dtmvtolt  --Data Movimentacao
                                     ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 0,
             crapcob.dtsitcrt = NULL,
             crapcob.dtbloque = NULL
       WHERE crapcob.rowid  = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;

    IF rw_crapcob.nrdident > 0 THEN
      -- Executa procedimentos do DDA-JD
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad => 'A'                       --Tipo Operacao
                                       ,pr_tpdbaixa => ''                       --Envio para protesto
                                       ,pr_dtvencto => rw_crapcob.dtvencto       --Data Vencimento
                                       ,pr_vldescto => rw_crapcob.vldescto       --Valor Desconto
                                       ,pr_vlabatim => rw_crapcob.vlabatim       --Valor Abatimento
                                       ,pr_flgdprot => rw_crapcob.flgdprot       --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic => vr_cdcritic               --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);             --Descricao Critica
                                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao realizar procedimento DDA: ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;                                             
    END IF;    

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --
    paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutdes => pr_vltarifa
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		--
	EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina cobr0011.pc_proc_devolucao. '||sqlerrm;
  END pc_proc_devolucao;
  --
	
	/* Rotina para atualizar o saldo */
	PROCEDURE pc_atualiza_saldo(pr_cdcooper IN  tbfin_recursos_saldo.cdcooper%TYPE       -- C�digo da cooperativa
		                         ,pr_nrdconta IN  tbfin_recursos_saldo.nrdconta%TYPE       -- N�mero da conta
														 ,pr_dtmvtolt IN  tbfin_recursos_saldo.dtmvtolt%TYPE       -- Data do movimento
														 ,pr_vllanmto IN  tbfin_recursos_saldo.vlsaldo_final%TYPE  -- Valor do lan�amento
														 ,pr_dsdebcre IN  tbfin_recursos_movimento.dsdebcre%TYPE   -- Identifica se o lan�amento � de [C]r�dito ou [D]�bito
														 ,pr_dscritic OUT VARCHAR2                                 -- Retornoda descri��o do erro
		                         ) IS
    --
		CURSOR cr_saldo(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
									 ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
									 ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE
		               ) IS
		  SELECT vlsaldo_final
			  FROM tbfin_recursos_saldo
			 WHERE cdcooper = pr_cdcooper
			   AND nrdconta = pr_nrdconta
				 AND dtmvtolt = (SELECT MAX(dtmvtolt)
				                   FROM tbfin_recursos_saldo
												  WHERE cdcooper = pr_cdcooper
												    AND nrdconta = pr_nrdconta
													  AND dtmvtolt < pr_dtmvtolt);
		--
		vr_vllancto tbfin_recursos_saldo.vlsaldo_final%TYPE;
		vr_vlultsld tbfin_recursos_saldo.vlsaldo_final%TYPE;
		--
	BEGIN
		-- Busca �ltimo saldo
		OPEN cr_saldo(pr_cdcooper
								 ,pr_nrdconta
								 ,pr_dtmvtolt
								 );
		--
		FETCH cr_saldo INTO vr_vlultsld;
		--
		CLOSE cr_saldo;
		-- Atualiza o saldo
		IF pr_dsdebcre = 'C' THEN
			--
			vr_vllancto := nvl(vr_vllancto, 0) + pr_vllanmto;
			--
		ELSE
			--
			vr_vllancto := nvl(vr_vllancto, 0) - pr_vllanmto;
			--
		END IF;
		--
		BEGIN
			--
			INSERT INTO tbfin_recursos_saldo(cdcooper
                                      ,nrdconta
                                      ,dtmvtolt
																			,vlsaldo_inicial
                                      ,vlsaldo_final
                                      ) VALUES( pr_cdcooper
																			         ,pr_nrdconta
																							 ,pr_dtmvtolt
																							 ,nvl(vr_vlultsld, 0)
																							 ,vr_vllancto
																							 );
			--
		EXCEPTION
			WHEN dup_val_on_index THEN
				BEGIN
					--
					UPDATE tbfin_recursos_saldo
					   SET vlsaldo_final = vlsaldo_final - vr_vllancto
					 WHERE cdcooper = pr_cdcooper
					   AND nrdconta = pr_nrdconta
						 AND dtmvtolt = pr_dtmvtolt;
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao atualizar o saldo: ' || SQLERRM;
				END;
			WHEN OTHERS THEN
				pr_dscritic := 'Erro ao inserir o saldo: ' || SQLERRM;
		END;
		--
	END pc_atualiza_saldo;
	
	/* Gerar registro de Retorno = 23 - Remessa a cart�rio */
  PROCEDURE pc_proc_remessa_cartorio (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
		                                 ,pr_cdbanpag IN INTEGER                  -- codigo do banco de pagamento
														         ,pr_cdagepag IN INTEGER                  -- codigo da agencia de pagamento
                                     ,pr_idtabcob IN ROWID                    -- Rowid da Cobranca
                                     ,pr_dtocorre IN DATE                     -- data da ocorrencia
                                     ,pr_vltarifa IN NUMBER                   -- Valor da tarifa
                                     ,pr_cdhistor IN NUMBER                   -- Codigo do historico
                                     ,pr_cdocorre IN INTEGER                  -- Codigo Ocorrencia
                                     ,pr_dsmotivo IN VARCHAR2                 -- Descricao Motivo
                                     ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- Data movimento
                                     ,pr_cdoperad IN VARCHAR2                 -- Codigo Operador
                                     ,pr_ret_nrremret OUT INTEGER             -- Numero Remessa Retorno Cooperado
                                     ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada -- Tabela lancamentos consolidada
                                      /* parametros de erro */
                                     ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS            -- Descricao critica
    /* ..........................................................................
    --
    --  Programa : pc_proc_remessa_cartorio
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Supero
    --  Data     : Abril/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Enviar registro de Retorno = 23 - Remessa a cart�rio
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    --Encontrar ultima remessa
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                      ,pr_nrcnvcob IN craprem.nrcnvcob%type
                      ,pr_nrdconta IN craprem.nrdconta%type
                      ,pr_nrdocmto IN craprem.nrdocmto%type
                      ,pr_dtmvtolt IN craprem.dtaltera%type) IS
      SELECT craprem.nrseqreg
        FROM craprem
       WHERE craprem.cdcooper = pr_cdcooper
         AND craprem.nrcnvcob = pr_nrcnvcob
         AND craprem.nrdconta = pr_nrdconta
         AND craprem.nrdocmto = pr_nrdocmto
         AND craprem.cdocorre IN ( 2,10)
         AND craprem.dtaltera <= pr_dtmvtolt
       ORDER BY craprem.progress_recid DESC; --FIND LAST
    rw_craprem cr_craprem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(4000);

    --variavel de descri��o para log
    vr_dsmotivo  VARCHAR2(100);
    vr_nrremret  crapret.nrremret%type;
    vr_rowid_ret rowid;
    vr_nrseqreg  integer;


  BEGIN

    --Inicializar variaveis retorno
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Selecionar registro cobranca
    OPEN cr_crapcob (pr_rowid => pr_idtabcob);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcob;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /** Atualiza crapcob */
    BEGIN
      UPDATE CRAPCOB
         SET crapcob.insitcrt = 3, /* com remessa a cart�rio */
             crapcob.dtsitcrt = pr_dtocorre,
             crapcob.dtbloque = pr_dtocorre
       WHERE crapcob.rowid    = pr_idtabcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel atualizar crapcob: '||SQLErrm;
        --Levantar Excecao
        RAISE vr_exc_erro;
    END;
		
		PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
																				,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia /* 24. Retir. Cartor. */
																				,pr_tplancto => 'T'              --Tipo Lancamento  /* tplancto = "C" Cartorio */
																				,pr_vltarifa => 0                --Valor Tarifa
																				,pr_cdhistor => 0                --Codigo Historico
																				,pr_cdmotivo => NULL             --Codigo motivo
																				,pr_tab_lcm_consolidada => pr_tab_lcm_consolidada --Tabela de Lancamentos
																				,pr_cdcritic => vr_cdcritic      --Codigo Critica
																				,pr_dscritic => vr_dscritic);    --Descricao Critica

    /* Preparar Lote de Retorno Cooperado */
    PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => rw_crapcob.rowid    --ROWID da cobranca
                                       ,pr_cdocorre => pr_cdocorre         --Codigo Ocorrencia
                                       ,pr_dsmotivo => NULL                --Descricao Motivo
                                       ,pr_dtmvtolt => pr_crapdat.dtmvtolt --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => pr_ret_nrremret     --Numero Remessa
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
		--
		paga0001.pc_prepara_retorno_cooperativa(pr_idtabcob => rw_crapcob.rowid
                                           ,pr_dtmvtolt => pr_crapdat.dtmvtolt
                                           ,pr_dtocorre => pr_dtocorre
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_vlabatim => 0
                                           ,pr_vldescto => 0
                                           ,pr_vljurmul => 0
                                           ,pr_vlrpagto => 0
                                           ,pr_vltarifa => 0
																					 ,pr_vloutdes => pr_vltarifa
                                           ,pr_flgdesct => FALSE
                                           ,pr_flcredit => FALSE
                                           ,pr_nrretcoo => pr_ret_nrremret
                                           ,pr_cdmotivo => pr_dsmotivo
                                           ,pr_cdocorre => pr_cdocorre
                                           ,pr_cdbanpag => pr_cdbanpag
                                           ,pr_cdagepag => pr_cdagepag
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           );

    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

		-- Criar Log Cobranca
		vr_dsmotivo:= 'Confirmada entrada em cart�rio';
		PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
																 ,pr_cdoperad => pr_cdoperad        --Operador
																 ,pr_dtmvtolt => pr_crapdat.dtmvtolt--Data movimento
																 ,pr_dsmensag => vr_dsmotivo        --Descricao Mensagem
																 ,pr_des_erro => vr_des_erro        --Indicador erro
																 ,pr_dscritic => vr_dscritic);      --Descricao erro
		--Se ocorreu erro
		IF vr_des_erro = 'NOK' THEN
			--Levantar Excecao
			RAISE vr_exc_erro;
		END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina PAGA0002.pc_proc_remessa_cartorio '||sqlerrm;
  END pc_proc_remessa_cartorio;
	-- Gera lan�amentos de estorno
	PROCEDURE pc_processa_estorno(pr_cdcooper IN  craplot.cdcooper%TYPE
		                           ,pr_dtmvtolt IN  craplot.dtmvtolt%TYPE
															 ,pr_nrdconta IN  crapcob.nrdconta%TYPE
															 ,pr_nrcnvcob IN  crapcob.nrcnvcob%TYPE
															 ,pr_nrdocmto IN  crapcob.nrdocmto%TYPE
															 ,pr_vllanmto IN  craplcm.vllanmto%TYPE
															 ,pr_dscritic OUT VARCHAR2
		                           ) IS
    --
		CURSOR cr_crapcop(pr_cdcooper craplot.cdcooper%TYPE
		                 ) IS
		  SELECT crapcop.nrctactl
			  FROM crapcop
			 WHERE crapcop.cdcooper <> 3
			   AND crapcop.flgativo = 1
				 AND crapcop.cdcooper = pr_cdcooper;
		--
		rw_crapcop cr_crapcop%ROWTYPE;
		--
		CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
		                 ,pr_cdhistor craphis.cdhistor%TYPE
		                 ) IS
      SELECT craphis.indebcre
			  FROM craphis
			 WHERE craphis.cdcooper = pr_cdcooper
			   AND craphis.cdhistor = pr_cdhistor; 
		--
		rw_craphis cr_craphis%ROWTYPE;
    --
		CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
		                 ,pr_nrdconta crapcob.nrdconta%TYPE
										 ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
										 ,pr_nrdocmto crapcob.nrdocmto%TYPE
		                 ) IS
		--
		  SELECT crapcob.rowid
			  FROM crapcob
			 WHERE crapcob.cdcooper = pr_cdcooper
			   AND crapcob.nrdconta = pr_nrdconta
				 AND crapcob.nrcnvcob = pr_nrcnvcob
				 AND crapcob.nrdocmto = pr_nrdocmto;
		--
		rw_crapcob cr_crapcob%ROWTYPE;
		--
		vr_cdcritic NUMBER;
		vr_dscritic VARCHAR2(4000);
		vr_sqdoclan NUMBER;
		vr_idlancto NUMBER;
		--
		vr_nrretcoo            NUMBER;
		vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
		rw_crapdat             btch0001.cr_crapdat%ROWTYPE;
		rw_craplot             cobr0011.cr_craplot%ROWTYPE;
		--
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		-- Leitura do calendario da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat
		 INTO rw_crapdat;
		-- Se nao encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			-- Fechar o cursor pois efetuaremos raise
			CLOSE btch0001.cr_crapdat;
			-- Montar mensagem de critica
			pr_dscritic := 'Data movimento nao encontrada!';
			RAISE vr_exc_erro;
		ELSE
			-- Apenas fechar o cursor
			CLOSE btch0001.cr_crapdat;
		END IF;
		--
		OPEN cr_crapcob(pr_cdcooper
									 ,pr_nrdconta
									 ,pr_nrcnvcob
									 ,pr_nrdocmto
									 );
    --
		FETCH cr_crapcob INTO rw_crapcob;
		--
		IF cr_crapcob%NOTFOUND THEN
			--
			pr_dscritic := 'Boleto nao encontrado!';
			RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_crapcob;
		--
		cobr0011.pc_proc_outros_creditos(pr_cdcooper            => 3                      -- IN     -- Fixo
																		,pr_idtabcob            => rw_crapcob.rowid       -- IN
																		,pr_cdbanpag            => 0                      -- IN     -- Fixo
																		,pr_cdagepag            => 0                      -- IN     -- Fixo
																		,pr_vloutcre            => pr_vllanmto            -- IN     -- Fixo
																		,pr_dtocorre            => rw_crapdat.dtmvtolt    -- IN
																		,pr_cdocorre            => 89                     -- IN     -- Fixo
																		,pr_dsmotivo            => '99'                   -- IN     -- Fixo
																		,pr_crapdat             => rw_crapdat             -- IN
																		,pr_cdoperad            => '1'                    -- IN     -- Fixo
																		,pr_ret_nrremret        => vr_nrretcoo            -- OUT    -- Fixo
																		,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN OUT -- Fixo
																		,pr_cdhistor            => 2634                   -- IN     -- Fixo
																		,pr_cdcritic            => vr_cdcritic            -- OUT
																		,pr_dscritic            => vr_dscritic            -- OUT
																		);
		--
		IF pr_dscritic IS NOT NULL THEN
			--
			RAISE vr_exc_erro;
			--
		END IF;
		--
		cobr0011.pc_insere_lote(pr_cdcooper => 3           -- IN -- Fixo
		                       ,pr_dtmvtolt => pr_dtmvtolt -- IN
													 ,pr_cdagenci => 1           -- IN -- Fixo
													 ,pr_cdbccxlt => 85          -- IN -- Fixo
													 ,pr_nrdolote => 7200        -- IN -- Fixo
													 ,pr_cdoperad => '1'         -- IN -- Fixo
													 ,pr_nrdcaixa => 0           -- IN -- Fixo
													 ,pr_tplotmov => 1           -- IN -- Fixo
													 ,pr_cdhistor => 2639        -- IN -- Fixo
													 ,pr_craplot  => rw_craplot  -- OUT
													 ,pr_dscritic => pr_dscritic -- OUT
													 );
		--
		IF pr_dscritic IS NOT NULL THEN
			--
			RAISE vr_exc_erro;
			--
		END IF;
		--
		OPEN cr_crapcop(pr_cdcooper
		               );
		--
		FETCH cr_crapcop INTO rw_crapcop;
		--
		IF cr_crapcop%NOTFOUND THEN
			--
			--vr_cdcritic := 0;
			vr_dscritic := 'Cooperativa n�o encontrada: ' || pr_cdcooper;
			RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_crapcop;
		-- Gerar novo titulo usando a fn_sequence 
		vr_sqdoclan := fn_sequence(pr_nmtabela => 'CRAPLCM'
															,pr_nmdcampo => 'NRDOCMTO'
															,pr_dsdchave => pr_cdcooper || ';'
																					 || pr_dtmvtolt || ';'
																					 || rw_craplot.nrdolote
															);
		-- Criar lan�amento na cooperativa
		BEGIN
			--
			INSERT INTO craplcm(craplcm.cdagenci
												 ,craplcm.cdbccxlt
												 ,craplcm.cdcooper
												 ,craplcm.cdhistor
												 ,craplcm.cdoperad
												 ,craplcm.cdpesqbb
												 ,craplcm.dtmvtolt
												 ,craplcm.dtrefere
												 ,craplcm.hrtransa
												 ,craplcm.nrautdoc
												 ,craplcm.nrdconta
												 ,craplcm.nrdctabb
												 ,craplcm.nrdctitg
												 ,craplcm.nrdocmto
												 ,craplcm.nrdolote
												 ,craplcm.nrseqdig
												 ,craplcm.vllanmto
												 ,craplcm.cdcoptfn
												 ,craplcm.cdagetfn
												 ,craplcm.nrterfin
												 ) VALUES(rw_craplot.cdagenci         -- cdagenci
																 ,rw_craplot.cdbccxlt         -- cdbccxlt
																 ,3                           -- cdcooper -- Fixo
																 ,rw_craplot.cdhistor         -- cdhistor
																 ,rw_craplot.cdoperad         -- cdoperad
																 ,'ESTORNO PROTESTO'          -- cdpesqbb
																 ,rw_craplot.dtmvtolt         -- dtmvtolt
																 ,rw_craplot.dtmvtolt         -- dtrefere
																 ,GENE0002.fn_busca_time      -- hrtransa
																 ,0                           -- nrautdoc -- Fixo
																 ,rw_crapcop.nrctactl         -- nrdconta
																 ,rw_crapcop.nrctactl         -- nrdctabb
																 ,' '                         -- nrdctitg -- Fixo
																 ,vr_sqdoclan                 -- nrdocmto
																 ,rw_craplot.nrdolote         -- nrdolote
																 ,nvl(rw_craplot.nrseqdig,0)  -- nrseqdig
																 ,pr_vllanmto                 -- vllanmto
																 ,0                           -- cdcoptfn -- Fixo
																 ,0                           -- cdagetfn -- Fixo
																 ,0                           -- nrterfin -- Fixo
																 );
		  --
		EXCEPTION
			WHEN OTHERS THEN
				--vr_cdcritic := 0;
				vr_dscritic := 'Erro ao inserir na tabela craplcm: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		OPEN cr_craphis(pr_cdcooper => pr_cdcooper
									 ,pr_cdhistor => 2640
									 );
		--
		FETCH cr_craphis INTO rw_craphis;
		--
		IF cr_craphis%NOTFOUND THEN
			--
			--vr_cdcritic := 0;
			vr_dscritic := 'Contrapartida do hist�rico 2640 n�o encontrada!';
			CLOSE cr_craphis;
			RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_craphis;
		-- Criar lan�amento na central
		BEGIN
			-- Gerar novo movimento usando a fn_sequence 
			vr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
													 		  ,pr_nmdcampo => 'IDLANCTO'
																,pr_dsdchave => 'IDLANCTO'
																);
			--
			INSERT INTO tbfin_recursos_movimento(cdcooper
																					,nrdconta
																					,dtmvtolt
																					,nrdocmto
																					,nrseqdig
																					,cdhistor
																					,dsdebcre
																					,vllanmto
																					,nmif_debitada
																					,nrcnpj_debitada
																					,nmtitular_debitada
																					,tpconta_debitada
																					,cdagenci_debitada
																					,dsconta_debitada
																					,nrispbif
																					,nrcnpj_creditada
																					,nmtitular_creditada
																					,tpconta_creditada
																					,cdagenci_creditada
																					,dsconta_creditada
																					,hrtransa
																					,cdoperad
																					,dsinform
																					,idlancto
																					) VALUES(3                          -- cdcooper -- Fixo
																									,rw_crapcop.nrctactl        -- nrdconta
																									,rw_craplot.dtmvtolt        -- dtmvtolt
																									,vr_sqdoclan                -- nrdocmto
																									,nvl(rw_craplot.nrseqdig,0) -- nrseqdig
																									,2640                       -- cdhistor -- Fixo
																									,rw_craphis.indebcre        -- dsdebcre
																									,pr_vllanmto                -- vllanmto
																									,' '                        -- nmif_debitada -- Fixo
																									,0                          -- nrcnpj_debitada -- Fixo
																									,' '                        -- nmtitular_debitada -- Fixo
																									,' '                        -- tpconta_debitada -- Fixo
																									,0                          -- cdagenci_debitada -- Fixo
																									,' '                        -- dsconta_debitada -- Fixo
																									,0                          -- nrispbif -- Fixo
																									,0                          -- nrcnpj_creditada -- Fixo
																									,' '                        -- nmtitular_creditada -- Fixo
																									,' '                        -- tpconta_creditada -- Fixo
																									,0                          -- cdagenci_creditada -- Fixo
																									,' '                        -- dsconta_creditada -- Fixo
																									,GENE0002.fn_busca_time     -- hrtransa
																									,rw_craplot.cdoperad        -- cdoperad
																									,' '                        -- dsinform -- Fixo
																									,vr_idlancto                -- idlancto
																									);
		  --
		EXCEPTION
			WHEN OTHERS THEN
				--vr_cdcritic := 0;
				vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_movimento: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Atualiza o saldo
		pc_atualiza_saldo(pr_cdcooper => 3                   -- IN -- Fixo
										 ,pr_nrdconta => rw_crapcop.nrctactl -- IN
										 ,pr_dtmvtolt => rw_craplot.dtmvtolt -- IN
										 ,pr_vllanmto => pr_vllanmto         -- IN
										 ,pr_dsdebcre => rw_craphis.indebcre -- IN
										 ,pr_dscritic => vr_dscritic         -- OUT
										 );
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			pr_dscritic :=nvl(pr_dscritic, vr_dscritic);
		WHEN OTHERS THEN
			--vr_cdcritic := 0;
			vr_dscritic := 'Erro na pc_processa_lancamento: ' || SQLERRM;
			pr_dscritic := vr_dscritic;
	END pc_processa_estorno;
	-- Gera o lote e o lan�amento
	PROCEDURE pc_processa_lancamento(pr_cdcooper IN  craplot.cdcooper%TYPE
                                  ,pr_nrdconta IN tbfin_recursos_movimento.nrdconta%TYPE
		                              ,pr_dtmvtolt IN  craplot.dtmvtolt%TYPE
																	,pr_cdagenci IN  craplot.cdagenci%TYPE
																	,pr_cdoperad IN  craplot.cdoperad%TYPE
																	,pr_cdhistor IN  craplot.cdhistor%TYPE
																	,pr_vllanmto IN  craplcm.vllanmto%TYPE
																	,pr_nmarqtxt IN  VARCHAR2
																	,pr_craplot  OUT cobr0011.cr_craplot%ROWTYPE
																	,pr_dscritic OUT VARCHAR2
		                              ) IS
    --
		CURSOR cr_crapcop(pr_cdcooper craplot.cdcooper%TYPE
		                 ) IS
		  SELECT crapcop.nrctactl
			  FROM crapcop
			 WHERE crapcop.cdcooper <> 3
			   AND crapcop.flgativo = 1
				 AND crapcop.cdcooper = pr_cdcooper;
		--
		rw_crapcop cr_crapcop%ROWTYPE;
		--
		CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
		                 ,pr_cdhistor craphis.cdhistor%TYPE
		                 ) IS
      SELECT craphis.indebcre
			  FROM craphis
			 WHERE craphis.cdcooper = pr_cdcooper
			   AND craphis.cdhistor = pr_cdhistor; 
		--
		rw_craphis cr_craphis%ROWTYPE;
		--
		--rw_craplot cobr0011.cr_craplot%ROWTYPE;
		--
		--vr_cdcritic NUMBER;
		vr_dscritic VARCHAR2(4000);
		vr_cdhistor craplot.cdhistor%TYPE;
		vr_sqdoclan NUMBER;
		vr_idlancto NUMBER;
		--
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		--
		cobr0011.pc_insere_lote(pr_cdcooper => 3           -- IN -- Fixo
		                       ,pr_dtmvtolt => pr_dtmvtolt -- IN
													 ,pr_cdagenci => pr_cdagenci -- IN
													 ,pr_cdbccxlt => 85          -- IN -- Fixo
													 ,pr_nrdolote => 7200        -- IN -- Fixo
													 ,pr_cdoperad => pr_cdoperad -- IN
													 ,pr_nrdcaixa => 0           -- IN -- Fixo
													 ,pr_tplotmov => 1           -- IN -- Fixo
													 ,pr_cdhistor => pr_cdhistor -- IN
													 ,pr_craplot  => pr_craplot  -- OUT
													 ,pr_dscritic => pr_dscritic -- OUT
													 );
		--
		IF pr_dscritic IS NOT NULL THEN
			--
			RAISE vr_exc_erro;
			--
		END IF;
		--
		OPEN cr_crapcop(pr_cdcooper
		               );
		--
		FETCH cr_crapcop INTO rw_crapcop;
		--
		IF cr_crapcop%NOTFOUND THEN
			--
			--vr_cdcritic := 0;
			vr_dscritic := 'Cooperativa n�o encontrada: ' || pr_cdcooper;
			RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_crapcop;
		-- Gerar novo titulo usando a fn_sequence 
		vr_sqdoclan := fn_sequence(pr_nmtabela => 'CRAPLCM'
															,pr_nmdcampo => 'NRDOCMTO'
															,pr_dsdchave => pr_cdcooper || ';'
																					 || pr_dtmvtolt || ';'
																					 || pr_craplot.nrdolote
															);
		-- Criar lan�amento na cooperativa
		BEGIN
			--
			INSERT INTO craplcm(craplcm.cdagenci
												 ,craplcm.cdbccxlt
												 ,craplcm.cdcooper
												 ,craplcm.cdhistor
												 ,craplcm.cdoperad
												 ,craplcm.cdpesqbb
												 ,craplcm.dtmvtolt
												 ,craplcm.dtrefere
												 ,craplcm.hrtransa
												 ,craplcm.nrautdoc
												 ,craplcm.nrdconta
												 ,craplcm.nrdctabb
												 ,craplcm.nrdctitg
												 ,craplcm.nrdocmto
												 ,craplcm.nrdolote
												 ,craplcm.nrseqdig
												 ,craplcm.vllanmto
												 ,craplcm.cdcoptfn
												 ,craplcm.cdagetfn
												 ,craplcm.nrterfin
												 ) VALUES(pr_craplot.cdagenci         -- cdagenci
																 ,pr_craplot.cdbccxlt         -- cdbccxlt
																 ,3                           -- cdcooper -- Fixo
																 ,pr_cdhistor -- pr_craplot.cdhistor         -- cdhistor
																 ,pr_craplot.cdoperad         -- cdoperad
																 ,TRIM(pr_nmarqtxt)           -- cdpesqbb
																 ,pr_craplot.dtmvtolt         -- dtmvtolt
																 ,pr_craplot.dtmvtolt         -- dtrefere
																 ,GENE0002.fn_busca_time      -- hrtransa
																 ,0                           -- nrautdoc -- Fixo
																 ,rw_crapcop.nrctactl         -- nrdconta
																 ,rw_crapcop.nrctactl         -- nrdctabb
																 ,' '                         -- nrdctitg -- Fixo
																 ,vr_sqdoclan                 -- nrdocmto
																 ,pr_craplot.nrdolote         -- nrdolote
																 ,nvl(pr_craplot.nrseqdig,0)  -- nrseqdig
																 ,pr_vllanmto                 -- vllanmto
																 ,0                           -- cdcoptfn -- Fixo
																 ,0                           -- cdagetfn -- Fixo
																 ,0                           -- nrterfin -- Fixo
																 );
		  --
		EXCEPTION
			WHEN OTHERS THEN
				--vr_cdcritic := 0;
				vr_dscritic := 'Erro ao inserir na tabela craplcm: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Busca o c�digo de hist�rico da contrapartida
		CASE
			WHEN pr_cdhistor = 2635 THEN
				--
				vr_cdhistor := 2636;
				--
		  WHEN pr_cdhistor = 2643 THEN
				--
				vr_cdhistor := 2644;
				--
			WHEN pr_cdhistor = 2623 THEN
				--
				vr_cdhistor := 2624;
				--
			ELSE
				--
				--vr_cdcritic := 0;
				vr_dscritic := 'Contrapartida do hist�rico ' || pr_cdhistor || ' n�o encontrada!';
				RAISE vr_exc_erro;
				--
		END CASE;
		--
		OPEN cr_craphis(pr_cdcooper => pr_cdcooper
									 ,pr_cdhistor => vr_cdhistor
									 );
		--
		FETCH cr_craphis INTO rw_craphis;
		--
		IF cr_craphis%NOTFOUND THEN
			--
			--vr_cdcritic := 0;
			vr_dscritic := 'Contrapartida do hist�rico ' || pr_cdhistor || ' n�o encontrada!';
			CLOSE cr_craphis;
			RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_craphis;
		-- Criar lan�amento na central
		BEGIN
			-- Gerar novo movimento usando a fn_sequence 
			vr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
													 		  ,pr_nmdcampo => 'IDLANCTO'
																,pr_dsdchave => 'IDLANCTO'
																);
			--
			INSERT INTO tbfin_recursos_movimento(cdcooper
																					,nrdconta
																					,dtmvtolt
																					,nrdocmto
																					,nrseqdig
																					,cdhistor
																					,dsdebcre
																					,vllanmto
																					,nmif_debitada
																					,nrcnpj_debitada
																					,nmtitular_debitada
																					,tpconta_debitada
																					,cdagenci_debitada
																					,dsconta_debitada
																					,nrispbif
																					,nrcnpj_creditada
																					,nmtitular_creditada
																					,tpconta_creditada
																					,cdagenci_creditada
																					,dsconta_creditada
																					,hrtransa
																					,cdoperad
																					,dsinform
																					,idlancto
																					) VALUES(3                          -- cdcooper -- Fixo
																									,pr_nrdconta                -- nrdconta conta recurso movimento
																									,pr_craplot.dtmvtolt        -- dtmvtolt
																									,vr_sqdoclan                -- nrdocmto
																									,nvl(pr_craplot.nrseqdig,0) -- nrseqdig
																									,vr_cdhistor                -- cdhistor
																									,rw_craphis.indebcre        -- dsdebcre
																									,pr_vllanmto                -- vllanmto
																									,' '                        -- nmif_debitada -- Fixo
																									,0                          -- nrcnpj_debitada -- Fixo
																									,' '                        -- nmtitular_debitada -- Fixo
																									,' '                        -- tpconta_debitada -- Fixo
																									,0                          -- cdagenci_debitada -- Fixo
																									,' '                        -- dsconta_debitada -- Fixo
																									,0                          -- nrispbif -- Fixo
																									,0                          -- nrcnpj_creditada -- Fixo
																									,' '                        -- nmtitular_creditada -- Fixo
																									,' '                        -- tpconta_creditada -- Fixo
																									,0                          -- cdagenci_creditada -- Fixo
																									,' '                        -- dsconta_creditada -- Fixo
																									,GENE0002.fn_busca_time     -- hrtransa
																									,pr_craplot.cdoperad        -- cdoperad
																									,' '                        -- dsinform -- Fixo
																									,vr_idlancto                -- idlancto
																									);
		  --
		EXCEPTION
			WHEN OTHERS THEN
				--vr_cdcritic := 0;
				vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_movimento: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Atualiza o saldo
		pc_atualiza_saldo(pr_cdcooper => 3                   -- IN -- Fixo
										 ,pr_nrdconta => pr_nrdconta         -- IN conta recurso movimento
										 ,pr_dtmvtolt => pr_craplot.dtmvtolt -- IN
										 ,pr_vllanmto => pr_vllanmto         -- IN
										 ,pr_dsdebcre => rw_craphis.indebcre -- IN
										 ,pr_dscritic => vr_dscritic         -- OUT
										 );
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			pr_dscritic :=nvl(pr_dscritic, vr_dscritic);
		WHEN OTHERS THEN
			--vr_cdcritic := 0;
			vr_dscritic := 'Erro na pc_processa_lancamento: ' || SQLERRM;
			pr_dscritic := vr_dscritic;
	END pc_processa_lancamento;
	-- Gera log em tabelas
  PROCEDURE pc_gera_log(pr_cdcooper     IN crapcop.cdcooper%type DEFAULT 3 -- Cooperativa
                       ,pr_dstiplog     IN VARCHAR2                        -- Tipo de Log
                       ,pr_dscritic     IN VARCHAR2 DEFAULT NULL           -- Descri��o do Log
                       ,pr_tpocorrencia IN VARCHAR2 dEFAULT 4              -- Tipo de Ocorr�ncia
                       ) IS
  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_log
  --  Sistema  : Rotina para gravar logs em tabelas
  --  Sigla    : CRED
  --  Autor    : Supero
  --  Data     : Mar�o/2018           Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Rotina executada em qualquer frequencia.
  -- Objetivo  : Controla grava��o de log em tabelas.
  --
  -- Alteracoes:  
  --             
  ------------------------------------------------------------------------------------------------------------   
  vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
  --vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
  --
  BEGIN         
    -- Controlar gera��o de log de execu��o dos jobs                                
    pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E') 
                          ,pr_cdprograma    => 'CRPS730'
                          ,pr_cdcooper      => pr_cdcooper
                          ,pr_tpexecucao    => 2 -- job
                          ,pr_tpocorrencia  => pr_tpocorrencia
                          ,pr_cdcriticidade => 0 -- baixa
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_idprglog      => vr_idprglog
                          ,pr_nmarqlog      => NULL
                          );
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Inclus�o na tabela de erros Oracle
      pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_gera_log;
	-- Totaliza por cooperativa
	PROCEDURE pc_totaliza_cooperativa(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                   ,pr_nrdconta IN  tbfin_recursos_movimento.nrdconta%TYPE
		                               ,pr_vlpagmto IN  NUMBER
		                               ,pr_dscritic OUT VARCHAR2
		                               ) IS
	  --
		vr_achou      BOOLEAN := FALSE;
		vr_index_coop NUMBER  := 0;
		--
		vr_reg_coop   typ_reg_coop;
		--
	BEGIN
		--
		IF vr_tab_coop.count() > 0 THEN
			--
			WHILE vr_index_coop IS NOT NULL LOOP
				--
				IF vr_tab_coop(vr_index_coop).cdcooper = pr_cdcooper THEN
					--
					vr_achou := TRUE;
					--
					vr_tab_coop(vr_index_coop).vlpagmto := vr_tab_coop(vr_index_coop).vlpagmto + pr_vlpagmto;
          vr_tab_coop(vr_index_coop).nrdconta := pr_nrdconta; -- conta recurso movimento
					--
				END IF;
				-- Pr�ximo registro
				vr_index_coop := vr_tab_coop.next(vr_index_coop);
				--
			END LOOP;
			--
		END IF;
		--
		IF NOT vr_achou THEN
			--
			vr_reg_coop.cdcooper := pr_cdcooper;
			vr_reg_coop.vlpagmto := pr_vlpagmto;
      vr_reg_coop.nrdconta := pr_nrdconta;
			--
			vr_tab_coop(vr_tab_coop.count()) := vr_reg_coop;
			--
		END IF;
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro na pc_totaliza_cooperativa: ' || SQLERRM;
	END pc_totaliza_cooperativa;
	--
	PROCEDURE pc_gera_movimento_pagamento(pr_dscritic OUT VARCHAR2
		                                   ) IS
    --
		CURSOR cr_conciliados IS
		  SELECT crapcob.rowid crapcob_id
			      ,tri.rowid retorno_id
			      ,crapcob.cdcooper
						,crapcob.nrcnvcob
						,crapcob.nrdconta
						,crapcob.nrdocmto
			      ,crapcob.nrnosnum
						,crapcop.cdbcoctl
            ,crapcop.cdagectl
						,crapcob.vltitulo
						,tri.vltitulo vlliquid
						,tri.vlsaldo_titulo
						,crapdat.dtmvtolt
            ,trm.nrdconta nrdconta_trm
						,crapcco.nrdolote
						,crapcco.cdagenci
						,crapcco.cdbccxlt
						,crapcco.nrconven
						,tci.rowid
				FROM tbcobran_conciliacao_ieptb tci
						,tbfin_recursos_movimento   trm
						,tbcobran_retorno_ieptb     tri
						,crapcob
						,crapcop
						,crapdat
						,crapcco
			 WHERE crapcob.cdcooper = crapcop.cdcooper
			   AND crapcob.cdcooper = crapdat.cdcooper
         --AND crapcop.cdagectl = pr_cdagectl				 
			   AND crapcob.cdcooper    = tri.cdcooper
				 AND crapcob.nrdconta    = tri.nrdconta
				 AND crapcob.nrcnvcob    = tri.nrcnvcob
				 AND crapcob.nrdocmto    = tri.nrdocmto
				 AND tci.idrecurso_movto = trm.idlancto
				 AND tci.idretorno_ieptb = tri.idretorno
				 AND crapcco.cdcooper    = crapcob.cdcooper
				 AND crapcco.nrconven    = crapcob.nrcnvcob
				 AND tci.dtconcilicao    IS NOT NULL
				 AND tri.dtconciliacao   IS NOT NULL
				 AND tci.flgproc         = 0
				 AND tri.tpocorre        = 1;
		--
		rw_conciliados cr_conciliados%ROWTYPE;
		--
		CURSOR cr_crapret(pr_cdcooper crapret.cdcooper%TYPE
                     ,pr_nrcnvcob crapret.nrcnvcob%TYPE
                     ,pr_nrdconta crapret.nrdconta%TYPE
                     ,pr_nrdocmto crapret.nrdocmto%TYPE
                     ,pr_dtocorre crapret.dtocorre%TYPE
                     ,pr_cdocorre crapret.cdocorre%TYPE
                     ,pr_cdmotivo crapret.cdmotivo%TYPE
                     ) IS
      SELECT crapret.nrremret
            ,crapret.nrseqreg
        FROM crapret
       WHERE crapret.cdcooper = pr_cdcooper
         AND crapret.nrcnvcob = pr_nrcnvcob
         AND crapret.nrdconta = pr_nrdconta
         AND crapret.nrdocmto = pr_nrdocmto
         AND crapret.dtocorre = pr_dtocorre
         AND crapret.cdocorre = pr_cdocorre
         AND nvl(crapret.cdmotivo, 0) = nvl(pr_cdmotivo, 0);
		--
    rw_crapret cr_crapret%ROWTYPE;
		--
		vr_index_coop NUMBER;
		vr_nrretcoo   NUMBER;
		vr_cdcritic   NUMBER;
		vr_cdcritic2  INTEGER;
    vr_dscritic   VARCHAR2(4000);
		vr_vloutcre   NUMBER;
		--
		vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
		vr_tab_descontar       PAGA0001.typ_tab_titulos;
		rw_craplot             cobr0011.cr_craplot%ROWTYPE;
		--
		vr_exc_erro  EXCEPTION;
		--
	BEGIN
		--
		OPEN cr_conciliados;
		--
		LOOP
			--
			FETCH cr_conciliados INTO rw_conciliados;
			EXIT WHEN cr_conciliados%NOTFOUND;
      
			--
			IF rw_conciliados.vlsaldo_titulo > rw_conciliados.vlliquid THEN
				--
				vr_vloutcre := rw_conciliados.vlsaldo_titulo - rw_conciliados.vlliquid;
				--
			ELSE
				--
				vr_vloutcre := 0;
				--
			END IF;
			-- Processar liquidacao
			paga0001.pc_processa_liquidacao(pr_idtabcob            => rw_conciliados.crapcob_id               -- Rowid da Cobranca
																		 ,pr_nrnosnum            => rw_conciliados.nrnosnum                 -- Nosso Numero
																		 ,pr_cdbanpag            => rw_conciliados.cdbcoctl                 -- Codigo banco pagamento
																		 ,pr_cdagepag            => rw_conciliados.cdagectl                 -- Codigo Agencia pagamento
																		 ,pr_vltitulo            => rw_conciliados.vltitulo                 -- Valor do titulo
																		 ,pr_vlliquid            => rw_conciliados.vlliquid                 -- Valor liquidacao
																		 ,pr_vlrpagto            => rw_conciliados.vlsaldo_titulo           -- Valor pagamento
																		 ,pr_vlabatim            => 0                                       -- Valor abatimento
																		 ,pr_vldescto            => 0                                       -- Valor desconto
																		 ,pr_vlrjuros            => 0                                       -- Valor juros
																		 ,pr_vloutdeb            => 0                                       -- Valor saida debito
																		 ,pr_vloutcre            => vr_vloutcre                             -- Valor saida credito
																		 ,pr_dtocorre            => rw_conciliados.dtmvtolt                 -- Data Ocorrencia
																		 ,pr_dtcredit            => rw_conciliados.dtmvtolt                 -- Data Credito
																		 ,pr_cdocorre            => 6                                       -- Codigo Ocorrencia
																		 ,pr_dsmotivo            => '08'                                    -- Descricao Motivo
																		 ,pr_dtmvtolt            => rw_conciliados.dtmvtolt                 -- Data movimento
																		 ,pr_cdoperad            => '1'                                     -- Codigo Operador
																		 ,pr_indpagto            => 0                                       -- Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA
																		 ,pr_ret_nrremret        => vr_nrretcoo                             -- Numero remetente
																		 ,pr_cdcritic            => vr_cdcritic                             -- Codigo Critica
																		 ,pr_dscritic            => vr_dscritic                             -- Descricao Critica
																		 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada                  -- Tabela lancamentos consolidada
																		 ,pr_tab_descontar       => vr_tab_descontar                        -- Tabela de titulos
																		 );
			--
			IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Buscar a descricao
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic
																								,vr_dscritic
																								);
				-- Padroniza��o de logs
				pc_gera_log(pr_cdcooper     => rw_crapcob.cdcooper
									 ,pr_dstiplog     => 'E'
									 ,pr_dscritic     =>  vr_dscritic
									 ,pr_tpocorrencia => 2 -- Erro Tratado
									 );
			  --
				RAISE vr_exc_erro;
				--
			END IF;
      
			PAGA0001.pc_realiza_lancto_cooperado(pr_cdcooper => rw_conciliados.cdcooper --Codigo Cooperativa
																					,pr_dtmvtolt => rw_conciliados.dtmvtolt --Data Movimento
																					,pr_cdagenci => rw_conciliados.cdagenci --Codigo Agencia
																					,pr_cdbccxlt => rw_conciliados.cdbccxlt --Codigo banco caixa
																					,pr_nrdolote => rw_conciliados.nrdolote --rw_crapcco.nrdolote --Numero do Lote
																					,pr_cdpesqbb => rw_conciliados.nrconven --rw_crapcco.nrconven --Codigo Convenio
																					,pr_cdcritic => vr_cdcritic         --Codigo Critica
																					,pr_dscritic => vr_dscritic         --Descricao Critica
																					,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada        --Tabela Lancamentos
																					);

		 --Se ocorreu erro
		 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
			 --Levantar Excecao
			 RAISE vr_exc_erro;
		 END IF;
			--
			vr_tab_lcm_consolidada.delete;
			--
			OPEN cr_crapret(pr_cdcooper => rw_conciliados.cdcooper
										 ,pr_nrcnvcob => rw_conciliados.nrcnvcob
										 ,pr_nrdconta => rw_conciliados.nrdconta
										 ,pr_nrdocmto => rw_conciliados.nrdocmto
										 ,pr_dtocorre => rw_conciliados.dtmvtolt
										 ,pr_cdocorre => 6
										 ,pr_cdmotivo => '08'
										 );
			--
			FETCH cr_crapret INTO rw_crapret;
			--
			IF cr_crapret%NOTFOUND THEN
				--
				vr_dscritic := 'N�o encontrado o registro na CRAPRET.';
				RAISE vr_exc_erro;
				--
			END IF;
			--
			CLOSE cr_crapret;
			--
			BEGIN
				--
				UPDATE tbcobran_retorno_ieptb tri
				   SET tri.nrremret = rw_crapret.nrremret
					    ,tri.nrseqreg = rw_crapret.nrseqreg
				 WHERE tri.rowid = rw_conciliados.retorno_id;
				--
			EXCEPTION
				WHEN OTHERS THEN
					pr_dscritic := 'Erro ao atualiza o retorno: ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
			IF nvl(rw_conciliados.vlliquid, 0) > 0 THEN
				--
				pc_totaliza_cooperativa(pr_cdcooper => rw_conciliados.cdcooper         -- IN
                               ,pr_nrdconta => rw_conciliados.nrdconta_trm     -- Conta Recurso movimento
															 ,pr_vlpagmto => nvl(rw_conciliados.vlliquid, 0) -- IN
															 ,pr_dscritic => pr_dscritic                     -- OUT
															 );
				--
				IF pr_dscritic IS NOT NULL THEN
					--
					RAISE vr_exc_erro;
					--
				END IF;
				--
			END IF;
			--
			BEGIN
				--
				UPDATE tbcobran_conciliacao_ieptb tci
				   SET tci.flgproc = 1
				 WHERE tci.rowid = rw_conciliados.rowid;
				--
			EXCEPTION
				WHEN OTHERS THEN
					pr_dscritic := 'Erro ao atualizar a conciliacao: ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
		END LOOP;

		-- Gerar os lan�amentos por cooperativa e na central
		vr_index_coop := 0;
		--
		IF vr_tab_coop.COUNT() > 0 THEN
			--
			WHILE vr_index_coop IS NOT NULL LOOP
				--
				IF nvl(vr_tab_coop(vr_index_coop).vlpagmto, 0) > 0 THEN
					-- Gera lan�amento hist�rico 2623 
          -- Repasse de liquida��o dos boletos para as cooperativas
					pc_processa_lancamento(pr_cdcooper => vr_tab_coop(vr_index_coop).cdcooper -- IN
                                ,pr_nrdconta => vr_tab_coop(vr_index_coop).nrdconta -- IN
																,pr_dtmvtolt => rw_conciliados.dtmvtolt             -- IN
																,pr_cdagenci => 1                                   -- IN
																,pr_cdoperad => '1'                                 -- IN
																,pr_cdhistor => 2623                                -- IN
																,pr_vllanmto => vr_tab_coop(vr_index_coop).vlpagmto -- IN
																,pr_nmarqtxt => ' '-- vr_nmarquiv                   -- IN
																,pr_craplot  => rw_craplot                          -- OUT
																,pr_dscritic => pr_dscritic                         -- OUT
																);
					--
					IF pr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
				END IF;
				-- Pr�ximo registro
				vr_index_coop := vr_tab_coop.next(vr_index_coop);
				--
			END LOOP;
			--
		END IF;
		--
		--
		CLOSE cr_conciliados;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			pr_dscritic := nvl(pr_dscritic, vr_dscritic);
		WHEN OTHERS THEN
			pr_dscritic := 'Erro na pc_gera_movimento_pagamento: ' || SQLERRM;
	END pc_gera_movimento_pagamento;
	--
	PROCEDURE pc_enviar_email_teds (pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_dscritic OUT VARCHAR2) IS
 
  vr_dsdiretorio VARCHAR2(500);
  vr_arquivo VARCHAR2(500);

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(500);
  vr_retxml xmltype;
  vr_nmdcampo VARCHAR2(500);

  vr_exc_erro EXCEPTION;
      
  vr_email_dest VARCHAR2(500);
  vr_emails_cobranca tbcobran_param_protesto.dsemail_cobranca%TYPE;
  vr_emails_ieptb tbcobran_param_protesto.dsemail_ieptb%TYPE;
  
  vr_des_assunto VARCHAR2(500);
  vr_conteudo VARCHAR2(500);
  BEGIN
    
    BEGIN
      --
      SELECT tpp.dsemail_cobranca, tpp.dsemail_ieptb
        INTO vr_emails_cobranca, vr_emails_ieptb
        FROM tbcobran_param_protesto tpp
       WHERE tpp.cdcooper = pr_cdcooper;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel retornar os e-mails do protesto: ' || SQLERRM;
    END;
    
    IF (vr_emails_cobranca IS NULL or vr_emails_ieptb IS NULL) THEN
      vr_dscritic := 'O e-mail de cobran�a ou o e-mail do IEPTB n�o foi configurado.';
      RAISE vr_exc_erro;      
    END IF;
  
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';

    TELA_MANPRT.pc_exporta_consulta_teds(pr_cdcooper => pr_cdcooper
                                        ,pr_dtinicial => NULL
                                        ,pr_dtfinal => NULL
                                        ,pr_vlinicial => 0
                                        ,pr_vlfinal => 0
                                        ,pr_cartorio => NULL
                                        ,pr_nrregist => 0
                                        ,pr_nriniseq => 0
                                        ,pr_xmllog => NULL
                                        ,pr_flgcon => 0
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_retxml => vr_retxml
                                        ,pr_nmdcampo => vr_nmdcampo
                                        ,pr_des_erro => vr_cdcritic);
    
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_arquivo := TRIM(vr_retxml.extract('/nmarqcsv/text()').getstringval());
    vr_arquivo := vr_dsdiretorio || '/' || vr_arquivo;
    
    vr_des_assunto := 'CECRED - Extrato TEDs recebidas';
    vr_conteudo := 'Segue em anexo as TEDs recebidas e n�o conciliadas.';
    vr_email_dest := vr_emails_cobranca || ',' || vr_emails_ieptb;
    
    GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                              ,pr_cdprogra        => '' --> Programa conectado
                              ,pr_des_destino     => vr_email_dest --> Um ou mais detinat�rios separados por ';' ou ','
                              ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                              ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                              ,pr_des_anexo       => vr_arquivo     --> Um ou mais anexos separados por ';' ou ','
                              ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N'            --> Se o envio ser� do e-mail da Cooperativa
                              ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                              ,pr_des_email_reply => NULL           --> Endere�o para resposta ao e-mail
                              ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                              ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
                              
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'N�o foi possivel enviar o e-mail das TEDs n�o conciliadas: '||SQLERRM;

  END pc_enviar_email_teds;
	--
end cobr0011;
/
