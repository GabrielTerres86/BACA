CREATE OR REPLACE PACKAGE CECRED.RISC0001 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0001
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Agosto/2014.                   Ultima atualizacao: 29/08/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genéricas para calculo de Risco
  ---------------------------------------------------------------------------------------------------------------

  /* Tabela de memória para guardar as informações da central
     de risco - antiga b1wgen0024 -- tt-central-risco */
  TYPE typ_reg_central_risco IS
    RECORD(dtdrisco crapopf.dtrefere%type
          ,qtopescr crapopf.qtopesfn%type
          ,qtifoper crapopf.qtifssfn%type
          ,vltotsfn NUMBER
          ,vlopescr NUMBER
          ,vlrpreju NUMBER);

  /* Tabela com as informações de estouro de conta
     antiga b1wgen0027 - tt-estouros */
  TYPE typ_reg_estouros IS
    RECORD(nrseqdig crapneg.nrseqdig%type
          ,dtiniest crapneg.dtiniest%type
          ,qtdiaest crapneg.qtdiaest%type
          ,cdhisest VARCHAR2(30)
          ,vlestour crapneg.vlestour%type
          ,nrdctabb crapneg.nrdctabb%type
          ,nrdocmto crapneg.nrdocmto%type
          ,cdobserv crapali.dsalinea%type
          ,dsobserv VARCHAR2(100)
          ,vllimcre crapneg.vllimcre%type
          ,dscodant VARCHAR2(30)
          ,dscodatu VARCHAR2(30));
  TYPE typ_tab_estouros IS
    TABLE OF typ_reg_estouros
      INDEX BY PLS_INTEGER;


  PROCEDURE pc_risco_k(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                      ,pr_dtrefere  IN VARCHAR2               --> Data de referencia
                      ,pr_retfile  OUT VARCHAR2               --> Nome do arquivo de retorno
                      ,pr_dscritic OUT VARCHAR2);             --> Nome do arquivo de saida

  PROCEDURE pc_risco_t(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                      ,pr_dtrefere  IN VARCHAR2               --> Data de referencia
                      ,pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  PROCEDURE pc_risco_g(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                      ,pr_dtrefere  IN VARCHAR2               --> Data de referencia
                      ,pr_dscritic OUT VARCHAR2);             --> Descricao da critica


  /* Obter os dados do banco cetral para analise da proposta, consulta de SCR. (Tela CONSCR) */
  PROCEDURE pc_obtem_valores_central_risco(pr_cdcooper           IN crapcop.cdcooper%type          --> Codigo Cooperativa
                                          ,pr_cdagenci           IN crapass.cdagenci%type          --> Codigo Agencia
                                          ,pr_nrdcaixa           IN INTEGER                        --> Numero Caixa
                                          ,pr_nrdconta           IN crapass.nrdconta%TYPE          --> Numero da Conta
                                          ,pr_nrcpfcgc           IN crapass.nrcpfcgc%TYPE          --> CPF/CGC do associado
                                          ,pr_tab_central_risco OUT risc0001.typ_reg_central_risco --> Informações da Central de Risco
                                          ,pr_tab_erro          OUT gene0001.typ_tab_erro          --> Tabela Erro
                                          ,pr_des_reto          OUT VARCHAR2);                     --> Retorno OK/NOK

  /* Obter as informaões de estouro do cooperado */
  PROCEDURE pc_lista_estouros(pr_cdcooper      IN crapcop.cdcooper%type     --> Codigo Cooperativa
                             ,pr_cdoperad      IN crapope.cdoperad%type     --> Operador conectado
                             ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                             ,pr_idorigem      IN INTEGER                   --> Identificador Origem
                             ,pr_idseqttl      IN INTEGER                   --> Sequencial do Titular
                             ,pr_nmdatela      IN VARCHAR2                  --> Nome da tela
                             ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE     --> Data do movimento
                             ,pr_tab_estouros OUT risc0001.typ_tab_estouros --> Informações de estouro na conta
                             ,pr_dscritic     OUT VARCHAR2);                --> Retorno de erro

END RISC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0001
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Agosto/2014.                   Ultima atualizacao: 27/04/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genéricas para calculo de Risco
  --
  -- Alterações: 24/02/2015 - Correção em cursores com ORDER BY progress_recid para forçar o
  --                          índice utilizado pelo Progress (Dionathan)
  --
  --             20/06/2016 - Correcao para o uso correto do indice da CRAPTAB em varias procedures
  --                          desta package.(Carlos Rafael Tanholi).
  --
  --             27/04/2017 - Nas linhas de reversao verificar se é uma data util,(pc_risco_k, pc_risco_t)
  --                          (Tiago/Thiago SD 589074).
  ---------------------------------------------------------------------------------------------------------------

  -- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  vr_dtrefris DATE;

  type typ_reg_craptip is record
       (cdtipcta  craptip.cdtipcta%type,
        dstipcta  craptip.dstipcta%type,
        cdcooper  craptip.cdcooper%type);

  type typ_tab_craptip is table of typ_reg_craptip
  index by varchar2(15); --cdcooper(10) + cdtipcta(+)

  vr_tab_craptip typ_tab_craptip;



  /*variavel global para vencimento - GERAR ARQUIVO TXT*/
  TYPE vr_venc IS RECORD(
      dias INTEGER);

  TYPE typ_vencto IS TABLE OF vr_venc INDEX BY BINARY_INTEGER;
      vr_vencto typ_vencto;


  TYPE typ_decimal IS RECORD(
      valor  NUMBER(25, 2) := 0
     ,dsc    VARCHAR(25));

  TYPE typ_arr_decimal
    IS TABLE OF typ_decimal
      INDEX BY BINARY_INTEGER;

  TYPE typ_decimal_pfpj IS RECORD(
      valorpf NUMBER(25, 2) := 0
     ,dscpf   VARCHAR(25)
     ,valorpj NUMBER(25, 2) := 0
     ,dscpj   VARCHAR(25));

  TYPE typ_arr_decimal_pfpj
    IS TABLE OF typ_decimal_pfpj
      INDEX BY BINARY_INTEGER;


  -- Relatorio
  vr_nom_arquivo VARCHAR2(100);
  vr_des_xml     CLOB;
  vr_dstexto     VARCHAR2(32700);
  vr_nom_direto  VARCHAR2(400);

  --Variavel de Exceção
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;


 ------------------------------- PROCEDURES INTERNAS ---------------------------------
  FUNCTION fn_verifica_conta_migracao(par_cdcooper IN craptco.cdcooper%TYPE
                                     ,par_nrdconta IN craptco.nrdconta%TYPE
                                     ,par_dtrefere IN DATE) RETURN BOOLEAN IS
  -- ..........................................................................
    --
    --  Programa : fn_verifica_conta_migracao            Antigo: ????????????

    --  Sistema  : Rotinas genericas para RISCO
    --  Sigla    : RISC
    --  Autor    : ?????
    --  Data     : ?????                         Ultima atualizacao: 31/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : 31/12/2016 - Incorporação Transulcred -> Transpocred (Oscar).
    --
    -- .............................................................................

  vr_return BOOLEAN := FALSE;

  CURSOR cr_craptco(par_cdcooper IN craptco.cdcooper%TYPE
                   ,par_cdcopant IN craptco.cdcopant%TYPE
                   ,par_nrdconta IN craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3;
  rw_craptco cr_craptco%ROWTYPE;

  CURSOR cr_craptco_acredi(par_cdcooper IN craptco.cdcooper%TYPE
                          ,par_cdcopant IN craptco.cdcopant%TYPE
                          ,par_nrdconta IN craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3
       AND (craptco.cdageant = 2 OR craptco.cdageant = 4 OR
           craptco.cdageant = 6 OR craptco.cdageant = 7 OR
           craptco.cdageant = 11);
  rw_craptco_acredi cr_craptco_acredi%ROWTYPE;


  BEGIN

    -- Incorporacao Concredi -> Viacredi
    IF par_cdcooper = 1 AND
       par_dtrefere <= to_date('30/11/2014', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(1, 4, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Incorporacao Credimilsul -> Scrcred
    IF par_cdcooper = 13 AND
       par_dtrefere <= to_date('30/11/2014', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(13, 15, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Migracao Viacredi -> Altovale

    IF par_cdcooper = 16 AND
       par_dtrefere <= to_date('31/12/2012', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(16, 1, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Migracao Acredicop -> Viacredi
    IF par_cdcooper = 1 AND
       par_dtrefere <= to_date('31/12/2013', 'dd/mm/YYYY') THEN

      OPEN cr_craptco_acredi(1, 2, par_nrdconta);
      FETCH cr_craptco_acredi
        INTO rw_craptco_acredi;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF  vr_return  THEN
        RETURN FALSE;
      END IF;

    END IF;


    -- Migracao Transulcred -> Transpocred
    IF par_cdcooper = 09 AND
       par_dtrefere <= to_date('31/12/2016', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(09, 17, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;


    RETURN TRUE;

  END fn_verifica_conta_migracao;


  FUNCTION fn_normaliza_jurosa60(par_cdcooper IN crapris.cdcooper%TYPE
                                ,par_nrdconta IN crapris.nrdconta%TYPE
                                ,par_dtrefere IN DATE
                                ,par_innivris IN crapris.innivris%TYPE
                                ,par_cdmodali IN crapris.cdmodali%TYPE
                                ,par_nrctremp IN crapris.nrctremp%TYPE
                                ,par_nrseqctr IN crapris.nrseqctr%TYPE
                                ,par_vldjuros IN OUT crapvri.vldivida%TYPE)
  RETURN NUMBER IS
  -- ..........................................................................
  --
  --  Programa : fn_normaliza_jurosa60         Antigo: ????????????

  --  Sistema  : Rotinas genericas para RISCO
  --  Sigla    : RISC
  --  Autor    : ?????
  --  Data     : ?????                         Ultima atualizacao: ??/??/????
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  :
  --
  -- .............................................................................

    CURSOR cr_crapvri_jur(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE
                         ,pr_innivris IN crapris.innivris%TYPE
                         ,pr_cdmodali IN crapris.cdmodali%TYPE
                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
      SELECT crapvri.innivris
            ,crapvri.cdvencto
            ,crapvri.cdcooper
            ,crapvri.vldivida
        FROM crapvri
       WHERE crapvri.cdcooper = pr_cdcooper
         AND crapvri.nrdconta = pr_nrdconta
         AND crapvri.dtrefere = pr_dtrefere
         AND crapvri.innivris = pr_innivris
         AND crapvri.cdmodali = pr_cdmodali
         AND crapvri.nrctremp = pr_nrctremp
         AND crapvri.nrseqctr = pr_nrseqctr
         AND crapvri.cdvencto >= 230
         AND crapvri.cdvencto <= 290;


    vr_vldiva60 NUMBER := 0;
    --vr_vldjuros NUMBER := par_vldjuros;
    BEGIN

    FOR rw_crapvri_jur2 IN cr_crapvri_jur(par_cdcooper,
                                          par_nrdconta,
                                          par_dtrefere,
                                          par_innivris,
                                          par_cdmodali,
                                          par_nrctremp,
                                          par_nrseqctr) LOOP

      vr_vldiva60 := vr_vldiva60 + nvl(rw_crapvri_jur2.vldivida, 0);

    END LOOP;

    IF par_vldjuros >= vr_vldiva60 THEN

      IF ((par_vldjuros - vr_vldiva60) > 1) AND (vr_vldiva60 > 1) THEN
        par_vldjuros := vr_vldiva60 - 1;
      ELSE
        par_vldjuros := vr_vldiva60 - 0.1;
      END IF;

    END IF;

    RETURN NVL(par_vldjuros,0);

  END fn_normaliza_jurosa60;


  PROCEDURE pc_calcula_juros_60k(par_cdcooper IN crapris.cdcooper%TYPE
                                ,par_dtrefere IN crapris.dtrefere%TYPE
                                ,par_cdmodali IN crapris.cdmodali%TYPE
                                ,par_dtinicio IN crapris.dtinictr%TYPE
                                ,pr_tabvljur1 IN OUT typ_arr_decimal_pfpj    --> TR - Modalidade 299 - Por PA.
                                ,pr_tabvljur2 IN OUT typ_arr_decimal_pfpj    --> TR - Modalidade 499 - Por PA.
                                ,pr_tabvljur3 IN OUT typ_arr_decimal_pfpj    --> PP - Modalidade 299 - Por PA.
                                ,pr_tabvljur4 IN OUT typ_arr_decimal_pfpj    --> PP - Modalidade 499 - Por PA.
                                ,pr_tabvljur5 IN OUT typ_arr_decimal_pfpj    --> PP – Cessao - Por PA.
                                ,pr_tabvljur6 IN OUT typ_arr_decimal_pfpj    --> POS - Modalidade 299 - Por PA.
                                ,pr_tabvljur7 IN OUT typ_arr_decimal_pfpj    --> POS - Modalidade 499 - Por PA.
                                ,pr_vlrjuros  OUT typ_decimal_pfpj           --> TR - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros  OUT typ_decimal_pfpj           --> TR - Modalidade 499 - Por Tipo pessoa.
                                ,pr_vlrjuros2 OUT typ_decimal_pfpj           --> PP - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros2 OUT typ_decimal_pfpj           --> PP - Modalidade 499 - Por Tipo pessoa.
                                ,pr_vlrjuros3 OUT typ_decimal_pfpj           --> PP – Cessao - Por Tipo pessoa.
                                ,pr_vlrjuros6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros6 OUT typ_decimal_pfpj
                                ,pr_empjuros1  OUT typ_decimal_pfpj           --> TR – Emprestimo pessoa fisica refinanciado
                                ,pr_empjuros2  OUT typ_decimal_pfpj           --> PP – Emprestimo pessoa fisica refinanciado
                                ,pr_empjuros3  OUT typ_decimal_pfpj           --> POS – Emprestimo pessoa fisica refinanciado
                                ,pr_finjuros3  OUT typ_decimal_pfpj           --> TR – Financiamento pessoa fisica refinanciado
                                ,pr_finjuros4  OUT typ_decimal_pfpj           --> PP – Finaciamento pessoa fisica refinanciado
                                ,pr_finjuros5  OUT typ_decimal_pfpj           --> POS – Financiamento pessoa fisica refinanciado
                                ,pr_juros38    OUT typ_decimal_pfpj           --> 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                                ,pr_taxas37    OUT typ_decimal_pfpj           --> 0037 -Taxa sobre saldo em c/c negativo
                                ,pr_juros57    OUT typ_decimal_pfpj           --> 0057 -Juros sobre saque de deposito bloqueado
                                ,pr_tarifa1441 OUT typ_decimal_pfpj           --> 1441 -Tarifa adiantamento a depositantes
                                ,pr_tarifa1465 OUT typ_decimal_pfpj           --> 1465 -Tarifa adiantamento a depositantes
                                ,pr_tabvlempjur1    IN OUT typ_arr_decimal_pfpj    --> TR – Cessao Emprestimo - Por PA.
                                ,pr_tabvlempjur2    IN OUT typ_arr_decimal_pfpj    --> PP – Cessao Emprestimo - Por PA.
                                ,pr_tabvlempjur3    IN OUT typ_arr_decimal_pfpj    --> POS – Cessao Emprestimo - Por PA.
                                ,pr_tabvlfinjur1    IN OUT typ_arr_decimal_pfpj    --> TR – Cessao Financiamento - Por PA.
                                ,pr_tabvlfinjur2    IN OUT typ_arr_decimal_pfpj   --> PP – Cessao Financiamento - Por PA.
                                ,pr_tabvlfinjur3    IN OUT typ_arr_decimal_pfpj   --> POS – Cessao Financiamento - Por PA.
                                ,pr_tabvljuros38    IN OUT typ_arr_decimal_pfpj    --> 38 – Juros sobre limite de credito    - Por PA.
                                ,pr_tabvltaxas37    IN OUT typ_arr_decimal_pfpj    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                                ,pr_tabvljuros57    IN OUT typ_arr_decimal_pfpj    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.
                                ,pr_tabvltarifa1441 IN OUT typ_arr_decimal_pfpj    -->1441 – Tarifa adiantamento a depositantes- Por PA.
                                ,pr_tabvltarifa1465 IN OUT typ_arr_decimal_pfpj   --> 1465 – Tarifa adiantamento a depositantes - Por PA.
                                ) IS
  -- ..........................................................................
  --
  --  Programa : pc_calcula_juros_60k          Antigo: ????????????

  --  Sistema  : Rotinas genericas para RISCO
  --  Sigla    : RISC
  --  Autor    : ?????
  --  Data     : ?????                         Ultima atualizacao: 21/03/2018
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : 23/03/2017 - Ajustado para retornar valores da Cessao do cartao de credito.
  --                            PRJ343 - Cessao de credito (Odirlei-AMcom)
  --
  --               21/07/2017 - Ajuste para somar os lançamentos de rendas a apropriar e provisao das
  --                            cessoes nos emprestimos PP modalidade 299 (SD 718024 Anderson).
  --
  --               03/10/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
  --
  --               12/03/2018 - Ajuste para buscar valores de juros +60 de contratos refinanciados
  --               Projeto Ligeirinho (Rangel Decker) AMcom
  --
  --               21/03/2018 - Ajuste para buscar valores de juros,taxas,mora etc... de contas
  --                            correntes negativas e caso possuir com limites de credito estourado (Rangel Decker) AMcom
  --  ...............................................................................

    CURSOR cr_crapvri_jur(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE
                         ,pr_innivris IN crapris.innivris%TYPE
                         ,pr_cdmodali IN crapris.cdmodali%TYPE
                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
      SELECT /*+ INDEX_DESC(crapvri CRAPVRI##CRAPVRI1) */
             crapvri.innivris
            ,crapvri.cdvencto
            ,crapvri.cdcooper
            ,crapvri.vldivida
        FROM crapvri
       WHERE crapvri.cdcooper = pr_cdcooper
         AND crapvri.dtrefere = pr_dtrefere
         AND crapvri.nrdconta = pr_nrdconta
         AND crapvri.innivris = pr_innivris
         AND crapvri.cdmodali = pr_cdmodali
         AND crapvri.nrctremp = pr_nrctremp
         AND crapvri.nrseqctr = pr_nrseqctr
         AND crapvri.cdvencto >= 230
         AND crapvri.cdvencto <= 290;
    rw_crapvri_jur cr_crapvri_jur%ROWTYPE;

    CURSOR cr_craplem(pr_cdcooper     IN crapris.cdcooper%TYPE
                     ,pr_nrdconta     IN crapris.nrdconta%TYPE
                     ,vr_diascalc    IN INTEGER
                     ,pr_tel_dtrefere craplem.dtmvtolt%TYPE
                     ,par_dtinicio    IN craplem.dtmvtolt%TYPE
                     ,pr_nrctremp     IN crapris.nrctremp%TYPE) IS
      SELECT craplem.vllanmto
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.dtmvtolt >= pr_tel_dtrefere - vr_diascalc
         AND craplem.dtmvtolt >= par_dtinicio
         AND craplem.dtmvtolt <= pr_tel_dtrefere
         AND craplem.cdhistor = 98
         AND craplem.nrdocmto = pr_nrctremp;


    CURSOR cr_crapris_jur(par_cdcooper IN crapris.cdcooper%TYPE
                         ,par_dtrefere IN crapris.dtrefere%TYPE
                         ,par_cdmodali IN crapris.cdmodali%TYPE) IS
      SELECT ris.cdcooper
            ,ris.nrdconta
            ,ris.nrctremp
            ,ris.nrseqctr
            ,ris.dtrefere
            ,ris.inpessoa
            ,epr.tpemprst
            ,ris.innivris
            ,ris.cdmodali
            ,ris.cdagenci
            ,ris.qtdiaatr
            ,ris.vljura60
        FROM crapris ris
            ,crapepr epr
       WHERE ris.cdcooper = par_cdcooper
         AND ris.dtrefere = par_dtrefere
         AND ris.cdmodali = par_cdmodali
         AND ris.inddocto = 1
         AND epr.cdcooper = ris.cdcooper
         AND epr.nrdconta = ris.nrdconta
         AND epr.nrctremp = ris.nrctremp
       ORDER BY ris.cdagenci,
                ris.nrdconta;

    --> Verificar se é um emprestimo de cessao de credito
    CURSOR cr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                      pr_nrdconta crapepr.nrdconta%TYPE,
                      pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM tbcrd_cessao_credito ces
       WHERE ces.cdcooper = pr_cdcooper
         AND ces.nrdconta = pr_nrdconta
         AND ces.nrctremp = pr_nrctremp;

  --Busca contratos que são ativos , nao estao na situação de prejuizo.
    -- Verifica se foi refinanciado
    CURSOR cr_crapris_jur_refi (pr_cdcooper IN crapepr.cdcooper%TYPE,
                                pr_cdmodali IN tbepr_liquidado_financiado.cdmodali%TYPE ) IS
    SELECT   tlf.cdcooper,
             tlf.nrdconta,
             ass.inpessoa inpessoa,
             tlf.cdmodali,
             tlf.nrctremp,
             tlf.qtdia_atraso  qtdiaatr,
             tlf.vljuros60     vljura60,
             epr.cdagenci,
             epr.tpemprst,
             epr.nrctremp nctremp
    FROM   crawepr crwpr,
           crapepr epr,
           tbepr_liquidado_financiado tlf,
           crapass ass
    WHERE  (crwpr.nrctrliq##1   = tlf.nrctremp
    OR      crwpr.nrctrliq##2 = tlf.nrctremp
    OR      crwpr.nrctrliq##3 = tlf.nrctremp
    OR      crwpr.nrctrliq##4 = tlf.nrctremp
    OR      crwpr.nrctrliq##5 = tlf.nrctremp
    OR      crwpr.nrctrliq##6 = tlf.nrctremp
    OR      crwpr.nrctrliq##7 = tlf.nrctremp
    OR      crwpr.nrctrliq##8 = tlf.nrctremp
    OR      crwpr.nrctrliq##9 = tlf.nrctremp
    OR      crwpr.nrctrliq##10= tlf.nrctremp)
    AND     crwpr.nrctremp = epr.nrctremp
    AND     crwpr.cdcooper = epr.cdcooper
    AND     crwpr.cdagenci = epr.cdagenci
    AND     crwpr.nrdconta = epr.nrdconta
    AND     epr.cdcooper   = tlf.cdcooper
    AND     epr.nrdconta   = tlf.nrdconta
    AND     tlf.cdcooper   = ass.cdcooper
    AND     tlf.nrdconta   = ass.nrdconta
    AND     tlf.cdmodali   = pr_cdmodali
    AND     epr.inprejuz   =0 --SEM PREJUIZO
    AND     epr.inliquid   =0 --ATIVO
    AND     crwpr.cdcooper  = pr_cdcooper
    AND     CECRED.fn_exibe_epr_ref(epr.tpemprst,
                                    epr.qtpreemp,
                                    epr.qtprepag,
                                    epr.qtpcalat) >0;

    --Busca conta corrente negativada acima do limite e conta negativada sem limite de credito
    CURSOR cr_conta_negativa (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
     SELECT ass.inpessoa, --Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
            sld.qtddsdev,
            sld.nrdconta,
            sld.vlsddisp
            --  cecred.fn_busca_inicio_atraso(sld.nrdconta,sld.cdcooper ) dt_ini_atr
       FROM  crapass ass,
             crapsld sld,
             craplim lim
       WHERE ass.nrdconta = sld.nrdconta
       AND   ass.cdcooper = sld.cdcooper
       AND   sld.nrdconta = lim.nrdconta
       AND   sld.cdcooper = lim.cdcooper
       AND    lim.insitlim = 2 -- Possui limite Ativo
       AND    sld.cdcooper = pr_cdcooper
       AND    sld.qtddsdev >=60
       AND    sld.vlsddisp <0
       AND    (sld.vlsddisp*-1) > lim.vllimite
       UNION
       SELECT ass.inpessoa, --Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
              sld.qtddsdev,
              sld.nrdconta,
              sld.vlsddisp
           --   cecred.fn_busca_inicio_atraso(sld.nrdconta,sld.cdcooper) dt_ini_atr
       FROM  crapass ass,
             crapsld sld
       WHERE ass.nrdconta = sld.nrdconta
       AND   ass.cdcooper = sld.cdcooper
       AND sld.cdcooper = pr_cdcooper
       AND    sld.qtddsdev >=60
       AND    sld.vlsddisp <0
       AND    sld.nrdconta not in (select  lim.nrdconta
                                   from craplim lim
                                   where lim.cdcooper =pr_cdcooper);

    --Retorna os laçamentos de taxas cobradas na situação de conta negativa
    CURSOR cr_conta_juros60 (pr_cdcooper IN craplcm.cdcooper%TYPE,
                             pr_nrdconta IN craplcm.nrdconta%TYPE) IS
     SELECT /*+ index (lcm CRAPLCM##CRAPLCM2) */
             lcm.nrdconta
            ,lcm.dtmvtolt
            ,lcm.cdagenci
            ,lcm.vllanmto
            ,his.cdhistor
            ,his.dshistor
            ,lcm.rowid
       FROM craplcm lcm
          ,craphis his
      WHERE lcm.cdcooper = his.cdcooper
       AND lcm.cdhistor  = his.cdhistor
       AND lcm.cdcooper  = pr_cdcooper
       AND lcm.nrdconta  = pr_nrdconta
       AND lcm.dtmvtolt  = gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                      ,pr_dtmvtolt  => (par_dtrefere+ 1) -- Próximo dia
                                                      ,pr_tipo      => 'P')
       AND his.indebcre ='D'
       AND his.cdhistor in(38)
      UNION
      SELECT /*+ index (lcm CRAPLCM##CRAPLCM2) */
             lcm.nrdconta
            ,lcm.dtmvtolt
            ,lcm.cdagenci
            ,lcm.vllanmto
            ,his.cdhistor
            ,his.dshistor
            ,lcm.rowid
       FROM craplcm lcm
          ,craphis his
      WHERE lcm.cdcooper = his.cdcooper
       AND lcm.cdhistor  = his.cdhistor
       AND lcm.cdcooper  = pr_cdcooper
       AND lcm.nrdconta  = pr_nrdconta
       AND lcm.dtmvtolt  = par_dtrefere
       AND his.indebcre ='D'
       AND his.cdhistor in(1441,38,1465,37,57,90);


    vr_vljurctr          NUMBER;
    vr_crapvri_jur_found BOOLEAN := FALSE;
    vr_diascalc          INTEGER := 0;
    contador             INTEGER := 0;
    vr_fleprces          INTEGER := 0;

  BEGIN
    pr_vlrjuros.valorpf  := 0;
    pr_vlrjuros.valorpj  := 0;
    pr_vlrjuros2.valorpf := 0;
    pr_vlrjuros2.valorpj := 0;

    pr_finjuros.valorpf  := 0;
    pr_finjuros.valorpj  := 0;
    pr_finjuros2.valorpf := 0;
    pr_finjuros2.valorpj := 0;

     --EMPRESTIMOS

    --Tipo TR
    pr_empjuros1.valorpf:=0;
    pr_empjuros1.valorpj:=0;

    --Tipo PP
    pr_empjuros2.valorpf:=0;
    pr_empjuros2.valorpj:=0;

    --Tipo POS
    pr_empjuros3.valorpf:=0;
    pr_empjuros3.valorpj:=0;


    --FINANCIAMENTOS

    --Tipo TR
    pr_finjuros3.valorpf:=0;
    pr_finjuros3.valorpj:=0;

    --Tipo PP
    pr_finjuros4.valorpf:=0;
    pr_finjuros4.valorpj:=0;

    --Tipo POS
    pr_finjuros5.valorpf:=0;
    pr_finjuros5.valorpj:=0;

    --Conta Corrente
    pr_juros38.valorpf:=0;
    pr_juros38.valorpj:=0;

    pr_taxas37.valorpf:=0;
    pr_taxas37.valorpj:=0;

    pr_juros57.valorpf:=0;
    pr_juros57.valorpj:=0;

    pr_tarifa1441.valorpf:=0;
    pr_tarifa1441.valorpj:=0;

    pr_tarifa1465.valorpf:=0;
    pr_tarifa1465.valorpj:=0;

    FOR rw_crapris_jur IN cr_crapris_jur(par_cdcooper,
                                         par_dtrefere,
                                         par_cdmodali) LOOP

      IF par_cdcooper IN ( 1, 13 ,16, 09) THEN
        IF NOT fn_verifica_conta_migracao(rw_crapris_jur.cdcooper,
                                          rw_crapris_jur.nrdconta,
                                          rw_crapris_jur.dtrefere) THEN
          CONTINUE;
        END IF;
      END IF;

      IF rw_crapris_jur.tpemprst = 0 THEN

        OPEN cr_crapvri_jur(rw_crapris_jur.cdcooper,
                            rw_crapris_jur.nrdconta,
                            rw_crapris_jur.dtrefere,
                            rw_crapris_jur.innivris,
                            rw_crapris_jur.cdmodali,
                            rw_crapris_jur.nrctremp,
                            rw_crapris_jur.nrseqctr);
        FETCH cr_crapvri_jur
          INTO rw_crapvri_jur;
        vr_crapvri_jur_found := cr_crapvri_jur%FOUND;
        CLOSE cr_crapvri_jur;

        IF NOT vr_crapvri_jur_found THEN
          CONTINUE;
        END IF;


        contador := contador + 1;


        IF rw_crapvri_jur.cdvencto = 290 THEN
          vr_diascalc := rw_crapris_jur.qtdiaatr - 60;

        ELSE

          IF vr_vencto(rw_crapvri_jur.cdvencto).dias < rw_crapris_jur.qtdiaatr THEN
            vr_diascalc := vr_vencto(rw_crapvri_jur.cdvencto).dias - 60;
          ELSE
            vr_diascalc := rw_crapris_jur.qtdiaatr - 60;
          END IF;

        END IF;

        vr_vljurctr := 0;

        FOR rw_craplem IN cr_craplem(rw_crapris_jur.cdcooper,
                                     rw_crapris_jur.nrdconta,
                                     vr_diascalc,
                                     par_dtrefere,
                                     par_dtinicio,
                                     rw_crapris_jur.nrctremp) LOOP

          vr_vljurctr := vr_vljurctr + nvl(rw_craplem.vllanmto, 0);

        END LOOP;

        -- Normaliza Juros
        vr_vljurctr := fn_normaliza_jurosa60(rw_crapris_jur.cdcooper,
                                             rw_crapris_jur.nrdconta,
                                             rw_crapris_jur.dtrefere,
                                             rw_crapris_jur.innivris,
                                             rw_crapris_jur.cdmodali,
                                             rw_crapris_jur.nrctremp,
                                             rw_crapris_jur.nrseqctr,
                                             vr_vljurctr);
        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros.valorpf := pr_vlrjuros.valorpf + vr_vljurctr;

            IF pr_tabvljur1.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf,0) +  vr_vljurctr;
            ELSE
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf := vr_vljurctr;
            END IF;
          ELSE -- PJ
            pr_vlrjuros.valorpj := pr_vlrjuros.valorpj + vr_vljurctr;

            IF pr_tabvljur1.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj,0) +  vr_vljurctr;
            ELSE
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj := vr_vljurctr;
            END IF;
          END IF;

        ELSE  /* 499 */

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_finjuros.valorpf := pr_finjuros.valorpf + vr_vljurctr;

            IF pr_tabvljur2.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf,0) + vr_vljurctr;
            ELSE
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf := vr_vljurctr;
            END IF;

          ELSE -- PJ
            pr_finjuros.valorpj := pr_finjuros.valorpj + vr_vljurctr;

            IF pr_tabvljur2.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj,0) + vr_vljurctr;
            ELSE
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj := vr_vljurctr;
            END IF;
          END IF;

        END IF;

      ELSIF rw_crapris_jur.tpemprst = 1 THEN  -- Pre-Fixado

        vr_fleprces := 0;
        --> Verificar se é um emprestimo de cessao de credito
        OPEN cr_cessao (pr_cdcooper => rw_crapris_jur.cdcooper,
                        pr_nrdconta => rw_crapris_jur.nrdconta,
                        pr_nrctremp => rw_crapris_jur.nrctremp);
        FETCH cr_cessao INTO vr_fleprces;
        CLOSE cr_cessao;

        --Conforme SD 718024 - os dados das cessoes devem ser somados aqui e na modalidade 299 também.
        IF vr_fleprces = 1 THEN
          -- Por tipo de pessoa
          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros3.valorpf := pr_vlrjuros3.valorpf + NVL(rw_crapris_jur.vljura60,0);

            -- Por PA
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          ELSE -- PJ
            pr_vlrjuros3.valorpj := pr_vlrjuros3.valorpj + NVL(rw_crapris_jur.vljura60,0);

            -- Por PA
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          END IF;
        END IF;

        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros2.valorpf := pr_vlrjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          ELSE -- PJ
            pr_vlrjuros2.valorpj := pr_vlrjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
            END IF;

          END IF;

        ELSE

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_finjuros2.valorpf := pr_finjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          ELSE  -- PJ
            pr_finjuros2.valorpj := pr_finjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          END IF;

        END IF;

      ELSIF rw_crapris_jur.tpemprst = 2 THEN  -- POS FIXADO

        -- Emprestimo
        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros6.valorpf := pr_vlrjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
      END IF;
          ELSE -- PJ
            pr_vlrjuros6.valorpj := pr_vlrjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
            END IF;

          END IF;

        ELSE

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_finjuros6.valorpf := pr_finjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          ELSE  -- PJ
            pr_finjuros6.valorpj := pr_finjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
            END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;

    --Soma de Juros +60 a apropriar para contratos refinanciados.
    FOR  rw_crapris_jur_refi in cr_crapris_jur_refi(par_cdcooper,
                                                    par_cdmodali) LOOP
      --EMPRESTIMOS
       IF par_cdmodali = 299 THEN
         IF rw_crapris_jur_refi.inpessoa = 1 THEN -- PF
           --Tipos de Emprestimos
           --TR
           IF rw_crapris_jur_refi.tpemprst = 0  THEN
              pr_empjuros1.valorpf := pr_empjuros1.valorpf +rw_crapris_jur_refi.vljura60;

              IF pr_tabvlempjur1.exists(rw_crapris_jur_refi.cdagenci) THEN
                 pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
              ELSE
                 pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
               END IF;
             END IF;

             --PP
             IF rw_crapris_jur_refi.tpemprst = 1  THEN
                pr_empjuros2.valorpf := pr_empjuros2.valorpf +rw_crapris_jur_refi.vljura60;

                IF pr_tabvlempjur2.exists(rw_crapris_jur_refi.cdagenci) THEN
                   pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
                ELSE
                   pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
                END IF;
              END IF;

                --POS
              IF rw_crapris_jur_refi.tpemprst > 1  THEN
                 pr_empjuros3.valorpf := pr_empjuros3.valorpf +rw_crapris_jur_refi.vljura60;

                 IF pr_tabvlempjur3.exists(rw_crapris_jur_refi.cdagenci) THEN
                    pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
                 ELSE
                    pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
                 END IF;

               END IF;
             END IF;

         IF rw_crapris_jur_refi.inpessoa = 2 THEN -- PJ
           --Tipos de Emprestimos
           --TR
           IF rw_crapris_jur_refi.tpemprst = 0  THEN
              pr_empjuros1.valorpj := pr_empjuros1.valorpj +rw_crapris_jur_refi.vljura60;

              IF pr_tabvlempjur1.exists(rw_crapris_jur_refi.cdagenci) THEN
                 pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpj  := NVL(pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
              ELSE
                 pr_tabvlempjur1(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
              END IF;
            END IF;

           --PP
           IF rw_crapris_jur_refi.tpemprst = 1  THEN
              pr_empjuros2.valorpj := pr_empjuros2.valorpj +rw_crapris_jur_refi.vljura60;

              IF pr_tabvlempjur2.exists(rw_crapris_jur_refi.cdagenci) THEN
                 pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpj := NVL(pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
              ELSE
                 pr_tabvlempjur2(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
              END IF;
            END IF;

           --POS
           IF rw_crapris_jur_refi.tpemprst > 1  THEN
               pr_empjuros3.valorpj := pr_empjuros3.valorpj +rw_crapris_jur_refi.vljura60;

               IF pr_tabvlempjur3.exists(rw_crapris_jur_refi.cdagenci) THEN
                  pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpj := NVL(pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
               ELSE
                  pr_tabvlempjur3(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
               END IF;

             END IF;
          END IF;
       END IF;

       --FINANCIAMENTO
       IF  par_cdmodali = 499  THEN

        IF rw_crapris_jur_refi.inpessoa = 1 THEN -- PF
            --Tipos de Emprestimos

            --TR
            IF rw_crapris_jur_refi.tpemprst = 0  THEN
               pr_finjuros3.valorpf := pr_finjuros3.valorpf +rw_crapris_jur_refi.vljura60;

               IF pr_tabvlfinjur1.exists(rw_crapris_jur_refi.cdagenci) THEN
                  pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
               ELSE
                  pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
               END IF;

             END IF;

            --PP
            IF rw_crapris_jur_refi.tpemprst = 1  THEN
                pr_finjuros4.valorpf := pr_finjuros4.valorpf +rw_crapris_jur_refi.vljura60;

                IF pr_tabvlfinjur2.exists(rw_crapris_jur_refi.cdagenci) THEN
                   pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
                ELSE
                   pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
                END IF;

             END IF;

            --POS
            IF rw_crapris_jur_refi.tpemprst > 1  THEN
               pr_finjuros5.valorpf := pr_finjuros5.valorpf +rw_crapris_jur_refi.vljura60;

                IF pr_tabvlfinjur3.exists(rw_crapris_jur_refi.cdagenci) THEN
                   pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpf := NVL(pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpf,0) +  rw_crapris_jur_refi.vljura60;
                ELSE
                   pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpf := rw_crapris_jur_refi.vljura60;
                END IF;
             END IF;

          END IF;


        IF rw_crapris_jur_refi.inpessoa = 2 THEN -- PJ
          --Tipos de Emprestimos
          --TR
          IF rw_crapris_jur_refi.tpemprst = 0  THEN
             pr_finjuros3.valorpj := pr_finjuros3.valorpj +rw_crapris_jur_refi.vljura60;

             IF pr_tabvlfinjur1.exists(rw_crapris_jur_refi.cdagenci) THEN
                pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpj := NVL(pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
             ELSE
                pr_tabvlfinjur1(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
             END IF;

           END IF;

          --PP
          IF rw_crapris_jur_refi.tpemprst = 1  THEN
            pr_finjuros4.valorpj := pr_finjuros4.valorpj +rw_crapris_jur_refi.vljura60;

            IF pr_tabvlfinjur2.exists(rw_crapris_jur_refi.cdagenci) THEN
               pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpj := NVL(pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
            ELSE
               pr_tabvlfinjur2(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
            END IF;

          END IF;

          --POS
          IF rw_crapris_jur_refi.tpemprst > 1  THEN
            pr_finjuros5.valorpj := pr_finjuros5.valorpj +rw_crapris_jur_refi.vljura60;

            IF pr_tabvlfinjur3.exists(rw_crapris_jur_refi.cdagenci) THEN
               pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpj := NVL(pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpj,0) +  rw_crapris_jur_refi.vljura60;
             ELSE
               pr_tabvlfinjur3(rw_crapris_jur_refi.cdagenci).valorpj := rw_crapris_jur_refi.vljura60;
            END IF;
           END IF;

         END IF;
       END IF;
    END LOOP;

    IF par_cdmodali = 999 THEN
        --Soma de valoor juros e taxas de contas correntes inadimplentes
        FOR  rw_conta_negativa in cr_conta_negativa(par_cdcooper) LOOP

          FOR  rw_conta_juros60 in cr_conta_juros60(par_cdcooper,
                                                    rw_conta_negativa.nrdconta) LOOP

                IF rw_conta_negativa.inpessoa = 1 THEN  --Pessoa Fisica
                   -- 0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU
                   --(CRPS249) PROVISAO JUROS CH. ESPECIAL
                    IF rw_conta_juros60.cdhistor = 38 THEN
                       pr_juros38.valorpf := pr_juros38.valorpf +rw_conta_juros60.vllanmto;

                        IF pr_tabvljuros38.exists(rw_conta_juros60.cdagenci) THEN
                           pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpf := NVL(pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpf,0) +  rw_conta_juros60.vllanmto;
                        ELSE
                           pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpf := rw_conta_juros60.vllanmto;
                        END IF;


                    END IF;

                    IF rw_conta_juros60.cdhistor = 37 THEN
                       pr_taxas37.valorpf := pr_taxas37.valorpf +rw_conta_juros60.vllanmto;

                       IF pr_tabvltaxas37.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpf := NVL(pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpf,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpf := rw_conta_juros60.vllanmto;
                       END IF;
                    END IF;

                    IF rw_conta_juros60.cdhistor = 57 THEN
                       pr_juros57.valorpf := pr_juros57.valorpf +rw_conta_juros60.vllanmto;

                       IF pr_tabvljuros57.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpf := NVL(pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpf,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpf := rw_conta_juros60.vllanmto;
                       END IF;

                    END IF;

                    IF rw_conta_juros60.cdhistor = 1441 THEN
                       pr_tarifa1441.valorpf := pr_tarifa1441.valorpf +rw_conta_juros60.vllanmto;

                       IF pr_tabvltarifa1441.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpf := NVL(pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpf,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpf := rw_conta_juros60.vllanmto;
                       END IF;


                    END IF;

                    IF rw_conta_juros60.cdhistor = 1465 THEN

                       pr_tarifa1465.valorpf := pr_tarifa1465.valorpf +rw_conta_juros60.vllanmto;

                       IF pr_tabvltarifa1465.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpf := NVL(pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpf,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpf := rw_conta_juros60.vllanmto;
                       END IF;


                    END IF;

                END IF;

                IF rw_conta_negativa.inpessoa = 2  THEN --Pessoa Juridica
                   -- 0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU
                   --(CRPS249) PROVISAO JUROS CH. ESPECIAL
                    IF rw_conta_juros60.cdhistor = 38 THEN
                       pr_juros38.valorpj := pr_juros38.valorpj +rw_conta_juros60.vllanmto;

                        IF pr_tabvljuros38.exists(rw_conta_juros60.cdagenci) THEN
                           pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpj := NVL(pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpj,0) +  rw_conta_juros60.vllanmto;
                        ELSE
                           pr_tabvljuros38(rw_conta_juros60.cdagenci).valorpj := rw_conta_juros60.vllanmto;
                        END IF;

                    END IF;

                    IF rw_conta_juros60.cdhistor = 37 THEN
                       pr_taxas37.valorpj := pr_taxas37.valorpj +rw_conta_juros60.vllanmto;

                       IF pr_tabvltaxas37.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpj := NVL(pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpj,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltaxas37(rw_conta_juros60.cdagenci).valorpj := rw_conta_juros60.vllanmto;
                       END IF;

                    END IF;

                    IF rw_conta_juros60.cdhistor = 57 THEN
                       pr_juros57.valorpj := pr_juros57.valorpj +rw_conta_juros60.vllanmto;

                       IF pr_tabvljuros57.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpj := NVL(pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpj,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvljuros57(rw_conta_juros60.cdagenci).valorpj := rw_conta_juros60.vllanmto;
                       END IF;

                    END IF;

                    IF rw_conta_juros60.cdhistor = 1441 THEN
                       pr_tarifa1441.valorpj := pr_tarifa1441.valorpj +rw_conta_juros60.vllanmto;

                       IF pr_tabvltarifa1441.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpj := NVL(pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpj,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltarifa1441(rw_conta_juros60.cdagenci).valorpj := rw_conta_juros60.vllanmto;
                       END IF;

                    END IF;

                    IF rw_conta_juros60.cdhistor = 1465 THEN
                       pr_tarifa1465.valorpj := pr_tarifa1465.valorpj +rw_conta_juros60.vllanmto;

                       IF pr_tabvltarifa1465.exists(rw_conta_juros60.cdagenci) THEN
                          pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpj := NVL(pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpj,0) +  rw_conta_juros60.vllanmto;
                       ELSE
                          pr_tabvltarifa1465(rw_conta_juros60.cdagenci).valorpj := rw_conta_juros60.vllanmto;
                       END IF;



                    END IF;

                END IF;

           END LOOP;

        END LOOP;

     END IF;


  END pc_calcula_juros_60k;

  /*** Gerar arquivo txt para radar ***/
  PROCEDURE pc_risco_k(pr_cdcooper   IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_retfile   OUT VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS
  /* .............................................................................
  Programa: Includes/riscok.i (Conversão)
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Felipe Oliveira
  Data    : Dezembro/2014                       Ultima Alteracao: 21/03/2018

  Dados referentes ao programa:

  Frequencia: Diario (on-line)
  Objetivo  : Gerar Arq. Contabilizacao Provisao
              (Relatorio 321)

  Alterações:
      08/04/2015 - Equalização com versão do Progress (Guilherme/SUPERO)
                   Projeto 186 - Divisão PF/PJ

      03/09/2015 - Passar a enviar os valores de Juros+60 por tipo de pessoa
                   e nível de risco juntamente as classificações de risco e
                   Enviar os valores da dívida por tipo de MicroCrédito.
                   Projeto 214 - (Vanessa).

      06/11/2015 - Pequena correção com as contas de debito conforme solicitação
                   da Adriana - Contabil (Marcos-Supero)

      01/12/2015 - Ajuste na carga das temp-tables de MicroCredito, pois para cooperativas
                   sem o PA 999 estava gerando no-data-found (Marcos-supero)


      07/12/2015 - Inversão das contas de crédito e débito no envio das informações
                   de Juros+60 conforme solicitação da Adriana (Marcos-Supero)

      17/03/2016 - Tratar o arquivo contábil gerado na opção "K" da tela RISCO,
                   para incluir a Provisão de operações do BNDES.
                   (Carlos Rafael Tanholi - SD 370441)

     06/10/2016 - Alteração do diretório para geração de arquivo contábil.
                   P308 (Ricardo Linhares).

     02/01/2017 - Ajustes da incorporação Transulcred -> Transpocred, no projeto
                  214 foi implementado para gerar os juros+60 separadamente, porém não foi
                  tratado a incorporação, estava somando a incorporação na nova cooperativa
                  no fechamento do mes. (Oscar).

     27/04/2017 - Nas linhas de reversao verificar se é uma data util
                  (Tiago/Thiago SD 589074).

     21/07/2017 - Ajuste para somar os lançamentos de rendas a apropriar e provisao das
                  cessoes nos emprestimos PP modalidade 299 (SD 718024 Anderson).

     09/02/2018 - Ajuste para contemplar o Juros 60 para o produto Pos Fixado. (James)

     12/03/2018 - Ajuste para exibir valores de juros +60 de contratos refinanciados
                  Projeto Ligeirinho (Rangel Decker) AMcom

     21/03/2018 - Ajuste para exibir valores de juros,taxas,mora etc... de contas
                  correntes negativas e caso possuir com limites de credito estourado (Rangel Decker) AMcom

  ............................................................................. */


    /**********************************  CURSORES ****************************/

    -- Buscar informações da central de risco para documento 3020
    CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE
                     ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT ris.cdcooper
            ,ris.dtrefere
            ,ris.vldivida
            ,ris.nrdconta
            ,ris.innivris
            ,ris.cdmodali
            ,ris.nrctremp
            ,ris.nrseqctr
            ,ris.dsinfaux
            ,ris.vljura60
            ,ris.cdorigem
            ,ris.inpessoa
            ,ris.cdagenci
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 1
       ORDER BY ris.cdagenci
               ,ris.nrdconta
               ,ris.nrctremp;

    -- Cursor LIMITE NAO UTILIZADO - LNU
    CURSOR cr_crapris_lnu(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT ris.cdcooper
            ,ris.dtrefere
            ,ris.vldivida
            ,ris.nrdconta
            ,ris.inpessoa
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 3
         AND ris.cdmodali = 1901;

    -- Buscar as informações dos vencimentos de risco
    CURSOR cr_crapvri(pr_cdcooper IN crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN crapvri.dtrefere%TYPE
                     ,pr_innivris IN crapvri.innivris%TYPE
                     ,pr_cdmodali IN crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN crapvri.nrseqctr%TYPE) IS
      SELECT vri.cdvencto
            ,vri.vldivida
            ,vri.cdcooper
            ,vri.nrdconta
            ,vri.dtrefere
            ,vri.innivris
            ,vri.cdmodali
            ,vri.nrctremp
            ,vri.nrseqctr
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.nrdconta = pr_nrdconta
         AND vri.dtrefere = pr_dtrefere
         AND vri.innivris = pr_innivris
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr
       ORDER BY vri.nrdconta
               ,vri.nrctremp;

    -- Busca vencimentos de risco maior q 190
    CURSOR cr_crabvri(pr_cdcooper IN crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN crapvri.dtrefere%TYPE
                     ,pr_innivris IN crapvri.innivris%TYPE
                     ,pr_cdmodali IN crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN crapvri.nrseqctr%TYPE) IS
      SELECT vri.cdcooper
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.nrdconta = pr_nrdconta
         AND vri.innivris = pr_innivris
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr
         AND vri.cdvencto > 190;
    rw_crabvri cr_crabvri%ROWTYPE;

    -- Buscar informações do tipo de emprestimo, conforme o contrato
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT crapepr.tpemprst
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- Buscar agencias da cooperativa
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
      SELECT crapage.cdagenci
            ,crapage.cdccuage
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper;

    -- Buscar parametro na tabela CRAPTAB
    CURSOR cr_craptab(par_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT craptab.dstextab
        FROM craptab
       WHERE craptab.cdcooper = par_cdcooper
         AND UPPER(craptab.nmsistem) = 'CRED'
         AND UPPER(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 00
         AND UPPER(craptab.cdacesso) = 'PROVISAOCL';


    -- Inicializar tabela de Microcredito
    CURSOR cr_tabmicro(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
        SELECT age.cdagenci
              ,lcr.dsorgrec
          FROM craplcr lcr
              ,(select cdagenci from crapage where cdcooper = pr_cdcooper
                union
                select 999 from dual) age
         WHERE lcr.cdcooper = pr_cdcooper
           AND lcr.cdusolcr = 1
           AND lcr.dsorgrec <> ' '
           GROUP BY age.cdagenci,lcr.dsorgrec
           ORDER BY age.cdagenci,lcr.dsorgrec ASC;
    rw_tabmicro cr_tabmicro%ROWTYPE;

    -- Verificar se o contrato  refere-se a MicroCrédito
    CURSOR cr_craplcr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT lcr.cdusolcr
              ,lcr.dsorgrec
          FROM craplcr lcr
              ,crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;


    -- Valores de juros+60 para os empréstimos/financiamentos
    --por tipo de pessoa e nível de risco
    CURSOR cr_crapris_60(pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_cdcopant IN craptco.cdcopant%TYPE
                        ,pr_dtincorp IN crapdat.dtmvtolt%TYPE) IS
        SELECT  ris.inpessoa
               ,ris.innivris
               ,SUM(ris.vljura60) vljura60
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper --Cooperativa atual
           AND ris.dtrefere = pr_dtrefere --Data atual da cooperativa
           AND ris.inddocto = 1           --Contratos ativos
           AND ris.cdorigem = 3           --Empréstimos / Financiamentos
           AND (NOT EXISTS (SELECT 1
                              FROM craptco t
                             WHERE t.cdcooper = ris.cdcooper
                               AND t.nrdconta = ris.nrdconta
                               AND t.cdcopant = pr_cdcopant) OR
               pr_dtrefere > pr_dtincorp)
          GROUP BY ris.inpessoa
                  ,ris.innivris
          HAVING SUM(ris.vljura60) > 0
          ORDER BY ris.inpessoa
                  ,ris.innivris;
    rw_crapris_60 cr_crapris_60%ROWTYPE;

    -- cursor de emprestimos do BNDES
    CURSOR cr_crapebn(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT crapebn.nrctremp
        FROM crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctremp;
    rw_crapebn cr_crapebn%ROWTYPE;

    --> Verificar se é um emprestimo de cessao de credito
    CURSOR cr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                      pr_nrdconta crapepr.nrdconta%TYPE,
                      pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM tbcrd_cessao_credito ces
       WHERE ces.cdcooper = pr_cdcooper
         AND ces.nrdconta = pr_nrdconta
         AND ces.nrctremp = pr_nrctremp;

    /*****************************  VARIAVEIS  ****************************/
    vr_exc_erro          EXCEPTION;
    vr_file_erro         EXCEPTION;

    vr_nrmaxpas          INTEGER := 0;
    rw_crapdat           btch0001.cr_crapdat%ROWTYPE;

    vr_dircon VARCHAR2(200);
    vr_arqcon VARCHAR2(200);


    -- Constante para usar em indice do primeiro nivel
    vr_price_atr CONSTANT VARCHAR2(3) := 'ATR'; -- PRICE TR
    vr_price_pre CONSTANT VARCHAR2(3) := 'PRE'; -- PRICE PRÉ-FIXADO

    -- Constante para usar em indice do segundo nivel
    vr_price_pf CONSTANT VARCHAR2(1) := '1';     -- Coluna de Pessoa Fisica
    vr_price_pj CONSTANT VARCHAR2(1) := '2';     -- Coluna de Pessoa Juridica

    -- Constante para usar em indice do terceiro nivel
    vr_price_deb CONSTANT VARCHAR2(1) := 'D'; -- PRICE TR
    vr_price_cre CONSTANT VARCHAR2(1) := 'C'; -- PRICE PRÉ-FIXADO

    -- Pl-Table para gravar as contas por tipo Tipo de Produto X Tipo de Pessoa X Origem do Recurso
    TYPE typ_reg_contas IS
       RECORD(nrdconta NUMBER);       -- Numero da conta

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_descricao IS TABLE OF typ_reg_contas INDEX BY VARCHAR2(36);

    -- Instancia e indexa por Debito/Credito
    TYPE typ_tab_debcre IS TABLE OF typ_tab_descricao INDEX BY VARCHAR2(1);

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_pessoa IS TABLE OF typ_tab_debcre INDEX BY VARCHAR2(1);

     -- Informações por tipo de produto
    TYPE typ_tab_produto IS TABLE OF typ_tab_pessoa INDEX BY VARCHAR2(3);
    vr_tab_contas        typ_tab_produto;

    -- Armazenar as informações principais do microcredito
    TYPE typ_tab_microtrpre IS TABLE OF typ_decimal INDEX BY VARCHAR2(43);
    TYPE typ_tab_dsorgrec   IS TABLE OF typ_tab_microtrpre INDEX BY VARCHAR2(4);

    --Armazenar as informações de lançamentos de conta corrente ADP
    TYPE typ_lancamento_conta IS RECORD (
      valorl  NUMBER(25,2) :=0
     );

    TYPE typ_arr_lacamento_conta IS TABLE OF typ_lancamento_conta INDEX BY BINARY_INTEGER;


    vr_tab_microcredito        typ_tab_dsorgrec;

    vr_pacvljur_1        typ_arr_decimal_pfpj;
    vr_pacvljur_2        typ_arr_decimal_pfpj;
    vr_pacvljur_3        typ_arr_decimal_pfpj;
    vr_pacvljur_4        typ_arr_decimal_pfpj;
    vr_pacvljur_5        typ_arr_decimal_pfpj;
    vr_pacvljur_6        typ_arr_decimal_pfpj;
    vr_pacvljur_7        typ_arr_decimal_pfpj;

    -- Calculo de Juros - Variáveis acumuladoras para geração do arquivo
    vr_vldjuros          typ_decimal_pfpj;
    vr_finjuros          typ_decimal_pfpj;
    vr_vldjuros2         typ_decimal_pfpj;
    vr_finjuros2         typ_decimal_pfpj;
    vr_vldjuros6         typ_decimal_pfpj;
    vr_finjuros6         typ_decimal_pfpj;
    vr_vldjuros3         typ_decimal_pfpj;
    -- Calculo de Juros / Variáveis de retorno da pc_calcula_juros_60k
    vr_vldjur_calc       typ_decimal_pfpj;
    vr_finjur_calc       typ_decimal_pfpj;
    vr_vldjur_calc2      typ_decimal_pfpj;
    vr_finjur_calc2      typ_decimal_pfpj;
    vr_vldjur_calc3      typ_decimal_pfpj;
    vr_vldjur_calc6      typ_decimal_pfpj;
    vr_finjur_calc6      typ_decimal_pfpj;

    vr_empjur_calc1      typ_decimal_pfpj;
    vr_empjur_calc2      typ_decimal_pfpj;
    vr_empjur_calc3      typ_decimal_pfpj;

    vr_finjur_calc3      typ_decimal_pfpj;
    vr_finjur_calc4      typ_decimal_pfpj;
    vr_finjur_calc5      typ_decimal_pfpj;

    vr_juros38_calc      typ_decimal_pfpj;
    vr_taxas37_calc      typ_decimal_pfpj;
    vr_juros57_calc      typ_decimal_pfpj;
    vr_tarifa1441_calc   typ_decimal_pfpj;
    vr_tarifa1465_calc   typ_decimal_pfpj;



    vr_empjuros1          typ_decimal_pfpj;
    vr_empjuros2          typ_decimal_pfpj;
    vr_empjuros3          typ_decimal_pfpj;

    vr_finjuros3          typ_decimal_pfpj;
    vr_finjuros4          typ_decimal_pfpj;
    vr_finjuros5          typ_decimal_pfpj;

    vr_juros38            typ_decimal_pfpj;
    vr_taxas37            typ_decimal_pfpj;
    vr_juros57            typ_decimal_pfpj;
    vr_tarifa1441         typ_decimal_pfpj;
    vr_tarifa1465         typ_decimal_pfpj;

    --Somatorio das Agencias
    vr_tabvlempjur1        typ_arr_decimal_pfpj;
    vr_tabvlempjur2        typ_arr_decimal_pfpj;
    vr_tabvlempjur3        typ_arr_decimal_pfpj;
    vr_tabvlfinjur1        typ_arr_decimal_pfpj;
    vr_tabvlfinjur2        typ_arr_decimal_pfpj;
    vr_tabvlfinjur3        typ_arr_decimal_pfpj;

    vr_tabvljuros38        typ_arr_decimal_pfpj;
    vr_tabvltaxas37        typ_arr_decimal_pfpj;
    vr_tabvljuros57        typ_arr_decimal_pfpj;
    vr_tabvltarifa1441     typ_arr_decimal_pfpj;
    vr_tabvltarifa1465     typ_arr_decimal_pfpj;


    vr_rel_dsdrisco      typ_arr_decimal;
    vr_rel_percentu      typ_arr_decimal;
    vr_rel_vldabase      typ_arr_decimal;
    vr_rel_vlprovis      typ_arr_decimal;

    vr_rel_vldivida      typ_arr_decimal;
    vr_vlpercen          NUMBER := 0;
    vr_vldivida_sldblq   NUMBER := 0;
    vr_vlpreatr          NUMBER := 0;
    vr_vlempatr_bndes_2  NUMBER := 0;

    vr_vlag0101          typ_arr_decimal_pfpj;
    vr_vlag0101_1722_v   typ_arr_decimal_pfpj;
    vr_vlag0201          typ_arr_decimal_pfpj;
    vr_vlag0201_1722_v   typ_arr_decimal_pfpj;
    vr_vlag0299_1613     typ_arr_decimal_pfpj;
    vr_vlag1724          typ_arr_decimal_pfpj;   -- AJUSTE PROVISAO TIT.DESCONTADOS PF/PJ


    vr_vlag0101_1611     typ_arr_decimal;
    vr_vlag0201_1622     typ_arr_decimal;
    vr_vlag1721          typ_arr_decimal;   -- AJUSTE PROVISAO EMPR.PESSOAIS
    vr_vlag1723          typ_arr_decimal;   -- AJUSTE PROVISAO EMPR.EMPRESAS
    vr_vlag1731_1        typ_arr_decimal;   -- AJUSTE PROVISAO FIN.PESSOAIS
    vr_vlag1731_2        typ_arr_decimal;   -- AJUSTE PROVISAO FIN.EMPRESAS
    vr_vlag1721_pre      typ_arr_decimal;
    vr_vlag1723_pre      typ_arr_decimal;
    vr_vlag1731_1_pre    typ_arr_decimal;

    vr_vlag1731_2_pre    typ_arr_decimal;
    vr_vlatrage_bndes_2  typ_arr_decimal;
    vr_rel1723_v_pre     NUMBER := 0;

    vr_rel1731_2_v_pre   NUMBER := 0;

    vr_rel1721           NUMBER := 0;
    vr_rel1723           NUMBER := 0;
    vr_rel1731_1         NUMBER := 0;
    vr_rel1731_2         NUMBER := 0;



    --CESSAO
    vr_rel1760_pre       NUMBER := 0;
    vr_rel1761_pre       NUMBER := 0;
    vr_rel1760_v_pre     NUMBER := 0;
    vr_rel1761_v_pre     NUMBER := 0;
    vr_vlag1760_pre      typ_arr_decimal;
    vr_vlag1761_pre      typ_arr_decimal;


    vr_rel1724           typ_decimal_pfpj;
    vr_rel1722_0101      typ_decimal_pfpj;
    vr_rel1722_0201      typ_decimal_pfpj;
    vr_rel1722_0201_v    typ_decimal_pfpj;
    vr_rel1722_0101_v    typ_decimal_pfpj;
    vr_rel1613_0299_v    typ_decimal_pfpj;
    vr_rel1724_v         typ_decimal_pfpj;

    vr_rel1721_v         NUMBER := 0;
    vr_rel1723_v         NUMBER := 0;
    vr_rel1731_1_v       NUMBER := 0;
    vr_rel1731_2_v       NUMBER := 0;

    vr_rel1731_2_pre     NUMBER := 0;
    vr_rel1731_1_pre     NUMBER := 0;
    vr_rel1723_pre       NUMBER := 0;
    vr_rel1721_pre       NUMBER := 0;

    vr_rel1721_v_pre     NUMBER := 0;
    vr_rel1731_1_v_pre   NUMBER := 0;

    -->> POS <<--
      --FIN
    vr_vldespes_pj_pos     NUMBER := 0;
    vr_vldespes_pf_pos     NUMBER := 0;
    vr_vldevedo_pf_v_pos   NUMBER := 0;
    vr_vldevedo_pj_v_pos   NUMBER := 0;
    vr_vlag1731_1_pos    typ_arr_decimal;
    vr_vlag1731_2_pos    typ_arr_decimal;

      --EMPR
    --PF
    vr_rel1721_v_pos       NUMBER := 0;
    vr_rel1721_pos         NUMBER := 0;
    --PJ
    vr_rel1723_pos         NUMBER := 0;
    vr_rel1723_v_pos       NUMBER := 0;
    vr_vlag1721_pos        typ_arr_decimal; --> PF
    vr_vlag1723_pos        typ_arr_decimal; --> PJ


    vr_relmicro_atr_pf   NUMBER := 0;
    vr_relmicro_pre_pf   NUMBER := 0;
    vr_relmicro_atr_pj   NUMBER := 0;
    vr_relmicro_pre_pj   NUMBER := 0;

    vr_contador           INTEGER;

    vr_arrchave1 VARCHAR(4);
    vr_contador1 VARCHAR(43);
    vr_arrchave2 VARCHAR(43);
    vr_flgmicro  BOOLEAN ;

    vr_flsoavto          BOOLEAN;

    vr_vlprejuz_conta    NUMBER := 0;
    vr_vldivida          NUMBER := 0;

    vr_vllmtepf          NUMBER := 0;
    vr_vllmtepj          NUMBER := 0;

    vr_dtinicio          DATE := '01/08/2010';

    vr_dtmovime          DATE;
    vr_dtmvtopr          DATE;
    vr_dtmvtolt          DATE;

    TYPE typ_nrdcctab IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    TYPE typ_vldcctab IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
    vr_nrdcctab          typ_nrdcctab;
    vr_vldevedo          typ_vldcctab;  -- Vl Devedor PF
    vr_vldevepj          typ_vldcctab;  -- Vl Devedor PJ
    vr_vldespes          typ_vldcctab;  -- Vl Despes PF
    vr_vldesppj          typ_vldcctab;  -- Vl Despes PJ
    vr_vltotdev          NUMBER;
    vr_vltotdes          NUMBER;

    vr_con_dtmvtolt      VARCHAR(3000);
    vr_con_dtmvtopr      VARCHAR(3000);
    vr_con_dtmovime      VARCHAR(3000);
    vr_linhadet          VARCHAR(3000);
    vr_cdccuage          typ_arr_decimal;

    vr_vllanmto          NUMBER := 0;
    vr_ttlanmto          NUMBER := 0;
    vr_ttlanmto_risco    NUMBER := 0;
    vr_ttlanmto_divida   NUMBER := 0;

    vr_fleprces          INTEGER := 0;

    -- Variaveis para tratamento de erros
    vr_cdprogra          CONSTANT crapprg.cdprogra%TYPE := 'RISCO';
    vr_cdcritic          PLS_INTEGER;
    vr_dscritic          VARCHAR2(4000);
    vr_contacon          INTEGER;
    vr_nrdcctab_c        VARCHAR(15);
    vr_dtrefere          DATE;

    -- Declarando handle do Arquivo
    vr_ind_arquivo       utl_file.file_type;
    vr_utlfileh          VARCHAR2(4000);
    -- Nome do Arquivo
    vr_nmarquiv          VARCHAR2(100);
    -- Comando completo
    vr_dscomando         VARCHAR2(4000);
    -- Saida da OS Command
    vr_typ_saida         VARCHAR2(4000);
    -- Cooperativas incorporadas
    vr_dtincorp crapdat.dtmvtolt%TYPE;
    vr_cdcopant craptco.cdcopant%TYPE;

    --Váriveis juros microcredito
    vr_chave VARCHAR2(200);
    vr_tpemprst VARCHAR2(2);
    vr_nrctadst NUMBER;
    vr_nrctaori NUMBER;
    vr_descricao VARCHAR2(200);
    vr_chave2 varchar2(10);

    -- Escrever linha no arquivo
    PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
    BEGIN
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
    END;

  BEGIN
    --Armazena as informações das contas Tipo de Produto X Tipo de Pessoa X Origem do Recurso.
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('RECURSO PROPRIO').nrdconta := 0;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('RECURSO PROPRIO').nrdconta := 0;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 5558;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 5559;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 5572;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 5573;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 5558;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 5559;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 5572;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 5573;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 5558;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 5559;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 5572;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 5573;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 5552;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 5553;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 5566;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 5567;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5506;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5507;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5508;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5509;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES CECRED').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 5554;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 5555;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 5568;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 5569;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 5556;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 5557;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 5570;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 5571;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 5558;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 5559;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 5572;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 5573;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 5558;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 5559;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 5572;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 5573;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 5563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 5552;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 5548;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 5553;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 5549;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 5566;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 5562;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 5567;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 5563;

    -- CONTAS JUROS +60
    -- vr_tab_risco('B') := 3;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('3').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('3').nrdconta := 3333;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('3').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('3').nrdconta := 3333;
    --  vr_tab_risco('C') := 4;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('4').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('4').nrdconta := 3343;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('4').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('4').nrdconta := 3343;
    -- vr_tab_risco('D') := 5;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('5').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('5').nrdconta := 3353;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('5').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('5').nrdconta := 3353;
    -- vr_tab_risco('E') := 6;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('6').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('6').nrdconta := 3363;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('6').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('6').nrdconta := 3363;
    --vr_tab_risco('F') := 7;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('7').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('7').nrdconta := 3373;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('7').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('7').nrdconta := 3373;
    --vr_tab_risco('G') := 8;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('8').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('8').nrdconta := 3383;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('8').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('8').nrdconta := 3383;
    -- vr_tab_risco('H') := 9;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('9').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('9').nrdconta := 3393;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('9').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('9').nrdconta := 3393;


    -- ZERAR VARIAVEIS PF/PJ
    vr_rel1722_0201_v.valorpf := 0;
    vr_rel1722_0201_v.valorpj := 0;
    vr_rel1722_0201.valorpf   := 0;
    vr_rel1722_0201.valorpj   := 0;
    vr_rel1613_0299_v.valorpf := 0;
    vr_rel1613_0299_v.valorpj := 0;
    vr_rel1722_0101_v.valorpf := 0;
    vr_rel1722_0101_v.valorpj := 0;
    vr_rel1722_0101.valorpf   := 0;
    vr_rel1722_0101.valorpj   := 0;
    vr_rel1724.valorpf        := 0;
    vr_rel1724.valorpj        := 0;
    vr_rel1724_v.valorpf      := 0;
    vr_rel1724_v.valorpj      := 0;

    -- Data de referencia
    vr_dtrefere := to_date(pr_dtrefere, 'dd/mm/YY');

    -- CRAPTAB -> 'PROVISAOCL'
    FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
      vr_contador                         := substr(rw_craptab.dstextab, 12, 2);
      vr_rel_dsdrisco(vr_contador).dsc    := TRIM(substr(rw_craptab.dstextab, 8, 3));
      vr_rel_percentu(vr_contador).valor  := substr(rw_craptab.dstextab, 1, 6);
    END LOOP;


    FOR rw_tabmicro IN cr_tabmicro(pr_cdcooper) LOOP
         -- Inicializa tabela de Microcrédito vr_price_pre||vr_price_pf;
        vr_arrchave1 := vr_price_pre||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,40,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_pre||vr_price_pj;
        vr_arrchave1 := vr_price_pre||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,40,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pf;
        vr_arrchave1 := vr_price_atr||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,40,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pj;
        vr_arrchave1 := vr_price_atr||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,40,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';
    END LOOP;

    -- Percorrer todos os dados de risco
    FOR rw_crapris IN cr_crapris(pr_cdcooper,
                                 vr_dtrefere) LOOP

      IF pr_cdcooper IN ( 1, 13 ,16, 09) THEN

        IF NOT fn_verifica_conta_migracao(rw_crapris.cdcooper,
                                          rw_crapris.nrdconta,
                                          rw_crapris.dtrefere) THEN
          CONTINUE;

        END IF;

      END IF;

      vr_vlprejuz_conta := 0;
      vr_vldivida := 0;

      -- Percorrer os valores do risco
      FOR rw_crapvri IN cr_crapvri(pr_cdcooper,
                                   rw_crapris.nrdconta,
                                   rw_crapris.dtrefere,
                                   rw_crapris.innivris,
                                   rw_crapris.cdmodali,
                                   rw_crapris.nrctremp,
                                   rw_crapris.nrseqctr) LOOP

        -- Variáveis auxiliares para regras do risco
        vr_contador := 0;
        vr_flsoavto := TRUE;

        -- Se código do vencimento estiver entre 110 e 290
        IF  rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vldivida := vr_vldivida + NVL(rw_crapvri.vldivida,0);
        ELSIF rw_crapvri.cdvencto IN (310,320,330) THEN -- Se for 310, 320 ou 330
          vr_vlprejuz_conta := vr_vlprejuz_conta + NVL(rw_crapvri.vldivida,0);
        END IF;

        ----- Gerando Valores Para Contabilizacao (RISCO) ---
        IF  rw_crapvri.cdvencto BETWEEN 110 AND 190 THEN -- nao se considerar a vencer porque tem vencidas

          -- Buscar valores do risco
          OPEN cr_crabvri(pr_cdcooper,
                          rw_crapvri.nrdconta,
                          rw_crapvri.dtrefere,
                          rw_crapvri.innivris,
                          rw_crapvri.cdmodali,
                          rw_crapvri.nrctremp,
                          rw_crapvri.nrseqctr);
          FETCH cr_crabvri INTO rw_crabvri;
          -- Verifica se encontrou registros
          IF cr_crabvri%FOUND THEN
            vr_flsoavto := FALSE;
            -- nao se considerar a vencer porque tem vencidas
          END IF;

          CLOSE cr_crabvri;

        END IF;

        -- Se nivel de risco for 1 ou 2
        IF rw_crapvri.innivris IN (1,2) THEN
          vr_contador := rw_crapvri.innivris;
        ELSIF rw_crapvri.cdvencto BETWEEN 110 AND 190 AND vr_flsoavto THEN -- A vencer
          -- Verificar nível de risco
          IF rw_crapvri.innivris = 3 THEN
            vr_contador := 3;
          ELSIF rw_crapvri.innivris = 4 THEN
            vr_contador := 5;
          ELSIF rw_crapvri.innivris = 5 THEN
            vr_contador := 7;
          ELSIF rw_crapvri.innivris = 6 THEN
            vr_contador := 9;
          ELSIF rw_crapvri.innivris = 7 THEN
            vr_contador := 11;
          ELSIF rw_crapvri.innivris = 8 THEN
            vr_contador := 13;
          ELSE
            vr_contador := 15;
          END IF;
        ELSE
          -- Verificar nível de risco
          IF rw_crapvri.innivris = 3 THEN
            vr_contador := 4;
          ELSIF rw_crapvri.innivris = 4 THEN
            vr_contador := 6;
          ELSIF rw_crapvri.innivris = 5 THEN
            vr_contador := 8;
          ELSIF rw_crapvri.innivris = 6 THEN
            vr_contador := 10;
          ELSIF rw_crapvri.innivris = 7 THEN
            vr_contador := 12;
          ELSIF rw_crapvri.innivris = 8 THEN
            vr_contador := 14;
          ELSE
            vr_contador := 16;
          END IF;
        END IF;

        -- Contabilizar risco - prejuizo --
        IF vr_rel_vldivida.exists(vr_contador) THEN
          vr_rel_vldivida(vr_contador).valor := nvl(vr_rel_vldivida(vr_contador).valor, 0) + rw_crapvri.vldivida;
        ELSE
          vr_rel_vldivida(vr_contador).valor := rw_crapvri.vldivida;
        END IF;

        -- Verifica se é prejuizo para Contabilidade
        IF rw_crapvri.cdvencto IN (310,320,330) THEN
          CONTINUE; -- Desprezar prejuizo - para Contabilidade
        END IF;

        IF vr_vldevedo.exists(vr_contador) THEN
          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapvri.vldivida;
        ELSE
          vr_vldevedo(vr_contador) := rw_crapvri.vldivida;
        END IF;
      END LOOP;  -- Fim do LOOP da cr_crapvri

      -- Reinicializa a variável
      vr_contador := rw_crapris.innivris;

      -- Nao provisionar prejuizo
      IF vr_vlprejuz_conta = rw_crapris.vldivida THEN
        CONTINUE;
      END IF;

      -- Calculo do % de provisao do Risco
      IF vr_rel_percentu.exists(vr_contador) THEN
         vr_vlpercen := vr_rel_percentu(vr_contador).valor / 100;
      ELSE
        vr_vlpercen := 0;
      END IF;

      -- Para Adiantamento a Depositante com Informacao Adicional
      IF  rw_crapris.cdorigem = 1
      AND rw_crapris.cdmodali = 101
      AND rw_crapris.dsinfaux <> ' ' THEN
        -- Armazenamos o valor da divida do Saldo Bloqueado
        vr_vldivida_sldblq := to_number(rw_crapris.dsinfaux, '999G999G999D99');
      ELSE
        -- Limpar variavel do Saldo Bloqueado
        vr_vldivida_sldblq := 0;
      END IF;

      -- Calculo da provisao do risco atual
      vr_vlpreatr := round(((vr_vldivida - rw_crapris.vljura60) *  vr_vlpercen), 2);

      -- Acumular totalizadores de provisao e divida por niveis
      IF vr_rel_vlprovis.exists(vr_contador) THEN
        vr_rel_vlprovis(vr_contador).valor := vr_rel_vlprovis(vr_contador).valor + vr_vlpreatr;
      ELSE
        vr_rel_vlprovis(vr_contador).valor := vr_vlpreatr;
      END IF;
      IF vr_rel_vldabase.exists(vr_contador) THEN
        vr_rel_vldabase(vr_contador).valor := vr_rel_vldabase(vr_contador).valor + vr_vldivida;
      ELSE
        vr_rel_vldabase(vr_contador).valor := vr_vldivida;
      END IF;

      vr_fleprces := 0;
      -- Emprestimos sem Crapepr devem ser desconsiderados
      IF rw_crapris.cdorigem = 3 THEN

        -- Buscar dados de emprestimo
        OPEN cr_crapepr(rw_crapris.cdcooper,
                        rw_crapris.nrdconta,
                        rw_crapris.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;

        -- Se nao encontrou, continua
        IF cr_crapepr%NOTFOUND THEN

          --verifica se eh uma operacao do BNDES
          OPEN cr_crapebn(rw_crapris.cdcooper,
                          rw_crapris.nrdconta,
                          rw_crapris.nrctremp);

          FETCH cr_crapebn INTO rw_crapebn;

          -- Se nao for do BNDES e nao existir na crapepr, continua
          IF cr_crapebn%NOTFOUND THEN
            CLOSE cr_crapebn;
          CONTINUE;
        END IF;

          CLOSE cr_crapebn;

        END IF;

        -- Fecha o curso para continuar
        CLOSE cr_crapepr;

      --> Verificar se é um emprestimo de cessao de credito
      OPEN cr_cessao (pr_cdcooper => rw_crapris.cdcooper,
                      pr_nrdconta => rw_crapris.nrdconta,
                      pr_nrctremp => rw_crapris.nrctremp);
      FETCH cr_cessao INTO vr_fleprces;
      CLOSE cr_cessao;

      END IF;

      -- CESSAO
      IF  vr_fleprces = 1 THEN
        -- Se pessoa Física
        IF rw_crapris.inpessoa = 1 THEN

          -- Verifica o tipo do empréstimo - PP
          IF rw_crapepr.tpemprst = 1 THEN

            vr_rel1760_pre   := vr_rel1760_pre   + vr_vlpreatr;
            vr_rel1760_v_pre := vr_rel1760_v_pre + vr_vldivida;

            IF vr_vlag1760_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1760_pre(rw_crapris.cdagenci).valor := vr_vlag1760_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1760_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            --Conforme SD 718024 - os dados das cessoes devem ser somados com os PP modalidade 299.
            vr_rel1721_pre   := vr_rel1721_pre   + vr_vlpreatr;
            IF vr_vlag1721_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlag1721_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;

          END IF;
        ELSE -- Se pessoa Juridica
          -- Verifica o tipo do empréstimo - PP
          IF rw_crapepr.tpemprst = 1 THEN

            vr_rel1761_pre   := vr_rel1761_pre + vr_vlpreatr;
            vr_rel1761_v_pre := vr_rel1761_v_pre + vr_vldivida;

            IF vr_vlag1761_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1761_pre(rw_crapris.cdagenci).valor := vr_vlag1761_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1761_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
      END IF;

            --Conforme SD 718024 - os dados das cessoes devem ser somados com os PP modalidade 299.
            vr_rel1723_pre   := vr_rel1723_pre + vr_vlpreatr;
            IF vr_vlag1723_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlag1723_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;
        END IF;
        END IF;
      ELSE  -- FIM - CESSAO

      -- EMPRESTIMOS
      IF  rw_crapris.cdorigem = 3 AND rw_crapris.cdmodali = 0299 THEN
        -- Se pessoa Física
        IF rw_crapris.inpessoa = 1 THEN
          -- Verifica o tipo do empréstimo
          IF rw_crapepr.tpemprst = 0 THEN

            vr_rel1721   := vr_rel1721   + vr_vlpreatr;
            vr_rel1721_v := vr_rel1721_v + vr_vldivida;

            IF vr_vlag1721.exists(rw_crapris.cdagenci) THEN
              vr_vlag1721(rw_crapris.cdagenci).valor := vr_vlag1721(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1721(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          -- Prefixado
          ELSIF rw_crapepr.tpemprst = 1 THEN

            vr_rel1721_pre   := vr_rel1721_pre   + vr_vlpreatr;
            vr_rel1721_v_pre := vr_rel1721_v_pre + vr_vldivida;

            IF vr_vlag1721_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlag1721_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          -- PosFixado
          ELSIF rw_crapepr.tpemprst = 2 THEN

            vr_rel1721_pos   := vr_rel1721_pos   + vr_vlpreatr;
            vr_rel1721_v_pos := vr_rel1721_v_pos + vr_vldivida;

            IF vr_vlag1721_pos.exists(rw_crapris.cdagenci) THEN
              vr_vlag1721_pos(rw_crapris.cdagenci).valor := vr_vlag1721_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1721_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;


          END IF;

        ELSE -- Se pessoa Juridica
          -- Verifica o tipo do empréstimo
          IF rw_crapepr.tpemprst = 0 THEN

            vr_rel1723   := vr_rel1723   + vr_vlpreatr;
            vr_rel1723_v := vr_rel1723_v + vr_vldivida;

            IF vr_vlag1723.exists(rw_crapris.cdagenci) THEN
              vr_vlag1723(rw_crapris.cdagenci).valor := vr_vlag1723(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1723(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          -- Prefixado
          ELSIF rw_crapepr.tpemprst = 1 THEN

            vr_rel1723_pre   := vr_rel1723_pre + vr_vlpreatr;
            vr_rel1723_v_pre := vr_rel1723_v_pre + vr_vldivida;

            IF vr_vlag1723_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlag1723_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          -- Pos Fixado
          ELSIF rw_crapepr.tpemprst = 2 THEN

            vr_rel1723_pos   := vr_rel1723_pos + vr_vlpreatr;
            vr_rel1723_v_pos := vr_rel1723_v_pos + vr_vldivida;

            IF vr_vlag1723_pos.exists(rw_crapris.cdagenci) THEN
              vr_vlag1723_pos(rw_crapris.cdagenci).valor := vr_vlag1723_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1723_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;
          END IF;
        END IF;
      END IF;  -- FIM - EMPRESTIMOS

      -- FINANCIAMENTOS
      IF  rw_crapris.cdorigem = 3 AND rw_crapris.cdmodali = 0499 THEN

        -- Verifica se é microcrédito
        OPEN cr_craplcr(rw_crapris.cdcooper,
                        rw_crapris.nrdconta,
                        rw_crapris.nrctremp);
        FETCH cr_craplcr INTO rw_craplcr;
        CLOSE cr_craplcr;


        -- Se pessoa física
        IF rw_crapris.inpessoa = 1 THEN  -- Pessoa fisica
          -- Verifica o tipo do empréstimo
          IF rw_crapepr.tpemprst = 0 THEN

            vr_rel1731_1   := vr_rel1731_1   + vr_vlpreatr;
            vr_rel1731_1_v := vr_rel1731_1_v + vr_vldivida;

            IF vr_vlag1731_1.exists(rw_crapris.cdagenci) THEN
              vr_vlag1731_1(rw_crapris.cdagenci).valor := vr_vlag1731_1(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1731_1(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            --Microcrédito
            IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
               vr_arrchave1 := vr_price_atr||vr_price_pf;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,40,' ')||LPAD(rw_crapris.cdagenci,3,0));
               --Acumulador de TR Pessoa fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;

            END IF;

          --> Prefixado
          ELSIF rw_crapepr.tpemprst = 1 THEN

            vr_rel1731_1_pre   := vr_rel1731_1_pre   + vr_vlpreatr;
            vr_rel1731_1_v_pre := vr_rel1731_1_v_pre + vr_vldivida;

            IF vr_vlag1731_1_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1731_1_pre(rw_crapris.cdagenci).valor := vr_vlag1731_1_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1731_1_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            --Microcrédito
            IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
               vr_arrchave1 := vr_price_pre||vr_price_pf;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,40,' ')||LPAD(rw_crapris.cdagenci,3,0));
               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;

            END IF;

          --> Pos fixado
          ELSIF rw_crapepr.tpemprst = 2 THEN

            vr_vldespes_pf_pos   := vr_vldespes_pf_pos   + vr_vlpreatr;
            vr_vldevedo_pf_v_pos := vr_vldevedo_pf_v_pos + vr_vldivida;

            IF vr_vlag1731_1_pos.exists(rw_crapris.cdagenci) THEN
              vr_vlag1731_1_pos(rw_crapris.cdagenci).valor := vr_vlag1731_1_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1731_1_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;
          END IF;

        ELSE  -- Pessoa Juridica

          --verifica se eh uma operacao do BNDES
          OPEN cr_crapebn(rw_crapris.cdcooper,
                          rw_crapris.nrdconta,
                          rw_crapris.nrctremp);

          FETCH cr_crapebn INTO rw_crapebn;

          -- Se nao for do BNDES e nao existir na crapepr, continua
          IF cr_crapebn%NOTFOUND THEN
            CLOSE cr_crapebn;

          -- Verifica o tipo do empréstimo
          IF rw_crapepr.tpemprst = 0 THEN

            vr_rel1731_2   := vr_rel1731_2   + vr_vlpreatr;
            vr_rel1731_2_v := vr_rel1731_2_v + vr_vldivida;

            IF vr_vlag1731_2.exists(rw_crapris.cdagenci) THEN
              vr_vlag1731_2(rw_crapris.cdagenci).valor := vr_vlag1731_2(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1731_2(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            --Microcrédito
            IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
               vr_arrchave1 := vr_price_atr||vr_price_pj;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,40,' ')||LPAD(rw_crapris.cdagenci,3,0));
               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;

            END IF;
            --> prefixado
          ELSIF rw_crapepr.tpemprst = 1 THEN -- tipo de emprestimo

            vr_rel1731_2_pre   := vr_rel1731_2_pre   + vr_vlpreatr;
            vr_rel1731_2_v_pre := vr_rel1731_2_v_pre + vr_vldivida;

            IF vr_vlag1731_2_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1731_2_pre(rw_crapris.cdagenci).valor := vr_vlag1731_2_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1731_2_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            --Microcrédito
            IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
               vr_arrchave1 := vr_price_pre||vr_price_pj;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,40,' ')||LPAD(rw_crapris.cdagenci,3,0));
               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,40,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;

            END IF;

            --> PosFixado
            ELSIF rw_crapepr.tpemprst = 2 THEN -- tipo de emprestimo

              vr_vldespes_pj_pos   := vr_vldespes_pj_pos   + vr_vlpreatr;
              vr_vldevedo_pj_v_pos := vr_vldevedo_pj_v_pos + vr_vldivida;

              IF vr_vlag1731_2_pos.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_2_pos(rw_crapris.cdagenci).valor := vr_vlag1731_2_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_2_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;
            END IF;

          ELSE -- Se for operacao do BNDES
            CLOSE cr_crapebn;
            -- totalizar em uma nova variável o valor do empréstimo em atraso(vr_vlpreatr).
            vr_vlempatr_bndes_2 := vr_vlempatr_bndes_2 + vr_vlpreatr;

            -- armazena também o valor em atraso por agência
            IF vr_vlatrage_bndes_2.exists(rw_crapris.cdagenci) THEN
              vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor := vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor := vr_vlpreatr;
        END IF;

          END IF; -- FIM - Validacao do BNDES
        END IF; -- FIM - Pessoa Juridica
      END IF;  -- FIM - FINANCIAMENTOS

      END IF; -- FIM - CESSAO
      -- DESCONTOS
      --      2 = Desconto de Cheques
      --      4 = Desconto de Titulos - cob. sem reg.
      --      5 = Desconto de Titulos - cob. reg
      IF rw_crapris.cdorigem IN (2,4,5) THEN -- Desconto de Titulos - cob. reg
        -- Se pessoa física
        IF rw_crapris.inpessoa = 1 THEN
          vr_rel1724.valorpf   := NVL(vr_rel1724.valorpf,0)   + vr_vlpreatr;
          vr_rel1724_v.valorpf := NVL(vr_rel1724_v.valorpf,0) + vr_vldivida;

          IF vr_vlag1724.exists(rw_crapris.cdagenci) THEN
            vr_vlag1724(rw_crapris.cdagenci).valorpf := NVL(vr_vlag1724(rw_crapris.cdagenci).valorpf,0) + vr_vlpreatr;
          ELSE
            vr_vlag1724(rw_crapris.cdagenci).valorpf := vr_vlpreatr;
          END IF;

        ELSE

          vr_rel1724.valorpj   := NVL(vr_rel1724.valorpj,0)   + vr_vlpreatr;
          vr_rel1724_v.valorpj := NVL(vr_rel1724_v.valorpj,0) + vr_vldivida;

          IF vr_vlag1724.exists(rw_crapris.cdagenci) THEN
            vr_vlag1724(rw_crapris.cdagenci).valorpj := NVL(vr_vlag1724(rw_crapris.cdagenci).valorpj,0) + vr_vlpreatr;
          ELSE
            vr_vlag1724(rw_crapris.cdagenci).valorpj := vr_vlpreatr;
          END IF;

        END IF;

      END IF;

      -- CONTA
      IF rw_crapris.cdorigem = 1 THEN
        -- Cheque especial
        IF rw_crapris.cdmodali = 0201 THEN
          -- Pessoa física
          IF rw_crapris.inpessoa = 1 THEN
            vr_rel1722_0201.valorpf   := vr_rel1722_0201.valorpf   + vr_vlpreatr;
            vr_rel1722_0201_v.valorpf := vr_rel1722_0201_v.valorpf + vr_vldivida;

            IF vr_vlag0201_1722_v.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpf,0) + vr_vldivida;
            ELSE
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpf := vr_vldivida;
            END IF;

            IF vr_vlag0201.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0201(rw_crapris.cdagenci).valorpf,0) + vr_vlpreatr;
            ELSE
              vr_vlag0201(rw_crapris.cdagenci).valorpf := vr_vlpreatr;
            END IF;

          ELSE  -- Pessoa juridica
            vr_rel1722_0201.valorpj   := vr_rel1722_0201.valorpj   + vr_vlpreatr;
            vr_rel1722_0201_v.valorpj := vr_rel1722_0201_v.valorpj + vr_vldivida;

            IF vr_vlag0201_1722_v.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj,0) + vr_vldivida;
            ELSE
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj := vr_vldivida;
            END IF;

            IF vr_vlag0201.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0201(rw_crapris.cdagenci).valorpj,0) + vr_vlpreatr;
            ELSE
              vr_vlag0201(rw_crapris.cdagenci).valorpj := vr_vlpreatr;
            END IF;

          END IF;

          IF vr_vlag0201_1622.exists(rw_crapris.cdagenci) THEN
            vr_vlag0201_1622(rw_crapris.cdagenci).valor := vr_vlag0201_1622(rw_crapris.cdagenci).valor + vr_vldivida;
          ELSE
            vr_vlag0201_1622(rw_crapris.cdagenci).valor := vr_vldivida;
          END IF;

        ELSE  -- Ad. a Depositante

          IF vr_vldivida_sldblq <> 0 THEN  -- Se ha Saldo Bloqueado

            -- Enfim, geramos as informaçoes do Saldo Bloqueado
             --  calculadas mais acima
            IF rw_crapris.inpessoa = 1 THEN -- PF
              vr_rel1613_0299_v.valorpf := vr_rel1613_0299_v.valorpf + vr_vldivida_sldblq;

              IF vr_vlag0299_1613.exists(rw_crapris.cdagenci) THEN
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0299_1613(rw_crapris.cdagenci).valorpf,0) +
                                                                 vr_vldivida_sldblq;
              ELSE
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpf := vr_vldivida_sldblq;
              END IF;

            ELSE  -- PJ
              vr_rel1613_0299_v.valorpj := vr_rel1613_0299_v.valorpj + vr_vldivida_sldblq;

              IF vr_vlag0299_1613.exists(rw_crapris.cdagenci) THEN
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0299_1613(rw_crapris.cdagenci).valorpj,0) +
                                                                 vr_vldivida_sldblq;
              ELSE
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpj := vr_vldivida_sldblq;
              END IF;
            END IF;

          END IF;

          -- PROJ 186 - Divisao PF/PJ
          IF rw_crapris.inpessoa = 1 THEN -- PF

            -- Guardar os valores de Ad. a Depositante
            vr_rel1722_0101.valorpf   := NVL(vr_rel1722_0101.valorpf,0) + vr_vlpreatr;
            vr_rel1722_0101_v.valorpf := NVL(vr_rel1722_0101_v.valorpf,0) + vr_vldivida;


            IF vr_vlag0101.exists(rw_crapris.cdagenci) THEN
              vr_vlag0101(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0101(rw_crapris.cdagenci).valorpf,0) + vr_vlpreatr;
            ELSE
              vr_vlag0101(rw_crapris.cdagenci).valorpf := vr_vlpreatr;
            END IF;

            IF vr_vlag0101_1722_v.exists(rw_crapris.cdagenci) THEN
              vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpf,0) +
                                                                 vr_vldivida;
            ELSE
              vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpf := vr_vldivida;
            END IF;

          ELSE  -- PJ

            -- Guardar os valores de Ad. a Depositante
            vr_rel1722_0101.valorpj   := NVL(vr_rel1722_0101.valorpj,0) + vr_vlpreatr;
            vr_rel1722_0101_v.valorpj := NVL(vr_rel1722_0101_v.valorpj,0) + vr_vldivida;

            IF vr_vlag0101.exists(rw_crapris.cdagenci) THEN
              vr_vlag0101(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0101(rw_crapris.cdagenci).valorpj,0) + vr_vlpreatr;
            ELSE
              vr_vlag0101(rw_crapris.cdagenci).valorpj := vr_vlpreatr;
            END IF;

            IF vr_vlag0101_1722_v.exists(rw_crapris.cdagenci) THEN
              vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpj,0) +
                                                                 vr_vldivida;
            ELSE
              vr_vlag0101_1722_v(rw_crapris.cdagenci).valorpj := vr_vldivida;
            END IF;

          END IF;

          IF vr_vlag0101_1611.exists(rw_crapris.cdagenci) THEN
            vr_vlag0101_1611(rw_crapris.cdagenci).valor := vr_vlag0101_1611(rw_crapris.cdagenci).valor +
                                                           vr_vldivida;
          ELSE
            vr_vlag0101_1611(rw_crapris.cdagenci).valor := vr_vldivida;
          END IF;
        END IF;
      END IF;
    END LOOP; -- FIM LOOP crapris

    -- TOTALIZAR  LIMITE NAO UTILIZADO
    FOR rw_crapris_lnu IN cr_crapris_lnu(pr_cdcooper,
                                         vr_dtrefere) LOOP

      IF pr_cdcooper IN ( 1, 13 ,16, 09) THEN

        IF NOT fn_verifica_conta_migracao(rw_crapris_lnu.cdcooper,
                                          rw_crapris_lnu.nrdconta,
                                          rw_crapris_lnu.dtrefere) THEN
          CONTINUE;
        END IF;
      END IF;

      IF  rw_crapris_lnu.inpessoa = 1 THEN
        vr_vllmtepf := vr_vllmtepf + rw_crapris_lnu.vldivida;
      ELSE
        vr_vllmtepj := vr_vllmtepj + rw_crapris_lnu.vldivida;
      END IF;
    END LOOP;

    -- Leitura do crapris para reversao da receita de juros de emprestimo com
    -- mais de 60 dias de atraso (Guilherme)
    vr_vencto(230).dias := 90;
    vr_vencto(240).dias := 120;
    vr_vencto(245).dias := 150;
    vr_vencto(250).dias := 180;
    vr_vencto(255).dias := 240;
    vr_vencto(260).dias := 300;
    vr_vencto(270).dias := 360;
    vr_vencto(280).dias := 540;
    vr_vencto(290).dias := 540;

    vr_vldjuros.valorpf  := 0;
    vr_vldjuros.valorpj  := 0;
    vr_vldjuros2.valorpf := 0;
    vr_vldjuros2.valorpj := 0;
    vr_finjuros.valorpf  := 0;
    vr_finjuros.valorpj  := 0;
    vr_finjuros2.valorpf := 0;
    vr_finjuros2.valorpj := 0;
    vr_vldjuros6.valorpf := 0;
    vr_vldjuros6.valorpj := 0;
    vr_finjuros6.valorpf := 0;
    vr_finjuros6.valorpj := 0;

    vr_empjuros1.valorpj := 0;
    vr_empjuros1.valorpf := 0;
    vr_empjuros2.valorpj := 0;
    vr_empjuros2.valorpf := 0;
    vr_empjuros3.valorpj := 0;
    vr_empjuros3.valorpf := 0;

    vr_finjuros3.valorpj := 0;
    vr_finjuros3.valorpf := 0;
    vr_finjuros4.valorpj := 0;
    vr_finjuros4.valorpf := 0;
    vr_finjuros5.valorpj := 0;
    vr_finjuros5.valorpf := 0;

    vr_juros38.valorpf    :=0;
    vr_juros38.valorpj    :=0;
    vr_taxas37.valorpf    :=0;
    vr_taxas37.valorpj    :=0;
    vr_juros57.valorpf    :=0;
    vr_juros57.valorpj    :=0;
    vr_tarifa1441.valorpf :=0;
    vr_tarifa1441.valorpj :=0;
    vr_tarifa1465.valorpf :=0;
    vr_tarifa1465.valorpj :=0;


    pc_calcula_juros_60k (par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_cdmodali => 299
                          ,par_dtinicio => vr_dtinicio
                          ,pr_tabvljur1 => vr_pacvljur_1     --> TR - Modalidade 299 - Por PA.
                          ,pr_tabvljur2 => vr_pacvljur_2     --> TR - Modalidade 499 - Por PA.
                          ,pr_tabvljur3 => vr_pacvljur_3     --> PP - Modalidade 299 - Por PA.
                          ,pr_tabvljur4 => vr_pacvljur_4     --> PP - Modalidade 499 - Por PA.
                          ,pr_tabvljur5 => vr_pacvljur_5     --> PP – Cessao - Por PA.
                          ,pr_tabvljur6 => vr_pacvljur_6     --> POS - Modalidade 299 - Por PA.
                          ,pr_tabvljur7 => vr_pacvljur_7     --> POS - Modalidade 499 - Por PA.
                          ,pr_vlrjuros  => vr_vldjur_calc    --> TR - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros  => vr_finjur_calc    --> TR - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros2 => vr_vldjur_calc2   --> PP - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros2 => vr_finjur_calc2   --> PP - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros3 => vr_vldjur_calc3   --> PP – Cessao - Por Tipo pessoa.
                          ,pr_vlrjuros6 => vr_vldjur_calc6   --> POS - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros6 => vr_finjur_calc6  --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_empjuros1 => vr_empjur_calc1   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros2 => vr_empjur_calc2   --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros3 => vr_empjur_calc3   --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros3 => vr_finjur_calc3   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros4 => vr_finjur_calc4      --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros5 => vr_finjur_calc5      --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_juros38   => vr_juros38_calc      --> 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_taxas37   => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                          ,pr_juros57    => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                          ,pr_tarifa1441 => vr_tarifa1441_calc  --> 1441 -Tarifa adiantamento a depositantes
                          ,pr_tarifa1465 => vr_tarifa1465_calc        --> 1465 -Tarifa adiantamento a depositantes
                          ,pr_tabvlempjur1 => vr_tabvlempjur1    --> TR – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur2 => vr_tabvlempjur2    --> PP – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur3 => vr_tabvlempjur3    --> POS – Cessao Emprestimo - Por PA.
                          ,pr_tabvlfinjur1 => vr_tabvlfinjur1    --> TR – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur2 => vr_tabvlfinjur2    --> PP – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur3 => vr_tabvlfinjur3    --> POS – Cessao Financiamento - Por PA.
                          ,pr_tabvljuros38 => vr_tabvljuros38    --> 38 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvltaxas37 => vr_tabvltaxas37    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                          ,pr_tabvljuros57 => vr_tabvljuros57    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.
                          ,pr_tabvltarifa1441 =>vr_tabvltarifa1441-->1441 – Tarifa adiantamento a depositantes- Por PA.
                          ,pr_tabvltarifa1465 =>vr_tabvltarifa1465); --> 1465 – Tarifa adiantamento a depositantes - Por PA.
    -- Acumula retornos da pc_calcula_juros_60k
    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;
    -- Produto Pos Fixado
    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;

    --Cessao credito
    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

   --Conta Corrente
    vr_juros38.valorpj := vr_juros38.valorpj + vr_juros38_calc.valorpj;
    vr_juros38.valorpf := vr_juros38.valorpf + vr_juros38_calc.valorpf;
    vr_taxas37.valorpj := vr_taxas37.valorpj + vr_taxas37_calc.valorpj;
    vr_taxas37.valorpf := vr_taxas37.valorpf + vr_taxas37_calc.valorpf;
    vr_juros57.valorpj := vr_juros57.valorpj + vr_juros57_calc.valorpj;
    vr_juros57.valorpf := vr_juros57.valorpf + vr_juros57_calc.valorpf;
    vr_tarifa1441.valorpj := vr_tarifa1441.valorpj + vr_tarifa1441_calc.valorpj;
    vr_tarifa1441.valorpf := vr_tarifa1441.valorpf + vr_tarifa1441_calc.valorpf;
    vr_tarifa1465.valorpj := vr_tarifa1465.valorpj + vr_tarifa1465_calc.valorpj;
    vr_tarifa1465.valorpf := vr_tarifa1465.valorpf + vr_tarifa1465_calc.valorpf;

    pc_calcula_juros_60k (par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_cdmodali => 499
                          ,par_dtinicio => vr_dtinicio
                          ,pr_tabvljur1 => vr_pacvljur_1     --> TR - Modalidade 299 - Por PA.
                          ,pr_tabvljur2 => vr_pacvljur_2     --> TR - Modalidade 499 - Por PA.
                          ,pr_tabvljur3 => vr_pacvljur_3     --> PP - Modalidade 299 - Por PA.
                          ,pr_tabvljur4 => vr_pacvljur_4     --> PP - Modalidade 499 - Por PA.
                          ,pr_tabvljur5 => vr_pacvljur_5     --> PP – Cessao - Por PA.
                          ,pr_tabvljur6 => vr_pacvljur_6     --> POS - Modalidade 299 - Por PA.
                          ,pr_tabvljur7 => vr_pacvljur_7     --> POS - Modalidade 499 - Por PA.
                          ,pr_vlrjuros  => vr_vldjur_calc    --> TR - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros  => vr_finjur_calc    --> TR - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros2 => vr_vldjur_calc2   --> PP - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros2 => vr_finjur_calc2   --> PP - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros3 => vr_vldjur_calc3   --> PP – Cessao - Por Tipo pessoa.
                          ,pr_vlrjuros6 => vr_vldjur_calc6   --> POS - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros6 => vr_finjur_calc6  --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_empjuros1 => vr_empjur_calc1   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros2 => vr_empjur_calc2   --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros3 => vr_empjur_calc3   --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros3 => vr_finjur_calc3   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros4 => vr_finjur_calc4      --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros5 => vr_finjur_calc5      --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_juros38   => vr_juros38_calc      --> 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_taxas37   => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                          ,pr_juros57    => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                          ,pr_tarifa1441 => vr_tarifa1441_calc  --> 1441 -Tarifa adiantamento a depositantes
                          ,pr_tarifa1465 => vr_tarifa1465_calc        --> 1465 -Tarifa adiantamento a depositantes
                          ,pr_tabvlempjur1 => vr_tabvlempjur1    --> TR – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur2 => vr_tabvlempjur2    --> PP – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur3 => vr_tabvlempjur3    --> POS – Cessao Emprestimo - Por PA.
                          ,pr_tabvlfinjur1 => vr_tabvlfinjur1    --> TR – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur2 => vr_tabvlfinjur2    --> PP – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur3 => vr_tabvlfinjur3    --> POS – Cessao Financiamento - Por PA.
                          ,pr_tabvljuros38 => vr_tabvljuros38    --> 38 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvltaxas37 => vr_tabvltaxas37    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                          ,pr_tabvljuros57 => vr_tabvljuros57    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.
                          ,pr_tabvltarifa1441 =>vr_tabvltarifa1441-->1441 – Tarifa adiantamento a depositantes- Por PA.
                          ,pr_tabvltarifa1465 =>vr_tabvltarifa1465); --> 1465 – Tarifa adiantamento a depositantes - Por PA.

    -- Acumula retornos da pc_calcula_juros_60k
    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;
    -- Produto Pos Fixado
    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;

    --Cessao credito
    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

    --Conta Corrente
    vr_juros38.valorpj := vr_juros38.valorpj + vr_juros38_calc.valorpj;
    vr_juros38.valorpf := vr_juros38.valorpf + vr_juros38_calc.valorpf;
    vr_taxas37.valorpj := vr_taxas37.valorpj + vr_taxas37_calc.valorpj;
    vr_taxas37.valorpf := vr_taxas37.valorpf + vr_taxas37_calc.valorpf;
    vr_juros57.valorpj := vr_juros57.valorpj + vr_juros57_calc.valorpj;
    vr_juros57.valorpf := vr_juros57.valorpf + vr_juros57_calc.valorpf;
    vr_tarifa1441.valorpj := vr_tarifa1441.valorpj + vr_tarifa1441_calc.valorpj;
    vr_tarifa1441.valorpf := vr_tarifa1441.valorpf + vr_tarifa1441_calc.valorpf;
    vr_tarifa1465.valorpj := vr_tarifa1465.valorpj + vr_tarifa1465_calc.valorpj;
    vr_tarifa1465.valorpf := vr_tarifa1465.valorpf + vr_tarifa1465_calc.valorpf;


    pc_calcula_juros_60k (par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_cdmodali => 999              --> Conta Corrente
                          ,par_dtinicio => vr_dtinicio
                          ,pr_tabvljur1 => vr_pacvljur_1     --> TR - Modalidade 299 - Por PA.
                          ,pr_tabvljur2 => vr_pacvljur_2     --> TR - Modalidade 499 - Por PA.
                          ,pr_tabvljur3 => vr_pacvljur_3     --> PP - Modalidade 299 - Por PA.
                          ,pr_tabvljur4 => vr_pacvljur_4     --> PP - Modalidade 499 - Por PA.
                          ,pr_tabvljur5 => vr_pacvljur_5     --> PP – Cessao - Por PA.
                          ,pr_tabvljur6 => vr_pacvljur_6     --> POS - Modalidade 299 - Por PA.
                          ,pr_tabvljur7 => vr_pacvljur_7     --> POS - Modalidade 499 - Por PA.
                          ,pr_vlrjuros  => vr_vldjur_calc    --> TR - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros  => vr_finjur_calc    --> TR - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros2 => vr_vldjur_calc2   --> PP - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros2 => vr_finjur_calc2   --> PP - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros3 => vr_vldjur_calc3   --> PP – Cessao - Por Tipo pessoa.
                          ,pr_vlrjuros6 => vr_vldjur_calc6   --> POS - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros6 => vr_finjur_calc6  --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_empjuros1 => vr_empjur_calc1   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros2 => vr_empjur_calc2   --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_empjuros3 => vr_empjur_calc3   --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros3 => vr_finjur_calc3   --> TR – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros4 => vr_finjur_calc4      --> PP – Emprestimo pessoa fisica refinanciado
                          ,pr_finjuros5 => vr_finjur_calc5      --> POS – Emprestimo pessoa fisica refinanciado
                          ,pr_juros38   => vr_juros38_calc      --> 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_taxas37   => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                          ,pr_juros57    => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                          ,pr_tarifa1441 => vr_tarifa1441_calc  --> 1441 -Tarifa adiantamento a depositantes
                          ,pr_tarifa1465 => vr_tarifa1465_calc        --> 1465 -Tarifa adiantamento a depositantes
                          ,pr_tabvlempjur1 => vr_tabvlempjur1    --> TR – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur2 => vr_tabvlempjur2    --> PP – Cessao Emprestimo - Por PA.
                          ,pr_tabvlempjur3 => vr_tabvlempjur3    --> POS – Cessao Emprestimo - Por PA.
                          ,pr_tabvlfinjur1 => vr_tabvlfinjur1    --> TR – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur2 => vr_tabvlfinjur2    --> PP – Cessao Financiamento - Por PA.
                          ,pr_tabvlfinjur3 => vr_tabvlfinjur3    --> POS – Cessao Financiamento - Por PA.
                          ,pr_tabvljuros38 => vr_tabvljuros38    --> 38 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvltaxas37 => vr_tabvltaxas37    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                          ,pr_tabvljuros57 => vr_tabvljuros57    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.
                          ,pr_tabvltarifa1441 =>vr_tabvltarifa1441-->1441 – Tarifa adiantamento a depositantes- Por PA.
                          ,pr_tabvltarifa1465 =>vr_tabvltarifa1465); --> 1465 – Tarifa adiantamento a depositantes - Por PA.

    -- Acumula retornos da pc_calcula_juros_60k
    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;

    vr_finjuros3.valorpj := vr_finjuros3.valorpj + vr_finjur_calc3.valorpj;
    vr_finjuros3.valorpf := vr_finjuros3.valorpf + vr_finjur_calc3.valorpf;
    vr_finjuros4.valorpj := vr_finjuros4.valorpj + vr_finjur_calc4.valorpj;
    vr_finjuros4.valorpf := vr_finjuros4.valorpf + vr_finjur_calc4.valorpf;
    vr_finjuros5.valorpj := vr_finjuros5.valorpj + vr_finjur_calc5.valorpj;
    vr_finjuros5.valorpf := vr_finjuros5.valorpf + vr_finjur_calc5.valorpf;

    --Cessao credito
    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

  --Conta Corrente
    vr_juros38.valorpj := vr_juros38.valorpj + vr_juros38_calc.valorpj;
    vr_juros38.valorpf := vr_juros38.valorpf + vr_juros38_calc.valorpf;
    vr_taxas37.valorpj := vr_taxas37.valorpj + vr_taxas37_calc.valorpj;
    vr_taxas37.valorpf := vr_taxas37.valorpf + vr_taxas37_calc.valorpf;
    vr_juros57.valorpj := vr_juros57.valorpj + vr_juros57_calc.valorpj;
    vr_juros57.valorpf := vr_juros57.valorpf + vr_juros57_calc.valorpf;
    vr_tarifa1441.valorpj := vr_tarifa1441.valorpj + vr_tarifa1441_calc.valorpj;
    vr_tarifa1441.valorpf := vr_tarifa1441.valorpf + vr_tarifa1441_calc.valorpf;
    vr_tarifa1465.valorpj := vr_tarifa1465.valorpj + vr_tarifa1465_calc.valorpj;
    vr_tarifa1465.valorpf := vr_tarifa1465.valorpf + vr_tarifa1465_calc.valorpf;


    vr_contador := 1;
    WHILE vr_contador <= 16 LOOP

      IF vr_vldevedo.exists(vr_contador) THEN
        vr_vldespes(vr_contador) := vr_vldevedo(vr_contador);
      ELSE
        vr_vldespes(vr_contador) := 0;
        vr_vldevedo(vr_contador) := 0;
      END IF;

      vr_contador := vr_contador + 1;

    END LOOP;

    vr_vldevedo(17) := vr_rel1721_v;
    vr_vldespes(17) := vr_rel1721;
    vr_vldevedo(18) := vr_rel1723_v;
    vr_vldespes(18) := vr_rel1723;
    -- DIVISAO PF/PJ
    vr_vldevedo(19) := vr_rel1724_v.valorpf;
    vr_vldespes(19) := vr_rel1724.valorpf;
    vr_vldevepj(19) := vr_rel1724_v.valorpj;
    vr_vldesppj(19) := vr_rel1724.valorpj;
    --
    vr_vldevedo(20) := vr_rel1731_1_v;
    vr_vldespes(20) := vr_rel1731_1;
    vr_vldevedo(21) := vr_rel1731_2_v;
    vr_vldespes(21) := vr_rel1731_2;
    -- DIVISAO PF/PJ
    vr_vldevedo(22) := vr_rel1722_0201_v.valorpf;  -- usado no CRRL321
    vr_vldevepj(22) := vr_rel1722_0201_v.valorpj;  -- usado no CRRL321
    vr_vldespes(22) := vr_rel1722_0201.valorpf;
    vr_vldesppj(22) := vr_rel1722_0201.valorpj;
    vr_vldevedo(24) := vr_rel1722_0101_v.valorpf;
    vr_vldevepj(24) := vr_rel1722_0101_v.valorpj;
    vr_vldespes(24) := vr_rel1722_0101.valorpf;
    vr_vldesppj(24) := vr_rel1722_0101.valorpj;
    --

    -- DIVISAO PF/PJ
    vr_vldevedo(25) := vr_rel1722_0201_v.valorpf;  -- usado no CRRL321
    vr_vldevepj(25) := vr_rel1722_0201_v.valorpj;  -- usado no CRRL321
    vr_vldespes(25) := vr_rel1722_0201.valorpf;
    vr_vldesppj(25) := vr_rel1722_0201.valorpj;
    vr_vldevedo(27) := vr_rel1722_0101_v.valorpf;
    vr_vldevepj(27) := vr_rel1722_0101_v.valorpj;
    vr_vldespes(27) := vr_rel1722_0101.valorpf;
    vr_vldesppj(27) := vr_rel1722_0101.valorpj;
    --
    vr_vldevedo(28) := vr_rel1721_v_pre;
    vr_vldespes(28) := vr_rel1721_pre;
    vr_vldevedo(29) := vr_rel1723_v_pre;
    vr_vldespes(29) := vr_rel1723_pre;
    vr_vldevedo(30) := vr_rel1731_1_v_pre;
    vr_vldespes(30) := vr_rel1731_1_pre;
    vr_vldevedo(31) := vr_rel1731_2_v_pre;
    vr_vldespes(31) := vr_rel1731_2_pre;
    vr_vldespes(32) := vr_vlempatr_bndes_2;

    --Cessao
    vr_vldevedo(33) := vr_rel1760_v_pre;
    vr_vldespes(33) := vr_rel1760_pre;
    vr_vldevedo(34) := vr_rel1761_v_pre;
    vr_vldespes(34) := vr_rel1761_pre;

    --Pos Fixado
      --> EMPR
    vr_vldevedo(35) := vr_rel1721_v_pos; --PF
    vr_vldespes(35) := vr_rel1721_pos;   --PF
    vr_vldevedo(36) := vr_rel1723_v_pos; --PJ
    vr_vldespes(36) := vr_rel1723_pos;   --PJ
      --> FIN
    vr_vldevedo(37) := vr_vldevedo_pf_v_pos;
    vr_vldespes(37) := vr_vldespes_pf_pos;
    vr_vldevedo(38) := vr_vldevedo_pj_v_pos;
    vr_vldespes(38) := vr_vldespes_pj_pos;


    -- Buscar o próximo dia útil
    vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => (vr_dtrefere + 1) -- Próximo dia
                                              ,pr_tipo      => 'P' );            -- Próximo ou anterior

    -- Buscar o ultimo dia útil
    vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => vr_dtrefere -- último dia util
                                              ,pr_tipo      => 'A' );      -- Próximo ou anterior

    -- Definir as datas das linhas do arquivo
    vr_con_dtmvtolt := '70' ||
                       to_char(vr_dtmvtolt, 'yy') ||
                       to_char(vr_dtmvtolt, 'mm') ||
                       to_char(vr_dtmvtolt, 'dd');
    vr_con_dtmvtopr := '70' ||
                       to_char(vr_dtmvtopr, 'yy') ||
                       to_char(vr_dtmvtopr, 'mm') ||
                       to_char(vr_dtmvtopr, 'dd');


    -- Define o diretório do arquivo
    vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/contab') ;

    -- Define Nome do Arquivo
    vr_nmarquiv := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO.TMP';
    pr_retfile  := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO.txt';


    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);       --> Erro


    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_file_erro;
    END IF;

    -- Percorrer as agencias da cooperativa
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_nrmaxpas := rw_crapage.cdagenci;
      vr_cdccuage(rw_crapage.cdagenci).dsc := rw_crapage.cdccuage;
    END LOOP;

    -- Inicializa variáveis
    vr_ttlanmto        := 0;
    vr_ttlanmto_risco  := 0;
    vr_ttlanmto_divida := 0; -- Divida Conta Corrente

    -- Buscar as datas do sistema
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Se data de movimento não foi encontrada
    IF rw_crapdat.dtmvtolt IS NULL THEN
      vr_cdcritic := 1;
      -- Busca Critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Gera log no proc_batch
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper, pr_ind_tipo_log => 1 -- Erro sem tratamento
                                , pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                ' - ' || vr_cdprogra ||
                                                ' --> ' || vr_dscritic);
    ELSE
      -- Guarda a data
      vr_dtmovime := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                ,pr_dtmvtolt  => rw_crapdat.dtultdia
                                                ,pr_tipo      => 'A'
                                                ,pr_excultdia => TRUE);
    END IF;

    vr_con_dtmovime := '70' ||
                       to_char(vr_dtmovime, 'yy') ||
                       to_char(vr_dtmovime, 'mm') ||
                       to_char(vr_dtmovime, 'dd');

    /*************************
    Registro da reversao da receita de juros de
    empréstimos com mais 60 dias de atraso:

    No final do mes:
    D - 7116
    C - 1633
    Histórico:1434 - Ajuste de saldo de (risco) RECEITAS A APROPRIAR

    No início do mes seguinte:
    D - 1633
    C - 7116
    *************************/

    --EMPRESTIMO - RENDAS A APROPRIAR REFINANCIADO TR PF
    IF vr_empjuros1.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7010,5514,' ||
                      TRIM(to_char(vr_empjuros1.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Emprestimo TR Refinanciado PF"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur1.exists(vr_contador)
         AND vr_tabvlempjur1(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5514,7010,' ||
                     TRIM(to_char(vr_empjuros1.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Emprestimo TR Refinanciado PF"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --EMPRESTIMO - RENDAS A APROPRIAR  REFINANCIADO TR PJ
    IF vr_empjuros1.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7010,5514,' ||
                      TRIM(to_char(vr_empjuros1.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Emprestimo TR Refinanciado PJ"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur1.exists(vr_contador)
         AND vr_tabvlempjur1(vr_contador).valorpj <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5514,7010,' ||
                     TRIM(to_char(vr_empjuros1.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Emprestimo TR Refinanciado PJ"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur1.exists(vr_contador)
        AND vr_tabvlempjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --EMPRESTIMO - RENDAS A APROPRIAR REFINANCIADO PP PF
    IF vr_empjuros2.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,5518,' ||
                      TRIM(to_char(vr_empjuros2.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Emprestimo PP Refinanciado PF"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur2.exists(vr_contador)
         AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5518,7016,' ||
                     TRIM(to_char(vr_empjuros2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Emprestimo PP Refinanciado PF"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

   --EMPRESTIMO - RENDAS A APROPRIAR REFINANCIADO  PP PJ
    IF vr_empjuros2.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,5518,' ||
                      TRIM(to_char(vr_empjuros2.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Emprestimo PP Refinanciado PJ"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur2.exists(vr_contador)
         AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5518,7016,' ||
                     TRIM(to_char(vr_empjuros2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Emprestimo PP Refinanciado PJ "';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur2.exists(vr_contador)
        AND vr_tabvlempjur2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --EMPRESTIMO - RENDAS A APROPRIAR REFINANCIADO POS PF
    IF vr_empjuros3.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,5519,' ||
                      TRIM(to_char(vr_empjuros3.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar EMPRESTIMO POS REFINANCIADO PF"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur3.exists(vr_contador)
         AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5519,7017,' ||
                     TRIM(to_char(vr_empjuros3.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar EMPRESTIMO POS Refinanciado PF"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

   --EMPRESTIMO - RENDAS A APROPRIAR REFINANCIADO POS PJ
    IF vr_empjuros3.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,5519,' ||
                      TRIM(to_char(vr_empjuros3.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar EMPRESTIMO POS REFINANCIADO PJ "';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlempjur3.exists(vr_contador)
         AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5519,7017,' ||
                     TRIM(to_char(vr_empjuros3.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar EMPRESTIMO POS Refinanciado PJ "';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlempjur3.exists(vr_contador)
        AND vr_tabvlempjur3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur3(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --FINANCIAMENTO - RENDAS A APROPRIAR  REFINANCIADO TR PF
    IF vr_finjuros3.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7026,5522,' ||
                      TRIM(to_char(vr_finjuros3.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Financiamento TR Refinanciado PF"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur1.exists(vr_contador)
         AND vr_tabvlfinjur1(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5522,7026,' ||
                     TRIM(to_char(vr_finjuros3.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento TR Refinanciado PF"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;


    --FINANCIAMENTO - RENDAS A APROPRIAR REFINANCIADO TR PJ
    IF vr_finjuros3.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7010,5514,' ||
                      TRIM(to_char(vr_finjuros3.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Reversao rendas a apropriar Financiamento TR Refinanciado PJ"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur1.exists(vr_contador)
         AND vr_tabvlfinjur1(vr_contador).valorpj <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5514,7010,' ||
                     TRIM(to_char(vr_finjuros3.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento TR Refinanciado PJ"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur1.exists(vr_contador)
        AND vr_tabvlfinjur1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlempjur1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;


    --FINANCIAMENTO - RENDAS A APROPRIAR REFINANCIADO PP PF
    IF vr_finjuros4.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,5518,' ||
                      TRIM(to_char(vr_finjuros4.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Financiamento PP Refinanciado PF"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur2.exists(vr_contador)
         AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5518,7016,' ||
                     TRIM(to_char(vr_finjuros4.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento PP Refinanciado PF"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;


   --FINANCIAMENTO - RENDAS A APROPRIAR  REFINANCIADO PP PJ
    IF vr_finjuros4.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,5518,' ||
                      TRIM(to_char(vr_finjuros4.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Financiamento PP Refinanciado PJ"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur2.exists(vr_contador)
         AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5518,7016,' ||
                     TRIM(to_char(vr_finjuros4.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento PP Refinanciado PJ"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur2.exists(vr_contador)
        AND vr_tabvlfinjur2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;


    --FINANCIAMENTO - RENDAS A APROPRIAR REFINANCIADO POS PF
    IF vr_finjuros5.valorpf <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,5519,' ||
                      TRIM(to_char(vr_finjuros5.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Financiamento POS Refinanciado PF "';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur3.exists(vr_contador)
         AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpf, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5519,7017,' ||
                     TRIM(to_char(vr_finjuros5.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento POS Refinanciado PF "';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --FINANCIAMENTO - RENDAS A APROPRIAR REFINANCIADO POS PJ
    IF vr_finjuros5.valorpj <> 0 THEN

      -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,5519,' ||
                      TRIM(to_char(vr_finjuros5.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar Financiamento POS Refinanciado PJ"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpj <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
        END LOOP;


        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
         IF  vr_tabvlfinjur3.exists(vr_contador)
         AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
           vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpj, '99999999999990.00'));
           -- Gravar Linha
           pc_gravar_linha(vr_linhadet);
         END IF;
       END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5519,7017,' ||
                     TRIM(to_char(vr_finjuros5.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversao rendas a apropriar Financiamento POS Refinanciado PJ "';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_tabvlfinjur3.exists(vr_contador)
        AND vr_tabvlfinjur3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvlfinjur3(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA FISICA
    IF vr_juros38.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7014,5510,' ||
                      TRIM(to_char(vr_juros38.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_tabvljuros38.exists(vr_contador)
          AND vr_tabvljuros38(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_tabvljuros38(vr_contador).valorpf,'99999999999990.00'));
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
          END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_tabvljuros38.exists(vr_contador)
          AND vr_tabvljuros38(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_tabvljuros38(vr_contador).valorpf,'99999999999990.00'));
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
          END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5510,7014,' ||
                       TRIM(to_char(vr_juros38.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA
    IF vr_juros38.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7015,5511,' ||
                      TRIM(to_char(vr_juros38.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;


        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5511,7015,' ||
                       TRIM(to_char(vr_juros38.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';
         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38.exists(vr_contador)
           AND vr_tabvljuros38(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --0037 -TAXA SOBRE SALDO EM C/C NEGATIVO PESSOA FISICA
    IF vr_taxas37.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7012,5510,' ||
                      TRIM(to_char(vr_taxas37.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5510,7012,' ||
                       TRIM(to_char(vr_taxas37.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa fisica"';

         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --0037 -TAXA SOBRE SALDO EM C/C NEGATIVO PESSOA JURIDICA
    IF vr_taxas37.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7013,5511,' ||
                      TRIM(to_char(vr_taxas37.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;


        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5511,7013,' ||
                       TRIM(to_char(vr_taxas37.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa juridica"';


         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;
   END IF;


    --0057 -JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO   PESSOA FISICA
    IF vr_juros57.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7012,5510,' ||
                      TRIM(to_char(vr_juros57.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5510,7012,' ||
                       TRIM(to_char(vr_juros57.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa fisica"';

        -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;


   END IF;

    --0057 -JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO   PESSOA JURIDICA
    IF vr_juros57.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7013,5511,' ||
                      TRIM(to_char(vr_juros57.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5511,7013,' ||
                       TRIM(to_char(vr_juros57.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa juridica"';

         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --1441 - TARIFA ADIANTAMENTO A DEPOSITANTES  PESSOA FISICA
    IF vr_tarifa1441.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7242,5510,' ||
                      TRIM(to_char(vr_tarifa1441.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 1441 Tarifa adiantamento a depositantes - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1441.exists(vr_contador)
           AND vr_tabvltarifa1441(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1441(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1441.exists(vr_contador)
           AND vr_tabvltarifa1441(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1441(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5510,7242,' ||
                       TRIM(to_char(vr_tarifa1441.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 1441 Tarifa adiantamento a depositantes - pessoa fisica"';

        -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1441.exists(vr_contador)
           AND vr_tabvltarifa1441(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1441(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1441.exists(vr_contador)
           AND vr_tabvltarifa1441(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1441(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --1465 - TARIFA ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA
    IF vr_tarifa1465.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7453,5511,' ||
                      TRIM(to_char(vr_tarifa1465.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 1465 Tarifa adiantamento a depositantes - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1465.exists(vr_contador)
           AND vr_tabvltarifa1465(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1465(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1465.exists(vr_contador)
           AND vr_tabvltarifa1465(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1465(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;


        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5511,7453,' ||
                       TRIM(to_char(vr_tarifa1465.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 1465 Tarifa adiantamento a depositantes - pessoa juridica"';

        -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

       FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1465.exists(vr_contador)
           AND vr_tabvltarifa1465(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1465(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltarifa1465.exists(vr_contador)
           AND vr_tabvltarifa1465(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltarifa1465(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
        END LOOP;

   END IF;


    -- EMPRESTIMOS EM ATRASO PESSOA FISICA
    IF vr_vldjuros.valorpf <> 0 THEN
      -- Monta a linha de cabeçalho
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7010,5530,' ||
                     TRIM(to_char(vr_vldjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5530,7010,' ||
                     TRIM(to_char(vr_vldjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PESSOA JURIDICA
    IF vr_vldjuros.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7011,5531,' ||
                     TRIM(to_char(vr_vldjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5531,7011,' ||
                     TRIM(to_char(vr_vldjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    -- FINAN CIAMENTOS EM ATRASO - PESSOA FISICA
    IF vr_finjuros.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7026,5560,' ||
                     TRIM(to_char(vr_finjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5560,7026,' ||
                     TRIM(to_char(vr_finjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO - PESSOA JURIDICA
    IF vr_finjuros.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7027,5561,' ||
                     TRIM(to_char(vr_finjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5561,7027,' ||
                     TRIM(to_char(vr_finjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj,'99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA FISICA
    IF vr_vldjuros2.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,5534,' ||
                     TRIM(to_char(vr_vldjuros2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5534,7016,' ||
                     TRIM(to_char(vr_vldjuros2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA JURIDICA
    IF vr_vldjuros2.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,5535,' ||
                     TRIM(to_char(vr_vldjuros2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5535,7017,' ||
                     TRIM(to_char(vr_vldjuros2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_3.exists(vr_contador)
        AND vr_pacvljur_3(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_3(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA FISICA
    IF vr_finjuros2.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7028,5576,' ||
                     TRIM(to_char(vr_finjuros2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5576,7028,' ||
                     TRIM(to_char(vr_finjuros2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA
    IF vr_finjuros2.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7029,5577,' ||
                     TRIM(to_char(vr_finjuros2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5577,7029,' ||
                     TRIM(to_char(vr_finjuros2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_4.exists(vr_contador)
        AND vr_pacvljur_4(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_4(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- CESSAO EMPRESTIMO EM ATRASO - PESSOA FISICA
    IF vr_vldjuros3.valorpf <> 0 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5534,1756,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                       ',5210,' ||
                     '"(Cessao) RENDAS A APROPRIAR CESSÃO CARTAO PESSOA FISICA."';
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
              -- Gravar Linha
              pc_gravar_linha(vr_linhadet);
            END IF;
          END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
      END IF;
      END LOOP;

      -- Reversão
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1756,5534,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                       ',5210,' ||
                     '"(Cessao) REVERSAO RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
              -- Gravar Linha
              pc_gravar_linha(vr_linhadet);
            END IF;
          END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
      END IF;
    END LOOP;

    END IF;

    -- CESSAO EMPRESTIMO EM ATRASO - PESSOA JURIDICA
    IF vr_vldjuros3.valorpj <> 0 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5535,1757,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                       ',5210,' ||
                     '"(Cessao) RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
              -- Gravar Linha
              pc_gravar_linha(vr_linhadet);
            END IF;
          END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
      END IF;
      END LOOP;

      -- Reversão
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1757,5535,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                       ',5210,' ||
                     '"(Cessao) REVERSAO RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
              -- Gravar Linha
              pc_gravar_linha(vr_linhadet);
            END IF;
          END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
      END IF;
    END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA FISICA
    IF vr_vldjuros6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7591,5335,' ||
                     TRIM(to_char(vr_vldjuros6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5335,7591,' ||
                     TRIM(to_char(vr_vldjuros6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA JURIDICA
    IF vr_vldjuros6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7592,5336,' ||
                     TRIM(to_char(vr_vldjuros6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5336,7592,' ||
                     TRIM(to_char(vr_vldjuros6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_6.exists(vr_contador)
        AND vr_pacvljur_6(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_6(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA FISICA
    IF vr_finjuros6.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7561,5339,' ||
                     TRIM(to_char(vr_finjuros6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5339,7561,' ||
                     TRIM(to_char(vr_finjuros6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA
    IF vr_finjuros6.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7562,5340,' ||
                     TRIM(to_char(vr_finjuros6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5340,7562,' ||
                     TRIM(to_char(vr_finjuros6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_7.exists(vr_contador)
        AND vr_pacvljur_7(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_7(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    -- AJUSTE CESSAO EMPRESTIMO EM ATRASO - PESSOA FISICA
    IF vr_vldjuros3.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7537,7016,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',7016,7537,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- AJUSTE CESSAO EMPRESTIMO EM ATRASO - PESSOA JURIDICA
    IF vr_vldjuros3.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7538,7017,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',7017,7538,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
    END IF;
      END LOOP;

    END IF;
    --> FIM CESSAO


    -- TOTAL CHEQUE ESPECIAL UTILIZADO - PESSOA FISICA
    IF vr_rel1722_0201_v.valorpf <> 0 THEN

      vr_ttlanmto_divida := vr_ttlanmto_divida + vr_rel1722_0201_v.valorpf ;

      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',1631,4451,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',5528,4112,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA FISICA"';
      END IF;

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- Imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      -- REVERSÃO
      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4451,1631,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4112,5528,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA FISICA"';

      END IF;
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;

    -- TOTAL CHEQUE ESPECIAL UTILIZADO - PESSOA JURIDICA
    IF vr_rel1722_0201_v.valorpj <> 0 THEN

      vr_ttlanmto_divida := vr_ttlanmto_divida + vr_rel1722_0201_v.valorpj ;

      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',1631,4451,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',5529,4112,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA"';
      END IF;

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- Imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      -- REVERSÃO
      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4451,1631,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4112,5529,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA"';

      END IF;
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;




    -- Cheque Especial Utilizado (Provisao ) - Mod.0201
    -- PESSOA FISICA - PF
    IF vr_vldespes(22) <> 0 THEN

      vr_vllanmto := vr_vldespes(22);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',8442,1722,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',8447,5588,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) PROVISAO SALDO CHEQUE ESPECIAL UTILIZADO PESSOA FISICA"';

      END IF;
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- REVERSÃO
      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) ||
                       ',1722,8442,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) ||
                       ',5588,8447,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) PROVISAO SALDO CHEQUE ESPECIAL UTILIZADO PESSOA FISICA"';
      END IF;

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpf,'99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpf,'99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;
    -- Cheque Especial Utilizado (Provisao ) - Mod.0201
    -- PESSOA JURIDICA - PJ
    IF vr_vldesppj(22) <> 0 THEN

      vr_vllanmto := vr_vldesppj(22);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',8442,1722,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',8448,5589,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) PROVISAO SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA"';

      END IF;
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- REVERSÃO
      IF pr_cdcooper = 3 THEN

        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) ||
                       ',1722,8442,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) ||
                       ',5589,8448,' ||
                       TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) PROVISAO SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA"';
      END IF;

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpj,'99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201.exists(vr_contador) THEN

          IF vr_vlag0201(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201(vr_contador).valorpj,'99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;




    -- Total Saque sobre Bloqueio - SAQUE SOBRE DEPOSITO BLOQUEADO
    -- PESSOA FISICA - PF
    IF vr_rel1613_0299_v.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5502,5500,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,5502,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1613_0299_v.valorpf, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;

    -- Total Saque sobre Bloqueio - SAQUE SOBRE DEPOSITO BLOQUEADO
    -- PESSOA JURIDICA - PJ
    IF vr_rel1613_0299_v.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5503,5501,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,5503,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1613_0299_v.valorpj, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0299_1613.exists(vr_contador) THEN

          IF vr_vlag0299_1613(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0299_1613(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;




    -- Adiantamento a Depositantes (Mod.0101)
    -- ADIANTAMENTO A DEPOSITANTES PESSOA FISICA / PF
    IF vr_rel1722_0101_v.valorpf <> 0 THEN

      vr_ttlanmto_divida := vr_ttlanmto_divida + vr_rel1722_0101_v.valorpf;

      IF pr_cdcooper = 3 THEN
        vr_contacon := 4451;
      ELSE
        vr_contacon := 4112;
      END IF;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5500,' ||
                     vr_contacon || ',' ||
                     TRIM(to_char(vr_rel1722_0101_v.valorpf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0101_1722_v.exists(vr_contador) THEN

          IF vr_vlag0101_1722_v(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0101_1722_v(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpf, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                     vr_contacon || ',5500,' ||
                     TRIM(to_char((vr_rel1722_0101_v.valorpf - vr_rel1613_0299_v.valorpf), '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpf - vr_rel1613_0299_v.valorpf, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101_1722_v.exists(vr_contador)
        AND vr_vlag0101_1722_v(vr_contador).valorpf <> 0 THEN

          IF vr_vlag0299_1613.exists(vr_contador) THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                            TRIM(to_char((vr_vlag0101_1722_v(vr_contador).valorpf -
                                          vr_vlag0299_1613(vr_contador).valorpf), '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          ELSE
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0101_1722_v(vr_contador).valorpf, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;

    -- ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA / PJ
    IF vr_rel1722_0101_v.valorpj <> 0 THEN

      vr_ttlanmto_divida := vr_ttlanmto_divida + vr_rel1722_0101_v.valorpj;

      IF pr_cdcooper = 3 THEN
        vr_contacon := 4451;
      ELSE
        vr_contacon := 4112;
      END IF;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5501,' ||
                     vr_contacon || ',' ||
                     TRIM(to_char(vr_rel1722_0101_v.valorpj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0101_1722_v.exists(vr_contador) THEN

          IF vr_vlag0101_1722_v(vr_contador).valorpj <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0101_1722_v(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpj, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                     vr_contacon || ',5501,' ||
                     TRIM(to_char((vr_rel1722_0101_v.valorpj - vr_rel1613_0299_v.valorpj), '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      -- imprimir imprime_gerencialcontab
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpj - vr_rel1613_0299_v.valorpj, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101_1722_v.exists(vr_contador)
        AND vr_vlag0101_1722_v(vr_contador).valorpj <> 0 THEN

          IF vr_vlag0299_1613.exists(vr_contador) THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                            TRIM(to_char((vr_vlag0101_1722_v(vr_contador).valorpj -
                                          vr_vlag0299_1613(vr_contador).valorpj), '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          ELSE
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0101_1722_v(vr_contador).valorpj, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

    END IF;




    -- Adiantamento a Depositantes(Provisao)  - Mod.0101
    -- ADIANTAMENTO A DEPOSITANTES - PESSOA FISICA - PF
    IF vr_vldespes(24) <> 0 THEN

      vr_vllanmto := vr_vldespes(24);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      -- PROJ 186 - Divisao PF/PJ
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5588,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO ADIANTAMENTO A DEPOSITANTES PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);


      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpf, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpf, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;

      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5588,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO ADIANTAMENTO A DEPOSITANTES PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpf, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpf, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- Adiantamento a Depositantes(Provisao)  - Mod.0101
    -- ADIANTAMENTO A DEPOSITANTES - PESSOA JURIDICA - PJ
    IF vr_vldesppj(24) <> 0 THEN

      vr_vllanmto := vr_vldesppj(24);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      -- PROJ 186 - Divisao PF/PJ
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5589,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);


      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpj, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpj, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;

      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5589,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpj, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag0101.exists(vr_contador)
        AND vr_vlag0101(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag0101(vr_contador).valorpj, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;



    -- AJUSTE PROVISAO FIN.PESSOAIS
    IF vr_vldespes(20) <> 0 THEN

      vr_vllanmto := vr_vldespes(20);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5594,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO FIN.PESSOAIS"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1.exists(vr_contador)
        AND vr_vlag1731_1(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1.exists(vr_contador)
        AND vr_vlag1731_1(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                      TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5594,8447,' ||
                      TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                      ',1434,' || '"(risco) PROVISAO FIN.PESSOAIS"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1.exists(vr_contador)
        AND vr_vlag1731_1(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1.exists(vr_contador)
        AND vr_vlag1731_1(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;



    -- AJUSTE PROVISAO FIN.EMPRESAS
    IF vr_vldespes(21) <> 0 THEN

      vr_vllanmto := vr_vldespes(21);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5595,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO FIN.EMPRESAS "';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2.exists(vr_contador)
        AND vr_vlag1731_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2.exists(vr_contador)
        AND vr_vlag1731_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5595,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO FIN.EMPRESAS"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2.exists(vr_contador)
        AND vr_vlag1731_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2.exists(vr_contador)
        AND vr_vlag1731_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,    '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Empresas e Entidades
    -- AJUSTE PROVISAO EMPR.EMPRESAS
    IF vr_vldespes(18) <> 0 THEN

      vr_vllanmto := vr_vldespes(18);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1723,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPR.EMPRESAS "';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723.exists(vr_contador)
        AND vr_vlag1723(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723.exists(vr_contador)
        AND vr_vlag1723(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1723,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPR.EMPRESAS "';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723.exists(vr_contador)
        AND vr_vlag1723(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723.exists(vr_contador)
        AND vr_vlag1723(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Emprestimos Pessoais
    -- AJUSTE PROVISAO EMPR.PESSOAIS
    IF vr_vldespes(17) <> 0 THEN

      vr_vllanmto := vr_vldespes(17);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1721,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPR.PESSOAIS"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721.exists(vr_contador)
        AND vr_vlag1721(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721.exists(vr_contador)
        AND vr_vlag1721(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1721,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPR.PESSOAIS"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721.exists(vr_contador)
        AND vr_vlag1721(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721.exists(vr_contador)
        AND vr_vlag1721(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721(vr_contador).valor,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    -- AJUSTE PROVISAO FIN.PESSOAIS PREFIXADO
    IF vr_vldespes(30) <> 0 THEN

      vr_vllanmto := vr_vldespes(30);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5596,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pre.exists(vr_contador)
        AND vr_vlag1731_1_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pre.exists(vr_contador)
        AND vr_vlag1731_1_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5596,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pre.exists(vr_contador)
        AND vr_vlag1731_1_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pre.exists(vr_contador)
        AND vr_vlag1731_1_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- AJUSTE PROVISAO FIN.EMPRESAS PREFIXADO
    IF vr_vldespes(31) <> 0 THEN

      vr_vllanmto := vr_vldespes(31);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5597,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS PREFIXADO "';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pre.exists(vr_contador)
        AND vr_vlag1731_2_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pre.exists(vr_contador)
        AND vr_vlag1731_2_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5597,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pre.exists(vr_contador)
        AND vr_vlag1731_2_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pre.exists(vr_contador)
        AND vr_vlag1731_2_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Empresas e Entidades prefixado
    -- AJUSTE PROVISAO EMPR.EMPRESAS PREFIXADO
    IF vr_vldespes(29) <> 0 THEN

      vr_vllanmto := vr_vldespes(29);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5587,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.EMPRESAS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pre.exists(vr_contador)
        AND vr_vlag1723_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pre.exists(vr_contador)
        AND vr_vlag1723_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5587,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.EMPRESAS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pre.exists(vr_contador)
        AND vr_vlag1723_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pre.exists(vr_contador)
        AND vr_vlag1723_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Emprestimos Pessoais prefixado
    -- AJUSTE PROVISAO EMPR.PESSOAIS PREFIXADO
    IF vr_vldespes(28) <> 0 THEN

      vr_vllanmto := vr_vldespes(28);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5586,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.PESSOAIS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pre.exists(vr_contador)
        AND vr_vlag1721_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pre.exists(vr_contador)
        AND vr_vlag1721_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5586,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.PESSOAIS PREFIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag1721_pre.exists(vr_contador)
        AND vr_vlag1721_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pre.exists(vr_contador)
        AND vr_vlag1721_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    --->>>>> POS FIXADO <<<<<---

    -- AJUSTE PROVISAO FIN.PESSOAIS POS FIXADO
    IF vr_vldespes(37) <> 0 THEN

      vr_vllanmto := vr_vldespes(37);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5329,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pos.exists(vr_contador)
        AND vr_vlag1731_1_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pos.exists(vr_contador)
        AND vr_vlag1731_1_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5329,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pos.exists(vr_contador)
        AND vr_vlag1731_1_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_1_pos.exists(vr_contador)
        AND vr_vlag1731_1_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_1_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- AJUSTE PROVISAO FIN.EMPRESAS POS FIXADO
    IF vr_vldespes(38) <> 0 THEN

      vr_vllanmto := vr_vldespes(38);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5330,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS POS FIXADO "';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pos.exists(vr_contador)
        AND vr_vlag1731_2_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pos.exists(vr_contador)
        AND vr_vlag1731_2_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;


      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5330,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pos.exists(vr_contador)
        AND vr_vlag1731_2_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1731_2_pos.exists(vr_contador)
        AND vr_vlag1731_2_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1731_2_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Empresas e Entidades prefixado
    -- AJUSTE PROVISAO EMPR.EMPRESAS POS FIXADO
    IF vr_vldespes(36) <> 0 THEN

      vr_vllanmto := vr_vldespes(36);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5332,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.EMPRESAS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pos.exists(vr_contador)
        AND vr_vlag1723_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pos.exists(vr_contador)
        AND vr_vlag1723_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5332,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.EMPRESAS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pos.exists(vr_contador)
        AND vr_vlag1723_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_pos.exists(vr_contador)
        AND vr_vlag1723_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao CL - Emprestimos Pessoais prefixado
    -- AJUSTE PROVISAO EMPR.PESSOAIS POS FIXADO
    IF vr_vldespes(35) <> 0 THEN

      vr_vllanmto := vr_vldespes(35);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5331,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.PESSOAIS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pos.exists(vr_contador)
        AND vr_vlag1721_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pos.exists(vr_contador)
        AND vr_vlag1721_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5331,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO EMPR.PESSOAIS POS FIXADO"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag1721_pos.exists(vr_contador)
        AND vr_vlag1721_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_pos.exists(vr_contador)
        AND vr_vlag1721_pos(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_pos(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    --->>>>>> FIM POS FIXADO <<<<<---

    -- PROVISAO DE CESSAO CARTAO - PESSOA FISICA
    IF vr_vldespes(33) <> 0 THEN

      vr_vllanmto := vr_vldespes(33);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5586,1760,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) PROVISAO DE CESSAO CARTAO PESSOA FISICA."';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1760_pre.exists(vr_contador)
        AND vr_vlag1760_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1760_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1760_pre.exists(vr_contador)
        AND vr_vlag1760_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1760_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1760,5586,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO PROVISAO DE CESSAO CARTAO PESSOA FISICA."';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag1760_pre.exists(vr_contador)
        AND vr_vlag1760_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1760_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1760_pre.exists(vr_contador)
        AND vr_vlag1760_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1760_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- PROVISAO DE CESSAO CARTAO - PESSOA JURIDICA
    IF vr_vldespes(34) <> 0 THEN

      vr_vllanmto := vr_vldespes(34);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',5587,1761,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) PROVISAO DE CESSAO CARTAO PESSOA JURIDICA."';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1761_pre.exists(vr_contador)
        AND vr_vlag1761_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1761_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1761_pre.exists(vr_contador)
        AND vr_vlag1761_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1761_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1761,5587,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO PROVISAO DE CESSAO CARTAO PESSOA JURIDICA."';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag1761_pre.exists(vr_contador)
        AND vr_vlag1761_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1761_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1761_pre.exists(vr_contador)
        AND vr_vlag1761_pre(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlag1761_pre(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    -- Ajuste Provisao - Provisão de operações do BNDES.
    -- AJUSTE PROVISAO FINAME PESSOA JURIDICA
    IF vr_vldespes(32) <> 0 THEN

      vr_vllanmto := vr_vldespes(32);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5599,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FINAME PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_bndes_2.exists(vr_contador)
        AND vr_vlatrage_bndes_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_bndes_2(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_bndes_2.exists(vr_contador)
        AND vr_vlatrage_bndes_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_bndes_2(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5599,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FINAME PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_bndes_2.exists(vr_contador)
        AND vr_vlatrage_bndes_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_bndes_2(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_bndes_2.exists(vr_contador)
        AND vr_vlatrage_bndes_2(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_bndes_2(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
    END IF;
      END LOOP;

    END IF;

    -- Ajuste Provisao CL - Titulos Descontados
    -- AJUSTE PROVISAO TIT.DESCONTADOS - PESSOA FISICA / PF
    IF vr_vldespes(19) <> 0 THEN

      vr_vllanmto := vr_vldespes(19);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5592,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO TIT.DESCONTADOS PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5592,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO TIT.DESCONTADOS PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;
    -- Ajuste Provisao CL - Titulos Descontados
    -- AJUSTE PROVISAO TIT.DESCONTADOS - PESSOA JURIDICA / PJ
    IF vr_vldesppj(19) <> 0 THEN

      vr_vllanmto := vr_vldesppj(19);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,5593,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO TIT.DESCONTADOS PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5593,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO TIT.DESCONTADOS PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724.exists(vr_contador)
        AND vr_vlag1724(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

  -- MICROCREDITO --

  --Pessoa Fisica TR
  IF vr_tab_microcredito.EXISTS(vr_price_atr||vr_price_pf) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pf).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := '1';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,40)) THEN
                vr_arrchave2 := substr(vr_contador1,0,40);
                vr_relmicro_atr_pf := vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||'999').valor;
               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pf > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pf, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

               --REVERSAO
               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pf > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                   TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_CRE)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pf, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

            END IF;
            vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pf).next(vr_contador1);
         END LOOP;

     END IF;
  END IF;

  --Pessoa Fisica PRE
  IF vr_tab_microcredito.EXISTS(vr_price_pre||vr_price_pf) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pf).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := 'PF';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,40)) THEN
                vr_arrchave2 := substr(vr_contador1,0,40);
                vr_relmicro_pre_pf := vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||'999').valor;
               -- Monta a linha de cabeçalho
               IF vr_relmicro_pre_pf > 0 THEN
                  vr_flgmicro := FALSE;
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_pre_pf, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

               --REVERSAO
               -- Monta a linha de cabeçalho
               IF vr_relmicro_pre_pf > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                   TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_CRE)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_pre_pf, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

            END IF;
            vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pf).next(vr_contador1);
         END LOOP;

     END IF;
   END IF;

   --Pessoa Juridica TR
   IF vr_tab_microcredito.EXISTS(vr_price_atr||vr_price_pj) THEN
     vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pj).first;
     IF vr_contador1 <> ' ' THEN
        vr_arrchave2 := '1';
        WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,40)) THEN
                vr_arrchave2 := substr(vr_contador1,0,40);
                vr_relmicro_atr_pj := vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||'999').valor;
               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pj > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pj, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

               --REVERSAO
               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pj > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                   TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_CRE)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pj, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

            END IF;
            vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pj).next(vr_contador1);
         END LOOP;

     END IF;
  END IF;

  --Pessoa Juridica PRE
  IF vr_tab_microcredito.EXISTS(vr_price_pre||vr_price_pj) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pj).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := 'PF';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,40)) THEN
                vr_arrchave2 := substr(vr_contador1,0,40);
                vr_relmicro_pre_pj := vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||'999').valor;
               -- Monta a linha de cabeçalho
               IF vr_relmicro_pre_pj > 0 THEN
                  vr_flgmicro := FALSE;
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_pre_pj, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

               --REVERSAO
               -- Monta a linha de cabeçalho
               IF vr_relmicro_pre_pj > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                   TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_CRE)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_pre_pj, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';
                   -- Gravar Linha
                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      -- Gravar Linha
                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;

            END IF;
            vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pj).next(vr_contador1);
         END LOOP;

     END IF;
   END IF;
   --FIM MICROCRÉDITO

    vr_nrdcctab(1) := '3311.9302';  -- Contas para Contabilizacao Provisao
    vr_nrdcctab(2) := '3321.9302';
    vr_nrdcctab(3) := '3332.9302';
    vr_nrdcctab(4) := '3333.9302';
    vr_nrdcctab(5) := '3342.9302';
    vr_nrdcctab(6) := '3343.9302';
    vr_nrdcctab(7) := '3352.9302';
    vr_nrdcctab(8) := '3353.9302';
    vr_nrdcctab(9) := '3362.9302';
    vr_nrdcctab(10):= '3363.9302';
    vr_nrdcctab(11):= '3372.9302';
    vr_nrdcctab(12):= '3373.9302';
    vr_nrdcctab(13):= '3382.9302';
    vr_nrdcctab(14):= '3383.9302';
    vr_nrdcctab(15):= '3392.9302';
    vr_nrdcctab(16):= '3393.9302';
    vr_nrdcctab(17):= '8442.1721';  -- Emprestimos Pessoas - Origem 3
    vr_nrdcctab(18):= '8442.1723';  -- Emprestimos Empresas - Origem 3
    vr_nrdcctab(19):= '8442.1724';  -- Titulos Descontados - Origem 2 Mod.0302
    vr_nrdcctab(20):= '8442.1731';  -- Financiamentos Pessoas - Origem 3
    vr_nrdcctab(21):= '8442.1731';  -- Financiamentos Empresas - Origem 3
    vr_nrdcctab(22):= '8442.1722';  -- Conta - Origem 1 Mod.0201 Cheque Esp.
    vr_nrdcctab(23):= '8442.1722';  -- Conta - Origem 1 Mod.0299 Outros Empr.
    vr_nrdcctab(24):= '8442.1722';  -- Conta - Origem 1 Mod.0101 Adiant.Depos.
    vr_nrdcctab(25):= '1622.4112';  -- Conta - Origem 1 Mod.0201 Cheque Esp.
    vr_nrdcctab(26):= '1613.4112';  -- Conta - Origem 1 Mod.0299 Outros Empr.
    vr_nrdcctab(27):= '1611.4112';  -- Conta - Origem 1 Mod.0101 Adiant.Depos.
    vr_nrdcctab(28):= '3987.9292';  -- * Conta - Limite Nao Utilizado - PJ
    vr_nrdcctab(29):= '3988.9292';  -- * Conta - Limite Nao Utilizado - PF

    -- Inicializar contador
    vr_contador := 0;

    WHILE vr_contador <= 16 LOOP
      IF vr_vldespes.exists(vr_contador) THEN

        IF vr_vldespes(vr_contador) <> 0 THEN

          vr_vllanmto       := vr_vldespes(vr_contador);
          vr_ttlanmto_risco := vr_ttlanmto_risco + vr_vllanmto;

          vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(vr_contador),'.',',') || ',';

          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                         ',1434,' || '"(risco) CLASSIFICACAO DO RISCO"';
          pc_gravar_linha(vr_linhadet);

          -- Reversão
          vr_nrdcctab_c := ',' ||
                           substr(vr_nrdcctab(vr_contador),6)        ||
                           ',' ||
                           substr(vr_nrdcctab(vr_contador),1,4)      ||
                           ',';

          vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                         TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                         ',1434,' || '"(risco) CLASSIFICACAO DO RISCO"';

          pc_gravar_linha(vr_linhadet);
        END IF;

      END IF;

      vr_contador := vr_contador + 1;

    END LOOP;


    /** LIMITE NAO UTILIZADO - PJ - CONTA EXTENT 28 **/
    IF  vr_vllmtepj <> 0 THEN

      vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(28),'.',',') || ',';

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);


      -- REVERSÃO
      vr_nrdcctab_c := ',' ||
                       substr(vr_nrdcctab(28),6)        ||
                       ',' ||
                       substr(vr_nrdcctab(28),1,4)      ||
                       ',';

      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

    END IF;
    /** LIMITE NAO UTILIZADO - PF - CONTA EXTENT 29 **/
    IF  vr_vllmtepf <> 0 THEN
      vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(29),'.',',') || ',';

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      -- REVERSÃO
      vr_nrdcctab_c := ',' ||
                       substr(vr_nrdcctab(29),6)        ||
                       ',' ||
                       substr(vr_nrdcctab(29),1,4)      ||
                       ',';

      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);
    END IF;

    -- Incorporação Transulcred -> Transpocred
    vr_cdcopant := 0;
    vr_dtincorp := NULL;
    IF (pr_cdcooper = 09) THEN /* Transpocred */
       vr_cdcopant := 17; /* Transulcred */
       vr_dtincorp := to_date('31/12/2016','DD/MM/RRRR'); /* Data da Incorporação */
    END IF;

    -- Juros +60 Microcrédito
    FOR rw_crapris_60 IN cr_crapris_60(pr_cdcooper
                                      ,vr_dtrefere
                                      ,vr_cdcopant
                                      ,vr_dtincorp) LOOP



       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(rw_crapris_60.inpessoa)(vr_price_deb)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(rw_crapris_60.inpessoa)(vr_price_cre)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       TRIM(to_char(rw_crapris_60.vljura60, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO"';
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        --REVERSAO
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       TRIM(to_char(rw_crapris_60.vljura60, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO"';
                       -- Gravar Linha
                       pc_gravar_linha(vr_linhadet);
    END LOOP;

    /******************************************* GERAR ARQUIVO *****************************/


    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    -- Executa comando UNIX para converter arq para Dos
    vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                              || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Busca o diretório para contabilidade
     vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => vc_cdtodascooperativas
                                           ,pr_cdacesso => vc_cdacesso);
     vr_arqcon := to_char(vr_dtmvtolt, 'yy') ||
                  to_char(vr_dtmvtolt, 'mm') ||
                  to_char(vr_dtmvtolt, 'dd') ||
                  '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                  '_RISCO.txt';

      -- Executa comando UNIX para converter arq para Dos
     vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                                vr_dircon||'/'||vr_arqcon||' 2>/dev/null';


    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Remover arquivo tmp
    vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN

        RAISE vr_exc_erro;

    END IF;


    /********************* GERAR ARQUIVO CRRL321 *********************/

    --Inicializar variavel de erro
    vr_des_erro:= NULL;
    -- Busca do diretório base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    -- Define o nome do relatorio
    vr_nom_arquivo := 'crrl321.lst';


    /* IMPRESSAO DO RELATORIO */
    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto,
                        '<?xml version="1.0" encoding="utf-8"?><crrl321>');

    ---  Lista  Contas Contabilzacao (risco.lst ) --
    FOR vr_contador IN 1..27 LOOP

      -- Verifica contador
      IF  vr_contador NOT IN (20,21,23,26) THEN

        -- Verificar se o contador está entre os que devem ser somados
        IF vr_contador IN (19,22,24,25,27) THEN
          -- Somar os totais de PF e PJ
          vr_vltotdev := NVL(vr_vldevedo(vr_contador),0) + NVL(vr_vldevepj(vr_contador),0);
          vr_vltotdes := NVL(vr_vldespes(vr_contador),0) + NVL(vr_vldesppj(vr_contador),0);

          -- Escrever no xml as informacoes
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vltotdev,'fm999G999G999G990D00')||'</vldevedo>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vltotdes,'fm999G999G999G990D00')||'</vldespes>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');
        ELSE
          -- Escrever no xml as informacoes
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vldevedo(vr_contador),'fm999G999G999G990D00')||'</vldevedo>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vldespes(vr_contador),'fm999G999G999G990D00')||'</vldespes>');
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');
        END IF;

      END IF;

      IF vr_contador = 21  THEN
        -- Somar o saldo
        vr_vldevedo(vr_contador) := vr_vldevedo(vr_contador) + vr_vldevedo(20);
        vr_vldespes(vr_contador) := vr_vldespes(vr_contador) + vr_vldespes(20);

        --Escrever no xml as informacoes
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vldevedo(vr_contador),'fm999G999G999G990D00')||'</vldevedo>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vldespes(vr_contador),'fm999G999G999G990D00')||'</vldespes>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      ELSIF vr_contador = 16 THEN   /* Listar Totais Contas Risco */

        /** Risco - Limite Nao utilizado PJ - Nao totaliza "Contab." */
        --Escrever no xml as informacoes
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(28)||'</nrdcctab>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vllmtepj,'fm999G999G999G990D00')||'</vldevedo>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(0,'fm999G999G999G990D00')||'</vldespes>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

        /** Risco - Limite Nao utilizado PF - Nao totaliza "Contab." */
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(29)||'</nrdcctab>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vllmtepf,'fm999G999G999G990D00')||'</vldevedo>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(0,'fm999G999G999G990D00')||'</vldespes>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

        -- "Total Lancto Risco "
        /** Risco - Limite Nao utilizado PF - Nao totaliza "Contab." */
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto Risco</nrdcctab>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo/>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_ttlanmto_risco,'fm999G999G999G990D00')||'</vldespes>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      ELSIF vr_contador = 22 THEN   /* Listar Totais Conta Provisao  */

         -- "Total Lancto Prov. "
        /** Risco - Limite Nao utilizado PF - Nao totaliza "Contab." */
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto Prov.</nrdcctab>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo/>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_ttlanmto,'fm999G999G999G990D00')||'</vldespes>');
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      END IF;
    END LOOP;

    /* Lista Totais Contas - Dividas */
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto CONTA</nrdcctab>');
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_ttlanmto_divida,'fm999G999G999G990D00')||'</vldevedo>');
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes/>');
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      -- Finalizar relatorio
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl321>',true);

    -- Efetuar solicitação de geração de relatório --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                 --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml                  --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl321/registro'         --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl321.jasper'            --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                        --> Nao tem parametros
                               ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo --> Arquivo final com código da agência
                               ,pr_qtcoluna  => 234                         --> 234 colunas
                               ,pr_sqcabrel  => NULL                        --> Sequencia do Relatorio {includes/cabrel132_3.i}
                               ,pr_cdrelato  => 321                         --> Código fixo para o relatório (nao busca pelo sqcabrel)
                               ,pr_flg_impri => 'N'                         --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '234dh'                     --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                           --> Número de cópias
                               ,pr_flg_gerar => 'N'                         --> gerar na hora
                               ,pr_des_erro  => vr_dscritic);               --> Saída com erro

 /**s**/
    -- Verifica se ocorreu erro na geracao do relatorio
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    ---------------------------- FIM GERACAO RELATORIO CRRL321 ----------------------------

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Monta mensagem de erro
      pr_dscritic := 'Erro em RISC0001.pc_risco_k: ' || SQLERRM;
  END pc_risco_k;

  /*** Gerar arquivo txt para radar ***/
  PROCEDURE pc_risco_t(pr_cdcooper   IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : James Prust Junior
    Data    : Marco/2016                       Ultima Alteracao: 27/04/2017

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Gerar Arq. Contabilizacao Provisao

    Alterações:   06/10/2016 - Alteração do diretório para geração de arquivo contábil.
                               P308 (Ricardo Linhares).

                  04/01/2016 - Ajustes para desprezar as contas migradas antes da
                               incorporação.
                               PRJ342 - Incorporação Transulcred(Odirlei-AMcom)

                  27/04/2017 - Nas linhas de reversao verificar se é uma data util
                               (Tiago/Thiago SD 589074).
  ............................................................................. */
    DECLARE
      -- Buscar todos os percentual de cada nivel de risco
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT craptab.dstextab
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND UPPER(craptab.nmsistem) = 'CRED'
           AND UPPER(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres = 00
           AND UPPER(craptab.cdacesso) = 'PROVISAOCL';

      -- Buscar informações da central de risco para documento 3020
      CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT ris.cdcooper
              ,ris.dtrefere
              ,ris.vldivida
              ,ris.nrdconta
              ,ris.innivris
              ,ris.cdmodali
              ,ris.nrctremp
              ,ris.nrseqctr
              ,ris.dsinfaux
              ,ris.vljura60
              ,ris.cdorigem
              ,ris.inpessoa
              ,ris.cdagenci
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 4
      ORDER BY ris.cdagenci;

      CURSOR cr_tbcrd_risco(pr_cdcooper IN crapvri.cdcooper%TYPE
                           ,pr_dtrefere IN crapvri.dtrefere%TYPE) IS
        SELECT COALESCE(SUM(tbcrd_risco.vlsaldo_devedor),0) vllimite
          FROM tbcrd_risco
         WHERE tbcrd_risco.cdcooper = pr_cdcooper
           AND tbcrd_risco.dtrefere = pr_dtrefere;

      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));

      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_fisica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_fisica IS
        TABLE OF typ_reg_pessoa_fisica
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_juridica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_juridica IS
        TABLE OF typ_reg_pessoa_juridica
          INDEX BY PLS_INTEGER;

      -- Vetor
      vr_tab_percentual       typ_tab_percentual;
      vr_tab_pessoa_fisica    typ_tab_pessoa_fisica;
      vr_tab_pessoa_juridica  typ_tab_pessoa_juridica;
      vr_tipsplit             gene0002.typ_split;

      -- Variaveis de controle de erro
      vr_cdcritic             PLS_INTEGER;
      vr_dscritic             VARCHAR2(4000);

      -- Cursor generico de calendario
      rw_crapdat              BTCH0001.cr_crapdat%ROWTYPE;
      vr_dsprmris             crapprm.dsvlrprm%TYPE;
      vr_dtultdma_util        crapdat.dtultdma%TYPE;
      vr_dtmvtopr_arq         crapdat.dtmvtopr%TYPE;
      vr_vlpreatr             NUMBER;
      vr_total_vlpreatr_fis   NUMBER;
      vr_total_vlpreatr_jur   NUMBER;
      vr_total_limite         NUMBER;
      vr_vlpercen             NUMBER;
      vr_hasfound             BOOLEAN;
      vr_linhadet             VARCHAR(3000);
      vr_linhadet_dtultdma    VARCHAR(3000);
      vr_linhadet_dtultdia    VARCHAR(3000);
      vr_dtrefere             DATE;
      vr_indice               PLS_INTEGER;

      -- Declarando handle do Arquivo
      vr_ind_arquivo          utl_file.file_type;
      vr_utlfileh             VARCHAR2(4000);
      -- Nome do Arquivo
      vr_nmarquiv             VARCHAR2(100);

      -- Escrever linha no arquivo
      PROCEDURE pc_gravar_linha(pr_ind_arquivo IN OUT utl_file.file_type
                               ,pr_linha       IN VARCHAR2) IS
      BEGIN
        GENE0001.pc_escr_linha_arquivo(pr_ind_arquivo,pr_linha);
      END;

    BEGIN
      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      vr_hasfound := btch0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      IF NOT vr_hasfound THEN
        -- Gerar excecao
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Vamos verificar se nesse exato momento estah sendo importado o arquivo CB117, pelo JOB
      vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'RISCO_CARTAO_BACEN');

      vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
      IF vr_tipsplit(3) = '1' THEN
        vr_dscritic := 'Nao foi possivel gerar o arquivo contabil. Arquivo CB117 esta sendo importado!';
        RAISE vr_exc_erro;
      END IF;

      -- Seta a flag que nesse momento estamos gerando o arquivo contabil, e nao podera ocorrer importacao de arquivos
      vr_tipsplit(2) := 1;
      RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                             ,pr_tipsplit => vr_tipsplit
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a gravacao da Flag, que nesse momento estah sendo gerado o arquivo contabil
      COMMIT;

      -- CRAPTAB -> 'PROVISAOCL'
      FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
      END LOOP;

      -- Buscar o ultimo dia útil
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                     ,pr_dtmvtolt  => vr_dtrefere -- último dia util
                                                     ,pr_tipo      => 'A');       -- Próximo ou anterior

      -- Data do proximo dia util, depois da mensal
      vr_dtmvtopr_arq := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                                    ,pr_dtmvtolt  => vr_dtrefere + 1 -- último dia util
                                                    ,pr_tipo      => 'P');           -- Próximo ou anterior

     -- Define o diretório do arquivo
     vr_utlfileh := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => vc_cdtodascooperativas
                                             ,pr_cdacesso => vc_cdacesso);


      -- Define Nome do Arquivo
      vr_nmarquiv := TO_CHAR(vr_dtultdma_util,'RR') ||
                     TO_CHAR(vr_dtultdma_util,'MM') ||
                     TO_CHAR(vr_dtultdma_util,'DD') ||'_' ||
                     LPAD(TO_CHAR(pr_cdcooper),2,'0') ||
                     '_RISCOCARTAO.txt';

      -- Abre arquivo em modo de escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Percorrer todos os dados de risco
      FOR rw_crapris IN cr_crapris(pr_cdcooper => pr_cdcooper,
                                   pr_dtrefere => vr_dtrefere) LOOP

        -- Tratar incorporação 17 -> 9
        --> Desprezar contas migradas antes da data de incorporação
        --> contas nao devem ser enviadas no arquivo
        IF pr_cdcooper IN (9) THEN
          IF NOT fn_verifica_conta_migracao(rw_crapris.cdcooper,
                                            rw_crapris.nrdconta,
                                            rw_crapris.dtrefere) THEN
            CONTINUE;
          END IF;
        END IF;

        -- Calculo do % de provisao do Risco
        IF vr_tab_percentual.exists(rw_crapris.innivris) THEN
          vr_vlpercen := vr_tab_percentual(rw_crapris.innivris).percentual / 100;
        ELSE
          vr_vlpercen := 0;
        END IF;

        -- Valor do atraso
        vr_vlpreatr := ROUND((rw_crapris.vldivida *  vr_vlpercen), 2);

        IF rw_crapris.inpessoa = 1 THEN
          -- Valor total pessoa fisica
          vr_total_vlpreatr_fis := NVL(vr_total_vlpreatr_fis,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa fisica
          IF vr_tab_pessoa_fisica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor := vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        ELSE
          -- Valor total pessoa juridica
          vr_total_vlpreatr_jur := NVL(vr_total_vlpreatr_jur,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa juridica
          IF vr_tab_pessoa_juridica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor := vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        END IF;
      END LOOP;

      -- Somar todos os limites de creditos
      OPEN cr_tbcrd_risco(pr_cdcooper => pr_cdcooper
                         ,pr_dtrefere => vr_dtrefere);
      FETCH cr_tbcrd_risco
       INTO vr_total_limite;
      CLOSE cr_tbcrd_risco;

      -- Linha da ultima data do mes anterior
      vr_linhadet_dtultdma := '70' ||
                              TO_CHAR(vr_dtultdma_util, 'yy') ||
                              TO_CHAR(vr_dtultdma_util, 'mm') ||
                              TO_CHAR(vr_dtultdma_util, 'dd');

      -- Linha do ultimo dia do mes
      vr_linhadet_dtultdia := '70' ||
                              TO_CHAR(rw_crapdat.dtultdia, 'yy') ||
                              TO_CHAR(rw_crapdat.dtultdia, 'mm') ||
                              TO_CHAR(rw_crapdat.dtultdia, 'dd');

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DO CARTAO DE CREDITO PESSOA FISICA
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_vlpreatr_fis > 0 THEN
      vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8453,4914,' ||
                     TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA FISICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa fisica e grava no arquivo
      vr_indice := vr_tab_pessoa_fisica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
      -----------------------------------------------------------------------------------------------------------
      vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                     TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                             ,pr_dtmvtolt  => rw_crapdat.dtultdia
                                                             ,pr_tipo      => 'A'
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8453,' ||
                     TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA FISICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa fisica e grava no arquivo
      vr_indice := vr_tab_pessoa_fisica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
      END LOOP;
      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DO CARTAO DE CREDITO PESSOA JURIDICA
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_vlpreatr_jur > 0 THEN
      vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8454,4914,' ||
                     TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA JURIDICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa juridica e grava no arquivo
      vr_indice := vr_tab_pessoa_juridica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
      -----------------------------------------------------------------------------------------------------------
      vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                     TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                             ,pr_dtmvtolt  => rw_crapdat.dtultdia
                                                             ,pr_tipo      => 'A'
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8454,' ||
                     TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA JURIDICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa juridica e grava no arquivo
      vr_indice := vr_tab_pessoa_juridica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
      END LOOP;

      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE LIMITE CONCEDIDO CARTAO
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_limite > 0 THEN
        vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                       TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',3133,9131,' ||
                       TRIM(to_char(vr_total_limite, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) LIMITE CONCEDIDO CARTAO"';

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);

        -----------------------------------------------------------------------------------------------------------
        --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
        -----------------------------------------------------------------------------------------------------------
        vr_linhadet := '70' ||
                       TO_CHAR(vr_dtmvtopr_arq, 'yy') ||
                       TO_CHAR(vr_dtmvtopr_arq, 'mm') ||
                       TO_CHAR(vr_dtmvtopr_arq, 'dd') || ',' ||
                       TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                               ,pr_dtmvtolt  => vr_dtmvtopr_arq
                                                               ,pr_tipo      => 'A'
                                                               ,pr_excultdia => TRUE), 'ddmmyy')) || ',9131,3133,' ||
                       TRIM(to_char(vr_total_limite, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) REVERSAO LIMITE CONCEDIDO CARTAO"';

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);

      END IF;

      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      -----------------------------------------------------------------------------------------------------------
      --  Grava na tabela de controle que o arquivo contabil foi gerado
      -----------------------------------------------------------------------------------------------------------
      vr_tipsplit(1) := TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR');
      vr_tipsplit(2) := 0;
      RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                             ,pr_tipsplit => vr_tipsplit
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;
        -- Atualiza os dados de controle do arquivo contabil
        vr_tipsplit(2) := 0;
        RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                               ,pr_tipsplit => vr_tipsplit
                                               ,pr_dscritic => vr_dscritic);
        COMMIT;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Monta mensagem de erro
        pr_dscritic := 'Erro em RISC0001.pc_risco_t: ' || SQLERRM;
        -- Atualiza os dados de controle do arquivo contabil
        vr_tipsplit(2) := 0;
        RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                               ,pr_tipsplit => vr_tipsplit
                                               ,pr_dscritic => vr_dscritic);
        COMMIT;
    END;

  END pc_risco_t;

    /*** Gerar arquivo txt para radar da Provisão das Garantias Prestadas ***/
  PROCEDURE pc_risco_g(pr_cdcooper   IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei-Mouts
    Data    : Maio/2017                       Ultima Alteracao:

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Gerar Arq. Contabilizacao Provisao

    Alterações:
  ............................................................................. */
    DECLARE
      -- Buscar todos os percentual de cada nivel de risco
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT craptab.dstextab
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND UPPER(craptab.nmsistem) = 'CRED'
           AND UPPER(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres = 00
           AND UPPER(craptab.cdacesso) = 'PROVISAOCL';

      -- Buscar informações da central de risco para Provisão
      CURSOR cr_crapris_dividas(pr_cdcooper IN crapris.cdcooper%TYPE
                               ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT ris.cdcooper
              ,ris.dtrefere
              ,ris.vldivida
              ,ris.nrdconta
              ,ris.innivris
              ,ris.cdmodali
              ,ris.nrctremp
              ,ris.nrseqctr
              ,ris.dsinfaux
              ,ris.vljura60
              ,ris.cdorigem
              ,ris.inpessoa
              ,ris.cdagenci
              ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia) cdgarantia
              ,prd.dsproduto
              ,ROW_NUMBER ()
                 OVER (PARTITION BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia) ORDER BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia),ris.cdagenci) nrseqgar
              ,Count (1)
                 OVER (PARTITION BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia)) qtreggar
          FROM crapris ris
              ,tbrisco_provisgarant_movto mvt
              ,tbrisco_provisgarant_prodt prd
         WHERE mvt.idproduto = prd.idproduto
           AND ris.dsinfaux = mvt.idmovto_risco
           AND ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 5                -- Registros lançados em tela
           AND ris.innivris > 1                -- Contratos com risco = AA não tem provisão
      ORDER BY prd.dsproduto
              ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia)
              ,ris.cdagenci;

      -- Buscar informações da central de risco para envio dos valores Contratados
      CURSOR cr_crapris_contrat(pr_cdcooper IN crapris.cdcooper%TYPE
                               ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT risc0003.fn_valor_opcao_dominio(mvt.idgarantia) cdgarantia
              ,prd.dsproduto
              /* Produtos Cartão usam Valor Operação (Limite) outros usam SALDO*/
              ,sum(DECODE(INSTR(UPPER(prd.tparquivo),'CARTAO'),0,mvt.vlsaldo_pendente,mvt.vloperacao)) vloperacao
          FROM crapris ris
              ,tbrisco_provisgarant_movto mvt
              ,tbrisco_provisgarant_prodt prd
         WHERE mvt.idproduto = prd.idproduto
           AND ris.dsinfaux = mvt.idmovto_risco
           AND ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 5                -- Registros lançados em tela
           AND ris.vldivida > 0                -- Com saldo
        GROUP BY prd.dsproduto
                ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia)
      ORDER BY prd.dsproduto
              ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia);

      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));

      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_fisica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_fisica IS
        TABLE OF typ_reg_pessoa_fisica
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_juridica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_juridica IS
        TABLE OF typ_reg_pessoa_juridica
          INDEX BY PLS_INTEGER;

      -- Vetor
      vr_tab_percentual       typ_tab_percentual;
      vr_tab_pessoa_fisica    typ_tab_pessoa_fisica;
      vr_tab_pessoa_juridica  typ_tab_pessoa_juridica;

      -- Variaveis de controle de erro
      vr_cdcritic             PLS_INTEGER;
      vr_dscritic             VARCHAR2(4000);

      -- Cursor generico de calendario
      rw_crapdat              BTCH0001.cr_crapdat%ROWTYPE;
      vr_dtultdia_util        crapdat.dtultdia%TYPE;
      vr_dtmvtopr_arq         crapdat.dtmvtopr%TYPE;
      vr_vlpreatr             NUMBER;
      vr_total_vlpreatr_fis   NUMBER;
      vr_total_vlpreatr_jur   NUMBER;
      vr_vlpercen             NUMBER;
      vr_hasfound             BOOLEAN;
      vr_linhadet             VARCHAR(3000);
      vr_linhadet_dtultdia    VARCHAR(3000);
      vr_linhadet_dtprxdia    VARCHAR(3000);
      vr_dtrefere             DATE;
      vr_indice               PLS_INTEGER;

      -- Declarando handle do Arquivo
      vr_ind_arquivo          utl_file.file_type;
      vr_utlfileh             VARCHAR2(4000);
      -- Nome do Arquivo
      vr_nmarquiv             VARCHAR2(100);
      -- Contas de Debito e Credito
      vr_nrctaded_pf NUMBER;
      vr_nrctaded_pj NUMBER;
      vr_nrctacre NUMBER;
      vr_nrctadeb NUMBER;


    BEGIN
      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      vr_hasfound := btch0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      IF NOT vr_hasfound THEN
        -- Gerar excecao
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Verificar se foi encerrada a digitação pelo Financeiro
      IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIGIT_RISCO_FINAN_LIBERA') = 1 THEN
        vr_dscritic := 'Periodo para digitacao nao encerrado pela area responsavel!';
        RAISE vr_exc_erro;
      END IF;

      -- CRAPTAB -> 'PROVISAOCL'
      FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
      END LOOP;

      -- Buscar o ultimo dia útil
      vr_dtultdia_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                     ,pr_dtmvtolt  => vr_dtrefere -- último dia util
                                                     ,pr_tipo      => 'A');       -- Próximo ou anterior

      -- Buscar o proximo dia útil
      vr_dtmvtopr_arq := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                    ,pr_dtmvtolt  => vr_dtrefere+1 -- último dia util
                                                    ,pr_tipo      => 'P');         -- Próximo ou anterior


      -- Define o diretório do arquivo
      vr_utlfileh := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => vc_cdtodascooperativas
                                              ,pr_cdacesso => vc_cdacesso);


      -- Define Nome do Arquivo
      vr_nmarquiv := TO_CHAR(vr_dtultdia_util,'RR') ||
                     TO_CHAR(vr_dtultdia_util,'MM') ||
                     TO_CHAR(vr_dtultdia_util,'DD') ||'_' ||
                     LPAD(TO_CHAR(pr_cdcooper),2,'0') ||
                     '_RISCO_GARANTIAS.txt';

      -- Abre arquivo em modo de escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Linha do ultimo dia anterior
      vr_linhadet_dtultdia := '70' ||
                              TO_CHAR(vr_dtultdia_util, 'yy') ||
                              TO_CHAR(vr_dtultdia_util, 'mm') ||
                              TO_CHAR(vr_dtultdia_util, 'dd');

      -- Linha do proximo dia util
      vr_linhadet_dtprxdia := '70' ||
                              TO_CHAR(vr_dtmvtopr_arq, 'yy') ||
                              TO_CHAR(vr_dtmvtopr_arq, 'mm') ||
                              TO_CHAR(vr_dtmvtopr_arq, 'dd');

      -- Percorrer todos os dados de risco de dividas para geração provisão
      FOR rw_crapris IN cr_crapris_dividas(pr_cdcooper => pr_cdcooper,
                                           pr_dtrefere => vr_dtrefere) LOOP

        -- Calculo do % de provisao do Risco
        IF vr_tab_percentual.exists(rw_crapris.innivris) THEN
          vr_vlpercen := vr_tab_percentual(rw_crapris.innivris).percentual / 100;
        ELSE
          vr_vlpercen := 0;
        END IF;

        -- Valor do atraso
        vr_vlpreatr := ROUND((rw_crapris.vldivida *  vr_vlpercen), 2);

        -- Para o primeiro registro do tipo de garantia
        IF rw_crapris.nrseqgar = 1 THEN
          -- Inicializar contadores
          vr_total_vlpreatr_fis := 0;
          vr_tab_pessoa_fisica.delete();
          vr_total_vlpreatr_jur := 0;
          vr_tab_pessoa_juridica.delete();
        END IF;

        IF rw_crapris.inpessoa = 1 THEN
          -- Valor total pessoa fisica
          vr_total_vlpreatr_fis := NVL(vr_total_vlpreatr_fis,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa fisica
          IF vr_tab_pessoa_fisica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor := vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        ELSE
          -- Valor total pessoa juridica
          vr_total_vlpreatr_jur := NVL(vr_total_vlpreatr_jur,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa juridica
          IF vr_tab_pessoa_juridica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor := vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        END IF;

        -- No ultimo registro do tipo de garantia
        IF rw_crapris.qtreggar = rw_crapris.nrseqgar THEN

          -- Contas de Debito cfme tipo de pessoa
          vr_nrctaded_pf := 8453;
          vr_nrctaded_pj := 8454;

          -- Conta credito conforme garantia
          IF rw_crapris.cdgarantia = '01' THEN
            vr_nrctacre := 4914;
          ELSIF rw_crapris.cdgarantia = '02' THEN
            vr_nrctacre := 4868;
          ELSE
            vr_nrctacre := 4867;
          END IF;

          -- GARANTIAS PF
          IF vr_total_vlpreatr_fis > 0 THEN
            vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                           TRIM(to_char(vr_dtultdia_util, 'ddmmyy')) || ','||vr_nrctaded_pf||','||vr_nrctacre||',' ||
                           TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                           ',1434,' ||
                           '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS '||rw_crapris.dsproduto||' PF COOPERATIVAS FILIADAS"';

            -- Grava a linha no arquivo
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                          ,vr_linhadet);

            -- Percorre todas as agencias de pessoa fisica e grava no arquivo
            vr_indice := vr_tab_pessoa_fisica.first;
            WHILE vr_indice IS NOT NULL LOOP
              -- Se houver valor
              IF vr_tab_pessoa_fisica(vr_indice).valor > 0 THEN
                vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                               TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));
                -- Grava a linha no arquivo
                GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                              ,vr_linhadet);
              END IF;
              -- Proximo registro
              vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
            END LOOP;

            -- REVERSAO GARANTIAS PF
            vr_linhadet := TRIM(vr_linhadet_dtprxdia) || ',' ||
                           TRIM(to_char(vr_dtmvtopr_arq, 'ddmmyy')) || ','||vr_nrctacre||','||vr_nrctaded_pf||',' ||
                           TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                           ',1434,' ||
                           '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS '||rw_crapris.dsproduto||' PF COOPERATIVAS FILIADAS"';

            -- Grava a linha no arquivo
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                          ,vr_linhadet);

            -- Percorre todas as agencias de pessoa fisica e grava no arquivo
            vr_indice := vr_tab_pessoa_fisica.first;
            WHILE vr_indice IS NOT NULL LOOP
              -- Se houver valor
              IF vr_tab_pessoa_fisica(vr_indice).valor > 0 THEN
                vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                               TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));
                -- Grava a linha no arquivo
                GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                              ,vr_linhadet);
              END IF;
              -- Proximo registro
              vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
            END LOOP;
          END IF; -- FIM PF

          -- GARANTIAS PJ
          IF vr_total_vlpreatr_jur > 0 THEN
            vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                          TRIM(to_char(vr_dtultdia_util, 'ddmmyy')) || ','||vr_nrctaded_pj||','||vr_nrctacre||',' ||
                          TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                          ',1434,' ||
                          '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS '||rw_crapris.dsproduto||' PJ COOPERATIVAS FILIADAS"';

            -- Grava a linha no arquivo
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                          ,vr_linhadet);

            -- Percorre todas as agencias de pessoa juridica e grava no arquivo
            vr_indice := vr_tab_pessoa_juridica.first;
            WHILE vr_indice IS NOT NULL LOOP
              -- Se houver valor
              IF vr_tab_pessoa_juridica(vr_indice).valor > 0 THEN
                vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                               TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
                -- Grava a linha no arquivo
                GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                              ,vr_linhadet);
              END IF;
              -- Proximo registro
              vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
            END LOOP;

            -- REVERSAO GARANTIA PJ
            vr_linhadet := TRIM(vr_linhadet_dtprxdia) || ',' ||
                           TRIM(to_char(vr_dtmvtopr_arq, 'ddmmyy')) || ','||vr_nrctacre||','||vr_nrctaded_pj||',' ||
                           TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                           ',1434,' ||
                           '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS '||rw_crapris.dsproduto||' PJ COOPERATIVAS FILIADAS"';

            -- Grava a linha no arquivo
            GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                          ,vr_linhadet);

            -- Percorre todas as agencias de pessoa juridica e grava no arquivo
            vr_indice := vr_tab_pessoa_juridica.first;
            WHILE vr_indice IS NOT NULL LOOP
              -- Se houver valor
              IF vr_tab_pessoa_juridica(vr_indice).valor > 0 THEN
                vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                               TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
                -- Grava a linha no arquivo
                GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                              ,vr_linhadet);
              END IF;
              -- Proximo registro
              vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
            END LOOP;
          END IF; -- FIM PJ

        END IF; -- FIM ULTIMO REGISTRO

      END LOOP;

      -- Percorrer todos os dados de risco de dividas para geração provisão
      FOR rw_crapris IN cr_crapris_contrat(pr_cdcooper => pr_cdcooper,
                                           pr_dtrefere => vr_dtrefere) LOOP
        -- Contas de Credito é fixa
        vr_nrctacre := 9131;

        -- Conta Debito conforme garantia
        IF rw_crapris.cdgarantia = '01' THEN
          vr_nrctadeb := 3133;
        ELSIF rw_crapris.cdgarantia = '02' THEN
          vr_nrctadeb := 3142;
        ELSE
          vr_nrctadeb := 3143;
        END IF;

        -- Se há valor contratado
        IF rw_crapris.vloperacao > 0 THEN
          vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                         TRIM(to_char(vr_dtultdia_util, 'ddmmyy')) || ','||vr_nrctadeb||','||vr_nrctacre||',' ||
                         TRIM(to_char(rw_crapris.vloperacao, '99999999999990.00')) ||
                         ',1434,' ||
                         '"(risco) VALOR CONCEDIDO EM GARANTIA '||rw_crapris.dsproduto||' COOPERATIVAS FILIADAS"';

          -- Grava a linha no arquivo
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                        ,vr_linhadet);

          -- REVERSAO GARANTIAS
          vr_linhadet := TRIM(vr_linhadet_dtprxdia) || ',' ||
                         TRIM(to_char(vr_dtmvtopr_arq, 'ddmmyy')) || ','||vr_nrctacre||','||vr_nrctadeb||',' ||
                         TRIM(to_char(rw_crapris.vloperacao, '99999999999990.00')) ||
                         ',1434,' ||
                         '"(risco) REVERSAO VALOR CONCEDIDO EM GARANTIA '||rw_crapris.dsproduto||' COOPERATIVAS FILIADAS"';

          -- Grava a linha no arquivo
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo
                                        ,vr_linhadet);


        END IF; -- FIM TEM VALOR


      END LOOP;  -- Fim leitura valores contratados

      -- Fechar arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Monta mensagem de erro
        pr_dscritic := 'Erro em RISC0001.pc_risco_g: ' || SQLERRM;
    END;

  END pc_risco_g;

  /* Obter os dados do banco cetral para analise da proposta, consulta de SCR. (Tela CONSCR) */
  PROCEDURE pc_obtem_valores_central_risco(pr_cdcooper IN crapcop.cdcooper%type                    --> Codigo Cooperativa
                                          ,pr_cdagenci IN crapass.cdagenci%type                    --> Codigo Agencia
                                          ,pr_nrdcaixa IN INTEGER                                  --> Numero Caixa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE                    --> Numero da Conta
                                          ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE                    --> CPF/CGC do associado
                                          ,pr_tab_central_risco OUT risc0001.typ_reg_central_risco --> Informações da Central de Risco
                                          ,pr_tab_erro          OUT gene0001.typ_tab_erro          --> Tabela Erro
                                          ,pr_des_reto          OUT VARCHAR2) IS                   --> Retorno OK/NOK
  BEGIN
    /* .............................................................................

     Programa: pc_obtem_valores_central_risco                 Antigo: b1wgen0024.p --> obtem-valores-central-risco
     Sistema : CRED
     Sigla   : CADA0001
     Autor   : Marcos E. Martini
     Data    : Agosto/2014.                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamada.
     Objetivo  : Obter os dados do banco cetral para analise da proposta, consulta de SCR.
                (Tela CONSCR)

     Alteracoes: 29/08/2014 - Conversao Progress >> Oracle (PLSQL) (Marcos-Supero)

    ............................................................................. */
    DECLARE
      -- Controle de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(1000);
      vr_exc_erro exception;
      -- Auxiliares para calculo dos intervalos de busca
      vr_dtauxili DATE;
      -- Buscaremos a ultima operação financeira superior ao período em teste
      CURSOR cr_crapopf_dt(pr_dtauxili DATE) IS
        SELECT /*+index (crapopf crapopf##crapopf2)*/
               dtrefere
          FROM crapopf
         WHERE dtrefere >= pr_dtauxili --> Somente após o período passado
         ORDER BY dtrefere DESC;
      -- Buscar o CPF/CGC do Associado
      CURSOR cr_crapass IS
        SELECT nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
      -- Buscaremos a ultima operação financeira superior ao período em teste
      CURSOR cr_crapopf_cpf(pr_nrcpfcgc crapopf.nrcpfcgc%type
                           ,pr_dtrefere crapopf.dtrefere%type) IS
        SELECT dtrefere
              ,qtopesfn
              ,qtifssfn
          FROM crapopf
         WHERE nrcpfcgc  = pr_nrcpfcgc --> Somente do CPFCGC passado
           AND dtrefere >= pr_dtrefere --> Somente após o período passado
         ORDER BY dtrefere DESC;       --> Buscar a ultima
      rw_crapopf_cpf cr_crapopf_cpf%ROWTYPE;
      -- Vencimento das operações financeiras
      CURSOR cr_crapvop(pr_nrcpfcgc crapopf.nrcpfcgc%type
                       ,pr_dtrefere crapopf.dtrefere%type) IS
        SELECT SUM(vlvencto) vltotsfn
              ,sum(case
                    when cdvencto >= 205 and cdvencto <= 290 then vlvencto
                    else 0
                   end) vlopescr
              ,sum(case
                    when cdvencto >= 310 and cdvencto <= 330 then vlvencto
                    else 0
                   end) vlrpreju
          FROM crapvop
         WHERE nrcpfcgc = pr_nrcpfcgc
           AND dtrefere = pr_dtrefere;
      rw_crapvop cr_crapvop%ROWTYPE;
    BEGIN
      -- Se ainda não encontrou a data da ultima
      -- movimentação nesta seção em execução
      IF vr_dtrefris IS NULL THEN
        -- Inicializar com sysdate
        vr_dtauxili := SYSDATE;
        -- Buscaremos a ultima operação financeira superior ao período em teste
        LOOP
          -- Buscas com saltos de mês em mês
          vr_dtauxili := ADD_MONTHS(vr_dtauxili,-1);
          -- Buscar na tabela
          OPEN cr_crapopf_dt(vr_dtauxili);
          FETCH cr_crapopf_dt
           INTO vr_dtrefris;
          -- Sair quando tiver encontrado
          EXIT WHEN cr_crapopf_dt%FOUND;
          -- Se não saiu é pq não encontrou, fechar o cursor para tentar novamente
          CLOSE cr_crapopf_dt;
        END LOOP;
        -- Fechar o cursor do teste acima
        IF cr_crapopf_dt%FOUND THEN
          CLOSE cr_crapopf_dt;
        END IF;
      END IF;
      -- Se nao foi enviado CPF
      IF NVL(pr_nrcpfcgc,0) = 0 THEN
        -- Pegar da conta
        OPEN cr_crapass;
        FETCH cr_crapass
         INTO vr_nrcpfcgc;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          -- Gerar erro critica 9
          vr_cdcritic := 9;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapass;
        END IF;
      ELSE
        -- Usaremos este
        vr_nrcpfcgc := pr_nrcpfcgc;
      END IF;
      -- Pegar ultimo valor recibido das ope. financeiras, s/ CDCOOPER
      OPEN cr_crapopf_cpf(vr_nrcpfcgc,vr_dtrefris);
      FETCH cr_crapopf_cpf
       INTO rw_crapopf_cpf;
      -- Somente continuar se encontrou
      IF cr_crapopf_cpf%FOUND THEN
        CLOSE cr_crapopf_cpf;
        -- Buscar o Vencimento das operacoes financeiras
        OPEN cr_crapvop(vr_nrcpfcgc,rw_crapopf_cpf.dtrefere);
        FETCH cr_crapvop
         INTO rw_crapvop;
        CLOSE cr_crapvop;
        -- Enfim, cria o registro na tabela de central de risco
        pr_tab_central_risco.dtdrisco := rw_crapopf_cpf.dtrefere;
        pr_tab_central_risco.qtopescr := rw_crapopf_cpf.qtopesfn;
        pr_tab_central_risco.qtifoper := rw_crapopf_cpf.qtifssfn;
        pr_tab_central_risco.vltotsfn := rw_crapvop.vltotsfn;
        pr_tab_central_risco.vlopescr := rw_crapvop.vlopescr;
        pr_tab_central_risco.vlrpreju := rw_crapvop.vlrpreju;
      ELSE
        -- Apenas fechar o cursor e não retornar os dados da central de risco
        CLOSE cr_crapopf_cpf;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        vr_dscritic := 'Erro não tratado em RISC0001.pc_calcula_faturamento: ' || SQLERRM;
        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        pr_des_reto := 'NOK';
    END;
  END pc_obtem_valores_central_risco;

  /* Obter as informaões de estouro do cooperado */
  PROCEDURE pc_lista_estouros(pr_cdcooper      IN crapcop.cdcooper%type     --> Codigo Cooperativa
                             ,pr_cdoperad      IN crapope.cdoperad%type     --> Operador conectado
                             ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                             ,pr_idorigem      IN INTEGER                   --> Identificador Origem
                             ,pr_idseqttl      IN INTEGER                   --> Sequencial do Titular
                             ,pr_nmdatela      IN VARCHAR2                  --> Nome da tela
                             ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE     --> Data do movimento
                             ,pr_tab_estouros OUT risc0001.typ_tab_estouros --> Informações de estouro na conta
                             ,pr_dscritic     OUT VARCHAR2) IS              --> Retorno de erro
  BEGIN
    /* .............................................................................

     Programa: pc_lista_estouros                 Antigo: b1wgen0027.p --> lista_estouros
     Sistema : CRED
     Sigla   : CADA0001
     Autor   : Marcos E. Martini
     Data    : Agosto/2014.                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamada.
     Objetivo  : Obter as informaões de estouro do cooperado

     Alteracoes: 29/08/2014 - Conversao Progress >> Oracle (PLSQL) (Marcos-Supero)

    ............................................................................. */
    DECLARE
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Informações negativas da conta
      CURSOR cr_crapneg IS
        SELECT cdhisest
              ,cdobserv
              ,nrseqdig
              ,dtiniest
              ,dtfimest
              ,qtdiaest
              ,vlestour
              ,nrdctabb
              ,nrdocmto
              ,vllimcre
              ,cdtctant
              ,cdtctatu
          FROM crapneg
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      -- Variaveis genéricas para preenchimento da pltable
      vr_cdhisest VARCHAR2(30);
      vr_dsobserv crapali.dsalinea%type;
      vr_cdobserv VARCHAR2(100);
      vr_dscodant VARCHAR2(30);
      vr_dscodatu VARCHAR2(30);
      vr_idx      NUMBER;
      -- Busca das alíneas
      CURSOR cr_crapali(pr_cdobserv crapali.cdalinea%TYPE) IS
        SELECT cdalinea
              ,dsalinea
          FROM crapali
         WHERE cdalinea = pr_cdobserv;
      rw_crapali cr_crapali%ROWTYPE;

      -- Busca do cadastro de tipo de contas
      CURSOR cr_craptip
                       IS
        SELECT dstipcta,
               cdcooper,
               cdtipcta
          FROM craptip;
    BEGIN

      -- popular temp table de contas se estiver vazia
      IF vr_tab_craptip.COUNT = 0 THEN

        FOR rw_craptip IN cr_craptip LOOP
          -- definir index
          vr_idx := lpad(rw_craptip.cdcooper,10,'0')||lpad(rw_craptip.cdtipcta,5,'0');
          vr_tab_craptip(vr_idx).cdcooper := rw_craptip.cdcooper;
          vr_tab_craptip(vr_idx).cdtipcta := rw_craptip.cdtipcta;
          vr_tab_craptip(vr_idx).dstipcta := rw_craptip.dstipcta;
        END LOOP;

      END IF;

      -- Laço sobre as informações negativas da conta
      FOR rw_crapneg IN cr_crapneg LOOP
        -- Limpar variaveis
        vr_cdobserv := '';
        vr_dsobserv := '';
        vr_dscodant := '';
        vr_dscodatu := '';
        -- Gerar descrição do histórico
        CASE rw_crapneg.cdhisest
          WHEN 0 THEN vr_cdhisest := 'Admissao socio';
          WHEN 1 THEN vr_cdhisest := 'Devolucao Chq.';
          WHEN 2 THEN vr_cdhisest := 'Alt. Tipo Conta';
          WHEN 3 THEN vr_cdhisest := 'Alt. Sit. Conta';
          WHEN 4 THEN vr_cdhisest := 'Credito Liquid.';
          WHEN 5 THEN vr_cdhisest := 'Estouro';
          WHEN 6 THEN vr_cdhisest := 'Notificacao';
          ELSE vr_cdhisest := '';
        END CASE;
        -- Testar acerto
        IF (rw_crapneg.cdhisest = 1 AND rw_crapneg.dtfimest IS NOT NULL) THEN
          vr_dscodatu := '  ACERTADO';
        END IF;
        -- Para históricos 1 e 5 com observação
        IF (rw_crapneg.cdhisest IN(1,5) AND rw_crapneg.cdobserv > 0) THEN
          -- Buscar alinea
          OPEN cr_crapali(rw_crapneg.cdobserv);
          FETCH cr_crapali
           INTO rw_crapali;
          -- Se não encontrou
          IF cr_crapali%NOTFOUND THEN
            -- Para o histórico 1, concatenar a alínea
            IF rw_crapneg.cdhisest = 1 THEN
              vr_dsobserv := 'Alinea '|| to_char(rw_crapneg.cdobserv);
              vr_cdobserv := '';
            ELSE
              vr_cdobserv := '';
              vr_dsobserv := '';
            END IF;
          ELSE
            -- Usar informações da alinea
            vr_dsobserv := rw_crapali.dsalinea;
            vr_cdobserv := rw_crapali.cdalinea;
          END IF;
          CLOSE cr_crapali;
        END IF;
        -- Para o histórico 2
        IF rw_crapneg.cdhisest = 2 THEN
          -- Buscaremos o cadastro de tipo de conta anterior
          vr_idx := lpad(pr_cdcooper,10,'0')||lpad(rw_crapneg.cdtctant,5,'0');
          -- Se não encontrar
          IF NOT vr_tab_craptip.exists(vr_idx) THEN
            vr_dscodant := rw_crapneg.cdtctant;
          ELSE
            -- Usamos a descrição dele
            vr_dscodant := vr_tab_craptip(vr_idx).dstipcta;
          END IF;

          -- Buscaremos o cadastro de tipo de conta para a atual
          vr_idx := lpad(pr_cdcooper,10,'0')||lpad(rw_crapneg.cdtctatu,5,'0');
          -- Se não encontrar
          IF NOT vr_tab_craptip.exists(vr_idx) THEN
            vr_dscodatu := rw_crapneg.cdtctatu;
          ELSE
            -- Usamos a descrição dele
            vr_dscodatu := vr_tab_craptip(vr_idx).dstipcta;
          END IF;
        END IF;
        -- Para o histórico 3
        IF rw_crapneg.cdhisest = 3 THEN
          -- Se não há tipo conta anterior
          IF rw_crapneg.cdtctant = 0 THEN
            vr_dscodant := rw_crapneg.cdtctant;
          ELSE
            -- Guardar normal ou encerrada
            IF rw_crapneg.cdtctant = 1 THEN
              vr_dscodant := 'NORMAL';
            ELSE
              vr_dscodant := 'ENCERRADA';
            END IF;
          END IF;
          -- Se não há tipo de conta atual
          IF rw_crapneg.cdtctatu = 0  THEN
            vr_dscodatu := rw_crapneg.cdtctatu;
          ELSE
            -- Guardar normal ou encerrada
            IF rw_crapneg.cdtctatu = 1 THEN
              vr_dscodatu := 'NORMAL';
            ELSE
              vr_dscodatu := 'ENCERRADA';
            END IF;
          END IF;
        END IF;
        -- Enfim, criar as informações na tabela de estouros
        vr_idx := pr_tab_estouros.count + 1;
        pr_tab_estouros(vr_idx).nrseqdig := rw_crapneg.nrseqdig;
        pr_tab_estouros(vr_idx).dtiniest := rw_crapneg.dtiniest;
        pr_tab_estouros(vr_idx).qtdiaest := rw_crapneg.qtdiaest;
        pr_tab_estouros(vr_idx).cdhisest := vr_cdhisest;
        pr_tab_estouros(vr_idx).vlestour := rw_crapneg.vlestour;
        pr_tab_estouros(vr_idx).nrdctabb := rw_crapneg.nrdctabb;
        pr_tab_estouros(vr_idx).nrdocmto := rw_crapneg.nrdocmto;
        pr_tab_estouros(vr_idx).cdobserv := vr_cdobserv;
        pr_tab_estouros(vr_idx).dsobserv := vr_dsobserv;
        pr_tab_estouros(vr_idx).vllimcre := rw_crapneg.vllimcre;
        pr_tab_estouros(vr_idx).dscodant := vr_dscodant;
        pr_tab_estouros(vr_idx).dscodatu := vr_dscodatu;
      END LOOP;
      -- Gerar LOG do acessoa  rotina
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Listar estouros de conta.'
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado em RISC0001.pc_lista_estouros: ' || SQLERRM;
    END;
  END pc_lista_estouros;


END RISC0001;
/