CREATE OR REPLACE PACKAGE CECRED.TELA_OPECEL AS

  -- Rotina para buscar inforamções da operadora
  PROCEDURE pc_busca_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE --> Código da Operadora
                              ,pr_xmllog      IN VARCHAR2                             --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER                         --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2                            --> Descricao da critica
                              ,pr_retxml      IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2                            --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2);                          --> Erros do processo

  -- Rotina para pesquisar operadora
  PROCEDURE pc_pesquisa_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE --> Codigo da operadora
                                 ,pr_nmoperadora IN tbrecarga_operadora.nmoperadora%TYPE --> Nome da operadora
                                 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para alterar operadora
 	PROCEDURE pc_altera_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE            --> Código da Operadora
		                           ,pr_flgsituacao IN tbrecarga_operadora.flgsituacao%TYPE            --> Flag situação (0-INATIVO/1-ATIVO)
															 ,pr_cdhisdebcop IN tbrecarga_operadora.cdhisdeb_cooperado%TYPE     --> Histórico de débito cooperado
															 ,pr_cdhisdebcnt IN tbrecarga_operadora.cdhisdeb_centralizacao%TYPE --> Histórico de débito centralização
															 ,pr_perreceita  IN tbrecarga_operadora.perreceita%TYPE             --> Percentual de receita
															 ,pr_xmllog      IN VARCHAR2                                        --> XML com informacoes de LOG
															 ,pr_cdcritic    OUT PLS_INTEGER                                    --> Codigo da critica
															 ,pr_dscritic    OUT VARCHAR2                                       --> Descricao da critica
															 ,pr_retxml      IN OUT NOCOPY xmltype                              --> Arquivo de retorno do XML
															 ,pr_nmdcampo    OUT VARCHAR2                                       --> Nome do campo com erro
															 ,pr_des_erro    OUT VARCHAR2);                                     --> Erros do processo  
	
END TELA_OPECEL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_OPECEL AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_OPECEL
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
  
  PROCEDURE pc_busca_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE --> Código da Operadora
		                          ,pr_xmllog      IN VARCHAR2                             --> XML com informacoes de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER                         --> Codigo da critica
                              ,pr_dscritic    OUT VARCHAR2                            --> Descricao da critica
                              ,pr_retxml      IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2                            --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2) IS                        --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_operadora
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados da operadora

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
			vr_dshiscop craphis.dshistor%TYPE;
			vr_dshiscnt craphis.dshistor%TYPE;

      vr_tab_operadoras tbrecarga_operadora%ROWTYPE;
			
			-- Buscar históricos
			CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
			  SELECT his.dshistor
				  FROM craphis his
				 WHERE his.cdcooper = pr_cdcooper
				   AND his.cdhistor = pr_cdhistor;
			
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
			
			-- Se não informou código da operadora
			IF pr_cdoperadora = 0 THEN
				-- Gerar crítica
				vr_dscritic := 'Informe a operadora de celular.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Buscar informações da operadora
			RCEL0001.pc_busca_operadora(pr_cdoperadora => pr_cdoperadora
			                           ,pr_tab_operadoras => vr_tab_operadoras
																 ,pr_cdcritic => vr_cdcritic
																 ,pr_dscritic => vr_dscritic);
													
		  -- Se retornou crítica			 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Gerar crítica
				vr_dscritic := 'Não há operadora com o código informado.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Buscar descrição do histórico cooperado
			OPEN cr_craphis(vr_cdcooper
			               ,vr_tab_operadoras.cdhisdeb_cooperado);
			FETCH cr_craphis INTO vr_dshiscop;
			-- Fechar cursor
			CLOSE cr_craphis;

			-- Buscar descrição do histórico centralizacao
			OPEN cr_craphis(vr_cdcooper
			               ,vr_tab_operadoras.cdhisdeb_centralizacao);
			FETCH cr_craphis INTO vr_dshiscnt;
			-- Fechar cursor
			CLOSE cr_craphis;
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
								 || '<nmoperadora>'            || vr_tab_operadoras.nmoperadora || '</nmoperadora>'
								 || '<flgsituacao>'            || vr_tab_operadoras.flgsituacao || '</flgsituacao>'
								 || '<cdhisdeb_cooperado>'     || vr_tab_operadoras.cdhisdeb_cooperado || '</cdhisdeb_cooperado>'
								 || '<cdhisdeb_centralizacao>' || vr_tab_operadoras.cdhisdeb_centralizacao || '</cdhisdeb_centralizacao>'
								 || '<perreceita>'             || to_char(vr_tab_operadoras.perreceita, 'fm990d00') || '</perreceita>'
								 || '<dshiscop>'               || vr_dshiscop || '</dshiscop>'
								 || '<dshiscnt>'               || vr_dshiscnt || '</dshiscnt>'								 
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
        pr_dscritic := 'Erro geral na rotina da tela OPECEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_operadora;
  
  -- Rotina para pesquisar operadora
  PROCEDURE pc_pesquisa_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE --> Codigo da operadora
																 ,pr_nmoperadora IN tbrecarga_operadora.nmoperadora%TYPE --> Nome da operadora
																 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
																 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
																 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela de operadoras
      CURSOR cr_tboperadoras IS
        SELECT opr.cdoperadora
				      ,opr.nmoperadora
              ,count(1) over() retorno
          FROM tbrecarga_operadora opr
         WHERE opr.cdoperadora = decode(nvl(pr_cdoperadora,0),0,opr.cdoperadora, pr_cdoperadora)
           AND (trim(pr_nmoperadora) IS NULL
            OR  UPPER(opr.nmoperadora) LIKE '%'||UPPER(pr_nmoperadora)||'%')
         ORDER BY opr.cdoperadora;

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

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

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
        FOR rw_tboperadoras IN cr_tboperadoras LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<OPERADORAS qtregist="' || rw_tboperadoras.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdoperadora>' || rw_tboperadoras.cdoperadora ||'</cdoperadora>'||
                                                            '<nmoperadora>' || rw_tboperadoras.nmoperadora ||'</nmoperadora>'||
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
                                 ,pr_texto_novo     => '<OPERADORAS qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</OPERADORAS></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
					-- Busca descrição da crítica
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na pesquisa operadoras: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pesquisa_operadora;
	
	PROCEDURE pc_altera_operadora(pr_cdoperadora IN tbrecarga_operadora.cdoperadora%TYPE            --> Código da Operadora
		                           ,pr_flgsituacao IN tbrecarga_operadora.flgsituacao%TYPE            --> Flag situação (0-INATIVO/1-ATIVO)
															 ,pr_cdhisdebcop IN tbrecarga_operadora.cdhisdeb_cooperado%TYPE     --> Histórico de débito cooperado
															 ,pr_cdhisdebcnt IN tbrecarga_operadora.cdhisdeb_centralizacao%TYPE --> Histórico de débito centralização
															 ,pr_perreceita  IN tbrecarga_operadora.perreceita%TYPE             --> Percentual de receita
															 ,pr_xmllog      IN VARCHAR2                                        --> XML com informacoes de LOG
															 ,pr_cdcritic    OUT PLS_INTEGER                                    --> Codigo da critica
															 ,pr_dscritic    OUT VARCHAR2                                       --> Descricao da critica
															 ,pr_retxml      IN OUT NOCOPY xmltype                              --> Arquivo de retorno do XML
															 ,pr_nmdcampo    OUT VARCHAR2                                       --> Nome do campo com erro
															 ,pr_des_erro    OUT VARCHAR2) IS                                   --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_altera_operadora
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar os dados da operadora

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
      vr_tab_operadoras tbrecarga_operadora%ROWTYPE;
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
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
			
      -- Ativo			
			IF pr_flgsituacao = 1 THEN
			   IF pr_cdhisdebcop = 0 OR pr_cdhisdebcnt = 0 THEN
					 -- Gerar crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Informe os históricos de débito';
					 -- Levantar exceção
					 RAISE vr_exc_erro;
				 END IF;
			END IF;
			
			IF pr_perreceita > 100 THEN
				-- Gerar crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Percentual de receita não pode ultrapassar 100%';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Buscar informações da operadora
			RCEL0001.pc_busca_operadora(pr_cdoperadora => pr_cdoperadora
			                           ,pr_tab_operadoras => vr_tab_operadoras
																 ,pr_cdcritic => vr_cdcritic
																 ,pr_dscritic => vr_dscritic);
													
		  -- Se retornou crítica			 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Atualizar informações da operadora
			UPDATE tbrecarga_operadora
			   SET flgsituacao = pr_flgsituacao
				    ,cdhisdeb_cooperado = pr_cdhisdebcop
						,cdhisdeb_centralizacao = pr_cdhisdebcnt
						,perreceita = pr_perreceita
		   WHERE cdoperadora = pr_cdoperadora;
			
		 -- Se alterou Situação
		 IF vr_tab_operadoras.flgsituacao <> pr_flgsituacao THEN
			 vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou a situacao da operadora de celular ' 
									 || vr_tab_operadoras.nmoperadora 
                   || ' de ' || CASE WHEN vr_tab_operadoras.flgsituacao = 1 THEN 'ATIVO' ELSE 'INATIVO' END
									 || ' para ' || CASE WHEN pr_flgsituacao = 1 THEN 'ATIVO' ELSE 'INATIVO' END || '.' || chr(10);
		 END IF;
			
 		 -- Se alterou Histórico de débito do cooperado
		 IF vr_tab_operadoras.cdhisdeb_cooperado <> pr_cdhisdebcop THEN
			 vr_dslogtel := vr_dslogtel
                   || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou o historico de debito da recarga na conta do cooperado'
									 || ' da operadora de celular ' || vr_tab_operadoras.nmoperadora
                   || ' de ' || vr_tab_operadoras.cdhisdeb_cooperado
									 || ' para ' || pr_cdhisdebcop || '.' || chr(10);
		 END IF;
		 
 		 -- Se alterou Histórico de débito das filiadas
		 IF vr_tab_operadoras.cdhisdeb_centralizacao <> pr_cdhisdebcnt THEN
			 vr_dslogtel := vr_dslogtel
			             || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou o historico de debito da recarga na conta das filiadas'
									 || ' da operadora de celular ' || vr_tab_operadoras.nmoperadora
                   || ' de ' || vr_tab_operadoras.cdhisdeb_centralizacao
									 || ' para ' || pr_cdhisdebcnt || '.' || chr(10);
		 END IF;

 		 -- Se alterou percentual de receita
		 IF vr_tab_operadoras.perreceita <> pr_perreceita THEN
			 vr_dslogtel := vr_dslogtel
			             || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou o percentual de receita'
									 || ' da operadora de celular ' || vr_tab_operadoras.nmoperadora
                   || ' de ' || TO_CHAR(vr_tab_operadoras.perreceita, 'fm990d00') || '%'
									 || ' para ' || TO_CHAR(pr_perreceita, 'fm990d00') || '%.' || chr(10);
		 END IF;

		 -- Se deve gerar algum log
		 IF TRIM(vr_dslogtel) IS NOT NULL THEN
			 btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
																 ,pr_ind_tipo_log => 2 -- Erro tratato
																 ,pr_nmarqlog     => 'opecel.log'
																 ,pr_des_log      => rtrim(vr_dslogtel,chr(10)));
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
        pr_dscritic := 'Erro geral na rotina da tela OPECEL: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_altera_operadora;

END TELA_OPECEL; 
/
