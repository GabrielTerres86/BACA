CREATE OR REPLACE PACKAGE CECRED.TELA_ATACOR IS

PROCEDURE pc_busca_contratos_lc100(pr_nracordo tbrecup_acordo.nrdconta%TYPE
                                 , pr_xmllog   IN VARCHAR2                  --> XML com informações de LOG
                                 , pr_cdcritic OUT PLS_INTEGER              --> Código da crítica
                                 , pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                                 , pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                 , pr_nmdcampo OUT VARCHAR2                 --> Nome do campo com erro
                                 , pr_des_erro OUT VARCHAR2 );

PROCEDURE pc_valida_contrato_lc100(pr_nracordo tbrecup_acordo.nrdconta%TYPE
                                 , pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE
                                 , pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                                 , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_busca_contratos_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE
                                  , pr_cdcooper crapepr.cdcooper%TYPE
                                  , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inclui_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE    --> Número do acordo
                                  , pr_nrctremp crapepr.nrctremp%TYPE           --> Código da cooperativa
                                  , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_exclui_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE    --> Número do acordo
                                  , pr_nrctremp crapepr.nrctremp%TYPE           --> Código da cooperativa
                                  , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2);

PROCEDURE pc_atualiza_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE          --> Número do acordo
                                    , pr_nrctremp crapepr.nrctremp%TYPE                 --> Código da cooperativa
																		, pr_indpagar tbrecup_acordo_contrato.indpagar%TYPE --> Pagar (S/N)
                                    , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2);

END TELA_ATACOR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATACOR IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATACOR
  --  Sistema  : Procedimentos para tela ATACOR (Atualização de Acordos com Contratos da LC100)
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Janeiro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações usadas na tela de Atualização de Acordos
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------

PROCEDURE pc_busca_contratos_lc100(pr_nracordo tbrecup_acordo.nrdconta%TYPE
                                 , pr_xmllog   IN VARCHAR2                  --> XML com informações de LOG
                                 , pr_cdcritic OUT PLS_INTEGER              --> Código da crítica
                                 , pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
                                 , pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                 , pr_nmdcampo OUT VARCHAR2                 --> Nome do campo com erro
                                 , pr_des_erro OUT VARCHAR2 ) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_contratos_lc100
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar contratos LC100 de uma conta fornecida
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador do contrato para uso no XML

    ----------->>> CURSORES <<<--------

    -- Contratos LC100 da conta fornecida
    CURSOR cr_contratos_lc100(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
		                        , pr_nracordo tbrecup_acordo.nrdconta%TYPE) IS
    SELECT c.nrctremp
         , c.dtmvtolt
         , c.vlemprst
      FROM tbrecup_acordo a
			   , crapepr c
     WHERE a.cdcooper = pr_cdcooper
		   AND a.nracordo = pr_nracordo
		   AND c.cdcooper = a.cdcooper
       AND c.nrdconta = a.nrdconta
       AND c.inliquid = 0
       AND c.cdlcremp = 100
     ORDER BY c.dtmvtolt desc
         , c.nrctremp asc;
    rw_contratos_lc100 cr_contratos_lc100%ROWTYPE;

BEGIN
    pr_des_erro := 'OK';

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
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Linhas',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Percorre os contratos LC100 da conta fornecida
    FOR rw_contratos_lc100
      IN cr_contratos_lc100(vr_cdcooper, pr_nracordo) LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Linhas',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Linha',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Número do contrato
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Linha',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrctremp',
                               pr_tag_cont => rw_contratos_lc100.nrctremp,
                               pr_des_erro => pr_dscritic);

        -- Data da efetivação do contrato
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Linha',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dtmvtolt',
                               pr_tag_cont => TO_CHAR(rw_contratos_lc100.dtmvtolt, 'DD/MM/YYYY'),
                               pr_des_erro => pr_dscritic);

        -- Valor do contrato
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Linha',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'vlemprst',
                               pr_tag_cont => rw_contratos_lc100.vlemprst,
                               pr_des_erro => pr_dscritic);

        vr_contcont := vr_contcont + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_contratos_lc100;

PROCEDURE pc_valida_contrato_lc100(pr_nracordo tbrecup_acordo.nrdconta%TYPE
                                 , pr_nrctremp tbrecup_acordo_contrato.nrctremp%TYPE
                                 , pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                                 , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_valida_contrato_lc100
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para validar número de contrato LC100 fornecido para a conta fornecida
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_qtd_contratos_validos INTEGER := 0; -- Indicador de contrato válido (Se igual a 0, indica contrato inválido)
		vr_contrato_valido VARCHAR2(1) := 'S';

    BEGIN

    pr_des_erro := 'OK';

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
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Dados',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

    -- Verifica se existe contrato LC100 válido com o número fornecido para a conta fornecida
    SELECT COUNT(c.nrctremp)
      INTO vr_qtd_contratos_validos
      FROM tbrecup_acordo a
			   , crapepr c
     WHERE a.cdcooper = pr_cdcooper
		   AND a.nracordo = pr_nracordo
		   AND c.cdcooper = a.cdcooper
       AND c.nrdconta = a.nrdconta
       AND c.nrctremp = pr_nrctremp
       AND c.cdlcremp = 100
       AND c.inliquid = 0;

		IF (vr_qtd_contratos_validos = 0) THEN
		   vr_contrato_valido := 'N';
		END IF;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Dados',
                            pr_posicao  => 0,
                            pr_tag_nova => 'valido',
                            pr_tag_cont => vr_contrato_valido,
                            pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_valida_contrato_lc100;

PROCEDURE pc_busca_contratos_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE   --> Número do acordo
                                        , pr_cdcooper crapepr.cdcooper%TYPE           --> Código da cooperativa
                                        , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                        , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                        , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                        , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                        , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                        , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_conta_contratos_acordo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados da conta e dos contratos vinculados com um acordo fornecido
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador dos contratos para uso no XML

    ----------->>> CURSORES <<<--------

		-- Dados da conta vinculada ao acordo
		CURSOR cr_dados_conta(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                        , pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
		SELECT c.nmprimtl
		     , c.nrdconta
		  FROM tbrecup_acordo a
			   , crapass c
		 WHERE a.cdcooper = pr_cdcooper
		   AND a.nracordo = pr_nracordo
			 AND c.cdcooper = a.cdcooper
			 AND c.nrdconta = a.nrdconta;
		rw_dados_conta cr_dados_conta%ROWTYPE;

    -- Contratos (e conta corrente) vinculados ao acordo fornecido
    CURSOR cr_contratos_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                             , pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
    SELECT ctr.nrctremp
         , ctr.cdorigem
         , DECODE(ctr.cdorigem, 1, 'Conta corrente', 'Empréstimo') dsorigem
         , e.cdlcremp
         , ctr.indpagar
         , ctr.cdoperad
      FROM (SELECT c.cdorigem, t.nrdconta, t.cdcooper, c.nrctremp, c.indpagar, c.cdoperad
			        FROM tbrecup_acordo t
                 , tbrecup_acordo_contrato c
						 WHERE t.cdcooper = pr_cdcooper
						   AND t.nracordo = pr_nracordo
							 AND c.nracordo = t.nracordo) ctr
         , crapepr e
     WHERE e.cdcooper(+) = ctr.cdcooper
       AND e.nrdconta(+) = ctr.nrdconta
       AND e.nrctremp(+) = ctr.nrctremp;
    rw_contratos_acordo cr_contratos_acordo%ROWTYPE;

    BEGIN

    pr_des_erro := 'OK';

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
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Root',
                            pr_posicao  => 0,
                            pr_tag_nova => 'Dados',
                            pr_tag_cont => NULL,
                            pr_des_erro => vr_dscritic);

		OPEN cr_dados_conta(pr_cdcooper, pr_nracordo);

		FETCH cr_dados_conta INTO rw_dados_conta;

		CLOSE cr_dados_conta;

		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Titular',
                           pr_tag_cont => rw_dados_conta.nmprimtl,
                           pr_des_erro => pr_dscritic);

		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Conta',
                           pr_tag_cont => rw_dados_conta.nrdconta,
                           pr_des_erro => pr_dscritic);

		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Contratos',
                           pr_tag_cont => NULL,
                           pr_des_erro => pr_dscritic);

    FOR rw_contratos_acordo
      IN cr_contratos_acordo(pr_cdcooper, pr_nracordo) LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contratos',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Contrato',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Número do contrato
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrctremp',
                               pr_tag_cont => CASE WHEN rw_contratos_acordo.cdorigem = 3 THEN rw_contratos_acordo.nrctremp ELSE NULL END,
                               pr_des_erro => pr_dscritic);

        -- Código de origem (1 => Conta corrente / 2 ou 3 => Empréstimo)
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'cdorigem',
                               pr_tag_cont => rw_contratos_acordo.cdorigem,
                               pr_des_erro => pr_dscritic);

        -- Descrição da origem
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dsorigem',
                               pr_tag_cont => rw_contratos_acordo.dsorigem,
                               pr_des_erro => pr_dscritic);

        -- Linha de crédito do contrato de empréstimo
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'cdlcremp',
                               pr_tag_cont => rw_contratos_acordo.cdlcremp,
                               pr_des_erro => pr_dscritic);

        -- Flag que indica se os boletos devem pagar o contrato em questão
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'indpagar',
                               pr_tag_cont => rw_contratos_acordo.indpagar,
                               pr_des_erro => pr_dscritic);

        -- Código do operador que incluiu o contrato no acordo (Se foi incluído manualmente)
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Contrato',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'cdoperad',
                               pr_tag_cont => rw_contratos_acordo.cdoperad,
                               pr_des_erro => pr_dscritic);

        vr_contcont := vr_contcont + 1;
    END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_busca_contratos_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_busca_contratos_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_contratos_acordo;

PROCEDURE pc_inclui_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE    --> Número do acordo
                                  , pr_nrctremp crapepr.nrctremp%TYPE           --> Código da cooperativa
                                  , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_inclui_contrato_acordo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para incluir um novo contrato em um acordo
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----------->>> VARIAVEIS <<<--------

		-- Busca número da conta do acordo em que o contrato está sendo incluído
    CURSOR cr_acordo(pr_cdcooper NUMBER, pr_nracordo NUMBER) IS
    SELECT a.nrdconta
		  FROM tbrecup_acordo a
		 WHERE a.cdcooper = pr_cdcooper
		   AND a.nracordo = pr_nracordo;
		rw_acordo cr_acordo%ROWTYPE;

		-- Busca calendário para a cooperativa de trabalho
		CURSOR cr_dat(pr_cdcooper NUMBER) IS
		SELECT *
		  FROM crapdat
		 WHERE cdcooper = pr_cdcooper;
		rw_dat cr_dat%ROWTYPE;

		-- Busca calendário para a cooperativa de trabalho
		CURSOR cr_contrato_valido(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_nrctremp NUMBER) IS
		SELECT COUNT(1) qtd_contratos
		  FROM crapepr e
		 WHERE e.cdcooper = pr_cdcooper
		   AND e.nrdconta = pr_nrdconta
			 AND e.nrctremp = pr_nrctremp
			 AND e.cdlcremp = 100;
		rw_contrato_valido cr_contrato_valido%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    BEGIN

			pr_des_erro := 'OK';

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
			IF TRIM(vr_dscritic) IS NOT NULL THEN
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);

			OPEN cr_dat(vr_cdcooper);

			FETCH cr_dat INTO rw_dat;

			CLOSE cr_dat;

			OPEN cr_acordo(vr_cdcooper, pr_nracordo);

			FETCH cr_acordo INTO rw_acordo;

			CLOSE cr_acordo;

			OPEN cr_contrato_valido(vr_cdcooper, rw_acordo.nrdconta, pr_nrctremp);

			FETCH cr_contrato_valido INTO rw_contrato_valido;

			CLOSE cr_contrato_valido;

			IF rw_contrato_valido.qtd_contratos > 0 THEN

				-- Insere o novo contrato vinculado com o acordo
				INSERT INTO tbrecup_acordo_contrato (
					 nracordo
				 , nrctremp
				 , nrgrupo
				 , cdorigem
				 , indpagar
				 , cdoperad
				 , dtdinclu
				)
				VALUES (
					 pr_nracordo
				 , pr_nrctremp
				 , 1
				 , 3
				 , 'S'
				 , vr_cdoperad
				 , rw_dat.dtmvtolt
				);

				-- Replica registro da tabela CRAPCYC para o novo contrato inserido
				INSERT INTO crapcyc (
					 cdcooper
				 , cdorigem
				 , nrdconta
				 , nrctremp
				 , flgjudic
				 , flextjud
				 , flgehvip
				 , cdoperad
				 , dtinclus
				 , cdopeinc
				 , cdassess
				 , cdmotcin
				)
				SELECT vr_cdcooper
						 , 3
						 , rw_acordo.nrdconta
						 , pr_nrctremp
						 , c.flgjudic
						 , c.flextjud
						 , c.flgehvip
						 , vr_cdoperad
						 , rw_dat.dtmvtolt
						 , vr_cdoperad
						 , c.cdassess
						 , c.cdmotcin
				 FROM crapcyc c
				WHERE c.cdcooper = vr_cdcooper
					AND c.nrdconta = rw_acordo.nrdconta
					AND c.cdorigem = 1;

				COMMIT;

				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															 pr_tag_pai  => 'Dados',
															 pr_posicao  => 0,
															 pr_tag_nova => 'Inserido',
															 pr_tag_cont => 'S',
															 pr_des_erro => vr_dscritic);

				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															 pr_tag_pai  => 'Dados',
															 pr_posicao  => 0,
															 pr_tag_nova => 'valido',
															 pr_tag_cont => 'S',
															 pr_des_erro => vr_dscritic);

			ELSE
				gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															 pr_tag_pai  => 'Dados',
															 pr_posicao  => 0,
															 pr_tag_nova => 'valido',
															 pr_tag_cont => 'N',
															 pr_des_erro => vr_dscritic);
			END IF;
		EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_inclui_contrato_acordo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_inclui_contrato_acordo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_inclui_contrato_acordo;

PROCEDURE pc_exclui_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE    --> Número do acordo
                                  , pr_nrctremp crapepr.nrctremp%TYPE           --> Código da cooperativa
                                  , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_exclui_contrato_acordo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para excluir um contrato em um acordo
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----------->>> CURSORES <<<--------

		-- Busca número da conta do acordo em que o contrato está sendo incluído
    CURSOR cr_acordo(pr_cdcooper NUMBER, pr_nracordo NUMBER) IS
    SELECT a.nrdconta
		  FROM tbrecup_acordo a
		 WHERE a.cdcooper = pr_cdcooper
		   AND a.nracordo = pr_nracordo;
		rw_acordo cr_acordo%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    BEGIN

			pr_des_erro := 'OK';

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
			IF TRIM(vr_dscritic) IS NOT NULL THEN
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);


			OPEN cr_acordo(vr_cdcooper, pr_nracordo);

			FETCH cr_acordo INTO rw_acordo;

			CLOSE cr_acordo;

			-- Exclui o registro da tabela CRAPCYC relativo ao contrato que será removido
			DELETE
			  FROM crapcyc
			 WHERE cdcooper = vr_cdcooper
			   AND nrdconta = rw_acordo.nrdconta
				 AND nrctremp = pr_nrctremp
				 AND cdorigem = 3;

			-- Exclui o vínculo entre o contrato e o acordo
			DELETE
			  FROM tbrecup_acordo_contrato
			 WHERE nracordo = pr_nracordo
			   AND nrctremp = pr_nrctremp;

		  COMMIT;

			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Dados',
															pr_posicao  => 0,
															pr_tag_nova => 'Excluido',
															pr_tag_cont => 'S',
															pr_des_erro => vr_dscritic);

		EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_exclui_contrato_acordo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_exclui_contrato_acordo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_exclui_contrato_acordo;

PROCEDURE pc_atualiza_contrato_acordo(pr_nracordo tbrecup_acordo.nracordo%TYPE          --> Número do acordo
                                    , pr_nrctremp crapepr.nrctremp%TYPE                 --> Código da cooperativa
																		, pr_indpagar tbrecup_acordo_contrato.indpagar%TYPE --> Pagar (S/N)
                                    , pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_atualiza_contrato_acordo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para alterar o campo INDPAGAR de um contrato para um acordo
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    BEGIN

			pr_des_erro := 'OK';

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
			IF TRIM(vr_dscritic) IS NOT NULL THEN
					-- Levanta exceção
					RAISE vr_exc_saida;
			END IF;

			-- Criar cabeçalho do XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Root',
															pr_posicao  => 0,
															pr_tag_nova => 'Dados',
															pr_tag_cont => NULL,
															pr_des_erro => vr_dscritic);

			-- Atualiza o INDPAGAR para o contrato no acordo
			UPDATE tbrecup_acordo_contrato
			   SET indpagar = pr_indpagar
			 WHERE nracordo = pr_nracordo
			   AND (nrctremp IS NOT NULL AND nrctremp = pr_nrctremp) OR (pr_nrctremp IS NULL AND cdorigem = 1);

			COMMIT;

			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Dados',
															pr_posicao  => 0,
															pr_tag_nova => 'Atualizado',
															pr_tag_cont => 'S',
															pr_des_erro => vr_dscritic);

			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Dados',
															pr_posicao  => 0,
															pr_tag_nova => 'indpagar',
															pr_tag_cont => pr_indpagar,
															pr_des_erro => vr_dscritic);

		EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATACOR - pc_atualiza_contrato_acordo: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATACOR - pc_atualiza_contrato_acordo: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_atualiza_contrato_acordo;

END TELA_ATACOR;
/
