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

END PCPS0001;
/
