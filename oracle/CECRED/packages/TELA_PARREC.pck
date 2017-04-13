CREATE OR REPLACE PACKAGE CECRED.TELA_PARREC AS
  -- Buscar parametros de recarga de celular das cooperativas singulares  
  PROCEDURE pc_busca_param_coop(pr_cdcoppar IN tbrecarga_param.cdcooper%TYPE --> Código da Operadora
		                           ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

	-- Altera os parametros da recarga de celular das cooperativas singulares
  PROCEDURE pc_altera_param_coop(pr_cdcoppar IN tbrecarga_param.cdcooper%TYPE        --> Código da Cooperativa
                                ,pr_flsitsac IN tbrecarga_param.flgsituacao_sac%TYPE --> Flag situação SAC (1-Sim/0-Não)
                                ,pr_flsittaa IN tbrecarga_param.flgsituacao_taa%TYPE --> Flag situação TAA (1-Sim/0-Não)
                                ,pr_flsitibn IN tbrecarga_param.flgsituacao_ib%TYPE  --> Flag situação IB (1-Sim/0-Não)
                                ,pr_vlrmaxpf IN tbrecarga_param.vlmaximo_pf%TYPE     --> Valor máximo pessoa física
                                ,pr_vlrmaxpj IN tbrecarga_param.vlmaximo_pj%TYPE     --> Valor máximo pessoa jurídica
                                ,pr_xmllog   IN VARCHAR2                             --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                         --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                            --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                            --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);                          --> Erros do processo
																
  -- Buscar parametros de recarga de celular da CECRED
  PROCEDURE pc_busca_param_cecred(pr_cddopcao IN VARCHAR2                      --> Opção da tela
		                             ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
																 ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
																 ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
																 ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Alterar parametros de recarga de celular da CECRED
  PROCEDURE pc_altera_param_cecred(pr_nrispbif IN crapprm.dsvlrprm%TYPE         --> INSPB
		                              ,pr_cdageban IN crapprm.dsvlrprm%TYPE         --> Agência do banco
																	,pr_nrdconta IN crapprm.dsvlrprm%TYPE         --> Conta
																	,pr_nrdocnpj IN crapprm.dsvlrprm%TYPE         --> CNPJ
																	,pr_dsdonome IN crapprm.dsvlrprm%TYPE         --> INSPB
		                              ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
																  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
																  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
																  ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
																  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
																  ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Buscar Mensagens
  PROCEDURE pc_busca_mensagens(pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
														  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
														  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
														  ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Altera Mensagens
	PROCEDURE pc_altera_mensagens(pr_dsmsgsaldo IN tbgen_mensagem.dsmensagem%TYPE --> Mensagem insuficiência de saldo
		                           ,pr_dsmsgoperac IN tbgen_mensagem.dsmensagem%TYPE --> Mensagem operação não autorizada
		                           ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
														   ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
														   ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
														   ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
														   ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
														   ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo


END TELA_PARREC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARREC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PARREC
  --    Autor   : Lucas Reinert
  --    Data    : Janeiro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela PARREC (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
	
  -- Buscar parametros de recarga de celular das cooperativas singulares  
  PROCEDURE pc_busca_param_coop(pr_cdcoppar IN tbrecarga_param.cdcooper%TYPE --> Código da Operadora
		                           ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_param_coop
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os parametros de recarga de celular
		            das cooperativas singulares

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

      vr_param_coop tbrecarga_param%ROWTYPE;
			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PARREC'
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
			
			-- Buscar informações da operadora
			RCEL0001.pc_busca_param_coop(pr_cdcooper => pr_cdcoppar
			                            ,pr_param_coop => vr_param_coop
																  ,pr_cdcritic => vr_cdcritic
																  ,pr_dscritic => vr_dscritic);
													
		  -- Se retornou crítica			 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<flsitsac>' || vr_param_coop.flgsituacao_sac || '</flsitsac>'
								 || '<flsittaa>' || vr_param_coop.flgsituacao_taa || '</flsittaa>'
								 || '<flsitibn>' || vr_param_coop.flgsituacao_ib  || '</flsitibn>'
								 || '<vlrmaxpf>' || to_char(vr_param_coop.vlmaximo_pf, 'fm999g999g999g990d00') || '</vlrmaxpf>'
								 || '<vlrmaxpj>' || to_char(vr_param_coop.vlmaximo_pj, 'fm999g999g999g990d00') || '</vlrmaxpj>'
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
        pr_dscritic := 'Erro geral na rotina da tela PARREC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_param_coop;

  -- Altera os parametros da recarga de celular das cooperativas singulares
  PROCEDURE pc_altera_param_coop(pr_cdcoppar IN tbrecarga_param.cdcooper%TYPE        --> Código da Cooperativa
                                ,pr_flsitsac IN tbrecarga_param.flgsituacao_sac%TYPE --> Flag situação SAC (1-Sim/0-Não)
                                ,pr_flsittaa IN tbrecarga_param.flgsituacao_taa%TYPE --> Flag situação TAA (1-Sim/0-Não)
                                ,pr_flsitibn IN tbrecarga_param.flgsituacao_ib%TYPE  --> Flag situação IB (1-Sim/0-Não)
                                ,pr_vlrmaxpf IN tbrecarga_param.vlmaximo_pf%TYPE     --> Valor máximo pessoa física
                                ,pr_vlrmaxpj IN tbrecarga_param.vlmaximo_pj%TYPE     --> Valor máximo pessoa jurídica
                                ,pr_xmllog   IN VARCHAR2                             --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                         --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                            --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                            --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS                        --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_altera_param_coop
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar os parametros da recarga de celular 
  				      das cooperativas singulares

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

      -- Variavel temporária para LOG 
      vr_dslogtel VARCHAR2(32767) := '';

      -- Rowtypes
      vr_param_coop tbrecarga_param%ROWTYPE;
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Busca do nome da Cooperativa
      CURSOR cr_crapcop(pr_cdcoppar IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcoppar;
      vr_nmrescop crapcop.nmrescop%TYPE;
			
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_OPECEL'
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
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => Vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Data nao cadastrada.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
						
			-- Buscar informações da operadora
			RCEL0001.pc_busca_param_coop(pr_cdcooper => pr_cdcoppar
			                            ,pr_param_coop => vr_param_coop
																	,pr_cdcritic => vr_cdcritic
																	,pr_dscritic => vr_dscritic);
													
		  -- Se retornou crítica			 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Atualizar informações da operadora
			UPDATE tbrecarga_param tpar
			   SET tpar.flgsituacao_sac = pr_flsitsac
				    ,tpar.flgsituacao_taa = pr_flsittaa
						,tpar.flgsituacao_ib  = pr_flsitibn
						,tpar.vlmaximo_pf     = nvl(pr_vlrmaxpf, 0)
						,tpar.vlmaximo_pj     = nvl(pr_vlrmaxpj, 0)
		   WHERE cdcooper = pr_cdcoppar;
			
			-- Registro ainda não criado, devemos inseri-lo
			IF SQL%ROWCOUNT = 0 THEN
				INSERT INTO tbrecarga_param
				            (cdcooper
										,flgsituacao_taa
										,flgsituacao_sac
										,flgsituacao_ib
										,vlmaximo_pf
										,vlmaximo_pj)
							VALUES(pr_cdcoppar
							      ,pr_flsittaa
										,pr_flsitsac
										,pr_flsitibn
										,pr_vlrmaxpf
										,pr_vlrmaxpj);										
			END IF;
			
		  -- Buscar nome da cooperativa
		  OPEN cr_crapcop(pr_cdcoppar => pr_cdcoppar);
		  FETCH cr_crapcop INTO vr_nmrescop;
			
		  -- Se alterou situação do SAC
		  IF vr_param_coop.flgsituacao_sac <> pr_flsitsac THEN
			  vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou o canal de recarga SAC '
                    || ' de ' || CASE WHEN vr_param_coop.flgsituacao_sac = 1 THEN 'SIM' ELSE 'NAO' END
									  || ' para ' || CASE WHEN pr_flsitsac = 1 THEN 'SIM' ELSE 'NAO' END 
									  || ' na cooperativa ' || vr_nmrescop || '.' || chr(10);
		  END IF;
			
		  -- Se alterou situação do TAA
		  IF vr_param_coop.flgsituacao_taa <> pr_flsittaa THEN
			  vr_dslogtel := vr_dslogtel
			              || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou o canal de recarga TA '
                    || ' de ' || CASE WHEN vr_param_coop.flgsituacao_taa = 1 THEN 'SIM' ELSE 'NAO' END
						 			  || ' para ' || CASE WHEN pr_flsittaa = 1 THEN 'SIM' ELSE 'NAO' END 
						 			  || ' na cooperativa ' || vr_nmrescop || '.' || chr(10);
 		  END IF;
		 
		  -- Se alterou situação do IB
		  IF vr_param_coop.flgsituacao_ib <> pr_flsitibn THEN
			  -- Devemos bloquear a opção no IB
				UPDATE crapmni mni
				   SET mni.flgitmbl = pr_flsitibn
				 WHERE mni.cdcooper = pr_cdcoppar
				   AND upper(mni.nmdoitem) = 'RECARGA DE CELULAR';
			  -- Gerar log
			  vr_dslogtel := vr_dslogtel
			              || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou o canal de recarga INTERNET BANKING '
                    || ' de ' || CASE WHEN vr_param_coop.flgsituacao_ib = 1 THEN 'SIM' ELSE 'NAO' END
									  || ' para ' || CASE WHEN pr_flsitibn = 1 THEN 'SIM' ELSE 'NAO' END 
									  || ' na cooperativa ' || vr_nmrescop || '.' || chr(10);
		  END IF;

 		  -- Se alterou valor máximo de limite para PF
		  IF nvl(vr_param_coop.vlmaximo_pf, 0) <> nvl(pr_vlrmaxpf, 0) THEN
			  vr_dslogtel := vr_dslogtel
			              || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou o valor do limite maximo diario para PESSOA FISICA '
                    || ' de ' || to_char(nvl(vr_param_coop.vlmaximo_pf, 0), 'fm999g999g990d00')
									  || ' para ' || to_char(nvl(pr_vlrmaxpf, 0), 'fm999g999g990d00')
									  || ' na cooperativa ' || vr_nmrescop || '.' || chr(10);
		  END IF;

 		  -- Se alterou valor máximo de limite para PF
		  IF nvl(vr_param_coop.vlmaximo_pj, 0) <> nvl(pr_vlrmaxpj, 0) THEN
			  vr_dslogtel := vr_dslogtel
			              || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou o valor do limite maximo diario para PESSOA JURIDICA '
                    || ' de ' || to_char(nvl(vr_param_coop.vlmaximo_pj, 0), 'fm999g999g990d00')
									  || ' para ' || to_char(nvl(pr_vlrmaxpj, 0), 'fm999g999g990d00')
									  || ' na cooperativa ' || vr_nmrescop || '.' || chr(10);
		  END IF;

		  -- Se deve gerar algum log
		  IF TRIM(vr_dslogtel) IS NOT NULL THEN
			  btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
																  ,pr_ind_tipo_log => 2 -- Erro tratato
																  ,pr_nmarqlog     => 'parrec.log'
																  ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
																	,pr_cdprograma   => 'PARREC');
      END IF;					 	
		  -- Efetuar commit
		  COMMIT;
			 
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
																			 
				-- Efetuar Rollback
        ROLLBACK;																			 

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela OPECEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
																			 
				-- Efetuar Rollback
        ROLLBACK;
																			 																			 
    END;
  END pc_altera_param_coop;

  -- Buscar parametros de recarga de celular da CECRED
  PROCEDURE pc_busca_param_cecred(pr_cddopcao IN VARCHAR2                      --> Opção da tela
		                             ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
																 ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
																 ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
																 ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_param_cecred
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os parametros de recarga de celular
		            da CERED

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

      -- Variáveis com dados da tela
      vr_nrispbif crapprm.dsvlrprm%TYPE;
			vr_cdbccxlt crapban.cdbccxlt%TYPE;
			vr_nmresbcc crapban.nmresbcc%TYPE;
			vr_cdageban crapprm.dsvlrprm%TYPE;
			vr_nmageban crapagb.nmageban%TYPE;
			vr_nrdconta crapprm.dsvlrprm%TYPE;
			vr_nrdocnpj crapprm.dsvlrprm%TYPE;
			vr_dsdonome crapprm.dsvlrprm%TYPE;
			
			-- Buscar cód e nome do banco
			CURSOR cr_crapban(pr_nrispbif IN crapban.nrispbif%TYPE) IS
			  SELECT ban.cdbccxlt
				      ,ban.nmresbcc
					FROM crapban ban
				 WHERE (ban.nrispbif = pr_nrispbif AND pr_nrispbif <> 0)
				    OR (ban.cdbccxlt = 1           AND pr_nrispbif =  0);
			
			-- Buscar agencia do banco
			CURSOR cr_crapagb(pr_cddbanco IN crapagb.cddbanco%TYPE
			                 ,pr_cdageban IN crapagb.cdageban%TYPE) IS
				SELECT agb.nmageban
				  FROM crapagb agb
				 WHERE agb.cddbanco = pr_cddbanco
				   AND agb.cdageban = pr_cdageban;
					 
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PARREC'
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
      
			IF UPPER(pr_cddopcao) = 'A' THEN
				-- Se operador não for do Financeiro
				IF gene0005.fn_valida_depart_operad(pr_cdcooper => vr_cdcooper
																					 ,pr_cdoperad => vr_cdoperad
																					 ,pr_dsdepart => 'COORD.ADM/FINANCEIRO') = 0 THEN
					-- Gera crítica
					vr_cdcritic := 36;
					vr_dscritic := '';
					-- Levanta exceção
					RAISE vr_exc_erro;
				END IF;
      END IF;
						
			-- Número ISPB
      vr_nrispbif := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_ISPB_REPASSE'); 
			-- Agência
      vr_cdageban := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_AGENCIA_REPASSE'); 																							
			-- Número da conta
      vr_nrdconta := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_CONTA_REPASSE');
			-- Número do CNPJ
      vr_nrdocnpj := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_CNPJ_REPASSE');
			-- Nome
      vr_dsdonome := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_NOME_REPASSE');
			-- Se possuir ISPB
			IF TRIM(vr_nrispbif) IS NOT NULL THEN
				-- Buscar código do banco e nome
				OPEN cr_crapban(pr_nrispbif => vr_nrispbif);
				FETCH cr_crapban INTO vr_cdbccxlt, vr_nmresbcc;
				-- Fechar cursor
				CLOSE cr_crapban;
			END IF;
			
			-- Se possuir agência e banco
			IF TRIM(vr_cdageban) IS NOT NULL AND vr_cdbccxlt > 0 THEN
				-- Buscar nome da agência
				OPEN cr_crapagb(pr_cddbanco => vr_cdbccxlt
				               ,pr_cdageban => vr_cdageban);
				FETCH cr_crapagb INTO vr_nmageban;
				-- Fechar cursor
				CLOSE cr_crapagb;
			END IF;
											
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<nrispbif>' || vr_nrispbif || '</nrispbif>'
								 || '<cdbccxlt>' || vr_cdbccxlt || '</cdbccxlt>'
								 || '<nmresbcc>' || vr_nmresbcc || '</nmresbcc>'
								 || '<cdageban>' || trim(vr_cdageban) || '</cdageban>'
								 || '<nmageban>' || vr_nmageban || '</nmageban>'
								 || '<nrdconta>' || vr_nrdconta || '</nrdconta>'
								 || '<nrdocnpj>' || vr_nrdocnpj || '</nrdocnpj>'
								 || '<dsdonome>' || vr_dsdonome || '</dsdonome>'
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
        pr_dscritic := 'Erro geral na rotina da tela PARREC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_param_cecred;
	
  -- Alterar parametros de recarga de celular da CECRED
  PROCEDURE pc_altera_param_cecred(pr_nrispbif IN crapprm.dsvlrprm%TYPE         --> INSPB
		                              ,pr_cdageban IN crapprm.dsvlrprm%TYPE         --> Agência do banco
																	,pr_nrdconta IN crapprm.dsvlrprm%TYPE         --> Conta
																	,pr_nrdocnpj IN crapprm.dsvlrprm%TYPE         --> CNPJ
																	,pr_dsdonome IN crapprm.dsvlrprm%TYPE         --> INSPB
		                              ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
																  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
																  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
																  ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
																  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
																  ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_altera_param_cecred
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar os parametros de recarga de celular
		            da CERED

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
      vr_dslogtel VARCHAR2(32767) := '';

      -- Variáveis com dados da tela
      vr_nrispbif crapprm.dsvlrprm%TYPE;
			vr_cdbccxlt crapban.cdbccxlt%TYPE;
			vr_nmresbcc crapban.nmresbcc%TYPE;
			vr_cdageban crapprm.dsvlrprm%TYPE;
			vr_nmageban crapagb.nmageban%TYPE;
			vr_nrdconta crapprm.dsvlrprm%TYPE;
			vr_nrdocnpj crapprm.dsvlrprm%TYPE;
			vr_dsdonome crapprm.dsvlrprm%TYPE;

      -- Variáveis auxiliares
			vr_stsnrcal BOOLEAN;
      vr_inpessoa INTEGER;
			
      -- Rowtypes			
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
      FUNCTION fn_exists_param(pr_cdacesso IN crapprm.cdacesso%TYPE) RETURN INTEGER IS
			BEGIN
				DECLARE
			  -- Variável para retornar resultado	
        vr_result INTEGER;
				
				-- Cursor para verificar se parametro existe
				CURSOR cr_crapprm IS
				  SELECT 1
					  FROM crapprm prm
					 WHERE prm.cdcooper = 3
					   AND upper(prm.nmsistem) = 'CRED'
					   AND upper(prm.cdacesso) = pr_cdacesso;
				BEGIN
				   OPEN cr_crapprm;
					 FETCH cr_crapprm INTO vr_result;
					 CLOSE cr_crapprm;
					 
					 RETURN nvl(vr_result, 0);				
				END;
			END;
			
		  -- Inserir PRM
			PROCEDURE pc_insere_param_sistema(pr_cdacesso IN crapprm.cdacesso%TYPE
				                               ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE
																			 ,pr_dstexprm IN crapprm.dstexprm%TYPE) IS
				BEGIN
					-- Inserir valor na prm
					INSERT INTO crapprm (nmsistem
					                    ,cdcooper
															,cdacesso
															,dstexprm
															,dsvlrprm)
					              VALUES('CRED'
												      ,3
															,pr_cdacesso
															,pr_dstexprm
															,pr_dsvlrprm);
				EXCEPTION
					WHEN OTHERS THEN
						-- Gerar crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao inserir novo parâmetro (crapprm) -> ' || SQLERRM;
						-- Levantar exceção
						RAISE vr_exc_erro;
			END;
			
		  -- Alterar PRM			
			PROCEDURE pc_altera_param_sistema(pr_cdacesso IN crapprm.cdacesso%TYPE
				                               ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE) IS
				BEGIN
          UPDATE crapprm prm
					   SET prm.dsvlrprm = pr_dsvlrprm
					 WHERE prm.cdcooper = 3
					   AND prm.nmsistem = 'CRED'
					   AND prm.cdacesso = pr_cdacesso;
				EXCEPTION
					WHEN OTHERS THEN
						-- Gerar crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao alterar parâmetro (crapprm) -> ' || SQLERRM;
						-- Levantar exceção
						RAISE vr_exc_erro;
			END;
					 
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PARREC'
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
			
			--Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => Vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Data nao cadastrada.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
			
			-- Se operador não for do Financeiro
			IF gene0005.fn_valida_depart_operad(pr_cdcooper => vr_cdcooper
				                                 ,pr_cdoperad => vr_cdoperad
																				 ,pr_dsdepart => 'COORD.ADM/FINANCEIRO') = 0 THEN
				-- Gera crítica
				vr_cdcritic := 36; -- Operação não autorizada
				vr_dscritic := '';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
			gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => to_number(regexp_replace(pr_nrdocnpj, '[^0-9]'))
			                           ,pr_stsnrcal => vr_stsnrcal
																 ,pr_inpessoa => vr_inpessoa);
													
			-- Se está inválido			 
		  IF NOT vr_stsnrcal THEN
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'CNPJ inválido.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Número ISPB
      vr_nrispbif := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_ISPB_REPASSE'); 
			-- Agência
      vr_cdageban := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_AGENCIA_REPASSE'); 																							
			-- Número da conta
      vr_nrdconta := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_CONTA_REPASSE');
			-- Número do CNPJ
      vr_nrdocnpj := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_CNPJ_REPASSE');
			-- Nome
      vr_dsdonome := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => 3
																							,pr_cdacesso => 'RECCEL_NOME_REPASSE');			
																										
			-- Se não existir parametro
			IF fn_exists_param('RECCEL_ISPB_REPASSE') = 0 THEN
				-- Se não existir valor, inserir
				pc_insere_param_sistema(pr_cdacesso => 'RECCEL_ISPB_REPASSE'
				                       ,pr_dsvlrprm => pr_nrispbif
															 ,pr_dstexprm => 'Número ISPB da instituição para repasse do valor de recarga de celular');
				-- Gerar log																 
				vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
										|| to_char(SYSDATE, 'hh24:mi:ss') 
										|| ' -->  Operador '|| vr_cdoperad || ' '
										|| ' inseriu o ISPB ' 
                    || pr_nrispbif || ' para a cooperativa CECRED.' || chr(10);																 															 
			ELSE -- Se existir valor, atualizar
				-- Se valor informado for diferente da base
				IF vr_nrispbif <> pr_nrispbif THEN
          -- Atualizar parâmetro
					pc_altera_param_sistema(pr_cdacesso => 'RECCEL_ISPB_REPASSE'
																 ,pr_dsvlrprm => pr_nrispbif);
          -- Gerar log																 
					vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
											|| to_char(SYSDATE, 'hh24:mi:ss') 
											|| ' -->  Operador '|| vr_cdoperad || ' '
										  || ' alterou o ISPB ' 
											|| ' de ' || vr_nrispbif
											|| ' para ' || pr_nrispbif || ' para a cooperativa CECRED.' || chr(10);																 
				END IF;
			END IF;
			
			-- Se não existir parametro
      IF fn_exists_param('RECCEL_AGENCIA_REPASSE') = 0 THEN
				-- Se não existir valor, inserir
				pc_insere_param_sistema(pr_cdacesso => 'RECCEL_AGENCIA_REPASSE'
				                       ,pr_dsvlrprm => pr_cdageban
															 ,pr_dstexprm => 'Agência da instituição para repasse do valor de recarga de celular');
				-- Gerar log																 
				vr_dslogtel := vr_dslogtel
										|| to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
										|| to_char(SYSDATE, 'hh24:mi:ss') 
										|| ' -->  Operador '|| vr_cdoperad || ' '
										|| ' inseriu a AGENCIA ' 
                    || NVL(pr_cdageban,'NULO') || ' para a cooperativa CECRED.' || chr(10);																 																 
															 
			ELSE -- Se existir valor, atualizar
				-- Se valor informado for diferente da base
				IF vr_cdageban <> pr_cdageban THEN
          -- Atualizar parâmetro
					pc_altera_param_sistema(pr_cdacesso => 'RECCEL_AGENCIA_REPASSE'
																 ,pr_dsvlrprm => pr_cdageban);
          -- Gerar log																 
					vr_dslogtel := vr_dslogtel
					            || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
											|| to_char(SYSDATE, 'hh24:mi:ss') 
											|| ' -->  Operador '|| vr_cdoperad || ' '
										  || ' alterou a AGENCIA ' 
											|| ' de ' || nvl(vr_cdageban, 'NULO')
											|| ' para ' || nvl(pr_cdageban, 'NULO') || ' para a cooperativa CECRED.' || chr(10);																 																 
				END IF;															 
			END IF;
			
			-- Se não existir parametro
      IF fn_exists_param('RECCEL_CONTA_REPASSE') = 0 THEN
				-- Se não existir valor, inserir
				pc_insere_param_sistema(pr_cdacesso => 'RECCEL_CONTA_REPASSE'
				                       ,pr_dsvlrprm => pr_nrdconta
															 ,pr_dstexprm => 'Número da conta da instituição para repasse do valor de recarga de celular');															 
				-- Gerar log																 
				vr_dslogtel := vr_dslogtel
										|| to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
										|| to_char(SYSDATE, 'hh24:mi:ss') 
										|| ' -->  Operador '|| vr_cdoperad || ' '
										|| ' inseriu a CONTA ' 
                    || pr_nrdconta || ' para a cooperativa CECRED.' || chr(10);															 
			ELSE -- Se existir valor, atualizar
				-- Se valor informado for diferente da base
				IF vr_nrdconta <> pr_nrdconta THEN
          -- Atualizar parâmetro
					pc_altera_param_sistema(pr_cdacesso => 'RECCEL_CONTA_REPASSE'
																 ,pr_dsvlrprm => pr_nrdconta);
          -- Gerar log																 
					vr_dslogtel := vr_dslogtel
					            || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
											|| to_char(SYSDATE, 'hh24:mi:ss') 
											|| ' -->  Operador '|| vr_cdoperad || ' '
										  || ' alterou a CONTA ' 
											|| ' de ' || vr_nrdconta
											|| ' para ' || pr_nrdconta || ' para a cooperativa CECRED.' || chr(10);
																 
				END IF;															 															 
			END IF;
			
			-- Se não existir parametro
      IF fn_exists_param('RECCEL_CNPJ_REPASSE') = 0 THEN
				-- Se não existir valor, inserir
				pc_insere_param_sistema(pr_cdacesso => 'RECCEL_CNPJ_REPASSE'
				                       ,pr_dsvlrprm => pr_nrdocnpj
															 ,pr_dstexprm => 'CNPJ da instituição para repasse do valor de recarga de celular');
				-- Gerar log																 
				vr_dslogtel := vr_dslogtel
										|| to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
										|| to_char(SYSDATE, 'hh24:mi:ss') 
										|| ' -->  Operador '|| vr_cdoperad || ' '
										|| ' inseriu o CNPJ ' 
                    || pr_nrdocnpj || ' para a cooperativa CECRED.' || chr(10);																 															 
			ELSE -- Se existir valor, atualizar
				-- Se valor informado for diferente da base
				IF vr_nrdocnpj <> pr_nrdocnpj THEN
          -- Atualizar parâmetro
					pc_altera_param_sistema(pr_cdacesso => 'RECCEL_CNPJ_REPASSE'
																 ,pr_dsvlrprm => pr_nrdocnpj);
          -- Gerar log																 
					vr_dslogtel := vr_dslogtel
					            || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
											|| to_char(SYSDATE, 'hh24:mi:ss') 
											|| ' -->  Operador '|| vr_cdoperad || ' '
										  || ' alterou o CNPJ ' 
											|| ' de ' || vr_nrdocnpj
											|| ' para ' || pr_nrdocnpj || ' para a cooperativa CECRED.' || chr(10);																 
				END IF;															 															 															 
			END IF;

			-- Se não existir parametro
      IF fn_exists_param('RECCEL_NOME_REPASSE') = 0 THEN
				-- Se não existir valor, inserir
				pc_insere_param_sistema(pr_cdacesso => 'RECCEL_NOME_REPASSE'
				                       ,pr_dsvlrprm => pr_dsdonome
															 ,pr_dstexprm => 'Nome da instituição para repasse do valor de recarga de celular');
				-- Gerar log																 
				vr_dslogtel := vr_dslogtel
										|| to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
										|| to_char(SYSDATE, 'hh24:mi:ss') 
										|| ' -->  Operador '|| vr_cdoperad || ' '
										|| ' inseriu o NOME ' 
                    || pr_dsdonome || ' para a cooperativa CECRED.' || chr(10);																 															 
			ELSE -- Se existir valor, atualizar
				-- Se valor informado for diferente da base
				IF vr_dsdonome <> pr_dsdonome THEN
          -- Atualizar parâmetro
					pc_altera_param_sistema(pr_cdacesso => 'RECCEL_NOME_REPASSE'
																 ,pr_dsvlrprm => pr_dsdonome);
          -- Gerar log																 
					vr_dslogtel := vr_dslogtel
					            || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
											|| to_char(SYSDATE, 'hh24:mi:ss') 
											|| ' -->  Operador '|| vr_cdoperad || ' '
										  || ' alterou o NOME ' 
											|| ' de ' || vr_dsdonome
											|| ' para ' || pr_dsdonome || ' para a cooperativa CECRED.' || chr(10);																 
				END IF;															 															 															 															 
			END IF;
			
			-- Se deve gerar algum log
			IF TRIM(vr_dslogtel) IS NOT NULL THEN
				 btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
																	 ,pr_ind_tipo_log => 2 -- Erro tratato
																	 ,pr_nmarqlog     => 'parrec.log'
																	 ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
																	 ,pr_cdprograma   => 'PARREC');
      END IF;						
			
			-- Efetuar commit
			COMMIT;
						
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
																			 
				-- Efetuar Rollback
        ROLLBACK;
				
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARREC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
																			 
				-- Efetuar Rollback
        ROLLBACK;																			 
																			 
    END;

  END pc_altera_param_cecred;

  PROCEDURE pc_busca_mensagens(pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
														  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
														  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
														  ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_mensagens
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as mensagens de recarga de celular

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
			
			-- Variáveis auxiliares
			vr_dsmsgsaldo  VARCHAR2(1000);
      vr_dsmsgoperac VARCHAR2(1000);
			
			-- Buscar mensagens
			CURSOR cr_mensagem(pr_cdtipomsg tbgen_mensagem.cdtipo_mensagem%TYPE) IS
			  SELECT msg.dsmensagem
				  FROM tbgen_mensagem msg
				 WHERE msg.cdcooper = 3
				   AND msg.cdproduto = 32
					 AND msg.cdtipo_mensagem = pr_cdtipomsg;
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PARREC'
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
			
			-- Texto Minhas Mensagens Insuficiencia de Saldo
		  OPEN cr_mensagem(pr_cdtipomsg => 3);
			FETCH cr_mensagem INTO vr_dsmsgsaldo;
			CLOSE cr_mensagem;
		  -- Texto Minhas Mensagens Operação não autorizada
		  OPEN cr_mensagem(pr_cdtipomsg => 17);
			FETCH cr_mensagem INTO vr_dsmsgoperac;
			CLOSE cr_mensagem;
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<dsmsgsaldo>'  || vr_dsmsgsaldo  || '</dsmsgsaldo>'
								 || '<dsmsgoperac>' || vr_dsmsgoperac || '</dsmsgoperac>'
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
        pr_dscritic := 'Erro geral na rotina da tela PARREC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
	END pc_busca_mensagens; 
	
	PROCEDURE pc_altera_mensagens(pr_dsmsgsaldo IN tbgen_mensagem.dsmensagem%TYPE --> Mensagem insuficiência de saldo
		                           ,pr_dsmsgoperac IN tbgen_mensagem.dsmensagem%TYPE --> Mensagem operação não autorizada
		                           ,pr_xmllog   IN VARCHAR2                      --> XML com informacoes de LOG
														   ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
														   ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
														   ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
														   ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
														   ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_mensagens
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as mensagens de recarga de celular

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
			
			-- Variáveis auxiliares
			vr_dsmsgsaldo  VARCHAR2(1000);
      vr_dsmsgoperac VARCHAR2(1000);
      vr_dslogtel    VARCHAR2(32767) := '';
			
      -- Rowtypes			
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;			
			
			-- Buscar mensagens
			CURSOR cr_mensagem(pr_cdtipomsg tbgen_mensagem.cdtipo_mensagem%TYPE) IS
			  SELECT msg.dsmensagem
				  FROM tbgen_mensagem msg
				 WHERE msg.cdcooper = 3
				   AND msg.cdproduto = 32
					 AND msg.cdtipo_mensagem = pr_cdtipomsg;
					 
		BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_PARREC'
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
			
			--Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => Vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Data nao cadastrada.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
			
			-- Texto Minhas Mensagens Insuficiencia de Saldo
		  OPEN cr_mensagem(pr_cdtipomsg => 3);
			FETCH cr_mensagem INTO vr_dsmsgsaldo;
			
			-- Cria mensagem
			IF cr_mensagem%NOTFOUND THEN
				INSERT INTO tbgen_mensagem
							(cdcooper
							,cdproduto
							,cdtipo_mensagem
							,dsmensagem)
				VALUES(3
				      ,32
							,3
							,pr_dsmsgsaldo);
			ELSE
				-- Atualiza mensagem
				UPDATE tbgen_mensagem 
				   SET dsmensagem = pr_dsmsgsaldo
				 WHERE cdcooper = 3
				   AND cdproduto = 32
					 AND cdtipo_mensagem = 3;
			END IF;
			-- Fechar cursor
		  CLOSE cr_mensagem;
			
		  -- Texto Minhas Mensagens Operação não autorizada
		  OPEN cr_mensagem(pr_cdtipomsg => 17);
			FETCH cr_mensagem INTO vr_dsmsgoperac;
			
			-- Cria mensagem
			IF cr_mensagem%NOTFOUND THEN
				INSERT INTO tbgen_mensagem
							(cdcooper
							,cdproduto
							,cdtipo_mensagem
							,dsmensagem)
				VALUES(3
				      ,32
							,17
							,pr_dsmsgoperac);
			ELSE
				-- Atualiza mensagem
				UPDATE tbgen_mensagem 
				   SET dsmensagem = pr_dsmsgoperac
				 WHERE cdcooper = 3
				   AND cdproduto = 32
					 AND cdtipo_mensagem = 17;
			END IF;
			-- Fechar cursor
		  CLOSE cr_mensagem;

		  -- Se alterou mensagem de insuficiência de saldo
		  IF nvl(vr_dsmsgsaldo, ' ') <> nvl(pr_dsmsgsaldo, ' ') THEN
			  vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou a mensagem de INSUFICIENCIA DE SALDO.' || chr(10);
		  END IF;
			
		  -- Se alterou mensagem de insuficiência de saldo
		  IF nvl(vr_dsmsgoperac, ' ') <> nvl(pr_dsmsgoperac, ' ') THEN
			  vr_dslogtel := vr_dslogtel
				            || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			              || to_char(SYSDATE, 'hh24:mi:ss') 
                    || ' -->  Operador '|| vr_cdoperad || ' '
                    || ' alterou a mensagem de OPERACAO NAO AUTORIZADA.' || chr(10);
		  END IF;
			
			-- Se deve gerar algum log
			IF TRIM(vr_dslogtel) IS NOT NULL THEN
				 btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
																	 ,pr_ind_tipo_log => 2 -- Erro tratato
																	 ,pr_nmarqlog     => 'parrec.log'
																	 ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
																	 ,pr_cdprograma   => 'PARREC');
      END IF;						
			
			-- Efetuar commit
			COMMIT;

			
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
        pr_dscritic := 'Erro geral na rotina da tela PARREC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
	END pc_altera_mensagens;

END TELA_PARREC; 
/
