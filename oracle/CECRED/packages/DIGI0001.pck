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

  PROCEDURE pc_gera_pend_digitalizacao(pr_cdcooper  IN crapdoc.cdcooper%TYPE DEFAULT 0 --> Codigo da cooperativa 
                                      ,pr_nrdconta  IN crapdoc.nrdconta%TYPE DEFAULT 0 --> Nr. da conta
                                      ,pr_idseqttl  IN crapdoc.idseqttl%TYPE DEFAULT 0 --> Indicador de titular
                                      ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE           --> Numero do CPF/CNPJ
                                      ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE           --> Data do movimento
                                      ,pr_lstpdoct  IN VARCHAR2                        --> lista de Tipo do documento separados por ;
                                      ,pr_cdoperad  IN crapdoc.cdoperad%TYPE           --> Codigo do operador
                                      ,pr_nrseqdoc  IN crapdoc.nrseqdoc%TYPE DEFAULT 0 --> Numero seq. do documento quando houver(Ex. Sequencial do Bem)
                                      ,pr_cdcritic  OUT PLS_INTEGER                    --> Codigo da critica
                                      ,pr_dscritic  OUT VARCHAR2 );                    --> Descricao da critica
                                      
  PROCEDURE pc_grava_pend_digitalizacao( pr_cdcooper  IN crapdoc.cdcooper%TYPE --> Codigo da cooperativa 
                                        ,pr_nrdconta  IN crapdoc.nrdconta%TYPE --> Nr. da conta
                                        ,pr_idseqttl  IN crapdoc.idseqttl%TYPE --> Indicador de titular
                                        ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                        ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_tpdocmto  IN crapdoc.tpdocmto%TYPE --> Tipo do documento
                                        ,pr_cdoperad  IN crapdoc.cdoperad%TYPE --> Codigo do operador
                                        ,pr_nrseqdoc  IN crapdoc.nrseqdoc%TYPE DEFAULT 0 --> Numero seq. do documento quando houver(Ex. Sequencial do Bem)
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2 );         --> Descricao da critica                                      
                                                                                  

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

    Alteracoes: 
                25/07/2019 - Alteração para novo viewer do Smartshare (PRB0041878 - Joao Mannes - Mouts)
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
				SELECT ass.inpessoa, ass.nrcpfcgc
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
   					vr_chave    := 'mwRrO';
					ELSE -- Se for PJ
						vr_dstransa := 'Consulta Dossie DigiDoc Identificacao.';
					vr_chave    := 'iSQlN';
					END IF;

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
                 || '<inpessoa>' || rw_crapass.inpessoa || '</inpessoa>'
                 || '<nrcpfcgc>' || gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, rw_crapass.inpessoa) || '</nrcpfcgc>'
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
  
  PROCEDURE pc_gera_pend_digitalizacao(pr_cdcooper  IN crapdoc.cdcooper%TYPE DEFAULT 0 --> Codigo da cooperativa 
                                      ,pr_nrdconta  IN crapdoc.nrdconta%TYPE DEFAULT 0 --> Nr. da conta
                                      ,pr_idseqttl  IN crapdoc.idseqttl%TYPE DEFAULT 0 --> Indicador de titular
                                      ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE           --> Numero do CPF/CNPJ
                                      ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE           --> Data do movimento
                                      ,pr_lstpdoct  IN VARCHAR2                        --> lista de Tipo do documento separados por ;
                                      ,pr_cdoperad  IN crapdoc.cdoperad%TYPE           --> Codigo do operador
                                      ,pr_nrseqdoc  IN crapdoc.nrseqdoc%TYPE DEFAULT 0 --> Numero seq. do documento quando houver(Ex. Sequencial do Bem)
                                      ,pr_cdcritic  OUT PLS_INTEGER                    --> Codigo da critica
                                      ,pr_dscritic  OUT VARCHAR2 ) IS                  --> Descricao da critica
                                      

    /* .............................................................................
    Programa: pc_gera_pend_digitalizacao
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Fevereiro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar pendencias de digitalização de documentos

    Alteracoes: -----
    ..............................................................................*/
    
    ---------------> CURSORES <-----------------
    --> Identificar cooperativa pelo operador informado
    CURSOR cr_crapope (pr_cdoperad crapope.cdoperad%TYPE)IS 
      SELECT ope.cdcooper
        FROM crapope ope
       WHERE ope.cdoperad = pr_cdoperad; 
       
    --> Identificar cooperado
    CURSOR cr_crapass ( pr_cddooper crapass.cdcooper%TYPE,
                        pr_nrcpfcgc crapass.nrcpfcgc%TYPE )IS
      SELECT ass.nrdconta,
             decode(ass.inpessoa,1,1,0) idseqttl,
             ass.cdtipcta,
             tpc.cdmodalidade_tipo,
             ass.dtultalt
        FROM crapass ass,
             tbcc_tipo_conta tpc
       WHERE ass.cdtipcta = tpc.cdtipo_conta         
         AND ass.inpessoa = tpc.inpessoa
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcgc = pr_nrcpfcgc
         AND ass.dtdemiss IS NULL
      UNION
      SELECT ass.nrdconta,
             ttl.idseqttl,
             ass.cdtipcta,
             tpc.cdmodalidade_tipo,
             ass.dtultalt
        FROM crapass ass,
             crapttl ttl,
             tbcc_tipo_conta tpc
       WHERE ass.cdtipcta = tpc.cdtipo_conta
         AND ass.cdcooper = ttl.cdcooper
         AND ass.nrdconta = ttl.nrdconta
         AND ttl.cdcooper = pr_cdcooper
         AND ttl.nrcpfcgc = pr_nrcpfcgc
         AND ass.dtdemiss IS NULL
       ORDER BY dtultalt DESC;
             
    
    --------------> VARIAVEIS <-----------------    
    -- Variavel de criticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_return    EXCEPTION;
    
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_idseqttl      crapttl.idseqttl%TYPE;
    vr_tab_tpdocmto  gene0002.typ_split;
    
    
    -------------> SUB-ROTINAS <----------------  
    PROCEDURE pc_gerar_pend ( pr_cdcooper  IN crapdoc.cdcooper%TYPE --> Nr. da conta
                             ,pr_nrdconta  IN crapdoc.nrdconta%TYPE --> Código do produto
                             ,pr_idseqttl  IN crapdoc.idseqttl%TYPE --> Indicador de titular
                             ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                             ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE --> Data do movimento
                             ,pr_tpdocmto  IN crapdoc.tpdocmto%TYPE --> Tipo do documento
                             ,pr_cdoperad  IN crapdoc.cdoperad%TYPE --> Codigo do operador
                             ,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2 ) IS        --> Descricao da critica    
    
    BEGIN
      
      vr_nrdconta := NULL;  
     
      --> Caso nao tenha sido informado a conta, 
      -- deve localizar pelo CPF/CNPJ
      IF nvl(pr_nrdconta,0) = 0 AND 
         nvl(pr_nrcpfcgc,0) > 0 THEN
         
        -- Identificar conta do cooperado
        FOR rw_crapass IN cr_crapass( pr_cddooper => pr_nrdconta,
                                      pr_nrcpfcgc => pr_nrcpfcgc) LOOP
                                      
          --> 5 - Comprovante de residência
          IF pr_tpdocmto = 5 THEN
            --> para modalidade Conta salario e aplicacao nao deve gerar pendencia
            IF rw_crapass.cdmodalidade_tipo IN (2,3) THEN
              --> buscar proxima conta
              Continue;
            END IF;    
          END IF;
          
          vr_nrdconta := rw_crapass.nrdconta;
          vr_idseqttl := rw_crapass.idseqttl;
          --> Caso ja localizou deve sair do loop
          EXIT;
                                      
        END LOOP;    
      ELSE
      
        vr_nrdconta := pr_nrdconta;
        vr_idseqttl := pr_idseqttl;
      
      END IF;
      
      --> Caso encontrou alguma conta
      IF nvl(vr_nrdconta,0) <> 0 THEN
      
        --> Gravar pendencia
        DIGI0001.pc_grava_pend_digitalizacao ( pr_cdcooper  => pr_cdcooper       --> Nr. da conta
                                              ,pr_nrdconta  => vr_nrdconta       --> Código do produto
                                              ,pr_idseqttl  => vr_idseqttl       --> Indicador de titular
                                              ,pr_nrcpfcgc  => pr_nrcpfcgc       --> Numero do CPF/CNPJ
                                              ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento
                                              ,pr_tpdocmto  => pr_tpdocmto       --> Tipo do documento
                                              ,pr_cdoperad  => pr_cdoperad       --> Codigo do operador
                                              ,pr_nrseqdoc  => pr_nrseqdoc       --> Numero seq. do documento quando houver(Ex. Sequencial do Bem)
                                              ,pr_cdcritic  => vr_cdcritic       --> Codigo da critica
                                              ,pr_dscritic  => vr_dscritic);     --> Descricao da critica
                                      
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;            
        END IF;    
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;        
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao gerar pendencia: '||SQLERRM;        
    END pc_gerar_pend;
    
    
  BEGIN
    
    vr_tab_tpdocmto := gene0002.fn_quebra_string(pr_lstpdoct,';');
    IF vr_tab_tpdocmto.count() = 0 THEN
      vr_dscritic := 'Tipo de documento deve ser informado.';
      RAISE vr_exc_erro;
    END IF;
    
  
    --> Caso nao foi informado a cooperativa
    IF nvl(pr_cdcooper,0) = 0  THEN
      --> identificar cooperativa pelo operador informado    
      FOR rw_crapope IN cr_crapope(pr_cdoperad => pr_cdoperad) LOOP
      
        --> Gerar pendencia para cada tipo de documento informado
        FOR idx IN vr_tab_tpdocmto.first..vr_tab_tpdocmto.last LOOP
          --> Gravar pendencia
          pc_gerar_pend( pr_cdcooper  => rw_crapope.cdcooper       --> Nr. da conta
                        ,pr_nrdconta  => pr_nrdconta               --> Código do produto
                        ,pr_idseqttl  => pr_idseqttl               --> Indicador de titular
                        ,pr_nrcpfcgc  => pr_nrcpfcgc               --> Numero do CPF/CNPJ
                        ,pr_dtmvtolt  => pr_dtmvtolt               --> Data do movimento
                        ,pr_tpdocmto  => vr_tab_tpdocmto(idx)      --> Tipo do documento
                        ,pr_cdoperad  => pr_cdoperad               --> Codigo do operador
                        ,pr_cdcritic  => vr_cdcritic               --> Codigo da critica
                        ,pr_dscritic  => vr_dscritic);             --> Descricao da critica
                                        
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;            
          END IF;    
        
        END LOOP; --> Fim vr_tab_tpdocmto
      
      END LOOP; --> Fim cr_crapope
    
    
    ELSE
      --> Gerar pendencia para cada tipo de documento informado
      FOR idx IN vr_tab_tpdocmto.first..vr_tab_tpdocmto.last LOOP
        --> Gravar pendencia
        pc_gerar_pend( pr_cdcooper  => pr_cdcooper               --> Nr. da conta
                      ,pr_nrdconta  => pr_nrdconta               --> Código do produto
                      ,pr_idseqttl  => pr_idseqttl               --> Indicador de titular
                      ,pr_nrcpfcgc  => pr_nrcpfcgc               --> Numero do CPF/CNPJ
                      ,pr_dtmvtolt  => pr_dtmvtolt               --> Data do movimento
                      ,pr_tpdocmto  => vr_tab_tpdocmto(idx)      --> Tipo do documento
                      ,pr_cdoperad  => pr_cdoperad               --> Codigo do operador
                      ,pr_cdcritic  => vr_cdcritic               --> Codigo da critica
                      ,pr_dscritic  => vr_dscritic);             --> Descricao da critica
                                        
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;            
        END IF;    
        
      END LOOP; --> Fim vr_tab_tpdocmto
    END IF;    
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel gerar pendencia: '||SQLERRM;
    
  END pc_gera_pend_digitalizacao;    
  
  FUNCTION fn_valida_doc_renda(  pr_cdcooper  IN crapdoc.cdcooper%TYPE --> Nr. da conta
                                ,pr_nrdconta  IN crapdoc.nrdconta%TYPE --> Código do produto
                                ,pr_idseqttl  IN crapdoc.idseqttl%TYPE --> Indicador de titular
                                ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE --> Data do movimento
                                ,pr_tpdocmto  IN crapdoc.tpdocmto%TYPE --> Tipo do documento
                                ,pr_cdoperad  IN crapdoc.cdoperad%TYPE --> Codigo do operador
                                ,pr_cdmodtip  IN INTEGER               --> Motivo do tipo de modalidade de conta
                                )  RETURN BOOLEAN IS    
                                      

    /* .............................................................................
    Programa: fn_valida_doc_renda
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : junho/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar a geracao da documento de comprovante de renda.

    Alteracoes: -----
    ..............................................................................*/

    ---------------> CURSORES <-----------------
    
    
    BEGIN
    
      --> para modalidade Conta salario e aplicacao nao deve gerar pendencia
      IF pr_cdmodtip IN (2,3) THEN
        --> Caso exista algum registro ja gerado no dia, deve ser excluido,
        --> evitando a geração de pendencia, principalmente qnd a conta é gerada com tipo de conta 8-normal
        --> e em seguida alterada para tipo de conta salario
        BEGIN
          DELETE crapdoc doc
           WHERE doc.cdcooper = pr_cdcooper
             AND doc.dtmvtolt = pr_dtmvtolt
             AND doc.tpdocmto = pr_tpdocmto
             AND doc.nrdconta = pr_nrdconta 
             AND doc.idseqttl = pr_idseqttl
             AND doc.flgdigit = 0
             AND doc.tpbxapen = 0;
        EXCEPTION 
          WHEN OTHERS THEN
            RETURN FALSE; 
        END;
        
        RETURN FALSE;     
      END IF;
    
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN TRUE;  
    END fn_valida_doc_renda;  
  
  PROCEDURE pc_grava_pend_digitalizacao( pr_cdcooper  IN crapdoc.cdcooper%TYPE --> Nr. da conta
                                        ,pr_nrdconta  IN crapdoc.nrdconta%TYPE --> Código do produto
                                        ,pr_idseqttl  IN crapdoc.idseqttl%TYPE --> Indicador de titular
                                        ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                        ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_tpdocmto  IN crapdoc.tpdocmto%TYPE --> Tipo do documento
                                        ,pr_cdoperad  IN crapdoc.cdoperad%TYPE --> Codigo do operador
                                        ,pr_nrseqdoc  IN crapdoc.nrseqdoc%TYPE DEFAULT 0 --> Numero seq. do documento quando houver(Ex. Sequencial do Bem)
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2 ) IS        --> Descricao da critica
                                      

    /* .............................................................................
    Programa: pc_grava_pend_digitalizacao
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Fevereiro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar pendencias de digitalização de documentos

    Alteracoes: -----
    ..............................................................................*/

    ---------------> CURSORES <-----------------
    --> Buscar dados do cooperado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE  )IS
      SELECT ass.inpessoa,
             ass.cdtipcta,
             tpc.cdmodalidade_tipo
        FROM crapass ass,
             tbcc_tipo_conta tpc
       WHERE ass.cdtipcta = tpc.cdtipo_conta
         AND ass.inpessoa = tpc.inpessoa   
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Verificar se ja existe pendencia no dia atual
    CURSOR cr_crapdoc_1 ( pr_cdcooper crapdoc.cdcooper%TYPE
                         ,pr_dtmvtolt crapdoc.dtmvtolt%TYPE
                         ,pr_tpdocmto crapdoc.tpdocmto%TYPE
                         ,pr_nrdconta crapdoc.nrdconta%TYPE
                         ,pr_idseqttl crapdoc.idseqttl%TYPE
                         ,pr_nrcpfcgc crapdoc.nrcpfcgc%TYPE
                         ,pr_nrseqdoc INTEGER --crapdoc.nrseqdoc%TYPE
                         ) IS
      SELECT doc.rowid,
             doc.flgdigit,
             doc.tpbxapen
        FROM crapdoc doc
       WHERE doc.cdcooper = pr_cdcooper
         AND doc.dtmvtolt = pr_dtmvtolt
         AND doc.tpdocmto = pr_tpdocmto 
         AND nvl(doc.nrseqdoc,0) = nvl(pr_nrseqdoc,0)
         AND ((doc.nrdconta = pr_nrdconta AND 
               doc.idseqttl = pr_idseqttl) 
              OR
              doc.nrcpfcgc = pr_nrcpfcgc);
    
    rw_crapdoc_1 cr_crapdoc_1%ROWTYPE;
    
    --> Verificar se existe pendencia em aberto
    CURSOR cr_crapdoc_2 ( pr_cdcooper crapdoc.cdcooper%TYPE
                         ,pr_dtmvtolt crapdoc.dtmvtolt%TYPE
                         ,pr_tpdocmto crapdoc.tpdocmto%TYPE
                         ,pr_nrdconta crapdoc.nrdconta%TYPE
                         ,pr_idseqttl crapdoc.idseqttl%TYPE
                         ,pr_nrcpfcgc crapdoc.nrcpfcgc%TYPE
                         ,pr_nrseqdoc INTEGER --crapdoc.nrseqdoc%TYPE
                         ) IS
      SELECT doc.rowid,
             doc.flgdigit
        FROM crapdoc doc
       WHERE doc.cdcooper = pr_cdcooper
         AND doc.dtmvtolt <> pr_dtmvtolt
         AND doc.tpdocmto = pr_tpdocmto 
         AND nvl(doc.nrseqdoc,0) = nvl(pr_nrseqdoc,0)
         AND doc.flgdigit = 0
         AND doc.tpbxapen = 0 --> sem baixa
         AND ((doc.nrdconta = pr_nrdconta AND 
               doc.idseqttl = pr_idseqttl) 
              OR
              doc.nrcpfcgc = pr_nrcpfcgc);
    
    --------------> VARIAVEIS <-----------------    
    -- Variavel de criticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_return    EXCEPTION;
    
    
    vr_idseqttl      INTEGER;
    vr_fldigita      BOOLEAN;
    -------------> SUB-ROTINAS <----------------    
      
  BEGIN
  
  
    -----> VALIDACOES <-----
    
    --> Buscar dados do cooperado
    rw_crapass := NULL;
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta); 
    FETCH cr_crapass INTO rw_crapass;    
    --> Nao gera critica 9, pois ao criar conta é 
    -- gerado as pendencias antes de criar a conta na bo52
    CLOSE cr_crapass;
    
    vr_idseqttl := pr_idseqttl;
    
    IF rw_crapass.inpessoa > 1 AND 
       nvl(vr_idseqttl,0) <> 0 THEN
      vr_idseqttl := 0;    
    END IF;
    
    
    --> VALIDAR CRIAÇÃO DA PENDENCIA
    --> 5 - Comprovante de renda
    IF pr_tpdocmto = 5 THEN
      vr_fldigita := fn_valida_doc_renda(  pr_cdcooper  => pr_cdcooper  --> Nr. da conta
                                          ,pr_nrdconta  => pr_nrdconta --> Código do produto
                                          ,pr_idseqttl  => pr_idseqttl --> Indicador de titular
                                          ,pr_nrcpfcgc  => pr_nrcpfcgc --> Numero do CPF/CNPJ
                                          ,pr_dtmvtolt  => pr_dtmvtolt --> Data do movimento
                                          ,pr_tpdocmto  => pr_tpdocmto --> Tipo do documento
                                          ,pr_cdoperad  => pr_cdoperad --> Codigo do operador
                                          ,pr_cdmodtip  => rw_crapass.cdmodalidade_tipo); --> Motivo do tipo de modalidade de conta
      
      --> para modalidade Conta salario e aplicacao nao deve gerar pendencia
      IF vr_fldigita = FALSE THEN
        RAISE vr_exc_return;      
      END IF;    
    END IF;
    
    
    --> Verificar se ja existe pendencia no dia atual
    rw_crapdoc_1 := NULL;
    OPEN cr_crapdoc_1 ( pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_tpdocmto => pr_tpdocmto
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => vr_idseqttl
                       ,pr_nrcpfcgc => pr_nrcpfcgc
                       ,pr_nrseqdoc => pr_nrseqdoc);
  
    FETCH cr_crapdoc_1 INTO rw_crapdoc_1;
    --> Caso encontre
    IF cr_crapdoc_1%FOUND THEN
      CLOSE cr_crapdoc_1;
      
      --> Caso encontre um documento na data atual, 
      --> porem ja digitalizado, deve apenas reabrir a pendencia
      IF rw_crapdoc_1.flgdigit = 1 OR 
         rw_crapdoc_1.tpbxapen > 0 THEN
        BEGIN
          UPDATE crapdoc doc
             SET doc.flgdigit = 0
                 ,doc.tpbxapen = 0
                 ,doc.Dtbxapen = NULL
                 ,doc.cdopebxa = 0
           WHERE doc.rowid = rw_crapdoc_1.rowid;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar pendencia: '||SQLERRM;
            RAISE vr_exc_erro;        
        END;
        
        -- Apos realizar o ajustes apenas deve sair da rotina
        RAISE vr_exc_return;
        
      --> Caso a pendencia ja esteja em aberto  
      ELSIF rw_crapdoc_1.flgdigit = 0 THEN
        --> apenas sair da rotina
        RAISE vr_exc_return;
      END IF;
    ELSE
      CLOSE cr_crapdoc_1;
    END IF; --> fim cr_crapdoc_1  
    
    --> Verificar se existe pendencia em aberto
    FOR rw_crapdoc IN cr_crapdoc_2( pr_cdcooper => pr_cdcooper 
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_tpdocmto => pr_tpdocmto
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => vr_idseqttl
                                   ,pr_nrcpfcgc => pr_nrcpfcgc
                                   ,pr_nrseqdoc => pr_nrseqdoc) LOOP
   
      BEGIN
      
        UPDATE crapdoc doc
           SET doc.tpbxapen = 1,
               doc.Dtbxapen = SYSDATE,
               doc.cdopebxa = pr_cdoperad
         WHERE doc.rowid = rw_crapdoc.rowid;
         
      EXCEPTION
        WHEN OTHERS THEN 
          vr_dscritic := 'Nao foi possivel atualizar pendencia(2): '||SQLERRM;
          RAISE vr_exc_erro;        
      END;
    
    END LOOP;
    
    BEGIN
      INSERT INTO crapdoc
                  (  cdcooper
                   , nrdconta
                   , flgdigit
                   , dtmvtolt
                   , tpdocmto
                   , idseqttl
                   , cdoperad
                   , nrcpfcgc
                   , nrseqdoc )
            VALUES(  pr_cdcooper   --> cdcooper
                   , pr_nrdconta   --> nrdconta
                   , 0             --> flgdigit
                   , pr_dtmvtolt   --> dtmvtolt
                   , pr_tpdocmto   --> tpdocmto
                   , vr_idseqttl   --> idseqttl
                   , pr_cdoperad   --> cdoperad
                   , pr_nrcpfcgc   --> nrcpfcgc
                   , pr_nrseqdoc   --> nrseqdoc
                   );
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir pendencia: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    
  EXCEPTION
    WHEN vr_exc_return THEN
      --> Apenas sair, usado qnd nao precisa gerar pendencia
      NULL;
    WHEN vr_exc_erro THEN
    
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN  
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel gravar pendencia: '||SQLERRM;
  END pc_grava_pend_digitalizacao;

  
  
END DIGI0001; 
/
