CREATE OR REPLACE PACKAGE CECRED.TELA_TAB097 IS

  PROCEDURE pc_busca_param(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_param_exc(pr_indexcecao IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                              ,pr_dsuf       IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                              ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro   OUT VARCHAR2); --> Erros do processo
                          
  PROCEDURE pc_altera_param(pr_qtminimo_negativacao IN tbcobran_param_negativacao.qtminimo_negativacao%TYPE --> Quantidade de dias minimo para a negativacao
                           ,pr_qtmaximo_negativacao IN tbcobran_param_negativacao.qtmaximo_negativacao%TYPE --> Quantidade de dias maximo para a negativacao
                           ,pr_hrenvio_arquivo      IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_vlminimo_boleto      IN tbcobran_param_negativacao.vlminimo_boleto%TYPE --> Valor minimo do boleto para negativacao
                           ,pr_qtdias_vencimento    IN tbcobran_param_negativacao.qtdias_vencimento%TYPE --> Quantidade de dias que sera somado a data do envio para o calculo do vencimento
                           ,pr_qtdias_negativacao   IN tbcobran_param_negativacao.qtdias_negativacao%TYPE --> Quantidade de dias que devera ser aguardado para negativacao apos o recebimento na Serasa
                           ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_altera_param_uf(pr_indexcecao           IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                              ,pr_dsuf                 IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                              ,pr_qtminimo_negativacao IN tbcobran_param_exc_neg_serasa.qtminimo_negativacao%TYPE --> Quantidade de dias minimo para a negativacao
                              ,pr_qtmaximo_negativacao IN tbcobran_param_exc_neg_serasa.qtmaximo_negativacao%TYPE --> Quantidade de dias maximo para a negativacao
                              ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_altera_cnae(pr_cdcnae   IN tbgen_cnae.cdcnae%TYPE --> Codigo da classificacao nacional de atividades economicas (CNAE)
                          ,pr_flserasa IN tbgen_cnae.flserasa%TYPE --> Pode negativar no Serasa (0=Nao, 1=Sim)
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_param_exc(pr_indexcecao IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                               ,pr_dsuf       IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                               ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_TAB097;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB097 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB097
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Dezembro - 2015                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela TAB097
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_param(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_param
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_param(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT tbcobran_param_negativacao.qtminimo_negativacao,
               tbcobran_param_negativacao.qtmaximo_negativacao,
               TO_CHAR(TO_DATE(tbcobran_param_negativacao.hrenvio_arquivo,'SSSSS'),'HH24:MI') hrenvio_arquivo,
               tbcobran_param_negativacao.vlminimo_boleto,
               tbcobran_param_negativacao.qtdias_vencimento,
               tbcobran_param_negativacao.qtdias_negativacao
          FROM tbcobran_param_negativacao
         WHERE tbcobran_param_negativacao.cdcooper = pr_cdcooper;
      rw_param cr_param%ROWTYPE;

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

      -- Cursor com os dados
      OPEN cr_param(pr_cdcooper => vr_cdcooper);
      FETCH cr_param INTO rw_param;
      CLOSE cr_param;

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
                            ,pr_tag_nova => 'inf'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtminimo_negativacao'
                            ,pr_tag_cont => rw_param.qtminimo_negativacao
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtmaximo_negativacao'
                            ,pr_tag_cont => rw_param.qtmaximo_negativacao
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'hrenvio_arquivo'
                            ,pr_tag_cont => rw_param.hrenvio_arquivo
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlminimo_boleto'
                            ,pr_tag_cont => rw_param.vlminimo_boleto
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdias_vencimento'
                            ,pr_tag_cont => rw_param.qtdias_vencimento
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdias_negativacao'
                            ,pr_tag_cont => rw_param.qtdias_negativacao
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

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_param;

  PROCEDURE pc_busca_param_exc(pr_indexcecao IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                              ,pr_dsuf       IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                              ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_param_exc
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametrizacao das excecoes de Negativacao Serasa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_param(pr_indexcecao IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE
                     ,pr_dsuf       IN tbcobran_param_exc_neg_serasa.dsuf%TYPE) IS 
        SELECT tbcobran_param_exc_neg_serasa.indexcecao,
               tbcobran_param_exc_neg_serasa.dsuf,
               tbcobran_param_exc_neg_serasa.qtminimo_negativacao,
               tbcobran_param_exc_neg_serasa.qtmaximo_negativacao
          FROM tbcobran_param_exc_neg_serasa
         WHERE tbcobran_param_exc_neg_serasa.indexcecao = decode(nvl(pr_indexcecao,0),0,tbcobran_param_exc_neg_serasa.indexcecao, pr_indexcecao)
           AND tbcobran_param_exc_neg_serasa.dsuf = decode(nvl(pr_dsuf,'0'),'0',tbcobran_param_exc_neg_serasa.dsuf, pr_dsuf);

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_auxconta_uf INTEGER := 0;

    BEGIN
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
                            ,pr_tag_nova => 'ufs'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'ufnegdif'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      --RITM0012246 - Inclusão de uma tag para receber as informações do tipo 3
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'ufneg'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Listagem de parametrizacao das excecoes de negativacao no Serasa
      FOR rw_param IN cr_param(pr_indexcecao => pr_indexcecao
                              ,pr_dsuf       => pr_dsuf) LOOP

        -- Indicador da excecao: 1 - UF utiliza AR
        IF rw_param.indexcecao = 1 THEN

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'ufs'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'uf'
                                ,pr_tag_cont => rw_param.dsuf
                                ,pr_des_erro => vr_dscritic);

        -- Indicador da excecao: 2 - UF utiliza excecao na parametrizacao dos dias de negativacao
        ELSIF rw_param.indexcecao = 2 THEN 

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'ufnegdif'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'inf'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'inf'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsuf'
                                ,pr_tag_cont => rw_param.dsuf
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'inf'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'qtminimo_negativacao'
                                ,pr_tag_cont => rw_param.qtminimo_negativacao
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'inf'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'qtmaximo_negativacao'
                                ,pr_tag_cont => rw_param.qtmaximo_negativacao
                                ,pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;

        -- RITM0012246 - Indicador da excecao: 3 - UF utiliza excecao na parametrizacao dos dias de negativacao
        ELSIF rw_param.indexcecao = 3 THEN 
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'ufneg'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'infneg'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'infneg'
                                ,pr_posicao  => vr_auxconta_uf
                                ,pr_tag_nova => 'dsuf'
                                ,pr_tag_cont => rw_param.dsuf
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'infneg'
                                ,pr_posicao  => vr_auxconta_uf
                                ,pr_tag_nova => 'qtminimo_negativacao'
                                ,pr_tag_cont => rw_param.qtminimo_negativacao
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'infneg'
                                ,pr_posicao  => vr_auxconta_uf
                                ,pr_tag_nova => 'qtmaximo_negativacao'
                                ,pr_tag_cont => rw_param.qtmaximo_negativacao
                                ,pr_des_erro => vr_dscritic);

          vr_auxconta_uf := vr_auxconta_uf + 1;

        END IF;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_param_exc;

  PROCEDURE pc_altera_param(pr_qtminimo_negativacao IN tbcobran_param_negativacao.qtminimo_negativacao%TYPE --> Quantidade de dias minimo para a negativacao
                           ,pr_qtmaximo_negativacao IN tbcobran_param_negativacao.qtmaximo_negativacao%TYPE --> Quantidade de dias maximo para a negativacao
                           ,pr_hrenvio_arquivo      IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_vlminimo_boleto      IN tbcobran_param_negativacao.vlminimo_boleto%TYPE --> Valor minimo do boleto para negativacao
                           ,pr_qtdias_vencimento    IN tbcobran_param_negativacao.qtdias_vencimento%TYPE --> Quantidade de dias que sera somado a data do envio para o calculo do vencimento
                           ,pr_qtdias_negativacao   IN tbcobran_param_negativacao.qtdias_negativacao%TYPE --> Quantidade de dias que devera ser aguardado para negativacao apos o recebimento na Serasa
                           ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_param
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar parametrizacao de Negativacao Serasa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
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

      -- Caso prazo minimo seja maior que o maximo
      IF pr_qtminimo_negativacao > pr_qtmaximo_negativacao THEN
        vr_dscritic := 'Prazo minimo deve ser menor que o prazo maximo.';
        RAISE vr_exc_saida;
      END IF;

      -- Caso o valor minimo seja negativo
      IF pr_vlminimo_boleto < 0 THEN
        vr_dscritic := 'Valor minimo do boleto nao pode ser negativo.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Inserir registro
        INSERT INTO tbcobran_param_negativacao
                   (tbcobran_param_negativacao.cdcooper
                   ,tbcobran_param_negativacao.qtminimo_negativacao
                   ,tbcobran_param_negativacao.qtmaximo_negativacao
                   ,tbcobran_param_negativacao.hrenvio_arquivo
                   ,tbcobran_param_negativacao.vlminimo_boleto
                   ,tbcobran_param_negativacao.qtdias_vencimento
                   ,tbcobran_param_negativacao.qtdias_negativacao)
             VALUES(vr_cdcooper
                   ,pr_qtminimo_negativacao
                   ,pr_qtmaximo_negativacao
                   ,TO_CHAR(TO_DATE(pr_hrenvio_arquivo,'HH24:MI'),'SSSSS')
                   ,pr_vlminimo_boleto
                   ,pr_qtdias_vencimento
                   ,pr_qtdias_negativacao);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existe deve alterar
          BEGIN
            UPDATE tbcobran_param_negativacao
               SET tbcobran_param_negativacao.qtminimo_negativacao = pr_qtminimo_negativacao
                  ,tbcobran_param_negativacao.qtmaximo_negativacao = pr_qtmaximo_negativacao
                  ,tbcobran_param_negativacao.hrenvio_arquivo      = TO_CHAR(TO_DATE(pr_hrenvio_arquivo,'HH24:MI'),'SSSSS')
                  ,tbcobran_param_negativacao.vlminimo_boleto      = pr_vlminimo_boleto
                  ,tbcobran_param_negativacao.qtdias_vencimento    = pr_qtdias_vencimento
                  ,tbcobran_param_negativacao.qtdias_negativacao   = pr_qtdias_negativacao
             WHERE tbcobran_param_negativacao.cdcooper             = vr_cdcooper;

          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_param;

  PROCEDURE pc_altera_param_uf(pr_indexcecao           IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                              ,pr_dsuf                 IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                              ,pr_qtminimo_negativacao IN tbcobran_param_exc_neg_serasa.qtminimo_negativacao%TYPE --> Quantidade de dias minimo para a negativacao
                              ,pr_qtmaximo_negativacao IN tbcobran_param_exc_neg_serasa.qtmaximo_negativacao%TYPE --> Quantidade de dias maximo para a negativacao
                              ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_param_uf
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar parametrizacao de excecao da Negativacao Serasa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
      -- Caso prazo minimo seja maior que o maximo
      IF pr_qtminimo_negativacao > pr_qtmaximo_negativacao THEN
        vr_dscritic := 'Prazo minimo deve ser menor que o prazo maximo.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Inserir registro
        INSERT INTO tbcobran_param_exc_neg_serasa
                   (tbcobran_param_exc_neg_serasa.indexcecao
                   ,tbcobran_param_exc_neg_serasa.dsuf
                   ,tbcobran_param_exc_neg_serasa.qtminimo_negativacao
                   ,tbcobran_param_exc_neg_serasa.qtmaximo_negativacao)
             VALUES(pr_indexcecao
                   ,pr_dsuf
                   ,pr_qtminimo_negativacao
                   ,pr_qtmaximo_negativacao);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existe deve alterar
          BEGIN
            UPDATE tbcobran_param_exc_neg_serasa
               SET tbcobran_param_exc_neg_serasa.qtminimo_negativacao = pr_qtminimo_negativacao
                  ,tbcobran_param_exc_neg_serasa.qtmaximo_negativacao = pr_qtmaximo_negativacao
             WHERE tbcobran_param_exc_neg_serasa.indexcecao           = pr_indexcecao
               AND tbcobran_param_exc_neg_serasa.dsuf                 = pr_dsuf;

          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar parametros: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_param_uf;

  PROCEDURE pc_altera_cnae(pr_cdcnae   IN tbgen_cnae.cdcnae%TYPE --> Codigo da classificacao nacional de atividades economicas (CNAE)
                          ,pr_flserasa IN tbgen_cnae.flserasa%TYPE --> Pode negativar no Serasa (0=Nao, 1=Sim)
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_altera_cnae
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar o campo flserasa do CNAE.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_param(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE) IS
        SELECT 1
          FROM tbgen_cnae
         WHERE tbgen_cnae.cdcnae = pr_cdcnae;
      rw_param cr_param%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound  BOOLEAN;

    BEGIN
      -- Efetua a busca do registro
      OPEN cr_param(pr_cdcnae => pr_cdcnae);
      FETCH cr_param INTO rw_param;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_param%FOUND;
      -- Fecha cursor
      CLOSE cr_param;

      -- Se nao achou faz raise
      IF NOT vr_blnfound THEN
        vr_dscritic := 'CNAE nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        UPDATE tbgen_cnae
           SET tbgen_cnae.flserasa = pr_flserasa
         WHERE tbgen_cnae.cdcnae   = pr_cdcnae;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar CNAE: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_altera_cnae;

  PROCEDURE pc_exclui_param_exc(pr_indexcecao IN tbcobran_param_exc_neg_serasa.indexcecao%TYPE --> Indicador da excecao (1-UF utiliza AR, 2-UF utiliza excecao na parametrizacao dos dias de negativacao)
                               ,pr_dsuf       IN tbcobran_param_exc_neg_serasa.dsuf%TYPE --> Unidade de federacao
                               ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_param_exc
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Dezembro/2015                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir parametrizacao das excecoes de Negativacao Serasa.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      BEGIN
        DELETE 
          FROM tbcobran_param_exc_neg_serasa
         WHERE tbcobran_param_exc_neg_serasa.indexcecao = pr_indexcecao
           AND tbcobran_param_exc_neg_serasa.dsuf = pr_dsuf;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao excluir UF: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

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

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_param_exc;

END TELA_TAB097;
/
