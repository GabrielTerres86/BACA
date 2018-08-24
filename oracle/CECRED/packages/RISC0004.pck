CREATE OR REPLACE PACKAGE CECRED.RISC0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0004
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Março/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para a manipulação de dados de risco
  --
  ---------------------------------------------------------------------------------------------------------------

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
FUNCTION fn_traduz_nivel_risco(pr_dsnivris crawepr.dsnivris%TYPE, pr_default_value crapris.innivris%TYPE := NULL)
	RETURN crapris.innivris%TYPE;

-- Busca o rating definido para uma conta/contrato
FUNCTION fn_busca_rating(pr_cdcooper NUMBER
                       , pr_nrdconta NUMBER
                       , pr_nrctremp NUMBER
                       , pr_cdorigem NUMBER)
  RETURN crapnrc.indrisco%TYPE;

-- Busca rating efetivo por conta (sem especificar contrato)
FUNCTION fn_busca_rating_conta(pr_cdcooper NUMBER
                             , pr_nrdconta NUMBER)
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
                           , pr_dtmvtoan   DATE)
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
                               , pr_dtmvtoan   DATE)
	RETURN INTEGER;

-- Verifica se a conta possui atraso (ADP) na central de riscos (diária)
FUNCTION fn_verifica_atraso_conta(pr_cdcooper   crawepr.cdcooper%TYPE
                                , pr_nrdconta   crawepr.nrdconta%TYPE
                                , pr_dtmvtoan   crapdat.dtmvtoan%TYPE)
	RETURN BOOLEAN;

-- Busca o nível de risco da última mensal na central de riscos para uma conta
FUNCTION fn_busca_risco_ult_central(pr_cdcooper    crawepr.cdcooper%TYPE
                                  , pr_nrdconta   crawepr.nrdconta%TYPE
                                  , pr_dtultdma   crapdat.dtultdma%TYPE)
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
  RETURN crapris.innivris%TYPE;

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
                                 , pr_numero_grupo OUT NUMBER
                                 , pr_risco_grupo  OUT NUMBER);

-- Carrega os dados da central de riscos (CRAPRIS) para a TBRISCO_CENTRAL_OCR
PROCEDURE pc_carrega_tabela_riscos(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da Critica retornada
                                  ,pr_dscritic OUT VARCHAR2);

  -- Buscar o maior dias atraso dos contratos que estão sendo liquidados
  PROCEDURE pc_dias_atraso_liquidados(pr_cdcooper IN NUMBER                  --> Cooperativa
                                     ,pr_nrdconta IN NUMBER                  --> Conta
                                     ,pr_nrctremp IN NUMBER                  --> Contrato
                                     ,pr_dsliquid IN VARCHAR2 DEFAULT NULL   --> Lista de contratos liquidados
                                     ,pr_qtdatref OUT NUMBER                 --> Qtde dias atraso refinanciamento
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
FUNCTION fn_traduz_nivel_risco(pr_dsnivris crawepr.dsnivris%TYPE, pr_default_value crapris.innivris%TYPE := NULL)
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

FUNCTION fn_busca_rating_conta(pr_cdcooper NUMBER
                             , pr_nrdconta NUMBER)
  RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;

    --- >>> CURSORES <<< ---
    CURSOR cr_rating IS
    SELECT  max(rat.indrisco) indrisco
       FROM crapnrc rat
      WHERE rat.cdcooper =  pr_cdcooper
        AND rat.nrdconta =  pr_nrdconta
        AND rat.insitrat =  2;
    rw_rating cr_rating%ROWTYPE;
BEGIN
   OPEN cr_rating;
   FETCH cr_rating INTO rw_rating;

   vr_rating := rw_rating.indrisco;

   CLOSE cr_rating;

   RETURN vr_rating;
END fn_busca_rating_conta;

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
                           , pr_dtmvtoan   DATE)
  RETURN crapris.dtdrisco%TYPE AS vr_data_risco crapris.dtdrisco%TYPE;

   --- >>> CURSORES <<< ---

   -- Cursor para recuperar a data de risco --
   CURSOR cr_data_risco(pr_cdcooper    NUMBER
                       , pr_nrdconta   NUMBER
                       , pr_dtmvtoan   DATE) IS
   SELECT r.dtdrisco
     FROM crapris r
    WHERE r.cdcooper = pr_cdcooper
      AND r.nrdconta = pr_nrdconta
      AND r.dtrefere = pr_dtmvtoan
      AND r.inddocto = 1
     ORDER BY r.innivris DESC
         , r.dtdrisco ASC;
   rw_data_risco cr_data_risco%ROWTYPE;
BEGIN
   OPEN cr_data_risco(pr_cdcooper, pr_nrdconta, pr_dtmvtoan);
   FETCH cr_data_risco INTO rw_data_risco;
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
                               , pr_dtmvtoan   DATE)
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
                                , pr_dtmvtoan   crapdat.dtmvtoan%TYPE)
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
                                  , pr_dtultdma   crapdat.dtultdma%TYPE)
  RETURN crawepr.dsnivris%TYPE AS vr_risco_ult_central crawepr.dsnivris%TYPE;

   -- >>> CURSORES <<< --

   -- Dados do risco da última central --
   CURSOR cr_riscos(pr_cdcooper   crawepr.cdcooper%TYPE
                   ,pr_nrdconta   crawepr.nrdconta%TYPE
                   ,pr_dtultdma   crapdat.dtultdma%TYPE) IS
   SELECT uc.innivris
     FROM crapris uc
    WHERE uc.cdcooper = pr_cdcooper
      AND uc.nrdconta = pr_nrdconta
      AND uc.dtrefere = pr_dtultdma
      AND uc.inddocto = 1
    ORDER BY uc.innivris DESC,
             uc.dtdrisco ASC;
   rw_riscos cr_riscos%ROWTYPE;

   -- Variáveis --
   vr_risco_nao_cadastrado BOOLEAN;
BEGIN
    vr_risco_nao_cadastrado := FALSE;

    OPEN cr_riscos(pr_cdcooper
                  ,pr_nrdconta
                  ,pr_dtultdma);

    FETCH cr_riscos INTO rw_riscos;
       CLOSE cr_riscos;

       vr_risco_ult_central := rw_riscos.innivris;

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
    tipo_contrato := CASE WHEN cdmodali = 0 OR cdmodali = 999 THEN 'CTA'
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
  RETURN crapris.innivris%TYPE AS vr_risco_grupo crapris.innivris%TYPE;

	CURSOR cr_grupo IS
	SELECT DISTINCT g.innivrge
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
                                 , pr_numero_grupo OUT NUMBER
                                 , pr_risco_grupo  OUT NUMBER) IS

    --  26/06/2018 - Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO. (Mario Bernat - AMcom)

		--- >>> CURSORES <<< ---
		CURSOR cr_grupo IS
		SELECT g.nrdgrupo
             , g.innivrge
		  FROM crapgrp g
		 WHERE g.cdcooper(+) = pr_cdcooper
		   AND g.nrctasoc(+) = pr_nrdconta
		   AND g.nrcpfcgc(+) = pr_nrcpfcgc;
		rw_grupo cr_grupo%ROWTYPE;
BEGIN
	OPEN cr_grupo;
	FETCH cr_grupo INTO rw_grupo;
	CLOSE cr_grupo;

	pr_numero_grupo := rw_grupo.nrdgrupo;
	pr_risco_grupo  := rw_grupo.innivrge;
END pc_busca_grupo_economico;

-- Carrega os dados da central de riscos (CRAPRIS) para a TBRISCO_CENTRAL_OCR
PROCEDURE pc_carrega_tabela_riscos(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da Critica retornada
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica retornada

  -- Tabela para armazenar o risco CPF
  TYPE typ_tab_rowids IS TABLE OF ROWID INDEX BY PLS_INTEGER;
  TYPE typ_reg_risco_cpf IS RECORD (
      inrisco_cpf tbrisco_central_ocr.inrisco_cpf%TYPE
    , rowids_to_update typ_tab_rowids
  );
  TYPE typ_tab_risco_cpf IS TABLE OF typ_reg_risco_cpf INDEX BY VARCHAR2(14);
  vr_tab_risco_cpf typ_tab_risco_cpf;

  -- Carrega os dados da CRAPRIS (base para preenchimento da TBRISCO_CENTRAL_OCR)
  CURSOR cr_crapris(pr_cdcooper crapris.cdcooper%TYPE
                  , pr_dtrefere crapris.dtrefere%TYPE) IS
  SELECT ris1.nrdconta
       , ris1.nrctremp
       , ris1.nrcpfcgc
       , ris1.cdmodali
       , ris1.cdorigem
       , ris1.nrdgrupo
       , ris1.dtdrisco
       , ris1.inddocto
       , ris1.innivris
       , ris1.qtdiaatr
       , ris1.inpessoa
       , ris1.vldivida
       , ris1.rowid
    FROM crapris ris1
   WHERE ris1.cdcooper = pr_cdcooper
     AND ris1.dtrefere = pr_dtrefere
     AND ris1.cdmodali NOT IN (1901)
  UNION
  SELECT ris3.nrdconta
       , ris3.nrctremp
       , ris3.nrcpfcgc
       , ris3.cdmodali
       , ris3.cdorigem
       , ris3.nrdgrupo
       , ris3.dtdrisco
       , ris3.inddocto
       , ris3.innivris
       , ris3.qtdiaatr
       , ris3.inpessoa
       , ris3.vldivida
       , ris3.rowid
    FROM crapris ris3
   WHERE ris3.cdcooper = pr_cdcooper
     AND ris3.dtrefere = pr_dtrefere
     AND ris3.cdmodali = 1901
     AND NOT EXISTS (
        SELECT 1
          FROM crapris aux
         WHERE aux.cdcooper = ris3.cdcooper
           AND aux.nrdconta = ris3.nrdconta
           AND aux.dtrefere = ris3.dtrefere
           AND aux.cdmodali IN (201)
     );
  rw_crapris cr_crapris%ROWTYPE;

  -- Identifica o número do contrato de desconto de títulos a partir do número do borderô
  CURSOR cr_crapbdt(pr_nrborder crapbdt.nrborder%TYPE) IS
  SELECT bdt.nrctrlim
    FROM crapbdt bdt
   WHERE bdt.cdcooper = pr_cdcooper
     AND bdt.nrborder = pr_nrborder;

  -- Identifica o número do contrato de desconto de cheques a partir do número do borderô
  CURSOR cr_crapbdc(pr_nrborder crapbdc.nrborder%TYPE) IS
  SELECT bdc.nrctrlim
    FROM crapbdc bdc
   WHERE bdc.cdcooper = pr_cdcooper
     AND bdc.nrborder = pr_nrborder;

  -- Verifica se o contrato já se encontra inserido na TBRISCO_CENTRAL_OCR
  CURSOR cr_tbrisco(pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE
                  , pr_nrctremp tbrisco_central_ocr.nrctremp%TYPE
                  , pr_cdmodali tbrisco_central_ocr.cdmodali%TYPE
                  , pr_dtrefere tbrisco_central_ocr.dtrefere%TYPE) IS
  SELECT 1
    FROM tbrisco_central_ocr ocr
   WHERE ocr.dtrefere = pr_dtrefere
     AND ocr.cdcooper = pr_cdcooper
     AND ocr.nrdconta = pr_nrdconta
     AND ocr.nrctremp = pr_nrctremp
     AND ocr.cdmodali = pr_cdmodali;

  -- Busca os riscos Inclusão, Melhora e Refin para um contrato de empréstimo
  CURSOR cr_crapepr(pr_nrdconta crapepr.nrdconta%TYPE
                  , pr_nrctremp crapepr.nrctremp%TYPE) IS
  SELECT epr.inrisco_refin
       , epr.qtdias_atraso_refin
       , decode(wpr.dsnivris, ' ', 'A', wpr.dsnivris) dsnivris
       , decode(wpr.dsnivori, ' ', 'A', wpr.dsnivori) dsnivori
    FROM crapepr epr
       , crawepr wpr
   WHERE epr.cdcooper = pr_cdcooper
     AND epr.nrdconta = pr_nrdconta
     AND epr.nrctremp = pr_nrctremp
     AND wpr.cdcooper = epr.cdcooper
     AND wpr.nrdconta = epr.nrdconta
     AND wpr.nrctremp = epr.nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;

  -- Identifica contas que não possuem registro de limite de crédito ou ADP (cdmodali in (101,201)) na central de riscos
  CURSOR cr_crapass(pr_dtrefere tbrisco_central_ocr.dtrefere%TYPE) IS
  SELECT /*+index_asc (ass CRAPASS##CRAPASS1)*/ ass.nrdconta
       , ass.nrcpfcgc
       , ass.inpessoa
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.dtdemiss IS NULL
     AND ass.dtelimin IS NULL
     AND ass.nrdconta NOT IN (
            SELECT /*+index_asc (ocr TBRISCO_CENTRAL_OCR_PK)*/ ocr.nrdconta
              FROM tbrisco_central_ocr ocr
             WHERE ocr.cdcooper = ass.cdcooper
               AND ocr.nrdconta = ass.nrdconta
               AND ocr.dtrefere = pr_dtrefere
               AND ocr.cdmodali = 101
         );
  rw_crapass cr_crapass%ROWTYPE;

  -- Busca risco final para uma conta na TBRISCO_CENTRAL_OCR
  CURSOR cr_risco_final(pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE
                      , pr_dtrefere tbrisco_central_ocr.dtrefere%TYPE) IS
  SELECT DISTINCT nvl(inrisco_final, 2)
    FROM tbrisco_central_ocr ocr
   WHERE ocr.cdcooper = pr_cdcooper
     AND ocr.nrdconta = pr_nrdconta
     AND ocr.dtrefere = pr_dtrefere;

  rw_crapdat cr_dat%ROWTYPE;     -- Calendário de datas da cooperativa

  vr_nrctremp crapris.nrctremp%TYPE;
  vr_cdmodali crapris.cdmodali%TYPE;
  vr_jaexiste INTEGER;
  vr_nrdgrupo crapris.nrdgrupo%TYPE;
  vr_chtabcpf VARCHAR2(14);           -- Chave para a tabela que armazena o risco CPF
  vr_indrowid INTEGER;                -- Índice para a tabela de ROWIDs a atualizar para o risco CPF
  vr_rowidocr ROWID;                  -- ROWID do registro inserido na TBRISCO_CENTRAL_OCR

  vr_inrisco_inclusao tbrisco_central_ocr.inrisco_inclusao%TYPE;
  vr_inrisco_rating   tbrisco_central_ocr.inrisco_rating%TYPE;
  vr_inrisco_atraso   tbrisco_central_ocr.inrisco_atraso%TYPE;
  vr_inrisco_agravado tbrisco_central_ocr.inrisco_agravado%TYPE;
  vr_inrisco_melhora  tbrisco_central_ocr.inrisco_melhora%TYPE;
  vr_inrisco_operacao tbrisco_central_ocr.inrisco_operacao%TYPE;
  vr_inrisco_refin    tbrisco_central_ocr.inrisco_refin%TYPE;
  vr_inrisco_grupo    tbrisco_central_ocr.inrisco_grupo%TYPE;
  vr_inrisco_final    tbrisco_central_ocr.inrisco_final%TYPE;

  vr_qtdias_atraso_refin crapepr.qtdias_atraso_refin%TYPE;
BEGIN
  -- Carrega o calendário de datas da cooperativa
  OPEN cr_dat(pr_cdcooper);
  FETCH cr_dat INTO rw_crapdat;
  CLOSE cr_dat;

  -- Percorre os dados carregados da CRAPRIS
  FOR rw_crapris
    IN cr_crapris(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP

    vr_cdmodali := rw_crapris.cdmodali;
    vr_inrisco_final := rw_crapris.innivris;

    IF rw_crapris.cdmodali = 1901 THEN
       -- Evita redundância de registros do limite de crédito (cdmodali = 201 ou cdmodali = 1901)
       vr_cdmodali := 201;
       OPEN cr_risco_final(rw_crapris.nrdconta, rw_crapdat.dtmvtoan);
       FETCH cr_risco_final INTO vr_inrisco_final;
       CLOSE cr_risco_final;
    END IF;

    IF rw_crapris.cdmodali  = 301 THEN    -- Descontro de títulos
      OPEN cr_crapbdt(rw_crapris.nrctremp);
      FETCH cr_crapbdt INTO vr_nrctremp;
      CLOSE cr_crapbdt;
    ELSIF rw_crapris.cdmodali  = 302 THEN -- Descontro de cheques
      OPEN cr_crapbdc(rw_crapris.nrctremp);
      FETCH cr_crapbdc INTO vr_nrctremp;
      CLOSE cr_crapbdc;
    ELSE                                  -- Demais modallidades
      vr_nrctremp := rw_crapris.nrctremp;
    END IF;

    -- Verifica se o contrato já existe na TBRISCO_CENTRAL_OCR
    OPEN cr_tbrisco(rw_crapris.nrdconta
                  , vr_nrctremp
                  , vr_cdmodali
                  , rw_crapdat.dtmvtoan);
    FETCH cr_tbrisco INTO vr_jaexiste;
    IF cr_tbrisco%FOUND THEN
      CLOSE cr_tbrisco;

      -- Ignora o contrato já inserido
      CONTINUE;
    END IF;
    CLOSE cr_tbrisco;

    -- Calcula o risco Atraso
    vr_inrisco_atraso := fn_traduz_nivel_risco(CASE WHEN vr_cdmodali IN (101,201, 1901)
                                                    THEN fn_calcula_risco_atraso_adp(rw_crapris.qtdiaatr)
                                                    ELSE fn_calcula_risco_atraso(rw_crapris.qtdiaatr) END);

    -- Calcula o risco Agravado
    vr_inrisco_agravado := fn_busca_risco_agravado(pr_cdcooper
                                                 , rw_crapris.nrdconta
                                                 , rw_crapdat.dtmvtoan);

    -- Calula o risco Rating
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating(pr_cdcooper
                                                             , rw_crapris.nrdconta
                                                             , vr_nrctremp
                                                             , rw_crapris.cdorigem));

    -- Calcula os riscos Inclusão, Melhora e Refin
    IF vr_cdmodali IN (299,499) THEN
      OPEN cr_crapepr(rw_crapris.nrdconta
                    , vr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      CLOSE cr_crapepr;

      vr_inrisco_refin := rw_crapepr.inrisco_refin;
      vr_inrisco_inclusao := fn_traduz_nivel_risco(rw_crapepr.dsnivori);
      vr_inrisco_melhora := CASE WHEN rw_crapepr.dsnivris < rw_crapepr.dsnivori THEN fn_traduz_nivel_risco(rw_crapepr.dsnivris) ELSE NULL END;
      vr_qtdias_atraso_refin := rw_crapepr.qtdias_atraso_refin;
    ELSE
      vr_inrisco_refin := NULL;
      vr_inrisco_inclusao := 2;
      vr_inrisco_melhora := NULL;
      vr_qtdias_atraso_refin := 0;
    END IF;

    -- Calcula o risco Operação
    vr_inrisco_operacao := greatest(nvl(vr_inrisco_agravado, 2)
                                  , nvl(vr_inrisco_rating, 2)
                                  , vr_inrisco_atraso
                                  , nvl(vr_inrisco_refin, 2)
                                  , CASE WHEN vr_inrisco_melhora < vr_inrisco_inclusao
                                         THEN vr_inrisco_melhora
                                         ELSE vr_inrisco_inclusao END);

    -- Calcula risco grupo
    IF nvl(rw_crapris.nrdgrupo, 0) > 0 THEN
      vr_inrisco_grupo := fn_busca_niv_risco_ge(pr_cdcooper
                                               ,rw_crapris.nrdconta
                                               ,rw_crapris.nrcpfcgc
                                              , rw_crapris.nrdgrupo);
    ELSE
      vr_inrisco_grupo := NULL;
    END IF;

    -- Insere o contrato na TBRISCO_CENTRAL_OCR (dados básicos do risco)
    INSERT INTO tbrisco_central_ocr (
        cdcooper
      , nrdconta
      , nrctremp
      , nrcpfcgc
      , dtrefere
      , cdmodali
      , cdorigem
      , inddocto
      , nrdgrupo
      , dtdrisco
      , inrisco_final
      , inrisco_atraso
      , inrisco_grupo
      , inrisco_inclusao
      , inrisco_melhora
      , inrisco_agravado
      , inrisco_rating
      , inrisco_operacao
      , inrisco_refin
      --, qtdias_atraso_refin
    )
    VALUES (
        pr_cdcooper
      , rw_crapris.nrdconta
      , vr_nrctremp
      , rw_crapris.nrcpfcgc
      , rw_crapdat.dtmvtoan
      , vr_cdmodali
      , rw_crapris.cdorigem
      , rw_crapris.inddocto
      , rw_crapris.nrdgrupo
      , rw_crapris.dtdrisco
      , vr_inrisco_final
      , vr_inrisco_atraso
      , vr_inrisco_grupo
      , vr_inrisco_inclusao
      , vr_inrisco_melhora
      , vr_inrisco_agravado
      , vr_inrisco_rating
      , vr_inrisco_operacao
      , vr_inrisco_refin
    --  , vr_qtdias_atraso_refin
    ) RETURNING ROWID INTO vr_rowidocr;

    -- Calcula a raíz do CNPJ para uso como chave da tabela de riscos CPF
    vr_chtabcpf := CASE WHEN rw_crapris.inpessoa = 2
                       THEN substr(to_char(rw_crapris.nrcpfcgc, '00000000000000'), 1, 8)
                       ELSE to_char(rw_crapris.nrcpfcgc, '00000000000') END;

    IF vr_tab_risco_cpf.EXISTS(vr_chtabcpf) THEN
      -- Se já existe a chave na tabela e o risco da operação é maior
      -- que o risco CPF já armazenado, substitui
      IF vr_inrisco_operacao > vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf AND
        rw_crapris.inddocto = 1 THEN
        vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf := vr_inrisco_operacao;
      END IF;

      vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update(
         vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update.COUNT + 1) := vr_rowidocr;
    ELSE
      -- Armazena o risco Operação na tabela como sendo o risco CPF
      IF rw_crapris.inddocto = 1 THEN
        vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf := vr_inrisco_operacao;
      ELSE
        vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf := 2;
      END IF;

      vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update(1) := vr_rowidocr;
    END IF;
  END LOOP;

  -- Incluir contas que não possuem 101, 201, 1901 na CRAPRIS
  FOR rw_crapass
    IN cr_crapass(rw_crapdat.dtmvtoan) LOOP

    -- Calcula o risco Agravado
    vr_inrisco_agravado := fn_busca_risco_agravado(pr_cdcooper
                                                 , rw_crapass.nrdconta
                                                 , rw_crapdat.dtmvtoan);

    -- Calula o risco Rating
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating(pr_cdcooper
                                                             , rw_crapass.nrdconta
                                                             , rw_crapass.nrdconta
                                                             , 1));

    -- Define o risco atraso como "A" (não há atraso)
    vr_inrisco_atraso := 2;
    -- Define o risco inclusão como "A"
    vr_inrisco_inclusao := 2;
    vr_inrisco_melhora := NULL;
    vr_inrisco_refin := NULL;

    -- Identifica o grupo econômico da conta e o risco do grupo
    pc_busca_grupo_economico(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => rw_crapass.nrdconta
                           , pr_nrcpfcgc => rw_crapass.nrcpfcgc
                           , pr_numero_grupo => vr_nrdgrupo
                           , pr_risco_grupo => vr_inrisco_grupo);

    -- Calcula o risco Operação
    vr_inrisco_operacao := greatest(nvl(vr_inrisco_agravado, 2)
                                  , nvl(vr_inrisco_rating, 2)
                                  , vr_inrisco_atraso
                                  , nvl(vr_inrisco_refin, 2)
                                  , CASE WHEN vr_inrisco_melhora < vr_inrisco_inclusao
                                         THEN vr_inrisco_melhora
                                         ELSE vr_inrisco_inclusao END);

    -- Calcula o risco final
    OPEN cr_risco_final(rw_crapass.nrdconta
                      , rw_crapdat.dtmvtoan);
    FETCH cr_risco_final INTO vr_inrisco_final;

    -- Se não há outro registro para a conta na TBRISCO_CENTRAL_OCR
    IF cr_risco_final%NOTFOUND THEN
      -- Calcula o risco final como o máximo entre o risco operação e o risco grupo
      vr_inrisco_final := greatest(vr_inrisco_operacao, nvl(vr_inrisco_grupo, 2));
    END IF;

    CLOSE cr_risco_final;

    -- Insere o contrato na TBRISCO_CENTRAL_OCR (dados básicos do risco)
    INSERT INTO tbrisco_central_ocr (
        cdcooper
      , nrdconta
      , nrctremp
      , nrcpfcgc
      , dtrefere
      , cdmodali
      , cdorigem
      , inddocto
      , nrdgrupo
      , dtdrisco
      , inrisco_final
      , inrisco_atraso
      , inrisco_grupo
      , inrisco_inclusao
      , inrisco_melhora
      , inrisco_agravado
      , inrisco_rating
      , inrisco_operacao
      , inrisco_refin
    )
    VALUES (
        pr_cdcooper
      , rw_crapass.nrdconta
      , rw_crapass.nrdconta
      , rw_crapass.nrcpfcgc
      , rw_crapdat.dtmvtoan
      , 999
      , 1
      , 1
      , vr_nrdgrupo
      , NULL
      , vr_inrisco_final
      , vr_inrisco_atraso
      , vr_inrisco_grupo
      , vr_inrisco_inclusao
      , vr_inrisco_melhora
      , vr_inrisco_agravado
      , vr_inrisco_rating
      , vr_inrisco_operacao
      , vr_inrisco_refin
    ) RETURNING ROWID INTO vr_rowidocr;

    -- Calcula a raíz do CNPJ para uso como chave da tabela de riscos CPF
    vr_chtabcpf := CASE WHEN rw_crapass.inpessoa = 2
                       THEN substr(to_char(rw_crapass.nrcpfcgc, '00000000000000'), 1, 8)
                       ELSE to_char(rw_crapass.nrcpfcgc, '00000000000') END;

    IF vr_tab_risco_cpf.EXISTS(vr_chtabcpf) THEN
      vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update(
         vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update.COUNT + 1) := vr_rowidocr;
    ELSE
      -- Armazena o risco Operação como risco CPF
      vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf := vr_inrisco_operacao;
      vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update(1) := vr_rowidocr;
    END IF;
  END LOOP;

  -- Calcular risco CPF
  vr_chtabcpf := vr_tab_risco_cpf.FIRST;
  WHILE vr_chtabcpf IS NOT NULL LOOP
    -- Atualiza o risco CPF para todos os registros do CPF/CNPJ na TBRISCO_CENTRAL_OCR

    vr_indrowid := vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update.FIRST;
    WHILE vr_indrowid IS NOT NULL LOOP
      UPDATE tbrisco_central_ocr ocr
         SET inrisco_cpf = vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf
       WHERE ocr.rowid = vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update(vr_indrowid);

      vr_indrowid := vr_tab_risco_cpf(vr_chtabcpf).rowids_to_update.NEXT(vr_indrowid);
    END LOOP;

    vr_chtabcpf := vr_tab_risco_cpf.NEXT(vr_chtabcpf);
  END LOOP;

  COMMIT; -- *************** REMOVER APÓS TESTES ****************** --

  NULL;
END pc_carrega_tabela_riscos;

END RISC0004;
/
