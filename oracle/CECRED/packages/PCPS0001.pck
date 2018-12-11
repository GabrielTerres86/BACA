CREATE OR REPLACE PACKAGE CECRED.PCPS0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0001
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/

    PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE --> Nr. da Conta
														  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
														  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
														  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
														  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2); --> Erros do processo
															
    PROCEDURE pc_valida_conta_salario (pr_cdcooper     IN crapttl.cdcooper%TYPE
				                              ,pr_nrdconta     IN crapttl.nrdconta%TYPE
                                      ,pr_dscritic     OUT crapcri.dscritic%TYPE); --> Descricao Erro
																			
    PROCEDURE pc_valida_emp_conta_salario (pr_cdcooper     IN crapttl.cdcooper%TYPE
																					,pr_nrdconta     IN crapttl.nrdconta%TYPE
																					,pr_nrdocnpj     IN crapemp.nrdocnpj%TYPE DEFAULT NULL
																					,pr_cdempres     IN crapemp.cdempres%TYPE
																					,pr_dscritic     OUT crapcri.dscritic%TYPE);

    PROCEDURE pc_incluir_pacote_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
																			 ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
																			 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																			 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
																			 ,pr_dscritic        OUT VARCHAR2);              --> Descrição da crítica																					
																			 
    PROCEDURE pc_desativar_pacote_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
		                                     ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
																				 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																				 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
																				 ,pr_dscritic        OUT VARCHAR2);						   --> Descrição da crítica
																				 
    PROCEDURE pc_remove_digidoc_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
																			 ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
																			 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																			 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
																			 ,pr_dscritic        OUT VARCHAR2);              --> Descrição da crítica
																			 
    PROCEDURE pc_valida_transf_conta_salario (pr_cdcooper        IN crapcop.cdcooper%TYPE   --> Código da cooperativa
																						 ,pr_nrdconta        IN crapass.nrdconta%TYPE   --> Nr da conta
																						 ,pr_cdageban        IN crapcti.cdageban%TYPE   --> codigo da agencia bancaria.
																						 ,pr_nrctatrf        IN VARCHAR2                --> conta que recebe a transferencia.
																						 ,pr_des_erro        OUT VARCHAR2               --> Houve critica?
																						 ,pr_dscritic        OUT VARCHAR2);             --> Descrição da crítica
  

END PCPS0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0001 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0001
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
   PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE --> Nr. da Conta
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
        
            Programa: pc_busca_dominio
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Outubro/2018                 Ultima atualizacao: 03/10/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retorna os valores do dominio
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;


        CURSOR cr_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE) IS
              SELECT tdc.cddominio
                    ,tdc.dscodigo
                FROM tbcc_dominio_campo tdc
               WHERE tdc.nmdominio = pr_nmdominio;
        rw_dominio cr_dominio%ROWTYPE;
    
    BEGIN
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        FOR rw_dominio IN cr_dominio(pr_nmdominio) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dominio'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
                            
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'cddominio'
                                ,pr_tag_cont => rw_dominio.cddominio
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dscodigo'
                                ,pr_tag_cont => rw_dominio.dscodigo
                                ,pr_des_erro => vr_dscritic);                                                        
        
          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure PCPS0001.pc_busca_dominio. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');        
    END pc_busca_dominio;
		
		PROCEDURE pc_valida_conta_salario (pr_cdcooper     IN crapttl.cdcooper%TYPE
				                              ,pr_nrdconta     IN crapttl.nrdconta%TYPE
			                                ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao Erro
			/* .............................................................................
        
            Programa: pc_valida_conta_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Outubro/2018                 Ultima atualizacao: 29/10/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Valida se o empregador da nova conta salário não é o mesmo de uma conta salário
						já existente para o cooperado em outra cooperativa.
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
				
				-- Cursor das contas do CPF
				CURSOR cr_contas(pr_nrcpfcgc crapass.nrcpfcgc%TYPE
				                ,pr_cdcooper crapass.cdcooper%TYPE
				                ,pr_nrdconta crapass.nrdconta%TYPE
												,pr_nrcpfemp crapttl.nrcpfemp%TYPE) IS
				      SELECT 1
								FROM crapass ass
										,tbcc_tipo_conta ttc
										,crapttl ttl
							 WHERE ass.cdtipcta = ttc.cdtipo_conta
								 AND ass.inpessoa = ttc.inpessoa
								 AND ass.nrcpfcgc = pr_nrcpfcgc
								 AND ass.nrdconta = ttl.nrdconta
								 AND ass.cdcooper = ttl.cdcooper
								 AND ass.dtdemiss IS NULL
								 AND ass.cdcooper = pr_cdcooper
								 AND ass.nrdconta <> pr_nrdconta
								 AND ttc.cdmodalidade_tipo = 2
								 AND ttl.nrcpfemp = pr_nrcpfemp
								 AND ttl.idseqttl = 1;
				rw_contas cr_contas%ROWTYPE;
				
				-- Cursor dos empregadores
				CURSOR cr_empregadores(pr_cdcooper crapttl.cdcooper%TYPE
				                      ,pr_nrdconta crapttl.nrdconta%TYPE) IS
							SELECT ttl.nrcpfemp
							      ,ttl.nrcpfcgc
										,ttc.cdmodalidade_tipo
								FROM crapttl ttl
								    ,crapass ass
										,tbcc_tipo_conta ttc
							 WHERE ttl.cdcooper = pr_cdcooper
								 AND ttl.nrdconta = pr_nrdconta
								 AND ttl.idseqttl = 1
								 --AND ttl.nrcpfemp <> 0
								 AND ass.cdcooper = ttl.cdcooper
								 AND ass.nrdconta = ttl.nrdconta
								 AND ass.inpessoa = ttc.inpessoa
								 AND ass.cdtipcta = ttc.cdtipo_conta;
			  rw_empregadores cr_empregadores%ROWTYPE;

				-- Variaveis de critica
				vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
				
		BEGIN
			  --
				OPEN cr_empregadores(pr_cdcooper => pr_cdcooper
														,pr_nrdconta => pr_nrdconta);
				FETCH cr_empregadores INTO rw_empregadores;
				--
				IF cr_empregadores%NOTFOUND THEN
					CLOSE cr_empregadores;
					vr_dscritic := 'Registro na crapttl do cooperado nao localizado.';
					RAISE vr_exc_saida;
				END IF;
				--
				CLOSE cr_empregadores;
				--			
		    OPEN cr_contas(pr_nrcpfcgc => rw_empregadores.nrcpfcgc
											,pr_cdcooper => pr_cdcooper
											,pr_nrdconta => pr_nrdconta
											,pr_nrcpfemp => rw_empregadores.nrcpfemp);
				FETCH cr_contas INTO rw_contas;
				--
				IF cr_contas%FOUND THEN
					CLOSE cr_contas;
					vr_dscritic := 'CPF ja possui conta salario para este empregador.';
					RAISE vr_exc_saida;
				END IF;
				CLOSE cr_contas;
				--
		EXCEPTION
		    WHEN vr_exc_saida THEN
					pr_dscritic := vr_dscritic;
				WHEN OTHERS THEN
					pr_dscritic := 'Erro geral na rotina na procedure pc_valida_conta_salario. Erro: ' || SQLERRM;
			
		END pc_valida_conta_salario;
		
		PROCEDURE pc_valida_emp_conta_salario (pr_cdcooper     IN crapttl.cdcooper%TYPE
																					,pr_nrdconta     IN crapttl.nrdconta%TYPE
																					,pr_nrdocnpj     IN crapemp.nrdocnpj%TYPE DEFAULT NULL
																					,pr_cdempres     IN crapemp.cdempres%TYPE
																					,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao Erro
			/* .............................................................................
        
            Programa: pc_valida_emp_conta_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Outubro/2018                 Ultima atualizacao: 29/10/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Valida se o empregador da conta salário não é o mesmo de uma conta salário
						já existente para o cooperado em outra cooperativa.
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
				
				-- Cursor de cpf e modalidade 2
				CURSOR cr_modalidade(pr_cdcooper crapass.cdcooper%TYPE
				                    ,pr_nrdconta crapass.nrdconta%TYPE) IS
						  SELECT ass.nrcpfcgc
							  FROM crapass ass
								    ,tbcc_tipo_conta ttc
							 WHERE ass.cdcooper = pr_cdcooper
							   AND ass.nrdconta = pr_nrdconta
								 AND ass.cdtipcta = ttc.cdtipo_conta
								 AND ass.inpessoa = ttc.inpessoa
								 AND ttc.cdmodalidade_tipo = 2;
				
				-- Cursor da empresa
				CURSOR cr_empresa(pr_cdcooper crapemp.cdcooper%TYPE
				                 ,pr_cdempres crapemp.cdempres%TYPE) IS
				      SELECT emp.nrdocnpj
							  FROM crapemp emp
							 WHERE emp.cdcooper = pr_cdcooper
							   AND emp.cdempres = pr_cdempres;


        -- Cursor das contas do CPF
				CURSOR cr_contas(pr_nrcpfcgc crapass.nrcpfcgc%TYPE
				                ,pr_cdcooper crapass.cdcooper%TYPE
				                ,pr_nrdconta crapass.nrdconta%TYPE
												,pr_nrcpfemp crapttl.nrcpfemp%TYPE) IS
				      SELECT 1
								FROM crapass ass
										,tbcc_tipo_conta ttc
										,crapttl ttl
							 WHERE ass.cdtipcta = ttc.cdtipo_conta
								 AND ass.inpessoa = ttc.inpessoa
								 AND ass.nrcpfcgc = pr_nrcpfcgc
								 AND ass.nrdconta = ttl.nrdconta
								 AND ass.cdcooper = ttl.cdcooper
								 AND ass.dtdemiss IS NULL
								 AND ass.cdcooper = pr_cdcooper
								 AND ass.nrdconta <> pr_nrdconta
								 AND ttc.cdmodalidade_tipo = 2
								 AND ttl.nrcpfemp = pr_nrcpfemp
								 AND ttl.idseqttl = 1;
				rw_contas cr_contas%ROWTYPE;

				-- Variaveis de critica
				vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
				
				-- Variaveis internas
				vr_nrdocnpj crapemp.nrdocnpj%TYPE;
				vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
				
		BEGIN
		  --
		  OPEN cr_modalidade(pr_cdcooper => pr_cdcooper
			                  ,pr_nrdconta => pr_nrdconta);
			FETCH cr_modalidade INTO vr_nrcpfcgc;
			--
			IF cr_modalidade%NOTFOUND THEN
				RETURN;
			END IF;
			--
			CLOSE cr_modalidade;
		  --
			vr_nrdocnpj := pr_nrdocnpj;
			IF nvl(vr_nrdocnpj,0) = 0 THEN
				OPEN cr_empresa(pr_cdcooper => pr_cdcooper
				               ,pr_cdempres => pr_cdempres);
				FETCH cr_empresa INTO vr_nrdocnpj;
				--
				IF cr_empresa%NOTFOUND THEN
				  CLOSE cr_empresa;					
					vr_dscritic := 'Registro na crapemp nao localizado.';
					RAISE vr_exc_saida;
				END IF;
				-- 
				CLOSE cr_empresa;
			END IF;
			--
			OPEN cr_contas(pr_nrcpfcgc => vr_nrcpfcgc
				            ,pr_cdcooper => pr_cdcooper
				            ,pr_nrdconta => pr_nrdconta
										,pr_nrcpfemp => vr_nrdocnpj);
			FETCH cr_contas INTO rw_contas;
			--
			IF cr_contas%FOUND THEN
			   CLOSE cr_contas;
				 vr_dscritic := 'CPF ja possui conta salario para este empregador.';
				 RAISE vr_exc_saida;
			END IF;
			CLOSE cr_contas;
			--
		EXCEPTION
		    WHEN vr_exc_saida THEN
					pr_dscritic := vr_dscritic;
				WHEN OTHERS THEN
					pr_dscritic := 'Erro geral na rotina na procedure pc_valida_conta_salario. Erro: ' || SQLERRM;
			
		END pc_valida_emp_conta_salario;
		

  PROCEDURE pc_incluir_pacote_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
		                                 ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
																		 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																		 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
                                     ,pr_dscritic        OUT VARCHAR2) IS            --> Descrição da crítica
    /* .............................................................................
            Programa: pc_incluir_pacote_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Novembro/2018                 Ultima atualizacao: 20/11/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Incluir o pacote de tarifas conta salário à uma conta.
						          O pacote padrão para conta salário fica definido na crappco.
        
            Observacao: -----
        
            Alteracoes:
    ............................................................................. */

    -- Busca valor da tarifa
    CURSOR cr_vltarifa (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdpacote IN tbtarif_pacotes_coop.cdpacote%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
      SELECT to_char(fco.vltarifa, 'fm999g999g999g990d00') vltarifa
        FROM tbtarif_pacotes tpac
            ,tbtarif_pacotes_coop tcoop
            ,crapfco fco
            ,crapfvl fvl
       WHERE tcoop.cdcooper = pr_cdcooper
         AND tcoop.cdpacote = pr_cdpacote
         AND tcoop.flgsituacao = 1
         AND tcoop.dtinicio_vigencia <= pr_dtmvtolt
         AND tpac.cdpacote = tcoop.cdpacote
         AND tpac.tppessoa = pr_inpessoa
         AND fco.cdcooper = tcoop.cdcooper
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND fvl.cdtarifa = tpac.cdtarifa_lancamento;
    rw_vltarifa cr_vltarifa%ROWTYPE;

    -- Busca tipo de pessoa
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
		
		-- Buscar parametro de pacote de tarifas para contas salario
		CURSOR cr_crappco IS
		  SELECT p.dsconteu
			  FROM crappco p
			 WHERE p.cdcooper = 3
			   AND p.cdpartar = 65;
	  rw_crappco cr_crappco%ROWTYPE;
		
		-- Buscar se já não temos algum pacote ativo para o cooperado
		CURSOR cr_pct_vigente(pr_cdcooper IN crapcop.cdcooper%TYPE
		                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		  SELECT tcp.cdpacote
			  FROM tbtarif_contas_pacote tcp
			 WHERE tcp.cdcooper = pr_cdcooper
				 AND tcp.nrdconta = pr_nrdconta
				 AND tcp.flgsituacao = 1
				 AND tcp.dtcancelamento IS NULL;
		rw_pct_vigente cr_pct_vigente%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_existe_pacote      VARCHAR2(1);
    vr_dtinicio_vigencia  DATE;
    vr_dstransa           VARCHAR2(1000);
    vr_nrdrowid           ROWID;
    vr_flgfound           BOOLEAN;
		vr_cdpacote           tbtarif_pacotes_coop.cdpacote%TYPE;
		vr_dtdiadebito        INTEGER;
		vr_auxpacote          GENE0002.typ_split;

    --Controle de erro
    vr_exc_erro EXCEPTION;

    vr_tbtarif_pacotes TELA_ADEPAC.typ_tab_tbtarif_pacotes;

  BEGIN
    pr_des_erro := 'OK';
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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
		
		OPEN cr_crappco;
		FETCH cr_crappco INTO rw_crappco;
		IF cr_crappco%NOTFOUND THEN
			CLOSE cr_crappco;
			vr_dscritic := 'Parametro de pacote de tarifas para contas salario nao definido.';
			RAISE vr_exc_erro;
		END IF;
   	CLOSE cr_crappco;
		
		vr_auxpacote := gene0002.fn_quebra_string(nvl(rw_crappco.dsconteu, ''), ';');
		IF NOT vr_auxpacote.exists(1) OR NOT vr_auxpacote.exists(2) THEN
			vr_dscritic := 'Parametro de pacote de tarifas para contas salario cadastrado indevidamente.';
			RAISE vr_exc_erro;
		END IF;
			
		vr_cdpacote := vr_auxpacote(1);
		vr_dtdiadebito := vr_auxpacote(2);
		
		OPEN cr_pct_vigente(pr_cdcooper => pr_cdcooper
		                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_pct_vigente INTO rw_pct_vigente;

		IF cr_pct_vigente%FOUND THEN
			CLOSE cr_pct_vigente;
			IF rw_pct_vigente.cdpacote = vr_cdpacote THEN
				RETURN;
			ELSE
			  vr_dscritic := 'Conta possui pacote de serviços cooperativo ativo. Realizar cancelamento para prosseguir.';
			END IF;
			RAISE vr_exc_erro;
		END IF;
    CLOSE cr_pct_vigente;

    -- Pega o primeiro dia do proximo mes
    vr_dtinicio_vigencia := to_date('01/' || to_char(rw_crapdat.dtultdia + 8, 'MM/RRRR'), 'DD/MM/RRRR');

    -- Busca tipo de pessoa
    OPEN cr_crapass (pr_cdcooper,pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    vr_flgfound := cr_crapass%FOUND;
    CLOSE cr_crapass;

    -- Buscar valor da tarifa
    IF vr_flgfound THEN
      OPEN cr_vltarifa (pr_cdcooper => pr_cdcooper
                       ,pr_cdpacote => vr_cdpacote
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_inpessoa => rw_crapass.inpessoa);
      FETCH cr_vltarifa INTO rw_vltarifa;
      vr_flgfound := cr_vltarifa%FOUND;
      CLOSE cr_vltarifa;
      IF NOT vr_flgfound THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor da tarifa não encontrado';
        RAISE vr_exc_erro;
      END IF;
    ELSE
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;

    vr_dstransa := 'Adesão serviços cooperativos de conta salário';

    --Insere novo pacote
    BEGIN
      INSERT INTO tbtarif_contas_pacote (cdcooper
                                        ,nrdconta
                                        ,cdpacote
                                        ,dtadesao
                                        ,dtinicio_vigencia
                                        ,nrdiadebito
                                        ,indorigem
                                        ,flgsituacao
                                        ,perdesconto_manual
                                        ,qtdmeses_desconto
                                        ,cdreciprocidade
                                        ,cdoperador_adesao
                                        ,dtcancelamento)
                                VALUES (pr_cdcooper
                                       ,pr_nrdconta
                                       ,vr_cdpacote
                                       ,rw_crapdat.dtmvtolt
                                       ,vr_dtinicio_vigencia
                                       ,vr_dtdiadebito
                                       ,1 -- Ayllos
                                       ,1 -- Ativo
                                       ,0
                                       ,0
                                       ,0
                                       ,pr_cdoperad
                                       ,NULL);
    EXCEPTION
			WHEN dup_val_on_index THEN
				 UPDATE tbtarif_contas_pacote
					 SET flgsituacao = 1
							,dtcancelamento = NULL
							,dtadesao = rw_crapdat.dtmvtolt
              ,dtinicio_vigencia = vr_dtinicio_vigencia
							,cdoperador_adesao = pr_cdoperad
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND cdpacote = vr_cdpacote;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir novo servico cooperativo. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(5) -- Aimaro WEB
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'CONTAS'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Codigo do servico'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => vr_cdpacote);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => rw_vltarifa.vltarifa);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Dia do debito'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => vr_dtdiadebito);
    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Inicio da vigencia'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => to_char(vr_dtinicio_vigencia,'DD/MM/RRRR'));

    -- Efetua commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
			
			pr_dscritic := vr_dscritic;
			ROLLBACK;

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      -- Erro
      pr_dscritic := 'Erro na PCPS0001.PC_INCLUIR_PACOTE_SALARIO: ' || SQLERRM;
			ROLLBACK;

  END pc_incluir_pacote_salario;
	
	PROCEDURE pc_desativar_pacote_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
		                                   ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
																			 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																			 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
																			 ,pr_dscritic        OUT VARCHAR2) IS            --> Descrição da crítica
    /* .............................................................................
            Programa: pc_desativar_pacote_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Novembro/2018                 Ultima atualizacao: 21/11/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Desativar o pacote de tarifas conta salário de uma conta.
						          O pacote padrão para conta salário fica definido na crappco.
        
            Observacao: -----
        
            Alteracoes:
    ............................................................................. */
	
	-- Buscar parametro de pacote de tarifas para contas salario
	CURSOR cr_crappco IS
		SELECT p.dsconteu
			FROM crappco p
		 WHERE p.cdcooper = 3
			 AND p.cdpartar = 64;
	rw_crappco cr_crappco%ROWTYPE;
		
	-- Buscar se já não temos algum pacote ativo para o cooperado
	CURSOR cr_pct_vigente(pr_cdcooper IN crapcop.cdcooper%TYPE
											 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		SELECT tcp.cdpacote
			FROM tbtarif_contas_pacote tcp
		 WHERE tcp.cdcooper = pr_cdcooper
			 AND tcp.nrdconta = pr_nrdconta
			 AND tcp.flgsituacao = 1
			 AND tcp.dtcancelamento IS NULL;
	rw_pct_vigente cr_pct_vigente%ROWTYPE;
	
	-- Cursor genérico de calendário
	rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

	--- VARIAVEIS ---
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic crapcri.dscritic%TYPE;
	
	-- Variaveis auxiliares
	vr_existe_pacote      BOOLEAN := FALSE;
	vr_cdpacote           tbtarif_pacotes_coop.cdpacote%TYPE;
	vr_auxpacote          GENE0002.typ_split;
  vr_dstransa           VARCHAR2(1000);
  vr_nrdrowid           ROWID;
	
	--Controle de erro
	vr_exc_erro EXCEPTION;
	
	BEGIN
		pr_des_erro := 'OK';
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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
		
		OPEN cr_crappco;
		FETCH cr_crappco INTO rw_crappco;
		IF cr_crappco%NOTFOUND THEN
			CLOSE cr_crappco;
			vr_dscritic := 'Parametro de pacote de tarifas para contas salario nao definido.';
			RAISE vr_exc_erro;
		END IF;
   	CLOSE cr_crappco;
		
		vr_auxpacote := gene0002.fn_quebra_string(nvl(rw_crappco.dsconteu, ''), ';');
		IF NOT vr_auxpacote.exists(1) OR NOT vr_auxpacote.exists(2) THEN
			vr_dscritic := 'Parametro de pacote de tarifas para contas salario cadastrado indevidamente.';
			RAISE vr_exc_erro;
		END IF;
			
		vr_cdpacote := vr_auxpacote(1);
		
		OPEN cr_pct_vigente(pr_cdcooper => pr_cdcooper
		                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_pct_vigente INTO rw_pct_vigente;
		
		IF cr_pct_vigente%FOUND THEN
			IF nvl(rw_pct_vigente.cdpacote, 0) = vr_cdpacote THEN
         vr_existe_pacote := TRUE;
			END IF;
		END IF;
    CLOSE cr_pct_vigente;
		
		IF vr_existe_pacote THEN
			BEGIN
				UPDATE tbtarif_contas_pacote
					 SET flgsituacao = 0
							,dtcancelamento = rw_crapdat.dtmvtolt
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND cdpacote = vr_cdpacote;
			EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao desativar servico cooperativo. ' || SQLERRM;
        RAISE vr_exc_erro;
      END;
		END IF;
		
    vr_dstransa := 'Cancelamento serviços cooperativos de conta salário';
		
		-- Gerar informacoes do log
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => GENE0001.vr_vet_des_origens(5) -- Aimaro WEB
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'CONTAS'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Gerar informacoes do item
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Codigo do servico'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => vr_cdpacote);

    -- Efetua commit
    COMMIT;
		
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
			
			pr_dscritic := vr_dscritic;
			ROLLBACK;

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      -- Erro
      pr_dscritic := 'Erro na PCPS0001.PC_DESATIVAR_PACOTE_SALARIO: ' || SQLERRM;
			ROLLBACK;

	END;
	
	PROCEDURE pc_remove_digidoc_salario(pr_cdcooper        IN  crapcop.cdcooper%TYPE   --> Código da cooperativa
		                                 ,pr_nrdconta        IN  crapass.nrdconta%TYPE   --> Nr da conta
											  						 ,pr_cdoperad        IN  crapope.cdoperad%TYPE   --> Operador
																		 ,pr_des_erro        OUT VARCHAR2                --> Houve critica?
																		 ,pr_dscritic        OUT VARCHAR2) IS            --> Descrição da crítica
																		 
    /* .............................................................................
            Programa: pc_remove_digidoc_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Novembro/2018                 Ultima atualizacao: 26/11/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Remover pendencias DIGIDOC que não sejam identificação e endereço.
						          Usado especialmente para casos de conta salário.

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */
  
	
		--- VARIAVEIS ---
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic crapcri.dscritic%TYPE;
	
	--Controle de erro
	vr_exc_erro EXCEPTION;
	
	
	BEGIN

		BEGIN
			DELETE FROM crapdoc 
      WHERE cdcooper = pr_cdcooper
			  AND nrdconta = pr_nrdconta  
				AND dtbxapen IS NULL 
				AND flgdigit = 1 
				AND tpdocmto NOT IN (2,3);
		EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao remover pendencia digidoc. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
 
   -- Efetua commit		
		COMMIT;
		
  EXCEPTION
		WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
			
			pr_dscritic := vr_dscritic;
			ROLLBACK;

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      -- Erro
      pr_dscritic := 'Erro na PCPS0001.PC_REMOVE_DIGIDOC_SALARIO: ' || SQLERRM;
			ROLLBACK;
  END;
	
	
	PROCEDURE pc_valida_transf_conta_salario (pr_cdcooper        IN crapcop.cdcooper%TYPE   --> Código da cooperativa
																					 ,pr_nrdconta        IN crapass.nrdconta%TYPE   --> Nr da conta
																					 ,pr_cdageban        IN crapcti.cdageban%TYPE   --> codigo da agencia bancaria.
                                           ,pr_nrctatrf        IN VARCHAR2                --> conta que recebe a transferencia.
																					 ,pr_des_erro        OUT VARCHAR2               --> Houve critica?
																					 ,pr_dscritic        OUT VARCHAR2) IS           --> Descrição da crítica
																					 
    /* .............................................................................
            Programa: pc_valida_transf_conta_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Novembro/2018                 Ultima atualizacao: 26/11/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Validar se determinanada conta salário pode ou nao receber transferencias
						          de determinada conta. Usado para garantir que apenas o empregador fará
											transferencias para a conta salario.

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */																					 

	-- Buscar primeiro titular
	CURSOR cr_crapttl (pr_cdcooper crapass.cdcooper%TYPE
										,pr_nrdconta crapass.nrdconta%TYPE) IS
			SELECT t.nrcpfemp
				FROM crapttl t
			 WHERE t.cdcooper = pr_cdcooper
				 AND t.nrdconta = pr_nrdconta
				 AND t.idseqttl = 1;
	rw_crapttl cr_crapttl%ROWTYPE;
	
	-- Buscar associado
	CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%TYPE
										,pr_cdcooper crapass.cdcooper%TYPE) IS
		  SELECT a.nrcpfcgc
			      ,a.inpessoa
			      ,a.cdtipcta
				FROM crapass a
			 WHERE a.cdcooper = pr_cdcooper
			   AND a.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
	
	-- Variaveis
	vr_cdcopctl  crapcop.cdcooper%TYPE;
	vr_cdmodali  INTEGER;
	
	-- Variaveis de critica
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic crapcri.dscritic%TYPE;
	vr_des_erro VARCHAR2(1000);
	
	--Controle de erro
	vr_exc_erro EXCEPTION;
  
	BEGIN
	  pr_des_erro := 'OK';

		BEGIN
			SELECT cdcooper INTO vr_cdcopctl FROM crapcop WHERE crapcop.cdagectl = pr_cdageban;
		EXCEPTION
			WHEN OTHERS THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Problema ao encontrar agencia destino';
				RAISE vr_exc_erro;  
		END;
		
		-- Buscamos o destinatario
		OPEN cr_crapass (pr_cdcooper => vr_cdcopctl
		                ,pr_nrdconta => pr_nrctatrf);
	  FETCH cr_crapass INTO rw_crapass;
		--
		IF cr_crapass%NOTFOUND THEN
			CLOSE	cr_crapass;
			vr_cdcritic := 0;
			vr_dscritic := 'Destinatario nao localizado';
			RAISE vr_exc_erro;
		END IF;
		--
    CLOSE	cr_crapass;

		cada0006.pc_busca_modalidade_tipo(pr_inpessoa => rw_crapass.inpessoa
		                                 ,pr_cdtipo_conta => rw_crapass.cdtipcta
																		 ,pr_cdmodalidade_tipo => vr_cdmodali
																		 ,pr_des_erro => vr_des_erro
																		 ,pr_dscritic => vr_dscritic);
																		 
    IF TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
		
		-- Caso o remetente não for uma conta salário, apenas ignoramos a validação.
		IF vr_cdmodali <> 2 THEN
			RETURN;
		END IF;
		
		-- Buscamos o remetente
		OPEN cr_crapass (pr_cdcooper => pr_cdcooper
		                ,pr_nrdconta => pr_nrdconta);
	  FETCH cr_crapass INTO rw_crapass;
		--
		IF cr_crapass%NOTFOUND THEN
			CLOSE	cr_crapass;
			vr_cdcritic := 0;
			vr_dscritic := 'Remetente nao localizado';
			RAISE vr_exc_erro;
		END IF;
		--
    CLOSE	cr_crapass;
		
		--
    OPEN cr_crapttl (pr_cdcooper => vr_cdcopctl
		                ,pr_nrdconta => pr_nrctatrf);
	  FETCH cr_crapttl INTO rw_crapttl;
		--
		IF cr_crapttl%FOUND THEN
			IF rw_crapass.nrcpfcgc <> rw_crapttl.nrcpfemp THEN
				CLOSE	cr_crapttl;
				vr_cdcritic := 0;
				vr_dscritic := 'Lancamento nao permitido para este tipo de conta.';
				RAISE vr_exc_erro;
			END IF;
		END IF;
		--
    CLOSE	cr_crapttl;
		
  EXCEPTION
		WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
			
			pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      -- Erro
      pr_dscritic := 'Erro na PCPS0001.PC_VALIDA_TRANSF_CONTA_SALARIO: ' || SQLERRM;
  END;

END PCPS0001;
/
