CREATE OR REPLACE PACKAGE CECRED.TELA_CADCUR AS

  -- Rotina para buscar curso
  PROCEDURE pc_busca_curso(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
													,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
													,pr_dscritic OUT VARCHAR2             --> Descricao da critica
													,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
													,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
													,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para pesquisar cursos
  PROCEDURE pc_pesquisa_cursos(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE  --> Codigo do curso
														  ,pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE  --> Nome resumido do curso
														  ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
														  ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
														  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para alterar curso
  PROCEDURE pc_altera_curso(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													 ,pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Nome resumido do curso
													 ,pr_dsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Descrição do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2);        --> Erros do processo

  -- Rotina para incluir curso	
	PROCEDURE pc_inclui_curso(pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Nome resumido do curso
													 ,pr_dsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Descrição do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2);        --> Erros do processo
													 
  -- Rotina para excluir curso superior	
	PROCEDURE pc_exclui_curso(pr_cdfrmttl    IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2);        --> Erros do processo
													 
	
END TELA_CADCUR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADCUR AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADCUR
  --    Autor   : Lucas Reinert
  --    Data    : Julho/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela CADCUR (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_busca_curso(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
													,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
													,pr_dscritic OUT VARCHAR2             --> Descricao da critica
													,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
													,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
													,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_curso
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Julho/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os cursos cadastrados

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
			
			-- Buscar curso superior
      CURSOR cr_gncdfrm IS
			  SELECT cur.cdfrmttl
				      ,cur.dsfrmttl
							,cur.rsfrmttl
				  FROM gncdfrm cur
				 WHERE cur.cdfrmttl = pr_cdfrmttl;
		  rw_gncdfrm cr_gncdfrm%ROWTYPE;
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADCUR'
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
			
			-- Se não informou código do curso
			IF pr_cdfrmttl = 0 THEN
				-- Gerar crítica
				vr_dscritic := 'Informe o curso.';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			
			-- Buscar curso
      OPEN cr_gncdfrm;
			FETCH cr_gncdfrm INTO rw_gncdfrm;
			-- Se não encontrou curso
			IF cr_gncdfrm%NOTFOUND THEN
				-- Fechar cursor
			  CLOSE cr_gncdfrm;
				vr_cdcritic := 0;
				vr_dscritic := 'Curso superior não encontrado';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_gncdfrm;			
			
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
			              '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
                    || '<cdfrmttl>' || rw_gncdfrm.cdfrmttl || '</cdfrmttl>'
                    || '<dsfrmttl>' || rw_gncdfrm.dsfrmttl || '</dsfrmttl>'
                    || '<rsfrmttl>' || rw_gncdfrm.rsfrmttl || '</rsfrmttl>'																				
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
        pr_dscritic := 'Erro geral na rotina da tela CADCUR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_curso;
  
  -- Rotina para pesquisar cursos
  PROCEDURE pc_pesquisa_cursos(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE  --> Codigo do curso
														  ,pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE  --> Nome resumido do curso
														  ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
														  ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
														  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
														  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
														  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
														  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela de cursos
      CURSOR cr_tbcursos IS
        SELECT cur.cdfrmttl
				      ,cur.rsfrmttl
              ,count(1) over() retorno
          FROM gncdfrm cur
         WHERE cur.cdfrmttl = decode(nvl(pr_cdfrmttl,0),0,cur.cdfrmttl, pr_cdfrmttl)
           AND (trim(pr_rsfrmttl) IS NULL
            OR  UPPER(cur.rsfrmttl) LIKE '%'||UPPER(pr_rsfrmttl)||'%')
         ORDER BY cur.cdfrmttl;

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

        -- Loop sobre a tabela de Cursos
        FOR rw_tbcursos IN cr_tbcursos LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<CURSOS qtregist="' || rw_tbcursos.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdfrmttl>' || rw_tbcursos.cdfrmttl ||'</cdfrmttl>'||
                                                            '<rsfrmttl>' || rw_tbcursos.rsfrmttl ||'</rsfrmttl>'||
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
                                 ,pr_texto_novo     => '<CURSOS qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</CURSOS></Dados>'
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
        pr_dscritic := 'Erro geral na pesquisa de cursos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pesquisa_cursos;
	
	PROCEDURE pc_altera_curso(pr_cdfrmttl IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													 ,pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Nome resumido do curso
													 ,pr_dsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Descrição do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_altera_curso
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Julho/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar os dados de curso superior

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
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
			-- Buscar curso superior
      CURSOR cr_gncdfrm IS
			  SELECT cur.cdfrmttl
				      ,cur.dsfrmttl
							,cur.rsfrmttl
							,ROWID							
				  FROM gncdfrm cur
				 WHERE cur.cdfrmttl = pr_cdfrmttl;
		  rw_gncdfrm cr_gncdfrm%ROWTYPE;

			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADCUR'
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
			
			-- Verificar se foi informado nome resumido
      IF TRIM(pr_rsfrmttl) IS NULL THEN
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nome resumido do curso superior deve ser informado.';
        RAISE vr_exc_erro;
			END IF;
			
			-- Verificar se foi informado descrição
      IF TRIM(pr_rsfrmttl) IS NULL THEN
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Descrição do curso superior deve ser informado.';
        RAISE vr_exc_erro;
			END IF;			
			
			-- Buscar curso superior
			OPEN cr_gncdfrm;
			FETCH cr_gncdfrm INTO rw_gncdfrm;
			
			-- Se não encontrou curso
			IF cr_gncdfrm%NOTFOUND THEN
				-- Fechar cursor
        CLOSE cr_gncdfrm;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Curso superior não encontrado.';
        RAISE vr_exc_erro;				
			END IF;
			-- Fechar cursor
			CLOSE cr_gncdfrm;
																
			-- Atualizar informações do curso superior
			UPDATE gncdfrm
			   SET rsfrmttl = upper(pr_rsfrmttl)
				    ,dsfrmttl = upper(pr_dsfrmttl)
		   WHERE ROWID = rw_gncdfrm.rowid;
			
		 -- Se alterou nome resumido
		 IF rw_gncdfrm.rsfrmttl <> pr_rsfrmttl THEN
			 vr_dslogtel := vr_dslogtel 
			             || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou o nome do curso resumido de ' 
									 || rw_gncdfrm.rsfrmttl
									 || ' para ' || upper(pr_rsfrmttl) || '.' || chr(10);
		 END IF;
			
		 -- Se alterou descrição
		 IF rw_gncdfrm.dsfrmttl <> pr_dsfrmttl THEN
			 vr_dslogtel := vr_dslogtel 
			             || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
			             || to_char(SYSDATE, 'hh24:mi:ss') 
                   || ' -->  Operador '|| vr_cdoperad || ' '
                   || ' alterou descricao de ' 
									 || rw_gncdfrm.dsfrmttl
									 || ' para ' || upper(pr_dsfrmttl) || '.' || chr(10);
		 END IF;

		 -- Se deve gerar algum log
		 IF TRIM(vr_dslogtel) IS NOT NULL THEN
			 btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
																 ,pr_ind_tipo_log => 2 -- Erro tratato
																 ,pr_nmarqlog     => 'cadcur.log'
																 ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
																 ,pr_cdprograma   => 'CADCUR');
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
        pr_dscritic := 'Erro geral na rotina da tela CADCUR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_altera_curso;

  -- Rotina para incluir curso superior	
	PROCEDURE pc_inclui_curso(pr_rsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Nome resumido do curso
													 ,pr_dsfrmttl IN gncdfrm.rsfrmttl%TYPE --> Descrição do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_inclui_curso
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Julho/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir registro de curso superior

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
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
			-- Buscar curso superior
      CURSOR cr_gncdfrm IS
			  SELECT 1
				  FROM gncdfrm cur
				 WHERE cur.rsfrmttl = upper(pr_rsfrmttl)
				   AND cur.dsfrmttl = upper(pr_dsfrmttl);
		  rw_gncdfrm cr_gncdfrm%ROWTYPE;

			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADCUR'
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
			
			-- Verificar se foi informado nome resumido
      IF TRIM(pr_rsfrmttl) IS NULL THEN
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nome resumido do curso superior deve ser informado.';
        RAISE vr_exc_erro;
			END IF;
			
			-- Verificar se foi informado descrição
      IF TRIM(pr_rsfrmttl) IS NULL THEN
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Descrição do curso superior deve ser informado.';
        RAISE vr_exc_erro;
			END IF;			
			
			-- Buscar curso superior
			OPEN cr_gncdfrm;
			FETCH cr_gncdfrm INTO rw_gncdfrm;
			
			-- Se encontrou curso
			IF cr_gncdfrm%FOUND THEN
				-- Fechar cursor
        CLOSE cr_gncdfrm;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Curso superior já cadastrado.';
        RAISE vr_exc_erro;				
			END IF;
			-- Fechar cursor
			CLOSE cr_gncdfrm;
																
			-- Inserir registro de curso superior
      INSERT INTO gncdfrm (cdfrmttl
			                    ,dsfrmttl
													,rsfrmttl) 
										VALUES(fn_sequence(pr_nmtabela => 'gncdfrm'
										                  ,pr_nmdcampo => 'cdfrmttl'
																			,pr_dsdchave => 'cdfrmttl')
													,upper(pr_dsfrmttl)
													,upper(pr_rsfrmttl));
                          
		  -- Atribuir log			
		  vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
								  || to_char(SYSDATE, 'hh24:mi:ss') 
								  || ' -->  Operador '|| vr_cdoperad || ' '
								  || ' inseriu registro de curso superior | Nome: ' 
								  || upper(pr_rsfrmttl) || ' | Descricao: ' || upper(pr_dsfrmttl) || '.' || chr(10);
									 			
		  -- Gerar log
		  btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
															  ,pr_ind_tipo_log => 2 -- Erro tratato
															  ,pr_nmarqlog     => 'cadcur.log'
															  ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
															  ,pr_cdprograma   => 'CADCUR');
			 	
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
        pr_dscritic := 'Erro geral na rotina da tela CADCUR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_inclui_curso;

  -- Rotina para excluir curso superior	
	PROCEDURE pc_exclui_curso(pr_cdfrmttl    IN gncdfrm.cdfrmttl%TYPE --> Código do curso
													 ,pr_xmllog      IN VARCHAR2           --> XML com informacoes de LOG
													 ,pr_cdcritic    OUT PLS_INTEGER       --> Codigo da critica
													 ,pr_dscritic    OUT VARCHAR2          --> Descricao da critica
													 ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
													 ,pr_nmdcampo    OUT VARCHAR2          --> Nome do campo com erro
													 ,pr_des_erro    OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_exclui_curso
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Julho/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir registro de curso superior

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
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
			-- Buscar curso superior
      CURSOR cr_gncdfrm IS
			  SELECT cur.cdfrmttl
				      ,cur.rsfrmttl
							,cur.dsfrmttl
				  FROM gncdfrm cur
				 WHERE cur.cdfrmttl = pr_cdfrmttl;
		  rw_gncdfrm cr_gncdfrm%ROWTYPE;
			
			-- Verificar se curso está sendo utilizado
			CURSOR cr_utilcur IS
			  SELECT DISTINCT(1) FROM crapttl WHERE crapttl.cdfrmttl = pr_cdfrmttl
				UNION
				SELECT DISTINCT(1) FROM crapcje WHERE crapcje.cdfrmttl = pr_cdfrmttl;
      rw_utilcur cr_utilcur%ROWTYPE;
			
    BEGIN
		  -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADCUR'
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
									
			-- Buscar curso superior
			OPEN cr_gncdfrm;
			FETCH cr_gncdfrm INTO rw_gncdfrm;
			
			-- Se encontrou curso
			IF cr_gncdfrm%NOTFOUND THEN
				-- Fechar cursor
        CLOSE cr_gncdfrm;
        --Montar Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Curso superior não encontrado.';
        RAISE vr_exc_erro;				
			END IF;
			-- Fechar cursor
			CLOSE cr_gncdfrm;
			
			-- Verificar se curso está sendo utilizado
			OPEN cr_utilcur;
			FETCH cr_utilcur INTO rw_utilcur;
			
			-- Se está sendo utilizado
			IF cr_utilcur%FOUND THEN
				-- Fechar cursor
				CLOSE cr_utilcur;
				-- Montar mensagem de erro
				vr_cdcritic := 0;
				vr_dscritic := 'Curso superior já está sendo utilizado.';
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_utilcur;
																
			-- Remover registro de curso superior
      DELETE FROM gncdfrm
			WHERE gncdfrm.cdfrmttl = pr_cdfrmttl;
                          
		  -- Atribuir log			
		  vr_dslogtel := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ' '
								  || to_char(SYSDATE, 'hh24:mi:ss') 
								  || ' -->  Operador '|| vr_cdoperad || ' '
								  || ' excluiu registro de curso superior | Codigo: ' || rw_gncdfrm.cdfrmttl 
									|| ' | Nome: ' || rw_gncdfrm.rsfrmttl 
									|| ' | Descricao: ' || rw_gncdfrm.dsfrmttl || '.' || chr(10);
									 			
		  -- Gerar log
		  btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
															  ,pr_ind_tipo_log => 2 -- Erro tratato
															  ,pr_nmarqlog     => 'cadcur.log'
															  ,pr_des_log      => rtrim(vr_dslogtel,chr(10))
															  ,pr_cdprograma   => 'CADCUR');
			 	
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
        pr_dscritic := 'Erro geral na rotina da tela CADCUR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_exclui_curso;

END TELA_CADCUR; 
/
