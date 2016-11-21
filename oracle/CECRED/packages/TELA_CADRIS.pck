CREATE OR REPLACE PACKAGE CECRED.TELA_CADRIS IS

  PROCEDURE pc_busca_risco(pr_cdnivel_risco  IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                          ,pr_xmllog         IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro      OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_risco(pr_nrdconta      IN VARCHAR2 --> Conta
                           ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro      OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_inclui_risco(pr_nrdconta        IN tbrisco_cadastro_conta.nrdconta%TYPE --> Conta
                           ,pr_cdnivel_risco   IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_dsjustificativa IN tbrisco_cadastro_conta.dsjustificativa%TYPE --> Justificativa
                           ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro       OUT VARCHAR2); --> Erros do processo

END TELA_CADRIS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADRIS IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADRIS
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Maio - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADRIS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

	-- Tipos de Risco
  TYPE typ_tab_risco IS VARRAY(9) OF VARCHAR2(1);
  vr_tab_risco typ_tab_risco := typ_tab_risco('','A','B','C','D','E','F','G','H');

  PROCEDURE pc_busca_risco(pr_cdnivel_risco  IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                          ,pr_xmllog         IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro      OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_risco
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os cadastros de risco.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar a listagem de riscos
      CURSOR cr_risco(pr_cdcooper      IN crapcop.cdcooper%TYPE
                     ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE) IS
        SELECT tcc.nrdconta
              ,tcc.dsjustificativa
              ,ass.nmprimtl
          FROM tbrisco_cadastro_conta tcc,
               crapass ass
         WHERE tcc.cdcooper      = pr_cdcooper
           AND tcc.cdnivel_risco = pr_cdnivel_risco
           AND tcc.cdcooper      = ass.cdcooper
           AND tcc.nrdconta      = ass.nrdconta;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis Gerais
      vr_contador INTEGER := 0;

    BEGIN
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

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de riscos
      FOR rw_risco IN cr_risco(pr_cdcooper      => vr_cdcooper
                              ,pr_cdnivel_risco => pr_cdnivel_risco) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'risco'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nrdconta'
                              ,pr_tag_cont => GENE0002.fn_mask_conta(rw_risco.nrdconta)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmprimtl'
                              ,pr_tag_cont => rw_risco.nmprimtl
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dsjustificativa'
                              ,pr_tag_cont => rw_risco.dsjustificativa
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADRIS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_risco;

  PROCEDURE pc_exclui_risco(pr_nrdconta      IN VARCHAR2 --> Conta
                           ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro      OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_risco             Antigo: 
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o risco.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_dsmsglog  VARCHAR2(4000) := '';
      vr_ds_enter  VARCHAR2(10) := '';
      vr_indice    VARCHAR2(7);
      vr_tab_split GENE0002.typ_split;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
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

	    vr_tab_split := GENE0002.fn_quebra_string(pr_nrdconta,'|');

      vr_indice := vr_tab_split.FIRST;
      WHILE vr_indice IS NOT NULL LOOP

        BEGIN
          DELETE tbrisco_cadastro_conta
           WHERE cdcooper      = vr_cdcooper
             AND nrdconta      = vr_tab_split(vr_indice)
             AND cdnivel_risco = pr_cdnivel_risco;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao excluir risco: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;
        
        vr_dsmsglog := vr_dsmsglog || vr_ds_enter || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                       ' -->  Operador '|| vr_cdoperad || ' - ' ||
                       'Excluiu a conta: ' || vr_tab_split(vr_indice) || 
                       ' - Nivel de Risco: ' || vr_tab_risco(pr_cdnivel_risco);
        vr_ds_enter := chr(10);

        vr_indice := vr_tab_split.NEXT(vr_indice);
      END LOOP;

      -- Gera log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadris.log'
                                ,pr_des_log      => vr_dsmsglog);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_risco;

  PROCEDURE pc_inclui_risco(pr_nrdconta        IN tbrisco_cadastro_conta.nrdconta%TYPE --> Conta
                           ,pr_cdnivel_risco   IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_dsjustificativa IN tbrisco_cadastro_conta.dsjustificativa%TYPE --> Justificativa
                           ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro       OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_inclui_risco             Antigo: 
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir o risco.

    Alteracoes: 02/08/2016 - Inclusao da data e operador que efetuou o cadastro. 
                             (Jaison - SD: 491821)
    ..............................................................................*/
    DECLARE

      -- Valida conta
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT COUNT(1)
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_qtassoci NUMBER;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
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

      -- Valida conta
      OPEN  cr_crapass(pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_qtassoci;
      CLOSE cr_crapass;

      -- Caso nao encontre gera critica
      IF vr_qtassoci = 0 THEN
        vr_cdcritic := 564;
        RAISE vr_exc_saida;
      END IF;

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

	    BEGIN
        INSERT INTO tbrisco_cadastro_conta
                   (cdcooper
                   ,nrdconta
                   ,cdnivel_risco
                   ,dsjustificativa
                   ,dtmvtolt
                   ,cdoperad)
             VALUES(vr_cdcooper
                   ,pr_nrdconta
                   ,pr_cdnivel_risco
                   ,pr_dsjustificativa
                   ,rw_crapdat.dtmvtolt
                   ,vr_cdoperad);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Conta já cadastrada!';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir risco: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
        
      -- Gera log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadris.log'
                                ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                    'Incluiu a conta: ' || pr_nrdconta || 
                                                    ' - Nivel de Risco: ' || vr_tab_risco(pr_cdnivel_risco) ||
                                                    ' - Justificativa: ' || pr_dsjustificativa);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_inclui_risco;

END TELA_CADRIS;
/
