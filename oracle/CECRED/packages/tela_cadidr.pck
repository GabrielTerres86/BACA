CREATE OR REPLACE PACKAGE CECRED.tela_cadidr IS

	PROCEDURE pc_obtem_indicadores(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);        --> Erros do processo

	PROCEDURE pc_obtem_idindicador(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
																,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);        --> Erros do processo

 	PROCEDURE pc_insere_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
															 ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
		                           ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
															 ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
															 ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
		                           ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
															 ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

	PROCEDURE pc_altera_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

	PROCEDURE pc_exclui_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

END tela_cadidr;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_cadidr IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADIDR
  --  Sistema  : Ayllos Web
  --  Autor    : Lucas Reinert
  --  Data     : Fevereiro - 2016.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADIDR
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_obtem_indicadores(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_obtem_indicadores
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar indicadores de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_indicadores IS
				SELECT idindicador
							,nmindicador
							,dsindicador
							,decode(flgativo,1,'Sim','Não') flgativo
							,decode(tpindicador,'Q','Quantidade','M','Moeda','Adesão') tpindicador
					FROM tbrecip_indicador
				 ORDER BY idindicador;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      FOR rw_indicadores IN cr_indicadores LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indicador'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'idindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.idindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nmindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.nmindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.dsindicador)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'flgativo'
                              ,pr_tag_cont => to_char(rw_indicadores.flgativo)
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'tpindicador'
                              ,pr_tag_cont => to_char(rw_indicadores.tpindicador)
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_obtem_indicadores;

	PROCEDURE pc_obtem_idindicador(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_obtem_idindicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar último idindicador disponivel para inserção

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_indicadores IS
				SELECT nvl(max(idindicador),0) + 1 idindicador
          FROM tbrecip_indicador;
			rw_indicadores cr_indicadores%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Busca idindicador disponível
      OPEN cr_indicadores;
			FETCH cr_indicadores INTO rw_indicadores;

			IF cr_indicadores%FOUND THEN
			  -- Insere tag
				gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dados'
															,pr_posicao  => vr_auxconta
															,pr_tag_nova => 'idindicador'
															,pr_tag_cont => to_char(rw_indicadores.idindicador)
															,pr_des_erro => vr_dscritic);
		  END IF;

			CLOSE cr_indicadores;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_obtem_idindicador;

	PROCEDURE pc_insere_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_insere_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do indicador
			CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      CURSOR cr_nmindicador IS
				SELECT 1
          FROM tbrecip_indicador ind
				 WHERE ind.nmindicador = pr_nmindica;
			rw_nmindicador cr_nmindicador%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

      -- Abre cursor para verificar se já existe indicador cadastrado com o id parametrizado
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

			-- Se existe
			IF cr_indicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_indicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este ID. Favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_indicador;

		  -- Abre cursor para verificar se existe indicador com o mesmo nome
		  OPEN cr_nmindicador;
			FETCH cr_nmindicador INTO rw_nmindicador;

 			-- Se existe
			IF cr_nmindicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_nmindicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este nome, favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_nmindicador;

      BEGIN
				INSERT INTO tbrecip_indicador(idindicador, nmindicador, dsindicador, tpindicador, flgativo)
				                       VALUES(pr_idindica, pr_nmindica, pr_dsindica, pr_tpindica, pr_flgativo);
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

			-- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(pr_idindica));

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nmindica);

      CASE pr_tpindica
				WHEN 'Q' THEN
					vr_tpindica := 'Quantidade';
				WHEN 'A' THEN
					vr_tpindica := 'Adesao';
				WHEN 'M' THEN
					vr_tpindica := 'Moeda';
			END CASE;	

		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tpindica);

      IF pr_flgativo = 0 THEN
				vr_dsfativo := 'Inativo';
			ELSE
				vr_dsfativo := 'Ativo';
			END IF;

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => vr_dsfativo);

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => '',
																pr_dsdadatu => pr_dsindica);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_insere_indicador;

	PROCEDURE pc_altera_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_nmindica IN tbrecip_indicador.nmindicador%TYPE --> Nome do indicador
                               ,pr_tpindica IN tbrecip_indicador.tpindicador%TYPE --> Tipo do indicador ('M' - Moeda, 'Q' - Quantidade e 'A' - Adesão)
                               ,pr_flgativo IN tbrecip_indicador.flgativo%TYPE    --> Disponibilidade do indicador (0 - Inativo, 1 - Ativo)
                               ,pr_dsindica IN tbrecip_indicador.dsindicador%TYPE --> Descrição do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Buscar informações do indicador
		  CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      -- Cursor para verificar se existe outro indicador com o mesmo nome
      CURSOR cr_nmindicador IS
				SELECT 1
          FROM tbrecip_indicador ind
				 WHERE ind.nmindicador = pr_nmindica
				   AND ind.idindicador <> pr_idindica;
			rw_nmindicador cr_nmindicador%ROWTYPE;

      -- Cursor para verificar se indicador já está em uso
      CURSOR cr_tpindicador IS
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_COOP
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_APURACAO_INDICA
	       WHERE idindicador = pr_idindica;
      rw_tpindicador cr_tpindicador%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Alteracao indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
			vr_tpindica2 VARCHAR2(100);

    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

		  -- Abre indicador
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

		  IF cr_indicador%FOUND THEN
				IF (rw_indicador.tpindicador = 'A'          AND
					  rw_indicador.tpindicador <> pr_tpindica) OR
				   (rw_indicador.tpindicador IN ('Q','M')   AND
					  pr_tpindica = 'A')                     THEN
					-- Verifica se indicador já foi utilizado
					OPEN cr_tpindicador;
					FETCH cr_tpindicador INTO rw_tpindicador;

					-- Se encontrou está sendo utilizado
					IF cr_tpindicador%FOUND THEN
						-- Fecha cursores
				    CLOSE cr_indicador;
            CLOSE cr_tpindicador;
						-- Gera crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Tipo não pode ser alterado se já estiver em uso!';
						-- Levanta exceção
						RAISE vr_exc_saida;
					END IF;
					-- Fecha cursor
					CLOSE cr_tpindicador;
				END IF;
			END IF;

			-- Fecha cursor
			CLOSE cr_indicador;

		  -- Abre cursor para verificar se existe indicador com o mesmo nome
		  OPEN cr_nmindicador;
			FETCH cr_nmindicador INTO rw_nmindicador;

 			-- Se existe
			IF cr_nmindicador%FOUND THEN
				-- Fecha cursor
				CLOSE cr_nmindicador;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Já existe outro indicador com este nome, favor revisar o cadastro!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_nmindicador;

      BEGIN
				UPDATE tbrecip_indicador ind
				SET ind.nmindicador = pr_nmindica,
				    ind.dsindicador = pr_dsindica,
						ind.tpindicador = pr_tpindica,
						ind.flgativo    = pr_flgativo
				WHERE ind.idindicador = pr_idindica;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a gravação, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

      -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => to_char(rw_indicador.idindicador),
																pr_dsdadatu => to_char(pr_idindica));

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => to_char(rw_indicador.nmindicador),
																pr_dsdadatu => pr_nmindica);

      CASE rw_indicador.tpindicador
				WHEN 'Q' THEN
					vr_tpindica := 'Quantidade';
				WHEN 'A' THEN
					vr_tpindica := 'Adesao';
				WHEN 'M' THEN
					vr_tpindica := 'Moeda';
			END CASE;	

      CASE pr_tpindica
				WHEN 'Q' THEN
					vr_tpindica2 := 'Quantidade';
				WHEN 'A' THEN
					vr_tpindica2 := 'Adesao';
				WHEN 'M' THEN
					vr_tpindica2 := 'Moeda';
			END CASE;						
			
		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => vr_tpindica,
																pr_dsdadatu => vr_tpindica2);

      IF pr_flgativo = 0 THEN
				vr_dsfativo := 'Inativo';
			ELSE
				vr_dsfativo := 'Ativo';
			END IF;

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => to_char(rw_indicador.flgativo),
																pr_dsdadatu => vr_dsfativo);

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => to_char(rw_indicador.dsindicador),
																pr_dsdadatu => pr_dsindica);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_indicador;

	PROCEDURE pc_exclui_indicador(pr_idindica IN tbrecip_indicador.idindicador%TYPE --> Identificador do indicador
                               ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_exclui_indicador
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Fevereiro - 2016.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir indicador de reciprocidade

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

		  -- Verificar se indicador existe
		  CURSOR cr_indicador IS
			  SELECT ind.idindicador,
				       ind.nmindicador,
							 ind.tpindicador,
							 decode(flgativo,1,'Ativo','Inativo') flgativo,
							 ind.dsindicador
				  FROM tbrecip_indicador ind
				 WHERE ind.idindicador = pr_idindica;
			rw_indicador cr_indicador%ROWTYPE;

      -- Cursor para verificar se indicador já está em uso
      CURSOR cr_indicador_em_uso IS
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_COOP
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_PARAME_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_INDICA_CALCULO
				 WHERE idindicador = pr_idindica
				 UNION
				SELECT 1
				  FROM TBRECIP_APURACAO_INDICA
	       WHERE idindicador = pr_idindica;
      rw_indicador_em_uso cr_indicador_em_uso%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Exclusao indicador de reciprocidade';
			vr_nrdrowid ROWID;
			vr_tpindica VARCHAR2(100);
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

		  -- Abre indicador
		  OPEN cr_indicador;
			FETCH cr_indicador INTO rw_indicador;

		  -- Se não existe
		  IF cr_indicador%NOTFOUND THEN
					-- Fecha cursor
					CLOSE cr_indicador;
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Indicador não encontrado!';
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

			-- Fecha cursor
			CLOSE cr_indicador;

			-- Verificar se indicador está em uso por alguma cooperativa
			OPEN cr_indicador_em_uso;
			FETCH cr_indicador_em_uso INTO rw_indicador_em_uso;

			-- Se encontrou está em uso
			IF cr_indicador_em_uso%FOUND THEN
 					-- Fecha cursor
		      CLOSE cr_indicador_em_uso;
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Indicador não pode ser excluído! Motivo: Está em uso em pelo menos uma cooperativa.';
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;
			
			-- Fecha cursor
      CLOSE cr_indicador_em_uso;

      BEGIN
				DELETE FROM tbrecip_indicador ind
				WHERE ind.idindicador = pr_idindica;
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a exclusão, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

	    -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
				                   pr_cdoperad => vr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => vr_nmdatela,
													 pr_nrdconta => 0,
													 pr_nrdrowid => vr_nrdrowid);

		  -- ID Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'ID Indicador',
																pr_dsdadant => to_char(rw_indicador.idindicador),
																pr_dsdadatu => '');

		  -- Nome Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nome Indicador',
																pr_dsdadant => to_char(rw_indicador.nmindicador),
																pr_dsdadatu => '');

      CASE rw_indicador.tpindicador
				WHEN 'Q' THEN
					vr_tpindica := 'Quantidade';
				WHEN 'A' THEN
					vr_tpindica := 'Adesao';
				WHEN 'M' THEN
					vr_tpindica := 'Moeda';
			END CASE;	

		  -- Tipo Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo Indicador',
																pr_dsdadant => vr_tpindica,
																pr_dsdadatu => '');

		  -- Atividade Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Atividade Indicador',
																pr_dsdadant => to_char(rw_indicador.flgativo),
																pr_dsdadatu => '');

		  -- Descrição Indicador
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Descricao Indicador',
																pr_dsdadant => to_char(rw_indicador.dsindicador),
																pr_dsdadatu => '');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADIDR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_indicador;

END tela_cadidr;
/
