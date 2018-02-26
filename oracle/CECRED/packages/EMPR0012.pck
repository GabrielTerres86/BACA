CREATE OR REPLACE PACKAGE CECRED.EMPR0012 IS

  TYPE typ_cmp_bens IS TABLE OF VARCHAR2(200) 
	    INDEX BY VARCHAR2(200);

	TYPE typ_tab_bens IS TABLE OF typ_cmp_bens  -- Associative array type
			INDEX BY PLS_INTEGER;            --  indexed by string

             
  /* Verificar contas do cooperado a partir do CPF/CNPJ */
  PROCEDURE pc_consulta_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                 ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo de pessoa
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Nr. do CPF/CNPJ
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
									
  /* Validar dados da inclusão da proposta */							 
	PROCEDURE pc_valida_dados_proposta(pr_cdcoploj IN NUMBER     --> Código da cooperativa do lojista
		                                ,pr_nrctaloj IN NUMBER     --> Nr. da conta do lojista
																		,pr_cdcopass IN NUMBER     --> Código da cooperativa do associado
																		,pr_tpemprst IN NUMBER     --> Tipo de empréstimo
																		,pr_cdlcremp IN NUMBER     --> Código da linha de crédito
																		,pr_cdfinemp IN NUMBER     --> Código da finalidade
																		,pr_dsbensal IN VARCHAR2   --> Bens em alienação 
																		,pr_dsbensal_out OUT CLOB  --> Bens em alienação alterados
																		,pr_cdcritic OUT crapcri.cdcritic%TYPE
																		,pr_dscritic OUT crapcri.dscritic%TYPE);

  /* Responsável pela montagem do retorna das propostas */
  PROCEDURE pc_monta_retorno_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                                 ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																		 ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Nr. contrato
																		 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK                            

  /* Validar inclusão do gravames */
	PROCEDURE pc_valida_gravames(pr_cdcopass IN NUMBER                 --> Código da cooperativa do associado
		                          ,pr_nrctaass IN NUMBER                 --> Nr. da conta do associado
															,pr_nrctremp IN NUMBER                 --> Número do contrato de empréstimo
															,pr_dsbensal IN VARCHAR2               --> Bens em alienação 
															,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
															,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
															,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

	/* Rotina responsável por montar o retorno ao Autorizador */
	PROCEDURE pc_monta_retorno_gravames(pr_cdcooper IN NUMBER                 --> Código da cooperativa
																		 ,pr_dtretgrv IN DATE                   --> Data de registro do gravames
																		 ,pr_nrseqlot IN NUMBER                 --> Número do lote do gravames
																		 ,pr_dsjsongv OUT NOCOPY json                  --> Retorna o json para envio
																		 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
						
  /* Enviar retorno do gravames */
	PROCEDURE pc_envia_retorno_gravames(pr_cdcooper IN NUMBER                   --> Código da cooperativa
		                                 ,pr_dtretgrv IN DATE                     --> Data de processamento do retorno
																		 ,pr_nrseqlot IN NUMBER                   --> Número do lote de processamento
																		 ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2);              --> Descrição da crítica	
	
	/* Validar informações do serviço */
	PROCEDURE pc_valida_dados_integracao(pr_cdcooper  IN NUMBER                 --> Código da cooperativa
  		                                ,pr_cdcoploj  IN NUMBER                 --> Código da cooperativa do lojista		
																			,pr_dsusuari  IN VARCHAR2               --> Usuário
																			,pr_dsdsenha  IN VARCHAR2               --> Senha
																			,pr_cdcliente IN PLS_INTEGER            --> Código do cliente
																			,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
																			,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
																			,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
																			,pr_retxml    IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
																			,pr_nmdcampo  OUT VARCHAR2              --> Nome do Campo
																			,pr_des_erro  OUT VARCHAR2);            --> Saida OK/NOK
													 
   /* Processa retorno analise motor de credito */
   PROCEDURE pc_processa_analise(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa da proposta
                                ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta da proposta
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero da proposta
                                ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                                ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                                ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                                ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                                ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                                ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                                ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                                ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                                ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                                ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
																
 --> Rotina responsavel por validar se cooperativa está em contingência
  PROCEDURE pc_verifica_contingencia_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
																				,pr_incdccon OUT tbepr_cdc_parametro.inintegra_cont%TYPE
																				,pr_cdcritic OUT NUMBER
																				,pr_dscritic OUT VARCHAR2);				 
END EMPR0012;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0012 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0012
  --  Sistema  : Integração CDC x Autorizador
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Outubro - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para integração do CDC x Autorizador.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  FUNCTION fn_retorna_chassi_seq(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS --> Cooperativa
	/* .............................................................................
		Programa: fn_retorna_chassi_seq
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Novembro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Function para retornar nr. do chassi ficticio
	    
		Alteracoes: 
	............................................................................. */
	  -- Variáveis auxiliáres
		vr_nrchassi VARCHAR2(40);
	BEGIN
    -- Buscar nr. do chassi
    vr_nrchassi := 'CDC' 
		            || to_char(pr_cdcooper, 'fm000') 
								|| to_char(SEQEPR_DSCHASSI.nextval,'fm00000000000');
		-- Retornar chassi
		RETURN vr_nrchassi;
  END;
  
	PROCEDURE pc_consulta_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                             ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo de pessoa
																 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Nr. do CPF/CNPJ
		                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
	/* .............................................................................
		Programa: pc_consulta_cooperado
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Outubro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por validar se o CPF/CNPJ possui conta nas 
		            cooperativas. (webservice)
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10000);
				
		-- Variáveis auxiliares
		vr_contador      NUMBER := 0;
		vr_retxml        xmltype;		
		vr_stsnrcal      BOOLEAN;
		vr_inpessoa      INTEGER;
		
		-- Verificar se CPF possui conta em alguma cooperativa
		CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
		                 ,pr_inpessoa IN crapass.inpessoa%TYPE
										 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
			SELECT ass.cdcooper
						,ass.cdagenci
						,substr(ass.nrdconta, 1, length(ass.nrdconta)-1) AS nrdconta
						,substr(ass.nrdconta,-1) AS dvdconta 
						,to_char(ass.dtadmiss, 'DD/MM/RRRR') dtadmiss
				FROM crapass ass
						,crapcop cop
				WHERE ass.cdcooper = cop.cdcooper
					AND ass.inpessoa = pr_inpessoa
					AND ass.nrcpfcgc = pr_nrcpfcgc
					AND ass.dtdemiss IS NULL 
					AND ass.cdsitdct IN (1,6) -- situacao conta 
	        AND ((ass.cdcooper = pr_cdcooper AND cop.flintcdc = 1)
					 OR  (cop.tpcdccop = 1 AND cop.flintcdc = 1)); -- RF88
  BEGIN
		-- Incluir nome do módulo logado
		GENE0001.pc_informa_acesso(pr_module => 'EMPR0012'
															,pr_action => null); 
												
		-- Validar CPF/CNPJ
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc, 
			                          pr_stsnrcal => vr_stsnrcal, 
																pr_inpessoa => vr_inpessoa);

    -- CPF/CNPJ inválido		
		IF vr_stsnrcal = FALSE THEN
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Parametro CPFCNPJNumero nao e um numero valido!';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

		
		-- Iniciar o XML
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_erro);
		gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => NULL, pr_des_erro => vr_des_erro);

    -- Loop sob as contas do cooperado		
		FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper
			                          ,pr_inpessoa => pr_inpessoa
																,pr_nrcpfcgc => pr_nrcpfcgc) LOOP

      -- Inserir tag de nova conta																
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'contas', pr_posicao => 0          , pr_tag_nova => 'conta'            , pr_tag_cont => NULL               , pr_des_erro => vr_des_erro);
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'conta' , pr_posicao => vr_contador, pr_tag_nova => 'cooperativaCodigo', pr_tag_cont => rw_crapass.cdcooper, pr_des_erro => vr_des_erro);
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'conta' , pr_posicao => vr_contador, pr_tag_nova => 'PACodigo'         , pr_tag_cont => rw_crapass.cdagenci, pr_des_erro => vr_des_erro);
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'conta' , pr_posicao => vr_contador, pr_tag_nova => 'contaNumero'      , pr_tag_cont => rw_crapass.nrdconta, pr_des_erro => vr_des_erro);
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'conta' , pr_posicao => vr_contador, pr_tag_nova => 'contaDV'          , pr_tag_cont => rw_crapass.dvdconta, pr_des_erro => vr_des_erro);
			gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'conta' , pr_posicao => vr_contador, pr_tag_nova => 'admissaoData'     , pr_tag_cont => rw_crapass.dtadmiss, pr_des_erro => vr_des_erro);	
			
			vr_contador := vr_contador + 1;
												
		END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Nao Cooperado';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		-- Repassar retorno do XML
		pr_retxml := vr_retxml;

  EXCEPTION
			WHEN vr_exc_erro THEN		
				-- Atribuir críticas
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
				
			WHEN OTHERS THEN      
				-- Erro
				pr_cdcritic := 0;
				pr_dscritic := 'Erro geral do sistema ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_consulta_cooperado;
	
	PROCEDURE pc_valida_dados_proposta(pr_cdcoploj IN NUMBER     --> Código da cooperativa do lojista
		                                ,pr_nrctaloj IN NUMBER     --> Nr. da conta do lojista
																		,pr_cdcopass IN NUMBER     --> Código da cooperativa do associado
																		,pr_tpemprst IN NUMBER     --> Tipo de empréstimo
																		,pr_cdlcremp IN NUMBER     --> Código da linha de crédito
																		,pr_cdfinemp IN NUMBER     --> Código da finalidade
																		,pr_dsbensal IN VARCHAR2   --> Bens em alienação 
																		,pr_dsbensal_out OUT CLOB  --> Bens em alienação alterados
																		,pr_cdcritic OUT crapcri.cdcritic%TYPE
																		,pr_dscritic OUT crapcri.dscritic%TYPE) IS
	/* .............................................................................
		Programa: pc_valida_dados_proposta
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Outubro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por validar a inclusão da proposta.
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Variáveis auxiliares
		vr_qtdaciona NUMBER := 0;
		vr_nrchassi  VARCHAR2(40);
		vr_dsbensal_out  CLOB;

		 -- data das coopeativas
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar parâmetros do cdc
		CURSOR cr_param_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT par.nrprop_env
			      ,par.intempo_prop_env
			  FROM tbepr_cdc_parametro par
			 WHERE par.cdcooper = pr_cdcooper;		
		rw_param_cdc cr_param_cdc%ROWTYPE;
		
		CURSOR cr_ver_aciona(pr_cdcoploj IN NUMBER
		                    ,pr_nrctaloj IN NUMBER
												,pr_tempoenv IN NUMBER
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS 
		  SELECT count(*)
			  FROM crawepr epr
            ,tbgen_webservice_aciona aci
			 WHERE epr.cdcoploj=pr_cdcoploj
         AND epr.nrdccloj=pr_nrctaloj
         AND epr.dtmvtolt=pr_dtmvtolt
         AND epr.cdcooper=aci.cdcooper
         AND epr.nrdconta=aci.nrdconta
         AND epr.nrctremp=aci.nrctrprp
         AND aci.dhacionamento >= (SYSDATE - ((pr_tempoenv / 60)/24));
							  
	  -- Verificar indicador de integração CDC na cooperativa
		CURSOR cr_crapcop_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT 1
			  FROM crapcop cop
			 WHERE cop.cdcooper = pr_cdcooper
			   AND cop.flintcdc = 1;
		rw_crapcop_cdc cr_crapcop_cdc%ROWTYPE;
		
		-- Verficar tipo de finalidade
		CURSOR cr_crapfin(pr_cdcooper IN crapcop.cdcooper%TYPE
		                 ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
		  SELECT 1
			  FROM crapfin fin
			 WHERE fin.cdcooper = pr_cdcooper
			   AND fin.cdfinemp = pr_cdfinemp
				 AND fin.tpfinali = 3; -- CDC
		rw_crapfin cr_crapfin%ROWTYPE;
		
		-- Verificar se a linha de crédito está em uma finalidade CDC
		CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
		                 ,pr_cdfinemp IN craplch.cdfinemp%TYPE
										 ,pr_cdlcremp IN craplch.cdlcrhab%TYPE) IS
		  SELECT 1
			  FROM craplch lch,
				     crapfin fin
			 WHERE lch.cdcooper = pr_cdcooper
			   AND lch.cdlcrhab = pr_cdlcremp
				 AND lch.cdfinemp = pr_cdfinemp
				 AND fin.cdcooper = lch.cdcooper
				 AND fin.cdfinemp = lch.cdfinemp
				 AND fin.tpfinali = 3; -- CDC
		rw_craplch cr_craplch%ROWTYPE;
		
		-- Percorrer os bens alienados
		CURSOR cr_dsbensal IS
			SELECT trim(regexp_substr(texto, '[^\;]+', 1, 1)) categoriaBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 2)) descricaoFinalidadeBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 3)) corBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 4)) valorMercadoBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 5)) chassiBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 6)) anoFabricacaoBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 7)) anoModeloBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 8)) numeroPlaca
						,trim(regexp_substr(texto, '[^\;]+', 1, 9)) numeroRenavam
						,trim(regexp_substr(texto, '[^\;]+', 1, 10)) tipoChassi
						,trim(regexp_substr(texto, '[^\;]+', 1, 11)) UFPlaca
						,trim(regexp_substr(texto, '[^\;]+', 1, 12)) documentoProprietario
						,trim(regexp_substr(texto, '[^\;]+', 1, 13)) UFLicenciamento
						,trim(regexp_substr(texto, '[^\;]+', 1, 14)) tipoBem
						,trim(regexp_substr(texto, '[^\;]+', 1, 15)) identificacaoBem						
			FROM (			
				SELECT regexp_substr(pr_dsbensal, '[^|]+', 1, LEVEL) texto
					FROM dual
				CONNECT BY LEVEL <= regexp_count(pr_dsbensal, '[^|]+')
			);			
		
  BEGIN
		
	  -- Buscar parâmetros CDC da cooperativa
	  OPEN cr_param_cdc(pr_cdcooper => pr_cdcoploj);
		FETCH cr_param_cdc INTO rw_param_cdc;
	
    -- Se não encontrou parâmetros de integração CDC
    IF cr_param_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_param_cdc;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Parametros de CDC nao cadastrados.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_param_cdc;	
		
		-- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcoploj);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
       
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Verificar quantidade de acionamentos feitos pelo mesmo lojista dentro de uma hora		
    OPEN cr_ver_aciona(pr_cdcoploj => pr_cdcoploj
		                  ,pr_nrctaloj => pr_nrctaloj
											,pr_tempoenv => rw_param_cdc.intempo_prop_env
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		FETCH cr_ver_aciona INTO vr_qtdaciona;
    -- Fechar cursor
		CLOSE cr_ver_aciona;

    -- Verificar quantidade máxima parametrizada de envio de propostas por hora
    IF vr_qtdaciona > rw_param_cdc.nrprop_env THEN
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Quantidade de propostas excedeu o limite maximo.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		IF pr_tpemprst <> 1 THEN
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Tipo de emprestimo invalido';
			-- Levantar exceção
			RAISE vr_exc_erro;			
		END IF;
		
		-- Verificar indicador de integração CDC na cooperativa do lojista
		OPEN cr_crapcop_cdc(pr_cdcoploj);
		FETCH cr_crapcop_cdc INTO rw_crapcop_cdc;
				
		-- Se não possui integração CDC
		IF cr_crapcop_cdc%NOTFOUND THEN
			-- Fechar cursor
      CLOSE cr_crapcop_cdc;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Cooperativa nao permite integracao CDC.';
			-- Levantar exceção
			RAISE vr_exc_erro;			
		END IF;
		-- Fechar cursor
		CLOSE cr_crapcop_cdc;

		-- Verificar indicador de integração CDC na cooperativa do associado
		OPEN cr_crapcop_cdc(pr_cdcopass);
		FETCH cr_crapcop_cdc INTO rw_crapcop_cdc;
		
		-- Se não possui integração CDC
		IF cr_crapcop_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapcop_cdc;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Cooperativa nao permite integracao CDC.';
			-- Levantar exceção
			RAISE vr_exc_erro;			
		END IF;
		-- Fechar cursor
		CLOSE cr_crapcop_cdc;
		
		-- Verificar se finalidade de empréstimo é do tipo CDC
		OPEN cr_crapfin(pr_cdcooper => pr_cdcopass
		               ,pr_cdfinemp => pr_cdfinemp);
		FETCH cr_crapfin INTO rw_crapfin;
		
		-- Se não encontrou
		IF cr_crapfin%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapfin;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Finalidade de emprestimo invalida.';
			-- Levantar exceção
			RAISE vr_exc_erro;						
		END IF;

    -- Verificar se linha de crédito pertence a finalidade CDC
    OPEN cr_craplch(pr_cdcooper => pr_cdcopass
		               ,pr_cdfinemp => pr_cdfinemp
									 ,pr_cdlcremp => pr_cdlcremp);
		FETCH cr_craplch INTO rw_craplch;

		-- Se não encontrou
		IF cr_crapfin%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapfin;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Linha de credito invalida.';
			-- Levantar exceção
			RAISE vr_exc_erro;						
		END IF;
		
		-- Percorrer bens em alienação
		FOR rw_dsbensal IN cr_dsbensal LOOP
			-- O tipo do chassi deve ser sempre 2 (Normal)
			IF rw_dsbensal.tipoChassi <> '2' THEN
				-- Gerar crítica
				vr_cdcritic    := 0;
				vr_dscritic    := 'Tipo do Chassi invalido.';
				-- Levantar exceção
				RAISE vr_exc_erro;										
			END IF;
			
			-- Se não possuir nr. do chassi
			IF rw_dsbensal.chassibem IS NULL THEN
				-- Devemos buscar o número do chassi
				vr_nrchassi := fn_retorna_chassi_seq(pr_cdcooper => pr_cdcopass);
			ELSE 
				-- Recebe o valor do chassi recebido
				vr_nrchassi := rw_dsbensal.chassibem;
			END IF;
			-- Preparar o retorno dos bens alienados
			vr_dsbensal_out := nvl(vr_dsbensal_out, '')
			                || rw_dsbensal.categoriaBem
											|| ';' || rw_dsbensal.descricaoFinalidadeBem
											|| ';' || rw_dsbensal.corBem
											|| ';' || rw_dsbensal.valorMercadoBem
											|| ';' || vr_nrchassi
											|| ';' || rw_dsbensal.anoFabricacaoBem
											|| ';' || rw_dsbensal.anoModeloBem
											|| ';' || rw_dsbensal.numeroPlaca
											|| ';' || rw_dsbensal.numeroRenavam
											|| ';' || rw_dsbensal.tipoChassi
											|| ';' || rw_dsbensal.UFPlaca
											|| ';' || rw_dsbensal.documentoProprietario
											|| ';' || rw_dsbensal.UFLicenciamento
											|| ';' || rw_dsbensal.tipoBem
											|| ';' || rw_dsbensal.identificacaoBem || '|';
		END LOOP;
		
		-- Retornar bens alienados alterados
		pr_dsbensal_out := vr_dsbensal_out;
	EXCEPTION
		WHEN vr_exc_erro THEN		
			-- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
			                                  
  END pc_valida_dados_proposta;
	
  PROCEDURE pc_monta_retorno_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                                 ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Nr. da conta
																		 ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Nr. contrato
																		 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
	/* .............................................................................
		Programa: pc_monta_retorno_proposta
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Novembro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Montar retorno da proposta criada para envio de dados a Ibratan para a 
                chamada do Motor de Crédito
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;

    vr_dsjsonan json;
		vr_dsjsonan_clob CLOB;
    BEGIN
			-- Enviar proposta para análise no motor
			este0002.pc_gera_json_analise(pr_cdcooper => pr_cdcooper
			                             ,pr_cdagenci => pr_cdagenci
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrctremp => pr_nrctremp
																	 ,pr_nrctaav1 => 0
																	 ,pr_nrctaav2 => 0
																	 ,pr_dsjsonan => vr_dsjsonan
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic);
						
	    -- Se retornou alguma crítica											 
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_dsjsonan_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_dsjsonan_clob, dbms_lob.lob_readwrite);
			json.to_clob(vr_dsjsonan,vr_dsjsonan_clob);

		  -- Retornar para o XML
			pr_retxml := XMLType.createXML('<Root><Dados><dsjsonan><![CDATA[' || vr_dsjsonan_clob ||']]></dsjsonan></Dados></Root>');

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dsjsonan_clob);
      dbms_lob.freetemporary(vr_dsjsonan_clob);                        
						
		EXCEPTION
			WHEN vr_exc_erro THEN		
				-- Se crítica possui código e não tem descrição
			  IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
					-- Buscar descrição da crítica
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;
			
				-- Atribuir críticas
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
				
			WHEN OTHERS THEN      
				-- Erro
				pr_cdcritic := 0;
				pr_dscritic := 'Erro geral do sistema ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
			
	END pc_monta_retorno_proposta;
	
	PROCEDURE pc_valida_gravames(pr_cdcopass IN NUMBER                 --> Código da cooperativa do associado
		                          ,pr_nrctaass IN NUMBER                 --> Nr. da conta do associado
															,pr_nrctremp IN NUMBER                 --> Número do contrato de empréstimo
															,pr_dsbensal IN VARCHAR2               --> Bens em alienação 
															,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
															,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
															,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
	/* .............................................................................
		Programa: pc_valida_gravames
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Dezembro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por validar as regras para o processamento da 
		            inclusão do gravames.
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Variáveis auxiliares
		vr_bens           gene0002.typ_split;
    vr_dsc_bens       gene0002.typ_split;
		vr_val_bens       gene0002.typ_split;
		vr_ind_bens       gene0002.typ_split;
			
		vr_tab_bens  typ_tab_bens;        -- Associative array variable=
		
		-- Verificar se contrato de emprestimo já foi aprovado
		CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
		                 ,pr_nrdconta IN crawepr.nrdconta%TYPE
										 ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
		  SELECT 1
			  FROM crawepr epr
			 WHERE epr.cdcooper = pr_cdcooper
			   AND epr.nrdconta = pr_nrdconta
				 AND epr.nrctremp = pr_nrctremp
				 AND epr.insitapr = 1;		 
	   rw_crawepr cr_crawepr%ROWTYPE;
		 
		-- Buscar dados cadastrados do bem
		CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
		                 ,pr_nrdconta IN crapbpr.nrdconta%TYPE
										 ,pr_nrctremp IN crapbpr.nrctrpro%TYPE
										 ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
		  SELECT bpr.vlmerbem
			      ,bpr.nrmodbem
						,bpr.nranobem
						,ROWID
			  FROM crapbpr bpr
			 WHERE bpr.cdcooper = pr_cdcooper
			   AND bpr.nrdconta = pr_nrdconta
				 AND bpr.nrctrpro = pr_nrctremp
				 AND bpr.tpctrpro = 90 /* Emprestimo */
				 AND bpr.idseqbem = pr_idseqbem;
		rw_crapbpr cr_crapbpr%ROWTYPE;
				 
  BEGIN
		-- Verificar se contrato de emprestimo já foi aprovado
	  OPEN cr_crawepr(pr_cdcooper => pr_cdcopass
		               ,pr_nrdconta => pr_nrctaass
									 ,pr_nrctremp => pr_nrctremp);
	  FETCH cr_crawepr INTO rw_crawepr;
		
		-- Se não encontrou, contrato não existe ou ainda não foi aprovado
		IF cr_crawepr%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crawepr;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Contrato não existe ou ainda não foi aprovado.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crawepr;

		-- Cada registro de bem está separado por pipe ('|')
	  vr_bens := GENE0002.fn_quebra_string(pr_string => pr_dsbensal, pr_delimit => '|');
	
	  -- Percorrer cada registro de Bem recebido
	  FOR i IN vr_bens.first..vr_bens.last LOOP
			
		  -- Se registro for nulo, avança para próximo registro
		  IF TRIM(vr_bens(i)) IS NULL THEN
				continue;
		  END IF;
			-- Buscar valores e indices dos bens
			vr_dsc_bens := GENE0002.fn_quebra_string(pr_string => vr_bens(i), pr_delimit => '#');
			-- Capturar valores
			vr_val_bens := GENE0002.fn_quebra_string(pr_string => vr_dsc_bens(1), pr_delimit => ';');
			-- Capturar indices
			vr_ind_bens := GENE0002.fn_quebra_string(pr_string => vr_dsc_bens(2), pr_delimit => ';');			
			
			FOR j IN vr_val_bens.first..vr_val_bens.last LOOP
				-- Alimentamos a PlTable com o indice e valor de referencia
				vr_tab_bens(i)(vr_ind_bens(j)) := vr_val_bens(j);
			END LOOP;
			
		END LOOP;
		
		-- Percorrer os bens
		FOR i IN vr_tab_bens.first..vr_tab_bens.last LOOP
			-- Buscar registro de bem
		  OPEN cr_crapbpr(pr_cdcooper => pr_cdcopass
			               ,pr_nrdconta => pr_nrctaass
										 ,pr_nrctremp => pr_nrctremp
										 ,pr_idseqbem => to_number(vr_tab_bens(i)('identificacaoBem')));
			FETCH cr_crapbpr INTO rw_crapbpr;

      -- Se não encontrou bem
      IF cr_crapbpr%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapbpr;
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Bem não encontrado.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapbpr;
			
			-- Se uma das informações abaixo forem diferentes das cadastradas
			IF rw_crapbpr.vlmerbem <> to_number(vr_tab_bens(i)('valorMercadoBem')) OR 
				 rw_crapbpr.nrmodbem <> to_number(vr_tab_bens(i)('anoModeloBem'))    OR
				 rw_crapbpr.nranobem <> to_number(vr_tab_bens(i)('anoFabricaoBem'))  THEN
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Os campos Valor Mercado, Ano Modelo e Fabricação não podem ser alterados';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Verificar se chassi foi informado
			IF TRIM(vr_tab_bens(i)('chassiBem')) IS NULL THEN
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Chassi não informado ou informado de forma incorreta';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Atualizar os bens da proposta
			UPDATE crapbpr
			   SET crapbpr.dscatbem = vr_tab_bens(i)('categoriaBem')
				    ,crapbpr.dsbemfin = vr_tab_bens(i)('descricaoBem')
						,crapbpr.dscorbem = vr_tab_bens(i)('corBem')
						,crapbpr.dschassi = vr_tab_bens(i)('chassiBem')
						,crapbpr.nrdplaca = to_number(vr_tab_bens(i)('numeroPlaca'))
						,crapbpr.nrrenava = to_number(vr_tab_bens(i)('numeroRenavam'))
						,crapbpr.tpchassi = to_number(vr_tab_bens(i)('tipoChassi'))
						,crapbpr.ufdplaca = vr_tab_bens(i)('UFPlaca')
						,crapbpr.nrcpfbem = to_number(vr_tab_bens(i)('documentoProprietario'))
			      ,crapbpr.uflicenc = vr_tab_bens(i)('UFLicenciamento')
						,crapbpr.dstipbem = vr_tab_bens(i)('tipoBem')
			 WHERE crapbpr.rowid = rw_crapbpr.rowid;
		END LOOP;
	
	  -- Efetuar commit
		COMMIT;
	EXCEPTION
		WHEN vr_exc_erro THEN		
			-- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
			
			-- Efetuar rollback
			ROLLBACK;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
			
			-- Efetuar rollback
			ROLLBACK;			                                  
  END pc_valida_gravames;
	
	/* Rotina responsável por montar o retorno ao Autorizador */
	PROCEDURE pc_monta_retorno_gravames(pr_cdcooper IN NUMBER                 --> Código da cooperativa
																		 ,pr_dtretgrv IN DATE                 --> Data de registro do gravames
																		 ,pr_nrseqlot IN NUMBER                 --> Número do lote do gravames
																		 ,pr_dsjsongv OUT NOCOPY json                  --> Retorna o json para envio
																		 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
	/* .............................................................................
		Programa: pc_monta_retorno_gravames
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Janeiro/2017                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Montar JSON para retorno ao Autorizador com o processamento do Gravames.
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Declarar objetos Json necessários:
		vr_obj_generico  json := json();
		vr_obj_generic2  json := json();		
		vr_lst_generico  json_list := json_list();
		vr_lst_generic2  json_list := json_list();

    -- Buscar registros de gravames 
		CURSOR cr_crapgrv (pr_cdcooper IN crapgrv.cdcooper%TYPE
		                  ,pr_dtretgrv IN crapgrv.dtretgrv%TYPE
											,pr_nrseqlot IN crapgrv.nrseqlot%TYPE) IS
			SELECT grv.nrctrpro
			      ,grv.cdcooper
						,grv.nrdconta
			  FROM crapgrv grv
			 WHERE grv.cdcooper = pr_cdcooper
			   AND grv.dtretgrv = pr_dtretgrv
				 AND grv.nrseqlot = pr_nrseqlot
				 AND grv.tpctrpro = 90
			 GROUP BY grv.cdcooper
			         ,grv.nrdconta
							 ,grv.nrctrpro;

    -- Buscar bens do gravames 
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
		                 ,pr_nrdconta IN crapbpr.nrdconta%TYPE
										 ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE) IS
		  SELECT bpr.dschassi
			      ,bpr.nrgravam
			      ,bpr.dtatugrv
            ,(CASE WHEN bpr.flcancel = 1 THEN 'Cancelamento' ELSE 
              CASE WHEN bpr.flginclu = 1 THEN 'Inclusao' ELSE
              CASE WHEN bpr.flgbaixa = 1 THEN 'Baixa' END END END) tpsolici
						,decode(bpr.cdsitgrv
						       ,0, 'Nao enviado'
									 ,1, 'Em processamento'
									 ,2, 'Alienacao'
									 ,3, 'Processado com critica'
									 ,4, 'Baixado'
									 ,5, 'Cancelado', '') dssitgrv
			  FROM crapbpr bpr
			 WHERE bpr.cdcooper = pr_cdcooper
				 AND bpr.nrdconta = pr_nrdconta
				 AND bpr.nrctrpro = pr_nrctrpro
				 AND bpr.tpctrpro = 90
				 AND bpr.flgalien = 1
         AND (bpr.dscatbem LIKE '%AUTOMOVEL%' OR
              bpr.dscatbem LIKE '%MOTO%'      OR
              bpr.dscatbem LIKE '%CAMINHAO%');
				 				    
	BEGIN
		-- Inicializar json
		vr_lst_generico := json_list();
		
	  -- Percorrer registros do gravames
		FOR rw_crapgrv IN cr_crapgrv(pr_cdcooper => pr_cdcooper
			                          ,pr_dtretgrv => pr_dtretgrv
																,pr_nrseqlot => pr_nrseqlot) LOOP
																
      -- Para cada registro de Gravames, criar objeto com as respectivas informações 
      vr_obj_generico := json();
      vr_obj_generico.put('contratoNumero',             rw_crapgrv.nrctrpro);
      vr_obj_generico.put('cooperativaAssociadoCodigo', rw_crapgrv.cdcooper);
      vr_obj_generico.put('contaAssociadoNumero',       SUBSTR(to_char(rw_crapgrv.nrdconta), 0, LENGTH(to_char(rw_crapgrv.nrdconta)) - 1));
      vr_obj_generico.put('contaAssociadoDV',           SUBSTR(to_char(rw_crapgrv.nrdconta), -1));

      -- Inicializar lista de bens
			vr_lst_generic2 := json_list();

      -- Buscar bens do contrato
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => rw_crapgrv.cdcooper
				                          ,pr_nrdconta => rw_crapgrv.nrdconta
																	,pr_nrctrpro => rw_crapgrv.nrctrpro) LOOP
				-- Para cada registro de Bem, criar objeto com as respectivas informações 
				vr_obj_generic2 := json();
	      vr_obj_generic2.put('chassiNumero',        rw_crapbpr.dschassi);
	      vr_obj_generic2.put('gravamesNumero',      rw_crapbpr.nrgravam);
	      vr_obj_generic2.put('gravamesData',        rw_crapbpr.dtatugrv);
	      vr_obj_generic2.put('tipoSolicitacao',     rw_crapbpr.tpsolici);
	      vr_obj_generic2.put('retornoDescricao',    rw_crapbpr.dssitgrv);
				
				-- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
			
			END LOOP;
			
			vr_obj_generico.put('bensAlienacao', vr_lst_generic2);
			
			-- Adicionar Bem na lista
      vr_lst_generico.append(vr_obj_generico.to_json_value());
	  END LOOP;
		
		vr_obj_generico := json();
		vr_obj_generico.put('retornoGravames', vr_lst_generico);
		
		-- Repassar o json criado para o parâmetro
    pr_dsjsongv := vr_obj_generico;		
		
	EXCEPTION
		WHEN vr_exc_erro THEN		
			-- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
			
			-- Efetuar rollback
			ROLLBACK;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
			
			-- Efetuar rollback
			ROLLBACK;			                                  		
	END pc_monta_retorno_gravames;
	
	PROCEDURE pc_envia_retorno_gravames(pr_cdcooper IN NUMBER                   --> Código da cooperativa
		                                 ,pr_dtretgrv IN DATE                     --> Data de processamento do retorno
																		 ,pr_nrseqlot IN NUMBER                   --> Número do lote de processamento
																		 ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2) IS            --> Descrição da crítica
	/* .............................................................................
		Programa: pc_envia_retorno_gravames
    Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Janeiro/2018                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por enviar os dados de retorno de Gravames
		            ao Autorizador.
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    
		-- Variáveis de envio/resposta da ibratan
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;

	  -- Variáveis auxiliares
		vr_autori_cdc    VARCHAR2(500);
    vr_dsdirlog      VARCHAR2(500);
    vr_dsjsongv json := json();
		vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE := 0;
		
		-- Buscar usuário e senha da Ibratan
		CURSOR cr_cliente_cdc IS
		  SELECT cli.idtoken
			      ,cli.dstoken
			 FROM tbgen_webservice_cliente cli
			WHERE cli.cdcliente = 1;
		rw_cliente_cdc cr_cliente_cdc%ROWTYPE;
	
	BEGIN
		
	  -- Buscar usuário e senha
		OPEN cr_cliente_cdc;
		FETCH cr_cliente_cdc INTO rw_cliente_cdc;
	
	  -- Se não encontrou 
	  IF cr_cliente_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_cliente_cdc;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Cliente não cadastrado';
			-- Levantar execeção
			RAISE vr_exc_erro;
		END IF;

		-- Fechar cursor
		CLOSE cr_cliente_cdc;
		
		-- Montar retorno do processamento do gravames
		pc_monta_retorno_gravames(pr_cdcooper => pr_cdcooper
		                         ,pr_dtretgrv => pr_dtretgrv
														 ,pr_nrseqlot => pr_nrseqlot
														 ,pr_dsjsongv => vr_dsjsongv
														 ,pr_cdcritic => vr_cdcritic
														 ,pr_dscritic => vr_dscritic);
	
	  -- Codificar usuário e senha na Base64
	  vr_autori_cdc := utl_encode.text_encode(rw_cliente_cdc.idtoken || ':' || rw_cliente_cdc.dstoken
                                           ,'WE8ISO8859P1', UTL_ENCODE.BASE64);
	
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := '';
    vr_request.api_route   := '';
    vr_request.method      := '';
    vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_cdc;
    vr_request.content := vr_dsjsongv.to_char();
    
		-- Gravar acionamento
		webs0003.pc_grava_acionamento(pr_cdcooper => pr_cdcooper
		                             ,pr_cdagenci => 1
																 ,pr_cdoperad => 'AUTOCDC'
																 ,pr_cdorigem => 5
																 ,pr_nrctrprp => 0
																 ,pr_nrdconta => 0
																 ,pr_cdcliente => 1
																 ,pr_tpacionamento => 1
																 ,pr_dsoperacao => 'INTEGRACAO CDC - RETORNO GRAVAMES'
																 ,pr_dsuriservico => vr_request.service_uri
																 ,pr_dsmetodo => vr_request.method
																 ,pr_dtmvtolt => TRUNC(SYSDATE)
																 ,pr_cdstatus_http => 200
																 ,pr_dsconteudo_requisicao => vr_request.content
																 ,pr_dsresposta_requisicao => ''
																 ,pr_dsprotocolo => ''
																 ,pr_flgreenvia => 0
																 ,pr_nrreenvio => 0
																 ,pr_tpconteudo => 1
																 ,pr_tpproduto => 0
																 ,pr_idacionamento => vr_idacionamento
																 ,pr_dscritic => vr_dscritic);		

    -- Em caso de crítica retornar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
																 
    --> Buscar diretorio do log
    vr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => 3, 
                                         pr_nmsubdir => '/log/webservices' ); 		
		
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
 
		-- Atualizar tabela de acionamento após envio
		WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => vr_response.status_code
																		,pr_flgreenvia              => 0
																		,pr_idacionamento           => vr_idacionamento
																		,pr_dsresposta_requisicao   => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
																																	 ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
																																	 ',"Content":'||vr_response.content||'}'
																		,pr_dscritic                => vr_dscritic);     

    -- Em caso de crítica retornar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

	EXCEPTION
		WHEN vr_exc_erro THEN		
			-- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
			
			-- Enviar e-mail informando falha no envio
			gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper
			                          ,pr_cdprogra => 'EMPR0012'
																,pr_des_destino => 'cdc@cecred.coop.br'
																,pr_des_assunto => 'Falha ao enviar retorno de gravames'
																,pr_des_corpo => 'A rotina falhou ao enviar retorno de gravames.' || CHR(13) ||
																                 'Cooperativa: ' || pr_cdcooper || CHR(13) ||
																								 'Data de retorno do gravames: ' || pr_dtretgrv || CHR(13) ||
																                 'Nr. do lote: ' || pr_nrseqlot || CHR(13) ||
																								 'Id. Acionamento: ' || vr_idacionamento || '.'
																,pr_des_anexo => ''
																,pr_des_erro => vr_dscritic);
			
			-- Se já foi gravado acionamento
			IF vr_idacionamento > 0 THEN
			  -- Atualizar tabela de acionamento após envio
				WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => NULL
																				,pr_flgreenvia              => 1
																				,pr_idacionamento           => vr_idacionamento
																				,pr_dsresposta_requisicao   => ''
																				,pr_dscritic                => vr_dscritic);     

			END IF;
			
			-- Commitar para gravar o acionamento
			COMMIT;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;

			-- Enviar e-mail informando falha no envio
			gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper
			                          ,pr_cdprogra => 'EMPR0012'
																,pr_des_destino => 'cdc@cecred.coop.br'
																,pr_des_assunto => 'Falha ao enviar retorno de gravames'
																,pr_des_corpo => 'A rotina falhou ao enviar retorno de gravames' || CHR(13) ||
																                 'Cooperativa: ' || pr_cdcooper || CHR(13) ||
																								 'Data de retorno do gravames: ' || pr_dtretgrv || CHR(13) ||
																                 'Nr. do lote: ' || pr_nrseqlot || CHR(13) ||
																								 'Id. Acionamento: ' || vr_idacionamento || '.'
																,pr_des_anexo => ''
																,pr_des_erro => vr_dscritic);
			
			-- Se já foi gravado acionamento
			IF vr_idacionamento > 0 THEN
			  -- Atualizar tabela de acionamento após envio
				WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => NULL
																				,pr_flgreenvia              => 1
																				,pr_idacionamento           => vr_idacionamento
																				,pr_dsresposta_requisicao   => ''
																				,pr_dscritic                => vr_dscritic);     

			END IF;
			
			-- Commitar para gravar o acionamento
			COMMIT;
	END pc_envia_retorno_gravames;
	
	PROCEDURE pc_valida_dados_integracao(pr_cdcooper  IN NUMBER                 --> Código da cooperativa
  		                                ,pr_cdcoploj  IN NUMBER                 --> Código da cooperativa do lojista
																			,pr_dsusuari  IN VARCHAR2               --> Usuário
																			,pr_dsdsenha  IN VARCHAR2               --> Senha
																			,pr_cdcliente IN PLS_INTEGER            --> Código do cliente
																			,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
																			,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
																			,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
																			,pr_retxml    IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
																			,pr_nmdcampo  OUT VARCHAR2              --> Nome do Campo
																			,pr_des_erro  OUT VARCHAR2) IS          --> Saida OK/NOK
	/* .............................................................................
		Programa: pc_valida_gravames
    Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Lucas Reinert
		Data    : Janeiro/2018                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por validar os serviços de integração CDC.
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Buscar usuário e senha da Ibratan
		CURSOR cr_cliente_cdc IS
		  SELECT cli.idtoken
			      ,cli.dstoken
			 FROM tbgen_webservice_cliente cli
			WHERE cli.cdcliente = pr_cdcliente;
		rw_cliente_cdc cr_cliente_cdc%ROWTYPE;
		
	  -- Verificar indicador de integração CDC na cooperativa
		CURSOR cr_crapcop_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT 1
			  FROM crapcop cop
			 WHERE cop.cdcooper = pr_cdcooper
			   AND cop.flintcdc = 1;
		rw_crapcop_cdc cr_crapcop_cdc%ROWTYPE;

    -- Verificar se integração CDC está em contingencia
    CURSOR cr_param_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT 1
			  FROM tbepr_cdc_parametro par
			 WHERE par.cdcooper = pr_cdcooper
			   AND par.inintegra_cont = 1;
		rw_param_cdc cr_param_cdc%ROWTYPE;
		
		rw_crapdat btch0001.cr_crapdat%ROWTYPE;
		
	BEGIN
		--Verificar se a data existe
		OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		-- Se não encontrar
		IF BTCH0001.cr_crapdat%NOTFOUND THEN
			-- Montar mensagem de critica
			vr_cdcritic:= 1;
			CLOSE BTCH0001.cr_crapdat;
			RAISE vr_exc_erro;
		ELSE
			-- Apenas fechar o cursor
			CLOSE BTCH0001.cr_crapdat;
		END IF;	
		
		-- Se está rodando o processo noturno
		IF rw_crapdat.inproces > 1 THEN
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Sistema indisponível';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
	  -- Buscar usuário e senha
		OPEN cr_cliente_cdc;
		FETCH cr_cliente_cdc INTO rw_cliente_cdc;
	
	  -- Se não encontrou 
	  IF cr_cliente_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_cliente_cdc;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Cliente não cadastrado';
			-- Levantar execeção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_cliente_cdc;
		
		-- Usuário diferente do parametrizado
		IF pr_dsusuari <> rw_cliente_cdc.idtoken THEN
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Usuário ou senha inválidos';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		
		-- Senha diferente do parametrizado
		IF pr_dsdsenha <> rw_cliente_cdc.dstoken THEN
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Usuário ou senha inválidos';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

		-- Verificar indicador de integração CDC na cooperativa do cooperado
		OPEN cr_crapcop_cdc(pr_cdcooper);
		FETCH cr_crapcop_cdc INTO rw_crapcop_cdc;
					
		-- Se não possui integração CDC
		IF cr_crapcop_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapcop_cdc;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Cooperativa nao permite integracao CDC.';
			-- Levantar exceção
			RAISE vr_exc_erro;			
		END IF;
		-- Fechar cursor
		CLOSE cr_crapcop_cdc;
		
		-- Verificar indicador de integração CDC na cooperativa do lojista
		OPEN cr_crapcop_cdc(pr_cdcoploj);
		FETCH cr_crapcop_cdc INTO rw_crapcop_cdc;
					
		-- Se não possui integração CDC
		IF cr_crapcop_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapcop_cdc;
			-- Gerar crítica
			vr_cdcritic    := 0;
			vr_dscritic    := 'Cooperativa nao permite integracao CDC.';
			-- Levantar exceção
			RAISE vr_exc_erro;			
		END IF;
		-- Fechar cursor
		CLOSE cr_crapcop_cdc;
		
    OPEN cr_param_cdc(pr_cdcooper);
		FETCH cr_param_cdc INTO rw_param_cdc;
		
		-- Cooperativa está com integração em contingencia
		IF cr_param_cdc%FOUND THEN
			-- Fechar cursor
			CLOSE cr_param_cdc;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Cooperativa em contingência.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
		WHEN vr_exc_erro THEN		
			-- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
			
			-- Efetuar rollback
			ROLLBACK;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
			
			-- Efetuar rollback
			ROLLBACK;			                                  
	END pc_valida_dados_integracao;
	
	  --> Rotina responsavel por reenviar os acionamentos com erro
  PROCEDURE pc_reenvia_acionamento(pr_cdcritic OUT NUMBER
                                  ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
      Programa : pc_reenvia_acionamento
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Lucas Reinert
      Data     : Janeiro/2018.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Chamada pelo o JOB
      Objetivo  : Reenviar os acionamentos que apresentaram erro
          
      Alteração : 
    ..........................................................................*/

    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;

    -- Variáveis auxiliares
		vr_autori_cdc    VARCHAR2(500);
    vr_dsdirlog      VARCHAR2(500);

		-- Variáveis de envio/resposta da ibratan
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
		
    -- Buscar acionamentos
	  CURSOR cr_acionamento IS
      SELECT twa.idacionamento
            ,twa.dsconteudo_requisicao
            ,twa.dsuriservico
            ,twa.dsmetodo
            ,twa.nrreenvio
            ,twa.cdcliente
            ,twa.tpconteudo
						,twa.cdcooper
						,twa.dsoperacao
        FROM tbgen_webservice_aciona twa
       WHERE twa.flgreenvia=1;
    rw_acionamento cr_acionamento%ROWTYPE;
	
    -- Buscar senha do cliente
		CURSOR cr_cliente (pr_cdcliente IN tbgen_webservice_cliente.cdcliente%TYPE) is
			SELECT twc.idtoken
						,twc.dstoken
				FROM tbgen_webservice_cliente twc
			 WHERE twc.cdcliente=pr_cdcliente;
		rw_cliente cr_cliente%ROWTYPE;
		
    BEGIN

			--> Buscar diretorio do log
			vr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C', 
																					 pr_cdcooper => 3, 
																					 pr_nmsubdir => '/log/webservices' ); 		

      -- Percorrer os dados de acionamento
      FOR rw_acionamento IN cr_acionamento LOOP

        -- Buscar dados de usuário e senha para conexao webservice
        OPEN cr_cliente (pr_cdcliente => rw_acionamento.cdcliente);
        FETCH cr_cliente INTO rw_cliente;
        
				-- Se nao tiver cliente nao envia 
				IF cr_cliente%NOTFOUND THEN
					-- Marcar para nao reenviar mais
					WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => NULL
																					,pr_flgreenvia              => 0
																					,pr_idacionamento           => rw_acionamento.idacionamento
																					,pr_dsresposta_requisicao   => ''
																					,pr_nrreenvio               => (rw_acionamento.nrreenvio + 1)
																					,pr_dscritic                => vr_dscritic);
																					
					-- Enviar e-mail informando falha no envio
					gene0003.pc_solicita_email(pr_cdcooper => rw_acionamento.cdcooper
																		,pr_cdprogra => 'EMPR0012'
																		,pr_des_destino => 'cdc@cecred.coop.br'
																		,pr_des_assunto => 'Falha ao reenviar acionamento: ' || rw_acionamento.dsoperacao
																		,pr_des_corpo => 'A rotina falhou ao reenviar acionamento.' || CHR(13) ||
																										 'Cooperativa: ' || rw_acionamento.cdcooper || CHR(13) ||
																										 'Id. Acionamento: ' || rw_acionamento.idacionamento || CHR(13) ||
																										 'Erro: Cliente não cadastrado.'
																		,pr_des_anexo => ''
																		,pr_des_erro => vr_dscritic);
          -- Pular para próximo registro
					CONTINUE;
				END IF;
        CLOSE cr_cliente;

        -- se for a 11 tentativa vamos enviar e-mail informando que esta com erro e então travar o reenvio
	      IF rw_acionamento.nrreenvio > 10 THEN
					-- Marcar para nao reenviar mais
					WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => NULL
																					,pr_flgreenvia              => 0
																					,pr_idacionamento           => rw_acionamento.idacionamento
																					,pr_dsresposta_requisicao   => ''
																					,pr_nrreenvio               => (rw_acionamento.nrreenvio + 1)
																					,pr_dscritic                => vr_dscritic);
																					
					-- Enviar e-mail informando falha no envio
					gene0003.pc_solicita_email(pr_cdcooper => rw_acionamento.cdcooper
																		,pr_cdprogra => 'EMPR0012'
																		,pr_des_destino => 'cdc@cecred.coop.br'
																		,pr_des_assunto => 'Falha ao reenviar acionamento: ' || rw_acionamento.dsoperacao
																		,pr_des_corpo => 'A rotina falhou ao reenviar acionamento.' || CHR(13) ||
																										 'Cooperativa: ' || rw_acionamento.cdcooper || CHR(13) ||
																										 'Id. Acionamento: ' || rw_acionamento.idacionamento || CHR(13) ||
																										 'Erro: Número de tentativas de reenvio excedida.'
																		,pr_des_anexo => ''
																		,pr_des_erro => vr_dscritic);
          -- Pular para próximo registro
					CONTINUE;
	      END IF;

				-- Codificar usuário e senha na Base64
				vr_autori_cdc := utl_encode.text_encode(rw_cliente.idtoken || ':' || rw_cliente.dstoken
																							 ,'WE8ISO8859P1', UTL_ENCODE.BASE64);
			
				-- Atribuir valores necessarios para comunicacao
				vr_request.service_uri := '';
				vr_request.api_route   := '';
				vr_request.method      := '';
				vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
		    
				vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
				vr_request.headers('Authorization') := vr_autori_cdc;
				vr_request.content := rw_acionamento.dsconteudo_requisicao;
								
				-- Disparo do REQUEST
				json0001.pc_executa_ws_json(pr_request           => vr_request
																	 ,pr_response          => vr_response
																	 ,pr_diretorio_log     => vr_dsdirlog
																	 ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
																	 ,pr_dscritic          => vr_dscritic); 
		                               
				IF TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;			
				
				-- Atualiza tabela acionamento apos tentativa de reenvio
        WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => vr_response.status_code
                                        ,pr_flgreenvia              => 0
                                        ,pr_idacionamento           => rw_acionamento.idacionamento
                                        ,pr_dsresposta_requisicao   => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
																																			 ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
																																			 ',"Content":'||vr_response.content||'}'
																				,pr_nrreenvio               => (rw_acionamento.nrreenvio + 1)
                                        ,pr_dscritic                => vr_dscritic);     
    
		  END LOOP;
			
      -- Efetuar commit		
      COMMIT;

    EXCEPTION
			WHEN vr_exc_erro THEN
				-- Atribuir críticas aos parâmetros
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
				
				-- Enviar e-mail informando falha no envio
				gene0003.pc_solicita_email(pr_cdcooper => rw_acionamento.cdcooper
																	,pr_cdprogra => 'EMPR0012'
																	,pr_des_destino => 'cdc@cecred.coop.br'
																	,pr_des_assunto => 'Falha ao reenviar acionamento: ' || rw_acionamento.dsoperacao
																	,pr_des_corpo => 'A rotina falhou ao reenviar acionamento.' || CHR(13) ||
																									 'Cooperativa: ' || rw_acionamento.cdcooper || CHR(13) ||
																									 'Id. Acionamento: ' || rw_acionamento.idacionamento || CHR(13) ||
																									 'Erro: ' || pr_dscritic || '.'
																	,pr_des_anexo => ''
																	,pr_des_erro => vr_dscritic);
																	
				-- Apenas para garantir atualização do registro de acionamento
				IF rw_acionamento.idacionamento > 0 THEN
					-- Atualizar tabela de acionamento após envio
					WEBS0003.pc_atualiza_acionamento(pr_cdstatus_http           => NULL
																					,pr_flgreenvia              => 1
																					,pr_idacionamento           => rw_acionamento.idacionamento
																					,pr_dsresposta_requisicao   => ''
																				  ,pr_nrreenvio               => (rw_acionamento.nrreenvio + 1)																					
																					,pr_dscritic                => vr_dscritic);     
				END IF;
				
				-- Efetuar commit
        COMMIT;				
      WHEN OTHERS THEN
				-- Atribuir críticas aos parâmetros				
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao efetuar reenvio de acionamentos: ' || SQLERRM;
	
				-- Enviar e-mail informando falha no envio
				gene0003.pc_solicita_email(pr_cdcooper => 3
																	,pr_cdprogra => 'EMPR0012'
																	,pr_des_destino => 'cdc@cecred.coop.br'
																	,pr_des_assunto => 'Falha ao reenviar acionamento. '
																	,pr_des_corpo => 'A rotina falhou ao reenviar acionamento.' || CHR(13) ||
																									 'Erro: ' || pr_dscritic || '.'
																	,pr_des_anexo => ''
																	,pr_des_erro => vr_dscritic);
					
				-- Efetuar commit
        COMMIT;				
  END pc_reenvia_acionamento;
  
  --> responsavel por processar o retorno da analise do motor de credito
  PROCEDURE pc_processa_analise(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                               ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa da proposta
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta da proposta
                               ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero da proposta
                               ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                               ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                               ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                               ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                               ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                               ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                               ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                               ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                               ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                               ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                               ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                               ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                               ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
	/* .............................................................................
	 Programa: pc_processa_analise
	 Sistema : Rotina integracao CDC
	 Sigla   : WEBS
	 Autor   : Lucas Reinert
	 Data    : Janeiro/17.                    Ultima atualizacao:

	 Dados referentes ao programa: 
   
	 Frequencia: Sempre que for executado o servico de analise

	 Objetivo  : Processar o retorno do motor de credito integracao cdc

	 Observacao: 
     
	 Alteracoes:

	 ..............................................................................*/	
	 DECLARE
     -- Tratamento de críticas
     vr_exc_saida EXCEPTION;
     vr_cdcritic PLS_INTEGER;
     vr_dscritic VARCHAR2(4000);
     vr_des_reto VARCHAR2(10);
			
     -- Variáveis auxiliares
     vr_msg_detalhe  VARCHAR2(10000);      --> Detalhe da mensagem    
     vr_status       PLS_INTEGER;          --> Status
	   vr_dssitret     VARCHAR2(100);        --> Situação de retorno
	   vr_nrtransacao  NUMBER(25) := 0;      --> Numero da transacao
	   vr_inpessoa     PLS_INTEGER := 0;     --> 1 - PF/ 2 - PJ
	   vr_insitapr     crawepr.insitapr%TYPE; --> Situacao Aprovacao(0-Em estudo/1-Aprovado/2-Nao aprovado/3-Restricao/4-Refazer)
      
     -- Buscar a proposta de empréstimo vinculada ao protocolo
	   CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE
                      ,pr_nrdconta crawepr.nrdconta%TYPE
                      ,pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT wpr.cdcooper
              ,wpr.nrdconta
              ,wpr.nrctremp
              ,wpr.cdagenci
              ,wpr.cdopeste
              ,wpr.insitest
              ,decode(wpr.insitapr, 0, 'EM ESTUDO', 1, 'APROVADO', 2, 'NAO APROVADO', 3, 'RESTRICAO', 4, 'REFAZER', 'SITUACAO DESCONHECIDA') dssitapr
              ,wpr.rowid
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp;  
		  rw_crawepr cr_crawepr%ROWTYPE;
			
     -- Buscar o tipo de pessoa que contratou o empréstimo
     CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
		                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT ass.inpessoa
		   FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
			  AND ass.nrdconta = pr_nrdconta;
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
    -- Variaveis temp para ajuste valores recebidos nos indicadores
    vr_indrisco VARCHAR2(100); --> Nível do risco calculado para a operação
    vr_nrnotrat VARCHAR2(100); --> Valor do rating calculado para a operação
    vr_nrinfcad VARCHAR2(100); --> Valor do item Informações Cadastrais calculado no Rating
    vr_nrliquid VARCHAR2(100); --> Valor do item Liquidez calculado no Rating
    vr_nrgarope VARCHAR2(100); --> Valor das Garantias calculada no Rating
    vr_nrparlvr VARCHAR2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
    vr_nrperger VARCHAR2(100); --> Valor da Percepção Geral da Empresa calculada no Rating
    vr_desscore VARCHAR2(100); --> Descricao do Score Boa Vista
    vr_datscore VARCHAR2(100); --> Data do Score Boa Vista
    vr_flgpreap INTEGER := 0;

    -- Bloco PLSQL para chamar a execução paralela do pc_crps414
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(100);
      
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := 'S';
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

    -- Função para verificar se parâmetro passado é numérico
    FUNCTION fn_is_number(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
      BEGIN
        IF TRIM(gene0002.fn_char_para_number(pr_vlparam)) IS NULL THEN
          RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;  
      EXCEPTION
        WHEN OTHERS THEN
					RETURN FALSE;
    END fn_is_number;
      
    -- Função para verificar se parâmetro passado é Data
    FUNCTION fn_is_date(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
      vr_data date;
      BEGIN
        vr_data := TO_DATE(pr_vlparam,'RRRRMMDD');
          IF vr_data IS NULL THEN 
            RETURN FALSE;
          ELSE
            RETURN TRUE;  
          END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
    END fn_is_date;
      
    -- Função para trocar o litereal "null" por null
    FUNCTION fn_converte_null(pr_dsvaltxt IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        IF pr_dsvaltxt = 'null' THEN
          RETURN NULL;
        ELSE
          RETURN pr_dsvaltxt;
         END IF;
      END;
								 
    BEGIN

    -- Se o acionamento já foi gravado na origem
    IF nvl(pr_nrtransa,0) > 0 THEN
      vr_nrtransacao := pr_nrtransa;
    END IF;  
    
    -- Buscar a proposta de empréstimo a partir do protocolo
    OPEN cr_crawepr(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrctremp);

    FETCH cr_crawepr INTO rw_crawepr;
			
    -- Se não encontrou a proposta
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                  ||' - WEBS0001 --> Erro ao gravar resultado da analise automatica '
                                                  ||'proposta – '|| pr_nrctremp ||' inexistente'          
                                ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																														                 ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Resultado Analise Automatica nao foi atualizado, ocorreu '
                     || 'erro interno no Sistema(1).';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crawepr;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crawepr.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno no sistema(2)';
      RAISE vr_exc_saida;
    END IF;
    
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
      
    -- Montar a mensagem que será gravada no acionamento
    CASE lower(pr_dsresana)
    WHEN 'aprovar'      THEN vr_dssitret := 'APROVADO AUTOM.';
    WHEN 'reprovar'     THEN vr_dssitret := 'REJEITADA AUTOM.';
    WHEN 'derivar'      THEN vr_dssitret := 'ANALISAR MANUAL';
    WHEN 'erro'         THEN vr_dssitret := 'ERRO';
    WHEN 'aprovar_auto' THEN vr_dssitret := 'APROVADO PRE APROVADO'; vr_flgpreap := 1;
    ELSE vr_dssitret := 'DESCONHECIDA';
    END CASE;

    -- Condicao para verificar se o processo esta rodando
    IF NVL(rw_crapdat.inproces,0) <> 1 THEN
      -- Montar mensagem de critica
      vr_status      := 400;
      vr_cdcritic    := 138;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, o processo batch  CECRED esta em execucao.';
      RAISE vr_exc_saida;
    END IF;	
      
    -- Somente se a proposta não foi atualizada ainda
    IF rw_crawepr.insitest <> 1 THEN
      -- Montar mensagem de critica
      vr_status      := 400;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Situacao da Proposta ja foi alterada - analise nao sera recebida.';
      RAISE vr_exc_saida;        
    END IF;		
			
    -- Se algum dos parâmetros abaixo não foram informados
    IF nvl(pr_cdorigem, 0) = 0 OR TRIM(pr_dsresana) IS NULL THEN
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(4)';
      RAISE vr_exc_saida;
    END IF;
	
    -- Se os parâmetros abaixo possuirem algum valor diferente do verificado
    IF NOT pr_cdorigem IN(5,9) OR NOT lower(pr_dsresana) IN('aprovar', 'aprovar_auto', 'reprovar', 'derivar', 'erro') THEN
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(5)';
      RAISE vr_exc_saida;
    END IF;
			
    -- Copia dos valores dos parâmetros para variaveis já corrigindo
    -- possiveis problemas com a vinda de parâmetros "null"
    vr_indrisco := fn_converte_null(pr_indrisco);
    vr_nrnotrat := fn_converte_null(pr_nrnotrat);
    vr_nrinfcad := fn_converte_null(pr_nrinfcad);
    vr_nrliquid := fn_converte_null(pr_nrliquid);
    vr_nrgarope := fn_converte_null(pr_nrgarope);
    vr_nrparlvr := fn_converte_null(pr_nrparlvr);
    vr_nrperger := fn_converte_null(pr_nrperger);
    vr_desscore := fn_converte_null(pr_desscore);
    vr_datscore := fn_converte_null(pr_datscore);
      
    -- Buscar o tipo de pessoa
    OPEN cr_crapass(pr_cdcooper => rw_crawepr.cdcooper
                   ,pr_nrdconta => rw_crawepr.nrdconta);
    FETCH cr_crapass INTO vr_inpessoa;
    CLOSE cr_crapass;
      
    IF lower(pr_dsresana) IN ('aprovar', 'aprovar_auto', 'reprovar', 'derivar') THEN
      -- Neste caso testes retornos obrigatórios
      IF (TRIM(vr_indrisco) IS NULL OR
          TRIM(vr_nrnotrat) IS NULL OR
          TRIM(vr_nrinfcad) IS NULL OR
          TRIM(vr_nrliquid) IS NULL OR
          TRIM(vr_nrgarope) IS NULL OR
          TRIM(vr_nrparlvr) IS NULL OR
          (TRIM(vr_nrperger) IS NULL AND vr_inpessoa = 2)) THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(6)';
          RAISE vr_exc_saida;
      END IF;
        
      -- Se risco não for um dos verificados abaixo
      IF NOT pr_indrisco IN('AA','A','B','C','D','E','F','G','H') THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(7)';
        RAISE vr_exc_saida;
      END IF;
        
      -- Se algum dos parâmetros abaixo não forem números
      IF NOT fn_is_number(vr_nrnotrat) OR
         NOT fn_is_number(vr_nrinfcad) OR
         NOT fn_is_number(vr_nrliquid) OR
         NOT fn_is_number(vr_nrgarope) OR
         NOT fn_is_number(vr_nrparlvr) OR
         (NOT fn_is_number(vr_nrperger) AND vr_inpessoa = 2 ) THEN

        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(8)';
        RAISE vr_exc_saida;
      END IF;
        
      -- Se nao for uma data valida
      IF vr_datscore IS NOT NULL AND NOT fn_is_date(vr_datscore) THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(9)';
        RAISE vr_exc_saida;
      END IF;

    END IF;

    -- Tratar status
    IF lower(pr_dsresana) = 'aprovar' OR lower(pr_dsresana) = 'aprovar_auto' THEN
      vr_insitapr := 1; -- Aprovado
    ELSIF lower(pr_dsresana) = 'reprovar' THEN
      vr_insitapr := 2; -- Reprovado
    ELSIF lower(pr_dsresana) = 'derivar' THEN
      vr_insitapr := 5; -- Derivada
    ELSE
      vr_insitapr := 6; -- Erro
    END IF;
        
    -- Atualizar proposta de empréstimo
    WEBS0001.pc_atualiza_prop_srv_emprestim(pr_cdcooper    => rw_crawepr.cdcooper --> Codigo da cooperativa
                                  ,pr_nrdconta    => rw_crawepr.nrdconta --> Numero da conta
                                  ,pr_nrctremp    => rw_crawepr.nrctremp --> Numero do contrato
                                  ,pr_tpretest    => 'M'            --> Retorno Motor  
                                  ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                  ,pr_insitapr    => vr_insitapr    --> Situação da Aprovação
                                  ,pr_indrisco    => vr_indrisco    --> Nível do Risco calculado na Analise 
                                  ,pr_nrnotrat    => gene0002.fn_char_para_number(vr_nrnotrat)    --> Calculo do Rating na Analise 
                                  ,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informação Cadastral da Analise 
                                  ,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise 
                                  ,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise 
                                  ,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise 
                                  ,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepção Geral Empresa na Analise 
                                  ,pr_dsdscore    => vr_desscore    --> Descrição Score Boa Vista
                                  ,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD')    --> Data Score Boa Vista
                                  ,pr_flgpreap    => vr_flgpreap    --> Indicador de Pré Aprovado
                                  ,pr_status      => vr_status      --> Status
                                  ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                  ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                  ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                  ,pr_des_reto    => vr_des_reto);  --> Erros do processo

		-- Caso somente foi passado como parametro o codigo da critica, vamos buscar a descricao da critica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
      RAISE vr_exc_saida;
		END IF;    
		
    -- Retornar XML
		pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);

    -- Gravar
    COMMIT;                                 

    EXCEPTION
      WHEN vr_exc_saida THEN
				-- Caso somente foi passado como parametro o codigo da critica, vamos buscar a descricao da critica
				IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
					-- Buscar crítica
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;    				
				
        -- Retornar XML
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);
				
      WHEN OTHERS THEN
				-- Montar retorno de erro
				vr_status      := 500;
        vr_cdcritic    := 0; 
        vr_dscritic    := 'Erro geral do sistema: ' || SQLERRM;
				vr_msg_detalhe := 'Ocorreu um erro interno no sistema.';

        -- Retornar XML
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);
				
    END; 
  END pc_processa_analise;	                                                     	

  --> Rotina responsavel por validar se cooperativa está em contingência
  PROCEDURE pc_verifica_contingencia_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
																				,pr_incdccon OUT tbepr_cdc_parametro.inintegra_cont%TYPE
																				,pr_cdcritic OUT NUMBER
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN																				
    /* ..........................................................................
      Programa : pc_verifica_contingencia_cdc
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Lucas Reinert
      Data     : Fevereiro/2018.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamada
      Objetivo  : Verificar se cooperativa está em contingencia
          
      Alteração : 
    ..........................................................................*/
    DECLARE
			-- Variáveis para tratamento de erros
			vr_exc_erro EXCEPTION;
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic crapcri.dscritic%TYPE;
			
	    -- Buscar parâmetro do cdc
			CURSOR cr_param_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				SELECT par.inintegra_cont
					FROM tbepr_cdc_parametro par
				 WHERE par.cdcooper = pr_cdcooper;		
			rw_param_cdc cr_param_cdc%ROWTYPE;

		BEGIN
			
			-- Buscar parâmetros CDC da cooperativa
			OPEN cr_param_cdc(pr_cdcooper => pr_cdcooper);
			FETCH cr_param_cdc INTO rw_param_cdc;
		
			-- Se não encontrou parâmetros de integração CDC
			IF cr_param_cdc%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_param_cdc;
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Parametros de CDC nao cadastrado.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_param_cdc;	
			
			-- Retornar se cooperativa está em contingencia
			pr_incdccon := rw_param_cdc.inintegra_cont;
			
		EXCEPTION
			WHEN vr_exc_erro THEN		
				-- Atribuir críticas
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
			WHEN OTHERS THEN      
				-- Erro
				pr_cdcritic := 0;
				pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
		END;
  END pc_verifica_contingencia_cdc;
	
END EMPR0012;
/
