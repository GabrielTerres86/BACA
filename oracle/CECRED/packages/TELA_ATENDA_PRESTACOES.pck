CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_PRESTACOES IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PRESTACOES
  --  Sistema  : Rotinas utilizadas pela Tela ATENDA_PRESTACOES
  --  Sigla    : EMPR
  --  Autor    : Daniel/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ATENDA_PRESTACOES
  --
  ---------------------------------------------------------------------------
  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  ---------------------------------- ROTINAS --------------------------------

  PROCEDURE pc_consultar_controle(pr_nrdconta IN NUMBER --> Número da conta
                                 ,pr_nrctremp IN NUMBER --> Contrato
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar_controle(pr_nrdconta   IN NUMBER --> Número da conta
                               ,pr_nrctremp   IN NUMBER  --> Contrato
                               ,pr_idquaprc   IN NUMBER  --> Controle Qualificação
                               ,pr_xmllog     IN VARCHAR2  --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_ATENDA_PRESTACOES;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_PRESTACOES IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PRESTACOES
  --  Sistema  : Rotinas utilizadas pela Tela ATENDA_PRESTACOES
  --  Sigla    : EMPR
  --  Autor    : Daniel/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ATENDA_PRESTACOES
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar_controle(pr_nrdconta IN NUMBER             --> Número da conta
                                 ,pr_nrctremp IN NUMBER             --> Contrato
                                 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar_controle
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar Qualificacao
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      vr_dstextab craptab.dstextab%TYPE;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------      
      CURSOR cr_consulta_controle (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				select crapepr.idquaprc
             , crawepr.idquapro
          from crapepr
             , crawepr
         where crawepr.cdcooper = crapepr.cdcooper
           and crawepr.nrdconta = crapepr.nrdconta
           and crawepr.nrctremp = crapepr.nrctremp
           and crapepr.cdcooper = pr_cdcooper
           and crapepr.nrdconta = pr_nrdconta
           and crapepr.nrctremp = pr_nrctremp;
         rw_consulta_controle cr_consulta_controle%ROWTYPE;

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

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- CAMPOS
      -- Busca os dados
      OPEN cr_consulta_controle(vr_cdcooper);
     FETCH cr_consulta_controle
      INTO rw_consulta_controle;
     CLOSE cr_consulta_controle;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'idquaprc',
                             pr_tag_cont => rw_consulta_controle.idquaprc,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'idquapro',
                             pr_tag_cont => rw_consulta_controle.idquapro,
                             pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar_controle;

  PROCEDURE pc_alterar_controle(pr_nrdconta   IN NUMBER             --> Número da conta
                               ,pr_nrctremp   IN NUMBER             --> Contrato
                               ,pr_idquaprc   IN NUMBER             --> Controle Qualificação
                               ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_alterar_controle.
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para alterar Qualificacao
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      vr_dstextab craptab.dstextab%TYPE;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------      

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

    BEGIN  
      UPDATE crapepr
         SET idquaprc = pr_idquaprc
       WHERE crapepr.cdcooper = vr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Qualificação do controle!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
    END;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_alterar_controle;
  --
END TELA_ATENDA_PRESTACOES;
/
