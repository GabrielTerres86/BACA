CREATE OR REPLACE PACKAGE CECRED.TELA_CADRES IS
  --
	PROCEDURE pc_busca_workflow(pr_cdcooper IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
                             ,pr_xmllog   IN  VARCHAR2                             -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                          -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                             -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                             -- Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2                             -- Erros do processo
		                         );
  --
	PROCEDURE pc_insere_aprovador(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
                               ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           );
  --
	PROCEDURE pc_exclui_aprovador(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           );
	--
	PROCEDURE pc_busca_aprovadores(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                            ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
																,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
																,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
																,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
																,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
																,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
																,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
																);
	--
	PROCEDURE pc_busca_operadores(pr_cdcooper IN  crapope.cdcooper%TYPE -- Identificador da cooperativa
		                           ,pr_cdoperad IN  crapope.cdoperad%TYPE -- Código do operador
															 ,pr_nmoperad IN  crapope.nmoperad%TYPE -- Nome do operador
															 ,pr_xmllog   IN  VARCHAR2              -- XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype     -- Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2              -- Erros do processo
															 );
	--
END TELA_CADRES;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADRES IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADRES
  --  Sistema  : Ayllos Web
  --  Autor    : Adriao Nagasava - Supero
  --  Data     : 13/07/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADRES
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
	
	PROCEDURE pc_insere_param_workflow(pr_cdcooper           IN  tbrecip_param_workflow.cdcooper%TYPE
		                                ,pr_cdalcada_aprovacao IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE
																		,pr_dscritic           OUT VARCHAR2
		                                ) IS
    /* .............................................................................

    Programa: pc_insere_param_workflow
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 13/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar incluir as alcadas de aprovacao para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
	BEGIN
		--
		INSERT INTO tbrecip_param_workflow(cdcooper
		                                  ,cdalcada_aprovacao
																			,flcadastra_aprovador
																			)
																VALUES(pr_cdcooper
																      ,pr_cdalcada_aprovacao
																			-- Se o nível é 1 - Coordenação Regional, indica que deverá buscar os aprovadores da CADREG
																			,decode(pr_cdalcada_aprovacao, 1, 0, 1)
																			);
																			
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao inserir na tbrecip_param_workflow: ' || SQLERRM;
	END pc_insere_param_workflow;
	--
	PROCEDURE pc_busca_workflow(pr_cdcooper IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
														 ,pr_xmllog   IN  VARCHAR2                             -- XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER                          -- Código da crítica
														 ,pr_dscritic OUT VARCHAR2                             -- Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2                             -- Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2                             -- Erros do processo
		                         ) IS
    /* .............................................................................

    Programa: pc_busca_workflow
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 13/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as alcadas de aprovacao para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar o flow de aprovação
		CURSOR cr_param_workflow(pr_cdcooper tbrecip_param_workflow.cdcooper%TYPE
		                        ) IS
      SELECT tpw.cdalcada_aprovacao
						,tdc.dscodigo
						,tpw.flregra_aprovacao
						,tpw.flcadastra_aprovador
				FROM tbrecip_param_workflow tpw
						,tbcobran_dominio_campo tdc
			 WHERE tpw.cdalcada_aprovacao = tdc.cddominio
				 AND tdc.nmdominio          = 'IDALCADA_RECIPR'
				 AND tpw.cdcooper           = pr_cdcooper;
		
		rw_param_workflow cr_param_workflow%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_qtregistros NUMBER;
		vr_tab_dominios gene0010.typ_tab_dominio;
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			SELECT COUNT(1)
			  INTO vr_qtregistros
			  FROM tbrecip_param_workflow tpw
			 WHERE tpw.cdcooper = pr_cdcooper;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao verificar se existe workflow: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Se não encontrou o cadastro de workflow para a cooperativa informada
		IF vr_qtregistros = 0 THEN
			--
			GENE0010.pc_retorna_dominios(pr_nmmodulo     => 'COBRAN'          -- Nome do modulo(CADAST, COBRAN, etc.)
																	,pr_nmdomini     => 'IDALCADA_RECIPR' -- Nome do dominio
																	,pr_tab_dominios => vr_tab_dominios   -- Retorna os dados dos dominios
																	,pr_dscritic     => vr_dscritic       -- Retorna descricao da critica
																	);
			--
			IF vr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_erro;
				--
			END IF;
			--
			IF vr_tab_dominios.count > 0 THEN
				--
				FOR i IN vr_tab_dominios.first..vr_tab_dominios.last LOOP
					--
					pc_insere_param_workflow(pr_cdcooper           => pr_cdcooper                  -- IN
																	,pr_cdalcada_aprovacao => vr_tab_dominios(i).cddominio -- IN
																	,pr_dscritic           => vr_dscritic                  -- OUT
																	);
					--
					IF vr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
				END LOOP;
				--
			END IF;
			--
		END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_param_workflow(pr_cdcooper);
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_param_workflow INTO rw_param_workflow;
			EXIT WHEN cr_param_workflow%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdalcada_aprovacao>'   || rw_param_workflow.cdalcada_aprovacao   ||'</cdalcada_aprovacao>'   ||
												'<flregra_aprovacao>'    || rw_param_workflow.flregra_aprovacao    ||'</flregra_aprovacao>'    ||
												'<flcadastra_aprovador>' || rw_param_workflow.flcadastra_aprovador ||'</flcadastra_aprovador>' ||
												'<dsalcada_aprovacao>'   || rw_param_workflow.dscodigo             ||'</dsalcada_aprovacao>' ||
										 '</inf>');
			--
		END LOOP;
		--
		IF cr_param_workflow%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		ELSE
			--
			vr_dscritic := 'Nenhuma alcada encontrada para a cooperativa informada: ' || pr_cdcooper;
      RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_param_workflow;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_workflow;
	--
	PROCEDURE pc_insere_aprovador(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           ) IS
		/* .............................................................................

    Programa: pc_insere_aprovador
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir o aprovador na alcadas de aprovacao para a cooperativa e nível informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
		
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			INSERT INTO tbrecip_param_aprovador(cdcooper
			                                   ,cdalcada_aprovacao
																				 ,cdaprovador
																				 )
																	 VALUES(pr_cdcooper
																	       ,pr_cdalcada_aprovacao
																				 ,pr_cdaprovador
																				 );
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao inserir o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_insere_aprovador;
	--
	PROCEDURE pc_exclui_aprovador(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           ) IS
		/* .............................................................................

    Programa: pc_exclui_aprovador
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o aprovador na alcadas de aprovacao para a cooperativa e nível informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
		
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			DELETE FROM tbrecip_param_aprovador tpa
			      WHERE tpa.cdcooper           = pr_cdcooper
			        AND tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao
							AND tpa.cdaprovador        = pr_cdaprovador;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao excluir o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_exclui_aprovador;
  --
  PROCEDURE pc_busca_aprovadores(pr_cdcooper           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                            ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
																,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
																,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
																,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
																,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
																,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
																,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
																) IS
    /* .............................................................................

    Programa: pc_busca_aprovadores
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 17/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os aprovadores cadastrados para a alcada de aprovacao e cooperativa informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar os aprovadores
		CURSOR cr_aprovadores(pr_cdcooper           tbrecip_param_aprovador.cdcooper%TYPE
		                     ,pr_cdalcada_aprovacao tbrecip_param_aprovador.cdalcada_aprovacao%TYPE
		                     ) IS
      SELECT tpa.cdaprovador
			      ,crapope.nmoperad
				FROM tbrecip_param_aprovador tpa
				    ,crapope
			 WHERE tpa.cdcooper           = crapope.cdcooper
			   AND tpa.cdaprovador        = crapope.cdoperad
				 AND tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao
				 AND tpa.cdcooper           =	pr_cdcooper;
		
		rw_aprovadores cr_aprovadores%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_qtregistros NUMBER;
		vr_tab_dominios gene0010.typ_tab_dominio;
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_aprovadores(pr_cdcooper
											 ,pr_cdalcada_aprovacao
											 );
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_aprovadores INTO rw_aprovadores;
			EXIT WHEN cr_aprovadores%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdaprovador>'   || rw_aprovadores.cdaprovador   ||'</cdaprovador>'   ||
												'<nmaprovador>'    || rw_aprovadores.nmoperad    ||'</nmaprovador>'    ||
										 '</inf>');
			--
		END LOOP;
		--
		IF cr_aprovadores%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		/* -- Comentado para não gerar erro na tela
		ELSE
			--
			vr_dscritic := 'Nenhum aprovador encontrado para a cooperativa e alçada informados: ' || pr_cdcooper || ' - ' || pr_cdalcada_aprovacao;
      RAISE vr_exc_erro;
			-- */
		END IF;
		--
		CLOSE cr_aprovadores;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_aprovadores;
	--
	PROCEDURE pc_busca_operadores(pr_cdcooper IN  crapope.cdcooper%TYPE -- Identificador da cooperativa
		                           ,pr_cdoperad IN  crapope.cdoperad%TYPE -- Código do operador
															 ,pr_nmoperad IN  crapope.nmoperad%TYPE -- Nome do operador
															 ,pr_xmllog   IN  VARCHAR2              -- XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype     -- Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2              -- Erros do processo
															 ) IS
    /* .............................................................................

    Programa: pc_busca_operadores
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 17/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os operadores cadastrados para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Busca o(s) operador(es)
		CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
		                 ,pr_cdoperad crapope.cdoperad%TYPE
										 ,pr_nmoperad crapope.nmoperad%TYPE
		                 ) IS
				SELECT crapope.cdoperad
							,crapope.nmoperad
					FROM crapope
				 WHERE crapope.cdsitope = 1
					 AND crapope.cdcooper = pr_cdcooper
					 AND (TRIM(pr_cdoperad) IS NULL 
									 OR UPPER(crapope.cdoperad) = UPPER(pr_cdoperad))
					 AND (TRIM(pr_nmoperad) IS NULL
										OR UPPER(crapope.nmoperad) LIKE '%' || UPPER(pr_nmoperad) || '%');
    --
    rw_crapope cr_crapope%ROWTYPE;

		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_qtregistros NUMBER;
		vr_tab_dominios gene0010.typ_tab_dominio;
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_crapope(pr_cdcooper
									 ,pr_cdoperad
									 ,pr_nmoperad
									 );
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_crapope INTO rw_crapope;
			EXIT WHEN cr_crapope%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdoperad>' || rw_crapope.cdoperad ||'</cdoperad>' ||
												'<nmoperad>' || rw_crapope.nmoperad ||'</nmoperad>' ||
										 '</inf>');
			--
		END LOOP;
		--
		IF cr_crapope%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		/* -- Comentado para não gerar erro na tela
		ELSE
			--
			vr_dscritic := 'Nenhum operador ativo encontrado para a cooperativa informada: ' || pr_cdcooper;
      RAISE vr_exc_erro;
			--*/
		END IF;
		--
		CLOSE cr_crapope;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_operadores;
	--
END TELA_CADRES;
/
