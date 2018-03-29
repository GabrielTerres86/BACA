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
  -- Alterado:
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
		SELECT sld.vlsddisp
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
		SELECT sda.vlsddisp
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
		vr_saldo_devedor_mais_60dias NUMBER := 0; -- Saldo devedor a partir do 60º dia
		vr_saldo_devedor_total       NUMBER := 0; -- Saldo devedor total
		vr_valor_iof_debitar         NUMBER := 0; -- Valor do IOF a debitar
		vr_data_59dias_atraso        DATE;
		vr_data_corte                DATE := TO_DATE('10/04/2018', 'dd/mm/yyyy'); -- Data de corte para contagem em dias úteis/corridos (substituir por parâmetro do BD)

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

			IF rw_saldos.dtrisclq IS NOT NULL THEN
				IF rw_saldos.qtddsdev < 60 THEN
           vr_saldo_devedor_59dias := rw_saldos.vlsddisp;
				ELSE
					 IF rw_saldos.dtrisclq < vr_data_corte THEN -- Se data de início do atraso menor que a data de corte
			        vr_data_59dias_atraso := fn_soma_dias_uteis_data(vr_cdcooper, rw_saldos.dtrisclq, 59); -- Conta dias úteis
					 ELSE
						  vr_data_59dias_atraso := rw_saldos.dtrisclq + 59; -- Conta dias corridos
					 END IF;

				   OPEN cr_crapsda(vr_cdcooper, pr_nrdconta, vr_data_59dias_atraso);
				   FETCH cr_crapsda INTO rw_crapsda;

				   IF cr_crapsda%NOTFOUND THEN
						  CLOSE cr_crapsda;

					    RAISE vr_exc_saldo_indisponivel;
					 ELSE
						  vr_saldo_devedor_59dias      := rw_crapsda.vlsddisp;
							vr_saldo_devedor_mais_60dias := rw_saldos.vlsddisp - vr_saldo_devedor_59dias;
  			   END IF;
				END IF;
			END IF;

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
															pr_tag_cont => to_char(vr_saldo_devedor_mais_60dias,
															                       '9G999G990D00',
																										 'nls_numeric_characters='',.'''),
															pr_des_erro => vr_dscritic);
															
			vr_valor_iof_debitar := nvl(rw_saldos.vliofmes, 0) * -1;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
															pr_tag_pai  => 'Dados',
															pr_posicao  => 0,
															pr_tag_nova => 'valor_iof_debitar',
															pr_tag_cont => to_char(vr_valor_iof_debitar,
															                       '9G999G990D00',
																										 'nls_numeric_characters='',.'''),
															pr_des_erro => vr_dscritic);

			 vr_saldo_devedor_total := vr_saldo_devedor_59dias +
			                           vr_saldo_devedor_mais_60dias +
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

END TELA_ATENDA_DEPOSVIS;
/
