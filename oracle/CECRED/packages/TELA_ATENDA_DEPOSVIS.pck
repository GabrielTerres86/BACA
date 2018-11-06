CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DEPOSVIS IS

FUNCTION fn_soma_dias_uteis_data(pr_cdcooper NUMBER, pr_dtmvtolt DATE, pr_qtddias INTEGER)
    RETURN DATE;

FUNCTION fn_calc_data_59dias_atraso(pr_cdcooper crapass.cdcooper%TYPE
	                                , pr_nrdconta crapass.nrdconta%TYPE
																	, pr_fldtcort INTEGER DEFAULT 1)
  RETURN DATE;


PROCEDURE pc_busca_saldos_devedores(pr_nrdconta crapass.nrdconta%TYPE    --> COnta para a qual se deseja obter os saldos
                                  , pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  , pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                  , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2);

  -- retorna datas de prejuizo da conta, em XML
  PROCEDURE pc_busca_dts_preju_atraso ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                               ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                               ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                               ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                               ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                               ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_preju_cc(pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                   ,pr_valorprj OUT NUMBER             --> valor do prejuizo
                                   ,pr_dtiniprj OUT DATE);          --> data de registro do prejuizo

  PROCEDURE pc_busca_inicio_atraso (pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                   ,pr_dtiniatr OUT DATE);          --> retorno da data de inicio de atraso

  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Descricao do erro

  -- retorna dados da conta em prejuizo, em XML
  PROCEDURE pc_busca_vlrs_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  -- efetua pagamento de conta em prejuizo
  PROCEDURE pc_paga_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_vlrpagto  IN NUMBER                --> valor pago
                                     ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_paga_emprestimo_ct(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                 ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                 ,pr_vlrpagto  IN NUMBER                --> valor pago
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);
   
  -- consulta data de inclus�o preju�zo
  PROCEDURE pc_consulta_dt_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);


  PROCEDURE pc_busca_saldos_juros60(pr_cdcooper IN crapris.cdcooper%TYPE --> C�digo da cooperativa
                                , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se n�o informado, a procedure recupera da base)
                                , pr_tppesqui IN NUMBER DEFAULT 1    --> 1|Online  0|Batch
                                , pr_vlsld59d OUT NUMBER               --> Saldo at� 59 dias (saldo devedor - juros +60)
                                , pr_vljuro60 OUT NUMBER
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Busca saldo at� 59 dias e valores de juros +60 detalhados (hist. 37+57+2718 e hist 38)
  PROCEDURE pc_busca_saldos_juros60_det(pr_cdcooper IN crapris.cdcooper%TYPE --> C�digo da cooperativa
                                    , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                    , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se n�o informado, a procedure recupera da base)
                                    , pr_dtlimite IN DATE   DEFAULT NULL --> Data limite para filtro dos lan�amentos na CRAPLCM
                                      , pr_tppesqui IN NUMBER DEFAULT 1    --> 1|Online  0|Batch
                                    , pr_vlsld59d OUT NUMBER             --> Saldo at� 59 dias (saldo devedor - juros +60)
                                    , pr_vlju6037 OUT NUMBER             --> Juros +60 (Hist. 37 + 2718)
                                    , pr_vlju6038 OUT NUMBER             -- Juros + 60 (Hist. 38)
                                    , pr_vlju6057 OUT NUMBER             -- Juros + 60 (Hist. 57)
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Consulta a situa��o do empr�stimo
  PROCEDURE pc_consulta_sit_empr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

END TELA_ATENDA_DEPOSVIS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DEPOSVIS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DEPOSVIS
  --  Sistema  : Procedimentos para tela ATENDA - Dep�sitos � Vista
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Mar�o/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para tela ATENDA - Dep�sitos � Vista
  --
  -- Alterado  : 01/08/2018 - Ajustes pagamento Preju�zo
  --                          PJ 450 - Diego Simas - AMcom
  --
  --             08/08/2018 - Ajustes pagamento de Empr�stimo
  --                          PJ 450 - Diego Simas - AMcom
  --
  --             23/08/2018 - Apresentar mensagem quando o valor do pagamento
  --                          � maior que o saldo devedor do empr�stimo
  --                          PJ 450 - Diego Simas - AMcom.
  --
	--             29/10/2018 - Ajuste para corrigir diverg�ncia nos juros +60 quando conta
	--                          tem cheques devolvidos e para correto c�lculo dos juros +60
	--                          quando h� estorno do pagamento de preju�zo da conta corrente.
	--                          (Reginaldo - AMcom - P450)
  --
  ---------------------------------------------------------------------------------------------------------------

FUNCTION fn_soma_dias_uteis_data(pr_cdcooper NUMBER, pr_dtmvtolt DATE, pr_qtddias INTEGER)
    RETURN DATE AS vr_data DATE;

  /* ............................................................................
        Programa: fn_soma_dias_uteis_data
        Sistema : CECRED
        Sigla   : CECRED
        Autor   : Reginaldo/AMcom
        Data    : Mar�o/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Soma a quantidade de dias �teis (desconsiderando finais de semana e feriados)
                    � data de refer�ncia informada.
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

  ----->>> VARI�VEIS <<<-----

  vr_dtcompar DATE;
  vr_contador   INTEGER := 0;

BEGIN
    vr_dtcompar := pr_dtmvtolt;

    LOOP
      -- Busca se a data � feriado
      OPEN cr_crapfer(pr_cdcooper, vr_dtcompar);
      FETCH cr_crapfer INTO rw_crapfer;

      -- Se a data n�o for sabado ou domingo ou feriado
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

FUNCTION fn_valida_dia_util(pr_cdcooper NUMBER, pr_dtmvtolt DATE)
    RETURN BOOLEAN AS vr_dia_util BOOLEAN;


  CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                 ,pr_dtcompar IN crapfer.dtferiad%TYPE) IS
  SELECT cf.dsferiad
    FROM crapfer cf
   WHERE cf.cdcooper = pr_cdcooper
     AND cf.dtferiad = pr_dtcompar;
  rw_crapfer cr_crapfer%ROWTYPE;

  ----->>> VARI�VEIS <<<-----

  vr_dtcompar DATE;
  vr_contador   INTEGER := 0;

BEGIN
    vr_dtcompar := pr_dtmvtolt;


		-- Busca se a data � feriado
		OPEN cr_crapfer(pr_cdcooper, vr_dtcompar);
		FETCH cr_crapfer INTO rw_crapfer;

		-- Se a data n�o for sabado ou domingo ou feriado
		vr_dia_util := NOT(TO_CHAR(vr_dtcompar, 'd') IN (1,7) OR cr_crapfer%FOUND);

		CLOSE cr_crapfer;

    RETURN vr_dia_util;
END fn_valida_dia_util;

FUNCTION fn_calc_data_59dias_atraso(pr_cdcooper crapass.cdcooper%TYPE
	                                , pr_nrdconta crapass.nrdconta%TYPE
																	, pr_fldtcort INTEGER DEFAULT 1) RETURN DATE IS
  vr_data_corte_dias_uteis DATE;
	vr_dtcorte_rendaprop     DATE;
	vr_data_59dias_atraso    DATE;

	CURSOR cr_crapris IS
	SELECT dtinictr
	  FROM crapris ris
	 WHERE cdcooper = pr_cdcooper
	   AND nrdconta = pr_nrdconta
		 AND cdmodali = 101
		 AND dtrefere = (SELECT CASE WHEN to_char(dtmvtolt, 'MM') = to_char(dtmvtoan, 'MM') THEN
                              dtmvtoan
                            ELSE
                              dtultdma
                            END
                       FROM crapdat
                      WHERE cdcooper = pr_cdcooper);
	rw_crapris cr_crapris%ROWTYPE;
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
		 OPEN cr_crapris;
		 FETCH cr_crapris INTO rw_crapris;
		 CLOSE cr_crapris;

     IF rw_crapris.dtinictr < vr_data_corte_dias_uteis THEN -- Se data de in�cio do atraso menor que a data de corte
				vr_data_59dias_atraso := fn_soma_dias_uteis_data(pr_cdcooper, rw_crapris.dtinictr, 59); -- Conta dias �teis
		 ELSE
				vr_data_59dias_atraso := rw_crapris.dtinictr + 59; -- Conta dias corridos
		 END IF;

     IF pr_fldtcort = 1 THEN -- Se deve considerar a data de corte do rendas a apropriar
			 -- Se contrato atingiu 60 dias de atraso antes da data de corte do Rendas a Apropriar
			 IF vr_data_59dias_atraso < vr_dtcorte_rendaprop THEN
				 vr_data_59dias_atraso := vr_dtcorte_rendaprop;
			 END IF;
		 END IF;

		 RETURN vr_data_59dias_atraso;
END fn_calc_data_59dias_atraso;


PROCEDURE pc_busca_saldos_devedores(pr_nrdconta crapass.nrdconta%TYPE    --> COnta para a qual se deseja obter os saldos
                                  , pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  , pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                  , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_saldos_devedores
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Reginaldo/AMcom
        Data    : Mar�o/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina que obt�m o valor do Saldo Devedor at� 59 dias de atraso,
                    Saldo Devedor a partir do 60� dia de atraso e Valor do IOF a Debitar
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE
    ----------->>> CURSORES <<<---------

    -- Informa��es de saldo atual da conta corrente
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

    -- Hist�rico do saldo da conta
    CURSOR cr_crapsda(pr_cdcooper NUMBER
                    , pr_nrdconta NUMBER
                    , pr_dtmvtolt DATE) IS
    SELECT abs(sda.vlsddisp) - sda.vllimcre vlsddisp
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper
       AND sda.nrdconta = pr_nrdconta
       AND sda.dtmvtolt = pr_dtmvtolt;
    rw_crapsda cr_crapsda%ROWTYPE;

    -- Calend�rio da cooperativa
    rw_crapdat btch0001.rw_crapdat%TYPE;

    ----------->>> VARIAVEIS <<<--------

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida              EXCEPTION;
    vr_exc_saldo_indisponivel EXCEPTION;

    -- Vari�veis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Vari�veis gerais da procedure
    vr_saldo_devedor_59dias      NUMBER := 0; -- Saldo devedor at� 59 dias
    vr_vljuros60                 NUMBER := 0; -- Valor dos juros +60
    vr_saldo_devedor_mais_60dias NUMBER := 0; -- Saldo devedor a partir do 60� dia
    vr_saldo_devedor_total       NUMBER := 0; -- Saldo devedor total
    vr_valor_iof_debitar         NUMBER := 0; -- Valor do IOF a debitar
    vr_data_59dias_atraso        DATE;
    vr_data_corte                DATE ; -- Data de corte para contagem em dias �teis/corridos (substituir por par�metro do BD)

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

      -- Se retornou alguma cr�tica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levanta exce��o
          RAISE vr_exc_saida;
      END IF;

      -- Criar cabe�alho do XML de retorno
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

      pc_busca_saldos_juros60(pr_cdcooper => vr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_vlsld59d => vr_saldo_devedor_59dias
                            , pr_vljuro60 => vr_vljuros60
                            , pr_cdcritic => vr_cdcritic
                            , pr_dscritic => vr_dscritic);

			IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
				RAISE vr_exc_saida;
			END IF;

      -- Insere informa��es dos saldos no XML de retorno
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
        pr_dscritic := 'Erro na rotina da tela TELA_ATENDA_DEPOSVIS - pc_busca_saldos_devedores: Erro ao obter SALDO DEVEDOR AT� 59 DIAS.';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro n�o tratado na rotina da tela TELA_ATENDA_DEPOSVIS - pc_busca_saldos_devedores: ' || SQLERRM;
        -- Carregar XML padr�o para variavel de retorno
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

     Objetivo  : Retorna XML com as datas, de transferencia de conta para prejuizo e Data de in�cio de atraso

     Alteracoes:
     ..............................................................................*/
  PROCEDURE pc_busca_dts_preju_atraso ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                       ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                       ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2)  IS
    vr_exc_erro EXCEPTION;
    vr_dttrapre date;
    vr_dtiniatr date;
    vr_vlratra number;

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro
  BEGIN
    pc_busca_inicio_atraso(pr_nrdconta=>pr_nrdconta,
                           pr_cdcooper=>pr_cdcooper,
                           pr_dtiniatr=>vr_dtiniatr);

    pc_busca_preju_cc(pr_nrdconta=>pr_nrdconta,
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
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
        WHEN OTHERS THEN
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
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
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
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
       and dtrefere = (select CASE WHEN to_char(dtmvtoan, 'MM') = to_char(dtmvtolt, 'MM') THEN dtmvtoan ELSE dtultdma END from crapdat where cdcooper = pr_cdcooper);

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
     Programa: fn_busca_preju_cc
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcel Kohls
     Data    : Marco/2018.                    Ultima atualizacao: 19/09/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : retorna informacoes de prejuizo de conta corrente

     Alteracoes: 19/09/2018 - Inclusa busca de preju�zo de conta corrente, priorizado sobre a LC100
     ..............................................................................*/
  PROCEDURE pc_busca_preju_cc(pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                   ,pr_valorprj OUT NUMBER            --> valor do prejuizo
                                   ,pr_dtiniprj OUT DATE)  IS          --> data de registro do prejuizo
    CURSOR cr_crapepr (
                      pr_cdcooper IN crapepr.cdcooper%TYPE,
                      pr_nrdconta IN crapris.nrdconta%TYPE
                     ) IS
    SELECT vlsdprej
         , dtmvtolt
      FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND cdlcremp = 100 -- Linha 100 (indicador de que conta tem um contrato de prejuizo)
       AND vlsdprej > 0; -- com valor pendente
    rw_crapepr cr_crapepr%ROWTYPE;
		
		CURSOR cr_prejuizo IS
		SELECT prj.dtinclusao 
		     , prj.vlsdprej +
				   prj.vljur60_ctneg +
					 prj.vljur60_lcred +
					 prj.vljuprej vlsldprej
		  FROM tbcc_prejuizo prj
	   WHERE prj.cdcooper = pr_cdcooper
		   AND prj.nrdconta = pr_nrdconta
			 AND prj.dtliquidacao IS NULL;
		rw_prejuizo cr_prejuizo%ROWTYPE;
  BEGIN
		OPEN cr_prejuizo;
		FETCH cr_prejuizo INTO rw_prejuizo;
		
		IF cr_prejuizo%FOUND THEN
			pr_valorprj := nvl(rw_prejuizo.vlsldprej, 0);
			pr_dtiniprj := rw_prejuizo.dtinclusao;
		ELSE 
    -- Busca registro de linha 100, indicando contrato de prejuizo
    OPEN cr_crapepr(pr_cdcooper, pr_nrdconta);
    FETCH cr_crapepr
     INTO rw_crapepr;
    -- Fecha o cursor

    pr_valorprj := nvl(rw_crapepr.vlsdprej, 0);
    pr_dtiniprj := rw_crapepr.dtmvtolt;
		END IF;

		CLOSE cr_prejuizo;
  END pc_busca_preju_cc; 
  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

    Altera��es : PJ450 - Adicionado campo indicador de prejuizo da conta
               (Renato Cordeiro - AMCOM)

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar se j� houve prejuizo nessa conta
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

    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exce��o
      RAISE vr_exc_saida;
    END IF; */

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabe�alho do XML
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
        -- Conta Corrente em Preju�zo
        vr_despreju := 'Conta Corrente em Preju�zo';
      ELSE
        OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_prejuizo INTO rw_prejuizo;
        IF cr_prejuizo%FOUND THEN
          CLOSE cr_prejuizo;
          -- Houve preju�zo de Conta Corrente
          vr_despreju := 'Houve preju�zo de Conta Corrente';
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
      -- Retorno n�o OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_preju_cc --> '|| SQLERRM;

      -- Existe para satisfazer exig�ncia da interface.
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

     Alteracoes: 01/08/2018 - Ajustes pagamento Preju�zo
                              PJ 450 - Diego Simas - AMcom

                 20/08/2018 - Inclus�o do campo juremune (Juros Remunerat�rio)
                              PJ 450 - Diego Simas - AMcom

     ..............................................................................*/
  PROCEDURE pc_busca_vlrs_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
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
    vr_vltotiof           crapsld.vliofmes%TYPE := 0;

    vr_vljupre_prov NUMBER:=0;

    -- erros
    vr_exc_erro EXCEPTION;

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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
                       rw_tbcc_prejuizo.vljur60_lcred +
											 rw_tbcc_prejuizo.vljuprej;
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
                          ,pr_tag_nova => 'vltotiof'
                          ,pr_tag_cont => to_char(vr_vltotiof,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'juremune'
                          ,pr_tag_cont => to_char(vr_vljupre_prov,
                                                 '9G999G990D00',
                                                 'nls_numeric_characters='',.''')
                          ,pr_des_erro => vr_dscritic);

    EXCEPTION
        WHEN vr_exc_erro THEN
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
        WHEN OTHERS THEN
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
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
  PROCEDURE pc_paga_prejuz_cc ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                     ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                     ,pr_vlrpagto  IN NUMBER                --> valor pago
                                     ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)  IS

    CURSOR cr_prejuizo IS
    SELECT prj.vlsdprej
         , prj.vljuprej
         , prj.vljur60_ctneg
         , prj.vljur60_lcred
         , prj.vlsldlib
				 , sld.vliofmes
      FROM tbcc_prejuizo prj
			   , crapsld sld
     WHERE prj.cdcooper = pr_cdcooper
       AND prj.nrdconta = pr_nrdconta
       AND prj.dtliquidacao IS NULL
			 AND sld.cdcooper = prj.cdcooper
			 AND sld.nrdconta = prj.nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;

    -- erros
    vr_exc_erro EXCEPTION;

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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
								 rw_prejuizo.vliofmes +
                 vr_juprej_prov;

    IF (pr_vlrpagto + nvl(pr_vlrabono, 0)) > vr_slddev THEN
      vr_dscritic := 'O valor total informado para pagamento � maior que o saldo devedor.';
      RAISE vr_exc_erro;
    END IF;

    IF pr_vlrpagto > PREJ0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) THEN
      vr_dscritic := 'O valor informado para pagamento � maior que o saldo dispon�vel.';
      RAISE vr_exc_erro;
    END IF;

		-- Atualiza o saldo liberado para opera��es na conta corrente
		UPDATE tbcc_prejuizo
		   SET vlsldlib = vlsldlib + pr_vlrpagto
		 WHERE cdcooper = pr_cdcooper
		   AND nrdconta = pr_nrdconta
			 AND dtliquidacao IS NULL;

    PREJ0003.pc_pagar_prejuizo_cc(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_vlrpagto => pr_vlrpagto
                                , pr_vlrabono => pr_vlrabono
                                , pr_cdcritic => vr_cdcritic
                                , pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
	
    IF pr_vlrpagto > 0 THEN 
		PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                               , pr_cdoperad => '1'
                               , pr_vllanmto => pr_vlrpagto
                               , pr_dtmvtolt => rw_crapdat.dtmvtolt
															 , pr_atsldlib => 0 -- N�o atualiza o saldo liberado para opera��es (j� foi atualizado no in�cio do processo)
                               , pr_cdcritic => vr_cdcritic
                               , pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
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
          pr_dscritic := 'N�o foi poss�vel efetuar o pagamento do preju�zo. ERRO -> ' || SQLERRM ;

          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
  END pc_paga_prejuz_cc;

  PROCEDURE pc_paga_emprestimo_ct(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                 ,pr_vlrabono  IN NUMBER                --> valor de abono pago
                                 ,pr_vlrpagto  IN NUMBER                --> valor pago
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
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

  Objetivo  : Efetua pagamento de empr�stimo.

  Alteracoes: 23/08/2018 - Apresentar mensagem quando o valor do pagamento
                           � maior que o saldo devedor do empr�stimo
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

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Vari�veis retornadas da gene0004.pc_extrai_dados
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

       -- Se retornou alguma cr�tica
       IF TRIM(vr_dscritic) IS NOT NULL THEN
         -- Levanta exce��o
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

        -- PJ 450 -- Diego Simas (AMcom) -- In�cio

        /* Procedure para obter dados de emprestimos do associado */
        EMPR0001.pc_obtem_dados_empresti(pr_cdcooper   => vr_cdcooper               --> Cooperativa conectada
                                        ,pr_cdagenci   => nvl(vr_cdagenci, 0) --> C�digo da ag�ncia
                                        ,pr_nrdcaixa   => nvl(vr_nrdcaixa, 0) --> N�mero do caixa
                                        ,pr_cdoperad   => vr_cdoperad               --> C�digo do operador
                                        ,pr_nmdatela   => 'ATENDA'                  --> Nome datela conectada
                                        ,pr_idorigem   => nvl(vr_idorigem, 0) --> Indicador da origem da chamada
                                        ,pr_nrdconta   => pr_nrdconta               --> Conta do associado
                                        ,pr_idseqttl   => 1                         --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat                --> Vetor com dados de par�metro (CRAPDAT)
                                        ,pr_dtcalcul   => rw_crapdat.dtmvtolt       --> Data solicitada do calculo
                                        ,pr_nrctremp   => nvl(pr_nrctremp,0)    --> N�mero contrato empr�stimo
                                        ,pr_cdprogra   => 'ATENDA'              --> Programa conectado
                                        ,pr_inusatab   => false                 --> Indicador de utiliza��o da tabela
                                        ,pr_flgerlog   => 'S'                   --> Gerar log S/N
                                        ,pr_flgcondc   => false                 --> Mostrar emprestimos liquidados sem prejuizo
                                        ,pr_nmprimtl   => null                  --> Nome Primeiro Titular
                                        ,pr_tab_parempctl  => null              --> Dados tabela parametro
                                        ,pr_tab_digitaliza => null              --> Dados tabela parametro
                                        ,pr_nriniseq       => 1                 --> Numero inicial da paginacao
                                        ,pr_nrregist       => 1                 --> Numero de registros por pagina
                                        ,pr_qtregist       => vr_qtregist       --> Qtde total de registros
                                        ,pr_tab_dados_epr  => vr_tab_dados_epr  --> Saida com os dados do empr�stimo
                                        ,pr_des_reto       => vr_des_reto       --> Retorno OK / NOK
                                        ,pr_tab_erro       => vr_tab_erro);     --> Tabela com poss�ves erros

       IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
             vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
             vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'N�o foi possivel obter dados de emprestimos.';
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
                 vr_dscritic := 'Valor superior ao saldo devedor! Valor M�ximo permitido: ' ||
                                to_char(vr_vlaliqui, '9G999G990D00', 'nls_numeric_characters='',.''');
                 RAISE vr_exc_erro;
              END IF;
           ELSE
              IF pr_vlrpagto > vr_sldpreju THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Valor superior ao saldo devedor! Valor M�ximo permitido: ' ||
                                to_char(vr_sldpreju, '9G999G990D00', 'nls_numeric_characters='',.''');
                 RAISE vr_exc_erro;
              END IF;
           END IF;
        ELSE
           CLOSE cr_crapepr;
           vr_cdcritic := 0;
           vr_dscritic := 'O Contrato informado n�o existe!';
           RAISE vr_exc_erro;
        END IF;

        -- PJ 450 -- Diego Simas (AMcom) -- Fim

        IF pr_vlrpagto > PREJ0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) THEN
          vr_dscritic := 'Valor informado para pagamento � maior que o saldo dispon�vel.';

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
          pr_dscritic := 'Erro n�o tratado na rotina TELA_ATENDA_DEPOSVIS.pc_paga_emprestimo_ct: ' || SQLERRM;

          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || SQLERRM || '</Erro></Root>');
          ROLLBACK;
  END pc_paga_emprestimo_ct;

  PROCEDURE pc_consulta_dt_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
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
  Objetivo   : Consulta a data de inclus�o de preju�zo.

  Altera��es :

  -------------------------------------------------------------------------------------------------------------*/

  -- CURSORES --

  --> Consultar data de inclus�o prejuizo quando a conta est� em preju�zo
  CURSOR cr_prejuizo_s(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
    SELECT t.dtinclusao
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtliquidacao IS NULL;
  rw_prejuizo_s cr_prejuizo_s%ROWTYPE;

  --> Consultar data de inclus�o prejuizo quando a conta "n�o" est� em preju�zo
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

  -- Se retornou alguma cr�tica
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Levanta exce��o
    RAISE vr_exc_saida;
  END IF;

  -- PASSA OS DADOS PARA O XML RETORNO
  -- Criar cabe�alho do XML
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
      -- Conta Corrente est� em Preju�zo
      OPEN cr_prejuizo_s(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);

      FETCH cr_prejuizo_s INTO rw_prejuizo_s;
      IF cr_prejuizo_s%FOUND THEN
        vr_dataprej := rw_prejuizo_s.dtinclusao;
      END IF;
    ELSE
      -- Conta Corrente n�o est� em Preju�zo
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
    -- Retorno n�o OK
    pr_des_erro:= 'NOK';

    -- Erro
    pr_cdcritic:= vr_cdcritic;
    pr_dscritic:= vr_dscritic;

    -- Existe para satisfazer exig�ncia da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  WHEN OTHERS THEN
    -- Retorno n�o OK
    pr_des_erro:= 'NOK';

    -- Erro
    pr_cdcritic:= 0;
    pr_dscritic:= 'Erro na pc_consulta_dt_preju --> '|| SQLERRM;

    -- Existe para satisfazer exig�ncia da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_dt_preju;

PROCEDURE pc_busca_saldos_juros60(pr_cdcooper IN crapris.cdcooper%TYPE --> C�digo da cooperativa
                                , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se n�o informado, a procedure recupera da base)
                                , pr_tppesqui IN NUMBER DEFAULT 1    --> 1|Online  0|Batch
                                , pr_vlsld59d OUT NUMBER               --> Saldo at� 59 dias (saldo devedor - juros +60)
                                , pr_vljuro60 OUT NUMBER
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE)  IS          --> Valor dos juros +60

BEGIN

DECLARE
  -- Calend�rio da cooperativa
  rw_crapdat btch0001.rw_crapdat%TYPE;

  vr_exc_saida  EXCEPTION;  --> Exce��o para o caso de saldo indispon�vel na base de dados
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;

  vr_jur60_37 NUMBER;
  vr_jur60_57 NUMBER;
  vr_jur60_38 NUMBER;
BEGIN
    pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_qtdiaatr => pr_qtdiaatr
                             , pr_tppesqui => pr_tppesqui
                             , pr_vlsld59d => pr_vlsld59d
                             , pr_vlju6037 => vr_jur60_37
                             , pr_vlju6038 => vr_jur60_38
                             , pr_vlju6057 => vr_jur60_57
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);

    IF vr_cdcritic >0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_vljuro60 := vr_jur60_37 + vr_jur60_38 + vr_jur60_57;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := 'Erro n�o tratado na "TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60".';
  END;
END pc_busca_saldos_juros60;

-- Busca saldo at� 59 dias e valores de juros +60 detalhados (hist. 37+2718, hist 38 e hist. 57)
PROCEDURE pc_busca_saldos_juros60_det(pr_cdcooper IN crapris.cdcooper%TYPE --> C�digo da cooperativa
                                    , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                    , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se n�o informado, a procedure recupera da base)
                                    , pr_dtlimite IN DATE   DEFAULT NULL --> Data limite para filtro dos lan�amentos na CRAPLCM
                                    , pr_tppesqui IN NUMBER DEFAULT 1    --> 1|Online  0|Batch
                                    , pr_vlsld59d OUT NUMBER             --> Saldo at� 59 dias (saldo devedor - juros +60)
                                    , pr_vlju6037 OUT NUMBER             --> Juros +60 (Hist. 37 + 2718)
                                    , pr_vlju6038 OUT NUMBER             -- Juros + 60 (Hist. 38)
                                    , pr_vlju6057 OUT NUMBER             -- Juros + 60 (Hist. 57)
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE)  IS          --> Valor dos juros +60

BEGIN

DECLARE
  -- Recupera dados da CRAPLCM para compor saldo devedor at� 59 dias e valores de juros +60
  CURSOR cr_craplcm(pr_dt59datr IN crapris.dtinictr%TYPE
	                , pr_dtprejuz IN tbcc_prejuizo.dtinclusao%TYPE
					, pr_dtmvtolt IN crapsda.dtmvtolt%TYPE) IS
	SELECT *
    FROM (
		WITH lancamentos AS (
          SELECT lcm.dtmvtolt dtmvtolt
               , his.cdhistor cdhistor
               , his.indebcre indebcre
               , lcm.vllanmto vllanmto
							 , 0            vlsddisp
							 , 0            vlsdante
							 , 0            vldifsld
    FROM craplcm lcm
       , craphis his
			 WHERE his.cdcooper = lcm.cdcooper
     AND his.cdhistor   = lcm.cdhistor
				 AND lcm.cdcooper = pr_cdcooper
				 AND lcm.nrdconta = pr_nrdconta
				 AND lcm.dtmvtolt > pr_dt59datr
				 AND (pr_dtlimite IS NULL OR lcm.dtmvtolt <= pr_dtlimite)
					UNION
					SELECT sda.dtmvtolt dtmvtolt
					     , 0            cdhistor
							 , 'X'          indebcre
							 , 0            vllanmto
							 , abs(sda.vlsddisp) vlsddisp
               , LAG(abs(sda.vlsddisp)) OVER(ORDER BY sda.dtmvtolt) vlsdante
               , NVL((LAG(abs(sda.vlsddisp)) OVER(ORDER BY sda.dtmvtolt) ) - abs(sda.vlsddisp) ,0) vldifsld
					  FROM crapsda sda
					 WHERE sda.cdcooper = pr_cdcooper
             AND sda.nrdconta = pr_nrdconta
             AND sda.dtmvtolt >= pr_dt59datr
						 AND (pr_dtlimite IS NULL OR sda.dtmvtolt <= pr_dtlimite)
					UNION
					-- Cria registro para o dia atual (que n�o tem saldo na CRAPSDA)
					SELECT pr_dtmvtolt   dtmvtolt
               , 0             cdhistor
               , 'X'           indebcre
               , 0             vllanmto
               , 0             vlsddisp
               , 0             vlsdante
               , nvl(SUM(decode(his.indebcre, 'C', vllanmto, vllanmto * -1)), 0) vldifsld
            FROM craplcm lcm
               , craphis his
           WHERE his.cdcooper = lcm.cdcooper
             AND his.cdhistor = lcm.cdhistor
             AND lcm.cdcooper = pr_cdcooper
             AND lcm.nrdconta = pr_nrdconta
             AND lcm.dtmvtolt = pr_dtmvtolt
						 AND NOT EXISTS (
						      SELECT 1
									  FROM crapsda aux
									 WHERE aux.cdcooper = lcm.cdcooper
									   AND aux.nrdconta = lcm.nrdconta
										 AND aux.dtmvtolt = pr_dtmvtolt
						     )
		)
		SELECT 'jur60_37' tipo
				 , lct.dtmvtolt
				 , sum(lct.vllanmto) valor
			FROM lancamentos lct
		 WHERE lct.cdhistor = 37
		 GROUP BY lct.dtmvtolt
		UNION
		SELECT 'jur60_38' tipo
				 , lct.dtmvtolt
				 , SUM(lct.vllanmto) valor
		 FROM lancamentos lct
		WHERE lct.cdhistor = 38
		GROUP BY lct.dtmvtolt
		UNION
		SELECT 'jur60_57' tipo
				 , lct.dtmvtolt
				 , SUM(lct.vllanmto) valor
		 FROM lancamentos lct
		WHERE lct.cdhistor = 57
		GROUP BY lct.dtmvtolt
		UNION
		SELECT 'jur60_2718' tipo
				 , lct.dtmvtolt
				 , SUM(lct.vllanmto) valor
		 FROM lancamentos lct
		WHERE lct.cdhistor = 2718
		GROUP BY lct.dtmvtolt
		UNION
		SELECT 'iof_prej' tipo
				 , lct.dtmvtolt
				 , SUM(lct.vllanmto) valor
		 FROM lancamentos lct
		WHERE lct.cdhistor = 2323
			AND pr_dtprejuz IS NOT NULL
			AND lct.dtmvtolt >= pr_dtprejuz
		GROUP BY lct.dtmvtolt
		UNION
		SELECT 'vlsddisp' tipo
				 , lct.dtmvtolt
				 , SUM(lct.vlsddisp) valor
		 FROM lancamentos lct
		 WHERE lct.cdhistor = 0
		 GROUP BY lct.dtmvtolt
		UNION
		SELECT 'vlsdante' tipo
		     , lct.dtmvtolt
				 , SUM(lct.vlsdante) valor
		  FROM lancamentos lct
		 WHERE lct.cdhistor = 0
		 GROUP BY lct.dtmvtolt
		 UNION
		 SELECT 'vldifsld' tipo
		     , lct.dtmvtolt
				 , SUM(lct.vldifsld) valor
		  FROM lancamentos lct
		 WHERE lct.cdhistor = 0
		GROUP BY lct.dtmvtolt
	)
	PIVOT
	(
	   SUM(valor)
		 FOR tipo IN ('jur60_37'   AS jur60_37
                    , 'jur60_38'   AS jur60_38
                    , 'jur60_57'   AS jur60_57
                    , 'jur60_2718' AS jur60_2718
                    , 'iof_prej'   AS iof_prej
					, 'vlsddisp'   AS vlsddisp
					, 'vlsdante'   AS vlsdante
					, 'vldifsld'   AS vldifsld)
	)
	ORDER BY dtmvtolt;
  rw_craplcm cr_craplcm%ROWTYPE;

  -- Busca o limite de cr�dito atual do cooperado e a flag de preju�zo da conta corrente
  CURSOR cr_crapass IS
  SELECT nvl(ass.vllimcre,0) vllimcre
	     , inprejuz
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta;
	rw_crapass cr_crapass%ROWTYPE;

  -- Informa��es de saldo atual da conta corrente
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

  -- Busca o saldo da conta para o dia em que ela atingiu 59 dias de atraso
	CURSOR cr_crapsda(pr_dt59datr IN DATE) IS
	SELECT abs(sda.vlsddisp)
    FROM crapsda sda
   WHERE sda.cdcooper = pr_cdcooper
     AND sda.nrdconta = pr_nrdconta
		 AND sda.dtmvtolt = pr_dt59datr;

  -- Consulta data de transfer�ncia da conta corrente para preju�zo
	CURSOR cr_prejuizo IS
	SELECT dtinclusao
	  FROM tbcc_prejuizo
	 WHERE cdcooper = pr_cdcooper
	   AND nrdconta = pr_nrdconta
		 AND dtliquidacao IS NULL;

	-- Consulta o valor estornado de juros +60 na conta corrente em preju�zo
	CURSOR cr_estjur60(pr_dtmvtolt DATE) IS
	SELECT nvl(SUM(decode(cdhistor, 2728, vllanmto, vllanmto * -1)), 0) total_estorno
	  FROM tbcc_prejuizo_detalhe prj
	 WHERE cdcooper = pr_cdcooper
	   AND nrdconta = pr_nrdconta
		 AND dtmvtolt = pr_dtmvtolt
		 AND cdhistor IN (2727, 2728);

  -- Calend�rio da cooperativa
  rw_crapdat btch0001.rw_crapdat%TYPE;

  vr_data_corte_dias_uteis DATE; --> Data de corte para contagem de dias de atraso em dias corridos
  vr_dtcorte_rendaprop     DATE; --> Data de corte de implanta��o do Rendas a Apropriar (n�o apropria��o de receita dos juros +60)
  vr_data_59dias_atraso    DATE; --> Data em que a conta atingiu 59 dias de atraso (ADP)
  vr_jur60_37              NUMBER;
  vr_jur60_57              NUMBER;
  vr_jur60_2718            NUMBER;
  vr_jur60_38              NUMBER;
  vr_vliofprj              NUMBER := 0;
  vr_dtprejuz              DATE;
  vr_tipo_busca            Varchar2(1);

  vr_tab_saldos  EXTR0001.typ_tab_saldos;
  vr_tab_erro    GENE0001.typ_tab_erro;
  vr_vlsldisp    NUMBER;  
  vr_index_saldo INTEGER; 
  vr_des_reto    VARCHAR2(2000);
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_exc_erro    EXCEPTION;

  vr_exc_saldo_indisponivel EXCEPTION;  --> Exce��o para o caso de saldo indispon�vel na base de dados
  vr_qtddiaatr INTEGER;                 --> Quantidade de dias de atraso da conta
	
	vr_datasaldo DATE;

	vr_saldo_dia   NUMBER;
	vr_est_jur60   NUMBER;
BEGIN
    -- Busca data de corte para contagem de dias de atraso em dias corridos
    vr_data_corte_dias_uteis := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                   ,'DD/MM/RRRR');
    -- Carrega o calend�rio da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --  Carrega informa��es de saldo atual da conta
    OPEN cr_saldos(pr_cdcooper, pr_nrdconta);
    FETCH cr_saldos INTO rw_saldos;
    CLOSE cr_saldos;

    -- Busca o limite ativo da conta
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    vr_qtddiaatr := pr_qtdiaatr;

    -- Se n�o foi informada a quantidade de dias em atraso (este valor ser� informado quando
    -- for necess�rio considerar a quantidade de dias em atraso calculada e n�o a armazenada na CRAPSLD).
    IF vr_qtddiaatr IS NULL THEN
      vr_qtddiaatr := rw_saldos.qtddsdev; -- Considera os dias em atraso da CRAPSLD
    END IF;

    pr_vlju6037 := 0; -- Assume que a conta n�o tem juros +60, caso a conta n�o tenha ultrapassado os 60 dias de atraso
    pr_vlju6038 := 0; -- Assume que a conta n�o tem juros +60, caso a conta n�o tenha ultrapassado os 60 dias de atraso
    pr_vlju6057 := 0; -- Assume que a conta n�o tem juros +60, caso a conta n�o tenha ultrapassado os 60 dias de atraso

    IF vr_qtddiaatr = 0 THEN -- Se a conta n�o est� em atraso
      pr_vlsld59d := 0;
    ELSE
      IF vr_qtddiaatr < 60 THEN -- Se a conta n�o ultrapassou os 60 dias de atraso

        IF pr_tppesqui = 0 THEN
          -- Processo Batch / Central de Risco
          vr_tipo_busca := 'I'; -- I=usa dtrefere (Saldo do Dia / Central)
          EXTR0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => 1
                                 ,pr_nrdcaixa   => 100
                                 ,pr_cdoperad   => NULL
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_dtrefere   => rw_crapdat.dtmvtopr
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tab_erro   => vr_tab_erro);
        ELSE
          -- Processo Online / Tela Depositos A Vista
          vr_tipo_busca := 'A'; -- A=Usa dtrefere-1 (Saldo Anterior / Online)
        -- Obt�m o saldo atual da conta
				EXTR0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 100
                                   ,pr_cdoperad => '1'
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vllimcre => rw_crapass.vllimcre
                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                   ,pr_tipo_busca => vr_tipo_busca
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_sald => vr_tab_saldos
                                   ,pr_tab_erro => vr_tab_erro);
        END IF;

				-- Se retornou erro
				IF vr_des_reto <> 'OK' THEN
					IF vr_tab_erro.COUNT > 0 THEN
						vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
            vr_dscritic := 'Erro na procedure TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60.';
					END IF;
					RAISE vr_exc_erro;
				END IF;

				-- Buscar Indice
				vr_index_saldo := vr_tab_saldos.FIRST;
				IF vr_index_saldo IS NOT NULL THEN
					-- Acumular Saldo
					vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0),2);
				END IF;
				
        -- Desconta o limite de cr�dito ativo do saldo devedor total
        pr_vlsld59d := abs(vr_vlsldisp) - rw_crapass.vllimcre;

        -- Tratamento para n�o mostrar o Saldo Devedor 59D negativo
        IF pr_vlsld59d < 0 THEN
          pr_vlsld59d := 0;
        END IF;
      ELSE --  vr_qtddiaatr >= 60
        -- Busca data em que a conta foi transferida para preju�zo
				 OPEN cr_prejuizo;
				 FETCH cr_prejuizo INTO vr_dtprejuz;
				 
				 IF cr_prejuizo%NOTFOUND THEN
					 vr_dtprejuz := NULL;
				 END IF;
				 
				 CLOSE cr_prejuizo;

        -- Calcula a data em que a aconta atingiu 59 dias de atraso
        vr_data_59dias_atraso := fn_calc_data_59dias_atraso(pr_cdcooper, pr_nrdconta);

        -- Busca o primeiro dia �til anterior a data calculada de 59 dias de atraso
        WHILE NOT fn_valida_dia_util(pr_cdcooper, vr_data_59dias_atraso)  LOOP
          vr_data_59dias_atraso := vr_data_59dias_atraso - 1;
				 END LOOP;

        -- Recupera o saldo do dia em que a conta atingiu 59 dias de atraso
        OPEN cr_crapsda(vr_data_59dias_atraso);
				FETCH cr_crapsda INTO pr_vlsld59d;

		 IF cr_crapsda%NOTFOUND THEN
            CLOSE cr_crapsda;

            RAISE vr_exc_saldo_indisponivel;
		 END IF;

		 CLOSE cr_crapsda;

            -- Desconta o limite de cr�dito ativo do saldo devedor total
				pr_vlsld59d := pr_vlsld59d - rw_crapass.vllimcre;

            -- Percorre os lan�amentos ocorridos ap�s 60 dias de atraso que n�o sejam juros +60
				FOR rw_craplcm IN cr_craplcm(vr_data_59dias_atraso, vr_dtprejuz, rw_crapdat.dtmvtolt) LOOP
					-- Descarta o primeiro registro, usado apenas para popular o saldo do dia anterior para a data que completa 60 dias de atraso
					IF rw_craplcm.dtmvtolt = vr_data_59dias_atraso THEN
						continue;
					END IF;

              pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_37,0);
							pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_2718,0); -- AJUSTAR *********
							pr_vlju6038 := pr_vlju6038 + nvl(rw_craplcm.jur60_38,0);
							pr_vlju6057 := pr_vlju6057 + nvl(rw_craplcm.jur60_57,0);
							vr_vliofprj := vr_vliofprj + nvl(rw_craplcm.iof_prej,0);

					vr_saldo_dia := rw_craplcm.vldifsld;

					IF vr_saldo_dia > 0 THEN -- Se fechou o dia com saldo positivo (cr�dito)
						vr_saldo_dia := vr_saldo_dia + (nvl(rw_craplcm.jur60_37, 0) +
							                              nvl(rw_craplcm.jur60_38, 0) +
																						nvl(rw_craplcm.jur60_57, 0) +
																						nvl(rw_craplcm.jur60_2718, 0) +
																						nvl(rw_craplcm.iof_prej,0));

                -- Paga IOF debitado ap�s transfer�ncia para preju�zo (se houver)
                IF vr_vliofprj > 0 THEN
							IF vr_saldo_dia >= vr_vliofprj THEN
								vr_saldo_dia := vr_saldo_dia - vr_vliofprj;
                    vr_vliofprj := 0;
                  ELSE
								vr_vliofprj := vr_vliofprj - vr_saldo_dia;
								vr_saldo_dia := 0;
                  END IF;
                END IF;

						IF vr_saldo_dia > 0 AND pr_vlju6037 > 0 THEN
                  -- Amortiza os juros + 60 (Hist. 37 + Hist. 2718)
							IF vr_saldo_dia >= pr_vlju6037 THEN
								vr_saldo_dia := vr_saldo_dia - pr_vlju6037;
                    pr_vlju6037 := 0;
                  ELSE
								pr_vlju6037 := pr_vlju6037 - vr_saldo_dia;
								vr_saldo_dia := 0;
                  END IF;
                END IF;

						IF vr_saldo_dia > 0 AND pr_vlju6038 > 0 THEN
                    -- Amortiza os juros + 60 (Hist. 38)
							IF vr_saldo_dia >= pr_vlju6038 THEN
								vr_saldo_dia := vr_saldo_dia - pr_vlju6038;
                      pr_vlju6038 := 0;
                    ELSE
								pr_vlju6038 := pr_vlju6038 - vr_saldo_dia;
								vr_saldo_dia := 0;
                  END IF;
                END IF;

						IF vr_saldo_dia > 0 AND pr_vlju6057 > 0 THEN
                    -- Amortiza os juros + 60 (Hist. 57)
							IF vr_saldo_dia >= pr_vlju6057 THEN
								vr_saldo_dia := vr_saldo_dia - pr_vlju6057;
                      pr_vlju6057 := 0;
                    ELSE
								pr_vlju6057 := pr_vlju6057 - vr_saldo_dia;
								vr_saldo_dia := 0;
                  END IF;
                END IF;

							IF vr_saldo_dia > 0 THEN
                  -- Amortiza o saldo devedor at� 59 dias
								IF vr_saldo_dia >= pr_vlsld59d THEN
                    pr_vlsld59d := 0;
                  ELSE
									pr_vlsld59d := pr_vlsld59d - vr_saldo_dia;
                  END IF;
                END IF;
						ELSIF vr_saldo_dia < 0 THEN -- Se fechou o dia com saldo negativo (d�bito)
							-- Desconta o valor dos juros +60 do saldo do dia (d�bito)
							vr_saldo_dia := abs(vr_saldo_dia) - (nvl(rw_craplcm.jur60_37, 0) +
							                                     nvl(rw_craplcm.jur60_38, 0) +
																							     nvl(rw_craplcm.jur60_57, 0) +
																							     nvl(rw_craplcm.jur60_2718, 0) +
																									 nvl(rw_craplcm.iof_prej, 0));
																									 
							IF vr_dtprejuz IS NOT NULL AND rw_craplcm.dtmvtolt >= vr_dtprejuz THEN
								OPEN cr_estjur60(rw_craplcm.dtmvtolt);
								FETCH cr_estjur60 INTO vr_est_jur60;
								CLOSE cr_estjur60;
								
								IF vr_est_jur60 > 0 THEN
									pr_vlju6037 := nvl(pr_vlju6037, 0) + vr_est_jur60;
									vr_saldo_dia := vr_saldo_dia - vr_est_jur60;
								END IF;
								
							END IF;

           -- Incorpora o d�bito ao saldo devedor at� 59 dias de atraso
							pr_vlsld59d := pr_vlsld59d + vr_saldo_dia;
						ELSIF vr_saldo_dia = 0 AND vr_dtprejuz IS NOT NULL 
						AND rw_craplcm.dtmvtolt >= vr_dtprejuz AND nvl(rw_craplcm.iof_prej, 0) > 0 THEN
						  -- Caso tenha ocorrido d�bito de IOF no pagamento de preju�zo e tenha ocorrido estorno do 
							-- pagamento no mesmo dia, � necess�rio acrescentar o valor do IOF ao saldo at� 59 dias
							-- mesmo que o saldo do dia tenha fechado com o mesmo valor do saldo do dia anteiror
							-- (Reginaldo/AMcom - P450)
						  pr_vlsld59d := pr_vlsld59d - abs(rw_craplcm.iof_prej);
              END IF;
            END LOOP;

            -- Soma o valor de IOF debitado ap�s a transfer�ncia para preju�zo ao saldo 59 dias (se n�o foi pago pelos cr�ditos ocorridos na conta)
            pr_vlsld59d := pr_vlsld59d + vr_vliofprj;

					-- Tratamento para n�o mostrar o Saldo Devedor 59D negativo
					IF pr_vlsld59d < 0 THEN
						pr_vlsld59d := 0;
         END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
    WHEN vr_exc_saldo_indisponivel THEN
      pr_cdcritic := 853;
      pr_dscritic := 'Nao foi poss�vel recuperar o saldo de 59 dias de atraso.';
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := 'Erro nao tratado na "TELA_ATENDA_DEPOSVIS.pc_consulta_saldos_juros60_det":' || SQLERRM;
  END;
END pc_busca_saldos_juros60_det;

PROCEDURE pc_consulta_sit_empr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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
    Objetivo   : Consulta para verificar se o empr�stimo est� em preju�zo.

    Altera��es :

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

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis Locais
    vr_indpreju INTEGER := 0;
  BEGIN
    pr_des_erro := 'OK';
    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    -- Criar cabe�alho do XML
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

    FETCH cr_crapepr INTO vr_indpreju;

    IF cr_crapepr%NOTFOUND THEN
    vr_indpreju := 0;
    END IF;

		CLOSE cr_crapepr;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inprejuz',
                           pr_tag_cont => vr_indpreju,
                           pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      pr_des_erro:= 'NOK';
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina "TELA_ATENDA_DEPOSVIS.pc_consulta_sit_empr": '|| SQLERRM;

      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_sit_empr;

END TELA_ATENDA_DEPOSVIS;
/
