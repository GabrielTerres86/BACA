CREATE OR REPLACE PACKAGE CECRED.TELA_PARPRT IS

  /* .............................................................................
  
  Programa: pc_busca_param
  Sistema : Ayllos Web
  Autor   : Marcus Guilherme Kaefer
  Data    : Janeiro/2018                 Ultima atualizacao: 29/01/2018

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.

  Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  ..............................................................................*/

  PROCEDURE pc_consulta_parprt(pr_cdcooper 				IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                          ,pr_xmllog   					IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic 					OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic 					OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   					IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo 					OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro 					OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_atualiza_parprt(pr_cdcooper 				IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
						   ,pr_qtlimitemin_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia%TYPE --> Limite minimo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_qtlimitemax_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia%TYPE --> Limite maximo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_hrenvio_arquivo      	IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_qtdias_cancelamento  	IN TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento%TYPE --> Quantidade de dias que para solicitar cancelamento
                           ,pr_flcancelamento         	IN TBCOBRAN_PARAM_PROTESTO.flcancelamento%TYPE --> Flag para definir se permite cancelamento quando boleto ja estiver em cartorio
                           ,pr_dsuf                   	IN TBCOBRAN_PARAM_PROTESTO.dsuf%TYPE --> Lista de UFs que autorizam exclusão
                           ,pr_dscnae                 	IN TBCOBRAN_PARAM_PROTESTO.dscnae%TYPE --> Lista de CNAEs não permitidos para protesto
                           ,pr_xmllog                 	IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic               	OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic               	OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml                 	IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo               	OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro               	OUT VARCHAR2); --> Erros do processo

END TELA_PARPRT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARPRT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARPRT
  --  Sistema  : Ayllos Web
  --  Autor    : Marcus Guilherme Kaefer
  --  Data     : Janeiro - 2018                 Ultima atualizacao: 29/01/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARPRT
  --
  -- Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_parprt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_param
    Sistema : Ayllos Web
    Autor   : Marcus Guilherme Kaefer
    Data    : Janeiro/2018                 Ultima atualizacao: 29/01/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.

    Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_param(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT TBCOBRAN_PARAM_PROTESTO.dsuf,
               TBCOBRAN_PARAM_PROTESTO.dscnae,
               TO_CHAR(TO_DATE(TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo,'SSSSS'),'HH24:MI') hrenvio_arquivo,
               TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia,
               TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia,
               TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento,
               TBCOBRAN_PARAM_PROTESTO.flcancelamento
          FROM TBCOBRAN_PARAM_PROTESTO
         WHERE TBCOBRAN_PARAM_PROTESTO.cdcooper = pr_cdcooper;

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
      OPEN cr_param(pr_cdcooper => pr_cdcooper);
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
                            ,pr_tag_nova => 'qtlimitemin_tolerancia'
                            ,pr_tag_cont => rw_param.qtlimitemin_tolerancia
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtlimitemax_tolerancia'
                            ,pr_tag_cont => rw_param.qtlimitemax_tolerancia
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
                            ,pr_tag_nova => 'qtdias_cancelamento'
                            ,pr_tag_cont => rw_param.qtdias_cancelamento
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flcancelamento'
                            ,pr_tag_cont => rw_param.flcancelamento
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsuf'
                            ,pr_tag_cont => rw_param.dsuf
                            ,pr_des_erro => vr_dscritic);
                            
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dscnae'
                            ,pr_tag_cont => rw_param.dscnae
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
        pr_dscritic := 'Erro geral na rotina da tela PARPRT: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_parprt;
  
  PROCEDURE pc_atualiza_parprt(pr_cdcooper 				    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
						               ,pr_qtlimitemin_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia%TYPE --> Limite minimo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_qtlimitemax_tolerancia	IN TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia%TYPE --> Limite maximo tolerancia (em dias) para envio de boleto para protesto
                           ,pr_hrenvio_arquivo      	IN VARCHAR2 --> Horario para envio do arquivo
                           ,pr_qtdias_cancelamento  	IN TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento%TYPE --> Quantidade de dias que para solicitar cancelamento
                           ,pr_flcancelamento       	IN TBCOBRAN_PARAM_PROTESTO.flcancelamento%TYPE --> Flag para definir se permite cancelamento quando boleto ja estiver em cartorio
                           ,pr_dsuf                 	IN TBCOBRAN_PARAM_PROTESTO.dsuf%TYPE --> Lista de UFs que autorizam exclusão
                           ,pr_dscnae                 IN TBCOBRAN_PARAM_PROTESTO.dscnae%TYPE --> Lista de CNAEs não permitidos para protesto
                           ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro               OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_atualiza_parprt
    Sistema : Ayllos Web
    Autor   : Marcus Guilherme Kaefer
    Data    : Janeiro/2018                 Ultima atualizacao: 29/01/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar parametrizacao de Negativacao Serasa.

    Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
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
      IF pr_qtlimitemin_tolerancia > pr_qtlimitemax_tolerancia THEN
        vr_dscritic := 'Limite minimo deve ser menor que o limite maximo.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Inserir registro
        INSERT INTO TBCOBRAN_PARAM_PROTESTO
                   (TBCOBRAN_PARAM_PROTESTO.cdcooper
                   ,TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia
                   ,TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia
                   ,TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo
                   ,TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento
                   ,TBCOBRAN_PARAM_PROTESTO.flcancelamento
                   ,TBCOBRAN_PARAM_PROTESTO.dsuf
                   ,TBCOBRAN_PARAM_PROTESTO.dscnae)
             VALUES(pr_cdcooper
                   ,pr_qtlimitemin_tolerancia
                   ,pr_qtlimitemax_tolerancia
                   ,TO_CHAR(TO_DATE(pr_hrenvio_arquivo,'HH24:MI'),'SSSSS')
                   ,pr_qtdias_cancelamento
                   ,pr_flcancelamento
                   ,pr_dsuf
                   ,pr_dscnae);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Se ja existe deve alterar
          BEGIN
            UPDATE TBCOBRAN_PARAM_PROTESTO
               SET TBCOBRAN_PARAM_PROTESTO.qtlimitemin_tolerancia = pr_qtlimitemin_tolerancia
                  ,TBCOBRAN_PARAM_PROTESTO.qtlimitemax_tolerancia = pr_qtlimitemax_tolerancia
                  ,TBCOBRAN_PARAM_PROTESTO.hrenvio_arquivo        = TO_CHAR(TO_DATE(pr_hrenvio_arquivo,'HH24:MI'),'SSSSS')
                  ,TBCOBRAN_PARAM_PROTESTO.qtdias_cancelamento    = pr_qtdias_cancelamento
                  ,TBCOBRAN_PARAM_PROTESTO.flcancelamento         = pr_flcancelamento
                  ,TBCOBRAN_PARAM_PROTESTO.dsuf                   = pr_dsuf
                  ,TBCOBRAN_PARAM_PROTESTO.dscnae                 = pr_dscnae
             WHERE TBCOBRAN_PARAM_PROTESTO.cdcooper               = pr_cdcooper;

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
        pr_dscritic := 'Erro geral na rotina da tela PARPRT: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_atualiza_parprt;

END TELA_PARPRT;
/
