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
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Ocorrencias
  --
  -- Alterado: 23/01/2018 - Daniel AMcom
  -- Ajuste: Criada procedure pc_busca_dados_risco
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
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  -- Alterado: 23/01/2018 - Reginaldo (AMcom)
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  FUNCTION fn_busca_rating(pr_cdcooper NUMBER
		                     , pr_nrdconta NUMBER
												 , pr_nrctremp NUMBER
												 , pr_cdorigem NUMBER)
    RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;
      --- >>> CURSORES <<< ---
      CURSOR cr_rating(pr_cdcooper NUMBER, pr_nrdconta NUMBER) IS
      SELECT rat.indrisco
         FROM crapnrc rat
        WHERE rat.cdcooper = pr_cdcooper
          AND rat.nrdconta = pr_nrdconta
          AND rat.nrctrrat = pr_nrctremp
			    AND rat.tpctrrat = DECODE(pr_cdorigem
					                         , 1, 1
																	 , 2, 2
																	 , 3, 90
																	 , 4, 3
																	 , 5, 3)
          AND rat.insitrat = 2;
      rw_rating cr_rating%ROWTYPE;
  BEGIN
     OPEN cr_rating(pr_cdcooper, pr_nrdconta);
     FETCH cr_rating INTO rw_rating;

     vr_rating := rw_rating.indrisco;

     CLOSE cr_rating;

     RETURN vr_rating;
  END fn_busca_rating;

	FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER, pr_nrdconta NUMBER)
    RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE AS vr_risco_agr tbrisco_cadastro_conta.cdnivel_risco%TYPE;
      --- >>> CURSORES <<< ---
      CURSOR cr_agravado(pr_cdcooper NUMBER, pr_nrdconta NUMBER) IS
      SELECT agr.cdnivel_risco
        FROM tbrisco_cadastro_conta agr
       WHERE agr.cdcooper = pr_cdcooper
         AND agr.nrdconta = pr_nrdconta;
      rw_agravado cr_agravado%ROWTYPE;
  BEGIN
    OPEN cr_agravado(pr_cdcooper, pr_nrdconta);

    FETCH cr_agravado INTO rw_agravado;

    vr_risco_agr := rw_agravado.cdnivel_risco;

    CLOSE cr_agravado;

    RETURN vr_risco_agr;
  END fn_busca_risco_agravado;

	FUNCTION fn_busca_valor_divida(pr_cdcooper NUMBER
                               , pr_nrdconta NUMBER
															 , pr_nrctremp NUMBER
                               , pr_dtmvtoan DATE)
		RETURN NUMBER AS vr_valor_divida NUMBER;

		 CURSOR cr_valor_divida(pr_cdcooper NUMBER
                          , pr_nrdconta NUMBER
													, pr_nrctremp NUMBER
                          , pr_dtmvtoan DATE) IS
     SELECT r.vldivida
       FROM crapris r
      WHERE r.cdcooper = pr_cdcooper
        AND r.nrdconta = pr_nrdconta
				AND r.nrctremp = pr_nrctremp
        AND r.dtrefere = pr_dtmvtoan
        AND r.inddocto = 1;
		 rw_valor_divida cr_valor_divida%ROWTYPE;
	BEGIN
		 OPEN cr_valor_divida(pr_cdcooper
		                    , pr_nrdconta
												, pr_nrctremp
												, pr_dtmvtoan);

		 FETCH cr_valor_divida INTO rw_valor_divida;

		 CLOSE cr_valor_divida;

		 vr_valor_divida := rw_valor_divida.vldivida;

		 RETURN vr_valor_divida;
	END fn_busca_valor_divida;

	FUNCTION fn_busca_data_risco(pr_cdcooper NUMBER
                             , pr_nrdconta NUMBER
                             , pr_dtmvtoan DATE)
		RETURN crapris.dtdrisco%TYPE AS vr_data_risco crapris.dtdrisco%TYPE;
		 -- Cursor para recuperar a data de risco --
	   CURSOR cr_data_risco(pr_cdcooper NUMBER
                         , pr_nrdconta NUMBER
                         , pr_dtmvtoan DATE) IS
     SELECT r.dtdrisco
		      , r.nrctremp
       FROM crapris r
      WHERE r.cdcooper = pr_cdcooper
        AND r.nrdconta = pr_nrdconta
        AND r.dtrefere = pr_dtmvtoan
        AND r.inddocto = 1
       ORDER BY r.innivris DESC
			     , r.dtdrisco ASC;
     rw_data_risco cr_data_risco%ROWTYPE;
		 -- Cursor para recuperar a data de efetivação do contrato de empréstimo --
		 CURSOR cr_data_emprestimo(pr_cdcooper NUMBER
		                         , pr_nrdconta NUMBER
														 , pr_nrctremp NUMBER) IS
		 SELECT e.dtmvtolt
		   FROM crapepr e
			WHERE e.cdcooper = pr_cdcooper
			  AND e.nrdconta = pr_nrdconta
				AND e.nrctremp = pr_nrctremp;
		 rw_data_emprestimo cr_data_emprestimo%ROWTYPE;
	BEGIN
	   OPEN cr_data_risco(pr_cdcooper, pr_nrdconta, pr_dtmvtoan);

		 FETCH cr_data_risco INTO rw_data_risco;
		 
		 CLOSE cr_data_risco;
		 
		 vr_data_risco := rw_data_risco.dtdrisco;

		 RETURN vr_data_risco;
	END fn_busca_data_risco;

	FUNCTION fn_busca_dias_atraso_adp(pr_cdcooper NUMBER
                                  , pr_nrdconta NUMBER
                                  , pr_dtmvtoan DATE)
		RETURN INTEGER AS vr_qtd_dias_atraso INTEGER;
		  -- Busca os dias de atraso do ADP --
		  CURSOR cr_adp(pr_cdcooper NUMBER
                  , pr_nrdconta NUMBER
                  , pr_dtmvtoan DATE) IS
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
	  OPEN cr_adp(pr_cdcooper, pr_nrdconta, pr_dtmvtoan);

		FETCH cr_adp INTO rw_adp;

		IF cr_adp%NOTFOUND THEN
			 vr_qtd_dias_atraso := NULL;
		ELSE
		   vr_qtd_dias_atraso := rw_adp.qtdiaatr;
		END IF;

		CLOSE cr_adp;

		RETURN vr_qtd_dias_atraso;
	END fn_busca_dias_atraso_adp;

	FUNCTION fn_busca_dias_atraso_lc(pr_cdcooper NUMBER
                                 , pr_nrdconta NUMBER
																 , pr_nrctrlim NUMBER
                                 , pr_dtmvtoan DATE)
		RETURN INTEGER AS vr_qtd_dias_atraso INTEGER;
		  -- Busca os dias de atraso do contrato (modalidade 201) --
		  CURSOR cr_atraso_lc(pr_cdcooper NUMBER
                        , pr_nrdconta NUMBER
												, pr_nrctrlim NUMBER
                        , pr_dtmvtoan DATE) IS
	    SELECT r.qtdiaatr
			  FROM crapris r
			 WHERE r.cdcooper = pr_cdcooper
			   AND r.nrdconta = pr_nrdconta
				 AND r.nrctremp = pr_nrctrlim
				 AND r.cdmodali = 201
				 AND r.inddocto = 1
				 AND r.dtrefere = pr_dtmvtoan;
			rw_atraso_lc cr_atraso_lc%ROWTYPE;
	BEGIN
		vr_qtd_dias_atraso := fn_busca_dias_atraso_adp(pr_cdcooper
		                                             , pr_nrdconta
																								 , pr_dtmvtoan);

		IF vr_qtd_dias_atraso IS NULL THEN
		   	OPEN cr_atraso_lc(pr_cdcooper
                        , pr_nrdconta
												, pr_nrctrlim
                        , pr_dtmvtoan );

				FETCH cr_atraso_lc INTO rw_atraso_lc;

				IF cr_atraso_lc%NOTFOUND THEN
					 vr_qtd_dias_atraso := 0;
				ELSE
					 vr_qtd_dias_atraso := rw_atraso_lc.qtdiaatr;
				END IF;

				CLOSE cr_atraso_lc;
		END IF;

		RETURN vr_qtd_dias_atraso;
	END fn_busca_dias_atraso_lc;
	
	FUNCTION fn_verifica_atraso_conta(pr_cdcooper   crawepr.cdcooper%TYPE
                                  , pr_nrdconta   crawepr.nrdconta%TYPE
                                  , pr_dtmvtoan   crapdat.dtmvtoan%TYPE
																	, pr_vlrarrasto NUMBER) 
    RETURN BOOLEAN AS vr_tem_atraso BOOLEAN;
		
		 -- >>> CURSORES <<< --
		 CURSOR cr_atraso(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_dtmvtoan DATE) IS
		 SELECT r1.qtdiaatr
		   FROM crapris r1
			WHERE r1.cdcooper = pr_cdcooper
			  AND r1.nrdconta = pr_nrdconta
				AND r1.nrctremp = pr_nrdconta
				AND r1.inddocto = 1
				AND r1.cdmodali = 101
				AND r1.dtrefere = pr_dtmvtoan
				AND r1.vldivida > pr_vlrarrasto
				AND NOT EXISTS (
				    SELECT 1
						  FROM crapris r2
						 WHERE r2.cdcooper = pr_cdcooper
						   AND r2.nrdconta = pr_nrdconta
							 AND r2.inddocto = 1
							 AND r2.cdmodali = 201
							 AND r2.dtrefere = pr_dtmvtoan	
				);
		 rw_atraso cr_atraso%ROWTYPE;
  BEGIN
	   OPEN cr_atraso(pr_cdcooper, pr_nrdconta, pr_dtmvtoan);
		 
		 FETCH cr_atraso INTO rw_atraso;
		 
		 IF cr_atraso%NOTFOUND OR rw_atraso.qtdiaatr = 0 THEN 
			 vr_tem_atraso := FALSE;
		 ELSE	 
			 vr_tem_atraso := TRUE; 
		 END IF;
		 
		 CLOSE cr_atraso;
		 
		 RETURN vr_tem_atraso;
	END fn_verifica_atraso_conta;

	FUNCTION fn_busca_risco_ult_central(pr_cdcooper    crawepr.cdcooper%TYPE
                                    , pr_nrdconta   crawepr.nrdconta%TYPE
                                    , pr_dtultdma   crapdat.dtultdma%TYPE
																		, pr_vlrarrasto NUMBER)
		RETURN crawepr.dsnivris%TYPE AS vr_risco_ult_central crawepr.dsnivris%TYPE;

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
         vr_risco_ult_central := 2;
      ELSE
         vr_risco_ult_central := rw_riscos.innivris;
      END IF;

      RETURN vr_risco_ult_central;
  END fn_busca_risco_ult_central;

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
                            WHEN qtdiaatr <=  15  THEN 'A'
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

  PROCEDURE pc_busca_dados_diaria(pr_cdcooper    IN NUMBER
                                , pr_nrdconta    IN NUMBER
                                , pr_nrctremp    IN NUMBER
                                , pr_dtmvtoan    IN DATE
												    		, vr_dias_atraso OUT NUMBER
													    	, vr_risco_final OUT NUMBER) IS

      --- >>> CURSORES <<< ---
      CURSOR cr_riscos(pr_cdcooper NUMBER
                     , pr_nrdconta NUMBER
                     , pr_nrctremp NUMBER
                     , pr_dtmvtoan DATE) IS
      SELECT ris.qtdiaatr
			     , ris.innivris
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = pr_dtmvtoan
         AND ris.inddocto = 1
				 AND ris.cdorigem = 3;
      rw_riscos cr_riscos%ROWTYPE;
  BEGIN
     OPEN cr_riscos(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_dtmvtoan);

     FETCH cr_riscos INTO rw_riscos;

     CLOSE cr_riscos;

     vr_dias_atraso   := rw_riscos.qtdiaatr;
		 vr_risco_final   := rw_riscos.innivris;
  END pc_busca_dados_diaria;

  PROCEDURE pc_busca_grupo_economico(pr_cdcooper     IN NUMBER
                                   , pr_nrdconta     IN NUMBER
                                   , pr_nrcpfcgc     IN NUMBER
                                   , vr_numero_grupo OUT NUMBER
                                   , vr_risco_grupo  OUT VARCHAR2) IS
      --- >>> CURSORES <<< ---
      CURSOR cr_grupo(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_nrcpfcgc NUMBER) IS
      SELECT g.nrdgrupo
           , g.dsdrisgp
        FROM crapgrp g
       WHERE g.cdcooper(+) = pr_cdcooper
         AND g.nrctasoc(+) = pr_nrdconta
         AND g.nrdconta(+) = pr_nrdconta
         AND g.nrcpfcgc(+) = pr_nrcpfcgc;
      rw_grupo cr_grupo%ROWTYPE;
  BEGIN
    OPEN cr_grupo(pr_cdcooper, pr_nrdconta, pr_nrcpfcgc);

    FETCH cr_grupo INTO rw_grupo;

    CLOSE cr_grupo;

    vr_numero_grupo := rw_grupo.nrdgrupo;
    vr_risco_grupo  := rw_grupo.dsdrisgp;
  END pc_busca_grupo_economico;

  PROCEDURE pc_monta_reg_conta_xml(pr_retxml     IN OUT NOCOPY XMLType
                               ,pr_pos_conta     IN INTEGER
                               ,pr_dscritic      IN OUT VARCHAR2
                               ,pr_num_conta     IN crapass.nrdconta%TYPE
                               ,pr_cpf_cnpj      IN crapass.nrcpfcgc%TYPE
                               ,pr_num_contrato  IN crawepr.nrctremp%TYPE
                               ,pr_ris_inclusao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_grupo     IN crawepr.dsnivris%TYPE
                               ,pr_rating        IN crawepr.dsnivris%TYPE
                               ,pr_ris_atraso    IN crawepr.dsnivris%TYPE
                               ,pr_ris_agravado  IN crawepr.dsnivris%TYPE
                               ,pr_ris_operacao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_cpf       IN crawepr.dsnivris%TYPE
                               ,pr_numero_grupo  IN crapgrp.nrdgrupo%TYPE
															 ,pr_ris_melhora   IN crawepr.dsnivris%TYPE
															 ,pr_ris_final     IN crawepr.dsnivris%TYPE
															 ,pr_tipo_registro IN VARCHAR2
															 ,pr_arrastaoperac IN VARCHAR2) IS
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
														 
					gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'arrasta_operacao',
                             pr_tag_cont => pr_arrastaoperac,
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
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar dados de risco a partir de uma conta base
        Observacao: -----
        Alteracoes:
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
			vr_risco_cpf         crawepr.dsnivris%TYPE;  -- Risco CPF
      vr_risco_final       crapris.innivris%TYPE;  -- Risco final
      vr_risco_ult_central crawepr.dsnivris%TYPE;  -- Risco da última central
      vr_data_risco_final  crapris.dtdrisco%TYPE;  -- Data do risco final
      vr_numero_grupo      crapgrp.nrdgrupo%TYPE;  -- Número do grupo econômico vinculado com a conta
      vr_risco_grupo       crapgrp.dsdrisgp%TYPE;  -- Risco do grupo econômico
      vr_qtd_dias_risco    INTEGER;                -- Quantidade de dias que o contrato está no risco
      vr_diasatraso        INTEGER;                -- Quantidade de dias em atraso do contrato
      vr_contratos_ativos  INTEGER;                -- Quantidade de contratos ativos da conta
      vr_risco_inclusao    crawepr.dsnivris%TYPE;  -- Risco inclusão para contratos de limite de crédito
			vr_valor_arrasto     NUMBER;

      ---------->> CURSORES <<--------
      -- Contas de mesmo titular da conta base
      CURSOR cr_contas_do_titular(rw_cbase IN crapass%ROWTYPE) IS
      SELECT c.cdcooper
           , c.nrdconta
           , c.nrcpfcgc
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
			 ORDER BY ordem;
      rw_contas_do_titular cr_contas_do_titular%ROWTYPE;

    -- Contratos de empréstimo ativos de uma conta
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
        AND e.inliquid = 0
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
         AND r.vldivida > 100
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
         AND r.vldivida > 100
         AND b.cdcooper = r.cdcooper
         AND b.nrborder = r.nrctremp
    )
    GROUP BY nrctrlim
		       , cdorigem
					 , tipcontr;
		rw_contratos_limite_desc cr_contratos_limite_desc%ROWTYPE;

    -- Contas dos grupos econômicos aos quais o titular da conta base está ligado
    CURSOR cr_contas_grupo_economico(rw_cbase IN crapass%ROWTYPE) IS
    SELECT DISTINCT cgr.cdcooper
         , cgr.nrdconta
         , cgr.nrcpfcgc
         , cgr.inpessoa
         , cgr.dsnivris
         , grp.nrdgrupo
         , grp.dsdrisgp
      FROM crapass cgr
         , crapgrp grp
     WHERE grp.nrdgrupo IN (
               SELECT aux.nrdgrupo
                 FROM crapgrp aux
                WHERE aux.cdcooper = rw_cbase.cdcooper
                  AND DECODE(rw_cbase.inpessoa, 1,
                         gene0002.fn_mask(aux.nrcpfcgc, '99999999999'),
                         substr(gene0002.fn_mask(aux.nrcpfcgc, '99999999999999'), 1, 8)) =
                      DECODE(rw_cbase.inpessoa, 1,
                         gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                         substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
           )
       AND grp.cdcooper =  rw_cbase.cdcooper
       AND DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(grp.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(grp.nrcpfcgc, '99999999999999'), 1, 8)) <>
           DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
       AND DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(cgr.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(cgr.nrcpfcgc, '99999999999999'), 1, 8)) <>
           DECODE(rw_cbase.inpessoa, 1,
                  gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999'),
                  substr(gene0002.fn_mask(rw_cbase.nrcpfcgc, '99999999999999'), 1, 8))
       AND cgr.cdcooper =  grp.cdcooper
       AND cgr.nrdconta =  grp.nrdconta;
    rw_contas_grupo_economico cr_contas_grupo_economico%ROWTYPE;

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
    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
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

      -- Percorre contas de mesmo CPF/CNPJ da conta base
      FOR rw_contas_do_titular
       IN cr_contas_do_titular(rw_cbase) LOOP
          -- Busca o grupo econômico da conta
          pc_busca_grupo_economico(rw_contas_do_titular.cdcooper
                                 , rw_contas_do_titular.nrdconta
                                 , rw_contas_do_titular.nrcpfcgc
                                 , vr_numero_grupo
                                 , vr_risco_grupo);

					-- Busca o risco agravado para a conta
          vr_risco_agr := fn_busca_risco_agravado(rw_contas_do_titular.cdcooper
                                                , rw_contas_do_titular.nrdconta);

          vr_contratos_ativos := 0;

          -- Percorre os contratos de empréstimo ativos  da conta
          FOR rw_contratos_emprestimo
            IN cr_contratos_emprestimo(rw_contas_do_titular.cdcooper
                                     , rw_contas_do_titular.nrdconta) LOOP

								IF fn_busca_valor_divida(rw_contas_do_titular.cdcooper
                                       , rw_contas_do_titular.nrdconta
																			 , rw_contratos_emprestimo.nrctremp
																			 , rw_dat.dtmvtoan) > vr_valor_arrasto THEN

										-- Busca o rating do contrato
										vr_rating := fn_busca_rating(rw_contas_do_titular.cdcooper
																							 , rw_contas_do_titular.nrdconta
																							 , rw_contratos_emprestimo.nrctremp
																							 , 3);

										-- Busca a quantidade dias em atraso e o risco final do contrato
										pc_busca_dados_diaria(rw_contas_do_titular.cdcooper
																				 , rw_contas_do_titular.nrdconta
																				 , rw_contratos_emprestimo.nrctremp
																				 , rw_dat.dtmvtoan
																				 , vr_diasatraso
																				 , vr_risco_final);

										-- Busca o risco atraso da operação
										vr_risco_atraso := fn_calcula_risco_atraso(vr_diasatraso);

										-- Adiciona registro para a conta/contrato no XML de retorno
										pc_monta_reg_conta_xml(pr_retxml
																				 , vr_auxconta
																				 , vr_dscritic
																				 , rw_contas_do_titular.nrdconta
																				 , rw_contas_do_titular.nrcpfcgc
																				 , rw_contratos_emprestimo.nrctremp
																				 , rw_contratos_emprestimo.dsnivori
																				 , vr_risco_grupo
																				 , vr_rating
																				 , vr_risco_atraso
																				 , fn_traduz_risco(vr_risco_agr)
																				 , greatest(nvl(vr_rating, 'A')
																									, vr_risco_atraso
																									, CASE WHEN rw_contratos_emprestimo.dsnivris <> rw_contratos_emprestimo.dsnivori AND rw_contratos_emprestimo.dsnivris = 'A'
																											THEN rw_contratos_emprestimo.dsnivris ELSE rw_contratos_emprestimo.dsnivori END
																									, nvl(fn_traduz_risco(vr_risco_agr), 'A'))   -- rw_contratos_emprestimo.dsnivcal
																				 , rw_contas_do_titular.dsnivris
																				 , vr_numero_grupo
																				 , rw_contratos_emprestimo.dsnivris
																				 , fn_traduz_risco(vr_risco_final)
																				 , 'EMP'
																				 , 'S');

										vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
										vr_contratos_ativos := vr_contratos_ativos + 1;
								END IF;
          END LOOP;

					-- Percorre os contratos de limtie de desconto com risco na central
					FOR rw_contratos_limite_desc
						IN cr_contratos_limite_desc(rw_contas_do_titular.cdcooper
                                      , rw_contas_do_titular.nrdconta
																			, rw_dat.dtmvtoan
																			, vr_valor_arrasto) LOOP

					      vr_rating := fn_busca_rating(rw_contas_do_titular.cdcooper
                                           , rw_contas_do_titular.nrdconta
																			     , rw_contratos_limite_desc.nrctrlim
																					 , rw_contratos_limite_desc.cdorigem);


								vr_risco_inclusao := 'A';
								vr_risco_atraso := fn_calcula_risco_atraso(rw_contratos_limite_desc.qtdiaatr);

								-- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_do_titular.nrdconta
                                     , rw_contas_do_titular.nrcpfcgc
                                     , rw_contratos_limite_desc.nrctrlim
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , vr_rating
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(nvl(vr_rating, 'A')
																							, vr_risco_inclusao
																							, vr_risco_atraso
																							, nvl(fn_traduz_risco(vr_risco_agr), 'A'))   -- rw_contratos_emprestimo.dsnivcal
                                     , rw_contas_do_titular.dsnivris
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , rw_contratos_limite_desc.tipcontr
																		 , 'S');

					     vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
						   vr_contratos_ativos := vr_contratos_ativos + 1;
					END LOOP;

					-- Processa o contrato de limite de crédito (se a conta possuir) --
					OPEN cr_contrato_limite_credito(rw_contas_do_titular.cdcooper
                                        , rw_contas_do_titular.nrdconta
																				, rw_dat.dtmvtoan);

					FETCH cr_contrato_limite_credito INTO rw_contrato_limite_credito;

					IF cr_contrato_limite_credito%FOUND THEN
						    vr_rating := fn_busca_rating(rw_contas_do_titular.cdcooper
                                           , rw_contas_do_titular.nrdconta
																			     , rw_contrato_limite_credito.nrctrlim
																					 , 1);

						    --vr_risco_inclusao := fn_traduz_risco(rw_contrato_limite_credito.innivris);
								vr_risco_inclusao := 'A';

								vr_diasatraso := fn_busca_dias_atraso_lc(rw_contas_do_titular.cdcooper
                                                       , rw_contas_do_titular.nrdconta
																			                 , rw_contrato_limite_credito.nrctrlim
																			                 , rw_dat.dtmvtoan);

							  vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);

					      -- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_do_titular.nrdconta
                                     , rw_contas_do_titular.nrcpfcgc
                                     , rw_contrato_limite_credito.nrctrlim
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , vr_rating
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(nvl(vr_rating, 'A')
																							, vr_risco_inclusao
																							, vr_risco_atraso
																							, nvl(fn_traduz_risco(vr_risco_agr), 'A'))   -- rw_contratos_emprestimo.dsnivcal
                                     , rw_contas_do_titular.dsnivris
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , 'LIM'
																		 , CASE WHEN fn_busca_valor_divida(rw_contas_do_titular.cdcooper
                                                                     , rw_contas_do_titular.nrdconta
																			                               , rw_contrato_limite_credito.nrctrlim
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto 
																		          OR fn_busca_valor_divida(rw_contas_do_titular.cdcooper
                                                                     , rw_contas_do_titular.nrdconta
																			                               , rw_contas_do_titular.nrdconta
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto
																						THEN 'S' ELSE 'N' END);

					   vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
						 vr_contratos_ativos := vr_contratos_ativos + 1;
					ELSE 
						   vr_risco_cpf := CASE WHEN trim(rw_contas_do_titular.dsnivris) IS NULL OR trim(rw_contas_do_titular.dsnivris) = '' THEN 'A' ELSE rw_contas_do_titular.dsnivris END;

					     vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas_do_titular.cdcooper
							                                         , rw_contas_do_titular.nrdconta
																											 , rw_dat.dtmvtoan);

							 vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);
							 
							 vr_risco_inclusao := 'A';

               pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_do_titular.nrdconta
                                     , rw_contas_do_titular.nrcpfcgc
                                     , NULL
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , NULL
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(vr_risco_atraso
																		          , nvl(fn_traduz_risco(vr_risco_agr), 'A'))
                                     , vr_risco_cpf
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , 'CTA'
																		 , CASE WHEN fn_busca_valor_divida(rw_contas_do_titular.cdcooper
                                                                     , rw_contas_do_titular.nrdconta
																			                               , rw_contas_do_titular.nrdconta
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto
																						THEN 'S' ELSE 'N' END);

                vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
					END IF;

					CLOSE cr_contrato_limite_credito;

          -- Se a conta não possui contratos ativos, inclui apenas dados de risco da conta
          /*IF vr_contratos_ativos = 0 
						OR fn_verifica_atraso_conta(rw_contas_do_titular.cdcooper
							                        , rw_contas_do_titular.nrdconta
																			, rw_dat.dtmvtoan
																			, vr_valor_arrasto) THEN
						   vr_risco_cpf := CASE WHEN trim(rw_contas_do_titular.dsnivris) IS NULL OR trim(rw_contas_do_titular.dsnivris) = '' THEN 'A' ELSE rw_contas_do_titular.dsnivris END;

					     vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas_do_titular.cdcooper
							                                         , rw_contas_do_titular.nrdconta
																											 , rw_dat.dtmvtoan);

							 vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);
							 
							 vr_risco_inclusao := 'A';

               pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_do_titular.nrdconta
                                     , rw_contas_do_titular.nrcpfcgc
                                     , NULL
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , NULL
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(vr_risco_atraso
																		          , nvl(fn_traduz_risco(vr_risco_agr), 'A'))
                                     , vr_risco_cpf
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , 'CTA');

                vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
          END IF; */
      END LOOP;

      -- Percorre contas dos grupos econômicos em que o titular da conta base faz parte
      FOR rw_contas_grupo_economico
        IN cr_contas_grupo_economico(rw_cbase) LOOP

        vr_contratos_ativos := 0;

				-- Busca o risco agravado para a conta
								vr_risco_agr := fn_busca_risco_agravado(rw_contas_grupo_economico.cdcooper
																									    , rw_contas_grupo_economico.nrdconta);

        -- Percorre os contratos de empréstimo ativos da conta
        FOR rw_contratos_emprestimo
          IN cr_contratos_emprestimo(rw_contas_grupo_economico.cdcooper
                                   , rw_contas_grupo_economico.nrdconta) LOOP

            IF fn_busca_valor_divida(rw_contas_grupo_economico.cdcooper
                                   , rw_contas_grupo_economico.nrdconta
																	 , rw_contratos_emprestimo.nrctremp
																	 , rw_dat.dtmvtoan) > vr_valor_arrasto THEN

								-- Busca o rating do contrato
								vr_rating := fn_busca_rating(rw_contas_grupo_economico.cdcooper
																	   			 , rw_contas_grupo_economico.nrdconta
																				   , rw_contratos_emprestimo.nrctremp
																					 , 3);

								-- Busca a quantidade de dias em atraso do contato
								pc_busca_dados_diaria(rw_contas_grupo_economico.cdcooper
																		, rw_contas_grupo_economico.nrdconta
																		, rw_contratos_emprestimo.nrctremp
																		, rw_dat.dtmvtoan
																		, vr_diasatraso
																		, vr_risco_final);

								-- Calcula o risco atraso para a operação
								vr_risco_atraso := fn_calcula_risco_atraso(vr_diasatraso);

								-- Adiciona registro para a conta no XML de retorno
								pc_monta_reg_conta_xml(pr_retxml
																	, vr_auxconta
																	, vr_dscritic
																	, rw_contas_grupo_economico.nrdconta
																	, rw_contas_grupo_economico.nrcpfcgc
																	, rw_contratos_emprestimo.nrctremp
																	, rw_contratos_emprestimo.dsnivori
																	, rw_contas_grupo_economico.dsdrisgp
																	, vr_rating
																	, vr_risco_atraso
																	, fn_traduz_risco(vr_risco_agr)
																	, greatest(nvl(vr_rating, 'A')
																									, vr_risco_atraso
																									, CASE WHEN rw_contratos_emprestimo.dsnivris <> rw_contratos_emprestimo.dsnivori AND rw_contratos_emprestimo.dsnivris = 'A'
																											THEN rw_contratos_emprestimo.dsnivris ELSE rw_contratos_emprestimo.dsnivori END
																									, nvl(fn_traduz_risco(vr_risco_agr), 'A')) -- rw_contratos_emprestimo.dsnivcal
																	, rw_contas_grupo_economico.dsnivris -- risco do CPF
																	, rw_contas_grupo_economico.nrdgrupo
																	, rw_contratos_emprestimo.dsnivris -- risco melhora
																	, fn_traduz_risco(vr_risco_final)
																	, 'EMP'
																	, 'S');

								vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
								vr_contratos_ativos := vr_contratos_ativos + 1;
						END IF;
          END LOOP;

					-- Percorre os contratos de limtie de desconto com risco na central
					FOR rw_contratos_limite_desc
						IN cr_contratos_limite_desc(rw_contas_grupo_economico.cdcooper
                                      , rw_contas_grupo_economico.nrdconta
																			, rw_dat.dtmvtoan
																			, vr_valor_arrasto) LOOP

					      vr_rating := fn_busca_rating(rw_contas_grupo_economico.cdcooper
                                           , rw_contas_grupo_economico.nrdconta
																			     , rw_contratos_limite_desc.nrctrlim
																					 , rw_contratos_limite_desc.cdorigem);


								vr_risco_inclusao := 'A';
								vr_risco_atraso := fn_calcula_risco_atraso(rw_contratos_limite_desc.qtdiaatr);

								-- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_grupo_economico.nrdconta
                                     , rw_contas_grupo_economico.nrcpfcgc
                                     , rw_contratos_limite_desc.nrctrlim
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , vr_rating
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(nvl(vr_rating, 'A')
																							, vr_risco_inclusao
																							, vr_risco_atraso
																							, nvl(fn_traduz_risco(vr_risco_agr), 'A'))   -- rw_contratos_emprestimo.dsnivcal
                                     , rw_contas_grupo_economico.dsnivris
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , rw_contratos_limite_desc.tipcontr
																		 , 'S');

					     vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
						   vr_contratos_ativos := vr_contratos_ativos + 1;
					END LOOP;

					OPEN cr_contrato_limite_credito(rw_contas_grupo_economico.cdcooper
							                          , rw_contas_grupo_economico.nrdconta
																				, rw_dat.dtmvtoan);

				  FETCH cr_contrato_limite_credito INTO rw_contrato_limite_credito;

					IF cr_contrato_limite_credito%FOUND THEN
						    vr_rating := fn_busca_rating(rw_contas_grupo_economico.cdcooper
                                           , rw_contas_grupo_economico.nrdconta
																			     , rw_contrato_limite_credito.nrctrlim
																					 , 1);
																					 
						    vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas_grupo_economico.cdcooper
							                                          , rw_contas_grupo_economico.nrdconta
																												, rw_dat.dtmvtoan);

							  vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);
								
								vr_risco_inclusao := 'A';

					      -- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_grupo_economico.nrdconta
                                     , rw_contas_grupo_economico.nrcpfcgc
                                     , rw_contrato_limite_credito.nrctrlim
                                     , vr_risco_inclusao
                                     , vr_risco_grupo
                                     , vr_rating
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(nvl(vr_rating, 'A')
																							, vr_risco_inclusao
																							, vr_risco_atraso
																							, nvl(fn_traduz_risco(vr_risco_agr), 'A'))   -- rw_contratos_emprestimo.dsnivcal
                                     , rw_contas_grupo_economico.dsnivris
                                     , vr_numero_grupo
																		 , NULL
																		 , NULL
																		 , 'LIM'
																		 , CASE WHEN fn_busca_valor_divida(rw_contas_grupo_economico.cdcooper
                                                                     , rw_contas_grupo_economico.nrdconta
																			                               , rw_contrato_limite_credito.nrctrlim
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto 
																		          OR fn_busca_valor_divida(rw_contas_grupo_economico.cdcooper
                                                                     , rw_contas_grupo_economico.nrdconta
																			                               , rw_contas_grupo_economico.nrdconta
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto
																						THEN 'S' ELSE 'N' END);

					   vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
						 vr_contratos_ativos := vr_contratos_ativos + 1;
					ELSE
						 vr_risco_cpf := CASE WHEN trim(rw_contas_grupo_economico.dsnivris) IS NULL OR trim(rw_contas_grupo_economico.dsnivris) = '' THEN 'A' ELSE rw_contas_grupo_economico.dsnivris END;

							 --vr_risco_inclusao := fn_traduz_risco(rw_contrato_limite_credito.innivris);
							 vr_risco_inclusao := 'A';

							 vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas_grupo_economico.cdcooper
                                                       , rw_contas_grupo_economico.nrdconta
																			              	 , rw_dat.dtmvtoan);

							 vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);

               pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_grupo_economico.nrdconta
                                     , rw_contas_grupo_economico.nrcpfcgc
                                     , NULL
                                     , vr_risco_inclusao
                                     , rw_contas_grupo_economico.dsdrisgp
                                     , NULL
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(vr_risco_atraso
																		          , nvl(fn_traduz_risco(vr_risco_agr), 'A'))
																		 , vr_risco_cpf
                                     , rw_contas_grupo_economico.nrdgrupo
																		 , NULL
																		 , NULL
																		 , 'CTA'
																		 , CASE WHEN fn_busca_valor_divida(rw_contas_grupo_economico.cdcooper
                                                                     , rw_contas_grupo_economico.nrdconta
																			                               , rw_contas_grupo_economico.nrdconta
																			                               , rw_dat.dtmvtoan) > vr_valor_arrasto
																						THEN 'S' ELSE 'N' END);

                vr_auxconta := vr_auxconta + 1;
					END IF;

					CLOSE cr_contrato_limite_credito;

          -- Se a conta não possui contratos ativos, inclui apenas dados de risco da conta
          /*IF vr_contratos_ativos = 0 
						OR fn_verifica_atraso_conta(rw_contas_grupo_economico.cdcooper
                                      , rw_contas_grupo_economico.nrdconta
																			, rw_dat.dtmvtoan
																			, vr_valor_arrasto) THEN
						   vr_risco_cpf := CASE WHEN trim(rw_contas_grupo_economico.dsnivris) IS NULL OR trim(rw_contas_grupo_economico.dsnivris) = '' THEN 'A' ELSE rw_contas_grupo_economico.dsnivris END;

							 --vr_risco_inclusao := fn_traduz_risco(rw_contrato_limite_credito.innivris);
							 vr_risco_inclusao := 'A';

							 vr_diasatraso := fn_busca_dias_atraso_adp(rw_contas_grupo_economico.cdcooper
                                                       , rw_contas_grupo_economico.nrdconta
																			              	 , rw_dat.dtmvtoan);

							 vr_risco_atraso := fn_calcula_risco_atraso_adp(vr_diasatraso);

               pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_grupo_economico.nrdconta
                                     , rw_contas_grupo_economico.nrcpfcgc
                                     , NULL
                                     , vr_risco_inclusao
                                     , rw_contas_grupo_economico.dsdrisgp
                                     , NULL
                                     , vr_risco_atraso
                                     , fn_traduz_risco(vr_risco_agr)
                                     , greatest(vr_risco_atraso
																		          , nvl(fn_traduz_risco(vr_risco_agr), 'A'))
																		 , vr_risco_cpf
                                     , rw_contas_grupo_economico.nrdgrupo
																		 , NULL
																		 , NULL
																		 , 'CTA');

                vr_auxconta := vr_auxconta + 1;
          END IF; */
      END LOOP;

      -- Busca o risco da última central de riscos (último fechamento)
      vr_risco_ult_central := fn_busca_risco_ult_central(pr_cdcooper
                                                       , pr_nrdconta
                                                       , rw_dat.dtultdma
																											 , vr_valor_arrasto);
			vr_data_risco_final := fn_busca_data_risco(pr_cdcooper
                                               , pr_nrdconta
                                               , rw_dat.dtmvtoan);

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
