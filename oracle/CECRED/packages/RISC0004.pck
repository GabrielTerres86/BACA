CREATE OR REPLACE PACKAGE CECRED."RISC0004" IS
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

  --Tipo de Registro para PARAMETROS GERAIS DA CENTRAL DE RISCO
  TYPE typ_reg_ctl_parametros IS
    RECORD (cdcooper                    tbrisco_central_parametros.cdcooper%TYPE
           ,perc_liquid_sem_garantia    tbrisco_central_parametros.perc_liquid_sem_garantia%TYPE
           ,perc_cobert_aplic_bloqueada tbrisco_central_parametros.perc_cobert_aplic_bloqueada%TYPE
           ,inrisco_melhora_minimo      tbrisco_central_parametros.inrisco_melhora_minimo%TYPE
           ,dthr_alteracao              tbrisco_central_parametros.dthr_alteracao%TYPE
           ,cdoperador_alteracao        tbrisco_central_parametros.cdoperador_alteracao%TYPE);
  TYPE typ_tab_ctl_parametros IS TABLE OF typ_reg_ctl_parametros INDEX BY PLS_INTEGER;


  --Tipo de Registro para PARAMETROS GERAIS DA CENTRAL DE RISCO
  TYPE typ_reg_contrato IS
    RECORD (cdcooper                    crapepr.cdcooper%TYPE
           ,nrdconta                    crapepr.nrdconta%TYPE
           ,nrctremp                    crapepr.nrctremp%TYPE
           ,tpctrato                    craplcr.tpctrato%TYPE    -- Tipo do Contrato EPR
           ,tpctrlcr                    craplcr.tpctrato%TYPE    -- Tipo do Contrato da LCR
           ,cdlcremp                    crapepr.cdlcremp%TYPE
           ,dtefetiv                    crapepr.dtmvtolt%TYPE    -- Data Efetivação Contrato
           ,idcobope                    crawepr.idcobope%TYPE -- Id Cobertura Operacao
           ,flgavali                    PLS_INTEGER           -- Indicador se tem Avalista
           ,dscatbem                    crapbpr.dscatbem%TYPE -- Categoria Bem (Tem Garantia)
           ,vlsdeved                    crapepr.vlsdeved%TYPE
           ,dtmvtolt                    crapdat.dtmvtolt%TYPE);
  TYPE typ_tab_contrato IS TABLE OF typ_reg_contrato INDEX BY PLS_INTEGER;

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


FUNCTION fn_busca_rating_operacao(pr_cdcooper NUMBER
                                , pr_nrdconta NUMBER
                                , pr_nrctrato NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE;
  
FUNCTION fn_busca_rating_operacao_efet(pr_cdcooper NUMBER
                                     , pr_nrdconta NUMBER
                                     , pr_nrctrato NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE;

FUNCTION fn_busca_rating_cpfcnpj(pr_cdcooper  NUMBER
                                ,pr_nrcpfcnpj NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE;



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

-- Busca o risco melhora do contrato de empréstimo
FUNCTION fn_busca_risco_melhora(pr_cdcooper   NUMBER
                              , pr_nrdconta   NUMBER
                              , pr_nrctremp   NUMBER
                              , pr_tpctrato   NUMBER)
  RETURN INTEGER;



  FUNCTION fn_verifica_garantias (pr_cdcooper   NUMBER
                                , pr_nrdconta   NUMBER
                                , pr_nrctremp   NUMBER
                                , pr_tpctrato   NUMBER
                                , pr_perc_min   NUMBER
                                , pr_perc_blq   NUMBER)
    RETURN BOOLEAN ;

  FUNCTION fn_verifica_garantias( pr_tab_ctl_param    IN typ_tab_ctl_parametros
                                 ,pr_tab_contrato     IN typ_tab_contrato)
    RETURN BOOLEAN ;

  FUNCTION fn_saldo_aplicacao (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              )
    RETURN NUMBER;

  -- Grava saldo refinanciado na crapepr
  PROCEDURE pc_gravar_saldo_refin(pr_cdcooper            NUMBER     --> Cooperativa
                                 ,pr_nrdconta            NUMBER     --> Conta
                                 ,pr_nrctremp            NUMBER     --> Contrato
                                 ,pr_devedor_calculado   NUMBER     --> Valor refinanciado
                                 ,pr_dscritic OUT VARCHAR2);


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
                                     ,pr_qtdatref OUT NUMBER                 --> Qtde dias atraso refinanciamento
                                     ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_central_risco_grupo(pr_cdcooper IN NUMBER           --> Cooperativa
                                  ,pr_dtrefere IN DATE             -- Data do dia da Coop
                                  ,pr_dtmvtoan IN DATE             -- Data da central anterior
                                  ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_calcula_risco_melhora(pr_cdcooper         IN NUMBER       --> Cooperativa
                                    ,pr_rowidepr         IN ROWID        --> ROWID do Emprestimo (EPR)
                                    ,pr_tpctrato         IN NUMBER       --> Lista de contratos liquidados
                                    ,pr_qtdiaatr         IN NUMBER       --> Dias em atraso do contrato atual
                                    ,pr_cdmodali         IN NUMBER       --> Modalidade do Contrato
                                    ,pr_tab_ctl_param    IN typ_tab_ctl_parametros
                                    ,pr_inrisco_melhora OUT NUMBER       --> Retornar o Risco Melhora
                                    ,pr_dscritic        OUT VARCHAR2);   --> Retorno Critica

  PROCEDURE pc_central_parametros(pr_cdcooper            IN NUMBER           --> Cooperativa
                                 ,pr_tab_ctl_parametros OUT typ_tab_ctl_parametros  --Vetor para o retorno das informações
                                 ,pr_dscritic           OUT VARCHAR2);

  -- Buscar o risco na inclusão e na efetivação  - P450 - Rating
  PROCEDURE pc_busca_risco_inclusao(pr_cdcooper IN NUMBER            --> Cooperativa
                                   ,pr_nrdconta IN NUMBER            --> Conta
                                   ,pr_dsctrliq IN VARCHAR2          --> Lista de Contratos Liquidados
                                   ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Data da cooperativa
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE DEFAULT NULL  --> Número do contrato de emprestimos
                                   ,pr_innivris OUT NUMBER
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2);

 PROCEDURE pc_grava_risco_inclusao( pr_cdcooper           IN NUMBER
                                  , pr_nrdconta           IN NUMBER
                                  , pr_nrctremp           IN NUMBER
                                  , pr_tpctrato           IN NUMBER
                                  , pr_nrcpfcnpj_base     IN NUMBER
                                  , pr_inrisco_inclusao   IN NUMBER
                                  , pr_dscritic           OUT VARCHAR2);
END RISC0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED."RISC0004" AS
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
  -- Alterado:
  --             26/06/2018 - Alterado a tabela CRAPGRP para TBCC_GRUPO_ECONOMICO. (Mario Bernat - AMcom)
  --             24/08/2018 - Inclusão da coluna quantidade de dias de atraso
  --                          PJ 450 - Diego Simas - AMcom
  --
  --             30/10/2018 - P450 - Inclusão da function fn_busca_risco_melhora e atribuicao
  --                          da variavel vr_inrisco_melhora (Douglas Pagel/AMcom)
  --                        - Inclusão da procedure pc_gravar_saldo_refinanciamento (Douglas Pagel/AMcom)
  --             05/12/2018 - Atualizar o nível de risco da conta conforme o maior risco do grupo (Heckmann/AMcom)
  --             14/02/2018 - Inclusão do nível de risco (rating) 1 - AA (Heckmann/AMcom)
  --             15/03/2019 - P450 - Rating, na pc_busca_risco_inclusao, busca risco da centralizadora risco
  --                          das operações (Elton AMcom)
  --             25/04/2019 - P450 - Rating, incluir a tabela craprnc quando a coopertativa for 3 - Ailos (Heckmann/AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------

 -- Busca do nr cpfcnpj base do associado
CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                      ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
SELECT  ass.nrcpfcnpj_base
  FROM crapass ass
WHERE ass.cdcooper = pr_cdcooper
  AND ass.nrdconta = pr_nrdconta;
rw_crapass_ope   cr_crapass_ope%ROWTYPE;

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
  nivel_risco := CASE WHEN pr_dsnivris = 'AA'  THEN 1
                      WHEN pr_dsnivris = 'A'   THEN 2
                      WHEN pr_dsnivris = 'B'   THEN 3
                      WHEN pr_dsnivris = 'C'   THEN 4
                      WHEN pr_dsnivris = 'D'   THEN 5
                      WHEN pr_dsnivris = 'E'   THEN 6
                      WHEN pr_dsnivris = 'F'   THEN 7
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



FUNCTION fn_busca_rating_operacao(pr_cdcooper NUMBER
                                , pr_nrdconta NUMBER
                                , pr_nrctrato NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE AS vr_rating tbrisco_operacoes.inrisco_rating%TYPE;
  -- De acordo com as mudanças no Rating, o Risco Rating deve ser exibido
  -- por operação, e não por CPF/CNPJ
  -- Busca o rating da operação especifica
    CURSOR cr_operacao IS
      SELECT nvl(TRO.INRISCO_RATING_AUTOM,TRO.INRISCO_RATING) INRISCO_RATING
        FROM TBRISCO_OPERACOES TRO
       WHERE TRO.CDCOOPER = pr_cdcooper
         AND tro.nrdconta = pr_nrdconta
         AND tro.nrctremp = pr_nrctrato
        ;
    rw_operacao  cr_operacao%ROWTYPE;
BEGIN
   OPEN cr_operacao;
   FETCH cr_operacao INTO rw_operacao;
   CLOSE cr_operacao;
   
   vr_rating := rw_operacao.inrisco_rating;
 
  RETURN vr_rating;
END fn_busca_rating_operacao;

FUNCTION fn_busca_rating_operacao_efet(pr_cdcooper NUMBER
                                     , pr_nrdconta NUMBER
                                     , pr_nrctrato NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE AS vr_rating tbrisco_operacoes.inrisco_rating%TYPE;
  /* BUSCA APENAS O RATING EFETIVO DA OPERAÇÃO - PARA CENTRAL DE RISCO */
  
  -- De acordo com as mudanças no Rating, o Risco Rating deve ser exibido
  -- por operação, e não por CPF/CNPJ
    CURSOR cr_operacao IS
      SELECT TRO.INRISCO_RATING
        FROM TBRISCO_OPERACOES TRO
       WHERE TRO.CDCOOPER = pr_cdcooper
         AND tro.nrdconta = pr_nrdconta
         AND tro.nrctremp = pr_nrctrato
         AND TRO.INRISCO_RATING_AUTOM IS NOT NULL
         AND ( TRO.INSITUACAO_RATING = 4 --- efetivado
              OR
              (TRO.INSITUACAO_RATING = 3 AND --- vencido
               TRO.Dtrisco_Rating IS NOT NULL)) -- Era Efetivo antes de mudar pra 3-Vencido
        ;
    rw_operacao  cr_operacao%ROWTYPE;
BEGIN
   OPEN cr_operacao;
   FETCH cr_operacao INTO rw_operacao;
   CLOSE cr_operacao;
   
   vr_rating := rw_operacao.inrisco_rating;
 
  RETURN vr_rating;
END fn_busca_rating_operacao_efet;

FUNCTION fn_busca_rating_cpfcnpj(pr_cdcooper  NUMBER
                                ,pr_nrcpfcnpj NUMBER)
  RETURN tbrisco_operacoes.inrisco_rating%TYPE AS vr_rating tbrisco_operacoes.inrisco_rating%TYPE;

    CURSOR cr_operacao IS
      SELECT TRO.CDCOOPER,
             TRO.nrdconta,
             TRO.nrctremp,
             TRO.INRISCO_RATING,
             TRO.DTRISCO_RATING,
             TRO.INSITUACAO_RATING
        FROM TBRISCO_OPERACOES TRO
       WHERE TRO.CDCOOPER       = pr_cdcooper
         AND tro.nrcpfcnpj_base = pr_nrcpfcnpj
         AND TRO.INRISCO_RATING_AUTOM IS NOT NULL
         AND ( TRO.INSITUACAO_RATING = 4 --- efetivado
              OR
              (TRO.INSITUACAO_RATING = 3 AND --- vencido
               TRO.Dtrisco_Rating IS NOT NULL)) -- Era Efetivo antes de mudar pra 3-Vencido
        ;
    rw_operacao  cr_operacao%ROWTYPE;

BEGIN
   OPEN cr_operacao;
   FETCH cr_operacao INTO rw_operacao;
   CLOSE cr_operacao;
   
   vr_rating := rw_operacao.inrisco_rating;  
 
  RETURN vr_rating;
END fn_busca_rating_cpfcnpj;


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

  /* .............................................................................

   Programa: fn_calcula_risco_atraso_adp       (Antigo: NAO HA)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   :
   Data    :                            Ultima atualizacao: 19/01/2018

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Calcular nivel de risco atraso ADP

   Alteracoes: 19/01/2019 - P450 - Alterado para utilizar a mesma regra de calculo do emprestimo.(Odirlei-Ailos)

  ............................................................................. */

BEGIN

  --> Alterado para risco atraso do ADP utlizar o mesmo calculo de risco atraso de emprestimo
    /*risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 'A'
                          WHEN qtdiaatr <   15  THEN 'A'
                          WHEN qtdiaatr <=  30  THEN 'B'
                          WHEN qtdiaatr <=  60  THEN 'D'
                          WHEN qtdiaatr <=  90  THEN 'F'
                          ELSE 'H' END; */

  risco_atraso := fn_calcula_risco_atraso(qtdiaatr => qtdiaatr);

    RETURN risco_atraso;
END fn_calcula_risco_atraso_adp;

-- Callcula nível de risco atraso ADP
FUNCTION fn_calc_niv_risco_atraso_adp(qtdiaatr NUMBER)
    RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;

  /* .............................................................................

   Programa: fn_calc_niv_risco_atraso_adp       (Antigo: NAO HA)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   :
   Data    :                            Ultima atualizacao: 19/01/2018

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Calcular nivel de risco atraso ADP

   Alteracoes: 19/01/2019 - P450 - Alterado para utilizar a mesma regra de calculo do emprestimo.(Odirlei-Ailos)

  ............................................................................. */

BEGIN

  --> Alterado para risco atraso do ADP utlizar o mesmo calculo de risco atraso de emprestimo

    /*risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
                                                WHEN qtdiaatr <   15  THEN 2
                                                WHEN qtdiaatr <=  30  THEN 3
                                                WHEN qtdiaatr <=  60  THEN 5
                                                WHEN qtdiaatr <=  90  THEN 7
                                                ELSE 9 END;*/

  risco_atraso := fn_calcula_niv_risco_atraso(qtdiaatr => qtdiaatr);

    RETURN risco_atraso;
END fn_calc_niv_risco_atraso_adp;

FUNCTION fn_traduz_risco(innivris NUMBER)
  RETURN crawepr.dsnivris%TYPE AS dsnivris crawepr.dsnivris%TYPE;
BEGIN
    dsnivris :=  CASE WHEN innivris = 1  THEN 'AA'
                      WHEN innivris = 2  THEN 'A'
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


-- Busca o risco melhora do contrato de emprestimo --
FUNCTION fn_busca_risco_melhora(pr_cdcooper   NUMBER
                              , pr_nrdconta   NUMBER
                              , pr_nrctremp   NUMBER
                              , pr_tpctrato   NUMBER)
  RETURN INTEGER AS vr_risco_melhora INTEGER;

    --- >>> CURSORES <<< ---
    CURSOR cr_tbrisco_operacoes IS
    SELECT r.inrisco_melhora
      FROM tbrisco_operacoes r
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND r.tpctrato = pr_tpctrato;
    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

BEGIN
  OPEN cr_tbrisco_operacoes;

  FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;

  IF cr_tbrisco_operacoes%NOTFOUND THEN
     vr_risco_melhora := NULL;
  ELSE
     vr_risco_melhora := rw_tbrisco_operacoes.inrisco_melhora;
  END IF;

  CLOSE cr_tbrisco_operacoes;

  RETURN vr_risco_melhora;
END fn_busca_risco_melhora;


  -- VERIFICAR SE O CONTRATO POSSUI GARANTIAS --
  FUNCTION fn_verifica_garantias (pr_cdcooper   NUMBER
                                , pr_nrdconta   NUMBER
                                , pr_nrctremp   NUMBER
                                , pr_tpctrato   NUMBER    -- Tipo do Contrato com base na Linha de Credito (lcr.tpctrato)
                                , pr_perc_min   NUMBER    -- Perc. Minimo da Aplicação
                                , pr_perc_blq   NUMBER)   -- Valor Perc. Parametro Bloqueado
    RETURN BOOLEAN AS vr_tem_garantia BOOLEAN ;

    -- >>> CURSORES <<< ---


    -- >>> VARIAVEIS <<< ---
    vr_sld_bloq_garan    NUMBER(15,2):=0;     -- Valor da Aplicacao que está bloqueado

  BEGIN
     -- ATENCAO: AS GARANTIAS SO SERAO VALIDADAS NA FASE 2 DO RISCO MELHORA
     -- FASE 1 TODOS SERÃO TRATADOS COMO "SEM GARANTIA"
     vr_tem_garantia := FALSE;


     RETURN vr_tem_garantia;

  END fn_verifica_garantias;

  -- VERIFICAR SE O CONTRATO POSSUI GARANTIAS --
  FUNCTION fn_verifica_garantias (pr_tab_ctl_param    IN typ_tab_ctl_parametros
                                 ,pr_tab_contrato     IN typ_tab_contrato)
    RETURN BOOLEAN AS vr_tem_garantia BOOLEAN ;

    -- >>> CURSORES <<< ---


    -- >>> VARIAVEIS <<< ---
    vr_vlbloque_aplica   NUMBER:=0;
    vr_vlbloque_poupa    NUMBER:=0;
    vr_vlaplicacoes      NUMBER:=0;
    vr_dscritic          VARCHAR2(2000);
    vr_ingarantia        INTEGER;


    -- Tipos Linha de Credito (tpctrlcr)
    --    1 Empréstimo
    --    2 Alienação fiduciaria
    --    3 Hipoteca
    --    4 Aplicação
  BEGIN

    -- Iniciar como "SEM GARANTIA"
    vr_tem_garantia := FALSE;




    -- Verificar Garantia Aplicação - Modelo novo
    -- Retornar o valor bloqueado em Garantia Aplicação
    BLOQ0001.pc_calc_bloqueio_garantia(pr_cdcooper        => pr_tab_contrato(1).cdcooper,
                                              pr_nrdconta        => pr_tab_contrato(1).nrdconta,
                                              pr_vlbloque_aplica => vr_vlbloque_aplica,
                                              pr_vlbloque_poupa  => vr_vlbloque_poupa,
                                              pr_dscritic        => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      -- Se deu erro, tratar que não tem garantia
      vr_tem_garantia := FALSE;
    ELSE
      -- Verificar se respeita o % do Parametro
      -- Verificar se o valor Bloqueado Garantia SUPERA o
      -- percentual de Cobertura do Parametro em relação ao Sld Deved. (% do vlsdeved)
      IF (NVL(vr_vlbloque_aplica,0) + NVL(vr_vlbloque_poupa,0)) >
         (pr_tab_contrato(1).vlsdeved * (pr_tab_ctl_param(1).perc_cobert_aplic_bloqueada / 100)) THEN
         vr_tem_garantia := TRUE;
      END IF;
    END IF;


    IF vr_tem_garantia THEN
       vr_ingarantia := 1;
    ELSE
       vr_ingarantia := 0;
    END IF;

    -- Se, SEM GARANTIA, verificar aplicação modelo antigo.
    IF vr_tem_garantia = FALSE THEN
      -- Modelo ANTIGO de Garantia Aplicacao
      vr_vlaplicacoes := fn_saldo_aplicacao(pr_cdcooper => pr_tab_contrato(1).cdcooper
                                           ,pr_nrdconta => pr_tab_contrato(1).nrdconta
                                           ,pr_dtmvtolt => pr_tab_contrato(1).dtmvtolt);
      -- Valor Aplicação  >= Saldo Devedor
      IF vr_vlaplicacoes  >= pr_tab_contrato(1).vlsdeved THEN
         vr_tem_garantia := TRUE;
      END IF;
    END IF;

    IF vr_tem_garantia THEN
       vr_ingarantia := 1;
    ELSE
       vr_ingarantia := 0;
    END IF;



    -- Se, SEM GARANTIA, verificar Avalista
    IF vr_tem_garantia = FALSE THEN
      -- Verificação se tem Garantia PESSOAL (Avalista)
      IF pr_tab_contrato(1).flgavali = 1 THEN
        vr_tem_garantia := TRUE;
      END IF;
    END IF;
    IF vr_tem_garantia THEN
       vr_ingarantia := 1;
    ELSE
       vr_ingarantia := 0;
    END IF;


    -- Se, SEM GARANTIA, verificar Bens Imoveis/Veiculos
    IF vr_tem_garantia = FALSE THEN
      -- Verificar BENS do Contrato (Alienado, Nao Baixado e Não Cancelado)
      IF pr_tab_contrato(1).dscatbem IS NOT NULL THEN
        -- Tem BEM IMOVEL/VEICULO/MAQUINA/EQUIPAMENTO como Garantia
        vr_tem_garantia := TRUE;
      END IF;
    END IF;
    IF vr_tem_garantia THEN
       vr_ingarantia := 1;
        ELSE
       vr_ingarantia := 0;
        END IF;



    RETURN vr_tem_garantia;

  END fn_verifica_garantias;

  FUNCTION fn_saldo_aplicacao (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              )
    RETURN NUMBER AS vr_vlgarantia NUMBER ;

    vr_ind              INTEGER:=0;
    vr_vlsldapl         NUMBER:=0;
    vr_vlsldtot         NUMBER:=0;
    vr_vlsldrgt         NUMBER:=0;
    vr_cdcritic         NUMBER:=0;
    vr_dscritic         VARCHAR2(2000);
    vr_des_reto         VARCHAR2(100);
    vr_tab_saldo_rdca   APLI0001.typ_tab_saldo_rdca;
    vr_tab_erro         gene0001.typ_tab_erro;

  BEGIN

    vr_vlgarantia := 0;

    apli0002.pc_obtem_dados_aplicacoes(pr_cdcooper => pr_cdcooper,
                                              pr_cdagenci => 1,
                                              pr_nrdcaixa => 1,
                                              pr_cdoperad => '1',
                                              pr_nmdatela => 'ATENDA',
                                              pr_idorigem => 5,
                                              pr_nrdconta => pr_nrdconta,
                                              pr_idseqttl => 1,
                                              pr_nraplica => 0,
                                              pr_cdprogra => 'ATENDA',
                                              pr_flgerlog => 0,
                                              pr_dtiniper => NULL,
                                              pr_dtfimper => NULL,
                                              pr_vlsldapl => vr_vlsldapl,
                                              pr_des_reto => vr_des_reto,
                                              pr_tab_saldo_rdca => vr_tab_saldo_rdca,
                                              pr_tab_erro => vr_tab_erro);
    IF vr_des_reto = 'NOK' THEN
      RETURN 0;
    END IF;

    vr_ind := vr_tab_saldo_rdca.first;
    WHILE vr_ind IS NOT NULL LOOP
      -- Somar o valor de resgate
      vr_vlgarantia := vr_vlgarantia + vr_tab_saldo_rdca(vr_ind).sldresga;
      vr_ind      := vr_tab_saldo_rdca.next(vr_ind);
    END LOOP;

    --> Buscar saldo das aplicacoes
    APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                      ,pr_cdoperad => '1'           --> Código do Operador
                                      ,pr_nmdatela => 'ATENDA'      --> Nome da Tela
                                      ,pr_idorigem => 5             --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                      ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                      ,pr_idseqttl => 1             --> Titular da Conta
                                      ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Data de Movimento
                                      ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
                                      ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                      ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
                                      ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
                                      ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RETURN 0;
    END IF;

    vr_vlgarantia := vr_vlgarantia + vr_vlsldrgt;

    RETURN vr_vlgarantia;

  END fn_saldo_aplicacao;


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
       , ris1.dtinictr
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
       , ris3.dtinictr
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

  -- Cursor de buscar o maior risco do borderô
  CURSOR cr_crapbdt_ris(pr_cdcooper crapbdt.cdcooper%TYPE
                       ,pr_nrdconta crapbdt.nrdconta%TYPE) IS
    SELECT
      MAX(bdt.nrinrisc) AS nrinrisc_max,
      bdt.qtdirisc
    FROM crapbdt bdt
    WHERE bdt.cdcooper = pr_cdcooper
      AND bdt.nrdconta = pr_nrdconta
      AND nrinrisc > 1
      AND bdt.insitbdt <> 4
    GROUP BY qtdirisc
    ORDER BY  max(nrinrisc) DESC, qtdirisc DESC;
  rw_crapbdt_ris cr_crapbdt_ris%ROWTYPE;

  --> Buscar cessao de cartão
  CURSOR cr_tbcessao (pr_cdcooper  tbcrd_cessao_credito.cdcooper%TYPE,
                      pr_nrdconta  tbcrd_cessao_credito.nrdconta%TYPE,
                      pr_nrctremp  tbcrd_cessao_credito.nrctremp%TYPE)IS
    SELECT ces.dtvencto,
           'S' incessao
      FROM tbcrd_cessao_credito ces
     WHERE ces.cdcooper = pr_cdcooper
       AND ces.nrdconta = pr_nrdconta
       AND ces.nrctremp = pr_nrctremp;
  rw_tbcessao cr_tbcessao%ROWTYPE;

  ----------- VARIAVEIS ------------------
  rw_crapdat             cr_dat%ROWTYPE;     -- Calendário de datas da cooperativa

  vr_nrctremp            crapris.nrctremp%TYPE;
  vr_cdmodali            crapris.cdmodali%TYPE;
  vr_jaexiste            INTEGER;
  vr_nrdgrupo            crapris.nrdgrupo%TYPE;
  vr_chtabcpf            VARCHAR2(14);           -- Chave para a tabela que armazena o risco CPF
  vr_indrowid            INTEGER;                -- Índice para a tabela de ROWIDs a atualizar para o risco CPF
  vr_rowidocr            ROWID;                  -- ROWID do registro inserido na TBRISCO_CENTRAL_OCR
  vr_idx_grp             VARCHAR2(18);
                         
  vr_inrisco_inclusao    tbrisco_central_ocr.inrisco_inclusao%TYPE;
  vr_inrisco_rating      tbrisco_central_ocr.inrisco_rating%TYPE;
  vr_inrisco_atraso      tbrisco_central_ocr.inrisco_atraso%TYPE;
  vr_inrisco_agravado    tbrisco_central_ocr.inrisco_agravado%TYPE;
  vr_inrisco_melhora     tbrisco_central_ocr.inrisco_melhora%TYPE;
  vr_inrisco_operacao    tbrisco_central_ocr.inrisco_operacao%TYPE;
  vr_inrisco_refin       tbrisco_central_ocr.inrisco_refin%TYPE;
  vr_inrisco_grupo       tbrisco_central_ocr.inrisco_grupo%TYPE;
  vr_inrisco_final       tbrisco_central_ocr.inrisco_final%TYPE;

  vr_qtdias_atraso_refin crapepr.qtdias_atraso_refin%TYPE;
  vr_qtddiatr_ces        INTEGER;
  vr_dtcorte_cessao      DATE := NULL;
  vr_dscritic            VARCHAR2(500);

  vr_habrat              VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

BEGIN

  vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                         pr_cdcooper => pr_cdcooper,
                                         pr_cdacesso => 'HABILITA_RATING_NOVO');

  -- Carrega o calendário de datas da cooperativa
  OPEN cr_dat(pr_cdcooper);
  FETCH cr_dat INTO rw_crapdat;
  CLOSE cr_dat;

  --> Buscar data de corte para
  BEGIN
    vr_dtcorte_cessao := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                           pr_cdcooper => pr_cdcooper,
                                                           pr_cdacesso => 'DTCESSAO_CORTE_ATRASO'),'DD/MM/RRRR');

  EXCEPTION
    WHEN OTHERS THEN
      vr_dtcorte_cessao := to_date('01/01/2000','DD/MM/RRRR');
  END;

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

    vr_cdmodali      := rw_crapris.cdmodali;
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

    -- iniciar rowtype antes do IF para nao deixar sujeira
    rw_tbcessao := NULL;

    IF vr_cdmodali = 299 THEN

      --> Buscar cessao de cartão
      OPEN cr_tbcessao (pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => rw_crapris.nrdconta,
                        pr_nrctremp  => rw_crapris.nrctremp);
      FETCH cr_tbcessao INTO rw_tbcessao;
      CLOSE cr_tbcessao;

    END IF;

    --> Se for cessão e que a data do contrato seja a partir da data de corte
    IF rw_tbcessao.incessao = 'S' AND
      rw_crapris.dtinictr >= vr_dtcorte_cessao THEN

      --> Calcular qtd dias de atraso a partir do do vencto
      vr_qtddiatr_ces := rw_crapdat.dtmvtoan - rw_tbcessao.dtvencto;

      -- Calcula o risco Atraso
      vr_inrisco_atraso := fn_traduz_nivel_risco(CASE WHEN vr_cdmodali IN (101,201, 1901)
                                                      THEN fn_calcula_risco_atraso_adp(vr_qtddiatr_ces)
                                                      ELSE fn_calcula_risco_atraso(vr_qtddiatr_ces) END);
    ELSE
      -- Calcula o risco Atraso
      vr_inrisco_atraso := fn_traduz_nivel_risco(CASE WHEN vr_cdmodali IN (101,201, 1901)
                                                      THEN fn_calcula_risco_atraso_adp(rw_crapris.qtdiaatr)
                                                      ELSE fn_calcula_risco_atraso(rw_crapris.qtdiaatr) END);

    END IF;
    -- Calcula o risco Agravado
    vr_inrisco_agravado := fn_busca_risco_agravado(pr_cdcooper
                                                 , rw_crapris.nrdconta
                                                 , rw_crapdat.dtmvtoan);

    -- Calula o risco Rating
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
      vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating_conta(pr_cdcooper
                                                                      ,rw_crapris.nrdconta));
    ELSE
      -- P450 - Rating
      vr_inrisco_rating  := fn_busca_rating_operacao_efet(pr_cdcooper
                                                         ,rw_crapris.nrdconta
                                                         ,vr_nrctremp);
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Calcula os riscos Inclusão, Melhora e Refin
    IF vr_cdmodali IN (299,499) THEN
      OPEN cr_crapepr(rw_crapris.nrdconta
                    , vr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      CLOSE cr_crapepr;

      vr_inrisco_refin    := rw_crapepr.inrisco_refin;
      vr_inrisco_inclusao := fn_traduz_nivel_risco(rw_crapepr.dsnivori);
      vr_inrisco_melhora  := fn_busca_risco_melhora(pr_cdcooper   => pr_cdcooper
                                                   ,pr_nrdconta   => rw_crapris.nrdconta
                                                   ,pr_nrctremp   => vr_nrctremp
                                                   ,pr_tpctrato   => 90);
      vr_qtdias_atraso_refin := rw_crapepr.qtdias_atraso_refin;
    ELSIF vr_cdmodali IN (301) THEN -- Desconto de Títulos, calcular o pior risco do borderô
      OPEN cr_crapbdt_ris(pr_cdcooper
                         ,rw_crapris.nrdconta);
      FETCH cr_crapbdt_ris INTO rw_crapbdt_ris;
      CLOSE cr_crapbdt_ris;
      vr_inrisco_refin       := NULL;
      vr_inrisco_inclusao    := rw_crapbdt_ris.nrinrisc_max;
      vr_inrisco_melhora     := NULL;
      vr_qtdias_atraso_refin := 0;
      vr_inrisco_atraso      := rw_crapbdt_ris.nrinrisc_max;
    ELSE
      vr_inrisco_refin       := NULL;
      vr_inrisco_inclusao    := 2;
      vr_inrisco_melhora     := NULL;
      vr_qtdias_atraso_refin := 0;
    END IF;


    -- CALCULA O RISCO OPERAÇÃO  -> O Risco da Operação é o PIOR entre os riscos
    IF vr_inrisco_melhora IS NULL THEN
      -- Sem MELHORA => PIOR ENTRE => INC/ATR/RAT/AGR/REF
      vr_inrisco_operacao := GREATEST(NVL(vr_inrisco_inclusao,2)
                                     ,NVL(vr_inrisco_atraso,2)
                                     ,NVL(vr_inrisco_rating,2)
                                     ,NVL(vr_inrisco_agravado,2)
                                     ,NVL(vr_inrisco_refin,2) );
    ELSE
      -- Quando há MELHORA, não considera INCLUSAO e REFIN
      -- Com MELHORA => PIOR ENTRE => ATR/RAT/AGR/MEL
      vr_inrisco_operacao := GREATEST(NVL(vr_inrisco_atraso,2)
                                     ,NVL(vr_inrisco_rating,2)
                                     ,NVL(vr_inrisco_agravado,2)
                                     ,NVL(vr_inrisco_melhora,2) );
    END IF;

    -- Tratamento para Contrato em Prejuizo
    IF rw_crapris.innivris = 10 THEN
      vr_inrisco_operacao := 10;
    END IF;

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
      , qtdias_atraso_refin
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
      , vr_qtdias_atraso_refin
    ) RETURNING ROWID INTO vr_rowidocr;

    -- Não levar o risco HH para o CPF, máximo H
    IF vr_inrisco_operacao = 10 THEN
      vr_inrisco_operacao := 9;
    END IF;

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
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
      vr_inrisco_rating := fn_traduz_nivel_risco(fn_busca_rating_conta(pr_cdcooper
                                                                      ,rw_crapass.nrdconta));
    ELSE
      -- P450 - Rating
      vr_inrisco_rating  := fn_busca_rating_operacao_efet(pr_cdcooper
                                                         ,rw_crapass.nrdconta
                                                         ,rw_crapass.nrdconta);
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

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

     pr_qtdatref := nvl(rw_qtdatref.qtdatref,0);

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

   Alteracoes: 01/10/2018 - P450 - Arrasto do risco para Limite de Credito (Fabio/AMcom)
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
               vr_dscritic := 'RISC0004.pc_central_risco_grupo: Erro ao atualizar Riscos G.E.(crapris). '||
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

          -- Atualizar o nível de risco da conta conforme o maior risco do grupo (Heckmann/AMcom)
          BEGIN
            UPDATE crapass
               SET dsnivris = fn_traduz_risco(vr_maxrisco)
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = rw_contas_grupo.nrdconta;
          EXCEPTION
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao atualizar o nível de risco da conta conforme o maior risco do grupo (crapass). '||
                           'Erro: '||SQLERRM;
            RAISE vr_exc_erro;
          END; -- Fim atualização do nível de risco do grupo

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




  PROCEDURE pc_grava_critica_melhora(pr_cdcooper          IN NUMBER
                                   , pr_nrdconta          IN NUMBER
                                   , pr_nrctremp          IN NUMBER
                                   , pr_tpctrato          IN NUMBER
                                   , pr_cdcritic_melhora  IN NUMBER
                                   , pr_dscritic         OUT VARCHAR2) IS
  /* .............................................................................

   Programa: pc_grava_critica_melhora       (Antigo: NAO HA)
   Sistema : Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Novembro/2018.                        Ultima atualizacao: 10.05.2019

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Gravar a Critica para o não-cálculo do Risco Melhora

   Alteracoes: 10/05/2019  - P450 - Rating. pc_grava_risco_melhora, gravar cpfcnpj base 
                             ao inserir tbrisco_operacoes (AMcom - Mario)

  ............................................................................. */

 -- Busca do nr cpfcnpj base do associado
CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                      ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
  SELECT  ass.nrcpfcnpj_base
    FROM crapass ass
  WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta;
  rw_crapass_ope   cr_crapass_ope%ROWTYPE;

  vr_des_erro    VARCHAR2(2000);
  vr_exc_erro    EXCEPTION;
/*---------------------------------------
  TABELA DE CRITICAS DE NÃO CALCULO DO MELHORA:
    0) EMPRESTIMO NAO ENCONTRADO
    1) CALCULO DO RISCO MELHORA EXECUTADO APENAS NO PRIMEIRO DIA DO MES
    2) RISCO MELHORA JA CALCULADO NO MES
    3) EMPRESTIMO DIFERENTE DE PP E POS (EXCLUSIVO PARA ESSES)
    4) EMPRESTIMO NAO TEM RISCO REFIN CALCULADO
    5) COOPERADO COM PREJUIZO ATIVO
    6) CONTRATO COM MAIS DE 4 DIAS DE ATRASO
    7) NAO FOI GRAVADO SALDO REFINANCIADO OU É ZERO
    8) SEM GARANTIA, PERC.MIN DE LIQUIDACAO SALDO REFINANCIADO NAO ALCANÇADO
    9) ADIMPLENCIA COM GARANTIA NÃO ATENDIDA
   10) ADIMPLENCIA SEM GARANTIA NÃO ATENDIDA
   11) RISCO OPERACAO MENOR OU IGUAL AO RISCO MELHORA MINIMO
   12) RISCO OPERACAO MENOR OU IGUAL AO MAIOR RISCO ENTRE RAT/ATR/AGR
   13) MELHORA MINIMO JA ATINGIDO (MEL)
   14) MELHORA MINIMO JA ATINGIDO (REF)
   15) QUALIF.OPERAC. NÃO PERMITE "MELHORA"
   16) RISCO INCLUSÃO ESTÁ NO VALOR MINIMO "A"
---------------------------------------*/

  BEGIN
    pr_dscritic := NULL;

    -- Se a critica vier nula ou 0, não grava nada
    IF pr_cdcritic_melhora > 0 THEN

      -- Faz o UPDATE do registro
      BEGIN
         UPDATE TBRISCO_OPERACOES t
            SET t.cdcritica_melhora = pr_cdcritic_melhora
          WHERE t.cdcooper = pr_cdcooper
            AND t.nrdconta = pr_nrdconta
            AND t.nrctremp = pr_nrctremp
            AND t.tpctrato = pr_tpctrato;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := ' Detalhes[2]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

      -- Se igual a 0, nao encontrou. Fazer INSERT
      IF SQL%ROWCOUNT = 0 THEN
        --Buscar o CPF CNPJ Base do Associado  - P450 - Rating
        OPEN cr_crapass_ope(pr_cdcooper
                           ,pr_nrdconta);
        FETCH cr_crapass_ope INTO rw_crapass_ope;
        CLOSE cr_crapass_ope;
        BEGIN
          INSERT INTO TBRISCO_OPERACOES
                     (cdcooper,
                      nrdconta,
                      nrctremp,
                      tpctrato,
                      inrisco_inclusao,
                      inrisco_calculado,
                      inrisco_melhora,
                      dtrisco_melhora,
                      cdcritica_melhora,
                      --p450 - rating
                      nrcpfcnpj_base)
                VALUES (pr_cdcooper,
                        pr_nrdconta,
                        pr_nrctremp,
                        pr_tpctrato,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        pr_cdcritic_melhora,
                        rw_crapass_ope.nrcpfcnpj_base
                       );
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := ' Detalhes[1]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_erro;
        END;
      END IF;
    END IF;

   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       pr_dscritic := 'Erro RISC0004.pc_grava_critica_melhora --> ' ||pr_dscritic;

     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na RISC0004.pc_grava_critica_melhora --> ' || SQLERRM;

  END pc_grava_critica_melhora;

  PROCEDURE pc_grava_risco_melhora(pr_cdcooper          IN NUMBER
                                 , pr_nrdconta          IN NUMBER
                                 , pr_nrctremp          IN NUMBER
                                 , pr_tpctrato          IN NUMBER
                                 , pr_inrisco_melhora   IN NUMBER
                                 , pr_dtrisco_melhora   IN DATE
                                 , pr_dscritic         OUT VARCHAR2) IS
  /* .............................................................................

   Programa: pc_grava_risco_melhora       (Antigo: NAO HA)
   Sistema : Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Novembro/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Gravar o resultado do cálculo do Risco Melhora

   Alteracoes: 14/03/2019  - P450 - Rating. pc_grava_risco_melhora, gravar cpfcnpj base 
                             ao inserir tbrisco_operacoes
  ............................................................................. */

  CURSOR cr_operacao IS
    SELECT 1
      FROM tbrisco_operacoes t
      WHERE t.cdcooper = pr_cdcooper
        AND t.nrdconta = pr_nrdconta
        AND t.nrctremp = pr_nrctremp
        AND t.tpctrato = pr_tpctrato;
  rw_operacao cr_operacao%ROWTYPE;


  vr_des_erro   VARCHAR2(2000);
  vr_exc_erro   EXCEPTION;
  BEGIN
    pr_dscritic := NULL;

    -- Se a critica vier nula ou 0, não grava nada
    IF pr_inrisco_melhora > 0 THEN

      -- Faz o UPDATE do registro
      BEGIN
        UPDATE TBRISCO_OPERACOES t
           SET t.inrisco_melhora   = pr_inrisco_melhora
              ,t.dtrisco_melhora   = pr_dtrisco_melhora
              ,t.cdcritica_melhora = NULL -- Quando atualizar, zera a critica
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp
           AND t.tpctrato = pr_tpctrato;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := ' Detalhes[1]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

      -- Se igual a 0, nao encontrou. Fazer INSERT
      IF SQL%ROWCOUNT = 0 THEN
        BEGIN

          --Buscar o CPF CNPJ Base do Associado  - P450 - Rating
          OPEN cr_crapass_ope(pr_cdcooper
                             ,pr_nrdconta);
          FETCH cr_crapass_ope INTO rw_crapass_ope;
          CLOSE cr_crapass_ope;
          ----
          INSERT INTO TBRISCO_OPERACOES
                     (cdcooper,
                      nrdconta,
                      nrctremp,
                      tpctrato,
                      inrisco_inclusao,
                      inrisco_calculado,
                      inrisco_melhora,
                      dtrisco_melhora,
                      cdcritica_melhora,
                      --p450 - rating
                      nrcpfcnpj_base)
                VALUES (pr_cdcooper,
                        pr_nrdconta,
                        pr_nrctremp,
                        pr_tpctrato,
                        NULL,
                        NULL,
                        pr_inrisco_melhora,
                        pr_dtrisco_melhora,
                        NULL,
                        rw_crapass_ope.nrcpfcnpj_base
                       );
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := ' Detalhes[2]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_erro;
        END;
      END IF;


      -- MANTER ATUALIZANDO O RISCO DSNIVRIS ENQUANTO NAO FOR REMOVIDO DEFINITIVO
      BEGIN
         UPDATE crawepr t
            SET t.dsnivris = pr_inrisco_melhora
          WHERE t.cdcooper = pr_cdcooper
            AND t.nrdconta = pr_nrdconta
            AND t.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := ' Detalhes[3]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

    END IF;


   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       pr_dscritic := 'Erro RISC0004.pc_grava_risco_melhora --> ' ||pr_dscritic;


     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na RISC0004.pc_grava_risco_melhora --> ' || SQLERRM;

  END pc_grava_risco_melhora;


  -- Procedure responsavel por validar se deve calcular risco melhora e retornar qual o risco
 PROCEDURE pc_calcula_risco_melhora(pr_cdcooper         IN NUMBER       --> Cooperativa
                                   ,pr_rowidepr         IN ROWID        --> ROWID do Emprestimo (EPR)
                                   ,pr_tpctrato         IN NUMBER       --> Lista de contratos liquidados
                                   ,pr_qtdiaatr         IN NUMBER       --> Dias em atraso do contrato atual
                                   ,pr_cdmodali         IN NUMBER       --> Modalidade do Contrato
                                   ,pr_tab_ctl_param    IN typ_tab_ctl_parametros
                                   ,pr_inrisco_melhora OUT NUMBER       --> Retornar o Risco Melhora
                                   ,pr_dscritic        OUT VARCHAR2) IS --> Critica
  /* .............................................................................

   Programa: pc_calcula_risco_melhora       (Antigo: NAO HA)
   Sistema : Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Novembro/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Procedure responsável por fazer todas as validações pertinentes ao
               do Risco Melhora e, quando sucesso, indicar/retornar o nível ao final

   Alteracoes: 15/08/2019 - P450 - Ajuste para ser aplicado o Risco Melhora em operações com classificação 
                            1-Normal e 2-Renovação que tenham o risco de inclusão diferente de A. (Heckmann - AMcom)
  ............................................................................. */
  -- CURSORES
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  CURSOR cr_emprest(pr_rowidepr IN ROWID) IS
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
          ,e.dtmvtolt -- Data Efetivação
          ,e.cdlcremp
          ,e.tpemprst
          ,e.qtprepag -- QTD Parcelas Pagas
          ,e.qtmesdec -- QTD Meses Decorridos
          ,e.inrisco_refin
          ,t.inrisco_melhora
          ,t.dtrisco_melhora
          ,e.vlsaldo_refinanciado
          ,NVL(e.vlsdeved,0) vlsdeved
          ,NVL(e.vlemprst,0) vlemprst
          ,l.tpctrato -- Tipo Contrato na Linha de Credito
          ,l.permingr
          ,TRIM(b.dscatbem) dscatbem
          ,b.vlmerbem
          ,( CASE
               WHEN w.nrctaav1 > 0 OR
                    w.nrctaav2 > 0 OR
                    w.nmdaval1 <> ' ' OR
                    w.nmdaval2 <> ' '
                 THEN 1
               ELSE 0
             END ) flgavali          -- Se tem avalista
          ,w.idcobope          -- Cobertura Aplicacao
          ,e.idquaprc          -- Qualificacao da operacao
          ,w.dsnivori dsriscoinc  -- Risco Inclusao
      FROM crapepr e, crawepr w, crapbpr b
         , tbrisco_operacoes t, craplcr l
     WHERE e.rowid       = PR_ROWIDEPR  -- Rowid do Emprestimo
       AND W.CDCOOPER    = e.cdcooper
       AND W.NRDCONTA    = e.nrdconta
       AND W.Nrctremp    = e.nrctremp
       AND l.cdcooper    = e.cdcooper
       AND l.cdlcremp    = e.cdlcremp
       AND t.cdcooper(+) = e.cdcooper
       AND t.nrdconta(+) = e.nrdconta
       AND t.nrctremp(+) = e.nrctremp
       AND t.tpctrato(+) = 90
       AND b.cdcooper(+) = e.cdcooper
       AND b.nrdconta(+) = e.nrdconta
       AND b.nrctrpro(+) = e.nrctremp
       AND b.tpctrpro(+) = 90
       AND b.flgalien(+) = 1  -- Deve estar Alienado
       AND b.flgbaixa(+) = 0  -- Não pode ter sido Baixado
       AND b.flcancel(+) = 0  -- Não pode ter sido Cancelado
     ORDER BY e.nrctremp;
  rw_crapepr   cr_emprest%ROWTYPE;

  CURSOR cr_central (pr_cdcooper IN crapris.cdcooper%TYPE
                    ,pr_nrdconta IN crapris.nrdconta%TYPE
                    ,pr_nrctremp IN crapris.nrctremp%TYPE
                    ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
    SELECT t.inrisco_operacao
          ,t.inrisco_rating
          ,t.inrisco_refin
          ,t.inrisco_melhora
          ,t.inrisco_atraso
          ,t.inrisco_agravado
      FROM tbrisco_central_ocr t
     WHERE t.cdcooper = pr_cdcooper
       AND t.dtrefere = pr_dtrefere
       AND t.nrdconta = pr_nrdconta
       AND t.nrctremp = pr_nrctremp
       AND t.cdmodali = pr_cdmodali;
  rw_central cr_central%ROWTYPE;

  -- Variáveis
  vr_cdcritic             crapcri.cdcritic%TYPE;
  vr_dscritic             VARCHAR2(4000);
  vr_exc_erro             EXCEPTION;
  vr_grava_log            EXCEPTION;  -- Usado para criticas da validação do Risco Melhora


  -- Variáveis de uso comum
  vr_cdcritica_melhora    NUMBER;
  vr_dtrefere             DATE;
  vr_tem_garantias        BOOLEAN:=FALSE;
  vr_melhora_novo         INTEGER;
  vr_risco_atual          INTEGER;

  vr_sucesso              BOOLEAN:=TRUE;

  vr_tab_contrato         RISC0004.typ_tab_contrato;

  BEGIN

    pr_inrisco_melhora := NULL;

    -- Busca data de movimento
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;


    -- Data para Central Anterior
    IF to_char(rw_crapdat.dtmvtoan, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
      vr_dtrefere := rw_crapdat.dtmvtoan;
    ELSE
      vr_dtrefere := rw_crapdat.dtultdma;
    END IF;

    -- Verificar Emprestimo
    OPEN cr_emprest(pr_rowidepr => pr_rowidepr);
    FETCH cr_emprest INTO rw_crapepr;
    IF cr_emprest%NOTFOUND THEN
      CLOSE cr_emprest;
      vr_cdcritica_melhora := 0;  -- 0) EMPRESTIMO NAO ENCONTRADO
      RAISE vr_grava_log;
    END IF;
    CLOSE cr_emprest;



    -- Montar a vr_tab de emprestimos (passar para o fn_verifica_garantias)
    vr_tab_contrato.delete;
    vr_tab_contrato(1).cdcooper := pr_cdcooper;
    vr_tab_contrato(1).nrdconta := rw_crapepr.nrdconta;
    vr_tab_contrato(1).nrctremp := rw_crapepr.nrctremp;
    vr_tab_contrato(1).cdlcremp := rw_crapepr.cdlcremp;
    vr_tab_contrato(1).dtefetiv := rw_crapepr.dtmvtolt;
    vr_tab_contrato(1).idcobope := nvl(rw_crapepr.idcobope,0);
    vr_tab_contrato(1).tpctrlcr := 90;
    vr_tab_contrato(1).flgavali := rw_crapepr.flgavali;
    vr_tab_contrato(1).tpctrlcr := rw_crapepr.tpctrato;
    vr_tab_contrato(1).dscatbem := rw_crapepr.dscatbem;
    vr_tab_contrato(1).vlsdeved := rw_crapepr.vlsdeved;
    vr_tab_contrato(1).dtmvtolt := rw_crapdat.dtmvtolt; -- Data do Movimento


    -- Quando o Risco Melhora rodar DIARIO, essa validação será removida
    IF to_char(rw_crapdat.dtmvtoan, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
--      IF rw_crapdat.dtmvtolt <> to_date('05/12/2018','dd/mm/yyyy') THEN --> Condicao apenas para rodar pelo menos 1 vez em 2018 (DtLiberacao = 04/12)
    -- 1) CALCULO DO RISCO MELHORA EXECUTADO APENAS NO PRIMEIRO DIA DO MES
      vr_cdcritica_melhora := 1;
      RAISE vr_grava_log;
--      END IF;
    END IF;

    IF  rw_crapepr.dtrisco_melhora IS NOT NULL
    AND to_char(rw_crapepr.dtrisco_melhora, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
      -- 2) RISCO MELHORA JA CALCULADO NO MES
      vr_cdcritica_melhora := 2;
      RAISE vr_grava_log;
    END IF;


    IF rw_crapepr.tpemprst NOT IN(1,2) THEN
    -- 3) EMPRESTIMO DIFERENTE DE PP E POS (EXCLUSIVO PARA ESSES)
      vr_cdcritica_melhora := 3;
      RAISE vr_grava_log;
    END IF;

    IF PREJ0003.fn_verifica_preju_ativo(pr_cdcooper => pr_cdcooper
                                      , pr_nrdconta => rw_crapepr.nrdconta
                                      , pr_tipverif => 1 ) THEN
      -- 5) COOPERADO COM PREJUIZO ATIVO (C/C ou EPR ou DSC TIT)
      vr_cdcritica_melhora := 5;
      RAISE vr_grava_log;
    END IF;

    IF pr_qtdiaatr > 4 THEN
    -- 6) CONTRATO COM MAIS DE 4 DIAS DE ATRASO
      vr_cdcritica_melhora := 6;
      RAISE vr_grava_log;
    END IF;

    -- VERIFICAR GARANTIAS
    vr_tem_garantias := RISC0004.fn_verifica_garantias(pr_tab_ctl_param => pr_tab_ctl_param
                                                      ,pr_tab_contrato  => vr_tab_contrato);


    -- Se for Sem Garantia, deve liquidar % minimo do saldo refinanciado, conforme parametro
    IF NOT vr_tem_garantias THEN
      
      IF (rw_crapepr.vlsaldo_refinanciado IS NULL
      OR rw_crapepr.vlsaldo_refinanciado = 0)
      AND rw_crapepr.idquaprc IN(3,4) THEN
        -- 7) NAO FOI GRAVADO SALDO REFINANCIADO OU É ZERO
        vr_cdcritica_melhora := 7;
        RAISE vr_grava_log;
      ELSE
        IF rw_crapepr.idquaprc IN(3,4) THEN
          IF  (rw_crapepr.vlsdeved / rw_crapepr.vlsaldo_refinanciado) >
              ((100 - pr_tab_ctl_param(1).perc_liquid_sem_garantia)/100) THEN
            -- 8) SEM GARANTIA, PERC.MIN DE LIQUIDACAO SALDO REFINANCIADO NAO ALCANÇADO
            vr_cdcritica_melhora := 8;--alterado (era 7)
            RAISE vr_grava_log;
          END IF;
        ELSE
          -- Para rw_crapepr.idquaprc IN(1,2) deve-se utilizar
          -- o Valor Emprestado e nao o Saldo Refinanciado
          IF  (rw_crapepr.vlsdeved / rw_crapepr.vlemprst) >
              ((100 - pr_tab_ctl_param(1).perc_liquid_sem_garantia)/100) THEN
            -- 8) SEM GARANTIA, PERC.MIN DE LIQUIDACAO SALDO REFINANCIADO NAO ALCANÇADO
            vr_cdcritica_melhora := 8;--alterado (era 7)
            RAISE vr_grava_log;
          END IF;          
        END IF;
      END IF;
    ELSE
      -- TEM GARANTIAS
      NULL;
    END IF;

    -- VERIFICAR ADIMPLENCIA DO CONTRATO
    IF vr_tem_garantias THEN -- Com Garantia
      IF NOT ((rw_crapepr.qtprepag >= rw_crapepr.qtmesdec)  AND
               rw_crapepr.qtprepag > 0) THEN
        -- 9) Adimplencia COM Garantia não atendida
        vr_cdcritica_melhora := 9;
        RAISE vr_grava_log;
      END IF;
    ELSE -- Sem Garantia
      IF NOT (MOD(rw_crapepr.qtprepag, 2) = 0            AND
              rw_crapepr.qtprepag >= rw_crapepr.qtmesdec AND
               rw_crapepr.qtprepag > 0) THEN
        -- 10) Adimplencia SEM Garantia não atendida
        vr_cdcritica_melhora := 10;
        RAISE vr_grava_log;
      END IF;
    END IF;


    -- VERIFICAR RISCOS DA CENTRAL ANTERIOR
    OPEN cr_central (pr_cdcooper => rw_crapepr.cdcooper
                    ,pr_nrdconta => rw_crapepr.nrdconta
                    ,pr_nrctremp => rw_crapepr.nrctremp
                    ,pr_dtrefere => vr_dtrefere);
    FETCH cr_central INTO rw_central;

    IF cr_central%FOUND THEN
      CLOSE cr_central;
      IF rw_central.inrisco_operacao <= pr_tab_ctl_param(1).inrisco_melhora_minimo THEN
        -- 11) Risco Operacao Menor ou Igual ao Risco Melhora Minimo
        vr_cdcritica_melhora := 11;
        RAISE vr_grava_log;
      ELSE
        IF rw_central.inrisco_operacao <
           greatest(rw_central.inrisco_rating,rw_central.inrisco_atraso,rw_central.inrisco_agravado) THEN
          -- 12) Risco Operacao Menor ou Igual ao Maior risco entre RAT/ATR/AGR
          vr_cdcritica_melhora := 12;
          RAISE vr_grava_log;
        END IF;
      END IF;
    ELSE
      CLOSE cr_central;
    END IF;
    -- Se nao encontrou, segue normalmente



    -- SE PASSOU DE TODAS AS VALIDAÇÕES, PODE CALCULAR RISCO MELHORA
    IF rw_crapepr.inrisco_melhora IS NOT NULL THEN

      -- Risco Melhora ja calculado
      pr_inrisco_melhora := rw_crapepr.inrisco_melhora - 1;

      -- Se o MELHORA Atual ja é menor ou igual ao parametro minimo, não faz nada.
      IF rw_crapepr.inrisco_melhora <= pr_tab_ctl_param(1).inrisco_melhora_minimo THEN
        -- 13) Melhora Minimo ja atingido (MEL)
        vr_cdcritica_melhora := 13;
        RAISE vr_grava_log;
      END IF;

      -- Novo Melhora deve respeitar o minimo parametrizado
      IF pr_inrisco_melhora < pr_tab_ctl_param(1).inrisco_melhora_minimo THEN
        pr_inrisco_melhora := pr_tab_ctl_param(1).inrisco_melhora_minimo;
      END IF;
    ELSE
      
      -- P450 Inicio
      -- Risco MELHORA ainda não calculado
      IF rw_crapepr.idquaprc IN (1,2) THEN -- pega risco do inclusao
        IF rw_crapepr.dsriscoinc <> 'A' THEN
          pr_inrisco_melhora := fn_traduz_nivel_risco(rw_crapepr.dsriscoinc) - 1;  -- traduz nivel risco
          vr_risco_atual     := fn_traduz_nivel_risco(rw_crapepr.dsriscoinc);
        ELSE
          -- 16) Risco Inclusão está no valor minimo "A"
          vr_cdcritica_melhora := 16;
          RAISE vr_grava_log;
        END IF;
      ELSIF rw_crapepr.idquaprc IN (3, 4) THEN 
        pr_inrisco_melhora := rw_crapepr.inrisco_refin - 1;
        vr_risco_atual     := rw_crapepr.inrisco_refin;
      ELSE
        -- 15) Qualif.Operac. não permite "Melhora"
        vr_cdcritica_melhora := 15;
        RAISE vr_grava_log;
      END IF;
      -- P450 Fim

      -- Se o Risco Atual ja é menor ou igual ao parametro minimo, não faz nada.
      IF vr_risco_atual  <= pr_tab_ctl_param(1).inrisco_melhora_minimo THEN
        -- 14) Melhora Minimo ja atingido (REF)
        vr_cdcritica_melhora := 14;
        RAISE vr_grava_log;   
      END IF;

      -- Novo Melhora deve respeitar o minimo parametrizado
      IF pr_inrisco_melhora < pr_tab_ctl_param(1).inrisco_melhora_minimo THEN
        pr_inrisco_melhora := pr_tab_ctl_param(1).inrisco_melhora_minimo;        
      END IF;
    END IF;



    -- CONCLUIDO O PROCESSO DO MELHORA, GRAVA O VALOR NA TABELA
    RISC0004.pc_grava_risco_melhora(pr_cdcooper         => rw_crapepr.cdcooper
                                  , pr_nrdconta         => rw_crapepr.nrdconta
                                  , pr_nrctremp         => rw_crapepr.nrctremp
                                  , pr_tpctrato         => pr_tpctrato
                                  , pr_inrisco_melhora  => pr_inrisco_melhora
                                  , pr_dtrisco_melhora  => rw_crapdat.dtmvtolt
                                  , pr_dscritic         => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;




  EXCEPTION
    WHEN vr_grava_log THEN
      -- USADO PARA GRAVAR A CRITICA DE NAO CALCULO DO MELHORA
      -- QUANDO NAO CALCULAR O MELHORA, CHAMAR RAISE COM ESSE vr_grava_log

      -- Se nao encontrou o emprestimo do parametro (vr_cdcritica_melhora = 0)
      IF vr_cdcritica_melhora = 0 THEN
        pr_inrisco_melhora := NULL;
        pr_dscritic        := NULL;
      ELSE
        -- Busca o valor ja gravado para esse contrato
        pr_inrisco_melhora := RISC0004.fn_busca_risco_melhora(pr_cdcooper => rw_crapepr.cdcooper
                                                              , pr_nrdconta => rw_crapepr.nrdconta
                                                              , pr_nrctremp => rw_crapepr.nrctremp
                                                              , pr_tpctrato => pr_tpctrato);
        pr_dscritic        := NULL;
        pc_grava_critica_melhora(pr_cdcooper => rw_crapepr.cdcooper
                                ,pr_nrdconta => rw_crapepr.nrdconta
                                ,pr_nrctremp => rw_crapepr.nrctremp
                                ,pr_tpctrato => 90
                                ,pr_cdcritic_melhora => vr_cdcritica_melhora
                                ,pr_dscritic => pr_dscritic );
        IF pr_dscritic IS NOT NULL THEN
          pr_dscritic := 'RISC0004.pc_calcula_risco_melhora => ' || pr_dscritic;
        END IF;

      END IF;

    WHEN vr_exc_erro THEN
      ROLLBACK;
      vr_cdcritica_melhora := NULL;
      pr_inrisco_melhora   := NULL;
      -- Variavel de erro recebe erro ocorrido
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_dscritic := vr_dscritic;


    WHEN OTHERS THEN
      ROLLBACK;
      vr_cdcritica_melhora := NULL;
      -- Descricao do erro
      pr_dscritic := 'Erro nao tratado na risc0003.pc_dias_atraso_liquidados --> ' || SQLERRM;

 END pc_calcula_risco_melhora;


  PROCEDURE pc_central_parametros(pr_cdcooper            IN NUMBER           --> Cooperativa
                                 ,pr_tab_ctl_parametros OUT typ_tab_ctl_parametros  --Vetor para o retorno das informações
                                 ,pr_dscritic           OUT VARCHAR2) IS   --> Critica
  /* .............................................................................

   Programa: pc_central_parametros       (Antigo: NAO HA)
   Sistema : Credito
   Sigla   : CRED
   Autor   : Guilherme/AMcom
   Data    : Novembro/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Buscar os parametros da Central de Risco para utilização

   Alteracoes:
  ............................................................................. */

   -- CURSORES
   CURSOR cr_ctl_param IS
     SELECT cdcooper
           ,perc_liquid_sem_garantia
           ,perc_cobert_aplic_bloqueada
           ,inrisco_melhora_minimo
           ,dthr_alteracao
           ,cdoperador_alteracao
       FROM tbrisco_central_parametros t
      WHERE t.cdcooper = pr_cdcooper;
   rw_ctl_param cr_ctl_param%ROWTYPE;

   -- VARIAVEIS LOCAIS


   -- VARIAVEIS DE ERRO
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(4000);
   vr_exc_erro             EXCEPTION;

   BEGIN

     -- Limpar tabela de Parametros
     pr_tab_ctl_parametros.delete;

     rw_ctl_param := NULL;
     OPEN cr_ctl_param;
     FETCH cr_ctl_param INTO rw_ctl_param;

     IF cr_ctl_param%NOTFOUND THEN
       CLOSE cr_ctl_param;
       -- Carrega parametros defauls
       pr_tab_ctl_parametros(1).cdcooper                    := 3;
       pr_tab_ctl_parametros(1).perc_liquid_sem_garantia    := 20;
       pr_tab_ctl_parametros(1).perc_cobert_aplic_bloqueada := 70;
       pr_tab_ctl_parametros(1).inrisco_melhora_minimo      := 2;
       pr_tab_ctl_parametros(1).dthr_alteracao              := SYSDATE;
       pr_tab_ctl_parametros(1).cdoperador_alteracao        := '1';
     ELSE
       CLOSE cr_ctl_param;
       -- Carrega dados cadastrados
       pr_tab_ctl_parametros(1).cdcooper                    := rw_ctl_param.cdcooper;
       pr_tab_ctl_parametros(1).perc_liquid_sem_garantia    := rw_ctl_param.perc_liquid_sem_garantia;
       pr_tab_ctl_parametros(1).perc_cobert_aplic_bloqueada := rw_ctl_param.perc_cobert_aplic_bloqueada;
       pr_tab_ctl_parametros(1).inrisco_melhora_minimo      := rw_ctl_param.inrisco_melhora_minimo;
       pr_tab_ctl_parametros(1).dthr_alteracao              := rw_ctl_param.dthr_alteracao;
       pr_tab_ctl_parametros(1).cdoperador_alteracao        := rw_ctl_param.cdoperador_alteracao;
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
        pr_dscritic := 'Erro nao tratado na RISC0004.pc_central_parametros --> ' || SQLERRM;

  END pc_central_parametros;


-- Buscar o risco na inclusão e na efetivação  - P450 - Rating
  PROCEDURE pc_busca_risco_inclusao(pr_cdcooper IN NUMBER            --> Cooperativa
                                   ,pr_nrdconta IN NUMBER            --> Conta
                                   ,pr_dsctrliq IN VARCHAR2          --> Lista de Contratos Liquidados
                                   ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Data da cooperativa
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE DEFAULT NULL  --> Número do contrato de emprestimos
                                   ,pr_innivris OUT NUMBER
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS

    /* .............................................................................

    Programa: pc_busca_risco_inclusao
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Heckmann/AMcom
    Data    : Agostoo/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar o risco na inclusão e na efetivação
    Observacao: -----

    Alteracoes:  15/03/2019   - P450 - Rating, busca risco da centralizadora risco
                                das operações (Elton AMcom)
                 25/04/2019   - P450 - Rating, incluir a tabela craprnc quando a coopertativa for 3 - Ailos (Heckmann/AMcom)
    ..............................................................................*/

    ----------->>> VARIAVEIS <<<--------
    -- Variáveis de críticas
    vr_cdcritic         crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic         VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro         EXCEPTION;

    --Variáveis de uso comum
    vr_innivris_central crapris.innivris%type;
    vr_innivris_rating  crapris.innivris%type;
    vr_indice           NUMBER(10);
    vr_dtrefere_aux     DATE;                   --> Data de referência auxiliar do processo

    vr_dsctrliq         VARCHAR2(500);

    -- Variável para criar uma lista com os contratos
    -- passados e com os separados nos contratos a liquidar
    vr_split_pr_dsliquid GENE0002.typ_split;

     --- >>> CURSORES <<< ---
    CURSOR cr_crapris(pr_nrctremp IN NUMBER
                     ,pr_dtrefere IN crapris.dtrefere%TYPE) IS    --> Contrato
    SELECT ris.inrisco_operacao innivris
        FROM tbrisco_central_ocr ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = pr_dtrefere
       ORDER BY ris.inrisco_operacao desc;       
       
    rw_crapris cr_crapris%ROWTYPE;

  BEGIN
    IF pr_cdcooper = 3 THEN
      vr_innivris_rating  := NVL(fn_traduz_nivel_risco(fn_busca_rating_conta(pr_cdcooper,pr_nrdconta)),2);
    ELSE
    -- P450 - Rating
      IF nvl(pr_nrctremp,0) = 0 THEN  
        
        OPEN cr_crapass_ope(pr_cdcooper
                           ,pr_nrdconta);
        FETCH cr_crapass_ope INTO rw_crapass_ope;
        CLOSE cr_crapass_ope;
         
        vr_innivris_rating  := NVL(fn_busca_rating_cpfcnpj(pr_cdcooper,rw_crapass_ope.nrcpfcnpj_base),2);
      ELSE
        vr_innivris_rating  := NVL(fn_busca_rating_operacao(pr_cdcooper,pr_nrdconta,pr_nrctremp),2);
      END IF;  
    --
    END IF;

    IF ((nvl(pr_dsctrliq, '0') <> '0') OR (TRIM(pr_dsctrliq) <> '')) THEN

      vr_innivris_central := 2;

      vr_dsctrliq := replace(replace(pr_dsctrliq,'.',''),',',';');

      --Verificar data
      IF to_char(pr_rw_crapdat.dtmvtoan, 'MM') <> to_char(pr_rw_crapdat.dtmvtolt, 'MM') THEN
        -- Utilizar o final do mês como data
        vr_dtrefere_aux := pr_rw_crapdat.dtultdma;
      ELSE
        -- Utilizar a data atual
        vr_dtrefere_aux := pr_rw_crapdat.dtmvtoan;
      END IF;

      -- Efetuar split dos contratos passados para facilitar os testes
      vr_split_pr_dsliquid := gene0002.fn_quebra_string(replace(rtrim(vr_dsctrliq, ','),';',','),',');

      vr_indice := 1;
      LOOP
        OPEN cr_crapris(vr_split_pr_dsliquid(vr_indice)
                       ,vr_dtrefere_aux);
        FETCH cr_crapris INTO rw_crapris;

          IF cr_crapris%NOTFOUND THEN
            vr_innivris_central := 2;
          END IF;

          IF nvl(vr_innivris_central,0) < nvl(rw_crapris.innivris, 0) THEN
            vr_innivris_central := rw_crapris.innivris;
          END IF;

        CLOSE cr_crapris;
        vr_indice   := vr_indice + 1;
        EXIT WHEN (vr_split_pr_dsliquid.count = vr_indice - 1);
      END LOOP;

      -- verificar quem é o pior
      pr_innivris := GREATEST(vr_innivris_central, vr_innivris_rating);
    ELSE -- SE NAO LIQUIDA NENHUM CONTRATO, RISCO INCLUSÃO É RATING
      pr_innivris := vr_innivris_rating;
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
    pr_dscritic := 'Erro nao tratado na risc0003.pc_busca_risco_inclusao --> ' || SQLERRM;

  END pc_busca_risco_inclusao;

----
 PROCEDURE pc_grava_risco_inclusao( pr_cdcooper           IN NUMBER
                                  , pr_nrdconta           IN NUMBER
                                  , pr_nrctremp           IN NUMBER
                                  , pr_tpctrato           IN NUMBER
                                  , pr_nrcpfcnpj_base     IN NUMBER
                                  , pr_inrisco_inclusao   IN NUMBER
                                  , pr_dscritic           OUT VARCHAR2) IS
  /* .............................................................................

   Programa: pc_grava_risco_inclusão       (Antigo: NAO HA)
   Sistema : Credito
   Sigla   : CRED
   Autor   : Elton/AMcom
   Data    : Março/2019.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Gravar o resultado do cálculo do Risco Inclusão

   Alteracoes:
  ............................................................................. */


  vr_des_erro   VARCHAR2(2000);
  vr_exc_erro   EXCEPTION;
  BEGIN
    pr_dscritic := NULL;

    -- Se a critica vier nula ou 0, não grava nada
    IF pr_inrisco_inclusao > 0 THEN

      -- Faz o UPDATE do registro
      BEGIN
        UPDATE TBRISCO_OPERACOES t
           SET t.inrisco_inclusao = pr_inrisco_inclusao
         WHERE t.cdcooper       = pr_cdcooper
           AND t.nrdconta       = pr_nrdconta
           AND t.nrctremp       = pr_nrctremp
           AND t.tpctrato       = pr_tpctrato
           AND t.nrcpfcnpj_base = pr_nrcpfcnpj_base;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := ' Detalhes[1]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

      -- Se igual a 0, nao encontrou. Fazer INSERT
      IF SQL%ROWCOUNT = 0 THEN
        BEGIN
          ----
          INSERT INTO TBRISCO_OPERACOES
                     (cdcooper,
                      nrdconta,
                      nrctremp,
                      tpctrato,
                      inrisco_inclusao,
                      inrisco_calculado,
                      inrisco_melhora,
                      dtrisco_melhora,
                      cdcritica_melhora,
                      --p450 - rating
                      nrcpfcnpj_base)
                VALUES (pr_cdcooper,
                        pr_nrdconta,
                        pr_nrctremp,
                        pr_tpctrato,
                        pr_inrisco_inclusao,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        pr_nrcpfcnpj_base
                       );
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := ' Detalhes[2]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_erro;
        END;
      END IF;

      -- MANTER ATUALIZANDO O RISCO DSNIVRIS ENQUANTO NAO FOR REMOVIDO DEFINITIVO
      BEGIN
         UPDATE crawepr t
            SET  t.dsnivris = fn_traduz_risco(pr_inrisco_inclusao)
                ,t.dsnivori = fn_traduz_risco(pr_inrisco_inclusao)
          WHERE t.cdcooper = pr_cdcooper
            AND t.nrdconta = pr_nrdconta
            AND t.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := ' Detalhes[3]:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

    END IF;


   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       pr_dscritic := 'Erro RISC0004.pc_grava_risco_inclusao --> ' ||pr_dscritic;


     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na RISC0004.pc_grava_risco_inclusao --> ' || SQLERRM;

  END pc_grava_risco_inclusao;
END RISC0004;
/
