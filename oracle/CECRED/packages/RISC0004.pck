CREATE OR REPLACE PACKAGE CECRED.RISC0004 IS

-- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;

-- Retorna o dia útil anterior do calendário da cooperativa
FUNCTION fn_dia_anterior(pr_cdcooper NUMBER)
	RETURN DATE;

-- Traduz risco para nível numérico
FUNCTION fn_traduz_nivel_risco(pr_dsnivris crawepr.dsnivris%TYPE, pr_default_value crawepr.dsnivris%TYPE := NULL)
	RETURN crapris.innivris%TYPE;

-- Busca o rating definido para uma conta/contrato
FUNCTION fn_busca_rating(pr_cdcooper NUMBER
											 , pr_nrdconta NUMBER
											 , pr_nrctremp NUMBER
											 , pr_cdorigem NUMBER
											 , pr_dtmvtoan DATE)
	RETURN crapnrc.indrisco%TYPE;

-- Busca o risco agravado definido para uma conta
FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER, pr_nrdconta NUMBER, pr_dtmvtoan DATE)
	RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE;

-- Busca o valor da dívida de um contrato na central de riscos (diária)
FUNCTION fn_busca_valor_divida(pr_cdcooper NUMBER
														 , pr_nrdconta NUMBER
														 , pr_nrctremp NUMBER
														 , pr_dtmvtoan DATE
														 , pr_cdmodali NUMBER)
	RETURN NUMBER;

-- Busca a data mais antiga do pior risco da central de riscos (diária) para uma conta
FUNCTION fn_busca_data_risco(pr_cdcooper   NUMBER
													 , pr_nrdconta   NUMBER
													 , pr_dtmvtoan   DATE
													 , pr_vlrarrasto NUMBER)
	RETURN crapris.dtdrisco%TYPE;

-- Busca a quantidade de dias de atraso para o ADP de uma conta na central de riscos (diária)
FUNCTION fn_busca_dias_atraso_adp(pr_cdcooper   NUMBER
																, pr_nrdconta   NUMBER
																, pr_dtmvtoan   DATE)
	RETURN INTEGER;

-- Busca a quantidade de dias de atraso para um contrato de limite de crédito na central de riscos (diária)
FUNCTION fn_busca_dias_atraso_lc(pr_cdcooper   NUMBER
															 , pr_nrdconta   NUMBER
															 , pr_nrctrlim   NUMBER
															 , pr_dtmvtoan   DATE
															 , pr_vlrarrasto NUMBER)
	RETURN INTEGER;

-- Verifica se a conta possui atraso (ADP) na central de riscos (diária)
FUNCTION fn_verifica_atraso_conta(pr_cdcooper   crawepr.cdcooper%TYPE
																, pr_nrdconta   crawepr.nrdconta%TYPE
																, pr_dtmvtoan   crapdat.dtmvtoan%TYPE
																, pr_vlrarrasto NUMBER)
	RETURN BOOLEAN;

-- Busca o nível de risco da última mensal na central de riscos para uma conta
FUNCTION fn_busca_risco_ult_central(pr_cdcooper    crawepr.cdcooper%TYPE
																	, pr_nrdconta   crawepr.nrdconta%TYPE
																	, pr_dtultdma   crapdat.dtultdma%TYPE
																	, pr_vlrarrasto NUMBER)
	RETURN crawepr.dsnivris%TYPE;

-- Calcula risco atraso para Ctr. Empr. (A, B, C, ...)
FUNCTION fn_calcula_risco_atraso(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE;

-- Calcula nível de risco atraso para Ctr. Empr. (2, 3, 4, ...)
FUNCTION fn_calcula_niv_risco_atraso(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE;

-- Calcula risco atraso ADP (A, B, C, ...)
FUNCTION fn_calcula_risco_atraso_adp(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE;

-- Callcula nível de risco atraso ADP (2, 3, 4, ...)
FUNCTION fn_calc_niv_risco_atraso_adp(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE;

FUNCTION fn_traduz_risco(innivris NUMBER)
	RETURN crawepr.dsnivris%TYPE;

-- Busca nível de risco do grupo economico
FUNCTION fn_busca_niv_risco_ge(pr_cdcooper     IN NUMBER
																 ,pr_nrdconta     IN NUMBER
																 ,pr_nrcpfcgc     IN NUMBER
																 ,pr_nrdgrupo     IN NUMBER)
	RETURN crapgrp.innivrge%TYPE;

-- Busca a quantidade de dias em atraso e o risco final para uma conta/contrato na central de riscos (diária)
PROCEDURE pc_busca_dados_diaria(pr_cdcooper    IN NUMBER
															, pr_nrdconta    IN NUMBER
															, pr_nrctremp    IN NUMBER
															, pr_dtmvtoan    IN DATE
															, vr_dias_atraso OUT NUMBER
															, vr_risco_final OUT NUMBER);

-- Busca o número e o nível de risco do grupo econômico para uma conta
PROCEDURE pc_busca_grupo_economico(pr_cdcooper     IN NUMBER
																 , pr_nrdconta     IN NUMBER
																 , pr_nrcpfcgc     IN NUMBER
																 , vr_numero_grupo OUT NUMBER
																 , vr_risco_grupo  OUT VARCHAR2);


  -- Buscar o maior dias atraso dos contratos que estão sendo liquidados
  PROCEDURE pc_dias_atraso_liquidados(pr_cdcooper IN NUMBER           --> Cooperativa
                                      ,pr_nrdconta IN NUMBER          --> Conta
                                      ,pr_nrctremp IN NUMBER          --> Contrato
                                      ,pr_qtdatref OUT NUMBER       --> Qtde dias atraso refinanciamento
                                      ,pr_dscritic OUT VARCHAR2);

END RISC0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0004 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0004
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Maço/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para a manipulação de dados de risco
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------

-- Retorna o dia útil anterior do calendário da cooperativa
FUNCTION fn_dia_anterior(pr_cdcooper NUMBER)
	RETURN DATE AS dia_anterior DATE;
  rw_dat RISC0004.cr_dat%ROWTYPE;
BEGIN
	OPEN RISC0004.cr_dat(pr_cdcooper);
	FETCH RISC0004.cr_dat INTO rw_dat;
	CLOSE RISC0004.cr_dat;

	dia_anterior := rw_dat.dtmvtoan;

	RETURN dia_anterior;
END fn_dia_anterior;

-- Traduz risco para nível numérico
FUNCTION fn_traduz_nivel_risco(pr_dsnivris crawepr.dsnivris%TYPE, pr_default_value crawepr.dsnivris%TYPE := NULL)
	RETURN crapris.innivris%TYPE AS nivel_risco crapris.innivris%TYPE;
BEGIN
	nivel_risco := CASE WHEN pr_dsnivris = 'A'  THEN 2
										WHEN pr_dsnivris = 'B'  THEN 3
										WHEN pr_dsnivris = 'C'  THEN 4
										WHEN pr_dsnivris = 'D'  THEN 5
										WHEN pr_dsnivris = 'E'  THEN 6
										WHEN pr_dsnivris = 'F'  THEN 7
										WHEN pr_dsnivris = 'G'  THEN 8
										WHEN pr_dsnivris = 'H'  THEN 9
										WHEN pr_dsnivris = 'HH' THEN 10
								 ELSE pr_default_value END;

	RETURN nivel_risco;
END fn_traduz_nivel_risco;

FUNCTION fn_busca_rating(pr_cdcooper NUMBER
                       , pr_nrdconta NUMBER
                       , pr_nrctremp NUMBER
                       , pr_cdorigem NUMBER
                       , pr_dtmvtoan DATE)
  RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;

    --- >>> CURSORES <<< ---
    CURSOR cr_rating IS
    SELECT rat.indrisco
       FROM crapnrc rat
      WHERE rat.cdcooper =  pr_cdcooper
        AND rat.nrdconta =  pr_nrdconta
        AND rat.nrctrrat =  pr_nrctremp
        AND rat.tpctrrat =  DECODE(pr_cdorigem
                                  , 1, 1
                                  , 2, 2
                                  , 3, 90
                                  , 4, 3
                                  , 5, 3)
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

FUNCTION fn_busca_dias_atraso_lc(pr_cdcooper   NUMBER
                               , pr_nrdconta   NUMBER
                               , pr_nrctrlim   NUMBER
                               , pr_dtmvtoan   DATE
                               , pr_vlrarrasto NUMBER)
  RETURN INTEGER AS vr_qtd_dias_atraso INTEGER;

    --- >>> CURSORES <<< ---

    -- Busca os dias de atraso do contrato (modalidade 201) --
    CURSOR cr_atraso_lc IS
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
       OPEN cr_atraso_lc;

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
   CURSOR cr_atraso IS
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
   OPEN cr_atraso;

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

-- Busca risco atraso
FUNCTION fn_calcula_niv_risco_atraso(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
BEGIN
	risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
												WHEN qtdiaatr <   15  THEN 2
												WHEN qtdiaatr <=  30  THEN 3
												WHEN qtdiaatr <=  60  THEN 4
												WHEN qtdiaatr <=  90  THEN 5
												WHEN qtdiaatr <= 120  THEN 6
												WHEN qtdiaatr <= 150  THEN 7
												WHEN qtdiaatr <= 180  THEN 8
												ELSE 9 END;
	RETURN risco_atraso;
END fn_calcula_niv_risco_atraso;

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

-- Callcula nível de risco atraso ADP
FUNCTION fn_calc_niv_risco_atraso_adp(qtdiaatr NUMBER)
	RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
BEGIN
	risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
												WHEN qtdiaatr <   15  THEN 2
												WHEN qtdiaatr <=  30  THEN 3
												WHEN qtdiaatr <=  60  THEN 5
												WHEN qtdiaatr <=  90  THEN 7
												ELSE 9 END;
	RETURN risco_atraso;
END fn_calc_niv_risco_atraso_adp;

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

FUNCTION fn_traduz_cdmodali_tpctr(cdmodali NUMBER)
  RETURN VARCHAR2 AS tipo_contrato VARCHAR2(3);
BEGIN
    tipo_contrato := CASE WHEN cdmodali = 0 THEN 'CTA'
                          WHEN cdmodali = 299 OR cdmodali = 499 THEN 'EMP'
                          WHEN cdmodali = 301 THEN 'DCH'
                          WHEN cdmodali = 302 THEN 'DTI'
                          WHEN cdmodali = 201 OR cdmodali = 1901 THEN 'LIM'
                          WHEN cdmodali = 101 THEN 'ADP'
                          ELSE 'N/D' END;
    RETURN tipo_contrato;
END fn_traduz_cdmodali_tpctr;

-- Busca nível de risco do grupo economico
FUNCTION fn_busca_niv_risco_ge(pr_cdcooper     IN NUMBER
																 ,pr_nrdconta     IN NUMBER
																 ,pr_nrcpfcgc     IN NUMBER
																 ,pr_nrdgrupo     IN NUMBER)
	RETURN crapgrp.innivrge%TYPE AS vr_risco_grupo crapgrp.innivrge%TYPE;

	CURSOR cr_grupo IS
	SELECT DISTINCT
				 g.innivrge
		FROM crapgrp g
	 WHERE g.cdcooper(+) = pr_cdcooper
		 AND g.nrctasoc(+) = pr_nrdconta
		 AND g.nrcpfcgc(+) = pr_nrcpfcgc
		 AND g.nrdgrupo(+) = pr_nrdgrupo;
	rw_grupo cr_grupo%ROWTYPE;
BEGIN
	OPEN cr_grupo;
	FETCH cr_grupo INTO rw_grupo;

	vr_risco_grupo  := rw_grupo.innivrge;

	CLOSE cr_grupo;

	RETURN vr_risco_grupo;
END fn_busca_niv_risco_ge;

PROCEDURE pc_busca_dados_diaria(pr_cdcooper    IN NUMBER
                              , pr_nrdconta    IN NUMBER
                              , pr_nrctremp    IN NUMBER
                              , pr_dtmvtoan    IN DATE
                              , vr_dias_atraso OUT NUMBER
                    					, vr_risco_final OUT NUMBER) IS

		--- >>> CURSORES <<< ---
		CURSOR cr_riscos IS
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
	 OPEN cr_riscos;

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
		CURSOR cr_grupo IS
		SELECT g.nrdgrupo
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


 -- Buscar o maior dias atraso dos contratos que estão sendo liquidados
  PROCEDURE pc_dias_atraso_liquidados(pr_cdcooper IN NUMBER           --> Cooperativa
                                      ,pr_nrdconta IN NUMBER          --> Conta
                                      ,pr_nrctremp IN NUMBER          --> Contrato (proposta)
                                      ,pr_qtdatref OUT NUMBER         --> Qtde dias atraso refinanciamento
                                      ,pr_dscritic OUT VARCHAR2) IS   --> Critica
    -- cursores
    CURSOR cr_qtdatref (pr_cdcooper   NUMBER
                       ,pr_nrdconta   NUMBER
                       ,pr_nrctremp   NUMBER) IS
      select nvl(max(qtdiaatr), 0) as qtdatref from
            (select ctrs.*, ris.dtrefere, ris.qtdiaatr
            from (
                   SELECT data, ctrliq, nrctremp, nrdconta, cdcooper FROM crawepr
                   UNPIVOT (ctrliq FOR data IN (nrctrliq##1, nrctrliq##2, nrctrliq##3, nrctrliq##4, nrctrliq##5, nrctrliq##6, nrctrliq##7, nrctrliq##8, nrctrliq##9, nrctrliq##10, nrliquid))
                     where cdcooper = pr_cdcooper and ctrliq > 0 and nrdconta = pr_nrdconta and nrctremp = pr_nrctremp
              ) ctrs
              left join crapris ris 
                     on ris.cdcooper = ctrs.cdcooper 
                    and ris.nrdconta = ctrs.nrdconta
                    and ris.nrctremp = ctrs.ctrliq
                    and ris.dtrefere IN (SELECT NVL((CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
                                          THEN dat.dtmvtoan
                                          ELSE dat.dtultdma END), '01/01/1980')
                                  FROM crapdat dat
                                 WHERE dat.cdcooper = pr_cdcooper));
                           
    rw_qtdatref cr_qtdatref%ROWTYPE;
    
    -- variaveis
    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;                                      
                                      
   BEGIN
   
     OPEN cr_qtdatref(pr_cdcooper, pr_nrdconta, pr_nrctremp);
     FETCH cr_qtdatref INTO rw_qtdatref;

     pr_qtdatref := rw_qtdatref.qtdatref;

     CLOSE cr_qtdatref;
     
   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       -- Variavel de erro recebe erro ocorrido
       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na risc0003.pc_dias_atraso_liquidados --> ' || SQLERRM;

  END pc_dias_atraso_liquidados;
  
END RISC0004;
/
