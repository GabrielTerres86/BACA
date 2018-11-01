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

  TYPE typ_reg_grupos IS
     RECORD ( cdcooper      crapris.cdcooper%TYPE
             ,nrdconta      crapris.nrdconta%TYPE
             ,nrdgrupo      crapris.nrdgrupo%TYPE
             ,inrisco_grupo tbcc_grupo_economico.inrisco_grupo%TYPE);
  TYPE typ_tab_grupos IS TABLE OF typ_reg_grupos
    INDEX BY VARCHAR2(18);
  vr_tab_grupos typ_tab_grupos;

  vr_execucao PLS_INTEGER :=0;

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

  PROCEDURE pc_central_risco_grupo(pr_cdcooper IN NUMBER           --> Cooperativa
                                  ,pr_dtrefere IN DATE             -- Data do dia da Coop
                                  ,pr_dtmvtoan IN DATE             -- Data da central anterior
                                     ,pr_dscritic OUT VARCHAR2);

  -- Grava saldo refinanciado na crapepr                                
  PROCEDURE pc_gravar_saldo_refin(pr_cdcooper            NUMBER     --> Cooperativa
                                 ,pr_nrdconta            NUMBER     --> Conta
                                 ,pr_nrctremp            NUMBER     --> Contrato
                                 ,pr_devedor_calculado   NUMBER     --> Valor refinanciado
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
  --  Data     : Março/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para a manipulação de dados de risco
  --
  -- Alterado  :
  --             26/06/2018 - Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO. (Mario Bernat - AMcom)
  --             24/08/2018 - Inclusão da coluna quantidade de dias de atraso
  --                          PJ 450 - Diego Simas - AMcom  
  --             31/10/2018 - inclusão da procedure pc_gravar_saldo_refinanciamento (Douglas Pagel/AMcom)
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
                          WHEN cdmodali = 302 THEN 'DCH'
                          WHEN cdmodali = 301 THEN 'DTI'
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
    SELECT inrisco_grupo
                FROM tbcc_grupo_economico       pai
     WHERE pai.cdcooper = pr_cdcooper
       AND pai.idgrupo  = pr_nrdgrupo;
  rw_grupo cr_grupo%ROWTYPE;

BEGIN
  rw_grupo := NULL;
  OPEN cr_grupo;
  FETCH cr_grupo INTO rw_grupo;

  vr_risco_grupo  := rw_grupo.inrisco_grupo;

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
      SELECT *
        FROM (SELECT p.inrisco_grupo
                    ,int.idgrupo
                    ,int.nrdconta
                FROM tbcc_grupo_economico_integ INT
                    ,tbcc_grupo_economico p
               WHERE int.dtexclusao IS NULL
                 AND int.cdcooper = pr_cdcooper
                 AND int.idgrupo  = p.idgrupo
               UNION
              SELECT pai.inrisco_grupo
                    ,pai.idgrupo
                    ,pai.nrdconta
                FROM tbcc_grupo_economico       pai
                   , crapass                    ass
                   , tbcc_grupo_economico_integ int
               WHERE ass.cdcooper = pai.cdcooper
                 AND ass.nrdconta = pai.nrdconta
                 AND int.idgrupo  = pai.idgrupo
                 AND int.dtexclusao is NULL
                 AND ass.cdcooper = pr_cdcooper
                 AND int.cdcooper = pr_cdcooper
            ) dados
       WHERE dados.nrdconta = pr_nrdconta;
    rw_grupo cr_grupo%ROWTYPE;
  
  -- variaveis
  vr_indice  VARCHAR2(18);  
  vr_dscritic VARCHAR2(500);
    
BEGIN
  rw_grupo := NULL;
  
  vr_indice := LPAD(pr_cdcooper,3,'0') || LPAD(pr_nrdconta,15,'0');
  
  -- Verifica se a conta está na VR_TAB (Desempenho) (Batch)
  IF  vr_tab_grupos.exists(vr_indice) THEN
    pr_numero_grupo := vr_tab_grupos(vr_indice).nrdgrupo;
    pr_risco_grupo  := vr_tab_grupos(vr_indice).inrisco_grupo;
  ELSE -- Se nao estiver, busca na tabela de Grupos (Tela)
  
    IF vr_execucao = 0 THEN    -- Não é pela OCR
      OPEN cr_grupo;
      FETCH cr_grupo INTO rw_grupo;
      CLOSE cr_grupo;

      pr_numero_grupo := rw_grupo.idgrupo;
      pr_risco_grupo  := rw_grupo.inrisco_grupo;
    END IF;

  END IF;

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

  -- Cursor para carregar vr_tab de grupos
  CURSOR cr_grupos (pr_cdcooper crapris.cdcooper%TYPE) IS
    SELECT p.inrisco_grupo
          ,int.idgrupo
          ,int.nrdconta
      FROM tbcc_grupo_economico_integ INT
          ,tbcc_grupo_economico p
     WHERE int.dtexclusao IS NULL
       AND int.cdcooper = pr_cdcooper
       AND int.idgrupo  = p.idgrupo
     UNION
    SELECT pai.inrisco_grupo
          ,pai.idgrupo
          ,pai.nrdconta
      FROM tbcc_grupo_economico       pai
         , crapass                    ass
         , tbcc_grupo_economico_integ int
     WHERE ass.cdcooper = pai.cdcooper
       AND ass.nrdconta = pai.nrdconta
       AND int.idgrupo  = pai.idgrupo
       AND int.dtexclusao is NULL
       AND ass.cdcooper = pr_cdcooper
       AND int.cdcooper = pr_cdcooper
     ORDER BY idgrupo, nrdconta;
  rw_grupos cr_grupos%ROWTYPE;

     
     
  ----------- VARIAVEIS ------------------
  rw_crapdat cr_dat%ROWTYPE;     -- Calendário de datas da cooperativa

  vr_nrctremp crapris.nrctremp%TYPE;
  vr_cdmodali crapris.cdmodali%TYPE;
  vr_jaexiste INTEGER;
  vr_nrdgrupo crapris.nrdgrupo%TYPE;
  vr_chtabcpf VARCHAR2(14);           -- Chave para a tabela que armazena o risco CPF
  vr_indrowid INTEGER;                -- Índice para a tabela de ROWIDs a atualizar para o risco CPF
  vr_rowidocr ROWID;                  -- ROWID do registro inserido na TBRISCO_CENTRAL_OCR
  vr_idx_grp  VARCHAR2(18);

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


  vr_idx_grp  := NULL;
  vr_execucao := 1;
  -- Carregar Grupos da Cooperativa
  FOR rw_grupos IN cr_grupos (pr_cdcooper) LOOP
    vr_idx_grp := LPAD(pr_cdcooper,3,'0') || LPAD(rw_grupos.nrdconta,15,'0');
    
    -- Evitar duplicados
    IF NOT vr_tab_grupos.exists(vr_idx_grp) THEN
      vr_tab_grupos(vr_idx_grp).nrdgrupo      := rw_grupos.idgrupo;
      vr_tab_grupos(vr_idx_grp).inrisco_grupo := rw_grupos.inrisco_grupo;
      vr_tab_grupos(vr_idx_grp).cdcooper      := pr_cdcooper;
      vr_tab_grupos(vr_idx_grp).nrdconta      := rw_grupos.nrdconta;
    END IF;
  END LOOP;

  -- Percorre os dados carregados da CRAPRIS
  FOR rw_crapris IN cr_crapris(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP

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
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating_conta(pr_cdcooper
                                                                   , rw_crapris.nrdconta));
/*
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating(pr_cdcooper
                                                             , rw_crapris.nrdconta
                                                             , vr_nrctremp
                                                             , rw_crapris.cdorigem));
*/

    -- Calcula os riscos Inclusão, Melhora e Refin
    IF vr_cdmodali IN (299,499) THEN
      OPEN cr_crapepr(rw_crapris.nrdconta
                    , vr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      CLOSE cr_crapepr;

      vr_inrisco_refin := rw_crapepr.inrisco_refin;
      vr_inrisco_inclusao := fn_traduz_nivel_risco(rw_crapepr.dsnivori);
      vr_inrisco_melhora     := CASE WHEN rw_crapepr.dsnivris = 'A' THEN 2 ELSE NULL END; -- Risco Melhora só melhora para 2(A), se não, não melhora
                                --CASE WHEN rw_crapepr.dsnivris < rw_crapepr.dsnivori THEN fn_traduz_nivel_risco(rw_crapepr.dsnivris) ELSE NULL END;
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
      , qtdiaatr -- PJ 450 -- Diego Simas (AMcom)
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
      , rw_crapris.qtdiaatr -- PJ 450 -- Diego Simas (AMcom)
    --  , vr_qtdias_atraso_refin
    ) RETURNING ROWID INTO vr_rowidocr;

    -- Calcula a raíz do CNPJ para uso como chave da tabela de riscos CPF
    vr_chtabcpf := CASE WHEN rw_crapris.inpessoa = 2
                       THEN substr(to_char(rw_crapris.nrcpfcgc, 'FM00000000000000'), 1, 8)
                       ELSE to_char(rw_crapris.nrcpfcgc, 'FM00000000000') END;

    IF vr_tab_risco_cpf.EXISTS(vr_chtabcpf) THEN
      -- Se já existe a chave na tabela e o risco da operação é maior
      -- que o risco CPF já armazenado, substitui
      IF  vr_inrisco_operacao > vr_tab_risco_cpf(vr_chtabcpf).inrisco_cpf
      AND rw_crapris.inddocto = 1 THEN
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
  FOR rw_crapass IN cr_crapass(rw_crapdat.dtmvtoan) LOOP

    -- Calcula o risco Agravado
    vr_inrisco_agravado := fn_busca_risco_agravado(pr_cdcooper
                                                 , rw_crapass.nrdconta
                                                 , rw_crapdat.dtmvtoan);

    -- Calula o risco Rating
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating_conta(pr_cdcooper
                                                                   , rw_crapass.nrdconta));
/*
    vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating(pr_cdcooper
                                                             , rw_crapass.nrdconta
                                                             , rw_crapass.nrdconta
                                                             , 1));
*/

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
    vr_chtabcpf := CASE WHEN rw_crapass.inpessoa = 2 THEN 
                             substr(to_char(rw_crapass.nrcpfcgc, 'FM00000000000000'), 1, 8)
                        ELSE to_char(rw_crapass.nrcpfcgc, 'FM00000000000') END;

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


 -- Buscar o maior dias atraso dos contratos que estão sendo liquidados
  PROCEDURE pc_dias_atraso_liquidados(pr_cdcooper IN NUMBER                 --> Cooperativa
                                     ,pr_nrdconta IN NUMBER                 --> Conta
                                     ,pr_nrctremp IN NUMBER                 --> Contrato (proposta)
                                     ,pr_dsliquid IN VARCHAR2 DEFAULT NULL  --> Lista de contratos liquidados
                                     ,pr_qtdatref OUT NUMBER                --> Qtde dias atraso refinanciamento
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Critica
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
    
    CURSOR cr_crapepr  (pr_cdcooper   NUMBER
                       ,pr_nrdconta   NUMBER
                       ,pr_nrctremp   NUMBER) IS
      select epr.dtliquid
        from crapepr epr
       where epr.cdcooper = pr_cdcooper 
         and epr.nrdconta = pr_nrdconta
         and epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    
    CURSOR cr_crapris  (pr_cdcooper   NUMBER
                       ,pr_nrdconta   NUMBER
                       ,pr_nrctremp   NUMBER
                       ,pr_dtrefere   DATE) IS
      select ris.qtdiaatr
        from crapris ris
       where ris.cdcooper = pr_cdcooper 
         and ris.nrdconta = pr_nrdconta
         and ris.nrctremp = pr_nrctremp
         and ris.dtrefere = pr_dtrefere;
    rw_crapris cr_crapris%ROWTYPE;
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    -- Variáveis
    -- Variáveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;
    
    -- Variáveis para criar uma lista com os contratos
    -- passados e com os separados nos contratos a liquidar
    vr_split_pr_dsliquid    GENE0002.typ_split;
    
    -- Variáveis de uso comum
    vr_indice               NUMBER(10) := 1;
    vr_dtrefere_aux         DATE;
    vr_dtrefere             DATE;
    vr_qtdiaatr             crapris.qtdiaatr%type;

   BEGIN
     IF pr_dsliquid IS NULL THEN
       
       OPEN cr_qtdatref(pr_cdcooper, pr_nrdconta, pr_nrctremp);
       FETCH cr_qtdatref INTO rw_qtdatref;

       pr_qtdatref := nvl(rw_qtdatref.qtdatref,0);

       CLOSE cr_qtdatref;

     ELSE
       
       -- Efetuar split dos contratos passados para facilitar os testes
       vr_split_pr_dsliquid := gene0002.fn_quebra_string(replace(rtrim(pr_dsliquid, ','),';',','),',');
       
       IF vr_split_pr_dsliquid.count > 0 THEN
         
         /* Busca data de movimento */
         OPEN  btch0001.cr_crapdat(pr_cdcooper);
         FETCH btch0001.cr_crapdat INTO rw_crapdat;
         CLOSE btch0001.cr_crapdat;
         
         IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
           -- Utilizar o final do mês como data
           vr_dtrefere_aux := rw_crapdat.dtultdma;
         ELSE
           -- Utilizar a data atual
           vr_dtrefere_aux := rw_crapdat.dtmvtoan;
         END IF;
         
         vr_qtdiaatr := 0;
         
         LOOP
     
           OPEN cr_crapepr(pr_cdcooper, pr_nrdconta, vr_split_pr_dsliquid(vr_indice));
           FETCH cr_crapepr INTO rw_crapepr;
           
           vr_dtrefere := NVL(rw_crapepr.dtliquid, vr_dtrefere_aux);
           
           OPEN cr_crapris(pr_cdcooper, pr_nrdconta, vr_split_pr_dsliquid(vr_indice), vr_dtrefere);
           FETCH cr_crapris INTO rw_crapris;
           
           IF vr_qtdiaatr < nvl(rw_crapris.qtdiaatr,0) THEN
             vr_qtdiaatr := nvl(rw_crapris.qtdiaatr,0);
           END IF;

           CLOSE cr_crapris;
           CLOSE cr_crapepr;
           
           vr_indice := vr_indice + 1;           
           
           EXIT WHEN (vr_split_pr_dsliquid.count = vr_indice - 1);
         END LOOP;
         
         pr_qtdatref := vr_qtdiaatr;
         
       END IF;
     
     END IF;

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


  PROCEDURE pc_central_risco_grupo(pr_cdcooper IN NUMBER           --> Cooperativa
                                  ,pr_dtrefere IN DATE             -- Data do dia da Coop
                                  ,pr_dtmvtoan IN DATE             -- Data da central anterior
                                  ,pr_dscritic OUT VARCHAR2) IS   --> Critica
  /* .............................................................................

   Programa: pc_central_risco_grupo       (Antigo: NAO HA)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Agosto/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Atribuir o Nr.Grupo nas contas da Central de Risco,
               Calcular o maior risco do G.E.
               Gravar nas contas do G.E. o risco do grupo

   Alteracoes: 
  ............................................................................. */

    -- ESTE CURSOR INDICA EM QUAL GRUPO TAL CPF/CNPJ DEVERIA ESTAR
    CURSOR cr_grupo_cpf (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT DISTINCT grp.cdcooper
                    , grp.tppessoa
                    , grp.nrcpfcnpj_base
                    , first_value(idgrupo) over (partition by nrcpfcnpj_base
                                                     order by dtinclusao, idgrupo
                                                   rows unbounded preceding) as nrdgrupo
        FROM (SELECT dados.*
                FROM (SELECT int.cdcooper
                           , int.tppessoa
                           , CASE WHEN int.tppessoa = 1                      then int.nrcpfcgc
                                  WHEN int.tppessoa = 2 and int.nrcpfcgc > 0 then to_number(substr(to_char(int.nrcpfcgc,'FM00000000000000'),1,8))
                                  ELSE NULL
                             END AS nrcpfcnpj_base
                           , int.dtinclusao
                           , int.idgrupo
                        FROM tbcc_grupo_economico_integ int
                       WHERE int.dtexclusao IS NULL
                         AND int.cdcooper = pr_cdcooper
                       UNION
                      SELECT pai.cdcooper
                           , ass.inpessoa
                           , ass.nrcpfcnpj_base
                           , pai.dtinclusao
                           , pai.idgrupo
                        FROM tbcc_grupo_economico       pai
                           , crapass                    ass
                           , tbcc_grupo_economico_integ int
                       WHERE ass.cdcooper = pai.cdcooper
                         AND ass.nrdconta = pai.nrdconta
                         AND int.idgrupo  = pai.idgrupo
                         AND int.dtexclusao is null
                         AND pai.cdcooper = pr_cdcooper
                         AND ass.cdcooper = pr_cdcooper
                    ) dados
              ORDER BY 1,2,3,4
        ) grp;     
    rw_grupo_cpf cr_grupo_cpf%ROWTYPE;

    CURSOR cr_ass_contas (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrcpfcgc IN crapass.nrcpfcnpj_base%TYPE) IS
      SELECT ass.nrdconta  
            ,ass.cdcooper
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.Nrcpfcnpj_Base = pr_nrcpfcgc;
    rw_ass_contas cr_ass_contas%ROWTYPE;


    -- ENCONTRAR O MAIOR RISCO DO GRUPO
    CURSOR cr_risco_grupo (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT r.nrdgrupo
           , MAX(r.innivris) risco_grupo
        FROM crapris r
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere
         AND r.nrdgrupo > 0
       GROUP BY r.nrdgrupo;
    rw_risco_grupo cr_risco_grupo%ROWTYPE;

    -- LISTAR TODAS AS CONTAS DE UM GRUPO
    CURSOR cr_contas_grupo (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE) IS
      SELECT *
        FROM (SELECT int.idgrupo
                    ,int.nrdconta
                FROM tbcc_grupo_economico_integ INT
                    ,tbcc_grupo_economico p
               WHERE int.dtexclusao IS NULL
                 AND int.cdcooper = pr_cdcooper
                 AND int.idgrupo  = p.idgrupo
              UNION
              SELECT pai.idgrupo
                    ,pai.nrdconta
                FROM tbcc_grupo_economico       pai
                   , crapass                    ass
                   , tbcc_grupo_economico_integ int
               WHERE ass.cdcooper = pai.cdcooper
                 AND ass.nrdconta = pai.nrdconta
                 AND int.idgrupo  = pai.idgrupo
                 AND int.dtexclusao is NULL
                 AND ass.cdcooper = pr_cdcooper
                 AND pai.cdcooper = pr_cdcooper
            ) dados
       WHERE dados.idgrupo = pr_idgrupo;    
    rw_contas_grupo cr_contas_grupo%ROWTYPE;

    -- Cadastro de informacoes de central de riscos
    CURSOR cr_crapris(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapris.nrdconta%TYPE
                     ,pr_dtrefere IN crapris.dtrefere%TYPE
                     ,pr_innivris IN crapris.innivris%TYPE) IS
      SELECT /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
              ris.cdcooper
             ,ris.dtrefere
             ,ris.nrdconta
             ,ris.innivris
             ,ris.cdmodali
             ,ris.cdorigem
             ,ris.nrctremp
             ,ris.nrseqctr
             ,ris.qtdiaatr
             ,ris.progress_recid
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.nrdconta = pr_nrdconta
         AND ris.innivris < pr_innivris -- Menor que o risco do grupo
         --AND ris.inddocto = 1
         AND (ris.inddocto = 1 OR ris.cdmodali = 1901)
         ;
    rw_crapris cr_crapris%ROWTYPE;

    CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_nrctremp IN crapris.nrctremp%TYPE
                          ,pr_cdmodali IN crapris.cdmodali%TYPE
                          ,pr_cdorigem IN crapris.cdorigem%TYPE
                          ,pr_dtrefere in crapris.dtrefere%TYPE) IS
         SELECT r.dtrefere
              , r.innivris
              , r.dtdrisco
          FROM crapris r
         WHERE r.cdcooper = pr_cdcooper
           AND r.nrdconta = pr_nrdconta
           AND r.dtrefere = pr_dtrefere
           AND r.nrctremp = pr_nrctremp
           AND r.cdmodali = pr_cdmodali
           AND r.cdorigem = pr_cdorigem
           --AND r.inddocto = 1 -- 3020 e 3030
           AND (r.inddocto = 1 OR r.cdmodali = 1901)
         ORDER BY r.dtrefere DESC --> Retornar o ultimo gravado
                , r.innivris DESC --> Retornar o ultimo gravado
                , r.dtdrisco DESC;
    rw_crapris_last cr_crapris_last%ROWTYPE;

    -- cadastro do vencimento do risco
    CURSOR cr_crapvri( pr_cdcooper IN crapris.cdcooper%TYPE
                      ,pr_dtrefere IN crapris.dtrefere%TYPE
                      ,pr_nrdconta IN crapris.nrdconta%TYPE
                      ,pr_innivris IN crapris.innivris%TYPE
                      ,pr_cdmodali IN crapris.cdmodali%TYPE
                      ,pr_nrctremp IN crapris.nrctremp%TYPE
                      ,pr_nrseqctr IN crapris.nrseqctr%TYPE
                      ) IS
      SELECT ROWID
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.nrdconta = pr_nrdconta
         AND vri.innivris = pr_innivris
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr;
    rw_crapvri cr_crapvri%ROWTYPE;



    -- variaveis
    vr_maxrisco             INTEGER:=-10;
    vr_dtdrisco             crapris.dtdrisco%TYPE; -- Data da atualização do risco
    vr_dttrfprj             DATE;
      
    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;
    
    vr_nrcpfcnpj_base       crapass.nrcpfcnpj_base%TYPE;

   BEGIN


     -------------------------------------------------------------
     ----- GRUPO ECONOMICO - GRAVAR GRUPO NA CENTRAL DE RISCO ----
     -------------------------------------------------------------
     -- PERCORRE TODOS OS GRUPOS DA COOPERATIVA
     -- IDENTIFICA EM QUAL GRUPO O CPF/CNPJ DEVE ESTAR
     FOR rw_grupo_cpf IN cr_grupo_cpf (pr_cdcooper => pr_cdcooper) LOOP

       -- PEGAR TODAS AS CONTAS DE UM CPF/CNPJ PARA ATUALIZAR O GRUPO NA CENTRAL
       FOR rw_ass_contas IN cr_ass_contas (pr_cdcooper => pr_cdcooper
                                          ,pr_nrcpfcgc => rw_grupo_cpf.nrcpfcnpj_base) LOOP
         --------
         BEGIN
           -- ATUALIZAR GRUPO NA CENTRAL DE RISCO
           UPDATE crapris r
              SET r.nrdgrupo = rw_grupo_cpf.nrdgrupo
            WHERE r.cdcooper = rw_ass_contas.cdcooper
              AND r.nrdconta = rw_ass_contas.nrdconta
              AND r.dtrefere = pr_dtrefere;

         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'RISC0004.pc_central_risco_grupo - '
                            || 'Erro ao definir G.E. na Central de Risco --> '
                            ||'Conta: '||rw_ass_contas.nrdconta
                            ||'Grupo: '||rw_grupo_cpf.nrdgrupo                            
                            || '. Detalhes:'||SQLERRM;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || 'RISC0004 || ' --> '
                                                         || vr_dscritic );
             RAISE vr_exc_erro;
         END;
         --------
       END LOOP;

     END LOOP;


     ---------------------------------------------------------
     ----- RISCO DO GRUPO - ATUALIZAR NA CENTRAL DE RISCO ----
     ---------------------------------------------------------
     -- AGRUPAR POR GRUPO E VERIFICAR O MAIOR RISCO DO GRUPO
     FOR rw_risco_grupo IN cr_risco_grupo (pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => pr_dtrefere) LOOP

         -- MAIOR RISCO DO GRUPO
       vr_maxrisco := rw_risco_grupo.risco_grupo;
       -- NAO LEVA PARA O PREJUIZO
       IF vr_maxrisco = 10 THEN
         vr_maxrisco := 9;
       END IF;

       -- LISTA DE CONTAS DO GRUPO
       FOR rw_contas_grupo IN cr_contas_grupo (pr_cdcooper => pr_cdcooper
                                              ,pr_idgrupo  => rw_risco_grupo.nrdgrupo) LOOP

         -- BUSCA NA CENTRAL CONTAS QUE TEM RISCO MENOR QUE O RISCO DO GRUPO
         FOR rw_crapris IN cr_crapris(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_contas_grupo.nrdconta
                                     ,pr_dtrefere => pr_dtrefere -- Data do Dia
                                     ,pr_innivris => vr_maxrisco) LOOP

           -- Busca dos dados do ultimo risco de origem 1
           OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
                               ,pr_nrctremp => rw_crapris.nrctremp
                               ,pr_cdmodali => rw_crapris.cdmodali
                               ,pr_cdorigem => rw_crapris.cdorigem
                               ,pr_dtrefere => pr_dtmvtoan); -- Data da Central anterior
           FETCH cr_crapris_last
            INTO rw_crapris_last;
           -- Se encontrou
           IF cr_crapris_last%FOUND THEN
             -- RISCO DE "ONTEM" DIFERENTE DO DE "HOJE" ?
             IF (rw_crapris_last.innivris <> vr_maxrisco) THEN
               vr_dtdrisco := pr_dtrefere;
             ELSE
               -- Utilizar a data do ultimo risco
               IF rw_crapris_last.dtdrisco IS NULL THEN
                 vr_dtdrisco := pr_dtrefere;
               ELSE
                 -- Utilizar a data do ultimo risco
                 vr_dtdrisco := rw_crapris_last.dtdrisco;
               END IF;
             END IF;
           ELSE
             -- Utilizar a data de referência do processo
             vr_dtdrisco := pr_dtrefere;
           END IF;
           -- Fechar o cursor
           CLOSE cr_crapris_last;

           vr_dttrfprj := NULL;
           IF vr_maxrisco >= 9 THEN
             vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                  vr_maxrisco,
                                                                  rw_crapris.qtdiaatr,
                                                                  vr_dtdrisco);
           END IF;

           -- Atualiza CENTRAL de RISCOS
           BEGIN
             UPDATE crapris
                SET crapris.innivris = vr_maxrisco,
                    crapris.inindris = vr_maxrisco,
                    crapris.dtdrisco = vr_dtdrisco,
                    crapris.dttrfprj = vr_dttrfprj
              WHERE cdcooper         = rw_crapris.cdcooper
                AND nrdconta         = rw_crapris.nrdconta
                AND dtrefere         = rw_crapris.dtrefere
                AND innivris         = rw_crapris.innivris
                AND progress_recid   = rw_crapris.progress_recid;
           EXCEPTION
             WHEN OTHERS THEN
               --gera critica
               vr_dscritic := 'risc0004.pc_central_risco_grupo: Erro ao atualizar Riscos G.E.(crapris). '||
                              'Erro: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
           --busca vencimento de riscos
           FOR rw_crapvri IN cr_crapvri( rw_crapris.cdcooper
                                        ,rw_crapris.dtrefere
                                        ,rw_crapris.nrdconta
                                        ,rw_crapris.innivris
                                        ,rw_crapris.cdmodali
                                        ,rw_crapris.nrctremp
                                        ,rw_crapris.nrseqctr ) LOOP

             BEGIN -- atualiza vencimento dos riscos
                UPDATE crapvri
                   SET crapvri.innivris = vr_maxrisco
                 WHERE ROWID = rw_crapvri.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  --gera critica
                   vr_dscritic := 'Erro ao atualizar Vencimento do risco(crapvri). '||
                                  'Erro: '||SQLERRM;
                   RAISE vr_exc_erro;
              END;
            END LOOP; -- FIM FOR rw_crapvri
          END LOOP; -- FIM FOR rw_crapris
        END LOOP; -- FIM FOR rw_contas_grupo

        -- Leitura de todos do grupo para atualizar o risco do grupo
        BEGIN
          UPDATE tbcc_grupo_economico ge
             SET ge.inrisco_grupo = vr_maxrisco
           WHERE ge.cdcooper = pr_cdcooper
             AND ge.idgrupo  = rw_risco_grupo.nrdgrupo;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            vr_dscritic := 'RISC0004.pc_central_risco_grupo - '
                         ||  'Erro ao atualizar Risco do G.E. - '
                           ||'Grupo:'|| rw_risco_grupo.nrdgrupo
                         || '. Detalhes:'||SQLERRM;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || 'RISC0004 || ' --> '
                                                         || vr_dscritic );
            RAISE vr_exc_erro;
        END;
      END LOOP; -- FIM FOR rw_risco_grupo


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
       pr_dscritic := 'Erro nao tratado na RISC0004.pc_central_risco_grupo --> ' || SQLERRM;

  END pc_central_risco_grupo;



  PROCEDURE pc_central_grava_dtdrisco(pr_cdcooper IN NUMBER           --> Cooperativa
                                     ,pr_dtrefere IN DATE             -- Data do dia da Coop
                                     ,pr_dtmvtoan IN DATE             -- Data da central anterior
                                     ,pr_dscritic OUT VARCHAR2) IS   --> Critica
  /* .............................................................................

   Programa: pc_central_grava_dtdrisco       (Antigo: NAO HA)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Outubro/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Gravar da Data do Risco de cada operação
   
   ------------------------------------------------------------------------
               ATENÇÃO: ESTE DEVE SER O UNICO PONTO DO SISTEMA ONDE GRAVA
               A dtdrisco DA CRAPRIS.
   ------------------------------------------------------------------------

   Alteracoes: 
  ............................................................................. */

    -- CURSORES
  
    -- VARIAVEIS LOCAIS


    -- variaveis
    vr_maxrisco             INTEGER:=-10;
    vr_dtdrisco             crapris.dtdrisco%TYPE; -- Data da atualização do risco
    vr_dttrfprj             DATE;
    vr_des_msg              VARCHAR2(500);
    vr_nrcpfcnpj_base       crapass.nrcpfcnpj_base%TYPE;
    
      
    -- VARIAVEIS DE ERRO
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;
  
    BEGIN

   /*------------------------------------------------------------------------
               ATENÇÃO: ESTE DEVE SER O UNICO PONTO DO SISTEMA ONDE GRAVA
               A dtdrisco DA CRAPRIS.
   ------------------------------------------------------------------------*/


    	-- PROCESSAR TODA CENTRAL DE RISCO DA DTREFERE (HOJE)
      
        -- PARA CADA crapRIS, VERIFICAR RISCO DA DATA DTMVTOAN (ONTEM)
        
          -- VALIDAR CONFORME ESTRUTURADO NA ROTINA PC_CENTRAL_RISCO_GRUPO
            -- VERIFICAR SE EXISTE "ONTEM"
              -- SE NÃO EXISTE, GRAVAR DTDRISCO = HOJE
              -- SE EXISTE, VERIFICAR O RISCO DE ONTEM É DIFERENTE DE HOJE
                 -- SE DTDRISCO É NULA, GRAVAR DTDRISCO = HOJE
                 -- SE SIM, GRAVAR DTDRISCO = HOJE
                 -- SE NÃO, GRAVAR DTDRISCO = dtdrisco DE ONTEM
                 -- EFETUAR A VALIDACAO/BUSCA fn_regra_dtprevisao_prejuizo
                 -- GRAVAR DTDRISCO E DTtrfprj PARA CADA CONTRATO
         
      NULL;


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
        pr_dscritic := 'Erro nao tratado na RISC0004.pc_central_risco_grupo --> ' || SQLERRM;

  END pc_central_grava_dtdrisco;
  
  -- Grava saldo refinanciado na crapepr                                
  PROCEDURE pc_gravar_saldo_refin(pr_cdcooper            NUMBER     --> Cooperativa
                                 ,pr_nrdconta            NUMBER     --> Conta
                                 ,pr_nrctremp            NUMBER     --> Contrato
                                 ,pr_devedor_calculado   NUMBER     --> Valor refinanciado
                                 ,pr_dscritic            OUT VARCHAR2) IS
  BEGIN
    
    UPDATE crapepr r
       SET r.vlsaldo_refinanciado = pr_devedor_calculado
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp;
       
  EXCEPTION
    WHEN OTHERS THEN
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na RISC0004.pc_gravar_saldo_refin --> ' 
                      ||'Conta: ' || pr_nrdconta
                      ||'. Contrato: ' || pr_nrctremp  
                      ||'. Detalhes: ' || SQLERRM;
          
  END pc_gravar_saldo_refin; 

END RISC0004;
/
