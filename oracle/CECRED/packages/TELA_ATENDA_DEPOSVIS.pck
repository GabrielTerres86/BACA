CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DEPOSVIS IS

FUNCTION fn_soma_dias_uteis_data(pr_cdcooper NUMBER, pr_dtmvtolt DATE, pr_qtddias INTEGER)
    RETURN DATE;


PROCEDURE pc_busca_saldos_devedores(pr_nrdconta crapass.nrdconta%TYPE    --> COnta para a qual se deseja obter os saldos
                                  , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2);

  -- retorna datas de prejuizo da conta, em XML
  PROCEDURE pc_busca_dts_preju_atraso ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                               ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                               ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                               ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_preju_cc_L100(pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_valorprj OUT NUMBER             --> valor do prejuizo
                                   ,pr_dtiniprj OUT DATE);          --> data de registro do prejuizo

  PROCEDURE pc_busca_inicio_atraso (pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_dtiniatr OUT DATE);          --> retorno da data de inicio de atraso

  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Descricao do erro

  -- retorna dados da conta em prejuizo, em XML
  PROCEDURE pc_busca_vlrs_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  -- efetua pagamento de conta em prejuizo
  PROCEDURE pc_paga_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_vlrpagto  IN NUMBER                --> valor pago
                                     ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_paga_emprestimo_ct(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                 ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                 ,pr_vlrpagto  IN NUMBER                --> valor pago
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

  -- consulta data de inclusão prejuízo
  PROCEDURE pc_consulta_dt_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);


  PROCEDURE pc_busca_saldos_juros60(pr_cdcooper IN crapris.cdcooper%TYPE --> Código da cooperativa
                                , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se não informado, a procedure recupera da base)
                                , pr_vlsld59d OUT NUMBER               --> Saldo até 59 dias (saldo devedor - juros +60)
                                , pr_vljuro60 OUT NUMBER
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Busca saldo até 59 dias e valores de juros +60 detalhados (hist. 37+57+2718 e hist 38)
  PROCEDURE pc_busca_saldos_juros60_det(pr_cdcooper IN crapris.cdcooper%TYPE --> Código da cooperativa
                                    , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                    , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se não informado, a procedure recupera da base)
																		, pr_dtlimite IN DATE   DEFAULT NULL --> Data limite para filtro dos lançamentos na CRAPLCM
                                    , pr_vlsld59d OUT NUMBER             --> Saldo até 59 dias (saldo devedor - juros +60)
                                    , pr_vljucneg OUT NUMBER             --> Juros +60 (Hist. 37 + 57 + 2718)
																  	, pr_vljucesp OUT NUMBER             -- Juros + 60 (Hist. 38)
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Consulta a situação do empréstimo
  PROCEDURE pc_consulta_sit_empr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

END TELA_ATENDA_DEPOSVIS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DEPOSVIS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DEPOSVIS
  --  Sistema  : Procedimentos para tela ATENDA - Depósitos à Vista
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Março/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para tela ATENDA - Depósitos à Vista
  --
  -- Alterado  : 01/08/2018 - Ajustes pagamento Prejuízo
  --                          PJ 450 - Diego Simas - AMcom
  --
  --             08/08/2018 - Ajustes pagamento de Empréstimo
  --                          PJ 450 - Diego Simas - AMcom
  --                          
  --             23/08/2018 - Apresentar mensagem quando o valor do pagamento
  --                          é maior que o saldo devedor do empréstimo
  --                          PJ 450 - Diego Simas - AMcom                            
  --
  --
  ---------------------------------------------------------------------------------------------------------------

FUNCTION fn_soma_dias_uteis_data(pr_cdcooper NUMBER, pr_dtmvtolt DATE, pr_qtddias INTEGER)
    RETURN DATE AS vr_data DATE;

  /* ............................................................................
        Programa: fn_soma_dias_uteis_data
        Sistema : CECRED
        Sigla   : CECRED
        Autor   : Reginaldo/AMcom
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Soma a quantidade de dias úteis (desconsiderando finais de semana e feriados)
                    à data de referência informada.
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

  ----->>> CURSORES <<<-----

  CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                 ,pr_dtcompar IN crapfer.dtferiad%TYPE) IS
  SELECT cf.dsferiad
    FROM crapfer cf
   WHERE cf.cdcooper = pr_cdcooper
     AND cf.dtferiad = pr_dtcompar;
  rw_crapfer cr_crapfer%ROWTYPE;

  ----->>> VARIÁVEIS <<<-----

  vr_dtcompar DATE;
  vr_contador   INTEGER := 0;

BEGIN
    vr_dtcompar := pr_dtmvtolt;

    LOOP
      -- Busca se a data é feriado
      OPEN cr_crapfer(pr_cdcooper, vr_dtcompar);
      FETCH cr_crapfer INTO rw_crapfer;

      -- Se a data não for sabado ou domingo ou feriado
      IF NOT(TO_CHAR(vr_dtcompar, 'd') IN (1,7) OR cr_crapfer%FOUND) THEN
        vr_contador := vr_contador + 1;
      END IF;

      CLOSE cr_crapfer;

      -- Sair quando atingir quant. de dias desejada
      EXIT WHEN vr_contador > pr_qtddias;

      -- Decrementar data
      vr_dtcompar := vr_dtcompar + 1;
    END LOOP;

    vr_data := vr_dtcompar;

    RETURN vr_data;
END fn_soma_dias_uteis_data;

PROCEDURE pc_busca_saldos_devedores(pr_nrdconta crapass.nrdconta%TYPE    --> COnta para a qual se deseja obter os saldos
                                  , pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_saldos_devedores
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Março/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina que obtém o valor do Saldo Devedor até 59 dias de atraso,
                    Saldo Devedor a partir do 60º dia de atraso e Valor do IOF a Debitar
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----------->>> CURSORES <<<---------

    -- Informações de saldo atual da conta corrente
    CURSOR cr_saldos(pr_cdcooper NUMBER
                   , pr_nrdconta NUMBER) IS
    SELECT abs(sld.vlsddisp) - (SELECT ass.vllimcre
                             FROM crapass ass
                            WHERE ass.cdcooper = sld.cdcooper
                              AND ass.nrdconta = sld.nrdconta ) vlsddisp
         , sld.dtrisclq
         , sld.qtddsdev
         , sld.vliofmes
      FROM crapsld sld
     WHERE sld.cdcooper = pr_cdcooper
       AND sld.nrdconta = pr_nrdconta;
    rw_saldos cr_saldos%ROWTYPE;

    -- Histórico do saldo da conta
    CURSOR cr_crapsda(pr_cdcooper NUMBER
                    , pr_nrdconta NUMBER
                    , pr_dtmvtolt DATE) IS
    SELECT abs(sda.vlsddisp) - sda.vllimcre vlsddisp
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper
       AND sda.nrdconta = pr_nrdconta
       AND sda.dtmvtolt = pr_dtmvtolt;
    rw_crapsda cr_crapsda%ROWTYPE;

    -- Calendário da cooperativa
    rw_crapdat btch0001.rw_crapdat%TYPE;

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida              EXCEPTION;
    vr_exc_saldo_indisponivel EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_saldo_devedor_59dias      NUMBER := 0; -- Saldo devedor até 59 dias
    vr_vljuros60                 NUMBER := 0; -- Valor dos juros +60
    vr_saldo_devedor_mais_60dias NUMBER := 0; -- Saldo devedor a partir do 60º dia
    vr_saldo_devedor_total       NUMBER := 0; -- Saldo devedor total
    vr_valor_iof_debitar         NUMBER := 0; -- Valor do IOF a debitar
    vr_data_59dias_atraso        DATE;
    vr_data_corte                DATE; -- Data de corte para contagem em dias úteis/corridos (substituir por parâmetro do BD)

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


      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      OPEN cr_saldos(vr_cdcooper, pr_nrdconta);
      FETCH cr_saldos INTO rw_saldos;
      CLOSE cr_saldos;

      vr_data_corte := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                         ,'DD/MM/RRRR');

      pc_busca_saldos_juros60(pr_cdcooper => vr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_vlsld59d => vr_saldo_devedor_59dias
                            , pr_vljuro60 => vr_vljuros60
                            , pr_cdcritic => vr_cdcritic
                            , pr_dscritic => vr_dscritic);

      -- Insere informações dos saldos no XML de retorno
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Dados',
                              pr_posicao  => 0,
                              pr_tag_nova => 'saldo_devedor_59dias',
                              pr_tag_cont => to_char(vr_saldo_devedor_59dias,
                                                     '9G999G990D00',
                                                     'nls_numeric_characters='',.'''),
                              pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Dados',
                              pr_posicao  => 0,
                              pr_tag_nova => 'saldo_devedor_mais_60dias',
                              pr_tag_cont => to_char(vr_vljuros60,
                                                     '9G999G990D00',
                                                     'nls_numeric_characters='',.'''),
                              pr_des_erro => vr_dscritic);

      vr_valor_iof_debitar := nvl(rw_saldos.vliofmes, 0);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Dados',
                              pr_posicao  => 0,
                              pr_tag_nova => 'valor_iof_debitar',
                              pr_tag_cont => to_char(vr_valor_iof_debitar,
                                                     '9G999G990D00',
                                                     'nls_numeric_characters='',.'''),
                              pr_des_erro => vr_dscritic);

       vr_saldo_devedor_total := vr_saldo_devedor_59dias +
                                 vr_vljuros60 +
                                 vr_valor_iof_debitar;

       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Dados',
                              pr_posicao  => 0,
                              pr_tag_nova => 'valor_saldo_devedor_total',
                              pr_tag_cont => to_char(vr_saldo_devedor_total,
                                                     '9G999G990D00',
                                                     'nls_numeric_characters='',.'''),
                              pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_DEPOSVIS - pc_busca_saldos_devedores: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN vr_exc_saldo_indisponivel THEN
        pr_dscritic := 'Erro na rotina da tela TELA_ATENDA_DEPOSVIS - pc_busca_saldos_devedores: Erro ao obter SALDO DEVEDOR ATÉ 59 DIAS.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_DEPOSVIS - pc_busca_saldos_devedores: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_saldos_devedores;


    /* .............................................................................

     Programa: pc_busca_dts_preju_atraso
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Marco/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Retorna XML com as datas, de transferencia de conta para prejuizo e Data de início de atraso

     Alteracoes:
     ..............................................................................*/
  PROCEDURE pc_busca_dts_preju_atraso ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                       ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2)  IS
    vr_exc_erro EXCEPTION;
    vr_dttrapre date;
    vr_dtiniatr date;
    vr_vlratra number;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro
  BEGIN
    pc_busca_inicio_atraso(pr_nrdconta=>pr_nrdconta,
                           pr_cdcooper=>pr_cdcooper,
                           pr_dtiniatr=>vr_dtiniatr);

    pc_busca_preju_cc_L100(pr_nrdconta=>pr_nrdconta,
                           pr_cdcooper=>pr_cdcooper,
                           pr_valorprj=>vr_vlratra,
                           pr_dtiniprj=>vr_dttrapre);


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
                          ,pr_tag_nova => 'dttrapre'
                          ,pr_tag_cont => TO_CHAR(vr_dttrapre, 'DD/MM/YYYY')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtiniatr'
                          ,pr_tag_cont => TO_CHAR(vr_dtiniatr, 'DD/MM/YYYY')
                          ,pr_des_erro => vr_dscritic);

    EXCEPTION
        WHEN vr_exc_erro THEN
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
        WHEN OTHERS THEN
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');

  END pc_busca_dts_preju_atraso;

/* .............................................................................
     Programa: pc_busca_inicio_atraso
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Marco/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : retorna data do inicio de atraso de uma conta

     Alteracoes:
     ..............................................................................*/
  PROCEDURE pc_busca_inicio_atraso (pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_dtiniatr OUT DATE)  IS          --> retorno da data de inicio de atraso
    CURSOR cr_crapris (
                    pr_cdcooper IN crapris.cdcooper%TYPE,
                    pr_nrdconta IN crapris.nrdconta%TYPE
                   ) IS
    SELECT dtinictr FROM crapris
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND cdmodali = 101 -- ADP
       AND cdorigem = 1 -- c/c
       and dtrefere = (select dtmvtoan from crapdat where cdcooper = pr_cdcooper);

    rw_crapris cr_crapris%ROWTYPE;
  BEGIN
    -- Busca data de inicio do atraso
    OPEN cr_crapris(pr_cdcooper, pr_nrdconta);
    FETCH cr_crapris
     INTO rw_crapris;
    -- Fecha o cursor
    CLOSE cr_crapris;

    pr_dtiniatr := rw_crapris.dtinictr;
  END pc_busca_inicio_atraso;

    /* .............................................................................
     Programa: fn_busca_preju_cc_L100
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Marco/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : retorna informacoes de prejuizo de conta corrente com base no contrato linha 100 e base nos dados gerados pela central de risco

     Alteracoes:
     ..............................................................................*/
  PROCEDURE pc_busca_preju_cc_L100(pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_valorprj OUT NUMBER            --> valor do prejuizo
                                   ,pr_dtiniprj OUT DATE)  IS          --> data de registro do prejuizo
    CURSOR cr_crapepr (
                      pr_cdcooper IN crapepr.cdcooper%TYPE,
                      pr_nrdconta IN crapris.nrdconta%TYPE
                     ) IS
    SELECT vlsdprej, dtmvtolt FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND cdlcremp = 100 -- Linha 100 (indicador de que conta tem um contrato de prejuizo)
       AND vlsdprej > 0; -- com valor pendente

    rw_crapepr cr_crapepr%ROWTYPE;
  BEGIN
    -- Busca registro de linha 100, indicando contrato de prejuizo
    OPEN cr_crapepr(pr_cdcooper, pr_nrdconta);
    FETCH cr_crapepr
     INTO rw_crapepr;
    -- Fecha o cursor
    CLOSE cr_crapepr;

    pr_valorprj := nvl(rw_crapepr.vlsdprej, 0);
    pr_dtiniprj := rw_crapepr.dtmvtolt;
  END pc_busca_preju_cc_L100;

  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_preju_cc
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Maio/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Consulta para verificar se a conta corrente houve prejuizo ou se esta em prejuizo.

    Alterações : PJ450 - Adicionado campo indicador de prejuizo da conta
               (Renato Cordeiro - AMCOM)

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar se já houve prejuizo nessa conta
    CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT t.nrdconta
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;

    --> Consultar crapass
    CURSOR cr_crapass(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                      pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT c.inprejuz
        FROM crapass c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Variaveis Locais
    vr_despreju VARCHAR2(200);
    vr_inprejuz INTEGER;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
 /*   gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
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
    END IF; */

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

    -----> PROCESSAMENTO PRINCIPAL <-----
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);

    FETCH cr_crapass INTO rw_crapass;

    vr_despreju := '';

    IF cr_crapass%FOUND THEN
      CLOSE cr_crapass;
      IF rw_crapass.inprejuz = 1 THEN
        -- Conta Corrente em Prejuízo
        vr_despreju := 'Conta Corrente em Prejuízo';
      ELSE
        OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_prejuizo INTO rw_prejuizo;
        IF cr_prejuizo%FOUND THEN
          CLOSE cr_prejuizo;
          -- Houve prejuízo de Conta Corrente
          vr_despreju := 'Houve prejuízo de Conta Corrente';
        ELSE
          CLOSE cr_prejuizo;
        END IF;
      END IF;
    ELSE
      CLOSE cr_crapass;
    END IF;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'despreju',
                           pr_tag_cont => vr_despreju,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inprejuz',
                           pr_tag_cont => rw_crapass.inprejuz,
                           pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_preju_cc --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_preju_cc;

    /* .............................................................................

     Programa: pc_busca_dts_preju_atraso
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Junho/2018.                    Ultima atualizacao: 20/08/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Retorna XML com os valores do prejuizo da conta corrente

     Alteracoes: 01/08/2018 - Ajustes pagamento Prejuízo
                              PJ 450 - Diego Simas - AMcom

                 20/08/2018 - Inclusão do campo juremune (Juros Remuneratório)
                              PJ 450 - Diego Simas - AMcom

     ..............................................................................*/
  PROCEDURE pc_busca_vlrs_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)  IS
    -- CURSORES --
    CURSOR cr_tbcc_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                            pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT prej.vlsdprej
           , prej.vljur60_ctneg
           , prej.vljur60_lcred
           , prej.vljuprej
           , sld.vliofmes
           , prej.idprejuizo
           , prej.dtinclusao
        FROM tbcc_prejuizo prej
        LEFT JOIN crapsld sld
               ON sld.nrdconta = prej.nrdconta
              AND sld.cdcooper = prej.cdcooper
       WHERE prej.cdcooper = pr_cdcooper
         AND prej.nrdconta = pr_nrdconta
         AND prej.dtliquidacao IS NULL;
    rw_tbcc_prejuizo cr_tbcc_prejuizo%ROWTYPE;

    -- variaveis
    vr_vlsdprej           tbcc_prejuizo.vlsdprej%TYPE;
    vr_vlttjurs           tbcc_prejuizo.vljuprej%TYPE;
    vr_vltotiof           crapsld.vliofmes%TYPE := 0;

    vr_vljupre_prov NUMBER:=0;

    -- erros
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  BEGIN
     OPEN BTCH0001.cr_crapdat(pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     CLOSE BTCH0001.cr_crapdat;

     OPEN cr_tbcc_prejuizo(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta);
     FETCH cr_tbcc_prejuizo INTO rw_tbcc_prejuizo;

		 IF cr_tbcc_prejuizo%FOUND THEN
			 PREJ0003.pc_calc_juros_remun_prov(pr_cdcooper => pr_cdcooper
			                                 , pr_nrdconta => pr_nrdconta
																			 , pr_vljuprov => vr_vljupre_prov
																			 , pr_cdcritic => vr_cdcritic
																			 , pr_dscritic => vr_dscritic);

				vr_vlsdprej := rw_tbcc_prejuizo.vlsdprej +
											 rw_tbcc_prejuizo.vljur60_ctneg +
											 rw_tbcc_prejuizo.vljur60_lcred;
				vr_vlttjurs := rw_tbcc_prejuizo.vljuprej;
				vr_vltotiof := rw_tbcc_prejuizo.vliofmes;
		 END IF;

    CLOSE cr_tbcc_prejuizo;

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
                          ,pr_tag_nova => 'vlsdprej'
                          ,pr_tag_cont => to_char(vr_vlsdprej,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'vlttjurs'
                          ,pr_tag_cont => to_char(vr_vlttjurs,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'vltotiof'
                          ,pr_tag_cont => to_char(vr_vltotiof,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'juremune'
                          ,pr_tag_cont => to_char(vr_vljupre_prov + vr_vlttjurs,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    EXCEPTION
        WHEN vr_exc_erro THEN
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
        WHEN OTHERS THEN
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');

  END pc_busca_vlrs_prejuz_cc;

      /* .............................................................................

     Programa: pc_busca_dts_preju_atraso
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Junho/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : efetua pagamento de conta em prejuizo

     Alteracoes:
     ..............................................................................*/
  PROCEDURE pc_paga_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_vlrpagto  IN NUMBER                --> valor pago
                                     ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)  IS

    CURSOR cr_prejuizo IS
    SELECT prj.vlsdprej
         , prj.vljuprej
         , prj.vljur60_ctneg
         , prj.vljur60_lcred
         , prj.vlsldlib
      FROM tbcc_prejuizo prj
     WHERE prj.cdcooper = pr_cdcooper
       AND prj.nrdconta = pr_nrdconta
       AND prj.dtliquidacao IS NULL;
    rw_prejuizo cr_prejuizo%ROWTYPE;

    -- erros
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    vr_slddev NUMBER;
		vr_juprej_prov NUMBER;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  BEGIN
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    OPEN cr_prejuizo;
    FETCH cr_prejuizo INTO rw_prejuizo;
    CLOSE cr_prejuizo;

		PREJ0003.pc_calc_juros_remun_prov(pr_cdcooper => pr_cdcooper
		                                , pr_nrdconta => pr_nrdconta
																		, pr_vljuprov => vr_juprej_prov
																		, pr_cdcritic => vr_cdcritic
																		, pr_dscritic => vr_dscritic);

    vr_slddev := rw_prejuizo.vlsdprej +
                 rw_prejuizo.vljuprej +
                 rw_prejuizo.vljur60_ctneg +
                 rw_prejuizo.vljur60_lcred +
								 vr_juprej_prov;

    IF (pr_vlrpagto + nvl(pr_vlrabono, 0)) > vr_slddev THEN
      vr_dscritic := 'O valor total informado para pagamento é maior que o saldo devedor.';

      RAISE vr_exc_erro;
    END IF;

		IF pr_vlrpagto > PREJ0003.fn_sld_cta_prj(pr_cdcooper, pr_nrdconta) THEN
			vr_dscritic := 'O valor informado para pagamento é maior que o saldo disponível.';

      RAISE vr_exc_erro;
		END IF;

    PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                               , pr_cdoperad => '1'
                               , pr_vllanmto => pr_vlrpagto
                               , pr_dtmvtolt => rw_crapdat.dtmvtolt
                               , pr_cdcritic => vr_cdcritic
                               , pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    PREJ0003.pc_pagar_prejuizo_cc(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_vlrpagto => pr_vlrpagto
                                , pr_vlrabono => pr_vlrabono
                                , pr_cdcritic => vr_cdcritic
                                , pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;

    EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

					pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Não foi possível efetuar o pagamento do prejuízo. ERRO -> ' || SQLERRM ;

					pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
  END pc_paga_prejuz_cc;

  PROCEDURE pc_paga_emprestimo_ct(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa (0-processa todas)
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                 ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                 ,pr_vlrpagto  IN NUMBER                --> valor pago
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2)  IS
  /* .............................................................................

  Programa: pc_paga_emprestimo_ct
  Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
  Sigla   : EMPR
  Autor   : Diego Simas
  Data    : Agosto/2018.                    Ultima atualizacao: 23/08/2018

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Efetua pagamento de empréstimo.

  Alteracoes: 23/08/2018 - Apresentar mensagem quando o valor do pagamento
                           é maior que o saldo devedor do empréstimo
                           PJ 450 - Diego Simas - AMcom   

  ..............................................................................*/

	-- Cursores                       
    CURSOR cr_crapepr(pr_cdcooper IN crapris.cdcooper%TYPE,
                      pr_nrdconta IN crapris.nrdconta%TYPE,
                      pr_nrctremp IN crapris.nrctremp%TYPE) IS
    SELECT c.inprejuz         
      FROM crapepr c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- erros
    vr_exc_erro EXCEPTION;

    --Variaveis de trabalho
    vr_idvlrmin  NUMBER;
    vr_vltotpag  NUMBER;
    vr_qtregist  NUMBER;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_tab_erro  gene0001.typ_tab_erro;
    vr_des_reto VARCHAR2(3);
    vr_vlaliqui crapepr.vlsdeved%TYPE;
    vr_index INTEGER;
	vr_sldpreju crapepr.vlsdeved%TYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  BEGIN
    
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
         vr_cdcritic := 0;
         RAISE vr_exc_erro;
       END IF;
       
       cecred.gene0001.pc_informa_acesso('TELA_ATENDA_DEPOSVIS.pc_paga_emprestimo_ct');
       pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

       GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

        OPEN BTCH0001.cr_crapdat(pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;

        -- PJ 450 -- Diego Simas (AMcom) -- Início
        
        /* Procedure para obter dados de emprestimos do associado */
        EMPR0001.pc_obtem_dados_empresti(pr_cdcooper   => vr_cdcooper               --> Cooperativa conectada
                                        ,pr_cdagenci   => to_number(vr_cdagenci, 0) --> Código da agência
                                        ,pr_nrdcaixa   => to_number(vr_nrdcaixa, 0) --> Número do caixa
                                        ,pr_cdoperad   => vr_cdoperad               --> Código do operador
                                        ,pr_nmdatela   => 'ATENDA'                  --> Nome datela conectada
                                        ,pr_idorigem   => to_number(vr_idorigem, 0) --> Indicador da origem da chamada
                                        ,pr_nrdconta   => pr_nrdconta               --> Conta do associado
                                        ,pr_idseqttl   => 1                         --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat                --> Vetor com dados de parâmetro (CRAPDAT)
                                        ,pr_dtcalcul   => rw_crapdat.dtmvtolt       --> Data solicitada do calculo
                                        ,pr_nrctremp   => nvl(pr_nrctremp,0)    --> Número contrato empréstimo
                                        ,pr_cdprogra   => 'ATENDA'              --> Programa conectado
                                        ,pr_inusatab   => false                 --> Indicador de utilização da tabela
                                        ,pr_flgerlog   => 'S'                   --> Gerar log S/N
                                        ,pr_flgcondc   => false                 --> Mostrar emprestimos liquidados sem prejuizo
                                        ,pr_nmprimtl   => null                  --> Nome Primeiro Titular
                                        ,pr_tab_parempctl  => null              --> Dados tabela parametro
                                        ,pr_tab_digitaliza => null              --> Dados tabela parametro
                                        ,pr_nriniseq       => 1                 --> Numero inicial da paginacao
                                        ,pr_nrregist       => 1                 --> Numero de registros por pagina
                                        ,pr_qtregist       => vr_qtregist       --> Qtde total de registros
                                        ,pr_tab_dados_epr  => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                        ,pr_des_reto       => vr_des_reto       --> Retorno OK / NOK
                                        ,pr_tab_erro       => vr_tab_erro);     --> Tabela com possíves erros

       IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
             vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
             vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        
        -- ler os registros de emprestimos e incluir no xml
        vr_index := vr_tab_dados_epr.first;

        vr_vlaliqui := vr_tab_dados_epr(vr_index).vlsdeved +
                       vr_tab_dados_epr(vr_index).vlmtapar +
                       vr_tab_dados_epr(vr_index).vlmrapar +
                       vr_tab_dados_epr(vr_index).vliofcpl;
                       
        vr_sldpreju := vr_tab_dados_epr(vr_index).vlsdprej;
        
        OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => nvl(pr_nrctremp,0));
        FETCH cr_crapepr INTO rw_crapepr;
        
        IF cr_crapepr%FOUND THEN 
           CLOSE cr_crapepr;
           IF rw_crapepr.inprejuz = 0 THEN
              IF pr_vlrpagto > vr_vlaliqui THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Valor superior ao saldo devedor! Valor Máximo permitido: ' || 
                                to_char(vr_vlaliqui, '9G999G990D00', 'nls_numeric_characters='',.''');
                 RAISE vr_exc_erro;
              END IF; 
           ELSE
              IF pr_vlrpagto > vr_sldpreju THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Valor superior ao saldo devedor! Valor Máximo permitido: ' || 
                                to_char(vr_sldpreju, '9G999G990D00', 'nls_numeric_characters='',.''');
                 RAISE vr_exc_erro;
              END IF; 
           END IF;
        ELSE
           CLOSE cr_crapepr;    
           vr_cdcritic := 0;
           vr_dscritic := 'O Contrato informado não existe!';
           RAISE vr_exc_erro;
        END IF;
        
        -- PJ 450 -- Diego Simas (AMcom) -- Fim

        IF pr_vlrpagto > PREJ0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) THEN
          vr_dscritic := 'Valor informado para pagamento é maior que o saldo disponível.';

          RAISE vr_exc_erro;
        END IF;

        vr_idvlrmin := 0;

        PREJ0003.pc_pagar_contrato_emprestimo(pr_cdcooper =>  pr_cdcooper,
                                                      pr_nrdconta => pr_nrdconta,
                                                      pr_cdagenci => 1,
                                                      pr_nrctremp => pr_nrctremp,
                                                      pr_nrparcel => 1,
                                                      pr_cdoperad => '1',
                                                      pr_vlrpagto => pr_vlrpagto,
                                                      pr_vlrabono => pr_vlrabono,
                                                      pr_idorigem => 1,
                                                      pr_idvlrmin => vr_idvlrmin,
                                                      pr_vltotpag => vr_vltotpag,
                                                      pr_cdcritic => vr_cdcritic,
                                                      pr_dscritic => vr_dscritic);

       IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;

       IF vr_vltotpag > 0 THEN
         IF vr_vltotpag - pr_vlrabono > 0 THEN
           PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_vlrlanc => vr_vltotpag - nvl(pr_vlrabono,0)
                                       , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);

           IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;
          END IF;
       ELSE
         vr_dscritic := 'Nenhum valor foi pago.';

         RAISE vr_exc_erro;
       END IF;

       COMMIT;

       GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'msg'
                          ,pr_tag_cont => 'Pagamento efetuado no valor de: ' ||
                                          to_char(vr_vltotpag,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);
    EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro não tratado na rotina TELA_ATENDA_DEPOSVIS.pc_paga_emprestimo_ct: ' || SQLERRM;

          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
          ROLLBACK;
  END pc_paga_emprestimo_ct;

  PROCEDURE pc_consulta_dt_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2)IS          --> Saida OK/NOK

/*---------------------------------------------------------------------------------------------------------------

  Programa : pc_consulta_dt_preju
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Diego Simas
  Data     : Junho/2018                          Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: -----
  Objetivo   : Consulta a data de inclusão de prejuízo.

  Alterações :

  -------------------------------------------------------------------------------------------------------------*/

  -- CURSORES --

  --> Consultar data de inclusão prejuizo quando a conta está em prejuízo
  CURSOR cr_prejuizo_s(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
    SELECT t.dtinclusao
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtliquidacao IS NULL;
  rw_prejuizo_s cr_prejuizo_s%ROWTYPE;

  --> Consultar data de inclusão prejuizo quando a conta "não" está em prejuízo
  CURSOR cr_prejuizo_n(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                     pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
    SELECT MIN(t.dtinclusao) dtinclusao
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rw_prejuizo_n cr_prejuizo_n%ROWTYPE;

  --> Consultar crapass
  CURSOR cr_crapass(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                    pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
    SELECT c.inprejuz
      FROM crapass c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

   --> Consultar crapdat
  CURSOR cr_crapdat(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE)IS
    SELECT c.dtmvtolt
      FROM crapdat c
     WHERE c.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3);
  vr_exc_saida EXCEPTION;

  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;

  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  --Variaveis Locais
  vr_qtregist INTEGER := 0;
  vr_clob     CLOB;
  vr_xml_temp VARCHAR2(32726) := '';
  vr_despreju VARCHAR2(200);
  vr_dataprej DATE;
  vr_dataatua DATE;
  vr_inprejuz INTEGER;

  --Variaveis de Indice
  vr_index PLS_INTEGER;

  --Variaveis de Excecoes
  vr_exc_ok    EXCEPTION;
  vr_exc_erro  EXCEPTION;

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

  -----> PROCESSAMENTO PRINCIPAL <-----

  vr_inprejuz := 0;

  OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                  pr_nrdconta => pr_nrdconta);

  FETCH cr_crapass INTO rw_crapass;

  IF cr_crapass%FOUND THEN
    CLOSE cr_crapass;
    IF rw_crapass.inprejuz = 1 THEN
      vr_inprejuz := 1;
      -- Conta Corrente está em Prejuízo
      OPEN cr_prejuizo_s(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);

      FETCH cr_prejuizo_s INTO rw_prejuizo_s;
      IF cr_prejuizo_s%FOUND THEN
        vr_dataprej := rw_prejuizo_s.dtinclusao;
      END IF;
    ELSE
      -- Conta Corrente não está em Prejuízo
      OPEN cr_prejuizo_n(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);

      FETCH cr_prejuizo_n INTO rw_prejuizo_n;
      IF cr_prejuizo_n%FOUND THEN
        vr_dataprej := rw_prejuizo_n.dtinclusao;
      END IF;
    END IF;
  ELSE
    CLOSE cr_crapass;
  END IF;

  OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapdat INTO rw_crapdat;
  IF cr_crapdat%FOUND THEN
    CLOSE cr_crapdat;
    vr_dataatua := rw_crapdat.dtmvtolt;
  ELSE
    CLOSE cr_crapdat;
  END IF;

  pr_cdcritic := NULL;
  pr_dscritic := NULL;

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_qtregist,
                         pr_tag_nova => 'datpreju',
                         pr_tag_cont => to_char(vr_dataprej,'DD/MM/YYYY'),
                         pr_des_erro => vr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_qtregist,
                         pr_tag_nova => 'datatual',
                         pr_tag_cont => to_char(vr_dataatua, 'DD/MM/YYYY'),
                         pr_des_erro => vr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_inprejuz,
                         pr_tag_nova => 'inprejuz',
                         pr_tag_cont => vr_inprejuz,
                         pr_des_erro => vr_dscritic);



EXCEPTION
  WHEN vr_exc_erro THEN
    -- Retorno não OK
    pr_des_erro:= 'NOK';

    -- Erro
    pr_cdcritic:= vr_cdcritic;
    pr_dscritic:= vr_dscritic;

    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  WHEN OTHERS THEN
    -- Retorno não OK
    pr_des_erro:= 'NOK';

    -- Erro
    pr_cdcritic:= 0;
    pr_dscritic:= 'Erro na pc_consulta_dt_preju --> '|| SQLERRM;

    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_dt_preju;

PROCEDURE pc_busca_saldos_juros60(pr_cdcooper IN crapris.cdcooper%TYPE --> Código da cooperativa
                                , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se não informado, a procedure recupera da base)
                                , pr_vlsld59d OUT NUMBER               --> Saldo até 59 dias (saldo devedor - juros +60)
                                , pr_vljuro60 OUT NUMBER
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE)  IS          --> Valor dos juros +60

BEGIN

DECLARE
  -- Recupera a soma dos lançamentos de juros +60 da conta
  CURSOR cr_craplcm_ccjuros60(pr_dt59datr IN crapris.dtinictr%TYPE) IS
  SELECT  nvl(sum(lcm.vllanmto),0) vl_juros60
    FROM craplcm lcm
   WHERE lcm.cdhistor IN (37,38,57)    -- INCLUIR histórico dos juros remuneratórios do prejuízo
     AND lcm.cdcooper   = pr_cdcooper
     AND lcm.nrdconta   = pr_nrdconta
     AND lcm.dtmvtolt   > pr_dt59datr; -- Data em que completou 59 dias em ADP

  -- Recupera os lançamentos que não são juros +60 ocorridos após 60 dias de atraso da conta
  CURSOR cr_craplcm_outros(pr_dt59datr IN crapris.dtinictr%TYPE) IS
  SELECT lcm.vllanmto
       , lcm.dtmvtolt
       , his.indebcre
    FROM craplcm lcm
       , craphis his
   WHERE lcm.cdhistor NOT IN (37,38,57)    -- INCLUIR histórico dos juros remuneratórios do prejuízo
     AND lcm.cdcooper   = pr_cdcooper
     AND lcm.nrdconta   = pr_nrdconta
     AND lcm.dtmvtolt   > pr_dt59datr -- Data em que completou 59 dias em ADP
     AND his.cdcooper   = lcm.cdcooper
     AND his.cdhistor   = lcm.cdhistor
   ORDER BY indebcre DESC;
  rw_craplcm_outros cr_craplcm_outros%ROWTYPE;

  -- Busca o limite de crédito atual do cooperado
  CURSOR cr_limite IS
  SELECT nvl(ass.vllimcre,0) vllimcre
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta;

  -- Informações de saldo atual da conta corrente
  CURSOR cr_saldos(pr_cdcooper NUMBER
                 , pr_nrdconta NUMBER) IS
  SELECT abs(sld.vlsddisp) vlsddisp
       , sld.dtrisclq
       , sld.qtddsdev
       , sld.vliofmes
    FROM crapsld sld
   WHERE sld.cdcooper = pr_cdcooper
     AND sld.nrdconta = pr_nrdconta;
  rw_saldos cr_saldos%ROWTYPE;

  -- Histórico do saldo da conta
  CURSOR cr_crapsda(pr_dtmvtolt DATE) IS
  SELECT * FROM (
  SELECT abs(sda.vlsddisp) vlsddisp
       , ROWNUM
    FROM crapsda sda
   WHERE sda.cdcooper = pr_cdcooper
     AND sda.nrdconta = pr_nrdconta
     AND sda.dtmvtolt >= pr_dtmvtolt
  ORDER BY dtmvtolt)
  WHERE rownum = 1;
  rw_crapsda cr_crapsda%ROWTYPE;

  -- Calendário da cooperativa
  rw_crapdat btch0001.rw_crapdat%TYPE;

  vr_data_corte_dias_uteis DATE; --> Data de corte para contagem de dias de atraso em dias corridos
  vr_dtcorte_rendaprop     DATE; --> Data de corte de implantação do Rendas a Apropriar (não apropriação de receita dos juros +60)
  vr_data_59dias_atraso    DATE; --> Data em que a conta atingiu 59 dias de atraso (ADP)

  vr_vlrlimite NUMBER;

  vr_exc_saida  EXCEPTION;  --> Exceção para o caso de saldo indisponível na base de dados
  vr_qtddiaatr  INTEGER;                 --> Quantidade de dias de atraso da conta
  vr_jur60_cneg NUMBER;                 --> Juros +60 (Hist. 37 + Hist. 57)
  vr_jur60_cesp NUMBER;                 --> Juros +60 (Hist. 38)
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;
BEGIN
    pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_qtdiaatr => pr_qtdiaatr
                             , pr_vlsld59d => pr_vlsld59d
                             , pr_vljucneg => vr_jur60_cneg
                             , pr_vljucesp => vr_jur60_cesp
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);

    IF vr_cdcritic >0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_vljuro60 := vr_jur60_cneg + vr_jur60_cesp;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := 'Erro não tratado na "TELA_ATENDA_DEPOSVIS.pc_consulta_saldos_juros60".';
  END;
END pc_busca_saldos_juros60;

-- Busca saldo até 59 dias e valores de juros +60 detalhados (hist. 37+57+2718 e hist 38)
PROCEDURE pc_busca_saldos_juros60_det(pr_cdcooper IN crapris.cdcooper%TYPE --> Código da cooperativa
                                    , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                    , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se não informado, a procedure recupera da base)
                                    , pr_dtlimite IN DATE   DEFAULT NULL --> Data limite para filtro dos lançamentos na CRAPLCM
                                    , pr_vlsld59d OUT NUMBER             --> Saldo até 59 dias (saldo devedor - juros +60)
                                    , pr_vljucneg OUT NUMBER             --> Juros +60 (Hist. 37 + 57 + 2718)
                                    , pr_vljucesp OUT NUMBER             -- Juros + 60 (Hist. 38)
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE)  IS          --> Valor dos juros +60

BEGIN

DECLARE
  -- Recupera os lançamentos que não são juros +60 ocorridos após 60 dias de atraso da conta
  CURSOR cr_craplcm(pr_dt59datr IN crapris.dtinictr%TYPE) IS
  SELECT lcm.vllanmto
       , lcm.dtmvtolt
       , his.indebcre
       , his.dshistor
       , his.cdhistor
    FROM craplcm lcm
       , craphis his
   WHERE lcm.cdcooper   = pr_cdcooper
     AND lcm.nrdconta   = pr_nrdconta
     AND lcm.dtmvtolt   > pr_dt59datr -- Data em que completou 59 dias em ADP
     AND (pr_dtlimite IS NULL OR lcm.dtmvtolt <= pr_dtlimite)
     AND (his.indebcre = 'D'
      OR (his.indebcre = 'C'
     AND NOT EXISTS (
           SELECT 1
             FROM craplcm aux
            WHERE aux.cdcooper = lcm.cdcooper
              AND aux.nrdconta = lcm.nrdconta
              AND aux.dtmvtolt = lcm.dtmvtolt
              AND aux.nrdocmto = lcm.nrdocmto
              AND aux.cdhistor = 2719
              AND aux.vllanmto = lcm.vllanmto
         )))
     AND his.cdhistor   NOT IN (2718, 2719)
     AND his.cdcooper   = lcm.cdcooper
     AND his.cdhistor   = lcm.cdhistor
   ORDER BY dtmvtolt ASC, indebcre DESC;
  rw_craplcm cr_craplcm%ROWTYPE;

  -- Busca o limite de crédito atual do cooperado
  CURSOR cr_limite IS
  SELECT nvl(ass.vllimcre,0) vllimcre
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta;

  -- Informações de saldo atual da conta corrente
  CURSOR cr_saldos(pr_cdcooper NUMBER
                 , pr_nrdconta NUMBER) IS
  SELECT nvl(abs(sld.vlsddisp),0) vlsddisp
       , sld.dtrisclq
       , sld.qtddsdev
       , sld.vliofmes
    FROM crapsld sld
   WHERE sld.cdcooper = pr_cdcooper
     AND sld.nrdconta = pr_nrdconta;
  rw_saldos cr_saldos%ROWTYPE;

  -- Histórico do saldo da conta
  CURSOR cr_crapsda(pr_dtmvtolt DATE) IS
  SELECT * FROM (
  SELECT nvl(abs(sda.vlsddisp),0) vlsddisp
       , ROWNUM
    FROM crapsda sda
   WHERE sda.cdcooper = pr_cdcooper
     AND sda.nrdconta = pr_nrdconta
     AND sda.dtmvtolt >= pr_dtmvtolt
  ORDER BY dtmvtolt)
  WHERE rownum = 1;
  rw_crapsda cr_crapsda%ROWTYPE;

  -- Calendário da cooperativa
  rw_crapdat btch0001.rw_crapdat%TYPE;

  vr_data_corte_dias_uteis DATE; --> Data de corte para contagem de dias de atraso em dias corridos
  vr_dtcorte_rendaprop     DATE; --> Data de corte de implantação do Rendas a Apropriar (não apropriação de receita dos juros +60)
  vr_data_59dias_atraso    DATE; --> Data em que a conta atingiu 59 dias de atraso (ADP)
  vr_jur60_37              NUMBER;
  vr_jur60_57              NUMBER;
  vr_jur60_2718            NUMBER;
  vr_jur60_38              NUMBER;

  vr_vlrlimite NUMBER;

  vr_exc_saldo_indisponivel EXCEPTION;  --> Exceção para o caso de saldo indisponível na base de dados
  vr_qtddiaatr INTEGER;                 --> Quantidade de dias de atraso da conta
BEGIN
    -- Busca data de corte para contagem de dias de atraso em dias corridos
    vr_data_corte_dias_uteis := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                   ,'DD/MM/RRRR');

    --Buscar a data de corte
     vr_dtcorte_rendaprop := TO_DATE(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                                ,pr_nmsistem => 'CRED'
                                                                ,pr_cdacesso => 'DT_CORTE_RENDAPROP')
                                                               ,'DD/MM/RRRR');

    -- Carrega o calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --  Carrega informações de saldo atual da conta
    OPEN cr_saldos(pr_cdcooper, pr_nrdconta);
    FETCH cr_saldos INTO rw_saldos;
    CLOSE cr_saldos;

    -- Busca o limite ativo da conta
    OPEN cr_limite;
    FETCH cr_limite INTO vr_vlrlimite;
    CLOSE cr_limite;

    vr_qtddiaatr := pr_qtdiaatr;

    -- Se não foi informada a quantidade de dias em atraso (este valor será informado quando
    -- for necessário considerar a quantidade de dias em atraso calculada e não a armazenada na CRAPSLD).
    IF vr_qtddiaatr IS NULL THEN
      vr_qtddiaatr := rw_saldos.qtddsdev; -- Considera os dias em atraso da CRAPSLD
    END IF;

    pr_vljucneg := 0; -- Assume que a conta não tem juros +60, caso a conta não tenha ultrapassado os 60 dias de atraso
    pr_vljucesp := 0; -- Assume que a conta não tem juros +60, caso a conta não tenha ultrapassado os 60 dias de atraso

    IF rw_saldos.dtrisclq IS NULL THEN -- Se a conta não está em atraso
      pr_vlsld59d := 0;
    ELSE
      IF vr_qtddiaatr < 60 THEN -- Se a conta não ultrapassou os 60 dias de atraso
        pr_vlsld59d := rw_saldos.vlsddisp - vr_vlrlimite;
      ELSE
         IF rw_saldos.dtrisclq < vr_data_corte_dias_uteis THEN -- Se data de início do atraso menor que a data de corte
            vr_data_59dias_atraso := fn_soma_dias_uteis_data(pr_cdcooper, rw_saldos.dtrisclq, 59); -- Conta dias úteis
         ELSE
            vr_data_59dias_atraso := rw_saldos.dtrisclq + 59; -- Conta dias corridos
         END IF;

         -- Se contrato atingiu 60 dias de atraso antes da data de corte do Rendas a Apropriar
         IF vr_data_59dias_atraso < vr_dtcorte_rendaprop THEN
           vr_data_59dias_atraso := vr_dtcorte_rendaprop;
         END IF;

         -- Busca os saldo do dia em que a conta completou 59 dias de atraso
         OPEN cr_crapsda(vr_data_59dias_atraso);
         FETCH cr_crapsda INTO rw_crapsda;

         IF cr_crapsda%NOTFOUND THEN -- Se não encontrou o saldo para o dia em questão
            CLOSE cr_crapsda;

            RAISE vr_exc_saldo_indisponivel;
         ELSE
            pr_vlsld59d := rw_crapsda.vlsddisp - vr_vlrlimite;

            -- Percorre os lançamentos ocorridos após 60 dias de atraso que não sejam juros +60
            FOR rw_craplcm IN cr_craplcm(vr_data_59dias_atraso) LOOP
              IF rw_craplcm.cdhistor IN (37,57,2718) THEN
                pr_vljucneg := pr_vljucneg + rw_craplcm.vllanmto;
              ELSIF rw_craplcm.cdhistor = 38 THEN
                pr_vljucesp := pr_vljucesp + rw_craplcm.vllanmto;
              ELSIF rw_craplcm.indebcre = 'D' THEN
                pr_vlsld59d := pr_vlsld59d + rw_craplcm.vllanmto;
              ELSE
                IF pr_vljucneg > 0 THEN
                  -- Amortiza os juros + 60 (Hist. 37 + Hist. 57)
                  IF rw_craplcm.vllanmto >= pr_vljucneg THEN
                    rw_craplcm.vllanmto := rw_craplcm.vllanmto - pr_vljucneg;
                    pr_vljucneg := 0;
                  ELSE
                    pr_vljucneg := pr_vljucneg - rw_craplcm.vllanmto;
                    rw_craplcm.vllanmto := 0;
                  END IF;
                END IF;

                IF rw_craplcm.vllanmto > 0 THEN
                  IF pr_vljucesp > 0 THEN
                    -- Amortiza os juros + 60 (Hist. 38)
                    IF rw_craplcm.vllanmto >= pr_vljucesp THEN
                      rw_craplcm.vllanmto := rw_craplcm.vllanmto - pr_vljucesp;
                      pr_vljucesp := 0;
                    ELSE
                      pr_vljucesp := pr_vljucesp - rw_craplcm.vllanmto;
                      rw_craplcm.vllanmto := 0;
                    END IF;
                  END IF;
                END IF;

                IF rw_craplcm.vllanmto > 0 THEN
                  -- Amortiza o saldo devedor até 59 dias
                  IF rw_craplcm.vllanmto >= pr_vlsld59d THEN
                    pr_vlsld59d := 0;
                  ELSE
                    pr_vlsld59d := pr_vlsld59d - rw_craplcm.vllanmto;
                  END IF;
                END IF;
              END IF;
            END LOOP;
         END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_saldo_indisponivel THEN
      pr_cdcritic := 853;
      pr_dscritic := 'Não foi possível recuperar o saldo de 59 dias de atraso.';
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := 'Erro não tratado na "TELA_ATENDA_DEPOSVIS.pc_consulta_saldos_juros60_ab".';
  END;
END pc_busca_saldos_juros60_det;

PROCEDURE pc_consulta_sit_empr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2)IS           --> Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_sit_empr
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Maio/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Consulta para verificar se o empréstimo está em prejuízo.

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar crapepr
    CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE,
                      pr_nrdconta crapepr.nrdconta%TYPE,
                      pr_nrctremp crapepr.nrctremp%TYPE)IS
      SELECT c.inprejuz
        FROM crapepr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_indpreju VARCHAR2(200);

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

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

    -----> PROCESSAMENTO PRINCIPAL <-----
    OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);

    FETCH cr_crapepr INTO rw_crapepr;

    vr_indpreju := 0;

    IF cr_crapepr%FOUND THEN
      CLOSE cr_crapepr;
      vr_indpreju := rw_crapepr.inprejuz;
    ELSE
      CLOSE cr_crapepr;
    END IF;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_qtregist,
                           pr_tag_nova => 'inprejuz',
                           pr_tag_cont => vr_indpreju,
                           pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_preju_cc --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_sit_empr;

END TELA_ATENDA_DEPOSVIS;
/
