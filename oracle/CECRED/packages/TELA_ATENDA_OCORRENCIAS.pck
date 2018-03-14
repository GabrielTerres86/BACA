CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da tela Atenda Ocorrências
  --
  -- Alterado: Criada procedure pc_busca_dados_risco
	--           23/01/2018 - Reginaldo (AMcom) 
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Busca dados de risco das contas (contratos de empréstimo e limite de crédito) */
  PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                                ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

						/* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

END TELA_ATENDA_OCORRENCIAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_OCORRENCIAS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da tela Atenda Ocorrências
  --
  -- Alterado: Criada procedure pc_busca_dados_risco
	--           23/01/2018 - Reginaldo (AMcom)          
  --
  ---------------------------------------------------------------------------------------------------------------

	-- Registro para armazenar todos os dados que são exibidos em cada linha da aba de Riscos
	TYPE typ_info_riscos IS
      RECORD(nrdconta       crapris.nrdconta%TYPE
						,nrcpfcgc       crapass.nrcpfcgc%TYPE
						,nrctremp       crapris.nrctremp%TYPE
						,tiplinha       VARCHAR2(3)
						,ris_inclusao   VARCHAR2(2)
						,ris_rating     VARCHAR2(2)
						,ris_atraso     VARCHAR2(2)
						,ris_agravado   VARCHAR2(2)
						,ris_melhora    VARCHAR2(2)
						,ris_operacao   VARCHAR2(2)
						,ris_cpf        VARCHAR2(2)
						,ris_final      VARCHAR2(2)
						,nrdgrupo       VARCHAR2(11)
			);

	-- Tabela temporária para armazenar os dados de riscos
	TYPE typ_tab_riscos IS TABLE OF typ_info_riscos
	  INDEX BY BINARY_INTEGER;

	-- Tabela que armazenará os riscos CPF que são calculados durante o processamento das contas
	TYPE typ_tab_cpf IS TABLE OF VARCHAR(2)
	  INDEX BY VARCHAR2(11);

	-- Tabela que armazenará os riscos do grupo econômico que são calculados durante o processamento das contas
	TYPE typ_tab_ge IS TABLE OF VARCHAR(2)
	  INDEX BY VARCHAR(11);

  FUNCTION fn_busca_rating(pr_cdcooper NUMBER
		                     , pr_nrdconta NUMBER
												 , pr_nrctremp NUMBER
												 , pr_cdorigem NUMBER)
    RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;

      --- >>> CURSORES <<< ---
      CURSOR cr_rating IS
      SELECT rat.indrisco
         FROM crapnrc rat
        WHERE rat.cdcooper =  pr_cdcooper
          AND rat.nrdconta =  pr_nrdconta
          AND rat.nrctrrat =  pr_nrctremp
			    AND rat.tpctrrat =  DECODE(pr_cdorigem
					                          , 1, 1  -- conta corrente
															  		, 2, 2  -- limite de desconto de cheques
																	  , 3, 90 -- empréstimo/financiamento
																	  , 4, 3  -- limite de desconto de títulos
																	  , 5, 3) -- limite de desconto de títulos
          AND rat.insitrat =  2;
      rw_rating cr_rating%ROWTYPE;
  BEGIN
     OPEN cr_rating;
     FETCH cr_rating INTO rw_rating;

     vr_rating := rw_rating.indrisco;

     CLOSE cr_rating;

     RETURN vr_rating;
  END fn_busca_rating;

	FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_dtmvtoan DATE)
    RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE AS vr_risco_agr tbrisco_cadastro_conta.cdnivel_risco%TYPE;

			--- >>> CURSORES <<< ---
      CURSOR cr_agravado IS
      SELECT agr.cdnivel_risco
        FROM tbrisco_cadastro_conta agr
       WHERE agr.cdcooper =  pr_cdcooper
         AND agr.nrdconta =  pr_nrdconta
				 AND agr.dtmvtolt <= pr_dtmvtoan;
      rw_agravado cr_agravado%ROWTYPE;
  BEGIN
    OPEN cr_agravado;

    FETCH cr_agravado INTO rw_agravado;

    vr_risco_agr := rw_agravado.cdnivel_risco;

    CLOSE cr_agravado;

    RETURN vr_risco_agr;
  END fn_busca_risco_agravado;

	FUNCTION fn_busca_valor_divida(pr_cdcooper NUMBER
                               , pr_nrdconta NUMBER
															 , pr_nrctremp NUMBER
                               , pr_dtmvtoan DATE
															 , pr_cdmodali NUMBER)
		RETURN NUMBER AS vr_valor_divida NUMBER;

		 --- >>> CURSORES <<< ---
		 CURSOR cr_valor_divida IS
     SELECT r.vldivida
       FROM crapris r
      WHERE r.cdcooper = pr_cdcooper
        AND r.nrdconta = pr_nrdconta
				AND r.nrctremp = pr_nrctremp
        AND r.dtrefere = pr_dtmvtoan
				AND (pr_cdmodali IS NULL OR r.cdmodali = pr_cdmodali)
        AND r.inddocto = 1;
		 rw_valor_divida cr_valor_divida%ROWTYPE;
	BEGIN
		 OPEN cr_valor_divida;

		 FETCH cr_valor_divida INTO rw_valor_divida;

		 CLOSE cr_valor_divida;

		 vr_valor_divida := rw_valor_divida.vldivida;

		 RETURN vr_valor_divida;
	END fn_busca_valor_divida;

	FUNCTION fn_busca_data_risco(pr_cdcooper   NUMBER
                             , pr_nrdconta   NUMBER
                             , pr_dtmvtoan   DATE
														 , pr_vlrarrasto NUMBER)
		RETURN crapris.dtdrisco%TYPE AS vr_data_risco crapris.dtdrisco%TYPE;

		 --- >>> CURSORES <<< ---

		 -- Cursor para recuperar a data de risco --
	   CURSOR cr_data_risco(pr_cdcooper    NUMBER
                         , pr_nrdconta   NUMBER
                         , pr_dtmvtoan   DATE
												 , pr_vlrarrasto NUMBER) IS
     SELECT r.dtdrisco
       FROM crapris r
      WHERE r.cdcooper = pr_cdcooper
        AND r.nrdconta = pr_nrdconta
        AND r.dtrefere = pr_dtmvtoan
        AND r.inddocto = 1
				AND (pr_vlrarrasto IS NULL OR r.vldivida > pr_vlrarrasto)
       ORDER BY r.innivris DESC
			     , r.dtdrisco ASC;
     rw_data_risco cr_data_risco%ROWTYPE;
	BEGIN
	   OPEN cr_data_risco(pr_cdcooper, pr_nrdconta, pr_dtmvtoan, pr_vlrarrasto);

		 FETCH cr_data_risco INTO rw_data_risco;

		 IF cr_data_risco%NOTFOUND THEN
		    CLOSE cr_data_risco;

				OPEN cr_data_risco(pr_cdcooper, pr_nrdconta, pr_dtmvtoan, NULL);

				FETCH cr_data_risco INTO rw_data_risco;
		 END IF;

		 CLOSE cr_data_risco;

		 vr_data_risco := rw_data_risco.dtdrisco;

		 RETURN vr_data_risco;
	END fn_busca_data_risco;
	
	FUNCTION fn_busca_dias_atraso_emp(pr_cdcooper    NUMBER
                                  , pr_nrdconta    NUMBER
                                  , pr_nrctremp    NUMBER
                                  , pr_dtmvtoan    DATE) 
		RETURN INTEGER AS vr_dias_atraso INTEGER;

      --- >>> CURSORES <<< ---
      CURSOR cr_diaatr IS
      SELECT ris.qtdiaatr
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = pr_dtmvtoan
         AND ris.inddocto = 1
				 AND ris.cdorigem = 3;
      rw_diaatr cr_diaatr%ROWTYPE;
  BEGIN
     OPEN cr_diaatr;

     FETCH cr_diaatr INTO rw_diaatr;

     CLOSE cr_diaatr;

     vr_dias_atraso   := rw_diaatr.qtdiaatr;
		 
		 RETURN vr_dias_atraso;
  END fn_busca_dias_atraso_emp;

	FUNCTION fn_busca_dias_atraso_adp(pr_cdcooper   NUMBER
                                  , pr_nrdconta   NUMBER
                                  , pr_dtmvtoan   DATE)
		RETURN INTEGER AS vr_qtd_dias_atraso INTEGER;

			--- >>> CURSORES <<< ---

		  -- Busca os dias de atraso do ADP --
		  CURSOR cr_adp IS
	    SELECT r.qtdiaatr
			  FROM crapris r
			 WHERE r.cdcooper = pr_cdcooper
			   AND r.nrdconta = pr_nrdconta
				 AND r.nrctremp = pr_nrdconta
				 AND r.cdmodali = 101
				 AND r.inddocto = 1
				 AND r.cdorigem = 1
				 AND r.dtrefere = pr_dtmvtoan;
			rw_adp cr_adp%ROWTYPE;
	BEGIN
	  OPEN cr_adp;

		FETCH cr_adp INTO rw_adp;

		IF cr_adp%NOTFOUND THEN
			 vr_qtd_dias_atraso := NULL;
		ELSE
		   vr_qtd_dias_atraso := rw_adp.qtdiaatr;
		END IF;

		CLOSE cr_adp;

		RETURN vr_qtd_dias_atraso;
	END fn_busca_dias_atraso_adp;

	FUNCTION fn_busca_risco_ult_mensal(pr_cdcooper    crawepr.cdcooper%TYPE
                                    , pr_nrdconta   crawepr.nrdconta%TYPE
                                    , pr_dtultdma   crapdat.dtultdma%TYPE
																		, pr_vlrarrasto NUMBER)
		RETURN crawepr.dsnivris%TYPE AS vr_risco_ult_mensal crawepr.dsnivris%TYPE;

     -- >>> CURSORES <<< --

     -- Dados do risco da última central --
     CURSOR cr_riscos(pr_cdcooper   crawepr.cdcooper%TYPE
                     ,pr_nrdconta   crawepr.nrdconta%TYPE
                     ,pr_dtultdma   crapdat.dtultdma%TYPE
                     ,pr_vlrarrasto NUMBER) IS
     SELECT uc.innivris
       FROM crapris uc
      WHERE uc.cdcooper = pr_cdcooper
        AND uc.nrdconta = pr_nrdconta
        AND uc.dtrefere = pr_dtultdma
        AND uc.inddocto = 1
        AND (pr_vlrarrasto IS NULL OR uc.vldivida > pr_vlrarrasto)
      ORDER BY uc.innivris DESC,
               uc.dtdrisco ASC;
     rw_riscos cr_riscos%ROWTYPE;

     -- Variáveis --
     vr_risco_nao_cadastrado BOOLEAN;
  BEGIN
      vr_risco_nao_cadastrado := FALSE;

      OPEN cr_riscos(pr_cdcooper
                    ,pr_nrdconta
                    ,pr_dtultdma
                    ,pr_vlrarrasto);

      FETCH cr_riscos INTO rw_riscos;

      IF cr_riscos%NOTFOUND THEN
         CLOSE cr_riscos;

         OPEN cr_riscos(pr_cdcooper
                       ,pr_nrdconta
                       ,pr_dtultdma
                       ,NULL);

         FETCH cr_riscos INTO rw_riscos;

         IF cr_riscos%NOTFOUND THEN
            vr_risco_nao_cadastrado := TRUE;
         END IF;
      END IF;

      CLOSE cr_riscos;

      IF vr_risco_nao_cadastrado THEN
         vr_risco_ult_mensal := 2;
      ELSE
         vr_risco_ult_mensal := rw_riscos.innivris;
      END IF;

      RETURN vr_risco_ult_mensal;
  END fn_busca_risco_ult_mensal;

	FUNCTION fn_calcula_risco_atraso(qtdiaatr NUMBER)
    RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
  BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 'A'
                            WHEN qtdiaatr <   15  THEN 'A'
                            WHEN qtdiaatr <=  30  THEN 'B'
                            WHEN qtdiaatr <=  60  THEN 'C'
                            WHEN qtdiaatr <=  90  THEN 'D'
                            WHEN qtdiaatr <= 120  THEN 'E'
                            WHEN qtdiaatr <= 150  THEN 'F'
                            WHEN qtdiaatr <= 180  THEN 'G'
                            ELSE 'H' END;
      RETURN risco_atraso;
  END fn_calcula_risco_atraso;

	FUNCTION fn_calcula_risco_atraso_adp(qtdiaatr NUMBER)
    RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
  BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 'A'
                            WHEN qtdiaatr <   15  THEN 'A'
                            WHEN qtdiaatr <=  30  THEN 'B'
                            WHEN qtdiaatr <=  60  THEN 'D'
                            WHEN qtdiaatr <=  90  THEN 'F'
                            ELSE 'H' END;
      RETURN risco_atraso;
  END fn_calcula_risco_atraso_adp;

	FUNCTION fn_traduz_risco(innivris NUMBER)
		RETURN crawepr.dsnivris%TYPE AS dsnivris crawepr.dsnivris%TYPE;
  BEGIN
      dsnivris :=  CASE WHEN innivris = 2  THEN 'A'
                        WHEN innivris = 3  THEN 'B'
                        WHEN innivris = 4  THEN 'C'
                        WHEN innivris = 5  THEN 'D'
                        WHEN innivris = 6  THEN 'E'
                        WHEN innivris = 7  THEN 'F'
                        WHEN innivris = 8  THEN 'G'
                        WHEN innivris = 9  THEN 'H'
												WHEN innivris = 10 THEN 'HH'
                        ELSE '' END;
      RETURN dsnivris;
  END fn_traduz_risco;

  PROCEDURE pc_busca_grupo_economico(pr_cdcooper     IN NUMBER
                                   , pr_nrdconta     IN NUMBER
                                   , pr_nrcpfcgc     IN NUMBER
                                   , vr_numero_grupo OUT VARCHAR2
                                   , vr_risco_grupo  OUT VARCHAR2) IS

			--- >>> CURSORES <<< ---
      CURSOR cr_grupo IS
      SELECT TO_CHAR(g.nrdgrupo) nrdgrupo
           , g.dsdrisgp
        FROM crapgrp g
       WHERE g.cdcooper(+) = pr_cdcooper
         AND g.nrctasoc(+) = pr_nrdconta
         AND g.nrcpfcgc(+) = pr_nrcpfcgc;
      rw_grupo cr_grupo%ROWTYPE;
  BEGIN
    OPEN cr_grupo;

    FETCH cr_grupo INTO rw_grupo;

    CLOSE cr_grupo;

    vr_numero_grupo := rw_grupo.nrdgrupo;
    vr_risco_grupo  := rw_grupo.dsdrisgp;
  END pc_busca_grupo_economico;

  PROCEDURE pc_monta_reg_conta_xml(pr_retxml     IN OUT NOCOPY XMLType
                               ,pr_pos_conta     IN INTEGER
                               ,pr_dscritic      IN OUT VARCHAR2
                               ,pr_num_conta     IN crapass.nrdconta%TYPE
                               ,pr_cpf_cnpj      IN VARCHAR2
                               ,pr_num_contrato  IN crawepr.nrctremp%TYPE
                               ,pr_ris_inclusao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_grupo     IN crawepr.dsnivris%TYPE
                               ,pr_rating        IN crawepr.dsnivris%TYPE
                               ,pr_ris_atraso    IN crawepr.dsnivris%TYPE
                               ,pr_ris_agravado  IN crawepr.dsnivris%TYPE
                               ,pr_ris_operacao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_cpf       IN crawepr.dsnivris%TYPE
                               ,pr_numero_grupo  IN VARCHAR2
															 ,pr_ris_melhora   IN crawepr.dsnivris%TYPE
															 ,pr_ris_final     IN crawepr.dsnivris%TYPE
															 ,pr_tipo_registro IN VARCHAR2) IS
  BEGIN
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Contas',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Conta',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_conta',
                             pr_tag_cont => pr_num_conta,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'cpf_cnpj',
                             pr_tag_cont => pr_cpf_cnpj,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'contrato',
                             pr_tag_cont => pr_num_contrato,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_inclusao',
                             pr_tag_cont => pr_ris_inclusao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_grupo',
                             pr_tag_cont => pr_ris_grupo,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'rating',
                             pr_tag_cont => pr_rating,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_atraso',
                             pr_tag_cont => pr_ris_atraso,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_agravado',
                             pr_tag_cont => pr_ris_agravado,
                             pr_des_erro => pr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_melhora',
                             pr_tag_cont => CASE WHEN pr_ris_melhora <> pr_ris_inclusao AND pr_ris_melhora = 'A' THEN pr_ris_melhora ELSE '' END,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_operacao',
                             pr_tag_cont => pr_ris_operacao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_cpf',
                             pr_tag_cont => pr_ris_cpf,
                             pr_des_erro => pr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_final',
                             pr_tag_cont => pr_ris_final,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_gr_economico',
                             pr_tag_cont => pr_numero_grupo,
                             pr_des_erro => pr_dscritic);

		      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'tipo_registro',
                             pr_tag_cont => pr_tipo_registro,
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_conta_xml;

  PROCEDURE pc_monta_reg_central_risco(pr_retxml           IN OUT NOCOPY XMLType
                                      ,pr_dscritic         IN OUT VARCHAR2
                                      ,pr_ris_ult_central  IN crawepr.dsnivris%TYPE
                                      ,pr_data_risco       IN VARCHAR2
                                      ,pr_qtd_dias_risco   IN VARCHAR2
																	    ,pr_ris_cooperado    IN crapass.inrisctl%TYPE
																	    ,pr_dat_ris_cooperad IN crapass.dtrisctl%TYPE) IS
  BEGIN
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Central',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_ult_central',
                             pr_tag_cont => pr_ris_ult_central,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'data_risco',
                             pr_tag_cont => pr_data_risco,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtd_dias_risco',
                             pr_tag_cont => pr_qtd_dias_risco,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_cooperado',
                             pr_tag_cont => pr_ris_cooperado || ' - ' || TO_CHAR(pr_dat_ris_cooperad, 'DD/MM/YYYY'),
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_central_risco;


 PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                               ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* ............................................................................

        Programa: pc_busca_dados_risco
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom & Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao: 14/03/2018

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar dados de risco a partir de uma conta base
        Observacao: -----
        Alteracoes: 
				            Modificação no processamento das contas para considerar rating de
										contratos de limite de crédito no arrasto, mesmo que a conta não
										possua outras operações.
										14/03/2018 - Reginaldo (AMcom)
      ..............................................................................*/

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
      vr_auxconta          INTEGER := 0;           -- Contador auxiliar para posicão no XML
      vr_rating            crapnrc.indrisco%TYPE;  -- Rating do contrato
      vr_risco_agr         tbrisco_cadastro_conta.cdnivel_risco%TYPE; -- Risco agravado da conta
      vr_risco_atraso      crawepr.dsnivris%TYPE;  -- Risco atraso da operação
			vr_risco_operacao    crawepr.dsnivris%TYPE;  -- Risco da operação
			vr_risco_cpf         crawepr.dsnivris%TYPE;  -- Risco CPF
      vr_risco_final       crawepr.dsnivris%TYPE;  -- Risco final
      vr_risco_ult_central crawepr.dsnivris%TYPE;  -- Risco da última central
      vr_data_risco_final  crapris.dtdrisco%TYPE;  -- Data do risco final
      vr_numero_grupo      VARCHAR2(11);           -- Número do grupo econômico vinculado com a conta
      vr_risco_grupo       crapgrp.dsdrisgp%TYPE;  -- Risco do grupo econômico
      vr_diasatraso        INTEGER;                -- Quantidade de dias em atraso do contrato
      vr_risco_inclusao    crawepr.dsnivris%TYPE;  -- Risco inclusão para contratos de limite de crédito
			vr_valor_arrasto     NUMBER(11);
			vr_index_linha       INTEGER := 1;
			vr_chave_cpfcgc      VARCHAR2(11);           -- Chave para indexação da vr_tab_riscos_cpf

			-- Tabelas temporárias para processamento dos dados de riscos
			vr_tab_dados_risco   typ_tab_riscos;
			vr_tab_riscos_cpf    typ_tab_cpf;
			vr_tab_riscos_ge     typ_tab_ge;

      ---------->> CURSORES <<--------

      -- Contas vinculadas com a conta base
      CURSOR cr_contas(rw_cbase IN crapass%ROWTYPE) IS
      SELECT c.cdcooper
           , c.nrdconta
           , gene0002.fn_mask(c.nrcpfcgc,
				                    DECODE(c.inpessoa, 1, '99999999999','99999999999999')) nrcpfcgc
           , c.inpessoa
           , c.dsnivris
					 , CASE WHEN c.nrdconta = rw_cbase.nrdconta THEN 0 ELSE 1 END ordem
        FROM crapass c
       WHERE c.cdcooper = rw_cbase.cdcooper
         AND DECODE(rw_cbase.inpessoa, 1,
             gene0002.fn_mask(c.nrcpfcgc, '99999999999'),
             substr(gene0002.fn_mask(c.nrcpfcgc, '99999999999999'), 1, 8)) =
             DECODE(rw_cbase.inpessoa, 1,
             gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
             substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
	  UNION
	  SELECT DISTINCT cgr.cdcooper
         , cgr.nrdconta
         , gene0002.fn_mask(cgr.nrcpfcgc,
				                    DECODE(cgr.inpessoa, 1, '99999999999','99999999999999')) nrcpfcgc
         , cgr.inpessoa
         , cgr.dsnivris
         , 1 AS ordem
      FROM crapass cgr
         , crapgrp grp
     WHERE grp.nrdgrupo IN (
               SELECT aux.nrdgrupo
                 FROM crapgrp aux
                WHERE aux.cdcooper = rw_cbase.cdcooper
                  AND DECODE(aux.inpessoa, 1,
                         gene0002.fn_mask(aux.nrcpfcgc, '99999999999'),
                         substr(gene0002.fn_mask(aux.nrcpfcgc, '99999999999999'), 1, 8)) =
                      DECODE(rw_cbase.inpessoa, 1,
                         gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                         substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
           )
       AND grp.cdcooper =  rw_cbase.cdcooper
       AND DECODE(grp.inpessoa, 1,
                  gene0002.fn_mask(grp.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(grp.nrcpfcgc, '99999999999999'), 1, 8)) <>
           DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
       AND DECODE(cgr.inpessoa, 1,
                  gene0002.fn_mask(cgr.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(cgr.nrcpfcgc, '99999999999999'), 1, 8)) <>
           DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
       AND cgr.cdcooper =  grp.cdcooper
       AND (cgr.nrdconta =  grp.nrdconta OR cgr.nrdconta = grp.nrctasoc)
			ORDER BY ordem;
      rw_contas cr_contas%ROWTYPE;

    -- Contratos de empréstimo ativos (ou em prejuízo) de uma conta
    CURSOR cr_contratos_emprestimo(pr_cdcooper NUMBER
		                             , pr_nrdconta NUMBER) IS
    SELECT w.dsnivori
		     , w.dsnivris
         , w.dsnivcal
         , e.nrctremp
      FROM crawepr w
         , crapepr e
      WHERE e.cdcooper = pr_cdcooper
        AND e.nrdconta = pr_nrdconta
        AND (e.inliquid = 0 OR e.vlsdprej > 0) 
        AND w.cdcooper = e.cdcooper
        AND w.nrdconta = e.nrdconta
        AND w.nrctremp = e.nrctremp;
    rw_contratos_emprestimo cr_contratos_emprestimo%ROWTYPE;

    -- Contratos de limite de crédito
    CURSOR cr_contrato_limite_credito(pr_cdcooper NUMBER
		                                , pr_nrdconta NUMBER
																		, pr_dtmvtoan DATE) IS
    SELECT l.nrctrlim
      FROM craplim l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta
       AND l.insitlim = 2
			 AND l.tpctrlim = 1;
    rw_contrato_limite_credito cr_contrato_limite_credito%ROWTYPE;

		-- Busca contratos de limite de desconto (cheques e títulos) --
		CURSOR cr_contratos_limite_desc(pr_cdcooper   NUMBER
		                              , pr_nrdconta   NUMBER
																	, pr_dtmvtoan   DATE
																	, pr_vlrarrasto NUMBER) IS

    SELECT nrctrlim
     , cdorigem
		 , tipcontr
		 , MAX(qtdiaatr) qtdiaatr
    FROM (
      SELECT nrctrlim
           , qtdiaatr
           , cdorigem
           , 'DCH' tipcontr
        FROM crapris r
           , crapbdc b
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtmvtoan
         AND r.inddocto = 1
         AND r.nrdconta = pr_nrdconta
         AND r.cdmodali = 302
         AND r.vldivida > pr_vlrarrasto
         AND b.cdcooper = r.cdcooper
         AND b.nrborder = r.nrctremp
    )
    GROUP BY nrctrlim
		       , cdorigem
					 , tipcontr
		UNION
		SELECT nrctrlim
     , cdorigem
		 , tipcontr
		 , MAX(qtdiaatr) qtdiaatr
    FROM (
      SELECT nrctrlim
           , qtdiaatr
           , cdorigem
           , 'DTI' tipcontr
        FROM crapris r
           , crapbdt b
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtmvtoan
         AND r.inddocto = 1
         AND r.nrdconta = pr_nrdconta
         AND r.cdmodali = 301
         AND r.vldivida > pr_vlrarrasto
         AND b.cdcooper = r.cdcooper
         AND b.nrborder = r.nrctremp
    )
    GROUP BY nrctrlim
		       , cdorigem
					 , tipcontr;
		rw_contratos_limite_desc cr_contratos_limite_desc%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

		-- Parâmetro do arrasto --
    CURSOR cr_tab(pr_cdcooper crawepr.cdcooper%TYPE) IS
    SELECT t.dstextab
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'USUARI'
       AND t.cdempres = 11
       AND t.cdacesso = 'RISCOBACEN'
       AND t.tpregist = 000;
    rw_tab cr_tab%ROWTYPE;

    -- Dados da conta base
    CURSOR cr_base(pr_cdcooper INTEGER
		     , pr_nrdconta INTEGER) IS
    SELECT cb.*
      FROM crapass cb
     WHERE cb.cdcooper = pr_cdcooper
       AND cb.nrdconta = pr_nrdconta;
    rw_cbase cr_base%ROWTYPE;

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

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Contas',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      CLOSE cr_dat;

			-- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
      CLOSE cr_tab;

      vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), ',', '.'));

      -- Busca dados da conta base
      OPEN cr_base(pr_cdcooper, pr_nrdconta);
      FETCH cr_base INTO rw_cbase;
      CLOSE cr_base;

      -- Percorre as contas
      FOR rw_contas
       IN cr_contas(rw_cbase) LOOP
          -- Busca o grupo econômico da conta
          pc_busca_grupo_economico(rw_contas.cdcooper
                                 , rw_contas.nrdconta
                                 , rw_contas.nrcpfcgc
                                 , vr_numero_grupo
                                 , vr_risco_grupo);

					-- Busca o risco agravado para a conta
          vr_risco_agr := fn_busca_risco_agravado(rw_contas.cdcooper
                                                , rw_contas.nrdconta
																								, rw_dat.dtmvtoan);

          -- Percorre os contratos de empréstimo ativos  da conta
          FOR rw_contratos_emprestimo
            IN cr_contratos_emprestimo(rw_contas.cdcooper
                                     , rw_contas.nrdconta) LOOP

								IF fn_busca_valor_divida(rw_contas.cdcooper
                                       , rw_contas.nrdconta
																			 , rw_contratos_emprestimo.nrctremp
																			 , rw_dat.dtmvtoan
																			 , NULL) > vr_valor_arrasto THEN 

										-- Busca o rating do contrato
										vr_rating := fn_busca_rating(rw_contas.cdcooper
																							 , rw_contas.nrdconta
																							 , rw_contratos_emprestimo.nrctremp
																							 , 3);

										-- Busca a quantidade dias em atraso e o risco final do contrato
										vr_diasatraso := fn_busca_dias_atraso_emp(rw_contas.cdcooper
																				                    , rw_contas.nrdconta
																			                    	, rw_contratos_emprestimo.nrctremp
																			                    	, rw_dat.dtmvtoan);

										-- Busca o risco atraso da operação
										vr_risco_atraso := fn_calcula_risco_atraso(vr_diasatraso);

										vr_risco_operacao := greatest(nvl(vr_rating, 'A')
																								, vr_risco_atraso
																								, CASE WHEN rw_contratos_emprestimo.dsnivris <> rw_contratos_emprestimo.dsnivori AND rw_contratos_emprestimo.dsnivris = 'A'
																								       THEN rw_contratos_emprestimo.dsnivris ELSE rw_contratos_emprestimo.dsnivori END
																								, nvl(fn_traduz_risco(vr_risco_agr), 'A'));

										vr_tab_dados_risco(vr_index_linha).nrdconta     := rw_contas.nrdconta;
										vr_tab_dados_risco(vr_index_linha).nrcpfcgc     := rw_contas.nrcpfcgc;
										vr_tab_dados_risco(vr_index_linha).nrctremp     := rw_contratos_emprestimo.nrctremp;
										vr_tab_dados_risco(vr_index_linha).tiplinha     := 'EMP';
										vr_tab_dados_risco(vr_index_linha).ris_inclusao := rw_contratos_emprestimo.dsnivori;
										vr_tab_dados_risco(vr_index_linha).ris_rating   := vr_rating;
										vr_tab_dados_risco(vr_index_linha).ris_atraso   := vr_risco_atraso;
										vr_tab_dados_risco(vr_index_linha).ris_agravado := fn_traduz_risco(vr_risco_agr);
										vr_tab_dados_risco(vr_index_linha).ris_melhora  := rw_contratos_emprestimo.dsnivris;
										vr_tab_dados_risco(vr_index_linha).ris_operacao := vr_risco_operacao;
										vr_tab_dados_risco(vr_index_linha).nrdgrupo     := vr_numero_grupo;

										vr_chave_cpfcgc := CASE WHEN length(rw_contas.nrcpfcgc) > 11 THEN
										                        SUBSTR(rw_contas.nrcpfcgc, 1, 8) ELSE rw_contas.nrcpfcgc END;

									  IF vr_tab_riscos_cpf.exists(vr_chave_cpfcgc) THEN
											IF vr_risco_operacao > vr_tab_riscos_cpf(vr_chave_cpfcgc) THEN
												vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
											END IF;
										ELSE
											vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
										END IF;

										IF vr_numero_grupo IS NOT NULL THEN
											IF vr_tab_riscos_ge.exists(vr_numero_grupo) THEN
												IF vr_tab_riscos_cpf(vr_chave_cpfcgc) > vr_tab_riscos_ge(vr_numero_grupo) THEN
													vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
												END IF;
											ELSE
												vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
											END IF;
										END IF; 										

										vr_index_linha := vr_index_linha + 1;
								END IF;
          END LOOP;

					-- Percorre os contratos de limtie de desconto com risco na central
					FOR rw_contratos_limite_desc
						IN cr_contratos_limite_desc(rw_contas.cdcooper
                                      , rw_contas.nrdconta
																			, rw_dat.dtmvtoan
																			, vr_valor_arrasto) LOOP

					      vr_rating := fn_busca_rating(rw_contas.cdcooper
                                           , rw_contas.nrdconta
																			     , rw_contratos_limite_desc.nrctrlim
																					 , rw_contratos_limite_desc.cdorigem);

								vr_risco_inclusao := 'A';
								vr_risco_atraso := fn_calcula_risco_atraso(rw_contratos_limite_desc.qtdiaatr);

								vr_risco_operacao := greatest(nvl(vr_rating, 'A')
																								, vr_risco_atraso
																								, nvl(fn_traduz_risco(vr_risco_agr), 'A'));

										vr_tab_dados_risco(vr_index_linha).nrdconta     := rw_contas.nrdconta;
										vr_tab_dados_risco(vr_index_linha).nrcpfcgc     := rw_contas.nrcpfcgc;
										vr_tab_dados_risco(vr_index_linha).nrctremp     := rw_contratos_limite_desc.nrctrlim;
										vr_tab_dados_risco(vr_index_linha).tiplinha     := rw_contratos_limite_desc.tipcontr;
										vr_tab_dados_risco(vr_index_linha).ris_inclusao := 'A';
										vr_tab_dados_risco(vr_index_linha).ris_rating   := vr_rating;
										vr_tab_dados_risco(vr_index_linha).ris_atraso   := vr_risco_atraso;
										vr_tab_dados_risco(vr_index_linha).ris_agravado := fn_traduz_risco(vr_risco_agr);
										vr_tab_dados_risco(vr_index_linha).ris_melhora  := NULL;
										vr_tab_dados_risco(vr_index_linha).ris_operacao := vr_risco_operacao;
										vr_tab_dados_risco(vr_index_linha).nrdgrupo     := vr_numero_grupo;

										vr_chave_cpfcgc := CASE WHEN length(rw_contas.nrcpfcgc) > 11 THEN
										                        SUBSTR(rw_contas.nrcpfcgc, 1, 8) ELSE rw_contas.nrcpfcgc END;

									  IF vr_tab_riscos_cpf.exists(vr_chave_cpfcgc) THEN
											IF vr_risco_operacao > vr_tab_riscos_cpf(vr_chave_cpfcgc) THEN
												vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
											END IF;
										ELSE
											vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
										END IF;

										IF vr_numero_grupo IS NOT NULL THEN
											IF vr_tab_riscos_ge.exists(vr_numero_grupo) THEN
												IF vr_tab_riscos_cpf(vr_chave_cpfcgc) > vr_tab_riscos_ge(vr_numero_grupo) THEN
													vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
												END IF;
											ELSE
												vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
											END IF;
										END IF;
										
							 vr_index_linha := vr_index_linha + 1;
					END LOOP;


					-- Processa o contrato de limite de crédito (se a conta possuir) --
					OPEN cr_contrato_limite_credito(rw_contas.cdcooper
                                        , rw_contas.nrdconta
																				, rw_dat.dtmvtoan);

					FETCH cr_contrato_limite_credito INTO rw_contrato_limite_credito;

					IF cr_contrato_limite_credito%FOUND THEN
						    vr_rating := fn_busca_rating(rw_contas.cdcooper
                                           , rw_contas.nrdconta
																			     , rw_contrato_limite_credito.nrctrlim
																					 , 1);

								vr_risco_inclusao := 'A';

							  vr_risco_atraso := 'A';

								vr_risco_operacao := greatest(nvl(vr_rating, 'A')
																								, vr_risco_atraso
																								, nvl(fn_traduz_risco(vr_risco_agr), 'A'));

										vr_tab_dados_risco(vr_index_linha).nrdconta     := rw_contas.nrdconta;
										vr_tab_dados_risco(vr_index_linha).nrcpfcgc     := rw_contas.nrcpfcgc;
										vr_tab_dados_risco(vr_index_linha).nrctremp     := rw_contrato_limite_credito.nrctrlim;
										vr_tab_dados_risco(vr_index_linha).tiplinha     := 'LIM';
										vr_tab_dados_risco(vr_index_linha).ris_inclusao := 'A';
										vr_tab_dados_risco(vr_index_linha).ris_rating   := vr_rating;
										vr_tab_dados_risco(vr_index_linha).ris_atraso   := vr_risco_atraso;
										vr_tab_dados_risco(vr_index_linha).ris_agravado := fn_traduz_risco(vr_risco_agr);
										vr_tab_dados_risco(vr_index_linha).ris_melhora  := NULL;
										vr_tab_dados_risco(vr_index_linha).ris_operacao := vr_risco_operacao;
										vr_tab_dados_risco(vr_index_linha).nrdgrupo     := vr_numero_grupo;

										-- Se deve arrastar o risco da operação
										IF fn_busca_valor_divida(rw_contas.cdcooper
                                           , rw_contas.nrdconta
																			     , rw_contrato_limite_credito.nrctrlim
																			     , rw_dat.dtmvtoan
																					 , NULL) > vr_valor_arrasto
										 OR fn_busca_valor_divida(rw_contas.cdcooper
                                            , rw_contas.nrdconta
																			      , rw_contas.nrdconta
																			      , rw_dat.dtmvtoan
																						, 101) > vr_valor_arrasto
										 OR vr_rating IS NOT NULL THEN

										     vr_chave_cpfcgc := CASE WHEN length(rw_contas.nrcpfcgc) > 11 THEN
										                        SUBSTR(rw_contas.nrcpfcgc, 1, 8) ELSE rw_contas.nrcpfcgc END;

									       IF vr_tab_riscos_cpf.exists(vr_chave_cpfcgc) THEN
											     IF vr_risco_operacao > vr_tab_riscos_cpf(vr_chave_cpfcgc) THEN
												     vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
											     END IF;
										     ELSE
											     vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
										     END IF; 
												 
												 IF vr_numero_grupo IS NOT NULL THEN
														IF vr_tab_riscos_ge.exists(vr_numero_grupo) THEN
															IF vr_tab_riscos_cpf(vr_chave_cpfcgc) > vr_tab_riscos_ge(vr_numero_grupo) THEN
																vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
															END IF;
														ELSE
															vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
														END IF;
												 END IF;
										END IF; 

							 vr_index_linha := vr_index_linha + 1;
					ELSE
						   vr_rating := NULL;
					     vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas.cdcooper
							                                         , rw_contas.nrdconta
																											 , rw_dat.dtmvtoan);

							 vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);

							 vr_risco_operacao := greatest(nvl(vr_rating, 'A')
																								, vr_risco_atraso
																								, nvl(fn_traduz_risco(vr_risco_agr), 'A'));

										vr_tab_dados_risco(vr_index_linha).nrdconta      := rw_contas.nrdconta;
										vr_tab_dados_risco(vr_index_linha).nrcpfcgc      := rw_contas.nrcpfcgc;
										vr_tab_dados_risco(vr_index_linha).nrctremp      := NULL;
										vr_tab_dados_risco(vr_index_linha).tiplinha      := 'CTA';
										vr_tab_dados_risco(vr_index_linha).ris_inclusao  := 'A';
										vr_tab_dados_risco(vr_index_linha).ris_rating    := vr_rating;
										vr_tab_dados_risco(vr_index_linha).ris_atraso    := vr_risco_atraso;
										vr_tab_dados_risco(vr_index_linha).ris_agravado  := fn_traduz_risco(vr_risco_agr);
										vr_tab_dados_risco(vr_index_linha).ris_melhora   := NULL;
										vr_tab_dados_risco(vr_index_linha).ris_operacao  := vr_risco_operacao;
										vr_tab_dados_risco(vr_index_linha).nrdgrupo  := vr_numero_grupo;
										
										IF fn_busca_valor_divida(rw_contas.cdcooper
                                           , rw_contas.nrdconta
																			     , rw_contas.nrdconta
																			     , rw_dat.dtmvtoan
																					 , 101) > vr_valor_arrasto THEN

												vr_chave_cpfcgc := CASE WHEN length(rw_contas.nrcpfcgc) > 11 THEN
																								SUBSTR(rw_contas.nrcpfcgc, 1, 8) ELSE rw_contas.nrcpfcgc END;

												IF vr_tab_riscos_cpf.exists(vr_chave_cpfcgc) THEN
													IF vr_risco_operacao > vr_tab_riscos_cpf(vr_chave_cpfcgc) THEN
														vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
													END IF;
												ELSE
													vr_tab_riscos_cpf(vr_chave_cpfcgc) := vr_risco_operacao;
												END IF;

												IF vr_numero_grupo IS NOT NULL THEN
													IF vr_tab_riscos_ge.exists(vr_numero_grupo) THEN
														IF vr_tab_riscos_cpf(vr_chave_cpfcgc) > vr_tab_riscos_ge(vr_numero_grupo) THEN
															vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
														END IF;
													ELSE
														vr_tab_riscos_ge(vr_numero_grupo) := vr_tab_riscos_cpf(vr_chave_cpfcgc);
													END IF;
												END IF;
										END IF;

								vr_index_linha := vr_index_linha + 1;
					END IF;

					CLOSE cr_contrato_limite_credito;
      END LOOP;

			vr_auxconta := 0;

			-- Percorre tabela temporária de contas e monta XML de retorno
			vr_index_linha := vr_tab_dados_risco.first;
			WHILE vr_index_linha IS NOT NULL
      LOOP
						vr_chave_cpfcgc := CASE WHEN length(vr_tab_dados_risco(vr_index_linha).nrcpfcgc) > 11
						                        THEN SUBSTR(vr_tab_dados_risco(vr_index_linha).nrcpfcgc, 1, 8)
																		ELSE vr_tab_dados_risco(vr_index_linha).nrcpfcgc END;

						IF vr_tab_riscos_cpf.exists(vr_chave_cpfcgc) THEN
						     vr_risco_cpf := vr_tab_riscos_cpf(vr_chave_cpfcgc);
						ELSE
							   vr_risco_cpf := 'A';
						END IF;

						IF vr_tab_dados_risco(vr_index_linha).nrdgrupo IS NOT NULL THEN
							 IF vr_tab_riscos_ge.exists(vr_tab_dados_risco(vr_index_linha).nrdgrupo) THEN
						       vr_risco_grupo := vr_tab_riscos_ge(vr_tab_dados_risco(vr_index_linha).nrdgrupo);
							 ELSE
								   vr_risco_grupo := vr_risco_cpf;
							 END IF;
						ELSE
						   vr_risco_grupo := NULL;
						END IF;

						vr_risco_final := greatest(vr_risco_cpf, nvl(vr_risco_grupo, 'A'));

            pc_monta_reg_conta_xml(pr_retxml
                                 , vr_auxconta
                                 , vr_dscritic
                                 , vr_tab_dados_risco(vr_index_linha).nrdconta
                                 , vr_tab_dados_risco(vr_index_linha).nrcpfcgc
                                 , vr_tab_dados_risco(vr_index_linha).nrctremp
                                 , vr_tab_dados_risco(vr_index_linha).ris_inclusao
                                 , vr_risco_grupo
                                 , vr_tab_dados_risco(vr_index_linha).ris_rating
                                 , vr_tab_dados_risco(vr_index_linha).ris_atraso
                                 , vr_tab_dados_risco(vr_index_linha).ris_agravado
                                 , vr_tab_dados_risco(vr_index_linha).ris_operacao
                                 , vr_risco_cpf
                                 , vr_tab_dados_risco(vr_index_linha).nrdgrupo
																 , vr_tab_dados_risco(vr_index_linha).ris_melhora
																 , vr_risco_final
																 , vr_tab_dados_risco(vr_index_linha).tiplinha);

			      vr_auxconta := vr_auxconta + 1;
            vr_index_linha := vr_tab_dados_risco.NEXT(vr_index_linha);
      END LOOP;
			
      -- Busca o risco da última central de riscos (último fechamento)
      vr_risco_ult_central := fn_busca_risco_ult_mensal(pr_cdcooper
                                                      , pr_nrdconta
                                                      , rw_dat.dtultdma
																											, vr_valor_arrasto);
			vr_data_risco_final := fn_busca_data_risco(pr_cdcooper
                                               , pr_nrdconta
                                               , rw_dat.dtmvtoan
																							 , vr_valor_arrasto);

      -- Adiciona registro com dados da central de riscos no XML de retorno
      pc_monta_reg_central_risco(pr_retxml
                            , vr_dscritic
                            , fn_traduz_risco(vr_risco_ult_central)
                            , TO_CHAR(vr_data_risco_final, 'DD/MM/YYYY')
                            , CASE WHEN vr_data_risco_final IS NOT NULL THEN TO_CHAR(rw_dat.dtmvtolt-vr_data_risco_final) ELSE '' END
														, rw_cbase.inrisctl
														, rw_cbase.dtrisctl);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;

      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_dscritic := vr_dscritic;

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
  END pc_busca_dados_risco;

	 /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK

  BEGIN

    /* .............................................................................

    Programa: pc_busca_ctr_acordos
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem de contratos de acordos e riscos(Daniel AMcom).

    Alteracoes:
    ..............................................................................*/

    DECLARE
      -- >>> CURSORES <<< --

      -- Consulta de contratos de acordos ativos
      CURSOR cr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                      ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                      ,pr_cdsituacao tbrecup_acordo.cdsituacao%TYPE) IS
        SELECT tbrecup_acordo.cdcooper AS cdcooper
              ,tbrecup_acordo_contrato.nracordo AS nracordo
              ,tbrecup_acordo.nrdconta AS nrdconta
              ,tbrecup_acordo_contrato.nrctremp AS nrctremp
              ,DECODE(tbrecup_acordo_contrato.cdorigem,1,'Estouro de Conta',2,'Empréstimo',3,'Empréstimo','Inexistente') AS dsorigem
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo.cdsituacao = pr_cdsituacao;

      rw_acordo cr_acordo%ROWTYPE;

      -- Variavel de criticas
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
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'acordos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_acordo IN cr_acordo(pr_cdcooper   => vr_cdcooper
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_cdsituacao => 1) LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordos', pr_posicao => 0, pr_tag_nova => 'acordo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nracordo', pr_tag_cont => TO_CHAR(rw_acordo.nracordo), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'dsorigem', pr_tag_cont => TO_CHAR(rw_acordo.dsorigem), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => GENE0002.fn_mask_contrato(rw_acordo.nrctremp), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_ctr_acordos;

END TELA_ATENDA_OCORRENCIAS;
/
