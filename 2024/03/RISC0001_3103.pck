CREATE OR REPLACE PACKAGE CECRED.RISC0001_3103 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0001_3103
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
                                          ,pr_tab_central_risco OUT RISC0001_3103.typ_reg_central_risco --> Informações da Central de Risco
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
                             ,pr_tab_estouros OUT RISC0001_3103.typ_tab_estouros --> Informações de estouro na conta
                             ,pr_dscritic     OUT VARCHAR2);                --> Retorno de erro

  PROCEDURE pc_gera_arq_3026(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                   ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE --> Data de referência
                                   --,pr_retorno   OUT xmltype            --> XML de retorno
                                   ,pr_retxml    OUT CLOB                 --> Arquivo de retorno do XML
                                   ,pr_dscritic  OUT VARCHAR2);           --> Texto de erro/critica encontrada

  PROCEDURE pc_gera_arq_previa_3040(pr_cdcooper   IN crapcop.cdcooper%TYPE          --> Codigo da cooperativa
                                   ,pr_cddopcao   IN VARCHAR2                       --> Opção selecionado tela RISCO
                                   ,pr_cdoperad   IN crapope.cdoperad%TYPE          --> Código do Operador
                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE          --> Codigo da critica
                                   ,pr_dscritic  OUT crapcri.dscritic%TYPE);        --> Descricao da critica

  PROCEDURE pc_gera_arq_previa_3040_job(pr_cdcooper           IN crapcop.cdcooper%TYPE             --> Codigo da cooperativa
                                       ,pr_dtrefere           IN DATE                              --> Data de referencia para gerar 3040
                                       ,pr_cdprogra           IN crapprg.cdprogra%TYPE             --> Nome do programa
                                       ,pr_idprglog           IN tbgen_prglog.idprglog%TYPE        --> ID do controle de log de programas executados
                                       ,pr_cdoperad           IN crapope.cdoperad%TYPE             --> Código do Operador
                                       ,pr_cdagenci_gerar3040 IN crapage.cdagenci%TYPE DEFAULT 0); --> Gerar 3040 por Codigo Agencia com paralelismo

  FUNCTION fn_gera_arq_previa_nomexml(pr_cdprogra   IN crapprg.cdprogra%TYPE
                                     ,pr_idrelato   IN VARCHAR2) RETURN VARCHAR2;
                                     
  PROCEDURE verificarSaidas(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                           ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da conta
                           ,pr_nrctremp      IN crapepr.nrctremp%TYPE     --> Numero Contrato
                           ,pr_dtrefere      IN crapris.dtrefere%TYPE     --> DAta Referencia (ult dia mes anter)
                           ,pr_situacao     OUT NUMBER                    --> Existe Saida 1-Sim / 0 - Nao
                           ,pr_dscritic     OUT craperr.dscritic%TYPE);  --> Descrição Crítica


END RISC0001_3103;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0001_3103 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0001_3103
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : Marcos Ernani Martini - Supero
  --  Data     : Agosto/2014.                   Ultima atualizacao: 19/08/2020
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
  --
  --             29/07/2019 - PRJ298.3 - Gravar na base de forma segregada os lançamentos de juros +60 remuneratórios e juros +60 de correção - Supero (Nagasava)
  --
  --             25/09/2019 - Considerar o qtd. de dias de atraso da crapris na chaamda
  --                          da rotina pc_busca_saldos_juros60_det. (Elton / AMcom)
  --
  --             29/10/2019 - P577 - Gravar na base de forma segregada os lançamentos de juros +60 remuneratórios e juros +60 e multa PP - Darlei (Supero)
  --
  --             19/08/2020 - RITM0087847 retirar a geração do arquivo 3040 do processo batch,
  --                          executando por job ao acessar tela RISCO, opção F (Carlos)
  --
  --             15/04/2021 - RITM0130707 Incluir na package RISC0001_3103.pc_risco_k a geração de uma linha com o total da operação no último dia do mês
  --                          e uma linha para a reversão com o mesmo valor no primeiro dia do mês subsequente.
  --
  --             03/05/2021 - RITM0134267 - Efetuar segregação dos níveis de risco para operações de crédito com linha de crédito 6901
  --                          Heitor (Mouts)
  --
  --             04/06/2021 - INC0092295 - Adicionar modalidade 1909 no cálculo do limite (Mateus Kienen/Mouts)
  --
  ---------------------------------------------------------------------------------------------------------------*/

  -- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  -- Constantes para Prévio 3040
  vr_cdprogra_p        CONSTANT crapprg.cdprogra%TYPE := 'RPREV3040P';
  vr_cdprogra_q        CONSTANT crapprg.cdprogra%TYPE := 'RPREV3040Q';
  vr_cdprogra_f        CONSTANT crapprg.cdprogra%TYPE := 'RPREV3040F';


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
      valorpf  NUMBER(25, 2) := 0
     ,dscpf    VARCHAR(25)
     ,valorpj  NUMBER(25, 2) := 0
     ,dscpj    VARCHAR(25)
     ,valormei NUMBER(25, 2) := 0
     ,dscmei   VARCHAR(25));

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
                         ,pr_cdmodali IN crapris.cdmodali%TYPE
                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
      SELECT crapvri.cdvencto
            ,crapvri.cdcooper
            ,crapvri.vldivida
        FROM crapvri
       WHERE crapvri.cdcooper = pr_cdcooper
         AND crapvri.nrdconta = pr_nrdconta
         AND crapvri.dtrefere = pr_dtrefere
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
      SELECT ROUND(SUM((x.dtvencto - x.dtvenmin60 + 1) * txdiaria *
                       vltitulo)
                  ,2) AS vljurrec, -- valor de juros de receita a ser apropriado
             cdcooper,
             cdagenci,
             inpessoa,
             SUM(vljura60) AS vljurmor -- valor de juros de mora a ser apropriado
        FROM (SELECT UNIQUE tdb.vljura60,
                     tdb.nrdconta,
                     tdb.nrborder,
                     tdb.dtlibbdt,
                     tdb.dtvencto,
                     (tdb.dtvencto - tdb.dtlibbdt) AS qtd_dias, -- quantidade de dias contabilizados para juros a apropriar
                     tdb.vltitulo,
                     tdv.dtvenmin,
                     (tdv.dtvenmin + 60) AS dtvenmin60,
                     tdb.cdcooper,
                     tdb.nrdocmto,
                     tdb.nrcnvcob,
                     tdb.nrdctabb,
                     tdb.cdbandoc,
                     tdb.nrtitulo,
                     ((bdt.txmensal / 100) / 30) AS txdiaria,
                     ass.cdagenci,
                     ass.inpessoa
                FROM craptdb tdb
               INNER JOIN (SELECT cdcooper,
                                 nrdconta,
                                 nrborder,
                                 MIN(dtvencto) dtvenmin
                            FROM craptdb
                           WHERE (dtvencto + 60) < par_dtrefere
                             AND insittit = 4
                             AND cdcooper = par_cdcooper
                           GROUP BY cdcooper, nrdconta, nrborder) tdv
                  ON tdb.cdcooper = tdv.cdcooper
                 AND tdb.nrdconta = tdv.nrdconta
                 AND tdb.nrborder = tdv.nrborder
               INNER JOIN crapbdt bdt
                  ON bdt.nrborder = tdb.nrborder
                 AND bdt.cdcooper = tdb.cdcooper
                 AND bdt.flverbor = 1
               INNER JOIN crapass ass
                  ON bdt.nrdconta = ass.nrdconta
                 AND bdt.cdcooper = ass.cdcooper
                 AND (bdt.inprejuz = 0 OR
                     (bdt.inprejuz = 1 AND bdt.dtprejuz > par_dtrefere))
               WHERE 1 = 1
                 AND tdb.insittit = 4
                 AND tdb.dtvencto >= (tdv.dtvenmin + 60)
               ORDER BY tdb.cdcooper, tdb.nrdconta, tdb.nrtitulo) x
       GROUP BY cdcooper, inpessoa, cdagenci
       ORDER BY cdcooper, cdagenci;

    CURSOR cr_jur60 IS
      SELECT ass.inpessoa
            ,ass.cdagenci
            ,SUM(ris.vljura60) vljura60
        FROM gestaoderisco.tbrisco_juros_desconto_titulo ris
       INNER JOIN crapass ass ON ris.nrdconta = ass.nrdconta AND
                                 ris.cdcooper = ass.cdcooper
       WHERE ris.cdcooper = par_cdcooper
         AND ris.dtrefere = par_dtrefere
         AND ris.vljura60 > 0
     GROUP BY ass.inpessoa
             ,ass.cdagenci;

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
                                ,pr_tabvljur8 IN OUT typ_arr_decimal_pfpj    --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
                                ,pr_tabvljur9 IN OUT typ_arr_decimal_pfpj    --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
                                ,pr_tabvljur10 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
                                ,pr_tabvljur11 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
                                ,pr_tabvljur12 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
                                ,pr_tabvljur13 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
                                ,pr_tabvljur14 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 299 - Por PA - Juros Mora - P577
                                ,pr_tabvljur15 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 499 - Por PA - Juros Mora - P577
                                ,pr_tabvljur16 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 299 - Por PA - Juros - P577
                                ,pr_tabvljur17 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 499 - Por PA - Juros - P577
                                ,pr_tabvljur18 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 299 - Por PA - Multa - P577
                                ,pr_tabvljur19 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 499 - Por PA - Multa - P577
                                ,pr_tabvljur20 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 299 - Por PA - Juros Correção - P577
                                ,pr_tabvljur21 IN OUT typ_arr_decimal_pfpj   --> PP - Modalidade 499 - Por PA - Juros Correção - P577
                                ,pr_tabvljur22 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 299 - Por PA - Multa - P577
                                ,pr_tabvljur23 IN OUT typ_arr_decimal_pfpj   --> POS - Modalidade 499 - Por PA - Multa - P577
                                ,pr_vlrjuros  OUT typ_decimal_pfpj           --> TR - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros  OUT typ_decimal_pfpj           --> TR - Modalidade 499 - Por Tipo pessoa.
                                ,pr_vlrjuros2 OUT typ_decimal_pfpj           --> PP - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros2 OUT typ_decimal_pfpj           --> PP - Modalidade 499 - Por Tipo pessoa.
                                ,pr_vlrjuros3 OUT typ_decimal_pfpj           --> PP – Cessao - Por Tipo pessoa.
                                ,pr_vlrjuros6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa.
                                ,pr_finjuros6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa.
                                ,pr_vlmrapar6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                                ,pr_fimrapar6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                                ,pr_vljuremu6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                                ,pr_fijuremu6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                                ,pr_vljurcor6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
                                ,pr_fijurcor6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
                                ,pr_vljurmta6 OUT typ_decimal_pfpj           --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PJ577
                                ,pr_fijurmta6 OUT typ_decimal_pfpj           --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PJ577
                                ,pr_vlmrapar2 OUT typ_decimal_pfpj           --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
                                ,pr_fimrapar2 OUT typ_decimal_pfpj           --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
                                ,pr_vljuropp2 OUT typ_decimal_pfpj           --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
                                ,pr_fijuropp2 OUT typ_decimal_pfpj           --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
                                ,pr_vlmultpp2 OUT typ_decimal_pfpj           --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
                                ,pr_fimultpp2 OUT typ_decimal_pfpj           --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
                                ,pr_vljurcor2 OUT typ_decimal_pfpj           --> PJ577
                                ,pr_fijurcor2 OUT typ_decimal_pfpj           --> PJ577
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
  --  Data     : ?????                         Ultima atualizacao: 29/07/2019
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
  --
  --               29/07/2019 - PRJ298.3 - Gravar na base de forma segregada os lançamentos de juros +60 remuneratórios e juros +60 de correção - Supero (Nagasava)
  --
  --               29/10/2019 - P577 - Gravar na base de forma segregada os lançamentos de juros +60 remuneratórios e juros +60 e multa PP - Darlei (Supero)
  -- ......................................................................................................


    CURSOR cr_crapvri_jur(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE
                         ,pr_cdmodali IN crapris.cdmodali%TYPE
                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
      SELECT /*+ INDEX_DESC(crapvri CRAPVRI##CRAPVRI1) */
             crapvri.cdvencto
            ,crapvri.cdcooper
            ,crapvri.vldivida
        FROM crapvri
       WHERE crapvri.cdcooper = pr_cdcooper
         AND crapvri.dtrefere = pr_dtrefere
         AND crapvri.nrdconta = pr_nrdconta
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
            ,a.cdagenci
            ,ris.qtdiaatr qtdiaatr
            ,nvl(j.vlmrapar60, 0) + nvl(j.vljurmorpp, 0) vlmrapar60 -- PRJ298.3
            ,nvl(j.vljurparpp, 0) vljuremu60 -- PRJ298.3
            ,nvl(j.vljurcor60, 0) + nvl(j.vljurcorpp, 0) vljurcor60 -- PRJ298.3
            ,nvl(j.vljurantpp, 0) vljurantpp -- P577
            ,nvl(j.vljurparpp, 0) vljurparpp -- P577
            ,nvl(j.vljurmorpp, 0) vljurmorpp -- P577
            ,nvl(j.vljurmulpp, 0) vljurmulpp -- P577
            ,nvl(j.vljurcorpp, 0) vljurcorpp -- P577
            ,nvl(j.vljura60, 0) vljura60
        FROM crapris ris
            ,crapepr epr
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
            ,crapass a
       WHERE ris.cdcooper = par_cdcooper
         AND ris.dtrefere = par_dtrefere
         AND ris.cdmodali = par_cdmodali
         AND ris.inddocto = 1
         AND epr.cdcooper = ris.cdcooper
         AND epr.nrdconta = ris.nrdconta
         AND epr.nrctremp = ris.nrctremp
         AND a.cdcooper = ris.cdcooper
         AND a.nrdconta = ris.nrdconta
         AND ris.cdcooper = j.cdcooper(+)
         AND ris.nrdconta = j.nrdconta(+)
         AND ris.nrctremp = j.nrctremp(+)
         AND ris.dtrefere = j.dtrefere(+)
       ORDER BY a.cdagenci,
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
      SELECT ris.nrdconta
           , DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa /* Tratamento para Pessoa Administrativa considerar com PJ*/
           , ass.cdagenci
           , j.qtdiaatr qtdiaatr
           , ris.vldivida
           , ris.dtinictr
           , sld.vljuresp -- Valor provisionado do histórico 38 (DF)
           , null tpregtrb
        FROM crapass ass
           , crapris ris
           , crapsld sld
           , GESTAODERISCO.vw_historico_juros_adp j
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta  = ass.nrdconta
         and ris.inpessoa <> 2
         AND ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere  = par_dtrefere
         AND ris.cdmodali  = 101
         AND j.qtdiaatr >= 60
         AND ris.innivris <  10 --> Apenas operações que ainda não estejam em prejuizo
         AND sld.cdcooper = ass.cdcooper
         AND sld.nrdconta = ass.nrdconta
         AND j.cdcooper = ris.cdcooper
         AND j.nrdconta = ris.nrdconta
         AND j.dtmvtolt = ris.dtrefere
         AND j.vljura60adp > 0
      union
      SELECT ris.nrdconta
           , DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa /* Tratamento para Pessoa Administrativa considerar com PJ*/
           , ass.cdagenci
           , j.qtdiaatr qtdiaatr
           , ris.vldivida
           , ris.dtinictr
           , sld.vljuresp -- Valor provisionado do histórico 38 (DF)
           , jur.tpregtrb
        FROM crapjur jur
           , crapass ass
           , crapris ris
           , crapsld sld
           , GESTAODERISCO.vw_historico_juros_adp j
       WHERE jur.cdcooper = ris.cdcooper
         and jur.nrdconta = ris.nrdconta
         and ris.cdcooper = ass.cdcooper
         AND ris.nrdconta  = ass.nrdconta
         and ris.inpessoa  = 2
         AND ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere  = par_dtrefere
         AND ris.cdmodali  = 101
         AND j.qtdiaatr >= 60
         AND ris.innivris <  10 --> Apenas operações que ainda não estejam em prejuizo
         AND sld.cdcooper = ass.cdcooper
         AND sld.nrdconta = ass.nrdconta
         AND j.cdcooper = ris.cdcooper
         AND j.nrdconta = ris.nrdconta
         AND j.dtmvtolt = ris.dtrefere
         AND j.vljura60adp > 0;
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
    pr_juros38_df.valorpf  :=0;
    pr_juros38_df.valorpj  :=0;
    pr_juros38_df.valormei :=0;

    pr_juros38_da.valorpf  :=0;
    pr_juros38_da.valorpj  :=0;
    pr_juros38_da.valormei :=0;

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

            pr_vlrjuros3.valorpf := pr_vlrjuros3.valorpf + NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577

            -- Por PA
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60 + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577
            END IF;
          ELSE -- PJ
            pr_vlrjuros3.valorpj := pr_vlrjuros3.valorpj + NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577

            -- Por PA
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60 + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ577
            END IF;
          END IF;
        END IF;

        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros2.valorpf := pr_vlrjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar2.valorpf := pr_vlmrapar2.valorpf + nvl(rw_crapris_jur.vljurmorpp,0); -- P577
            pr_vljuropp2.valorpf := pr_vljuropp2.valorpf + nvl(rw_crapris_jur.vljurparpp,0) -- P577
                                                         /*+ nvl(rw_crapris_jur.vljurparpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
            pr_vlmultpp2.valorpf := pr_vlmultpp2.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); -- P577
            pr_vljurcor2.valorpf := pr_vljurcor2.valorpf + nvl(rw_crapris_jur.vljurcorpp,0); -- P577

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmorpp; -- P577
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurparpp -- P577
                                                                                                                      /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp; -- P577
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcorpp; -- P577
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmorpp,0); -- P577
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurparpp,0) -- P577
                                                              /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmulpp,0); -- P577
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurcorpp,0); -- P577
            END IF;
          ELSE -- PJ
            pr_vlrjuros2.valorpj := pr_vlrjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar2.valorpj := pr_vlmrapar2.valorpj + nvl(rw_crapris_jur.vljurmorpp,0); -- P577
            pr_vljuropp2.valorpj := pr_vljuropp2.valorpj + nvl(rw_crapris_jur.vljurparpp,0) -- P577
                                                         /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
            pr_vlmultpp2.valorpj := pr_vlmultpp2.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); -- P577
            pr_vljurcor2.valorpj := pr_vljurcor2.valorpj + nvl(rw_crapris_jur.vljurcorpp,0); -- P577

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmorpp; -- P577
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurparpp -- P577
                                                                                                                      /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp; -- P577
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcorpp; -- P577
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmorpp,0); -- P577
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurparpp,0) -- P577
                                                              /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmulpp,0); -- P577
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurcorpp,0); -- P577
            END IF;

          END IF;

        ELSE

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_finjuros2.valorpf := pr_finjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar2.valorpf := pr_fimrapar2.valorpf + nvl(rw_crapris_jur.vljurmorpp,0); -- P577
            pr_fijuropp2.valorpf := pr_fijuropp2.valorpf + nvl(rw_crapris_jur.vljurparpp,0) -- P577
                                                         /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
            pr_fimultpp2.valorpf := pr_fimultpp2.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); -- P577
            pr_fijurcor2.valorpf := pr_fijurcor2.valorpf + nvl(rw_crapris_jur.vljurcorpp,0); -- P577

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmorpp; -- P577
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurparpp -- P577
                                                                                                                      /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp; -- P577
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcorpp; -- P577
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmorpp,0); -- P577
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurparpp,0) -- P577
                                                              /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmulpp,0); -- P577
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurcorpp,0); -- P577
            END IF;
          ELSE  -- PJ
            pr_finjuros2.valorpj := pr_finjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar2.valorpj := pr_fimrapar2.valorpj + nvl(rw_crapris_jur.vljurmorpp,0); -- P577
            pr_fijuropp2.valorpj := pr_fijuropp2.valorpj + nvl(rw_crapris_jur.vljurparpp,0) -- P577
                                                         /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
            pr_fimultpp2.valorpj := pr_fimultpp2.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); -- P577
            pr_fijurcor2.valorpj := pr_fijurcor2.valorpj + nvl(rw_crapris_jur.vljurcorpp,0); -- P577

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmorpp; -- P577
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurparpp -- P577
                                                                                                                      /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp; -- P577
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcorpp; -- P577
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmorpp,0); -- P577
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurparpp,0) -- P577
                                                              /*+ nvl(rw_crapris_jur.vljurantpp, 0)*/; -- PRJ577 -- Divergencia entre o relatorio 354 e o arquivo de risco
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmulpp,0); -- P577
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurcorpp,0); -- P577
            END IF;
          END IF;

        END IF;

      ELSIF rw_crapris_jur.tpemprst = 2 THEN  -- POS FIXADO

        -- Emprestimo
        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_vlrjuros6.valorpf := pr_vlrjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar6.valorpf := pr_vlmrapar6.valorpf + nvl(rw_crapris_jur.vlmrapar60,0); -- PRJ298.3
            pr_vljuremu6.valorpf := pr_vljuremu6.valorpf + nvl(rw_crapris_jur.vljuremu60,0); -- PRJ298.3
            pr_vljurcor6.valorpf := pr_vljurcor6.valorpf + nvl(rw_crapris_jur.vljurcor60,0); -- PRJ298.3
            pr_vljurmta6.valorpf := pr_vljurmta6.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ298.3

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vlmrapar60; --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljuremu60; --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcor60; --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vlmrapar60,0); --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljuremu60,0); --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurcor60,0); --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurmulpp,0);
      END IF;
          ELSE -- PJ
            pr_vlrjuros6.valorpj := pr_vlrjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar6.valorpj := pr_vlmrapar6.valorpj + nvl(rw_crapris_jur.vlmrapar60,0); -- PRJ298.3
            pr_vljuremu6.valorpj := pr_vljuremu6.valorpj + nvl(rw_crapris_jur.vljuremu60,0); -- PRJ298.3
            pr_vljurcor6.valorpj := pr_vljurcor6.valorpj + nvl(rw_crapris_jur.vljurcor60,0); -- PRJ298.3
            pr_vljurmta6.valorpj := pr_vljurmta6.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ298.3

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vlmrapar60; --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljuremu60; --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcor60; --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vlmrapar60,0); --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljuremu60,0); --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurcor60,0); --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurmulpp,0);
            END IF;

          END IF;

        ELSE -- 499

          IF rw_crapris_jur.inpessoa = 1 THEN -- PF

            pr_finjuros6.valorpf := pr_finjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar6.valorpf := pr_fimrapar6.valorpf + nvl(rw_crapris_jur.vlmrapar60,0); -- PRJ298.3
            pr_fijuremu6.valorpf := pr_fijuremu6.valorpf + nvl(rw_crapris_jur.vljuremu60,0); -- PRJ298.3
            pr_fijurcor6.valorpf := pr_fijurcor6.valorpf + nvl(rw_crapris_jur.vljurcor60,0); -- PRJ298.3
            pr_vljurmta6.valorpf := pr_vljurmta6.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ298.3

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vlmrapar60; --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljuremu60; --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcor60; --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vlmrapar60,0); --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljuremu60,0); --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurcor60,0); --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurmulpp,0);
            END IF;
          ELSE  -- PJ
            pr_finjuros6.valorpj := pr_finjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar6.valorpj := pr_fimrapar6.valorpj + nvl(rw_crapris_jur.vlmrapar60,0); -- PRJ298.3
            pr_fijuremu6.valorpj := pr_fijuremu6.valorpj + nvl(rw_crapris_jur.vljuremu60,0); -- PRJ298.3
            pr_fijurcor6.valorpj := pr_fijurcor6.valorpj + nvl(rw_crapris_jur.vljurcor60,0); -- PRJ298.3
            pr_fijurmta6.valorpj := pr_fijurmta6.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); -- PRJ298.3

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vlmrapar60; --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljuremu60; --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcor60; --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vlmrapar60,0); --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljuremu60,0); --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurcor60,0); --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurmulpp,0);
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
                                                         , pr_qtdiaatr => rw_conta_negativa.qtdiaatr -- Considerar o número de dias da Crapris
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

               if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                 pr_juros38_df.valormei := pr_juros38_df.valormei + rw_conta_negativa.vljuresp;
               end if;

               IF pr_tabvljuros38_df.exists(rw_conta_negativa.cdagenci) THEN
                 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj,0) + rw_conta_negativa.vljuresp;

                 if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                   pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valormei := NVL(pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valormei,0) + rw_conta_negativa.vljuresp;
                 end if;
               ELSE
                 pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valorpj := rw_conta_negativa.vljuresp;

                 if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                   pr_tabvljuros38_df(rw_conta_negativa.cdagenci).valormei := rw_conta_negativa.vljuresp;
                 end if;
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

               if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                 pr_juros38_da.valormei := pr_juros38_da.valormei + vr_vlju6038;
               end if;

               IF pr_tabvljuros38_da.exists(rw_conta_negativa.cdagenci) THEN
                 pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj := NVL(pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj,0) +  vr_vlju6038;

                if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                  pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valormei := NVL(pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valormei,0) +  vr_vlju6038;
                end if;
               ELSE
                 pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valorpj := vr_vlju6038;

                if nvl(rw_conta_negativa.tpregtrb,0) = 4 then
                  pr_tabvljuros38_da(rw_conta_negativa.cdagenci).valormei := vr_vlju6038;
                end if;
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
  Data    : Dezembro/2014                       Ultima Alteracao: 16/03/2022

  Dados referentes ao programa:

  Frequencia: Diario (on-line)
  Objetivo  : Gerar Arq. Contabilizacao Provisao
              (Relatorio 321)

  Alterações:
      ------------ COMENTÁRIOS ANTERIORES BUSCAR NO REPOSITÓRIO ------------

     09/03/2021 - RISCOS - Tratamento carta circular 4092 - Limite Credito 1902 (Guilherme/AMcom)

     15/04/2021 - RITM0130707 - RITM0130707 - Incluir na package RISC0001_3103.pc_risco_k a geração de uma linha com o total da operação no último dia do mês
                  e uma linha para a reversão com o mesmo valor no primeiro dia do mês subsequente.

     04/06/2021 - INC0092295 - Adicionar modalidade 1909 no cálculo do limite (Mateus Kienen/Mouts)

     07/06/2021 - PRB0045545 - Correção na abertura do cursor cr_craplcr_6901.
                               Inclusão dos valores referentes a juros nas linhas de lançamento vencidas.
                               (Heitor - Mouts)

     26/09/2021 - INC0106788 - Adicionada rotina para calcular provisionamento do risco
                               (Luiz Otávio Olinger Momm/Squad Risco - Ailos)

     17/10/2021 - RITM0170907 - Segregacao dos valores de PRONAMPE (Linha 2600) em 1 e 2
                                1 --> Até 31/12/2020 // 2 --> Após 31/12/2020 (Heitor - Mouts)

     16/03/2022 - Adicionada critica caso a data do parametro seja maior que a data da central
                  (Darlei Zillmer / PremierSoft)
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
            ,CASE WHEN ris.cdmodali IN (901,902,903,990) THEN 'IMOBILIARIO' ELSE '' END dsinfaux
            ,nvl(j.vljura60, 0) vljura60
            ,ris.cdorigem
            ,ris.inpessoa
            ,a.cdagenci
            ,nvl(j.vljurantpp,0) vljurantpp -- PRJ577
            ,null tpregtrb
            ,ris.nracordo
        FROM crapris ris
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
            ,crapass a
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND a.cdcooper = ris.cdcooper
         AND a.nrdconta = ris.nrdconta
         AND ris.inddocto = 1
         and ris.inpessoa <> 2
         AND ris.cdcooper = j.cdcooper(+)
         AND ris.nrdconta = j.nrdconta(+)
         AND ris.nrctremp = j.nrctremp(+)
         AND ris.dtrefere = j.dtrefere(+)
      UNION
      SELECT ris.cdcooper
            ,ris.dtrefere
            ,ris.vldivida
            ,ris.nrdconta
            ,ris.innivris
            ,ris.cdmodali
            ,ris.nrctremp
            ,ris.nrseqctr
            ,CASE WHEN ris.cdmodali IN (901,902,903,990) THEN 'IMOBILIARIO' ELSE '' END dsinfaux
            ,nvl(j.vljura60, 0) vljura60
            ,ris.cdorigem
            ,ris.inpessoa
            ,a.cdagenci
            ,nvl(j.vljurantpp,0) vljurantpp -- PRJ577
            ,jur.tpregtrb
            ,ris.nracordo
        FROM crapjur jur
           , crapris ris
           ,GESTAODERISCO.tbrisco_juros_emprestimo j
           ,crapass a
       WHERE jur.cdcooper = ris.cdcooper
         and jur.nrdconta = ris.nrdconta
         and ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND a.cdcooper = ris.cdcooper
         AND a.nrdconta = ris.nrdconta
         AND ris.inddocto = 1
         and ris.inpessoa = 2
         AND ris.cdcooper = j.cdcooper(+)
         AND ris.nrdconta = j.nrdconta(+)
         AND ris.nrctremp = j.nrctremp(+)
         AND ris.dtrefere = j.dtrefere(+)
       ORDER BY cdagenci
               ,nrdconta
               ,nrctremp;

    -- Cursor LIMITE NAO UTILIZADO - LNU
    CURSOR cr_crapris_lnu(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_cdmodali  IN crapris.cdmodali%TYPE
                          ,pr_cdmodali2 IN crapris.cdmodali%TYPE DEFAULT NULL) IS
      SELECT ris.cdcooper
            ,ris.dtrefere
            ,ris.vldivida
            ,ris.nrdconta
            ,ris.inpessoa
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 3
         AND ris.cdmodali IN (pr_cdmodali, NVL(pr_cdmodali2,0));

    -- Informações da central de risco
    CURSOR cr_crapris_249(pr_cdcooper in crapris.cdcooper%TYPE
                         ,pr_dtultdia in crapris.dtrefere%TYPE
                         ,pr_cdorigem in crapris.cdorigem%TYPE
                         ,pr_cdmodali in crapris.cdmodali%TYPE
                         ,pr_tpemprst IN crapepr.tpemprst%TYPE) IS
      SELECT r.cdagenci
            ,(SUM(v.vldivida)) saldo_devedor
        FROM crapris r
            ,crapepr e
            ,crapvri v
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtultdia
         AND r.cdorigem = pr_cdorigem
         AND r.cdmodali = pr_cdmodali
         AND e.cdcooper = r.cdcooper
         AND e.nrdconta = r.nrdconta
         AND e.nrctremp = r.nrctremp
         AND e.tpemprst = pr_tpemprst
         AND v.cdcooper = r.cdcooper
         AND v.nrdconta = r.nrdconta
         AND v.nrctremp = r.nrctremp
         AND v.dtrefere = r.dtrefere
         AND v.cdmodali = r.cdmodali
         AND v.cdvencto BETWEEN 110 AND 290
         --> Deve ignorar emprestimos de cessao de credito
         AND NOT EXISTS (SELECT 1
                           FROM crapebn b
                          WHERE b.cdcooper = r.cdcooper
                            AND b.nrdconta = r.nrdconta
                            AND b.nrctremp = r.nrctremp)
         AND NOT EXISTS (SELECT 1
                           FROM tbcrd_cessao_credito ces
                          WHERE ces.cdcooper = r.cdcooper
                            AND ces.nrdconta = r.nrdconta
                            AND ces.nrctremp = r.nrctremp)
         --> Gerar linha com o somatorios
         GROUP BY (r.cdagenci)
         --> Ordenar para linha de somatorio ser apresentada primeiro
         ORDER BY nvl(r.cdagenci,0) ASC;

    TYPE typ_cr_crapris_249 IS TABLE OF cr_crapris_249%ROWTYPE index by PLS_INTEGER;
    rw_crapris_249 typ_cr_crapris_249;

    CURSOR cr_crapris_249_jura60(pr_cdcooper in crapris.cdcooper%TYPE
                                ,pr_dtultdia in crapris.dtrefere%TYPE
                                ,pr_cdorigem in crapris.cdorigem%TYPE
                                ,pr_cdmodali in crapris.cdmodali%TYPE
                                ,pr_tpemprst IN crapepr.tpemprst%TYPE
                                ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT (SUM(NVL(j.vljura60,0))) vljura60
        FROM crapris r
            ,crapepr e
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
       WHERE e.cdcooper = r.cdcooper
         AND e.nrdconta = r.nrdconta
         AND e.nrctremp = r.nrctremp
         AND r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtultdia
         AND r.cdorigem = pr_cdorigem
         AND r.cdmodali = pr_cdmodali
         AND e.tpemprst = pr_tpemprst
         AND r.cdagenci = pr_cdagenci
         AND r.cdcooper = j.cdcooper(+)
         AND r.nrdconta = j.nrdconta(+)
         AND r.nrctremp = j.nrctremp(+)
         AND r.dtrefere = j.dtrefere(+)
         AND NVL(j.vljura60,0) + nvl(j.vljurantpp,0) > 0
         --> Deve ignorar emprestimos de cessao de credito
         AND NOT EXISTS (SELECT 1
                           FROM crapebn b
                          WHERE b.cdcooper = r.cdcooper
                            AND b.nrdconta = r.nrdconta
                            AND b.nrctremp = r.nrctremp)
         AND NOT EXISTS (SELECT 1
                           FROM tbcrd_cessao_credito ces
                          WHERE ces.cdcooper = r.cdcooper
                            AND ces.nrdconta = r.nrdconta
                            AND ces.nrctremp = r.nrctremp);
    vr_vljura60_249       GESTAODERISCO.tbrisco_juros_emprestimo.vljura60%TYPE;

    CURSOR cr_juros60_vri(pr_cdcooper IN crapvri.cdcooper%TYPE
                         ,pr_nrdconta IN crapvri.nrdconta%TYPE
                         ,pr_dtrefere IN crapvri.dtrefere%TYPE
                         ,pr_nrctremp IN crapvri.nrctremp%TYPE
                         ,pr_nrseqctr IN crapvri.nrseqctr%TYPE) IS
      SELECT nvl(j.vljura60,0) vljura60, nvl(j.vljurantpp,0) vljurantpp
        FROM gestaoderisco.vw_operacoes_risco_juros60 j
       WHERE j.cdcooper = pr_cdcooper
         AND j.nrdconta = pr_nrdconta
         AND j.nrctremp = pr_nrctremp
         AND j.dtmvtolt = pr_dtrefere
         AND decode(pr_nrseqctr, 95, 90, 96, 90, 91, 3, pr_nrseqctr) = j.tpproduto;
    rw_juros60_vri cr_juros60_vri%ROWTYPE;

    -- Buscar as informações dos vencimentos de risco
    CURSOR cr_crapvri(pr_cdcooper IN crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN crapvri.dtrefere%TYPE
                     ,pr_cdmodali IN crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN crapvri.nrseqctr%TYPE
                     ,pr_vldivida IN NUMBER) IS
      SELECT v.cdvencto,
             v.vldivida,
             v.cdcooper,
             v.nrdconta,
             v.dtrefere,
             v.cdmodali,
             v.nrctremp,
             v.nrseqctr,
             ROW_NUMBER ()
              OVER (PARTITION BY v.nrdconta,v.nrctremp,v.nrseqctr ORDER BY v.nrdconta,v.nrctremp,v.nrseqctr) nrseqreg,
             Count (1)
              OVER (PARTITION BY v.nrdconta,v.nrctremp,v.nrseqctr) qtreggar
        FROM crapvri v
       WHERE v.cdcooper = pr_cdcooper
         AND v.nrdconta = pr_nrdconta
         AND v.dtrefere = pr_dtrefere
         AND v.cdmodali = pr_cdmodali
         AND v.nrctremp = pr_nrctremp
         AND v.nrseqctr = pr_nrseqctr;

    -- Busca vencimentos de risco maior q 205
    CURSOR cr_crabvri(pr_cdcooper IN crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN crapvri.dtrefere%TYPE
                     ,pr_cdmodali IN crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN crapvri.nrseqctr%TYPE) IS
      SELECT vri.cdcooper
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.nrdconta = pr_nrdconta
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr
         AND vri.cdvencto > 205;
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
               ,SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)) vljura60 -- PRJ577
          FROM crapris ris, GESTAODERISCO.vw_operacoes_risco_juros60 j
         WHERE ris.cdcooper = pr_cdcooper --Cooperativa atual
           AND ris.dtrefere = pr_dtrefere --Data atual da cooperativa
           AND ris.cdcooper = j.cdcooper(+)
           AND ris.nrdconta = j.nrdconta(+)
           AND ris.nrctremp = j.nrctremp(+)
           AND ris.dtrefere = j.dtmvtolt(+)
           AND decode(ris.nrseqctr, 95, 90, 96, 90, 91, 3, ris.nrseqctr) = j.tpproduto(+)
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
          HAVING SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)) > 0 -- PRJ577
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

    --> Verifica se é um contrato e desconsidera microcrédito PRJ0023821
    CURSOR cr_crapebn_desconsid_microcred(pr_cdcooper IN crapepr.cdcooper%TYPE
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctremp
         AND crapebn.indescrisc = 1;

    -- Cursor de crédito Imobiliário
    CURSOR cr_imob(pr_cdcooper IN CREDITO.Tbepr_Contrato_Imobiliario.cdcooper%TYPE
                  ,pr_nrdconta IN CREDITO.Tbepr_Contrato_Imobiliario.nrdconta%TYPE
                  ,pr_nrctremp IN CREDITO.Tbepr_Contrato_Imobiliario.nrctremp%TYPE) IS
      SELECT imo.nrctremp, SUBSTR(imo.modelo_aquisicao,1,3) modelo_aquisicao,
             UPPER(imo.modelo_aquisicao) AS modelo_aquisicao_completo
        FROM CREDITO.Tbepr_Contrato_Imobiliario imo
       WHERE imo.cdcooper = pr_cdcooper
         AND imo.nrdconta = pr_nrdconta
         AND imo.nrctremp = pr_nrctremp;
    rw_imob cr_imob%ROWTYPE;

    --> Verificar se é um emprestimo de cessao de credito
    CURSOR cr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                      pr_nrdconta crapepr.nrdconta%TYPE,
                      pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM tbcrd_cessao_credito ces
       WHERE ces.cdcooper = pr_cdcooper
         AND ces.nrdconta = pr_nrdconta
         AND ces.nrctremp = pr_nrctremp;

    --> Geração de uma linha com o total da operação no último dia do mês e uma linha para a reversão com o mesmo valor no primeiro dia do mês subsequente
    --> Linha de crédito 2600. Linha de crédito 1600 para todos e 1601 e 1602 para a Cooperativa Cívia. Linha de crédito 4600 e 5600
    --> Saldo da operação
     CURSOR cr_saldo_opera (pr_cdcooper IN crapepr.cdcooper%TYPE,
                            pr_dtrefere IN crapris.dtrefere%TYPE,
                            pr_cdlcremp IN crapepr.cdlcremp%TYPE) is
      SELECT NVL(ROUND((SUM(vldivida) + nvl(SUM(j.vljura60),0) + NVL(SUM(j.vljurantpp),0)),2),0)
        FROM CRAPRIS r, CRAPEPR
           , gestaoderisco.tbrisco_juros_emprestimo j
       WHERE r.cdcooper = pr_cdcooper -- cooperativa
         AND r.dtrefere = pr_dtrefere --data base
         AND crapepr.cdlcremp = pr_cdlcremp --2600 --linha de crédito
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.cdcooper = j.cdcooper(+)
         AND r.nrdconta = j.nrdconta(+)
         AND r.nrctremp = j.nrctremp(+)
         AND r.dtrefere = j.dtrefere(+)
         AND r.inddocto = 1 --somente contratos ativos
         AND r.innivris <= 9; --risco de a ao h

    --> RITM0170907 - Pronampe 1 --> Operações até 31/12/2020
     CURSOR cr_saldo_opera_pronampe1(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                     pr_dtrefere IN crapris.dtrefere%TYPE,
                                     pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
      SELECT NVL(ROUND((SUM(vldivida) + nvl(SUM(j.vljura60),0) + NVL(SUM(j.vljurantpp),0)),2),0)
        FROM CRAPRIS r, CRAPEPR
           , gestaoderisco.tbrisco_juros_emprestimo j
       WHERE r.cdcooper = pr_cdcooper -- cooperativa
         AND r.dtrefere = pr_dtrefere --data base
         AND crapepr.cdlcremp = pr_cdlcremp --2600 --linha de crédito
         AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.cdcooper = j.cdcooper(+)
         AND r.nrdconta = j.nrdconta(+)
         AND r.nrctremp = j.nrctremp(+)
         AND r.dtrefere = j.dtrefere(+)
         AND r.inddocto = 1 --somente contratos ativos
         AND r.innivris <= 9; --risco de a ao h

    --> RITM0170907 - Pronampe 2 --> Operações após 31/12/2020
     CURSOR cr_saldo_opera_pronampe2(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                     pr_dtrefere IN crapris.dtrefere%TYPE,
                                     pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
      SELECT NVL(ROUND((SUM(vldivida) + nvl(SUM(j.vljura60),0) + NVL(SUM(j.vljurantpp),0)),2),0)
        FROM CRAPRIS r, CRAPEPR
           , gestaoderisco.tbrisco_juros_emprestimo j
       WHERE r.cdcooper = pr_cdcooper -- cooperativa
         AND r.dtrefere = pr_dtrefere --data base
         AND crapepr.cdlcremp = pr_cdlcremp --2600 --linha de crédito
         AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.cdcooper = j.cdcooper(+)
         AND r.nrdconta = j.nrdconta(+)
         AND r.nrctremp = j.nrctremp(+)
         AND r.dtrefere = j.dtrefere(+)
         AND r.inddocto = 1 --somente contratos ativos
         AND r.innivris <= 9; --risco de a ao h

    --> Geração de uma linha com o total da operação no último dia do mês e uma linha para a reversão com o mesmo valor no primeiro dia do mês subsequente
    --> Linha de crédito 2600. Linha de crédito 1600 para todos e 1601 e 1602 para a Cooperativa Cívia. Linha de crédito 4600 e 5600
    --> Rendas a apropriar (juros+60)
     CURSOR cr_juros_60  (pr_cdcooper IN crapepr.cdcooper%TYPE,
                          pr_dtrefere IN crapris.dtrefere%TYPE,
                          pr_cdlcremp IN crapepr.cdlcremp%TYPE) is
      SELECT nvl(ROUND(SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)),2),0)
          FROM CRAPRIS, CRAPEPR, GESTAODERISCO.tbrisco_juros_emprestimo j
         WHERE crapris.cdcooper  = pr_cdcooper -- COOPERATIVA
           AND crapris.dtrefere  = pr_dtrefere --data base
           AND crapepr.cdlcremp  = pr_cdlcremp --linha de crédito
           AND crapris.cdcooper  = crapepr.cdcooper
           AND crapris.nrdconta  = crapepr.nrdconta
           AND crapris.nrctremp  = crapepr.nrctremp
           AND crapris.cdcooper = j.cdcooper(+)
           AND crapris.nrdconta = j.nrdconta(+)
           AND crapris.nrctremp = j.nrctremp(+)
           AND crapris.dtrefere = j.dtrefere(+)
           AND crapris.inddocto  = 1 --somente contratos ativos
           AND crapris.innivris  <= 9; --risco de a ao h

     --RITM0170907 - Pronampe1 --> Operações até 31/12/2020
     CURSOR cr_juros_60_pronampe1(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                  pr_dtrefere IN crapris.dtrefere%TYPE,
                                  pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
       SELECT NVL(ROUND(SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)),2),0)
         FROM crapris
            , crapepr
            , GESTAODERISCO.tbrisco_juros_emprestimo j
        WHERE crapris.cdcooper  = pr_cdcooper -- COOPERATIVA
          AND crapris.dtrefere  = pr_dtrefere --data base
          AND crapepr.cdlcremp  = pr_cdlcremp --linha de crédito
          AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
          AND crapris.cdcooper  = crapepr.cdcooper
          AND crapris.nrdconta  = crapepr.nrdconta
          AND crapris.nrctremp  = crapepr.nrctremp
          AND crapris.cdcooper = j.cdcooper(+)
          AND crapris.nrdconta = j.nrdconta(+)
          AND crapris.nrctremp = j.nrctremp(+)
          AND crapris.dtrefere = j.dtrefere(+)
          AND crapris.inddocto  = 1 --somente contratos ativos
          AND crapris.innivris  <= 9; --risco de a ao h

     --RITM0170907 - Pronampe1 --> Operações após 31/12/2020
     CURSOR cr_juros_60_pronampe2(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                  pr_dtrefere IN crapris.dtrefere%TYPE,
                                  pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
       SELECT NVL(ROUND(SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)),2),0)
         FROM crapris
            , crapepr
            , GESTAODERISCO.tbrisco_juros_emprestimo j
        WHERE crapris.cdcooper  = pr_cdcooper -- COOPERATIVA
          AND crapris.dtrefere  = pr_dtrefere --data base
          AND crapepr.cdlcremp  = pr_cdlcremp --linha de crédito
          AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
          AND crapris.cdcooper  = crapepr.cdcooper
          AND crapris.nrdconta  = crapepr.nrdconta
          AND crapris.nrctremp  = crapepr.nrctremp
          AND crapris.cdcooper = j.cdcooper(+)
          AND crapris.nrdconta = j.nrdconta(+)
          AND crapris.nrctremp = j.nrctremp(+)
          AND crapris.dtrefere = j.dtrefere(+)
          AND crapris.inddocto  = 1 --somente contratos ativos
          AND crapris.innivris  <= 9; --risco de a ao h

     -- RITM0130707 - Provisão de perdas
     CURSOR cr_prov_perdas (pr_cdcooper IN crapepr.cdcooper%TYPE,
                            pr_dtrefere IN crapris.dtrefere%TYPE,
                            pr_cdlcremp IN crapepr.cdlcremp%TYPE) is
     SELECT nvl(ROUND(SUM(v_provisao_perda),2),0) FROM
    (SELECT  crapris.innivris,
    ROUND((crapris.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
      FROM CRAPRIS, CRAPEPR,
       (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, substr(craptab.dstextab, 12, 2) innivris
            FROM CRAPTAB
           WHERE craptab.cdcooper = pr_cdcooper
             AND UPPER(craptab.nmsistem) = 'CRED'
             AND UPPER(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres = 00
             AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO
     WHERE  crapris.cdcooper = pr_cdcooper -- cooperativa
       AND crapris.dtrefere = pr_dtrefere --data base
       AND crapepr.cdlcremp = pr_cdlcremp --linha de crédito
       AND crapris.cdcooper = crapepr.cdcooper
       AND crapris.nrdconta = crapepr.nrdconta
       AND crapris.nrctremp = crapepr.nrctremp
       AND crapris.inddocto = 1 --somente contratos ativos
       AND crapris.innivris <= 9 --risco de a ao h;
       AND crapris.innivris = n_risco.innivris);

    --RITM0170907 - Pronampe1 --> Operações até 31/12/2020
    CURSOR cr_prov_perdas_pronampe1(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                    pr_dtrefere IN crapris.dtrefere%TYPE,
                                    pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
     SELECT NVL(ROUND(SUM(v_provisao_perda),2),0) FROM
    (SELECT crapris.innivris,
            ROUND((crapris.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
       FROM CRAPRIS, CRAPEPR,
            (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, SUBSTR(craptab.dstextab, 12, 2) innivris
               FROM CRAPTAB
              WHERE craptab.cdcooper = pr_cdcooper
                AND UPPER(craptab.nmsistem) = 'CRED'
                AND UPPER(craptab.tptabela) = 'GENERI'
                AND craptab.cdempres = 00
                AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO
      WHERE crapris.cdcooper = pr_cdcooper -- cooperativa
        AND crapris.dtrefere = pr_dtrefere --data base
        AND crapepr.cdlcremp = pr_cdlcremp --linha de crédito
        AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
        AND crapris.cdcooper = crapepr.cdcooper
        AND crapris.nrdconta = crapepr.nrdconta
        AND crapris.nrctremp = crapepr.nrctremp
        AND crapris.inddocto = 1 --somente contratos ativos
        AND crapris.innivris <= 9 --risco de a ao h;
        AND crapris.innivris = n_risco.innivris);


    --RITM0170907 - Pronampe2 --> Operações após 31/12/2020
    CURSOR cr_prov_perdas_pronampe2(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                    pr_dtrefere IN crapris.dtrefere%TYPE,
                                    pr_cdlcremp IN crapepr.cdlcremp%TYPE) IS
     SELECT NVL(ROUND(SUM(v_provisao_perda),2),0) FROM
    (SELECT crapris.innivris,
            ROUND((crapris.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
       FROM CRAPRIS, CRAPEPR,
            (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, SUBSTR(craptab.dstextab, 12, 2) innivris
               FROM CRAPTAB
              WHERE craptab.cdcooper = pr_cdcooper
                AND UPPER(craptab.nmsistem) = 'CRED'
                AND UPPER(craptab.tptabela) = 'GENERI'
                AND craptab.cdempres = 00
                AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO
      WHERE crapris.cdcooper = pr_cdcooper -- cooperativa
        AND crapris.dtrefere = pr_dtrefere --data base
        AND crapepr.cdlcremp = pr_cdlcremp --linha de crédito
        AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
        AND crapris.cdcooper = crapepr.cdcooper
        AND crapris.nrdconta = crapepr.nrdconta
        AND crapris.nrctremp = crapepr.nrctremp
        AND crapris.inddocto = 1 --somente contratos ativos
        AND crapris.innivris <= 9 --risco de a ao h;
        AND crapris.innivris = n_risco.innivris);

    --RITM0134267
    cursor cr_craplcr_6901(pr_cdcooper IN crapepr.cdcooper%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE) is
      select aux.innivris
           , sum(aux.vldivida_normal) vldivida_normal
           , sum(aux.vldivida_vencida) /* - sum(vljura60_pf) - sum(vljura60_pj) - sum(vljurantpp_pf) - sum(vljurantpp_pj)*/ vldivida_vencida
           , sum(vljura60_pf) + sum(vljurantpp_pf) vljuros_pf
           , sum(vljura60_pj) + sum(vljurantpp_pj) vljuros_pj
        from (select c.innivris
                   , (sum(c.vldivida) + SUM(nvl(j.vljura60,0)) + SUM(nvl(j.vljurantpp,0))) vldivida_normal
                   , 0 vldivida_vencida
                   , sum(case a.inpessoa when 1 then nvl(j.vljura60,0) else 0 end) vljura60_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljura60,0) end) vljura60_pj
                   , sum(case a.inpessoa when 1 then nvl(j.vljurantpp,0) else 0 end) vljurantpp_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljurantpp,0) end) vljurantpp_pj
                from crapass a
                   , crapepr e
                   , crapris c
                   , GESTAODERISCO.tbrisco_juros_emprestimo j
               where not exists (select 1
                                   from crapvri v
                                  where v.cdcooper = c.cdcooper
                                    and v.dtrefere = c.dtrefere
                                    and v.nrdconta = c.nrdconta
                                    and v.cdmodali = c.cdmodali
                                    and v.nrctremp = c.nrctremp
                                    and v.nrseqctr = c.nrseqctr
                                    and v.cdvencto > 205)
                 and a.cdcooper = c.cdcooper
                 and a.nrdconta = c.nrdconta
                 and e.cdcooper = c.cdcooper
                 and e.nrdconta = c.nrdconta
                 and e.nrctremp = c.nrctremp
                 AND c.cdcooper = j.cdcooper(+)
                 AND c.nrdconta = j.nrdconta(+)
                 AND c.nrctremp = j.nrctremp(+)
                 AND c.dtrefere = j.dtrefere(+)
                 and e.cdlcremp = 6901
                 and c.cdcooper = pr_cdcooper
                 and c.inddocto = 1
                 and c.dtrefere = pr_dtrefere
                 and c.innivris <> 10
               group
                  by c.innivris
              union all
              select c.innivris
                   , 0 vldivida_normal
                   , (sum(c.vldivida) + SUM(nvl(j.vljura60,0)) + SUM(nvl(j.vljurantpp,0))) vldivida_vencida
                   , sum(case a.inpessoa when 1 then nvl(j.vljura60,0) else 0 end) vljura60_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljura60,0) END )vljura60_pj
                   , sum(case a.inpessoa when 1 then nvl(j.vljurantpp,0) else 0 END) vljurantpp_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljurantpp,0) end) vljurantpp_pj
                from crapass a
                   , crapepr e
                   , crapris c
                   , GESTAODERISCO.tbrisco_juros_emprestimo j
               where exists (select 1
                               from crapvri v
                              where v.cdcooper = c.cdcooper
                                and v.dtrefere = c.dtrefere
                                and v.nrdconta = c.nrdconta
                                and v.cdmodali = c.cdmodali
                                and v.nrctremp = c.nrctremp
                                and v.nrseqctr = c.nrseqctr
                                and v.cdvencto > 205)
                 and a.cdcooper = c.cdcooper
                 and a.nrdconta = c.nrdconta
                 and e.cdcooper = c.cdcooper
                 and e.nrdconta = c.nrdconta
                 and e.nrctremp = c.nrctremp
                 AND c.cdcooper = j.cdcooper(+)
                 AND c.nrdconta = j.nrdconta(+)
                 AND c.nrctremp = j.nrctremp(+)
                 AND c.dtrefere = j.dtrefere(+)
                 and e.cdlcremp = 6901
                 and c.cdcooper = pr_cdcooper
                 and c.inddocto = 1
                 and c.dtrefere = pr_dtrefere
                 and c.innivris <> 10
               group
                  by c.innivris) aux
       group
          by aux.innivris
       order
          by aux.innivris;

    CURSOR cr_crapsda(pr_cdcooper  IN crapass.cdcooper%TYPE
                     ,pr_nrdconta  IN crapass.nrdconta%TYPE
                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) IS
      SELECT nvl(s.vlsdbloq,0) + nvl(s.vlsdblpr,0) + nvl(s.vlsdblfp,0) vlbloque
        FROM crapsda s
            ,crapass a
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta
         AND s.dtmvtolt = pr_dtmvtolt
         AND a.cdcooper = s.cdcooper
         AND a.nrdconta = s.nrdconta;
    rw_crapsda cr_crapsda%ROWTYPE;

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

    -- Armazena os contratos de microcredito
    vr_tab_microcredito_desconsid   typ_tab_dsorgrec;

    vr_pacvljur_1        typ_arr_decimal_pfpj;
    vr_pacvljur_2        typ_arr_decimal_pfpj;
    vr_pacvljur_3        typ_arr_decimal_pfpj;
    vr_pacvljur_4        typ_arr_decimal_pfpj;
    vr_pacvljur_5        typ_arr_decimal_pfpj;
    vr_pacvljur_6        typ_arr_decimal_pfpj;
    vr_pacvljur_7        typ_arr_decimal_pfpj;
    vr_pacvljur_8        typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_9        typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_10       typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_11       typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_12       typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_13       typ_arr_decimal_pfpj; -- PRJ298.3
    vr_pacvljur_14        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_15        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_16        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_17        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_18        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_19        typ_arr_decimal_pfpj; -- P577

    vr_pacvljur_20        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_21        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_22        typ_arr_decimal_pfpj; -- P577
    vr_pacvljur_23        typ_arr_decimal_pfpj; -- P577

    -- Calculo de Juros - Variáveis acumuladoras para geração do arquivo
    vr_vldjuros          typ_decimal_pfpj;
    vr_finjuros          typ_decimal_pfpj;
    vr_vldjuros2         typ_decimal_pfpj;
    vr_finjuros2         typ_decimal_pfpj;
    vr_vlmrapar2         typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
    vr_fimrapar2         typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
    vr_vljuropp2         typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
    vr_fijuropp2         typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
    vr_vlmultpp2         typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
    vr_fimultpp2         typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
    vr_vldjuros6         typ_decimal_pfpj;
    vr_finjuros6         typ_decimal_pfpj;
    vr_vlmrapar6         typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
    vr_fimrapar6         typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
    vr_vljuremu6         typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
    vr_fijuremu6         typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
    vr_vljurcor6         typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
    vr_fijurcor6         typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
    vr_vljurmta6         typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PRJ577
    vr_fijurmta6         typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PRJ577

    vr_vldjuros3         typ_decimal_pfpj;
    -- Calculo de Juros / Variáveis de retorno da pc_calcula_juros_60k
    vr_vldjur_calc       typ_decimal_pfpj;
    vr_finjur_calc       typ_decimal_pfpj;
    vr_vldjur_calc2      typ_decimal_pfpj;
    vr_finjur_calc2      typ_decimal_pfpj;
    vr_vlmrap_calc2      typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
    vr_fimrap_calc2      typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
    vr_vljuro_calc2      typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
    vr_fijuro_calc2      typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
    vr_vlmult_calc2      typ_decimal_pfpj; --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
    vr_fimult_calc2      typ_decimal_pfpj; --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
    vr_vljuco_calc2      typ_decimal_pfpj; -- PJ577
    vr_fijuco_calc2      typ_decimal_pfpj; -- PJ577
    vr_vldjur_calc3      typ_decimal_pfpj;
    vr_vldjur_calc6      typ_decimal_pfpj;
    vr_finjur_calc6      typ_decimal_pfpj;
    vr_vlmrapar_calc6    typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
    vr_fimrapar_calc6    typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
    vr_vljuremu_calc6    typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
    vr_fijuremu_calc6    typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
    vr_vljurcor_calc6    typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
    vr_fijurcor_calc6    typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3

    vr_vljurmta_calc6    typ_decimal_pfpj; --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PRJ298.3
    vr_fijurmta_calc6    typ_decimal_pfpj; --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PRJ298.3

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

    -- Imobiliario
    vr_vlatr_imobi_sfh_pf   NUMBER := 0;
    vr_vlatr_imobi_sfh_pj   NUMBER := 0;
    vr_vlatr_imobi_sfi_pf   NUMBER := 0;
    vr_vlatr_imobi_sfi_pj   NUMBER := 0;
    vr_vlatr_imobi_home_equity_pf NUMBER := 0;
    vr_vlatr_imobi_terreno_pf_pj NUMBER := 0;

    vr_vlatr_imobi_v_sfh_pf   NUMBER := 0;
    vr_vlatr_imobi_v_sfh_pj   NUMBER := 0;
    vr_vlatr_imobi_v_sfi_pf   NUMBER := 0;
    vr_vlatr_imobi_v_sfi_pj   NUMBER := 0;
    vr_vlatr_imobi_v_home_equity_pf NUMBER := 0;
    vr_vlatr_imobi_v_terreno_pf_pj NUMBER := 0;
    --
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
    vr_vlag1721_imob     typ_arr_decimal;   -- AJUSTE PROVISAO EMPR.IMOBILIARIO
    vr_vlag1723          typ_arr_decimal;   -- AJUSTE PROVISAO EMPR.EMPRESAS
    vr_vlag1723_imob     typ_arr_decimal;   -- AJUSTE PROVISAO EMPR.IMOBILIARIO
    vr_vlag1731_1        typ_arr_decimal;   -- AJUSTE PROVISAO FIN.PESSOAIS
    vr_vlag1731_2        typ_arr_decimal;   -- AJUSTE PROVISAO FIN.EMPRESAS
    vr_vlag1721_pre      typ_arr_decimal;
    vr_vlag1723_pre      typ_arr_decimal;
    vr_vlag1731_1_pre    typ_arr_decimal;

    vr_vlag1731_2_pre    typ_arr_decimal;
    vr_vlatrage_bndes_2  typ_arr_decimal;

    vr_vlatrage_imob_sfh_pf typ_arr_decimal;
    vr_vlatrage_imob_sfh_pj typ_arr_decimal;
    vr_vlatrage_imob_sfi_pf typ_arr_decimal;
    vr_vlatrage_imob_sfi_pj typ_arr_decimal;
    vr_vlatrage_imob_home_equity_pf typ_arr_decimal;
    vr_vlatrage_imob_terreno_pf_pj typ_arr_decimal;

    vr_rel1723_v_pre     NUMBER := 0;

    vr_rel1731_2_v_pre   NUMBER := 0;

    vr_rel1721           NUMBER := 0;
    vr_rel1721_imob      NUMBER := 0;
    vr_rel1723           NUMBER := 0;
    vr_rel1723_imob      NUMBER := 0;
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
    vr_rel1721_v_imob    NUMBER := 0;
    vr_rel1723_v         NUMBER := 0;
    vr_rel1723_v_imob    NUMBER := 0;
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

    vr_relmicro_atr_pf_descris NUMBER := 0;
    vr_relmicro_pre_pf_descris NUMBER := 0;
    vr_relmicro_atr_pj_descris NUMBER := 0;
    vr_relmicro_pre_pj_descris NUMBER := 0;

    vr_contador           INTEGER;
    vr_flsomjur           INTEGER := 0;

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
    vr_vljuro_suspenso   NUMBER := 0;

    vr_vllmtepf          NUMBER := 0;
    vr_vllmtepj          NUMBER := 0;

    vr_dtinicio          DATE := to_date('01/08/2010', 'dd/mm/rrrr');

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

    vr_datacorte_1902    DATE;
    vr_cdmodali          crapris.cdmodali%TYPE;
    vr_cdmodali2         crapris.cdmodali%TYPE;

    vr_tab_erro          cecred.gene0001.typ_tab_erro;

    vr_total_jur60       NUMBER := 0; -- RITM0130707
    vr_total_jur60_r     NUMBER := 0; -- RITM0130707

    vr_saldo_opera       NUMBER := 0; -- RITM0130707
    vr_saldo_opera_r     NUMBER := 0; -- RITM0130707

    vr_prov_perdas       NUMBER := 0; -- RITM0130707
    vr_prov_perdas_r     NUMBER := 0; -- RITM0130707

    vr_flverbor crapbdt.flverbor%TYPE;
    vr_desconsid_microcredito     NUMBER := 0;

    vr_vltotorc            crapsdc.vllanmto%type;
    vr_flgctpas            boolean; -- PASSIVO
    vr_flgctred            boolean; -- REDUTORA
    vr_flgrvorc            boolean; -- REVERSAO
    vr_dshcporc            varchar2(100);
    vr_lsctaorc            varchar2(100);
    vr_dtmvtolt_yymmdd     varchar2(6);
    vr_dshstorc            varchar2(240);

    -- PL/Table que substitui a temp-table cratorc
    type typ_cratorc is record (vr_cdagenci  crapass.cdagenci%type,
                                vr_vllanmto  crapsdc.vllanmto%type);
    -- Definição da tabela
    type typ_tab_cratorc is table of typ_cratorc index by binary_integer;
    -- Instância da tabela. O índice é o código da agência.
    vr_tab_cratorc         typ_tab_cratorc;

    -- Escrever linha no arquivo
    PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
    BEGIN
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
    END;

     -- Insere linhas de orçamento no arquivo
    procedure pc_proc_lista_orcamento is
      vr_ger_dsctaorc    varchar2(50);
      vr_pac_dsctaorc    varchar2(50);
      vr_dtmvto          date;
      vr_indice_agencia  crapass.cdagenci%type;
    BEGIN
      -- Se o valor total for igual a zero
      if vr_vltotorc = 0 THEN
        return;
      end IF;
      if vr_flgctpas then  -- PASSIVO
        if vr_flgctred then  -- REDUTORA
          if vr_flgrvorc then  -- REVERSAO
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else  -- DO DIA
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        else  -- NORMAL
          if vr_flgrvorc then  -- REVERSAO
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else  -- DO DIA
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        end if;
      else  -- ATIVO
        if vr_flgctred then  -- REDUTORA
          if vr_flgrvorc then  -- REVERSAO
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else  -- DO DIA
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        else  -- NORMAL
          if vr_flgrvorc then  -- REVERSAO
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else  -- DO DIA
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        end if;
      end if;
      -- Escolhe a data a utilizar
      if vr_flgrvorc then
        vr_dtmvto := vr_dtmvtopr;
      else
        vr_dtmvto := vr_dtmvtolt;
      end if;
      -- Inclui as informações no arquivo
      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_ger_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);

      pc_gravar_linha(vr_linhadet);

      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));

      pc_gravar_linha(vr_linhadet);
      --
      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_pac_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);

      pc_gravar_linha(vr_linhadet);

      -- Inclui informações por PA
      vr_indice_agencia := vr_tab_cratorc.first;
      -- Percorre todas as agencias
      WHILE vr_indice_agencia IS NOT NULL LOOP
        -- Se o valor de lançamentos for diferente de zero
        if vr_tab_cratorc(vr_indice_agencia).vr_vllanmto <> 0 then
          vr_linhadet := to_char(vr_tab_cratorc(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                         trim(to_char(vr_tab_cratorc(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        end if;
        -- Próximo indice(agencia)
        vr_indice_agencia := vr_tab_cratorc.next(vr_indice_agencia);
      END LOOP;

    END;

  BEGIN
    -- Data de referencia
    vr_dtrefere := to_date(pr_dtrefere, 'dd/mm/YY');

    -- Buscar as datas do sistema
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
      vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
      RAISE vr_exc_erro;
    END IF;

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
    -- vr_tab_risco('A') := 2;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('2').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('2').nrdconta := 3321;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('2').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('2').nrdconta := 3321;

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

    --RITM0134267
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('2 6901').nrdconta := 3321;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('2 6901').nrdconta := 3521;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('2 6901').nrdconta := 3321;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('2 6901').nrdconta := 3521;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('3 6901').nrdconta := 3333;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('3 6901').nrdconta := 3533;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('3 6901').nrdconta := 3333;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('3 6901').nrdconta := 3533;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('4 6901').nrdconta := 3343;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('4 6901').nrdconta := 3543;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('4 6901').nrdconta := 3343;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('4 6901').nrdconta := 3543;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('5 6901').nrdconta := 3353;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('5 6901').nrdconta := 3553;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('5 6901').nrdconta := 3353;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('5 6901').nrdconta := 3553;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('6 6901').nrdconta := 3363;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('6 6901').nrdconta := 3563;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('6 6901').nrdconta := 3363;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('6 6901').nrdconta := 3563;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('7 6901').nrdconta := 3373;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('7 6901').nrdconta := 3573;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('7 6901').nrdconta := 3373;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('7 6901').nrdconta := 3573;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('8 6901').nrdconta := 3383;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('8 6901').nrdconta := 3583;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('8 6901').nrdconta := 3383;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('8 6901').nrdconta := 3583;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('9 6901').nrdconta := 3393;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('9 6901').nrdconta := 3593;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('9 6901').nrdconta := 3393;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('9 6901').nrdconta := 3593;
    --RITM0134267 FIM

    -- ZERAR VARIAVEIS PF/PJ
    vr_rel1722_0201_v.valorpf  := 0;
    vr_rel1722_0201_v.valorpj  := 0;
    vr_rel1722_0201_v.valormei := 0;
    vr_rel1722_0201.valorpf    := 0;
    vr_rel1722_0201.valorpj    := 0;
    vr_rel1722_0201.valormei   := 0;
    vr_rel1613_0299_v.valorpf  := 0;
    vr_rel1613_0299_v.valorpj  := 0;
    vr_rel1722_0101_v.valorpf  := 0;
    vr_rel1722_0101_v.valorpj  := 0;
    vr_rel1722_0101.valorpf    := 0;
    vr_rel1722_0101.valorpj    := 0;
    vr_rel1724.valorpf         := 0;
    vr_rel1724.valorpj         := 0;
    vr_rel1724_v.valorpf       := 0;
    vr_rel1724_v.valorpj       := 0;
    vr_rel1724_bdt.valorpf     := 0;
    vr_rel1724_bdt.valorpj     := 0;

    -- CRAPTAB -> 'PROVISAOCL'
    FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
      vr_contador                         := substr(rw_craptab.dstextab, 12, 2);
      vr_rel_dsdrisco(vr_contador).dsc    := TRIM(substr(rw_craptab.dstextab, 8, 3));
      vr_rel_percentu(vr_contador).valor  := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
    END LOOP;

    FOR rw_tabmicro IN cr_tabmicro(pr_cdcooper) LOOP
         -- Inicializa tabela de Microcrédito vr_price_pre||vr_price_pf;
        vr_arrchave1 := vr_price_pre||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_pre||vr_price_pj;
        vr_arrchave1 := vr_price_pre||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pf;
        vr_arrchave1 := vr_price_atr||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        -- Inicializa tabela de Microcrédito vr_price_atr||vr_price_pj;
        vr_arrchave1 := vr_price_atr||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        -- Inicializa tabela juros +60
        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

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
      vr_vljuro_suspenso := 0;
      vr_valjur60 := 0;

      --> Necessario acrescentar valor da do juros + 60 no ADP,
      -- visto que este valor não é apresentado nos vencimentos
      IF rw_crapris.cdorigem = 1 THEN
        vr_vldivida := vr_vldivida + nvl(rw_crapris.vljura60,0);
      END IF;

      --inclusao para somar a coluna de juros vljurantpp INC0112944(diferenca contabil)
      vr_valjur60 := nvl(rw_crapris.vljura60,0) + nvl(rw_crapris.vljurantpp,0);
      vr_flsomjur := 0;

      -- Percorrer os valores do risco
      FOR rw_crapvri IN cr_crapvri(pr_cdcooper,
                                   rw_crapris.nrdconta,
                                   rw_crapris.dtrefere,
                                   rw_crapris.cdmodali,
                                   rw_crapris.nrctremp,
                                   rw_crapris.nrseqctr,
                                   rw_crapris.vldivida) LOOP

        -- Variáveis auxiliares para regras do risco
        vr_contador := 0;
        vr_flsoavto := TRUE;

        -- Se código do vencimento estiver entre 110 e 290
        IF  rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vldivida := vr_vldivida + NVL(rw_crapvri.vldivida,0);
        ELSIF rw_crapvri.cdvencto IN (310,320,330) THEN -- Se for 310, 320 ou 330
          vr_vlprejuz_conta := vr_vlprejuz_conta + NVL(rw_crapvri.vldivida,0);
        END IF;

        IF rw_crapvri.nrseqreg = rw_crapvri.qtreggar THEN
          rw_juros60_vri := null;
          OPEN cr_juros60_vri(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapris.nrdconta
                             ,pr_dtrefere => rw_crapris.dtrefere
                             ,pr_nrctremp => rw_crapris.nrctremp
                             ,pr_nrseqctr => rw_crapris.nrseqctr);
          FETCH cr_juros60_vri INTO rw_juros60_vri;
          vr_vldivida := vr_vldivida + nvl(rw_juros60_vri.vljura60,0) + nvl(rw_juros60_vri.vljurantpp,0);
          vr_vljuro_suspenso := nvl(rw_juros60_vri.vljura60,0) + nvl(rw_juros60_vri.vljurantpp,0);
          CLOSE cr_juros60_vri;
        END IF;

        --> para contratos de ADP em prejuizo não deve reconhecer a divida
        IF rw_crapris.cdmodali = 0101 AND
           rw_crapris.innivris = 10   THEN
          vr_vldivida := 0;
        END IF;

        ----- Gerando Valores Para Contabilizacao (RISCO) ---
        IF  rw_crapvri.cdvencto BETWEEN 110 AND 205 THEN -- nao se considerar a vencer porque tem vencidas

          -- Buscar valores do risco
          OPEN cr_crabvri(pr_cdcooper,
                          rw_crapvri.nrdconta,
                          rw_crapvri.dtrefere,
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
        IF rw_crapris.innivris IN (1,2) THEN
          vr_contador := rw_crapris.innivris;
        ELSIF rw_crapvri.cdvencto BETWEEN 110 AND 205 AND vr_flsoavto AND -- A vencer
              nvl(rw_crapris.nracordo,0) = 0 THEN
          -- Verificar nível de risco
          IF rw_crapris.innivris = 3 THEN
            vr_contador := 3;
          ELSIF rw_crapris.innivris = 4 THEN
            vr_contador := 5;
          ELSIF rw_crapris.innivris = 5 THEN
            vr_contador := 7;
          ELSIF rw_crapris.innivris = 6 THEN
            vr_contador := 9;
          ELSIF rw_crapris.innivris = 7 THEN
            vr_contador := 11;
          ELSIF rw_crapris.innivris = 8 THEN
            vr_contador := 13;
          ELSE
            vr_contador := 15;
          END IF;
        ELSE
          -- Verificar nível de risco
          IF rw_crapris.innivris = 3 THEN
            vr_contador := 4;
          ELSIF rw_crapris.innivris = 4 THEN
            vr_contador := 6;
          ELSIF rw_crapris.innivris = 5 THEN
            vr_contador := 8;
          ELSIF rw_crapris.innivris = 6 THEN
            vr_contador := 10;
          ELSIF rw_crapris.innivris = 7 THEN
            vr_contador := 12;
          ELSIF rw_crapris.innivris = 8 THEN
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
          vr_rel_vldivida(vr_contador).valor := nvl(vr_rel_vldivida(vr_contador).valor, 0) + rw_crapvri.vldivida;
        ELSE
          vr_rel_vldivida(vr_contador).valor := rw_crapvri.vldivida;
        END IF;

        IF rw_crapvri.nrseqreg = rw_crapvri.qtreggar THEN
          vr_rel_vldivida(vr_contador).valor := nvl(vr_rel_vldivida(vr_contador).valor, 0) + nvl(rw_juros60_vri.vljura60,0) + nvl(rw_juros60_vri.vljurantpp,0);
        END IF;

        -- Verifica se é prejuizo para Contabilidade
        IF rw_crapvri.cdvencto IN (310,320,330) THEN
          CONTINUE; -- Desprezar prejuizo - para Contabilidade
        END IF;

        --> P450 - Se a modalidade é 0101, soma o valor dos juros +60 aos saldos devedores,
        --> pois a CRAPVRI é alimentada para esta modalidade somente com o valor do
        --> aldo devedor até 59 dias de atraso (sem os juros +60)

        IF vr_vldevedo.exists(vr_contador) THEN
          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapvri.vldivida;
        ELSE
          vr_vldevedo(vr_contador) := rw_crapvri.vldivida;
        END IF;

        IF rw_crapvri.nrseqreg = rw_crapvri.qtreggar THEN
          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + nvl(rw_juros60_vri.vljura60,0) + nvl(rw_juros60_vri.vljurantpp,0);
        END IF;

        IF rw_crapris.cdmodali = 101 AND
           vr_flsomjur = 0 AND
           rw_crapris.vljura60 > 0
           THEN

          vr_flsomjur := 1;

          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapris.vljura60;
          vr_rel_vldivida(vr_contador).valor := vr_rel_vldivida(vr_contador).valor + rw_crapris.vljura60;
        END IF;
      END LOOP;  -- Fim do LOOP da cr_crapvri

      -- Reinicializa a variável
      vr_contador := rw_crapris.innivris;

      -- Nao provisionar prejuizo
      IF vr_vlprejuz_conta = (rw_crapris.vldivida + vr_vljuro_suspenso) THEN
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
      AND rw_crapris.cdmodali = 101 THEN
        OPEN cr_crapsda(pr_cdcooper => rw_crapris.cdcooper
                       ,pr_nrdconta => rw_crapris.nrdconta
                       ,pr_dtmvtolt => gene0005.fn_valida_dia_util(pr_cdcooper => rw_crapris.cdcooper
                                                                  ,pr_dtmvtolt => rw_crapris.dtrefere
                                                                  ,pr_tipo => 'A'));
        FETCH cr_crapsda INTO rw_crapsda;
        vr_vldivida_sldblq := nvl(rw_crapsda.vlbloque, 0);
        CLOSE cr_crapsda;

        IF vr_vldivida_sldblq > 0 THEN
          IF vr_vldivida < vr_vldivida_sldblq THEN
            vr_vldivida_sldblq := vr_vldivida;
          END IF;
        END IF;
      ELSE
        vr_vldivida_sldblq := 0;
      END IF;

      -- Calculo da provisao do risco atual
      vr_vlpreatr := round((rw_crapris.vldivida *  vr_vlpercen), 2);
      GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => rw_crapris.cdcooper,
                                               pr_nrdconta => rw_crapris.nrdconta,
                                               pr_nrctremp => rw_crapris.nrctremp,
                                               pr_cdmodali => rw_crapris.cdmodali,
                                               pr_vlpreatr => vr_vlpreatr,
                                               pr_dscritic => vr_dscritic);

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

          IF cr_crapebn%NOTFOUND THEN

            --verifica se eh uma operacao do Imobiliario
            OPEN cr_imob(rw_crapris.cdcooper,
                         rw_crapris.nrdconta,
                         rw_crapris.nrctremp);

            FETCH cr_imob INTO rw_imob;

            -- Se nao for do Imobiliario e nao existir na crapebn e crapepr, continua
            IF cr_imob%NOTFOUND THEN

              CLOSE cr_imob;
            CLOSE cr_crapebn;
            CLOSE cr_crapepr;
            CONTINUE;
          END IF;

            CLOSE cr_imob;
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

            ELSIF rw_imob.modelo_aquisicao_completo IS NOT NULL AND
                  TRIM(rw_crapris.dsinfaux) = 'IMOBILIARIO' THEN

              vr_rel1721_imob   := vr_rel1721_imob   + vr_vlpreatr;
              vr_rel1721_v_imob := vr_rel1721_v_imob + vr_vldivida;

              IF vr_vlag1721_imob.exists(rw_crapris.cdagenci) THEN
                vr_vlag1721_imob(rw_crapris.cdagenci).valor := vr_vlag1721_imob(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1721_imob(rw_crapris.cdagenci).valor := vr_vlpreatr;
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

            ELSIF rw_imob.modelo_aquisicao_completo IS NOT NULL AND
                  TRIM(rw_crapris.dsinfaux) = 'IMOBILIARIO' THEN

              vr_rel1723_imob   := vr_rel1723_imob   + vr_vlpreatr;
              vr_rel1723_v_imob := vr_rel1723_v_imob + vr_vldivida;

              IF vr_vlag1723_imob.exists(rw_crapris.cdagenci) THEN
                vr_vlag1723_imob(rw_crapris.cdagenci).valor := vr_vlag1723_imob(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1723_imob(rw_crapris.cdagenci).valor := vr_vlpreatr;
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

        --verifica se e uma operacao que deve ser desconsiderada do microcredito
        vr_desconsid_microcredito := 0;
        OPEN cr_crapebn_desconsid_microcred(rw_crapris.cdcooper,
                               rw_crapris.nrdconta,
                               rw_crapris.nrctremp);
        FETCH cr_crapebn_desconsid_microcred INTO vr_desconsid_microcredito;
        CLOSE cr_crapebn_desconsid_microcred;

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

               -- Acumulador de TR Pessoa Fisica | Desconsidera Microcrédito
               IF vr_desconsid_microcredito = 1 THEN
                 vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
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

               -- Acumulador PRE Pessoa Fisica | Desconsidera Microcrédito
               IF vr_desconsid_microcredito = 1 THEN
                 vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
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

               -- Acumulador TR Pessoa Juridica
                  vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               -- Acumulador de TR PJ +60
                  vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
                  vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;

               -- Acumulador TR Pessoa Juridica  | Desconsidera Microcrédito
               IF vr_desconsid_microcredito = 1 THEN
                  vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
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

               -- Acumulador PRE Pessoa Juridica | Desconsidera Microcrédito
               IF vr_desconsid_microcredito = 1 THEN
                  vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
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

            if nvl(rw_crapris.tpregtrb,0) = 4 then
              vr_rel1722_0201.valormei   := vr_rel1722_0201.valormei   + vr_vlpreatr;
              vr_rel1722_0201_v.valormei := vr_rel1722_0201_v.valormei + vr_vldivida;
            end if;

            IF vr_vlag0201_1722_v.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj,0) + vr_vldivida;

              if nvl(rw_crapris.tpregtrb,0) = 4 then
                vr_vlag0201_1722_v(rw_crapris.cdagenci).valormei := NVL(vr_vlag0201_1722_v(rw_crapris.cdagenci).valormei,0) + vr_vldivida;
              end if;
            ELSE
              vr_vlag0201_1722_v(rw_crapris.cdagenci).valorpj := vr_vldivida;

              if nvl(rw_crapris.tpregtrb,0) = 4 then
                vr_vlag0201_1722_v(rw_crapris.cdagenci).valormei := vr_vldivida;
              end if;
            END IF;

            IF vr_vlag0201.exists(rw_crapris.cdagenci) THEN
              vr_vlag0201(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0201(rw_crapris.cdagenci).valorpj,0) + vr_vlpreatr;

              if nvl(rw_crapris.tpregtrb,0) = 4 then
                vr_vlag0201(rw_crapris.cdagenci).valormei := NVL(vr_vlag0201(rw_crapris.cdagenci).valormei,0) + vr_vlpreatr;
              end if;
            ELSE
              vr_vlag0201(rw_crapris.cdagenci).valorpj := vr_vlpreatr;

              if nvl(rw_crapris.tpregtrb,0) = 4 then
                vr_vlag0201(rw_crapris.cdagenci).valormei := vr_vlpreatr;
              end if;
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

      -- Se pessoa física - Credito Imobiliario
      IF rw_crapris.inpessoa = 1 THEN  -- Pessoa fisica
        IF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFH' AND rw_crapris.cdmodali IN (901,902,903,990)  THEN
          -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
          vr_vlatr_imobi_sfh_pf   := vr_vlatr_imobi_sfh_pf + vr_vlpreatr;
          vr_vlatr_imobi_v_sfh_pf := vr_vlatr_imobi_v_sfh_pf + vr_vldivida;

          -- armazena também o valor em atraso por agência
          IF vr_vlatrage_imob_sfh_pf.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;

        ELSIF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFI' AND rw_crapris.cdmodali IN (901,902,903,990) THEN
          -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
          vr_vlatr_imobi_sfi_pf   := vr_vlatr_imobi_sfi_pf + vr_vlpreatr;
          vr_vlatr_imobi_v_sfi_pf := vr_vlatr_imobi_v_sfi_pf + vr_vldivida;

          -- armazena também o valor em atraso por agência
          IF vr_vlatrage_imob_sfi_pf.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;

        ELSIF rw_crapris.cdorigem = 3 AND
              rw_crapris.cdmodali = 0211 AND
              rw_imob.modelo_aquisicao_completo IS NOT NULL AND
              TRIM(rw_crapris.dsinfaux) = 'IMOBILIARIO' THEN -- Home equity
             -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
              vr_vlatr_imobi_home_equity_pf   := vr_vlatr_imobi_home_equity_pf + vr_vlpreatr;
              vr_vlatr_imobi_v_home_equity_pf := vr_vlatr_imobi_v_home_equity_pf + vr_vldivida;

              -- armazena também o valor em atraso por agência
              IF vr_vlatrage_imob_home_equity_pf.exists(rw_crapris.cdagenci) THEN
                vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;
        END IF;
      ELSE -- Pessoa Jurídica
        IF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFH' AND rw_crapris.cdmodali IN (901,902,903,990) THEN
          -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
          vr_vlatr_imobi_sfh_pj   := vr_vlatr_imobi_sfh_pj + vr_vlpreatr;
          vr_vlatr_imobi_v_sfh_pj := vr_vlatr_imobi_v_sfh_pj + vr_vldivida;

          -- armazena também o valor em atraso por agência
          IF vr_vlatrage_imob_sfh_pj.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;

        ELSIF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFI' AND rw_crapris.cdmodali IN (901,902,903,990) THEN
          -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
          vr_vlatr_imobi_sfi_pj   := vr_vlatr_imobi_sfi_pj + vr_vlpreatr;
          vr_vlatr_imobi_v_sfi_pj := vr_vlatr_imobi_v_sfi_pj + vr_vldivida;
          -- armazena também o valor em atraso por agência
          IF vr_vlatrage_imob_sfi_pj.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;
          END IF;

        END IF;
      END IF;

      -- Terreno
      IF rw_crapris.cdorigem = 3 AND
         rw_imob.modelo_aquisicao = 'SFI' AND
         rw_crapris.cdmodali = 902 AND
         INSTR(rw_imob.modelo_aquisicao_completo,'TERRENO') > 0 THEN
       -- totalizar em uma nova variável o valor  em atraso(vr_vlpreatr).
        vr_vlatr_imobi_terreno_pf_pj   := vr_vlatr_imobi_terreno_pf_pj + vr_vlpreatr;
        vr_vlatr_imobi_v_terreno_pf_pj := vr_vlatr_imobi_v_terreno_pf_pj + vr_vldivida;

        -- armazena também o valor em atraso por agência
        IF vr_vlatrage_imob_terreno_pf_pj.exists(rw_crapris.cdagenci) THEN
           vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
        ELSE
           vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;
        END IF;
      END IF;
      --fim imobiliario

    END LOOP; -- FIM LOOP crapris

    -- Carrega Data Corte 1902 - Carta Circular 4062
    gestaoderisco.buscaDataCorteLimite1902(pr_cdcooper => pr_cdcooper,
                                           pr_dtdcorte => vr_datacorte_1902,
                                           pr_dscritic => vr_dscritic);
    -- Carrega Data Corte 1902 - Carta Circular
    IF vr_dtrefere >= vr_datacorte_1902 THEN
      -- Se for maior que a data de corte, assumir 1902
      vr_cdmodali := 1902;
      vr_cdmodali2 := 1909;
    ELSE
      vr_cdmodali := 1901;
    END IF;

    -- TOTALIZAR  LIMITE NAO UTILIZADO
    FOR rw_crapris_lnu IN cr_crapris_lnu(pr_cdcooper,
                                         vr_dtrefere,
                                         vr_cdmodali,
                                         vr_cdmodali2) LOOP

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
    vr_vlmrapar2.valorpf := 0; -- P577
    vr_vlmrapar2.valorpj := 0; -- P577
    vr_fimrapar2.valorpf := 0; -- P577
    vr_fimrapar2.valorpj := 0; -- P577
    vr_vljuropp2.valorpf := 0; -- P577
    vr_vljuropp2.valorpj := 0; -- P577
    vr_fijuropp2.valorpf := 0; -- P577
    vr_fijuropp2.valorpj := 0; -- P577
    vr_vlmultpp2.valorpf := 0; -- P577
    vr_vlmultpp2.valorpj := 0; -- P577
    vr_fimultpp2.valorpf := 0; -- P577
    vr_fimultpp2.valorpj := 0; -- P577
    vr_finjuros.valorpf  := 0;
    vr_finjuros.valorpj  := 0;
    vr_finjuros2.valorpf := 0;
    vr_finjuros2.valorpj := 0;
    vr_vldjuros6.valorpf := 0;
    vr_vldjuros6.valorpj := 0;
    vr_finjuros6.valorpf := 0;
    vr_finjuros6.valorpj := 0;
    vr_vlmrapar6.valorpf := 0; -- PRJ298.3
    vr_vlmrapar6.valorpj := 0; -- PRJ298.3
    vr_fimrapar6.valorpf := 0; -- PRJ298.3
    vr_fimrapar6.valorpj := 0; -- PRJ298.3
    vr_vljuremu6.valorpf := 0; -- PRJ298.3
    vr_vljuremu6.valorpj := 0; -- PRJ298.3
    vr_fijuremu6.valorpf := 0; -- PRJ298.3
    vr_fijuremu6.valorpj := 0; -- PRJ298.3
    vr_vljurcor6.valorpf := 0; -- PRJ298.3
    vr_vljurcor6.valorpj := 0; -- PRJ298.3
    vr_fijurcor6.valorpf := 0; -- PRJ298.3
    vr_fijurcor6.valorpj := 0; -- PRJ298.3

    vr_juros38df.valorpf  :=0;
    vr_juros38df.valorpj  :=0;
    vr_juros38df.valormei :=0;
    vr_juros38da.valorpf  :=0;
    vr_juros38da.valorpj  :=0;
    vr_juros38da.valormei :=0;
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
                          ,pr_tabvljur8 => vr_pacvljur_8     --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
                          ,pr_tabvljur9 => vr_pacvljur_9     --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
                          ,pr_tabvljur10 => vr_pacvljur_10   --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
                          ,pr_tabvljur11 => vr_pacvljur_11   --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
                          ,pr_tabvljur12 => vr_pacvljur_12   --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
                          ,pr_tabvljur13 => vr_pacvljur_13   --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
                          ,pr_tabvljur14 => vr_pacvljur_14   --> PP - Modalidade 299 - Por PA - Juros Mora - P577
                          ,pr_tabvljur15 => vr_pacvljur_15   --> PP - Modalidade 499 - Por PA - Juros Mora - P577
                          ,pr_tabvljur16 => vr_pacvljur_16   --> PP - Modalidade 299 - Por PA - Juros - P577
                          ,pr_tabvljur17 => vr_pacvljur_17   --> PP - Modalidade 499 - Por PA - Juros - P577
                          ,pr_tabvljur18 => vr_pacvljur_18   --> PP - Modalidade 299 - Por PA - Multa - P577
                          ,pr_tabvljur19 => vr_pacvljur_19   --> PP - Modalidade 499 - Por PA - Multa - P577

                          ,pr_tabvljur20 => vr_pacvljur_20   --> PP - Modalidade 299 - Por PA - Juros Correção - P577
                          ,pr_tabvljur21 => vr_pacvljur_21   --> PP - Modalidade 499 - Por PA - Juros Correção - P577
                          ,pr_tabvljur22 => vr_pacvljur_22   --> POS - Modalidade 299 - Por PA - Multa - P577
                          ,pr_tabvljur23 => vr_pacvljur_23   --> POS - Modalidade 499 - Por PA - Multa - P577

                          ,pr_vlrjuros  => vr_vldjur_calc    --> TR - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros  => vr_finjur_calc    --> TR - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros2 => vr_vldjur_calc2   --> PP - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros2 => vr_finjur_calc2   --> PP - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros3 => vr_vldjur_calc3   --> PP – Cessao - Por Tipo pessoa.
                          ,pr_vlrjuros6 => vr_vldjur_calc6   --> POS - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros6 => vr_finjur_calc6   --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlmrapar6 => vr_vlmrapar_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                          ,pr_fimrapar6 => vr_fimrapar_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                          ,pr_vljuremu6 => vr_vljuremu_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                          ,pr_fijuremu6 => vr_fijuremu_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                          ,pr_vljurcor6 => vr_vljurcor_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
                          ,pr_fijurcor6 => vr_fijurcor_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3

                          ,pr_vljurmta6 => vr_vljurmta_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PJ577
                          ,pr_fijurmta6 => vr_fijurmta_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PJ577

                          ,pr_vlmrapar2 => vr_vlmrap_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
                          ,pr_fimrapar2 => vr_fimrap_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
                          ,pr_vljuropp2 => vr_vljuro_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
                          ,pr_fijuropp2 => vr_fijuro_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
                          ,pr_vlmultpp2 => vr_vlmult_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
                          ,pr_fimultpp2 => vr_fimult_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
                          ,pr_vljurcor2 => vr_vljuco_calc2           --> PJ577
                          ,pr_fijurcor2 => vr_fijuco_calc2           --> PJ577
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
    -- Segragacao PP
    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; -- P577
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; -- P577
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; -- P577
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; -- P577
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; -- P577
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; -- P577
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; -- P577
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; -- P577
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; -- P577
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; -- P577
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; -- P577
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; -- P577
    -- Produto Pos Fixado
    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;
    vr_vlmrapar6.valorpf := vr_vlmrapar6.valorpf + vr_vlmrapar_calc6.valorpf; -- PRJ298.3
    vr_vlmrapar6.valorpj := vr_vlmrapar6.valorpj + vr_vlmrapar_calc6.valorpj; -- PRJ298.3
    vr_fimrapar6.valorpf := vr_fimrapar6.valorpf + vr_fimrapar_calc6.valorpf; -- PRJ298.3
    vr_fimrapar6.valorpj := vr_fimrapar6.valorpj + vr_fimrapar_calc6.valorpj; -- PRJ298.3
    vr_vljuremu6.valorpf := vr_vljuremu6.valorpf + vr_vljuremu_calc6.valorpf; -- PRJ298.3
    vr_vljuremu6.valorpj := vr_vljuremu6.valorpj + vr_vljuremu_calc6.valorpj; -- PRJ298.3
    vr_fijuremu6.valorpf := vr_fijuremu6.valorpf + vr_fijuremu_calc6.valorpf; -- PRJ298.3
    vr_fijuremu6.valorpj := vr_fijuremu6.valorpj + vr_fijuremu_calc6.valorpj; -- PRJ298.3
    vr_vljurcor6.valorpf := vr_vljurcor6.valorpf + vr_vljurcor_calc6.valorpf; -- PRJ298.3
    vr_vljurcor6.valorpj := vr_vljurcor6.valorpj + vr_vljurcor_calc6.valorpj; -- PRJ298.3
    vr_fijurcor6.valorpf := vr_fijurcor6.valorpf + vr_fijurcor_calc6.valorpf; -- PRJ298.3
    vr_fijurcor6.valorpj := vr_fijurcor6.valorpj + vr_fijurcor_calc6.valorpj; -- PRJ298.3

    vr_vljurmta6.valorpf := vr_vljurmta6.valorpf + vr_vljurmta_calc6.valorpf; -- PJ577
    vr_vljurmta6.valorpj := vr_vljurmta6.valorpj + vr_vljurmta_calc6.valorpj; -- PJ577
    vr_fijurmta6.valorpf := vr_fijurmta6.valorpf + vr_fijurmta_calc6.valorpf; -- PJ577
    vr_fijurmta6.valorpj := vr_fijurmta6.valorpj + vr_fijurmta_calc6.valorpj; -- PJ577

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
                         ,pr_tabvljur8 => vr_pacvljur_8       --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
                         ,pr_tabvljur9 => vr_pacvljur_9       --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
                         ,pr_tabvljur10 => vr_pacvljur_10     --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
                         ,pr_tabvljur11 => vr_pacvljur_11     --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
                         ,pr_tabvljur12 => vr_pacvljur_12     --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
                         ,pr_tabvljur13 => vr_pacvljur_13     --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
                         ,pr_tabvljur14 => vr_pacvljur_14   --> PP - Modalidade 299 - Por PA - Juros Mora - P577
                         ,pr_tabvljur15 => vr_pacvljur_15   --> PP - Modalidade 499 - Por PA - Juros Mora - P577
                         ,pr_tabvljur16 => vr_pacvljur_16   --> PP - Modalidade 299 - Por PA - Juros - P577
                         ,pr_tabvljur17 => vr_pacvljur_17   --> PP - Modalidade 499 - Por PA - Juros - P577
                         ,pr_tabvljur18 => vr_pacvljur_18   --> PP - Modalidade 299 - Por PA - Multa - P577
                         ,pr_tabvljur19 => vr_pacvljur_19   --> PP - Modalidade 499 - Por PA - Multa - P577

                         ,pr_tabvljur20 => vr_pacvljur_20   --> PP - Modalidade 299 - Por PA - Juros Correção - P577
                         ,pr_tabvljur21 => vr_pacvljur_21   --> PP - Modalidade 499 - Por PA - Juros Correção - P577
                         ,pr_tabvljur22 => vr_pacvljur_22   --> POS - Modalidade 299 - Por PA - Multa - P577
                         ,pr_tabvljur23 => vr_pacvljur_23   --> POS - Modalidade 499 - Por PA - Multa - P577

                         ,pr_vlrjuros  => vr_vldjur_calc      --> TR  - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros  => vr_finjur_calc      --> TR  - Modalidade 499 - Por Tipo pessoa.
                         ,pr_vlrjuros2 => vr_vldjur_calc2     --> PP  - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros2 => vr_finjur_calc2     --> PP  - Modalidade 499 - Por Tipo pessoa.
                         ,pr_vlrjuros3 => vr_vldjur_calc3     --> PP  – Cessao - Por Tipo pessoa.
                         ,pr_vlrjuros6 => vr_vldjur_calc6     --> POS - Modalidade 299 - Por Tipo pessoa.
                         ,pr_finjuros6 => vr_finjur_calc6     --> POS - Modalidade 499 - Por Tipo pessoa.
                         ,pr_vlmrapar6 => vr_vlmrapar_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                         ,pr_fimrapar6 => vr_fimrapar_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                         ,pr_vljuremu6 => vr_vljuremu_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                         ,pr_fijuremu6 => vr_fijuremu_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                         ,pr_vljurcor6 => vr_vljurcor_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
                         ,pr_fijurcor6 => vr_fijurcor_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3

                         ,pr_vljurmta6 => vr_vljurmta_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PJ577
                         ,pr_fijurmta6 => vr_fijurmta_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PJ577

                         ,pr_vlmrapar2 => vr_vlmrap_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
                         ,pr_fimrapar2 => vr_fimrap_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
                         ,pr_vljuropp2 => vr_vljuro_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
                         ,pr_fijuropp2 => vr_fijuro_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
                         ,pr_vlmultpp2 => vr_vlmult_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
                         ,pr_fimultpp2 => vr_fimult_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
                         ,pr_vljurcor2 => vr_vljuco_calc2           --> PJ577
                         ,pr_fijurcor2 => vr_fijuco_calc2           --> PJ577
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
    -- Segragacao PP
    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; -- P577
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; -- P577
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; -- P577
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; -- P577
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; -- P577
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; -- P577
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; -- P577
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; -- P577
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; -- P577
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; -- P577
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; -- P577
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; -- P577
    -- Produto Pos Fixado
    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;
    vr_vlmrapar6.valorpf := vr_vlmrapar6.valorpf + vr_vlmrapar_calc6.valorpf; -- PRJ298.3
    vr_vlmrapar6.valorpj := vr_vlmrapar6.valorpj + vr_vlmrapar_calc6.valorpj; -- PRJ298.3
    vr_fimrapar6.valorpf := vr_fimrapar6.valorpf + vr_fimrapar_calc6.valorpf; -- PRJ298.3
    vr_fimrapar6.valorpj := vr_fimrapar6.valorpj + vr_fimrapar_calc6.valorpj; -- PRJ298.3
    vr_vljuremu6.valorpf := vr_vljuremu6.valorpf + vr_vljuremu_calc6.valorpf; -- PRJ298.3
    vr_vljuremu6.valorpj := vr_vljuremu6.valorpj + vr_vljuremu_calc6.valorpj; -- PRJ298.3
    vr_fijuremu6.valorpf := vr_fijuremu6.valorpf + vr_fijuremu_calc6.valorpf; -- PRJ298.3
    vr_fijuremu6.valorpj := vr_fijuremu6.valorpj + vr_fijuremu_calc6.valorpj; -- PRJ298.3
    vr_vljurcor6.valorpf := vr_vljurcor6.valorpf + vr_vljurcor_calc6.valorpf; -- PRJ298.3
    vr_vljurcor6.valorpj := vr_vljurcor6.valorpj + vr_vljurcor_calc6.valorpj; -- PRJ298.3
    vr_fijurcor6.valorpf := vr_fijurcor6.valorpf + vr_fijurcor_calc6.valorpf; -- PRJ298.3
    vr_fijurcor6.valorpj := vr_fijurcor6.valorpj + vr_fijurcor_calc6.valorpj; -- PRJ298.3

    vr_vljurmta6.valorpf := vr_vljurmta6.valorpf + vr_vljurmta_calc6.valorpf; -- PRJ298.3
    vr_vljurmta6.valorpj := vr_vljurmta6.valorpj + vr_vljurmta_calc6.valorpj; -- PRJ298.3
    vr_fijurmta6.valorpf := vr_fijurmta6.valorpf + vr_fijurmta_calc6.valorpf; -- PRJ298.3
    vr_fijurmta6.valorpj := vr_fijurmta6.valorpj + vr_fijurmta_calc6.valorpj; -- PRJ298.3

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
                          ,pr_tabvljur8 => vr_pacvljur_8       --> POS - Modalidade 299 - Por PA - Juros Mora - PRJ298.3
                          ,pr_tabvljur9 => vr_pacvljur_9       --> POS - Modalidade 499 - Por PA - Juros Mora - PRJ298.3
                          ,pr_tabvljur10 => vr_pacvljur_10     --> POS - Modalidade 299 - Por PA - Juros Remuneratorio - PRJ298.3
                          ,pr_tabvljur11 => vr_pacvljur_11     --> POS - Modalidade 499 - Por PA - Juros Remuneratorio - PRJ298.3
                          ,pr_tabvljur12 => vr_pacvljur_12     --> POS - Modalidade 299 - Por PA - Juros Correcao - PRJ298.3
                          ,pr_tabvljur13 => vr_pacvljur_13     --> POS - Modalidade 499 - Por PA - Juros Correcao - PRJ298.3
                          ,pr_tabvljur14 => vr_pacvljur_14   --> PP - Modalidade 299 - Por PA - Juros Mora - P577
                          ,pr_tabvljur15 => vr_pacvljur_15   --> PP - Modalidade 499 - Por PA - Juros Mora - P577
                          ,pr_tabvljur16 => vr_pacvljur_16   --> PP - Modalidade 299 - Por PA - Juros - P577
                          ,pr_tabvljur17 => vr_pacvljur_17   --> PP - Modalidade 499 - Por PA - Juros - P577
                          ,pr_tabvljur18 => vr_pacvljur_18   --> PP - Modalidade 299 - Por PA - Multa - P577
                          ,pr_tabvljur19 => vr_pacvljur_19   --> PP - Modalidade 499 - Por PA - Multa - P577

                          ,pr_tabvljur20 => vr_pacvljur_20   --> PP - Modalidade 299 - Por PA - Juros Correção - P577
                          ,pr_tabvljur21 => vr_pacvljur_21   --> PP - Modalidade 499 - Por PA - Juros Correção - P577
                          ,pr_tabvljur22 => vr_pacvljur_22   --> POS - Modalidade 299 - Por PA - Multa - P577
                          ,pr_tabvljur23 => vr_pacvljur_23   --> POS - Modalidade 499 - Por PA - Multa - P577

                          ,pr_vlrjuros  => vr_vldjur_calc    --> TR - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros  => vr_finjur_calc    --> TR - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros2 => vr_vldjur_calc2   --> PP - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros2 => vr_finjur_calc2   --> PP - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlrjuros3 => vr_vldjur_calc3   --> PP – Cessao - Por Tipo pessoa.
                          ,pr_vlrjuros6 => vr_vldjur_calc6   --> POS - Modalidade 299 - Por Tipo pessoa.
                          ,pr_finjuros6 => vr_finjur_calc6  --> POS - Modalidade 499 - Por Tipo pessoa.
                          ,pr_vlmrapar6 => vr_vlmrapar_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                          ,pr_fimrapar6 => vr_fimrapar_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Mora -- PRJ298.3
                          ,pr_vljuremu6 => vr_vljuremu_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                          ,pr_fijuremu6 => vr_fijuremu_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Remuneratorio -- PRJ298.3
                          ,pr_vljurcor6 => vr_vljurcor_calc6   --> POS - Modalidade 299 - Por Tipo pessoa - Juros Correcao -- PRJ298.3
                          ,pr_fijurcor6 => vr_fijurcor_calc6   --> POS - Modalidade 499 - Por Tipo pessoa - Juros Correcao -- PRJ298.3

                          ,pr_vljurmta6 => vr_vljurmta_calc6 --> POS - Modalidade 299 - Por Tipo pessoa - Multa -- PJ577
                          ,pr_fijurmta6 => vr_fijurmta_calc6 --> POS - Modalidade 499 - Por Tipo pessoa - Multa -- PJ577

                          ,pr_vlmrapar2 => vr_vlmrap_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros Mora -- P577
                          ,pr_fimrapar2 => vr_fimrap_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros Mora -- P577
                          ,pr_vljuropp2 => vr_vljuro_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Juros -- P577
                          ,pr_fijuropp2 => vr_fijuro_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Juros -- P577
                          ,pr_vlmultpp2 => vr_vlmult_calc2   --> PP - Modalidade 299 - Por Tipo pessoa - Multa -- P577
                          ,pr_fimultpp2 => vr_fimult_calc2   --> PP - Modalidade 499 - Por Tipo pessoa - Multa -- P577
                          ,pr_vljurcor2 => vr_vljuco_calc2           --> PJ577
                          ,pr_fijurcor2 => vr_fijuco_calc2           --> PJ577
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

    -- Segragacao PP
    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; -- P577
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; -- P577
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; -- P577
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; -- P577
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; -- P577
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; -- P577
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; -- P577
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; -- P577
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; -- P577
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; -- P577
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; -- P577
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; -- P577

    --Cessao credito
    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

    --Conta Corrente
    vr_juros38df.valorpj  := vr_juros38df.valorpj  + vr_juros38df_calc.valorpj;
    vr_juros38df.valorpf  := vr_juros38df.valorpf  + vr_juros38df_calc.valorpf;
    vr_juros38df.valormei := vr_juros38df.valormei + vr_juros38df_calc.valormei;
    vr_juros38da.valorpj  := vr_juros38da.valorpj  + vr_juros38da_calc.valorpj;
    vr_juros38da.valorpf  := vr_juros38da.valorpf  + vr_juros38da_calc.valorpf;
    vr_juros38da.valormei := vr_juros38da.valormei + vr_juros38da_calc.valormei;

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

    -- imobiliario
    vr_vldespes(39) := vr_vlatr_imobi_sfh_pf;
    vr_vldevedo(39) := vr_vlatr_imobi_v_sfh_pf;

    vr_vldespes(40) := vr_vlatr_imobi_sfi_pf;
    vr_vldevedo(40) := vr_vlatr_imobi_v_sfi_pf;

    vr_vldespes(41) := vr_vlatr_imobi_sfh_pj;
    vr_vldevedo(41) := vr_vlatr_imobi_v_sfh_pj;

    vr_vldespes(42) := vr_vlatr_imobi_sfi_pj;
    vr_vldevedo(42) := vr_vlatr_imobi_v_sfi_pj;

    vr_vldespes(43) := vr_vlatr_imobi_home_equity_pf; -- Home Equity - PF
    vr_vldevedo(43) := vr_vlatr_imobi_v_home_equity_pf; -- Home Equity - PF

    vr_vldespes(44) := vr_rel1721_imob; -- Emprestimo Garantido - PF
    vr_vldevedo(44) := vr_rel1721_v_imob; -- Emprestimo Garantido - PF

    vr_vldespes(45) := vr_rel1723_imob; -- Emprestimo Garantido - PJ
    vr_vldevedo(45) := vr_rel1723_v_imob; -- Emprestimo Garantido - PJ

    vr_vldespes(46) := vr_vlatr_imobi_terreno_pf_pj; -- Terreno - PF e PJ
    vr_vldevedo(46) := vr_vlatr_imobi_v_terreno_pf_pj; -- Terreno - PF e PJ

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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7118,1611,' ||
                     TRIM(to_char(vr_juros38da.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valorpf <> 0   THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7118,' ||
                     TRIM(to_char(vr_juros38da.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DA
    IF vr_juros38da.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7704,1611,' ||
                      TRIM(to_char(vr_juros38da.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         -- REVERSÃO
         vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                        TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7704,' ||
                        TRIM(to_char(vr_juros38da.valorpj, '99999999999990.00')) ||
                        ',1434,' ||
                        '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38da.exists(vr_contador)
           AND vr_tabvljuros38da(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38da(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;
    END IF;

    /* Alteração RITM0058093 - MEI */
    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DA - MEI
    IF vr_juros38da.valormei <> 0 THEN
      -- Monta a linha de cabeçalho
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7702,7704,' ||
                     TRIM(to_char(vr_juros38da.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica - MEI"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',7704,7702,' ||
                     TRIM(to_char(vr_juros38da.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica - MEI"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38da.exists(vr_contador) AND vr_tabvljuros38da(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38da(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    /* Fim Alteração RITM0058093 - MEI */

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA FISICA DF
    IF vr_juros38df.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7118,1802,' ||
                      TRIM(to_char(vr_juros38df.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1802,7118,' ||
                       TRIM(to_char(vr_juros38df.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa fisica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;
    END IF;

    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DF
    IF vr_juros38df.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7704,1802,' ||
                      TRIM(to_char(vr_juros38df.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1802,7704,' ||
                       TRIM(to_char(vr_juros38df.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros38df.exists(vr_contador)
           AND vr_tabvljuros38df(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros38df(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;
    END IF;

    /* Alteração RITM0058093 - MEI */
    --0038 - JUROS SOBRE LIMITE DE CREDITO UTILIZADO OU (CRPS249) PROVISAO JUROS CH. ESPECIAL
    --PESSOA JURIDICA DF - MEI
    IF vr_juros38df.valormei <> 0  THEN
      -- Monta a linha de cabeçalho
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7702,7704,' ||
                     TRIM(to_char(vr_juros38df.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica - MEI"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38df.exists(vr_contador) AND vr_tabvljuros38df(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38df(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38df.exists(vr_contador) AND vr_tabvljuros38df(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38df(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',7704,7702,' ||
                     TRIM(to_char(vr_juros38df.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) Reversão rendas a apropriar adto a depositantes - Hist. 0038 Juros sobre limite de credito utilizado - pessoa juridica - MEI"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38df.exists(vr_contador) AND vr_tabvljuros38df(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38df(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_tabvljuros38df.exists(vr_contador) AND vr_tabvljuros38df(vr_contador).valormei <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_tabvljuros38df(vr_contador).valormei,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    /* Fim Alteração RITM0058093 - MEI */

    --0037 -TAXA SOBRE SALDO EM C/C NEGATIVO PESSOA FISICA
    IF vr_taxas37.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7113,1611,' ||
                      TRIM(to_char(vr_taxas37.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa fisica"';

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7113,' ||
                       TRIM(to_char(vr_taxas37.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa fisica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

    END IF;

    --0037 -TAXA SOBRE SALDO EM C/C NEGATIVO PESSOA JURIDICA
    IF vr_taxas37.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7113,1611,' ||
                      TRIM(to_char(vr_taxas37.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa juridica"';

        pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7113,' ||
                       TRIM(to_char(vr_taxas37.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0037 Taxa saldo em c/c negativa - pessoa juridica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvltaxas37.exists(vr_contador)
           AND vr_tabvltaxas37(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvltaxas37(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;
   END IF;

    --0057 -JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO   PESSOA FISICA
    IF vr_juros57.valorpf <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7113,1611,' ||
                      TRIM(to_char(vr_juros57.valorpf, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa fisica"';

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
        END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7113,' ||
                       TRIM(to_char(vr_juros57.valorpf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa fisica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpf <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpf,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;
    END IF;

    --0057 -JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO   PESSOA JURIDICA
    IF vr_juros57.valorpj <> 0  THEN
       -- Monta a linha de cabeçalho
       vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                      TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7113,1611,' ||
                      TRIM(to_char(vr_juros57.valorpj, '99999999999990.00')) ||
                      ',1434,' ||
                      '"(risco) Rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa juridica"';

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

        -- REVERSÃO
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',1611,7113,' ||
                       TRIM(to_char(vr_juros57.valorpj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) Reversao rendas a apropriar adto a depositantes - Hist. 0057 Juros sobre saque deposito bloqueado - pessoa juridica"';

         pc_gravar_linha(vr_linhadet);

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

         FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
           IF  vr_tabvljuros57.exists(vr_contador)
           AND vr_tabvljuros57(vr_contador).valorpj <> 0 THEN
             vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                            TRIM(to_char(vr_tabvljuros57(vr_contador).valorpj,'99999999999990.00'));

             pc_gravar_linha(vr_linhadet);

           END IF;
         END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PESSOA FISICA
    IF vr_vldjuros.valorpf <> 0 THEN
      -- Monta a linha de cabeçalho
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7116,1621,' ||
                     TRIM(to_char(vr_vldjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          -- Escrever a linha com as informações da agencia
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1621,7116,' ||
                     TRIM(to_char(vr_vldjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PESSOA JURIDICA
    IF vr_vldjuros.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7116,1621,' ||
                     TRIM(to_char(vr_vldjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1621,7116,' ||
                     TRIM(to_char(vr_vldjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_1(vr_contador).valorpj,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINAN CIAMENTOS EM ATRASO - PESSOA FISICA
    IF vr_finjuros.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7141,1662,' ||
                     TRIM(to_char(vr_finjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1662,7141,' ||
                     TRIM(to_char(vr_finjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_pacvljur_2(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO - PESSOA JURIDICA
    IF vr_finjuros.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7141,1662,' ||
                     TRIM(to_char(vr_finjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1662,7141,' ||
                     TRIM(to_char(vr_finjuros.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar FINANCIAMENTOS EM ATRASO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_2.exists(vr_contador)
        AND vr_pacvljur_2(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                          TRIM(to_char(vr_pacvljur_2(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- Inicio -- P577
    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA FISICA - Juros Mora
    IF vr_vlmrapar2.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7123,1664,' ||
                     TRIM(to_char(vr_vlmrapar2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_14.exists(vr_contador) AND
          vr_pacvljur_14(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7123,' ||
                     TRIM(to_char(vr_vlmrapar2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Juros Mora
    IF vr_vlmrapar2.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7123,1664,' ||
                     TRIM(to_char(vr_vlmrapar2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7123,' ||
                     TRIM(to_char(vr_vlmrapar2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_14.exists(vr_contador) AND
           vr_pacvljur_14(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_14(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA FISICA - Juros Remuneratorios
    IF vr_vljuropp2.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7122,1664,' ||
                     TRIM(to_char(vr_vljuropp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratórios a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7122,' ||
                     TRIM(to_char(vr_vljuropp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratórios a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Juros Remuneratorios
    IF vr_vljuropp2.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7122,1664,' ||
                     TRIM(to_char(vr_vljuropp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
      --
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7122,' ||
                     TRIM(to_char(vr_vljuropp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA FISICA - Multa
    IF vr_vlmultpp2.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7124,1664,' ||
                     TRIM(to_char(vr_vlmultpp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7124,' ||
                     TRIM(to_char(vr_vlmultpp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Multa
    IF vr_vlmultpp2.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7124,1664,' ||
                     TRIM(to_char(vr_vlmultpp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1664,7124,' ||
                     TRIM(to_char(vr_vlmultpp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_18.exists(vr_contador) AND
           vr_pacvljur_18(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_18(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;
    -- Fim -- P577

    -- Inicio -- P577
    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA FISICA - Juros Mora
    IF vr_fimrapar2.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7136,1667,' ||
                     TRIM(to_char(vr_fimrapar2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7136,' ||
                     TRIM(to_char(vr_fimrapar2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Juros Mora
    IF vr_fimrapar2.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7136,1667,' ||
                     TRIM(to_char(vr_fimrapar2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7136,' ||
                     TRIM(to_char(vr_fimrapar2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros mora a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_15.exists(vr_contador) AND
           vr_pacvljur_15(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_15(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA FISICA - Juros Remuneratorio
    IF vr_fijuropp2.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7135,1667,' ||
                     TRIM(to_char(vr_fijuropp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juro remuneratorio a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7135,' ||
                     TRIM(to_char(vr_fijuropp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juro remuneratotio a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Juros Remuneratorio
    IF vr_fijuropp2.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7135,1667,' ||
                     TRIM(to_char(vr_fijuropp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juro remuneratorio a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7135,' ||
                     TRIM(to_char(vr_fijuropp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juro remuneratorio a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_17.exists(vr_contador) AND
           vr_pacvljur_17(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_17(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA FISICA - Multa
    IF vr_fimultpp2.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7138,1667,' ||
                     TRIM(to_char(vr_fimultpp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_19.exists(vr_contador) AND
            vr_pacvljur_19(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7138,' ||
                     TRIM(to_char(vr_fimultpp2.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- FINANCIAMENTOS EM ATRASO PREFIXADO - PESSOA JURIDICA - Multa
    IF vr_fimultpp2.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7138,1667,' ||
                     TRIM(to_char(vr_fimultpp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1667,7138,' ||
                     TRIM(to_char(vr_fimultpp2.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO PREFIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_19.exists(vr_contador) AND
           vr_pacvljur_19(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_19(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;
    -- Fim -- P577

    -- [Projeto 403] - Juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA
    IF vr_totrendap.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7067,1630,' ||
                     TRIM(to_char(vr_totrendap.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA ."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7067,' ||
                     TRIM(to_char(vr_totrendap.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros remuneratório a apropriar DESCONTO DE TITULO PESSOA FISICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- [Projeto 403] - Juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA
    IF vr_totrendap.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7067,1630,' ||
                     TRIM(to_char(vr_totrendap.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA ."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7067,' ||
                     TRIM(to_char(vr_totrendap.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros remuneratório a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_rendaapropr.exists(vr_contador)
        AND vr_rendaapropr(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_rendaapropr(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- [Projeto 403] - Juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA
    IF vr_totjurmra.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7068,1630,' ||
                     TRIM(to_char(vr_totjurmra.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7068,' ||
                     TRIM(to_char(vr_totjurmra.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros de mora a apropriar DESCONTO DE TITULO PESSOA FISICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- [Projeto 403] - Juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA
    IF vr_totjurmra.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7068,1630,' ||
                     TRIM(to_char(vr_totjurmra.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1630,7068,' ||
                     TRIM(to_char(vr_totjurmra.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO juros de mora a apropriar DESCONTO DE TITULO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_apropjurmra.exists(vr_contador)
        AND vr_apropjurmra(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_apropjurmra(vr_contador).valorpj, '99999999999990.00'));

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

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_pacvljur_5.exists(vr_contador)
          AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

                pc_gravar_linha(vr_linhadet);

          END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_pacvljur_5.exists(vr_contador)
          AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

            pc_gravar_linha(vr_linhadet);

          END IF;
        END LOOP;

        -- Reversão
        vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1766,1664,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                       ',5210,' ||
                     '"(Cessao) REVERSAO RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';

        pc_gravar_linha(vr_linhadet);

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_pacvljur_5.exists(vr_contador)
          AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

                pc_gravar_linha(vr_linhadet);

          END IF;
        END LOOP;

        FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
          IF  vr_pacvljur_5.exists(vr_contador)
          AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

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

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

              pc_gravar_linha(vr_linhadet);

            END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                   TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1766,1664,' ||
                   TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                     ',5210,' ||
                   '"(Cessao) REVERSAO RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

              pc_gravar_linha(vr_linhadet);

            END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- Inicio -- PRJ298.3
    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros Remuneratorio
    IF vr_vljuremu6.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7587,1603,' ||
                     TRIM(to_char(vr_vljuremu6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
          vr_pacvljur_10(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
          vr_pacvljur_10(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7587,' ||
                     TRIM(to_char(vr_vljuremu6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros Remuneratorio
    IF vr_vljuremu6.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7587,1603,' ||
                     TRIM(to_char(vr_vljuremu6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7587,' ||
                     TRIM(to_char(vr_vljuremu6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_10.exists(vr_contador) AND
           vr_pacvljur_10(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_10(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros de Correcao
    IF vr_vljurcor6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7590,1603,' ||
                     TRIM(to_char(vr_vljurcor6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7590,' ||
                     TRIM(to_char(vr_vljurcor6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros de Correcao
    IF vr_vljurcor6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7590,1603,' ||
                     TRIM(to_char(vr_vljurcor6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7590,' ||
                     TRIM(to_char(vr_vljurcor6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_12.exists(vr_contador) AND
           vr_pacvljur_12(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_12(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;
    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros Mora
    IF vr_vlmrapar6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7593,1603,' ||
                     TRIM(to_char(vr_vlmrapar6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_8.exists(vr_contador) AND
            vr_pacvljur_8(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7593,' ||
                     TRIM(to_char(vr_vlmrapar6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    -- EMPRESTIMOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros Mora
    IF vr_vlmrapar6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7593,1603,' ||
                     TRIM(to_char(vr_vlmrapar6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7593,' ||
                     TRIM(to_char(vr_vlmrapar6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_8.exists(vr_contador) AND
           vr_pacvljur_8(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_8(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;
    -- Fim -- PRJ298.3

    --############################################################################################
    IF vr_vljurmta6.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7596,1603,' ||
                     TRIM(to_char(vr_vljurmta6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7596,' ||
                     TRIM(to_char(vr_vljurmta6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    IF vr_vljurmta6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7596,1603,' ||
                     TRIM(to_char(vr_vljurmta6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1603,7596,' ||
                     TRIM(to_char(vr_vljurmta6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar EMPRESTIMOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_22.exists(vr_contador) AND
           vr_pacvljur_22(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_22(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    --############################################################################################

    -- Inicio -- PRJ298.3
    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros Remuneratorio
    IF vr_fijuremu6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7557,1607,' ||
                     TRIM(to_char(vr_fijuremu6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
          vr_pacvljur_11(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
          vr_pacvljur_11(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7557,' ||
                     TRIM(to_char(vr_fijuremu6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros Remuneratorio
    IF vr_fijuremu6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7557,1607,' ||
                     TRIM(to_char(vr_fijuremu6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7557,' ||
                     TRIM(to_char(vr_fijuremu6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros remuneratorio a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_11.exists(vr_contador) AND
           vr_pacvljur_11(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_11(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros de Correcao
    IF vr_fijurcor6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7560,1607,' ||
                     TRIM(to_char(vr_fijurcor6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7560,' ||
                     TRIM(to_char(vr_fijurcor6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros de Correcao
    IF vr_fijurcor6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7560,1607,' ||
                     TRIM(to_char(vr_fijurcor6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7560,' ||
                     TRIM(to_char(vr_fijurcor6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de correcao a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_13.exists(vr_contador) AND
           vr_pacvljur_13(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_13(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA FISICA - Juros Mora
    IF vr_fimrapar6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7563,1607,' ||
                     TRIM(to_char(vr_fimrapar6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_9.exists(vr_contador) AND
            vr_pacvljur_9(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7563,' ||
                     TRIM(to_char(vr_fimrapar6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpf <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    -- FINANCIAMENTOS EM ATRASO POS FIXADO - PESSOA JURIDICA - Juros Mora
    IF vr_fimrapar6.valorpj <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7563,1607,' ||
                     TRIM(to_char(vr_fimrapar6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7563,' ||
                     TRIM(to_char(vr_fimrapar6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros de mora a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
      --
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    -- Fim -- PRJ298.3

    --############################################################################################
    IF vr_fijurmta6.valorpf <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7566,1607,' ||
                     TRIM(to_char(vr_fijurmta6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7566,' ||
                     TRIM(to_char(vr_fijurmta6.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;


    IF vr_fijurmta6.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7566,1607,' ||
                     TRIM(to_char(vr_fijurmta6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;

      END LOOP;
      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1607,7566,' ||
                     TRIM(to_char(vr_fijurmta6.valorpj, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) multa a apropriar FINANCIAMENTOS EM ATRASO POS FIXADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP

        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_23.exists(vr_contador) AND
           vr_pacvljur_23(vr_contador).valorpj <> 0 THEN

          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_23(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    --############################################################################################

    -- AJUSTE CESSAO EMPRESTIMO EM ATRASO - PESSOA FISICA
    IF vr_vldjuros3.valorpf <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7539,7122,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',7122,7539,' ||
                     TRIM(to_char(vr_vldjuros3.valorpf, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA FISICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpf <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpf, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

    END IF;

    -- AJUSTE CESSAO EMPRESTIMO EM ATRASO - PESSOA JURIDICA
    IF vr_vldjuros3.valorpj <> 0 THEN

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7539,7122,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- Reversão
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',7122,7539,' ||
                     TRIM(to_char(vr_vldjuros3.valorpj, '99999999999990.00')) ||
                     ',5210,' ||
                     '"(Cessao) REVERSAO AJUSTE RENDAS A APROPRIAR CESSAO CARTAO PESSOA JURIDICA."';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_5.exists(vr_contador)
        AND vr_pacvljur_5(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_5(vr_contador).valorpj, '99999999999990.00'));

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
                       ',1546,4112,' ||
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
                       ',4112,1546,' ||
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

    /* Alteração RITM0058093 - MEI */
    -- TOTAL CHEQUE ESPECIAL UTILIZADO - PESSOA JURIDICA - MEI
    IF vr_rel1722_0201_v.valormei <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     ',1544,1546,' ||
                     TRIM(to_char(vr_rel1722_0201_v.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA - MEI"';
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valormei <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valormei, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valormei <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valormei, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                     ',1546,1544,' ||
                     TRIM(to_char(vr_rel1722_0201_v.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA - MEI"';

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valormei <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valormei, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlag0201_1722_v.exists(vr_contador) THEN

          IF vr_vlag0201_1722_v(vr_contador).valormei <> 0 THEN
            vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                           TRIM(to_char(vr_vlag0201_1722_v(vr_contador).valormei, '99999999999990.00'));
            pc_gravar_linha(vr_linhadet);
          END IF;
        END IF;
      END LOOP;
    END IF;
    /* Fim Alteração RITM0058093 - MEI */

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
                       ',8442,1722,' ||
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
                       ',1722,8442,' ||
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
                       ',8442,1722,' ||
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
                       ',1722,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1722,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1722,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1722,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1722,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1731,' ||
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
                      TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1731,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1731,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1731,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1723,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1723,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,5584,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',5584,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1733,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1733,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1733,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1733,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1725,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1725,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1725,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1725,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1617,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1617,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1617,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1617,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1615,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1615,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1615,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1615,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1734,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1734,8442,' ||
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

    -- Ajuste Provisao - Provisão de operações do Imobiliario.
    IF vr_vldespes(39) <> 0 THEN

      vr_vllanmto := vr_vldespes(39);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1736,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS CR.IMOBILIARIO SFH"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1736,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS CR.IMOBILIARIO SFH"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_sfh_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    IF vr_vldespes(40) <> 0 THEN

      vr_vllanmto := vr_vldespes(40);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1737,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS CR.IMOBILIARIO SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1737,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.PESSOAIS CR.IMOBILIARIO SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_sfi_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pf.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    IF vr_vldespes(41) <> 0 THEN

      vr_vllanmto := vr_vldespes(41);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1736,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS CR.IMOBILIARIO SFH"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1736,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS CR.IMOBILIARIO SFH"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_sfh_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfh_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfh_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfh_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    IF vr_vldespes(42) <> 0 THEN

      vr_vllanmto := vr_vldespes(42);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1737,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS CR.IMOBILIARIO SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1737,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO FIN.EMPRESAS CR.IMOBILIARIO SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_sfi_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_sfi_pj.exists(vr_contador)
        AND vr_vlatrage_imob_sfi_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_sfi_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    IF vr_vldespes(43) <> 0 THEN
      vr_vllanmto := vr_vldespes(43);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1747,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO HOME EQUITY PF"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_home_equity_pf.exists(vr_contador)
        AND vr_vlatrage_imob_home_equity_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_home_equity_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_home_equity_pf.exists(vr_contador)
        AND vr_vlatrage_imob_home_equity_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_home_equity_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1747,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO HOME EQUITY PF"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_home_equity_pf.exists(vr_contador)
        AND vr_vlatrage_imob_home_equity_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_home_equity_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_home_equity_pf.exists(vr_contador)
        AND vr_vlatrage_imob_home_equity_pf(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_home_equity_pf(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;


    IF vr_vldespes(44) <> 0 THEN

      vr_vllanmto := vr_vldespes(44);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1744,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPRESTIMO GARANTIDO PF"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_imob.exists(vr_contador)
        AND vr_vlag1721_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_imob.exists(vr_contador)
        AND vr_vlag1721_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1744,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPRESTIMO GARANTIDO PF"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_imob.exists(vr_contador)
        AND vr_vlag1721_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1721_imob.exists(vr_contador)
        AND vr_vlag1721_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1721_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    IF vr_vldespes(45) <> 0 THEN

      vr_vllanmto := vr_vldespes(45);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1744,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPRESTIMO GARANTIDO PJ"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_imob.exists(vr_contador)
        AND vr_vlag1723_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_imob.exists(vr_contador)
        AND vr_vlag1723_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1744,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' || '"(risco) PROVISAO EMPRESTIMO GARANTIDO PJ"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_imob.exists(vr_contador)
        AND vr_vlag1723_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlag1723_imob.exists(vr_contador)
        AND vr_vlag1723_imob(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc,  '009')) || ',' ||
                         TRIM(to_char(vr_vlag1723_imob(vr_contador).valor,'99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;

    IF vr_vldespes(46) <> 0 THEN
      vr_vllanmto := vr_vldespes(46);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1743,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO TERRENO - SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_terreno_pf_pj.exists(vr_contador)
        AND vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_terreno_pf_pj.exists(vr_contador)
        AND vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      -- REVERSÃO
      vr_linhadet := TRIM(vr_con_dtmovime) || ',' ||
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1743,8442,' ||
                     TRIM(to_char(vr_vllanmto, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO TERRENO - SFI"';
      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_vlatrage_imob_terreno_pf_pj.exists(vr_contador)
        AND vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_vlatrage_imob_terreno_pf_pj.exists(vr_contador)
        AND vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_vlatrage_imob_terreno_pf_pj(vr_contador).valor, '99999999999990.00'));
          pc_gravar_linha(vr_linhadet);
        END IF;
      END LOOP;

    END IF;

    -- Fim Imobiliario

    -- Ajuste Provisao CL - Titulos Descontados
    -- AJUSTE PROVISAO TIT.DESCONTADOS - PESSOA FISICA / PF
    IF vr_vldespes(19) <> 0 THEN

      vr_vllanmto := vr_vldespes(19);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1724,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1724,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1724,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1724,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1763,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1763,8442,' ||
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
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',8442,1763,' ||
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
                     TRIM(to_char(vr_dtmovime, 'ddmmyy')) || ',1763,8442,' ||
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

                -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_atr||vr_price_pf) THEN
                  vr_relmicro_atr_pf_descris := vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||'999').valor;
                  vr_relmicro_atr_pf := vr_relmicro_atr_pf - vr_relmicro_atr_pf_descris;
                END IF;

               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pf > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pf, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                       TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                       vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                       TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                       vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                       TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                       vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                       TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                       vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_pre||vr_price_pf) THEN
                  vr_relmicro_pre_pf_descris := vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||'999').valor;
                  vr_relmicro_pre_pf := vr_relmicro_pre_pf - vr_relmicro_pre_pf_descris;
                END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                       TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                       vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                         vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_atr||vr_price_pj) THEN
                  vr_relmicro_atr_pj_descris := vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||'999').valor;
                  vr_relmicro_atr_pj := vr_relmicro_atr_pj - vr_relmicro_atr_pj_descris;
                END IF;

               -- Monta a linha de cabeçalho
               IF vr_relmicro_atr_pj > 0 THEN
                   vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                   TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)(TRIM(vr_arrchave2)).nrdconta || ',' ||
                   TRIM(to_char(vr_relmicro_atr_pj, '99999999999990.00')) ||
                  ',1434,' ||
                   '"'||TRIM(vr_arrchave2) ||'"';

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));

                      END IF;
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

                -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_pre||vr_price_pj) THEN
                  vr_relmicro_pre_pj_descris := vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||'999').valor;
                  vr_relmicro_pre_pj := vr_relmicro_pre_pj - vr_relmicro_pre_pj_descris;
                END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

                   pc_gravar_linha(vr_linhadet);
                END IF;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      -- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

                      pc_gravar_linha(vr_linhadet);
                   END IF;
                   vr_contador := vr_cdccuage.next(vr_contador);
                END LOOP;
                vr_contador := vr_cdccuage.first;
                WHILE vr_contador IS NOT NULL LOOP
                   IF vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0
                      AND  vr_contador <> 999 THEN

                      --- Se for microcredito e for desconsiderar no arquivo de risco subtrai
                      IF vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor > 0 THEN
                        vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor-
                                     vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      ELSE
                      vr_linhadet := TRIM(to_char(vr_contador, '009')) || ',' ||
                                     TRIM(to_char(vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||TRIM(to_char(vr_contador, '009'))).valor,'99999999999990.00'));
                      END IF;

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

    -- Contas para Linha de Crédito 6901
    --Indice = 1/2 (1 - Normal / 2 - Vencida) + 6901 (Linha de Crédito) + Nível de risco
    --RITM0134267
    vr_nrdcctab(169011) := '3511.3311';
    vr_nrdcctab(169012) := '3521.3321';
    vr_nrdcctab(169013) := '3532.3332';
    vr_nrdcctab(169014) := '3542.3342';
    vr_nrdcctab(169015) := '3552.3352';
    vr_nrdcctab(169016) := '3562.3362';
    vr_nrdcctab(169017) := '3572.3372';
    vr_nrdcctab(169018) := '3582.3382';
    vr_nrdcctab(169019) := '3592.3392';
    vr_nrdcctab(269013) := '3533.3333';
    vr_nrdcctab(269014) := '3543.3343';
    vr_nrdcctab(269015) := '3553.3353';
    vr_nrdcctab(269016) := '3563.3363';
    vr_nrdcctab(269017) := '3573.3373';
    vr_nrdcctab(269018) := '3583.3383';
    vr_nrdcctab(269019) := '3593.3393';
    --RITM0134267 Fim

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

    /* RITM0134267 - Inicio */
    for rw_craplcr_6901 in cr_craplcr_6901(pr_cdcooper,vr_dtrefere) loop
      if vr_nrdcctab.exists(to_number('16901'||to_char(rw_craplcr_6901.innivris))) then
        if rw_craplcr_6901.vldivida_normal > 0 then
          vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(to_number('16901'||to_char(rw_craplcr_6901.innivris))),'.',',') || ',';

          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(rw_craplcr_6901.vldivida_normal, '99999999999990.00')) ||
                         ',1434,' || '"(risco) CLASSIFICACAO DO RISCO - LCR 6901 - NORMAL"';
          pc_gravar_linha(vr_linhadet);

          -- Reversão
          vr_nrdcctab_c := ',' ||
                           substr(vr_nrdcctab(to_number('16901'||to_char(rw_craplcr_6901.innivris))),6)        ||
                           ',' ||
                           substr(vr_nrdcctab(to_number('16901'||to_char(rw_craplcr_6901.innivris))),1,4)      ||
                           ',';

          vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                         TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(rw_craplcr_6901.vldivida_normal, '99999999999990.00')) ||
                         ',1434,' || '"(risco) REVERSAO CLASSIFICACAO DO RISCO - LCR 6901 - NORMAL"';

          pc_gravar_linha(vr_linhadet);
        end if;
      end if;

      if vr_nrdcctab.exists(to_number('26901'||to_char(rw_craplcr_6901.innivris))) then
        if rw_craplcr_6901.vldivida_vencida > 0 then
          vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(to_number('26901'||to_char(rw_craplcr_6901.innivris))),'.',',') || ',';

          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(rw_craplcr_6901.vldivida_vencida, '99999999999990.00')) ||
                         ',1434,' || '"(risco) CLASSIFICACAO DO RISCO - LCR 6901 - VENCIDA"';
          pc_gravar_linha(vr_linhadet);

          -- Reversão
          vr_nrdcctab_c := ',' ||
                           substr(vr_nrdcctab(to_number('26901'||to_char(rw_craplcr_6901.innivris))),6)        ||
                           ',' ||
                           substr(vr_nrdcctab(to_number('26901'||to_char(rw_craplcr_6901.innivris))),1,4)      ||
                           ',';

          vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                         TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                         TRIM(vr_nrdcctab_c) ||
                         TRIM(to_char(rw_craplcr_6901.vldivida_vencida, '99999999999990.00')) ||
                         ',1434,' || '"(risco) REVERSAO CLASSIFICACAO DO RISCO - LCR 6901 - VENCIDA"';

          pc_gravar_linha(vr_linhadet);
        end if;
      end if;
    end loop;
    /* RITM0134267 - Fim */

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

        pc_gravar_linha(vr_linhadet);

        --REVERSAO
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       TRIM(to_char(rw_crapris_60.vljura60, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO"';

                       pc_gravar_linha(vr_linhadet);
    END LOOP;

    /* RITM0134267 - Inicio */
    for rw_craplcr_6901 in cr_craplcr_6901(pr_cdcooper,vr_dtrefere) loop
      if rw_craplcr_6901.vljuros_pf > 0 then
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(1)(vr_price_deb)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(1)(vr_price_cre)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       TRIM(to_char(rw_craplcr_6901.vljuros_pf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO - LCR 6901 - JUROS PF"';

        pc_gravar_linha(vr_linhadet);

        --REVERSAO
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(1)(vr_price_cre)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(1)(vr_price_deb)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       TRIM(to_char(rw_craplcr_6901.vljuros_pf, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) REVERSAO CLASSIFICACAO DO RISCO - LCR 6901 - JUROS PF"';

                       pc_gravar_linha(vr_linhadet);
      end if;

      if rw_craplcr_6901.vljuros_pj > 0 then
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(2)(vr_price_deb)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(2)(vr_price_cre)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       TRIM(to_char(rw_craplcr_6901.vljuros_pj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO - LCR 6901 - JUROS PJ"';

        pc_gravar_linha(vr_linhadet);

        --REVERSAO
        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(2)(vr_price_cre)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(2)(vr_price_deb)(to_char(rw_craplcr_6901.innivris||' 6901')).nrdconta || ',' ||
                       TRIM(to_char(rw_craplcr_6901.vljuros_pj, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) REVERSAO CLASSIFICACAO DO RISCO - LCR 6901 - JUROS PJ"';

                       pc_gravar_linha(vr_linhadet);
      end if;
    end loop;
    /* RITM0134267 - Fim */

/* Adicionado por Eduardo - Mouts. Dia 15042021 - RITM0130707 -
   Geração de uma linha com o total da operação no último dia do mês e uma linha para a reversão com o mesmo valor no primeiro dia do mês subsequente
   */
       --  Saldo da operação Linha de crédito 2600
       -- RITM0170907 - Segregar operações em pronampe 1 e 2
       vr_saldo_opera:= 0;
       OPEN cr_saldo_opera_pronampe1(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600);
       FETCH cr_saldo_opera_pronampe1 INTO vr_saldo_opera;
       CLOSE cr_saldo_opera_pronampe1;

       -- Gerar lançamento apenas quando o valor do saldo da operação for maior que zero
       IF  vr_saldo_opera > 0 THEN
       --Operação no último dia do mês. Operação
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3939,9984,'||
                          TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                         ',5210,'||
                         '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão

            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3939,'||
                           TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- Fim vr_saldo_opera > 0

       vr_saldo_opera:= 0;
       OPEN cr_saldo_opera_pronampe2(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600);
       FETCH cr_saldo_opera_pronampe2 INTO vr_saldo_opera;
       CLOSE cr_saldo_opera_pronampe2;

       -- Gerar lançamento apenas quando o valor do saldo da operação for maior que zero
       IF  vr_saldo_opera > 0 THEN
       --Operação no último dia do mês. Operação
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3956,9984,'||
                          TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                         ',5210,'||
                         '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão

            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3956,'||
                           TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- Fim vr_saldo_opera > 0
       -- FIM RITM0170907 - Segregar operações em pronampe 1 e 2

       --     Linha de crédito 1600, 1601 e 1602 (Cooperativa Cívia )
       vr_saldo_opera:= 0;
       vr_saldo_opera_r:=0;
       IF pr_cdcooper = 13 THEN --Cooperativa Cívia

          OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_saldo_opera
           INTO vr_saldo_opera;
          CLOSE cr_saldo_opera;
          vr_saldo_opera_r:= vr_saldo_opera;

         OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1601);
          FETCH cr_saldo_opera
           INTO vr_saldo_opera;
          CLOSE cr_saldo_opera;
          vr_saldo_opera_r:=vr_saldo_opera_r + vr_saldo_opera;

          OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_cdlcremp => 1602);
          FETCH cr_saldo_opera
           INTO vr_saldo_opera;
          CLOSE cr_saldo_opera;
          --Soma do 1600, 1601 e 1602
          vr_saldo_opera_r:=vr_saldo_opera_r + vr_saldo_opera;
          -- Gerar lançamento apenas quando o valor do saldo da operação for maior que zero
          IF vr_saldo_opera_r > 0 THEN
              --Operação no último dia do mês. Operação
              vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                             TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3947,9984,'||
                             TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                             ',5210,'||
                             '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS - PESE"';

              pc_gravar_linha(vr_linhadet);

              -- primeiro dia do mês subsequente. Linha para a Reversão
              vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                             TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3947,'||
                             TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                             ',5210,'||
                             '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

              pc_gravar_linha(vr_linhadet);
          END IF;  --vr_saldo_opera_r > 0
      ELSE
         --     Linha de crédito 1600 (Todas as Cooperativas )
         OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_saldo_opera
           INTO vr_saldo_opera;
          CLOSE cr_saldo_opera;
          -- Gerar lançamento apenas quando o valor do saldo da operação for maior que zero
          IF vr_saldo_opera > 0 THEN
              --Operação no último dia do mês. Operação
              vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                             TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3947,9984,'||
                             TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                             ',5210,'||
                             '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS - PESE"';
              -- Gravar Linha
              pc_gravar_linha(vr_linhadet);

              -- primeiro dia do mês subsequente. Linha para a Reversão
              vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                             TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3947,'||
                             TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                             ',5210,'||
                             '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

              pc_gravar_linha(vr_linhadet);
         END IF;  --vr_saldo_opera > 0
      END IF;

        --    SALDO OPERAÇÃO. Linha de crédito 4600 e 5600
        vr_saldo_opera := 0;
        OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                             pr_dtrefere => vr_dtrefere,
                             pr_cdlcremp => 4600);
        FETCH cr_saldo_opera
         INTO vr_saldo_opera;
        CLOSE cr_saldo_opera;
        --Recebe o valor do 4600
        vr_saldo_opera_R:=vr_saldo_opera;

        OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                             pr_dtrefere => vr_dtrefere,
                             pr_cdlcremp => 5600);
        FETCH cr_saldo_opera
         INTO vr_saldo_opera;
        CLOSE cr_saldo_opera;
        --Soma do 4600 e 5600
        vr_saldo_opera_r:= vr_saldo_opera_r + vr_saldo_opera;
        -- Gerar lançamento apenas quando o valor do saldo da operação for maior que zero
        IF vr_saldo_opera_r > 0 THEN
            --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3943,9984,'||
                           TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC - FGI"';

            pc_gravar_linha(vr_linhadet);

           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3943,'||
                           TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                          ',5210,'||
                          '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);
        END IF ; -- Fim vr_saldo_opera_r > 0

       --  Linha de crédito 2600 -- Rendas a apropriar (juros+60)
       -- RITM0170907 - Segregar operações em pronampe 1 e 2
       vr_total_jur60:= 0;
       OPEN cr_juros_60_pronampe1(pr_cdcooper => pr_cdcooper,
                                  pr_dtrefere => vr_dtrefere,
                                  pr_cdlcremp => 2600);
       FETCH cr_juros_60_pronampe1 INTO vr_total_jur60;
       CLOSE cr_juros_60_pronampe1;
       -- Gerar lançamento apenas quando o valor o total do juros for maior que zero
       IF vr_total_jur60 > 0 THEN
           --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3939,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3939,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- vr_total_jur60 > 0

       vr_total_jur60:= 0;
       OPEN cr_juros_60_pronampe2(pr_cdcooper => pr_cdcooper,
                                  pr_dtrefere => vr_dtrefere,
                                  pr_cdlcremp => 2600);
       FETCH cr_juros_60_pronampe2 INTO vr_total_jur60;
       CLOSE cr_juros_60_pronampe2;
       -- Gerar lançamento apenas quando o valor o total do juros for maior que zero
       IF vr_total_jur60 > 0 THEN
           --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3956,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3956,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- vr_total_jur60 > 0

       /*  Linha de crédito 1601 e 1602 (Cooperativa Cívia )*/
       vr_total_jur60:= 0;
       vr_total_jur60_r:=0;
       IF pr_cdcooper = 13 THEN --Cooperativa Cívia

         OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1600);
         FETCH cr_juros_60
          INTO vr_total_jur60;
         CLOSE cr_juros_60;
         --Recebe o valor do 1601
         vr_total_jur60_r:=vr_total_jur60;

         OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 1601);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        --Recebe o valor do 1600 e 1601
        vr_total_jur60_r:=vr_total_jur60_r + vr_total_jur60;

        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1602);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        --Soma do 1600, 1601 e 1602
        vr_total_jur60_r:= vr_total_jur60_r + vr_total_jur60;
       -- Gerar lançamento apenas quando o valor o total do juros for maior que zero
        IF vr_total_jur60_r > 0 THEN
            --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3947,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
            -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3947,9984,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
        END IF; -- vr_total_jur60_r > 0

      ELSE
        --     Linha de crédito 1600 (Todas as Cooperativas )
        vr_total_jur60:= 0;
        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        -- Gerar lançamento apenas quando o valor o total do juros for maior que zero
        IF vr_total_jur60 > 0 THEN
            --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3947,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3947,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
        END IF; -- vr_total_jur60 > 0
      END IF;
       --    Rendas a apropriar (juros+60)   -- Linha de crédito 4600 e 5600
       vr_total_jur60 := 0;
       vr_total_jur60_r:=0;
       OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                         pr_dtrefere => vr_dtrefere,
                         pr_cdlcremp => 4600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        --Recebe o valor do 4600
        vr_total_jur60_r:=vr_total_jur60;
        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 5600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;

        --Soma do 4600 e 5600
        vr_total_jur60_r:= vr_total_jur60_r +vr_total_jur60;
        -- Gerar lançamento apenas quando o valor o total do juros for maior que zero
       IF vr_total_jur60_r > 0 THEN
            --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3943,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);

           -- primeiro dia do mês subsequente. Linha para a Reversão
           vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3943,9984,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);
       END IF; -- vr_total_jur60_r > 0

       /* RITM0130707 - Provisão de perdas - Add 19/04/2021 por Eduardo */
       --  Linha de crédito 2600
       -- RITM0170907 - Segregar operações em pronampe 1 e 2
       vr_prov_perdas:= 0;
       OPEN cr_prov_perdas_pronampe1(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600);
       FETCH cr_prov_perdas_pronampe1 INTO vr_prov_perdas;
       CLOSE cr_prov_perdas_pronampe1;

    -- Gerar lançamento apenas quando o valor de Provisão de perdas for maior que zero
       IF vr_prov_perdas > 0 THEN
           --Provisão de perdas no último dia do mês.
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3941,'||
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3941,9984,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- vr_prov_perdas > 0

       vr_prov_perdas:= 0;
       OPEN cr_prov_perdas_pronampe2(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600);
       FETCH cr_prov_perdas_pronampe2 INTO vr_prov_perdas;
       CLOSE cr_prov_perdas_pronampe2;

    -- Gerar lançamento apenas quando o valor de Provisão de perdas for maior que zero
       IF vr_prov_perdas > 0 THEN
           --Provisão de perdas no último dia do mês.
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3973,'||
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
           -- primeiro dia do mês subsequente. Linha para a Reversão
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3973,9984,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
       END IF; -- vr_prov_perdas > 0
       -- FIM RITM0170907 - Segregar operações em pronampe 1 e 2

       --     Linha de crédito 1600, 1601 e 1602 (Cooperativa Cívia )
       vr_prov_perdas:= 0;
       vr_prov_perdas_r:=0;
       IF pr_cdcooper = 13 THEN --Cooperativa Cívia

          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;
          --Recebe o valor do 1600
          vr_prov_perdas_r:= vr_prov_perdas;

          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_cdlcremp => 1601);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;
          --Recebe o valor do 1600
           vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;

          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_cdlcremp => 1602);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;

          --Soma do 1600, 1601 e 1602
          vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;
          -- Gerar lançamento apenas quando o valor de Provisão de perdas for maior que zero
          IF vr_prov_perdas_r > 0 THEN
                --Operação no último dia do mês. Operação
                vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                               TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3949,'||
                               TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                               ',5210,'||
                               '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
                -- Gravar Linha
                pc_gravar_linha(vr_linhadet);

             -- primeiro dia do mês subsequente. Linha para a Reversão
               vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                              TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3949,9984,'||
                              TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                               ',5210,'||
                               '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
              -- Gravar Linha
                pc_gravar_linha(vr_linhadet);
          END IF; -- vr_prov_perdas_r > 0
      ELSE
      -- Linha de crédito 1600 (Todas as Cooperativas )
         OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;

     -- Gerar lançamento apenas quando o valor de Provisão de perdas for maior que zero
        IF vr_prov_perdas > 0 THEN
            --Operação no último dia do mês. Operação
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3949,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
            -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
         -- primeiro dia do mês subsequente. Linha para a Reversão
           vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                          TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3949,9984,'||
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
          -- Gravar Linha
            pc_gravar_linha(vr_linhadet);
        END IF; -- Fim vr_prov_perdas > 0
      END IF;

      -- SALDO OPERAÇÃO. Linha de crédito 4600 e 5600
      vr_prov_perdas := 0;
      OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 4600);
      FETCH cr_prov_perdas
       INTO vr_prov_perdas;
      CLOSE cr_prov_perdas;
      -- Recebe o valor do 4600
      vr_prov_perdas_R:=vr_prov_perdas;
      OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 5600);
      FETCH cr_prov_perdas
       INTO vr_prov_perdas;
      CLOSE cr_prov_perdas;

      -- Soma do 4600 e 5600
      vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;
      -- Gerar lançamento apenas quando o valor de Provisão de perdas for maior que zero
      IF vr_prov_perdas_r > 0 THEN
          --Operação no último dia do mês. Operação
          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3945,'||
                         TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

          pc_gravar_linha(vr_linhadet);

         -- primeiro dia do mês subsequente. Linha para a Reversão
         vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                        TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3945,9984,'||
                        TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                        ',5210,'||
                        '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

          pc_gravar_linha(vr_linhadet);
     END IF; -- Fim vr_prov_perdas_r > 0
   -- FIM Saldo da operação
   /*Fim Alteração por Eduardo - RITM0130707

    /******************************************* GERAR ARQUIVO *****************************/

    vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yymmdd');

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 0) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 0
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;

    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    -- Financiamentos ......................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Buscar o vencimento do risco
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 0) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 0
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;

    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    -- Saldo Financiamentos
    if vr_vltotorc > 0 then
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1662,'||
                     '1621,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SALDO FINANCIAMENTOS."';

      pc_gravar_linha(vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);
      -- Reversão
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '1621,'||
                     '1662,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO SALDO FINANCIAMENTOS."';

      pc_gravar_linha(vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);

    end if;

    /* Emprestimo - PREFIXADO .............................................. */

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 1) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 1
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    /* Financiamentos - PREFIXADO .............................................. */

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer vencimentos do risco
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 1) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 1
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;

    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    /* ------------------------------------------------------------------------------------------
     * EMPRESTIMO - POS FIXADO
     * ------------------------------------------------------------------------------------------ */

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 2) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 2
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;

    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    /* ------------------------------------------------------------------------------------------
     * FINANCIAMENTO - POS FIXADO
     * ------------------------------------------------------------------------------------------ */

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer vencimentos do risco
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 2) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 2
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    --

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
      pr_dscritic := 'Erro em RISC0001_3103.pc_risco_k: ' || SQLERRM;
      cecred.pc_internal_exception (pr_cdcooper => 3
                                   ,pr_compleme => pr_dscritic);

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
    Data    : Marco/2016                       Ultima Alteracao: 16/03/2022

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

                  16/03/2022 - Adicionada critica caso a data do parametro seja maior que a data da central
                               (Darlei Zillmer / PremierSoft)
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
              ,ris.cdorigem
              ,a.inpessoa
              ,a.cdagenci
          FROM crapris ris, crapass a
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 4
           AND a.cdcooper = ris.cdcooper
           AND a.nrdconta = ris.nrdconta
      ORDER BY a.cdagenci;

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

      IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
        vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
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
        GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => rw_crapris.cdcooper,
                                                 pr_nrdconta => rw_crapris.nrdconta,
                                                 pr_nrctremp => rw_crapris.nrctremp,
                                                 pr_cdmodali => rw_crapris.cdmodali,
                                                 pr_vlpreatr => vr_vlpreatr,
                                                 pr_dscritic => vr_dscritic);

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
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8484,4914,' ||
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
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8484,' ||
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
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8484,4914,' ||
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
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8484,' ||
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
        pr_dscritic := 'Erro em RISC0001_3103.pc_risco_t: ' || SQLERRM;
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
    Data    : Maio/2017                       Ultima Alteracao: 16/03/2022

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Gerar Arq. Contabilizacao Provisao

    Alterações: 16/03/2022 - Adicionada critica caso a data do parametro seja maior que a data da central
                            (Darlei Zillmer / PremierSoft)
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
              ,ris.cdorigem
              ,a.inpessoa
              ,a.cdagenci
              ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia) cdgarantia
              ,prd.dsproduto
              ,ROW_NUMBER ()
                 OVER (PARTITION BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia) ORDER BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia),a.cdagenci) nrseqgar
              ,Count (1)
                 OVER (PARTITION BY prd.dsproduto,risc0003.fn_valor_opcao_dominio(mvt.idgarantia)) qtreggar
          FROM crapris ris
              ,tbrisco_provisgarant_movto mvt
              ,tbrisco_provisgarant_prodt prd
              ,crapass a
         WHERE mvt.idproduto = prd.idproduto
           AND ris.nrctremp = mvt.nrctremp
           AND ris.dtrefere = mvt.dtbase
           AND ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND a.cdcooper = ris.cdcooper
           AND a.nrdconta = ris.nrdconta
           AND ris.inddocto = 5                -- Registros lançados em tela
           AND ris.innivris > 1                -- Contratos com risco = AA não tem provisão
      ORDER BY prd.dsproduto
              ,risc0003.fn_valor_opcao_dominio(mvt.idgarantia)
              ,a.cdagenci;

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
           AND ris.nrctremp = mvt.nrctremp
           AND ris.dtrefere = mvt.dtbase
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

      IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
        vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
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
        GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => rw_crapris.cdcooper,
                                                 pr_nrdconta => rw_crapris.nrdconta,
                                                 pr_nrctremp => rw_crapris.nrctremp,
                                                 pr_cdmodali => rw_crapris.cdmodali,
                                                 pr_vlpreatr => vr_vlpreatr,
                                                 pr_dscritic => vr_dscritic);

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
          vr_nrctaded_pf := 8484;
          vr_nrctaded_pj := 8484;

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
        pr_dscritic := 'Erro em RISC0001_3103.pc_risco_g: ' || SQLERRM;
    END;

  END pc_risco_g;

  /* Obter os dados do banco cetral para analise da proposta, consulta de SCR. (Tela CONSCR) */
  PROCEDURE pc_obtem_valores_central_risco(pr_cdcooper IN crapcop.cdcooper%type                    --> Codigo Cooperativa
                                          ,pr_cdagenci IN crapass.cdagenci%type                    --> Codigo Agencia
                                          ,pr_nrdcaixa IN INTEGER                                  --> Numero Caixa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE                    --> Numero da Conta
                                          ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE                    --> CPF/CGC do associado
                                          ,pr_tab_central_risco OUT RISC0001_3103.typ_reg_central_risco --> Informações da Central de Risco
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
        vr_dscritic := 'Erro não tratado em RISC0001_3103.pc_calcula_faturamento: ' || SQLERRM;
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
                             ,pr_tab_estouros OUT RISC0001_3103.typ_tab_estouros --> Informações de estouro na conta
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
        pr_dscritic := 'Erro não tratado em RISC0001_3103.pc_lista_estouros: ' || SQLERRM;
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
       Data    : Fevereiro/2019                       Ultima atualizacao: 17/03/2022

       Dados referentes ao programa:

       Frequencia: sempre que for chamado
       Objetivo  : gerar arquivo 3026 - Risco de Credito

       Alteracoes :
                     15/02/2019 - prj450 - Alteração no arquivo 3026 uso do cpfcnpj_base no participante
                                  do grupo (Fabio Adriano - AMcom)

                     18/06/2021 - Squad Risco - Ajuste repetições de operações do GE
                                  e data base (Luiz Otávio Olinger Momm - Ailos)

                     16/03/2022 - Adicionada critica caso a data do parametro seja maior que a data da central
                                 (Darlei Zillmer / PremierSoft)
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
        SELECT ass.inpessoa
              ,CASE WHEN ass.inpessoa = 1   then to_char(ass.nrcpfcnpj_base,'FM00000000000')
                    ELSE                         to_char(ass.nrcpfcnpj_base,'FM00000000')
               END AS nrcpfcnpj_base
          FROM gestaoderisco.tbrisco_grupo_economico_integrante INT
              ,crapass ass
         WHERE int.cdcooper = pr_cdcooper
           AND int.cdgrupo_economico = pr_nrdgrupo
           AND int.cdcooper = ass.cdcooper
           AND int.nrdconta = ass.nrdconta
           AND ass.dtelimin IS NULL
         GROUP BY inpessoa, nrcpfcnpj_base;
      rw_grupint   cr_grupint%ROWTYPE;

      -- Cursor para busca integrantes do grupo economico
      CURSOR cr_grupintegr (pr_nrdgrupo INTEGER)IS
        SELECT ass.inpessoa
              ,int.nrdconta
              ,ass.nrcpfcgc
          FROM gestaoderisco.tbrisco_grupo_economico_integrante INT
              ,crapass ass
         WHERE int.cdcooper = pr_cdcooper
           AND int.cdgrupo_economico = pr_nrdgrupo
           AND int.cdcooper = ass.cdcooper
           AND int.nrdconta = ass.nrdconta;
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

      IF pr_dtrefere > rw_crapdat.dtmvcentral THEN
        vr_dscritic := 'Dados da central de risco para a data ' || to_char(pr_dtrefere, 'dd/mm/yyyy') || ' ainda nao disponivel.';
        RAISE vr_exc_erro;
      END IF;

      --> Busca dados da cooperativa
      OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      vr_dtbase := to_char(pr_dtrefere,'yyyy') || '-12';
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

        rw_grupintegr := NULL;
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

  PROCEDURE pc_verifica_previa_3040(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_cdprogra   IN crapprg.cdprogra%TYPE
                                   ,pr_dtrefere   IN DATE
                                   ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                   ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS
    -- ..........................................................................
    --
    --  Programa : pc_verifica_previa_3040

    --  Sistema  : Verifica se é possível gerar arquivo 3040 prévio ou não
    --  Sigla    : RISC
    --  Autor    : Luiz Otávio Olinger Momm - AMCOM
    --  Data     : 24/03/2020                   Ultima atualizacao: 17/12/2020
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Verifica se já tem algum processo rodando para a mesma opção e
    --               cooperativa.
    --   Alterações: 17/12/2020 - Squad Riscos - Removida a validação para não gerar
    --                            arquivos no mesmo dia  (Luiz Otávio Olinger Momm
    --                            - AMCOM)
    -- .............................................................................

    CURSOR cr_verifica_job IS
      SELECT DISTINCT 1
        FROM dba_scheduler_jobs
       WHERE owner         = 'CECRED'
         AND job_name   LIKE '%'|| pr_cdprogra ||'%'
         AND JOB_ACTION LIKE '%pr_cdcooper => '||pr_cdcooper||'%';
    rw_verifica_job cr_verifica_job%ROWTYPE;

    CURSOR cr_crapris IS
      SELECT 1
        FROM crapris r
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere;
    rw_crapris cr_crapris%ROWTYPE;

    vr_retcur BOOLEAN := FALSE;
    -- Variaveis para tratamento de erros

    vr_exc_erro          EXCEPTION;
    vr_dscritic          crapcri.dscritic%TYPE := '';

  BEGIN

    -- Se for primeiro dia de movimentação dentro do mês não gerar 3040 para mês corrente
    IF pr_cdprogra = vr_cdprogra_p THEN
      IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtoan,'mm') THEN
        vr_dscritic := 'Nao possui dados para geracao do 3040';
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Verifica se processo está em execução
    OPEN cr_verifica_job;
    FETCH cr_verifica_job INTO rw_verifica_job;
    vr_retcur := cr_verifica_job%FOUND;
    CLOSE cr_verifica_job;
    IF vr_retcur THEN
      vr_dscritic := 'Previa ja solicitada (1)';
      RAISE vr_exc_erro;
    END IF;

    OPEN cr_crapris;
    FETCH cr_crapris INTO rw_crapris;
    vr_retcur := cr_crapris%FOUND;
    CLOSE cr_crapris;
    IF vr_retcur = FALSE THEN
      vr_dscritic := 'Data de referencia invalida';
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Monta mensagem de erro
      pr_dscritic := 'Erro em RISC0001_3103.pc_verifica_previa_3040: ' || SQLERRM;

  END pc_verifica_previa_3040;

  PROCEDURE pc_gera_arq_previa_3040(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_cddopcao   IN VARCHAR2
                                   ,pr_cdoperad   IN crapope.cdoperad%TYPE
                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  /* .............................................................................
  Programa: pc_gera_arq_previa_3040
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Luiz Otávio Olinger Momm
  Data    : Março/2020                       Ultima Alteracao:

  Dados referentes ao programa:

  Frequencia: sempre que for chamado

  Objetivo  : Gerar arquivo 3040 prévio do mês corrente ou do mes anterior
              conforme opção pela tela de RISCO - Risco de Credito
              Opção P – Prévia diária – Nesta opção deverá ser gerada a prévia
                        considerando as informações do mês corrente até o dia
                        anterior.
              Opção Q – Prévia mensal - Nesta opção deverá ser gerada a prévia
                        considerando as informações fechadas do mês anterior.

  Alterações:

    /*****************************  VARIAVEIS  ****************************/
    rw_crapdat           btch0001.cr_crapdat%ROWTYPE;

    vr_dtrefere          DATE;
    vr_cdprogra          crapprg.cdprogra%TYPE;
    vr_idprglog          tbgen_prglog.idprglog%TYPE;
    vr_dsplsql           VARCHAR2(4000);
    vr_timestamp         TIMESTAMP;
    vr_jobname           VARCHAR2(50);

    -- Variaveis para tratamento de erros
    vr_exc_erro          EXCEPTION;
    vr_cdcritic          crapcri.cdcritic%TYPE;
    vr_dscritic          crapcri.dscritic%TYPE;

  BEGIN

    IF UPPER(pr_cddopcao) = 'P' THEN
      vr_cdprogra := vr_cdprogra_p;
    ELSIF UPPER(pr_cddopcao) = 'Q' THEN
      vr_cdprogra := vr_cdprogra_q;
    ELSIF UPPER(pr_cddopcao) = 'F' THEN
      vr_cdprogra := vr_cdprogra_f;
    ELSE
      vr_dscritic := 'Opcao invalida';
      RAISE vr_exc_erro;
    END IF;

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
      RAISE vr_exc_erro;
    ELSE
      IF UPPER(pr_cddopcao) = 'P' THEN
        vr_dtrefere := rw_crapdat.dtmvcentral; -- Data movimento anterior
      ELSIF UPPER(pr_cddopcao) = 'Q' or UPPER(pr_cddopcao) = 'F' THEN
        vr_dtrefere := rw_crapdat.dtultdma; -- Data do último dia do mês anterior
      END IF;
    END IF;

    -- Faz validação se pode executar previa 3040 por cooperativa e opção
    vr_dscritic := NULL;
    pc_verifica_previa_3040(pr_cdcooper    => pr_cdcooper
                           ,pr_cdprogra    => vr_cdprogra
                           ,pr_dtrefere    => vr_dtrefere
                           ,pr_rw_crapdat  => rw_crapdat
                           ,pr_dscritic    => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_flgsucesso => 0
                   ,pr_cdcooper   => pr_cdcooper
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    -- vr_jobname := dbms_scheduler.generate_job_name(substr(vr_cdprogra,1,18));
    vr_jobname := vr_cdprogra;

    vr_dsplsql := '
BEGIN
  -- Gera arquivo previo do XML 3040 pela tela de RISCO do Aimaro Caractere
  cecred.RISC0001_3103.pc_gera_arq_previa_3040_job(pr_cdcooper => '   || pr_cdcooper || '
                                             ,pr_dtrefere => ''' || vr_dtrefere || '''
                                             ,pr_cdprogra => ''' || vr_cdprogra || '''
                                             ,pr_idprglog => '   || vr_idprglog || '
                                             ,pr_cdoperad => ''' || pr_cdoperad || ''');
END;
';

    vr_timestamp := (SYSDATE + 1/1440);

    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper         --> Código da cooperativa
                          ,pr_cdprogra  => vr_cdprogra         --> Código do programa
                          ,pr_dsplsql   => vr_dsplsql          --> Bloco PLSQL a executar
                          ,pr_dthrexe   => vr_timestamp        --> SYSDATE  + 1/1440 --> Executar após 1 minuto
                          ,pr_interva   => NULL                --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname          --> Nome randomico criado
                          ,pr_des_erro  => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Erro sem tratamento
                                ,pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                ' - ' || vr_cdprogra ||
                                                ' --> ' || vr_dscritic);
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      ROLLBACK;
      pr_dscritic := 'Erro em RISC0001_3103.pc_gera_arq_previa_3040: ' || SQLERRM;
  END pc_gera_arq_previa_3040;

  PROCEDURE pc_gera_arq_previa_3040_job(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                       ,pr_dtrefere           IN DATE
                                       ,pr_cdprogra           IN crapprg.cdprogra%TYPE
                                       ,pr_idprglog           IN tbgen_prglog.idprglog%TYPE
                                       ,pr_cdoperad           IN crapope.cdoperad%TYPE
                                       ,pr_cdagenci_gerar3040 IN crapage.cdagenci%TYPE DEFAULT 0) IS
  /* .............................................................................
  Programa: pc_gera_arq_previa_3040
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Luiz Otávio Olinger Momm
  Data    : Março/2020                       Ultima Alteracao: 17/12/2020

  Dados referentes ao programa: Cria JOB para geração prévia dos arquivos 3040
                                do mês anterior ou do mês atual.
                                JAMAIS chamar essa procedure sem chamar pela
                                pc_gera_arq_previa_3040 devido aos tratamentos
                                necessários para geração das informações.

  Frequencia: sempre que for chamado

  Objetivo  : Gerar o arquivo 3040 por cooperativa e por data de referencia
  Alterações: 07/05/2020 - Squad Riscos - 31108 - Adicionado um e-mail padrão
                           caso a crapope estiver vazia
                           (Luiz Otávio Olinger Momm - AMCOM)

              18/05/2020 - Removido tratamento para chamar o programa pc_crps660
                           que individualiza as operações na opção do mês
                           anterior Q (Luiz Otávio Olinger Momm / AMCOM)

              17/12/2020 - Adicionado geração por agência para cooperativas com
                           paralelismo gerando arquivos 3040 e diminuindo o tempo
                           de espera na geração parcial (Luiz Otávio Olinger
                           Momm / AMCOM)

    /**********************************  CURSORES ****************************/
    CURSOR cr_nrseqsol(pr_idrelato IN VARCHAR2) IS
      SELECT s.nrseqsol, s.dsarqsai
        FROM crapslr s
       WHERE s.cdcooper = pr_cdcooper
         AND s.dsarqsai LIKE '%/Previa%' || pr_idrelato || '%.xml'
         AND trunc(s.dtsolici) = trunc(SYSDATE)
       ORDER BY s.dtsolici DESC;
    rw_nrseqsol cr_nrseqsol%ROWTYPE;

    CURSOR cr_crapope(pr_email crapope.dsdemail%TYPE) IS
      SELECT NVL(o.dsdemail, pr_email) dsdemail
        FROM crapope o
       WHERE o.cdcooper        = pr_cdcooper
         AND UPPER(o.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope           cr_crapope%ROWTYPE;

    CURSOR cr_crapcop IS
      SELECT c.nmrescop
            ,c.dsdircop
        FROM crapcop c
       WHERE c.cdcooper = pr_cdcooper;
    rw_crapcop            cr_crapcop%ROWTYPE;
    /*****************************  VARIAVEIS  ****************************/
    vr_idprglog tbgen_prglog.idprglog%TYPE;
    vr_cdprogra crapprg.cdprogra%TYPE;

    vr_stprogra          PLS_INTEGER;
    vr_infimsol          PLS_INTEGER;
    vr_dtrefere          DATE;
    vr_retcur            BOOLEAN := FALSE;
    vr_email             crapope.dsdemail%TYPE := NULL;
    vr_nmrescop          crapcop.nmrescop%TYPE;
    vr_dsdircop          crapcop.dsdircop%TYPE;

    vr_dsassunto         VARCHAR2(300);

    -- Separaçao do caminho e nome do arquivo
    vr_dsdir             VARCHAR2(300);
    vr_dsarq             VARCHAR2(300);
    vr_emailArquivos     VARCHAR2(4000);

    -- Variaveis para registrar tempo de processamento
    vr_proc_inicio       DATE;
    vr_proc_fim          DATE;
    vr_proc_tempo        VARCHAR2(1000);

    -- Variaveis para tratamento de erros
    vr_cdcritic          crapcri.cdcritic%TYPE;
    vr_dscritic          crapcri.dscritic%TYPE;
    vr_des_erro          VARCHAR2(6000);
    vr_idrelato          VARCHAR2(5);
    vr_exc_erro          EXCEPTION;

    vr_dsconteu crappco.dsconteu%TYPE;
    vr_tab_erro cecred.gene0001.typ_tab_erro;

  BEGIN
    vr_idprglog := pr_idprglog;
    vr_dtrefere := pr_dtrefere;
    vr_cdprogra := pr_cdprogra;

    -- Início da execução
    vr_proc_inicio := SYSDATE;

    vr_idrelato := LPAD(SUBSTR(to_char(pr_idprglog),-5),5, '0');

    cecred.pc_crps660(pr_cdcooper => pr_cdcooper
                     ,pr_dtrefere => vr_dtrefere
                     ,pr_stprogra => vr_stprogra
                     ,pr_infimsol => vr_infimsol
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                ' - ' || vr_cdprogra ||
                                                ' --> ' || vr_dscritic);
      pc_log_programa(PR_DSTIPLOG   => 'F'
                     ,PR_CDPROGRAMA => vr_cdprogra
                     ,pr_tpexecucao => 2
                     ,pr_flgsucesso => 0
                     ,pr_cdcooper   => pr_cdcooper
                     ,PR_IDPRGLOG   => vr_idprglog);

      RAISE vr_exc_erro;
    END IF;

    IF vr_cdprogra = 'RPREV3040F' THEN
      --execução final do arquivo 3040. Opção F, tela RISCO
      cecred.pc_crps573(pr_cdcooper           => pr_cdcooper,
                        pr_dtrefere           => vr_dtrefere,
                        pr_stprogra           => vr_stprogra,
                        pr_infimsol           => vr_infimsol,
                        pr_cdagenci_gerar3040 => pr_cdagenci_gerar3040,
                        pr_cdcritic           => vr_cdcritic,
                        pr_dscritic           => vr_dscritic);
    ELSE
      cecred.pc_crps573(pr_cdcooper           => pr_cdcooper,
                        pr_dtrefere           => vr_dtrefere,
                        pr_cdprogra           => vr_cdprogra,
                        pr_idrelato           => vr_idrelato,
                        pr_stprogra           => vr_stprogra,
                        pr_infimsol           => vr_infimsol,
                        pr_cdagenci_gerar3040 => pr_cdagenci_gerar3040,
                        pr_cdcritic           => vr_cdcritic,
                        pr_dscritic           => vr_dscritic);
    END IF;

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                ' - ' || vr_cdprogra ||
                                                ' --> ' || vr_dscritic);
      pc_log_programa(PR_DSTIPLOG   => 'F'
                     ,PR_CDPROGRAMA => vr_cdprogra
                     ,pr_tpexecucao => 2
                     ,pr_flgsucesso => 0
                     ,pr_cdcooper   => pr_cdcooper
                     ,PR_IDPRGLOG   => vr_idprglog);
    ELSE
      pc_log_programa(PR_DSTIPLOG   => 'F'
                     ,PR_CDPROGRAMA => vr_cdprogra
                     ,pr_tpexecucao => 2
                     ,pr_flgsucesso => 1
                     ,pr_cdcooper   => pr_cdcooper
                     ,PR_IDPRGLOG   => vr_idprglog);

      vr_retcur := FALSE;
      vr_emailArquivos := '';
      FOR rw_nrseqsol IN cr_nrseqsol(vr_idrelato) LOOP
        vr_retcur := cr_nrseqsol%FOUND;
        -- Salva XML conforme path da coluna crapslr.dsarqsai
        cecred.gene0002.pc_process_relato_penden(pr_nrseqsol => rw_nrseqsol.nrseqsol,
                                                 pr_cdfilrel => null,
                                                 pr_des_erro => vr_des_erro);

        gene0001.pc_separa_arquivo_path(pr_caminho => rw_nrseqsol.dsarqsai
                                       ,pr_direto  => vr_dsdir
                                       ,pr_arquivo => vr_dsarq);
        vr_emailArquivos := vr_emailArquivos || '<br>' || vr_dsarq;
      END LOOP;

      -- Garante que o Cursor seja encerrado
      IF cr_nrseqsol%ISOPEN THEN
        CLOSE cr_nrseqsol;
      END IF;

      IF vr_retcur = FALSE and vr_cdprogra <> 'RPREV3040F' THEN
        -- Caso não achar o relatório 3040
        btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> Arquivo 3040 nao gerado');
      ELSE

        -- Fim da execução com sucesso
        vr_proc_fim := SYSDATE;

        --calcula o tempo de execução da rotina
        vr_proc_tempo := LPAD(TRUNC(( (vr_proc_fim - vr_proc_inicio) * 86400 / 3600)), 2, '0')  ||':' ||
                         LPAD(TRUNC(MOD( (vr_proc_fim - vr_proc_inicio) * 86400 , 3600 ) / 60 ), 2, '0') || ':'||
                         LPAD(TRUNC(MOD(MOD( (vr_proc_fim - vr_proc_inicio) * 86400, 3600 ), 60)), 2, '0');

        -- Paramentro do e-mail padrão quando não existir na crapope.dsemail
        vr_dsconteu := '';
        tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                              ,pr_cdbattar => 'PREVEMAIL3040'
                                              ,pr_dsconteu => vr_dsconteu
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic
                                              ,pr_des_erro => vr_des_erro
                                              ,pr_tab_erro => vr_tab_erro);

        IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dsconteu) IS NULL THEN
          vr_dsconteu := '';
        END IF;
        -- Paramentro do e-mail padrão quando não existir na crapope.dsemail

        OPEN cr_crapope(pr_email => vr_dsconteu);
        FETCH cr_crapope INTO rw_crapope;
        vr_retcur := cr_crapope%FOUND;
        CLOSE cr_crapope;
        IF vr_retcur THEN
          vr_email := rw_crapope.dsdemail;
        END IF;

        OPEN cr_crapcop;
        FETCH cr_crapcop INTO rw_crapcop;
        vr_retcur := cr_crapcop%FOUND;
        CLOSE cr_crapcop;
        IF vr_retcur THEN
          vr_nmrescop := rw_crapcop.nmrescop;
          vr_dsdircop := rw_crapcop.dsdircop;
        END IF;

        IF TRIM(vr_email) IS NOT NULL THEN

          if vr_cdprogra <> 'RPREV3040F' then
            vr_dsassunto := 'Finalização da geração de Prévia diária - ' || vr_nmrescop;
          else
            vr_dsassunto := 'Finalização da geração 3040 - ' || vr_nmrescop;
          end if;

          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper,
                                     pr_cdprogra        => 'RISCO',
                                     pr_des_destino     => vr_email,
                                     pr_des_assunto     => vr_dsassunto,
                                     pr_des_corpo       => 'A sua solicitação de geração do arquivo 3040 foi finalizada.'
                                                        || '<br/><br/>'
                                                        || 'O tempo para sua geração foi de ' || vr_proc_tempo
                                                        || ' minutos (Das '
                                                        || to_char(vr_proc_inicio, 'HH24:MI:SS') || ' até '
                                                        || to_char(vr_proc_fim, 'HH24:MI:SS') || ').'
                                                        || '<br/><br/>'
                                                        || 'Disponibilizado na pasta: L:\' || vr_dsdircop || '\salvar\'
                                                        || '<br/><br/>'
                                                        || 'Arquivos:'
                                                        || '<br/>' || vr_emailArquivos,
                                     pr_des_anexo       => '',
                                     pr_flg_enviar      => 'S',
                                     pr_des_erro        => vr_dscritic);

          -- Armazena informações em caso de erro porém não aborta
          -- visto que a geração já concluiu
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
          END IF;

        END IF;

      END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
    WHEN OTHERS THEN
      ROLLBACK;
      vr_dscritic := 'Erro em RISC0001_3103.pc_gera_arq_previa_3040_job: ' || SQLERRM;
  END pc_gera_arq_previa_3040_job;

  FUNCTION fn_gera_arq_previa_nomexml(pr_cdprogra   IN crapprg.cdprogra%TYPE
                                     ,pr_idrelato   IN VARCHAR2) RETURN VARCHAR2 IS
    -- ..........................................................................
    --
    --  Programa : fn_gera_arq_previa_nomexml

    --  Sistema  : Rotinas genericas para RISCO
    --  Sigla    : RISC
    --  Autor    : Luiz OTávio Olinger Momm - AMCOM
    --  Data     : 31/03/2020                    Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Retorna o nome do arquivo conforme máscara definida
    --
    -- ..........................................................................

    -- Variaveis para tratamento de erros

  BEGIN
    IF pr_cdprogra = vr_cdprogra_p THEN
      RETURN 'Previa_P_' || to_char(SYSDATE, 'ddmmyyyyhh24miss') || '_' || pr_idrelato;
    ELSIF pr_cdprogra = vr_cdprogra_q THEN
      RETURN 'Previa_Q_' || to_char(SYSDATE, 'ddmmyyyyhh24miss') || '_' || pr_idrelato;
    END IF;

    -- Caso o programa enviado não for tratado evita com que não
    -- gera o arquivo prévio do XML 3040
    RETURN 'Previa_' || to_char(SYSDATE, 'ddmmyyyyhh24miss') || '_' || pr_idrelato;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Erro na RISC0001_3103.fn_gera_arq_previa_nomexml: '||SQLERRM);
  END fn_gera_arq_previa_nomexml;


/*
 Autor.....: Guilherme/AMcom
 Data......: 23/09/2020
 Dominio...: Credito
 Subdominio: Riscos
 Objetivo..: Verificar se houve ocorrencia de Saida na modalidade para a conta/contrato
 Alteracoes:

   30/12/2020 - Ajuste no controle da obtenção da modalidade na geração das saídas de operação.
                (Wagner/Ailos).

*/
  PROCEDURE verificarSaidas(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                           ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da conta
                           ,pr_nrctremp      IN crapepr.nrctremp%TYPE     --> Numero Contrato
                           ,pr_dtrefere      IN crapris.dtrefere%TYPE     --> DAta Referencia (ult dia mes anter)
                           ,pr_situacao     OUT NUMBER                    --> Existe Saida 1-Sim / 0 - Nao
                           ,pr_dscritic     OUT craperr.dscritic%TYPE) IS --> Descrição Crítica

    vr_dsconteu crappco.dsconteu%TYPE;
    vr_des_erro VARCHAR2(5);
    vr_tab_erro cecred.gene0001.typ_tab_erro;
    vr_tab_split gene0002.typ_split;

    vr_data_ocr DATE;
    vr_data_opi DATE;
    vr_data_opf DATE;
    vr_dias_atr NUMBER;

    -- Variáveis de erro
    vr_cdcritic craperr.cdcritic%TYPE;
    vr_dscritic craperr.dscritic%TYPE;
    vr_idprglog tbgen_prglog.idprglog%TYPE;
    vr_excsaida EXCEPTION;

    CURSOR cr_crapris (pr_cdcooper      IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta      IN crapass.nrdconta%TYPE
                      ,pr_nrctremp      IN crapepr.nrctremp%TYPE
                      ,pr_dtrefere      IN crapris.dtrefere%TYPE) IS
      SELECT 1
        FROM crapris cr
       WHERE cr.cdcooper = pr_cdcooper
         AND cr.dtrefere = pr_dtrefere
         AND cr.nrdconta = pr_nrdconta
         AND cr.nrctremp = pr_nrctremp
         AND cr.inddocto = 2 -- Registro de Saida na Central
         AND rownum      = 1;
    rw_crapris  cr_crapris%ROWTYPE;

  BEGIN
    -- Inicializa como não existe
    pr_situacao := 0;


    OPEN cr_crapris (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp
                    ,pr_dtrefere => pr_dtrefere);
    FETCH cr_crapris INTO rw_crapris;
    IF cr_crapris%FOUND THEN
      pr_situacao := 1;
    ELSE
      pr_situacao := 0;
    END IF;
    CLOSE cr_crapris;

  EXCEPTION

    WHEN OTHERS THEN
      pr_situacao := 0;
      pr_dscritic := 'Erro na rotina verificarSaidas. Descrição: ' || SQLERRM;
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

  END verificarSaidas;

END RISC0001_3103;
/
