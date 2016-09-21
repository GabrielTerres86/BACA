CREATE OR REPLACE PACKAGE CECRED.GED0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GED0001
  --  Autor   : Lucas Reinert
  --  Data    : Maio/2016                  Ultima Atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Englobar procedures referente a GED
  --
  --  Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_pacote_tarifas_ged(pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																			 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do beneficiario
																			 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																			 ,pr_dscritic OUT VARCHAR2);                         --> Desc. da crítica
																			 
	PROCEDURE pc_atualiza_digito_pacote(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
																		 ,pr_inadecan IN INTEGER               --> Indicador de adesão/cancelamento (1 = Adesão/ 2 = Cancelamento)
																		 ,pr_cdcritic OUT INTEGER              --> Cód. da crítica
																		 ,pr_dscritic OUT VARCHAR2);           --> Desc. da crítica																			 

END GED0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GED0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GED0001
  --  Autor   : Lucas Reinert
  --  Data    : Maio/2016                  Ultima Atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Englobar procedures referente a GED
  --
  --  Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_pacote_tarifas_ged(pr_cdcooper IN crapcop.cdcooper%TYPE               --> Cooperativa
																			 ,pr_clobxmlc OUT CLOB                               --> Clob com dados do pacote
																			 ,pr_cdcritic OUT INTEGER                            --> Cód. da crítica
																			 ,pr_dscritic OUT VARCHAR2) IS                       --> Desc. da crítica
	/* ..........................................................................
	--
	--  Programa : pc_busca_pacote_tarifas_ged
	--  Sistema  : Conta-Corrente - Cooperativa de Credito
	--  Sigla    : CRED
	--  Autor    : Lucas Reinert
	--  Data     : Maio/2016.                   Ultima atualizacao: --/--/----
	--
	--  Dados referentes ao programa:
	--
	--   Frequencia: Sempre que for chamado
	--   Objetivo  : Procedure para buscar pacotes de tarifas do cooperado
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
																									     						
		-- Busca dados de adesao do pacote de tarifa do cooperado
		 CURSOR cr_conta_pacote_adesao	IS
		   SELECT ctpac.nrdconta
			       ,to_char(ctpac.dtadesao, 'DD/MM/RRRR') dtadesao
             ,ctpac.cdoperador_adesao
         FROM tbtarif_contas_pacote ctpac
        WHERE ctpac.cdcooper = pr_cdcooper
          AND ctpac.flgsituacao = 1
          AND ctpac.dtcancelamento IS NULL
					AND ctpac.flgdigit_adesao = 0
					AND ctpac.indorigem = 1;
					
 		 -- Busca dados de cancelamento do pacote de tarifa do cooperado
		 CURSOR cr_conta_pacote_cancelamento	IS
		   SELECT ctpac.nrdconta
			       ,to_char(ctpac.dtcancelamento, 'DD/MM/RRRR') dtcancelamento
             ,ctpac.cdoperador_cancela
         FROM tbtarif_contas_pacote ctpac
        WHERE ctpac.cdcooper = pr_cdcooper
          AND ctpac.flgsituacao = 0
          AND ctpac.dtcancelamento IS NOT NULL
					AND ctpac.flgdigit_cancela = 0
					AND ctpac.indorigem = 1;
		
	BEGIN
			
		-- Criar documento XML
		dbms_lob.createtemporary(pr_clobxmlc, TRUE);
		dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

		-- Insere o cabeçalho do XML
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '<raiz><adesao>');
    
		-- Para cada pacote de adesao
		FOR rw_conta_pacote IN cr_conta_pacote_adesao LOOP
							
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => '<pacote>'
																								||  '<nrdconta>' || NVL(to_char(rw_conta_pacote.nrdconta), 0)   || '</nrdconta>'
																								||  '<dtadesao>' || NVL(to_char(rw_conta_pacote.dtadesao), ' ') || '</dtadesao>'
																								||  '<cdoperador_adesao>' || NVL(to_char(rw_conta_pacote.cdoperador_adesao), ' ') ||'</cdoperador_adesao>'
																								||  '</pacote>');
							
		END LOOP;

		-- Insere o cabeçalho do XML
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '</adesao><cancelamento>');

		-- Para cada pacote de cancelamento
		FOR rw_conta_pacote IN cr_conta_pacote_cancelamento LOOP
							
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => '<pacote>'
																								||  '<nrdconta>' || NVL(to_char(rw_conta_pacote.nrdconta), 0)   || '</nrdconta>'
																								||  '<dtcancelamento>' || NVL(to_char(rw_conta_pacote.dtcancelamento), ' ') || '</dtcancelamento>'
																								||  '<cdoperador_cancela>' || NVL(to_char(rw_conta_pacote.cdoperador_cancela), ' ') ||'</cdoperador_cancela>'
																								||  '</pacote>');
							
		END LOOP;
			
		-- Encerrar a tag raiz
		gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '</cancelamento></raiz>'
													 ,pr_fecha_xml      => TRUE);

	EXCEPTION
		WHEN vr_exc_saida THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
		WHEN OTHERS THEN
			pr_cdcritic := 0;
			pr_dscritic := 'Erro nao tratado na procedure GED0001.pc_busca_pacote_tarifas --> ' || SQLERRM;
	  END;
	END pc_busca_pacote_tarifas_ged;
	
	PROCEDURE pc_atualiza_digito_pacote(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
																		 ,pr_inadecan IN INTEGER               --> Indicador de adesão/cancelamento (1 = Adesão/ 2 = Cancelamento)
																		 ,pr_cdcritic OUT INTEGER              --> Cód. da crítica
																		 ,pr_dscritic OUT VARCHAR2) IS         --> Desc. da crítica
	/* ..........................................................................
	--
	--  Programa : pc_atualiza_digito_pacote
	--  Sistema  : Conta-Corrente - Cooperativa de Credito
	--  Sigla    : CRED
	--  Autor    : Lucas Reinert
	--  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
	--
	--  Dados referentes ao programa:
	--
	--   Frequencia: Sempre que for chamado
	--   Objetivo  : Procedure para atualizar digito do pacotes de tarifas 
	--               do cooperado
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
																									     						
		-- Busca dados de adesao do pacote de tarifa do cooperado
		CURSOR cr_conta_pacote_adesao	IS
		   SELECT ctpac.rowid 
         FROM tbtarif_contas_pacote ctpac
        WHERE ctpac.cdcooper = pr_cdcooper
				  AND ctpac.nrdconta = pr_nrdconta
          AND ctpac.flgsituacao = 1
          AND ctpac.dtcancelamento IS NULL
					AND ctpac.flgdigit_adesao = 0
					AND ctpac.indorigem = 1;
    rw_conta_pacote_adesao cr_conta_pacote_adesao%ROWTYPE;
		 
 		-- Busca dados de cancelamento do pacote de tarifa do cooperado
		CURSOR cr_conta_pacote_cancelamento	IS
		   SELECT ctpac.rowid
         FROM tbtarif_contas_pacote ctpac
        WHERE ctpac.cdcooper = pr_cdcooper
				  AND ctpac.nrdconta = pr_nrdconta
          AND ctpac.flgsituacao = 0
          AND ctpac.dtcancelamento IS NOT NULL
					AND ctpac.flgdigit_cancela = 0
					AND ctpac.indorigem = 1;
    rw_conta_pacote_cancelamento cr_conta_pacote_cancelamento%ROWTYPE;
		
		BEGIN																	 
    -- Adesão																		 
		IF (pr_inadecan = 1) THEN
			OPEN cr_conta_pacote_adesao;
			FETCH cr_conta_pacote_adesao 
			 INTO rw_conta_pacote_adesao;
			 
			-- Se encontrou
			IF cr_conta_pacote_adesao%FOUND THEN
				 -- Atualiza digito de adesão
         UPDATE tbtarif_contas_pacote
				    SET tbtarif_contas_pacote.flgdigit_adesao = 1
					WHERE tbtarif_contas_pacote.rowid = rw_conta_pacote_adesao.rowid;
			END IF;
			CLOSE cr_conta_pacote_adesao;
		ELSE -- Cancelamento
			OPEN cr_conta_pacote_cancelamento;
			FETCH cr_conta_pacote_cancelamento 
			 INTO rw_conta_pacote_cancelamento;
			 
			-- Se encontrou
			IF cr_conta_pacote_cancelamento%FOUND THEN
				 -- Atualiza digito de adesão
         UPDATE tbtarif_contas_pacote
				    SET tbtarif_contas_pacote.flgdigit_cancela = 1
					WHERE tbtarif_contas_pacote.rowid = rw_conta_pacote_cancelamento.rowid;
			END IF;
			CLOSE cr_conta_pacote_adesao;			
		END IF;

    COMMIT;
		
	EXCEPTION
		WHEN vr_exc_saida THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
		WHEN OTHERS THEN
			pr_cdcritic := 0;
			pr_dscritic := 'Erro nao tratado na procedure GED0001.pc_atualiza_digito_pacote --> ' || SQLERRM;
	  END;	
	END pc_atualiza_digito_pacote;

END GED0001;
/
