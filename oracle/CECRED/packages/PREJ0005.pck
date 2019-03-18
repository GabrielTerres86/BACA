CREATE OR REPLACE PACKAGE CECRED.PREJ0005 AS
/*..............................................................................

   Programa: PREJ0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Luis Fernando (GFT)
   Data    : 27/08/2018                      Ultima atualizacao: 13/09/2018

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Rotinas de controle de prejuizo para borderos

   Alteracoes: 13/09/2018 - Quando cancelar o Limite de Desconto de Títulos na pc_bloqueio_conta_corrente, também cancelar sua
                            proposta Principal e as Propostas de Manutenção, conforme o que ocorre atualmente na
                            b1wgen0030.efetua_cancelamento_limite (Andrew Albuquerque - GFT)
..............................................................................*/
  -- Códigos contábeis
  -- Transferência
  vr_cdhistordsct_principal           CONSTANT craphis.cdhistor%TYPE := 2754; -- CONTABIL: TRF.PREJUIZO DESC.TIT
  vr_cdhistordsct_juros_60_rem        CONSTANT craphis.cdhistor%TYPE := 2755; -- CONTABIL: TRF. PREJ. JUROS DESC
  vr_cdhistordsct_juros_60_mor        CONSTANT craphis.cdhistor%TYPE := 2761; -- CONTABIL: TRF. PREJ. JUROS DESC
  vr_cdhistordsct_multa_atraso        CONSTANT craphis.cdhistor%TYPE := 2764; -- CONTABIL: MULTA Compensação
  vr_cdhistordsct_juros_mora          CONSTANT craphis.cdhistor%TYPE := 2765; -- CONTABIL: JUROS MORA
  vr_cdhistordsct_juros_60_mul        CONSTANT craphis.cdhistor%TYPE := 2879; -- CONTABIL: REVERSAO MULTA DESCONTO DE TITULO PREJUIZO

  -- Diario
  vr_cdhistordsct_juros_atuali        CONSTANT craphis.cdhistor%TYPE := 2763; -- CONTABIL: JUROS PREJUIZO

  -- Recuperação
  vr_cdhistordsct_rec_principal       CONSTANT craphis.cdhistor%TYPE := 2770; -- PAG.PREJUIZO PRINCIP.
  vr_cdhistordsct_rec_jur_60          CONSTANT craphis.cdhistor%TYPE := 2771; -- PGTO JUROS +60
  vr_cdhistordsct_rec_jur_atuali      CONSTANT craphis.cdhistor%TYPE := 2772; -- PAGTO JUROS  PREJUIZO
  vr_cdhistordsct_rec_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2773; -- PGTO MULTA ATRASO
  vr_cdhistordsct_rec_jur_mora        CONSTANT craphis.cdhistor%TYPE := 2774; -- PGTO JUROS MORA
  vr_cdhistordsct_rec_abono           CONSTANT craphis.cdhistor%TYPE := 2689; -- ABONO PREJUIZO
  vr_cdhistordsct_rec_preju           CONSTANT craphis.cdhistor%TYPE := 2876; -- PAG. PREJUIZO SEM ABONO

  -- Extrato do cooperado na recuperação
  vr_cdhistordsct_recup_preju         CONSTANT craphis.cdhistor%TYPE := 2386; -- RECUPERAÇÃO DE PREJUÍZO
  vr_cdhistordsct_recup_iof           CONSTANT craphis.cdhistor%TYPE := 2317; --  IOF COMPLEMENTAR RECUPERAÇÃO DE PREJUIZO

  -- Estorno
  vr_cdhistordsct_est_rec_princi      CONSTANT craphis.cdhistor%TYPE := 2387; -- ESTORNO RECUPERAÇÃO
  vr_cdhistordsct_est_principal       CONSTANT craphis.cdhistor%TYPE := 2775; -- ESTORNO PREJUIZO PRINCIPAL
  vr_cdhistordsct_est_jur_60          CONSTANT craphis.cdhistor%TYPE := 2776; -- ESTORNO JUROS +60
  vr_cdhistordsct_est_jur_prej        CONSTANT craphis.cdhistor%TYPE := 2777; -- ESTORNO JUROS PREJUIZO
  vr_cdhistordsct_est_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2778; -- ESTORNO MULTA ATRASO
  vr_cdhistordsct_est_jur_mor         CONSTANT craphis.cdhistor%TYPE := 2779; -- ESTORNO JUROS MORA
  vr_cdhistordsct_est_abono           CONSTANT craphis.cdhistor%TYPE := 2690; -- ESTORNO ABONO
  vr_cdhistordsct_est_preju           CONSTANT craphis.cdhistor%TYPE := 2877; -- ESTORNO PAG. PREJUIZO SEM ABONO


  --Tipo de Desconto de Títulos
  TYPE typ_prejuizo IS RECORD(
     dtliqprj DATE
    ,dtprejuz DATE
    ,inprejuz crapbdt.inprejuz%TYPE
    ,vlaboprj NUMBER(25,2)
    ,qtdirisc INTEGER
    ,diasatrs INTEGER
    ,nrdconta crapbdt.nrdconta%TYPE
    ,toprejuz NUMBER(25,2)
    ,tosdprej NUMBER(25,2)
    ,tojrmprj NUMBER(25,2)
    ,tojraprj NUMBER(25,2)
    ,topgjrpr NUMBER(25,2)
    ,tottjmpr NUMBER(25,2)
    ,topgjmpr NUMBER(25,2)
    ,tottmupr NUMBER(25,2)
    ,topgmupr NUMBER(25,2)
    ,toiofprj NUMBER(25,2)
    ,toiofppr NUMBER(25,2)
    ,vlsldatu NUMBER(25,2)
    ,tovlpago NUMBER(25,2)
    ,vlsldaco NUMBER(25,2)
    ,totjur60 NUMBER(25,2)
    ,totpgm60 NUMBER(25,2)
    ,tojrpr60 NUMBER(25,2)
    );
  TYPE typ_tab_preju IS TABLE OF typ_prejuizo INDEX BY PLS_INTEGER;

  PROCEDURE pc_bloqueio_conta_corrente (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                            --------> OUT <--------
                                            ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                            ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                           );

  PROCEDURE pc_transferir_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE         --> Coop conectada
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE    --> Numero do bordero
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2 );

  PROCEDURE pc_executa_job_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                    -- OUT --
                    ,pr_cdcritic OUT PLS_INTEGER
                    ,pr_dscritic OUT VARCHAR2
                    );

  PROCEDURE pc_calcula_saldo_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                      ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                      ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                      ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> codigo do operador
                                      ,pr_cdagenci     IN crapope.cdagenci%TYPE  --> codigo da agencia
                                      ,pr_nrdcaixa     IN INTEGER  --> numero do caixa
                                      ,pr_cdorigem     IN INTEGER DEFAULT 0
                                      -- OUT --
                                      ,pr_possui_saldo OUT INTEGER
                                      ,pr_mensagem_ret OUT VARCHAR2
                                      ,pr_cdcritic OUT PLS_INTEGER
                                      ,pr_dscritic OUT VARCHAR2
                                      );

  PROCEDURE pc_busca_dados_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                   ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                   -- OUT --
                                   ,pr_tab_prej OUT prej0005.typ_tab_preju
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2
                                   );

  PROCEDURE pc_pagar_bordero_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                              ,pr_nrborder  IN crapbdt.nrborder%TYPE
                              ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                              ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                              ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> codigo do operador
                              ,pr_cdagenci     IN crapope.cdagenci%TYPE  --> codigo da agencia
                              ,pr_nrdcaixa     IN INTEGER  --> numero do caixa
                              ,pr_cdorigem     IN INTEGER DEFAULT 0
                              -- OUT --
                              ,pr_liquidou OUT INTEGER
                              ,pr_cdcritic OUT PLS_INTEGER
                              ,pr_dscritic OUT VARCHAR2
                              );

  PROCEDURE pc_liquidar_bordero_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                        -- OUT --
                                        ,pr_liquidou OUT INTEGER
                                        ,pr_cdcritic OUT PLS_INTEGER
                                        ,pr_dscritic OUT VARCHAR2
                                        );

  PROCEDURE pc_calcula_atraso_prejuizo(pr_cdcooper  IN craptdb.cdcooper%TYPE
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                      ,pr_nrborder IN craptdb.nrborder%TYPE
                                      ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                                      ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                                      ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                                      ,pr_nrdocmto IN craptdb.nrdocmto%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      -- OUT --
                                      ,pr_vljraprj OUT NUMBER
                                      ,pr_vljrmprj OUT NUMBER
                                      ,pr_cdcritic OUT PLS_INTEGER
                                      ,pr_dscritic OUT VARCHAR2
                                      );

  PROCEDURE pc_pagar_titulo_prejuizo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                              ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                              ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                              ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                              ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                              ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                              ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                              ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                              ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                              ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                              ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                              ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                              ,pr_vlaboorj    IN NUMBER DEFAULT 0                --Valor do abono
                              ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                              ,pr_dscritic    OUT VARCHAR2);

  PROCEDURE pc_calcula_saldo_prej_risco (pr_cdcooper     IN crapbdt.cdcooper%TYPE
                                        ,pr_nrborder     IN crapbdt.nrborder%TYPE
                                        -- OUT --
                                        ,pr_vlsldprj     OUT NUMBER
                                        ,pr_cdcritic     OUT PLS_INTEGER
                                        ,pr_dscritic     OUT VARCHAR2
                                        );
END PREJ0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0005 AS
/*..............................................................................

   Programa: PREJ0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Luis Fernando
   Data    : 27/08/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Rotinas de controle de prejuizo para borderos

   Alteracoes:
               29/11/2018 - P450 - estória 12166:Transferência Desconto de titulo - Controle
                            da situação da conta corrente (Fabio Adriano - AMcom).

..............................................................................*/

  -- Cursor para calcular o juros de atualizacao +60
  CURSOR cr_tdb60(pr_cdcooper crapbdt.cdcooper%TYPE
                 ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                 ,pr_nrborder crapbdt.nrborder%TYPE
                 ,pr_nrdconta crapbdt.nrdconta%TYPE
                 ,pr_nrtitulo craptdb.nrtitulo%TYPE) IS
  SELECT 
     ROUND(SUM((x.dtvencto-x.dtvenmin60+1)*txdiaria*vltitulo),2) AS vljurrec, -- valor de juros de receita a ser apropriado
     cdcooper,
     nrborder,
     nrdconta
  FROM (
      SELECT UNIQUE
        tdb.dtvencto,
        tdb.vltitulo,
        tdb.cdcooper,
        tdb.vljura60,
        tdb.nrborder,
        tdb.nrdconta,
        (tdb.dtvencto-tdb.dtlibbdt) AS qtd_dias, -- quantidade de dias contabilizados para juros a apropriar
        (tdv.dtvenmin+60) AS dtvenmin60,
        ((bdt.txmensal/100)/30) AS txdiaria
      FROM 
        craptdb tdb
        INNER JOIN (SELECT 
                      cdcooper,nrborder,MIN(dtvencto) AS dtvenmin ,nrdconta
                    FROM craptdb 
                    WHERE (dtvencto+60) < pr_dtmvtolt 
                      AND insittit = 4 
                      AND cdcooper = pr_cdcooper
                      AND nrborder = pr_nrborder
                      AND nrdconta = pr_nrdconta
                    GROUP BY cdcooper,nrborder,nrdconta
                    ) tdv ON tdb.cdcooper=tdv.cdcooper AND tdb.nrborder=tdv.nrborder
        INNER JOIN crapbdt bdt ON bdt.nrborder=tdb.nrborder AND bdt.cdcooper=tdb.cdcooper AND bdt.flverbor=1 
        INNER JOIN crapass ass ON bdt.nrdconta=ass.nrdconta AND bdt.cdcooper=ass.cdcooper
      WHERE 1=1
        AND tdb.nrtitulo = decode(nvl(pr_nrtitulo,0), 0, tdb.nrtitulo, pr_nrtitulo)
        AND tdb.insittit = 4
        AND tdb.dtvencto >= (tdv.dtvenmin+60)
        AND tdb.nrborder = pr_nrborder
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.cdcooper = pr_cdcooper
    ) x
    GROUP BY 
      cdcooper,
      nrborder,
      nrdconta;
  rw_craptdb60 cr_tdb60%ROWTYPE;




  PROCEDURE pc_bloqueio_conta_corrente (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                            --------> OUT <--------
                                            ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                            ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                           ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_bloqueio_conta_corrente
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 27/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Bloquear produtos da conta corrente do cooperado

        Alteracoes: 13/09/2018 - Quando cancelar o Limite de Desconto de Títulos, também cancelar sua proposta Principal e as
                                 Propostas de Manutenção, conforme é feita na b1wgen0030.efetua_cancelamento_limite (Andrew Albuquerque - GFT)
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro

      -- Declara cursor de data
      rw_crapdat   btch0001.cr_crapdat%rowtype;

      CURSOR cr_craplim(pr_cdcooper craplim.cdcooper%TYPE
                       ,pr_nrdconta craplim.nrdconta%TYPE) IS
        SELECT l.nrctrlim
          FROM craplim l
         WHERE l.insitlim = 2
           AND l.tpctrlim = 3
           AND l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta;
      vr_nrctrlim  craplim.nrctrlim%TYPE;

      BEGIN
        -- Buscar data do sistema
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        IF (btch0001.cr_crapdat%NOTFOUND) THEN
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
          RAISE vr_exc_erro;
        END IF;
        CLOSE btch0001.cr_crapdat;

        -- Bloqueio cartao magnetico
        BEGIN
          UPDATE
            crapcrm
          SET
            crapcrm.cdsitcar = 4 -- Bloqueado
            ,crapcrm.dtcancel = rw_crapdat.dtmvtolt
            ,crapcrm.dttransa = trunc(sysdate)
          WHERE
            crapcrm.cdcooper = pr_cdcooper
            AND crapcrm.nrdconta = pr_nrdconta
            AND crapcrm.cdsitcar NOT IN (3,4)
          ;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao cancelar cartão magnético: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Bloqueio senha internet
        BEGIN
          UPDATE
            crapsnh
          SET
            crapsnh.cdsitsnh = 2 -- Bloqueado
            ,crapsnh.dtblutsh = rw_crapdat.dtmvtolt
            ,crapsnh.dtaltsit = rw_crapdat.dtmvtolt
        WHERE
          crapsnh.cdcooper = pr_cdcooper
          AND crapsnh.nrdconta = pr_nrdconta
          AND crapsnh.cdsitsnh = 1 -- Ativa
          AND crapsnh.tpdsenha = 1 -- Internet
          AND crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar senha internet: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE
          crapmcr
        SET
          crapmcr.dtcancel = rw_crapdat.dtmvtolt
        WHERE
          crapmcr.cdcooper = pr_cdcooper
          AND crapmcr.nrdconta = pr_nrdconta
          AND crapmcr.tpctrmif = 3
        ;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar LIMITE: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      vr_nrctrlim := null;
      --awae: Biscar o número de contrato de Limite de Desconto de Título Ativo.
      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craplim INTO vr_nrctrlim;
    CLOSE cr_craplim;

      -- Cancelamento de Contrato, Proposta Ativa e Propostas de Manutenção de Limite de Desconto de Título
      IF nvl(vr_nrctrlim,0) > 0 THEN

        BEGIN
          -- Cancelamento de Contrato de Limite de Desconto de Título
          UPDATE
            craplim
          SET
            craplim.insitlim = 3 -- Cancelado
            ,craplim.dtfimvig = rw_crapdat.dtmvtolt
            ,craplim.dtcancel = rw_crapdat.dtmvtolt
          WHERE
            craplim.cdcooper = pr_cdcooper
            AND craplim.nrdconta = pr_nrdconta
            AND craplim.insitlim = 2
            AND craplim.tpctrlim = 3
          ;
        EXCEPTION
          when others then
            vr_dscritic := 'Erro ao cancelar Limite: ' || sqlerrm;
            raise vr_exc_erro;
        END;

        -- Cancelamento de Proposta Principal de Criação de Limite de Desconto de Título
        BEGIN
          UPDATE
            crawlim
          SET
            crawlim.insitlim = 3 -- Cancelado
            ,crawlim.dtfimvig = rw_crapdat.dtmvtolt
          WHERE
            crawlim.cdcooper = pr_cdcooper
            AND crawlim.nrdconta = pr_nrdconta
            AND crawlim.nrctrlim = vr_nrctrlim
            AND crawlim.tpctrlim = 3
          ;
        EXCEPTION
          when others then
            vr_dscritic := 'Erro ao cancelar Proposta Principal de Limite: ' || sqlerrm;
            raise vr_exc_erro;
        END;

        -- Cancelamento das Propostas de Manutenção de Limite de Desconto de Título
        BEGIN
          UPDATE
            crawlim
          SET
            crawlim.insitlim = 3 -- Cancelado
            ,crawlim.dtfimvig = rw_crapdat.dtmvtolt
          WHERE
            crawlim.cdcooper = pr_cdcooper
            AND crawlim.nrdconta = pr_nrdconta
            AND crawlim.nrctrmnt = vr_nrctrlim
            AND crawlim.tpctrlim = 3
          ;

        EXCEPTION
          when others then
            vr_dscritic := 'Erro ao cancelar Propostas de Manutenção do Limite: ' || sqlerrm;
            raise vr_exc_erro;
        END;

        -- Faz lançamento do log da proposta
        TELA_ATENDA_DSCTO_TIT.pc_gravar_hist_alt_limite(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrlim => vr_nrctrlim
                            ,pr_tpctrlim => 3
                            ,pr_dsmotivo => 'CANCELAMENTO PREJUÍZO'
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            );
        IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao nao tratado na rotina pc_bloqueio_conta_corrente: ' ||SQLERRM;
  END pc_bloqueio_conta_corrente;

  PROCEDURE pc_transferir_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Coop conectada
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE    --> Numero do bordero
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS
    /* .............................................................................

    Programa: pc_transferir_prejuizo
    Sistema :
    Sigla   : CRED
    Autor   : Luis Fernando
    Data    : 27/08/2018                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Transferir o bordero para prejuizo e bloquear os respectivos acessos do cooperado

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.nrborder,
        bdt.nrdconta,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtlibbdt,
        bdt.insitbdt,
        bdt.qtdirisc,
        bdt.nrinrisc
      FROM
        crapbdt bdt
      WHERE
        bdt.nrborder = pr_nrborder
        AND bdt.cdcooper = pr_cdcooper
    ;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    CURSOR cr_crapbdt_prej (pr_nrdconta craptdb.nrdconta%TYPE, pr_cdcooper craptdb.cdcooper%TYPE, pr_nrborder craptdb.nrborder%TYPE)  IS
      SELECT
        SUM(tdb.vlprejuz) AS vlprejuz,
        SUM(tdb.vlsdprej) AS vlsdprej,
        SUM(tdb.vlttmupr) AS vlttmupr,
        SUM(tdb.vlttjmpr) AS vlttjmpr,
        SUM(tdb.vliofprj) AS vliofprj,
        SUM((vljura60 - vlpgjm60)) AS sdjura60
      FROM
        craptdb tdb
      WHERE
        tdb.nrdconta = pr_nrdconta
        AND tdb.cdcooper = pr_cdcooper
        AND tdb.nrborder = pr_nrborder
      GROUP BY
        tdb.nrborder,
        tdb.cdcooper,
        tdb.nrdconta
      ;
    rw_crapbdt_prej cr_crapbdt_prej%ROWTYPE;

    -- Cursor para calcular o juros de atualizacao +60
    CURSOR cr_tdb60 (pr_cdcooper crapbdt.cdcooper%TYPE, pr_dtmvtolt crapdat.dtmvtolt%TYPE, pr_nrborder crapbdt.nrborder%TYPE, pr_nrdconta crapbdt.nrdconta%TYPE) IS
      SELECT
         SUM((x.dtvencto-x.dtvenmin60+1)*txdiaria*vltitulo) AS vljurrec, -- valor de juros de receita a ser apropriado
         cdcooper,
         nrborder,
         nrdconta,
         rowtdb
      FROM (
          SELECT UNIQUE
            tdb.dtvencto,
            tdb.vltitulo,
            tdb.cdcooper,
            tdb.nrborder,
            tdb.nrdconta,
            (tdb.dtvencto-tdb.dtlibbdt) AS qtd_dias, -- quantidade de dias contabilizados para juros a apropriar
            (tdv.dtvenmin+60) AS dtvenmin60,
            ((bdt.txmensal/100)/30) AS txdiaria,
            tdb.rowid rowtdb
          FROM
            craptdb tdb
            INNER JOIN (SELECT
                          cdcooper,nrborder,MIN(dtvencto) AS dtvenmin ,nrdconta
                        FROM craptdb
                        WHERE (dtvencto+60) < pr_dtmvtolt
                          AND insittit = 4
                          AND cdcooper = pr_cdcooper
                          AND nrborder = pr_nrborder
                          AND nrdconta = pr_nrdconta
                        GROUP BY cdcooper,nrborder,nrdconta
                        ) tdv ON tdb.cdcooper=tdv.cdcooper AND tdb.nrborder=tdv.nrborder
            INNER JOIN crapbdt bdt ON bdt.nrborder=tdb.nrborder AND bdt.cdcooper=tdb.cdcooper AND bdt.flverbor=1
            INNER JOIN crapass ass ON bdt.nrdconta=ass.nrdconta AND bdt.cdcooper=ass.cdcooper
          WHERE 1=1
            AND tdb.insittit = 4
            AND tdb.dtvencto >= (tdv.dtvenmin+60)
            AND tdb.nrborder = pr_nrborder
            AND tdb.nrdconta = pr_nrdconta
            AND tdb.cdcooper = pr_cdcooper
        ) x
        GROUP BY
          cdcooper,
          nrborder,
          nrdconta,
          rowtdb ;
    rw_craptdb60 cr_tdb60%ROWTYPE;

    CURSOR cr_craptdb (pr_nrborder craptdb.nrborder%TYPE,pr_nrdconta craptdb.nrdconta%TYPE, pr_cdcooper craptdb.cdcooper%TYPE) IS
      SELECT
        ROWID id,
        (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
        (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
        vlmratit,
        nrtitulo,
        cdcooper,
        nrdconta,
        nrborder,
        cdbandoc,
        nrdctabb,
        nrcnvcob,
        nrdocmto
      FROM
        craptdb
      WHERE
        craptdb.nrborder = pr_nrborder
        AND craptdb.nrdconta = pr_nrdconta
        AND craptdb.insittit = 4 -- apenas titulos liberados
        AND craptdb.cdcooper = pr_cdcooper;

    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                          ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                          ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                          ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt
       AND lcb.dtestorn IS NULL;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;

    rw_crapdat   btch0001.cr_crapdat%rowtype;

    ---->> VARIAVEIS <<-----
    vr_jurmor60 NUMBER;
    
    ---->> TRATAMENTO DE ERROS <<-----
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN
      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_cdcritic := 1166; -- bordero nao encontrado
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;

      IF (rw_crapbdt.inprejuz=1) THEN
        vr_dscritic := 'Bordero ja esta em prejuizo';
        RAISE vr_exc_erro;
      END IF;

      IF (rw_crapbdt.insitbdt<>3) THEN
        vr_cdcritic := 1175; -- bordero diferente de liberado
        RAISE vr_exc_erro;
      END IF;

      IF (rw_crapbdt.nrinrisc<>9 OR rw_crapbdt.qtdirisc<180) THEN
        vr_dscritic := 'Borderô deve estar no risco H há mais de 180 dias';
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza bordero para prejuizo
      UPDATE
        crapbdt
      SET
        inprejuz = 1,
        dtprejuz = rw_crapdat.dtmvtolt,
        nrinrisc = 10,
        qtdirisc = 0
      WHERE
        ROWID = rw_crapbdt.id
      ;

      -- Atualiza os saldos de prejuizo
      UPDATE
        craptdb
      SET
        vlprejuz = vlsldtit + (vlmratit - vlpagmra) - (vljura60 - vlpgjm60), --Prejuízo original – Valor transferido para prejuízo valor transferido sem incidência de juros, multa, IOF e Juros Remuneratório (conforme cursor abaixo cr_tdb60)
        vlsdprej = vlsldtit, -- Saldo prejuízo original – Saldo devedor do prejuízo original sem somar juros e multa, IOF.
        vlttmupr = vlmtatit - vlpagmta, -- Multa – Deverá apresentar o valor de multa até a após transferência para prejuízo.
        vljrmprj = 0, -- Juros do mês – Valor cobrado de juros remuneratórios de prejuízo no mês.
        vlttjmpr = vlmratit - vlpagmra, -- Juros de mora – Valor de juros de mora cobrados até a data da transferência.
        vlpgjmpr = 0, -- Valores pagos de Juros de mora – Valores que já foram pagos de juros de mora após a transferência para prejuízo.
        vlpgmupr = 0, -- Vlr pago Multa – Valores que já foram pagos de multa após a transferência para prejuízo
        vlsprjat = 0, -- Saldo em prejuizo do dia anterior
        vljraprj = 0, -- Juros acumulados – Valor total de juros remuneratórios desde a transferência para prejuízo.
        vliofprj = (vliofcpl - vlpagiof), -- IOF Atraso – Valor do IOF complementar de atraso até a data da transferência
        vliofppr = 0, -- VLR Pg IOF – Valores que já foram pagos de IOF após a transferência
        vlpgjrpr = 0 -- Valor pago dos juros acumulados
      WHERE
        nrborder = rw_crapbdt.nrborder
        AND nrdconta = rw_crapbdt.nrdconta
        AND insittit = 4 -- apenas titulos liberados
        AND cdcooper = rw_crapbdt.cdcooper;    

      -- Buscar juros 60 remuneratório para atualizar o valor do prejuizo somente dos titulos que passaram de 60
      vr_jurmor60 := 0;
      OPEN cr_tdb60(pr_nrdconta => rw_crapbdt.nrdconta
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_cdcooper => rw_crapbdt.cdcooper
                   ,pr_nrborder => rw_crapbdt.nrborder);
      LOOP
        FETCH cr_tdb60 INTO rw_craptdb60;
        EXIT WHEN cr_tdb60%NOTFOUND;
        
        vr_jurmor60 := vr_jurmor60 + rw_craptdb60.vljurrec;

        UPDATE craptdb tdb
           SET vlprejuz = vlprejuz - rw_craptdb60.vljurrec
         WHERE tdb.rowid = rw_craptdb60.rowtdb;
      END LOOP;
      CLOSE cr_tdb60;
      vr_jurmor60 := round(vr_jurmor60,2);

      IF (vr_jurmor60 > 0) THEN
        -- (Crédito) 2755 - TRF.PREJ JUROS DESC
        -- O lançamento do histórico 2755 no momento da transferência para prejuízo refere-se ao valor de juros +60 remuneratório do prejuízo (ver cursor da tela RISCO_K)
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapbdt.nrdconta
                                     ,pr_nrborder => rw_crapbdt.nrborder
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdorigem => 5
                                     ,pr_cdhistor => vr_cdhistordsct_juros_60_rem
                                     ,pr_vllanmto => vr_jurmor60
                                     ,pr_dscritic => vr_dscritic );
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- Verifica os valores totais das transferencias para prejuizo para fazer os respectivos lançamentos contábeis
      OPEN cr_crapbdt_prej(pr_nrdconta => rw_crapbdt.nrdconta, pr_cdcooper => rw_crapbdt.cdcooper, pr_nrborder => rw_crapbdt.nrborder);
      FETCH cr_crapbdt_prej INTO rw_crapbdt_prej;
      CLOSE cr_crapbdt_prej;

      IF (rw_crapbdt_prej.sdjura60 > 0) THEN
        -- (Crédito) 2761 - TRF.PREJ JUROS DESC
        -- O lançamento do histórico 2761 no momento da transferência para prejuízo refere-se ao valor de juros +60 de mora do prejuízo (ver cursor da tela RISCO_K)
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapbdt.nrdconta
                                     ,pr_nrborder => rw_crapbdt.nrborder
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdorigem => 5
                                     ,pr_cdhistor => vr_cdhistordsct_juros_60_mor
                                     ,pr_vllanmto => rw_crapbdt_prej.sdjura60
                                     ,pr_dscritic => vr_dscritic );
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- (Crédito) 2754 - TRF.PREJUIZO DESC.TIT
      -- O lançamento do histórico 2754 no momento da transferência para prejuízo refere-se ao valor principal do prejuízo, conforme o cálculo abaixo:
      -- Valor principal do Prejuízo - Valor de Juros +60 Remuneratório (ver cursor da tela RISCO_K) + (Valor de Juros de Mora - Valor de Juros +60 de Mora)
      -- SOMA tudo no vlsdtitulo - "tdb dos +60" + ("valor mora" - "valor mora +60")
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_principal
                                   ,pr_vllanmto => rw_crapbdt_prej.vlprejuz
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      -- (Débito) 2764 - MULTA
      -- O lançamento do histórico 2764 no momento da transferência para prejuízo refere-se ao valor de multa do prejuízo.
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_multa_atraso
                                   ,pr_vllanmto => rw_crapbdt_prej.vlttmupr
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      -- (Débito) 2879 - MULTA
      -- O lançamento do histórico 2879 no momento da transferência para prejuízo refere-se ao valor de multa do prejuízo.
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_juros_60_mul
                                   ,pr_vllanmto => rw_crapbdt_prej.vlttmupr
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      -- (Débito) 2765 - JUROS MORA
      -- O lançamento do histórico 2765 no momento da transferência para prejuízo refere-se ao valor de juros de mora do prejuízo.
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_juros_mora
                                   ,pr_vllanmto => rw_crapbdt_prej.sdjura60
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

      -- Lança apropriação de Juros de Mora e de Multa de cada titulo que foi transferido para prejuizo
      FOR rw_craptdb IN cr_craptdb (pr_nrborder => rw_crapbdt.nrborder,
                                     pr_nrdconta => rw_crapbdt.nrdconta,
                                     pr_cdcooper => pr_cdcooper) LOOP
        IF rw_craptdb.vlmtatit_restante > 0 THEN
          -- Lançar valor de apropriação da multa nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_craptdb.cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                       ,pr_nrtitulo => rw_craptdb.nrtitulo
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmta
                                       ,pr_vllanmto => rw_craptdb.vlmtatit_restante
                                       ,pr_dscritic => vr_dscritic );

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
        IF rw_craptdb.vlmratit_restante > 0  THEN
          OPEN cr_lancboraprop(pr_cdcooper => rw_craptdb.cdcooper
                              ,pr_nrdconta => rw_craptdb.nrdconta
                              ,pr_nrborder => rw_craptdb.nrborder
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                              ,pr_cdbandoc => rw_craptdb.cdbandoc
                              ,pr_nrdctabb => rw_craptdb.nrdctabb
                              ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                              ,pr_nrdocmto => rw_craptdb.nrdocmto
                              );
          FETCH cr_lancboraprop INTO rw_lancboraprop;
          CLOSE cr_lancboraprop;

          -- Lançar valor de apropriação dos juros nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_craptdb.cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                       ,pr_nrtitulo => rw_craptdb.nrtitulo
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                                       ,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                       ,pr_dscritic => vr_dscritic );

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;

      pc_bloqueio_conta_corrente(pr_cdcooper => rw_crapbdt.cdcooper
                                 ,pr_nrdconta => rw_crapbdt.nrdconta
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao não tratado na rotina pc_transferir_prejuizo: ' ||SQLERRM;
  END pc_transferir_prejuizo;

  PROCEDURE pc_executa_job_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                    -- OUT --
                    ,pr_cdcritic OUT PLS_INTEGER
                    ,pr_dscritic OUT VARCHAR2
                    ) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_executa_job_prejuizo
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 29/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Executa rotina que verifica os borderos que devem ser enviados para prejuizo e os transfere
      ---------------------------------------------------------------------------------------------------------------------*/

      ---->> CURSORES <<-----
      CURSOR cr_crapbdt IS
        SELECT
          bdt.rowid AS id,
          bdt.nrborder,
          bdt.nrdconta,
          bdt.cdcooper,
          bdt.inprejuz,
          bdt.dtlibbdt,
          bdt.insitbdt,
          bdt.qtdirisc,
          bdt.nrinrisc
        FROM
          crapbdt bdt
        WHERE
          bdt.nrinrisc = 9
          AND bdt.qtdirisc>=180
          AND bdt.inprejuz=0
      ;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        OPEN cr_crapbdt;
        LOOP FETCH cr_crapbdt INTO rw_crapbdt;
          EXIT WHEN cr_crapbdt%NOTFOUND;
          pc_transferir_prejuizo(pr_cdcooper  => rw_crapbdt.cdcooper
                                 ,pr_nrborder => rw_crapbdt.nrborder
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          IF (NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
            RAISE vr_exc_erro;
          END IF;
        END LOOP;

      EXCEPTION
        WHEN vr_exc_erro THEN
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina PREJ0005.pc_executa_job_prejuizo: ' || SQLERRM;

  END pc_executa_job_prejuizo;

  PROCEDURE pc_calcula_saldo_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                      ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                      ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                      ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> codigo do operador
                                      ,pr_cdagenci     IN crapope.cdagenci%TYPE  --> codigo da agencia
                                      ,pr_nrdcaixa     IN INTEGER  --> numero do caixa
                                      ,pr_cdorigem     IN INTEGER DEFAULT 0
                                      -- OUT --
                                      ,pr_possui_saldo OUT INTEGER
                                      ,pr_mensagem_ret OUT VARCHAR2
                                      ,pr_cdcritic OUT PLS_INTEGER
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_saldo_prejuizo
          + > pr_cdorigpg: Código da origem do processo de pagamento
                           0 - Sem nada
                           1 - Sem nada
                           2 - Pagamento COBTIT
     Sistema  :
     Sigla    : CRED
     Autor    : Luis Fernando (GFT)
     Data     : 10/09/2018
     Frequencia: Sempre que for chamado
     Objetivo  : Buscar o Saldo em Conta do cooperado e verificar a alcada do operador para calculo de prejuizo
     Alterações:
      - 16/10/2018 - Inserção da origem na chamada da procedure e tratativa para COBTIT (Vitor S. Assanuma - GFT)
   ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

    -- Variável de Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_total    NUMBER(25,2);
    vr_total_saldo NUMBER(25,2);
    vr_vlsldatu    craptdb.vlsdprej%TYPE;

    -- Variaveis do calculo de saldo
    vr_vllimcre crapass.vllimcre%TYPE;
    vr_des_reto VARCHAR2(5);
    vr_tab_sald EXTR0001.typ_tab_saldos;
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Retorno da tabela de prejuizo
    vr_tab_prej typ_tab_preju;

    -- Cursor para pegar a alcada do operador
    CURSOR cr_crapope(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE
                   ) IS
       SELECT  vlpagchq
       FROM  crapope ope
       WHERE ope.cdcooper = pr_cdcooper
             AND TRIM(UPPER(ope.cdoperad)) = TRIM(UPPER(pr_cdoperad))
    ;
    rw_crapope cr_crapope%rowtype;

    -- Cursor para verifica limite do cooperado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT
        vllimcre
      FROM
        crapass
      WHERE
        cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
      ;
    rw_crapass cr_crapass%ROWTYPE;

    -- Verifica se possui permissao de abono
    CURSOR cr_crapace (pr_cdoperad crapace.cdoperad%TYPE) IS
      SELECT 1
        FROM crapace ace
       WHERE ace.cdcooper = pr_cdcooper
         AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
         AND UPPER(ace.nmdatela) = 'ATENDA'
         AND ace.idambace = 2
         AND UPPER(ace.cddopcao) = 'B'
         AND UPPER(ace.nmrotina) = 'DSC TITS - BORDERO';
    rw_crapace cr_crapace%ROWTYPE;

    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Busca as informações do bordero em prejuizo
      PREJ0005.pc_busca_dados_prejuizo(pr_cdcooper => pr_cdcooper
                             ,pr_nrborder => pr_nrborder
                             -- OUT --
                             ,pr_tab_prej => vr_tab_prej
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Variavel de verificacao se possui saldo suficiente para os titulos
      pr_possui_saldo := 0;

      -- Verifica se tem ABONO e se tem permissao
      -- Cursor para verificar se operador tem acesso a opção de baixa da tela
      OPEN cr_crapace (pr_cdoperad=>pr_cdoperad);
      FETCH cr_crapace INTO rw_crapace;
      IF pr_vlaboorj > 0 AND cr_crapace%NOTFOUND AND pr_cdoperad <> '1' THEN
        CLOSE cr_crapace;
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Não possui permissão de abono';
        -- Gera exceção
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapace;

      vr_total    := pr_vlpagmto + pr_vlaboorj;
      vr_vlsldatu := vr_tab_prej(0).vlsldatu - vr_tab_prej(0).vlsldaco;

      -- Lucas GFT:
      -- Adicionada tratativa para validar se o valor total equivale ao saldo do prejuízo
      --            somente quando a rotina for chamada pelo processo de pagamento manual do prejuízo pelo sistema Aimaro
      --
      --            Esta validação de saldo pela COBTIT não pode ser realizada pois poderá ocorrer a criação de um acordo
      --            de um dos títulos do borderô em prejuízo após a emissão de uma COBTIT para pagamento total do prejuízo

      IF (pr_vlaboorj < 0 OR pr_vlpagmto < 0 OR (vr_total > vr_vlsldatu AND pr_cdorigem <> 2)) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de pagamento inválido';
        RAISE vr_exc_erro;
      END IF;

      -- Caso não esteja quitando o prejuízo e NÃO seja um pagamento de COBTIT, estoura erro ao tentar dar ABONO.
      IF (pr_vlaboorj > 0 AND vr_total <> vr_vlsldatu AND pr_cdorigem <> 2) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Abono só pode existir para quitar o valor total do prejuízo';
        RAISE vr_exc_erro;
      END IF;


      IF (vr_total <= 0) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de pagamento não pode ser zero';
        RAISE vr_exc_erro;
      END IF;

       -- Limite da conta
      OPEN cr_crapass (pr_cdcooper=>pr_cdcooper,pr_nrdconta => vr_tab_prej(0).nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF (cr_crapass%NOTFOUND) THEN
        CLOSE cr_crapass;
        vr_cdcritic := 564;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      vr_vllimcre := rw_crapass.vllimcre;

      -- Se o pagamento vier da COBTIT, não é necessário consultar o saldo do cooperado, visto
      IF pr_cdorigem = 2 THEN
        pr_possui_saldo := 1; -- Possui Saldo
        pr_mensagem_ret := 'Utilizando valor do boleto pago';
      ELSE
        extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => pr_cdagenci
                                 ,pr_nrdcaixa   => pr_nrdcaixa
                                 ,pr_cdoperad   => pr_cdoperad
                                 ,pr_nrdconta   => vr_tab_prej(0).nrdconta
                                 ,pr_vllimcre   => vr_vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => TRUE
                                 ,pr_tipo_busca => 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                 ,pr_des_reto   => vr_des_reto --> OK ou NOK
                                 ,pr_tab_sald   => vr_tab_sald
                                 ,pr_tab_erro   => vr_tab_erro);
        IF (vr_des_reto = 'NOK') THEN
          vr_dscritic := 'Erro ao recuperar saldo do cooperado. Saldo inválido';
          RAISE vr_exc_erro;
        END IF;
        -- Verifica se o saldo e maior ou menor que o prejuizo
        vr_total_saldo := NVL(vr_tab_sald(0).vlsddisp, 0) + vr_vllimcre;
        
        -- Caso o saldo + limite seja maior que o custo da soma dos titulos
        IF vr_total <= vr_total_saldo THEN
          pr_possui_saldo := 1; -- Possui Saldo
          pr_mensagem_ret := 'Utilizando Saldo do Cooperado.';
        ELSE -- Caso nao tenha saldo, verifica a alcada do operador
          OPEN  cr_crapope(pr_cdcooper => pr_cdcooper, pr_cdoperad => pr_cdoperad);
          FETCH cr_crapope into rw_crapope;
          IF (cr_crapope%NOTFOUND) THEN
            CLOSE cr_crapope;
            vr_cdcritic := 67;
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_crapope;
          IF (vr_total-vr_total_saldo) <= rw_crapope.vlpagchq THEN
            pr_possui_saldo := 2; -- Possui Alcada
            pr_mensagem_ret := 'Utilizando alçada do Operador.';
          ELSE
            pr_possui_saldo := 0;
            pr_mensagem_ret := 'Saldo e alçada insuficientes.';
          END IF;
        END IF;
      END IF;
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina PREJ0005.pc_calcula_saldo_prejuizo: ' || SQLERRM;

   END pc_calcula_saldo_prejuizo;

   PROCEDURE pc_busca_dados_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                   ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                   -- OUT --
                                   ,pr_tab_prej OUT prej0005.typ_tab_preju
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2
                                   ) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_prejuizo
      Sistema  :
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 24/08/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Buscar os valores de prejuizo do bordero e titulos
      Alterações:
       -- 11/09/2018 - Alteração dos campos no select (Vitor S Assanuma - GFT)
       -- 20/09/2018 - Inserção de validação de acordo e retorno do valor ao front (Vitor S Assanuma - GFT)
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
    vr_dscritic VARCHAR2(1000);        --> desc. erro

    -- Vetor da chave do titulo
    vr_index INTEGER;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;

    -- Cursor Bordero somatório
    CURSOR cr_crapbdt IS
      SELECT
        bdt.dtliqprj
        ,bdt.dtprejuz                        -- Data de envio para prejuizo
        ,bdt.inprejuz                        -- Flag que define se entrou em prejuizo
        ,bdt.vlaboprj                        -- Abono
        ,bdt.qtdirisc
        ,bdt.nrdconta
        ,SUM(tdb.vlprejuz)        AS toprejuz -- Valor do Prejuizo Original
        ,SUM(tdb.vlsdprej)        AS tosdprej -- Saldo em Prejuizo
        ,SUM(tdb.vljrmprj)        AS tojrmprj -- Juros Acumulados no mês
        ,SUM(tdb.vljraprj)        AS tojraprj -- Juros Remuneratórios no prejuizo
        ,SUM(tdb.vlpgjrpr)        AS topgjrpr -- Valor PAGO dos juros Remuneratórios
        ,SUM(tdb.vlttjmpr)        AS tottjmpr -- Valor dos juros de Mora
        ,SUM(tdb.vlpgjmpr)        AS topgjmpr -- Valor PAGO dos juros de Mora
        ,SUM(tdb.vlttmupr)        AS tottmupr -- Valor dos juros de Multa
        ,SUM(tdb.vlpgmupr)        AS topgmupr -- Valor PAGO dos juros de Multa
        ,SUM(tdb.vliofprj)        AS toiofprj -- Valor dos juros de IOF
        ,SUM(tdb.vliofppr)        AS toiofppr -- Valor PAGO dos juros de IOF
        ,SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)
          + (tdb.vliofprj - tdb.vliofppr)
                                ) AS vlsldatu -- Saldo atualizado
        ,SUM((tdb.vlsldtit - tdb.vlsdprej)+ vlpgjmpr + vlpgmupr + vliofppr) AS tovlpago
        ,MIN(tdb.dtvencto)        AS dtminven -- data de vencimento mais antigo
        ,SUM(tdb.vljura60)        AS totjur60
        ,SUM(tdb.vlpgjm60)        AS totpgm60
      FROM crapbdt bdt
        INNER JOIN craptdb tdb ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
      WHERE bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = pr_nrborder
        AND (tdb.insittit = 4 OR (tdb.insittit=3 AND bdt.dtliqprj IS NOT NULL))
        AND bdt.inprejuz = 1
      GROUP BY
        bdt.dtliqprj, bdt.dtprejuz, bdt.inprejuz, bdt.vlaboprj, bdt.qtdirisc, bdt.nrdconta
    ;rw_crapbdt cr_crapbdt%ROWTYPE;

    -- Cursor de saldo do acordo
    CURSOR cr_crapaco IS
    SELECT SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)
          + (tdb.vliofprj - tdb.vliofppr)
                                ) AS vlsldaco -- Saldo do acordo
       FROM craptdb tdb
       INNER JOIN tbdsct_titulo_cyber ttc
         ON tdb.cdcooper = ttc.cdcooper AND tdb.nrdconta = ttc.nrdconta AND tdb.nrborder = ttc.nrborder AND tdb.nrtitulo = ttc.nrtitulo
       INNER JOIN tbrecup_acordo_contrato tac
         ON ttc.nrctrdsc = tac.nrctremp
       INNER JOIN tbrecup_acordo ta
         ON tac.nracordo = ta.nracordo AND ttc.cdcooper = ta.cdcooper
         -- FALTAVAM ESTES CAMPOS NA CLAUSULA
        AND ta.cdcooper = ttc.cdcooper
        AND ta.nrdconta = ttc.nrdconta
       WHERE tac.cdorigem   = 4 -- Desconto de Títulos
         AND ta.cdsituacao <> 3 -- Acordo não está cancelado
         AND tdb.cdcooper   = pr_cdcooper
         AND tdb.nrborder   = pr_nrborder;
    rw_crapaco cr_crapaco%ROWTYPE;

    BEGIN
      --    Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      vr_index := 0;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF cr_crapbdt%NOTFOUND THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;
      /*
      -- Caso o saldo seja zero, está liquidado
      IF rw_crapbdt.vlsldatu = 0 THEN
        vr_dscritic := 'Prejuízo já liquidado.';
        RAISE vr_exc_erro;
      END IF;*/

      -- Busca para verificar se há algum titulo em acordo
      OPEN cr_crapaco;
      FETCH cr_crapaco INTO rw_crapaco;

      IF rw_crapaco.vlsldaco IS NULL THEN
        pr_tab_prej(vr_index).vlsldaco := 0;
      ELSE
        pr_tab_prej(vr_index).vlsldaco := rw_crapaco.vlsldaco;
      END IF;
      CLOSE cr_crapaco;
      
      rw_craptdb60 := NULL;
      OPEN cr_tdb60(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_nrborder => pr_nrborder
                   ,pr_nrdconta => rw_crapbdt.nrdconta
                   ,pr_nrtitulo => 0);
      FETCH cr_tdb60 INTO rw_craptdb60;
      CLOSE cr_tdb60;

      pr_tab_prej(vr_index).dtliqprj := rw_crapbdt.dtliqprj;
      pr_tab_prej(vr_index).dtprejuz := rw_crapbdt.dtprejuz;
      pr_tab_prej(vr_index).diasatrs := rw_crapdat.dtmvtolt - rw_crapbdt.dtminven;
      pr_tab_prej(vr_index).inprejuz := rw_crapbdt.inprejuz;
      pr_tab_prej(vr_index).vlaboprj := rw_crapbdt.vlaboprj;
      pr_tab_prej(vr_index).qtdirisc := rw_crapbdt.qtdirisc;
      pr_tab_prej(vr_index).nrdconta := rw_crapbdt.nrdconta;
      pr_tab_prej(vr_index).toprejuz := rw_crapbdt.toprejuz;
      pr_tab_prej(vr_index).tosdprej := rw_crapbdt.tosdprej;
      pr_tab_prej(vr_index).tojrmprj := rw_crapbdt.tojrmprj;
      pr_tab_prej(vr_index).tojraprj := rw_crapbdt.tojraprj;
      pr_tab_prej(vr_index).topgjrpr := rw_crapbdt.topgjrpr;
      pr_tab_prej(vr_index).tottjmpr := rw_crapbdt.tottjmpr;
      pr_tab_prej(vr_index).topgjmpr := rw_crapbdt.topgjmpr;
      pr_tab_prej(vr_index).tottmupr := rw_crapbdt.tottmupr;
      pr_tab_prej(vr_index).topgmupr := rw_crapbdt.topgmupr;
      pr_tab_prej(vr_index).toiofprj := rw_crapbdt.toiofprj;
      pr_tab_prej(vr_index).toiofppr := rw_crapbdt.toiofppr;
      pr_tab_prej(vr_index).vlsldatu := rw_crapbdt.vlsldatu;
      pr_tab_prej(vr_index).tovlpago := rw_crapbdt.tovlpago;
      pr_tab_prej(vr_index).totjur60 := rw_crapbdt.totjur60;
      pr_tab_prej(vr_index).totpgm60 := rw_crapbdt.totpgm60;
      pr_tab_prej(vr_index).tojrpr60 := nvl(rw_craptdb60.vljurrec,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina PREJ0005.pc_busca_dados_prejuizo: '||SQLERRM;

  END pc_busca_dados_prejuizo;

  PROCEDURE pc_pagar_bordero_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                              ,pr_nrborder     IN crapbdt.nrborder%TYPE
                              ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                              ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                              ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> codigo do operador
                              ,pr_cdagenci     IN crapope.cdagenci%TYPE  --> codigo da agencia
                              ,pr_nrdcaixa     IN INTEGER  --> numero do caixa
                              ,pr_cdorigem     IN INTEGER DEFAULT 0
                              -- OUT --
                              ,pr_liquidou OUT INTEGER
                              ,pr_cdcritic OUT PLS_INTEGER
                              ,pr_dscritic OUT VARCHAR2
                              ) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_pagar_bordero_prejuizo
          + > pr_cdorigpg: Código da origem do processo de pagamento
                           0 - Sem nada
                           1 - Sem nada
                           2 - Pagamento COBTIT
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 13/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Executar rotinas de pagamento do prejuizo
        Alterações:
         - 19/09/2018 - Remoção dos títulos em acordo do cursor de títulos (Vitor S. Assanuma - GFT)
         - 16/10/2018 - Inserção do tipo na chamada da procedure (Vitor S. Assanuma - GFT)
         - 30/11/2018 - Inserido lançamento total do pagamento sem abono nos lançamentos bordero (Lucas Negoseki - GFT)
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Verificar saldo
      vr_possui_saldo INTEGER;
      vr_mensagem_ret VARCHAR(100);

      -- Auxiliares para calculo
      vr_total            NUMBER := 0;
      vr_total_pago       NUMBER := 0;
      vr_pagamento_atual  NUMBER := 0;
      vr_pagamento_iof    NUMBER := 0;
      vr_saldo_60         NUMBER := 0;
      vr_pagamento_60     NUMBER := 0;
      vr_total_60         NUMBER := 0;
      vr_total_pago_recup NUMBER := 0;
      
      vr_index PLS_INTEGER;
      vr_total_titulos INTEGER;

      -- CURSORES
      CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.nrdconta,
        bdt.nrborder,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtliqprj,
        bdt.insitbdt
      FROM
        crapbdt bdt
      WHERE
        bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      CURSOR cr_craptdb IS
      SELECT
        tdb.rowid AS id
        ,tdb.insittit
        ,tdb.vlprejuz
        ,tdb.vliofprj
        ,tdb.vliofppr
        ,tdb.vlttjmpr
        ,tdb.vlpgjmpr
        ,tdb.vlttmupr
        ,tdb.vlpgmupr
        ,tdb.vljraprj
        ,tdb.vlpgjrpr
        ,tdb.vlsdprej   -- Valor devido do titulo
        ,(tdb.vliofprj - tdb.vliofppr) AS vlsldiof     -- Saldo iof
        ,(tdb.vlttjmpr - tdb.vlpgjmpr) AS vlsldmora    -- Saldo juros mora
        ,(tdb.vlttmupr - tdb.vlpgmupr) AS vlsldmulta   -- Saldo multa
        ,(tdb.vljraprj - tdb.vlpgjrpr) AS vlsldatual   -- Saldo Atualizacao
        ,(tdb.vljura60 - tdb.vlpgjm60) AS vljura60_restante
        ,tdb.dtvencto
        ,0 AS atualizou
        ,tdb.dtdebito
        ,tdb.dtdpagto
        ,tdb.cdbandoc
        ,tdb.nrdctabb
        ,tdb.nrcnvcob
        ,tdb.nrdocmto
        ,tdb.nrtitulo
        ,tdb.nrdconta
        ,tdb.nrborder
        ,tdb.vlpgjm60
        ,0 AS vlpago60atual
      FROM craptdb tdb
      WHERE tdb.cdcooper = pr_cdcooper
        AND tdb.nrborder = pr_nrborder
        AND tdb.insittit = 4
        -- E não está em nenhum Acordo em aberto
        AND (tdb.nrborder, tdb.nrtitulo) NOT IN (
          SELECT ttc.nrborder, ttc.nrtitulo
          FROM tbdsct_titulo_cyber ttc
            INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp
            INNER JOIN tbrecup_acordo ta           ON tac.nracordo = ta.nracordo
               -- FALTAVAM ESTES CAMPOS NA CLAUSULA
              AND ta.cdcooper = ttc.cdcooper
              AND ta.nrdconta = ttc.nrdconta
          WHERE tac.cdorigem   = 4 -- Desconto de Títulos
            AND ta.cdsituacao <> 3 -- Acordo não está cancelado
            AND tdb.cdcooper = ttc.cdcooper
            AND tdb.nrdconta = ttc.nrdconta
            AND tdb.nrborder = ttc.nrborder
            AND tdb.nrtitulo = ttc.nrtitulo
       )
      ORDER BY dtvencto ASC, vlsdprej DESC
      ;
      TYPE typ_tab_craptdb IS TABLE OF cr_craptdb%ROWTYPE INDEX BY PLS_INTEGER;

      vr_tab_craptdb typ_tab_craptdb;
      
      CURSOR cr_tbdsct_lancamento_bordero (pr_cdcooper IN tbdsct_lancamento_bordero.cdcooper%TYPE,
                          pr_cdhistor IN tbdsct_lancamento_bordero.cdhistor%TYPE,
                          pr_nrtitulo IN tbdsct_lancamento_bordero.nrtitulo%TYPE,
                          pr_nrborder IN tbdsct_lancamento_bordero.nrborder%TYPE) IS
        SELECT tlb.cdcooper,
               SUM(vllanmto) vllanmto
          FROM tbdsct_lancamento_bordero tlb
         WHERE tlb.cdcooper = pr_cdcooper
           AND tlb.nrborder = pr_nrborder
           AND tlb.cdhistor in (pr_cdhistor)
           AND tlb.dtestorn IS NULL
           AND tlb.nrtitulo = pr_nrtitulo
         GROUP BY tlb.cdcooper;
      rw_tbdsct_lancamento_bordero cr_tbdsct_lancamento_bordero%ROWTYPE;
      -- Seleciona os titulos abertos em um bordero em prejuizo
      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        IF (btch0001.cr_crapdat%NOTFOUND) THEN
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
          RAISE vr_exc_erro;
        END IF;
        CLOSE btch0001.cr_crapdat;

        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;
        IF (cr_crapbdt%NOTFOUND) THEN
          CLOSE cr_crapbdt;
          vr_cdcritic := 1166; -- bordero nao encontrado
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapbdt;

        IF (rw_crapbdt.inprejuz <> 1) THEN
          vr_dscritic := 'Borderô não está em prejuízo';
          RAISE vr_exc_erro;
        END IF;

        IF (rw_crapbdt.dtliqprj IS NOT NULL) THEN
          vr_dscritic := 'Prejuízo já liquidado';
          RAISE vr_exc_erro;
        END IF;

        IF (rw_crapbdt.insitbdt <> 3) THEN
          vr_cdcritic := 1175; -- bordero diferente de liberado
          RAISE vr_exc_erro;
        END IF;

        -- Verifica saldo
        PREJ0005.pc_calcula_saldo_prejuizo(pr_cdcooper => pr_cdcooper
                                ,pr_nrborder => pr_nrborder
                                ,pr_vlaboorj => pr_vlaboorj
                                ,pr_vlpagmto => pr_vlpagmto
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdorigem => pr_cdorigem
                                -- OUT --
                                ,pr_possui_saldo => vr_possui_saldo
                                ,pr_mensagem_ret => vr_mensagem_ret
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                );
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF (vr_possui_saldo = 0) THEN
          vr_dscritic := 'Saldo e alçada insuficientes.';
          RAISE vr_exc_erro;
        END IF;

        -- Valor total que esta sendo pago do prejuizo do bordero
        vr_total :=  pr_vlpagmto + nvl(pr_vlaboorj,0);

        OPEN cr_craptdb;
        FETCH cr_craptdb BULK COLLECT INTO vr_tab_craptdb;
        CLOSE cr_craptdb;

        vr_total_titulos := vr_tab_craptdb.count;

        IF (vr_total_titulos = 0) THEN
          vr_dscritic := 'Nenhum título encontrado para esse borderô';
          RAISE vr_exc_erro;
        END IF;

        -- Paga IOF
        vr_index := vr_tab_craptdb.first;
        WHILE vr_index IS NOT NULL AND vr_total > 0 LOOP
          -- Verifica se possui saldo devedor de IOF
          IF (vr_tab_craptdb(vr_index).vlsldiof > 0) THEN
            -- Comeca o pagamento do iof
            IF (vr_tab_craptdb(vr_index).vlsldiof > vr_total) THEN -- pagamento parcial
              vr_pagamento_atual := vr_total;
            ELSE -- pagamento total
              vr_pagamento_atual := vr_tab_craptdb(vr_index).vlsldiof;
            END IF;
            vr_tab_craptdb(vr_index).vliofppr := vr_tab_craptdb(vr_index).vliofppr + vr_pagamento_atual;
            vr_total := vr_total - vr_pagamento_atual;
            vr_total_pago := vr_total_pago + vr_pagamento_atual;
            vr_tab_craptdb(vr_index).atualizou := 1;

            vr_pagamento_iof := vr_pagamento_iof + vr_pagamento_atual;

            -- Condicao para verificar se houve critica
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

          END IF;
          vr_index := vr_tab_craptdb.next(vr_index);
        END LOOP;

        -- Paga MULTA
        IF (vr_total > 0) THEN
          vr_index := vr_tab_craptdb.first;
          WHILE vr_index IS NOT NULL AND vr_total > 0 LOOP
            -- Verifica se possui saldo devedor de MULTA
            IF (vr_tab_craptdb(vr_index).vlsldmulta > 0) THEN
              -- Comeca o pagamento do iof
              IF (vr_tab_craptdb(vr_index).vlsldmulta > vr_total) THEN -- pagamento parcial
                vr_pagamento_atual := vr_total;
              ELSE -- pagamento total
                vr_pagamento_atual := vr_tab_craptdb(vr_index).vlsldmulta;
              END IF;
              vr_tab_craptdb(vr_index).vlpgmupr := vr_tab_craptdb(vr_index).vlpgmupr + vr_pagamento_atual;
              vr_total := vr_total - vr_pagamento_atual;
              vr_total_pago := vr_total_pago + vr_pagamento_atual;
              vr_tab_craptdb(vr_index).atualizou := 1;

              -- Lançar valor de pagamento da multa nos lançamentos do borderô
              DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                           ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                           ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                           ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                           ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                           ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                           ,pr_cdorigem => 5
                                           ,pr_cdhistor => vr_cdhistordsct_rec_mult_atras
                                           ,pr_vllanmto => vr_pagamento_atual
                                           ,pr_dscritic => vr_dscritic );
              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;

            END IF;
            vr_index := vr_tab_craptdb.next(vr_index);
          END LOOP;
        END IF;

        -- Paga MORA 60
        IF (vr_total > 0) THEN
          vr_total_60 := vr_total;
          vr_index := vr_tab_craptdb.first;
          WHILE vr_index IS NOT NULL AND vr_total_60 > 0 LOOP
            vr_tab_craptdb(vr_index).vlpago60atual := 0;
            -- Verifica se possui saldo devedor de MORA
            IF (vr_tab_craptdb(vr_index).vlsldmora > 0) THEN
              --Faz o pagamento do juros 60 (apenas no campo) para fazer a diferenciacao contabil em prejuizo
              --vljura60
              IF (vr_tab_craptdb(vr_index).vljura60_restante > vr_total_60) THEN
                vr_tab_craptdb(vr_index).vlpago60atual := vr_total_60;
              ELSE
                vr_tab_craptdb(vr_index).vlpago60atual := vr_tab_craptdb(vr_index).vljura60_restante;
              END IF;
              vr_total_60 := vr_total_60 - vr_tab_craptdb(vr_index).vlpago60atual;
              vr_tab_craptdb(vr_index).vlpgjm60 := vr_tab_craptdb(vr_index).vlpgjm60 + vr_tab_craptdb(vr_index).vlpago60atual;
              vr_total_pago := vr_total_pago + vr_tab_craptdb(vr_index).vlpgjm60;
            END IF;

            -- Lançar valor de pagamento da mora nos lançamentos do borderô
            DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                         ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                         ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                         ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                         ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                         ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                         ,pr_cdorigem => 5
                                         ,pr_cdhistor => vr_cdhistordsct_rec_jur_mora
                                         ,pr_vllanmto => vr_tab_craptdb(vr_index).vlpago60atual
                                         ,pr_dscritic => vr_dscritic );
            -- Condicao para verificar se houve critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            vr_index := vr_tab_craptdb.next(vr_index);
          END LOOP;
        END IF;

        -- Paga MORA
        IF (vr_total > 0) THEN
          vr_index := vr_tab_craptdb.first;
          WHILE vr_index IS NOT NULL AND vr_total > 0 LOOP
            vr_tab_craptdb(vr_index).vlpago60atual := nvl(vr_tab_craptdb(vr_index).vlpago60atual,0);
            -- Verifica se possui saldo devedor de MORA
            IF (vr_tab_craptdb(vr_index).vlsldmora > 0) THEN
              vr_total := vr_total - vr_tab_craptdb(vr_index).vlpago60atual;
              vr_tab_craptdb(vr_index).vlsldmora := vr_tab_craptdb(vr_index).vlsldmora - vr_tab_craptdb(vr_index).vlpago60atual;
              -- Comeca o pagamento da mora
              IF (vr_tab_craptdb(vr_index).vlsldmora > vr_total) THEN -- pagamento parcial
                vr_pagamento_atual := vr_total;
              ELSE -- pagamento total
                vr_pagamento_atual := vr_tab_craptdb(vr_index).vlsldmora;
              END IF;
              vr_tab_craptdb(vr_index).vlpgjmpr := vr_tab_craptdb(vr_index).vlpgjmpr + vr_pagamento_atual + vr_tab_craptdb(vr_index).vlpago60atual;
              vr_total := vr_total - vr_pagamento_atual;
              vr_total_pago := vr_total_pago + vr_pagamento_atual;
              vr_tab_craptdb(vr_index).atualizou := 1;

              -- Lançar valor de pagamento de juros 59
              DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                           ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                           ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                           ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                           ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                           ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                           ,pr_cdorigem => 5
                                           ,pr_cdhistor => vr_cdhistordsct_rec_principal
                                           ,pr_vllanmto => vr_pagamento_atual
                                           ,pr_dscritic => vr_dscritic );
            END IF;
            vr_index := vr_tab_craptdb.next(vr_index);
          END LOOP;
        END IF;

        -- Paga SALDO
        IF (vr_total > 0) THEN
          vr_index := vr_tab_craptdb.first;
          WHILE vr_index IS NOT NULL AND vr_total > 0 LOOP
            -- Verifica se possui saldo devedor de SALDO PREJUIZO
            IF (vr_tab_craptdb(vr_index).vlsdprej > 0) THEN
              -- verifica se teve juros 60 de apropriação
              OPEN cr_tdb60(pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                            ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo);
              FETCH cr_tdb60 INTO rw_craptdb60;
              -- Se existiu o juros 60 de apropriação então faz primeiro o pagamento dele antes do pagamento do saldo
              IF (cr_tdb60%FOUND) THEN
                -- Pega o valor que já foi pago de juros 60+ para esse titulo
                OPEN cr_tbdsct_lancamento_bordero(pr_cdcooper => pr_cdcooper,
                                                  pr_cdhistor => vr_cdhistordsct_rec_jur_60,
                                                  pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo,
                                                  pr_nrborder => vr_tab_craptdb(vr_index).nrborder);
                FETCH cr_tbdsct_lancamento_bordero INTO rw_tbdsct_lancamento_bordero; -- tudo o que foi pago de juros 60 desse titulo
                CLOSE cr_tbdsct_lancamento_bordero;
                vr_saldo_60 := rw_craptdb60.vljurrec - nvl(rw_tbdsct_lancamento_bordero.vllanmto,0);
                IF (vr_saldo_60 > 0) THEN
                  IF (vr_saldo_60 > vr_total) THEN -- pagamento parcial
                    vr_pagamento_atual := vr_total;
                  ELSE -- pagamento total
                    vr_pagamento_atual := vr_saldo_60;
                  END IF;
                  vr_tab_craptdb(vr_index).vlsdprej := vr_tab_craptdb(vr_index).vlsdprej - vr_pagamento_atual;
                  vr_total := vr_total - vr_pagamento_atual;
                  vr_total_pago := vr_total_pago + vr_pagamento_atual;
                  vr_tab_craptdb(vr_index).atualizou := 1;

                  -- Lançar valor de pagamento da saldo nos lançamentos do borderô
                  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                               ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                               ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                               ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                               ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                               ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                               ,pr_cdorigem => 5
                                               ,pr_cdhistor => vr_cdhistordsct_rec_jur_60
                                               ,pr_vllanmto => vr_pagamento_atual
                                               ,pr_dscritic => vr_dscritic );
                  -- Condicao para verificar se houve critica
                  IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_erro;
                  END IF;
                END IF;
              END IF;
              CLOSE cr_tdb60;
              IF (vr_tab_craptdb(vr_index).vlsdprej > 0) AND vr_total > 0 THEN
                -- Comeca o pagamento do iof
                IF (vr_tab_craptdb(vr_index).vlsdprej > vr_total) THEN -- pagamento parcial
                  vr_pagamento_atual := vr_total;
                ELSE -- pagamento total
                  vr_pagamento_atual := vr_tab_craptdb(vr_index).vlsdprej;
                END IF;
                vr_tab_craptdb(vr_index).vlsdprej := vr_tab_craptdb(vr_index).vlsdprej - vr_pagamento_atual;
                vr_total := vr_total - vr_pagamento_atual;
                vr_total_pago := vr_total_pago + vr_pagamento_atual;
                vr_tab_craptdb(vr_index).atualizou := 1;

                -- Lançar valor de pagamento da saldo nos lançamentos do borderô
                DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                             ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                             ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                             ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                             ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                             ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                             ,pr_cdorigem => 5
                                             ,pr_cdhistor => vr_cdhistordsct_rec_principal
                                             ,pr_vllanmto => vr_pagamento_atual
                                             ,pr_dscritic => vr_dscritic );
                -- Condicao para verificar se houve critica
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;
            vr_index := vr_tab_craptdb.next(vr_index);
          END LOOP;
        END IF;

        -- Paga Atualizacao
        IF (vr_total > 0) THEN
          vr_index := vr_tab_craptdb.first;
          WHILE vr_index IS NOT NULL AND vr_total > 0 LOOP
            -- Verifica se possui saldo devedor de ATUALIZACAO
            IF (vr_tab_craptdb(vr_index).vlsldatual > 0) THEN
              -- Comeca o pagamento do iof
              IF (vr_tab_craptdb(vr_index).vlsldatual > vr_total) THEN -- pagamento parcial
                vr_pagamento_atual := vr_total;
              ELSE -- pagamento total
                vr_pagamento_atual := vr_tab_craptdb(vr_index).vlsldatual;
              END IF;
              vr_tab_craptdb(vr_index).vlpgjrpr := vr_tab_craptdb(vr_index).vlpgjrpr + vr_pagamento_atual;
              vr_total := vr_total - vr_pagamento_atual;
              vr_total_pago := vr_total_pago + vr_pagamento_atual;
              vr_tab_craptdb(vr_index).atualizou := 1;

              -- Lançar valor de pagamento da mora nos lançamentos do borderô
              DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_craptdb(vr_index).nrdconta
                                           ,pr_nrborder => vr_tab_craptdb(vr_index).nrborder
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdbandoc => vr_tab_craptdb(vr_index).cdbandoc
                                           ,pr_nrdctabb => vr_tab_craptdb(vr_index).nrdctabb
                                           ,pr_nrcnvcob => vr_tab_craptdb(vr_index).nrcnvcob
                                           ,pr_nrdocmto => vr_tab_craptdb(vr_index).nrdocmto
                                           ,pr_nrtitulo => vr_tab_craptdb(vr_index).nrtitulo
                                           ,pr_cdorigem => 5
                                           ,pr_cdhistor => vr_cdhistordsct_rec_jur_atuali
                                           ,pr_vllanmto => vr_pagamento_atual
                                           ,pr_dscritic => vr_dscritic );
              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            vr_index := vr_tab_craptdb.next(vr_index);
          END LOOP;
        END IF;

        -- Efetua o lançamento da Mensal dos juros de atualização
        DSCT0003.pc_lanc_jratu_mensal(pr_cdcooper => pr_cdcooper
                                     ,pr_nrborder => pr_nrborder
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza os títulos
        vr_index := vr_tab_craptdb.first;
        WHILE vr_index IS NOT NULL LOOP
          -- Verifica se houve modificacao no registro
          IF (vr_tab_craptdb(vr_index).atualizou = 1) THEN
            IF (vr_tab_craptdb(vr_index).vlsdprej=0
                AND (vr_tab_craptdb(vr_index).vliofprj = vr_tab_craptdb(vr_index).vliofppr)
                AND (vr_tab_craptdb(vr_index).vlttjmpr = vr_tab_craptdb(vr_index).vlpgjmpr)
                AND (vr_tab_craptdb(vr_index).vlttmupr = vr_tab_craptdb(vr_index).vlpgmupr)
                AND (vr_tab_craptdb(vr_index).vljraprj = vr_tab_craptdb(vr_index).vlpgjrpr)
                ) THEN
              vr_tab_craptdb(vr_index).insittit := 3;
              vr_tab_craptdb(vr_index).dtdebito := rw_crapdat.dtmvtolt;
              vr_tab_craptdb(vr_index).dtdpagto := rw_crapdat.dtmvtolt;
            END IF;

            UPDATE craptdb tdb
            SET
              tdb.vlsdprej = vr_tab_craptdb(vr_index).vlsdprej
              ,tdb.vliofppr = vr_tab_craptdb(vr_index).vliofppr
              ,tdb.vlpgjmpr = vr_tab_craptdb(vr_index).vlpgjmpr
              ,tdb.vlpgmupr = vr_tab_craptdb(vr_index).vlpgmupr
              ,tdb.vlpgjrpr = vr_tab_craptdb(vr_index).vlpgjrpr
              ,tdb.dtdebito = vr_tab_craptdb(vr_index).dtdebito
              ,tdb.dtdpagto = vr_tab_craptdb(vr_index).dtdpagto
              ,tdb.insittit = vr_tab_craptdb(vr_index).insittit
              ,tdb.vlpgjm60 = vr_tab_craptdb(vr_index).vlpgjm60
            WHERE
              ROWID = vr_tab_craptdb(vr_index).id;
          END IF;
          vr_index := vr_tab_craptdb.next(vr_index);
        END LOOP;

        -- Se houve abono, então efetua o lançamento do crédito
        IF pr_vlaboorj>0 THEN
          UPDATE crapbdt bdt
            SET bdt.vlaboprj = pr_vlaboorj
          WHERE
            ROWID = rw_crapbdt.id
          ;
          -- Lançar valor de pagamento da mora nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapbdt.nrdconta
                                       ,pr_nrborder => pr_nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => vr_cdhistordsct_rec_abono
                                       ,pr_vllanmto => pr_vlaboorj
                                       ,pr_dscritic => vr_dscritic );
          -- Condicao para verificar se houve critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Não lançar como valor de recuperação o total informado como abono no pagamento
        vr_total_pago_recup := (vr_total_pago - nvl(pr_vlaboorj,0)) - vr_pagamento_iof;

        IF vr_total_pago_recup > 0 THEN
          -- Após todos os pagamentos faz um lançamento na conta do cooperado de recuperação de prejuízo
          DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdconta => rw_crapbdt.nrdconta
                           ,pr_vllanmto => vr_total_pago_recup
                           ,pr_cdhistor => vr_cdhistordsct_recup_preju
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdpactra => 0
                           ,pr_nrdocmto => pr_nrborder
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Faz lançamento do valor pago nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapbdt.nrdconta
                                            ,pr_nrborder => pr_nrborder
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdorigem => 5
                                            ,pr_cdhistor => vr_cdhistordsct_rec_preju
                                            -- apenas lancamento do que foi realmente pago, tirando o abono
                                            ,pr_vllanmto => vr_total_pago_recup
                                            ,pr_dscritic => vr_dscritic );

          -- Condicao para verificar se houve critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        IF (vr_pagamento_iof > 0) THEN

          -- Realiza o débito do IOF complementar na conta corrente do cooperado
          DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdconta => rw_crapbdt.nrdconta
                           ,pr_vllanmto => vr_pagamento_iof
                           ,pr_cdhistor => vr_cdhistordsct_recup_iof
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdpactra => 0
                           ,pr_nrdocmto => pr_nrborder
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                ,pr_nrdconta     => rw_crapbdt.nrdconta
                                ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                ,pr_tpproduto    => 2   --> Desconto de Titulo
                                ,pr_nrcontrato   => pr_nrborder
                                ,pr_vliofcpl     => vr_pagamento_iof
                                ,pr_flgimune     => 0
                                ,pr_cdcritic     => vr_cdcritic
                                ,pr_dscritic     => vr_dscritic);
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;

        -- Atualiza a data de pagamento do borderô
        UPDATE crapbdt bdt SET dtultpag = rw_crapdat.dtmvtolt WHERE bdt.cdcooper = pr_cdcooper AND bdt.nrborder = pr_nrborder;

        pc_liquidar_bordero_prejuizo(pr_cdcooper => pr_cdcooper
                                     ,pr_nrborder => pr_nrborder
                                     ,pr_liquidou => pr_liquidou
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

      EXCEPTION
        WHEN vr_exc_erro THEN
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina PREJ0005.pc_pagar_prejuizo: ' || SQLERRM;
    END pc_pagar_bordero_prejuizo;

    PROCEDURE pc_liquidar_bordero_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                          ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                          -- OUT --
                                          ,pr_liquidou OUT INTEGER
                                          ,pr_cdcritic OUT PLS_INTEGER
                                          ,pr_dscritic OUT VARCHAR2
                                          ) IS
      /*---------------------------------------------------------------------------------------------------------------------
          Programa : pc_liquidar_bordero_prejuizo
          Sistema  :
          Sigla    : CRED
          Autor    : Luis Fernando (GFT)
          Data     : 14/09/2018
          Frequencia: Sempre que for chamado
          Objetivo  : Liquidar borderos que estavam previamente em prejuizo
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- CURSORES
      CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.insitbdt,
        bdt.dtliqprj
      FROM crapbdt bdt
      WHERE
        bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = pr_nrborder
      ;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      CURSOR cr_craptdb IS
      SELECT
        1
      FROM craptdb tdb
      WHERE
        tdb.cdcooper = pr_cdcooper
        AND tdb.nrborder = pr_nrborder
        AND tdb.insittit = 4
      ;
      rw_craptdb cr_craptdb%ROWTYPE;

      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        IF (btch0001.cr_crapdat%NOTFOUND) THEN
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
          RAISE vr_exc_erro;
        END IF;
        CLOSE btch0001.cr_crapdat;

        pr_liquidou := 0;

        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;
        IF cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_cdcritic := 1166; -- bordero nao encontrado
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapbdt;

        IF (rw_crapbdt.dtliqprj IS NOT NULL) THEN
          vr_dscritic := 'Prejuízo do borderô já liquidado';
          RAISE vr_exc_erro;
        END IF;

        -- Verifica se possui titulos abertos
        OPEN cr_craptdb;
        FETCH cr_craptdb INTO rw_craptdb;
        -- Nao possui nenhum titulo aberto entao liquida o bordero em prejuizo
        IF cr_craptdb%NOTFOUND THEN
          UPDATE
            crapbdt bdt
          SET
            bdt.dtliqprj = rw_crapdat.dtmvtolt
            ,bdt.insitbdt = 4
          WHERE
            bdt.rowid = rw_crapbdt.id;

          pr_liquidou := 1;
        END IF;
        CLOSE cr_craptdb;

        EXCEPTION
          WHEN vr_exc_erro THEN
            IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
            END IF;
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro geral na rotina PREJ0005.pc_liquidar_bordero_prejuizo: ' || SQLERRM;
    END pc_liquidar_bordero_prejuizo;

    PROCEDURE pc_calcula_atraso_prejuizo(pr_cdcooper  IN craptdb.cdcooper%TYPE
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                      ,pr_nrborder IN craptdb.nrborder%TYPE
                                      ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                                      ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                                      ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                                      ,pr_nrdocmto IN craptdb.nrdocmto%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      -- OUT --
                                      ,pr_vljraprj OUT NUMBER
                                      ,pr_vljrmprj OUT NUMBER
                                      ,pr_cdcritic OUT PLS_INTEGER
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
      /*---------------------------------------------------------------------------------------------------------------------
            Programa : pc_calcula_atraso_prejuizo
            Sistema  :
            Sigla    : CRED
            Autor    : Luis Fernando (GFT)
            Data     : 18/09/2018
            Frequencia: Sempre que for chamado
            Objetivo  : Calcular os valores diarios dos juros de atualizacao de borderos em prejuizo
      ---------------------------------------------------------------------------------------------------------------------*/
        -- Tratamento de erro
        vr_exc_erro EXCEPTION;

        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
        vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

        -- Variável de Data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;


        -- CURSORES
        CURSOR cr_craptdb IS
          SELECT
            tdb.vlprejuz, -- valor original do prejuizo
            tdb.vlsdprej, -- saldo do prejuizo
            bdt.dtprejuz, -- data de envio para prejuizo
            bdt.txmensal,  -- taxa para calculo de atualizacao
            tdb.vljrmprj,

            tdb.vlttjmpr,
            tdb.vlpgjmpr,
            tdb.vljura60,
            tdb.vlpgjm60,
            (tdb.vlttjmpr-tdb.vlpgjmpr)-(tdb.vljura60-tdb.vlpgjm60) AS vlsljm59

          FROM
            craptdb tdb
            INNER JOIN crapbdt bdt ON bdt.nrborder = tdb.nrborder AND bdt.cdcooper = tdb.cdcooper
          WHERE
            tdb.cdcooper = pr_cdcooper
            AND tdb.nrdconta = pr_nrdconta
            AND tdb.nrborder = pr_nrborder
            AND tdb.cdbandoc = pr_cdbandoc
            AND tdb.nrdctabb = pr_nrdctabb
            AND tdb.nrcnvcob = pr_nrcnvcob
            AND tdb.nrdocmto = pr_nrdocmto
        ;
        rw_craptdb cr_craptdb%ROWTYPE;

        CURSOR cr_tbdsct_lancamento_bordero IS
          SELECT dtmvtolt,vllanmto
            FROM tbdsct_lancamento_bordero
           WHERE tbdsct_lancamento_bordero.cdcooper = pr_cdcooper
             AND tbdsct_lancamento_bordero.nrdconta = pr_nrdconta
             AND tbdsct_lancamento_bordero.nrborder = pr_nrborder
             AND tbdsct_lancamento_bordero.cdbandoc = pr_cdbandoc
             AND tbdsct_lancamento_bordero.nrdctabb = pr_nrdctabb
             AND tbdsct_lancamento_bordero.nrcnvcob = pr_nrcnvcob
             AND tbdsct_lancamento_bordero.nrdocmto = pr_nrdocmto
             AND tbdsct_lancamento_bordero.cdhistor IN (vr_cdhistordsct_rec_principal)
             AND tbdsct_lancamento_bordero.dtestorn IS NULL
           ORDER BY dtmvtolt ASC
        ;
        rw_tbdsct_lancamento_bordero cr_tbdsct_lancamento_bordero%ROWTYPE;

        vr_vlsldtit   NUMBER; -- saldo do prejuiso
        vr_txdiaria   NUMBER; -- Taxa diária de juros de mora
        vr_dtmvtolt   DATE;
        vr_firstday   DATE;
        vr_diasmes    INTEGER;
        vr_valormoraprj  NUMBER;
        vr_valorsaldoprj NUMBER;


        BEGIN
          -- Leitura do calendário da cooperativa
          OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
            FETCH btch0001.cr_crapdat into rw_crapdat;
            IF (btch0001.cr_crapdat%NOTFOUND) THEN
              CLOSE btch0001.cr_crapdat;
              vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
              RAISE vr_exc_erro;
            END IF;
          CLOSE btch0001.cr_crapdat;

          -- Valida a existência do título
          OPEN cr_craptdb;
          FETCH cr_craptdb INTO rw_craptdb;

          IF cr_craptdb%NOTFOUND THEN
            CLOSE cr_craptdb;
            vr_cdcritic := 1108;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_craptdb;

          -- Calculo da taxa de mora diaria
          vr_txdiaria :=  (rw_craptdb.txmensal/30) / 100;

          vr_vlsldtit := rw_craptdb.vlsdprej;

          vr_valormoraprj  := 0;
          vr_firstday := ADD_MONTHS((LAST_DAY(pr_dtmvtolt)+1),-1);
          IF (vr_firstday < rw_craptdb.dtprejuz) THEN
            vr_firstday := rw_craptdb.dtprejuz;
          END IF;
          rw_craptdb.vljrmprj := 0;
          IF (vr_vlsldtit > 0) THEN
            -- Verifica se houve algum pagamento parcial do saldo
            vr_dtmvtolt   := rw_craptdb.dtprejuz;
            vr_valorsaldoprj := rw_craptdb.vlprejuz-rw_craptdb.vlsljm59;
            IF vr_valorsaldoprj <> (rw_craptdb.vlsdprej) THEN -- houve algum pagamento do saldo
              FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero LOOP
                IF (vr_dtmvtolt <= rw_tbdsct_lancamento_bordero.dtmvtolt) THEN
                  vr_valormoraprj  := vr_valormoraprj + NVL(ROUND(vr_valorsaldoprj * (rw_tbdsct_lancamento_bordero.dtmvtolt - vr_dtmvtolt) * vr_txdiaria,2),0);
                  -- pagamento no mes corrente
                  IF (to_char(vr_firstday,'mmrrrr') = to_char(vr_dtmvtolt,'mmrrrr')) THEN
                    rw_craptdb.vljrmprj := rw_craptdb.vljrmprj + NVL(ROUND(vr_valorsaldoprj * (rw_tbdsct_lancamento_bordero.dtmvtolt - vr_firstday) * vr_txdiaria,2),0);
                    vr_firstday := rw_tbdsct_lancamento_bordero.dtmvtolt;
                  END IF;
                  vr_dtmvtolt      := rw_tbdsct_lancamento_bordero.dtmvtolt;
                  vr_valorsaldoprj := vr_valorsaldoprj - rw_tbdsct_lancamento_bordero.vllanmto;
                END IF;
              END LOOP;
            END IF;

            /*IF (vr_vlsldtit <> vr_valorsaldoprj) THEN
              vr_dscritic := 'Ocorreu um erro ao calcular o saldo do titulo';
              RAISE vr_exc_erro;
            END IF;*/
            vr_valormoraprj  := vr_valormoraprj + NVL(ROUND(vr_vlsldtit * (pr_dtmvtolt - vr_dtmvtolt) * vr_txdiaria,2),0);
            rw_craptdb.vljrmprj  := rw_craptdb.vljrmprj + NVL(ROUND(vr_vlsldtit * (pr_dtmvtolt - vr_firstday) * vr_txdiaria,2),0);
          END IF;

          pr_vljraprj := vr_valormoraprj;
          pr_vljrmprj := rw_craptdb.vljrmprj;
          EXCEPTION
            WHEN vr_exc_erro THEN
              IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
              END IF;
            WHEN OTHERS THEN
              pr_cdcritic := 0;
              pr_dscritic := 'Erro geral na rotina PREJ0005.pc_calcula_atraso_prejuizo: ' || SQLERRM;

    END pc_calcula_atraso_prejuizo;

    PROCEDURE pc_pagar_titulo_prejuizo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                              ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                              ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                              ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                              ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                              ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                              ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                              ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                              ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                              ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                              ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                              ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                              ,pr_vlaboorj    IN NUMBER DEFAULT 0                --Valor do abono
                              ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                              ,pr_dscritic    OUT VARCHAR2) IS                   --Descricao Critica

    /* ................................................................................
       Programa: pc_pagar_titulo_prejuizo
       Sistema : Crédito
       Sigla   : CRED

       Autor   : Luis Fernando (GFT)
       Data    : 21/09/18

       Dados referentes ao programa:
       Frequencia: Sempre que for chamado
       Objetivo  :  Realiza o pagamento de um título em prejuízo através da conta corrente

                 pr_cdorigpg: Código da origem do processo de pagamento
                              0 - Conta-Corrente (Raspada, ...)
                              1 - Pagamento (Baixa de cobrança de títulos, ...)
                              2 - Pagamento COBTIT
                              3 - Tela PAGAR
                              4 - Sistema de Acordos

                 pr_indpagto: Indica de onde vem o pagamento
                              0 - COMPE
                              1 - Caixa On-Line
                              2 - ?????
                              3 - Internet
                              4 - TAA

       Alterações:
        - 19/10/2018 - Inserção do ABONO. (Vitor S Assanuma - GFT)
    ..................................................................................*/


      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Verificar saldo
      vr_possui_saldo INTEGER;
      vr_mensagem_ret VARCHAR(100);

      -- Auxiliares para calculo
      vr_total            NUMBER := 0;
      vr_total_pago       NUMBER := 0;
      vr_pagamento_atual  NUMBER := 0;
      vr_pagamento_iof    NUMBER := 0;
      vr_vlpagm60         NUMBER := 0; -- Valor pago do juros 60
      vr_total_pago_recup NUMBER := 0;

      vr_index PLS_INTEGER;
      vr_total_titulos INTEGER;
      vr_liquidou INTEGER;

      -- CURSORES
      CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.nrdconta,
        bdt.nrborder,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtliqprj,
        bdt.insitbdt
      FROM
        crapbdt bdt
      WHERE
        bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      CURSOR cr_craptdb IS
      SELECT
        tdb.rowid AS id
        ,tdb.insittit
        ,tdb.vlprejuz
        ,tdb.vliofprj
        ,tdb.vliofppr
        ,tdb.vlttjmpr
        ,tdb.vlpgjmpr
        ,tdb.vlttmupr
        ,tdb.vlpgmupr
        ,tdb.vljraprj
        ,tdb.vlpgjrpr
        ,tdb.vlsdprej   -- Valor devido do titulo
        ,(tdb.vliofprj - tdb.vliofppr) AS vlsldiof     -- Saldo iof
        ,(tdb.vlttjmpr - tdb.vlpgjmpr) AS vlsldmora    -- Saldo juros mora
        ,(tdb.vlttmupr - tdb.vlpgmupr) AS vlsldmulta   -- Saldo multa
        ,(tdb.vljraprj - tdb.vlpgjrpr) AS vlsldatual   -- Saldo Atualizacao,
        ,(tdb.vljura60 - tdb.vlpgjm60) AS vljura60_restante
        ,tdb.dtvencto
        ,0 AS atualizou
        ,tdb.dtdebito
        ,tdb.dtdpagto
        ,tdb.cdbandoc
        ,tdb.nrdctabb
        ,tdb.nrcnvcob
        ,tdb.nrdocmto
        ,tdb.nrtitulo
        ,tdb.nrdconta
        ,tdb.nrborder
        ,tdb.vlpgjm60
      FROM craptdb tdb
      WHERE tdb.cdcooper = pr_cdcooper
        AND tdb.nrborder = pr_nrborder
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.nrdocmto = pr_nrdocmto
        AND tdb.nrcnvcob = pr_nrcnvcob
        AND tdb.cdbandoc = pr_cdbandoc
        AND tdb.nrdctabb = pr_nrdctabb
        AND tdb.insittit = 4
        -- E está em acordo
        AND (tdb.nrborder, tdb.nrtitulo) IN (
          SELECT ttc.nrborder, ttc.nrtitulo
          FROM tbdsct_titulo_cyber ttc
            INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp
            INNER JOIN tbrecup_acordo ta           ON tac.nracordo = ta.nracordo
               -- FALTAVAM ESTES CAMPOS NA CLAUSULA
              AND ta.cdcooper = ttc.cdcooper
              AND ta.nrdconta = ttc.nrdconta
          WHERE tac.cdorigem   = 4 -- Desconto de Títulos
            AND ta.cdsituacao <> 3 -- Acordo não está cancelado
            AND tdb.cdcooper = ttc.cdcooper
            AND tdb.nrdconta = ttc.nrdconta
            AND tdb.nrborder = ttc.nrborder
            AND tdb.nrtitulo = ttc.nrtitulo
       )
      ORDER BY dtvencto ASC, vlsdprej DESC
      ;
      rw_craptdb cr_craptdb%ROWTYPE;

      -- Seleciona os titulos abertos em um bordero em prejuizo
      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        IF (btch0001.cr_crapdat%NOTFOUND) THEN
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
          RAISE vr_exc_erro;
        END IF;
        CLOSE btch0001.cr_crapdat;

        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;
        IF (cr_crapbdt%NOTFOUND) THEN
          CLOSE cr_crapbdt;
          vr_cdcritic := 1166; -- bordero nao encontrado
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapbdt;

        IF (rw_crapbdt.inprejuz<>1) THEN
          vr_dscritic := 'Borderô não está em prejuízo';
          RAISE vr_exc_erro;
        END IF;

        IF (rw_crapbdt.dtliqprj IS NOT NULL) THEN
          vr_dscritic := 'Prejuízo já liquidado';
          RAISE vr_exc_erro;
        END IF;

        IF (rw_crapbdt.insitbdt<>3) THEN
          vr_cdcritic := 1175; -- bordero diferente de liberado
          RAISE vr_exc_erro;
        END IF;

        -- Valor total que esta sendo pago do prejuizo do bordero
        vr_total :=  NVL(pr_vlpagmto, 0) + pr_vlaboorj;

        OPEN cr_craptdb;
        FETCH cr_craptdb INTO rw_craptdb;
        IF (cr_craptdb%NOTFOUND) THEN
           CLOSE cr_craptdb;
          vr_dscritic := 'Título não encontrado no acordo';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_craptdb;

        -- Paga IOF
        -- Verifica se possui saldo devedor de IOF
        IF (rw_craptdb.vlsldiof > 0) THEN
          -- Comeca o pagamento do iof
          IF (rw_craptdb.vlsldiof > vr_total) THEN -- pagamento parcial
            vr_pagamento_atual := vr_total;
          ELSE -- pagamento total
            vr_pagamento_atual := rw_craptdb.vlsldiof;
          END IF;
          rw_craptdb.vliofppr := rw_craptdb.vliofppr + vr_pagamento_atual;
          vr_total := vr_total - vr_pagamento_atual;
          vr_total_pago := vr_total_pago + vr_pagamento_atual;
          vr_pagamento_iof := vr_pagamento_iof + vr_pagamento_atual;

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Paga MULTA
        IF (vr_total > 0) THEN
          -- Verifica se possui saldo devedor de MULTA
          IF (rw_craptdb.vlsldmulta > 0) THEN
            -- Comeca o pagamento do iof
            IF (rw_craptdb.vlsldmulta > vr_total) THEN -- pagamento parcial
              vr_pagamento_atual := vr_total;
            ELSE -- pagamento total
              vr_pagamento_atual := rw_craptdb.vlsldmulta;
            END IF;
            rw_craptdb.vlpgmupr := rw_craptdb.vlpgmupr + vr_pagamento_atual;
            vr_total := vr_total - vr_pagamento_atual;
            vr_total_pago := vr_total_pago + vr_pagamento_atual;

            -- Lançar valor de pagamento da multa nos lançamentos do borderô
            DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                         ,pr_nrtitulo => rw_craptdb.nrtitulo
                                         ,pr_cdorigem => 5
                                         ,pr_cdhistor => vr_cdhistordsct_rec_mult_atras
                                         ,pr_vllanmto => vr_pagamento_atual
                                         ,pr_dscritic => vr_dscritic );
            -- Condicao para verificar se houve critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        -- Paga MORA
        IF (vr_total > 0) THEN
          -- Verifica se possui saldo devedor de MORA
          IF (rw_craptdb.vlsldmora > 0) THEN
            --Faz o pagamento do juros 60 (apenas no campo) para fazer a diferenciacao contabil em prejuizo
            --vljura60
            IF (rw_craptdb.vljura60_restante > vr_total) THEN
              vr_vlpagm60 := vr_total;
            ELSE
              vr_vlpagm60 := rw_craptdb.vljura60_restante;
            END IF;
            vr_total := vr_total - vr_vlpagm60;
            rw_craptdb.vlpgjm60 := rw_craptdb.vlpgjm60 + vr_vlpagm60;
            rw_craptdb.vlsldmora := rw_craptdb.vlsldmora - vr_vlpagm60;
            IF (vr_vlpagm60 > 0) THEN
              -- Lançar valor de pagamento da mora 60 nos lançamentos do borderô
              DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                         ,pr_nrtitulo => rw_craptdb.nrtitulo
                                         ,pr_cdorigem => 5
                                         ,pr_cdhistor => vr_cdhistordsct_rec_jur_mora
                                         ,pr_vllanmto => vr_vlpagm60
                                         ,pr_dscritic => vr_dscritic );
              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Comeca o pagamento da mora
            IF (rw_craptdb.vlsldmora > vr_total) THEN -- pagamento parcial
              vr_pagamento_atual := vr_total;
            ELSE -- pagamento total
              vr_pagamento_atual := rw_craptdb.vlsldmora;
            END IF;
            rw_craptdb.vlpgjmpr := rw_craptdb.vlpgjmpr + vr_pagamento_atual + vr_vlpagm60;
            vr_total := vr_total - vr_pagamento_atual;
            vr_total_pago := vr_total_pago + vr_pagamento_atual + vr_vlpagm60;

            IF (vr_pagamento_atual > 0) THEN
              -- Lançar valor de pagamento da mora nos lançamentos do borderô
              DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_craptdb.nrdconta
                                           ,pr_nrborder => rw_craptdb.nrborder
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdbandoc => rw_craptdb.cdbandoc
                                           ,pr_nrdctabb => rw_craptdb.nrdctabb
                                           ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                           ,pr_nrdocmto => rw_craptdb.nrdocmto
                                           ,pr_nrtitulo => rw_craptdb.nrtitulo
                                           ,pr_cdorigem => 5
                                           ,pr_cdhistor => vr_cdhistordsct_rec_principal
                                           ,pr_vllanmto => vr_pagamento_atual
                                           ,pr_dscritic => vr_dscritic );
              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        END IF;

        -- Paga SALDO
        IF (vr_total > 0) THEN
          -- Verifica se possui saldo devedor de SALDO PREJUIZO
          IF (rw_craptdb.vlsdprej > 0) THEN
            -- Comeca o pagamento do iof
            IF (rw_craptdb.vlsdprej > vr_total) THEN -- pagamento parcial
              vr_pagamento_atual := vr_total;
            ELSE -- pagamento total
              vr_pagamento_atual := rw_craptdb.vlsdprej;
            END IF;
            rw_craptdb.vlsdprej := rw_craptdb.vlsdprej - vr_pagamento_atual;
            vr_total := vr_total - vr_pagamento_atual;
            vr_total_pago := vr_total_pago + vr_pagamento_atual;

            -- Lançar valor de pagamento da saldo nos lançamentos do borderô
            DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                         ,pr_nrtitulo => rw_craptdb.nrtitulo
                                         ,pr_cdorigem => 5
                                         ,pr_cdhistor => vr_cdhistordsct_rec_principal
                                         ,pr_vllanmto => vr_pagamento_atual
                                         ,pr_dscritic => vr_dscritic );
            -- Condicao para verificar se houve critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        -- Paga Atualizacao
        IF (vr_total > 0) THEN
          -- Verifica se possui saldo devedor de ATUALIZACAO
          IF (rw_craptdb.vlsldatual > 0) THEN
            -- Comeca o pagamento do iof
            IF (rw_craptdb.vlsldatual > vr_total) THEN -- pagamento parcial
              vr_pagamento_atual := vr_total;
            ELSE -- pagamento total
              vr_pagamento_atual := rw_craptdb.vlsldatual;
            END IF;
            rw_craptdb.vlpgjrpr := rw_craptdb.vlpgjrpr + vr_pagamento_atual;
            vr_total := vr_total - vr_pagamento_atual;
            vr_total_pago := vr_total_pago + vr_pagamento_atual;
            rw_craptdb.atualizou := 1;

            -- Lançar valor de pagamento da mora nos lançamentos do borderô
            DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                         ,pr_nrtitulo => rw_craptdb.nrtitulo
                                         ,pr_cdorigem => 5
                                         ,pr_cdhistor => vr_cdhistordsct_rec_jur_atuali
                                         ,pr_vllanmto => vr_pagamento_atual
                                         ,pr_dscritic => vr_dscritic );
            -- Condicao para verificar se houve critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        -- Atualiza o título
        -- Verifica se houve modificacao no registro
          IF (rw_craptdb.vlsdprej=0
              AND (rw_craptdb.vliofprj = rw_craptdb.vliofppr)
              AND (rw_craptdb.vlttjmpr = rw_craptdb.vlpgjmpr)
              AND (rw_craptdb.vlttmupr = rw_craptdb.vlpgmupr)
              AND (rw_craptdb.vljraprj = rw_craptdb.vlpgjrpr)
              ) THEN
            rw_craptdb.insittit := 3;
            rw_craptdb.dtdebito := rw_crapdat.dtmvtolt;
            rw_craptdb.dtdpagto := rw_crapdat.dtmvtolt;
          END IF;

          UPDATE craptdb tdb
          SET
            tdb.vlsdprej = rw_craptdb.vlsdprej
            ,tdb.vliofppr = rw_craptdb.vliofppr
            ,tdb.vlpgjmpr = rw_craptdb.vlpgjmpr
            ,tdb.vlpgmupr = rw_craptdb.vlpgmupr
            ,tdb.vlpgjrpr = rw_craptdb.vlpgjrpr
            ,tdb.dtdebito = rw_craptdb.dtdebito
            ,tdb.dtdpagto = rw_craptdb.dtdpagto
            ,tdb.insittit = rw_craptdb.insittit
            ,tdb.vlpgjm60 = rw_craptdb.vlpgjm60
          WHERE
            ROWID = rw_craptdb.id;
        
        -- Não lançar como valor de recuperação o total informado como abono no pagamento
        vr_total_pago_recup := (vr_total_pago - nvl(pr_vlaboorj,0)) - vr_pagamento_iof;

        IF vr_total_pago_recup > 0 THEN
          -- Após todos os pagamentos faz um lançamento na conta do cooperado de recuperação de prejuízo
          DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdconta => rw_crapbdt.nrdconta
                           ,pr_vllanmto => vr_total_pago_recup
                           ,pr_cdhistor => vr_cdhistordsct_recup_preju
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdpactra => 0
                           ,pr_nrdocmto => pr_nrborder
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Faz lançamento do valor pago nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => rw_crapbdt.nrdconta
                                                ,pr_nrborder => pr_nrborder
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_cdorigem => 5
                                                ,pr_cdhistor => vr_cdhistordsct_rec_preju
                                                -- apenas lancamento do que foi realmente pago, tirando o abono
                                                ,pr_vllanmto => vr_total_pago_recup
                                                ,pr_dscritic => vr_dscritic );

          -- Condicao para verificar se houve critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        IF (vr_pagamento_iof > 0) THEN

          -- Realiza o débito do IOF complementar na conta corrente do cooperado
          DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdconta => rw_crapbdt.nrdconta
                           ,pr_vllanmto => vr_pagamento_iof
                           ,pr_cdhistor => vr_cdhistordsct_recup_iof
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdpactra => 0
                           ,pr_nrdocmto => pr_nrborder
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                ,pr_nrdconta     => rw_crapbdt.nrdconta
                                ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                ,pr_tpproduto    => 2   --> Desconto de Titulo
                                ,pr_nrcontrato   => pr_nrborder
                                ,pr_vliofcpl     => vr_pagamento_iof
                                ,pr_flgimune     => 0
                                ,pr_cdcritic     => vr_cdcritic
                                ,pr_dscritic     => vr_dscritic);
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;

        -- Caso tenha abono
        IF pr_vlaboorj>0 THEN
          UPDATE crapbdt bdt
            SET bdt.vlaboprj = nvl(bdt.vlaboprj, 0) + pr_vlaboorj
          WHERE
            ROWID = rw_crapbdt.id
          ;
          -- Lançar valor de pagamento da mora nos lançamentos do borderô
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapbdt.nrdconta
                                       ,pr_nrborder => pr_nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => vr_cdhistordsct_rec_abono
                                       ,pr_vllanmto => pr_vlaboorj
                                       ,pr_dscritic => vr_dscritic );
          -- Condicao para verificar se houve critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Atualiza a data de pagamento do borderô
        UPDATE crapbdt bdt SET dtultpag = rw_crapdat.dtmvtolt WHERE bdt.cdcooper = pr_cdcooper AND bdt.nrborder = pr_nrborder;

        pc_liquidar_bordero_prejuizo(pr_cdcooper => pr_cdcooper
                                     ,pr_nrborder => pr_nrborder
                                     ,pr_liquidou => vr_liquidou
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

        pr_vlpagmto := vr_total;
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
        vr_cdcritic := NVL(vr_cdcritic, 0);
        IF vr_cdcritic > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;

      --END;
    END pc_pagar_titulo_prejuizo;

  PROCEDURE pc_calcula_saldo_prej_risco (pr_cdcooper     IN crapbdt.cdcooper%TYPE
                                        ,pr_nrborder     IN crapbdt.nrborder%TYPE
                                        -- OUT --
                                        ,pr_vlsldprj     OUT NUMBER
                                        ,pr_cdcritic     OUT PLS_INTEGER
                                        ,pr_dscritic     OUT VARCHAR2
                                        ) IS
  /*---------------------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_saldo_prej_risco

     Sistema  :
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT)
     Data     : 22/11/2018
     Frequencia: Sempre que for chamado
     Objetivo  : Calcula o saldo do prejuízo do borderô a ser enviado à central de risco
     Alterações:

   ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

    -- Busca o lançamento contábil de transferência para prejuízo
    /*CURSOR cr_vltransfprej IS
      SELECT vllanmto AS vltransfprej
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.nrborder = pr_nrborder
         AND lbd.cdhistor = 2754;
    rw_vltransfprej cr_vltransfprej%ROWTYPE;*/

    -- Busca o lançamento contábil de pagamento de juros+60 remuneratório
    /*CURSOR cr_vljura60remun IS
      SELECT SUM(vllanmto) AS vljura60remun
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.nrborder = pr_nrborder
         AND lbd.cdhistor = vr_cdhistordsct_rec_jur_60;
    rw_vljura60remun cr_vljura60remun%ROWTYPE;*/

    -- Busca o saldo do prejuízo original dos títulos
    CURSOR cr_craptdb IS
      SELECT SUM(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vljura60) - (tdb.vlpgjmpr - tdb.vlpgjm60)) AS vlprejtotal
        FROM craptdb tdb
  INNER JOIN crapbdt bdt ON bdt.cdcooper = tdb.cdcooper AND bdt.nrborder = tdb.nrborder
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrborder = pr_nrborder
         AND bdt.inprejuz = 1
         AND bdt.flverbor = 1
         AND tdb.insittit = 4;
    rw_craptdb cr_craptdb%ROWTYPE;

    vr_vljura60remun NUMBER :=0 ;
    BEGIN

      /*OPEN cr_vljura60remun;
      FETCH cr_vljura60remun INTO rw_vljura60remun;

      IF (cr_vljura60remun%NOTFOUND) THEN
        CLOSE cr_vljura60remun;
        vr_vljura60remun := 0;
      ELSE
        vr_vljura60remun := rw_vljura60remun.vljura60remun;
      END IF;

      CLOSE cr_vljura60remun;
      */
      OPEN cr_craptdb;
      FETCH cr_craptdb INTO rw_craptdb;
      CLOSE cr_craptdb;

      pr_vlsldprj := nvl(rw_craptdb.vlprejtotal,0) /*- nvl(vr_vljura60remun,0)*/;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina PREJ0005.pc_calcula_saldo_prej_risco: ' || SQLERRM;

   END pc_calcula_saldo_prej_risco;
END PREJ0005;
/
