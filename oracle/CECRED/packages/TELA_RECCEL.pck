CREATE OR REPLACE PACKAGE CECRED.TELA_RECCEL AS

  -- Buscar informações da conta
  PROCEDURE pc_busca_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
													,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
													,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
													,pr_dscritic OUT VARCHAR2             --> Descricao da critica
													,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
													,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
													,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_busca_recargas(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                             ,pr_dtinirec IN VARCHAR2               --> Data de início da recarga
                             ,pr_dtfimrec IN VARCHAR2               --> Data final da recarga
                             ,pr_nriniseq IN NUMBER                 --> Número inicial da sequência
                             ,pr_nrregist IN NUMBER                 --> Número de registros a retornar
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
														 
--> Rotina para geração do relatorio de acompanhamento de cheques custodiados
  PROCEDURE pc_imprime_recarga( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Nr. da conta
		                           ,pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE  --> Id. da operação
															 ,pr_dsiduser   IN VARCHAR2               --> id do usuario
															 ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
															 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
															 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
															 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
															 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
															 ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo														 

  -- Verificar se canal permite recarga
  PROCEDURE pc_situacao_canal_recarga(pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
																		 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
																		 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
																		 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
																		 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
																		 ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

  -- Rotina para pesquisar favoritos
  PROCEDURE pc_pesquisa_telefones(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
																 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
																 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Busca operadoras com seus produtos e valores
	PROCEDURE pc_busca_operadoras(pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
															 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
															 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
															 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
															 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
															 ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

PROCEDURE pc_efetua_recarga(pr_nrdconta    IN tbrecarga_operacao.nrdconta%TYPE      --> Conta
		                         ,pr_nrdddtel    IN tbrecarga_operacao.nrddd%TYPE       --> DDD
		                         ,pr_nrtelefo    IN tbrecarga_operacao.nrcelular%TYPE   --> Celular
														 ,pr_cdoperadora IN tbrecarga_operacao.cdoperadora%TYPE --> Operadora
														 ,pr_cdproduto   IN tbrecarga_operacao.cdproduto%TYPE   --> Produto
														 ,pr_vlrecarga   IN tbrecarga_operacao.vlrecarga%TYPE   --> Valor da recarga
		                         ,pr_xmllog      IN VARCHAR2                            --> XML com informacoes de LOG
														 ,pr_cdcritic   OUT PLS_INTEGER                         --> Codigo da critica
														 ,pr_dscritic   OUT VARCHAR2                            --> Descricao da critica
														 ,pr_retxml  IN OUT NOCOPY xmltype                      --> Arquivo de retorno do XML
														 ,pr_nmdcampo   OUT VARCHAR2                            --> Nome do campo com erro
														 ,pr_des_erro   OUT VARCHAR2);                          --> Erros do processo

END TELA_RECCEL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_RECCEL AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_RECCEL
  --    Autor   : Lucas Reinert
  --    Data    : Janeiro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela OPECEL (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  -- Buscar informações da conta  
  PROCEDURE pc_busca_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
													,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
													,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
													,pr_dscritic OUT VARCHAR2             --> Descricao da critica
													,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
													,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
													,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_conta
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados do cooperado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Buscar associado
			CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
			                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
				SELECT ass.nmprimtl
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			vr_nmprimtl crapass.nmprimtl%TYPE;
			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_RECCEL'
                                ,pr_action => null); 
			
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

      -- Se retornou algum erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			-- Buscar nome do associado
		  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO vr_nmprimtl;
			
		  -- Se não encontrou associado
		  IF cr_crapass%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapass;
				-- Gera crítica
				vr_cdcritic := 9;
				vr_dscritic := '';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapass;			
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<nmprimtl>' || vr_nmprimtl || '</nmprimtl>'
								 || '</Dados></Root>');

			
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_conta;
  
  PROCEDURE pc_busca_recargas(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                             ,pr_dtinirec IN VARCHAR2               --> Data de início da recarga
                             ,pr_dtfimrec IN VARCHAR2               --> Data final da recarga
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
    Programa: pc_busca_recargas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 07/03/2017                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar recargas de celular

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
      vr_dtinirec DATE := to_date(pr_dtinirec, 'dd/mm/rrrr');
      vr_dtfimrec DATE := to_date(pr_dtfimrec, 'dd/mm/rrrr');
      vr_qtregist NUMBER;
      
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
    
      vr_clob CLOB;
    
      -- Busca Recargas de celular
      CURSOR cr_recargas(pr_cdcooper IN craphcc.cdcooper%TYPE
                        ,pr_nrdconta IN craphcc.nrdconta%TYPE
                        ,pr_dtinirec IN craphcc.dtmvtolt%TYPE
                        ,pr_dtfimrec IN craphcc.dtmvtolt%TYPE) IS
        SELECT * FROM (
					SELECT to_char(tope.dtrecarga, 'DD/MM/RRRR') dtrecarga
					      ,to_char(tope.dttransa, 'HH24:MI:SS') hrtransa
								,to_char(tope.vlrecarga, 'fm99g999g990d00') vlrecarga
								,('('||to_char(tope.nrddd, 'fm00')||') ' ||
                 to_char(tope.nrcelular,'fm00000g0000','nls_numeric_characters=.-')) nrtelefo
								,toper.nmoperadora
								,tope.dsnsu_operadora
								,tope.idoperacao
								,rownum rnum
						FROM tbrecarga_operacao tope
						    ,tbrecarga_operadora toper
					 WHERE tope.cdcooper = pr_cdcooper
						 AND tope.nrdconta = pr_nrdconta
						 AND tope.cdcanal = 5
						 AND tope.insit_operacao = 2
						 AND tope.dtrecarga BETWEEN pr_dtinirec AND pr_dtfimrec						 
						 AND rownum <= (pr_nriniseq + pr_nrregist)
						 AND toper.cdoperadora = tope.cdoperadora)
           WHERE rnum >= pr_nriniseq;

      -- Buscar quantidade total de registros           
      CURSOR cr_recargas_tot(pr_cdcooper IN craphcc.cdcooper%TYPE
                            ,pr_nrdconta IN craphcc.nrdconta%TYPE
                            ,pr_dtinirec IN craphcc.dtmvtolt%TYPE
                            ,pr_dtfimrec IN craphcc.dtmvtolt%TYPE) IS
          SELECT COUNT(1)
						FROM tbrecarga_operacao tope
					 WHERE tope.cdcooper = pr_cdcooper
						 AND tope.nrdconta = pr_nrdconta
						 AND tope.cdcanal = 5
						 AND tope.insit_operacao = 2
						 AND tope.dtrecarga BETWEEN pr_dtinirec AND pr_dtfimrec;
                  
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_RECCEL'
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
		  IF vr_dtinirec > vr_dtfimrec THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Data final deve ser maior ou igual à data inicial do período.';
				RAISE vr_exc_erro;
			END IF;
						
      -- Cria xml de retorno
      vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>';
			
		  -- Busca Headers de custódia de cheque
      FOR rw_recarga IN cr_recargas(pr_cdcooper => vr_cdcooper
				                           ,pr_nrdconta => pr_nrdconta
																	 ,pr_dtinirec => vr_dtinirec
																	 ,pr_dtfimrec => vr_dtfimrec) LOOP
																					
				vr_clob := vr_clob || 
				           '<inf>'
 									 || '<dtrecarga>'|| rw_recarga.dtrecarga || '</dtrecarga>'
 									 || '<hrtransa>' || rw_recarga.hrtransa  || '</hrtransa>'
 									 || '<vlrecarga>'|| rw_recarga.vlrecarga || '</vlrecarga>'
 									 || '<nrtelefo>' || rw_recarga.nrtelefo  || '</nrtelefo>'
								   || '<nmoperadora>' || rw_recarga.nmoperadora  || '</nmoperadora>'									
								   || '<nsuoperadora>' || rw_recarga.dsnsu_operadora  || '</nsuoperadora>'
 								   || '<idoperacao>' || rw_recarga.idoperacao  || '</idoperacao>' ||
									 '</inf>';
			END LOOP;			
			-- Fechar tag de dados do xml de retorno
		  vr_clob := vr_clob || '</Dados>';
			
			-- Busca quantidade total de registros
			OPEN cr_recargas_tot(pr_cdcooper => vr_cdcooper
												 ,pr_nrdconta => pr_nrdconta
												 ,pr_dtinirec => vr_dtinirec
												 ,pr_dtfimrec => vr_dtfimrec);
      FETCH cr_recargas_tot INTO vr_qtregist;
			
			vr_clob := vr_clob || '<Qtregist>' || vr_qtregist || '</Qtregist>';
			
	    -- Fechar tag root do xml de retorno
		  vr_clob := vr_clob || '</Root>';
			
			-- Criar XML
			pr_retxml := xmltype.createXML(vr_clob);
			
		EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;

  END pc_busca_recargas;

  --> Rotina para geração do relatorio de acompanhamento de cheques custodiados
  PROCEDURE pc_imprime_recarga( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Nr. da conta
		                           ,pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE  --> Id. da operação
															 ,pr_dsiduser   IN VARCHAR2               --> id do usuario
															 ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
															 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
															 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
															 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
															 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
															 ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

    /* .............................................................................

    Programa: pc_imprime_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para geração do comprovante de recarga de celular no Ayllos Web

    Alteracoes: -----
    ..............................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_nmarqpdf VARCHAR2(1000);
		vr_cdagectl VARCHAR2(4);
		
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    vr_dsdireto  VARCHAR2(4000);
    vr_dscomand  VARCHAR2(4000);
    vr_typsaida  VARCHAR2(100); 
    vr_des_reto  VARCHAR2(100);
    vr_tab_erro  GENE0001.typ_tab_erro;
		vr_dsparams  crapprm.dsvlrprm%TYPE;

    -- Buscar operações de recarga
    CURSOR cr_operacao(pr_idoperacao IN tbrecarga_operacao.idoperacao%TYPE) IS
		  SELECT to_char(tope.dtrecarga, 'DD/MM/RRRR') dtrecarga
			      ,to_char(tope.dttransa, 'HH24:MI:SS') hrtransa
						,to_char(tope.vlrecarga, 'fm99g999g990d00') vlrecarga
						,('('||to_char(tope.nrddd, 'fm00')||') ' ||
             to_char(tope.nrcelular,'fm00000g0000','nls_numeric_characters=.-')) nrtelefo
						,toper.nmoperadora
						,tope.dsnsu_operadora
						,tope.dtdebito
			  FROM tbrecarga_operacao tope
				    ,tbrecarga_operadora toper
			 WHERE tope.idoperacao = pr_idoperacao
			   AND toper.cdoperadora = tope.cdoperadora;
		rw_operacao cr_operacao%ROWTYPE;
		
    -- Buscar os dados da tabela de Associados
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT gene0002.fn_mask_conta(crapass.nrdconta) nrdconta
             ,crapass.nmprimtl
         FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;

     -- Buscar agência da central da cooperativa
		 CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		   SELECT to_char(cop.cdagectl, 'fm0000') cdagectl
			       ,cop.nrtelsac
			       ,cop.nrtelouv
			   FROM crapcop cop
				WHERE cop.cdcooper = pr_cdcooper;
		rw_crapcop cr_crapcop%ROWTYPE;
		
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;


  BEGIN
      
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

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'pc_imprime_recarga'
                              ,pr_action => NULL);
															
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;															
															
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;															
															
    -- Buscar associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta );
    FETCH cr_crapass
     INTO rw_crapass;

    IF cr_crapass%NOTFOUND  THEN
      vr_cdcritic := 9; -- Associado Não Cadastrado
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
					
	  -- Buscar agencia da central
		OPEN cr_crapcop(vr_cdcooper);
		FETCH cr_crapcop INTO rw_crapcop;
		
		-- Se não encontrou a cooperativa										    
		IF cr_crapcop%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapcop;
			-- Gerar crítica
			vr_cdcritic := 0;
			vr_dscritic := 'Cooperativa não encontrada.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapcop;
		
		-- Buscar operações 
    OPEN cr_operacao(pr_idoperacao => pr_idoperacao);
		FETCH cr_operacao INTO rw_operacao;
		
		-- Se não encontrou
		IF cr_operacao%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_operacao;
			-- Gerar exceção
			vr_cdcritic := 0;
			vr_dscritic := 'Operação de recarga de celular não encontrada.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_operacao;
		
		pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><Raiz><Dados>' ||
		               '<cdagectl>'||rw_crapcop.cdagectl||'</cdagectl>'||
									 '<nrtelsac>'||rw_crapcop.nrtelsac||'</nrtelsac>'||
									 '<nrtelouv>'||rw_crapcop.nrtelouv||'</nrtelouv>'||
									 '<nrdconta>'||trim(rw_crapass.nrdconta)||'</nrdconta>'||
 									 '<nmprimtl>'||trim(rw_crapass.nmprimtl)||'</nmprimtl>'||
									 '<vlrecarga>'||rw_operacao.vlrecarga||'</vlrecarga>'||
									 '<nmoperadora>'||rw_operacao.nmoperadora||'</nmoperadora>'||
									 '<nrtelefo>'||rw_operacao.nrtelefo||'</nrtelefo>'||
									 '<dtrecarga>'||rw_operacao.dtrecarga||'</dtrecarga>'||
									 '<hrtransa>'||rw_operacao.hrtransa||'</hrtransa>'||
									 '<dtdebito>'||rw_operacao.dtdebito||'</dtdebito>'||
									 '<dsnsuope>'||rw_operacao.dsnsu_operadora||'</dsnsuope>'||
									 '</Dados></Raiz>', TRUE);    

    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => vr_cdcooper,
                                         pr_nmsubdir => '/rl');
    
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl731_'||pr_dsiduser||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    vr_nmarqpdf := 'crrl731_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';
		
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Buscar parametro da imagem do logo
	  vr_dsparams := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																						,pr_cdcooper => vr_cdcooper
																						,pr_cdacesso => 'IMG_LOGO_COOP');
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                               , pr_cdprogra  => 'RECCEL'--pr_cdprogra
                               , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/Raiz/Dados'
                               , pr_dsjasper  => 'crrl731.jasper'
                               , pr_dsparams  => 'PR_IMGDLOGO##' || vr_dsparams --> Parametros do comprovante
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 80
                               , pr_cdrelato  => 731
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;  
		 -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
		GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
																,pr_cdagenci => NULL
																,pr_nrdcaixa => NULL
																,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
																,pr_des_reto => vr_des_reto
																,pr_tab_erro => vr_tab_erro);
		-- Se retornou erro
		IF NVL(vr_des_reto,'OK') <> 'OK' THEN
			IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
				vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
				vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
				RAISE vr_exc_erro; -- encerra programa
			END IF;
    END IF;

		-- Remover relatorio do diretorio padrao da cooperativa
		gene0001.pc_OScommand(pr_typ_comando => 'S'
												 ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
												 ,pr_typ_saida   => vr_typsaida
												 ,pr_des_saida   => vr_dscritic);
		-- Se retornou erro
		IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
			-- Concatena o erro que veio
			vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
			RAISE vr_exc_erro; -- encerra programa
		END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmarqpdf
                          ,pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_imprime_recarga;
	
  -- Verificar se canal permite recarga
  PROCEDURE pc_situacao_canal_recarga(pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
																		 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
																		 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
																		 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
																		 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
																		 ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

    /* .............................................................................

    Programa: pc_situacao_canal_recarga
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar situação da recarga para o canal de origem

    Alteracoes: -----
    ..............................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variáveis auxiliáres
		vr_flgsitrc INTEGER;
		
		BEGIN
 		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_RECCEL'
                                ,pr_action => null); 
			
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

      -- Se retornou algum erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
      -- Buscar situação do canal de recarga
      RCEL0001.pc_situacao_canal_recarga(pr_cdcooper => vr_cdcooper
			                                  ,pr_idorigem => vr_idorigem
																				,pr_flgsitrc => vr_flgsitrc
																				,pr_cdcritic => vr_cdcritic
																				,pr_dscritic => vr_dscritic);
																				
      -- Se retornou algum erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<flgsitrc>' || vr_flgsitrc || '</flgsitrc>'
								 || '</Dados></Root>');
			
		EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_situacao_canal_recarga;
	
  -- Rotina para pesquisar favoritos
  PROCEDURE pc_pesquisa_telefones(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
																 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
																 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
																 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela de operadoras
      CURSOR cr_favoritos(pr_cdcooper IN crapcop.cdcooper%TYPE
			                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT tfav.cdseq_favorito 
				      ,'('||to_char(tfav.nrddd, 'fm00')||') ' ||
               to_char(tfav.nrcelular,'fm00000g0000','nls_numeric_characters=.-') ||
							 decode(trim(tfav.nmcontato), NULL,'', ' / ' || tfav.nmcontato ) dstelefo
							,tfav.nrddd
							,tfav.nrcelular
              ,count(1) over() retorno
          FROM tbrecarga_favorito tfav
         WHERE tfav.cdcooper = pr_cdcooper
           AND tfav.nrdconta = pr_nrdconta
         ORDER BY tfav.cdseq_favorito;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de Operadoras
        FOR rw_favorito IN cr_favoritos(pr_cdcooper => vr_cdcooper
					                             ,pr_nrdconta => pr_nrdconta) LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<FAVORITOS qtregist="' || rw_favorito.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
 																														'<nrdddtel>'|| rw_favorito.nrddd||'</nrdddtel>'||
 																														'<nrtelefo>'|| rw_favorito.nrcelular||'</nrtelefo>'||																														
                                                            '<cdseq_favorito>' || rw_favorito.cdseq_favorito ||'</cdseq_favorito>'||																														
                                                            '<dstelefo>' || rw_favorito.dstelefo ||'</dstelefo>'||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
					-- Gerar crítica
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<FAVORITOS qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</FAVORITOS></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na pesquisa operadoras: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pesquisa_telefones;
	
	PROCEDURE pc_busca_operadoras(pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
															 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
															 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
															 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
															 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
															 ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
    /* .............................................................................

    Programa: pc_busca_operadoras
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar situação da recarga para o canal de origem

    Alteracoes: -----
    ..............................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variáveis auxiliares
    vr_clob CLOB;
		vr_dtmvtolt DATE;
		vr_qtdopera NUMBER := 0;
		
		-- Cursor para listar os produtos de recarga
		CURSOR cr_produtos IS
			SELECT tprd.cdoperadora
						,tprd.cdproduto				
						,tprd.nmproduto
						,tope.nmoperadora
				FROM tbrecarga_produto tprd
						,tbrecarga_operadora tope
			 WHERE tprd.tpproduto = 1 -- Pré fixado
				 AND tope.cdoperadora = tprd.cdoperadora
				 AND tope.flgsituacao = 1;

		-- Buscar último valor atualizado do produto
		CURSOR cr_valores_dat(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
												 ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE) IS
			SELECT MAX(tval.dtmvtolt)
				FROM tbrecarga_valor tval
			 WHERE tval.cdoperadora = pr_cdoperadora
				 AND tval.cdproduto   = pr_cdproduto;
							 
		-- Cursor para listar os produtos de recarga
		CURSOR cr_valores(pr_cdoperadora IN tbrecarga_valor.cdoperadora%TYPE
										 ,pr_cdproduto   IN tbrecarga_valor.cdproduto%TYPE
										 ,pr_dtmvtolt    IN tbrecarga_valor.dtmvtolt%TYPE) IS
			SELECT to_char(tval.vlrecarga, 'fm999g990d00') vlrecarga
				FROM tbrecarga_valor tval
			 WHERE tval.cdoperadora = pr_cdoperadora
				 AND tval.cdproduto   = pr_cdproduto
				 AND tval.dtmvtolt    = pr_dtmvtolt;

    BEGIN			
      /* Extrai dados do xml */			
      gene0004.pc_extrai_dados(pr_xml => pr_retxml
															,pr_cdcooper => vr_cdcooper
															,pr_nmdatela => vr_nmdatela
															,pr_nmeacao  => vr_nmeacao
															,pr_cdagenci => vr_cdagenci
															,pr_nrdcaixa => vr_nrdcaixa
															,pr_idorigem => vr_idorigem
															,pr_cdoperad => vr_cdoperad
															,pr_dscritic => vr_dscritic);

		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_RECCEL'
                                ,pr_action => null); 

			-- Monta documento XML de ERRO
      vr_clob := '<Root><Dados>';

      -- Buscar os produtos de cada operadora															 
      FOR rw_produto IN cr_produtos LOOP
				vr_clob := vr_clob || 
				           '<operadora>' ||
										 '<cdoperadora>' || rw_produto.cdoperadora  || '</cdoperadora>' ||
										 '<cdproduto>' || rw_produto.cdproduto || '</cdproduto>' ||
										 '<nmproduto>' || rw_produto.nmproduto || '</nmproduto>' ||
										 '<valores>';
				-- Buscar última data do valor
				OPEN cr_valores_dat(pr_cdoperadora => rw_produto.cdoperadora
				                   ,pr_cdproduto => rw_produto.cdproduto);
				FETCH cr_valores_dat INTO vr_dtmvtolt;
				-- Fechar cursor
				CLOSE cr_valores_dat;
        -- Buscar todos os valores do produto
        FOR rw_valor IN cr_valores(pr_cdoperadora => rw_produto.cdoperadora
																	,pr_cdproduto => rw_produto.cdproduto
																	,pr_dtmvtolt => vr_dtmvtolt) LOOP
          vr_clob := vr_clob || 																	
					           '<valor>' || rw_valor.vlrecarga ||'</valor>';
				END LOOP;
        -- Fechar tags				
				vr_clob := vr_clob ||
				           '</valores></operadora>';
				-- Incrementa quantidade de operadoras
        vr_qtdopera	:= vr_qtdopera + 1;
			END LOOP;
			-- Quantidade de operadoras encontradas
			vr_clob := vr_clob ||
			           '<qtdopera>' || to_char(vr_qtdopera) || '</qtdopera>';
			
      -- Fechar tags
      vr_clob := vr_clob ||
			           '</Dados></Root>';
								
			-- Criar XML
			pr_retxml := xmltype.createXML(vr_clob);			 			
		EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	END pc_busca_operadoras;
	
	PROCEDURE pc_efetua_recarga(pr_nrdconta    IN tbrecarga_operacao.nrdconta%TYPE    --> Conta
		                         ,pr_nrdddtel    IN tbrecarga_operacao.nrddd%TYPE       --> DDD
		                         ,pr_nrtelefo    IN tbrecarga_operacao.nrcelular%TYPE   --> Celular
														 ,pr_cdoperadora IN tbrecarga_operacao.cdoperadora%TYPE --> Operadora
														 ,pr_cdproduto   IN tbrecarga_operacao.cdproduto%TYPE   --> Produto
														 ,pr_vlrecarga   IN tbrecarga_operacao.vlrecarga%TYPE   --> Valor da recarga
		                         ,pr_xmllog      IN VARCHAR2                            --> XML com informacoes de LOG
														 ,pr_cdcritic   OUT PLS_INTEGER                         --> Codigo da critica
														 ,pr_dscritic   OUT VARCHAR2                            --> Descricao da critica
														 ,pr_retxml  IN OUT NOCOPY xmltype                      --> Arquivo de retorno do XML
														 ,pr_nmdcampo   OUT VARCHAR2                            --> Nome do campo com erro
														 ,pr_des_erro   OUT VARCHAR2) IS                        --> Erros do processo
	/* .............................................................................

	Programa: pc_efetua_recarga
	Sistema : Ayllos Web
	Autor   : Lucas Reinert
	Data    : Março/2017                 Ultima atualizacao:

	Dados referentes ao programa:

	Frequencia: Sempre que for chamado

	Objetivo  : Rotina para efetuar recarga de celular

	Alteracoes: -----
	..............................................................................*/
	
	-- Variavel de criticas
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic VARCHAR2(10000);

	-- Tratamento de erros
	vr_exc_erro EXCEPTION;

	-- Variaveis de log
	vr_cdcooper INTEGER;
	vr_cdoperad VARCHAR2(100);
	vr_nmdatela VARCHAR2(100);
	vr_nmeacao  VARCHAR2(100);
	vr_cdagenci VARCHAR2(100);
	vr_nrdcaixa VARCHAR2(100);
	vr_idorigem VARCHAR2(100);
	
	-- Variáveis auxiliares
	vr_dsnsuope tbrecarga_operacao.dsnsu_operadora%TYPE;
	vr_dsprotoc crappro.dsprotoc%TYPE;
	vr_lsdatagd VARCHAR2(4000);
	
	BEGIN
		/* Extrai dados do xml */			
		gene0004.pc_extrai_dados(pr_xml => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);

/*		-- Incluir nome do módulo logado
		GENE0001.pc_informa_acesso(pr_module => 'TELA_RECCEL'
															,pr_action => null); */

    -- Chamar rotina para validar a recarga
		RCEL0001.pc_valida_recarga(pr_cdcooper => vr_cdcooper
		                          ,pr_nrdconta => pr_nrdconta
															,pr_idseqttl => 1
															,pr_nrcpfope => 0
															,pr_nrdddtel => pr_nrdddtel
															,pr_nrtelefo => pr_nrtelefo
															,pr_dtrecarga => trunc(SYSDATE)
															,pr_qtmesagd => 0
															,pr_cddopcao => 1 -- Data atual
															,pr_idorigem => vr_idorigem
															,pr_lsdatagd => vr_lsdatagd
															,pr_cdcritic => vr_cdcritic
															,pr_dscritic => vr_dscritic);

    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Chamar rotina para efetuar a recarga
    RCEL0001.pc_efetua_recarga(pr_cdcooper => vr_cdcooper
		                          ,pr_nrdconta => pr_nrdconta
															,pr_idseqttl => 1
															,pr_vlrecarga => pr_vlrecarga
															,pr_nrdddtel => pr_nrdddtel
															,pr_nrtelefo => pr_nrtelefo
															,pr_cdproduto => pr_cdproduto
															,pr_cdopetel => pr_cdoperadora
															,pr_idoperac => 0
															,pr_nrcpfope => 0
															,pr_cdcoptfn => 0
															,pr_nrterfin => 0
															,pr_nrcartao => 0
															,pr_nrsequni => 0
															,pr_idorigem => vr_idorigem
															,pr_nsuopera => vr_dsnsuope
															,pr_dsprotoc => vr_dsprotoc
															,pr_cdcritic => vr_cdcritic
															,pr_dscritic => vr_dscritic);
															
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
											
		-- Criar XML de retorno
		pr_retxml := XMLTYPE.CREATEXML(
									'<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
							 || '<dsnsuope>' || vr_dsnsuope || '</dsnsuope>'
							 || '</Dados></Root>');
						
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			END IF;

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;

			-- Carregar XML padrao para variavel de retorno
			pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela RECCEL: ' || SQLERRM;

			-- Carregar XML padrao para variavel de retorno
			pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');			
	END pc_efetua_recarga;
		
END TELA_RECCEL;
/
