CREATE OR REPLACE PACKAGE TELA_CUSTOD IS

  /*-------------------------------------------------------------------------
  --
  --  Programa : TELA_CUSTOD
  --  Sistema  : Rotinas utilizadas pela Tela CUSTOD
  --  Sigla    : CUSTOD
  --  Autor    : Lucas Reinert
  --  Data     : Setembro/2016.                   Ultima atualizacao:
	--
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela COBRAN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
	-- Criar tipo de PLTable para armazenar as informações de erro
	TYPE typ_reg_erro_resgate IS
		RECORD(dsdocmc7 crapdcc.dsdocmc7%TYPE
					,dscritic VARCHAR2(4000));
	TYPE typ_erro_resgate IS
		TABLE OF typ_reg_erro_resgate
		INDEX BY BINARY_INTEGER;					
		
  --Criar tipo de PlTable para armazenar a quantidade de cheques com tarifa de custódia				
	TYPE typ_tab_lat IS
 		TABLE OF NUMBER	INDEX BY BINARY_INTEGER;

  -- Validar cheques informados para resgate
  PROCEDURE pc_valida_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
														 
  -- Efetuar resgate dos cheques informados														 
	PROCEDURE pc_efetua_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo														 

  -- Validar cheques informados para cancelamento de resgate
  PROCEDURE pc_valida_canc_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														      ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
	
	-- Efetuar cancelamento do resgate dos cheques informados																
	PROCEDURE pc_efetua_canc_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														      ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
																	
  -- Busca remessas de cheques custodiados																	
	PROCEDURE pc_busca_remessas(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dtinicst IN VARCHAR2               --> Lista de CMC7s
														 ,pr_dtfimcst IN VARCHAR2               --> Lista de CMC7s
														 ,pr_cdagenci IN PLS_INTEGER            --> PA da da Custodia
														 ,pr_insithcc IN NUMBER                 --> Lista de CMC7s														 
														 ,pr_nriniseq IN NUMBER                 --> Número inicial da sequência
														 ,pr_nrregist IN NUMBER                 --> Número de registros a retornar														 
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Busca cheques custodiados da remessa informada
	PROCEDURE pc_busca_cheques_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																	  ,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																	  ,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																	  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																	  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																	  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																	  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																	  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																	  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Busca detalhes do cheque informado
	PROCEDURE pc_busca_detalhe_cheque(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																	 ,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																	 ,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																	 ,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																	 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																	 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																	 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																	 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																	 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																	 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Alterar detalhe do cheque
	PROCEDURE pc_altera_detalhe_cheque(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																		,pr_dtemissa IN VARCHAR2               --> Data de emissão
																		,pr_dtlibera IN VARCHAR2               --> Data boa
																		,pr_vlcheque IN crapdcc.vlcheque%TYPE  --> Valor do cheque
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2);            --> Erros do processo
																		
  -- Excluir cheque da remessa	
	PROCEDURE pc_exclui_cheque_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2);            --> Erros do processo
																		
	-- Conciliar/desconciliar cheques
	PROCEDURE pc_conciliar_cheques(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																,pr_dscheque IN crapdcc.dsdocmc7%TYPE  --> Informações do cheque
																,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);            --> Erros do processo																		
								
	-- Conciliar todos os cheques da remessa
	PROCEDURE pc_conciliar_todos_cheques(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																			,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																			,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																			,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																			,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																			,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																			,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			,pr_des_erro OUT VARCHAR2);            --> Erros do processo
								
  -- Rotina para verifica os cheques não conciliados da remessa
  PROCEDURE pc_verifica_cheques_conc(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2);            --> Erros do processo
			
  -- Custodiar os cheques conciliados na remessa
	PROCEDURE pc_custodiar_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Gerar prévia da remessa	
	PROCEDURE pc_gera_previa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
													,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
													,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
													,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador
													,pr_cdcritic OUT PLS_INTEGER           --> Cód. da crítica
													,pr_dscritic OUT VARCHAR2);            --> Desc. da crítica

	-- Excluir remessa de custódia
	PROCEDURE pc_excluir_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
															,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
															,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
															,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
															,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
															,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
															,pr_des_erro OUT VARCHAR2);            --> Erros do processo

	
END TELA_CUSTOD;
/
CREATE OR REPLACE PACKAGE BODY TELA_CUSTOD IS
  /*-------------------------------------------------------------------------
  --
  --  Programa : TELA_CUSTOD
  --  Sistema  : Rotinas utilizadas pela Tela CUSTOD
  --  Sigla    : CUSTOD
  --  Autor    : Lucas Reinert
  --  Data     : Setembro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CUSTOD
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/
	
  -- Validar cheques informados para resgate
  PROCEDURE pc_valida_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_valida_resgate
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 01/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar os cheques para resgate

    Alteracoes: 
                                                     
  ............................................................................. */
		DECLARE
		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			

      -- Variáveis locais
      vr_ret_all_cheques gene0002.typ_split;
			vr_dsdocmc7 VARCHAR2(4000);
      vr_dsdocmc7_formatado VARCHAR2(40);
		  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
			-- Clob com informações do xml de retorno
			vr_clob CLOB;
							
			-- PlTable para armazenar informações de erro
      vr_tab_resgate_erro typ_erro_resgate;
      vr_index_erro INTEGER;
      vr_xml_erro_resgate VARCHAR2(32726);

      -- Criar tipo de PLTable para armazenar as informações do cheque
      TYPE typ_reg_inf_resgate IS
        RECORD(dsdocmc7 crapcst.dsdocmc7%TYPE
              ,dtlibera VARCHAR2(10)
							,vlcheque VARCHAR2(30));
      TYPE typ_inf_resgate IS
        TABLE OF typ_reg_inf_resgate
        INDEX BY BINARY_INTEGER;				

			-- PlTable para armazenar informações de erro
      vr_tab_resgate_inf typ_inf_resgate;
      vr_index_resg INTEGER;
      vr_xml_inf_resgate VARCHAR2(32726);
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
			
	  -- Busca cheques descontado		
		  CURSOR cr_crapcdb(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cdb.nrborder
				  FROM crapcdb cdb
				 WHERE cdb.cdcooper = pr_cdcooper
				   AND cdb.nrdconta = pr_nrdconta
				   AND UPPER(cdb.dsdocmc7) = UPPER(pr_dsdocmc7)
				   AND cdb.dtlibbdc IS NOT NULL
				   AND cdb.dtdevolu IS NULL;
			rw_crapcdb cr_crapcdb%ROWTYPE;
			
		  -- Busca cheques custodiados ainda não resgatados			
		  CURSOR cr_crapcst(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cst.vlcheque
				      ,cst.dtlibera
							,cst.insitchq
				  FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
				   AND cst.nrdconta = pr_nrdconta
				   AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7)
					 AND cst.dtdevolu IS NULL;
			rw_crapcst cr_crapcst%ROWTYPE;
			
			-- Verificar se cheque já foi resgatado
	    CURSOR cr_crapcst_resg(pr_cdcooper IN crapcop.cdcooper%TYPE
			                      ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cst.vlcheque
				      ,cst.dtlibera
							,cst.insitchq
				  FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
				   AND cst.nrdconta = pr_nrdconta
				   AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7)
					 AND cst.insitchq IN (1,5)
					 AND cst.dtdevolu IS NOT NULL;
			rw_crapcst_resg cr_crapcst_resg%ROWTYPE;
			
			-- Verificar se cheque foi resgatado na data de hoje
			CURSOR cr_crapcst_resg_hoje (pr_cdcooper IN crapcop.cdcooper%TYPE
			                            ,pr_dsdocmc7 IN VARCHAR2
																	,pr_dtmvtolt IN DATE) IS
			  SELECT cst.vlcheque
				      ,cst.dtlibera
							,cst.insitchq
				  FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
				   AND cst.nrdconta = pr_nrdconta
				   AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7)
					 AND cst.dtdevolu = pr_dtmvtolt;
			rw_crapcst_resg_hoje cr_crapcst_resg_hoje%ROWTYPE;
			
			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 
		
		BEGIN

		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
	
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
	
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
	
	    -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP

        -- Pega o cmc7 do cheque
        vr_dsdocmc7 := vr_ret_all_cheques(vr_auxcont);        
        -- Formatar o CMC-7
        vr_dsdocmc7_formatado := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
					
				  -- Verificar se cheque foi resgatado hoje
					OPEN cr_crapcst_resg_hoje(pr_cdcooper => vr_cdcooper
																	 ,pr_dsdocmc7 => vr_dsdocmc7_formatado
																	 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
					FETCH cr_crapcst_resg_hoje INTO rw_crapcst_resg_hoje;
					
					IF cr_crapcst_resg_hoje%FOUND THEN
						-- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 673);												
          		
          -- Fecha Cursor
          CLOSE cr_crapcst_resg_hoje;									
					ELSE				
          
          -- Fecha Cursor
          CLOSE cr_crapcst_resg_hoje; 
					
          -- Verifica se cheque foi custodiado e não foi resgatado			
          OPEN cr_crapcst(pr_cdcooper => vr_cdcooper
                         ,pr_dsdocmc7 => vr_dsdocmc7_formatado);
          FETCH cr_crapcst INTO rw_crapcst;
    				
          -- Se não encontrou
          IF cr_crapcst%NOTFOUND THEN
    				  				
						-- Verifica se cheque já foi resgatado
						OPEN cr_crapcst_resg(pr_cdcooper => vr_cdcooper
																,pr_dsdocmc7 => vr_dsdocmc7_formatado);
						FETCH cr_crapcst_resg INTO rw_crapcst_resg;
							
						-- Ja resgatado
						IF cr_crapcst_resg%FOUND THEN
								-- Gera crítica	
								vr_index_erro := vr_tab_resgate_erro.count + 1;  
								vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
								vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 672);
						ELSE
							-- Gera crítica	
							vr_index_erro := vr_tab_resgate_erro.count + 1;  
							vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
							vr_tab_resgate_erro(vr_index_erro).dscritic := 'Cheque não localizado';
						END IF;
              
              -- Fecha Cursor
						CLOSE cr_crapcst_resg;
            
				ELSE						
					-- Processado em dias anteriores
					IF rw_crapcst.insitchq = 2 AND 
					   rw_crapcst.dtlibera <= rw_crapdat.dtmvtoan THEN
					  -- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 670);
					-- Liber. inf a D-2										 
					ELSIF rw_crapcst.insitchq = 2 OR
                rw_crapcst.dtlibera <= rw_crapdat.dtmvtopr THEN
						-- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 677);						
					ELSIF rw_crapcst.insitchq <> 0 THEN
						-- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := 'Cheque já processado. Não permitido resgate.';						
						
					ELSE						
						-- Preenche informações do cheque
						vr_index_resg := vr_tab_resgate_inf.count + 1;  
						vr_tab_resgate_inf(vr_index_resg).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_inf(vr_index_resg).vlcheque := trim(to_char(rw_crapcst.vlcheque, '99g999g999g999g999g990d00'));
						vr_tab_resgate_inf(vr_index_resg).dtlibera := to_char(rw_crapcst.dtlibera, 'DD/MM/RRRR');
					END IF;
				END IF;
				-- Fecha cursor
				CLOSE cr_crapcst;
          
        END IF;  
          
      END LOOP;

	  -- Verifica se cheque foi custodiado e não foi resgatado			
      OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper
                     ,pr_dsdocmc7 => vr_dsdocmc7_formatado);
      FETCH cr_crapcdb INTO rw_crapcdb;
				
      -- Se não encontrou
      IF cr_crapcdb%FOUND THEN
        
          -- Gera crítica	
          vr_index_erro := vr_tab_resgate_erro.count + 1;  
          vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
          vr_tab_resgate_erro(vr_index_erro).dscritic := 'Cheque em Desconto';	
      END IF;    
      
      -- Fecha cursor
	  CLOSE cr_crapcdb;

      -- Cria xml de retorno
      vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>';

			vr_clob := vr_clob || '<Info_Cheques>';
			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_inf.count > 0 THEN
        vr_xml_inf_resgate := '';
        FOR vr_index_resg IN 1..vr_tab_resgate_inf.count LOOP
          -- Gera o XML com os erros
          vr_xml_inf_resgate := vr_xml_inf_resgate || 
                                  '<info'|| vr_index_resg || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_inf(vr_index_resg).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <vlcheque>' || vr_tab_resgate_inf(vr_index_resg).vlcheque || '</vlcheque>' ||
                                  '  <dtlibera>' || vr_tab_resgate_inf(vr_index_resg).dtlibera || '</dtlibera>' ||																	
                                  '</info'|| vr_index_resg || '>';
        END LOOP;				
				-- Adicionar informações dos cheques no xml de retorno
				vr_clob := vr_clob || vr_xml_inf_resgate;
      END IF;
      vr_clob := vr_clob || '</Info_Cheques>';
			
			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_erro.count > 0 THEN
        vr_xml_erro_resgate := '';
        FOR vr_index_erro IN 1..vr_tab_resgate_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_resgate := vr_xml_erro_resgate || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_resgate_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
				-- Adicionar críticas dos cheques no xml de retorno
				vr_clob := vr_clob || '<Validar_CMC7>' || vr_xml_erro_resgate || '</Validar_CMC7>';
      END IF;				  
		
		  -- Fechar tag root do xml de retorno
		  vr_clob := vr_clob || '</Root>';
			
			-- Criar XML
			pr_retxml := xmltype.createXML(vr_clob);
		
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_valida_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_valida_resgate;														 
	
	PROCEDURE pc_efetua_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_efetua_resgate
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 06/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para efetuar resgate dos cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- PlTable para armazenar informações de erro
      vr_tab_resgate_erro cust0001.typ_erro_resgate;
      vr_index_erro INTEGER;
      vr_xml_erro_resgate VARCHAR2(32726);
			
	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Resgatar cheques de custódia
      cust0001.pc_efetua_resgate_custodia(pr_cdcooper => vr_cdcooper
			                                   ,pr_nrdconta => pr_nrdconta
																				 ,pr_dscheque => pr_dscheque
																				 ,pr_cdoperad => vr_cdoperad
																				 ,pr_tab_erro_resg => vr_tab_resgate_erro
																				 ,pr_cdcritic => vr_cdcritic
																				 ,pr_dscritic => vr_dscritic);
			-- Se retornou alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_erro.count > 0 THEN
        vr_xml_erro_resgate := '';
        FOR vr_index_erro IN 1..vr_tab_resgate_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_resgate := vr_xml_erro_resgate || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_resgate_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Validar_CMC7>' || vr_xml_erro_resgate || '</Validar_CMC7></Root>');
      END IF;				  

      -- Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_efetua_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_efetua_resgate;

  -- Validar cheques informados para cancelamento de resgate
  PROCEDURE pc_valida_canc_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														      ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_valida_canc_resgate
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 12/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar os cheques para cancelamento de resgate

    Alteracoes: 
                                                     
  ............................................................................. */
		DECLARE
		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			

      -- Variáveis locais
      vr_ret_all_cheques gene0002.typ_split;
			vr_dsdocmc7 VARCHAR2(4000);
      vr_dsdocmc7_formatado VARCHAR2(40);
		  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
			-- Clob com informações do xml de retorno
			vr_clob CLOB;
							
			-- PlTable para armazenar informações de erro
      vr_tab_resgate_erro typ_erro_resgate;
      vr_index_erro INTEGER;
      vr_xml_erro_resgate VARCHAR2(32726);

      -- Criar tipo de PLTable para armazenar as informações do cheque
      TYPE typ_reg_inf_resgate IS
        RECORD(dsdocmc7 crapcst.dsdocmc7%TYPE
              ,dtlibera VARCHAR2(10)
							,vlcheque VARCHAR2(30));
      TYPE typ_inf_resgate IS
        TABLE OF typ_reg_inf_resgate
        INDEX BY BINARY_INTEGER;				

			-- PlTable para armazenar informações de erro
      vr_tab_resgate_inf typ_inf_resgate;
      vr_index_resg INTEGER;
      vr_xml_inf_resgate VARCHAR2(32726);
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
			
		  -- Busca cheques custodiados ainda não resgatados			
		  CURSOR cr_crapcst(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cst.vlcheque
				      ,cst.dtlibera
							,cst.insitchq
							,cst.dtdevolu
				  FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
				   AND cst.nrdconta = pr_nrdconta
				   AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7);
			rw_crapcst cr_crapcst%ROWTYPE;			
			
			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 
		
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
		
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
	
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
	
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
	
	    -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP

        -- Pega o cmc7 do cheque
        vr_dsdocmc7 := vr_ret_all_cheques(vr_auxcont);        
        -- Formatar o CMC-7
        vr_dsdocmc7_formatado := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
					
				-- Verifica se cheque foi custodiado e não foi resgatado			
        OPEN cr_crapcst(pr_cdcooper => vr_cdcooper
				               ,pr_dsdocmc7 => vr_dsdocmc7_formatado);
				FETCH cr_crapcst INTO rw_crapcst;
				
				-- Se não encontrou
				IF cr_crapcst%NOTFOUND THEN
					-- Gera crítica	
					vr_index_erro := vr_tab_resgate_erro.count + 1;  
					vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
					vr_tab_resgate_erro(vr_index_erro).dscritic := 'Cheque não localizado';
				ELSE						
          -- Cheques com situacao 5 NAO podem ser desfeita a devolucao
					IF rw_crapcst.insitchq <> 1 THEN
						-- Não processado
						IF rw_crapcst.insitchq = 0 THEN
							-- Gera crítica	
							vr_index_erro := vr_tab_resgate_erro.count + 1;  
							vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
							vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 671);
						ELSE
							-- Gera crítica	
							vr_index_erro := vr_tab_resgate_erro.count + 1;  
							vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
							vr_tab_resgate_erro(vr_index_erro).dscritic := gene0001.fn_busca_critica(pr_cdcritic => 670);
						END IF;
					-- Só é permitido cancelar o resgate de cheques resgatados no dia
					ELSIF rw_crapcst.dtdevolu < rw_crapdat.dtmvtolt THEN
						-- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := 'Permitido apenas cancelamento de resgates efetuados no dia.';						
					ELSE
						-- Preenche informações do cheque
						vr_index_resg := vr_tab_resgate_inf.count + 1;  
						vr_tab_resgate_inf(vr_index_resg).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_inf(vr_index_resg).vlcheque := trim(to_char(rw_crapcst.vlcheque, '99g999g999g999g999g990d00'));
						vr_tab_resgate_inf(vr_index_resg).dtlibera := to_char(rw_crapcst.dtlibera, 'DD/MM/RRRR');
					END IF;
				END IF;
				-- Fecha cursor
				CLOSE cr_crapcst;
      END LOOP;

      -- Cria xml de retorno
      vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>';

			vr_clob := vr_clob || '<Info_Cheques>';
			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_inf.count > 0 THEN
        vr_xml_inf_resgate := '';
        FOR vr_index_resg IN 1..vr_tab_resgate_inf.count LOOP
          -- Gera o XML com os erros
          vr_xml_inf_resgate := vr_xml_inf_resgate || 
                                  '<info'|| vr_index_resg || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_inf(vr_index_resg).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <vlcheque>' || vr_tab_resgate_inf(vr_index_resg).vlcheque || '</vlcheque>' ||
                                  '  <dtlibera>' || vr_tab_resgate_inf(vr_index_resg).dtlibera || '</dtlibera>' ||																	
                                  '</info'|| vr_index_resg || '>';
        END LOOP;				
				-- Adicionar informações dos cheques no xml de retorno
				vr_clob := vr_clob || vr_xml_inf_resgate;
      END IF;
      vr_clob := vr_clob || '</Info_Cheques>';
			
			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_erro.count > 0 THEN
        vr_xml_erro_resgate := '';
        FOR vr_index_erro IN 1..vr_tab_resgate_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_resgate := vr_xml_erro_resgate || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_resgate_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
				-- Adicionar críticas dos cheques no xml de retorno
				vr_clob := vr_clob || '<Validar_CMC7>' || vr_xml_erro_resgate || '</Validar_CMC7>';
      END IF;				  
		
		  -- Fechar tag root do xml de retorno
		  vr_clob := vr_clob || '</Root>';
			
			-- Criar XML
			pr_retxml := xmltype.createXML(vr_clob);
		
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_valida_canc_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_valida_canc_resgate;

	PROCEDURE pc_efetua_canc_resgate(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														      ,pr_dscheque IN VARCHAR2               --> Lista de CMC7s
														      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_efetua_canc_resgate
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 12/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para efetuar cancelamento do resgate dos cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
      -- PLTABLE de erro generica
      vr_tab_erro GENE0001.typ_tab_erro;
			
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis locais
      vr_ret_all_cheques gene0002.typ_split;
			vr_dsdocmc7 VARCHAR2(4000);
      vr_dsdocmc7_formatado VARCHAR2(40);
			vr_nrdocmto crapcst.nrdocmto%TYPE; 
			vr_cdbattar VARCHAR2(100);
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
    

			-- PlTable para armazenar informações de erro
      vr_tab_resgate_erro typ_erro_resgate;
      vr_index_erro INTEGER;
      vr_xml_erro_resgate VARCHAR2(32726);
      
			-- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
			
		  -- Busca cheques custodiados ainda não resgatados			
		  CURSOR cr_crapcst(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cst.vlcheque
				      ,cst.dtlibera
							,cst.insitchq
							,cst.nrddigc3
							,cst.nrcheque
							,cst.nrctachq
							,cst.cdbccxlt
							,cst.cdagenci
							,cst.nrdolote
							,cst.dtmvtolt
							,cst.rowid
				  FROM crapcst cst
				 WHERE cst.cdcooper = pr_cdcooper
				   AND cst.nrdconta = pr_nrdconta
				   AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7);
			rw_crapcst cr_crapcst%ROWTYPE;

			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 


	  BEGIN			
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	

		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      -- Carrega dados da tarifa caso necessite estorno
			-- Codigo da tarifa
			IF rw_crapass.inpessoa = 1 THEN
				vr_cdbattar := 'RESGCUSTPF';
			ELSE
				vr_cdbattar := 'RESGCUSTPJ';
			END IF;

		  -- Busca o valor da tarifa
		  TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => vr_cdcooper   -- Codigo Cooperativa
																					  ,pr_cdbattar  => vr_cdbattar   -- Codigo Tarifa
																					  ,pr_vllanmto  => 0             -- Valor Lancamento
																					  ,pr_cdprogra  => 'CUST0001'    -- Codigo Programa
																					  ,pr_cdhistor  => vr_cdhistor   -- Codigo Historico
																					  ,pr_cdhisest  => vr_cdhisest   -- Historico Estorno
																					  ,pr_vltarifa  => vr_vltarifa   -- Valor tarifa
																					  ,pr_dtdivulg  => vr_dtdivulg   -- Data Divulgacao
																					  ,pr_dtvigenc  => vr_dtvigenc   -- Data Vigencia
																					  ,pr_cdfvlcop  => vr_cdfvlcop   -- Codigo faixa valor cooperativa
																					  ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
																					  ,pr_dscritic  => vr_dscritic   -- Descricao Critica
																					  ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
		  -- Se ocorreu erro
		  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
			  -- Se possui erro no vetor
			  IF vr_tab_erro.Count > 0 THEN
				  vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
				  vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
			  ELSE
				  vr_cdcritic := 0;
				  vr_dscritic := 'Nao foi possivel carregar a tarifa.';
			  END IF;
			  -- Levantar Excecao
			  RAISE vr_exc_erro;
		  END IF;
         
	    -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP

        -- Pega o cmc7 do cheque
        vr_dsdocmc7 := vr_ret_all_cheques(vr_auxcont);        
        -- Formatar o CMC-7
        vr_dsdocmc7_formatado := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
					
				-- Verifica se cheque foi custodiado e não foi resgatado			
        OPEN cr_crapcst(pr_cdcooper => vr_cdcooper
				               ,pr_dsdocmc7 => vr_dsdocmc7_formatado);
				FETCH cr_crapcst INTO rw_crapcst;

        -- Se não encontrou cheque
        IF cr_crapcst%NOTFOUND THEN
						-- Gera crítica	
						vr_index_erro := vr_tab_resgate_erro.count + 1;  
						vr_tab_resgate_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
						vr_tab_resgate_erro(vr_index_erro).dscritic := 'Erro ao efetuar resgate. Cheque não localizado.';
						-- Fecha cursor
						CLOSE cr_crapcst;
						--Próximo registro
						CONTINUE;
        ELSE
					-- Fecha cursor
					CLOSE cr_crapcst;
          -- Monta nr. do doc
					vr_nrdocmto := to_number(to_char(rw_crapcst.nrcheque, '000000') +
																	 to_char(rw_crapcst.nrddigc3, '0'));
								
						
					-- Atualiza lançamento automatico
					UPDATE craplau lau
					   SET lau.dtdebito = NULL
						    ,lau.insitlau = 1
					 WHERE lau.cdcooper = vr_cdcooper
					   AND lau.dtmvtolt = rw_crapcst.dtmvtolt
						 AND lau.cdagenci = rw_crapcst.cdagenci
						 AND lau.cdbccxlt = rw_crapcst.cdbccxlt 
						 AND lau.nrdolote = rw_crapcst.nrdolote
						 AND lau.nrdctabb = rw_crapcst.nrctachq
						 AND lau.nrdocmto = vr_nrdocmto;
							
					-- Atualiza situação da custódia
					UPDATE crapcst cst
					   SET cst.dtdevolu = NULL
						    ,cst.cdopedev = ''
								,cst.insitchq = 0
					 WHERE cst.rowid = rw_crapcst.rowid;

					 -- Atualiza lançamento de tarifa para baixado
					 UPDATE craplat lat
					    SET lat.insitlat = 3
								 ,lat.cdopeest = vr_cdoperad
								 ,lat.dtdestor = rw_crapdat.dtmvtolt
								 ,lat.cdmotest = 99999
								 ,lat.dsjusest = 'Cancelamento Resgate de Cheque.'
						WHERE lat.cdcooper = vr_cdcooper
							AND lat.nrdconta = pr_nrdconta
						  AND lat.nrdocmto = vr_nrdocmto
							AND lat.insitlat = 1
							AND rownum = 1;

				END IF;
			END LOOP;

			-- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_resgate_erro.count > 0 THEN
        vr_xml_erro_resgate := '';
        FOR vr_index_erro IN 1..vr_tab_resgate_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_resgate := vr_xml_erro_resgate || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_resgate_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_resgate_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Validar_CMC7>' || vr_xml_erro_resgate || '</Validar_CMC7></Root>');
      END IF;				  

      -- Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_efetua_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_efetua_canc_resgate;
	
	PROCEDURE pc_busca_remessas(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
														 ,pr_dtinicst IN VARCHAR2           	  --> Data inicio
														 ,pr_dtfimcst IN VARCHAR2               --> Data final
														 ,pr_cdagenci IN PLS_INTEGER            --> PA da da Custodia
														 ,pr_insithcc IN NUMBER                 --> Lista de CMC7s														 
														 ,pr_nriniseq IN NUMBER                 --> Número inicial da sequência
														 ,pr_nrregist IN NUMBER                 --> Número de registros a retornar
														 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_busca_remessas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 14/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar remessas de cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
	
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
		
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis auxiliares
      vr_dtinicst DATE := to_date(pr_dtinicst, 'dd/mm/rrrr');
      vr_dtfimcst DATE := to_date(pr_dtfimcst, 'dd/mm/rrrr');
			vr_qtregist NUMBER;
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
		
		  vr_clob CLOB;
		
		  -- Busca Header de custódia de cheque
		  CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_dtinicst IN craphcc.dtmvtolt%TYPE
											 ,pr_dtfimcst IN craphcc.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE
											 ,pr_insithcc IN craphcc.insithcc%TYPE) IS
			  SELECT * FROM (SELECT hcc.cdcooper
				      ,hcc.nrdconta
							,hcc.nrconven
							,hcc.nrremret
							,to_char(hcc.dtmvtolt,'dd/mm/rrrr') dtmvtolt
							,hcc.nmarquiv
							,decode(hcc.insithcc,1,'Pendente',2,'Processado') insithcc
							,to_char(hcc.dtcustod,'dd/mm/rrrr') dtcustod
							,hcc.intipmvt
							,hcc.idorigem
							,rownum rnum
                FROM craphcc hcc, crapass ass
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND(hcc.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
					 AND hcc.dtmvtolt BETWEEN pr_dtinicst AND pr_dtfimcst
					 AND(hcc.insithcc = pr_insithcc OR pr_insithcc = 0)
					 AND hcc.intipmvt IN (1,3)
           AND rownum <= (pr_nriniseq + pr_nrregist)
                 AND ass.cdcooper = hcc.cdcooper
                 AND ass.nrdconta = hcc.nrdconta
                 AND (ass.cdagenci = pr_cdagenci OR nvl(pr_cdagenci, 0) = 0)
           ORDER BY HCC.DTMVTOLT DESC /*, HCC.NRREMRET */)
					 WHERE rnum >= pr_nriniseq;

      -- Buscar quantidade total de registros					 
		  CURSOR cr_craphcc_tot(pr_cdcooper IN craphcc.cdcooper%TYPE
													 ,pr_nrdconta IN craphcc.nrdconta%TYPE
													 ,pr_dtinicst IN craphcc.dtmvtolt%TYPE
													 ,pr_dtfimcst IN craphcc.dtmvtolt%TYPE
                           ,pr_cdagenci IN crapass.cdagenci%TYPE
													 ,pr_insithcc IN craphcc.insithcc%TYPE) IS
			  SELECT COUNT(1)
					FROM craphcc hcc, crapass ass
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND(hcc.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
					 AND hcc.dtmvtolt BETWEEN pr_dtinicst AND pr_dtfimcst
					 AND(hcc.insithcc = pr_insithcc OR pr_insithcc = 0)
					 AND hcc.intipmvt IN (1,3)
           AND ass.cdcooper = hcc.cdcooper
           AND ass.nrdconta = hcc.nrdconta
           AND (ass.cdagenci = pr_cdagenci OR nvl(pr_cdagenci, 0) = 0);
			
      -- Busca informações gerais dos detalhes de cheque da remessa
      CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapdcc.nrdconta%TYPE
											 ,pr_nrconven IN crapdcc.nrconven%TYPE
											 ,pr_nrremret IN crapdcc.nrremret%TYPE
											 ,pr_intipmvt IN crapdcc.intipmvt%TYPE) IS
        SELECT to_char(SUM(dcc.vlcheque), 'fm999g999g999g999g990d00') vltotchq
				      ,SUM(dcc.inconcil) qtconcil
							,COUNT(1) qtcheque
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt;
      rw_crapdcc cr_crapdcc%ROWTYPE;		
			
			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 
			
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	

	    -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
	    
			-- Data de inicio deve ser menor que data final				
		  IF vr_dtinicst > vr_dtfimcst THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Data de início da remessa deve ser menor que data final.';
				RAISE vr_exc_erro;
			END IF;
			
			-- Data de inicio deve ser menor que data final				
		  IF (vr_dtfimcst - vr_dtinicst) > 30 THEN
				vr_cdcritic := 0;
				vr_dscritic := 'O período de pesquisa não pode ultrapassar 30 dias';
				RAISE vr_exc_erro;
			END IF;
			
      -- Cria xml de retorno
      vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>';
			
		  -- Busca Headers de custódia de cheque
      FOR rw_craphcc IN cr_craphcc(pr_cdcooper => vr_cdcooper
				                          ,pr_nrdconta => pr_nrdconta
																	,pr_dtinicst => vr_dtinicst
																	,pr_dtfimcst => vr_dtfimcst
                                  ,pr_cdagenci => pr_cdagenci
																	,pr_insithcc => pr_insithcc) LOOP
																	
        -- Busca informações gerais dos detalhes de cheque da remessa			
			  OPEN cr_crapdcc(pr_cdcooper => rw_craphcc.cdcooper
				               ,pr_nrdconta => rw_craphcc.nrdconta
											 ,pr_nrconven => rw_craphcc.nrconven
											 ,pr_nrremret => rw_craphcc.nrremret
											 ,pr_intipmvt => rw_craphcc.intipmvt);  	
			  FETCH cr_crapdcc INTO rw_crapdcc;
				CLOSE cr_crapdcc;
				
	      -- Verifica se a cooperativa esta cadastrada
				OPEN cr_crapass( pr_cdcooper => vr_cdcooper
											 , pr_nrdconta => rw_craphcc.nrdconta);
				FETCH cr_crapass INTO rw_crapass;
				CLOSE cr_crapass;
				vr_clob := vr_clob || 
				           '<inf>'
 									 || '<nrdconta>'|| trim(gene0002.fn_mask_conta(rw_craphcc.nrdconta)) || '</nrdconta>'
 									 || '<dtmvtolt>'|| rw_craphcc.dtmvtolt || '</dtmvtolt>'
 									 || '<nrremret>'|| rw_craphcc.nrremret || '</nrremret>'
 									 || '<vltotchq>'|| trim(rw_crapdcc.vltotchq) || '</vltotchq>'									 
 									 || '<qtcheque>'|| rw_crapdcc.qtcheque || '</qtcheque>'
 									 || '<qtconcil>'|| rw_crapdcc.qtconcil || '</qtconcil>'									 
 									 || '<insithcc>'|| rw_craphcc.insithcc || '</insithcc>'
 									 || '<dtcustod>'|| rw_craphcc.dtcustod || '</dtcustod>'
 									 || '<nmarquiv>'|| rw_craphcc.nmarquiv || '</nmarquiv>' 
									 || '<nrconven>'|| rw_craphcc.nrconven || '</nrconven>'
									 || '<intipmvt>'|| rw_craphcc.intipmvt || '</intipmvt>'
									 || '<nmprimtl>'|| rw_crapass.nmprimtl || '</nmprimtl>'
									 ||	'<dsorigem>'|| gene0001.vr_vet_des_origens(rw_craphcc.idorigem) ||'</dsorigem>' ||
									 '</inf>';
			END LOOP;			
			-- Fechar tag de dados do xml de retorno
		  vr_clob := vr_clob || '</Dados>';
			
			-- Busca quantidade total de registros
			OPEN cr_craphcc_tot(pr_cdcooper => vr_cdcooper
												 ,pr_nrdconta => pr_nrdconta
												 ,pr_dtinicst => vr_dtinicst
												 ,pr_dtfimcst => vr_dtfimcst
                         ,pr_cdagenci => pr_cdagenci
												 ,pr_insithcc => pr_insithcc);
      FETCH cr_craphcc_tot INTO vr_qtregist;
			
			vr_clob := vr_clob || '<Qtregist>' || vr_qtregist || '</Qtregist>';
			
	    -- Fechar tag root do xml de retorno
		  vr_clob := vr_clob || '</Root>';
			
			-- Criar XML
			pr_retxml := xmltype.createXML(vr_clob);
			
		EXCEPTION
      WHEN vr_exc_erro THEN			
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_busca_remessas: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;

  END pc_busca_remessas;
	
	PROCEDURE pc_busca_cheques_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																	  ,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																	  ,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																	  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																	  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																	  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																	  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																	  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																	  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_busca_cheques_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 19/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cheques da remessa de cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
	
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
		
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
		
		  -- Controle de dados
		  vr_clob CLOB;
		  vr_clob_temp CLOB;			
	    vr_dstexto VARCHAR2(32767);
			
		  -- Busca Detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT to_char(dcc.vlcheque, 'fm999g999g999g999g990d00') vlcheque
							,translate(dcc.dsdocmc7,
                         '[0-9]<>:',
                         '[0-9]') dsdocmc7
							,dcc.inconcil
              ,(SELECT dcc.cdocorre || ' - ' || occ.dsocorre
							    FROM crapocc occ
								 WHERE occ.cdocorre = dcc.cdocorre
								   AND occ.intipmvt = 2
								   AND occ.cdtipmvt = 21) cdocorre
					FROM crapdcc dcc					   
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt;

		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
		
	    -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
	    
      -- Criar documento XML
      dbms_lob.createtemporary(vr_clob, TRUE); 
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
      -- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml => vr_clob
			                       ,pr_texto_completo => vr_clob_temp
														 ,pr_texto_novo => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
			
		  -- Busca Detalhes da custódia de cheque
      FOR rw_crapdcc IN cr_crapdcc(pr_cdcooper => vr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_nrconven => pr_nrconven
																	,pr_nrremret => pr_nrremret
																	,pr_intipmvt => pr_intipmvt) LOOP
																	
				vr_dstexto :='<inf>'
										 || '<a>'|| rw_crapdcc.dsdocmc7 || '</a>' --Dsdocmc7
										 || '<b>'|| rw_crapdcc.vlcheque || '</b>' --Vlcheque
										 || '<c>'|| rw_crapdcc.inconcil || '</c>' --Inconcil
										 || '<d>'|| rw_crapdcc.cdocorre || '</d>' --Cdocorre
										 ||'</inf>';

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_clob_temp 
                                 ,pr_texto_novo     => vr_dstexto);

			END LOOP;			
			
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => vr_clob
														 ,pr_texto_completo => vr_clob_temp
														 ,pr_texto_novo     => '</Dados></Root>' 
														 ,pr_fecha_xml      => TRUE);
			
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
			
		EXCEPTION
      WHEN vr_exc_erro THEN			
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_busca_cheques_remessa: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;

  END pc_busca_cheques_remessa;
	
	PROCEDURE pc_busca_detalhe_cheque(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																	 ,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																	 ,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																	 ,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																	 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																	 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																	 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																	 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																	 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																	 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																	 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_busca_detalhe_cheque
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 27/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cheques da remessa de cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
	
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
		
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
		
		  -- Controle de dados
		  vr_clob CLOB;
		  vr_clob_temp CLOB;			
	    vr_dstexto VARCHAR2(32767);
			
		  -- Busca Detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE
											 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
			  SELECT gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => dcc.nrinsemi
				                                ,pr_inpessoa => dcc.cdtipemi) nrinsemi
							,nvl((SELECT cec.nmcheque 
									FROM crapcec cec 
								 WHERE cec.cdcooper = dcc.cdcooper
									 AND cec.cdcmpchq = dcc.cdcmpchq
									 AND cec.cdbanchq = dcc.cdbanchq
									 AND cec.cdagechq = dcc.cdagechq
									 AND cec.nrctachq = dcc.nrctachq
									 AND cec.nrdconta = 0
									 AND rownum = 1), 'NÃO CADASTRADO') nmcheque
							,dcc.cdagenci
							,dcc.cdbccxlt
							,dcc.nrdolote
							,to_char(dcc.dtdcaptu, 'DD/MM/RRRR') dtdcaptu
							,to_char(dcc.dtlibera, 'DD/MM/RRRR') dtlibera
							,dcc.cdocorre
							,(SELECT ' - ' || occ.dsocorre
							    FROM crapocc occ
								 WHERE occ.cdocorre = dcc.cdocorre
								   AND occ.intipmvt = 2
								   AND occ.cdtipmvt = 21) dsocorre
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.dsdocmc7 = gene0002.fn_mask(pr_dsdocmc7,'<99999999<9999999999>999999999999:');
       rw_crapdcc cr_crapdcc%ROWTYPE;
			 
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
		
	    -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
	    
      -- Criar documento XML
      dbms_lob.createtemporary(vr_clob, TRUE); 
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
      -- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml => vr_clob
			                       ,pr_texto_completo => vr_clob_temp
														 ,pr_texto_novo => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>');
			
		  -- Busca Detalhes da custódia de cheque
      OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt
										 ,pr_dsdocmc7 => pr_dsdocmc7);
			FETCH cr_crapdcc INTO rw_crapdcc;
																	
			vr_dstexto :='<Dados>' ||
											'<nrinsemi>' || rw_crapdcc.nrinsemi || '</nrinsemi>' ||
											'<nmcheque><![CDATA[' || rw_crapdcc.nmcheque || ']]></nmcheque>' ||
											'<cdagenci>' || rw_crapdcc.cdagenci || '</cdagenci>' ||
											'<cdbccxlt>' || rw_crapdcc.cdbccxlt || '</cdbccxlt>' ||
											'<nrdolote>' || rw_crapdcc.nrdolote || '</nrdolote>' ||
											'<dtdcaptu>' || rw_crapdcc.dtdcaptu || '</dtdcaptu>' ||
											'<dtlibera>' || rw_crapdcc.dtlibera || '</dtlibera>' ||
								      '<dsocorre>' || rw_crapdcc.cdocorre || rw_crapdcc.dsocorre || '</dsocorre>' ||											
									 '</Dados>';

			-- Escrever no XML
			gene0002.pc_escreve_xml(pr_xml            => vr_clob
														 ,pr_texto_completo => vr_clob_temp 
														 ,pr_texto_novo     => vr_dstexto);
			
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => vr_clob
														 ,pr_texto_completo => vr_clob_temp
														 ,pr_texto_novo     => '</Root>' 
														 ,pr_fecha_xml      => TRUE);
			
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
			
		EXCEPTION
      WHEN vr_exc_erro THEN			
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_busca_detalhe_cheque: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_busca_detalhe_cheque;
	
	PROCEDURE pc_altera_detalhe_cheque(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																		,pr_dtemissa IN VARCHAR2               --> Data de emissão
																		,pr_dtlibera IN VARCHAR2               --> Data boa
																		,pr_vlcheque IN crapdcc.vlcheque%TYPE  --> Valor do cheque
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_altera_detalhe_cheque
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 28/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar cheques da remessa de cheques em custódia

    Alteracoes: 29/08/2017 - Ajuste para não deixar alterar o cheque quando ele estiver
                             em um bordero.(Lombardi)
                                                     
  ............................................................................. */
  	DECLARE
	
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
		
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis auxiliares
			vr_dtemissa DATE := to_date(pr_dtemissa, 'DD/MM/RRRR');
			vr_dtlibera DATE := to_date(pr_dtlibera, 'DD/MM/RRRR');			
      vr_dtminimo DATE;
      vr_qtddmini NUMBER;
      -- Identifica o ultimo dia Util do ANO
      vr_dtultdia DATE;
      
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
					
		  -- Busca detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE
											 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
			  SELECT dcc.rowid
              ,dcc.dtdcaptu
              ,dcc.dtlibera
              ,dcc.vlcheque
              ,dcc.cdcmpchq
              ,dcc.cdbanchq
              ,dcc.cdagechq
              ,dcc.nrctachq
              ,dcc.nrcheque
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.dsdocmc7 = gene0002.fn_mask(pr_dsdocmc7,'<99999999<9999999999>999999999999:');
       rw_crapdcc cr_crapdcc%ROWTYPE;
			 
      CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                        ,pr_nrdconta IN craphcc.nrdconta%TYPE
                        ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcdb.cdagechq%TYPE
                        ,pr_nrctachq IN crapcdb.nrctachq%TYPE
                        ,pr_nrcheque IN crapcdb.nrcheque%TYPE
                        ,pr_dtlibera IN crapcdb.dtlibera%TYPE) IS
        SELECT cdb.nrborder
          FROM crapcdb cdb
         WHERE cdb.cdcooper = pr_cdcooper
           AND cdb.nrdconta = pr_nrdconta
           AND cdb.cdcmpchq = pr_cdcmpchq
           AND cdb.cdbanchq = pr_cdbanchq 
           AND cdb.cdagechq = pr_cdagechq 
           AND cdb.nrctachq = pr_nrctachq 
           AND cdb.nrcheque = pr_nrcheque 
           AND cdb.dtlibera = pr_dtlibera
           AND cdb.dtdevolu IS NULL;
      rw_crapcdb cr_crapcdb%ROWTYPE;
			 
      --Selecionar feriados
      CURSOR cr_crapfer (pr_cdcooper IN crapfer.cdcooper%TYPE
                        ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT crapfer.dtferiad
        FROM crapfer
        WHERE crapfer.cdcooper = pr_cdcooper
        AND   crapfer.dtferiad = pr_dtferiad;
      rw_crapfer cr_crapfer%ROWTYPE;

			 
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
		
	    -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
			
			-- Data de emissão não pode ser maior que a data atual
			IF vr_dtemissa > rw_crapdat.dtmvtolt THEN
				-- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Data de emissão inválida.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
			END IF;
	    			
      /* Tipo de movimento diferente de ARQUIVO, devemos validamos 2 dias úteis para custódia */
			-- Verificar se o cheque está no prazo mínimo de custódia
			vr_dtminimo := rw_crapdat.dtmvtolt;
			vr_qtddmini := 0;

			LOOP
				vr_dtminimo := vr_dtminimo + 1;

				-- Verifica se é Sabado ou Domingo
				IF to_char(vr_dtminimo,'D') = '1' OR to_char(vr_dtminimo,'D') = '7' THEN
					CONTINUE;
				END IF;

				-- Abre Cursor
				OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
											 ,pr_dtferiad => vr_dtminimo);
				--Posicionar no proximo registro
				FETCH cr_crapfer INTO rw_crapfer;

				--Se nao encontrar
				IF cr_crapfer%FOUND THEN
					-- Fecha Cursor
					CLOSE cr_crapfer;
					CONTINUE;
				ELSE
					-- Fecha Cursor
					CLOSE cr_crapfer;
				END IF;

				vr_qtddmini := vr_qtddmini + 1;

				EXIT WHEN vr_qtddmini = 2;
			END LOOP;

		  -- Busca Detalhes da custódia de cheque
      OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt
										 ,pr_dsdocmc7 => pr_dsdocmc7);
			FETCH cr_crapdcc INTO rw_crapdcc;

      -- Se não encontrou
      IF cr_crapdcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapdcc;
			  -- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Registro de detalhes do cheque não encontrado.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_crapdcc;
      
      IF rw_crapdcc.dtdcaptu <> vr_dtemissa OR
         rw_crapdcc.dtlibera <> vr_dtlibera OR
         rw_crapdcc.vlcheque <> pr_vlcheque THEN
        OPEN cr_crapcdb (vr_cdcooper
                        ,pr_nrdconta
                        ,rw_crapdcc.cdcmpchq
                        ,rw_crapdcc.cdbanchq
                        ,rw_crapdcc.cdagechq
                        ,rw_crapdcc.nrctachq
                        ,rw_crapdcc.nrcheque
                        ,rw_crapdcc.dtlibera);
        FETCH cr_crapcdb INTO rw_crapcdb;
        IF cr_crapcdb%FOUND THEN
          -- Data para Deposito invalida
          vr_cdcritic := 0;
          vr_dscritic := 'Cheque encontra-se no borderô ' || rw_crapcdb.nrborder || '. Não é possível realizar a alteração.';
          -- Executa RAISE para sair das validações
          RAISE vr_exc_erro;
        END IF;
      END IF;      
      
			-- Se o cheque não estiver no prazo mínimo ou no
			-- prazo máximo (1095 dias)
			IF   vr_dtlibera <= vr_dtminimo OR
					 vr_dtlibera > (rw_crapdat.dtmvtolt + 1095)   THEN
				-- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Data para Depósito inválida';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
			END IF;
			
      -- Buscar o ultimo dia do ANO
      vr_dtultdia:= add_months(TRUNC(vr_dtlibera,'RRRR'),12)-1;
      -- Atualizar para o ultimo dia util do ANO, considerando 31/12
      vr_dtultdia:= gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                               ,pr_dtmvtolt => vr_dtultdia
                                               ,pr_tipo => 'A' -- Dia Anterior
                                               ,pr_feriado => TRUE -- Validar Feriados
                                               ,pr_excultdia => TRUE); -- Considerar o dia 31/12

      -- Nao permitir que as custodias de cheques tenham data de liberacao no ultimo dia util do ano
      IF vr_dtlibera = vr_dtultdia THEN
				-- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Data para Depósito inválida';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
			END IF;																				
			
			-- Valor do cheque deve ser superior a 0
			IF pr_vlcheque <= 0 THEN
			  -- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Valor do cheque inválido.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
			END IF;

      -- Atualizar informações de detahles do cheque
			UPDATE crapdcc dcc
			   SET dcc.dtdcaptu = vr_dtemissa
				    ,dcc.dtlibera = vr_dtlibera
						,dcc.vlcheque = pr_vlcheque
						,dcc.inconcil = 0
						,dcc.cdocorre = NULL
			 WHERE dcc.rowid = rw_crapdcc.rowid;
			
			--Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN			
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_altera_detalhe_cheque: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_altera_detalhe_cheque;

  -- Excluir cheque da remessa	
	PROCEDURE pc_exclui_cheque_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE  --> CMC7
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_exclui_cheque_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 29/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para excluir cheques da remessa de cheques em custódia

    Alteracoes: 
                                                     
  ............................................................................. */
  	DECLARE
	
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
		
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
			
			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT 1
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt
					 AND hcc.insithcc = 1;
      rw_craphcc cr_craphcc%ROWTYPE;
								
		  -- Busca detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE
											 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
			  SELECT dcc.rowid
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.dsdocmc7 = gene0002.fn_mask(pr_dsdocmc7,'<99999999<9999999999>999999999999:');
       rw_crapdcc cr_crapdcc%ROWTYPE;			
			 
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
		
	    -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Buscar remessa de cheque para verificar se ainda não foi processada
      OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_craphcc INTO rw_craphcc;

      -- Se não encontrou
      IF cr_craphcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphcc;
			  -- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Remessa não encontrada ou já processada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_craphcc;
			
		  -- Busca Detalhes da custódia de cheque
      OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt
										 ,pr_dsdocmc7 => pr_dsdocmc7);
			FETCH cr_crapdcc INTO rw_crapdcc;

      -- Se não encontrou
      IF cr_crapdcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapdcc;
			  -- Data para Deposito invalida
        vr_cdcritic := 0;
				vr_dscritic := 'Registro do cheque não encontrado.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_crapdcc;

      -- Atualizar informações de detahles do cheque
			DELETE FROM crapdcc dcc
			 WHERE dcc.rowid = rw_crapdcc.rowid;
			
			--Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN			
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_altera_detalhe_cheque: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;
	END pc_exclui_cheque_remessa;
	
	-- Conciliar/desconciliar cheques
	PROCEDURE pc_conciliar_cheques(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																,pr_dscheque IN crapdcc.dsdocmc7%TYPE  --> Informações do cheque
																,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_conciliar_cheques
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 30/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para conciliar/desconciliar cheques modificados na tela

    Alteracoes: 
                                                     
  ............................................................................. */
		DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis locais
      vr_ret_all_cheques gene0002.typ_split;
      vr_ret_des_cheques gene0002.typ_split;
			
		  -- Variáveis auxiliares
			vr_qtocorre NUMBER := 0;
			vr_dsdocmc7 VARCHAR2(4000);
			vr_inconcil NUMBER;
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
			

			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT 1
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt
					 AND hcc.insithcc = 1;
      rw_craphcc cr_craphcc%ROWTYPE;
								
		  -- Busca detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE
											 ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
			  SELECT dcc.dsdocmc7
				      ,dcc.nrseqarq
							,dcc.intipmvt
							,dcc.rowid
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.dsdocmc7 = gene0002.fn_mask(pr_dsdocmc7,'<99999999<9999999999>999999999999:');
       rw_crapdcc cr_crapdcc%ROWTYPE;

	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

	    -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');

      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP

        -- Pega informações do cheque (CMC7 e inconcil)
        vr_ret_des_cheques := gene0002.fn_quebra_string( vr_ret_all_cheques(vr_auxcont), '#');     
				
				-- Pega CMC7
				vr_dsdocmc7 := vr_ret_des_cheques(1);
				-- Pega inconcil
				vr_inconcil := to_number(vr_ret_des_cheques(2));

				-- Buscar remessa de cheque para verificar se ainda não foi processada
				OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
											 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrconven => pr_nrconven
											 ,pr_nrremret => pr_nrremret
											 ,pr_intipmvt => pr_intipmvt);
				FETCH cr_craphcc INTO rw_craphcc;

				-- Se não encontrou
				IF cr_craphcc%NOTFOUND THEN
					-- Fecha cursor
					CLOSE cr_craphcc;
					-- Data para Deposito invalida
					vr_cdcritic := 0;
					vr_dscritic := 'Remessa não encontrada ou já processada.';
					-- Executa RAISE para sair das validações
					RAISE vr_exc_erro;				
				END IF;
				-- Fecha cursor
				CLOSE cr_craphcc;
				
				-- Busca Detalhes da custódia de cheque
				OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
											 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrconven => pr_nrconven
											 ,pr_nrremret => pr_nrremret
											 ,pr_intipmvt => pr_intipmvt
											 ,pr_dsdocmc7 => vr_dsdocmc7);
				FETCH cr_crapdcc INTO rw_crapdcc;

				-- Se não encontrou
				IF cr_crapdcc%NOTFOUND THEN
					-- Fecha cursor
					CLOSE cr_crapdcc;
					-- Data para Deposito invalida
					vr_cdcritic := 0;
					vr_dscritic := 'Registro do cheque não encontrado.';
					-- Executa RAISE para sair das validações
					RAISE vr_exc_erro;				
				END IF;
				-- Fecha cursor
				CLOSE cr_crapdcc;

				-- Conciliar cheque da remessa
			  cust0001.pc_conciliar_cheque_arquivo(pr_cdcooper => vr_cdcooper
				                                    ,pr_nrdconta => pr_nrdconta
																						,pr_nrremret => pr_nrremret
																						,pr_dsdocmc7 => rw_crapdcc.dsdocmc7
																						,pr_nrseqarq => rw_crapdcc.nrseqarq
																						,pr_intipmvt => rw_crapdcc.intipmvt
																						,pr_inconcil => vr_inconcil
																						,pr_dtmvtolt => rw_crapdat.dtmvtolt
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
				
				-- Se ocorreu erro
				IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
					-- Levantar Excecao
					vr_qtocorre := vr_qtocorre + 1;
				END IF;													
				
			END LOOP;

			-- Se houve algum cheque com ocorrência
			IF vr_qtocorre > 0 THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe(m) ' || vr_qtocorre || ' cheque(s) com ocorrência(s)';
        -- Efetuar commit
			  COMMIT;

        -- Levanta exceção
				RAISE vr_exc_erro;
			END IF;

      -- Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_efetua_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;	
	END pc_conciliar_cheques;
	
	-- Conciliar todos os cheques da remessa
	PROCEDURE pc_conciliar_todos_cheques(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																			,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																			,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																			,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																			,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																			,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																			,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_conciliar_todos_cheques
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 30/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para conciliar todos os cheques da remessa

    Alteracoes: 
                                                     
  ............................................................................. */
		DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
			
			-- Variáveis auxiliares
			vr_qtocorre NUMBER := 0;
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
			

			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT 1
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt
					 AND hcc.insithcc = 1;
      rw_craphcc cr_craphcc%ROWTYPE;		
			
		  -- Busca detalhes da custódia de cheque
		  CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT dcc.dsdocmc7
              ,dcc.nrseqarq
              ,dcc.intipmvt
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.inconcil = 0;						

	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

			-- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_craphcc INTO rw_craphcc;

			-- Se não encontrou
			IF cr_craphcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphcc;
				-- Data para Deposito invalida
				vr_cdcritic := 0;
				vr_dscritic := 'Remessa não encontrada ou já processada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_craphcc;				

      -- Buscar todos os cheques da remessa
      FOR rw_crapdcc IN cr_crapdcc(pr_cdcooper => vr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_nrconven => pr_nrconven
																	,pr_nrremret => pr_nrremret
																	,pr_intipmvt => pr_intipmvt) LOOP
				-- Conciliar cada cheque da remessa
			  cust0001.pc_conciliar_cheque_arquivo(pr_cdcooper => vr_cdcooper
				                                    ,pr_nrdconta => pr_nrdconta
																						,pr_nrremret => pr_nrremret
																						,pr_dsdocmc7 => rw_crapdcc.dsdocmc7
																						,pr_nrseqarq => rw_crapdcc.nrseqarq
																						,pr_intipmvt => rw_crapdcc.intipmvt
																						,pr_inconcil => 1
																						,pr_dtmvtolt => rw_crapdat.dtmvtolt
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
																						
				-- Se ocorreu erro
				IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
					-- Levantar Excecao
					vr_qtocorre := vr_qtocorre + 1;
				END IF;							
																			
      END LOOP;
			
			-- Se houve algum cheque com ocorrência
			IF vr_qtocorre > 0 THEN
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe(m) ' || vr_qtocorre || ' cheque(s) com ocorrência(s)';
        -- Efetuar commit
			  COMMIT;

        -- Levanta exceção
				RAISE vr_exc_erro;
			END IF;

      -- Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_efetua_resgate: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;	
	END pc_conciliar_todos_cheques;

  -- Custodiar os cheques conciliados na remessa
	PROCEDURE pc_custodiar_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_custodiar_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 03/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para custodiar os cheques conciliados na remessa

    Alteracoes: Ajuste no no cdoperad informado na geracao da previa (Daniel)
                                                     
  ............................................................................. */
		DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
						
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
			

			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT 1
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt
					 AND hcc.insithcc = 1;
      rw_craphcc cr_craphcc%ROWTYPE;		
					
      -- Verificar se possui cheque conciliado
			CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT 1
				  FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
           AND dcc.intipmvt = pr_intipmvt
           AND dcc.inconcil = 1;
      rw_crapdcc cr_crapdcc%ROWTYPE;	
      
	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

			-- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_craphcc INTO rw_craphcc;

			-- Se não encontrou
			IF cr_craphcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphcc;
				-- Data para Deposito invalida
				vr_cdcritic := 0;
				vr_dscritic := 'Remessa não encontrada ou já processada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_craphcc;				
      
      -- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_crapdcc INTO rw_crapdcc;

			-- Se não encontrou
			IF cr_crapdcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapdcc;
				-- Data para Deposito invalida
				vr_cdcritic := 0;
				vr_dscritic := 'Remessa não possui cheque conciliados. Operação Cancelada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_crapdcc;				

      -- Custodiar cheques da remessa
      cust0001.pc_custodiar_cheques(pr_cdcooper => vr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrconven => pr_nrconven
																	 ,pr_nrremret => pr_nrremret
																	 ,pr_intipmvt => pr_intipmvt
																	 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																	 ,pr_idorigem => vr_idorigem
																	 ,pr_cdoperad => vr_cdoperad
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic);

			-- Se ocorreu erro
			IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
		  END IF;
			
			pc_gera_previa(pr_cdcooper => vr_cdcooper  --> Cooperativa
										,pr_nrdconta => pr_nrdconta  --> Nr. da conta
										,pr_nrconven => pr_nrconven  --> Número do convênvio
										,pr_nrremret => pr_nrremret  --> Remessa
										,pr_cdoperad => vr_cdoperad  --> Operador
										,pr_cdcritic => vr_cdcritic  --> Cód. da crítica
										,pr_dscritic => vr_dscritic);--> Desc. da crítica
      
      -- Efetuar commit
			COMMIT;
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_custodiar_remessa: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;	
	END pc_custodiar_remessa;

  -- Rotina para verifica os cheques não conciliados da remessa
  PROCEDURE pc_verifica_cheques_conc(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
																		,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
																		,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
																		,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																		,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_verifica_cheques_conc
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 03/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para verificar os cheques não conciliados da remessa

    Alteracoes: 
                                                     
  ............................................................................. */
  DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
			
			-- Variáveis auxiliares
			vr_clob CLOB;
			vr_flgcqcon NUMBER := 0;
			vr_flgocorr NUMBER := 0;
						
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
						
		  -- Verifica se ha algum cheque conciliado na remessa
		  CURSOR cr_crapdcc_cqcon(pr_cdcooper IN craphcc.cdcooper%TYPE
														 ,pr_nrdconta IN craphcc.nrdconta%TYPE
														 ,pr_nrconven IN craphcc.nrconven%TYPE
														 ,pr_nrremret IN craphcc.nrremret%TYPE
														 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT distinct(1)
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.inconcil = 0
					 AND dcc.intipmvt IN (1,3)
					 AND trim(dcc.cdocorre) IS NULL;
					 
		  -- Verifica se há cheques com ocorrencia na remessa
		  CURSOR cr_crapdcc_ocorr(pr_cdcooper IN craphcc.cdcooper%TYPE
														 ,pr_nrdconta IN craphcc.nrdconta%TYPE
														 ,pr_nrconven IN craphcc.nrconven%TYPE
														 ,pr_nrremret IN craphcc.nrremret%TYPE
														 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT distinct(1)
					FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
					 AND dcc.inconcil = 0
					 AND dcc.intipmvt IN (1,3)
					 AND trim(dcc.cdocorre) IS NOT NULL;
					 
			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT hcc.insithcc
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt;
      rw_craphcc cr_craphcc%ROWTYPE;		
					 

	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
			
						-- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_craphcc INTO rw_craphcc;

			-- Se não encontrou
			IF cr_craphcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphcc;
				-- Atribui critica
				vr_cdcritic := 0;
				vr_dscritic := 'Remessa não encontrada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_craphcc;				

      -- Se eremessa estiver processada
      IF rw_craphcc.insithcc = 2 THEN
				-- Atribuir crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Remessa já processada';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
			END IF;
			
			-- Verifica se há um cheque não conciliado na remessa
			OPEN cr_crapdcc_cqcon(pr_cdcooper => vr_cdcooper
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_nrconven => pr_nrconven
													 ,pr_nrremret => pr_nrremret
													 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_crapdcc_cqcon INTO vr_flgcqcon;

			-- Verifica se há um cheque não conciliado na remessa com ocorrência
			OPEN cr_crapdcc_ocorr(pr_cdcooper => vr_cdcooper
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_nrconven => pr_nrconven
													 ,pr_nrremret => pr_nrremret
													 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_crapdcc_ocorr INTO vr_flgocorr;
			
      -- Cria xml de retorno
      vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
			           -- Se existe algum cheque não conciliado na remessa sem ocorrência
			           || '<flgcqcon>' || vr_flgcqcon || '</flgcqcon>' 
			           -- Se existe algum cheque não conciliado na remessa com ocorrência								 
								 || '<flgocorr>' || vr_flgocorr || '</flgocorr>'
								 || '</Dados></Root>';

      -- Xml de retorno
      pr_retxml := XMLType.createXML(vr_clob);
			
		EXCEPTION
			WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro geral em pc_verifica_cheques_conc: ' || SQLERRM;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
				ROLLBACK;		
		END;	
  END pc_verifica_cheques_conc;
	
	PROCEDURE pc_gera_previa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
													,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
													,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
													,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador
													,pr_cdcritic OUT PLS_INTEGER           --> Cód. da crítica
													,pr_dscritic OUT VARCHAR2) IS          --> Desc. da crítica
  BEGIN
  /* .............................................................................
    Programa: pc_gera_previa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 04/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar prévia dos lotes de custódia

    Alteracoes: 
                                                     
  ............................................................................. */		
	  DECLARE
			-- Tratamento de críticas		                                                                           
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
			
			vr_qtarquiv PLS_INTEGER; -- Quantidade de arquivos
			vr_totregis PLS_INTEGER; -- Total de registros
			vr_vlrtotal NUMBER;      -- Valor total
			
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
			
			-- Cursor de detalhes do cheque para gerar prévia por lote
			CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
			                 ,pr_nrdconta IN crapdcc.nrdconta%TYPE
			                 ,pr_nrconven IN crapdcc.nrconven%TYPE
											 ,pr_nrremret IN crapdcc.nrremret%TYPE) IS 
			  SELECT dcc.cdagenci
				      ,dcc.nrdolote
				  FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt IN (1,3)
					 AND dcc.nrdolote > 0
					 GROUP BY dcc.cdagenci, dcc.nrdolote;

	  BEGIN
			
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

			-- Bloqueia operador no processo da prévia
      COMP0001.pc_controla_bloqueio_previa(pr_cdcooper => pr_cdcooper
			                                    ,pr_nmsistem => 'CRED'
																					,pr_tptabela => 'GENERI'
																					,pr_cdempres => pr_cdcooper
																					,pr_cdacesso => 'COMPEL'
																					,pr_tpregist => 1
																					,pr_cdoperad => pr_cdoperad
																					,pr_inbloque => 1); -- 1 - Bloquear
			
			-- Percorre cheques da remessa agrupados por lote
			FOR rw_crapdcc IN cr_crapdcc(pr_cdcooper => pr_cdcooper
				                          ,pr_nrdconta => pr_nrdconta
																	,pr_nrconven => pr_nrconven
																	,pr_nrremret => pr_nrremret) LOOP
			
			  -- Gerar arquivo de previa
				COMP0001.pc_gerar_arquivos_compel(pr_dtmvtolt => rw_crapdat.dtmvtolt
				                                , pr_cdcooper => pr_cdcooper
																				, pr_cdageini => rw_crapdcc.cdagenci
																				, pr_cdagefim => rw_crapdcc.cdagenci
																				, pr_cdoperad => pr_cdoperad
																				, pr_nmdatela => 'COMPEL_CST'
																				, pr_nrdolote => rw_crapdcc.nrdolote
																				, pr_nrdcaixa => 600
																				, pr_cdbccxlt => 0
																				, pr_cdcritic => vr_cdcritic
																				, pr_dscritic => vr_dscritic
																				, pr_qtarquiv => vr_qtarquiv
																				, pr_totregis => vr_totregis
																				, pr_vlrtotal => vr_vlrtotal);
							
				-- Se retornou crítica										
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
					RAISE vr_exc_erro;
				END IF;
				
			END LOOP;         
			-- Desbloqueia operador no processo da prévia
      COMP0001.pc_controla_bloqueio_previa(pr_cdcooper => pr_cdcooper
			                                    ,pr_nmsistem => 'CRED'
																					,pr_tptabela => 'GENERI'
																					,pr_cdempres => pr_cdcooper
																					,pr_cdacesso => 'COMPEL'
																					,pr_tpregist => 1
																					,pr_cdoperad => pr_cdoperad
																					,pr_inbloque => 2); -- 2 - Desbloquear
		EXCEPTION
			WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        
				--Efetuar rollback
				ROLLBACK;
			WHEN OTHERS THEN
				--Atribuir críticas
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro geral em pc_verifica_cheques_conc: ' || SQLERRM;
				
        -- Efetuar rollback
				ROLLBACK;						
		END;													
  END pc_gera_previa;	
	
	-- Excluir remessa de custódia
	PROCEDURE pc_excluir_remessa(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
															,pr_nrconven IN craphcc.nrconven%TYPE  --> Número do convênvio
															,pr_nrremret IN craphcc.nrremret%TYPE  --> Remessa
															,pr_intipmvt IN craphcc.intipmvt%TYPE  --> Tipo de movimento
															,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
															,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
															,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
  /* .............................................................................
    Programa: pc_excluir_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 10/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para excluir a remessa de custódia

    Alteracoes: 
                                                     
  ............................................................................. */
		DECLARE
 		  -- Tratamento de críticas		                                                                           
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_erro EXCEPTION;			
  
      vr_dstransa      VARCHAR2(100);
      vr_rowid_log     ROWID;
      
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
						
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;					
			
			--Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

			-- Verificar se remessa está pendente
			CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
			  SELECT hcc.rowid
              ,hcc.nmarquiv
              ,hcc.insithcc
				  FROM craphcc hcc
				 WHERE hcc.cdcooper = pr_cdcooper
				   AND hcc.nrdconta = pr_nrdconta
					 AND hcc.nrconven = pr_nrconven
					 AND hcc.nrremret = pr_nrremret
					 AND hcc.intipmvt = pr_intipmvt
					 AND hcc.intipmvt = 3;
      rw_craphcc cr_craphcc%ROWTYPE;		

			-- Verificar se remessa está pendente
			CURSOR cr_crapdcc(pr_cdcooper IN craphcc.cdcooper%TYPE
			                 ,pr_nrdconta IN craphcc.nrdconta%TYPE
											 ,pr_nrconven IN craphcc.nrconven%TYPE
											 ,pr_nrremret IN craphcc.nrremret%TYPE
											 ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS
        SELECT dcc.nrborder
				  FROM crapdcc dcc
				 WHERE dcc.cdcooper = pr_cdcooper
				   AND dcc.nrdconta = pr_nrdconta
					 AND dcc.nrconven = pr_nrconven
					 AND dcc.nrremret = pr_nrremret
					 AND dcc.intipmvt = pr_intipmvt
           AND (dcc.inconcil = 1
            OR dcc.nrborder > 0)
           AND ROWNUM = 1;
      rw_crapdcc cr_crapdcc%ROWTYPE;		

			
	  BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CUSTOD'
                                ,pr_action => null); 	
			
		  -- Extrai dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

			-- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_craphcc INTO rw_craphcc;

			-- Se não encontrou
			IF cr_craphcc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphcc;
				-- Data para Deposito invalida
				vr_cdcritic := 0;
				vr_dscritic := 'Operação não permitida. Remessa não encontrada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;				
			END IF;
			-- Fecha cursor
			CLOSE cr_craphcc;	
      
      IF rw_craphcc.insithcc = 2 THEN
        vr_cdcritic := 0;
				vr_dscritic := 'Operação não permitida. Remessa já processada.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
      END IF;
      
      IF rw_craphcc.nmarquiv <> ' ' THEN
        vr_cdcritic := 0;
				vr_dscritic := 'Operação não permitida. Remessa por arquivo.';
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;
      END IF;
      
			-- Buscar remessa de cheque para verificar se ainda não foi processada
			OPEN cr_crapdcc(pr_cdcooper => vr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrconven => pr_nrconven
										 ,pr_nrremret => pr_nrremret
										 ,pr_intipmvt => pr_intipmvt);
			FETCH cr_crapdcc INTO rw_crapdcc;
			
			-- Se encontrou
			IF cr_crapdcc%FOUND THEN
				-- Fecha cursor
				CLOSE cr_crapdcc;
				-- Data para Deposito invalida
				vr_cdcritic := 0;
        IF rw_crapdcc.nrborder > 0 THEN
          vr_dscritic := 'Remessa possui cheques vinculados à um borderô.';
        ELSE
				vr_dscritic := 'Remessa possui cheques conciliados.';
        END IF;
				-- Executa RAISE para sair das validações
				RAISE vr_exc_erro;								
			END IF;
			-- Fecha cursor
			CLOSE cr_crapdcc;

      -- Remove detalhes do cheque
      DELETE FROM crapdcc dcc
 		   WHERE dcc.cdcooper = vr_cdcooper
				 AND dcc.nrdconta = pr_nrdconta
				 AND dcc.nrconven = pr_nrconven
				 AND dcc.nrremret = pr_nrremret
				 AND dcc.intipmvt = pr_intipmvt
				 AND dcc.inconcil = 0;				
      -- Remove header do cheque
			DELETE FROM craphcc hcc
		   WHERE hcc.rowid = rw_craphcc.rowid;
      -- Efetuar commit
			COMMIT;
			
      
      vr_dstransa := 'Exclusao da remessa ' || 'Nro.: ' || pr_nrremret;
          
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ' '
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid_log);
			
		EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
					pr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);
				ELSE					
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_custodiar_remessa: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;		
		END;	
	END pc_excluir_remessa;
	
END TELA_CUSTOD;
/
