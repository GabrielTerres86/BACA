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
																						 
    PROCEDURE pc_deslig_conta_salario;

	  PROCEDURE pc_gerar_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da coop
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao do erro
                                   ,pr_dssrvarq OUT VARCHAR2 --> Nome do servidor onde o arquivo foi postado                                        
                                   ,pr_dsdirarq OUT VARCHAR2 --> Nome do diretório onde o arquivo foi postado
                                   );																					 
  
    /* Função para converter um arquivo em formato UTF8 em CLOB */
    FUNCTION fn_arq_utf_para_clob(pr_caminho IN VARCHAR2
                                 ,pr_arquivo IN VARCHAR2) RETURN CLOB;
                                 
    -- Procedure para realizar a verificação de portabilidade ativa e solicitar a transferencia de salário
    PROCEDURE pc_transf_salario_portab(pr_cdcooper  IN NUMBER        --> Código da cooperativa
                                      ,pr_nrdconta  IN NUMBER        --> Número da conta
                                      ,pr_nrridlfp  IN NUMBER        --> Indica o registro do lançamento de folha de pagamento
                                      ,pr_vltransf  IN NUMBER        --> Valor para transferencia
                                      ,pr_idportab OUT NUMBER        --> Retorna indicando que a conta possui portabilidade
                                      ,pr_cdcritic OUT NUMBER        --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2);    --> Texto de erro/critica encontrada
    
    -- Verificar se o cooperado possui portabilidade de salário habilitada
    FUNCTION fn_verifica_portabilidade (pr_cdcooper     IN crapttl.cdcooper%TYPE                    
				                               ,pr_nrdconta     IN crapttl.nrdconta%TYPE) RETURN BOOLEAN;
                                       
    -- Rotina para realizar a devolução do valor de TED estornado para o empregador
    PROCEDURE pc_estorno_rej_empregador(pr_nrridlfp    IN NUMBER
                                       ,pr_nrdocmto    IN NUMBER
                                       ,pr_dscritic   OUT VARCHAR2);

    -- Validar se o depósito está sendo feito numa conta salário ou não.
		PROCEDURE pc_valida_deposito_cta_sal(pr_cdcooper IN crapcop.cdcooper%TYPE --Código da cooperativa de origem
			                                  ,pr_cdcopdst IN crapcop.cdcooper%TYPE --Código da cooperativa de destino
                                        ,pr_nrctadst IN crapass.nrdconta%TYPE --Número da conta de destino do depósito 
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                        ,pr_cdagenci IN NUMBER
                                        ,pr_nrdcaixa IN NUMBER
                                        ,pr_cdorigem IN NUMBER   -- Código da origem
                                        ,pr_nmdatela IN VARCHAR2 -- Nome da tela 
                                        ,pr_nmprogra IN VARCHAR2 -- Nome do programa
                                        ,pr_cdoperad IN VARCHAR2 -- Código do operador
                                        ,pr_flgerlog IN NUMBER
                                        ,pr_flmobile IN NUMBER
                                        ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                        ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
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
	
  -- Variáveis Globais e constantes
  vr_dsarqlg         CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- Nome do arquivo de log mensal	
  vr_dsmasklog       CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
  
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
      pr_dscritic := 'Erro na PCPS0001.PC_INCLUIR_PACOTE_SALARIO: ' || SQLERRM;

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
	 
  PROCEDURE pc_gerar_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da coop
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao do erro
                                 ,pr_dssrvarq OUT VARCHAR2 --> Nome do servidor onde o arquivo foi postado                                        
                                 ,pr_dsdirarq OUT VARCHAR2 ) IS --> Nome do diretório onde o arquivo foi postado
    /* .............................................................................
    
    Programa: pc_imprimir_termo_portab
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Outubro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar os dados para o termo de portabilidade
    
    Alteracoes: Gilberto (Supero) Março/2019 - Incluir os campos de arquivo e diretorio
    ..............................................................................*/

  
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    --vr_tab_erro gene0001.typ_tab_erro;
    --vr_des_reto VARCHAR2(10);
  
    -- Variaveis
    vr_xml_temp    VARCHAR2(32726) := '';
    vr_clob        CLOB;
    vr_qtde_dias   VARCHAR2(200);
    vr_dsqtde_dias VARCHAR2(200);
		vr_nrtelefo    VARCHAR2(100);
  
    vr_nom_direto VARCHAR2(200); --> Diretório para gravação do arquivo
    vr_dsjasper   VARCHAR2(100); --> nome do jasper a ser usado
    vr_nmarqim    VARCHAR2(50); --> nome do arquivo PDF
  
    CURSOR cr_solicitacao(pr_dsrowid VARCHAR2) IS
      SELECT tpe.dtsolicitacao
            ,gene0002.fn_mask_conta(tpe.nrdconta) nrdconta
            ,gene0002.fn_mask_cpf_cnpj(tpe.nrcpfcgc, 1) nrcpfcgc
            ,'(' || lpad(tpe.nrddd_telefone, 2, '0') || ')' || tpe.nrtelefone telefone
            ,tpe.nmprimtl
            ,gene0002.fn_mask_cpf_cnpj(tpe.nrcnpj_empregador, 2) nrcnpj_empregador
            ,tpe.dsnome_empregador
            ,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
            ,tpe.nrispb_banco_folha
            ,gene0002.fn_mask_cpf_cnpj(tpe.nrcnpj_banco_folha, 2) nrcnpj_banco_folha
            ,dom.dscodigo tipo_conta
            ,tpe.dsdemail
            ,ope.nmoperad
            ,ope.cdagenci pa
            ,tpe.cdagencia
            ,prm.dsvlrprm img_cooperativa
            ,TO_CHAR(tpe.dtassina_eletronica, 'DD/MM/YYYY') dtassina_eletronica 
            ,TO_CHAR(tpe.dtassina_eletronica, 'HH24:MI:SS') hrassina_eletronica
            ,decode(tpe.dtassina_eletronica, '', 0, 1) isass_eletronica
        FROM tbcc_portabilidade_envia tpe
            ,crapban                  ban
            ,tbcc_dominio_campo       dom
            ,crapope                  ope
            ,crapprm                  prm
       WHERE tpe.nrispb_banco_folha = ban.nrispbif
         AND tpe.cdtipo_conta = dom.cddominio
         AND dom.nmdominio = 'TIPO_CONTA_PCPS'
         AND tpe.cdoperador = ope.cdoperad
         AND prm.cdacesso = 'IMG_LOGO_COOP'
         AND prm.cdcooper = tpe.cdcooper
         AND tpe.rowid = pr_dsrowid;

    rw_solicitacao cr_solicitacao%ROWTYPE;
  
    CURSOR cr_dias_comp IS
      SELECT o.dsconteu
        FROM crappco o
       WHERE o.cdpartar = 63
         AND o.cdcooper = 3;

    rw_dias_comp cr_dias_comp%ROWTYPE;
  
  BEGIN
  
    -- Abre o cursor de data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    -- Abre o cursor com os dados do termo
    OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid);
    FETCH cr_solicitacao
      INTO rw_solicitacao;
  
    IF cr_solicitacao%NOTFOUND THEN
      CLOSE cr_solicitacao;
      vr_dscritic := 'Solicitacao nao encontrada.';
      RAISE vr_exc_saida;
    END IF;

    CLOSE cr_solicitacao;
  
    -- Abre o cursor com a parametrização de dias para aceite compulsório
    OPEN cr_dias_comp;
    FETCH cr_dias_comp
      INTO rw_dias_comp;
  
    IF cr_dias_comp%NOTFOUND OR
       rw_dias_comp.dsconteu IS NULL THEN
      CLOSE cr_dias_comp;
      vr_dscritic := 'Parametro de dias para aceite compulsorio nao cadastrado.';
      RAISE vr_exc_saida;
    END IF;

    CLOSE cr_dias_comp;
  
    BEGIN
      vr_qtde_dias   := to_number(rw_dias_comp.dsconteu);
      vr_dsqtde_dias := gene0002.fn_valor_extenso(pr_idtipval => 'I', pr_valor => vr_qtde_dias);
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Parametro de dias para aceite compulsorio invalido.';
        RAISE vr_exc_saida;

    END;

  
    --busca diretorio padrao da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
  
    -- Monta documento XML de Dados
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
  
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><adesao>');
  
		vr_nrtelefo := rw_solicitacao.telefone;
		IF TRIM(NVL(vr_nrtelefo,'')) = '()' THEN
			 vr_nrtelefo := ' ';
		END IF;

		
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<qtde_dias>' || vr_qtde_dias || '</qtde_dias>' ||
                                                 '<dsqtde_dias>' || vr_dsqtde_dias ||
                                                 '</dsqtde_dias>' || '<dtsolicitacao>' ||
                                                 to_char(rw_solicitacao.dtsolicitacao, 'DD/MM/RRRR') ||
                                                 '</dtsolicitacao>' || '<nrdconta>' ||
                                                 rw_solicitacao.nrdconta || '</nrdconta>' ||
                                                 '<nrcpfcgc>' || rw_solicitacao.nrcpfcgc ||
                                                 '</nrcpfcgc>' || '<telefone>' ||
                                                 vr_nrtelefo || '</telefone>' ||
                                                 '<nmprimtl>' || rw_solicitacao.nmprimtl ||
                                                 '</nmprimtl>' || '<nrcnpj_empregador>' ||
                                                 rw_solicitacao.nrcnpj_empregador ||
                                                 '</nrcnpj_empregador>' || '<dsnome_empregador>' ||
                                                 rw_solicitacao.dsnome_empregador ||
                                                 '</dsnome_empregador>' || '<banco>' ||
                                                 rw_solicitacao.banco || '</banco>' ||
                                                 '<nrispb_banco_folha>' ||
                                                 rw_solicitacao.nrispb_banco_folha ||
                                                 '</nrispb_banco_folha>' || '<nrcnpj_banco_folha>' ||
                                                 rw_solicitacao.nrcnpj_banco_folha ||
                                                 '</nrcnpj_banco_folha>' || '<tipo_conta>' ||
                                                 rw_solicitacao.tipo_conta || '</tipo_conta>' ||
                                                 '<dsdemail>' || NVL(rw_solicitacao.dsdemail, ' ') ||
                                                 '</dsdemail>' || '<nmoperad>' ||
                                                 rw_solicitacao.nmoperad || '</nmoperad>' || '<pa>' ||
                                                 rw_solicitacao.pa || '</pa>' || '<cdagencia>' ||
                                                 rw_solicitacao.cdagencia || '</cdagencia>' ||
                                                 '<img_cooperativa>' ||
                                                 rw_solicitacao.img_cooperativa ||
                                                 '</img_cooperativa>' ||
                                                 '<dtassina_eletronica>' || 
                                                 rw_solicitacao.dtassina_eletronica ||
                                                 '</dtassina_eletronica>' ||
                                                 '<hrassina_eletronica>' || 
                                                 rw_solicitacao.hrassina_eletronica ||
                                                 '</hrassina_eletronica>' ||
                                                 '<isass_eletronica>' || rw_solicitacao.isass_eletronica || '</isass_eletronica>'
                                                 );
  
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</adesao>',
                            pr_fecha_xml      => TRUE);
  
    vr_dsjasper := 'termo_solicitacao_portabilidade.jasper';
    vr_nmarqim  := '/TermoAdesaoPortabilidade_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
  
    -- Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                                pr_cdprogra  => 'ATENDA',
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                pr_dsxml     => vr_clob,
                                pr_dsxmlnode => '/adesao',
                                pr_dsjasper  => vr_dsjasper,
                                pr_dsparams  => NULL,
                                pr_dsarqsaid => vr_nom_direto || vr_nmarqim,
                                pr_cdrelato  => 733,
                                pr_flg_gerar => 'S',
                                pr_qtcoluna  => 80,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'N',
                                pr_nmformul  => ' ',
                                pr_nrcopias  => 1,
                                pr_parser    => 'R',
                                pr_nrvergrl  => 1,
                                pr_des_erro  => vr_dscritic);
    -- Se houve retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
  
    pr_dssrvarq := vr_nmarqim;                                   
    pr_dsdirarq := vr_nom_direto;

    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em PCPS0001.pc_imprimir_termo_portab: ' || SQLERRM;
      ROLLBACK;

  END pc_gerar_termo_portab;

	PROCEDURE pc_inclui_impedimento_deslig(pr_cdcooper IN crapass.cdcooper%TYPE
		                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
		                                    ,pr_cdimpedi IN tbcc_imped_deslig_cta_sal.cdimpedimento%TYPE) IS
    /* .............................................................................
            Programa: pc_inclui_impedimento_deslig
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Janeiro/2019                 Ultima atualizacao: 14/01/2019
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Valida se há algum impedimento para desligamento da conta salário

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */
  
	-- Variaveis de critica
	vr_dscritic VARCHAR2(1000);
	vr_exc_erro EXCEPTION;
	
	BEGIN
		INSERT INTO tbcc_imped_deslig_cta_sal (cdcooper
		                                      ,nrdconta
																					,cdimpedimento
																					,dtimpedimento)
																	 VALUES (pr_cdcooper
																	        ,pr_nrdconta
																					,nvl(pr_cdimpedi,0)
																					,SYSDATE);
	EXCEPTION
		WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir impedimento de desligamento de conta salário. ' || SQLERRM;
        RAISE vr_exc_erro;
  END;																			
	
	PROCEDURE pc_gera_log_deslig_cta_sal(pr_nmdacao IN VARCHAR2
		                                  ,pr_dsmsglog IN VARCHAR2) IS
    /* .............................................................................
            Programa: pc_grava_imped_deslig_ctasal
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Janeiro/2019                 Ultima atualizacao: 14/01/2019
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Valida se há algum impedimento para desligamento da conta salário

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */																	 
	
	vr_dsmsglog VARCHAR2(1000);

	BEGIN
		vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
									 || 'PCPS0001.' || pr_nmdacao
									 || ' --> ' || pr_dsmsglog;
          
		-- Incluir log de execução.
		BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
															,pr_ind_tipo_log => 1
															,pr_des_log      => vr_dsmsglog
															,pr_nmarqlog     => vr_dsarqlg);
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;
	
	PROCEDURE pc_valida_deslig_cta_sal(pr_cdcooper IN crapass.cdcooper%TYPE
		                                ,pr_nrdconta IN crapass.nrdconta%TYPE
																		,pr_dtmvtolt IN BTCH0001.CR_CRAPDAT%ROWTYPE
																	  ,pr_flgimped OUT BOOLEAN) IS
    /* .............................................................................
            Programa: pc_valida_deslig_cta_sal
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Janeiro/2019                 Ultima atualizacao: 14/01/2019
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Valida se há algum impedimento para desligamento da conta salário

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */																	 
	
	-- Cursor para Limite de Crédito
	CURSOR cr_craplim(pr_cdcooper craplim.cdcooper%TYPE
		               ,pr_nrdconta craplim.nrdconta%TYPE) IS
			SELECT 1
			  FROM craplim lim
			 WHERE lim.cdcooper = pr_cdcooper
			   AND lim.nrdconta = pr_nrdconta
				 AND lim.tpctrlim = 1
				 AND lim.insitlim = 2;
	rw_craplim cr_craplim%ROWTYPE;
	
	-- Cursor para Convenio 
	CURSOR cr_crapatr(pr_cdcooper crapatr.cdcooper%TYPE
		               ,pr_nrdconta crapatr.nrdconta%TYPE) IS
			SELECT 1
			  FROM crapatr atr
			 WHERE atr.cdcooper = pr_cdcooper
			   AND atr.nrdconta = pr_nrdconta
				 AND atr.dtfimatr IS NULL;
	rw_crapatr cr_crapatr%ROWTYPE;
	
	-- Cursor para PAMCARD
	CURSOR cr_crappam(pr_cdcooper crappam.cdcooper%TYPE
		               ,pr_nrdconta crappam.nrdconta%TYPE) IS
			SELECT 1
			  FROM crappam pam
			 WHERE pam.cdcooper = pr_cdcooper
			   AND pam.nrdconta = pr_nrdconta
				 AND pam.flgpamca = 1;
	rw_crappam cr_crappam%ROWTYPE;
	
	-- Cursor para conta ITG
	CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
		               ,pr_nrdconta crapass.nrdconta%TYPE) IS
			SELECT 1
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta
				 AND ass.flgctitg = 2;
	rw_crapass cr_crapass%ROWTYPE;

  -- Cursor para CDC
	CURSOR cr_crapcdr(pr_cdcooper crapcdr.cdcooper%TYPE
		               ,pr_nrdconta crapcdr.nrdconta%TYPE) IS
			SELECT 1
			  FROM crapcdr cdr
			 WHERE cdr.cdcooper = pr_cdcooper
			   AND cdr.nrdconta = pr_nrdconta
				 AND cdr.flgconve = 1;
	rw_crapcdr cr_crapcdr%ROWTYPE;
	
	-- Cursor dos produtos a consistir
	CURSOR cr_produto IS
	    SELECT pro.cdproduto
			      ,DECODE(pro.cdproduto,  5, 13
						                     , 15, 14
																 , 16, 15
																 , 31, 16
																 , 36, 17
																 , 37, 18) cdimpedimento
			  FROM tbcc_produto pro
			 WHERE pro.cdproduto IN (5,15,16,31,36,37);
	rw_produto cr_produto%ROWTYPE;
	
	-- Cursor das folhas de cheque
	CURSOR cr_crapfdc(pr_cdcooper crapfdc.cdcooper%TYPE
		               ,pr_nrdconta crapfdc.nrdconta%TYPE) IS
			SELECT fdc.cdcooper
						,fdc.nrdconta
						,fdc.cdbanchq
						,fdc.cdagechq
						,fdc.nrctachq
						,fdc.nrcheque
				FROM crapfdc fdc
			 WHERE fdc.cdcooper = pr_cdcooper
				 AND fdc.nrdconta = pr_nrdconta
				 AND fdc.incheque = 0 
				 AND fdc.dtliqchq IS NULL
				 AND fdc.dtemschq IS NOT NULL
				 AND fdc.dtretchq IS NOT NULL;
	rw_cheque cr_crapfdc%ROWTYPE;
	
	-- Cursor das devoluções/saldo negativo
	CURSOR cr_crapneg(pr_cdcooper crapneg.cdcooper%TYPE
									 ,pr_nrdconta crapneg.nrdconta%TYPE
									 ,pr_cdbanchq crapneg.cdbanchq%TYPE
									 ,pr_cdagechq crapneg.cdagechq%TYPE
									 ,pr_nrctachq crapneg.nrctachq%TYPE
									 ,pr_nrcheque crapneg.nrdocmto%TYPE) IS
		  SELECT 1
			  FROM crapneg neg
			 WHERE neg.cdcooper = pr_cdcooper
				 AND neg.nrdconta = pr_nrdconta
				 AND neg.cdbanchq = pr_cdbanchq
				 AND neg.cdagechq = pr_cdagechq
				 AND neg.nrctachq = pr_nrctachq
				 AND SUBSTR(neg.nrdocmto,1,6) = pr_nrcheque
				 AND neg.cdhisest = 1;
	 rw_crapneg cr_crapneg%ROWTYPE;
	
	-- Cursor para Bordero
	CURSOR cr_crapcdb(pr_cdcooper crapfdc.cdcooper%TYPE
		               ,pr_nrdconta crapfdc.nrdconta%TYPE) IS
	    SELECT 1
			  FROM crapcdb cdb
			 WHERE cdb.cdcooper = pr_cdcooper
				 AND cdb.nrdconta = pr_nrdconta
				 AND cdb.insitchq = 2
				 AND cdb.dtlibera > pr_dtmvtolt.dtmvtolt;
	rw_crapcdb cr_crapcdb%ROWTYPE;
	
	-- Cursor para Bloqueto Cobrança
	CURSOR cr_crapceb(pr_cdcooper crapfdc.cdcooper%TYPE
		               ,pr_nrdconta crapfdc.nrdconta%TYPE) IS
	   SELECT 1
			 FROM crapceb ceb
		  WHERE ceb.cdcooper = pr_cdcooper
			  AND ceb.nrdconta = pr_nrdconta
			  AND ceb.insitceb = 1;
  rw_crapceb cr_crapceb%ROWTYPE; 
	
	-- Cursor do cartao de credito
	CURSOR cr_cartao(pr_cdcooper crawcrd.cdcooper%TYPE
		              ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
		SELECT 1
			FROM crawcrd 
		 WHERE crawcrd.cdcooper = pr_cdcooper
			 AND crawcrd.nrdconta = pr_nrdconta
			 AND (crawcrd.insitcrd = 4 OR crawcrd.insitcrd = 3 OR crawcrd.insitcrd = 7);
	rw_cartao cr_cartao%ROWTYPE;	
	
	-- Variaveis locais
	vr_percenir                NUMBER;
	vr_tab_craptab             APLI0001.typ_tab_ctablq;
	vr_tab_craplpp             APLI0001.typ_tab_craplpp;
	vr_tab_craplrg             APLI0001.typ_tab_craplpp;
	vr_tab_resgate             APLI0001.typ_tab_resgate;
	vr_tab_dados_rpp           APLI0001.typ_tab_dados_rpp;
	vr_tab_erro                GENE0001.typ_tab_erro;
	vr_tab_saldo_rdca          APLI0001.typ_tab_saldo_rdca;
	vr_tab_totais_futuros      EXTR0002.typ_tab_totais_futuros;
  vr_tab_lancamento_futuro   EXTR0002.typ_tab_lancamento_futuro;
	vr_des_reto                VARCHAR2(10);
	vr_vlsldrpp                NUMBER := 0;
  vr_retorno                 VARCHAR2(500);
	vr_vlsldapl                crapapl.vlaplica%TYPE;
	vr_vllautom                NUMBER   := 0;
	
	BEGIN
	  pr_flgimped := FALSE;	
		
		-- Limite de crédito
		OPEN cr_craplim(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_craplim INTO rw_craplim;
		
		IF cr_craplim%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 1);
		END IF;
		CLOSE cr_craplim;
		
		-- Convenio
		OPEN cr_crapatr(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapatr INTO rw_crapatr;
		
		IF cr_crapatr%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 2);
		END IF;
		CLOSE cr_crapatr;
		
		-- PAMCARD
		OPEN cr_crappam(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crappam INTO rw_crappam;
		
		IF cr_crappam%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 3);
		END IF;
		CLOSE cr_crappam;
		
		-- Conta ITG
		OPEN cr_crapass(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapass INTO rw_crapass;
		
		IF cr_crapass%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 4);
		END IF;
		CLOSE cr_crapass;
		
		-- CDC
		OPEN cr_crapcdr(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapcdr INTO rw_crapcdr;
		
		IF cr_crapcdr%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 5);
		END IF;
		CLOSE cr_crapcdr;
		
		-- Folhas de cheque
		OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper
		              ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapfdc INTO rw_cheque;
		
		IF cr_crapfdc%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 6);
		END IF;
		CLOSE cr_crapfdc;
		
		-- Bordero
		OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapcdb INTO rw_crapcdb;
		
		IF cr_crapcdb%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 7);
		END IF;
		CLOSE cr_crapcdb;
		
    -- Cartao Credito
		OPEN cr_cartao(pr_cdcooper => pr_cdcooper
		              ,pr_nrdconta => pr_nrdconta);
		FETCH cr_cartao INTO rw_cartao;
		
		IF cr_cartao%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => 8);
		END IF;
		CLOSE cr_cartao;
		
		-- Bloqueto Cobrança
		OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapceb INTO rw_crapceb;
		
		IF cr_crapceb%FOUND THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_cdimpedi => 9);
		END IF;
		CLOSE cr_crapceb;
		
    -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
    vr_percenir := GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                          ,pr_nmsistem => 'CRED'
                                                                          ,pr_tptabela => 'CONFIG'
                                                                          ,pr_cdempres => 0
                                                                          ,pr_cdacesso => 'PERCIRAPLI'
                                                                          ,pr_tpregist => 0));		

		-- Resgate Poupança Programada
		APLI0001.pc_consulta_poupanca(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 1
																 ,pr_nrdcaixa => 1
																 ,pr_cdoperad => '1'
																 ,pr_idorigem => 1
																 ,pr_nrdconta => pr_nrdconta
																 ,pr_idseqttl => 1
																 ,pr_nrctrrpp => 0
																 ,pr_dtmvtolt => pr_dtmvtolt.dtmvtolt
																 ,pr_dtmvtopr => pr_dtmvtolt.dtmvtopr
																 ,pr_inproces => pr_dtmvtolt.inproces
																 ,pr_cdprogra => 'PCPS0001'
																 ,pr_flgerlog => FALSE
																 ,pr_percenir => vr_percenir
																 ,pr_tab_craptab => vr_tab_craptab
																 ,pr_tab_craplpp => vr_tab_craplpp
																 ,pr_tab_craplrg => vr_tab_craplrg
																 ,pr_tab_resgate => vr_tab_resgate
																 ,pr_vlsldrpp => vr_vlsldrpp
																 ,pr_retorno => vr_retorno
																 ,pr_tab_dados_rpp => vr_tab_dados_rpp
																 ,pr_tab_erro => vr_tab_erro);
		IF vr_vlsldrpp > 0 THEN
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
														,pr_nrdconta => pr_nrdconta
														,pr_cdimpedi => 10);
		END IF;

		-- Aplicação
		APLI0002.pc_obtem_dados_aplicacoes(pr_cdcooper => pr_cdcooper
																		  ,pr_cdagenci => 1
																		  ,pr_nrdcaixa => 1
																		  ,pr_cdoperad => '1'
																		  ,pr_nmdatela => 'PCPS0001'
																		  ,pr_idorigem => 1
																		  ,pr_nrdconta => pr_nrdconta
																		  ,pr_idseqttl => 1
																		  ,pr_nraplica => 0
																		  ,pr_cdprogra => 'PCPS0001'
																		  ,pr_flgerlog => 0
																		  ,pr_dtiniper => NULL
																		  ,pr_dtfimper => NULL
																		  ,pr_vlsldapl => vr_vlsldapl
																		  ,pr_des_reto => vr_des_reto
																		  ,pr_tab_saldo_rdca => vr_tab_saldo_rdca
																		  ,pr_tab_erro => vr_tab_erro);
																			
    IF vr_vlsldapl > 0 THEN
			pr_flgimped := TRUE;
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_cdimpedi => 11);
		END IF;																			

		-- Limpamos a tabela
		vr_tab_totais_futuros.delete;

    -- Lançamento Futuro
		EXTR0002.pc_consulta_lancamento(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 1
																	 ,pr_cdoperad => '1'
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_idorigem => 1
																	 ,pr_idseqttl => 1
																	 ,pr_nmdatela => 'PCPS0001'
																	 ,pr_flgerlog => FALSE
																	 ,pr_dtiniper => NULL
																	 ,pr_dtfimper => NULL
																	 ,pr_indebcre => ''
																	 ,pr_des_reto => vr_des_reto
																	 ,pr_tab_erro => vr_tab_erro
																	 ,pr_tab_totais_futuros => vr_tab_totais_futuros
																	 ,pr_tab_lancamento_futuro => vr_tab_lancamento_futuro);
																	 
    --> Extrair valor
    IF vr_tab_totais_futuros.exists(vr_tab_totais_futuros.first) THEN      
			pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_cdimpedi => 12);
    END IF;																	 

		FOR rw_produto IN cr_produto LOOP
			IF cada0003.fn_produto_habilitado(pr_cdcooper => pr_cdcooper
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_cdproduto => rw_produto.cdproduto) = 'S' THEN
			  pr_flgimped := TRUE;
				pc_inclui_impedimento_deslig(pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_cdimpedi => rw_produto.cdimpedimento);
		  END IF;
		END LOOP;
	END;
	
	PROCEDURE pc_deslig_conta_salario IS
																					 
    /* .............................................................................
            Programa: pc_deslig_conta_salario
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Janeiro/2019                 Ultima atualizacao: 11/01/2019
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Desliga uma conta salario, contanto q nao tenha impedimento

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */
		
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
		      ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.flgativo = 1;
		 
	-- Cursor para retornar os associados ativos que possuam conta salario e que
	-- não possuem movimentações a mais de 2 anos
	CURSOR cr_associados(pr_cdcooper tbcc_associados.cdcooper%TYPE) IS
    SELECT ass.nrdconta
		  FROM tbcc_associados tba
			    ,crapass ass
					,tbcc_tipo_conta ttc
		 WHERE tba.cdcooper = pr_cdcooper
		   AND tba.dtultimo_movto <= ADD_MONTHS(SYSDATE,-24)
			 AND tba.cdcooper = ass.cdcooper
			 AND tba.nrdconta = ass.nrdconta
			 AND ass.cdtipcta = ttc.cdtipo_conta
			 AND ass.inpessoa = ttc.inpessoa
			 AND ttc.cdmodalidade_tipo = 2
			 AND ass.dtdemiss IS NULL;
			 
  CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                   ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                   ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
    SELECT s.cdsitsnh
      FROM crapsnh s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.idseqttl = pr_idseqttl
       AND s.tpdsenha = 1
       AND (s.cdsitsnh = 1 
        OR  s.cdsitsnh = 2);
    rw_crapsnh cr_crapsnh%ROWTYPE;			 
			 
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;			 
			 
    -- Variáveis
    vr_vlcotlib NUMBER;
		vr_flgimped BOOLEAN;
		vr_tab_msg_confirma cada0003.typ_tab_msg_confirma;
		vr_tab_erro gene0001.typ_tab_erro;
    vr_dtdiautl DATE;
        
    -- Tratamento de erros
		vr_dscritic VARCHAR2(4000);
		vr_cdcritic NUMBER := 0;
		pr_nmdcampo VARCHAR2(400);
		vr_des_reto VARCHAR2(4000);
		vr_exec_erro EXCEPTION;

	BEGIN
		
		pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
														  ,pr_dsmsglog => 'INICIANDO PROCESSO DE DESLIGAMENTO DE CONTAS SALÁRIO SEM MOVIMENTO.' );

	
		-- Percorrer as cooperativas do cursor
		FOR rw_crapcop IN cr_crapcop LOOP

      -- Verifica se está rodando o job em um feriado
      vr_dtdiautl := gene0005.fn_valida_dia_util(pr_cdcooper  => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt  => TRUNC(SYSDATE) -- Data do dia
                                                ,pr_feriado   => TRUE );
      
      -- Se não for a mesma data indica que é feriado
      IF vr_dtdiautl <> TRUNC(SYSDATE) THEN
        -- Gera o log para a cooperativa
        pc_gera_log_deslig_cta_sal(pr_nmdacao  => 'pc_deslig_conta_salario'
														      ,pr_dsmsglog => 'COOPERATIVA '||rw_crapcop.cdcooper||' - '||rw_crapcop.nmrescop||', NÃO PROCESSOU DEVIDO A FERIADO REGISTRADO.' );
      
        -- Pula a cooperativa
        CONTINUE;
      END IF;
      
			-- Leitura do calendário da cooperativa
			OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
			FETCH btch0001.cr_crapdat INTO rw_crapdat;
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN
				-- Fechar o cursor pois efetuaremos raise
				CLOSE btch0001.cr_crapdat;
			ELSE
				-- Apenas fechar o cursor
				CLOSE btch0001.cr_crapdat;
			END IF;
			
			-- Limpamos todos os impedimentos da cooperativa para recriar os que ainda existem
			BEGIN
				DELETE
					FROM tbcc_imped_deslig_cta_sal
				 WHERE cdcooper = rw_crapcop.cdcooper;
      EXCEPTION
  		WHEN OTHERS THEN
        vr_dscritic := 'Erro ao remover impedimentos existentes. ' || SQLERRM;
				RAISE vr_exec_erro;
			END;

			FOR rw_associados IN cr_associados(rw_crapcop.cdcooper) LOOP
				--
				SAVEPOINT sessao_associado;	
				--
				vr_dscritic := NULL;
				--
			  pc_valida_deslig_cta_sal(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrdconta => rw_associados.nrdconta															 
															  ,pr_dtmvtolt => rw_crapdat
															  ,pr_flgimped => vr_flgimped);
				
			  -- Caso houve ao menos um impedimento vamos para a proxima conta
				IF vr_flgimped THEN
					continue;
				END IF;
				
				-- Chamar a rotina para buscar as cotas liberadas
        CADA0012.pc_retorna_cotas_liberada(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nrdconta => rw_associados.nrdconta
                                          ,pr_vldcotas => vr_vlcotlib
                                          ,pr_dscritic => vr_dscritic);
				IF TRIM(vr_dscritic) IS NOT NULL THEN
					pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
													          ,pr_dsmsglog => 'Não foi possível retornar as cotas do cooperado (' || rw_crapcop.cdcooper || '/' || rw_associados.nrdconta || '). ' || vr_dscritic);
          ROLLBACK TO sessao_associado;
					continue;
				END IF;															 

        -- Chamar a rotina de devolucao das cotas
				CADA0003.pc_gera_devolucao_capital(pr_cdcooper  => rw_crapcop.cdcooper
																					,pr_nrdconta  => rw_associados.nrdconta
																					,pr_vldcotas  => vr_vlcotlib                
																					,pr_formadev  => 1
																					,pr_qtdparce  => 1
																					,pr_datadevo  => rw_crapdat.dtmvtolt
																					,pr_mtdemiss  => 5
																					,pr_dtdemiss  => rw_crapdat.dtmvtolt
																					,pr_idorigem  => 1
																					,pr_cdoperad  => 0
																					,pr_nrdcaixa  => 0
																					,pr_nmdatela  => ''
																					,pr_cdagenci  => 0
																					,pr_oporigem   => 1
																					,pr_cdcritic  => vr_cdcritic
																					,pr_dscritic  => vr_dscritic
																					,pr_nmdcampo  => pr_nmdcampo
																					,pr_des_erro  => vr_des_reto);
																						 
																						 
				IF TRIM(vr_dscritic) IS NOT NULL THEN
           pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
													           ,pr_dsmsglog => 'Não foi possível devolver capital do cooperado (' || rw_crapcop.cdcooper || '/' || rw_associados.nrdconta || '). ' || vr_dscritic);
           ROLLBACK TO sessao_associado;
					 continue;																		
				END IF;																						 

        -- Buscamos a senha do associado
				OPEN cr_crapsnh(pr_cdcooper => rw_crapcop.cdcooper
											 ,pr_nrdconta => rw_associados.nrdconta 
											 ,pr_idseqttl => 1);
		                     
				FETCH cr_crapsnh INTO rw_crapsnh;
		    
				IF cr_crapsnh%NOTFOUND THEN
					--Fechar o cursor
					CLOSE cr_crapsnh;     
				ELSE
					--Fechar o cursor
					CLOSE cr_crapsnh;
		      
					-- Caso houver, realizamos o cancelamento
					CADA0003.pc_cancelar_senha_internet(pr_cdcooper => rw_crapcop.cdcooper
																						 ,pr_cdagenci => 0
																						 ,pr_nrdcaixa => 0
																						 ,pr_cdoperad => 0
																						 ,pr_nmdatela => ''
																						 ,pr_idorigem => 1
																						 ,pr_nrdconta => rw_associados.nrdconta
																						 ,pr_idseqttl => 1
																						 ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
																						 ,pr_inconfir => 3
																						 ,pr_flgerlog => 1
																						 ,pr_tab_msg_confirma => vr_tab_msg_confirma
																						 ,pr_tab_erro => vr_tab_erro
																						 ,pr_des_erro => vr_des_reto);
																						 
          --Se Ocorreu erro
          IF vr_des_reto <> 'OK' THEN						
					  --Se possuir erro na tabela
						IF vr_tab_erro.COUNT > 0 THEN
							vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;				        
						END IF;
						--Mensagem Erro
						vr_dscritic := 'Não foi possível cancelar senha do cooperado (' || rw_crapcop.cdcooper || '/' || rw_associados.nrdconta || '). ' || vr_dscritic;

						
						pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
													            ,pr_dsmsglog => vr_dscritic);
            ROLLBACK TO sessao_associado;
						continue;
					END IF;
					--
				END IF;
				
				pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
													        ,pr_dsmsglog => 'REALIZADO DESLIGAMENTO DA CONTA ' || gene0002.fn_mask_conta(rw_associados.nrdconta) || ' DA COOPERATIVA ' || rw_crapcop.nmrescop || '.' );
			
			END LOOP;
		 
		END LOOP;
		--
		pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
													    ,pr_dsmsglog => 'PROCESSO DE DESLIGAMENTO DE CONTAS SALÁRIO SEM MOVIMENTO FINALIZADO.' );
		--
		COMMIT;
		
  EXCEPTION
		WHEN vr_exec_erro THEN
				pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
				                          ,pr_dsmsglog => vr_dscritic);
        RAISE_APPLICATION_ERROR(-20001, vr_dscritic);
		WHEN OTHERS THEN
			  vr_dscritic := 'Erro na rotina: ' || SQLERRM;
				pc_gera_log_deslig_cta_sal(pr_nmdacao => 'pc_deslig_conta_salario'
				                          ,pr_dsmsglog => vr_dscritic);
        RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
	END pc_deslig_conta_salario;

  /* Função para converter um arquivo em formato UTF8 em CLOB */
  FUNCTION fn_arq_utf_para_clob(pr_caminho IN VARCHAR2
                               ,pr_arquivo IN VARCHAR2) RETURN CLOB IS
    /*..............................................................................

       Programa: fn_arq_utf_para_clob
       Autor   : Renato Darosci
       Data    : Fevereiro/2019                      Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Objetivo  : Criar um CLOB a partir do arquivo UTF8. Já existe uma rotina que 
                   faz a mesma coisa na GENE0002, porém ela trabalha com arquivos
                   US7ASCII de forma fixa e precisaremos trabalhar com UTF8 com os 
                   arquivos da CIP.

       Alteracoes: 
    ..............................................................................*/

    -- CLOB para saida
    vr_clob CLOB;
  BEGIN
	  -- Incluir nome do módulo logado 
		GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PCPS0001.fn_arq_utf_para_clob'); 
    
    -- Realiza a leitura do arquivo -->  NLS_CHARSET_NAME(871) = UTF8
    vr_clob := DBMS_XSLPROCESSOR.read2clob(pr_caminho, pr_arquivo, 871); 

    -- Alterado pc_set_modulo da procedure 
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

    RETURN vr_clob;
  END fn_arq_utf_para_clob;

  -- Procedure para realizar a verificação de portabilidade ativa e solicitar a transferencia de salário
  PROCEDURE pc_transf_salario_portab(pr_cdcooper  IN NUMBER        --> Código da cooperativa
                                    ,pr_nrdconta  IN NUMBER        --> Número da conta
                                    ,pr_nrridlfp  IN NUMBER        --> Indica o registro do lançamento de folha de pagamento
                                    ,pr_vltransf  IN NUMBER        --> Valor para transferencia
                                    ,pr_idportab OUT NUMBER        --> Retorna indicando que a conta possui portabilidade
                                    ,pr_cdcritic OUT NUMBER        --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS  --> Texto de erro/critica encontrada
    /*..............................................................................

       Programa: pc_transf_salario_portab
       Autor   : Renato Darosci
       Data    : Fevereiro/2019                      Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Objetivo  : Realizar a transferencia dos valores de salários através da 
                   portabilidade ativa na conta.

       Alteracoes: 
    ..............................................................................*/
    
    /******************************************************************************/
    -- A rotina será autonoma para reduzir impactos nas rotinas chamadoras, de forma
    -- que em caso de erro o programa chamador prossiga normalmente os créditos de 
    -- salário e com os logs os operadores ou o próprio cooperado possa estar 
    -- realizando a transferencia do valor.
    
    PRAGMA AUTONOMOUS_TRANSACTION;
    /******************************************************************************/
    
    -- Busca os dados do associado
    CURSOR cr_crapass IS 
      SELECT ass.cdtipcta
           , tip.cdmodalidade_tipo cdmodali
        FROM tbcc_tipo_conta  tip
           , crapass          ass
       WHERE tip.inpessoa     = ass.inpessoa
         AND tip.cdtipo_conta = ass.cdtipcta
         AND ass.cdcooper     = pr_cdcooper
         AND ass.nrdconta     = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;
    
    -- Buscar portabilidades ativas do cooperado
    CURSOR cr_portsal IS
      SELECT ban.cdbccxlt                cdbccxlt
           , rec.cdagencia_destinataria  cdagenci
           , rec.nrdconta_destinataria   nrdconta
           , rec.nmprimtl                nmprimtl
           , rec.nrcpfcgc                nrcpfcgc
           , rec.cdtipo_cta_destinataria intipcta
           , rec.nrispb_destinataria     nrispbdt
        FROM crapban                   ban
           , tbcc_portabilidade_recebe rec
       WHERE ban.nrcnpjif   = rec.nrcnpj_destinataria
         AND ban.nrispbif   = rec.nrispb_destinataria
         AND rec.idsituacao = 2 -- Aprovada
         AND rec.cdcooper   = pr_cdcooper
         AND rec.nrdconta   = pr_nrdconta
       ORDER BY rec.dtsolicitacao DESC;
    rw_portsal  cr_portsal%ROWTYPE;
    
    -- Variáveis
    vr_exc_erro    EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_hrlimpor    DATE;
    vr_cdhisdeb    NUMBER := 0;
    vr_intipcta    NUMBER;
    
    -- Retorno TED
    vr_dsprotoc    crappro.dsprotoc%TYPE;
    vr_tbprotoc    CXON0020.typ_tab_protocolo_ted;
    
    -- Retorno agendamento
    vr_idlancto   NUMBER; 
    vr_dstrans1   VARCHAR2(50);
    vr_msgofatr   VARCHAR2(100);
    vr_cdempcon   NUMBER;
    vr_cdsegmto   VARCHAR2(50);
    
    -- Procedure para a geração dos logs
    PROCEDURE pr_gerar_log_transf(pr_dsmsglog IN VARCHAR2) IS
      
      -- Variáveis
      vr_dsmsglog   VARCHAR2(500);
      vr_nrdrowid   VARCHAR2(100);
    
    BEGIN
      ----------
      BEGIN
        -- Mensagem de log para a VERLOG
        vr_dsmsglog := 'Erro transacao: '||pr_dsmsglog;
      
        -- Gerar log na verlog 
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => vr_dsmsglog
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dstransa => 'Transferencia de salario - Portabilidade'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'SOLPOR' --> Coloca o log como sendo a SOLPOR
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
			
      EXCEPTION
        WHEN OTHERS THEN
          -- QUALQUER ERRO EM LOGS DEVE SER DESPREZADO
          NULL;
      END;
      ----------
      BEGIN
        -- Gerar log no arquivo PCPS
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                     || 'PCPS0001.PC_TRANSF_SALARIO_PORTAB --> ' || pr_dsmsglog;
            
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      
      EXCEPTION
        WHEN OTHERS THEN
          -- QUALQUER ERRO EM LOGS DEVE SER DESPREZADO
          NULL;
      END;
      ----------
    END pr_gerar_log_transf;
    
  BEGIN
	  
    -- Informa o retorno como sendo uma conta sem portabilidade
    pr_idportab := 0; 
  
    -- Busca as informações do cooperado
    OPEN  cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    
    -- Se não encontrar registro
    IF cr_crapass%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapass;
      -- Erro de cooperado não encontrado
      vr_cdcritic := 9;
      -- Executa o raise
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapass;
    
    -- Buscar dados da CRAPDAT
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      -- Gerar excecao
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;
    
    -- Verifica se a conta não é modalidade de conta salário
    IF rw_crapass.cdmodali <> 2 THEN
      -- Não retornar nenhuma critica
      pr_cdcritic  := 0;
      pr_dscritic  := NULL;
      
      -- Realiza o Rolback da transação autonoma - Obrigatório em rotinas autonomas
      ROLLBACK;
      
      -- Deve sair da rotina sem realizar transferencia
      RETURN;
    END IF;
    
    -- Buscar portabilidade ativa por parte do cooperado
    OPEN  cr_portsal;
    FETCH cr_portsal INTO rw_portsal;
    
    -- Se não encontrar nenhum registro de portabilidade ativa
    IF cr_portsal%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_portsal;
      
      -- Não retornar nenhuma critica
      pr_cdcritic  := 0;
      pr_dscritic  := NULL;
      
      -- Realiza o Rolback da transação autonoma - Obrigatório em rotinas autonomas
      ROLLBACK;
      
      -- Deve sair da rotina sem realizar transferencia - Não possui portabilidade
      RETURN;
      
    END IF;
    
    -- Fechar cursor
    CLOSE cr_portsal;
    
    -- Busca do horário limite para a portabilidade
    BEGIN
      vr_hrlimpor := to_date(to_char(SYSDATE,'DD/MM/RRRR ') || gene0001.fn_param_sistema('CRED', pr_cdcooper, 'FOLHAIB_HOR_LIM_PORTAB'),'DD/MM/RRRR HH24:MI');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na leitura do parametro de hora limite de portabilidade: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- HISTÓRICO DE DÉBITO
    vr_cdhisdeb := 2944; -- NOSSA REMESSA TEC COMPE CECRED - CONTA SALARIO
    
    -- Se passou do horário do meio-dia
    IF vr_hrlimpor > SYSDATE THEN
      
      -- Tp. conta - Destinatário
      IF    rw_portsal.intipcta = 'CC' THEN -- Conta Corrente
        vr_intipcta := 1;
      ELSIF rw_portsal.intipcta = 'PP' THEN -- Poupança
        vr_intipcta := 2;
      ELSIF rw_portsal.intipcta = 'PG' THEN -- Conta de Pagamento
        vr_intipcta := 3;
      END IF;
    
      -- Deve realizar a TEC de Salário
      CXON0020.pc_executa_envio_ted
                          (pr_cdcooper => pr_cdcooper          --> Cooperativa
                          ,pr_cdagenci => 1                    --> Agencia
                          ,pr_nrdcaixa => 1                    --> Caixa Operador
                          ,pr_cdoperad => '1'                  --> Operador Autorizacao
                          ,pr_idorigem => 1                    --> Origem
                          ,pr_dtmvtolt => btch0001.rw_crapdat.dtmvtolt  --> Data do movimento
                          ,pr_nrdconta => pr_nrdconta          --> Conta Remetente
                          ,pr_idseqttl => 1                    --> Titular
                          ,pr_nrcpfope => 0                    --> CPF operador juridico
                          ,pr_cddbanco => rw_portsal.cdbccxlt  --> Banco destino
                          ,pr_cdageban => rw_portsal.cdagenci  --> Agencia destino
                          ,pr_nrctatrf => rw_portsal.nrdconta  --> Conta transferencia
                          ,pr_nmtitula => rw_portsal.nmprimtl  --> nome do titular destino
                          ,pr_nrcpfcgc => rw_portsal.nrcpfcgc  --> CPF do titular destino
                          ,pr_inpessoa => 1                    --> Tipo de pessoa - Portabilidade se aplica apenas a PF
                          ,pr_intipcta => vr_intipcta          --> Tipo de conta
                          ,pr_vllanmto => pr_vltransf          --> Valor do lançamento
                          ,pr_dstransf => ' '                  --> Identificacao Transf.
                          ,pr_cdfinali => 0                    --> Finalidade TED
                          ,pr_dshistor => ' '                  --> Descriçao do Histórico
                          ,pr_cdispbif => rw_portsal.nrispbdt  --> ISPB Banco Favorecido
                          ,pr_flmobile => 0                    --> Indicador se origem é do mobile
                          ,pr_idagenda => 1                    --> Tipo de agendamento
                          ,pr_iptransa => NULL                 --> IP da transacao no IBank/mobile
                          ,pr_dstransa => NULL                 --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos => 0                    --> Identificador do dispositivo movel 
                          ,pr_idportab => 1                    --> Indica que a TED é de transferencia de portabilidade
                          ,pr_nrridlfp => pr_nrridlfp          --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                          -- saida
                          ,pr_dsprotoc          => vr_dsprotoc  --> Retorna protocolo
                          ,pr_tab_protocolo_ted => vr_tbprotoc  --> dados do protocolo
                          ,pr_cdcritic          => vr_cdcritic  --> Codigo do erro
                          ,pr_dscritic          => vr_dscritic);--> Descricao do erro
      
      -- Se retornou crítica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    ELSE
    
      -- Realiza o agendamento da TEC de Salário
      PAGA0002.pc_cadastrar_agendamento
                                (pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                ,pr_cdagenci => 1              --> Codigo da agencia
                                ,pr_nrdcaixa => 1              --> Numero do caixa
                                ,pr_cdoperad => '1'            --> Codigo do operador
                                ,pr_nrdconta => pr_nrdconta    --> Numero da conta do cooperado
                                ,pr_idseqttl => 1              --> Sequencial do titular (conta salário deve ser individual
                                ,pr_dtmvtolt => btch0001.rw_crapdat.dtmvtolt  --> Data do movimento
                                ,pr_cdorigem => 1              --> Origem -> AYLLOS
                                ,pr_dsorigem => 'PORTABILIDAD' --> Descrição de origem do registro
                                ,pr_nmprogra => 'PCPS0001'     --> Nome do programa que chamou
                                ,pr_cdtiptra => 4              --> Tipo de transação - TED 
                                ,pr_idtpdpag => 0              --> Indicador de tipo de agendamento
                                ,pr_dscedent => ' '            --> Descrição do cedente
                                ,pr_dscodbar => ' '            --> Descrição codbarras
                                ,pr_lindigi1 => 0              --> 1° parte da linha digitavel
                                ,pr_lindigi2 => 0              --> 2° parte da linha digitavel
                                ,pr_lindigi3 => 0              --> 3° parte da linha digitavel
                                ,pr_lindigi4 => 0              --> 4° parte da linha digitavel
                                ,pr_lindigi5 => 0              --> 5° parte da linha digitavel
                                ,pr_cdhistor => vr_cdhisdeb    --> Codigo do historico
                                ,pr_dtmvtopg => btch0001.rw_crapdat.dtmvtopr  --> Data de pagamento -- AGENDA PARA O DIA SEGUINTE
                                ,pr_vllanaut => pr_vltransf    --> Valor do lancamento automatico
                                ,pr_dtvencto => NULL           --> Data de vencimento

                                ,pr_cddbanco => rw_portsal.cdbccxlt  --> Codigo do banco
                                ,pr_cdageban => rw_portsal.cdagenci  --> Codigo de agencia bancaria
                                ,pr_nrctadst => rw_portsal.nrdconta  --> Numero da conta destino

                                ,pr_cdcoptfn => 0              --> Codigo que identifica a cooperativa do cash.
                                ,pr_cdagetfn => 0              --> Numero do pac do cash.
                                ,pr_nrterfin => 0              --> Numero do terminal financeiro.

                                ,pr_nrcpfope => 0              --> Numero do cpf do operador juridico
                                ,pr_idtitdda => 0              --> Contem o identificador do titulo dda.
                                ,pr_cdtrapen => 0              --> Codigo da Transacao Pendente
                                ,pr_flmobile => 0              --> Indicador Mobile
                                ,pr_idtipcar => 0              --> Indicador Tipo Cartão Utilizado
                                ,pr_nrcartao => 0              --> Nr Cartao

                                ,pr_cdfinali => 0              --> Codigo de finalidade -> NÃO GRAVA PARA CDTIPTRA = 3
                                ,pr_dstransf => ' '            --> Descricao da transferencia -> NÃO GRAVA PARA CDTIPTRA = 3
                                ,pr_dshistor => ' '            --> Descricao da finalidade -> NÃO GRAVA PARA CDTIPTRA = 3
                                ,pr_iptransa => NULL           --> IP da transacao no IBank/mobile
                                ,pr_cdctrlcs => NULL           --> Código de controle de consulta CIP
                                ,pr_iddispos => NULL           --> Identificador do dispositivo movel 
                                ,pr_nrridlfp => pr_nrridlfp    --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                                /* parametros de saida */
                                ,pr_idlancto => vr_idlancto
                                ,pr_dstransa => vr_dstrans1    --> Descrição de transação
                                ,pr_msgofatr => vr_msgofatr
                                ,pr_cdempcon => vr_cdempcon
                                ,pr_cdsegmto => vr_cdsegmto
                                ,pr_dscritic => vr_dscritic);  --> Descricao critica
      
      -- Se retornou crítica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    
    -- Informa o retorno de portabilidade realizada
    pr_idportab := 1; 
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se a descrição da critica estiver em branco
      IF vr_dscritic IS NULL AND vr_cdcritic > 0 THEN 
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF; 
      
      -- Gerar os logs com a critica do processamento
      pr_gerar_log_transf(vr_dscritic);
      
      -- Retornar os erros
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Rollback para fechar a transação
      ROLLBACK;
    WHEN OTHERS THEN
      
      -- Crítica de processamento
      vr_dscritic := 'Erro na rotina PC_TRANSF_SALARIO_PORTAB: '||SQLERRM;
      
      -- Gerar os logs com a critica do processamento
      pr_gerar_log_transf(vr_dscritic);
      
      -- Retornar o erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      
      -- Rollback para fechar a transação
      ROLLBACK;
  END pc_transf_salario_portab;
  
  
  FUNCTION fn_verifica_portabilidade (pr_cdcooper     IN crapttl.cdcooper%TYPE                    
				                             ,pr_nrdconta     IN crapttl.nrdconta%TYPE) RETURN BOOLEAN IS 
	/* .............................................................................
       
    Programa: pc_verifica_portabilidade
    Sistema : CECRED
    Sigla   : CRD
    Autor   : Renato (Supero)
    Data    : Fevereiro/2019                 Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo: Valida se o cooperado possui portabilidade de salário ativa.
    
    Observacao: -----
    
    Alteracoes:
                15/07/2019 - Considerar também a modalidade do tipo de conta e não
                             somente a situação da solicitação de portabilidade, 
                             para realizar o envio de valores para outras IFs. 
                             (Renato Darosci - Supero)
  ..............................................................................*/
				
	  -- Buscar portabilidade aprovadas para o cooperado
		CURSOR cr_portabi IS
		  SELECT ptb.nrnu_portabilidade
				FROM tbcc_portabilidade_recebe ptb
			 WHERE ptb.cdcooper   = pr_cdcooper
         AND ptb.nrdconta   = pr_nrdconta
         AND ptb.idsituacao = 2 -- Aprovada
       ORDER BY ptb.dtsolicitacao DESC;
				rw_portabi cr_portabi%ROWTYPE;
				
    vr_dsmsglog  VARCHAR2(1000);
    vr_dssqlerr  VARCHAR2(1000);
    vr_cdmodali  NUMBER;
    vr_des_erro  VARCHAR2(1000);
    vr_dscritic  VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
	BEGIN
		
    -- Buscar a modalidade da conta
    CADA0006.pc_busca_modalidade_conta(pr_cdcooper          => pr_cdcooper
                                      ,pr_nrdconta          => pr_nrdconta
                                      ,pr_cdmodalidade_tipo => vr_cdmodali
                                      ,pr_des_erro          => vr_des_erro
                                      ,pr_dscritic          => vr_dscritic);
   
    -- Verificar erros na rotina
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Se não for da modalidade conta salário 
    IF NVL(vr_cdmodali,0) <> 2 THEN
      -- Retorna false indicando que não irá realizar transferencia de valores
      RETURN FALSE;
    END IF;
    
    -- Buscar as portabilidades
		OPEN  cr_portabi;
		FETCH cr_portabi INTO rw_portabi;
		
    -- Se não encontrou nenhuma portabilidade
		IF cr_portabi%NOTFOUND THEN
		  -- Fecha o cursor
      CLOSE cr_portabi;
      -- Retorna false indicando que não há portabilidade
      RETURN FALSE;
		END IF;
				
    -- Fecha o cursor
		CLOSE cr_portabi;
				
    -- Retorna TRUE, indicando que encontrou portabilidade ativa
		RETURN TRUE;
				
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Exception para tratamento pela rotina chamadora
			RAISE_APPLICATION_ERROR(-20001, 'Erro na rotin FN_VERIFICA_PORTABILIDADE: ' || vr_dscritic);
	  WHEN OTHERS THEN
      -- Guardar o erro
      vr_dssqlerr := SQLERRM;
      
      -- Montar a mensagem para o arquivo de log
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
									 || 'PCPS0001.FN_VERIFICA_PORTABILIDADE'  
									 || ' --> Erro na rotina: ' || vr_dssqlerr;
        
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 2
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);  
      
      -- Exception para tratamento pela rotina chamadora
			RAISE_APPLICATION_ERROR(-20000, 'Erro na rotin FN_VERIFICA_PORTABILIDADE: ' || vr_dssqlerr);
	END fn_verifica_portabilidade;


  -- Rotina para realizar a devolução do valor de TED estornado para o empregador
  PROCEDURE pc_estorno_rej_empregador(pr_nrridlfp    IN NUMBER
                                     ,pr_nrdocmto    IN NUMBER
                                     ,pr_dscritic   OUT VARCHAR2) IS
    
    -- Buscar o registro da LFP
    CURSOR cr_craplfp IS
      SELECT lfp.cdcooper
           , lfp.nrdconta
           , lfp.vllancto
        FROM craplfp lfp
       WHERE lfp.progress_recid = pr_nrridlfp;
    rw_craplfp     cr_craplfp%ROWTYPE;
   
    -- Buscar lote
    CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                      ,pr_nrdolote IN VARCHAR2) IS
      SELECT cdagenci
            ,cdbccxlt
            ,nrseqdig
            ,nrdolote
            ,qtinfoln
            ,qtcompln
            ,vlinfodb
            ,vlcompdb
            ,vlinfocr
            ,vlcompcr
            ,dtmvtolt
            ,rowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = 1
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    
    -- Busca a empresa do pagamento
    CURSOR cr_crapemp (pr_nrridlfp IN craplfp.progress_recid%TYPE) IS
     SELECT emp.cdempres
           ,emp.nrdconta
           ,emp.dsdemail
       FROM crapemp emp
           ,craplfp lfp
      WHERE lfp.progress_recid = pr_nrridlfp
        AND lfp.cdcooper       = emp.cdcooper
        AND lfp.cdempres       = emp.cdempres;
    rw_crapemp cr_crapemp%ROWTYPE;
    
    -- Busca o LOTE de folha da empresa
    CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdempres IN crapemp.cdempres%TYPE) IS
      SELECT to_number(dstextab) nrdolote
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND upper(craptab.nmsistem) = 'CRED'
         AND upper(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 0
         AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
         AND craptab.tpregist = pr_cdempres;
    rw_craptab cr_craptab%ROWTYPE;
    
    -- Verificar se já existe número do documento informado
    CURSOR cr_craplcm_nrdoc(pr_cdcooper  IN craplcm.cdcooper%TYPE
                           ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE
                           ,pr_nrdolote  IN craplcm.nrdolote%TYPE
                           ,pr_nrdctabb  IN craplcm.nrdctabb%TYPE
                           ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE ) IS
      SELECT 1
        FROM craplcm  lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = 1
         AND lcm.cdbccxlt = 100
         AND lcm.nrdolote = pr_nrdolote
         AND lcm.nrdctabb = pr_nrdctabb
         AND lcm.nrdocmto = pr_nrdocmto;
    
    -- Vairáveis
    vr_nrdlote        NUMBER;
    vr_nrdocmto	      NUMBER;
    vr_exis_lcm       NUMBER;
    vr_hrtransa       NUMBER;
    vr_nrseqdig       NUMBER;
    vr_emailerr       VARCHAR2(2000);
    vr_email_destino  VARCHAR2(1000);
    vr_email_assunto  VARCHAR2(1000);
    vr_email_corpo    VARCHAR2(32000);
    vr_hasfound       BOOLEAN;
    vr_cdhisest       NUMBER;
    
    vr_exc_erro       EXCEPTION;
    vr_exc_email      EXCEPTION;
    vr_cdcritic       NUMBER;
    vr_dscritic       VARCHAR2(1000);
    vr_idprglog       NUMBER;
    
    /************************************************************************/
    -- Procedimento para inserir o lote e não deixar tabela lockada
    PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                              pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                              pr_cdagenci IN craplot.cdagenci%TYPE,
                              pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                              pr_nrdolote IN craplot.nrdolote%TYPE,
                              pr_tplotmov IN craplot.tplotmov%TYPE,
                              pr_cdhistor IN craplot.cdhistor%TYPE DEFAULT 0,
                              pr_cdoperad IN craplot.cdoperad%TYPE,
                              pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                              pr_cdopecxa IN craplot.cdopecxa%TYPE,
                              pr_craplot  OUT cr_craplot%ROWTYPE,
                              pr_dscritic OUT VARCHAR2)IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;

      rw_craplot  cr_craplot%ROWTYPE;
      vr_nrdolote craplot.nrdolote%TYPE;

    BEGIN
      vr_nrdolote := pr_nrdolote;

      -- verificar lote
      OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                       pr_dtmvtolt  => pr_dtmvtolt,
                       pr_nrdolote  => vr_nrdolote);
      FETCH cr_craplot INTO rw_craplot;

      IF cr_craplot%NOTFOUND THEN
        -- criar registros de lote na tabela
        INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdcooper,
             cdoperad,
             nrdcaixa,
             cdopecxa,
             nrseqdig,
             cdhistor)
          VALUES
            (pr_dtmvtolt,
             pr_cdagenci,
             pr_cdbccxlt,
             vr_nrdolote,
             pr_tplotmov,  -- tplotmov
             pr_cdcooper,
             pr_cdoperad,
             pr_nrdcaixa,
             pr_cdopecxa,
             1,            -- nrseqdig
             pr_cdhistor)
           RETURNING ROWID,
                     craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.nrseqdig
                INTO rw_craplot.rowid,
                     rw_craplot.dtmvtolt,
                     rw_craplot.cdagenci,
                     rw_craplot.cdbccxlt,
                     rw_craplot.nrdolote,
                     rw_craplot.nrseqdig;
        
      END IF;

      CLOSE cr_craplot;
      pr_craplot := rw_craplot;

      -- Grava criação do lote
      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;

        ROLLBACK;
        -- se ocorreu algum erro durante a criac?o
        pr_dscritic := 'Erro ao inserir/atualizar lote '||rw_craplot.nrdolote||': '||SQLERRM;
        ROLLBACK;
    END pc_insere_lote;
    /************************************************************************/
    
  BEGIN
    
    -- Se o identificador não for válido
    IF NVL(pr_nrridlfp,0) <= 0 THEN
      ROLLBACK;
      RETURN; -- Deixa a rotina sem realizar processamento
    END IF;
    
    -- Buscar o registro do lançamento de folha de pagamento
    OPEN  cr_craplfp;
    FETCH cr_craplfp INTO rw_craplfp;
    
    -- Se não encontrar registro pelo ID
    IF cr_craplfp%NOTFOUND THEN
      -- Fechar o Cursor
      CLOSE cr_craplfp;
      
      -- Encerrar a rotina sem realizar processsamento
      RETURN;
    
    END IF;
    
    -- Criar um save point, caso não consiga realizar todo o processo, volta os lançamentos
    SAVEPOINT lcm_dev_empregador;
    
    -- Fechar o Cursor
    CLOSE cr_craplfp;
    
    -- Buscar o registro de datas
    OPEN  BTCH0001.cr_crapdat(rw_craplfp.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    
    -- Se não encontrar registro pelo ID
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o Cursor
      CLOSE BTCH0001.cr_crapdat;

      -- Crítica
      vr_cdcritic := 1;
      
      -- Encerrar a rotina sem realizar processsamento
      RAISE vr_exc_erro;
    
    END IF;
    
    -- Fchar o cursor
    CLOSE BTCH0001.cr_crapdat;
    
    -- Buscar numero do lote
    vr_nrdlote := gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper, 'FOLHAIB_NRLOTE_CTASAL');
    
    -- Inserir o lote para o débito de devolução
    pc_insere_lote(pr_cdcooper => rw_craplfp.cdcooper
                  ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt
                  ,pr_cdagenci => 1  
                  ,pr_cdbccxlt => 100 
                  ,pr_nrdolote => vr_nrdlote
                  ,pr_tplotmov => 1
                  ,pr_cdhistor => 0
                  ,pr_cdoperad => ' '
                  ,pr_nrdcaixa => 0  
                  ,pr_cdopecxa => ' '
                  ,pr_craplot  => rw_craplot
                  ,pr_dscritic => vr_dscritic);
    
    -- Se der erro
    IF vr_dscritic IS NOT NULL THEN
      vr_emailerr := '060 - LOTE INEXISTENTE: ' || vr_dscritic;
      RAISE vr_exc_email;
    END IF;          
    
    -- Buscar o próximo número de documento a ser utilizado
    vr_nrdocmto := pr_nrdocmto;
    vr_exis_lcm := 0;
    
    LOOP 
      -- Verifica se existe craplcm com mesmo numero de documento
      OPEN cr_craplcm_nrdoc(pr_cdcooper  => rw_craplfp.cdcooper
                           ,pr_dtmvtolt  => BTCH0001.rw_crapdat.dtmvtolt
                           ,pr_nrdolote  => rw_craplot.nrdolote
                           ,pr_nrdctabb  => rw_craplfp.nrdconta
                           ,pr_nrdocmto  => vr_nrdocmto);
      FETCH cr_craplcm_nrdoc INTO vr_exis_lcm;
      
      -- Sair quando não tiver encontrado
      EXIT WHEN cr_craplcm_nrdoc%NOTFOUND;
      -- Fechamos o CURSOR pois ele será reaberto no próximo LOOP
      CLOSE cr_craplcm_nrdoc;
      -- Se persite no loop é pq existe, então adicionamos o numero documento
      vr_nrdocmto := vr_nrdocmto + 1000000000;
    END LOOP;  
    
    -- Fechar cursor
    IF cr_craplcm_nrdoc%ISOPEN THEN
      CLOSE cr_craplcm_nrdoc;
    END IF; 
    
    -- Realiza o lançamento de DÉBITO na CRAPLCM 
    vr_hrtransa := gene0002.fn_busca_time;
    BEGIN
      vr_nrseqdig := fn_sequence('CRAPLOT'
						                    ,'NRSEQDIG'
						                    ,''||rw_craplfp.cdcooper||';'
							                     ||to_char(BTCH0001.rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
							                     ||rw_craplot.cdagenci||';'
							                     ||rw_craplot.cdbccxlt||';'
							                     ||rw_craplot.nrdolote);
    
      INSERT INTO craplcm
                  (craplcm.cdcooper
                  ,craplcm.dtmvtolt
                  ,craplcm.hrtransa
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdctabb
                  ,craplcm.nrdctitg
                  ,craplcm.nrdocmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.vllanmto)
           VALUES (rw_craplfp.cdcooper               --> craplcm.cdcooper
                  ,BTCH0001.rw_crapdat.dtmvtolt      --> craplcm.dtmvtolt
                  ,vr_hrtransa                       --> craplcm.hrtransa
                  ,1                                 --> craplcm.cdagenci
                  ,100                               --> craplcm.cdbccxlt
                  ,rw_craplot.nrdolote               --> craplcm.nrdolote
                  ,rw_craplfp.nrdconta               --> craplcm.nrdconta
                  ,rw_craplfp.nrdconta               --> craplcm.nrdctabb
                  ,to_char(rw_craplfp.nrdconta,'fm00000000') --> craplcm.nrdctitg
                  ,vr_nrdocmto                       --> craplcm.nrdocmto
                  ,2946 -- DEVOLUCAO DEBITO SALARIO - CONTA SALARIO --> craplcm.cdhistor
                  ,vr_nrseqdig                       --> craplcm.nrseqdig
                  ,rw_craplfp.vllancto);             --> craplcm.vllanmto
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
        vr_emailerr := SQLERRM;
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao inclur lançamento na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ' || vr_emailerr;
        RAISE vr_exc_email;
    END;
    
    -- Atualizar lote
    BEGIN
      UPDATE craplot
         SET qtinfoln = qtinfoln + 1
            ,qtcompln = qtcompln + 1
            ,vlinfodb = vlinfodb + rw_craplfp.vllancto
            ,vlcompdb = vlcompdb + rw_craplfp.vllancto
            ,nrseqdig = nrseqdig + 1
       WHERE cdcooper = rw_craplfp.cdcooper
         AND dtmvtolt = BTCH0001.rw_crapdat.dtmvtolt
         AND cdagenci = 1   -- cdagenci
         AND cdbccxlt = 100 -- cdbccxlt
         AND nrdolote = rw_craplot.nrdolote
         AND tplotmov = 1
       RETURNING nrseqdig
                ,qtinfoln
                ,qtcompln
                ,vlinfodb
                ,vlcompdb
                ,ROWID
           INTO rw_craplot.nrseqdig
               ,rw_craplot.qtinfoln
               ,rw_craplot.qtcompln
               ,rw_craplot.vlinfodb
               ,rw_craplot.vlcompdb
               ,rw_craplot.rowid;	
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
        vr_emailerr := SQLERRM;
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao atualizar lote na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ' || vr_emailerr;
        RAISE vr_exc_email;
    END;
    
    -- Atualiza o lançamento de pagamento como DEVOLVIDO
    BEGIN
      UPDATE craplfp
         SET idsitlct       = 'D'
            ,dsobslct       = 'Registro devolvido a empresa por Rejeição da TEC'
       WHERE progress_recid = pr_nrridlfp;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
        vr_emailerr := SQLERRM;
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao atualizar LFP na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ' || vr_emailerr;
        RAISE vr_exc_erro;
    END;
    
    -- busca o histórico para crédito na conta da empresa
    vr_cdhisest := gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper,'FOLHAIB_HIST_EST_TECSAL');
    
    -- Busca a empresa que realizou o pagamento ao cooperado
    OPEN  cr_crapemp (pr_nrridlfp => pr_nrridlfp);
    FETCH cr_crapemp INTO rw_crapemp;
    
    -- Se encontrou o empregador
    IF cr_crapemp%FOUND THEN
      
      -- Fecha o cursor
      CLOSE cr_crapemp;
    
      -- Buscar o lote de folha da empresa, através da CRAPTAB
      OPEN cr_craptab (pr_cdcooper => rw_craplfp.cdcooper
                      ,pr_cdempres => rw_crapemp.cdempres);
      FETCH cr_craptab INTO rw_craptab;
      
      -- Se não encontrar o registro na TAB
      IF cr_craptab%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_craptab;
        vr_emailerr := '060 - LOTE INEXISTENTE';
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro no lote folha da empresa na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: '||vr_emailerr;
        RAISE vr_exc_email;
      END IF;
      
      -- Fecha o cursor
      CLOSE cr_craptab;
      
      -- Buscar ou criar o lote para a devolução ao Empregador
      OPEN cr_craplot (pr_cdcooper => rw_craplfp.cdcooper
                      ,pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt
                      ,pr_nrdolote => rw_craptab.nrdolote);
      FETCH cr_craplot INTO rw_craplot;
      vr_hasfound := cr_craplot%FOUND;
      CLOSE cr_craplot;

      -- Se não existir
      IF NOT vr_hasfound THEN
        BEGIN -- Cria novo
          INSERT INTO craplot
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,tplotmov
                     ,qtinfoln
                     ,qtcompln
                     ,vlinfocr
                     ,vlcompcr
                     ,nrseqdig)
              VALUES(rw_craplfp.cdcooper
                    ,BTCH0001.rw_crapdat.dtmvtolt
                    ,1           -- cdagenci
                    ,100         -- cdbccxlt
                    ,rw_craptab.nrdolote
                    ,1
                    ,1
                    ,1
                    ,rw_craplfp.vllancto
                    ,rw_craplfp.vllancto
                    ,1)
           RETURNING nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfocr
                    ,vlcompcr
                    ,vlinfodb
                    ,vlcompdb
                    ,ROWID
               INTO rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfocr
                   ,rw_craplot.vlcompcr
                   ,rw_craplot.vlinfodb
                   ,rw_craplot.vlcompdb
                   ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
            vr_emailerr := '060 - LOTE INEXISTENTE';
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao criar lote na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: 060 - LOTE INEXISTENTE';
            RAISE vr_exc_email;
        END;
      ELSE -- Se existir, atualiza
        BEGIN
          UPDATE craplot
             SET qtinfoln = qtinfoln + 1
                ,qtcompln = qtcompln + 1
                ,vlinfocr = vlinfocr + rw_craplfp.vllancto
                ,vlcompcr = vlcompcr + rw_craplfp.vllancto
                ,nrseqdig = nrseqdig + 1
           WHERE cdcooper = rw_craplfp.cdcooper
             AND dtmvtolt = BTCH0001.rw_crapdat.dtmvtolt
             AND cdagenci = 1
             AND cdbccxlt = 100
             AND nrdolote = rw_craptab.nrdolote
           RETURNING nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfocr
                    ,vlcompcr
                    ,vlinfodb
                    ,vlcompdb
                    ,ROWID
               INTO rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfocr
                   ,rw_craplot.vlcompcr
                   ,rw_craplot.vlinfodb
                   ,rw_craplot.vlcompdb
                   ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
            vr_emailerr := '060 - LOTE INEXISTENTE';
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao criar lote na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: 060 - LOTE INEXISTENTE';
            RAISE vr_exc_email;
        END;
      END IF;
      
      -- Realiza o lançamento de CRÉDITO na CRAPLCM
      BEGIN
        INSERT INTO craplcm
                   (dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,nrdocmto
                   ,cdhistor
                   ,vllanmto
                   ,nrseqdig
                   ,cdcooper)
             VALUES(BTCH0001.rw_crapdat.dtmvtolt
                   ,1
                   ,100
                   ,rw_craptab.nrdolote
                   ,rw_crapemp.nrdconta
                   ,rw_crapemp.nrdconta
                   ,gene0002.fn_mask(rw_crapemp.nrdconta,'99999999') -- nrdctitg
                   ,rw_craplot.nrseqdig
                   ,vr_cdhisest
                   ,rw_craplfp.vllancto
                   ,rw_craplot.nrseqdig
                   ,rw_craplfp.cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => rw_craplfp.cdcooper);
          vr_emailerr := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro ao gerar lançamento na PC_ESTORNO_REJ_EMPREGADOR. Detalhes: '||vr_emailerr;
          RAISE vr_exc_email;
      END;
      
      -- Conteudo do e-mail informando para a empresa a devolução
      vr_email_corpo := 'Olá,<br> Houve(ram) problema(s) com o(s) lançamentos de folha de pagamento agendados em sua Conta-Online. <br>'||
                        'Com isso, efetuamos o estorno no valor de R$ '||TO_CHAR(rw_craplfp.vllancto,'FM9G999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '.<br>'||
                        'Para maiores detalhes dos problemas ocorridos, favor verificar sua Conta-Online ou acionar seu Posto de Atendimento. <br><br> ' ||
                        'Atenciosamente,<br>Sistema AILOS.';
      -- Enviar e-mail informando para a empresa a falta de saldo.
      gene0003.pc_solicita_email(pr_cdcooper        => rw_craplfp.cdcooper
                                ,pr_cdprogra        => 'PCPS0001'
                                ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                ,pr_des_assunto     => 'Folha de Pagamento - Estorno de Débito'
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      -- envia ao LOG
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                           , pr_cdprograma    => 'PCPS0001' 
                           , pr_cdcooper      => rw_craplfp.cdcooper
                           , pr_tpexecucao    => 0
                           , pr_tpocorrencia  => 1 
                           , pr_dsmensagem    => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Rotina PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ESTORNO de transferencia REJEITADA - EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.nrdconta || ' – DEVOLUÇÃO DE R$ ' || to_char(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00') || ' EFETUADA COM SUCESSO. '                           , pr_idprglog      => vr_idprglog);

    END IF; -- IF cr_crapemp%FOUND THEN
    
    -- Fechar o cursor se tiver aberto
    IF cr_crapemp%ISOPEN THEN
      CLOSE cr_crapemp;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se a descrição da critica estiver em branco
      IF vr_dscritic IS NULL AND vr_cdcritic > 0 THEN 
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF; 
      
      -- Retornar erro
      pr_dscritic := vr_dscritic;
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog     => 'O'
                           , pr_cdprograma   => 'PCPS0001' 
                           , pr_cdcooper     => rw_craplfp.cdcooper
                           , pr_tpexecucao   => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem   => vr_dscritic
                           , pr_idprglog     => vr_idprglog); 
      
      -- Faz rollback apenas das ações realizadas para o empregador
      ROLLBACK TO lcm_dev_empregador;

    WHEN vr_exc_email THEN
      -- Se a descrição da critica estiver em branco
      IF vr_dscritic IS NULL AND vr_cdcritic > 0 THEN 
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
       
      -- Retornar erro
      pr_dscritic := vr_dscritic;
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog     => 'O'
                           , pr_cdprograma   => 'PCPS0001' 
                           , pr_cdcooper     => rw_craplfp.cdcooper
                           , pr_tpexecucao   => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem   => vr_dscritic
                           , pr_idprglog     => vr_idprglog); 
      
      -- Faz rollback apenas das ações realizadas para o empregador
      ROLLBACK TO lcm_dev_empregador;
      
      /** REALIZAR O ENVIO DO E-MAIL **/
      vr_email_destino := gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper, 'FOLHAIB_EMAIL_ALERT_PROC') || ','
                       || gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper, 'FOLHAIB_EMAIL_ALERT_FIN');
      vr_email_assunto := 'Portabilidade – Problemas com o Estorno Automático das Rejeições/Devoluções TEC';
      vr_email_corpo   := 'Olá, encontramos problemas durante a rotina de estorno ' ||
                          'automático das rejeições/devoluções TEC das portabilidades de salário ' ||
                          'realizadas. Favor solicitar a verificação do erro informado.' ||
                          '<br>' ||
                          '<br>' ||
                          'Detalhes do erro:' || vr_emailerr;
                          
      gene0003.pc_solicita_email(pr_cdcooper        => rw_craplfp.cdcooper
                                ,pr_cdprogra        => 'PCPS0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
                                
      IF vr_dscritic IS NOT NULL THEN
        -- envia ao LOG o problema ocorrido
        CECRED.pc_log_programa(pr_dstiplog     => 'O'
                             , pr_cdprograma   => 'PCPS0001' 
                             , pr_cdcooper     => rw_craplfp.cdcooper
                             , pr_tpexecucao   => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem   => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro tratado na rotina PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ' || vr_dscritic
                             , pr_idprglog     => vr_idprglog);
        
      END IF;
      
      /********************************/
            
    WHEN OTHERS THEN
      
      -- Crítica de processamento
      pr_dscritic := 'Erro na rotina PC_ESTORNO_REJ_EMPREGADOR: '||SQLERRM;
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog     => 'O'
                           , pr_cdprograma   => 'PCPS0001' 
                           , pr_cdcooper     => rw_craplfp.cdcooper
                           , pr_tpexecucao   => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem   => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> ESTORNO TEC DE PORTABILIDADE - ' || pr_dscritic
                           , pr_idprglog     => vr_idprglog); 
      
      -- Faz rollback apenas das ações realizadas para o empregador
      ROLLBACK TO lcm_dev_empregador;
      
      /** REALIZAR O ENVIO DO E-MAIL **/
      vr_email_destino := gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper, 'FOLHAIB_EMAIL_ALERT_PROC') || ','
                       || gene0001.fn_param_sistema('CRED',rw_craplfp.cdcooper, 'FOLHAIB_EMAIL_ALERT_FIN');
      vr_email_assunto := 'Portabilidade – Problemas com o Estorno Automático das Rejeições/Devoluções TEC';
      vr_email_corpo   := 'Olá, encontramos problemas durante a rotina de estorno ' ||
                          'automático das rejeições/devoluções TEC das portabilidades de salário ' ||
                          'realizadas. Favor solicitar a verificação do erro informado.' ||
                          '<br>' ||
                          '<br>' ||
                          'Detalhes do erro:' || pr_dscritic;
                          
      gene0003.pc_solicita_email(pr_cdcooper        => rw_craplfp.cdcooper
                                ,pr_cdprogra        => 'PCPS0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        -- envia ao LOG o problema ocorrido
        CECRED.pc_log_programa(pr_dstiplog     => 'O'
                             , pr_cdprograma   => 'PCPS0001' 
                             , pr_cdcooper     => rw_craplfp.cdcooper
                             , pr_tpexecucao   => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem   => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - PCPS0001 --> Erro tratado na rotina PC_ESTORNO_REJ_EMPREGADOR. Detalhes: ' || vr_dscritic
                             , pr_idprglog     => vr_idprglog);
        
      END IF;
      
      /********************************/
      
  END pc_estorno_rej_empregador;
  
	-- Validar se o depósito está sendo feito numa conta salário ou não.
	PROCEDURE pc_valida_deposito_cta_sal(pr_cdcooper IN crapcop.cdcooper%TYPE --Código da cooperativa de origem
		                                  ,pr_cdcopdst IN crapcop.cdcooper%TYPE --Código da cooperativa de destino
                                      ,pr_nrctadst IN crapass.nrdconta%TYPE --Número da conta de destino do depósito 
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                      ,pr_cdagenci IN NUMBER
                                      ,pr_nrdcaixa IN NUMBER
                                      ,pr_cdorigem IN NUMBER   -- Código da origem
                                      ,pr_nmdatela IN VARCHAR2 -- Nome da tela 
                                      ,pr_nmprogra IN VARCHAR2 -- Nome do programa
                                      ,pr_cdoperad IN VARCHAR2 -- Código do operador
                                      ,pr_flgerlog IN NUMBER
                                      ,pr_flmobile IN NUMBER
                                      ,pr_dsretxml OUT xmltype  --> XML de retorno CLOB
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
																					 
    /* .............................................................................
            Programa: pc_valida_deposito_cta_sal
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Abril/2019                 Ultima atualizacao: 24/04/2019
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo: Validar se o depósito está sendo feito numa conta salário ou não.

            Observacao: -----
        
            Alteracoes:
    ............................................................................. */

	-- Variaveis
	vr_cdmodali  INTEGER;
	
	-- Variaveis de critica
	vr_dscritic crapcri.dscritic%TYPE;
	vr_des_erro VARCHAR2(1000);
	
	--Controle de erro
	vr_exc_erro EXCEPTION;
  
	BEGIN
		
	  -- Busca a modalidade da conta destino
		cada0006.pc_busca_modalidade_conta(pr_cdcooper => pr_cdcopdst
		                                  ,pr_nrdconta => pr_nrctadst
																			,pr_cdmodalidade_tipo => vr_cdmodali
																			,pr_des_erro => vr_des_erro
																			,pr_dscritic => vr_dscritic);
		
		-- Se retornou crítica
		IF TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
		
		-- Se for modalidade 2 significa que é conta salário
		IF vr_cdmodali = 2 THEN
				vr_dscritic := 'Lancamento nao permitido para este tipo de conta.';
				RAISE vr_exc_erro;
		END IF;
		
		pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmsgerr></dsmsgerr></Root>');
		
  EXCEPTION
		WHEN vr_exc_erro THEN
			--
			pr_dscritic := vr_dscritic;
			pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmsgerr>' ||
                                           pr_dscritic || '</dsmsgerr></Root>');

    WHEN OTHERS THEN
      --
      pr_dscritic := 'Erro geral na PCPS0001.PC_VALIDA_DEPOSITO_CTA_SAL: ' || SQLERRM;
			pr_dsretxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmsgerr>' ||
                                           pr_dscritic || '</dsmsgerr></Root>');
  END pc_valida_deposito_cta_sal;
  
END PCPS0001;
/
