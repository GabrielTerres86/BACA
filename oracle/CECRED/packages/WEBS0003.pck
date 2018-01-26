CREATE OR REPLACE PACKAGE CECRED.WEBS0003 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0003
  --  Sistema  : Rotinas referentes ao WebService
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Outubro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  
	--> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper              IN tbgen_webservice_aciona.cdcooper%TYPE              --> Código da cooperativa
                                ,pr_cdagenci              IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE  --> PA
                                ,pr_cdoperad              IN tbgen_webservice_aciona.cdoperad%TYPE              --> Operador
                                ,pr_cdorigem              IN tbgen_webservice_aciona.cdorigem%TYPE              --> Origem
															  ,pr_nrctrprp              IN tbgen_webservice_aciona.nrctrprp%TYPE              --> Nr. contrato da proposta
															  ,pr_nrdconta							IN tbgen_webservice_aciona.nrdconta%TYPE		          --> Nr. da conta 
                                ,pr_cdcliente             IN PLS_INTEGER                                        --> Código do cliente
                                ,pr_tpacionamento         IN tbgen_webservice_aciona.tpacionamento%TYPE         --> Tipo acionamento (1 - Entrada, 2 - Saída)
                                ,pr_dsoperacao            IN tbgen_webservice_aciona.dsoperacao%TYPE            --> Descrição operação
                                ,pr_dsuriservico          IN tbgen_webservice_aciona.dsuriservico%TYPE          --> URI usada
																,pr_dsmetodo              IN VARCHAR2                                           --> Método (post, put, delete, get)
                                ,pr_dtmvtolt              IN tbgen_webservice_aciona.dtmvtolt%TYPE              --> Data de movimento
                                ,pr_dhacionamento         IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP --> Data e hora acionamento
                                ,pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução
                                ,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteúdo requisição
                                ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta requisição
                                ,pr_dsprotocolo           IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL --> Protocolo do Acionamento
                                ,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE             --> Flag reenvio (0-Não, 1-Sim)
                                ,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE              --> Número de reenvios
																,pr_tpconteudo            IN tbgen_webservice_aciona.tpconteudo%TYPE             --> Tipo conteúdo (1-Json, 2-xml)
																,pr_tpproduto             IN tbgen_webservice_aciona.tpproduto%TYPE              --> Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                                ,pr_idacionamento         OUT tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento
                                ,pr_dscritic              OUT VARCHAR2);                                         --> Desc. crítica
																
	--> Rotina responsavel por gravar registro de log de acionamento para web
  PROCEDURE pc_grava_acionamento_web(pr_cdcooper              IN tbgen_webservice_aciona.cdcooper%TYPE              --> Código da cooperativa
																		,pr_cdagenci              IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE  --> PA
																		,pr_cdoperad              IN tbgen_webservice_aciona.cdoperad%TYPE              --> Operador
																		,pr_cdorigem              IN tbgen_webservice_aciona.cdorigem%TYPE              --> Origem
																		,pr_nrctrprp              IN tbgen_webservice_aciona.nrctrprp%TYPE              --> Nr. contrato da proposta
																		,pr_nrdconta							IN tbgen_webservice_aciona.nrdconta%TYPE		          --> Nr. da conta 
																		,pr_cdcliente             IN PLS_INTEGER                                        --> Código do cliente
																		,pr_tpacionamento         IN tbgen_webservice_aciona.tpacionamento%TYPE         --> Tipo acionamento (1 - Entrada, 2 - Saída)
																		,pr_dsoperacao            IN tbgen_webservice_aciona.dsoperacao%TYPE            --> Descrição operação
																		,pr_dsuriservico          IN tbgen_webservice_aciona.dsuriservico%TYPE          --> URI usada
																		,pr_dsmetodo              IN VARCHAR2                                           --> Método (post, put, delete, get)
																		,pr_dtmvtolt              IN VARCHAR2                                           --> Data de movimento
																		,pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução
																		,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteúdo requisição
																		,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta requisição
																		,pr_dsprotocolo           IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL --> Protocolo do Acionamento
																		,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE             --> Flag reenvio (0-Não, 1-Sim)
																		,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE              --> Número de reenvios
																		,pr_tpconteudo            IN tbgen_webservice_aciona.tpconteudo%TYPE             --> Tipo conteúdo (1-Json, 2-xml)
																		,pr_tpproduto             IN tbgen_webservice_aciona.tpproduto%TYPE              --> Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                                    ,pr_xmllog                IN VARCHAR2                                            --> XML com informações de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER                                        --> Código da crítica
                                    ,pr_dscritic              OUT VARCHAR2                                           --> Descrição da crítica
                                    ,pr_retxml                IN OUT NOCOPY xmltype                                  --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2                                           --> Nome do Campo
                                    ,pr_des_erro              OUT VARCHAR2);                                         --> Saida OK/NOK

	--> Rotina responsavel por atualizar registro de log de acionamento
  PROCEDURE pc_atualiza_acionamento(pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução																
																   ,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE            --> Flag reenvio (0-Não, 1-Sim)																
                                   ,pr_idacionamento         IN tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento																
                                   ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta
																	 ,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE DEFAULT NULL --> Número de reenvios
                                   ,pr_dscritic              OUT VARCHAR2);                                        --> Desc. crítica
																	 
	--> Rotina responsavel por atualizar registro de log de acionamento
  PROCEDURE pc_atualiza_acionamento_web(pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução																
																       ,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE            --> Flag reenvio (0-Não, 1-Sim)																
                                       ,pr_idacionamento         IN tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento																
                                       ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta
																			 ,pr_xmllog                IN VARCHAR2                                            --> XML com informações de LOG
																			 ,pr_cdcritic              OUT PLS_INTEGER                                        --> Código da crítica
																			 ,pr_dscritic              OUT VARCHAR2                                           --> Descrição da crítica
																			 ,pr_retxml                IN OUT NOCOPY xmltype                                  --> Arquivo de retorno do XML
																			 ,pr_nmdcampo              OUT VARCHAR2                                           --> Nome do Campo
																			 ,pr_des_erro              OUT VARCHAR2);                                         --> Saida OK/NOK		
																			 
  --> Rotina responsável por gravar os erros em arquivo de log
  PROCEDURE pc_grava_requisicao_erro(pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                    ,pr_dsmessag IN VARCHAR2              --> Descricao da mensagem de erro
																		,pr_nmarqlog IN VARCHAR2              --> Nome do arquivo de log
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  																			 
END WEBS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WEBS0003 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0003
  --  Sistema  : Rotinas referentes ao WebService
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Outubro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

	--> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper              IN tbgen_webservice_aciona.cdcooper%TYPE              --> Código da cooperativa
                                ,pr_cdagenci              IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE  --> PA
                                ,pr_cdoperad              IN tbgen_webservice_aciona.cdoperad%TYPE              --> Operador
                                ,pr_cdorigem              IN tbgen_webservice_aciona.cdorigem%TYPE              --> Origem
															  ,pr_nrctrprp              IN tbgen_webservice_aciona.nrctrprp%TYPE              --> Nr. contrato da proposta
															  ,pr_nrdconta							IN tbgen_webservice_aciona.nrdconta%TYPE		          --> Nr. da conta 
                                ,pr_cdcliente             IN PLS_INTEGER                                        --> Código do cliente
                                ,pr_tpacionamento         IN tbgen_webservice_aciona.tpacionamento%TYPE         --> Tipo acionamento (1 - Entrada, 2 - Saída)
                                ,pr_dsoperacao            IN tbgen_webservice_aciona.dsoperacao%TYPE            --> Descrição operação
                                ,pr_dsuriservico          IN tbgen_webservice_aciona.dsuriservico%TYPE          --> URI usada
																,pr_dsmetodo              IN VARCHAR2                                           --> Método (post, put, delete, get)
                                ,pr_dtmvtolt              IN tbgen_webservice_aciona.dtmvtolt%TYPE              --> Data de movimento
                                ,pr_dhacionamento         IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP --> Data e hora acionamento
                                ,pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução
                                ,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteúdo requisição
                                ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta requisição
                                ,pr_dsprotocolo           IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL --> Protocolo do Acionamento
																,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE             --> Flag reenvio (0-Não, 1-Sim)
																,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE              --> Número de reenvios
																,pr_tpconteudo            IN tbgen_webservice_aciona.tpconteudo%TYPE             --> Tipo conteúdo (1-Json, 2-xml)
																,pr_tpproduto             IN tbgen_webservice_aciona.tpproduto%TYPE              --> Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                                ,pr_idacionamento         OUT tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento
                                ,pr_dscritic              OUT VARCHAR2) IS                                       --> Desc. crítica
		
		/* ..........................................................................
          
			Programa : pc_grava_acionamento        
			Sistema  : Conta-Corrente - Cooperativa de Credito
			Sigla    : CRED
			Autor    : Lucas Reinert
			Data     : Outubro/2017.                   Ultima atualizacao: 
          
			Dados referentes ao programa:
          
			Frequencia: Sempre que for chamado
			Objetivo  : Grava registro de log de acionamento
          
			Alteração : 
              
		..........................................................................*/
		PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN
			INSERT INTO tbgen_webservice_aciona
						(cdcooper,
						 cdagenci_acionamento,
						 cdoperad,
						 cdorigem,
						 nrctrprp,
						 nrdconta,
						 tpacionamento,
						 dhacionamento,
						 dsoperacao,
						 dsuriservico,
						 dtmvtolt,
						 cdstatus_http,
						 dsconteudo_requisicao,
						 dsresposta_requisicao,
						 dsprotocolo,
 						 cdcliente,
						 dsmetodo,
						 flgreenvia,						 
						 nrreenvio,
						 tpconteudo,
						 tpproduto)
      VALUES(pr_cdcooper,
						 pr_cdagenci,
						 pr_cdoperad,
						 pr_cdorigem,
						 pr_nrctrprp,
						 pr_nrdconta,
						 pr_tpacionamento,
             pr_dhacionamento,
						 pr_dsoperacao,
						 pr_dsuriservico,
						 pr_dtmvtolt,
						 pr_cdstatus_http,
						 pr_dsconteudo_requisicao,
						 pr_dsresposta_requisicao,
						 pr_dsprotocolo,
 						 pr_cdcliente,
						 pr_dsmetodo,
						 pr_flgreenvia,
						 pr_nrreenvio,
						 pr_tpconteudo,
						 pr_tpproduto)
			RETURNING tbgen_webservice_aciona.idacionamento INTO pr_idacionamento;
		
			--> Commit para garantir que guarde as informações do log de acionamento
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				pr_dscritic := 'Erro ao inserir tbgen_webservice_aciona: ' || SQLERRM;
				ROLLBACK;
	END pc_grava_acionamento;
	
	--> Rotina responsavel por gravar registro de log de acionamento para web
  PROCEDURE pc_grava_acionamento_web(pr_cdcooper              IN tbgen_webservice_aciona.cdcooper%TYPE              --> Código da cooperativa
																		,pr_cdagenci              IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE  --> PA
																		,pr_cdoperad              IN tbgen_webservice_aciona.cdoperad%TYPE              --> Operador
																		,pr_cdorigem              IN tbgen_webservice_aciona.cdorigem%TYPE              --> Origem
																		,pr_nrctrprp              IN tbgen_webservice_aciona.nrctrprp%TYPE              --> Nr. contrato da proposta
																		,pr_nrdconta							IN tbgen_webservice_aciona.nrdconta%TYPE		          --> Nr. da conta 
																		,pr_cdcliente             IN PLS_INTEGER                                        --> Código do cliente
																		,pr_tpacionamento         IN tbgen_webservice_aciona.tpacionamento%TYPE         --> Tipo acionamento (1 - Entrada, 2 - Saída)
																		,pr_dsoperacao            IN tbgen_webservice_aciona.dsoperacao%TYPE            --> Descrição operação
																		,pr_dsuriservico          IN tbgen_webservice_aciona.dsuriservico%TYPE          --> URI usada
																		,pr_dsmetodo              IN VARCHAR2                                           --> Método (post, put, delete, get)
																		,pr_dtmvtolt              IN VARCHAR2                                           --> Data de movimento
																		,pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução
																		,pr_dsconteudo_requisicao IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE --> Conteúdo requisição
																		,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta requisição
																		,pr_dsprotocolo           IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL --> Protocolo do Acionamento
																		,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE             --> Flag reenvio (0-Não, 1-Sim)
																		,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE              --> Número de reenvios
																		,pr_tpconteudo            IN tbgen_webservice_aciona.tpconteudo%TYPE             --> Tipo conteúdo (1-Json, 2-xml)
																		,pr_tpproduto             IN tbgen_webservice_aciona.tpproduto%TYPE              --> Tipo de produto (0-Emprestimo|Financiamento / 1-Limite Credito / 2-Limite Desconto Cheque / 3-Limite Desconto Titulo)
                                    ,pr_xmllog                IN VARCHAR2                                            --> XML com informações de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER                                        --> Código da crítica
                                    ,pr_dscritic              OUT VARCHAR2                                           --> Descrição da crítica
                                    ,pr_retxml                IN OUT NOCOPY xmltype                                  --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2                                           --> Nome do Campo
                                    ,pr_des_erro              OUT VARCHAR2) IS                                       --> Saida OK/NOK
		/* ..........................................................................
          
			Programa : pc_grava_acionamento_web
			Sistema  : Conta-Corrente - Cooperativa de Credito
			Sigla    : CRED
			Autor    : Lucas Reinert
			Data     : Outubro/2017.                   Ultima atualizacao: 
          
			Dados referentes ao programa:
          
			Frequencia: Sempre que for chamado
			Objetivo  : Grava registro de log de acionamento para web
          
			Alteração : 
              
		..........................................................................*/
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Variáveis auxiliáres
		vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;

    BEGIN		
			-- Incluir nome do módulo logado
			GENE0001.pc_informa_acesso(pr_module => 'WEBS0003'
																,pr_action => null);
																
			-- Chamar rotina de acionamento
      pc_grava_acionamento(pr_cdcooper => pr_cdcooper 
													,pr_cdagenci => pr_cdagenci 
													,pr_cdoperad => pr_cdoperad 
													,pr_cdorigem => pr_cdorigem 
													,pr_nrctrprp => pr_nrctrprp 
													,pr_nrdconta => pr_nrdconta	
													,pr_cdcliente => pr_cdcliente
													,pr_tpacionamento => pr_tpacionamento 
													,pr_dsoperacao => pr_dsoperacao
													,pr_dsuriservico => pr_dsuriservico
													,pr_dsmetodo => pr_dsmetodo
													,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
													,pr_cdstatus_http => pr_cdstatus_http
													,pr_dsconteudo_requisicao => replace(pr_dsconteudo_requisicao, '&quot;', '"')
													,pr_dsresposta_requisicao => pr_dsresposta_requisicao
													,pr_dsprotocolo => pr_dsprotocolo
													,pr_flgreenvia => pr_flgreenvia 
													,pr_nrreenvio => pr_nrreenvio
													,pr_tpconteudo => pr_tpconteudo 
													,pr_tpproduto => pr_tpproduto
													,pr_idacionamento => vr_idacionamento
													,pr_dscritic => vr_dscritic);
													
			-- Se retornou alguma crítica							
		  IF TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Carregar XML padrao para variavel de retorno
			pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><idacionamento>' || vr_idacionamento || '</idacionamento></Root>');			

		EXCEPTION
			WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral no programa: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	END pc_grava_acionamento_web;

	--> Rotina responsavel por atualizar registro de log de acionamento
  PROCEDURE pc_atualiza_acionamento(pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução																
																   ,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE            --> Flag reenvio (0-Não, 1-Sim)																
                                   ,pr_idacionamento         IN tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento																
                                   ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta
																	 ,pr_nrreenvio             IN tbgen_webservice_aciona.nrreenvio%TYPE DEFAULT NULL --> Número de reenvios
                                   ,pr_dscritic              OUT VARCHAR2) IS                                      --> Desc. crítica
		/* ..........................................................................
          
			Programa : pc_atualiza_acionamento        
			Sistema  : Conta-Corrente - Cooperativa de Credito
			Sigla    : CRED
			Autor    : Lucas Reinert
			Data     : Novembro/2017.                   Ultima atualizacao: 
          
			Dados referentes ao programa:
          
			Frequencia: Sempre que for chamado
			Objetivo  : Atualiza registro de log de acionamento
          
			Alteração : 
              
		..........................................................................*/
		PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN
			UPDATE tbgen_webservice_aciona
			   SET cdstatus_http         = pr_cdstatus_http
				    ,flgreenvia            = pr_flgreenvia
						,dsresposta_requisicao = replace(pr_dsresposta_requisicao, '&quot;', '"')
						,nrreenvio             = nvl(pr_nrreenvio, nrreenvio)
			 WHERE idacionamento = pr_idacionamento;
		
			--> Commit para garantir que guarde as informações do log de acionamento
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				pr_dscritic := 'Erro ao atualizar tbgen_webservice_aciona: ' || SQLERRM;
				ROLLBACK;
	END pc_atualiza_acionamento;

	--> Rotina responsavel por atualizar registro de log de acionamento
  PROCEDURE pc_atualiza_acionamento_web(pr_cdstatus_http         IN tbgen_webservice_aciona.cdstatus_http%TYPE         --> Status de execução																
																       ,pr_flgreenvia            IN tbgen_webservice_aciona.flgreenvia%TYPE            --> Flag reenvio (0-Não, 1-Sim)																
                                       ,pr_idacionamento         IN tbgen_webservice_aciona.idacionamento%TYPE         --> Identificador do acionamento																
                                       ,pr_dsresposta_requisicao IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE --> Conteúdo resposta
																			 ,pr_xmllog                IN VARCHAR2                                           --> XML com informações de LOG
																			 ,pr_cdcritic              OUT PLS_INTEGER                                       --> Código da crítica
																			 ,pr_dscritic              OUT VARCHAR2                                          --> Descrição da crítica
																			 ,pr_retxml                IN OUT NOCOPY xmltype                                 --> Arquivo de retorno do XML
																			 ,pr_nmdcampo              OUT VARCHAR2                                          --> Nome do Campo
																			 ,pr_des_erro              OUT VARCHAR2) IS                                      --> Saida OK/NOK		
		/* ..........................................................................
          
			Programa : pc_atualiza_acionamento_web
			Sistema  : Conta-Corrente - Cooperativa de Credito
			Sigla    : CRED
			Autor    : Lucas Reinert
			Data     : Novembro/2017.                   Ultima atualizacao: 
          
			Dados referentes ao programa:
          
			Frequencia: Sempre que for chamado
			Objetivo  : Atualiza registro de log de acionamento
          
			Alteração : 
              
		..........................................................................*/
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_dscritic crapcri.dscritic%TYPE;

		BEGIN
			-- Incluir nome do módulo logado
			GENE0001.pc_informa_acesso(pr_module => 'WEBS0003'
																,pr_action => null);			
		
		  -- Chamar procedure para atualizar acionamento
      pc_atualiza_acionamento(pr_cdstatus_http         => pr_cdstatus_http
			                       ,pr_flgreenvia            => pr_flgreenvia
														 ,pr_idacionamento         => pr_idacionamento
														 ,pr_dsresposta_requisicao => pr_dsresposta_requisicao
														 ,pr_dscritic              => vr_dscritic);
			-- Se retornou alguma crítica								 
		  IF TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			--> Commit para garantir que guarde as informações do log de acionamento
			COMMIT;
		EXCEPTION
			WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral no programa: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	END pc_atualiza_acionamento_web;

  PROCEDURE pc_grava_requisicao_erro(pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                    ,pr_dsmessag IN VARCHAR2              --> Descricao da mensagem de erro
																		,pr_nmarqlog IN VARCHAR2              --> Nome do arquivo de log
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo  
  BEGIN
    /* .............................................................................
     Programa: pc_grava_requisicao_erro
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Lucas Reinert
     Data    : Abril/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gravar mensagem de erro no LOG

     Observacao: -----
     
     Alteracoes:      
     ..............................................................................*/
    DECLARE
      vr_des_log        VARCHAR2(4000);      
      vr_dsdirlog       VARCHAR2(100);
			vr_dsrequicao     VARCHAR2(4000);
    BEGIN
			vr_dsrequicao := REPLACE(pr_dsrequis, '<![CDATA[', '');
		  vr_dsrequicao := REPLACE(vr_dsrequicao, ']]>', '');
      -- Diretorio do arquivo      
      vr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => 'log/webservices');      
      -- Mensagem de LOG
      vr_des_log  := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                     ' - ' || 
                     'Requisicao: ' || vr_dsrequicao  || 
                     ' - ' || 
                     'Resposta: ' || pr_dsmessag;
                     
      -- Criacao do arquivo
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => DBMS_XMLGEN.CONVERT(vr_des_log, DBMS_XMLGEN.ENTITY_DECODE)
                                ,pr_nmarqlog     => pr_nmarqlog || '-' || TO_CHAR(SYSDATE,'DD-MM-RRRR')
                                ,pr_dsdirlog     => vr_dsdirlog);
                                
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END;                            
      
  END pc_grava_requisicao_erro;


END WEBS0003;
/
