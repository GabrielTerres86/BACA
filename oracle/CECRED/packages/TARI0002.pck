CREATE OR REPLACE PACKAGE CECRED.TARI0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TARI0002                         
  --  Autor   : Lucas Reinert
  --  Data    : Fevereiro/2013                  Ultima Atualizacao: 30/10/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Englobar procedures referente a tarifas
  --
  --  Alteracoes: 	  
  -- 
  -- 30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero) 
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_pacote_tarifas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
																	 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta    
 																	 ,pr_inpessoa IN crapass.inpessoa%TYPE --> Indicador de pessoa (1-fisica/2-juridica)
																	 ,pr_inconsul IN INTEGER               --> 0 - Consulta adesão / 1 - Consulta pacotes disponiveis  
																	 ,pr_clobxmlc OUT CLOB                 --> Clob com dados do beneficiario
																	 ,pr_cdcritic OUT INTEGER              --> Cód. da crítica
																	 ,pr_dscritic OUT VARCHAR2);           --> Desc. da crítica
																	 
	PROCEDURE pc_insere_pacote_conta (pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																	 ,pr_nrdconta IN crapass.nrdconta%TYPE               --> Nr. da conta      
																	 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE               --> CPF do operador juridico
																	 ,pr_idseqttl IN INTEGER                             --> Id. de sequencia do titular
																	 ,pr_cdpacote IN tbtarif_contas_pacote.cdpacote%TYPE --> Cód. pacote de tarifas
																	 ,pr_dtvigenc IN tbtarif_contas_pacote.dtinicio_vigencia%TYPE --> Data de inicio de vigencia
																	 ,pr_dtdiadbt IN tbtarif_contas_pacote.nrdiadebito%TYPE --> Dia débito
																	 ,pr_vlpacote IN NUMBER				
																	 ,pr_cdtransp IN tbtarif_pacote_trans_pend.cdtransacao_pendente%TYPE -- Código da transação pendente																	 													 
																	 ,pr_idorigem IN tbtarif_contas_pacote.indorigem%TYPE --> Indicador de origem Ayllos = 1 IB = 2
																	 ,pr_inaprpen IN NUMBER                              --> Indicador de aprovação de transacao pendente
																	 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																	 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																	 ,pr_dscritic OUT VARCHAR2);                         --> Desc. da crítica
  
  /*verifica se existe pacote*/
  PROCEDURE pc_ver_exist_pct_trf(pr_cdcooper IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> conta do cooperado
                                ,pr_existere OUT VARCHAR2             --> existe registro
                                ,pr_des_erro OUT VARCHAR2             --> Codigo da crítica
                                ,pr_dscritic OUT VARCHAR2);           --> Descricao da crítica
	
  /*Buscar pacotes de tarifas não digitalizados*/
	PROCEDURE pc_consul_tbtarif_ct_pct (pr_cdcooper    IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_flgsituacao IN  INTEGER               -- Situacao(1 - Ativo / 2 - Inativo)
                                     ,pr_clobxmlc    OUT CLOB                  -- XML com informações de LOG
                                     ,pr_des_erro    OUT VARCHAR2              -- Indicador erro OK/NOK
                                     ,pr_dscritic    OUT VARCHAR2);            -- Descrição da crítica
  
/*Busca dados para o cabecalho dos termos dos pacotes de tarifas*/
	PROCEDURE pc_cabeca_termos_pct_tar (pr_cdcooper IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_dtadesao IN  VARCHAR2              -- dt da adesao do pacote
                                     ,pr_nrdconta IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_tpdtermo IN  INTEGER               -- Tipo do termo 1 - Adesao / 2 - Cancelamento
                                     ,pr_idseqttl IN  crapttl.idseqttl%TYPE -- Codigo da cooperativa
                                     ,pr_cdagenci IN  crapass.cdagenci%TYPE --Codigo Agencia
                                     ,pr_nrdcaixa IN  INTEGER               --Numero Caixa
                                     ,pr_cdoperad IN  VARCHAR2              --Codigo Operador
                                     ,pr_nmdatela IN  VARCHAR2              --Nome Tela
                                     ,pr_idorigem IN  INTEGER               --Origem da chamada
																		 ,pr_cdpacote IN  tbtarif_pacotes.cdpacote%TYPE DEFAULT NULL -- Cód. Pacote
																		 ,pr_dspacote IN  VARCHAR2 DEFAULT NULL -- Desc. do pacote
																		 ,pr_dtinivig IN  VARCHAR2 DEFAULT NULL -- Data de início da vigência
																		 ,pr_dtdiadeb IN  VARCHAR2 DEFAULT NULL -- Dia de débito
																		 ,pr_vlpacote IN  VARCHAR2 DEFAULT NULL -- Valor do pacote
                                     ,pr_clobxmlc OUT CLOB                  -- XML com informações de LOG
                                     ,pr_des_erro OUT VARCHAR2              -- Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2);            -- Descrição da crítica																		 
  /*Imprime termo de adesao do pacote*/
  PROCEDURE pc_termo_adesao_pacote_ib(pr_cdcooper IN crapass.cdcooper%TYPE --> Cód. cooperativa
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
																		 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id. do titular
																		 ,pr_idorigem IN INTEGER               --> Id. de origem
																		 ,pr_cdpacote IN  tbtarif_pacotes.cdpacote%TYPE --> Cód. Pacote
																		 ,pr_dspacote IN  VARCHAR2             --> Desc. do pacote
																		 ,pr_dtinivig IN  VARCHAR2             -- Data de início da vigência
																		 ,pr_dtdiadeb IN  VARCHAR2             -- Dia de débito
																		 ,pr_vlpacote IN  VARCHAR2             -- Valor do pacote
                                     ,pr_iddspscp IN  INTEGER              -- Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
 	                                   ,pr_nmarquiv OUT VARCHAR2             -- Nome do arquivo
                                     ,pr_dssrvarq OUT VARCHAR2             -- Nome do servidor para download do arquivo
                                     ,pr_dsdirarq OUT VARCHAR2             -- Nome do diretório para download do arquivo                                                                                                                                   
																		 ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
																		 ,pr_dscritic OUT VARCHAR2);           -- Descrição da crítica    																		 

/* 	PROCEDURE pc_insere_pacote_conta_pj (pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																			,pr_nrdconta IN crapass.nrdconta%TYPE               --> Nr. da conta      
			                                ,pr_nrcpfope IN crapopi.nrcpfope%TYPE               --> CPF do operador juridico
																			,pr_idseqttl IN INTEGER                             --> Id. de sequencia do titular
																			,pr_cdpacote IN tbtarif_contas_pacote.cdpacote%TYPE --> Cód. pacote de tarifas
																			,pr_dtvigenc IN tbtarif_contas_pacote.dtinicio_vigencia%TYPE --> Data de inicio de vigencia
																			,pr_dtdiadbt IN tbtarif_contas_pacote.dtdiadebito%TYPE --> Dia débito
																			,pr_vlpacote IN NUMBER
																			,pr_idorigem IN tbtarif_contas_pacote.indorigem%TYPE --> Indicador de origem Ayllos = 1 IB = 2
																			,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																			,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																			,pr_dscritic OUT VARCHAR2);                       --> Desc. da crítica
*/

END TARI0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TARI0002 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : TARI0002
    Sigla    : CRED
    Autor    : Lucas Reinert
    Data     : Março/2016.                   Ultima atualizacao: --/--/----
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Englobar procedures referente a tarifas

  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_busca_pacote_tarifas(pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																	 ,pr_nrdconta IN crapass.nrdconta%TYPE               --> Nr. da conta      
																	 ,pr_inpessoa IN crapass.inpessoa%TYPE               --> Indicador de pessoa (1-fisica/2-juridica)
																	 ,pr_inconsul IN INTEGER                             --> 0 - Consulta adesão / 1 - Consulta pacotes disponiveis
																	 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																	 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																	 ,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
	/* ..........................................................................
	--
	--  Programa : pc_busca_pacote_tarifas
	--  Sistema  : Conta-Corrente - Cooperativa de Credito
	--  Sigla    : CRED
	--  Autor    : Lucas Reinert
	--  Data     : Março/2016.                   Ultima atualizacao: --/--/----
	--
	--  Dados referentes ao programa:
	--
	--   Frequencia: Sempre que for chamado
	--   Objetivo  : Procedure para buscar pacotes de tarifas 
	--
	--  Alteração :
	--
	-- ..........................................................................*/
	BEGIN
		DECLARE
		
 		 -- Variaveis de XML
		 vr_xml_temp VARCHAR2(32767);
		 
		 -- Variáveis para tratamento de erros
		 vr_exc_saida EXCEPTION;
		 vr_cdcritic  crapcri.cdcritic%TYPE;
		 vr_dscritic  crapcri.dscritic%TYPE;
		 
		 -- Variáveis auxiliares
		 vr_flgtarif BOOLEAN := FALSE;
		 vr_idastcjt   INTEGER(1);
		 vr_nrcpfcgc   INTEGER;
		 vr_nmprimtl   VARCHAR2(500);
		 vr_flcartma   INTEGER(1);		
     vr_inpessoa crapass.inpessoa%TYPE;	
				 
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
		 
		CURSOR cr_pacotes(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
		  SELECT tpac.dspacote
			      ,tpac.cdtarifa_lancamento cdtarifa
			      ,tcoop.cdpacote
						,to_char(TRUNC(add_months(pr_dtmvtolt, 1), 'MM'), 'DD/MM/RRRR') dtvigenc
			  FROM tbtarif_pacotes tpac,
				     tbtarif_pacotes_coop tcoop
			 WHERE tcoop.cdcooper = pr_cdcooper
			   AND tcoop.cdpacote = tpac.cdpacote
				 AND tcoop.flgsituacao = 1
				 AND tpac.tppessoa = pr_inpessoa
				 AND tcoop.dtinicio_vigencia <= pr_dtmvtolt;
																									     				
		
		-- Busca pacote de tarifa do cooperado
		 CURSOR cr_conta_pacote	IS
		   SELECT ctpac.cdpacote
			       ,to_char(ctpac.dtinicio_vigencia, 'DD/MM/RRRR') dtvigenc
					   ,to_char(ctpac.nrdiadebito, 'fm00') nrdiadebito
			       ,trpac.dspacote
						 ,trpac.cdtarifa_lancamento cdtarifa
         FROM tbtarif_contas_pacote ctpac,
              tbtarif_pacotes trpac         
        WHERE ctpac.cdcooper = pr_cdcooper
          AND ctpac.nrdconta = pr_nrdconta
          AND ctpac.flgsituacao = 1
          AND ctpac.dtcancelamento IS NULL
          AND trpac.cdpacote = ctpac.cdpacote;
		
		-- Busca valor da tarifa
		CURSOR cr_crapfco (pr_cdtarifa IN crapfvl.cdtarifa%TYPE) IS
		  SELECT to_char(fco.vltarifa, 'fm999g999g999g990d00') vltarifa
		   FROM crapfco fco
			     ,crapfvl fvl
			WHERE fco.cdcooper = pr_cdcooper
			  AND fco.flgvigen = 1
				AND fvl.cdtarifa = pr_cdtarifa
				AND fco.cdfaixav = fvl.cdfaixav;
		rw_crapfco cr_crapfco%ROWTYPE;

    -- Busca serviços de tarifa
		CURSOR cr_craptar (pr_cdpacote IN tbtarif_servicos.cdpacote%TYPE) IS
		  SELECT tar.dstarifa
			      ,tser.qtdoperacoes
			  FROM craptar tar
				    ,tbtarif_servicos tser
			 WHERE tser.cdpacote = pr_cdpacote
				 AND tar.cdtarifa = tser.cdtarifa;
         
    -- Buscar tipo de pessoa da conta
    CURSOR cr_crapass IS
		  SELECT ass.inpessoa
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
				 AND ass.nrdconta = pr_nrdconta;  
    rw_crapass cr_crapass%ROWTYPE;       
	BEGIN
		
		-- Leitura do calendário da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper);
		FETCH btch0001.cr_crapdat INTO rw_crapdat;
		-- Se não encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			-- Fechar o cursor pois efetuaremos raise
			CLOSE btch0001.cr_crapdat;
			-- Montar mensagem de critica
			vr_cdcritic := 1;
			vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
			RAISE vr_exc_saida;
		ELSE
			-- Apenas fechar o cursor
			CLOSE btch0001.cr_crapdat;
		END IF;
	
		--Verifica se conta for conta PJ e se exige asinatura multipla
		INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_idseqttl => 1
																			 ,pr_cdorigem => 3
																			 ,pr_idastcjt => vr_idastcjt
																			 ,pr_nrcpfcgc => vr_nrcpfcgc
																			 ,pr_nmprimtl => vr_nmprimtl
																			 ,pr_flcartma => vr_flcartma
																			 ,pr_cdcritic => vr_cdcritic
																			 ,pr_dscritic => vr_dscritic);

			
		-- Criar documento XML
		dbms_lob.createtemporary(pr_clobxmlc, TRUE);
		dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

		-- Insere o cabeçalho do XML
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '<raiz>');

    -- Se for consulta de adesao
    IF pr_inconsul = 0 THEN
			FOR rw_conta_pacote IN cr_conta_pacote LOOP
					
				-- Procura valor da tarifa
				OPEN cr_crapfco(rw_conta_pacote.cdtarifa);
				FETCH cr_crapfco INTO rw_crapfco;
					
				-- Se não encontrou
				IF cr_crapfco%NOTFOUND THEN
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Valor da tarifa não encontrado';
					-- Fecha cursor
					CLOSE cr_crapfco;
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;
				-- Fecha cursor
				CLOSE cr_crapfco;
				
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '<pacote>'
																									||  '<cdpacote>' || NVL(to_char(rw_conta_pacote.cdpacote), 0)   || '</cdpacote>'
																									||  '<dspacote>' || NVL(to_char(rw_conta_pacote.dspacote), ' ') || '</dspacote>'
																									||  '<dtvigenc>' || NVL(to_char(rw_conta_pacote.dtvigenc), ' ') ||'</dtvigenc>'
																									||  '<vltarifa>' || NVL(to_char(rw_crapfco.vltarifa), 0)   ||'</vltarifa>'
																									||  '<dtdiadebito>' || NVL(to_char(rw_conta_pacote.nrdiadebito), 0)   ||'</dtdiadebito>'
																									||  '<possuipac>1</possuipac>'
																									||  '<idastcjt>' || vr_idastcjt || '</idastcjt>'
																									||  '<servicos>');

				-- Busca serviços
				FOR rw_craptar IN cr_craptar(pr_cdpacote => rw_conta_pacote.cdpacote) LOOP
																		
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
																 ,pr_texto_completo => vr_xml_temp
																 ,pr_texto_novo     => '<servico>'
																										||  '<dsservic>' || NVL(rw_craptar.dstarifa, ' ') || '</dsservic>'																						
																										||  '<qtoperac>' || NVL(rw_craptar.qtdoperacoes, 0) || '</qtoperac>'
																										|| '</servico>');
					
				END LOOP;
						
				-- Encerrar a tag raiz
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '</servicos></pacote>');
				
				vr_flgtarif := TRUE;
				
			END LOOP;
    END IF;		
		-- Se cooperado não possui pacote de tarifas
		IF vr_flgtarif = FALSE THEN
				
      IF NVL(pr_inpessoa,0) = 0 THEN
        OPEN cr_crapass;
				FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 0;
					vr_dscritic := 'Associado não encontrado.';
				  CLOSE cr_crapass;
					RAISE vr_exc_saida;
        END IF;
        
        CLOSE cr_crapass;
        
        vr_inpessoa := rw_crapass.inpessoa;
      ELSE
        vr_inpessoa := pr_inpessoa;
      END IF;
      
			FOR rw_pacotes IN cr_pacotes(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_inpessoa => vr_inpessoa) LOOP
				
	 			-- Procura valor da tarifa
				OPEN cr_crapfco(rw_pacotes.cdtarifa);
				FETCH cr_crapfco INTO rw_crapfco;
					
				-- Se não encontrou
				IF cr_crapfco%NOTFOUND THEN
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Valor da tarifa não encontrado';
					-- Fecha cursor
				  CLOSE cr_crapfco;
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;
				-- Fecha cursor
				CLOSE cr_crapfco;
				
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '<pacote>'
																									||  '<cdpacote>' || NVL(to_char(rw_pacotes.cdpacote), 0)   || '</cdpacote>'
																									||  '<dspacote>' || NVL(to_char(rw_pacotes.dspacote), ' ') || '</dspacote>'
																									||  '<dtvigenc>' || NVL(to_char(rw_pacotes.dtvigenc), ' ') ||'</dtvigenc>'
																									||  '<vltarifa>' || NVL(to_char(rw_crapfco.vltarifa), 0)   ||'</vltarifa>'
																								  ||  '<dtdiadebito>1</dtdiadebito>'
																									||  '<possuipac>0</possuipac>'
																									||  '<idastcjt>' || vr_idastcjt || '</idastcjt>'																									
																									||  '<servicos>');

				-- Busca serviços
				FOR rw_craptar IN cr_craptar(pr_cdpacote => rw_pacotes.cdpacote) LOOP
																		
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
																 ,pr_texto_completo => vr_xml_temp
																 ,pr_texto_novo     => '<servico>'
																										||  '<dsservic>' || NVL(rw_craptar.dstarifa, ' ') || '</dsservic>'																						
																										||  '<qtoperac>' || NVL(rw_craptar.qtdoperacoes, 0) || '</qtoperac>'
																										|| '</servico>');
					
				END LOOP;
						
				-- Encerrar a tag raiz
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => '</servicos></pacote>');

			END LOOP;
		END IF;
		
		-- Encerrar a tag raiz
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '</raiz>'
													 ,pr_fecha_xml      => TRUE);

	EXCEPTION
		WHEN vr_exc_saida THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
		WHEN OTHERS THEN
			pr_cdcritic := 0;
			pr_dscritic := 'Erro nao tratado na procedure TARI0002.pc_busca_pacote_tarifas --> ' || SQLERRM;
	  END;
	END pc_busca_pacote_tarifas;
	
	PROCEDURE pc_insere_pacote_conta (pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																		,pr_nrdconta IN crapass.nrdconta%TYPE               --> Nr. da conta      
																		,pr_nrcpfope IN crapopi.nrcpfope%TYPE               --> CPF do operador juridico
																		,pr_idseqttl IN INTEGER                             --> Id. de sequencia do titular
																		,pr_cdpacote IN tbtarif_contas_pacote.cdpacote%TYPE --> Cód. pacote de tarifas
																		,pr_dtvigenc IN tbtarif_contas_pacote.dtinicio_vigencia%TYPE --> Data de inicio de vigencia
																		,pr_dtdiadbt IN tbtarif_contas_pacote.nrdiadebito%TYPE --> Dia débito
																		,pr_vlpacote IN NUMBER
																		,pr_cdtransp IN tbtarif_pacote_trans_pend.cdtransacao_pendente%TYPE -- Código da transação pendente
																		,pr_idorigem IN tbtarif_contas_pacote.indorigem%TYPE --> Indicador de origem Ayllos = 1 IB = 2
																		,pr_inaprpen IN NUMBER                              --> Indicador de aprovação de transacao pendente
																		,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																		,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																		,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
	BEGIN
	/* ..........................................................................
	--
	--  Programa : pc_insere_pacote_conta
	--  Sistema  : Conta-Corrente - Cooperativa de Credito
	--  Sigla    : CRED
	--  Autor    : Lucas Reinert
	--  Data     : Março/2016.                   Ultima atualizacao: --/--/----
	--
	--  Dados referentes ao programa:
	--
	--   Frequencia: Sempre que for chamado
	--   Objetivo  : Procedure para inserir pacotes de tarifas 
	--
	--  Alteração :
	--
	-- ..........................................................................*/

	DECLARE
	
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
	
    -- Buscar nome do preposto
		CURSOR cr_crapopi (pr_cdcooper IN crapopi.cdcooper%TYPE
											,pr_nrdconta IN crapopi.nrdconta%TYPE
											,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad
      FROM   crapopi
      WHERE  crapopi.cdcooper = pr_cdcooper 
      AND    crapopi.nrdconta = pr_nrdconta 
      AND    crapopi.nrcpfope = pr_nrcpfope;

    -- Busca descrição do pacote		
		CURSOR cr_pactar IS
			SELECT tpac.dspacote
				FROM tbtarif_pacotes tpac
			 WHERE tpac.cdpacote = pr_cdpacote;
		rw_pactar cr_pactar%ROWTYPE;

    -- Buscar pacote ativo na conta
	  CURSOR cr_conta_pacote_ativo IS
			SELECT 1
			 FROM tbtarif_contas_pacote ctpac,
						tbtarif_pacotes trpac         
			WHERE ctpac.cdcooper = pr_cdcooper
				AND ctpac.nrdconta = pr_nrdconta
				AND ctpac.flgsituacao = 1
				AND ctpac.dtcancelamento IS NULL
				AND trpac.cdpacote = ctpac.cdpacote;
		rw_conta_pacote_ativo cr_conta_pacote_ativo%ROWTYPE;


		-- Variáveis para tratamento de erros
		vr_exc_saida EXCEPTION;
		vr_cdcritic  crapcri.cdcritic%TYPE;
		vr_dscritic  crapcri.dscritic%TYPE;
		vr_des_erro  VARCHAR2(10);
		
		-- Variáveis auxiliares
		vr_xml_temp   VARCHAR2(32767);    
    vr_dsmsgsuc   VARCHAR2(500);
    vr_idastcjt   INTEGER(1);
    vr_nrcpfcgc   INTEGER;
    vr_nmprimtl   VARCHAR2(500);
    vr_flcartma   INTEGER(1);		
		vr_nmprepos   VARCHAR2(50);
		vr_dsprotoc   crappro.dsprotoc%TYPE;
		vr_dsinfor1   VARCHAR2(1000);
		vr_dsinfor2   VARCHAR2(1000);
		vr_dstransa   VARCHAR2(1000);
		vr_nrdrowid   ROWID;
	BEGIN		
			
		-- Leitura do calendário da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper);
		FETCH btch0001.cr_crapdat INTO rw_crapdat;
		-- Se não encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			-- Fechar o cursor pois efetuaremos raise
			CLOSE btch0001.cr_crapdat;
			-- Montar mensagem de critica
			vr_cdcritic := 1;
			vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
			RAISE vr_exc_saida;
		ELSE
			-- Apenas fechar o cursor
			CLOSE btch0001.cr_crapdat;
		END IF;

    -- Valida transação de representante legal
		INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_idseqttl => pr_idseqttl
																			 ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)
																			 ,pr_cdcritic => vr_cdcritic
																			 ,pr_dscritic => vr_dscritic);

    -- Se houve crítica, gerar exceção
		IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_saida;
		END IF; 

		--Verifica se conta for conta PJ e se exige asinatura multipla
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
			 RAISE vr_exc_saida; 
		END IF;                              								
		
    /* Efetuada por operador ou responsável de assinatura conjunta */
    IF (pr_nrcpfope > 0 OR vr_idastcjt = 1) AND pr_inaprpen = 0 THEN
       inet0002.pc_cria_trans_pend_pacote_tar(pr_cdagenci => 90
																						 ,pr_nrdcaixa => 900
																						 ,pr_cdoperad => '996'
																						 ,pr_nmdatela => 'INTERNETBANK'
																						 ,pr_idorigem => 3
																						 ,pr_idseqttl => pr_idseqttl
																						 ,pr_nrcpfope => pr_nrcpfope
																						 ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
																						 ,pr_cdcoptfn => 0    --> Cooperativa do Terminal
																						 ,pr_cdagetfn => 0
																						 ,pr_nrterfin => 0
																						 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																						 ,pr_cdcooper => pr_cdcooper
																						 ,pr_nrdconta => pr_nrdconta
																						 ,pr_cdpacote => pr_cdpacote
																						 ,pr_dtvigenc => pr_dtvigenc
																						 ,pr_dtdiadbt => pr_dtdiadbt
																						 ,pr_vlpacote => pr_vlpacote
																						 ,pr_idastcjt => vr_idastcjt
																						 ,pr_cdcritic => vr_cdcritic
																						 ,pr_dscritic => vr_dscritic);
			 
			IF nvl(vr_cdcritic,0) <> 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				 RAISE vr_exc_saida; 
			END IF;
			 
			IF vr_idastcjt = 1 THEN
				 vr_dsmsgsuc := 'Servico Cooperativo registrado com sucesso. '|| 
												'Aguardando aprovacao do registro pelos demais responsaveis.';
			ELSE
				 vr_dsmsgsuc := 'Servico Cooperativo registrado com sucesso. '|| 
												'Aguardando efetivacao do registro pelo preposto.';
			END IF;
      
      -- Criar documento XML
		  dbms_lob.createtemporary(pr_clobxmlc, TRUE);
		  dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

		  -- Insere mensagem de sucesso do XML
		  gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
				  									 ,pr_texto_novo     => '<dsmsgsuc>' || vr_dsmsgsuc || '</dsmsgsuc>'
					  								 ,pr_fecha_xml      => TRUE);                           
		ELSE
			-- Verifica se existe pacote ativo na conta
		  OPEN cr_conta_pacote_ativo;
			FETCH cr_conta_pacote_ativo INTO rw_conta_pacote_ativo;
			
			-- Se encontrou pacote ativo na conta
			IF cr_conta_pacote_ativo%FOUND THEN
			   
			  -- Se retornou código de transação pendente
			  IF (pr_cdtransp > 0) THEN
					-- Reprova transação pendente
					INET0002.pc_reprova_trans_pend(pr_cdcooper => pr_cdcooper
																				,pr_nrdconta => pr_nrdconta
																				,pr_nrdcaixa => 900
																				,pr_cdagenci => 90
																				,pr_cdoperad => '996'
																				,pr_dtmvtolt => rw_crapdat.dtmvtolt
																				,pr_cdorigem => 3
																				,pr_nmdatela => 'INTERNETBANK'
																				,pr_cdditens => '1,1,'||to_char(pr_cdtransp)||',0|'
																				,pr_nrcpfope => pr_nrcpfope
																				,pr_idseqttl => pr_idseqttl
																				,pr_flgerlog => 0
																				,pr_cdcritic => vr_cdcritic
																				,pr_dscritic => vr_dscritic);
				
					IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						-- Levanta exceção
						RAISE vr_exc_saida;
					END IF;
			
			  END IF;
				-- Gera críticas
				vr_cdcritic := 0;
				vr_dscritic := 'Já existe serviço cooperativo ativo na conta';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
		
			-- Insere pacote 
			INSERT INTO tbtarif_contas_pacote (cdcooper
																				,nrdconta
																				,cdpacote
																				,dtadesao
																				,dtinicio_vigencia
																				,nrdiadebito
																				,indorigem
																				,flgsituacao
																				,cdoperador_adesao)
																 VALUES (pr_cdcooper
																				,pr_nrdconta
																				,pr_cdpacote
																				,rw_crapdat.dtmvtolt
																				,pr_dtvigenc
																				,pr_dtdiadbt
																				,pr_idorigem
																				,1
																				,'996');
																				
      -- Busca pacotes de tarifas
      OPEN cr_pactar;
			FETCH cr_pactar INTO rw_pactar;
			
			-- Se não encontrou pacote
			IF cr_pactar%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_pactar;			
				-- Gera exceção
				vr_cdcritic := 0;
				vr_dscritic := 'Serviço Cooperativo não encontrado';
				RAISE vr_exc_saida;
			END IF;
				
		  vr_dsinfor1 := 'Serviços Cooperativos';
			vr_dsinfor2 := to_char(pr_cdpacote) || ' - ' || rw_pactar.dspacote || '#' 
			            || to_char(pr_vlpacote, 'fm999g999g999g990d00') || '#'
									|| to_char(pr_dtdiadbt, 'fm00') || '#'
									|| to_char(pr_dtvigenc, 'DD/MM/RRRR') || '#';
											
			-- Gera protocolo	
	    gene0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper
			                          ,pr_dtmvtolt => trunc(SYSDATE)
																,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
																,pr_nrdconta => pr_nrdconta
																,pr_nrdocmto => pr_cdpacote
																,pr_nrseqaut => 0
																,pr_vllanmto => pr_vlpacote
																,pr_nrdcaixa => 900
																,pr_gravapro => TRUE
																,pr_cdtippro => 14
																,pr_dsinfor1 => vr_dsinfor1
																,pr_dsinfor2 => vr_dsinfor2
																,pr_dsinfor3 => ''
																,pr_dscedent => NULL
																,pr_flgagend => FALSE
																,pr_nrcpfope => pr_nrcpfope
																,pr_nrcpfpre => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
																,pr_nmprepos => vr_nmprimtl
																,pr_dsprotoc => vr_dsprotoc
																,pr_dscritic => vr_dscritic
																,pr_des_erro => vr_des_erro);
																
			IF vr_des_erro <> 'OK' OR
				 nvl(vr_cdcritic,0) <> 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				 RAISE vr_exc_saida; 
			END IF;
																
		END IF; 		
    
		vr_dstransa := 'Adesão serviços cooperativos';
		
		IF pr_nrcpfope > 0  THEN
			 vr_dstransa := vr_dstransa ||' - operador';
		END IF;
    
		GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
												,pr_cdoperad => '996'
												,pr_dscritic => vr_dscritic
												,pr_dsorigem => 'INTERNET'
												,pr_dstransa => vr_dstransa
												,pr_dttransa => TRUNC(SYSDATE)
												,pr_flgtrans => 1
												,pr_hrtransa => gene0002.fn_busca_time
												,pr_idseqttl => pr_idseqttl
												,pr_nmdatela => 'INTERNETBANK'
												,pr_nrdconta => pr_nrdconta
												,pr_nrdrowid => vr_nrdrowid);
												
    IF pr_nrcpfope > 0  THEN
			-- Operador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Operador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
	  END IF;
					
		-- Código do pacote										 
		GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															,pr_nmdcampo => 'Código do pacote'
															,pr_dsdadant => ' '
															,pr_dsdadatu => to_char(pr_cdpacote));
											
		-- Valor do pacote				
		GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
														 ,pr_nmdcampo => 'Valor do pacote'
														 ,pr_dsdadant => ' '
														 ,pr_dsdadatu => to_char(pr_vlpacote, 'fm999g999g999g990d00'));

    -- Dia do débito
		GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
														 ,pr_nmdcampo => 'Dia do débito'
														 ,pr_dsdadant => ' '
														 ,pr_dsdadatu => to_char(pr_dtdiadbt, 'fm00'));

    -- Data de início da vigência
		GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
														 ,pr_nmdcampo => 'Início Vigencia'
														 ,pr_dsdadant => ' '
														 ,pr_dsdadatu => to_char(pr_dtvigenc, 'DD/MM/RRRR'));

    IF vr_dsprotoc IS NOT NULL THEN
			-- Protocolo
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Protocolo'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => vr_dsprotoc);
	  END IF;
		
		IF trim(vr_nmprimtl) IS NOT NULL AND pr_nrcpfope <= 0 THEN
			-- Nome do representante/procurador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Nome do Representante/Procurador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => vr_nmprimtl);
			
		END IF;
		
		IF vr_nrcpfcgc > 0 AND pr_nrcpfope <= 0 THEN
		  -- CPF do representante/procurador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'CPF do Representante/Procurador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc, 1));
		END IF;
					
	EXCEPTION
		WHEN vr_exc_saida THEN
			-- Atribui críticas
			pr_cdcritic := vr_cdcritic;
			IF vr_cdcritic <> 0 THEN
   		   pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			ELSE
				pr_dscritic := vr_dscritic;
			END IF;
		WHEN OTHERS THEN
			pr_cdcritic := 0;
			pr_dscritic := 'Erro nao tratado na procedure TARI0002.pc_busca_pacote_tarifas --> ' || SQLERRM;
	  END;
	END pc_insere_pacote_conta;
	
  /*verifica se existe pacote*/
  PROCEDURE pc_ver_exist_pct_trf(pr_cdcooper IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> conta do cooperado
                                ,pr_existere OUT VARCHAR2             --> existe registro
                                ,pr_des_erro OUT VARCHAR2          --> Codigo da crítica
                                ,pr_dscritic OUT VARCHAR2) IS         --> Descricao da crítica
    /* .............................................................................
    Programa: pc_ver_exist_pct_trf
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Lombardi
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Verifica se existe pacote de tarifas ativo para a conte.
                    
    Alteracoes: 
    ............................................................................. */
    
    --Busca dados do pacote
    CURSOR cr_dados_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1 
        FROM tbtarif_contas_pacote 
       WHERE tbtarif_contas_pacote.cdcooper = pr_cdcooper
         AND tbtarif_contas_pacote.nrdconta = pr_nrdconta
         AND tbtarif_contas_pacote.flgsituacao = 1         
         AND tbtarif_contas_pacote.dtcancelamento IS NULL;
    rw_dados_pacote cr_dados_pacote%ROWTYPE;
    
  BEGIN
    
    OPEN cr_dados_pacote(pr_cdcooper, pr_nrdconta);
    FETCH cr_dados_pacote INTO rw_dados_pacote;
    IF cr_dados_pacote%FOUND THEN
      pr_existere := 'true';
    ELSE
      pr_existere := 'false';
    END IF;
    CLOSE cr_dados_pacote;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Erro
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na TELA_ADEPAC.pc_ver_exist_pct_trf: ' || SQLERRM;
  END pc_ver_exist_pct_trf;
  
  /*Buscar pacotes de tarifas não digitalizados*/
	PROCEDURE pc_consul_tbtarif_ct_pct (pr_cdcooper    IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_flgsituacao IN  INTEGER               -- Situacao(1 - Ativo / 2 - Inativo)
                                     ,pr_clobxmlc    OUT CLOB                  -- XML com informações de LOG
                                     ,pr_des_erro    OUT VARCHAR2              -- Indicador erro OK/NOK
                                     ,pr_dscritic    OUT VARCHAR2) IS          -- Descrição da crítica

		BEGIN
/* .............................................................................
  
   Programa: pc_consul_tbtarif_ct_pct
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : TARI
   Autor   : Lombardi
   Data    : Abril/16.                    Ultima atualizacao: 99/99/9999

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Buscar pacotes de tarifas não digitalizados.

   Observacao: -----

   Alteracoes:
   ..............................................................................*/   
		DECLARE
      CURSOR cr_conta_pacotes (pr_cdcooper    IN crapcop.cdcooper%TYPE
                              ,pr_flgsituacao IN INTEGER) IS
        SELECT cdcooper
              ,nrdconta
              ,dtadesao
              ,cdoperador_adesao
          FROM tbtarif_contas_pacote
         WHERE cdcooper        = pr_cdcooper
           AND flgsituacao     = pr_flgsituacao
           AND ((pr_flgsituacao = 1
           AND dtcancelamento  IS NULL
           AND flgdigit_adesao = 0)
            OR (pr_flgsituacao = 0
           AND dtcancelamento  IS NOT NULL
           AND flgdigit_cancela = 0))
           AND indorigem       = 1;
      
      -- Variável de críticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_des_erro       VARCHAR2(3);

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
      
    BEGIN
      
			-- Criar documento XML
			dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
			dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       
      
      -- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
  		
		  FOR rw_conta_pacotes IN cr_conta_pacotes(pr_cdcooper, pr_flgsituacao) LOOP
        -- Montar XML com registros de aplicação
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => 
        '<pacote>' ||
             '<cdcoope>'           || NVL(TO_CHAR(rw_conta_pacotes.cdcooper),'0') || '</cdcoope>' ||
             '<nrdconta>'          || NVL(TO_CHAR(rw_conta_pacotes.nrdconta),'0') || '</nrdconta>' ||
             '<dtadesao>'          || NVL(TO_CHAR(rw_conta_pacotes.dtadesao),'0') || '</dtadesao>' ||
             '<cdoperador_adesao>' || NVL(TO_CHAR(rw_conta_pacotes.cdoperador_adesao),'0') || '</cdoperador_adesao>' ||
        '</pacote>');	
    		
      END LOOP;
      
				                                        															 														
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</root>' 
														 ,pr_fecha_xml      => TRUE);
				
			pr_des_erro := 'OK';
													 
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_des_erro := vr_des_erro;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := 'Erro nao tratado na consulta da situacao de portabildade em EMPR0006.pc_consulta_situacao_car: ' || SQLERRM;

    END;
  END pc_consul_tbtarif_ct_pct;
  
  /*Busca dados para o cabecalho dos termos dos pacotes de tarifas*/
	PROCEDURE pc_cabeca_termos_pct_tar (pr_cdcooper IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_dtadesao IN  VARCHAR2              -- dt da adesao do pacote
                                     ,pr_nrdconta IN  crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                     ,pr_tpdtermo IN  INTEGER               -- Tipo do termo 1 - Adesao / 2 - Cancelamento
                                     ,pr_idseqttl IN  crapttl.idseqttl%TYPE -- Codigo da cooperativa
                                     ,pr_cdagenci IN  crapass.cdagenci%TYPE --Codigo Agencia
                                     ,pr_nrdcaixa IN  INTEGER               --Numero Caixa
                                     ,pr_cdoperad IN  VARCHAR2              --Codigo Operador
                                     ,pr_nmdatela IN  VARCHAR2              --Nome Tela
                                     ,pr_idorigem IN  INTEGER               --Origem da chamada
																		 ,pr_cdpacote IN  tbtarif_pacotes.cdpacote%TYPE DEFAULT NULL -- Cód. Pacote
																		 ,pr_dspacote IN  VARCHAR2 DEFAULT NULL -- Desc. do pacote
																		 ,pr_dtinivig IN  VARCHAR2 DEFAULT NULL -- Data de início da vigência
																		 ,pr_dtdiadeb IN  VARCHAR2 DEFAULT NULL -- Dia de débito
																		 ,pr_vlpacote IN  VARCHAR2 DEFAULT NULL -- Valor do pacote
                                     ,pr_clobxmlc OUT CLOB                  -- XML com informações de LOG
                                     ,pr_des_erro OUT VARCHAR2              -- Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2) IS          -- Descrição da crítica

		BEGIN
/* .............................................................................
  
   Programa: pc_cabeca_termos_pct_tar
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : TARI
   Autor   : Lombardi
   Data    : Abril/16.                    Ultima atualizacao: 99/99/9999

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Busca dados para o cabecalho dos termos dos pacotes de tarifas.

   Observacao: -----

   Alteracoes:
   ..............................................................................*/   
		DECLARE
      
      -- Cursor genérico de calendário
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
      
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT nmextcop
              ,nmrescop
              ,gene0002.fn_mask_cpf_cnpj(nrdocnpj,2) nrdocnpj
              ,lpad(cdagectl,4,'0') cdagectl
              ,nmcidade
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Buscar dados do cooperado
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
        SELECT ttl.nmextttl  nmprimtl-- PESSOA FISICA
              ,gene0002.fn_mask_cpf_cnpj(ttl.nrcpfcgc,ttl.inpessoa) nrcpfcgc
              ,ttl.inpessoa
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl
        UNION
        SELECT ass.nmprimtl -- PESSOA JURIDICA
              ,gene0002.fn_mask_cpf_cnpj(ass.nrcpfcgc,ass.inpessoa) nrcpfcgc
              ,ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND ass.inpessoa = 2;
           
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Buscar informacoes do pacote cadastrado
      CURSOR cr_tbtarif_contas_pacote (pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                                      ,pr_tpdtermo IN INTEGER
                                      ,pr_dtadesao IN DATE) IS
        SELECT to_char(tcp.nrdiadebito,'fm00') nrdiadebito
              ,tp.dspacote
              ,to_char(tcp.dtinicio_vigencia, 'DD/MM/RRRR') dtinicio_vigencia
              ,tcp.dtcancelamento
              ,tcp.cdpacote
							,tcp.dtadesao
							,tp.cdtarifa_lancamento cdtarifa
							,CASE WHEN tcp.dtass_eletronica IS NULL THEN '0' ELSE '1' END idasseletronica
							,'Assinado eletronicamente em ' || TO_CHAR(tcp.dtass_eletronica, 'DD/MM/RRRR') || ' às ' || TO_CHAR(tcp.dtass_eletronica, 'HH24:MI') dsasseletronica
          FROM tbtarif_contas_pacote tcp
              ,tbtarif_pacotes       tp
         WHERE tcp.cdcooper = pr_cdcooper
           AND tcp.nrdconta = pr_nrdconta
           AND trunc(tcp.dtadesao) = trunc(pr_dtadesao)
           AND tp.cdpacote = tcp.cdpacote;
      rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
			
			-- Buscar valor da tarifa
			CURSOR cr_vltarifa (pr_cdcooper IN crapfco.cdcooper%TYPE
			                   ,pr_cdtarifa IN crapfvl.cdtarifa%TYPE		
			                   ,pr_dtvigenc IN crapfco.dtvigenc%TYPE) IS
			  SELECT 'R$ ' || to_char(fco.vltarifa,'fm999g990d00') vltarifa
				  FROM crapfvl fvl
              ,crapfco fco
				 WHERE fvl.cdtarifa = pr_cdtarifa
           AND fco.cdcooper = pr_cdcooper
           AND fco.cdfaixav = fvl.cdfaixav
		   AND fco.dtvigenc <= pr_dtvigenc
				ORDER BY fco.dtvigenc DESC;
      rw_vltarifa cr_vltarifa%ROWTYPE;			
      
      -- Buscar servicos
      CURSOR cr_tbtarif_servicos (pr_cdpacote IN tbtarif_servicos.cdpacote%TYPE) IS
        SELECT tar.dstarifa
              ,ts.qtdoperacoes
          FROM tbtarif_servicos ts
              ,craptar          tar
         WHERE ts.cdpacote = pr_cdpacote
           AND tar.cdtarifa = ts.cdtarifa;
					 
		  -- Buscar a data de adesão do contrato
      CURSOR cr_contas_pacote_dtadesao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS 
			  SELECT tcp.dtadesao					 
				  FROM tbtarif_contas_pacote tcp
				 WHERE tcp.cdcooper = pr_cdcooper
				   AND tcp.nrdconta = pr_nrdconta
					 AND tcp.flgsituacao = 1
					 AND tcp.dtcancelamento IS NULL;
      rw_contas_pacote_dtadesao cr_contas_pacote_dtadesao%ROWTYPE;				 
      
      -- Variaveis genericas
      vr_tab_crapavt    cada0001.typ_tab_crapavt_58;
      vr_tab_bens       cada0001.typ_tab_bens;
      vr_cdpacote       tbtarif_contas_pacote.cdpacote%TYPE;
      vr_represen       VARCHAR2(10000);
      vr_cargos         VARCHAR2(10000);
      vr_dstarifa       VARCHAR2(10000);
      vr_qtdoperacoes   VARCHAR2(10000);
      vr_xmlrepresen    VARCHAR2(10000);
      vr_dtcancelamento VARCHAR2(20);
      vr_dtinivig       VARCHAR2(10);
      
      -- Tratamento de erros
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      vr_des_erro  VARCHAR2(3);
      vr_tab_erro    gene0001.typ_tab_erro;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
      
    BEGIN
      
      -- Criar documento XML
			dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
			dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<cabecalho>');
  		
      -- Montar XML
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%FOUND THEN
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => 
        '<nmextcop>' || rw_crapcop.nmextcop || '</nmextcop>' ||
        '<nrdocnpj>' || rw_crapcop.nrdocnpj || '</nrdocnpj>');
				-- Se for IB
				IF (pr_idorigem = 3) THEN
					-- Se existe pacote ativo buscar data de adesão do pacote
				  OPEN cr_contas_pacote_dtadesao(pr_cdcooper => pr_cdcooper
					                              ,pr_nrdconta => pr_nrdconta);
					FETCH cr_contas_pacote_dtadesao INTO rw_contas_pacote_dtadesao;
				
				  -- Se encontrou mostra data de adesão
				  IF cr_contas_pacote_dtadesao%FOUND THEN
						gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																	 ,pr_texto_completo => vr_xml_temp 
																	 ,pr_texto_novo     => '<nmcidade>' || 
																				rw_crapcop.nmcidade || ', ' ||
																				to_char(rw_contas_pacote_dtadesao.dtadesao,'DD') || ' de ' ||
																				REPLACE(to_char(rw_contas_pacote_dtadesao.dtadesao,'MONTH','NLS_DATE_LANGUAGE=PORTUGUESE'), ' ','') || ' de ' ||
																				to_char(rw_contas_pacote_dtadesao.dtadesao,'RRRR') || '.' ||
																		'</nmcidade>');
					ELSE
						-- Senão mostra data atual
						gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																	 ,pr_texto_completo => vr_xml_temp 
																	 ,pr_texto_novo     => '<nmcidade>' || 
																				rw_crapcop.nmcidade || ', ' ||
																				to_char(rw_crapdat.dtmvtolt,'DD') || ' de ' ||
																				REPLACE(to_char(rw_crapdat.dtmvtolt,'MONTH','NLS_DATE_LANGUAGE=PORTUGUESE'), ' ','') || ' de ' ||
																				to_char(rw_crapdat.dtmvtolt,'RRRR') || '.' ||
																		'</nmcidade>');
					END IF;
					CLOSE cr_contas_pacote_dtadesao;
				-- Se for impressão do termo pelo ayllos mostra data atual
				ELSE
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     => '<nmcidade>' || 
																			rw_crapcop.nmcidade || ', ' ||
																			to_char(rw_crapdat.dtmvtolt,'DD') || ' de ' ||
																			REPLACE(to_char(rw_crapdat.dtmvtolt,'MONTH','NLS_DATE_LANGUAGE=PORTUGUESE'), ' ','') || ' de ' ||
																			to_char(rw_crapdat.dtmvtolt,'RRRR') || '.' ||
																	'</nmcidade>');
				END IF;
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>
					'<nmrescop>' || rw_crapcop.nmrescop || '</nmrescop>' ||
					'<cdagectl>' || rw_crapcop.cdagectl || '</cdagectl>');
      ELSE
        vr_dscritic := 'Cooperativa não encontrada.';
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_crapass(pr_cdcooper,pr_nrdconta,pr_idseqttl);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        vr_dscritic := 'Conta não encontrada.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => 
      '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
      '<nrcpfcgc>' || CASE WHEN rw_crapass.inpessoa = 1 THEN 'CPF:' ELSE 'CNPJ:' END || rw_crapass.nrcpfcgc || '</nrcpfcgc>' ||
      '<nrdconta>' || 
          REPLACE(gene0002.fn_mask_conta(pr_nrdconta),' ', '') ||
      '</nrdconta>');
      
      cada0001.pc_busca_dados_58 (pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => 0
                                 ,pr_flgerlog => TRUE
                                 ,pr_cddopcao => 'C'
                                 ,pr_nrdctato => 0
                                 ,pr_nrcpfcto => ''
                                 ,pr_nrdrowid => NULL
                                 ,pr_tab_crapavt => vr_tab_crapavt
                                 ,pr_tab_bens => vr_tab_bens
                                 ,pr_tab_erro => vr_tab_erro
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      
      --*********** PACOTE **********
      IF pr_idorigem <> 3 THEN -- no InternetBank o termo vem antes da inclusao
        OPEN cr_tbtarif_contas_pacote (pr_cdcooper
                                      ,pr_nrdconta
                                      ,pr_tpdtermo
                                      ,to_date(pr_dtadesao, 'DD/MM/RRRR'));
        FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
        IF cr_tbtarif_contas_pacote%NOTFOUND THEN
          vr_dscritic := 'Serviço Cooperativo não encontrado.';
	        CLOSE cr_tbtarif_contas_pacote;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_tbtarif_contas_pacote;
				
				OPEN cr_vltarifa (pr_cdcooper => pr_cdcooper
				                 ,pr_cdtarifa => rw_tbtarif_contas_pacote.cdtarifa
				                 ,pr_dtvigenc => rw_tbtarif_contas_pacote.dtadesao);
				FETCH cr_vltarifa INTO rw_vltarifa;
				
				IF cr_vltarifa%NOTFOUND THEN
          vr_dscritic := 'Valor da tarifa não encontrado.';
					CLOSE cr_vltarifa;
          RAISE vr_exc_saida;				
				END IF;
        CLOSE cr_vltarifa;
				
        vr_cdpacote := rw_tbtarif_contas_pacote.cdpacote;
        
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => 
            '<dtdiadebito>' || rw_tbtarif_contas_pacote.nrdiadebito || '</dtdiadebito>' ||
            '<dspacote>' || rw_tbtarif_contas_pacote.dspacote || '</dspacote>' ||
            '<vltarifa>' || rw_vltarifa.vltarifa || '</vltarifa>' ||
	        '<dtinicio_vigencia>' || rw_tbtarif_contas_pacote.dtinicio_vigencia || '</dtinicio_vigencia>' ||
		    '<idasseletronica>' || rw_tbtarif_contas_pacote.idasseletronica || '</idasseletronica>' ||
		    '<dsasseletronica><![CDATA[' || rw_tbtarif_contas_pacote.dsasseletronica || ']]></dsasseletronica>'
		);

        vr_dtinivig := rw_tbtarif_contas_pacote.dtinicio_vigencia;
			ELSE
				
			  IF pr_cdpacote IS NOT NULL THEN
					vr_cdpacote := pr_cdpacote;	
				
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     => 
																	'<dtdiadebito>' || to_char(pr_dtdiadeb, 'fm00') || '</dtdiadebito>' ||
																	'<dspacote>' || pr_dspacote || '</dspacote>' ||
																	'<vltarifa>R$ ' || pr_vlpacote || '</vltarifa>' ||
																	'<dtinicio_vigencia>' || pr_dtinivig || '</dtinicio_vigencia>');
          vr_dtinivig := pr_dtinivig;
				END IF;
      END IF;
      
      
      --*********** REPRESENTANTES **********
      vr_represen    := '';
      vr_cargos      := '';
      vr_xmlrepresen := '<representantes_legais>';
      -- Se for pessoa juridica
      IF rw_crapass.inpessoa = 2 THEN
        -- Popula responsaveis legais
        IF vr_tab_crapavt.COUNT() > 0 THEN
          -- Leitura de registros de avalistas, representantes e procuradores
          FOR vr_index IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
            IF vr_tab_crapavt(vr_index).idrspleg = 1 THEN
              
              IF trim(vr_represen) IS NOT NULL THEN
                vr_represen := vr_represen || '<br>';
                vr_cargos   := vr_cargos   || '<br>';
              END IF;
            
              vr_represen := vr_represen || vr_tab_crapavt(vr_index).nmdavali;
              vr_cargos   := vr_cargos   || vr_tab_crapavt(vr_index).dsproftl;
              
              vr_xmlrepresen := vr_xmlrepresen || 
                                '<representante>' ||
                                '  <nome>'  || vr_tab_crapavt(vr_index).nmdavali || '</nome>' ||         
                                '  <cargo>' || vr_tab_crapavt(vr_index).dsproftl || '</cargo>' ||                               
                                '</representante>';
            END IF;
          END LOOP;
        END IF;
      END IF;
      
      vr_xmlrepresen := vr_xmlrepresen || '</representantes_legais>';
      
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<representantes><![CDATA[' || vr_represen || ']]></representantes>');
      
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<cargos><![CDATA[' || vr_cargos || ']]></cargos>');
      
      
      --*********** SERVICOS **********        
			vr_dstarifa     := '';
			vr_qtdoperacoes := '';             
      
			IF vr_cdpacote IS NOT NULL THEN
				FOR rw_tbtarif_servicos IN cr_tbtarif_servicos(vr_cdpacote) LOOP
	          
					IF trim(vr_dstarifa) IS NOT NULL THEN
						vr_dstarifa     := vr_dstarifa     || '<br>';
						vr_qtdoperacoes := vr_qtdoperacoes || '<br>';
					END IF;
	            
					vr_dstarifa     := vr_dstarifa     || rw_tbtarif_servicos.dstarifa;
					vr_qtdoperacoes := vr_qtdoperacoes || rw_tbtarif_servicos.qtdoperacoes;
	          
				END LOOP;
	        
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
															 ,pr_texto_completo => vr_xml_temp 
															 ,pr_texto_novo     => '<dstarifas><![CDATA[' || vr_dstarifa || ']]></dstarifas>');
	        
				gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
															 ,pr_texto_completo => vr_xml_temp 
															 ,pr_texto_novo     => '<qtdoperacoes><![CDATA[' || vr_qtdoperacoes || ']]></qtdoperacoes>');

      END IF;      
			
      IF pr_tpdtermo = 2 AND rw_tbtarif_contas_pacote.dtcancelamento IS NULL THEN
        vr_dtcancelamento := to_char(rw_crapdat.dtultdia, 'DD/MM/RRRR');
      ELSE 
        vr_dtcancelamento := to_char(LAST_DAY(rw_tbtarif_contas_pacote.dtcancelamento),'DD/MM/RRRR');
      END IF;
      
      IF to_date(vr_dtinivig,'DD/MM/RRRR') > to_date(vr_dtcancelamento,'DD/MM/RRRR') THEN
        vr_dtcancelamento := '';
      END IF;
      
      -- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<dttermino_vigencia>' || vr_dtcancelamento || '</dttermino_vigencia>');
      
      -- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<inpessoa>' || rw_crapass.inpessoa || '</inpessoa>');
														 
      -- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<idorigem>' || pr_idorigem         || '</idorigem>' ||
                                                   '<dscpfcgc>' || rw_crapass.nrcpfcgc || '</dscpfcgc>');
                            
      -- Atribuir lista de representantes no XML                       
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => vr_xmlrepresen);                                                   
      
      -- Encerrar a tag raiz
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</cabecalho>' 
														 ,pr_fecha_xml      => TRUE);
				
			pr_des_erro := 'OK';
													 
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_des_erro := vr_des_erro;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := 'Erro nao tratado na procedure TARI0002.pc_cabeca_termos_pct_tar: ' || SQLERRM;

    END;
  END pc_cabeca_termos_pct_tar;
	
  /*Imprime termo de adesao do pacote*/
  PROCEDURE pc_termo_adesao_pacote_ib(pr_cdcooper IN crapass.cdcooper%TYPE --> Cód. cooperativa
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta
																		 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id. do titular
																		 ,pr_idorigem IN INTEGER               --> Id. de origem
																		 ,pr_cdpacote IN  tbtarif_pacotes.cdpacote%TYPE --> Cód. Pacote
																		 ,pr_dspacote IN  VARCHAR2             --> Desc. do pacote
																		 ,pr_dtinivig IN  VARCHAR2             -- Data de início da vigência
																		 ,pr_dtdiadeb IN  VARCHAR2             -- Dia de débito
																		 ,pr_vlpacote IN  VARCHAR2             -- Valor do pacote
                                     ,pr_iddspscp IN  INTEGER              -- Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
 	                                   ,pr_nmarquiv OUT VARCHAR2             -- Nome do arquivo
                                     ,pr_dssrvarq OUT VARCHAR2             -- Nome do servidor para download do arquivo
                                     ,pr_dsdirarq OUT VARCHAR2             -- Nome do diretório para download do arquivo                                                                                                                                   
																		 ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
																		 ,pr_dscritic OUT VARCHAR2) IS         -- Descrição da crítica    
 /* .............................................................................
    Programa: pc_termo_adesao_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Lucas Reinert
    Data    : Maio/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Gera termo de adesao do pacote via InternetBank
                    
    Alteracoes: 
    ............................................................................. */
   
    --- VARIAVEIS ---
    vr_titular         VARCHAR2(1000);
    vr_dspacote        VARCHAR2(1000);
    vr_cdreciprocidade tbtarif_contas_pacote.cdreciprocidade%TYPE;
    vr_vltarifa        VARCHAR2(100);
    vr_cdtarifa        crapfvl.cdtarifa%TYPE;
    vr_permanual       VARCHAR2(100);
    vr_vlpermanual     NUMBER;
    vr_contador        INTEGER;
    vr_vlrpago         NUMBER;
    vr_xml             CLOB;
    vr_texto_xml       VARCHAR2(32767);
    vr_caminho         VARCHAR2(100);
    vr_nom_arquivo     VARCHAR2(100);
    vr_dtmvtolt        crapdat.dtmvtolt%type;
    vr_comando         VARCHAR2(100);
    vr_nrdrowid        ROWID;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_reto VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;
    
  BEGIN
    
	  -- Gera dados do relatório        
    tari0002.pc_cabeca_termos_pct_tar(pr_cdcooper => pr_cdcooper
                                     ,pr_dtadesao => NULL
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => pr_idseqttl
                                     ,pr_tpdtermo => 1
                                     ,pr_cdagenci => 90
                                     ,pr_nrdcaixa => 900
                                     ,pr_cdoperad => '1'
                                     ,pr_nmdatela => 'IB171'
                                     ,pr_idorigem => pr_idorigem
																		 ,pr_cdpacote => pr_cdpacote
                                     ,pr_dspacote => pr_dspacote
                                     ,pr_dtinivig => pr_dtinivig
                                     ,pr_dtdiadeb => pr_dtdiadeb
                                     ,pr_vlpacote => pr_vlpacote
                                     ,pr_clobxmlc => vr_xml
                                     ,pr_des_erro => vr_des_reto
                                     ,pr_dscritic => vr_dscritic);
    
		-- Busca diretório de geração do arquivo
    vr_caminho := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                     ,pr_cdcooper => pr_cdcooper  --> Cooperativa
			                                 ,pr_nmsubdir => 'rl');       --> Raiz
        
    -- Monta nome do arquivo
    vr_nom_arquivo := pr_cdcooper || pr_nrdconta || pr_cdpacote || '.' || 
		                  TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')|| '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';
    
    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper      --> Cooperativa conectada
                               ,pr_cdprogra  => 'ADEPAC'         --> Programa chamador
                               ,pr_dtmvtolt  => trunc(SYSDATE)   --> Data do movimento atual
                               ,pr_dsxml     => vr_xml           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/cabecalho'     --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'termo_adesao_pct_tarifas.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_caminho||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 80               --> 132 colunas
                               ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                               ,pr_flg_gerar => 'S'              --> gerar na hora
                               ,pr_nmformul  => '80col'          --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                --> Numero de copias
                               ,pr_cdrelato  => 717              --> Codigo do Relatorio
                               ,pr_des_erro  => vr_dscritic);    --> Saida com erro
    
		-- Se retornou algum erro
    IF vr_dscritic != '' THEN
			-- Levanta exceção
      RAISE vr_exc_erro;
    END IF; 
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    IF pr_iddspscp = 0 THEN -- Manter cópia do arquivo via scp para o servidor destino
		-- Copia o PDF para o IB
		GENE0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper,
																		pr_nmarqpdf => vr_caminho || '/' || vr_nom_arquivo,
																		pr_des_erro => vr_des_reto);
		-- Testar se houve erro
		IF vr_des_reto IS NOT NULL THEN
			-- Gerar excecao
			RAISE vr_exc_erro;
		END IF;

		-- Remove o arquivo XML fisico de envio
		GENE0001.pc_OScommand (pr_typ_comando => 'S'
													,pr_des_comando => 'rm '||vr_caminho || '/' || vr_nom_arquivo||' 2> /dev/null'
													,pr_typ_saida   => vr_des_reto
													,pr_des_saida   => vr_dscritic);
		-- Se ocorreu erro dar RAISE
		IF vr_des_reto = 'ERR' THEN
			RAISE vr_exc_erro;
      END IF;      
    ELSE
      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                         ,pr_dsdirecp => vr_caminho||'/'
                                         ,pr_nmarqucp => vr_nom_arquivo
                                         ,pr_flgcopia => 0
                                         ,pr_dssrvarq => pr_dssrvarq
                                         ,pr_dsdirarq => pr_dsdirarq
                                         ,pr_des_erro => vr_dscritic);
        
      IF vr_dscritic IS NOT NULL AND TRIM(vr_dscritic) <> ' ' THEN
        RAISE vr_exc_erro;
		END IF;
    END IF;
		
		-- Seta o retorno
		pr_dscritic := NULL;
		pr_nmarquiv := vr_nom_arquivo;    
		
    -- Execução OK    
    pr_des_erro := 'OK';
		
		-- Efetua commit
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_dscritic := vr_dscritic;
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_dscritic := 'Erro na TARI0002.PC_TERMO_ADESAO_PACOTE_IB: ' || SQLERRM;
          
  END pc_termo_adesao_pacote_ib;


END TARI0002;
/
