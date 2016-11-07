CREATE OR REPLACE PACKAGE CECRED.TELA_CASH IS

  PROCEDURE pc_dados_pac(pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_dados_site(pr_nrterfin     IN tbsite_taa.nrterfin%TYPE --> Numero do TAA
                         ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados_site(pr_nrterfin      IN tbsite_taa.nrterfin%TYPE --> Numero do TAA
                               ,pr_nmterminal    IN tbsite_taa.nmterminal%TYPE --> Nome do TAA para apresentacao
                               ,pr_flganexo_pa   IN tbsite_taa.flganexo_pa%TYPE --> TAA localiza-se no PA: 1-Sim / 0-Nao
                               ,pr_dslogradouro  IN tbsite_taa.dslogradouro%TYPE --> Descricao do logradouro
                               ,pr_dscomplemento IN tbsite_taa.dscomplemento%TYPE --> Descricao do complemento
                               ,pr_nrendere      IN tbsite_taa.nrendere%TYPE --> Numero da localizacao do TAA
                               ,pr_nmbairro      IN tbsite_taa.nmbairro%TYPE --> Nome do bairro
                               ,pr_nrcep         IN tbsite_taa.nrcep%TYPE --> Numero do CEP
                               ,pr_idcidade      IN tbsite_taa.idcidade%TYPE --> Identificador da cidade
                               ,pr_nrlatitude    IN tbsite_taa.nrlatitude%TYPE --> Latitude da localizacao
                               ,pr_nrlongitude   IN tbsite_taa.nrlongitude%TYPE --> Longitude da localizacao
                               ,pr_dshorario     IN tbsite_taa.dshorario%TYPE --> Horario de atendimento
                               ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro     OUT VARCHAR2); --> Erros do processo

END TELA_CASH;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CASH IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CASH
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Julho - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CASH
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_dados_pac(pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_dados_pac
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados do PA.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT crapage.nmresage
              ,crapage.dsendcop
              ,crapage.nrendere
              ,crapage.nmbairro
              ,crapage.dscomple
              ,crapage.nrcepend
              ,crapage.idcidade
              ,crapage.nmcidade
              ,crapage.cdufdcop
              ,crapage.nrlatitu
              ,crapage.nrlongit
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

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

      -- Selecionar os dados
      OPEN cr_crapage(pr_cdcooper => vr_cdcooper
                     ,pr_cdagenci => pr_cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      -- Alimenta a booleana
      vr_blnfound := cr_crapage%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapage;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmresage'
                              ,pr_tag_cont => rw_crapage.nmresage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsendcop'
                              ,pr_tag_cont => rw_crapage.dsendcop
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendere'
                              ,pr_tag_cont => rw_crapage.nrendere
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmbairro'
                              ,pr_tag_cont => rw_crapage.nmbairro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscomple'
                              ,pr_tag_cont => rw_crapage.dscomple
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcepend'
                              ,pr_tag_cont => GENE0002.fn_mask(rw_crapage.nrcepend,'99.999-999')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcidade'
                              ,pr_tag_cont => rw_crapage.idcidade
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmcidade'
                              ,pr_tag_cont => rw_crapage.nmcidade
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdufdcop'
                              ,pr_tag_cont => rw_crapage.cdufdcop
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlatitu'
                              ,pr_tag_cont => (CASE WHEN rw_crapage.nrlatitu <> 0 THEN rw_crapage.nrlatitu ELSE '' END)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlongit'
                              ,pr_tag_cont => (CASE WHEN rw_crapage.nrlongit <> 0 THEN rw_crapage.nrlongit ELSE '' END)
                              ,pr_des_erro => vr_dscritic);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CASH: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_dados_pac;

  PROCEDURE pc_dados_site(pr_nrterfin     IN tbsite_taa.nrterfin%TYPE --> Numero do TAA
                         ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_dados_site
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados do TAA para o site da cooperativa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_tbsite_taa(pr_cdcooper IN tbsite_taa.cdcooper%TYPE
                          ,pr_nrterfin IN tbsite_taa.nrterfin%TYPE) IS
        SELECT t.nmterminal
              ,t.flganexo_pa
              ,t.dslogradouro
              ,t.dscomplemento
              ,t.nrendere
              ,t.nmbairro
              ,t.nrcep
              ,t.idcidade
              ,t.dshorario
              ,t.nrlatitude
              ,t.nrlongitude
          FROM tbsite_taa t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrterfin = pr_nrterfin;
      rw_tbsite_taa cr_tbsite_taa%ROWTYPE;

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

      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

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

      -- Selecionar os dados
      OPEN cr_tbsite_taa(pr_cdcooper => vr_cdcooper
                        ,pr_nrterfin => pr_nrterfin);
      FETCH cr_tbsite_taa INTO rw_tbsite_taa;
      -- Alimenta a booleana
      vr_blnfound := cr_tbsite_taa%FOUND;
      -- Fechar o cursor
      CLOSE cr_tbsite_taa;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmterminal'
                              ,pr_tag_cont => rw_tbsite_taa.nmterminal
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flganexo_pa'
                              ,pr_tag_cont => rw_tbsite_taa.flganexo_pa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dshorario'
                              ,pr_tag_cont => rw_tbsite_taa.dshorario
                              ,pr_des_erro => vr_dscritic);

        -- Se o TAA NAO estiver localizado no mesmo endereco do PA
        IF rw_tbsite_taa.flganexo_pa = 0 THEN

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'dslogradouro'
                                ,pr_tag_cont => rw_tbsite_taa.dslogradouro
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'dscomplemento'
                                ,pr_tag_cont => rw_tbsite_taa.dscomplemento
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrendere'
                                ,pr_tag_cont => rw_tbsite_taa.nrendere
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nmbairro'
                                ,pr_tag_cont => rw_tbsite_taa.nmbairro
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrcepend'
                                ,pr_tag_cont => GENE0002.fn_mask(rw_tbsite_taa.nrcep,'99.999-999')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'idcidade'
                                ,pr_tag_cont => rw_tbsite_taa.idcidade
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrlatitu'
                                ,pr_tag_cont => (CASE WHEN rw_tbsite_taa.nrlatitude <> 0 THEN rw_tbsite_taa.nrlatitude ELSE '' END)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrlongit'
                                ,pr_tag_cont => (CASE WHEN rw_tbsite_taa.nrlongitude <> 0 THEN rw_tbsite_taa.nrlongitude ELSE '' END)
                                ,pr_des_erro => vr_dscritic);

          -- Se possui cidade cadastrada
          IF rw_tbsite_taa.idcidade > 0 THEN

            -- Busca o nome da cidade
            CADA0003.pc_busca_cidades(pr_idcidade    => rw_tbsite_taa.idcidade
                                     ,pr_cdcidade    => 0
                                     ,pr_dscidade    => ''
                                     ,pr_cdestado    => ''
                                     ,pr_infiltro    => 1 -- CETIP
                                     ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                     ,pr_tab_crapmun => vr_tab_crapmun
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);
            -- Se retornou erro
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Se encontrou
            IF vr_tab_crapmun.COUNT > 0 THEN

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'Dados'
                                    ,pr_posicao  => 0
                                    ,pr_tag_nova => 'dscidade'
                                    ,pr_tag_cont => vr_tab_crapmun(1).dscidade
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'Dados'
                                    ,pr_posicao  => 0
                                    ,pr_tag_nova => 'cdestado'
                                    ,pr_tag_cont => vr_tab_crapmun(1).cdestado
                                    ,pr_des_erro => vr_dscritic);

            END IF;

          END IF; -- rw_tbsite_taa.idcidade > 0

        END IF; -- rw_tbsite_taa.flganexo_pa = 0

      END IF; -- cr_tbsite_taa

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
        pr_dscritic := 'Erro geral na rotina da tela CASH: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_dados_site;

  PROCEDURE pc_grava_dados_site(pr_nrterfin      IN tbsite_taa.nrterfin%TYPE --> Numero do TAA
                               ,pr_nmterminal    IN tbsite_taa.nmterminal%TYPE --> Nome do TAA para apresentacao
                               ,pr_flganexo_pa   IN tbsite_taa.flganexo_pa%TYPE --> TAA localiza-se no PA: 1-Sim / 0-Nao
                               ,pr_dslogradouro  IN tbsite_taa.dslogradouro%TYPE --> Descricao do logradouro
                               ,pr_dscomplemento IN tbsite_taa.dscomplemento%TYPE --> Descricao do complemento
                               ,pr_nrendere      IN tbsite_taa.nrendere%TYPE --> Numero da localizacao do TAA
                               ,pr_nmbairro      IN tbsite_taa.nmbairro%TYPE --> Nome do bairro
                               ,pr_nrcep         IN tbsite_taa.nrcep%TYPE --> Numero do CEP
                               ,pr_idcidade      IN tbsite_taa.idcidade%TYPE --> Identificador da cidade
                               ,pr_nrlatitude    IN tbsite_taa.nrlatitude%TYPE --> Latitude da localizacao
                               ,pr_nrlongitude   IN tbsite_taa.nrlongitude%TYPE --> Longitude da localizacao
                               ,pr_dshorario     IN tbsite_taa.dshorario%TYPE --> Horario de atendimento
                               ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic     OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic     OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro     OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados_site
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastrar os dados do TAA para o site da cooperativa.

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
      
      -- Variaveis
      vr_dslogradouro  tbsite_taa.dslogradouro%TYPE;
      vr_dscomplemento tbsite_taa.dscomplemento%TYPE;
      vr_nrendere      tbsite_taa.nrendere%TYPE;
      vr_nmbairro      tbsite_taa.nmbairro%TYPE;
      vr_nrcep         tbsite_taa.nrcep%TYPE;
      vr_idcidade      tbsite_taa.idcidade%TYPE;
      vr_nrlatitude    tbsite_taa.nrlatitude%TYPE;
      vr_nrlongitude   tbsite_taa.nrlongitude%TYPE;
      vr_dshorario     tbsite_taa.dshorario%TYPE;

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

      -- Se NAO foi informado nome
      IF TRIM(pr_nmterminal) IS NULL THEN
        vr_dscritic := 'Informe o nome.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Se NAO for o mesmo endereco do PA
      IF pr_flganexo_pa = 0 THEN
        vr_dslogradouro  := pr_dslogradouro;
        vr_dscomplemento := pr_dscomplemento;
        vr_nmbairro      := pr_nmbairro;
        vr_nrendere      := (CASE WHEN pr_nrendere > 0 THEN pr_nrendere ELSE NULL END);
        vr_nrcep         := (CASE WHEN pr_nrcep    > 0 THEN pr_nrcep    ELSE NULL END);
        vr_idcidade      := (CASE WHEN pr_idcidade > 0 THEN pr_idcidade ELSE NULL END);
        vr_nrlatitude    := pr_nrlatitude;
        vr_nrlongitude   := pr_nrlongitude;
      END IF;

      -- Remove o CDATA da String
      vr_dshorario := GENE0007.fn_remove_cdata(pr_dshorario);

      -- Insere ou atualiza os dados
      BEGIN
        INSERT INTO tbsite_taa
                   (cdcooper
                   ,nrterfin
                   ,nmterminal
                   ,flganexo_pa
                   ,dshorario
                   ,dslogradouro
                   ,dscomplemento
                   ,nrendere
                   ,nmbairro
                   ,nrcep
                   ,idcidade
                   ,nrlatitude
                   ,nrlongitude)
             VALUES(vr_cdcooper
                   ,pr_nrterfin
                   ,pr_nmterminal
                   ,pr_flganexo_pa
                   ,vr_dshorario
                   ,vr_dslogradouro
                   ,vr_dscomplemento
                   ,vr_nrendere
                   ,vr_nmbairro
                   ,vr_nrcep
                   ,vr_idcidade
                   ,NVL(vr_nrlatitude,0)
                   ,NVL(vr_nrlongitude,0));
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existir atualiza
          UPDATE tbsite_taa
             SET tbsite_taa.nmterminal = pr_nmterminal
                ,tbsite_taa.flganexo_pa = pr_flganexo_pa
                ,tbsite_taa.dshorario = vr_dshorario
                ,tbsite_taa.dslogradouro = vr_dslogradouro
                ,tbsite_taa.dscomplemento = vr_dscomplemento
                ,tbsite_taa.nrendere = vr_nrendere
                ,tbsite_taa.nmbairro = vr_nmbairro
                ,tbsite_taa.nrcep = vr_nrcep
                ,tbsite_taa.idcidade = vr_idcidade
                ,tbsite_taa.nrlatitude = NVL(vr_nrlatitude,0)
                ,tbsite_taa.nrlongitude = NVL(vr_nrlongitude,0)
           WHERE tbsite_taa.cdcooper = vr_cdcooper
             AND tbsite_taa.nrterfin = pr_nrterfin;

        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados para o site da cooperativa: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

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
        pr_dscritic := 'Erro geral na rotina da tela CASH: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_grava_dados_site;

END TELA_CASH;
/
