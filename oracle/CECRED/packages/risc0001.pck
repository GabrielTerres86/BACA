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
                                          ,pr_tab_central_risco OUT RISC0001.typ_reg_central_risco --> Informações da Central de Risco
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
                             ,pr_tab_estouros OUT RISC0001.typ_tab_estouros --> Informações de estouro na conta
                             ,pr_dscritic     OUT VARCHAR2);                --> Retorno de erro

  PROCEDURE pc_gera_arq_3026(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                   ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE --> Data de referência
                                   --,pr_retorno   OUT xmltype            --> XML de retorno
                                   ,pr_retxml    OUT CLOB                 --> Arquivo de retorno do XML
                                   ,pr_dscritic  OUT VARCHAR2);           --> Texto de erro/critica encontrada

END RISC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0001
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Agosto/2014.                   Ultima atualizacao: 19/08/2019
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
  --
  --             26/02/2018 - Tabela CRAPTIP substituida pela TBCC_TIPO_CONTA. PRJ366 (Lombardi).
  --
  --             29/01/2019 - Projeto Demanda Regulatoria (Contabilidade) - Alteracao na numeracao das contas utilizadas.
  --                          Heitor (Mouts)
  --             01/02/2019 - P450 - Criação da pc_gera_arq_3026 para gerar o 3026
  --                          (Fabio Adriano - AMcom).
  --
  --             15/02/2019 - P450 - Alteração no arquivo 3026 uso do cpfcnpj_base no participante
  --                          do grupo (Fabio Adriano - AMcom)
  --
  --             01/04/2019 - Correção historicos contabilização operações de desconto de tiutlo (Daniel - Ailos) 
  --
  --             19/08/2019 - Segregação de juros 60 até 90 dias e acima de 90 dias. (Darlei / Supero)
  ---------------------------------------------------------------------------------------------------------------

  -- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  vr_dtrefris DATE;

  type typ_reg_tipo_conta is record
       (cdtipcta  tbcc_tipo_conta.cdtipo_conta%type,
        dstipcta  tbcc_tipo_conta.dstipo_conta%type,
        inpessoa  tbcc_tipo_conta.inpessoa%type);

  type typ_tab_tipo_conta is table of typ_reg_tipo_conta
  index by varchar2(15); --cdcooper(10) + cdtipcta(+)

  vr_tab_tipo_conta typ_tab_tipo_conta;



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

  PROCEDURE pc_calcula_juros_60_tdb(par_cdcooper IN crapris.cdcooper%TYPE
                                ,par_dtrefere IN crapris.dtrefere%TYPE
                                ,par_totrendap OUT typ_decimal_pfpj
                                ,par_totjurmra OUT typ_decimal_pfpj
                                ,par_rendaapropr OUT typ_arr_decimal_pfpj    --> RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
                                ,par_apropjurmra OUT typ_arr_decimal_pfpj    --> APROPR. JUROS DE MORA DESCONTO DE TITULO
                                ) IS
  -- ..........................................................................
  --
  --  Programa : pc_calcula_juros_60_tdb

  --  Sistema  : Rotinas para geracao do calculos de juros de desconto de titulo
  --  Sigla    : RISC
  --  Autor    : Luis Fernando (GFT)
  --  Data     : 25/06/2018
  --
  --  Alteração : 25/06/2018 - Criação (Luis Fernando (GFT))
  --
  --              07/12/2018 - Removido a alimentação do parâmetro par_apropjurmra de dentro do loop do
  --                           cursor cr_tdb60 pois estava gerando juros de mora 60 erroneamente.
  --
  -- ......................................................................................................
  vr_index PLS_INTEGER;

    CURSOR cr_tdb60 IS
      -- Todos os títulos abertos de um bordero com ao menos um titulo vencido a mais de 60 dias
      SELECT 
         SUM((x.dtvencto-x.dtvenmin60+1)*txdiaria*vltitulo) AS vljurrec, -- valor de juros de receita a ser apropriado
         cdcooper,
         cdagenci,
         inpessoa,
         SUM(vljura60) AS vljurmor                                       -- valor de juros de mora a ser apropriado
      FROM (
          SELECT UNIQUE
            tdb.vljura60,
            tdb.nrdconta,
            tdb.nrborder,
            tdb.dtlibbdt,
            tdb.dtvencto,
            (tdb.dtvencto-tdb.dtlibbdt) AS qtd_dias, -- quantidade de dias contabilizados para juros a apropriar
            tdb.vltitulo,
            tdv.dtvenmin,
            (tdv.dtvenmin+60) AS dtvenmin60,
            tdb.cdcooper,
            tdb.nrdocmto,
            tdb.nrcnvcob,
            tdb.nrdctabb,
            tdb.cdbandoc,
            tdb.nrtitulo,
            ((bdt.txmensal/100)/30) AS txdiaria,
            ass.cdagenci,
            ass.inpessoa
          FROM 
            craptdb tdb
            INNER JOIN (SELECT cdcooper
                              ,nrdconta
                              ,nrborder
                              ,MIN(dtvencto) dtvenmin
                        FROM craptdb 
                        WHERE (dtvencto+60) < par_dtrefere 
                          AND insittit = 4 
                          AND cdcooper=par_cdcooper 
                         GROUP BY cdcooper
                                ,nrdconta
                                ,nrborder
                       ) tdv ON tdb.cdcooper = tdv.cdcooper 
                            AND tdb.nrdconta = tdv.nrdconta 
                            AND tdb.nrborder = tdv.nrborder
            INNER JOIN crapbdt bdt ON bdt.nrborder=tdb.nrborder AND bdt.cdcooper=tdb.cdcooper AND bdt.flverbor=1 
            INNER JOIN crapass ass ON bdt.nrdconta=ass.nrdconta AND bdt.cdcooper=ass.cdcooper
          WHERE 1=1
            AND tdb.insittit = 4
            AND tdb.dtvencto >= (tdv.dtvenmin+60)
            ORDER BY tdb.cdcooper, tdb.nrdconta, tdb.nrtitulo
        ) x
        GROUP BY 
          cdcooper,
          inpessoa,
          cdagenci
        ORDER BY
          cdcooper,
          cdagenci;

    CURSOR cr_jur60 IS
      SELECT ris.inpessoa
            ,ris.cdagenci
            ,SUM(ris.vljura60) vljura60
        FROM crapris ris
       INNER JOIN crapass ass ON ris.nrdconta = ass.nrdconta AND 
                                 ris.cdcooper = ass.cdcooper
       WHERE ris.cdcooper = par_cdcooper
         AND ris.dtrefere = par_dtrefere
         AND ris.cdmodali = 301
         AND ris.inddocto = 1
         AND ris.vljura60 > 0
     GROUP BY ris.inpessoa
             ,ris.cdagenci;
    
  BEGIN
    par_totrendap.valorpf := 0;
    par_totrendap.valorpj := 0;
    FOR rw_tdb60 IN cr_tdb60 LOOP
      IF rw_tdb60.inpessoa = 1 THEN -- PF
        par_totrendap.valorpf := par_totrendap.valorpf + rw_tdb60.vljurrec; 
        IF par_rendaapropr.exists(rw_tdb60.cdagenci) THEN
          par_rendaapropr(rw_tdb60.cdagenci).valorpf := NVL(par_rendaapropr(rw_tdb60.cdagenci).valorpf,0) + rw_tdb60.vljurrec;
        ELSE
          par_rendaapropr(rw_tdb60.cdagenci).valorpf := rw_tdb60.vljurrec;
        END IF;
      ELSE -- PJ
        par_totrendap.valorpj := par_totrendap.valorpj + rw_tdb60.vljurrec; 
        par_totjurmra.valorpj := par_totjurmra.valorpj + rw_tdb60.vljurmor;
        IF par_rendaapropr.exists(rw_tdb60.cdagenci) THEN
          par_rendaapropr(rw_tdb60.cdagenci).valorpj := NVL(par_rendaapropr(rw_tdb60.cdagenci).valorpj,0) + rw_tdb60.vljurrec;
        ELSE
          par_rendaapropr(rw_tdb60.cdagenci).valorpj := rw_tdb60.vljurrec;
        END IF;
        END IF;
    END LOOP;
    
    par_totjurmra.valorpf := 0;
    par_totjurmra.valorpj := 0;
    FOR rw_jur60 IN cr_jur60 LOOP
      IF rw_jur60.inpessoa = 1 THEN -- PF
        par_totjurmra.valorpf := par_totjurmra.valorpf + rw_jur60.vljura60;
        IF par_apropjurmra.exists(rw_jur60.cdagenci) THEN
          par_apropjurmra(rw_jur60.cdagenci).valorpf := NVL(par_apropjurmra(rw_jur60.cdagenci).valorpf,0) + rw_jur60.vljura60;
        ELSE
          par_apropjurmra(rw_jur60.cdagenci).valorpf := rw_jur60.vljura60;
        END IF;
      ELSE -- PJ
        par_totjurmra.valorpj := par_totjurmra.valorpj + rw_jur60.vljura60;
        IF par_apropjurmra.exists(rw_jur60.cdagenci) THEN
          par_apropjurmra(rw_jur60.cdagenci).valorpj := NVL(par_apropjurmra(rw_jur60.cdagenci).valorpj,0) + rw_jur60.vljura60;
        ELSE
          par_apropjurmra(rw_jur60.cdagenci).valorpj := rw_jur60.vljura60;
        END IF;
      END IF;
    END LOOP;
    
    -- Remover o valor dos juros remuneratórios +60 do juros de mora +60 gravados no campo vljura60 na central de risco, pois no
    -- arquivo do risco K o juros remuneratório já é impresso separadamente.
    IF par_totrendap.valorpf <> 0 THEN
      par_totjurmra.valorpf := par_totjurmra.valorpf - par_totrendap.valorpf;

      vr_index := par_apropjurmra.first;
      WHILE vr_index IS NOT NULL LOOP
        IF par_rendaapropr.exists(vr_index) AND par_rendaapropr(vr_index).valorpf <> 0 THEN
          par_apropjurmra(vr_index).valorpf := par_apropjurmra(vr_index).valorpf - par_rendaapropr(vr_index).valorpf;
      END IF;

        vr_index := par_apropjurmra.next(vr_index);
    END LOOP;
    END IF;

    IF par_totrendap.valorpj <> 0 THEN
      par_totjurmra.valorpj := par_totjurmra.valorpj - par_totrendap.valorpj;

      vr_index := par_apropjurmra.first;
      WHILE vr_index IS NOT NULL LOOP
        IF par_rendaapropr.exists(vr_index) AND par_rendaapropr(vr_index).valorpj <> 0 THEN
          par_apropjurmra(vr_index).valorpj := par_apropjurmra(vr_index).valorpj - par_rendaapropr(vr_index).valorpj;
        END IF;

        vr_index := par_apropjurmra.next(vr_index);
      END LOOP;
    END IF;
  END pc_calcula_juros_60_tdb;
  
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
                                ,pr_finjuros6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa.
                                ,pr_juros38_df OUT typ_decimal_pfpj           --> 0038 -Data Futura Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                                ,pr_juros38_da OUT typ_decimal_pfpj           --> 0038 -Data Atual  Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                                ,pr_taxas37    OUT typ_decimal_pfpj           --> 0037 -Taxa sobre saldo em c/c negativo
                                ,pr_juros57    OUT typ_decimal_pfpj           --> 0057 -Juros sobre saque de deposito bloqueado
                                ,pr_tabvljuros38_df IN OUT typ_arr_decimal_pfpj    --> Data Futura 0038 – Juros sobre limite de credito    - Por PA.
                                ,pr_tabvljuros38_da IN OUT typ_arr_decimal_pfpj    --> Data Atual  0038 – Juros sobre limite de credito    - Por PA.
                                ,pr_tabvltaxas37    IN OUT typ_arr_decimal_pfpj    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                                ,pr_tabvljuros57    IN OUT typ_arr_decimal_pfpj    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.
                                ) IS
  -- ..........................................................................
  --
  --  Programa : pc_calcula_juros_60k          Antigo: ????????????

  --  Sistema  : Rotinas genericas para RISCO
  --  Sigla    : RISC
  --  Autor    : ?????
  --  Data     : ?????                         Ultima atualizacao: 26/06/2018
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
  --               18/04/2018 - P450 - Ajuste para buscar valores de juros,taxas,mora etc... de contas
  --                            correntes negativas e caso possuir com limites de credito estourado
  --                            Projeto Contrataçao de Credito (Rangel Decker) AMCom
  --
  --               26/06/2018 - P450 - Ajuste calculo Juros60 (Rangel/AMcom)
  --
  --               25/07/2019 - P450 - Ajuste para buscar a data que é passada no parâmetro (Heckmann - AMcom)
  -- ......................................................................................................


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

    vr_vljurctr          NUMBER;
    vr_crapvri_jur_found BOOLEAN := FALSE;
    vr_diascalc          INTEGER := 0;
    contador             INTEGER := 0;
    vr_fleprces          INTEGER := 0;

    vr_vlsld59d NUMBER;
    vr_vlju6037 NUMBER;
    vr_vlju6038 NUMBER;
    vr_vlju6057 NUMBER;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Busca conta corrente em ADP saldo negativo e se houver limite estourado (Rangel Decker AMcom)
    CURSOR cr_conta_negativa (pr_cdcooper IN crapris.cdcooper%TYPE) IS
      SELECT  ris.nrdconta
           ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa /* Tratamento para Pessoa Administrativa considerar com PJ*/
           ,ass.cdagenci
           ,ris.qtdiaatr
           ,ris.vldivida
           ,ris.dtinictr
           ,sld.vljuresp -- Valor provisionado do histórico 38 (DF)
      FROM crapass ass
          ,crapris ris
          ,crapsld sld
      WHERE ris.cdcooper = ass.cdcooper
       AND ris.nrdconta  = ass.nrdconta
       AND ris.cdcooper  = pr_cdcooper
       AND ris.dtrefere  = par_dtrefere
       AND ris.cdmodali =101
       AND ris.qtdiaatr >=60
       AND ris.vljura60 >  0
        AND ris.innivris < 10 --> Apenas operações que ainda não estejam em prejuizo
       AND sld.cdcooper = ass.cdcooper
       AND sld.nrdconta = ass.nrdconta;
  BEGIN
    pr_vlrjuros.valorpf  := 0;
    pr_vlrjuros.valorpj  := 0;
    pr_vlrjuros2.valorpf := 0;
    pr_vlrjuros2.valorpj := 0;

    pr_finjuros.valorpf  := 0;
    pr_finjuros.valorpj  := 0;
    pr_finjuros2.valorpf := 0;
    pr_finjuros2.valorpj := 0;

    --Conta Corrente
    pr_juros38_df.valorpf:=0;
    pr_juros38_df.valorpj:=0;

    pr_juros38_da.valorpf:=0;
    pr_juros38_da.valorpj:=0;

    pr_taxas37.valorpf:=0;
    pr_taxas37.valorpj:=0;

    pr_juros57.valorpf:=0;
    pr_juros57.valorpj:=0;




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

     --Soma de valor juros e taxas de contas correntes inadimplentes (Rangel Decker AMcom)
    IF par_cdmodali = 999 THEN
        FOR  rw_conta_negativa in cr_conta_negativa(pr_cdcooper =>par_cdcooper) LOOP
          -- Chama procedure de cálculo dos juros +60
          TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => par_cdcooper
                                                         , pr_nrdconta => rw_conta_negativa.nrdconta
                                                         , pr_dtlimite => par_dtrefere 
                                                         , pr_tppesqui => 2 -- P450 - Pegar a data que é passada no parâmetro (Heckmann - AMcom)
                                                         , pr_vlsld59d => vr_vlsld59d
                                                         , pr_vlju6037 => vr_vlju6037
                                                         , pr_vlju6038 => vr_vlju6038
                                                         , pr_vlju6057 => vr_vlju6057
                                                         , pr_cdcritic => vr_cdcritic
                                                         , pr_dscritic => vr_dscritic);

           IF rw_conta_negativa.vljuresp > 0 THEN  -- 38 DF
             IF rw_conta_negativa.inpessoa = 1 THEN
							  pr_juros38_df.valorpf := pr_juros38_df.valorpf + rw_conta_negativa.vljuresp;

								IF pr_tabvljuros38_df.exists(rw_conta_negativa.cdagenci) THEN
									 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpf := NVL(pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpf,0) + rw_conta_negativa.vljuresp;
           ELSE
									 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpf := rw_conta_negativa.vljuresp;
           END IF;
                        ELSE
								pr_juros38_df.valorpj := pr_juros38_df.valorpj + rw_conta_negativa.vljuresp;

								IF pr_tabvljuros38_df.exists(rw_conta_negativa.cdagenci) THEN
									 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj,0) + rw_conta_negativa.vljuresp;
								ELSE
									 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj := rw_conta_negativa.vljuresp;
                        END IF;
                    END IF;
					 END IF;

					 IF vr_vlju6037 > 0 THEN  -- 37 DA
						 IF rw_conta_negativa.inpessoa = 1 THEN
						    pr_taxas37.valorpf := pr_taxas37.valorpf + vr_vlju6037;

								 IF pr_tabvltaxas37.exists(   rw_conta_negativa.cdagenci) THEN
										pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpf := NVL(pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpf,0) +  vr_vlju6037;
                        ELSE
										pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpf := vr_vlju6037;
                        END IF;
							ELSE
								 pr_taxas37.valorpj := pr_taxas37.valorpj + vr_vlju6037;

								 IF pr_tabvltaxas37.exists(rw_conta_negativa.cdagenci) THEN
										pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpj,0) +  vr_vlju6037;
								 ELSE
										pr_tabvltaxas37(rw_conta_negativa.cdagenci).valorpj := vr_vlju6037;
                    END IF;
                       END IF;
                    END IF;

					 IF vr_vlju6038 > 0 THEN  -- 38 DA
						  IF rw_conta_negativa.inpessoa = 1 THEN
						    pr_juros38_da.valorpf := pr_juros38_da.valorpf + vr_vlju6038;

								 IF pr_tabvljuros38_da.exists(rw_conta_negativa.cdagenci) THEN
										pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpf := NVL(pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpf,0) +  vr_vlju6038;
                       ELSE
										pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpf := vr_vlju6038;
                       END IF;
							ELSE
								 pr_juros38_da.valorpj := pr_juros38_da.valorpj + vr_vlju6038;

								 IF pr_tabvljuros38_da.exists(rw_conta_negativa.cdagenci) THEN
										pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj,0) +  vr_vlju6038;
								 ELSE
										pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj := vr_vlju6038;
                    END IF;
                END IF;
					 END IF;

					 IF vr_vlju6057 > 0 THEN  -- 57 DA
						  IF rw_conta_negativa.inpessoa = 1 THEN
						    pr_juros57.valorpf := pr_juros57.valorpf + vr_vlju6057;

								 IF pr_tabvljuros57.exists(rw_conta_negativa.cdagenci) THEN
										pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpf := NVL(pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpf,0) +  vr_vlju6057;
                        ELSE
										pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpf := vr_vlju6057;
                        END IF;
							ELSE
								 pr_juros57.valorpj := pr_juros57.valorpj + vr_vlju6057;

								 IF pr_tabvljuros57.exists(rw_conta_negativa.cdagenci) THEN
										pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpj,0) +  vr_vlju6057;
								 ELSE
										pr_tabvljuros57(rw_conta_negativa.cdagenci).valorpj := vr_vlju6057;
                    END IF;
                        END IF;
                    END IF;
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
  Data    : Dezembro/2014                       Ultima Alteracao: 21/11/2018

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

     21/03/2018 - P450 - Ajuste para exibir valores de juros,taxas,mora etc... de contas
                  correntes negativas e caso possuir com limites de credito estourado (Rangel Decker) AMcom

     02/10/2018 - Ajuste para acrescentar juros60 no valor da divida do ADP.
                  PRJ450 - Regulatorio(Odirlei-AMcom)
                  
     08/10/2018 - Ajuste no loop cr_crapris_60, para desprezar os valores que contas que ja estao em prejuizo.
                  PRJ450 - Regulatorio(Odirlei-AMcom)
                  
     21/11/2018 - Correção das contas envolvendo os juros +60, com a intensão de segregarmos as rendas a apropriar referente a operação 
                  normal das rendas não reconhecidas por atraso superior a 60 dias. Pessoa Juricida de 5591 para 5344 e Pessoa fisica   
                  de 5590   para 5343 (Paulo Penteado GFT)
                  
     22/11/2018 - Alterado contas contabies do renda a apropriar conforme solicitação da area contabil.
                  PRJ450 - Regulatorio(Odirlei-AMcom) 
             
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
        SELECT ris.inpessoa
               ,ris.innivris
               ,SUM(ris.vljura60) vljura60
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper --Cooperativa atual
           AND ris.dtrefere = pr_dtrefere --Data atual da cooperativa
           AND ris.inddocto = 1           --Contratos ativos
           AND ris.cdorigem IN (1,3       --Empréstimos / Financiamentos
                               ,4,5)      --Desconto de Titulos
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
    TYPE typ_tab_descricao IS TABLE OF typ_reg_contas INDEX BY VARCHAR2(45);

    -- Instancia e indexa por Debito/Credito
    TYPE typ_tab_debcre IS TABLE OF typ_tab_descricao INDEX BY VARCHAR2(1);

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_pessoa IS TABLE OF typ_tab_debcre INDEX BY VARCHAR2(1);

     -- Informações por tipo de produto
    TYPE typ_tab_produto IS TABLE OF typ_tab_pessoa INDEX BY VARCHAR2(3);
    vr_tab_contas        typ_tab_produto;

    -- Armazenar as informações principais do microcredito
    TYPE typ_tab_microtrpre IS TABLE OF typ_decimal INDEX BY VARCHAR2(53);
    TYPE typ_tab_dsorgrec   IS TABLE OF typ_tab_microtrpre INDEX BY VARCHAR2(4);
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

    vr_juros38df_calc    typ_decimal_pfpj;
    vr_juros38da_calc    typ_decimal_pfpj;
    vr_taxas37_calc      typ_decimal_pfpj;
    vr_juros57_calc      typ_decimal_pfpj;

    vr_juros38df          typ_decimal_pfpj;
    vr_juros38da          typ_decimal_pfpj;
    vr_taxas37            typ_decimal_pfpj;
    vr_juros57            typ_decimal_pfpj;

    --Somatorio das Agencias
    vr_tabvltaxas37        typ_arr_decimal_pfpj;
    vr_tabvljuros57        typ_arr_decimal_pfpj;
    vr_tabvljuros38df      typ_arr_decimal_pfpj;
    vr_tabvljuros38da      typ_arr_decimal_pfpj;

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
    vr_vlag1724_bdt      typ_arr_decimal_pfpj;


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
    vr_rel1724_bdt       typ_decimal_pfpj;

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
    vr_contador1 VARCHAR(53);
    vr_arrchave2 VARCHAR(53);
    vr_flgmicro  BOOLEAN ;

    vr_totrendap     typ_decimal_pfpj;
    vr_totjurmra     typ_decimal_pfpj;
    vr_rendaapropr   typ_arr_decimal_pfpj ; --RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
    vr_apropjurmra   typ_arr_decimal_pfpj ; --APROPR. JUROS DE MORA DESCONTO DE TITULO
    
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

    -- Valor juro +60
    vr_valjur60          NUMBER := 0;
    vr_dsjur60           VARCHAR2(10) := 'JUROS 60 ';
    vr_jurchave2         VARCHAR(53);
    
    vr_flverbor crapbdt.flverbor%TYPE;

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

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO ABN').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO ABN').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO ABN').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO ABN').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BB').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BB').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 1681;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES').nrdconta := 1681;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1687;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1687;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1688;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1688;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 1678;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 1678;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 1682;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO BRDE').nrdconta := 1682;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO BRDE').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 1683;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 1683;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 1685;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO CAIXA').nrdconta := 1685;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO CAIXA').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO PNMPO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO PNMPO DIM').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO DIM').nrdconta := 1667;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 1681;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('MICROCREDITO BNDES').nrdconta := 1681;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('MICROCREDITO BNDES').nrdconta := 1667;

    -- MICROCREDITO +60
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO DIM').nrdconta := 1676;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO DIM').nrdconta := 1676;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO DIM').nrdconta := 1686;
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1677;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1681;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES').nrdconta := 1681;
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1678;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1678;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1682;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BRDE').nrdconta := 1682;
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1683;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1683;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1685;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO CAIXA').nrdconta := 1685;
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1684;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1686;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO DIM').nrdconta := 1686;   
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1687;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1662;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1687;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pf)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1688;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_deb)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1667;
    vr_tab_contas(vr_price_pre)(vr_price_pj)(vr_price_cre)('JUROS 60 MICROCREDITO PNMPO BNDES AILOS').nrdconta := 1688;
    
    
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
    vr_rel1724_bdt.valorpf    := 0;
    vr_rel1724_bdt.valorpj    := 0;

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
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';
        
        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_pre||vr_price_pj;
        vr_arrchave1 := vr_price_pre||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';
        
        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pf;
        vr_arrchave1 := vr_price_atr||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';
        
        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pj;
        vr_arrchave1 := vr_price_atr||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';
        
        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';
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
      vr_valjur60 := 0;

      --> Necessario acrescentar valor da do juros + 60 no ADP, 
      -- visto que este valor não é apresentado nos vencimentos
      IF rw_crapris.cdorigem = 1 THEN
        vr_vldivida := vr_vldivida + nvl(rw_crapris.vljura60,0);
      END IF;
      
      vr_valjur60 := nvl(rw_crapris.vljura60,0);
      
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

        --> para contratos de ADP em prejuizo não deve reconhecer a divida
        IF rw_crapris.cdmodali = 0101 AND 
           rw_crapris.innivris = 10   THEN           
          vr_vldivida := 0;   
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

        --> P450 - Se a modalidade é 0101, soma o valor dos juros +60 aos saldos devedores,
				--> pois a CRAPVRI é alimentada para esta modalidade somente com o valor do
				--> aldo devedor até 59 dias de atraso (sem os juros +60)
        
        -- Contabilizar risco - prejuizo --
        IF vr_rel_vldivida.exists(vr_contador) THEN
          vr_rel_vldivida(vr_contador).valor := nvl(vr_rel_vldivida(vr_contador).valor, 0) + rw_crapvri.vldivida +
                                                (CASE WHEN rw_crapris.cdmodali = 101 
                                                     THEN rw_crapris.vljura60
                                                     ELSE 0 END);
        ELSE
          vr_rel_vldivida(vr_contador).valor := rw_crapvri.vldivida +
                                                (CASE WHEN rw_crapris.cdmodali = 101 
                                                     THEN rw_crapris.vljura60
                                                     ELSE 0 END);
        END IF;

        -- Verifica se é prejuizo para Contabilidade
        IF rw_crapvri.cdvencto IN (310,320,330) THEN
          CONTINUE; -- Desprezar prejuizo - para Contabilidade
        END IF;

        --> P450 - Se a modalidade é 0101, soma o valor dos juros +60 aos saldos devedores,
				--> pois a CRAPVRI é alimentada para esta modalidade somente com o valor do
				--> aldo devedor até 59 dias de atraso (sem os juros +60)
				 
        IF vr_vldevedo.exists(vr_contador) THEN
          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapvri.vldivida +
                                      (CASE WHEN rw_crapris.cdmodali = 101 
                                           THEN rw_crapris.vljura60
                                           ELSE 0 END);
        ELSE
          vr_vldevedo(vr_contador) := rw_crapvri.vldivida +
                                      (CASE WHEN rw_crapris.cdmodali = 101 
                                           THEN rw_crapris.vljura60
                                           ELSE 0 END);
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
              IF rw_craplcr.dsorgrec <> 'MICROCREDITO PNMPO CAIXA' OR pr_cdcooper <> 3 THEN
               vr_arrchave1 := vr_price_atr||vr_price_pf;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
                
               --Acumulador de TR Pessoa fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               -- Acumulador de TR PF +60
               vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
               vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;
            END IF;
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
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));

               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               -- Acumulador de TR PF +60
               vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
               vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;
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
              IF rw_craplcr.dsorgrec <> 'MICROCREDITO PNMPO CAIXA' OR pr_cdcooper <> 3 THEN
               vr_arrchave1 := vr_price_atr||vr_price_pj;
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               
               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               -- Acumulador de TR PF +60
               vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
               vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;
            END IF;
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
               vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
               
               -- Acumulador PRE Pessoa Fisica
               vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
               vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               -- Acumulador de TR PF +60
               vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
               vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;

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
        vr_flverbor := 0;
        IF rw_crapris.cdorigem = 5 THEN
          BEGIN
            SELECT bdt.flverbor
            INTO   vr_flverbor
            FROM   crapbdt bdt
            WHERE  bdt.nrdconta = rw_crapris.nrdconta
            AND    bdt.nrborder = rw_crapris.nrctremp
            AND    bdt.cdcooper = rw_crapris.cdcooper;
          EXCEPTION
            WHEN OTHERS THEN
              vr_flverbor := 0;
          END;
        END IF;
        
        IF vr_flverbor = 1 THEN
        -- Se pessoa física
          IF rw_crapris.inpessoa = 1 THEN
            vr_rel1724_bdt.valorpf   := NVL(vr_rel1724_bdt.valorpf,0)   + vr_vlpreatr;

            IF vr_vlag1724_bdt.exists(rw_crapris.cdagenci) THEN
              vr_vlag1724_bdt(rw_crapris.cdagenci).valorpf := NVL(vr_vlag1724_bdt(rw_crapris.cdagenci).valorpf,0) + vr_vlpreatr;
            ELSE
              vr_vlag1724_bdt(rw_crapris.cdagenci).valorpf := vr_vlpreatr;
            END IF;

          ELSE
            vr_rel1724_bdt.valorpj   := NVL(vr_rel1724_bdt.valorpj,0)   + vr_vlpreatr;

            IF vr_vlag1724_bdt.exists(rw_crapris.cdagenci) THEN
              vr_vlag1724_bdt(rw_crapris.cdagenci).valorpj := NVL(vr_vlag1724_bdt(rw_crapris.cdagenci).valorpj,0) + vr_vlpreatr;
            ELSE
              vr_vlag1724_bdt(rw_crapris.cdagenci).valorpj := vr_vlpreatr;
            END IF;
          END IF;          
        ELSE
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

    vr_juros38df.valorpf  :=0;
    vr_juros38df.valorpj  :=0;
    vr_juros38da.valorpf  :=0;
    vr_juros38da.valorpj  :=0;
    vr_taxas37.valorpf    :=0;
    vr_taxas37.valorpj    :=0;
    vr_juros57.valorpf    :=0;
    vr_juros57.valorpj    :=0;



    pc_calcula_juros_60k ( par_cdcooper => pr_cdcooper
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
                          ,pr_finjuros6 => vr_finjur_calc6   --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_juros38_df => vr_juros38df_calc   --> Data Futura 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_juros38_da => vr_juros38da_calc   --> Data Atual 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_taxas37   => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                          ,pr_juros57    => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                          ,pr_tabvljuros38_df => vr_tabvljuros38df -->Data Futura 38 – Juros sobre limite de credito - Por PA.
                          ,pr_tabvljuros38_da => vr_tabvljuros38da --> Data Atual  0038 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvltaxas37 => vr_tabvltaxas37      --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                          ,pr_tabvljuros57 => vr_tabvljuros57);    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.

                         
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

    pc_calcula_juros_60k( par_cdcooper => pr_cdcooper
                         ,par_dtrefere => vr_dtrefere
                         ,par_cdmodali => 499
                         ,par_dtinicio => vr_dtinicio
                         ,pr_tabvljur1 => vr_pacvljur_1       --> TR  - Modalidade 299 - Por PA.
                         ,pr_tabvljur2 => vr_pacvljur_2       --> TR  - Modalidade 499 - Por PA.
                         ,pr_tabvljur3 => vr_pacvljur_3       --> PP  - Modalidade 299 - Por PA.
                         ,pr_tabvljur4 => vr_pacvljur_4       --> PP  - Modalidade 499 - Por PA.
                         ,pr_tabvljur5 => vr_pacvljur_5       --> PP  – Cessao - Por PA.
                         ,pr_tabvljur6 => vr_pacvljur_6       --> POS - Modalidade 299 - Por PA.
                         ,pr_tabvljur7 => vr_pacvljur_7       --> POS - Modalidade 499 - Por PA.
                         ,pr_vlrjuros  => vr_vldjur_calc      --> TR  - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros  => vr_finjur_calc      --> TR  - Modalidade 499 - Por Tipo pessoa.
                         ,pr_vlrjuros2 => vr_vldjur_calc2     --> PP  - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros2 => vr_finjur_calc2     --> PP  - Modalidade 499 - Por Tipo pessoa.
                         ,pr_vlrjuros3 => vr_vldjur_calc3     --> PP  – Cessao - Por Tipo pessoa.
                         ,pr_vlrjuros6 => vr_vldjur_calc6     --> POS - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros6 => vr_finjur_calc6     --> POS - Modalidade 499 - Por Tipo pessoa.
                         ,pr_juros38_df  => vr_juros38df_calc  --> Data Futura 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                         ,pr_juros38_da  => vr_juros38da_calc  --> Data Atual  0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                         ,pr_taxas37     => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                         ,pr_juros57     => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                         ,pr_tabvljuros38_df => vr_tabvljuros38df -->Data Futura 38 – Juros sobre limite de credito - Por PA.
                         ,pr_tabvljuros38_da => vr_tabvljuros38da --> Data Atual  0038 – Juros sobre limite de credito    - Por PA.
                         ,pr_tabvltaxas37 => vr_tabvltaxas37    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                         ,pr_tabvljuros57 => vr_tabvljuros57);    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.

                         
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
                          ,pr_juros38_df   => vr_juros38df_calc --> Data Futura 0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_juros38_da   => vr_juros38da_calc --> Data Atual  0038 -Juros sobre limite de credito utilizado ou (crps249) provisao juros ch. especial
                          ,pr_taxas37   => vr_taxas37_calc      --> 0037 -Taxa sobre saldo em c/c negativo
                          ,pr_juros57    => vr_juros57_calc     --> 0057 -Juros sobre saque de deposito bloqueado
                          ,pr_tabvljuros38_df => vr_tabvljuros38df  --> 0038 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvljuros38_da => vr_tabvljuros38da  --> 0038 – Juros sobre limite de credito    - Por PA.
                          ,pr_tabvltaxas37 => vr_tabvltaxas37    --> 37 – Taxa sobre saldo em c/c negativo - Por PA.
                          ,pr_tabvljuros57 => vr_tabvljuros57);    --> 57 – Juros sobre saque de deposito bloqueado- Por PA.

    -- Acumula retornos da pc_calcula_juros_60k
    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;

    --Cessao credito
    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

  --Conta Corrente
    vr_juros38df.valorpj := vr_juros38df.valorpj + vr_juros38df_calc.valorpj;
    vr_juros38df.valorpf := vr_juros38df.valorpf + vr_juros38df_calc.valorpf;
    vr_juros38da.valorpj := vr_juros38da.valorpj + vr_juros38da_calc.valorpj;
    vr_juros38da.valorpf := vr_juros38da.valorpf + vr_juros38da_calc.valorpf;
    vr_taxas37.valorpj := vr_taxas37.valorpj + vr_taxas37_calc.valorpj;
    vr_taxas37.valorpf := vr_taxas37.valorpf + vr_taxas37_calc.valorpf;
    vr_juros57.valorpj := vr_juros57.valorpj + vr_juros57_calc.valorpj;
    vr_juros57.valorpf := vr_juros57.valorpf + vr_juros57_calc.valorpf;

    -- Calcula valores dos descontos de titulos vencidos
    pc_calcula_juros_60_tdb( par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_totrendap => vr_totrendap
                          ,par_totjurmra => vr_totjurmra
                          ,par_rendaapropr => vr_rendaapropr --> RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
                          ,par_apropjurmra => vr_apropjurmra     --> APROPR. JUROS DE MORA DESCONTO DE TITULO
                          );
    
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
    C - 1621
    Histórico:1434 - Ajuste de saldo de (risco) RECEITAS A APROPRIAR

    No início do mes seguinte:
    D - 1621
    C - 7116
    *************************/


    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA FISICA  DA

    IF vr_juros38da.valorpf <> 0   THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7014,1611,' ||
                      TRIM(to_char(vr_juros38da.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_tabvljuros38da.exists(vr_contador)
             AND vr_tabvljuros38da(vr_contador).valorpf <> 0   THEN
              vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                             TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
          END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_tabvljuros38da.exists(vr_contador)
          AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                           TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
          END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7014,' ||
                       TRIM(to_char(vr_juros38da.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DA
    IF vr_juros38da.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7015,1611,' ||
                      TRIM(to_char(vr_juros38da.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;


        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7015,' ||
                       TRIM(to_char(vr_juros38da.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';
         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

   END IF;


    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA FISICA DF
    IF vr_juros38df.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7014,1802,' ||
                      TRIM(to_char(vr_juros38df.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

     /*    FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;*/

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1802,7014,' ||
                       TRIM(to_char(vr_juros38df.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;
/*
         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;
*/
   END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DF
    IF vr_juros38df.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7015,1802,' ||
                      TRIM(to_char(vr_juros38df.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

      /*   FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;*/


        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1802,7015,' ||
                       TRIM(to_char(vr_juros38df.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';
         -- Gravar Linha
         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;

/*         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));
             -- Gravar Linha
             pc_gravar_linha(vr_linhadet);
           END IF;
         END LOOP;*/

   END IF;

    --0037 -TAXA SOBRE SALDO EM C/C NEGATIVO PESSOA FISICA
    IF vr_taxas37.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7012,1611,' ||
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
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7012,' ||
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
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7013,1611,' ||
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
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7013,' ||
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
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7012,1611,' ||
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
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7012,' ||
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
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7013,1611,' ||
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
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7013,' ||
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


    -- EMPRESTIMOS EM ATRASO PESSOA FISICA
    IF vr_vldjuros.valorpf <> 0 THEN
      -- Monta a linha de cabeçalho
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7010,1621,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1621,7010,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7011,1621,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1621,7011,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7026,1662,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1662,7026,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7027,1662,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1662,7027,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7016,1664,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7016,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7017,1664,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7017,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7028,1667,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7028,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7029,1667,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7029,' ||
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

    -- [Projeto 403] - Juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA 
    IF vr_totrendap.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7152,1630,' ||
                     TRIM(to_char(vr_totrendap.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA ."';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7152,' ||
                     TRIM(to_char(vr_totrendap.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;
    
    -- [Projeto 403] - Juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA
    IF vr_totrendap.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7153,1630,' ||
                     TRIM(to_char(vr_totrendap.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA ."';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7153,' ||
                     TRIM(to_char(vr_totrendap.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;
    
    -- [Projeto 403] - Juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA 
    IF vr_totjurmra.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7154,1630,' ||
                     TRIM(to_char(vr_totjurmra.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA."';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7154,' ||
                     TRIM(to_char(vr_totjurmra.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;
    
    -- [Projeto 403] - Juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA
    IF vr_totjurmra.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7155,1630,' ||
                     TRIM(to_char(vr_totjurmra.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7155,' ||
                     TRIM(to_char(vr_totjurmra.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;
    END IF;

    -- CESSAO EMPRESTIMO EM ATRASO - PESSOA FISICA
    IF vr_vldjuros3.valorpf <> 0 THEN
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1664,1766,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1766,1664,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1664,1766,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1766,1664,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7591,1603,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7591,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7592,1603,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7592,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7561,1607,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7561,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7562,1607,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7562,' ||
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
                       ',1432,4451,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',1622,4112,' ||
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
                       ',4451,1432,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA FISICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4112,1622,' ||
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
                       ',1432,4451,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                       ',1622,4112,' ||
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
                       ',4451,1432,' ||
                       TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) SALDO CREDITO ROTATIVO UTILIZADO PESSOA JURIDICA"';

      ELSE
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                       ',4112,1622,' ||
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
                       ',8447,1722,' ||
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
                       ',1722,8447,' ||
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
                       ',8448,1722,' ||
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
                       ',1722,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1613,1611,' ||
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
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,1613,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1613,1611,' ||
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
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,1613,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1611,' ||
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
                     vr_contacon || ',1611,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1611,' ||
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
                     vr_contacon || ',1611,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1722,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1722,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1722,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1722,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1731,' ||
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
                      TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1731,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1731,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1731,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,5584,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5584,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1733,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1733,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1733,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1733,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1725,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1725,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1725,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1725,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1617,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1617,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1617,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1617,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1615,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1615,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1615,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1615,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1725,1760,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1760,1725,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',1725,1760,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1760,1725,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1734,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1734,8448,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1724,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1724,8447,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1724,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1724,8448,' ||
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


    -- Ajuste Provisao CL - Titulos Descontados
    -- AJUSTE PROVISAO TIT.DESCONTADOS - PESSOA FISICA / PF
    IF vr_rel1724_bdt.valorpf <> 0 THEN

      vr_vllanmto := vr_rel1724_bdt.valorpf;
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8447,1763,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO DESCONTO TITULO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1763,8447,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) REVERSÃO PROVISAO DESCONTO TITULO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpf,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;
    
    -- Ajuste Provisao CL - Titulos Descontados
    -- AJUSTE PROVISAO TIT.DESCONTADOS - PESSOA JURIDICA / PJ
    IF vr_rel1724_bdt.valorpj <> 0 THEN

      vr_vllanmto := vr_rel1724_bdt.valorpj;
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8448,1763,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO DESCONTO TITULO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1763,8448,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) REVERSÃO PROVISAO DESCONTO TITULO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpj,'99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1724_bdt.exists(vr_contador)
        AND vr_vlag1724_bdt(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1724_bdt(vr_contador).valorpj,'99999999999990.00'));
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
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
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
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
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
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
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
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
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
    vr_nrdcctab(17):= '8442.5584';  -- Emprestimos Pessoas - Origem 3
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
                                      
       
       --> Para o Nivel = 10 que são referente as contas em prejuizo o valores de juros +60 não deve ser enviado
       --> por ja ser contabilizado como prejuizo 
       IF rw_crapris_60.innivris = 10 THEN
         continue;
       END IF; 
                                      
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
                                          ,pr_tab_central_risco OUT RISC0001.typ_reg_central_risco --> Informações da Central de Risco
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
                             ,pr_tab_estouros OUT RISC0001.typ_tab_estouros --> Informações de estouro na conta
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
        SELECT crapneg.cdhisest
              ,crapneg.cdobserv
              ,crapneg.nrseqdig
              ,crapneg.dtiniest
              ,crapneg.dtfimest
              ,crapneg.qtdiaest
              ,crapneg.vlestour
              ,crapneg.nrdctabb
              ,crapneg.nrdocmto
              ,crapneg.vllimcre
              ,crapneg.cdtctant
              ,crapneg.cdtctatu
              ,crapass.inpessoa
          FROM crapneg
              ,crapass
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.nrdconta = pr_nrdconta
           AND crapass.cdcooper = crapneg.cdcooper
           AND crapass.nrdconta = crapneg.nrdconta;
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
      CURSOR cr_tipo_conta
                       IS
        SELECT tipcta.dstipo_conta dstipcta,
               tipcta.inpessoa inpessoa,
               tipcta.cdtipo_conta cdtipcta
          FROM tbcc_tipo_conta tipcta;
    BEGIN

      -- popular temp table de contas se estiver vazia
      IF vr_tab_tipo_conta.COUNT = 0 THEN

        FOR rw_tipo_conta IN cr_tipo_conta LOOP
          -- definir index
          vr_idx := rw_tipo_conta.inpessoa||lpad(rw_tipo_conta.cdtipcta,5,'0');
          vr_tab_tipo_conta(vr_idx).inpessoa := rw_tipo_conta.inpessoa;
          vr_tab_tipo_conta(vr_idx).cdtipcta := rw_tipo_conta.cdtipcta;
          vr_tab_tipo_conta(vr_idx).dstipcta := rw_tipo_conta.dstipcta;
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
          vr_idx := lpad(rw_crapneg.inpessoa,10,'0')||lpad(rw_crapneg.cdtctant,5,'0');
          -- Se não encontrar
          IF NOT vr_tab_tipo_conta.exists(vr_idx) THEN
            vr_dscodant := rw_crapneg.cdtctant;
          ELSE
            -- Usamos a descrição dele
            vr_dscodant := vr_tab_tipo_conta(vr_idx).dstipcta;
          END IF;

          -- Buscaremos o cadastro de tipo de conta para a atual
          vr_idx := lpad(pr_cdcooper,10,'0')||lpad(rw_crapneg.cdtctatu,5,'0');
          -- Se não encontrar
          IF NOT vr_tab_tipo_conta.exists(vr_idx) THEN
            vr_dscodatu := rw_crapneg.cdtctatu;
          ELSE
            -- Usamos a descrição dele
            vr_dscodatu := vr_tab_tipo_conta(vr_idx).dstipcta;
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


  PROCEDURE pc_gera_arq_3026(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                            ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE --> Data de referência
                            --,pr_retorno   OUT xmltype              --> XML de retorno
                            ,pr_retxml    OUT CLOB                 --> Arquivo de retorno do XML
                            ,pr_dscritic  OUT VARCHAR2) IS         --> Texto de erro/critica encontrada
  BEGIN
  /* .............................................................................

       Programa: pc_gera_arq_3026
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Fabio Adriano - AMcom
       Data    : Fevereiro/2019                       Ultima atualizacao: 01/02/2019

       Dados referentes ao programa:

       Frequencia: sempre que for chamado
       Objetivo  : gerar arquivo 3026 - Risco de Credito

       Alteracoes :
                     15/02/2019 - prj450 - Alteração no arquivo 3026 uso do cpfcnpj_base no participante
                                  do grupo (Fabio Adriano - AMcom)

     .............................................................................*/

  DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'RISCO';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Exceções
      vr_exc_erro EXCEPTION;

      -- Variaveis gerais
      vr_xml xmltype; -- XML que sera enviado
      vr_retxml xmltype;
      vr_contador      NUMBER := 0;
      vr_nrcontgrup    NUMBER := 0;
      vr_nrcontintgrup NUMBER := 0;

      vr_dtbase        VARCHAR2(7);
      cnpjinst         VARCHAR2(8);
      vr_mes           char(2);
      vr_ano           char(4);
      vr_dtbase_cnpj   VARCHAR2(50);

      -- Variaveis para os arquivos
      vr_nom_direto    VARCHAR2(100);
      vr_nom_dirsal    VARCHAR2(100);
      vr_nom_dirmic    VARCHAR2(100);
      vr_nmarqsai      VARCHAR2(50); -- Nome do arquivo 3026

      -- Valor Minimo de divida para geração do arquivo 3026
      vr_vlmin_3026    NUMBER := 0;

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.dsnomscr
              ,cop.dsemascr
              ,cop.dstelscr
              ,cop.nrcepend
              ,cop.cdufdcop
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop   cr_crapcop%ROWTYPE;


      --Cursor principal central de risco
      CURSOR cr_crapris_prin(pr_cdcooper IN NUMBER
                            ,pr_dtrefere DATE) IS
         SELECT distinct
                  r.cdcooper
                 ,r.nrdconta
                 ,r.nrdgrupo
                 ,r.inpessoa
          FROM crapris r
          WHERE r.cdcooper = pr_cdcooper
           AND  r.dtrefere = pr_dtrefere
           AND  r.nrdgrupo > 0
           AND  r.vldivida > vr_vlmin_3026;
      rw_crapris_prin   cr_crapris_prin%ROWTYPE;


      -- Cursor para busca das contas do grupo economico
      CURSOR cr_grupint (pr_nrdgrupo INTEGER)IS
        SELECT int.tppessoa inpessoa
              ,int.nrdconta
              ,int.Nrcpfcgc
              ,CASE WHEN int.tppessoa = 1                      then int.nrcpfcgc
                    WHEN int.tppessoa = 2 and int.nrcpfcgc > 0 then to_number(substr(to_char(int.nrcpfcgc,'FM00000000000000'),1,8))
                    ELSE NULL
               END AS nrcpfcnpj_base
          FROM tbcc_grupo_economico_integ INT
              ,tbcc_grupo_economico p
              ,crapass ass
         WHERE int.dtexclusao IS NULL
           AND int.cdcooper = pr_cdcooper
           AND int.idgrupo  = p.idgrupo
           --AND int.tppessoa = 1  -- Somente PF
           AND int.idgrupo  = pr_nrdgrupo
           --AND int.nrdconta <> pr_nrdconta -- Desconsiderar a propria conta, pois ela ja foi analisada
           AND int.cdcooper = ass.cdcooper
           AND int.nrdconta = ass.nrdconta
         UNION
        SELECT ass.inpessoa
              ,pai.nrdconta
              ,ass.nrcpfcgc
              ,ass.nrcpfcnpj_base
          FROM tbcc_grupo_economico       pai
             , crapass                    ass
             , tbcc_grupo_economico_integ int
         WHERE ass.cdcooper = pai.cdcooper
           AND ass.nrdconta = pai.nrdconta
           AND int.idgrupo  = pai.idgrupo
           AND int.dtexclusao is NULL
           AND ass.dtelimin IS NULL -- Somente ativos
           --AND ass.inpessoa = 1  -- Somente PF
           AND ass.cdcooper = pr_cdcooper
           AND int.cdcooper = pr_cdcooper
           AND pai.idgrupo  = pr_nrdgrupo
           /*AND pai.nrdconta <> pr_nrdconta*/ ; -- Desconsiderar a propria conta, pois ela ja foi analisada
      rw_grupint   cr_grupint%ROWTYPE;

      -- Cursor para busca integrantes do grupo economico
      CURSOR cr_grupintegr (pr_nrdgrupo INTEGER)IS
        SELECT int.tppessoa inpessoa
              ,int.nrdconta
              ,int.Nrcpfcgc
          FROM tbcc_grupo_economico_integ INT
              ,tbcc_grupo_economico p
         WHERE int.dtexclusao IS NULL
           AND int.cdcooper = pr_cdcooper
           AND int.idgrupo  = p.idgrupo
           --AND int.tppessoa = 1  -- Somente PF
           AND int.idgrupo  = pr_nrdgrupo
           --AND int.nrdconta <> pr_nrdconta -- Desconsiderar a propria conta, pois ela ja foi analisada
         UNION
        SELECT ass.inpessoa
              ,pai.nrdconta
              ,ass.nrcpfcgc
          FROM tbcc_grupo_economico       pai
             , crapass                    ass
             , tbcc_grupo_economico_integ int
         WHERE ass.cdcooper = pai.cdcooper
           AND ass.nrdconta = pai.nrdconta
           AND int.idgrupo  = pai.idgrupo
           AND int.dtexclusao is NULL
           AND ass.dtelimin IS NULL -- Somente ativos
           --AND ass.inpessoa = 1  -- Somente PF
           AND ass.cdcooper = pr_cdcooper
           AND int.cdcooper = pr_cdcooper
           AND pai.idgrupo  = pr_nrdgrupo
           /*AND pai.nrdconta <> pr_nrdconta*/ ; -- Desconsiderar a propria conta, pois ela ja foi analisada
      rw_grupintegr   cr_grupintegr%ROWTYPE;

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT a.nrcpfcgc,
               a.inpessoa,
               a.dsnivris,
               a.dtadmiss,
               a.nrcpfcnpj_base
          FROM crapass a
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;
      vr_nrcpfcgc_ass crapass.nrcpfcgc%TYPE;
      vr_inpessoa_ass crapass.inpessoa%TYPE;
      vr_dsnivris_ass crapass.dsnivris%TYPE;
      vr_dtadmiss_ass crapass.dtadmiss%TYPE;


      -- Busca dados por CPF/CNPJ em todas as cooperativas trazendo a conta mais antiga
      -- Buscar o pior risco dentre todas as contas do CPF/CGC
      CURSOR cr_crapass_cpfcnpj(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
        SELECT /*+ index(crapass CRAPASS##CRAPASS9) */
               cdcooper
              ,dsnivris
              ,dtadmiss
          FROM crapass
         WHERE crapass.nrcpfcnpj_base = pr_nrcpfcgc;
      vr_cdcooper_ass crapass.cdcooper%TYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;


    -- ----------------------------------------------------------------
    -- Rotina Principal
    -- ----------------------------------------------------------------
    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      --> Busca dados da cooperativa
      OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      vr_mes := to_char(SYSDATE,'mm');
      vr_ano := to_char(SYSDATE,'yyyy');

      vr_dtbase := vr_ano || '-' || vr_mes;
      if length(rw_crapcop.nrdocnpj) = 14 then
         cnpjinst  := SubStr(rw_crapcop.nrdocnpj,1,8);
      else
         cnpjinst  := SubStr(rw_crapcop.nrdocnpj,1,7);
      end if;
      vr_dtbase_cnpj := 'DtBase=' || vr_dtbase || ' CNPJ=' || cnpjinst;

      -- Cria o cabecalho do xml de envio
      vr_xml := xmltype.createxml('<?xml version="1.0" encoding="UTF-8" ?><Doc3026/>');

      -- Cabeçalho do documento XML
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Doc3026' --NULL
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'CongEcon' --null --'Doc3026'
                            ,pr_tag_cont => NULL --vr_dtbase_cnpj
                            ,pr_des_erro => pr_dscritic);

      gene0007.pc_gera_atributo(pr_xml   => vr_xml,
                                pr_tag   => 'Doc3026',
                                pr_atrib => 'DtBase',
                                pr_atval => vr_dtbase,
                                pr_numva => 0,
                                pr_des_erro => pr_dscritic);

      gene0007.pc_gera_atributo(pr_xml   => vr_xml,
                                pr_tag   => 'Doc3026',
                                pr_atrib => 'CNPJ',
                                pr_atval => cnpjinst,
                                pr_numva => 0,
                                pr_des_erro => pr_dscritic);


      vr_vlmin_3026 := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'VLMIN_3026');

      -- Loop principal central de risco
      FOR rw_crapris_prin IN cr_crapris_prin(pr_cdcooper => pr_cdcooper
                                            ,pr_dtrefere => pr_dtrefere) LOOP

        OPEN cr_grupintegr(pr_nrdgrupo => rw_crapris_prin.nrdgrupo);
        FETCH cr_grupintegr INTO rw_grupintegr;
        IF cr_grupintegr%FOUND THEN
            CLOSE cr_grupintegr;

            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => 'Doc3026'
                                  ,pr_posicao  => 0 --vr_contador
                                  ,pr_tag_nova => 'CongEcon'
                                  ,pr_tag_cont => NULL --rw_crapris_prin.nrdgrupo
                                  ,pr_des_erro => pr_dscritic);

            gene0007.pc_gera_atributo(pr_xml   => vr_xml,
                                      pr_tag   => 'CongEcon',
                                      pr_atrib => 'Cd',
                                      pr_atval => rw_crapris_prin.nrdgrupo,
                                      pr_numva => vr_contador,
                                      pr_des_erro => pr_dscritic);


            FOR rw_grupint IN cr_grupint(rw_crapris_prin.nrdgrupo) LOOP

               gene0007.pc_insere_tag(pr_xml      => vr_xml
                                     ,pr_tag_pai  => 'CongEcon'
                                     ,pr_posicao  => vr_contador
                                     ,pr_tag_nova => 'Part'
                                     ,pr_tag_cont => NULL
                                     ,pr_des_erro => pr_dscritic);

               gene0007.pc_gera_atributo(pr_xml   => vr_xml,
                                         pr_tag   => 'Part',
                                         pr_atrib => 'Cd',
                                         pr_atval => rw_grupint.nrcpfcnpj_base,
                                         pr_numva => vr_nrcontgrup,
                                         pr_des_erro => pr_dscritic);

               gene0007.pc_gera_atributo(pr_xml   => vr_xml,
                                         pr_tag   => 'Part',
                                         pr_atrib => 'Tp',
                                         pr_atval => rw_grupint.inpessoa,
                                         pr_numva => vr_nrcontgrup,
                                         pr_des_erro => pr_dscritic);

               vr_nrcontgrup := vr_nrcontgrup + 1;
            END LOOP;

            -- Próxima sequencia
            vr_contador := vr_contador + 1;
        ELSE
          CLOSE cr_grupintegr;

        END IF;

      END LOOP;

      IF pr_dscritic is not null THEN
        -- Gerar crítica
        vr_dscritic    := pr_dscritic;
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Se não encontrou nenhum registro
      IF vr_contador = 0 THEN
        -- Gerar crítica
        vr_dscritic    := 'Não encontrado registro que atenda os requisitos';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      -- pr_retorno := vr_xml;
      dbms_output.put_line(vr_xml.getclobval);

      pr_retxml := vr_xml.getclobval();

      -- gera o arquivo xml 3026
      vr_nmarqsai := '3026' || '_' || to_char(pr_dtrefere,'MMYY')||'.xml';
      -- diretorio onde salvar
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      -- busca o diretorio micros contab
      vr_nom_dirmic := gene0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'contab');

      gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper
                                         ,pr_cdprogra  => 'RISCO'
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                         ,pr_dsxml     => pr_retxml
                                         ,pr_dsarqsaid => vr_nom_direto ||'/'|| vr_nmarqsai
                                         ,pr_cdrelato  => null
                                         ,pr_flg_gerar => 'S'              --> Apenas submeter
                                         ,pr_dspathcop => vr_nom_dirmic    --> Copiar para a Micros
                                         ,pr_fldoscop  => 'S'              --> Efetuar cópia com Ux2Dos
                                         ,pr_dscmaxcop => '| tr -d "\032"'
                                         ,pr_des_erro  => pr_dscritic);
      IF pr_dscritic is not null THEN
          -- Gerar crítica
          vr_dscritic    := 'Erro ao gravar arquivo - pc_solicita_relato_arquivo';
          -- Levantar exceção
          RAISE vr_exc_erro;
      END IF;


    EXCEPTION
      WHEN vr_exc_erro THEN

        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_dscritic := 'Erro não tratado na pc_gera_arq_3026';

    END;


  END PC_GERA_ARQ_3026;

END RISC0001;
/