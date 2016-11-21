CREATE OR REPLACE PACKAGE CECRED.TELA_RECIPR IS

  PROCEDURE pc_busca_coop(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                         ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_apuracao(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                             ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                             ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_det_indicador(pr_nrdconta             IN crapass.nrdconta%TYPE --> Conta
                                  ,pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE --> ID unico do periodo de apuracao de atrelado a contratacao 
                                  ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_det_tarifa(pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE --> ID unico do periodo de apuracao de atrelado a contratacao
                               ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

END TELA_RECIPR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_RECIPR IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_RECIPR
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Marco - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela RECIPR
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_coop(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                         ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_coop
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar dados do cooperado.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

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
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

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
                            ,pr_tag_nova => 'nmprimtl'
                            ,pr_tag_cont => rw_crapass.nmprimtl
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECIPR: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_coop;

  PROCEDURE pc_busca_apuracao(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                             ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                             ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_apuracao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os periodos de apuracao de Reciprocidade.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os periodos de apuracao pelo convenio repassado
      CURSOR cr_apuracao(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS 
        SELECT apr.idapuracao_reciproci 
              ,INITCAP(prd.dsproduto) dsproduto
              ,apr.cdchave_produto nrcontr_conven
              ,crp.qtdmes_retorno_reciproci
              ,TO_CHAR(apr.dtinicio_apuracao,'dd/mm/rr') dtinicio_apuracao
              ,TO_CHAR(apr.dttermino_apuracao,'dd/mm/rr') dttermino_apuracao
              ,DECODE(apr.indsituacao_apuracao,'A',TRUNC(pr_dtmvtolt) - apr.dtinicio_apuracao
                                              ,'C',TRUNC(apr.dtcancela_apuracao) - apr.dtinicio_apuracao
                                                  ,apr.dttermino_apuracao - apr.dtinicio_apuracao) qtdias_decorrido
              ,crp.qtdmes_retorno_reciproci * 30 qtdias_previsto
              ,DECODE(apr.indsituacao_apuracao,'A','Em apuração'
                                              ,'C','Cancelada'
                                                  ,'Encerrada') dssituacao
              ,DECODE(apr.indsituacao_apuracao,'E',TO_CHAR(apr.perrecipro_atingida,'fm990d00'),'-') desrecipro_atingida
              ,DECODE(apr.indsituacao_apuracao,'E',DECODE(apr.flgtarifa_revertida,1,'Sim','Não'),'-') destarifa_revertida
              ,DECODE(apr.indsituacao_apuracao,'E',DECODE(apr.flgtarifa_debitada,1,'Sim','Não'),'-') destarifa_debitada
          FROM tbcc_produto     prd
              ,tbrecip_apuracao apr
              ,tbrecip_calculo  crp
         WHERE apr.cdproduto = prd.cdproduto
           AND apr.idconfig_recipro = crp.idcalculo_reciproci
           AND apr.cdcooper = pr_cdcooper
           AND apr.nrdconta = pr_nrdconta
           AND (pr_nrconven > 0 AND apr.cdchave_produto = pr_nrconven)
           AND apr.tpreciproci = 1 -- Somente aqueles com base em previsao / realizacao
      ORDER BY apr.idapuracao_reciproci DESC;
      
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
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

      -- Variaveis
      vr_auxconta INTEGER := 0;

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

      -- Buscar calendário
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat; 
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de periodos de apuracao pelo convenio repassado
      FOR rw_apuracao IN cr_apuracao(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrconven => pr_nrconven
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'apuracao'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'idapuracao_reciproci'
                              ,pr_tag_cont => rw_apuracao.idapuracao_reciproci
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsproduto'
                              ,pr_tag_cont => rw_apuracao.dsproduto
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nrcontr_conven'
                              ,pr_tag_cont => rw_apuracao.nrcontr_conven
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtdmes_retorno_reciproci'
                              ,pr_tag_cont => rw_apuracao.qtdmes_retorno_reciproci
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtinicio_apuracao'
                              ,pr_tag_cont => rw_apuracao.dtinicio_apuracao
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dttermino_apuracao'
                              ,pr_tag_cont => rw_apuracao.dttermino_apuracao
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtdias_decorrido'
                              ,pr_tag_cont => rw_apuracao.qtdias_decorrido
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtdias_previsto'
                              ,pr_tag_cont => rw_apuracao.qtdias_previsto
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dssituacao'
                              ,pr_tag_cont => rw_apuracao.dssituacao
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'desrecipro_atingida'
                              ,pr_tag_cont => rw_apuracao.desrecipro_atingida
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'destarifa_revertida'
                              ,pr_tag_cont => rw_apuracao.destarifa_revertida
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'apuracao'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'destarifa_debitada'
                              ,pr_tag_cont => rw_apuracao.destarifa_debitada
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB097: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_apuracao;

  PROCEDURE pc_busca_det_indicador(pr_nrdconta             IN crapass.nrdconta%TYPE --> Conta
                                  ,pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE --> ID unico do periodo de apuracao de atrelado a contratacao
                                  ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_det_indicador
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os indicadores contratados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona os indicadores contratados
      CURSOR cr_indicador(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT idr.idindicador
              ,idr.nmindicador
              ,idr.tpindicador
              ,(icr.vlcontrata * crp.qtdmes_retorno_reciproci) vlcontrata
              ,DECODE(apr.indsituacao_apuracao,'A',RCIP0001.fn_valor_realizado_indicador(pr_cdcooper
                                                                                        ,pr_nrdconta
                                                                                        ,idr.idindicador
                                                                                        ,0
                                                                                        ,apr.dtinicio_apuracao
                                                                                        ,pr_dtmvtolt)
                                                  ,air.vlrealizado) vlrrealizado
             ,DECODE(idr.tpindicador,'A','-',to_char(icr.pertolera,'fm990d00')) pertolera
             ,DECODE(apr.indsituacao_apuracao,'E',DECODE(air.flgatingido,1,'Sim','Não'),'-') desatingido
         FROM tbrecip_apuracao        apr
             ,tbrecip_apuracao_indica air
             ,tbrecip_indica_calculo  icr 
             ,tbrecip_calculo         crp
             ,tbrecip_indicador       idr
        WHERE apr.idapuracao_reciproci = pr_idapuracao_reciproci
          AND apr.idapuracao_reciproci = air.idapuracao_reciproci
          AND apr.idconfig_recipro     = icr.idcalculo_reciproci
          AND air.idindicador          = icr.idindicador
          AND icr.idcalculo_reciproci  = crp.idcalculo_reciproci
          AND icr.idindicador          = idr.idindicador;
           
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_auxconta INTEGER := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_RCIPR'
                                ,pr_action => NULL);

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

      -- Buscar calendário
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de indicadores contratados
      FOR rw_indicador IN cr_indicador(pr_cdcooper             => vr_cdcooper
                                      ,pr_nrdconta             => pr_nrdconta
                                      ,pr_idapuracao_reciproci => pr_idapuracao_reciproci
                                      ,pr_dtmvtolt             => rw_crapdat.dtmvtolt) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indicador'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nmindicador'
                              ,pr_tag_cont => rw_indicador.nmindicador
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'tpindicador'
                              ,pr_tag_cont => rw_indicador.tpindicador
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlcontrata'
                              ,pr_tag_cont => RCIP0001.fn_format_valor_indicador(rw_indicador.idindicador,rw_indicador.vlcontrata)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vlrrealizado'
                              ,pr_tag_cont => RCIP0001.fn_format_valor_indicador(rw_indicador.idindicador,rw_indicador.vlrrealizado)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'pertolera'
                              ,pr_tag_cont => rw_indicador.pertolera
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'desatingido'
                              ,pr_tag_cont => rw_indicador.desatingido
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECIPR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_det_indicador;

  PROCEDURE pc_busca_det_tarifa(pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE --> ID unico do periodo de apuracao de atrelado a contratacao
                               ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_det_tarifa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para selecionar as informacoes de apuracao de tarifas.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Seleciona a apuracao de tarifas
      CURSOR cr_tarifa(pr_idapuracao_reciproci IN tbrecip_apuracao.idapuracao_reciproci%TYPE) IS
        SELECT tar.dstarifa
              ,apt.vltarifa_original
              ,apt.perdesconto
              ,COUNT(1) qtdocorre
              ,SUM(apt.vltarifa_original-apt.vltarifa_cobrado) vldesconto_acumulado
         FROM tbrecip_apuracao        apr
             ,tbrecip_apuracao_tarifa apt
             ,craptar                 tar
        WHERE apr.idapuracao_reciproci = pr_idapuracao_reciproci
          AND apt.cdtarifa = tar.cdtarifa
          AND apt.cdcooper = apr.cdcooper
          AND apt.nrdconta = apr.nrdconta
          AND apt.cdproduto = apr.cdproduto
          AND apt.cdchave_produto = apr.cdchave_produto
          AND apt.vltarifa_original > 0
          AND apt.dtocorre BETWEEN apr.dtinicio_apuracao AND DECODE(apr.indsituacao_apuracao,'C',apr.dtcancela_apuracao
                                                                                           ,apr.dttermino_apuracao)
     GROUP BY tar.dstarifa
             ,apt.vltarifa_original
             ,apt.perdesconto
     ORDER BY tar.dstarifa
             ,apt.vltarifa_original
             ,apt.perdesconto;
           
      -- Variável de críticas
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

      -- Variaveis
      vr_auxconta INTEGER := 0;

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

      -- Listagem de indicadores contratados
      FOR rw_tarifa IN cr_tarifa(pr_idapuracao_reciproci => pr_idapuracao_reciproci) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indicador'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dstarifa'
                              ,pr_tag_cont => rw_tarifa.dstarifa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'qtdocorre'
                              ,pr_tag_cont => rw_tarifa.qtdocorre
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vltarifa_original'
                              ,pr_tag_cont => rw_tarifa.vltarifa_original
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'perdesconto'
                              ,pr_tag_cont => rw_tarifa.perdesconto
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'indicador'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'vldesconto_acumulado'
                              ,pr_tag_cont => rw_tarifa.vldesconto_acumulado
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela RECIPR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_det_tarifa;

END TELA_RECIPR;
/
