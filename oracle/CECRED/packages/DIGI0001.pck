CREATE OR REPLACE PACKAGE CECRED.DIGI0001 AS

  PROCEDURE pc_acessa_dossie(pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da conta
  		                      ,pr_cdproduto IN INTEGER               --> Código do produto
														,pr_nmdatela_log IN VARCHAR2              --> Nome da tela
														,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
														,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
														,pr_dscritic  OUT VARCHAR2             --> Descricao da critica
														,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
														,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro  OUT VARCHAR2);           --> Erros do processo


END DIGI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DIGI0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: DIGI0001
  --    Autor   : Lucas Reinert
  --    Data    : Março/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package responsável pelas rotinas do DIGIDOC
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_acessa_dossie(pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da conta
  		                      ,pr_cdproduto IN INTEGER               --> Código do produto
														,pr_nmdatela_log IN VARCHAR2              --> Nome da tela														
														,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
														,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
														,pr_dscritic  OUT VARCHAR2             --> Descricao da critica
														,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
														,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_acessa_dossie
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Março/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para retornar a key da URL para acesso ao digidoc

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
			
			-- Variável para geração de log
			vr_dstransa VARCHAR2(4000);
			vr_rowid    ROWID;
			
			-- Variáveis auxiliáres
			vr_chave    VARCHAR2(20);
			
			-- Buscar indicador de pessoa
			CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
			                  ,pr_nrdconta crapass.nrdconta%TYPE) IS
				SELECT ass.inpessoa
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;									
			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'DIGI0001'
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
																							
			CASE pr_cdproduto
				WHEN 1 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Cartao Credito.';
					vr_chave    := 'xTCxe';
				WHEN 2 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Cobranca Bancaria.';
					vr_chave    := 'HRZfo';
				WHEN 3 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Consorcio.';
					vr_chave    := 'M1XMZ';
				WHEN 4 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc CDC.';
					vr_chave    := 'vyp8v';
				WHEN 5 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Folha de Pagamento.';
					vr_chave    := '99OXz';
				WHEN 6 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Portabilidade de Credito.';
					vr_chave    := 'b8834';
				WHEN 7 THEN
					vr_dstransa := 'Consulta Dossie DigiDoc Seguro.';
					vr_chave    := 'v0BVs';
				WHEN 8 THEN
					-- Buscar tipo de pessoa
					OPEN cr_crapass(pr_cdcooper => vr_cdcooper
												 ,pr_nrdconta => pr_nrdconta);															
					FETCH cr_crapass INTO rw_crapass;
					
					-- Se não encontrar associado
					IF cr_crapass%NOTFOUND THEN
						-- Gerar crítica
						vr_cdcritic := 9;
						vr_dscritic := '';
						-- Levantar exceção
						RAISE vr_exc_erro;
					END IF;
					
					-- Se retornou algum erro
					IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						-- Levanta exceção
						RAISE vr_exc_erro;
					END IF;

					-- Se for PF
					IF rw_crapass.inpessoa = 1 THEN
						vr_dstransa := 'Consulta Dossie DigiDoc Dados Pessoais.';						
					ELSE -- Se for PJ
						vr_dstransa := 'Consulta Dossie DigiDoc Identificacao.';
					END IF;
					vr_chave    := 'iSQlN';
				WHEN 9 THEN
					vr_dstransa := 'Consulta Cartao Assinatura.';
					vr_chave    := '8O3ky';
				ELSE
					-- Gerar crítica
					vr_dscritic := 'Produto não encontrado.';
					-- Levantar exceção
					RAISE vr_exc_erro;
				END CASE;

        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => null
														,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
														,pr_dstransa => vr_dstransa
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 1 --> TRUE
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => 1
														,pr_nmdatela => pr_nmdatela_log
														,pr_nrdconta => pr_nrdconta
												    ,pr_nrdrowid => vr_rowid);
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<chave>' || vr_chave || '</chave>'
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
        pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela_log ||': ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_acessa_dossie;
  
END DIGI0001; 
/
