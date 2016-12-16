CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DESCONTO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DESCONTO
  --  Sistema  : Ayllos Web
  --  Autor    : Lucas Reinert
  --  Data     : Outubro - 2016                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Descontos dentro da ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_inf_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
																,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_busca_cheques_dsc_cst(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
		                                ,pr_nriniseq  IN INTEGER                --> Paginação - Inicio de sequencia
																		,pr_nrregist  IN INTEGER                --> Paginação - Número de registros
																		,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																		,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																		,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																		,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																		,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
                         
  PROCEDURE pc_verifica_emitentes(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
																 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador 
																 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
	               
  PROCEDURE pc_manter_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
														 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
														 ,pr_nrdolote  IN crapbdc.nrdolote%TYPE  --> Lote
														 ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
														 ,pr_dscheque  IN CLOB                   --> Cheques
														 ,pr_dscheque_exc IN CLOB                --> Cheques a serem excluidos do bordero														 
														 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
														 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
														 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
														 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
														 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
	
	PROCEDURE pc_aprovar_reprovar_chq(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																	 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																	 ,pr_dscheque  IN CLOB                   --> Cheques
																	 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																	 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																	 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																	 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																	 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																	 ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
	
	PROCEDURE pc_verifica_assinatura_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																					,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																					,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																					,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																					,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																					,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																					,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																					,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
																					
	PROCEDURE pc_efetiva_desconto_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																			 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																			 ,pr_cdopcolb  IN crapbdc.cdopcolb%TYPE  --> Operador Liberação
																			 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																			 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																			 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																			 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																			 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																			 ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo																					
	
	PROCEDURE pc_efetuar_resgate(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
															,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
															,pr_dscheque  IN CLOB                   --> Cheques
															,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
															,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
															,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
															,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
															,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
															,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
	
END TELA_ATENDA_DESCONTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DESCONTO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DESCONTO
  --  Sistema  : Ayllos Web
  --  Autor    : Lucas Reinert
  --  Data     : Outubro - 2016                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Descontos dentro da ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_inf_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
		                            ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
		                            ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
																,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_inf_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar informações de desconto

    Alteracoes: -----
  ..............................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(1000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis auxiliares
		vr_inpessoa NUMBER;
		vr_stsnrcal BOOLEAN;
		vr_flbloque NUMBER := 0;

    vr_tab_cheques DSCC0001.typ_tab_cheques;
		vr_idx_ocorre PLS_INTEGER;

    vr_clob CLOB;
	
	  -- Buscar informações do bordero
		CURSOR cr_crapbdc(pr_cdcooper IN crapcdb.cdcooper%TYPE
		                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
										 ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
		  SELECT bdc.insitbdc
			  FROM crapbdc bdc
			 WHERE bdc.cdcooper = pr_cdcooper
			   AND bdc.nrdconta = pr_nrdconta
				 AND bdc.nrborder = pr_nrborder;
		rw_crapbdc cr_crapbdc%ROWTYPE;
	
		-- Buscar valor de limite disponível
		CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
										 ,pr_nrdconta IN craplim.nrdconta%TYPE
										 ,pr_dtmvtolt IN DATE) IS
			SELECT to_char(vllimite -
							nvl((SELECT SUM(vlcheque) FROM crapcdb
							WHERE cdcooper = pr_cdcooper
								AND nrdconta = pr_nrdconta
								AND dtlibbdc IS NOT NULL
								AND dtlibera > pr_dtmvtolt
								AND insitchq IN (0,2)
								AND insitana = 1), 0), 'fm999g999g999g990d00'
							) 
							vllimdis,
							nrctrlim
			 FROM craplim 
			WHERE cdcooper = pr_cdcooper
				AND nrdconta = pr_nrdconta
				AND insitlim = 2 
				AND tpctrlim = 2;									 
		rw_craplim cr_craplim%ROWTYPE;
		
		-- Buscar cheques para alteração
		CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
		                  ,pr_nrdconta IN crapcdb.nrdconta%TYPE
											,pr_nrborder IN crapcdb.nrborder%TYPE) IS
			SELECT cdb.dtlibera
			      ,cdb.cdcmpchq
						,cdb.cdbanchq
						,cdb.cdagechq
						,cdb.nrctachq
						,cdb.nrcheque
						,cdb.vlcheque
						,cdb.dsdocmc7
						,decode(
				(SELECT 1 
				   FROM crapcst cst
				  WHERE cst.cdcooper = pr_cdcooper
				    AND cst.nrdconta = pr_nrdconta
				    AND cst.nrborder = pr_nrborder
						AND cst.cdcmpchq = cdb.cdcmpchq
						AND cst.cdbanchq = cdb.cdbanchq
						AND cst.cdagechq = cdb.cdagechq
						AND cst.nrcheque = cdb.nrcheque
						AND cst.nrctachq = cdb.nrctachq						
				 UNION
				 SELECT dcc.inconcil
				   FROM crapdcc dcc
	  			WHERE dcc.cdcooper = pr_cdcooper
						AND dcc.nrdconta = pr_nrdconta
						AND dcc.nrborder = pr_nrborder
						AND dcc.cdcmpchq = cdb.cdcmpchq
						AND dcc.cdbanchq = cdb.cdbanchq
						AND dcc.cdagechq = cdb.cdagechq
						AND dcc.nrcheque = cdb.nrcheque
						AND dcc.nrctachq = cdb.nrctachq												
						AND dcc.nrconven = 1
						AND dcc.intipmvt IN (1,3)
						AND dcc.cdtipmvt = 1
						AND trim(dcc.cdocorre) IS NULL), 1, 'Entregue', 0, 'Pendente Entrega') dssitchq,
				(SELECT cec.nmcheque 
					 FROM crapcec cec 
					WHERE cec.cdcooper = cdb.cdcooper
						AND cec.nrcpfcgc = cdb.nrcpfcgc
						AND cec.cdcmpchq = cdb.cdcmpchq
						AND cec.cdbanchq = cdb.cdbanchq
						AND cec.cdagechq = cdb.cdagechq
						AND cec.nrctachq = cdb.nrctachq
						AND cec.nrdconta = 0) nmcheque,
				(SELECT nrcpfcgc
					 FROM crapcec cec 
					WHERE cec.cdcooper = cdb.cdcooper
						AND cec.nrcpfcgc = cdb.nrcpfcgc
						AND cec.cdcmpchq = cdb.cdcmpchq
						AND cec.cdbanchq = cdb.cdbanchq
						AND cec.cdagechq = cdb.cdagechq
						AND cec.nrctachq = cdb.nrctachq
						AND cec.nrdconta = 0) nrcpfcgc					
			FROM crapcdb cdb
			WHERE cdb.cdcooper = pr_cdcooper
			  AND cdb.nrdconta = pr_nrdconta
			  AND cdb.nrborder = pr_nrborder;
				
		-- Buscar valor total dos cheques do borderô 
		CURSOR cr_crapcdb_total(pr_cdcooper IN crapcdb.cdcooper%TYPE
													 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
													 ,pr_nrborder IN crapcdb.nrborder%TYPE
													 ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
			SELECT to_char(SUM(cdb.vlcheque),'fm999g999g999g990d00') vlborder
			  FROM crapcdb cdb
			 WHERE cdb.cdcooper = pr_cdcooper
			   AND cdb.nrdconta = pr_nrdconta
				 AND cdb.nrborder = pr_nrborder
				 AND cdb.insitchq = 2
				 AND cdb.dtlibera > pr_dtmvtolt;
    rw_crapcdb_total cr_crapcdb_total%ROWTYPE;
		
    -- Burscar cheques para resgate	
	  CURSOR cr_crapcdb_rsg(pr_cdcooper IN crapcdb.cdcooper%TYPE
												 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
												 ,pr_nrborder IN crapcdb.nrborder%TYPE
												 ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
      SELECT cdb.dtlibera
			      ,cdb.cdcmpchq
						,cdb.cdbanchq
						,cdb.cdagechq
						,cdb.nrctachq
						,cdb.nrcheque
						,cdb.vlcheque
						,cdb.dsdocmc7
            ,(SELECT cec.nmcheque 
                FROM crapcec cec 
               WHERE cec.cdcooper = cdb.cdcooper
                 AND cec.nrcpfcgc = cdb.nrcpfcgc
                 AND cec.cdcmpchq = cdb.cdcmpchq
                 AND cec.cdbanchq = cdb.cdbanchq
                 AND cec.cdagechq = cdb.cdagechq
                 AND cec.nrctachq = cdb.nrctachq
                 AND cec.nrdconta = 0) nmcheque              
						,(SELECT nrcpfcgc
								FROM crapcec cec 
							 WHERE cec.cdcooper = cdb.cdcooper
								 AND cec.nrcpfcgc = cdb.nrcpfcgc
								 AND cec.cdcmpchq = cdb.cdcmpchq
								 AND cec.cdbanchq = cdb.cdbanchq
								 AND cec.cdagechq = cdb.cdagechq
								 AND cec.nrctachq = cdb.nrctachq
								 AND cec.nrdconta = 0) nrcpfcgc							 
            FROM crapcdb cdb
          WHERE cdb.cdcooper = pr_cdcooper
            AND cdb.nrdconta = pr_nrdconta
            AND cdb.nrborder = pr_nrborder	
            AND cdb.insitchq = 2
            AND cdb.dtlibera > pr_dtmvtolt; -- somente cheques a vencer												 
		
		rw_crapdat btch0001.cr_crapdat%ROWTYPE;
		
	BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);		
	
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
														
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
					
		OPEN cr_craplim(pr_cdcooper => vr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		FETCH cr_craplim INTO rw_craplim;
		
		IF cr_craplim%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_craplim;
			-- Atribui crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Número do contrato e limite disponível não encontrados.';
			-- Levanta exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fecha cursor
		CLOSE cr_craplim;
		
		-- Incluir
		IF pr_cddopcao = 'I' THEN
			pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
																		 '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp>' || 
																		 '</Dados></Root>');
    -- Alterar																		 
		ELSIF pr_cddopcao = 'A' THEN
		
			-- Buscar bordero
			OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrborder => pr_nrborder);
			FETCH cr_crapbdc INTO rw_crapbdc;
			
			IF cr_crapbdc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapbdc;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô não encontrado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapbdc;
			
      -- Se não estiver em analise ou em estudo
	    IF rw_crapbdc.insitbdc NOT IN(1,2) THEN				
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô já liberado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
		  vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
																		 '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp><Cheques>';
		
	    FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => vr_cdcooper
				                          ,pr_nrdconta => pr_nrdconta
																	,pr_nrborder => pr_nrborder) LOOP
																	
				-- Buscar inpessoa do cpf/cnpj
				gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcdb.nrcpfcgc
																	 ,pr_stsnrcal => vr_stsnrcal
																	 ,pr_inpessoa => vr_inpessoa);																	
																	
				vr_clob := vr_clob
				        || '<Cheque>'
								|| '<dtlibera>' || to_char(rw_crapcdb.dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
								|| '<cdcmpchq>' || rw_crapcdb.cdcmpchq || '</cdcmpchq>'
								|| '<cdbanchq>' || rw_crapcdb.cdbanchq || '</cdbanchq>'
								|| '<cdagechq>' || rw_crapcdb.cdagechq || '</cdagechq>'								
							  || '<nrctachq>' || CASE WHEN rw_crapcdb.cdbanchq = 1 THEN 
							                        gene0002.fn_mask(rw_crapcdb.nrctachq,'zzzz.zzz-z')
																 ELSE
							                        gene0002.fn_mask(rw_crapcdb.nrctachq,'zzzzzz.zzz-z')
  															 END                   || '</nrctachq>'

								|| '<nrcheque>' || rw_crapcdb.nrcheque || '</nrcheque>'
								|| '<vlcheque>' || to_char(rw_crapcdb.vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'								
								|| '<nmcheque>' || nvl(rw_crapcdb.nmcheque,' ') || '</nmcheque>'								
							  || '<nrcpfcgc>' || CASE WHEN trim(rw_crapcdb.nrcpfcgc) IS NOT NULL THEN 
							                        gene0002.fn_mask_cpf_cnpj(rw_crapcdb.nrcpfcgc
							                                                 ,vr_inpessoa)
																 END
							                                         || '</nrcpfcgc>'
								|| '<dssitchq>' || rw_crapcdb.dssitchq || '</dssitchq>'								
                || '<dsdocmc7>' || regexp_replace(rw_crapcdb.dsdocmc7, '[^0-9]') || '</dsdocmc7>'								
								|| '</Cheque>';
			END LOOP;
			
			vr_clob := vr_clob
			        || '</Cheques></Dados></Root>';
										
			pr_retxml := XMLTYPE.CREATEXML(vr_clob);
		-- Analisar
		ELSIF pr_cddopcao = 'N' THEN
			
			-- Buscar bordero
			OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrborder => pr_nrborder);
			FETCH cr_crapbdc INTO rw_crapbdc;
			
			IF cr_crapbdc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapbdc;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô não encontrado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapbdc;
			
      -- Se não estiver em analise ou em estudo
	    IF rw_crapbdc.insitbdc NOT IN(1,2) THEN				
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô já liberado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;

      -- Buscar informações do cheque para analise	
			DSCC0001.pc_busca_cheques_analise(pr_cdcooper => vr_cdcooper
			                                 ,pr_nrdconta => pr_nrdconta
																			 ,pr_nrborder => pr_nrborder
																			 ,pr_tab_cheques => vr_tab_cheques
																			 ,pr_cdcritic => vr_cdcritic
																			 ,pr_dscritic => vr_dscritic);
			
			-- Se houve críticas
			IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Gerar crítica
        RAISE vr_exc_erro;
			END IF;
			
		  -- Analisar os cheques do borderô
			dscc0001.pc_analisar_bordero_cheques(pr_cdcooper => vr_cdcooper
			                                    ,pr_nrdconta => pr_nrdconta
																					,pr_cdagenci => vr_cdagenci
																					,pr_idorigem => vr_idorigem
																					,pr_cdoperad => vr_cdoperad
																					,pr_nrborder => pr_nrborder
																					,pr_tab_cheques => vr_tab_cheques
																					,pr_cdcritic => vr_cdcritic
																					,pr_dscritic => vr_dscritic);

			-- Se houve críticas
			IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Gerar crítica
        RAISE vr_exc_erro;
			END IF;
			
			IF vr_tab_cheques.count > 0 THEN
				vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
									 '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
									 '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp><Cheques>';

				FOR idx IN vr_tab_cheques.first..vr_tab_cheques.last LOOP
					-- Buscar inpessoa do cpf/cnpj
					gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_cheques(idx).nrcpfcgc
																		 ,pr_stsnrcal => vr_stsnrcal
																		 ,pr_inpessoa => vr_inpessoa);																	
																		
					vr_clob := vr_clob
									|| '<Cheque>'
									|| '<dtlibera>' || to_char(vr_tab_cheques(idx).dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
									|| '<cdcmpchq>' || vr_tab_cheques(idx).cdcmpchq || '</cdcmpchq>'
									|| '<cdbanchq>' || vr_tab_cheques(idx).cdbanchq || '</cdbanchq>'
									|| '<cdagechq>' || vr_tab_cheques(idx).cdagechq || '</cdagechq>'								
									|| '<nrctachq>' || CASE WHEN vr_tab_cheques(idx).cdbanchq = 1 THEN 
																				gene0002.fn_mask(vr_tab_cheques(idx).nrctachq,'zzzz.zzz-z')
																	 ELSE
																				gene0002.fn_mask(vr_tab_cheques(idx).nrctachq,'zzzzzz.zzz-z')
																	 END                   || '</nrctachq>'

									|| '<nrcheque>' || vr_tab_cheques(idx).nrcheque || '</nrcheque>'
									|| '<nmcheque>' || nvl(vr_tab_cheques(idx).nmcheque,' ') || '</nmcheque>'								
									|| '<nrcpfcgc>' || CASE WHEN trim(vr_tab_cheques(idx).nrcpfcgc) <> 0 THEN 
																				gene0002.fn_mask_cpf_cnpj(vr_tab_cheques(idx).nrcpfcgc
																																 ,vr_inpessoa)
																	   END
																												 || '</nrcpfcgc>'
									|| '<vlcheque>' || to_char(vr_tab_cheques(idx).vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'																																				 
									|| '<dscritic>';
									
					IF vr_tab_cheques(idx).ocorrencias.count > 0 THEN
						-- Busca primeiro indice da PlTable
						vr_idx_ocorre := vr_tab_cheques(idx).ocorrencias.first;
            LOOP
							EXIT WHEN vr_idx_ocorre IS NULL;
							
							vr_clob := vr_clob						
											|| '<![CDATA['
											|| vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).cdocorre || ' - '
											|| vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).dsrestri ||' </br>]]>';

              -- Se alguma ocorrência bloqueia a operação
              IF vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).flbloque = 1 THEN
								-- Bloqueia aprovação
								vr_flbloque := 1;
							END IF;											
              vr_idx_ocorre := vr_tab_cheques(idx).ocorrencias.next(vr_idx_ocorre);
						END LOOP;
					END IF;
					vr_clob := vr_clob
					        || '</dscritic>'								
									|| '<insitana>' || vr_tab_cheques(idx).insitana || '</insitana>'								
                  || '<dsdocmc7>' || regexp_replace(vr_tab_cheques(idx).dsdocmc7, '[^0-9]') || '</dsdocmc7>'																	
									|| '<flbloque>' || vr_flbloque || '</flbloque>'									
									|| '</Cheque>';
					
				END LOOP;
				vr_clob := vr_clob
                || '</Cheques></Dados></Root>';
										
			  pr_retxml := XMLTYPE.CREATEXML(vr_clob);
				
			ELSE
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Cheques não encontrados.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
		-- Resgatar
		ELSIF pr_cddopcao = 'R' THEN
			
			-- Buscar bordero
			OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrborder => pr_nrborder);
			FETCH cr_crapbdc INTO rw_crapbdc;
			
			IF cr_crapbdc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapbdc;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô não encontrado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapbdc;
			
      -- Se não estiver liberado
	    IF rw_crapbdc.insitbdc <> 3 THEN				
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Borderô ainda não foi liberado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
		  
			-- Buscar soma do valor dos cheques do borderô
			OPEN cr_crapcdb_total(pr_cdcooper => vr_cdcooper
			                     ,pr_nrdconta => pr_nrdconta
													 ,pr_nrborder => pr_nrborder
													 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		  FETCH cr_crapcdb_total INTO rw_crapcdb_total;
			
		  vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
								 '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
								 '<vlborder>' || rw_crapcdb_total.vlborder || '</vlborder><Cheques>';

	    FOR rw_crapcdb_rsg IN cr_crapcdb_rsg(pr_cdcooper => vr_cdcooper
																					,pr_nrdconta => pr_nrdconta
																					,pr_nrborder => pr_nrborder
																					,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
																	
				-- Buscar inpessoa do cpf/cnpj
				gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcdb_rsg.nrcpfcgc
																	 ,pr_stsnrcal => vr_stsnrcal
																	 ,pr_inpessoa => vr_inpessoa);																	
																	
				vr_clob := vr_clob
				        || '<Cheque>'
								|| '<dtlibera>' || to_char(rw_crapcdb_rsg.dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
								|| '<cdcmpchq>' || rw_crapcdb_rsg.cdcmpchq || '</cdcmpchq>'
								|| '<cdbanchq>' || rw_crapcdb_rsg.cdbanchq || '</cdbanchq>'
								|| '<cdagechq>' || rw_crapcdb_rsg.cdagechq || '</cdagechq>'								
							  || '<nrctachq>' || CASE WHEN rw_crapcdb_rsg.cdbanchq = 1 THEN 
							                        gene0002.fn_mask(rw_crapcdb_rsg.nrctachq,'zzzz.zzz-z')
																 ELSE
							                        gene0002.fn_mask(rw_crapcdb_rsg.nrctachq,'zzzzzz.zzz-z')
  															 END                   || '</nrctachq>'

								|| '<nrcheque>' || rw_crapcdb_rsg.nrcheque || '</nrcheque>'
								|| '<nmcheque>' || nvl(rw_crapcdb_rsg.nmcheque,' ') || '</nmcheque>'								
							  || '<nrcpfcgc>' || CASE WHEN trim(rw_crapcdb_rsg.nrcpfcgc) IS NOT NULL THEN 
							                        gene0002.fn_mask_cpf_cnpj(rw_crapcdb_rsg.nrcpfcgc
							                                                 ,vr_inpessoa)
																 END
							                                         || '</nrcpfcgc>'
								|| '<vlcheque>' || to_char(rw_crapcdb_rsg.vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'																																			 
                || '<dsdocmc7>' || regexp_replace(rw_crapcdb_rsg.dsdocmc7, '[^0-9]') || '</dsdocmc7>'								
								|| '</Cheque>';
			END LOOP;
			
			vr_clob := vr_clob
			        || '</Cheques></Dados></Root>';
										
			pr_retxml := XMLTYPE.CREATEXML(vr_clob);

		END IF;
		
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_busca_cheques_dsc_cst: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

	
	END pc_busca_inf_bordero;

  PROCEDURE pc_busca_cheques_dsc_cst(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
		                                ,pr_nriniseq  IN INTEGER                --> Paginação - Inicio de sequencia
																		,pr_nrregist  IN INTEGER                --> Paginação - Número de registros
																		,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																		,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																		,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																		,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
																		,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_busca_cheques_dsc_cst
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar cheques em custodia para desconto

    Alteracoes: -----
  ..............................................................................*/
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis auxiliares
    vr_qtregist NUMBER;
		vr_inpessoa NUMBER;
		vr_stsnrcal BOOLEAN;
		
    --PlTable com dados dos cheques
    vr_tab_cstdsc DSCC0001.typ_tab_cstdsc;

    -- Variáveis XML
		vr_clob CLOB;

		-- Cursor da data
		rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;		

	BEGIN	
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                                ,pr_action => NULL);	
	
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
														
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
														
    -- Busca cheques de custodia
    DSCC0001.pc_busca_cheques_dsc_cst(pr_cdcooper => vr_cdcooper
		                                 ,pr_nrdconta => pr_nrdconta
																		 ,pr_cdagenci => vr_cdagenci
																		 ,pr_nrdcaixa => vr_nrdcaixa
																		 ,pr_cdoperad => vr_cdoperad
																		 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																		 ,pr_idorigem => vr_idorigem
																		 ,pr_nriniseq => pr_nriniseq
																		 ,pr_nrregist => pr_nrregist
																		 ,pr_qtregist => vr_qtregist
																		 ,pr_tab_cstdsc => vr_tab_cstdsc
																		 ,pr_cdcritic => vr_cdcritic
																		 ,pr_dscritic => vr_dscritic);
											
		-- Se ocorreu algum erro 							 
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levanta exceção
		  RAISE vr_exc_erro;
		END IF;

    -- Se não houver nenhum cheque na PlTable
    IF vr_tab_cstdsc.count = 0 THEN
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Cheques não encontrados';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?>'
            || '<Root><Dados>';
		
		FOR idx IN vr_tab_cstdsc.first..vr_tab_cstdsc.last LOOP
		
		  gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_cstdsc(idx).nrcpfcgc
			                           ,pr_stsnrcal => vr_stsnrcal
																 ,pr_inpessoa => vr_inpessoa);
		
			vr_clob := vr_clob 
			        || '<Cheque>'
							|| '<dstipchq>' || vr_tab_cstdsc(idx).dstipchq                                 || '</dstipchq>'
							|| '<dtmvtolt>' || to_char(vr_tab_cstdsc(idx).dtmvtolt,'DD/MM/RRRR')           || '</dtmvtolt>'
							|| '<dtlibera>' || to_char(vr_tab_cstdsc(idx).dtlibera,'DD/MM/RRRR')           || '</dtlibera>'
							|| '<cdcmpchq>' || vr_tab_cstdsc(idx).cdcmpchq                                 || '</cdcmpchq>'
							|| '<cdbanchq>' || vr_tab_cstdsc(idx).cdbanchq                                 || '</cdbanchq>'
							|| '<cdagechq>' || gene0002.fn_mask_contrato(vr_tab_cstdsc(idx).cdagechq)      || '</cdagechq>'
							|| '<nrctachq>' || CASE WHEN vr_tab_cstdsc(idx).cdbanchq = 1 THEN 
							                        gene0002.fn_mask(vr_tab_cstdsc(idx).nrctachq,'zzzz.zzz-z')
																 ELSE
							                        gene0002.fn_mask(vr_tab_cstdsc(idx).nrctachq,'zzzzzz.zzz-z')
  															 END                                                         || '</nrctachq>'
							|| '<nrcheque>' || gene0002.fn_mask_contrato(vr_tab_cstdsc(idx).nrcheque)      || '</nrcheque>'
							|| '<vlcheque>' || to_char(vr_tab_cstdsc(idx).vlcheque,'fm999g999g999g990d00') || '</vlcheque>'
							|| '<inconcil>' || CASE WHEN vr_tab_cstdsc(idx).inconcil = 1 THEN 
							                        'Entregue' 
																 ELSE 
																	    'Pendente de entrega' 
																 END                                                         || '</inconcil>'
							|| '<nmcheque>' || vr_tab_cstdsc(idx).nmcheque                                 || '</nmcheque>'
							|| '<nrcpfcgc>' || CASE WHEN trim(vr_tab_cstdsc(idx).nrcpfcgc) IS NOT NULL THEN 
							                        gene0002.fn_mask_cpf_cnpj(vr_tab_cstdsc(idx).nrcpfcgc
							                                                 ,vr_inpessoa)
																 END
							                                                                               || '</nrcpfcgc>'
              || '<dsdocmc7>' || regexp_replace(vr_tab_cstdsc(idx).dsdocmc7, '[^0-9]')       || '</dsdocmc7>'
						  || '<dtdcaptu>' || to_char(vr_tab_cstdsc(idx).dtdcaptu,'DD/MM/RRRR')           || '</dtdcaptu>'
						  || '<dtcustod>' || CASE WHEN trim(vr_tab_cstdsc(idx).dtcustod) IS NOT NULL THEN 
							                        to_char(vr_tab_cstdsc(idx).dtcustod,'DD/MM/RRRR')           
																 END                                                         || '</dtcustod>'	
							|| '<nrremret>' || vr_tab_cstdsc(idx).nrremret                                 || '</nrremret>'																 
			        || '</Cheque>';

		END LOOP;
		-- Fechar tag de dados do xml de retorno
		vr_clob := vr_clob || '</Dados><Qtregist>' || vr_qtregist || '</Qtregist></Root>';
		
    -- Envia retorno do XML		
    pr_retxml := XMLType.createXML(vr_clob);

	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_busca_cheques_dsc_cst: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		
	END pc_busca_cheques_dsc_cst;

  PROCEDURE pc_verifica_emitentes(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
																 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador 
																 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  BEGIN
  /* .............................................................................
    Programa: pc_verifica_emitentes
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar emitentes dos cheques informados para 
		            inclusão/alteração de borderô

    Alteracoes: -----
  ..............................................................................*/
    DECLARE
		
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_exc_emiten EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);						
			
      /* Vetor para armazenar as informac?es de erro */
      vr_xml_emitentes VARCHAR2(32726);
			
      /* Vetor para armazenar as informacoes dos cheques que estao sendo custodiados */
      vr_tab_cheques DSCC0001.typ_tab_cheques;
			
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

      -- Verificar emitentes
      DSCC0001.pc_verifica_emitentes(pr_cdcooper => vr_cdcooper
			                              ,pr_nrdconta => pr_nrdconta
																		,pr_dscheque => pr_dscheque
																		,pr_tab_cheques => vr_tab_cheques
																		,pr_cdcritic => vr_cdcritic
																		,pr_dscritic => vr_dscritic);
			
			-- Se retornou erro												 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  --Levantar Excecao
			  RAISE vr_exc_erro;
		  END IF;
															 															 			
			-- Verificar se possui algum emitente não cadastrado
			IF vr_tab_cheques.count > 0 THEN
				vr_xml_emitentes := '';
				FOR vr_index_cheque IN 1..vr_tab_cheques.count LOOP
					-- Se exister algum cheque sem emitente
					IF vr_tab_cheques(vr_index_cheque).inemiten = 0 THEN
						-- Passar flag de falta de cadastro de emitente
						vr_xml_emitentes := vr_xml_emitentes ||
						                    '<emitente'|| vr_index_cheque || '>' ||
																'   <cdcmpchq>' || vr_tab_cheques(vr_index_cheque).cdcmpchq || '</cdcmpchq>' ||
																'   <cdbanchq>' || vr_tab_cheques(vr_index_cheque).cdbanchq || '</cdbanchq>' ||
																'   <cdagechq>' || vr_tab_cheques(vr_index_cheque).cdagechq || '</cdagechq>' ||
																'   <nrctachq>' || vr_tab_cheques(vr_index_cheque).nrctachq || '</nrctachq>' ||
						                    '</emitente'|| vr_index_cheque || '>';
					END IF;
				END LOOP;
				IF trim(vr_xml_emitentes) IS NOT NULL THEN
					RAISE vr_exc_emiten;
				END IF;
			END IF;
									
    EXCEPTION
			WHEN vr_exc_emiten THEN
        pr_cdcritic := 0;
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Emitentes>' || vr_xml_emitentes || '</Emitentes></Root>');				
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_verifica_emitentes: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_verifica_emitentes;

  PROCEDURE pc_manter_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
														 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
														 ,pr_nrdolote  IN crapbdc.nrdolote%TYPE  --> Lote
														 ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
														 ,pr_dscheque  IN CLOB                   --> Cheques
														 ,pr_dscheque_exc IN CLOB                --> Cheques a serem excluidos do bordero
														 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
														 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
														 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
														 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
														 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_manter_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para manter os borderos de desconto de cheque

    Alteracoes: -----
  ..............................................................................*/
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Informações do cheque
		vr_dsdocmc7 VARCHAR2(45);
		vr_cdbanchq NUMBER; 
		vr_cdagechq NUMBER;
		vr_cdcmpchq NUMBER;
		vr_nrctachq NUMBER;
		vr_nrcheque NUMBER;
		vr_vlcheque NUMBER;
		vr_intipchq NUMBER;
		vr_dtlibera DATE;
		vr_dtcustod DATE;
		vr_dtdcaptu DATE;		
		vr_nrremret NUMBER;
		vr_nrborder NUMBER := pr_nrborder;
		vr_nrdolote NUMBER := pr_nrdolote;
		
		vr_tab_cheques dscc0001.typ_tab_cheques;
		vr_index_cheque NUMBER;
		vr_ret_cheques gene0002.typ_split;
		vr_ret_cheques_exc gene0002.typ_split;		
		vr_ret_all_cheques gene0002.typ_split;		
		vr_ret_all_cheques_exc gene0002.typ_split;
		
		-- Busca informações do emitente
		CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE
											,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
											,pr_cdbanchq IN crapcec.cdbanchq%TYPE
											,pr_cdagechq IN crapcec.cdagechq%TYPE
											,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
			SELECT cec.nrcpfcgc
						,cec.nmcheque
				FROM crapcec cec
			 WHERE cec.cdcooper = pr_cdcooper
				 AND cec.cdcmpchq = pr_cdcmpchq
				 AND cec.cdbanchq = pr_cdbanchq
				 AND cec.cdagechq = pr_cdagechq
				 AND cec.nrctachq = pr_nrctachq
				 AND cec.nrdconta = 0;
		rw_crapcec cr_crapcec%ROWTYPE;
		
		rw_crapdat btch0001.cr_crapdat%ROWTYPE;
		
  BEGIN
		
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);	
	
	  -- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
	
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  
		
		IF trim(pr_dscheque_exc) IS NOT NULL AND pr_cddopcao = 'A' THEN
      -- Cria array com todos os registros de cheques			
			vr_ret_all_cheques_exc := gene0002.fn_quebra_string(pr_dscheque_exc, '|');
			
			FOR vr_auxcont IN 1..vr_ret_all_cheques_exc.count LOOP				
				-- Criando um array com todas as informações do cheque
			  vr_ret_cheques_exc := gene0002.fn_quebra_string(vr_ret_all_cheques_exc(vr_auxcont), ';');
				
        -- Data de liberação
			  vr_dtlibera := to_date(vr_ret_cheques_exc(1),'dd/mm/RRRR');
				
   			-- Buscar o cmc7			
				vr_dsdocmc7 := vr_ret_cheques_exc(2);
							
				-- Desmontar as informações do CMC-7
				-- Banco
				vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
				-- Agencia
				vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
				-- Compe
				vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
				-- Numero do Cheque
				vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
				-- Conta do Cheque
				IF vr_cdbanchq = 1 THEN
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
				ELSE 
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
				END IF;

				-- Carrega as informações do cheque para o bordero
				vr_index_cheque := vr_tab_cheques.count + 1;  
				vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
				vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
				vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
				vr_tab_cheques(vr_index_cheque).dsdocmc7 := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
				vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
				vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
				vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
				vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
				vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;

			END LOOP;
			
			-- Remover cheques do bordero
			DSCC0001.pc_excluir_cheque_bordero(pr_cdcooper => vr_cdcooper
			                                  ,pr_nrdconta => pr_nrdconta
																				,pr_cdagenci => vr_cdagenci
																				,pr_idorigem => vr_idorigem
																				,pr_cdoperad => vr_cdoperad
																				,pr_nrborder => pr_nrborder
																				,pr_tab_cheques => vr_tab_cheques
																				,pr_cdcritic => pr_cdcritic
																				,pr_dscritic => pr_dscritic);
			-- Se houve críticas													 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;	 

		END IF;
		
		-- Limpar PlTable
		vr_tab_cheques.DELETE();
			
		IF trim(pr_dscheque) IS NOT NULL THEN
			-- Criando um Array com todos os cheques que vieram como parametro
			vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
			
			-- Percorre todos os cheques para processá-los
			FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
				-- Criando um array com todas as informações do cheque
				vr_ret_cheques := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');
				-- Data de liberação
				vr_dtlibera := to_date(vr_ret_cheques(1),'dd/mm/RRRR');
				-- Data de emissão
				vr_dtdcaptu := to_date(vr_ret_cheques(2),'dd/mm/RRRR');
				IF TRIM(vr_ret_cheques(3)) IS NOT NULL THEN
					-- Data da custódia
					vr_dtcustod := to_date(vr_ret_cheques(3),'dd/mm/RRRR');
				ELSE
					vr_dtcustod := NULL;
				END IF;
				-- Tipo de cheque (1 - Novo, 2 - Selecionado)
				vr_intipchq := to_number(vr_ret_cheques(4));
				-- Valor do cheque
				vr_vlcheque := to_number(vr_ret_cheques(5));
				-- Buscar o cmc7			
				vr_dsdocmc7 := vr_ret_cheques(6);
  			-- Nr. da remessa
				vr_nrremret := vr_ret_cheques(7);
							
				-- Desmontar as informações do CMC-7
				-- Banco
				vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
				-- Agencia
				vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
				-- Compe
				vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
				-- Numero do Cheque
				vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
				-- Conta do Cheque
				IF vr_cdbanchq = 1 THEN
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
				ELSE 
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
				END IF;
				
				-- Verificar se possui emitente cadastrado
				OPEN cr_crapcec(pr_cdcooper => vr_cdcooper
											 ,pr_cdcmpchq => vr_cdcmpchq
											 ,pr_cdbanchq => vr_cdbanchq
											 ,pr_cdagechq => vr_cdagechq
											 ,pr_nrctachq => vr_nrctachq);
				FETCH cr_crapcec INTO rw_crapcec;
					
				-- Se não encontrou emitente 
				IF cr_crapcec%NOTFOUND THEN
					-- Fechar cursor
					CLOSE cr_crapcec;
					-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Emitente não cadastrado';
					-- Levantar exceção
					RAISE vr_exc_erro;
				END IF;
				
				-- Fechar cursor
				CLOSE cr_crapcec;
				
				-- Carrega as informações do cheque para o bordero
				vr_index_cheque := vr_tab_cheques.count + 1;  
				vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
				vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
				vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
				vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapdat.dtmvtolt;			
				vr_tab_cheques(vr_index_cheque).dtcustod := vr_dtcustod;
				vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
				vr_tab_cheques(vr_index_cheque).dtdcaptu := vr_dtdcaptu;
				vr_tab_cheques(vr_index_cheque).intipchq := vr_intipchq;
				vr_tab_cheques(vr_index_cheque).vlcheque := vr_vlcheque;
				vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
				vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
				vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
				vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
				vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
				vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
				vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapcec.nrcpfcgc;
				vr_tab_cheques(vr_index_cheque).nrremret := vr_nrremret;

			END LOOP;	
										
			IF pr_cddopcao = 'I' THEN
				-- Cria bordero			
				dscc0001.pc_criar_bordero_cheques(pr_cdcooper => vr_cdcooper
																				 ,pr_nrdconta => pr_nrdconta
																				 ,pr_cdagenci => vr_cdagenci
																				 ,pr_idorigem => vr_idorigem
																				 ,pr_cdoperad => vr_cdoperad
																				 ,pr_nrborder => vr_nrborder
																				 ,pr_nrdolote => vr_nrdolote
																				 ,pr_cdcritic => vr_cdcritic
																				 ,pr_dscritic => vr_dscritic);
				-- Se houve críticas													 
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
			END IF;
			-- Adicionar cheques ao bordero
			DSCC0001.pc_adicionar_cheques_bordero(pr_cdcooper => vr_cdcooper
																					 ,pr_nrdconta => pr_nrdconta
																					 ,pr_cdagenci => vr_cdagenci
																					 ,pr_idorigem => vr_idorigem 
																					 ,pr_cdoperad => vr_cdoperad
																					 ,pr_nrborder => vr_nrborder
																					 ,pr_nrdolote => vr_nrdolote
																					 ,pr_tab_cheques => vr_tab_cheques
																					 ,pr_cdcritic => vr_cdcritic
																					 ,pr_dscritic => vr_dscritic);
			-- Se houve críticas													 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;	 

		END IF;
		-- Efetuar commit
		COMMIT;
		
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_manter_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		
	END pc_manter_bordero;

  PROCEDURE pc_aprovar_reprovar_chq(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																	 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																	 ,pr_dscheque  IN CLOB                   --> Cheques
																	 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																	 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																	 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																	 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																	 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																	 ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_aprovar_reprovar_chq
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para aprovar/reprovar os cheques do borderô

    Alteracoes: -----
  ..............................................................................*/
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Informações do cheque
		vr_dsdocmc7 VARCHAR2(45);
		vr_cdbanchq NUMBER; 
		vr_cdagechq NUMBER;
		vr_cdcmpchq NUMBER;
		vr_nrctachq NUMBER;
		vr_nrcheque NUMBER;
		vr_flgaprov NUMBER;
		
		vr_tab_cheques dscc0001.typ_tab_cheques;
		vr_index_cheque NUMBER;
		vr_ret_cheques gene0002.typ_split;
		vr_ret_all_cheques gene0002.typ_split;		
		
		rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
		
		-- Buscar informações do cheque no borderô
		CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
		                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
										 ,pr_nrborder IN crapcdb.nrborder%TYPE
										 ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
										 ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
										 ,pr_cdagechq IN crapcdb.cdagechq%TYPE
										 ,pr_nrctachq IN crapcdb.nrctachq%TYPE
										 ,pr_nrcheque IN crapcdb.nrcheque%TYPE) IS
		  SELECT cdb.vlcheque
			      ,cdb.dtlibera
						,cdb.dtemissa
						,cdb.dtmvtolt
						,cdb.nrremret
			 FROM crapcdb cdb
			WHERE cdb.cdcooper = pr_cdcooper
			  AND cdb.nrdconta = pr_nrdconta
				AND cdb.nrborder = pr_nrborder
				AND cdb.cdcmpchq = pr_cdcmpchq
				AND cdb.cdbanchq = pr_cdbanchq
				AND cdb.cdagechq = pr_cdagechq
				AND cdb.nrctachq = pr_nrctachq
				AND cdb.nrcheque = pr_nrcheque;
		rw_crapcdb cr_crapcdb%ROWTYPE;
		
  BEGIN		
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);	
	
	  -- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
	
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  

		IF trim(pr_dscheque) IS NOT NULL THEN
			-- Criando um Array com todos os cheques que vieram como parametro
			vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
			
			-- Percorre todos os cheques para processá-los
			FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
				-- Criando um array com todas as informações do cheque
				vr_ret_cheques := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');
				-- CMC77			
				vr_dsdocmc7 := vr_ret_cheques(1);
  			-- Flag aprovação/reprovação cheque
				vr_flgaprov := vr_ret_cheques(2);
											
				-- Desmontar as informações do CMC-7
				-- Banco
				vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
				-- Agencia
				vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
				-- Compe
				vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
				-- Numero do Cheque
				vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
				-- Conta do Cheque
				IF vr_cdbanchq = 1 THEN
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
				ELSE 
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
				END IF;
				-- Buscar informações do cheque no borderô						
				OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper
											 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrborder => pr_nrborder
											 ,pr_cdcmpchq => vr_cdcmpchq
											 ,pr_cdbanchq => vr_cdbanchq
											 ,pr_cdagechq => vr_cdagechq
											 ,pr_nrctachq => vr_nrctachq
											 ,pr_nrcheque => vr_nrcheque);
				FETCH cr_crapcdb INTO rw_crapcdb;
				
				-- Se não encontrou
				IF cr_crapcdb%NOTFOUND THEN
					-- Fechar cursor
					CLOSE cr_crapcdb;
					-- Gerar crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Cheque não encontrado no borderô.';
					-- Levantar exceção
					RAISE vr_exc_erro;
				END IF;
				-- Fechar cursor
				CLOSE cr_crapcdb;
				
				-- Carrega as informações do cheque para o bordero
				vr_index_cheque := vr_tab_cheques.count + 1;  
				vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
				vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
				vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
				vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;			
				vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
				vr_tab_cheques(vr_index_cheque).dtdcaptu := rw_crapcdb.dtemissa;
				vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
				vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
				vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
				vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
				vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
				vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
				vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
				vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
				vr_tab_cheques(vr_index_cheque).flgaprov := vr_flgaprov;

			END LOOP;	
			
			-- Chamar rotina para aprovar/reprovar o cheque
			DSCC0001.pc_aprovar_reprovar_chq(pr_cdcooper => vr_cdcooper
																			,pr_nrdconta => pr_nrdconta
																			,pr_cdagenci => vr_cdagenci
																			,pr_idorigem => vr_idorigem
																			,pr_cdoperad => vr_cdoperad
																			,pr_nrborder => pr_nrborder
																			,pr_tab_cheques => vr_tab_cheques
																			,pr_cdcritic => vr_cdcritic
																			,pr_dscritic => vr_dscritic);
			-- Se retornou alguma crítica													
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar execeção
				RAISE vr_exc_erro;
			END IF;

    END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_manter_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_aprovar_reprovar_chq;
	
	PROCEDURE pc_efetiva_desconto_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																			 ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																			 ,pr_cdopcolb  IN crapbdc.cdopcolb%TYPE  --> Operador Liberação
																			 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																			 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																			 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																			 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																			 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																			 ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_efetiva_desconto_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para liberar (ou efetivar) a operação de desconto de cheques. 
		            Este procedimento realiza a finalização da operação de desconto de 
								cheque, onde é creditado o valor líquido da operação na conta do 
								cooperado, como também os encargos (IOF e tarifa (se houver)).

    Alteracoes: -----
  ..............................................................................*/
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;
		
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
	
	BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);	
		
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  
														
		-- Efetivar desconto do bordero
    DSCC0001.pc_efetiva_desconto_bordero(pr_cdcooper => vr_cdcooper
		                                    ,pr_nrdconta => pr_nrdconta
																				,pr_nrborder => pr_nrborder
																				,pr_cdoperad => vr_cdoperad
																				,pr_cdagenci => vr_cdagenci
																				,pr_cdopcolb => pr_cdopcolb
																				,pr_cdcritic => vr_cdcritic
																				,pr_dscritic => vr_dscritic);
		-- Se retornou alguma crítica															
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
	  -- Efetuar commit
		COMMIT;
		
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_manter_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');		
	END pc_efetiva_desconto_bordero;
	
	PROCEDURE pc_verifica_assinatura_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
																					,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
																					,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
																					,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
																					,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
																					,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
																					,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
																					,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_verifica_assinatura_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Verificar se o bordero necessita de assinatura para liberação.

    Alteracoes: -----
  ..............................................................................*/																			 
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Buscar borderô de desconto
		CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
										 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
										 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
			SELECT bdc.insitbdc
						,bdc.flgassin
						,bdc.dhdassin
						,bdc.cdopeasi
				FROM crapbdc bdc
			 WHERE bdc.cdcooper = pr_cdcooper
				 AND bdc.nrdconta = pr_nrdconta
				 AND bdc.nrborder = pr_nrborder;
		rw_crapbdc cr_crapbdc%ROWTYPE;

	BEGIN
	  -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);	
	
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  
	
	  -- Buscar borderô de desconto
    OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
	
	  -- Se não encontrou borderô
	  IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Borderô de desconto de cheque não encontrado.';
			-- Levanta exceção
			RAISE vr_exc_erro;
		END IF;
	
	  -- Se borderô já foi liberado
	  IF rw_crapbdc.insitbdc > 2 THEN
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Borderô já foi liberado.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	
	  -- Se borderô precisa de assinatura
	  IF rw_crapbdc.flgassin = 1 THEN
			IF trim(rw_crapbdc.dhdassin) IS NULL AND trim(rw_crapbdc.cdopeasi) IS NULL THEN
	      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><flgassin>1</flgassin></Root>');
			END IF;
		END IF;
		
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_manter_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');				
	END pc_verifica_assinatura_bordero;
	
  PROCEDURE pc_efetuar_resgate(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
														  ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
														  ,pr_dscheque  IN CLOB                   --> Cheques
														  ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
														  ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
														  ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
														  ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
														  ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
														  ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_efetuar_resgate
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 06/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para efetuar resgate dos cheques do bordero

    Alteracoes: 
                                                     
  ............................................................................. */
	
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Informações do cheque
		vr_dsdocmc7 VARCHAR2(45);
		vr_cdbanchq NUMBER; 
		vr_cdagechq NUMBER;
		vr_cdcmpchq NUMBER;
		vr_nrctachq NUMBER;
		vr_nrcheque NUMBER;
		vr_flgaprov NUMBER;
		
		vr_tab_cheques dscc0001.typ_tab_cheques;
		vr_index_cheque NUMBER;
		vr_ret_cheques gene0002.typ_split;
		
		rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
		
		-- Buscar informações do cheque no borderô
		CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
		                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
										 ,pr_nrborder IN crapcdb.nrborder%TYPE
										 ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
										 ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
										 ,pr_cdagechq IN crapcdb.cdagechq%TYPE
										 ,pr_nrctachq IN crapcdb.nrctachq%TYPE
										 ,pr_nrcheque IN crapcdb.nrcheque%TYPE) IS
		  SELECT cdb.vlcheque
			      ,cdb.dtlibera
						,cdb.dtemissa
						,cdb.dtmvtolt
						,cdb.nrremret
						,cdb.insitchq
            ,cdb.nrddigc3
            ,cdb.inchqcop
            ,cdb.vlliquid			
			 FROM crapcdb cdb
			WHERE cdb.cdcooper = pr_cdcooper
			  AND cdb.nrdconta = pr_nrdconta
				AND cdb.nrborder = pr_nrborder
				AND cdb.cdcmpchq = pr_cdcmpchq
				AND cdb.cdbanchq = pr_cdbanchq
				AND cdb.cdagechq = pr_cdagechq
				AND cdb.nrctachq = pr_nrctachq
				AND cdb.nrcheque = pr_nrcheque;
		rw_crapcdb cr_crapcdb%ROWTYPE;
		
  BEGIN		
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCONTO'
                              ,pr_action => NULL);	
	
	  -- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
	
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  

		IF trim(pr_dscheque) IS NOT NULL THEN
			-- Criando um Array com todos os cheques que vieram como parametro
			vr_ret_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
			
			-- Percorre todos os cheques para processá-los
			FOR vr_auxcont IN 1..vr_ret_cheques.count LOOP
				-- CMC77			
				vr_dsdocmc7 := vr_ret_cheques(vr_auxcont);											
				-- Desmontar as informações do CMC-7
				-- Banco
				vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
				-- Agencia
				vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
				-- Compe
				vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
				-- Numero do Cheque
				vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
				-- Conta do Cheque
				IF vr_cdbanchq = 1 THEN
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
				ELSE 
					vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
				END IF;
				-- Buscar informações do cheque no borderô						
				OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper
											 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrborder => pr_nrborder
											 ,pr_cdcmpchq => vr_cdcmpchq
											 ,pr_cdbanchq => vr_cdbanchq
											 ,pr_cdagechq => vr_cdagechq
											 ,pr_nrctachq => vr_nrctachq
											 ,pr_nrcheque => vr_nrcheque);
				FETCH cr_crapcdb INTO rw_crapcdb;
				
				-- Se não encontrou
				IF cr_crapcdb%NOTFOUND THEN
					-- Fechar cursor
					CLOSE cr_crapcdb;
					-- Gerar crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Cheque não encontrado no borderô.';
					-- Levantar exceção
					RAISE vr_exc_erro;
				END IF;
				-- Fechar cursor
				CLOSE cr_crapcdb;
				
				-- Carrega as informações do cheque para o bordero
				vr_index_cheque := vr_tab_cheques.count + 1;  
				vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
				vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
				vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
				vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;			
				vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
				vr_tab_cheques(vr_index_cheque).dtdcaptu := rw_crapcdb.dtemissa;
				vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
				vr_tab_cheques(vr_index_cheque).dsdocmc7 := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
				vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
				vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
				vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
				vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
				vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
				vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
				vr_tab_cheques(vr_index_cheque).flgaprov := vr_flgaprov;
				vr_tab_cheques(vr_index_cheque).insitchq := rw_crapcdb.insitchq;
				vr_tab_cheques(vr_index_cheque).nrddigc3 := rw_crapcdb.nrddigc3;
				vr_tab_cheques(vr_index_cheque).inchqcop := rw_crapcdb.inchqcop;
				vr_tab_cheques(vr_index_cheque).vlliquid := rw_crapcdb.vlliquid;

			END LOOP;	
			
			-- Chamar rotina para aprovar/reprovar o cheque
			DSCC0001.pc_resgata_cheques_bordero(pr_cdcooper => vr_cdcooper
			                                   ,pr_nrdconta => pr_nrdconta
																				 ,pr_nrborder => pr_nrborder
																				 ,pr_cdoperad => vr_cdoperad
																				 ,pr_tab_cheques => vr_tab_cheques
																				 ,pr_cdcritic => vr_cdcritic
																				 ,pr_dscritic => vr_dscritic);
			-- Se retornou alguma crítica													
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar execeção
				RAISE vr_exc_erro;
			END IF;

    END IF;
		
		-- Efetuar commit
		COMMIT;
	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetuar_resgate: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_efetuar_resgate;

END TELA_ATENDA_DESCONTO;
/
