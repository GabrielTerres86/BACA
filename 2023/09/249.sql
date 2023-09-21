DECLARE
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtrefere         DATE := to_date('01/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('31/08/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE gerarRelatoriosContabeisTbriscoRis(pr_cdcooper  IN cecred.craptab.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE  --> Primeiro dia util do mes
                                              ,pr_cdcritic OUT cecred.crapcri.cdcritic%TYPE  --> Código da Crítica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto do erro/crítica

    TYPE crapcdb_rec IS RECORD (vlcheque cecred.crapcdb.vlcheque%type,
                                vlliquid cecred.crapcdb.vlliquid%type,
                                nrdconta cecred.crapcdb.nrdconta%type,
                                nrborder cecred.crapcdb.nrborder%type,
                                cdagenci cecred.crapcdb.cdagenci%type,
                                nrcheque cecred.crapcdb.nrcheque%type,
                                inchqcop cecred.crapcdb.inchqcop%type);

    TYPE tab_crapcdb_rec IS TABLE OF crapcdb_rec INDEX BY BINARY_INTEGER;
    rw_crapcdb tab_crapcdb_rec;

    -- Buscar os dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper in cecred.craptab.cdcooper%type) is
      SELECT cdbcoctl,
             cdcrdarr,
             cdcrdins,
             dsdircop,
             nrctactl,
             nmrescop,
             vltardrf,
             vltarbcb
        FROM cecred.crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    rw_crapcop_2 cr_crapcop%ROWTYPE;

    -- Buscar os históricos com código de histórico na contabilidade maior que zero
    -- e das estruturas listadas abaixo
    cursor cr_craphis (pr_cdcooper in cecred.craphis.cdcooper%TYPE) is
      select upper(craphis.nmestrut) nmestrut,
             craphis.cdhistor cdhistor,
             craphis.tpctbcxa,
             craphis.tpctbccu,
             craphis.nrctacrd,
             craphis.nrctadeb
        from cecred.craphis
       where craphis.cdcooper = pr_cdcooper
         AND (craphis.nrctadeb <> craphis.nrctacrd OR craphis.nrctadeb = 0)
         and craphis.cdhstctb > 0
         and craphis.cdhistor NOT IN (1154, -- Hist.Sicredi
                                      3361, -- Hist.TIVIT
                                      1019, -- Hist. Debito Automatico Sicredi
                                      1414,
                                      2515, -- Hist. Arrecadação Convênios Bancoob
                                      /* P513 - Saque e Pague */
                                      2937, -- DEPOSITO - SAQUE E PAGUE (ate 21:45)
                                      2969, -- DEPOSITO - SAQUE E PAGUE (apos 21:45)
                                      2936, -- SAQUE - SAQUE E PAGUE (ate 21:45)
                                      2967, -- SAQUE - SAQUE E PAGUE (apos 21:45)
                                      2938, -- ESTORNO SAQUE - SAQUE E PAGUE (ate 21:45)
                                      2968, -- ESTORNO SAQUE - SAQUE E PAGUE (apos 21:45)
                                      2941, -- REPASSE DEPOSITOS - SAQUE E PAGUE
                                      2940, -- REPASSE ESTORNO SAQUE - SAQUE E PAGUE
                                      2939, -- REPASSE SAQUE - SAQUE E PAGUE
                                      3239, -- DEPOSITO VAREJISTA - SAQUE E PAGUE (ate 21:45)
                                      3241, -- DEPOSITO VAREJISTA - SAQUE E PAGUE (apos 21:45)
                                      3240, -- REPASSE DEPOSITOS VAREJISTA - SAQUE E PAGUE
                                      3292, -- Hist. Debito Automatico Bancoob
                                      3044, -- Para repasses de arrecadações de Outro Convênios
                                      3045, -- Para repasses de arrecadações de Convênios Concessionários de Serviço Público
                                      3046, -- Para repasses das arrecadações de DARE e GNRE.
                                      3049, -- Credito referente arrecadação de convênios Ailos.
                                      3852  -- Estorno de seguro prestamsita
                                      )
         and upper(craphis.nmestrut) in ('CRAPLCT',
                                         'CRAPLCM',
                                         'CRAPLEM',
                                         'CRAPLPP',
                                         'CRAPLAP',
                                         'CRAPLFT',
                                         'CRAPTVL',
                                         'CRAPLAC',
                                         'TBDSCT_LANCAMENTO_BORDERO',
                                         'TBCC_PREJUIZO_DETALHE')
      union all
      --Adicionados códigos de histórico do LCI
      SELECT UPPER(craphis.nmestrut) nmestrut
            ,craphis.cdhistor cdhistor
            ,craphis.tpctbcxa
            ,craphis.tpctbccu
            ,craphis.nrctacrd
            ,craphis.nrctadeb
        FROM cecred.craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND (craphis.nrctadeb <> craphis.nrctacrd OR craphis.nrctadeb = 0)
         AND craphis.cdhstctb > 0
         AND craphis.cdhistor IN (3843, --DB APLICACAO LCI POS
                                  3844, --RESGATE LCI POS PARA C.I
                                  3846, --ESTORNO DE APLICACAO LCI POS
                                  3847  --ESTORNO DE RESGATE LCI POS PARA C.I
                                  );
    rw_craphis    cr_craphis%rowtype;
    -- Buscar as tarifas do histórico
    CURSOR cr_crapthi (pr_cdcooper in cecred.crapthi.cdcooper%TYPE,
                       pr_cdhistor in cecred.craphis.cdhistor%TYPE,
                       pr_dsorigem in cecred.crapthi.dsorigem%TYPE) IS
      SELECT vltarifa
        FROM cecred.crapthi
       WHERE crapthi.cdcooper = pr_cdcooper
         AND crapthi.cdhistor = pr_cdhistor
         AND crapthi.dsorigem = pr_dsorigem;
    rw_crapthi    cr_crapthi%rowtype;
    -- Busca as agências da cooperativa
    CURSOR cr_crapage is
      SELECT cdagenci,
             cdccuage,
             cdcxaage,
             tpagenci
        FROM cecred.crapage
       WHERE cdcooper = pr_cdcooper
       ORDER BY cdagenci;
    -- Rejeitados na integração
    CURSOR cr_craprej (pr_cdcooper in cecred.craptab.cdcooper%TYPE,
                       pr_cdprogra in cecred.crapprg.cdprogra%TYPE,
                       pr_dtmvtolt in cecred.crapdat.dtmvtolt%TYPE,
                       pr_nraplica IN NUMBER) IS
      SELECT craphis.nrctacrd,
             craphis.nrctadeb,
             craprej.nrdctabb,
             craprej.dtrefere,
             craprej.cdagenci,
             craprej.vllanmto,
             craphis.cdhstctb,
             craphis.cdhistor,
             craphis.dsexthst,
             craphis.ingerdeb,
             craphis.ingercre,
             craphis.tpctbcxa,
             craprej.cdbccxlt,
             craprej.nraplica,
             craprej.vlsdapli,
             craprej.nrdocmto
        FROM cecred.craprej,
             cecred.craphis
       WHERE craprej.cdcooper = pr_cdcooper
         AND craprej.cdpesqbb = pr_cdprogra
         AND craprej.dtmvtolt = pr_dtmvtolt
         AND craphis.cdcooper = craprej.cdcooper
         AND craphis.cdhistor = craprej.cdhistor
         AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
         AND  pr_nraplica = 0)
          OR (craprej.nraplica IN (1,2)
         AND   pr_nraplica > 0))
         AND TRIM(craprej.dshistor) IS NULL
       ORDER BY craprej.cdhistor,
                craprej.nraplica,
                craprej.dtrefere,
                craprej.nrdocmto,
                craprej.cdagenci,
                craprej.progress_recid;

    -- Craprej arrecadacao valores TAA e Internet
    cursor cr_craprej_arr (pr_cdcooper in cecred.craptab.cdcooper%type,
                           pr_cdprogra in cecred.crapprg.cdprogra%type,
                           pr_dtmvtolt in cecred.crapdat.dtmvtolt%type,
                           pr_nraplica IN NUMBER,
                           pr_cdagenci in integer,
                           pr_cdhistor in integer) IS
      select rej.cdagenci
            ,rej.cdhistor
            ,rej.nrseqdig
            ,rej.vllanmto
        from cecred.craprej rej
       where rej.cdcooper = pr_cdcooper
         and rej.cdpesqbb = pr_cdprogra
         and rej.dtmvtolt = pr_dtmvtolt
         and rej.nrdocmto = pr_cdagenci
         and rej.cdhistor = pr_cdhistor
         AND ((rej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
         AND  pr_nraplica = 0)
          OR (rej.nraplica IN (1,2)
         AND   pr_nraplica > 0))
         AND trim(rej.dshistor) is null;

    -- Busca parâmetro genérico cadastrado
    cursor cr_craptab (pr_cdcooper in cecred.craptab.cdcooper%type,
                       pr_cdempres in cecred.craptab.cdempres%type,
                       pr_tptabela in cecred.craptab.tptabela%type,
                       pr_nrdctabb in cecred.craptab.cdacesso%type,
                       pr_cdbccxlt in cecred.craptab.tpregist%type) is
      select dstextab
        from cecred.craptab
       where craptab.cdcooper        = pr_cdcooper
         and UPPER(craptab.nmsistem) = 'CRED'
         and UPPER(craptab.tptabela) = pr_tptabela
         and craptab.cdempres        = pr_cdempres
         and UPPER(craptab.cdacesso) = pr_nrdctabb
         and craptab.tpregist        = pr_cdbccxlt;
    rw_craptab    cr_craptab%rowtype;
    -- Rejeitados na integração
    cursor cr_craprej2 (pr_cdcooper in cecred.craptab.cdcooper%type,
                        pr_cdprogra in cecred.crapprg.cdprogra%type,
                        pr_dtmvtolt in cecred.crapdat.dtmvtolt%type,
                        pr_nraplica IN NUMBER) IS
      select crapthi.cdcooper,
             crapthi.cdhistor,
             upper(craprej.dtrefere) dtrefere,
             craprej.nrdctabb,
             craprej.cdagenci,
             craprej.nrseqdig,
             craprej.tpintegr,
             crapthi.vltarifa,
             craprej.nraplica,
             craprej.vlsdapli,
             craprej.nrdocmto
        from cecred.craprej,
             cecred.crapthi
       where crapthi.cdcooper = pr_cdcooper
         and crapthi.vltarifa > 0
         and crapthi.dsorigem = 'AIMARO'
         and craprej.cdcooper = crapthi.cdcooper
         and craprej.cdhistor = crapthi.cdhistor
         and craprej.cdpesqbb = pr_cdprogra
         and craprej.dtmvtolt = pr_dtmvtolt
         AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
         AND  pr_nraplica = 0)
          OR (craprej.nraplica IN (1,2)
         AND   pr_nraplica > 0))
       order by crapthi.cdhistor,
                craprej.nraplica,
                craprej.nrdctabb,
                craprej.cdbccxlt,
                craprej.cdagenci,
                craprej.dtrefere;
    -- Histórico
    cursor cr_craphis2 (pr_cdcooper in cecred.crapthi.cdcooper%type,
                        pr_cdhistor in cecred.crapthi.cdhistor%type) is
      select cdhistor,
             cdhstctb,
             tpctbcxa,
             nrctatrd,
             nrctatrc,
             dsexthst,
             nrctacrd,
             nrctadeb,
             ingerdeb,
             ingercre,
             dshistor,
             nmestrut,
             tpctbccu
        from cecred.craphis
       where craphis.cdcooper = pr_cdcooper
         and craphis.cdhistor = pr_cdhistor
       ORDER BY craphis.progress_recid;
    rw_craphis2     cr_craphis2%rowtype;
    -- Busca parâmetro genérico cadastrado
    cursor cr_craptab2 (pr_cdcooper in cecred.craptab.cdcooper%type,
                        pr_tptabela in cecred.craptab.tptabela%type,
                        pr_nrdctabb in cecred.craptab.cdacesso%type) is
      select dstextab
        from cecred.craptab
       where craptab.cdcooper        = pr_cdcooper
         and UPPER(craptab.tptabela) = pr_tptabela
         and UPPER(craptab.cdacesso) = pr_nrdctabb;
    -- Tarifa dos históricos
    cursor cr_crabthi (pr_cdcooper in cecred.crapthi.cdcooper%type,
                       pr_cdhistor in cecred.crapthi.cdhistor%type,
                       pr_dsorigem in cecred.crapthi.dsorigem%type) is
      select vltarifa
        from cecred.crapthi
       where crapthi.cdcooper = pr_cdcooper
         and crapthi.cdhistor = pr_cdhistor
         and crapthi.dsorigem = pr_dsorigem;
    rw_crabthi     cr_crabthi%rowtype;
    -- Subscrição de capital
    cursor cr_crapsdc (pr_cdcooper in cecred.craptab.cdcooper%type,
                       pr_dtmvtolt in cecred.crapdat.dtmvtolt%type,
                       pr_indebito in cecred.crapsdc.indebito%type) is
      select sum(vllanmto) vllanmto
        from cecred.crapsdc
       where crapsdc.cdcooper = pr_cdcooper
         and crapsdc.dtdebito = pr_dtmvtolt
         and crapsdc.indebito = nvl(pr_indebito, crapsdc.indebito);

    -- Subscrição de capital atual
    cursor cr_crapsdc_LT (pr_cdcooper in craptab.cdcooper%type,
                           pr_dtmvtolt in crapdat.dtmvtolt%type) is
      select sum(vllanmto) vllanmto
        from cecred.crapsdc
       where crapsdc.cdcooper = pr_cdcooper
         and crapsdc.dtmvtolt = pr_dtmvtolt;

    -- Entradas de cheques em custodia do dia
    cursor cr_crapcst (pr_cdcooper in craptab.cdcooper%type,
                       pr_dtmvtolt in crapdat.dtmvtolt%type) is
      select nrdconta,
             vlcheque
        from crapcst
       where crapcst.cdcooper = pr_cdcooper
         and crapcst.dtmvtolt = pr_dtmvtolt
         and crapcst.nrborder = 0;
    -- Liberacao de cheques em custodia do dia
    cursor cr_crapcst2 (pr_cdcooper in cecred.craptab.cdcooper%type,
                        pr_dtmvtoan in cecred.crapcst.dtlibera%type,
                        pr_dtmvtolt in cecred.crapcst.dtlibera%type) is
      select /*+ index (crapcst crapcst##crapcst3)*/
             nrdconta,
             vlcheque
        from cecred.crapcst
       where crapcst.cdcooper = pr_cdcooper
         and crapcst.dtlibera > pr_dtmvtoan
         and crapcst.dtlibera <= pr_dtmvtolt
         and crapcst.dtdevolu is null
         and crapcst.nrborder = 0;
    -- Resgates de cheques em custodia do dia / transf. para desconto de cheques
    cursor cr_crapcst3 (pr_cdcooper in cecred.craptab.cdcooper%type,
                        pr_dtmvtolt in cecred.crapdat.dtmvtolt%type) is
      select /*+ index (crapcst crapcst##crapcst6)*/
             nrdconta,
             vlcheque,
             insitchq
        from cecred.crapcst
       where crapcst.cdcooper = pr_cdcooper
         and crapcst.dtdevolu = pr_dtmvtolt
         and crapcst.nrborder = 0;
    -- Títulos compensáveis
    cursor cr_craptit (pr_cdcooper in cecred.craptit.cdcooper%type,
                       pr_dtmvtolt in cecred.craptit.dtmvtolt%type,
                       pr_intitcop in cecred.craptit.intitcop%type)is
      select /*+ index (craptit craptit##craptit4)*/
             craptit.cdagenci,
             sum(craptit.vldpagto) vldpagto,
             count(*) qttottrf
        from cecred.craptit
       where craptit.cdcooper = pr_cdcooper
         and craptit.dtdpagto = pr_dtmvtolt
         and craptit.insittit in (0,2,4)
         and craptit.tpdocmto = 20
         and craptit.intitcop = pr_intitcop -- 0 = Outros Bancos; 1 = Cooperativa
       group by craptit.cdagenci
       order by craptit.cdagenci;
    -- Código do banco do titulo para uma agencia
    cursor cr_crapage2 (pr_cdcooper in cecred.crapage.cdcooper%type,
                        pr_cdagenci in cecred.crapage.cdagenci%type) is
      select cdbantit,
             cdbanchq
        from cecred.crapage
       where crapage.cdcooper = pr_cdcooper
         and crapage.cdagenci = pr_cdagenci;
    rw_crapage2     cr_crapage2%rowtype;
    -- Borderôs de desconto de cheques
    cursor cr_crapbdc (pr_cdcooper in cecred.crapbdc.cdcooper%type,
                       pr_dtmvtolt in cecred.crapbdc.dtlibbdc%type) is
      select nrborder
        from cecred.crapbdc
       where crapbdc.cdcooper = pr_cdcooper
         and crapbdc.dtlibbdc = pr_dtmvtolt
         and crapbdc.insitbdc = 3;
    -- Desconto de cheques
    cursor cr_crapcdb (pr_cdcooper in cecred.crapcdb.cdcooper%type,
                       pr_nrborder in cecred.crapcdb.nrborder%type) is
      select /*+ index (crapcdb crapcdb##crapcdb7)*/
             vlcheque,
             vlliquid,
             nrdconta,
             nrborder,
             cdagenci,
             nrcheque
        from cecred.crapcdb
       where crapcdb.cdcooper = pr_cdcooper
         and crapcdb.nrborder = pr_nrborder
         AND crapcdb.insitana = 1; --> apenas os aprovados
    -- Desconto de cheques
    cursor cr_crapcdb2 (pr_cdcooper in cecred.crapcdb.cdcooper%type,
                        pr_dtmvtoan in cecred.crapcdb.dtlibera%type,
                        pr_dtmvtolt in cecred.crapcdb.dtlibera%type) is
      select /*+ index (crapcdb crapcdb##crapcdb3)*/
             vlcheque,
             vlliquid,
             nrdconta,
             nrborder,
             cdagenci,
             nrcheque,
             inchqcop
        from cecred.crapcdb
       where crapcdb.cdcooper = pr_cdcooper
         and crapcdb.dtlibera > pr_dtmvtoan
         and crapcdb.dtlibera <= pr_dtmvtolt
         AND crapcdb.insitana = 1 --> apenas os aprovados
         and crapcdb.dtlibbdc is not null
         and crapcdb.dtdevolu is null;
    -- Desconto de cheques
    cursor cr_crapcdb3 (pr_cdcooper in cecred.crapcdb.cdcooper%type,
                        pr_dtdevolu in cecred.crapcdb.dtdevolu%type) is
      select /*+ index (crapcdb crapcdb##crapcdb6)*/
             vlcheque,
             vlliquid,
             nrdconta,
             nrborder,
             cdagenci,
             nrcheque,
             inchqcop,
             vlliqdev
        from cecred.crapcdb
       where crapcdb.cdcooper = pr_cdcooper
         and crapcdb.dtdevolu = pr_dtdevolu
         and crapcdb.insitana = 1 --> apenas os aprovados
         and crapcdb.insitchq = 1; -- Resgatado
    -- Borderô de desconto de títulos
    cursor cr_crapbdt (pr_cdcooper in cecred.crapbdt.cdcooper%type,
                       pr_dtmvtolt in cecred.crapbdt.dtlibbdt%type) is
      select nrdconta,
             nrborder,
             cdagenci,
             flverbor
        from cecred.crapbdt
       where crapbdt.cdcooper = pr_cdcooper
         and crapbdt.dtlibbdt = pr_dtmvtolt
         and crapbdt.insitbdt in (3, 4) -- Liberado ou Liquidado
         AND crapbdt.flverbor = 0;

    -- Títulos do borderô
    cursor cr_craptdb (pr_cdcooper in cecred.craptdb.cdcooper%type,
                       pr_nrdconta in cecred.craptdb.nrdconta%type,
                       pr_nrborder in cecred.craptdb.nrborder%type) is
      select /*+index (craptdb craptdb##craptdb1)*/
             craptdb.nrdconta,
             craptdb.nrborder,
             craptdb.nrdocmto,
             craptdb.vltitulo,
             crapcob.flgregis,
             craptdb.vlliquid
        from cecred.crapcob,
             cecred.craptdb
       where craptdb.cdcooper = pr_cdcooper
         and craptdb.nrdconta = pr_nrdconta
         and craptdb.nrborder = pr_nrborder
         --and craptdb.insittit <> 1 -- Resgatado
         and crapcob.cdcooper = craptdb.cdcooper
         and crapcob.nrdconta = craptdb.nrdconta
         and crapcob.nrcnvcob = craptdb.nrcnvcob
         and crapcob.nrdocmto = craptdb.nrdocmto
         and crapcob.nrdctabb = craptdb.nrdctabb
         and crapcob.cdbandoc = craptdb.cdbandoc
         and craptdb.dtlibbdt is not null;

    -- Títulos em desconto
    cursor cr_craptdb2 (pr_cdcooper in cecred.craptdb.cdcooper%type,
                        pr_dt_ini in cecred.craptdb.dtdpagto%type,
                        pr_dt_fim in cecred.craptdb.dtdpagto%type,
                        pr_cdbandoc in cecred.craptdb.cdbandoc%type) is
      select /*+ index (craptdb craptdb##craptdb2)*/
             tdb.cdcooper,
             tdb.cdbandoc,
             tdb.nrdctabb,
             tdb.nrcnvcob,
             tdb.nrdconta,
             tdb.nrdocmto,
             tdb.nrborder,
             tdb.vltitulo,
             tdb.vlliquid,
             tdb.vlliqres,
             tdb.dtlibbdt,
             tdb.dtvencto,
             tdb.rowid,
             bdt.cdagenci cdagenci_bdt
        from cecred.craptdb tdb, cecred.crapbdt bdt
       where tdb.cdcooper = pr_cdcooper
         and tdb.cdbandoc = nvl(pr_cdbandoc,tdb.cdbandoc)
         and tdb.dtdpagto > pr_dt_ini
         and tdb.dtdpagto <= pr_dt_fim
         and tdb.insittit = 2 -- Processados
         AND bdt.cdcooper = tdb.cdcooper
         AND bdt.nrdconta = tdb.nrdconta
         AND bdt.nrborder = tdb.nrborder
         AND bdt.flverbor = 0;

    -- Verificar se o título é da migração
    cursor cr_crapcco (pr_cdcooper in cecred.crapcco.cdcooper%type,
                       pr_nrcnvcob in cecred.crapcco.nrconven%type) is
      select crapcco.dsorgarq
        from cecred.crapcco
       where crapcco.cdcooper = pr_cdcooper
         and crapcco.nrconven = pr_nrcnvcob;
    rw_crapcco     cr_crapcco%rowtype;
    -- Títulos em desconto
    cursor cr_craptdb3 (pr_cdcooper in craptdb.cdcooper%type,
                        pr_dtmvtolt in craptdb.dtdpagto%type) is
      select /*+ index (craptdb craptdb##craptdb2)*/
             tdb.cdcooper,
             tdb.cdbandoc,
             tdb.nrdctabb,
             tdb.nrcnvcob,
             tdb.nrdconta,
             tdb.nrdocmto,
             tdb.nrborder,
             tdb.vltitulo,
             tdb.vlliquid,
             tdb.vlliqres,
             tdb.dtlibbdt,
             tdb.dtvencto,
             tdb.rowid,
             bdt.cdagenci cdagenci_bdt
        FROM cecred.craptdb tdb, cecred.crapbdt bdt
       where tdb.cdcooper = pr_cdcooper
         and tdb.dtdpagto = pr_dtmvtolt
         and tdb.insittit  = 2 -- Processado
         AND bdt.cdcooper = tdb.cdcooper
         AND bdt.nrdconta = tdb.nrdconta
         AND bdt.nrborder = tdb.nrborder
         AND bdt.flverbor = 0;

    -- Títulos em desconto
    cursor cr_craptdb4 (pr_cdcooper in cecred.craptdb.cdcooper%TYPE
                       ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE) is
      select tdb.cdcooper,
             tdb.cdbandoc,
             tdb.nrdctabb,
             tdb.nrcnvcob,
             tdb.nrdconta,
             tdb.nrdocmto,
             tdb.nrborder,
             tdb.vltitulo,
             tdb.vlliquid,
             tdb.vlliqres,
             tdb.dtlibbdt,
             tdb.dtvencto,
             tdb.rowid,
             bdt.cdagenci cdagenci_bdt
        from cecred.craptdb tdb, cecred.crapbdt bdt
       where tdb.cdcooper = pr_cdcooper
         and tdb.dtdebito = pr_dtmvtolt
         and tdb.insittit = 3 -- Processado
         AND bdt.cdcooper = tdb.cdcooper
         AND bdt.nrdconta = tdb.nrdconta
         AND bdt.nrborder = tdb.nrborder
         AND bdt.flverbor = 0;

    -- Títulos em desconto
    cursor cr_craptdb5 (pr_cdcooper in cecred.craptdb.cdcooper%type,
                        pr_dtmvtolt in cecred.craptdb.dtdpagto%type) is
      select /*+ index (craptdb craptdb##craptdb4)*/
             tdb.cdcooper,
             tdb.cdbandoc,
             tdb.nrdctabb,
             tdb.nrcnvcob,
             tdb.nrdconta,
             tdb.nrdocmto,
             tdb.nrborder,
             tdb.vltitulo,
             tdb.vlliquid,
             tdb.vlliqres,
             tdb.dtlibbdt,
             tdb.dtvencto,
             tdb.rowid,
             bdt.cdagenci cdagenci_bdt
        from cecred.craptdb tdb, cecred.crapbdt bdt
       where tdb.cdcooper = pr_cdcooper
         and tdb.dtresgat = pr_dtmvtolt
         and tdb.dtlibbdt <> pr_dtmvtolt
         AND bdt.cdcooper = tdb.cdcooper
         AND bdt.nrdconta = tdb.nrdconta
         AND bdt.nrborder = tdb.nrborder
         AND bdt.flverbor = 0;

    -- Documentos do desconto de títulos
    cursor cr_crapcob (pr_cdcooper in cecred.craptdb.cdcooper%type,
                       pr_cdbandoc in cecred.craptdb.cdbandoc%type,
                       pr_nrdctabb in cecred.craptdb.nrdctabb%type,
                       pr_nrcnvcob in cecred.craptdb.nrcnvcob%type,
                       pr_nrdconta in cecred.craptdb.nrdconta%type,
                       pr_nrdocmto in cecred.craptdb.nrdocmto%type) is
      select indpagto,
             flgregis,
             vldpagto,
             nrdconta,
             vltitulo,
             nrcnvcob
        from cecred.crapcob
       where crapcob.cdcooper = pr_cdcooper
         and crapcob.cdbandoc = pr_cdbandoc
         and crapcob.nrdctabb = pr_nrdctabb
         and crapcob.nrcnvcob = pr_nrcnvcob
         and crapcob.nrdconta = pr_nrdconta
         and crapcob.nrdocmto = pr_nrdocmto;
    rw_crapcob     cr_crapcob%rowtype;
    -- Informações do associado
    cursor cr_crapass (pr_cdcooper in cecred.crapass.cdcooper%type,
                       pr_nrdconta in cecred.crapass.nrdconta%type) is
      select crapass.cdagenci,
             crapass.inpessoa,
             crapass.dtdemiss,
             crapage.insitage
        from cecred.crapass,
             cecred.crapage
       where crapass.cdcooper = crapage.cdcooper
         and crapass.cdagenci = crapage.cdagenci
         and crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%rowtype;

    -- Retorno de títulos bancários do banco do brasil
    cursor cr_crapret (pr_cdcooper in cecred.crapret.cdcooper%type,
                       pr_dtmvtolt in cecred.crapret.dtaltera%type) is
      select crapret.cdhistbb,
             sum(nvl(crapret.vltarcus, 0)) vltarcus,
             sum(sum(nvl(crapret.vltarcus, 0))) over (partition by crapret.cdhistbb) vltarcus_tot,
             sum(nvl(crapret.vloutdes, 0)) vloutdes,
             sum(sum(nvl(crapret.vloutdes, 0))) over (partition by crapret.cdhistbb) vloutdes_tot,
             crapass.cdagenci
        from cecred.crapass,
             cecred.crapret,
             cecred.crapcco
       where crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 1
         AND crapcco.flgregis = 1
         AND crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO')
         AND crapret.cdcooper = crapcco.cdcooper
         AND crapret.nrcnvcob = crapcco.nrconven
         and crapret.dtocorre = pr_dtmvtolt
         and cdhistbb in (936, 937, 938, 939, 940, 965, 966, 973)
         and crapass.cdcooper = crapret.cdcooper
         and crapass.nrdconta = crapret.nrdconta
       group by crapret.cdhistbb,
                crapass.cdagenci
       order by crapret.cdhistbb,
                crapass.cdagenci;
    rw_crapret     cr_crapret%rowtype;
    -- Retorno de títulos bancários (associados não cadastrados)
    cursor cr_crapret2 (pr_cdcooper in cecred.crapret.cdcooper%type,
                        pr_dtmvtolt in cecred.crapret.dtaltera%type) is
      select crapret.rowid
        from cecred.crapret
            ,cecred.crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = 1
         AND crapcco.flgregis = 1
         AND crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO')
         AND crapret.cdcooper = crapcco.cdcooper
         AND crapret.nrcnvcob = crapcco.nrconven
         and crapret.dtocorre = pr_dtmvtolt
         and crapret.cdhistbb in (936, 937, 938, 939, 940, 965, 966, 973)
         -- Não existam associados
         and not exists (select 1
                           from crapass
                          where crapass.cdcooper = crapret.cdcooper
                            and crapass.nrdconta = crapret.nrdconta);
    -- Buscar acertos financeiros
    cursor cr_crapafi (pr_cdcooper in cecred.crapafi.cdcooper%type,
                       pr_dtmvtolt in cecred.crapafi.dtmvtolt%type) is
      select crapafi.cdcopdst,
             crapafi.cdhistor,
             sum(crapafi.vllanmto) vlafitot -- valor para crédito e débito, tratamento com IF dentro do loop
        from cecred.crapafi
       where crapafi.cdcooper = pr_cdcooper
         and crapafi.dtlanmto = pr_dtmvtolt
         and crapafi.cdhistor IN (266,971)  -- CREDITO DE COBRANCA BANCO DO BRASIL e CREDITO DE COBRANCA REGISTRADA B. BRASIL
    group by crapafi.cdcopdst
            ,crapafi.cdhistor;

    -- Buscar acertos financeiros e do associado por data , historico e conta bb
    cursor cr_crapafi2 (pr_cdcooper in cecred.crapafi.cdcooper%type,
                        pr_dtmvtolt in cecred.crapafi.dtmvtolt%type,
                        pr_cdhistor in cecred.crapafi.cdhistor%type,
                        pr_nrdctabb in cecred.crapafi.nrdctabb%type) is
      select crapafi.cdcopdst,
             crapafi.cdhistor,
             crapafi.vllanmto,  -- valor para crédito e débito, tratamento com IF dentro do loop
             crapass.cdagenci,
             Count(1) OVER (PARTITION BY crapafi.cdhistor) qtdreg,
             Row_Number() OVER (PARTITION BY crapafi.cdhistor ORDER BY crapafi.cdhistor) nrseqreg
       from cecred.crapafi,
            cecred.crapass
      where crapafi.cdcooper = pr_cdcooper
        and crapafi.dtlanmto = pr_dtmvtolt
        and crapafi.cdhistor = pr_cdhistor
        and crapafi.nrdctabb = pr_nrdctabb
        and crapass.cdcooper = crapafi.cdcooper
        and crapass.nrdconta = crapafi.nrctadst;

    -- Buscar acertos financeiros por data , historico e conta bb
    cursor cr_crapafi3 (pr_cdcooper in cecred.crapafi.cdcooper%type,
                        pr_dtmvtolt in cecred.crapafi.dtmvtolt%type,
                        pr_cdhistor in cecred.crapafi.cdhistor%type,
                        pr_nrdctabb in cecred.crapafi.nrdctabb%type) is
     select crapafi.cdcopdst,
            crapafi.cdhistor,
            sum(crapafi.vllanmto) vlafitot -- valor para crédito e débito, tratamento com IF dentro do loop
       from cecred.crapafi
      where crapafi.cdcooper = pr_cdcooper
        and crapafi.dtlanmto = pr_dtmvtolt
        and crapafi.cdhistor = pr_cdhistor
        and crapafi.nrdctabb = pr_nrdctabb
      group by crapafi.cdcopdst
              ,crapafi.cdhistor;

    -- IPTU
    cursor cr_craptit2 (pr_cdcooper in cecred.craptit.cdcooper%type,
                        pr_dtmvtolt in cecred.craptit.dtmvtolt%type) is
      select /*+ index (craptit craptit4##craptit4)*/
             craptit.cdagenci,
             sum(craptit.vldpagto) vldpagto,
             count(*) qttottrf
        from cecred.craptit
       where craptit.cdcooper = pr_cdcooper
         and craptit.dtdpagto = pr_dtmvtolt
         and craptit.insittit = 4
         and craptit.tpdocmto = 21
       group by craptit.cdagenci
       order by craptit.cdagenci;
    -- COBAN
    cursor cr_crapcbb (pr_cdcooper in cecred.crapcbb.cdcooper%type,
                       pr_dtmvtolt in cecred.crapcbb.dtmvtolt%type) is
      select crapcbb.cdagenci,
             sum(crapcbb.valorpag) valorpag,
             count(case when nvl(t.cdmodalidade_tipo,0) <> 4 and a.nrdconta is not null then 1 else null end) qttottrf,
             count(case when nvl(t.cdmodalidade_tipo,0) = 4 or a.nrdconta is null then 1 else null end) qttottrfep
        from cecred.crapcbb
     left join cecred.crapass a on (crapcbb.nrctaatd = a.nrdconta and crapcbb.cdcooper = a.cdcooper)
     left join cecred.tbcc_tipo_conta t on (a.inpessoa = t.inpessoa and a.cdtipcta = t.cdtipo_conta)
       where crapcbb.cdcooper = pr_cdcooper
         AND crapcbb.dtmvtolt = pr_dtmvtolt
         and crapcbb.flgrgatv = 1
         and crapcbb.tpdocmto < 3
       group by crapcbb.cdagenci
       order by crapcbb.cdagenci;
    -- COBAN - recebimento inss
    cursor cr_crapcbb2 (pr_cdcooper in cecred.crapcbb.cdcooper%type,
                        pr_dtmvtolt in cecred.crapcbb.dtmvtolt%type) is
      select crapcbb.cdagenci,
             sum(crapcbb.valorpag) valorpag,
             count(*) qttottrf
        from cecred.crapcbb
       where crapcbb.cdcooper = pr_cdcooper
         AND crapcbb.dtmvtolt = pr_dtmvtolt
         and crapcbb.flgrgatv = 1
         and crapcbb.tpdocmto = 3
       group by crapcbb.cdagenci
       order by crapcbb.cdagenci;
    -- Créditos pagos INSS
    cursor cr_craplpi (pr_cdcooper in cecred.craplpi.cdcooper%type,
                       pr_dtmvtolt in cecred.craplpi.dtmvtolt%type,
                       pr_cdagenci in cecred.craplpi.cdagenci%type) is
      select craplpi.tppagben,
             craplpi.vllanmto,
             craplpi.cdagenci
        from cecred.craplpi
       where craplpi.cdcooper = pr_cdcooper
         and craplpi.dtmvtolt = pr_dtmvtolt
         and craplpi.cdagenci = pr_cdagenci;
    -- Depósitos à vista
    cursor cr_craplcm (pr_cdcooper in cecred.craplcm.cdcooper%type,
                       pr_dtmvtolt in cecred.craplcm.dtmvtolt%type,
                       pr_cdagenci in cecred.craplcm.cdagenci%type) is
      select craplcm.cdagenci
        from cecred.craplcm
       where craplcm.cdcooper = pr_cdcooper
         and craplcm.dtmvtolt = pr_dtmvtolt
         and craplcm.cdagenci = pr_cdagenci
         and craplcm.cdhistor = 581; -- CREDITO DO BENEFICIO DO INSS

    -- Guias de previdência social
    cursor cr_gps_gerencial(pr_cdcooper in cecred.craplgp.cdcooper%type,
                            pr_dtmvtolt in cecred.craplgp.dtmvtolt%type,
                            pr_cdhistor in cecred.craphis.cdhistor%type) is
      select vlr.cdagenci,
             sum(vlr.vlrtotal) vlrtotal,
             count(*) qttottrf
        from ( select lgp.cdagenci
                     ,lgp.vlrtotal
                from cecred.craplgp lgp
               where lgp.cdcooper = pr_cdcooper
                 and lgp.dtmvtolt = pr_dtmvtolt
                 AND lgp.cdbccxlt = 11 -- GPS ANTIGO
            UNION ALL
              select lgp.cdagenci
                    ,lgp.vlrtotal
                from cecred.craplgp lgp
               where lgp.cdcooper = pr_cdcooper
                 and lgp.dtmvtolt = pr_dtmvtolt
                 AND lgp.cdbccxlt = 100 -- GPS NOVO
                 AND lgp.flgpagto = 1   -- PAGO
                 AND lgp.idsicred <> 0
                 AND lgp.flgativo = 1
                 AND ((pr_cdhistor = 1414) OR (pr_cdhistor = 3361 AND TRIM(lgp.cdbarras) IS NULL)) -- Para TIVIT coletar somente dados de guias sem código de barras
              ) vlr
       group by vlr.cdagenci
       order by vlr.cdagenci;

    -- Conta investimento
    cursor cr_craplci (pr_cdcooper in cecred.craplci.cdcooper%type,
                       pr_dtmvtolt in cecred.craplci.dtmvtolt%type) is
      select craplci.cdhistor,
             craplci.cdagenci,
             craplci.nrdconta,
             craplci.vllanmto
        from cecred.craplci
       where craplci.cdcooper = pr_cdcooper
         and craplci.dtmvtolt = pr_dtmvtolt
         and craplci.cdhistor in (485, 486, 487, 647, 648); -- Débitos e Créditos em investimentos
    -- Lançamentos extra-sistema para boletim de caixa
    cursor cr_craplcx (pr_cdcooper in cecred.craplcx.cdcooper%type,
                       pr_dtmvtolt in cecred.craplcx.dtmvtolt%type) is
      select /*+ index (craplcx craplcx##craplcx1)*/
             cdagenci,
             nrdcaixa,
             vldocmto,
             dsdcompl,
             cdhistor
        from cecred.craplcx
       where craplcx.cdcooper = pr_cdcooper
         and craplcx.dtmvtolt = pr_dtmvtolt
         and craplcx.cdhistor not in (718, 731, 2063, 2064); -- Custódia de cheques   -- Saque demitidos
    -- Saldo do terminal financeiro
    cursor cr_crapstf (pr_cdcooper in cecred.crapstf.cdcooper%type,
                       pr_dtmvtolt in cecred.crapstf.dtmvtolt%type) is
      select nrterfin,
             dtmvtolt
        from cecred.crapstf
       where crapstf.cdcooper = pr_cdcooper
         and crapstf.dtmvtolt = pr_dtmvtolt;
    -- Cadastro do terminal financeiro
    cursor cr_craptfn (pr_cdcooper in craptfn.cdcooper%type,
                       pr_nrterfin in craptfn.nrterfin%type) is
      select cdagenci,
             nrterfin
        from craptfn
       where craptfn.cdcooper = pr_cdcooper
         and craptfn.nrterfin = pr_nrterfin;
    rw_craptfn     cr_craptfn%rowtype;
    -- Log de operação do terminal financeiro
    cursor cr_craplfn (pr_cdcooper in cecred.craplfn.cdcooper%type,
                       pr_dtmvtolt in cecred.craplfn.dtmvtolt%type,
                       pr_nrterfin in cecred.craplfn.nrterfin%type) is
      select cdoperad,
             nrterfin,
             sum(decode(tpdtrans, 4, vltransa, 0)) vlsuprim,
             sum(decode(tpdtrans, 5, vltransa, 0)) vlrecolh
        from cecred.craplfn
       where craplfn.cdcooper = pr_cdcooper
         and craplfn.dtmvtolt = pr_dtmvtolt
         and craplfn.nrterfin = pr_nrterfin
       group by cdoperad,
                nrterfin
       ORDER BY MIN(craplfn.progress_recid); -- Renato Darosci - 18/10/2013
    -- Operador
    cursor cr_crapope (pr_cdcooper in cecred.crapope.cdcooper%type,
                       pr_cdoperad in cecred.crapope.cdoperad%type) is
      select nmoperad
        from cecred.crapope
       where crapope.cdcooper = pr_cdcooper
         and crapope.cdoperad = pr_cdoperad;
    rw_crapope     cr_crapope%rowtype;
    -- Contabilização da COMP ELETRONICA
    cursor cr_craplot (pr_cdcooper in cecred.craplot.cdcooper%type,
                       pr_dtmvtolt in cecred.craplot.dtmvtolt%type) is
      select /*+ index (crapchd crapchd##crapchd3)*/
             craplot.cdagenci,
             craplot.nrdcaixa,
             craplot.cdopecxa,
             sum(crapchd.vlcheque) vlcompel,
             count(*) qtcompel
        from cecred.crapchd,
             cecred.craplot
       where craplot.cdcooper = pr_cdcooper
         and craplot.dtmvtolt = pr_dtmvtolt
         and craplot.cdbccxlt in (11, 500)
         and craplot.tplotmov in (1, 23, 29)
         and crapchd.cdcooper = craplot.cdcooper
         and crapchd.dtmvtolt = craplot.dtmvtolt
         and crapchd.cdagenci = craplot.cdagenci
         and crapchd.cdbccxlt = craplot.cdbccxlt
         and crapchd.nrdolote = craplot.nrdolote
         and crapchd.inchqcop = 0
       group by craplot.cdagenci,
                craplot.nrdcaixa,
                craplot.cdopecxa
       order by craplot.cdagenci,
                craplot.nrdcaixa,
                craplot.cdopecxa;
    -- Transferência de salário para outra instituição
    cursor cr_craplcs (pr_cdcooper in cecred.craplcs.cdcooper%type,
                       pr_dtmvtolt in cecred.craplcs.dtmvtolt%type,
                       pr_cdhistor in cecred.craplcs.cdhistor%type) is
      select cdagenci,
             sum(vllanmto) vllanmto
        from cecred.craplcs
       where craplcs.cdcooper = pr_cdcooper
         and craplcs.dtmvtolt = pr_dtmvtolt
         and craplcs.cdhistor = pr_cdhistor
       group by cdagenci
       order by cdagenci;
    -- Transferência de salário para outra instituição
    cursor cr_craplcs2 (pr_cdcooper in cecred.craplcs.cdcooper%type,
                        pr_dtmvtolt in cecred.craplcs.dtmvtolt%type,
                        pr_cdhistor in cecred.craplcs.cdhistor%type) is
      select dtmvtolt,
             sum(vllanmto) vllanmto
        from cecred.craplcs
       where craplcs.cdcooper = pr_cdcooper
         and craplcs.dtmvtolt = pr_dtmvtolt
         and craplcs.cdhistor = pr_cdhistor
       group by dtmvtolt
       order by dtmvtolt;
    -- Depósitos à vista
    cursor cr_craplcm2 (pr_cdcooper in cecred.craplcm.cdcoptfn%type,
                        pr_dtmvtolt in cecred.craplcm.dtmvtolt%type,
                        pr_cdhistor in cecred.craplcm.cdhistor%type) is
      select cdagetfn,
             sum(vllanmto) vllanmto
        from cecred.craplcm
       where craplcm.cdcoptfn = pr_cdcooper
         and craplcm.dtmvtolt = pr_dtmvtolt
         and craplcm.cdhistor = pr_cdhistor
       group by cdagetfn
       order by cdagetfn;

    -- Saque Cooperados Demitidos
    cursor cr_craplcm21 (pr_cdcooper in cecred.craplcm.cdcoptfn%type,
                         pr_dtmvtolt in cecred.craplcm.dtmvtolt%type) is
     select craplcx1.cdagenci
           ,craplcx1.cdhistor
           ,craplcx1.vllanmto
       from (select craplcx.cdagenci
                   ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                                ,decode(crapass.inpessoa,1,2081,2082)) cdhistor
                   ,sum(craplcx.vldocmto) vllanmto
               from cecred.craplcx
                   ,cecred.crapass
              where craplcx.cdcooper = pr_cdcooper
                and craplcx.dtmvtolt = pr_dtmvtolt
                and craplcx.cdhistor in (2065,2083)
                and craplcx.cdcooper = crapass.cdcooper
                and craplcx.nrdconta = crapass.nrdconta
              group by craplcx.cdagenci
                      ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                                    ,decode(crapass.inpessoa,1,2081,2082))
              order by craplcx.cdagenci
                      ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                                    ,decode(crapass.inpessoa,1,2081,2082))
     ) craplcx1
     union
     select craplcm1.cdagenci
           ,craplcm1.cdhistor
           ,craplcm1.vllanmto
       from (select lanc.cdagenci
                   ,lanc.cdhistor
                   ,sum(lanc.vllanmto) vllanmto
               from (select crapass.cdagenci
                           ,case craplcm.cdhistor
                              when 4022 then
                                decode(crapass.inpessoa,1,2081,2082)
                              when 4023 then
                                decode(crapass.inpessoa,1,2081,2082)
                              when 4024 then
                                decode(crapass.inpessoa,1,2063,2064)
                              when 4025 then
                                decode(crapass.inpessoa,1,2063,2064)
                              when 4026 then
                                decode(crapass.inpessoa,1,4034,4035)
                              when 4028 then
                                decode(crapass.inpessoa,1,4036,4037)
                              when 4030 then
                                decode(crapass.inpessoa,1,4038,4039)
                              else -- 4032
                                decode(crapass.inpessoa,1,4040,4041)
                            end as cdhistor
                           ,craplcm.vllanmto
                       from cecred.craplcm
                           ,cecred.crapass
                           ,contacorrente.tbcc_solicitacao_devolucao
                      where craplcm.cdcooper = pr_cdcooper
                        and craplcm.dtmvtolt = pr_dtmvtolt
                        and craplcm.cdhistor in (4022,4023,4024,4025,4026,4028,4030,4032)
                        and craplcm.cdpesqbb = tbcc_solicitacao_devolucao.idsolicitacao
                        and craplcm.cdcooper = crapass.cdcooper
                        and tbcc_solicitacao_devolucao.nrdconta = crapass.nrdconta
                     ) lanc
              group by lanc.cdagenci
                      ,lanc.cdhistor
              order by lanc.cdagenci
                      ,lanc.cdhistor
     ) craplcm1
     ;


     -- FINAME BNDES
    CURSOR cr_craplcm7 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT cdcooper,
             SUM(vllanmto) vllanmto
        FROM cecred.craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor = pr_cdhistor
       GROUP BY cdcooper;
    /*
      pr_tpmovcontabil
      1 - Repasse da Operação entre Central e Filiada;
      2 - Pagamento Operação entre Central e Filiada;
      3 - Estorno Pagamento Operação entre Central e Filiada;
    */
    /* PRJ0024210 */
    CURSOR cr_bndes_peqemp (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_tpmovcontabil IN NUMBER) IS
    SELECT cdcooper
          ,SUM(vllanmto) vllanmto
      FROM cecred.craplcm
    WHERE craplcm.cdcooper = 3
      AND craplcm.dtmvtolt = pr_dtmvtolt
      AND ((craplcm.cdhistor IN (3999) AND pr_tpmovcontabil = 1) OR
           (craplcm.cdhistor IN (4001,4005,4006) AND pr_tpmovcontabil = 2) OR
           (craplcm.cdhistor IN (4009,4010,4011) AND pr_tpmovcontabil = 3))
      AND craplcm.nrdconta = (SELECT crapcop.nrctactl
                                FROM cecred.crapcop
                                WHERE crapcop.cdcooper = pr_cdcooper)
    GROUP BY cdcooper;

    rw_bndes_peqemp cr_bndes_peqemp%ROWTYPE;

    -- 403 - Transferncia para prejuizo desconto de titulo
    CURSOR cr_tbdsct_lancamento_bordero (pr_cdcooper IN cecred.tbdsct_lancamento_bordero.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.tbdsct_lancamento_bordero.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.tbdsct_lancamento_bordero.cdhistor%TYPE) IS
      SELECT tlb.cdcooper,
             SUM(vllanmto) vllanmto
        FROM cecred.tbdsct_lancamento_bordero tlb
       WHERE tlb.cdcooper = pr_cdcooper
         AND tlb.dtmvtolt = pr_dtmvtolt
         AND tlb.cdhistor in (pr_cdhistor)
       GROUP BY tlb.cdcooper;

    -- Melhoria 324 - Transferncia para prejuizo
    CURSOR cr_craplem2 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE,
                        pr_idtipo   in number) IS -- 1-emprestimo; 2-Financiamento
      SELECT craplem.cdcooper,
             SUM(vllanmto) vllanmto
        FROM cecred.craplem, cecred.crapepr, cecred.craplcr
       WHERE crapepr.cdcooper = craplem.cdcooper
         and crapepr.nrdconta = craplem.nrdconta
         and crapepr.nrctremp = craplem.nrctremp
         and craplcr.cdcooper = crapepr.cdcooper
         and craplcr.cdlcremp = crapepr.cdlcremp
         and craplem.cdcooper = pr_cdcooper
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdhistor in (pr_cdhistor)
         and ((pr_idtipo = 2 and craplcr.dsoperac  = 'FINANCIAMENTO')
          OR (pr_idtipo = 1 and craplcr.dsoperac <> 'FINANCIAMENTO')
          OR (pr_idtipo = 0))
       GROUP BY craplem.cdcooper;

    -- Melhoria 324 - Transferncia para prejuizo
    CURSOR cr_craplcm_prej (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                            pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                            pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT SUM(nvl(c.vllanmto,0)) vllanmto
        FROM cecred.craplcm c
       WHERE c.cdcooper = pr_cdcooper
         AND c.dtmvtolt = pr_dtmvtolt
         AND c.cdhistor = pr_cdhistor
         and c.cdbccxlt = 100
         ;

    -- Buscar operadoras ativas
    CURSOR cr_operadora (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE
                        ,pr_inpessoa IN cecred.crapass.inpessoa%TYPE) IS
      SELECT tope.cdoperadora
            ,topr.nmoperadora
            ,topr.perreceita
            ,decode(pr_inpessoa,0,0,ass.inpessoa) inpessoa
            ,ass.cdagenci
            ,sum(vlrecarga) vlrecarga
            ,(SUM(vlrecarga) - SUM(tope.vlrepasse)) vl_receita
        FROM cecred.tbrecarga_operacao tope
            ,cecred.tbrecarga_operadora topr
            ,cecred.crapass             ass
       WHERE tope.cdcooper = ass.cdcooper
         and tope.nrdconta = ass.nrdconta
         and tope.cdcooper = pr_cdcooper
         AND tope.insit_operacao = 2
         AND tope.dtdebito = pr_dtmvtolt
         AND topr.cdoperadora = tope.cdoperadora
         AND ass.inpessoa = decode(pr_inpessoa,0,ass.inpessoa,pr_inpessoa)
        GROUP BY tope.cdoperadora
                ,topr.nmoperadora
                ,topr.perreceita
                ,ass.cdagenci
                ,decode(pr_inpessoa,0,0,ass.inpessoa)
        order by ass.cdagenci;


    CURSOR cr_recargas (pr_cdcooper    IN cecred.craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt    IN cecred.craplcm.dtmvtolt%TYPE
                       ,pr_inpessoa    IN cecred.crapass.inpessoa%TYPE) IS

     SELECT cdagenci,
            inpessoa,
            sum(vl_receita) vl_receita
       FROM (SELECT tope.cdoperadora
                   ,topr.perreceita
                   ,decode(pr_inpessoa,0,0,ass.inpessoa) inpessoa
                   ,ass.cdagenci
                   ,(SUM(vlrecarga) - SUM(tope.vlrepasse)) vl_receita
        FROM cecred.tbrecarga_operacao tope
                   ,cecred.tbrecarga_operadora topr
            ,cecred.crapass ass
              WHERE tope.cdcooper       = ass.cdcooper
                and tope.nrdconta       = ass.nrdconta
                and tope.cdcooper       = pr_cdcooper
         AND tope.insit_operacao = 2
                AND tope.dtdebito       = pr_dtmvtolt
                AND topr.cdoperadora    = tope.cdoperadora
                AND ass.inpessoa        = decode(pr_inpessoa,0,ass.inpessoa,pr_inpessoa)
               GROUP BY tope.cdoperadora
                       ,topr.perreceita
                       ,ass.cdagenci
                       ,decode(pr_inpessoa,0,0,ass.inpessoa)
               order by ass.cdagenci)
     GROUP BY cdagenci,
              inpessoa
     ORDER BY cdagenci;

    CURSOR cr_crapcon (pr_cdcooper in cecred.crapcon.cdcooper%TYPE
                      ,pr_cdempcon IN cecred.crapcon.cdempcon%TYPE
            ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
      SELECT crapcon.nmextcon
        FROM cecred.crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto
         AND crapcon.CDHISTOR NOT IN (3465);   -- não pega o historico do DARF 100 - RFB;
    rw_crapcon     cr_crapcon%ROWTYPE;

    -- Convênio Sicredi
    cursor cr_crapscn (pr_cdempcon in cecred.crapcon.cdempcon%TYPE,
                       pr_cdsegmto IN cecred.crapcon.cdsegmto%TYPE) is
      select crapscn.cdempres
        from cecred.crapscn
       where crapscn.cdempcon = pr_cdempcon
         and crapscn.cdsegmto = pr_cdsegmto
         AND crapscn.dsoparre <> 'E';
    rw_crapscn     cr_crapscn%rowtype;

    cursor cr_crapscn3 (pr_cdempcon in cecred.crapcon.cdempcon%TYPE,
                        pr_cdsegmto IN cecred.crapcon.cdsegmto%TYPE) is
      select crapscn.cdempres
        from cecred.crapscn
       where crapscn.cdempco2 = pr_cdempcon
         and crapscn.cdsegmto = pr_cdsegmto
         AND crapscn.dsoparre <> 'E';

    -- Buscar pagamentos de convênios rejeitados no PAGFOR Sicredi ou TIVIT
    CURSOR cr_rejeicoes_sicredi_tivit (pr_cdcooper IN cecred.crapdat.cdcooper%TYPE
                                      ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE
                                      ,pr_cdagente IN cecred.tbconv_remessa_pagfor.cdagente_arrecadacao%TYPE) IS
      SELECT reg.cdagenci            cdagenci,
             reg.cdempresa_documento cdempres,
             SUM(reg.vlrpagamento)   vllanmto
        FROM cecred.tbconv_remessa_pagfor rem,
             cecred.tbconv_registro_remessa_pagfor reg
       WHERE rem.dtmovimento            = pr_dtmvtolt
         AND rem.cdagente_arrecadacao   = pr_cdagente
         AND reg.idremessa              = rem.idremessa
         AND reg.cdstatus_processamento = 4
         AND reg.cdcooper               = pr_cdcooper
    GROUP BY reg.cdagenci,
             reg.cdempresa_documento;
    rw_rejeicoes_sicredi_tivit cr_rejeicoes_sicredi_tivit%ROWTYPE;

    -- Lançamento de faturas sem código de barras
    cursor cr_craplft2 (pr_cdcooper in cecred.craplft.cdcooper%type,
                        pr_dtmvtolt in cecred.craplft.dtmvtolt%type,
                        pr_cdempcon in cecred.craplft.cdempcon%type,
                        pr_cdsegmto in cecred.craplft.cdsegmto%type,
                        pr_cdhistor in cecred.craplft.cdhistor%type,
                        pr_tpfatura in cecred.craplft.tpfatura%type,
                        pr_cdtr6106 number) is
      select decode(craplft.cdtribut,
                    6106, 'D0',
                    'A0') cdempres,
             craplft.cdagenci,
             lead (craplft.cdagenci,1) OVER (ORDER BY craplft.cdagenci) AS proxima_agencia,
             decode(craplft.cdagenci,
                    90, nvl(crapass.cdagenci, craplft.cdagenci),
                    91, nvl(crapass.cdagenci, craplft.cdagenci),
                    craplft.cdagenci) cdagenci_fatura,
             decode(craplft.tpfatura,
                    0, 0,
                    1) tpfatura, -- 0 para fatura, 1 para tributos
             count(craplft.vllanmto) qtlanmto,
             sum(craplft.vllanmto +
                 craplft.vlrmulta +
                 craplft.vlrjuros) vllanmto
        from cecred.crapass,
             cecred.craplft
       where craplft.cdcooper = pr_cdcooper
         and craplft.dtmvtolt = pr_dtmvtolt
         and craplft.cdempcon = pr_cdempcon
         and craplft.cdsegmto = pr_cdsegmto
         and craplft.cdhistor = pr_cdhistor
         and craplft.tpfatura = pr_tpfatura
         and ((pr_cdtr6106 = 0 and craplft.cdtribut <> 6106) or
              (pr_cdtr6106 = 1 and craplft.cdtribut  = 6106))
         and crapass.cdcooper (+) = craplft.cdcooper
         and crapass.nrdconta (+) = craplft.nrdconta
       group by decode(craplft.cdtribut,
                       6106, 'D0',
                       'A0'),
                craplft.cdagenci,
                nvl(crapass.cdagenci, craplft.cdagenci),
                decode(craplft.tpfatura,
                       0, 0,
                       1)
       order by 1, 2, 3;
    -- Convênio Sicredi
    cursor cr_crapstn (pr_cdempres in cecred.crapstn.cdempres%type,
                       pr_tpdarrec in cecred.crapstn.tpmeiarr%type) is
      select crapstn.vltrfuni
        from cecred.crapstn
       where upper(crapstn.cdempres) = pr_cdempres
         and upper(crapstn.tpmeiarr) = pr_tpdarrec
       AND crapstn.cdtransa = DECODE(crapstn.tpmeiarr,
                  'D', DECODE(crapstn.cdempres, 'K0', '0XY', '147', '1CK', crapstn.cdtransa),
                  crapstn.cdtransa);
    rw_crapstn     cr_crapstn%rowtype;
    -- Lançamento de faturas
    cursor cr_craplft (pr_cdcooper in cecred.craplft.cdcooper%type,
                       pr_dtmvtolt in cecred.craplft.dtmvtolt%type,
                       pr_cdhistor in cecred.craplft.cdhistor%type) is
      select craplft.cdempcon,
             craplft.cdsegmto,
             craplft.cdagenci,
             craplft.cdhistor,
             lead (craplft.cdagenci,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proxima_agencia,
             lead (craplft.cdempcon,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proximo_cdempcon,
             lead (craplft.cdsegmto,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proximo_cdsegmto,
             decode(craplft.cdagenci,
                    90, nvl(crapass.cdagenci, craplft.cdagenci),
                    91, nvl(crapass.cdagenci, craplft.cdagenci),
                    craplft.cdagenci) cdagenci_fatura,
             decode(craplft.tpfatura,
                    0, 0,
                    1) tpfatura, -- 0 para fatura, 1 para tributos
             sum(craplft.vllanmto) vllanmto,
             count(*) qtlanmto
        from cecred.crapass,
             cecred.craplft
       where craplft.cdcooper = pr_cdcooper
         and craplft.dtmvtolt = pr_dtmvtolt
         and craplft.cdhistor = pr_cdhistor
         and crapass.cdcooper (+) = craplft.cdcooper
         and crapass.nrdconta (+) = craplft.nrdconta
       group by craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdagenci,
                craplft.cdhistor,
                nvl(crapass.cdagenci, craplft.cdagenci),
                decode(craplft.tpfatura,
                       0, 0,
                       1)
       order by craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdagenci;

    TYPE typ_cr_craplft IS TABLE OF cr_craplft%ROWTYPE index by binary_integer;
    rw_craplft  typ_cr_craplft;

    -- Convênio Sicredi
    cursor cr_crapscn2 (pr_cdempres in cecred.crapscn.cdempres%type) is
      select crapscn.cdempres,
             crapscn.dsnomcnv
        from cecred.crapscn
       where UPPER(crapscn.cdempres) = pr_cdempres;
    rw_crapscn2     cr_crapscn2%rowtype;

    -- Debito Automatico Sicredi
    CURSOR cr_craplcm4 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT craplau.cdempres, crapscn.dsnomcnv, COUNT(*) qtlanmto, SUM(craplcm.vllanmto) vllanmto
        FROM cecred.craplcm, cecred.craplau, cecred.crapscn
        WHERE craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplau.cdempres = UPPER(crapscn.cdempres)
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.cdcooper = pr_cdcooper
          AND craplcm.dtmvtolt = pr_dtmvtolt
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplcm.cdhistor = pr_cdhistor
          AND crapscn.dtencemp IS NULL
          AND crapscn.dsoparre = 'E'
        GROUP BY craplau.cdempres,
                 crapscn.dsnomcnv
        ORDER BY craplau.cdempres;
    rw_craplcm4 cr_craplcm4%ROWTYPE;
    -- Debito Automatico Sicredi (Tarifa)
    CURSOR cr_craplcm5 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT /*+ index (craplau craplau##craplau2)*/
             crapass.cdagenci,
             craplau.cdempres,
             crapscn.dsnomcnv,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep,
             SUM(craplcm.vllanmto) vllanmto
        FROM cecred.craplcm, cecred.craplau, cecred.crapscn, cecred.crapass, cecred.tbcc_tipo_conta
        WHERE craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplau.cdempres = UPPER(crapscn.cdempres)
          AND craplcm.cdcooper = crapass.cdcooper
          AND craplcm.nrdconta = crapass.nrdconta
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.cdcooper = pr_cdcooper
          AND craplcm.dtmvtolt = pr_dtmvtolt
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplcm.cdhistor = pr_cdhistor
          AND crapscn.dtencemp IS NULL
          AND crapscn.dsoparre = 'E'
          AND tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          and tbcc_tipo_conta.inpessoa = crapass.inpessoa
        GROUP BY crapass.cdagenci,
                 craplau.cdempres,
                 crapscn.dsnomcnv
        ORDER BY craplau.cdempres,
                 crapass.cdagenci;
    rw_craplcm5 cr_craplcm5%ROWTYPE;
    -- Despesa Sicredi (Debito Automatico)
    CURSOR cr_craplcm6 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT crapass.cdagenci,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep
        FROM cecred.craplcm, cecred.craplau, cecred.crapscn, cecred.crapass, cecred.tbcc_tipo_conta
        WHERE craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplau.dtdebito = craplcm.dtmvtolt
          AND craplau.cdempres = UPPER(crapscn.cdempres)
          AND crapass.nrdconta = craplcm.nrdconta
          AND craplcm.nrdconta = crapass.nrdconta
          AND craplcm.cdcooper = crapass.cdcooper
          AND craplcm.cdcooper = pr_cdcooper
          AND craplcm.dtmvtolt = pr_dtmvtolt
          AND craplcm.cdhistor = pr_cdhistor
          AND crapscn.dtencemp IS NULL
          AND crapscn.dsoparre = 'E'
          AND tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          and tbcc_tipo_conta.inpessoa = crapass.inpessoa
        GROUP BY crapass.cdagenci
        ORDER BY crapass.cdagenci;
    rw_craplcm6 cr_craplcm6%ROWTYPE;

    -- Deb. Automatico Bancoob
      CURSOR cr_crapcon2(pr_cdcooper in cecred.crapcon.cdcooper%TYPE
                      ,pr_cdempres IN cecred.tbconv_arrecadacao.cdempres%TYPE) IS
      SELECT crapcon.nmextcon, tbconv_arrecadacao.vltarifa_debaut
        FROM cecred.tbconv_arrecadacao, cecred.crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = tbconv_arrecadacao.cdempcon
         AND crapcon.cdsegmto = tbconv_arrecadacao.cdsegmto
         AND tbconv_arrecadacao.cdempres = pr_cdempres;
    rw_crapcon2     cr_crapcon2%ROWTYPE;

    -- Debito Automatico Bancoob
    CURSOR cr_craplcm10 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                         pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                         pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT craplau.cdempres, SUM(craplcm.vllanmto) vllanmto
        FROM  cecred.craplcm, cecred.craplau, cecred.tbconv_arrecadacao
        WHERE craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplau.cdempres = tbconv_arrecadacao.cdempres
          aND craplau.cdhistor = pr_cdhistor
          and craplau.dtdebito = pr_dtmvtolt
          and craplau.cdcooper = pr_cdcooper
        GROUP BY craplau.cdempres
        ORDER BY craplau.cdempres;
       rw_craplcm10 cr_craplcm10%ROWTYPE;

    CURSOR cr_craplcm11 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                         pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                         pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT crapass.cdagenci,
             craplau.cdempres,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep,
             SUM(craplcm.vllanmto) vllanmto
        FROM cecred.craplcm, cecred.craplau, cecred.tbconv_arrecadacao, cecred.crapass, cecred.tbcc_tipo_conta
        WHERE tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          and tbcc_tipo_conta.inpessoa = crapass.inpessoa
          AND crapass.cdcooper = craplcm.cdcooper
          AND crapass.nrdconta = craplcm.nrdconta
          AND craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplau.cdempres = tbconv_arrecadacao.cdempres
          aND craplau.cdhistor = pr_cdhistor
          and craplau.dtdebito = pr_dtmvtolt
          and craplau.cdcooper = pr_cdcooper
        GROUP BY crapass.cdagenci,
                 craplau.cdempres
        ORDER BY craplau.cdempres,
                 crapass.cdagenci;
    rw_craplcm11 cr_craplcm11%ROWTYPE;

    CURSOR cr_craplcm12 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT crapass.cdagenci,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep
        FROM cecred.craplcm, cecred.craplau, cecred.tbconv_arrecadacao, cecred.crapass, cecred.tbcc_tipo_conta
        WHERE tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          and tbcc_tipo_conta.inpessoa = crapass.inpessoa
          AND crapass.cdcooper = craplcm.cdcooper
          AND crapass.nrdconta = craplcm.nrdconta
          AND craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplau.cdempres = tbconv_arrecadacao.cdempres
          aND craplau.cdhistor = pr_cdhistor
          and craplau.dtdebito = pr_dtmvtolt
          and craplau.cdcooper = pr_cdcooper
        GROUP BY crapass.cdagenci
        ORDER BY crapass.cdagenci;
    rw_craplcm12 cr_craplcm12%ROWTYPE;

   -- Debito Automatico Bancoob
    CURSOR cr_craplcm13 (pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                         pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                         pr_cdhistor IN cecred.craplcm.cdhistor%TYPE,
                         pr_cdempres IN cecred.craplau.cdempres%TYPE) IS
      SELECT COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep
        FROM  cecred.craplcm, cecred.craplau, cecred.crapass, cecred.tbconv_arrecadacao, cecred.tbcc_tipo_conta
        WHERE tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          AND tbcc_tipo_conta.inpessoa = crapass.inpessoa
          AND crapass.cdcooper = craplcm.cdcooper
          AND crapass.nrdconta = craplcm.nrdconta
          AND craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplau.cdempres = tbconv_arrecadacao.cdempres
          AND tbconv_arrecadacao.cdempres = pr_cdempres
          AND craplau.cdhistor = pr_cdhistor
          AND craplau.dtdebito = pr_dtmvtolt
          AND craplau.cdcooper = pr_cdcooper
        GROUP BY craplau.cdempres
        ORDER BY craplau.cdempres;
       rw_craplcm13 cr_craplcm13%ROWTYPE;

    CURSOR cr_craplcm14(pr_cdcooper IN cecred.craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE,
                        pr_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
      SELECT COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 then 1 else null end) qtlanmto,
             COUNT(case when nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 then 1 else null end) qtlanmtoep
        FROM cecred.craplcm, cecred.craplau, cecred.tbconv_arrecadacao, cecred.crapass, cecred.tbcc_tipo_conta
        WHERE tbcc_tipo_conta.cdtipo_conta = crapass.cdtipcta
          and tbcc_tipo_conta.inpessoa = crapass.inpessoa
          AND crapass.cdcooper = craplcm.cdcooper
          AND crapass.nrdconta = craplcm.nrdconta
          AND craplcm.cdcooper = craplau.cdcooper
          AND craplcm.nrdconta = craplau.nrdconta
          AND craplcm.cdhistor = craplau.cdhistor
          AND craplcm.nrdocmto = craplau.nrdocmto
          AND craplcm.dtmvtolt = craplau.dtdebito
          AND craplau.cdempres = tbconv_arrecadacao.cdempres
          aND craplau.cdhistor = pr_cdhistor
          and craplau.dtdebito = pr_dtmvtolt
          and craplau.cdcooper = pr_cdcooper;
      rw_craplcm14 cr_craplcm14%ROWTYPE;

    -- Tarifa para despesas Sicredi
    cursor cr_crapthi2 (pr_cdcooper in cecred.crapthi.cdcooper%type,
                        pr_cdhistor in cecred.crapthi.cdhistor%type) is
      select vltarifa
        from cecred.crapthi
       where crapthi.cdcooper = pr_cdcooper
         and crapthi.cdhistor = pr_cdhistor
         and crapthi.dsorigem = 'AIMARO';
    rw_crapthi2     cr_crapthi2%rowtype;

    -- Buscar os históricos a serem processados
    CURSOR cr_histori(pr_cdcooper in crapcco.cdcooper%TYPE) IS
      SELECT crapfvl.cdhistor
            ,crapcco.nrdctabb
            ,crapcco.flgregis
            ,crapcco.dsorgarq
        FROM cecred.crapcco
            ,cecred.crapfco
            ,cecred.crapfvl
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapfco.cdcooper = crapcco.cdcooper
         AND crapfco.nrconven = crapcco.nrconven
         AND crapfco.flgvigen = 1 -- Fixo
         AND crapfvl.cdfaixav = crapfco.cdfaixav;
    -- P681 - Entes Públicos - Marcus Abreu
    -- Buscar os históricos de Entes Públicos a serem processados
    CURSOR cr_historiep(pr_cdcooper in cecred.crapcco.cdcooper%TYPE) IS
      SELECT crapfvl.cdhistep
            ,crapcco.nrdctabb
            ,crapcco.flgregis
            ,crapcco.dsorgarq
        FROM cecred.crapcco
            ,cecred.crapfco
            ,cecred.crapfvl
            ,cecred.craptar
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapfco.cdcooper = crapcco.cdcooper
         AND crapfco.nrconven = crapcco.nrconven
         AND crapfco.flgvigen = 1 -- Fixo
         AND crapfvl.cdfaixav = crapfco.cdfaixav
         AND crapfvl.cdtarifa = craptar.cdtarifa
         and craptar.flgcnfep = 1;-- Somente Tarifas com Flag de configuracao do Ente Publico como 1-Sim
    -- Buscar contrato do BNDES
    CURSOR cr_crapebn(pr_cdcooper   cecred.crapebn.cdcooper%TYPE
                     ,pr_nrdconta   cecred.crapebn.nrdconta%TYPE
                     ,pr_nrctremp   cecred.crapebn.nrctremp%TYPE) IS
      SELECT 1
        FROM cecred.crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctremp;

    -- Títulos compensáveis
    CURSOR cr_craptit3 (pr_cdcooper IN cecred.craptit.cdcooper%TYPE,
                       pr_dtmvtolt IN cecred.craptit.dtmvtolt%TYPE) IS
      SELECT /*+ index (craptit craptit##craptit4)*/
             craptit.cdagenci,
             SUM(craptit.vldpagto) vldpagto,
             COUNT(*) qttottrf
        FROM cecred.craptit
       WHERE craptit.cdcooper = pr_cdcooper
         AND craptit.dtdpagto = pr_dtmvtolt
         AND craptit.insittit in (0,2,4)
         AND craptit.cdbandst <> 85
         AND craptit.tpdocmto = 20
         AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
       GROUP BY craptit.cdagenci
       ORDER BY craptit.cdagenci;

    -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE COM FLOAT
    -- MOVIMENTA CONTA 4972
    CURSOR cr_craptit4 (pr_cdcooper IN cecred.craptit.cdcooper%TYPE,
                       pr_dtmvtolt IN cecred.craptit.dtmvtolt%TYPE) IS
      SELECT /*+ index (craptit craptit##craptit4)*/
             craptit.cdagenci,
             SUM(craptit.vldpagto) vldpagto,
             SUBSTR(craptit.dscodbar,20,6) nrconven,
             crapcco.dsorgarq,
             COUNT(*) qttottrf
        FROM cecred.craptit, cecred.crapcco
       WHERE craptit.cdcooper = pr_cdcooper
         AND craptit.dtdpagto = pr_dtmvtolt
         AND craptit.insittit in (0,2,4)
         AND craptit.cdbandst = 85
         AND craptit.tpdocmto = 20
         AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
         AND NOT EXISTS (    SELECT 1
                               FROM cecred.craptdb tdb
                         INNER JOIN cecred.crapbdt bdt ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
                              WHERE bdt.flverbor = 0
                                AND tdb.cdcooper = craptit.cdcooper
                                AND tdb.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                                AND tdb.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                                AND tdb.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                                AND tdb.insittit = 2
                                AND tdb.dtdpagto = pr_dtmvtolt
                          UNION ALL
                             SELECT 1
                               FROM cecred.tbdsct_lancamento_bordero lbd
                         INNER JOIN cecred.crapbdt bdt ON bdt.cdcooper = lbd.cdcooper AND bdt.nrdconta = lbd.nrdconta AND bdt.nrborder = lbd.nrborder
                              WHERE bdt.flverbor = 1
                                AND lbd.cdcooper = craptit.cdcooper
                                AND lbd.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                                AND lbd.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                                AND lbd.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                                AND lbd.cdhistor = 2673
                                AND lbd.dtmvtolt = pr_dtmvtolt)
         AND crapcco.cdcooper = craptit.cdcooper
         AND crapcco.nrconven = to_number(SUBSTR(craptit.dscodbar,20,6))
       GROUP BY craptit.cdagenci, SUBSTR(craptit.dscodbar,20,6), crapcco.dsorgarq
       ORDER BY craptit.cdagenci;

    -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE - DESCONTADOS
    -- MOVIMENTA CONTA 4954
    CURSOR cr_craptit5 (pr_cdcooper IN cecred.craptit.cdcooper%TYPE,
                       pr_dtmvtolt IN cecred.craptit.dtmvtolt%TYPE) IS
      SELECT /*+ index (craptit craptit##craptit4)*/
             craptit.cdagenci,
             SUM(craptit.vldpagto) vldpagto,
             SUBSTR(craptit.dscodbar,20,6) nrconven,
             COUNT(*) qttottrf
        FROM cecred.craptit
       WHERE craptit.cdcooper = pr_cdcooper
         AND craptit.dtdpagto = pr_dtmvtolt
         AND craptit.insittit in (0,2,4)
         AND craptit.cdbandst = 85
         AND craptit.tpdocmto = 20
         AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
         AND EXISTS (    SELECT 1
                           FROM cecred.craptdb tdb
                     INNER JOIN cecred.crapbdt bdt ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
                          WHERE bdt.flverbor = 0
                            AND tdb.cdcooper = craptit.cdcooper
                            AND tdb.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                            AND tdb.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                            AND tdb.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                            AND tdb.insittit = 2
                            AND tdb.dtdpagto = pr_dtmvtolt
                      UNION ALL
                         SELECT 1
                           FROM cecred.tbdsct_lancamento_bordero lbd
                     INNER JOIN cecred.crapbdt bdt ON bdt.cdcooper = lbd.cdcooper AND bdt.nrdconta = lbd.nrdconta AND bdt.nrborder = lbd.nrborder
                          WHERE bdt.flverbor = 1
                            AND lbd.cdcooper = craptit.cdcooper
                            AND lbd.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                            AND lbd.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                            AND lbd.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                            AND lbd.cdhistor = 2673
                            AND lbd.dtmvtolt = pr_dtmvtolt)
       GROUP BY craptit.cdagenci, SUBSTR(craptit.dscodbar,20,6)
       ORDER BY craptit.cdagenci;

    -- Movimento dos títulos 085 pagos pela COMPE;
    CURSOR cr_crapret3 (pr_cdcooper in cecred.crapret.cdcooper%type,
                        pr_dtocorre in cecred.crapret.dtocorre%type) is
      SELECT ret.nrcnvcob,
             cco.dsorgarq,
             SUM(ret.vlrpagto) vlrpagto
        FROM cecred.crapcco cco, cecred.crapret ret, cecred.crapcop cop
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.cddbanco = 85
         AND cop.cdcooper = pr_cdcooper
         AND ret.cdcooper = cco.cdcooper
         AND ret.nrcnvcob = cco.nrconven
         AND ret.dtocorre = pr_dtocorre
         AND ret.dtcredit IS NOT NULL
         AND ret.cdocorre in (6,17,76,77)
         AND ret.vlrpagto < 250000
         AND ((ret.cdbcorec = 85 AND ret.cdagerec <> cop.cdagectl) OR
              (ret.cdbcorec <> 85) OR
              (ret.cdocorre = 6 AND ret.cdmotivo = '08')) -- liquidacoes cartorio IEPTB
       GROUP BY ret.nrcnvcob, cco.dsorgarq;

    -- cursor de consulta de produtos que possuem aplicacoes
    CURSOR cr_crapcpc IS
      SELECT crapcpc.cdprodut
            ,crapcpc.nmprodut
            ,crapcpc.cdhsnrap
            ,crapcpc.cddindex
        FROM cecred.crapcpc;

    CURSOR cr_crapplg(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                     ,pr_cdprodut cecred.crapcpc.cdprodut%TYPE
                     ,pr_dtcrps659 cecred.tbgen_prglog.dhfim%TYPE) IS
      SELECT ass.cdagenci
            ,nvl(sum(rac.vlslfmes),0) vlslfmes
      FROM cecred.crapass ass, cecred.craprac AS OF TIMESTAMP pr_dtcrps659 rac
      WHERE ass.nrdconta = rac.nrdconta+0
        AND ass.cdcooper = rac.cdcooper+0
        AND apli0012.fn_pessoa_ligada(rac.cdcooper,rac.nrdconta) = 1
        AND rac.idsaqtot = 0 --sem saque total
        AND rac.cdcooper = pr_cdcooper
        AND rac.cdprodut = pr_cdprodut --poupanca
      GROUP BY ass.cdagenci
      ORDER BY ass.cdagenci;
    TYPE typ_cr_crapplg IS TABLE OF cr_crapplg%ROWTYPE index by PLS_INTEGER;
    rw_crapplg typ_cr_crapplg;
    -- PRB0046128 - Novo cursor sem o TimeStamp
    CURSOR cr_crapplg_sem_ts(pr_cdcooper CECRED.crapcop.cdcooper%TYPE
                            ,pr_cdprodut CECRED.crapcpc.cdprodut%TYPE
                            ,pr_dtmvtoan CECRED.crapdat.dtmvtoan%TYPE) IS
      SELECT cdagenci
            ,NVL(SUM(vlaplicsaldomes),0) vlslfmes
        FROM CONTABILIDADE.tbcontab_arq_principal
       WHERE cdcooper = pr_cdcooper
         AND cdprodut = pr_cdprodut
         AND dtmvtolt = pr_dtmvtoan
         AND inprocesso = CONTABILIDADE.tipoTabArqPrincipal.inproc_RacSinteticoPorAgencia
    GROUP BY cdagenci
    ORDER BY cdagenci;

    -- cursor de consulta de aplicacoes
    CURSOR cr_craprac(pr_cdcooper cecred.crapcop.cdcooper%TYPE
                     ,pr_cdprodut cecred.crapcpc.cdprodut%TYPE
                     ,pr_dtcrps659 cecred.tbgen_prglog.dhfim%TYPE) IS
      SELECT craprac.vlslfmes,
             craprac.nrdconta,
             craprac.nraplica,
             craprac.idsaqtot
        FROM cecred.crapcpc, cecred.craprac AS OF TIMESTAMP pr_dtcrps659
       WHERE craprac.cdprodut = crapcpc.cdprodut
         AND craprac.cdcooper = pr_cdcooper
         AND craprac.cdprodut = pr_cdprodut
         AND craprac.idcalorc = 0;
      TYPE typ_cr_craprac IS TABLE OF cr_craprac%ROWTYPE index by PLS_INTEGER;
      rw_craprac typ_cr_craprac;
    -- PRB0046128 - Novo cursor sem o TimeStamp
    CURSOR cr_craprac_sem_ts(pr_cdcooper CECRED.crapcop.cdcooper%TYPE
                            ,pr_cdprodut CECRED.crapcpc.cdprodut%TYPE
                            ,pr_dtmvtoan CECRED.crapdat.dtmvtoan%TYPE) IS
      SELECT ass.cdagenci
            ,NVL(SUM(arq.vlaplicsaldomes),0) vlslfmes
        FROM CONTABILIDADE.tbcontab_arq_principal arq
            ,CECRED.crapass ass
       WHERE arq.cdcooper = ass.cdcooper
         AND arq.nrdconta = ass.nrdconta
         AND arq.cdcooper = pr_cdcooper
         AND arq.cdprodut = pr_cdprodut
         AND arq.dtmvtolt = pr_dtmvtoan
         AND arq.inprocesso = CONTABILIDADE.tipoTabArqPrincipal.inproc_RacAnalitico
    GROUP BY ass.cdagenci
    ORDER BY ass.cdagenci;
    TYPE typ_cr_craprac_sem_ts IS TABLE OF cr_craprac_sem_ts%ROWTYPE INDEX BY PLS_INTEGER;
    rw_craprac_sem_ts typ_cr_craprac_sem_ts;

    CURSOR cr_craplcm_tot(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                         ,pr_cdhistor IN cecred.craplcm.cdhistor%TYPE
                         ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS

      SELECT NVL(SUM(lcm.vllanmto),0) AS vllanmto
        FROM cecred.craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor = pr_cdhistor;
    rw_craplcm_tot cr_craplcm_tot%ROWTYPE;

    CURSOR cr_craplcm8(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                     ,pr_cdhistor IN cecred.craplcm.cdhistor%TYPE
                     ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS

      SELECT LPAD(ass.cdagenci,3,'0') AS cdagenci
            ,SUM(lcm.vllanmto)        AS vllanmto
        FROM cecred.craplcm lcm JOIN cecred.crapass ass
          ON lcm.cdcooper = ass.cdcooper
         AND lcm.nrdconta = ass.nrdconta
         AND lcm.cdhistor = pr_cdhistor
         AND lcm.dtmvtolt = pr_dtmvtolt
      WHERE lcm.cdcooper = pr_cdcooper
      GROUP BY ass.cdagenci
      ORDER BY ass.cdagenci;
    rw_craplcm8 cr_craplcm8%ROWTYPE;


    cursor cr_craprej4(pr_cdcooper in cecred.craptab.cdcooper%type,
                       pr_cdprogra in cecred.crapprg.cdprogra%type,
                       pr_dtmvtolt in cecred.crapdat.dtmvtolt%type,
                       pr_nraplica IN NUMBER) IS
      select craprej.cdagenci,
             case when craprej.cdhistor = 2094 then
                    2093
                  when craprej.cdhistor = 2091 then
                    2090
                  when craprej.cdhistor = 1544 then
                    1072
                  when craprej.cdhistor = 1542 then
                    1070
                  when craprej.cdhistor in (1510,1719) then
                    1710
                  else
                    craprej.cdhistor
             end cdhistor,
             craprej.nraplica,
             craprej.dshistor,
             sum(craprej.vlsdapli) vlsdapli
        from cecred.craprej
       where craprej.cdcooper = pr_cdcooper
         and craprej.cdpesqbb = pr_cdprogra
         and craprej.dtmvtolt = pr_dtmvtolt
         AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
         AND  pr_nraplica = 0)
          OR (craprej.nraplica IN (1,2)
         AND   pr_nraplica > 0))
         AND trim(craprej.dshistor) is not null
       group by craprej.cdagenci,
             case when craprej.cdhistor = 2094 then
                    2093
                  when craprej.cdhistor = 2091 then
                    2090
                  when craprej.cdhistor = 1544 then
                    1072
                  when craprej.cdhistor = 1542 then
                    1070
                  when craprej.cdhistor in (1510,1719) then
                    1710
                  else
                    craprej.cdhistor
             end,
             craprej.nraplica,
             craprej.dshistor
       HAVING SUM(craprej.vlsdapli)>0
       order by case when craprej.cdhistor = 2094 then
                    2093
                  when craprej.cdhistor = 2091 then
                    2090
                  when craprej.cdhistor = 1544 then
                    1072
                  when craprej.cdhistor = 1542 then
                    1070
                  when craprej.cdhistor in (1510,1719) then
                    1710
                  else
                    craprej.cdhistor
                end,
                craprej.dshistor,
                craprej.nraplica,
                craprej.cdagenci;


    CURSOR cr_craplcm_age(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                         ,pr_cdhistor IN cecred.craplcm.cdhistor%TYPE
                         ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
        SELECT NVL(SUM(lcm.vllanmto),0) AS vllanmto
            ,ass.cdagenci
            ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa
        FROM cecred.craplcm lcm
            ,cecred.crapass ass
       WHERE lcm.cdcooper = ass.cdcooper
         AND lcm.nrdconta = ass.nrdconta
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor = pr_cdhistor
       GROUP BY ass.cdagenci
               ,DECODE(ass.inpessoa,3,2,ass.inpessoa)
       ORDER BY ass.cdagenci
               ,DECODE(ass.inpessoa,3,2,ass.inpessoa);

    /* RITM0058093 */
    CURSOR cr_craplcm_age_mei(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                             ,pr_cdhistor IN cecred.craplcm.cdhistor%TYPE
                             ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT ass.cdagenci
           , NVL(SUM(lcm.vllanmto),0) AS vllanmto
        FROM cecred.craplcm lcm
           , cecred.crapass ass
           , cecred.crapjur jur
       WHERE jur.cdcooper = ass.cdcooper
         AND jur.nrdconta = ass.nrdconta
         AND jur.tpregtrb = 4
         AND lcm.cdcooper = ass.cdcooper
         AND lcm.nrdconta = ass.nrdconta
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor = pr_cdhistor
       GROUP
          BY ass.cdagenci
       ORDER
          BY ass.cdagenci;

    type            tab_agencia_mei is table of NUMBER index by binary_integer;
    vr_agencia_mei  tab_agencia_mei;
    vr_total_mei    NUMBER;
    /* RITM0058093 */

    cursor cr_crapafi4(pr_cdcooper in cecred.crapafi.cdcooper%type
                      ,pr_dtmvtolt in cecred.crapafi.dtmvtolt%type
                      ,pr_cdhistor in cecred.crapafi.cdhistor%type
                      ,pr_nrdctabb in cecred.crapafi.nrdctabb%type) is
      select decode(crapass.inpessoa,1,1,2) inpessoa,
             crapass.cdagenci,
             sum(crapafi.vllanmto) vllanmto
        from cecred.crapafi,
             cecred.crapass
       where crapafi.cdcooper = pr_cdcooper
         and crapafi.dtlanmto = pr_dtmvtolt
         and crapafi.cdhistor = pr_cdhistor
         and crapafi.nrdctabb = pr_nrdctabb
         and crapass.cdcooper = crapafi.cdcooper
         and crapass.nrdconta = crapafi.nrctadst
      group by decode(crapass.inpessoa,1,1,2),
               crapass.cdagenci
      order by decode(crapass.inpessoa,1,1,2),
               crapass.cdagenci;

    --
    cursor cr_craplcm9(pr_cdcooper in cecred.craplcm.cdcooper%type,
                       pr_dtmvtolt in cecred.craplcm.dtmvtolt%type,
                       pr_cdhistor in cecred.craplcm.cdhistor%type) is
      select crapass.cdagenci,
             decode(crapass.inpessoa,1,1,2) inpessoa,
             sum(to_number(nvl(trim(craplcm.dsidenti),0))) nrseqdig
        from cecred.crapass,
             cecred.craplcm
       where craplcm.cdcooper = pr_cdcooper
         and craplcm.dtmvtolt = pr_dtmvtolt
         and craplcm.cdhistor = pr_cdhistor
         and crapass.cdcooper = craplcm.cdcooper
         and crapass.nrdconta = craplcm.nrdconta
      group by crapass.cdagenci,
               crapass.inpessoa
      order by crapass.inpessoa,
               crapass.cdagenci;

  CURSOR cr_craprej_pa (pr_cdcooper in cecred.craprej.cdcooper%TYPE,
                           pr_cdhistor in cecred.craprej.cdhistor%TYPE,
                           pr_dtmvtolt IN cecred.craprej.dtmvtolt%TYPE,
                           pr_cdagenci IN cecred.craprej.cdagenci%TYPE) IS
      SELECT j.nrdocmto
            ,j.cdhistor
            ,j.nrseqdig
            ,j.tpintegr
        FROM cecred.craprej j
       WHERE j.cdcooper = pr_cdcooper
         AND upper(j.cdpesqbb) = 'CRPS249'
         AND j.cdhistor = pr_cdhistor
         AND j.dtmvtolt = pr_dtmvtolt
         AND j.cdagenci = pr_cdagenci
         AND j.nrdocmto <> 0; -- Pra não escrever duas vezes a linha do convenio

    -- Movimentos Protesto IEPTB
    CURSOR cr_finieptb(pr_cdcooper cecred.tbfin_recursos_movimento.cdcooper%TYPE
                      ,pr_dtmvtolt cecred.tbfin_recursos_movimento.dtmvtolt%TYPE
                      ) IS
      SELECT his.nrctadeb
            ,his.nrctacrd
            ,his.cdhstctb
            ,his.cdhistor
            ,fin.vllanmto
        FROM cecred.tbfin_recursos_movimento fin
            ,cecred.craphis                  his
       WHERE his.cdcooper = fin.cdcooper
         AND his.cdhistor = fin.cdhistor
         AND fin.vllanmto > 0
         AND fin.cdhistor IN(2622, 2642, 2646, 2663, 2734, 2917, 3005, 3007)
         AND fin.cdcooper = pr_cdcooper
         AND fin.dtmvtolt = pr_dtmvtolt;
    --
    rw_finieptb cr_finieptb%ROWTYPE;

    -- Lançamentos Pronampe (solicitacao e devolucao de honra)
    CURSOR cr_lanpronampe(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                      ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                      ) IS
      SELECT SUM(lcm.vllanmto) vllanmto
            ,lcm.cdhistor
        FROM cecred.craplcm lcm
            ,cecred.crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND lcm.cdcooper = 3
         AND lcm.nrdconta = cop.nrctactl
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.vllanmto > 0
         AND lcm.cdhistor IN (3786, 3777)
    GROUP BY lcm.cdhistor;

    rw_lanpronampe cr_lanpronampe%ROWTYPE;

    -- Lançamentos PEAC
    CURSOR cr_lanpeac(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                     ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
      SELECT SUM(lcm.vllanmto) vllanmto
            ,lcm.cdhistor
        FROM cecred.craplcm lcm
            ,cecred.crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND lcm.cdcooper = 3
         AND lcm.nrdconta = cop.nrctactl
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.vllanmto > 0
         AND lcm.cdhistor IN (3908, 3909)
    GROUP BY lcm.cdhistor;

    rw_lanpeac cr_lanpeac%ROWTYPE;

    -- Lançamentos Protesto IEPTB
    CURSOR cr_lanipetb(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                      ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                      ) IS
      SELECT SUM(lcm.vllanmto) vllanmto
            ,lcm.cdhistor
        FROM cecred.craplcm lcm
            ,cecred.crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND lcm.cdcooper = 3
         AND lcm.nrdconta = cop.nrctacmp
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.vllanmto > 0
         AND lcm.cdhistor IN (2635, 2637, 2639)
    GROUP BY lcm.cdhistor;
    --
    rw_lanipetb cr_lanipetb%ROWTYPE;

    CURSOR cr_lanipetb2(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                      ) IS
      SELECT cdagenci
            ,sum(vltarifa_ieptb) vltarifa_ieptb
            ,sum(sum(vltarifa_ieptb)) OVER () vltarifa_ieptb_total
       FROM( SELECT ass.cdagenci
                   ,SUM(con.vlgrava_eletronica) vltarifa_ieptb
               FROM cecred.tbcobran_confirmacao_ieptb con
                   ,cecred.crapass ass
              WHERE con.cdcooper        = pr_cdcooper
                AND con.dtmvtolt        = pr_dtmvtolt
                AND con.idlancto_tarifa > 0
                AND ass.cdcooper        = con.cdcooper
                AND ass.nrdconta        = con.nrdconta
              GROUP BY ass.cdagenci
              UNION
             SELECT ass.cdagenci
                   ,SUM(rti.vlgrava_eletronica)
               FROM cecred.tbcobran_retorno_ieptb rti
                   ,cecred.crapass ass
              WHERE rti.cdcooper        = pr_cdcooper
                AND rti.dtmvtolt        = pr_dtmvtolt
                AND rti.idlancto_tarifa > 0
                AND ass.cdcooper        = rti.cdcooper
                AND ass.nrdconta        = rti.nrdconta
           GROUP BY ass.cdagenci)
      GROUP BY cdagenci
      ORDER BY 1;
    --
    rw_lanipetb2 cr_lanipetb2%ROWTYPE;

    --> Buscar convenios Bancoob
    CURSOR cr_crapcon_bancoob (pr_cdcooper in cecred.crapcon.cdcooper%TYPE
                            ,pr_cdempcon IN cecred.crapcon.cdempcon%TYPE
                            ,pr_cdsegmto IN cecred.crapcon.cdsegmto%TYPE) is
      SELECT con.nmextcon
        FROM cecred.crapcon con
       WHERE con.cdempcon = pr_cdempcon
         AND con.cdsegmto = pr_cdsegmto
         AND con.cdcooper = pr_cdcooper;
    rw_crapcon_bancoob cr_crapcon_bancoob%ROWTYPE;

    -- Buscar valores de tarifas do bancoob
    CURSOR cr_conv_arrecad(pr_cdempcon IN cecred.crapcon.cdempcon%TYPE
                          ,pr_cdsegmto IN cecred.crapcon.cdsegmto%TYPE) IS
      SELECT arr.cdempres,
             arr.vltarifa_caixa,
             arr.vltarifa_internet,
             arr.vltarifa_taa
        FROM cecred.tbconv_arrecadacao arr
       WHERE arr.cdempcon = pr_cdempcon
         AND arr.cdsegmto = pr_cdsegmto;
    rw_conv_arrecad cr_conv_arrecad%ROWTYPE;

    -- Convênio Sicredi
    CURSOR cr_conv_rej (pr_cdempres in cecred.crapscn.cdempres%type) is
      SELECT scn.cdempcon,
             scn.cdsegmto,
             arr.cdempres,
             arr.vltarifa_caixa,
             arr.vltarifa_internet,
             arr.vltarifa_taa
        FROM cecred.crapscn scn,
             cecred.tbconv_arrecadacao arr
       WHERE UPPER(scn.cdempres) = pr_cdempres
         AND arr.cdempcon = scn.cdempcon
         AND arr.cdsegmto = scn.cdsegmto;
    rw_conv_rej cr_conv_rej%rowtype;

    -- Buscar pagamentos de convênios rejeitados no API Bancoob
    CURSOR cr_rejeicoes_bancoob (pr_cdcooper IN cecred.crapdat.cdcooper%TYPE
                                ,pr_dtmvtolt IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT reg.cdagenci            cdagenci,
             reg.cdempresa_documento cdempres,
             DECODE(reg.cdagenci,
                    90,NVL(ass.cdagenci,reg.cdagenci),
                    91,NVL(ass.cdagenci,reg.cdagenci),
                    reg.cdagenci) cdagenci_receita,
             (CASE
               WHEN NVL(tip.cdmodalidade_tipo,0) <> 4 AND ass.nrdconta IS NOT NULL THEN 1
               WHEN NVL(tip.cdmodalidade_tipo,0)  = 4 OR  ass.nrdconta IS NULL     THEN 2
               ELSE 0
              END) cdtipass
        FROM cecred.tbconv_remessa_pagfor rem,
             cecred.tbconv_registro_remessa_pagfor reg,
             cecred.tbcc_tipo_conta tip,
             cecred.crapass ass
       WHERE rem.dtmovimento            = pr_dtmvtolt
         AND rem.cdagente_arrecadacao   = 2 -- Bancoob
         AND reg.idremessa              = rem.idremessa
         AND reg.cdstatus_processamento = 4
         AND reg.cdcooper               = pr_cdcooper
         and ass.cdcooper           (+) = reg.cdcooper
         and ass.nrdconta           (+) = reg.nrdconta
         and tip.inpessoa           (+) = ass.inpessoa
         and tip.cdtipo_conta       (+) = ass.cdtipcta
    ORDER BY reg.cdagenci,
             reg.cdempresa_documento;
    rw_rejeicoes_bancoob cr_rejeicoes_bancoob%ROWTYPE;

    -- Lançamento de faturas do convênio bancoob
    CURSOR cr_craplft_bancoob
                       (pr_cdcooper in cecred.craplft.cdcooper%type,
                        pr_dtmvtolt in cecred.craplft.dtmvtolt%type,
                        pr_cdhistor in cecred.craplft.cdhistor%TYPE) is
      SELECT craplft.cdagenci,
         craplft.cdempcon,
         craplft.cdsegmto,
             LEAD (craplft.cdagenci,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proxima_agencia,
             LEAD (craplft.cdempcon,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proximo_cdempcon,
             LEAD (craplft.cdsegmto,1) OVER (ORDER BY craplft.cdempcon,
                                                      craplft.cdsegmto,
                                                      craplft.cdagenci) AS proximo_cdsegmto,
             DECODE(craplft.cdagenci,
                    90, nvl(crapass.cdagenci, craplft.cdagenci),
                    91, nvl(crapass.cdagenci, craplft.cdagenci),
                    craplft.cdagenci) cdagenci_fatura,
             COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN 1 ELSE NULL END) qtlanmto,
             COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0)  = 4 OR  crapass.nrdconta IS NULL     THEN 1 ELSE NULL END) qtlanmtoep,
             SUM(craplft.vllanmto) vllanmto
        FROM cecred.crapass,
             cecred.craplft,
             cecred.tbcc_tipo_conta
       WHERE craplft.cdcooper = pr_cdcooper
         AND craplft.dtmvtolt = pr_dtmvtolt
         AND craplft.cdhistor = pr_cdhistor
         AND crapass.cdcooper (+) = craplft.cdcooper
         AND crapass.nrdconta (+) = craplft.nrdconta
         AND tbcc_tipo_conta.inpessoa     (+) = crapass.inpessoa
         AND tbcc_tipo_conta.cdtipo_conta (+) = crapass.cdtipcta
    GROUP BY craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdagenci,
             NVL(crapass.cdagenci, craplft.cdagenci)
    ORDER BY craplft.cdempcon,
                craplft.cdsegmto,
          craplft.cdagenci;

    -- Lançamento de GPS do convênio bancoob
    CURSOR cr_craplgp_bancoob
                       (pr_cdcooper in cecred.craplgp.cdcooper%TYPE,
                        pr_dtmvtolt in cecred.craplgp.dtmvtolt%TYPE) is
      SELECT craplgp.cdagenci,
             LEAD(craplgp.cdagenci,1) OVER(ORDER BY craplgp.cdagenci) AS proxima_agencia,
             DECODE(craplgp.cdagenci,
                    90,NVL(crapass.cdagenci,craplgp.cdagenci),
                    91,NVL(crapass.cdagenci,craplgp.cdagenci),
                    craplgp.cdagenci) cdagenci_receita,
             COUNT(CASE WHEN NVL(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN 1 ELSE NULL END) qtlanmto,
             COUNT(CASE WHEN NVL(tbcc_tipo_conta.cdmodalidade_tipo,0)  = 4 OR  crapass.nrdconta IS NULL     THEN 1 ELSE NULL END) qtlanmtoep,
             SUM(craplgp.vlrtotal) vlrtotal
        FROM cecred.crapass,
             cecred.craplgp,
             cecred.tbcc_tipo_conta
       WHERE craplgp.cdcooper                 = pr_cdcooper
         AND craplgp.dtmvtolt                 = pr_dtmvtolt
         AND craplgp.cdbccxlt                 = 100
         AND craplgp.flgpagto                 = 1
         AND craplgp.idsicred                <> 0
         AND craplgp.flgativo                 = 1
         AND TRIM(craplgp.cdbarras) IS NOT NULL
         AND crapass.cdcooper             (+) = craplgp.cdcooper
         AND crapass.nrdconta             (+) = craplgp.nrctapag
         AND tbcc_tipo_conta.inpessoa     (+) = crapass.inpessoa
         AND tbcc_tipo_conta.cdtipo_conta (+) = crapass.cdtipcta
       GROUP BY craplgp.cdagenci,
                NVL(crapass.cdagenci,craplgp.cdagenci)
       ORDER BY craplgp.cdagenci;
      rw_craplgp_bancoob cr_craplgp_bancoob%ROWTYPE;

      cursor cr_principal (pr_cdcooper in cecred.craplft.cdcooper%type,
                         pr_dtmvtolt in cecred.craplft.dtmvtolt%type) is

               select SUM(pd.vllanmto) vllanmto
               from cecred.tbcc_prejuizo p,
                    cecred.tbcc_prejuizo_detalhe pd
               where p.cdcooper  = pd.cdcooper
               and   p.nrdconta  = pd.nrdconta
               AND   p.idprejuizo = pd.idprejuizo
               and   pd.cdcooper = pr_cdcooper
               and   pd.cdhistor IN(2408,2412)
               and   pd.dtmvtolt = pr_dtmvtolt
               and   p.incontabilizado = 0;

     rw_principal     cr_principal%rowtype;

   cursor cr_juros60 (pr_cdcooper in cecred.craplft.cdcooper%type,
                      pr_dtmvtolt in cecred.craplft.dtmvtolt%type) is

               select SUM(pd.vllanmto) vllanmto
               from cecred.tbcc_prejuizo p,
                    cecred.tbcc_prejuizo_detalhe pd
               where p.cdcooper  = pd.cdcooper
               and   p.nrdconta  = pd.nrdconta
               AND   p.idprejuizo = pd.idprejuizo
               and   pd.cdcooper = pr_cdcooper
               and   pd.cdhistor IN(2716,2717)
               and   pd.dtmvtolt = pr_dtmvtolt
               and   p.incontabilizado = 0;

    rw_juros60     cr_juros60%rowtype;

  --> Buscar os valores do historicos gerados nos detalhes da conta transitoria
      CURSOR cr_tbprejuizo_det (pr_cdcooper in cecred.craphis.cdcooper%type,
                                pr_dtmvtolt in cecred.craplcm.dtmvtolt%type,
                                pr_cdhistor in cecred.craphis.cdhistor%type) IS

        SELECT ass.cdagenci,
               COUNT(1) qtlanmto,
               SUM(pd.vllanmto) vllanmto
          FROM cecred.tbcc_prejuizo_detalhe pd,
               cecred.crapass ass
         WHERE pd.cdcooper = ass.cdcooper
           AND pd.nrdconta = ass.nrdconta
           AND pd.cdcooper = pr_cdcooper
           AND pd.cdhistor = pr_cdhistor
           AND pd.dtmvtolt = pr_dtmvtolt
         GROUP BY ass.cdagenci;

      CURSOR cr_craplcm_tdb(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                           ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                           ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                           ) IS
      SELECT tmp.cdagenci
            ,tmp.cdccuage
            ,tmp.vllanmto
      FROM  ( SELECT ass.cdagenci
                    ,age.cdccuage
                    ,SUM(lcm.vllanmto) vllanmto
              FROM   cecred.craplcm lcm
               INNER JOIN cecred.crapass ass ON (ass.nrdconta = lcm.nrdconta AND
                                          ass.cdcooper = lcm.cdcooper)
               INNER JOIN cecred.crapage age ON (age.cdagenci = ass.cdagenci AND
                                          age.cdcooper = lcm.cdcooper)
              WHERE  age.cdccuage  > 0
              AND    lcm.cdhistor  = pr_cdhistor
              AND    lcm.dtmvtolt >= pr_dtrefere
              AND    lcm.cdcooper  = pr_cdcooper
              GROUP  BY ass.cdagenci
                       ,ass.inpessoa
                       ,age.cdccuage

              UNION  ALL

              SELECT 999 cdagenci
                    ,0 cdccuage
                    ,SUM(lcm.vllanmto) vllanmto
              FROM   craplcm lcm
              WHERE  lcm.cdhistor  = pr_cdhistor
              AND    lcm.dtmvtolt >= pr_dtrefere
              AND    lcm.cdcooper  = pr_cdcooper
            ) tmp
      WHERE   tmp.vllanmto > 0
      ORDER  BY CASE WHEN tmp.cdagenci = 999 THEN 0
                     ELSE tmp.cdagenci END;

      -- Obter valores dos lançamentos da operação de crédito do desconto de títulos detalhados por Agencia-PA
      CURSOR cr_lancborage(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                          ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                          ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                          ) IS
      SELECT tmp.cdagenci
            ,tmp.cdccuage
            ,tmp.vllanmto
        FROM( SELECT ass.cdagenci
                    ,age.cdccuage
                    ,SUM(lcb.vllanmto) vllanmto
                FROM tbdsct_lancamento_bordero lcb
               INNER JOIN cecred.crapass ass ON (ass.nrdconta = lcb.nrdconta
                                      AND ass.cdcooper = lcb.cdcooper)
               INNER JOIN cecred.crapage age ON (age.cdagenci = ass.cdagenci
                                      AND age.cdcooper = lcb.cdcooper)
               WHERE age.cdccuage  > 0
                 AND lcb.cdhistor  = pr_cdhistor
                 AND lcb.dtmvtolt  = pr_dtrefere
                 AND lcb.cdcooper  = pr_cdcooper
               GROUP BY ass.cdagenci
                       ,age.cdccuage
            ) tmp
        WHERE tmp.vllanmto > 0
       ORDER  BY tmp.cdagenci;

      -- Obter valor total dos lançamentos da operação de crédito do desconto de títulos agrupados no Gerencial
      CURSOR cr_lancborger(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                          ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                          ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                          ) IS
      SELECT nvl(SUM(lcb.vllanmto),0) vllanmto
        FROM cecred.tbdsct_lancamento_bordero lcb
       WHERE lcb.cdhistor = pr_cdhistor
         AND lcb.dtmvtolt = pr_dtrefere
         AND lcb.cdcooper = pr_cdcooper;
      rw_lancborger cr_lancborger%ROWTYPE;

      -- Buscar valores aculumados de um determinado histórico da operação de crédito do borderô em aberto
      CURSOR cr_lancboracum(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                           ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                           ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                           ) IS
      SELECT ass.cdagenci
            ,ass.inpessoa
            ,age.cdccuage
            ,SUM(lcb.vllanmto) vllanmto
        FROM cecred.tbdsct_lancamento_bordero lcb
       INNER JOIN cecred.crapass ass ON (ass.nrdconta = lcb.nrdconta
                              AND ass.cdcooper = lcb.cdcooper)
       INNER JOIN cecred.crapage age ON (age.cdagenci = ass.cdagenci
                              AND age.cdcooper = lcb.cdcooper)
       INNER JOIN cecred.craptdb tdb ON (tdb.nrdocmto  = lcb.nrdocmto
                              AND tdb.nrcnvcob  = lcb.nrcnvcob
                              AND tdb.nrdctabb  = lcb.nrdctabb
                              AND tdb.cdbandoc  = lcb.cdbandoc
                              AND tdb.nrborder  = lcb.nrborder
                              AND tdb.nrdconta  = lcb.nrdconta
                              AND tdb.cdcooper  = lcb.cdcooper)
       INNER JOIN cecred.crapbdt bdt ON (bdt.nrborder  = lcb.nrborder
                              AND bdt.cdcooper  = lcb.cdcooper)
       WHERE bdt.inprejuz  = 0
         AND tdb.insittit  = 4
         AND lcb.cdhistor  = pr_cdhistor
         AND lcb.dtmvtolt <= pr_dtrefere
         AND lcb.cdcooper  = pr_cdcooper
       GROUP BY ass.cdagenci
               ,ass.inpessoa
               ,age.cdccuage
       ORDER BY ass.cdagenci;
     rw_lancboracum cr_lancboracum%ROWTYPE;

   -- Buscar valores aculumados de um determinado histórico da operação de crédito do borderô em aberto
      CURSOR cr_lancboracum2(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                           ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                           ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                           ) IS
      SELECT ass.cdagenci
            ,age.cdccuage
            ,SUM(lcb.vllanmto) vllanmto
        FROM cecred.tbdsct_lancamento_bordero lcb
       INNER JOIN cecred.crapass ass ON (ass.nrdconta = lcb.nrdconta
                              AND ass.cdcooper = lcb.cdcooper)
       INNER JOIN cecred.crapage age ON (age.cdagenci = ass.cdagenci
                              AND age.cdcooper = lcb.cdcooper)
       INNER JOIN cecred.craptdb tdb ON (tdb.nrdocmto  = lcb.nrdocmto
                              AND tdb.nrcnvcob  = lcb.nrcnvcob
                              AND tdb.nrdctabb  = lcb.nrdctabb
                              AND tdb.cdbandoc  = lcb.cdbandoc
                              AND tdb.nrborder  = lcb.nrborder
                              AND tdb.nrdconta  = lcb.nrdconta
                              AND tdb.cdcooper  = lcb.cdcooper)
       INNER JOIN cecred.crapbdt bdt ON (bdt.nrborder  = lcb.nrborder
                              AND bdt.cdcooper  = lcb.cdcooper)
       WHERE bdt.inprejuz  = 0
         AND tdb.insittit  = 4
         AND lcb.cdhistor  = pr_cdhistor
         AND lcb.dtmvtolt <= pr_dtrefere
         AND lcb.cdcooper  = pr_cdcooper
       GROUP BY ass.cdagenci
               ,age.cdccuage
       ORDER BY ass.cdagenci;
    rw_lancboracum2  cr_lancboracum2%ROWTYPE;

    CURSOR cr_prov_mes_38(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                         ,pr_dtiniper IN DATE
                         ,pr_dtfimper IN DATE) IS
      SELECT SUM(c.vllanmto) vllanmto
        FROM cecred.craplcm c
       WHERE c.cdcooper = pr_cdcooper
         AND c.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
         AND c.cdhistor = 38;

  ---Cursor com os lancamentos SEP do DIA ATUAL (pr_dtmvtolt), ate 21:45h - historicos: 2936,2937,2938 --(P513 - Saque e Pague)
    CURSOR cr_craplcm_sep1(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                          ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                           ) IS
      SELECT his.nrctadeb
            ,his.nrctacrd
            ,his.cdhstctb
            ,his.cdhistor
            ,his.dsexthst
            ,sum(lcm.vllanmto) vllanmto
        FROM cecred.craplcm lcm
            ,cecred.craphis his
       WHERE his.cdhistor  = lcm.cdhistor
         AND his.cdcooper  = lcm.cdcooper
         -- Adicionado o cdhistor = 3239 por Alexandre Girardi - P513
         AND lcm.cdhistor  IN (2936,2937,2938,3239)
         AND lcm.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
       GROUP BY his.nrctadeb
               ,his.nrctacrd
               ,his.cdhstctb
               ,his.cdhistor
               ,his.dsexthst;
    rw_craplcm_sep1 cr_craplcm_sep1%ROWTYPE;

  --Cursor com os lancamentos dos historicos 2967, 2968 e 2969, do DIA ATUAL  --(P513 - Saque e Pague)
    CURSOR cr_craplcm_sep2(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                          ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                           ) IS
      SELECT
             CASE lcm.cdhistor
               WHEN 2967  THEN his.nrctadeb
               WHEN 2968  THEN 4809 --conta transitoria
               WHEN 2969  THEN 1710
               WHEN 3241  then 1710
               ELSE 1710            --conta transitoria
             END               nrctadeb
            ,CASE lcm.cdhistor
               WHEN 2967  THEN 4809 --conta transitoria
               WHEN 2968  THEN his.nrctacrd
               WHEN 2969  THEN his.nrctacrd
               WHEN 3241  THEN his.nrctacrd
               ELSE his.nrctacrd
             END               nrctacrd
            ,his.cdhstctb
            ,his.cdhistor
            ,his.dsexthst
            ,sum(lcm.vllanmto) vllanmto
        FROM cecred.craplcm lcm
            ,cecred.craphis his
       WHERE his.cdhistor  = lcm.cdhistor
         AND his.cdcooper  = lcm.cdcooper
         -- Adicionado o cdhistor = 3241  por Alexandre Girardi - P513
         AND lcm.cdhistor  IN (2967,2968,2969,3241 )
         AND lcm.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
       GROUP BY CASE lcm.cdhistor
                  WHEN 2967  THEN his.nrctadeb
                  WHEN 2968  THEN 4809 --conta transitoria
                  WHEN 2969  THEN 1710
                  WHEN 3241  then 1710
                  ELSE 1710            --conta transitoria
                END
               ,CASE lcm.cdhistor
                  WHEN 2967  THEN 4809 --conta transitoria
                  WHEN 2968  THEN his.nrctacrd
                  WHEN 2969  THEN his.nrctacrd
                  WHEN 3241  THEN his.nrctacrd
                  ELSE his.nrctacrd
                END
               ,his.cdhstctb
               ,his.cdhistor
               ,his.dsexthst;
    rw_craplcm_sep2 cr_craplcm_sep2%ROWTYPE;

  --Cursor com os lancamentos dos historicos 2967, 2968 e 2969 do DIA ANTERIOR  --(P513 - Saque e Pague)
    CURSOR cr_craplcm_sep3(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                          ,pr_dtmvtoan cecred.craplcm.dtmvtolt%TYPE
                           ) IS
        SELECT lcm.dtmvtolt,
               his.cdhstctb,
               lcm.cdhistor,
               CASE lcm.cdhistor
                 WHEN 2967 THEN 4809 -- Saque
                 WHEN 2968 THEN 4957 -- Estorno Saque
                 WHEN 2969 THEN 4957 -- Deposito
                 WHEN 3241 THEN 4957 -- Deposito Varejista
                 ELSE 0
               END nrctadeb,
               CASE lcm.cdhistor
                 WHEN 2967 THEN 4957 -- Saque
                 WHEN 2968 THEN 4809 -- Estorno Saque
                 WHEN 2969 THEN 1710 -- Deposito
                 WHEN 3241 THEN 1710 -- Deposito Varejista
                 ELSE 0
               END nrctacrd,
               CASE lcm.cdhistor
                 -- Saque
                 WHEN 2967 THEN
                   'ACERTO DE SAQUE REALIZADO NO DIA ANTERIOR APOS 21:45 - SAQUE E PAGUE'
                 -- Estorno Saque
                 WHEN 2968 THEN
                   'ACERTO DE ESTORNO SAQUE REALIZADO NO DIA ANTERIOR APOS 21:45 - SAQUE E PAGUE'
                 -- Deposito
                 WHEN 2969 THEN
                   'ACERTO DE DEPOSITO REALIZADO NO DIA ANTERIOR APOS 21:45 - SAQUE E PAGUE'
                 -- Deposito Varejista
                 WHEN 3241 THEN
                   'ACERTO DE DEPOSITO REALIZADO NO DIA ANTERIOR APOS 21:45 - SAQUE E PAGUE VAREJISTA'
                 ELSE ''
               END dsexthst,
               sum(lcm.vllanmto) vllanmto
          FROM cecred.craplcm lcm, cecred.craphis his
         WHERE his.cdhistor = lcm.cdhistor
           AND his.cdcooper = lcm.cdcooper
              -- Adicionado o cdhistor = 3241  por Alexandre Girardi - P513
           AND lcm.cdhistor IN (2967, 2968, 2969, 3241)
           AND lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtoan -- DIA ANTERIOR
         GROUP BY lcm.dtmvtolt, lcm.cdhistor, his.cdhstctb;

    rw_craplcm_sep3 cr_craplcm_sep3%ROWTYPE;

  ---Cursor com os lancamentos SEP agrupados das cooperativas na central - historicos: 2939,2940,2941 --(P513 - Saque e Pague)
    CURSOR cr_craplcm_sep4(pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                           ) IS
      SELECT his.nrctadeb
            ,his.nrctacrd
            ,his.cdhstctb
            ,his.dsexthst
            ,his.cdhistor
            ,sum(lcm.vllanmto) vllanmto
        FROM cecred.craplcm lcm
            ,cecred.crapcop cop
            ,cecred.craphis his
       WHERE lcm.nrdconta = cop.nrctactl
         and his.cdhistor = lcm.cdhistor
         and his.cdcooper = cop.cdcooper
         AND lcm.cdcooper = 3
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.vllanmto > 0
         -- Adicionado o cdhistor 3240 por Alexandre Girardi - P513
         AND lcm.cdhistor IN (2939,2940,2941,3240)
    GROUP BY his.nrctadeb
            ,his.nrctacrd
            ,his.cdhstctb
            ,his.dsexthst
            ,his.cdhistor;
    rw_craplcm_sep4 cr_craplcm_sep4%ROWTYPE;

    --Cursor com os lancamentos SEP da cooperativa na central - historicos: 2939,2940,2941    --(P513 - Saque e Pague)
    CURSOR cr_craplcm_sep5(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                          ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE
                          ,pr_cdhistor cecred.craplcm.cdhistor%TYPE
                           ) IS
      SELECT SUM(lcm.vllanmto) vllanmto
            ,lcm.cdhistor
            ,his.dsexthst
        FROM cecred.craplcm lcm
            ,cecred.crapcop cop
            ,cecred.craphis his
       WHERE lcm.nrdconta = cop.nrctactl
         and his.cdhistor = lcm.cdhistor
         and his.cdcooper = cop.cdcooper
         and cop.cdcooper = pr_cdcooper
         AND lcm.cdcooper = 3
         AND lcm.nrdconta = cop.nrctactl
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.vllanmto > 0
         AND lcm.cdhistor = pr_cdhistor
    GROUP BY lcm.cdhistor
            ,his.dsexthst;
    rw_craplcm_sep5 cr_craplcm_sep5%ROWTYPE;

    --Cursor dos historicos SEP da cooperativa na Central
    CURSOR cr_craphis3 IS
      SELECT his.cdhistor
        FROM cecred.craphis his
       -- Adicionado o cdhistor 3240 por Alexandre Girardi - P513
       WHERE his.cdhistor IN (2939,2940,2941,3240)
       GROUP BY his.cdhistor
       ORDER BY his.cdhistor;
    rw_craphis3 cr_craphis3%ROWTYPE;

    -- Cursor Arrecadacao de Consrocio
    CURSOR cr_craplcm_cns(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                         ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
      SELECT SUM(lcm.vllanmto) vllanmto,
             his.cdhstctb,
             '" ARRECADACAO (' || his.cdhistor || ') ' || his.dsexthst || '"' dshistor,
             (CASE his.cdhistor
               WHEN  1230 THEN 4993
               WHEN  1231 THEN 4994
               WHEN  1232 THEN 4996
               WHEN  1233 THEN 4997
               WHEN  1234 THEN 4998
               WHEN  2027 THEN 4909
             END) nrctatrd
     FROM cecred.craplcm lcm,
          cecred.craphis his
    WHERE lcm.cdcooper = pr_cdcooper
      AND lcm.dtmvtolt = pr_dtmvtolt
      AND lcm.cdhistor IN(1230,1231,1232,1233,1234,2027)
      AND his.cdcooper = lcm.cdcooper
      AND his.cdhistor = lcm.cdhistor
    GROUP BY his.cdhstctb, his.cdhistor, his.dsexthst
    ORDER BY his.cdhistor;
    rw_craplcm_cns cr_craplcm_cns%ROWTYPE;

    -- Estorno de seguro prestamista
    CURSOR cr_craplcm_prst_1(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                            ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
    SELECT '50' || to_char(lcm.dtmvtolt, 'rrmmdd') || ',' ||
         to_char(lcm.dtmvtolt, 'ddmmrr') || ',' || his.nrctadeb || ',' ||
         his.nrctacrd || ',' ||
         trim(to_char(SUM(lcm.vllanmto), '99999999999990.00')) || ',' ||
         trim(to_char(his.cdhstctb)) || ',' || '" (' || his.cdhistor || ') ' ||
         his.dsexthst || '"' linha_titulo,
         SUM(lcm.vllanmto) vllanmto,
         his.cdhistor
    FROM cecred.craplcm lcm, cecred.craphis his, cecred.crapass ass
   WHERE lcm.cdcooper = pr_cdcooper
     AND lcm.dtmvtolt = pr_dtmvtolt
     AND lcm.cdhistor = 3852
     and ass.cdcooper = lcm.cdcooper
     and ass.nrdconta = lcm.nrdconta
     AND his.cdcooper = lcm.cdcooper
     AND his.cdhistor = lcm.cdhistor
   GROUP BY lcm.dtmvtolt,
            his.nrctadeb,
            his.nrctacrd,
            his.cdhstctb,
            his.cdhistor,
            his.dsexthst
  ORDER BY 1;
    rw_craplcm_prst_1 cr_craplcm_prst_1%ROWTYPE;

    -- Estorno de seguro prestamista
    CURSOR cr_craplcm_prst_2(pr_cdcooper cecred.craplcm.cdcooper%TYPE
                            ,pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
    SELECT to_char(lcm.cdagenci,'fm000') ||
           ','|| trim(to_char(SUM(lcm.vllanmto), '999999999990.00')) linha_pa
      FROM cecred.craplcm lcm, cecred.craphis his
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lcm.cdhistor = 3852
       AND his.cdcooper = lcm.cdcooper
       AND his.cdhistor = lcm.cdhistor
     GROUP BY lcm.cdagenci
    ORDER BY lcm.cdagenci;
    rw_craplcm_prst_2 cr_craplcm_prst_2%ROWTYPE;

    cursor cr_craplcm_cnv085 (pr_dtmvtolt in cecred.crapdat.dtmvtolt%type) is
      SELECT '50'||
         to_char(lcm.dtmvtolt,'ddmmrr')||','||
         to_char(lcm.dtmvtolt,'ddmmrr')||','||
         his.nrctadeb||','||
         his.nrctacrd||','||
         trim(to_char(SUM(lcm.vllanmto), '99999999999990.00')) ||','||
         trim(to_char(his.cdhstctb))||','||
         '" (' || his.cdhistor || ') ' || his.dsexthst || ' - ' || nve.nmempres || '"' linha
     FROM cecred.craplcm lcm,
          cecred.craphis his,
          cecred.gnconve nve
    WHERE lcm.cdcooper = 3
      AND lcm.dtmvtolt = pr_dtmvtolt
      AND lcm.cdhistor IN(3044,3045,3046)
      AND his.cdcooper = lcm.cdcooper
      AND his.cdhistor = lcm.cdhistor
      AND nve.cdconven = lcm.dsidenti
      AND nve.flgativo = 1
    GROUP BY his.cdhstctb, his.cdhistor, his.dsexthst, nve.nmempres,his.nrctadeb,his.nrctacrd,dtmvtolt
    ORDER BY his.cdhistor;

    cursor cr_craplcm_repasse_cnv085 (pr_cdcooper in cecred.crapcop.cdcooper%type
                                     ,pr_dtmvtolt in cecred.crapdat.dtmvtolt%type) is
      SELECT '50'||
         to_char(lcm.dtmvtolt,'ddmmrr')||','||
         to_char(lcm.dtmvtolt,'ddmmrr')||','||
         his.nrctadeb||','||
         his.nrctacrd||','||
         trim(to_char(SUM(lcm.vllanmto), '99999999999990.00')) ||','||
         trim(to_char(his.cdhstctb))||','||
         '" (' || his.cdhistor || ') ' || his.dsexthst || '"' linha,
         SUM(lcm.vllanmto) vllanmto
     FROM cecred.craplcm lcm,
          cecred.craphis his
    WHERE lcm.cdcooper = pr_cdcooper
      AND lcm.dtmvtolt = pr_dtmvtolt
      AND lcm.cdhistor = 3049
      AND his.cdcooper = lcm.cdcooper
      AND his.cdhistor = lcm.cdhistor
    GROUP BY his.cdhstctb, his.cdhistor, his.dsexthst,his.nrctadeb,his.nrctacrd,dtmvtolt
    ORDER BY his.cdhistor;

    --
    -- Inicio PIX
    vr_cdhstctb             cecred.craphis.cdhstctb%type;
    --
    -- Cursor das transacoes PIX com datas diferentes do BACEN
    CURSOR cr_craplcm_pix(pr_repasse in integer,
                          pr_dtmvtolt cecred.craplcm.dtmvtolt%TYPE) IS
      WITH LancamentosPix AS
        (SELECT lcm.nrdocmto
              ,lcm.dtmvtolt
              ,lcm.cdhistor
              ,lcm.vllanmto
          FROM cecred.craplcm lcm
          INNER JOIN cecred.crapcop cop
            ON lcm.cdcooper = cop.cdcooper
            -- Recebimento, Devolucoes de Recebimentos, Pagamento, Recebimento de Devolucoes
            -- Pag. Pix Cobrança, Dev. Rec. Pix Cob.
            -- Devolucao Bloqueio Cautelar (3892,3896,3898)
          WHERE lcm.cdhistor IN (3318, 3319, 3320, 3321, 3450, 3451, 3671, 3673, 3892, 3896, 3898)
            AND lcm.dtmvtolt BETWEEN pr_dtmvtolt AND gene0005.fn_valida_dia_util(pr_cdcooper => 3, pr_dtmvtolt => pr_dtmvtolt+1)),
      TransacaoFasePix AS
       (SELECT *
          FROM (SELECT fase.idtransacao
                      ,fase.idfase
                      ,TRUNC(fase.dhfase) data_fase
                  FROM LancamentosPix lcm
                 INNER JOIN pix.tbpix_transacao_fase fase
                    ON lcm.nrdocmto = fase.idtransacao
                 WHERE idfase IN (1, 5, 7, 11, 14))
        PIVOT(MIN(data_fase)
           FOR idfase IN(1 AS fase1, 5 AS fase5, 7 AS fase7, 11 AS fase11, 14 AS fase14)))
          -- fase1 - Registro PSP Pagador (3318, 3321, 3451)
          -- fase5 - Registro Debito em Conta (3319, 3320, 3450, 3673)
          -- fase7 - Registro API Transacional (3318, 3321, 3451,3671)
          -- fase11 - Estorno de debito nao confirmado (3319 -> 3323; 3320 -> 3322, 3323; 3450 -> 3452, 3453)
          -- fase14 - Efetivacao BACEN (3319, 3320, 3450)
      SELECT lcm.cdhistor
             -- Históricos:
             -- 3318, 3321, 3451,3671 (Fase 1 -> Fase 7)
             -- Descricao maxima 100 caracteres
            ,CASE
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3318) THEN 'SUA REMESSA PAGAMENTOS INSTANTANEOS - PIX - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3321) THEN 'DEVOLUCAO RECEBIDA PAGAMENTOS INSTANTANEOS - PIX - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3451) THEN 'DEVOLUÇÃO RECEBIDA PGTOS INSTANTANEOS - PIX COBRANCA - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3671) THEN 'SUA REMESSA PAGAMENTOS INSTANTANEOS - PIX COBRANCA - A REPASSAR EM D1'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3318) THEN 'REPASSE SUA REMESSA PAGAMENTOS INSTANTANEOS - PIX REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3321) THEN 'REPASSE DEVOLUCAO RECEBIDA PAGAMENTOS INSTANTANEOS - PIX REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3451) THEN 'REPASSE DEVOLUCAO RECEBIDA PGTOS INSTANTANEOS - PIX COBRANCA REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3671) THEN 'SUA REMESSA PAGAMENTOS INSTANTANEOS - PIX COBRANCA REF. DATA ANTERIOR'
               ELSE '***'
             END AS detalhe
            ,SUM(lcm.vllanmto) vllanmto
        FROM LancamentosPix lcm
       INNER JOIN TransacaoFasePix transacao
          ON lcm.nrdocmto = transacao.idtransacao
       WHERE transacao.fase1 = pr_dtmvtolt
         AND transacao.fase7 > pr_dtmvtolt
       GROUP BY lcm.cdhistor, 2
      UNION
      SELECT lcm.cdhistor
             -- Históricos:
             -- 3319, 3320, 3450, 3673 (Fase 5 -> Fase 14)
             -- Descricao maxima 100 caracteres
             ,CASE
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3319) THEN 'DEVOLUCAO REMETIDA PAGAMENTOS INSTANTANEOS - PIX - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3320) THEN 'NOSSA REMESSA PAGAMENTOS INSTANTANEOS - PIX - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3450) THEN 'NOSSA REMESSA PGTOS INSTANTANEOS - PIX COBRANCA - A REPASSAR EM D1'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3673) THEN 'DEVOLUCAO REM PGTOS INSTANTANEOS - PIX COBRANCA - A REPASSAR EM D1'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3319) THEN 'REPASSE DEVOLUCAO REMETIDA PAGAMENTOS INSTANTANEOS - PIX REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3320) THEN 'REPASSE NOSSA REMESSA PAGAMENTOS INSTANTANEOS - PIX REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3450) THEN 'REPASSE NOSSA REMESSA PGTOS INSTANTANEOS - PIX COBRANCA REF. DATA ANTERIOR'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3673) THEN 'DEVOLUCAO REM PGTOS INSTANTANEOS - PIX COBRANCA COBRANCA REF. DATA ANTERIOR'
               WHEN (pr_repasse = 0 AND lcm.cdhistor = 3892) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3892) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
         WHEN (pr_repasse = 0 AND lcm.cdhistor = 3896) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 3896) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
         WHEN (pr_repasse = 0 AND lcm.cdhistor = 4229) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
               WHEN (pr_repasse = 1 AND lcm.cdhistor = 4229) THEN 'DEVOLUCAO REMETIDA BLOQUEIO CAUTELAR - PIX'
               ELSE '...'
             END AS detalhe
            ,SUM(lcm.vllanmto)
        FROM LancamentosPix lcm
       INNER JOIN TransacaoFasePix transacao
          ON lcm.nrdocmto = transacao.idtransacao
       WHERE transacao.fase5 = pr_dtmvtolt
         AND transacao.fase14 > pr_dtmvtolt
       GROUP BY cdhistor, 2
       UNION
       SELECT cdhistor, detalhe, sum(vllanmto) FROM (
         SELECT -1 as cdhistor
            -- Históricos:
            -- 3319, 3320, 3450, 3673 (Fase 5 -> Fase 11)
            -- Descricao maxima 100 caracteres
            ,CASE
               WHEN (pr_repasse = 0 AND (lcm.cdhistor = 3319 OR lcm.cdhistor = 3320)) THEN 'NOSSA REMESSA/DEV REMETIDA PAGAMENTOS INSTANTANEOS - PIX - ESTORNADO EM D1'
               WHEN (pr_repasse = 1 AND (lcm.cdhistor = 3319 OR lcm.cdhistor = 3320)) THEN 'ESTORNO NOSSA REMESSA/DEV REMETIDA PAGAMENTOS INSTANTANEOS - PIX REF. DATA ANTERIOR'
               WHEN (pr_repasse = 0 AND (lcm.cdhistor = 3673 OR lcm.cdhistor = 3450)) THEN 'NOSSA REMESSA PGTOS INST./DEVOLUCAO REM PGTOS INST. - PIX COBRANCA - ESTORNADO EM D1'
               WHEN (pr_repasse = 1 AND (lcm.cdhistor = 3673 OR lcm.cdhistor = 3450)) THEN 'ESTORNO NOSSA REMESSA PGTOS INST./DEVOLUCAO REM PGTOS INST. - PIX COBRANCA REF. DATA ANTERIOR'
               ELSE '---'
             END AS detalhe
            ,lcm.vllanmto
         FROM LancamentosPix lcm
         INNER JOIN TransacaoFasePix transacao
               ON lcm.nrdocmto = transacao.idtransacao
         WHERE transacao.fase5 = pr_dtmvtolt
           AND transacao.fase11 > pr_dtmvtolt
         )
       GROUP BY cdhistor, detalhe;
    --
    -- Fim PIX


    -- Lançamento de Tributos e repasse do convênio ao RFB
    CURSOR cr_crapscn4(pr_cdempcon IN cecred.crapscn.cdempcon%TYPE,
                       pr_cdsegmto IN cecred.crapscn.cdsegmto%TYPE) is
      SELECT crapscn.cdempres, crapscn.dsnomres
        FROM cecred.crapscn
       WHERE crapscn.cdempcon = pr_cdempcon
         AND crapscn.cdsegmto = to_char(pr_cdsegmto)
         AND crapscn.dsoparre <> 'E'
         AND crapscn.cdempres IN ('D0064','D0385','D0153','D0100','G0270','D0328','D0432');
    rw_crapscn4     cr_crapscn4%rowtype;


    CURSOR cr_craplft_rfb
                       (pr_cdcooper in cecred.craplft.cdcooper%type,
                        pr_dtmvtolt in cecred.craplft.dtmvtolt%type) is
      SELECT craplft.cdempcon,
             craplft.cdsegmto,
             craplft.cdhistor,
             craplft.cdagenci,
             LEAD (craplft.cdempcon,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto,craplft.cdhistor,craplft.cdagenci) AS proximo_cdempcon,
             LEAD (craplft.cdsegmto,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto,craplft.cdhistor,craplft.cdagenci) AS proximo_cdsegmto,
             LEAD (craplft.cdhistor,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto,craplft.cdhistor,craplft.cdagenci) AS proxima_historico,
             LEAD (craplft.cdagenci,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto,craplft.cdhistor,craplft.cdagenci) AS proxima_agencia,
             DECODE(craplft.cdagenci,
                    90, nvl(crapass.cdagenci, craplft.cdagenci),
                    91, nvl(crapass.cdagenci, craplft.cdagenci),
                    craplft.cdagenci) cdagenci_fatura,
             COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN 1 ELSE NULL END) qtlanmto,
             COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0)  = 4 OR  crapass.nrdconta IS NULL THEN 1 ELSE NULL END) qtlanmtoep,
             COUNT(CASE WHEN (nvl(tbcc_tipo_conta.cdmodalidade_tipo,0)  = 4 OR  crapass.nrdconta IS NULL) AND tbconv_registro_remessa_pagfor.cdstatus_processamento < 4 THEN 1 ELSE NULL END) qtlanmtoep2,
             SUM(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL  THEN (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros) ELSE 0 END) vllanmto,
             SUM(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 OR crapass.nrdconta IS NULL  THEN (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros) ELSE 0 END) vllanmtoep,
             SUM(CASE WHEN (nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 OR crapass.nrdconta IS NULL) AND tbconv_registro_remessa_pagfor.cdstatus_processamento < 4  THEN (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros) ELSE 0 END) vllanmtoep2
        FROM cecred.crapass,
             cecred.craplft,
             cecred.tbcc_tipo_conta,
             cecred.tbconv_registro_remessa_pagfor
       WHERE craplft.cdcooper = pr_cdcooper
         AND craplft.dtmvtolt = pr_dtmvtolt
         AND craplft.cdhistor IN (3464,3465)
         AND crapass.cdcooper (+) = craplft.cdcooper
         AND crapass.nrdconta (+) = craplft.nrdconta
         AND tbcc_tipo_conta.inpessoa     (+) = crapass.inpessoa
         AND tbcc_tipo_conta.cdtipo_conta (+) = crapass.cdtipcta
         AND tbconv_registro_remessa_pagfor.idsicredi = craplft.idsicred
         AND tbconv_registro_remessa_pagfor.cdstatus_processamento IN (2,3,4)
       GROUP BY craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdhistor,
                craplft.cdagenci,
                crapass.cdagenci,
                NVL(crapass.cdagenci, craplft.cdagenci)
       ORDER BY craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdhistor,
                craplft.cdagenci,
                crapass.cdagenci;
      rw_craplft_rfb cr_craplft_rfb%ROWTYPE;

    CURSOR cr_rejeitado_rfb (pr_cdcooper in cecred.craplcm.cdcooper%type,
                             pr_dtmvtolt in cecred.craplcm.dtmvtolt%type) is
      SELECT (CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN 1 ELSE 0 END) qtlanmto,
             (CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 OR crapass.nrdconta IS NULL       THEN 1 ELSE 0 END) qtlanmtoep,
             (CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN craplcm.vllanmto ELSE 0 END) vllanmto,
             (CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) = 4 OR crapass.nrdconta IS NULL       THEN craplcm.vllanmto ELSE 0 END) vllanmtoep,
             craplft.cdhistor,
             craplft.cdempcon,
             craplft.cdsegmto,
             craplft.cdagenci,
             DECODE(craplft.cdagenci,
                    90, nvl(crapass.cdagenci, craplft.cdagenci),
                    91, nvl(crapass.cdagenci, craplft.cdagenci),
                    craplft.cdagenci) cdagenci_fatura
        FROM cecred.crapass,
             cecred.craplcm,
             cecred.craplft,
             cecred.tbcc_tipo_conta,
             cecred.tbconv_registro_remessa_pagfor
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor = 3466
         AND craplft.idsicred = craplcm.nrdocmto
         AND crapass.cdcooper (+) = craplcm.cdcooper
         AND crapass.nrdconta (+) = craplcm.nrdconta
         AND tbcc_tipo_conta.inpessoa     (+) = crapass.inpessoa
         AND tbcc_tipo_conta.cdtipo_conta (+) = crapass.cdtipcta
         AND tbconv_registro_remessa_pagfor.idsicredi = craplft.idsicred
         AND tbconv_registro_remessa_pagfor.cdstatus_processamento IN (2,3,4);
      rw_rejeitado_rfb cr_rejeitado_rfb%ROWTYPE;

    CURSOR cr_tarifa_central (pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
      SELECT craplft.cdempcon,
             craplft.cdsegmto,
             craplft.cdhistor,
             (crapthi.vltarifa * COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0) <> 4 AND crapass.nrdconta IS NOT NULL THEN 1 ELSE NULL END)) +
             (crapthi.vltarifa * COUNT(CASE WHEN nvl(tbcc_tipo_conta.cdmodalidade_tipo,0)  = 4 OR  crapass.nrdconta IS NULL THEN 1 ELSE NULL END)) vltarifa,
             LEAD (craplft.cdempcon,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto) AS proximo_cdempcon,
             LEAD (craplft.cdsegmto,1) OVER (ORDER BY craplft.cdempcon,craplft.cdsegmto) AS proximo_cdsegmto
        FROM cecred.craplft,
             cecred.tbcc_tipo_conta,
             cecred.tbconv_registro_remessa_pagfor,
             cecred.crapthi,
             cecred.crapass
       WHERE craplft.dtmvtolt = pr_dtmvtolt
         AND craplft.cdhistor IN (3464,3465)
         AND crapass.cdcooper (+) = craplft.cdcooper
         AND crapass.nrdconta (+) = craplft.nrdconta
         AND tbcc_tipo_conta.inpessoa     (+) = crapass.inpessoa
         AND tbcc_tipo_conta.cdtipo_conta (+) = crapass.cdtipcta
         AND tbconv_registro_remessa_pagfor.idsicredi = craplft.idsicred
         AND tbconv_registro_remessa_pagfor.cdstatus_processamento IN (2,3)
         AND crapthi.cdcooper = craplft.cdcooper
         AND crapthi.cdhistor = craplft.cdhistor
         AND crapthi.dsorigem = decode(craplft.cdagenci,90,'INTERNET',91,'TAA','CAIXA')
       GROUP BY craplft.cdempcon,
                craplft.cdsegmto,
                craplft.cdhistor,
                crapthi.vltarifa
       ORDER BY craplft.cdempcon;
     rw_tarifa_central cr_tarifa_central%ROWTYPE;

    --Cursor para buscar os dados do histórico, para gerar o lançamento 02
    --para os historicos (3719,3735,3736, 3739 e 3741) --PJ23311
    CURSOR cr_craphis4 (pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                       ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE) IS
      SELECT h.cdhistor, h.dsexthst, h.nrctadeb, h.nrctacrd
        FROM cecred.craphis h
       WHERE h.cdhistor = pr_cdhistor
         AND h.cdcooper = pr_cdcooper;
    rw_craphis4 cr_craphis4%ROWTYPE;

    --Cursor para buscar os dados do histórico, para gerar o lançamento 03
    --para os historicos (3719,3735,3736, 3739 e 3741) --PJ23311
    CURSOR cr_craphis5 (pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
      select lcm.cdhistor
            ,cop.nrctactl
            ,his.cdhstctb
            ,SUM(lcm.vllanmto) vllanmto
        from cecred.crapcop cop
            ,cecred.craplcm lcm
            ,cecred.craphis his
       where cop.cdcooper = pr_cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND his.cdcooper = lcm.cdcooper
         and lcm.nrdconta = cop.nrctactl
         and lcm.cdhistor IN (3719, 3741, 3739, 3735 , 3736, 3926, 3930, 3940, 3976, 3977, 3978, 3979, 3981, 3984, 4115, 4116, 4119, 4246, 4247, 4274, 4275)
         and lcm.dtmvtolt = pr_dtmvtolt
         and lcm.cdcooper = 3
         GROUP BY cop.nrctactl,lcm.cdhistor,his.cdhstctb
         ORDER BY lcm.cdhistor;
    rw_craphis5 cr_craphis5%ROWTYPE;

    --Cursor para buscar os valores de recebimento recursos funding - Imobiliario
    --para os historicos (3976,3977,3978,3979)) --PJ23311
    CURSOR cr_craphis6 (pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
      select NVL(SUM(lcm.vllanmto),0) vllanmto
        from cecred.craplcm lcm
            ,cecred.craphis his
       where his.cdhistor = lcm.cdhistor
         AND his.cdcooper = lcm.cdcooper
         and lcm.cdhistor IN (3976,3977,3978,3979)
         and lcm.dtmvtolt = pr_dtmvtolt
         and lcm.cdcooper = pr_cdcooper;
    rw_craphis6 cr_craphis6%ROWTYPE;

    -- Cursor busca a soma total de lancamentos por historico
    CURSOR cr_craphisttlvlr (pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                            ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE
                            ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
      select NVL(SUM(lcm.vllanmto),0) vllanmto
        from cecred.craplcm lcm
            ,cecred.craphis his
       where his.cdhistor = lcm.cdhistor
         AND his.cdcooper = lcm.cdcooper
         and lcm.cdhistor = pr_cdhistor
         and lcm.dtmvtolt = pr_dtmvtolt
         and lcm.cdcooper = pr_cdcooper;
    rw_craphisttlvlr cr_craphisttlvlr%ROWTYPE;

    --PRJ0023580
    cursor cr_bloqueio_pix(pr_cdcooper in cecred.crapcop.cdcooper%type) is
      select aux_blq.inpessoa
           , lpad(aux_blq.cdagenci,3,'0') cdagenci
           , aux_blq.vlbloqueado
           , sum(aux_blq.vlbloqueado) over (partition by aux_blq.inpessoa) vltotal
           , row_number() over (partition by aux_blq.inpessoa order by aux_blq.inpessoa, aux_blq.cdagenci) row_number
        from (select decode(ass.inpessoa,1,'PF','PJ') inpessoa
                   , ass.cdagenci
                   , sum(vlbloqueado) vlbloqueado
                from cecred.crapass ass
                   , contacorrente.tbcc_solicitacao_bloqueio blq
               where ass.cdcooper = blq.cdcooper
                 and ass.nrdconta = blq.nrdconta
                 and blq.instatus = 0
                 and blq.cdcooper = pr_cdcooper
               group
                  by decode(ass.inpessoa,1,'PF','PJ')
                   , ass.cdagenci) aux_blq
       order
          by 1,2;

    CURSOR cr_craphis7 (pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN cecred.craplcm.dtmvtolt%TYPE) IS
      select lcm.cdhistor
            ,cop.nrctactl
            ,his.cdhstctb
            ,his.dsexthst
            ,his.nrctadeb
            ,his.nrctacrd
            ,SUM(lcm.vllanmto) vllanmto
        from cecred.crapcop cop
            ,cecred.craplcm lcm
            ,cecred.craphis his
       where cop.cdcooper = pr_cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND his.cdcooper = lcm.cdcooper
         and lcm.nrdconta = cop.nrctactl
         and lcm.cdhistor = 4094
         and lcm.dtmvtolt = pr_dtmvtolt
         and lcm.cdcooper = 3
         GROUP BY cop.nrctactl,lcm.cdhistor,his.cdhstctb,his.dsexthst,his.nrctadeb,his.nrctacrd
         ORDER BY lcm.cdhistor;
    rw_craphis7 cr_craphis7%ROWTYPE;

    --Pegar lançamentos dos históricos 4145 e 4146 - PRJ0023922
    CURSOR cr_lancamentos_intrafiliadas(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN DATE) IS
        SELECT l.cdhistor,
               l.dtmvtolt,
               l.nrdconta,
               substr(l.nrdconta,1,length(l.nrdconta) -1)||'-'||substr(l.nrdconta,-1,1) nrctafmt,
               SUM(l.vllanmto) vllanmto
          FROM cecred.craplcm l,
               cecred.crapcop c
         WHERE l.nrdconta = c.nrctactl
           AND l.cdhistor IN (4145,4146)
           AND l.cdcooper = 3   --Apenas lançamentos realizados na central para a filiada
           AND l.dtmvtolt = pr_dtmvtolt
           AND c.cdcooper = pr_cdcooper --cooperativa filiada
        GROUP BY l.cdhistor,
                 l.dtmvtolt,
                 l.nrdconta,
                 substr(l.nrdconta,1,length(l.nrdconta) -1)||'-'||substr(l.nrdconta,-1,1)
        ORDER BY l.cdhistor;
    CURSOR cr_inadimplentes(pr_cdcooper in cecred.crapcop.cdcooper%TYPE,
                            pr_dtmvtolt in cecred.craplau.dtmvtolt%TYPE) IS
      SELECT '55' || to_char(pr_dtmvtolt, 'rrmmdd') || ',' ||
             to_char(pr_dtmvtolt, 'ddmmrr') || ',' || 8703 || ',' ||
             1890 || ',' ||
             trim(to_char(SUM(x.vllanaut), '99999999999990.00')) || ',' ||
             5210 || ',' ||
             '"VALOR REF. SEGURO PRESTAMISTA CONTRIBUTARIO NAO DEBITADO EM CONTA CORRENTE BAIXADO DEVIDO AO PRAZO DE 180 DIAS"'  linha_titulo, SUM(x.vllanaut) total
        FROM cecred.tbseg_prestamista p,
             cecred.craplau x
       WHERE p.cdcooper = pr_cdcooper
         AND x.insitlau IN (1, 3)
         AND x.cdhistor = 4228
         AND x.cdcooper = p.cdcooper
         AND x.nrdconta = p.nrdconta
         AND x.nrctremp = p.nrctremp
         AND x.cdseqtel = p.nrproposta
         AND p.tpcustei = 0
         AND p.tpregist IN (1,3)
         AND p.dtbaixacontab = pr_dtmvtolt
         --AND TRUNC(SYSDATE) - x.dtmvtolt >= cecred.gene0001.fn_param_sistema('CRED', 0, 'DIAS_MAX_REPIQUE_SEGPRE')-- inadimplentes acima de 180 dias
        ORDER BY x.dtmvtolt;
    rw_inadimplentes cr_inadimplentes%ROWTYPE;

    CURSOR cr_inadimplentes_pa(pr_cdcooper in cecred.crapcop.cdcooper%TYPE,
                               pr_dtmvtolt in cecred.craplau.dtmvtolt%TYPE) IS
      SELECT to_char(x.cdagenci,'fm000') ||
             ','|| trim(to_char(SUM(x.vllanaut), '999999999990.00')) linha_pa, SUM(x.vllanaut) total
        FROM cecred.tbseg_prestamista p,
             cecred.craplau x
       WHERE p.cdcooper = pr_cdcooper
         AND x.insitlau IN (1, 3)
         AND x.cdhistor = 4228
         AND x.cdcooper = p.cdcooper
         AND x.nrdconta = p.nrdconta
         AND x.nrctremp = p.nrctremp
         AND x.cdseqtel = p.nrproposta
         AND p.tpcustei = 0
         AND p.tpregist IN (1,3)
         AND p.dtbaixacontab = pr_dtmvtolt
         --AND TRUNC(SYSDATE) - x.dtmvtolt >= cecred.gene0001.fn_param_sistema('CRED', 0, 'DIAS_MAX_REPIQUE_SEGPRE') -- inadimplentes acima de 180 dias
       GROUP BY x.cdagenci
       ORDER by x.cdagenci;
    rw_inadimplentes_pa cr_inadimplentes_pa%ROWTYPE;

    CURSOR cr_seguros_inadimplentes(pr_cdcooper in cecred.crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt in cecred.craplau.dtmvtolt%TYPE) IS
      SELECT x.dtmvtolt
            ,x.cdcooper
            ,x.cdhistor
            ,x.nrdconta
            ,x.nrctremp
            ,c.vlpremio
            ,p.nrproposta
            ,p.nrctrseg
            ,x.cdagenci
            ,x.nrdocmto
        FROM cecred.crapseg c,
             cecred.tbseg_prestamista p,
             cecred.craplau x
       WHERE p.cdcooper = pr_cdcooper
         AND x.insitlau IN (1, 3)
         AND x.cdhistor = 4228
         AND x.cdcooper = p.cdcooper
         AND x.nrdconta = p.nrdconta
         AND x.nrctremp = p.nrctremp
         AND x.cdseqtel = p.nrproposta
         AND p.tpcustei = 0
         AND p.tpregist IN (1,3)
         AND p.cdcooper = c.cdcooper
         AND p.nrdconta = c.nrdconta
         AND p.nrctrseg = c.nrctrseg
         AND c.tpseguro = 4
         AND p.dtbaixacontab = pr_dtmvtolt;
         --AND TRUNC(SYSDATE) - x.dtmvtolt >= cecred.gene0001.fn_param_sistema('CRED', 0, 'DIAS_MAX_REPIQUE_SEGPRE');
    rw_seguros_inadimplentes cr_seguros_inadimplentes%ROWTYPE;

    --Variaveis PRJ0023580
    type typ_reg_bloqueio_pix is record (inpessoa varchar2(2), cdagenci varchar(5), vlbloqueado number(25,2), vltotal number(25,2), row_number number(5));
    type typ_tab_bloqueio_pix is table of typ_reg_bloqueio_pix index by varchar2(7);
    vr_tab_bloqueio_pix       typ_tab_bloqueio_pix;
    vr_index_bloqueio_pix     varchar2(7);

    vr_dtinicrps659 TIMESTAMP;

    -- PL/Table contendo informações por agencia e segregadas em PF e PJ
    TYPE typ_pf_pj_op_cred IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

    -- PL/Table contendo informações por agencia e segregadas em PF e PJ
    TYPE typ_age_ope_cred is table of typ_pf_pj_op_cred INDEX BY PLS_INTEGER;

    -- PL/Table principal para gravar dados em AAMMDD_OP_CREDI.txt
    TYPE typ_arq_op_cred is table of typ_age_ope_cred INDEX BY PLS_INTEGER;

    -- Variaveis referencia de PL-Table
    vr_arq_op_cred   typ_arq_op_cred;

    -- PL/Table contendo informações das agências
    type typ_agencia is record (vr_qttottrf      number(10),
                                vr_qttottrfep    number(10),
                                vr_qttarcmp      number(10),
                                vr_vlaprjur      cecred.crapljd.vldjuros%type,
                                vr_aprjursr      cecred.crapljt.vldjuros%type,
                                vr_aprjurcr      cecred.crapljt.vldjuros%type,
                                vr_vltarbcb      number(12,4),
                                vr_vltottar      cecred.crapthi.vltarifa%type,
                                vr_qttarpac      number(10),
                                vr_vltarpac      cecred.crapret.vloutdes%type,
                                vr_qttdbtot      number(10),
                                vr_vltagenc      cecred.craplcs.vllanmto%type,
                                vr_qttarpac_001  number(10),
                                vr_qttarpac_085  number(10));

    type typ_agencia2 is record (vr_cdccuage      cecred.crapage.cdccuage%type,
                                 vr_cdcxaage      cecred.crapage.cdcxaage%type);

    type typ_agencia3 is record (vr_rateio      boolean);


    type tyb_hist_cob is record (cdhistor number(10),
                                 nrdctabb number(10),
                                 flgregis number(1));

    TYPE typ_reg_limchq IS
      RECORD(cdagenci crapris.cdagenci%TYPE
            ,valor NUMBER(25,2));

    TYPE typ_tab_limchq IS
      TABLE OF typ_reg_limchq
        INDEX BY PLS_INTEGER;

    vr_tab_limcon           typ_tab_limchq;

    -- Definição da tabela para armazenar os registros das agências
    type typ_tab_agencia is table of typ_agencia index by binary_integer;
    type typ_tab_agencia2 is table of typ_agencia2 index by binary_integer;
    type typ_tab_agencia3 is table of typ_agencia3 index by binary_integer;
    type typ_tab_hist_cob is table of tyb_hist_cob index by varchar2(30);
    -- Instância da tabela. O índice será o código da agência.
    vr_tab_agencia         typ_tab_agencia;
    vr_tab_agencia2        typ_tab_agencia2;
    vr_tab_agencia3        typ_tab_agencia3;
    -- Instancia da tabela. o indice sera o historico e nr. da conta bb
    vr_tab_hist_cob        typ_tab_hist_cob;
    -- Variavel para leitura das pl/tables
    vr_indice_agencia      number(3);
    -- PL/Table que substitui a temp-table cratorc
    type typ_cratorc is record (vr_cdagenci  cecred.crapass.cdagenci%type,
                                vr_vllanmto  cecred.crapsdc.vllanmto%type);
    -- Definição da tabela
    type typ_tab_cratorc is table of typ_cratorc index by binary_integer;
    -- Instância da tabela. O índice é o código da agência.
    vr_tab_cratorc         typ_tab_cratorc;

    -- PL/Table que substitui a temp-table crapplg (Pessoa Ligada)
    type typ_crapplg is record (vr_cdagenci  cecred.crapass.cdagenci%type,
                                vr_vllanmto  cecred.crapsdc.vllanmto%type);
    -- Definição da tabela
    type typ_tab_crapplg is table of typ_crapplg index by binary_integer;
    -- Instância da tabela. O índice é o código da agência.
    vr_tab_crapplg         typ_tab_crapplg;

    -- PL/Table que substitui a temp-table tt-faturas
    type typ_faturas is record (vr_tpfatura  number(1),
                                vr_cdagenci  number(3),
                                vr_qtlanmto  number(10));
    -- Definição da tabela
    type typ_tab_faturas is table of typ_faturas index by varchar2(4);
    -- Instância da tabela. O índice é o código da agência + tipo da fatura.
    vr_tab_faturas         typ_tab_faturas;

    -- PL/Table para guardar o deposito dos municipios
    type typ_coopmunic is record (vr_cdcoopmunic  number(20),
                                  vr_vllanmto     cecred.crapsdc.vllanmto%type,
                                  vr_vlfgcoop     cecred.crapcop.vlfgcoop%TYPE);
    -- Definição da tabela
    type typ_tab_coopmunic is table of typ_coopmunic index by varchar2(20);
    -- Instância da tabela. O índice é o código da agência.
    vr_tab_coopmunic         typ_tab_coopmunic;


    -- Armazenar valores agupados por agencia
    TYPE typ_rec_age_gen
         IS RECORD (cdagenci  NUMBER,
                    qtlanmto  NUMBER,
                    vllamnto  NUMBER);
    TYPE typ_tab_age_gen IS TABLE OF typ_rec_age_gen
         INDEX BY PLS_INTEGER;

    vr_val_age_gen typ_tab_age_gen;

    -- Armazenar fatura bancoob
    TYPE typ_rec_valores_age
         IS RECORD (cdagenci   NUMBER,
                    qtlanmto   NUMBER,
                    vltarifa   NUMBER,
                    qtlanmtoep NUMBER,
                    vltarifaep NUMBER);
    TYPE typ_tab_valores_age IS TABLE OF typ_rec_valores_age
         INDEX BY PLS_INTEGER;

    vr_valores_age typ_tab_valores_age;
    type typ_faturas_bancoob
         IS RECORD ( cdempres  VARCHAR2(10),
                     nmextcon  VARCHAR2(100),
                     cdhistor  NUMBER,
                     cdhstctb  NUMBER,
                     cdagenci  NUMBER,
                     qtdtotal  NUMBER,
                     vltottar  NUMBER,
                     vltottarep  NUMBER,
                     agencias  typ_tab_valores_age);
    -- Definição da tabela
    type typ_tab_faturas_bancoob is table of typ_faturas_bancoob
         index by varchar2(30);
    vr_tab_fat_bancoob typ_tab_faturas_bancoob;

    TYPE typ_reg_bancoob
         IS RECORD (cdempres   VARCHAR2(10),
                    qttotrej   NUMBER,
                    qttotrejep NUMBER,
                    agencias   typ_tab_valores_age);
    TYPE typ_tab_rej_bancoob IS TABLE OF typ_reg_bancoob INDEX BY VARCHAR2(30);
    vr_tab_rej_bancoob typ_tab_rej_bancoob;

    -- Registro para inicializar dados por histórico
    TYPE typ_reg_historico
      IS RECORD (nrctaori_fis NUMBER          --> Conta Origem  PF
                ,nrctades_fis NUMBER          --> Conta Destino PJ
                ,dsrefere_fis VARCHAR2(500)   --> Descricao Historico
                ,nrctaori_jur NUMBER          --> Conta Origem  PF
                ,nrctades_jur NUMBER          --> Conta Destino PJ
                ,dsrefere_jur VARCHAR2(500)); --> Descricao Historico

    -- Pl-Table principal que indexa os registro historico
    TYPE typ_tab_historico
      IS TABLE OF typ_reg_historico
      INDEX BY BINARY_INTEGER;

    vr_tab_historico  typ_tab_historico;

    -- Registro para inicializar dados de operações microcrédito por histórico
    TYPE typ_reg_historico_mic
      IS RECORD (nrctaori_fis NUMBER          --> Conta Origem  PF
                ,nrctades_fis NUMBER          --> Conta Destino PJ
                ,dsrefere_fis VARCHAR2(500)   --> Descricao Historico
                ,nrctaori_jur NUMBER          --> Conta Origem  PF
                ,nrctades_jur NUMBER          --> Conta Destino PJ
                ,dsrefere_jur VARCHAR2(500)); --> Descricao Historico

    -- Pl-Table principal que indexa os registro historico
    TYPE typ_tab_historico_mic
      IS TABLE OF typ_reg_historico_mic
      INDEX BY BINARY_INTEGER;

    vr_tab_historico_mic  typ_tab_historico_mic;

    -- Pl-Table de acumulo valores por agência
    TYPE typ_tab_valores_ag
      IS TABLE OF VARCHAR2(32767)
      INDEX BY BINARY_INTEGER;

    -- Variavel Pl-Table
    vr_tab_valores_ag typ_tab_valores_ag;

    -- Pl-Table de acumulo valores de despesa de cobrança por agência  e pessoa fisica
    TYPE typ_tab_vlr_age_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_vlr_age_fis typ_tab_vlr_age_fis;

    -- Pl-Table de acumulo valores de despesa de cobrança por agência  e pessoa juridica
    TYPE typ_tab_vlr_age_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_vlr_age_jur typ_tab_vlr_age_jur;

    -- Pl-Table de acumulo valores de despesa de cobrança por tipo de pessoa
    TYPE typ_tab_vlr_descbr_pes IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_vlr_descbr_pes typ_tab_vlr_descbr_pes;


    -- Registro para inicializar dados por operadora de celular
    TYPE typ_reg_recarga_cel_ope
      IS RECORD (nmoperadora cecred.tbrecarga_operadora.nmoperadora%type,
                 vlreceita   cecred.tbrecarga_operacao.vlrecarga%type);

    TYPE typ_tab_recarga_cel_ope IS TABLE OF typ_reg_recarga_cel_ope INDEX BY PLS_INTEGER;
    vr_tab_recarga_cel_ope typ_tab_recarga_cel_ope;

    -- Registro de acumulo de códigos de histórico de contabilização
    TYPE typ_reg_craphis IS RECORD( cdhistor cecred.craphis.cdhistor%TYPE );

    TYPE typ_tab_craphis IS TABLE OF typ_reg_craphis INDEX BY BINARY_INTEGER;

    vr_tab_craphis typ_tab_craphis;

    -- Armazenar rejeições de pagamentos que ocorreram no PAGFOR Sicredi
    TYPE tab_rejeicoes_pagfor IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    vr_tab_rej_sicredi_tivit tab_rejeicoes_pagfor;

    -- Valores de Lançamentos de Arrecadações de Convenios Proprios de Entes Públicos (por Agencia)
    -- utilizado para lançar registros no arquivo principal
    TYPE typ_rec_arr_conv_age_ep
         IS RECORD (cdagenci  VARCHAR2(4000),
                    vllamnto  VARCHAR2(4000));
    TYPE typ_tab_arr_conv_age_ep IS TABLE OF typ_rec_arr_conv_age_ep
         INDEX BY PLS_INTEGER;
    -- Valores de Lançamentos de Arrecadações de Convenios Proprios de Entes Públicos (Totalizador)
    -- Utilizado para gerar a linha de cabeçalho, para cada histórico
    type typ_rec_arr_conv_tot_ep
         IS RECORD ( cdestrut           VARCHAR2(2),
                     dtmvtolt_yymmdd    VARCHAR2(6),
                     dtmvtolt           VARCHAR2(6),
                     nrctatrd           VARCHAR2(5),
                     nrctatrc           VARCHAR2(5),
                     vllamnto           VARCHAR2(200),
                     cdhstctb           VARCHAR2(100),
                     dscontab           varchar2(240),
                     agencias           typ_tab_arr_conv_age_ep);
    -- Definição da tabela
    type typ_tab_arr_conv_tot_ep is table of typ_rec_arr_conv_tot_ep
         index by varchar2(30);
    vr_tab_arr_conv_tot_ep typ_tab_arr_conv_tot_ep;


    -- Armazenar Tributos RFB (Receita Federal)
    TYPE typ_rec_valores_age2
         IS RECORD (cdagenci   NUMBER,
                    qtlanmto   NUMBER,
                    vltarifa   NUMBER,
                    qtlanmtoep NUMBER,
                    vltarifaep NUMBER,
                    vllamnto   NUMBER,
                    vllanrej   NUMBER,
                    vllamntoep NUMBER,
                    vllanrejep NUMBER);

    TYPE typ_rfb_valores_age IS TABLE OF typ_rec_valores_age2
         INDEX BY PLS_INTEGER;

    TYPE typ_tributos_rfb
         IS RECORD (cdempres   VARCHAR2(10),
                    nmextcon   VARCHAR2(100),
                    cdhistor   NUMBER,
                    cdhstctb   NUMBER,
                    cdagenci   NUMBER,
                    qtdtotal   NUMBER,
                    vltottrb   NUMBER,
                    vltottrbep NUMBER,
                    vltotrej   NUMBER,
                    vltottar   NUMBER,
                    vltottarep NUMBER,
                    vltotrejep NUMBER,
                    agencias  typ_rfb_valores_age);

    -- Definição da tabela
    TYPE typ_tab_tributos_rfb IS TABLE OF typ_tributos_rfb
         INDEX BY VARCHAR2(30);
    vr_tab_trb_rfb typ_tab_tributos_rfb;

    TYPE typ_tot_tributos_rfb IS TABLE OF typ_tributos_rfb
         INDEX BY VARCHAR2(30);
    vr_tot_trb_rfb typ_tot_tributos_rfb;



    -- Índice para a pl/table
    vr_indice_faturas      varchar2(30);
    vr_indice_hist_cob     varchar2(30);
    vr_idx_age             varchar2(30);
    vr_idx_age_2           varchar2(30);
    vr_idx_rej_pagfor      VARCHAR2(15);

    vr_ind_tot_ep          number;
    vr_ind_age_ep          number;
    -- Código do programa
    vr_cdprogra            cecred.crapprg.cdprogra%type;
    -- Controle de critica
    vr_cdcritic            cecred.crapcri.cdcritic%type;
    vr_dscritic            VARCHAR2(4000);
    -- Data do movimento
    vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
    vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
    vr_dtmvtoan            cecred.crapdat.dtmvtoan%type;
    vr_dtultdia            cecred.crapdat.dtultdia%type;
    vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
    vr_dtultdma            cecred.crapdat.dtultdma%type;
    -- Variáveis para armazenar a lista de contas convênio
    vr_lscontas            varchar2(4000);
    vr_lsconta4            varchar2(4000);
    -- Variável auxiliar para o número da conta BB
    vr_rel_nrdctabb        number(10);
    -- Variável auxiliar para o número da conta Sicredi
    vr_nrctasic            number(4);
    -- Variáveis de controle do Pagfor
    vr_plnctlpf            VARCHAR2(1) := '';
    vr_datctlpf            DATE;
    vr_cdagente            NUMBER;
    -- Tratamento de erros
    vr_exc_fimprg          EXCEPTION;
    vr_exc_saida           EXCEPTION;
    vr_typ_said            VARCHAR2(4);
    -- Data do movimento no formato yymmdd
    vr_dtmvtolt_yymmdd     varchar2(6);
    -- Nome do diretório
    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);
    -- Nome do arquivo que será gerado

    vr_nmarqnov            VARCHAR2(100); -- nome do arquivo por cooperativa
    vr_nmarqdat            varchar2(100);
    vr_nmarqdat_ope_cred   varchar2(100);
    vr_nmarqdat_ope_cred_nov   varchar2(100); --nome arquivo ope_cred por cooperativa

    -- Arquivo texto
    vr_arquivo_txt         utl_file.file_type;

    -- Variáveis para processamento do cursor cr_craprda
    vr_cdagenci_index      NUMBER;
    -- Variáveis para processamento do cursor cr_craprej
    vr_nrctacrd            cecred.craphis.nrctacrd%type;
    vr_nrctadeb            cecred.craphis.nrctadeb%type;
    vr_cdestrut            varchar2(2);
    vr_nrdctabb            craptab.dstextab%type;
    -- Variáveis que controlam as quebras do arquivo
    vr_cdhistor            cecred.craphis.cdhistor%type;
    vr_dtrefere            cecred.craprej.dtrefere%type;
    vr_vldtotal            cecred.craprej.vllanmto%type;
    -- Variáveis para processamento do cursor cr_craprej2
    vr_nrctatrd            varchar2(5);
    vr_nrctatrc            varchar2(5);
    vr_vltarece            cecred.crapthi.vltarifa%type;
    vr_vltarifa            cecred.crapthi.vltarifa%type;
    vr_vltarifa_ep         cecred.crapthi.vltarifa%type;
    -- Variável para processamento do cursor craptit
    vr_vltitulo            cecred.craptit.vldpagto%type;
    -- Variáveis para processamento de cheques e títulos
    vr_vlcapsub            cecred.crapsdc.vllanmto%type;
    vr_vlcstcop            cecred.crapcst.vlcheque%type;
    vr_vlcstout            cecred.crapcst.vlcheque%type;
    vr_vlcdbcop            cecred.crapcst.vlcheque%type;
    vr_vlcdbban            cecred.crapcst.vlcheque%type;
    vr_vlcdbtot            cecred.crapcdb.vlcheque%type;
    vr_vlcdbjur            cecred.crapcdb.vlcheque%type;
    vr_qtcdbban            number(10);
    vr_vltdbtot            cecred.craptdb.vltitulo%type;
    vr_vltdbjur            cecred.craptdb.vltitulo%type;
    vr_tdbtotsr            cecred.craptdb.vltitulo%type;
    vr_tdbjursr            cecred.craptdb.vltitulo%type;
    vr_tdbtotcr            cecred.craptdb.vltitulo%type;
    vr_tdbjurcr            cecred.craptdb.vltitulo%type;
    vr_tdbtotcr_001        cecred.craptdb.vltitulo%type;
    vr_tdbtotcr_085        cecred.craptdb.vltitulo%type;
    vr_tdbjurcr_001        cecred.craptdb.vltitulo%type;
    vr_tdbjurcr_085        cecred.craptdb.vltitulo%type;
    vr_qtdtdbcr_001        number(10);
    vr_qtdtdbcr_085        number(10);
    vr_qtdtdbsr            number(10);
    vr_qttdbtot            number(10);
    -- Variáveis para uso na leitura e processamento dos cursores cr_crapafi e cr_crapafi2
    vr_vlafideb            number(20,2);
    -- Variável para controlar a quebra do cursor cr_crapret
    vr_cdhistbb            cecred.crapret.cdhistbb%type;
    vr_vltarpac            cecred.crapret.vloutdes%type;
    -- Variável para processamento de saques e estornos
    vr_vllanmto            cecred.craplcm.vllanmto%type;
    -- Variáveis globais utilizadas pelos procedimentos internos
    vr_flgctpas            boolean; -- PASSIVO
    vr_flgctred            boolean; -- REDUTORA
    vr_flgrvorc            boolean; -- REVERSAO
    vr_vltotorc            cecred.crapsdc.vllanmto%type;
    vr_vlstotal            cecred.crapsdc.vllanmto%type;
    vr_vltotplg            cecred.crapsdc.vllanmto%type;
    vr_dshstorc            varchar2(240);
    vr_dshstor1            varchar2(240);
    vr_dshcporc            varchar2(100);
    vr_lsctaorc            varchar2(100);
    vr_nrsldpou            varchar2(100);
    vr_nrrevers            varchar2(100);
    vr_lsctacmp            varchar2(100);
    vr_tipocob             varchar2(100);
    -- Variável para geração do arquivo texto
    vr_linhadet            varchar2(300);
    vr_complinhadet        varchar2(100);
    --
    vr_vlpioneiro          number(10,2);
    vr_vlcartao            number(10,2);
    vr_vlrecibo            number(10,2);
    vr_vloutros            number(10,2);
    vr_flgpione            boolean;
    -- Convênio Sicredi
    vr_vllanmto_fat        cecred.craplft.vllanmto%type;
    vr_idtributo_6106      number(1);
    vr_cdempcon            cecred.crapcon.cdempcon%TYPE;
    vr_cdsegmto            cecred.crapcon.cdsegmto%TYPE;

    -- Receita Federal
    vr_dsorigem            VARCHAR2(10);
    vr_indice_faturas_2    VARCHAR2(30);
    vr_qtlanrej            NUMBER;
    vr_vllanrej            NUMBER;
    vr_qtlanrejep          NUMBER;
    vr_vllanrejep          NUMBER;

    -- Auxiliar
    vr_incrapebn           NUMBER;

    vr_nmextcon            cecred.crapcon.nmextcon%TYPE;
    vr_vltarifa_debaut     cecred.tbconv_arrecadacao.vltarifa_debaut%TYPE;

    vr_qtlanmto            number(10);
    vr_qtlanmtoep          number(10);
    vr_cdempres            cecred.craplau.cdempres%TYPE;

    -- Variaveis para relatorio
    vr_chave               PLS_INTEGER;

    -- Variavel recarga de celular
    vr_index               NUMBER;

    vr_nrctacre            rw_craphis.nrctacrd%TYPE;
    vr_cdagenci            NUMBER;
    vr_receita_cel_pf      NUMBER := 0;
    vr_receita_cel_pj      NUMBER := 0;

    vr_vltarifa_taa        NUMBER := 0;
    vr_vltarifa_ib         NUMBER := 0;
    vr_vltarifa_taa_ep     NUMBER := 0;
    vr_vltarifa_ib_ep      NUMBER := 0;
    vr_agencia_prox        INTEGER:= 0;
    vr_agencia_ant         INTEGER:= 0;
    vr_cdageori            INTEGER;
    vr_vlarrecada          NUMBER  := 0;
    vr_rateio90            BOOLEAN:= FALSE;
    vr_rateio91            BOOLEAN:= FALSE;
    vr_prodpoup            NUMBER := 1109;
    vr_vllanmto_tar        NUMBER := 0;

    --Váriaveis arquivo prejuizo
    vr_nmarqdat_prejuizo      VARCHAR2(100);
    vr_nmarqdat_prejuizo_nov  VARCHAR2(100);

    --Váriaveis arquivo tarifas cobranca bb
    vr_contador               NUMBER := 0;
    --
    vr_vltardes               NUMBER := 0;

    vr_isFirst                BOOLEAN;

    vr_usarTimeStamp          BOOLEAN := FALSE;

    vr_dtiniexc TIMESTAMP;
    vr_dtdurexc TIMESTAMP;
    vr_idprglog NUMBER;

    --Variaveis de lancto do credito imobiliario --PJ23311
    vr_cdhistorl   cecred.craphis.cdhistor%TYPE;
    vr_dshistor1   VARCHAR2(500);
    vr_nrctadebl   cecred.craphis.nrctadeb%TYPE;
    vr_nrctacrdl   cecred.craphis.nrctacrd%TYPE;
    vr_cdhistlct02 cecred.craphis.cdhistor%TYPE;
    vr_listou_03   INTEGER := 0;
    vr_listou_04   INTEGER := 0;
    vr_ttl_vllanmto cecred.craplcm.vllanmto%TYPE := 0;
    vr_idfunding NUMBER(1):= 0;
    vr_idhmequit NUMBER(1):= 0;
    vr_idempgara NUMBER(1):= 0;

    -- Valores prestamista
    vr_vlrtotal_estorno_prestamista number:= 0;
    vr_flgseguro_prest pls_integer;

    rw_crapdat datascooperativa;

    function fn_calcula_data (pr_cdcooper in cecred.craptab.cdcooper%type,
                              pr_dtmvtoan in date) return date is

      vr_dtrefere    date;
    begin
      vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                 pr_dtmvtoan - 1,
                                                 'A');
      -- Se teve fim de semana ou feriado antes de ontem
      if pr_dtmvtoan - vr_dtrefere > 1 then
        return vr_dtrefere;
      else
        return pr_dtmvtoan;
      end if;
    end;
    function fn_ultctaconve (pr_dstextab in varchar2) return varchar2 is
      vr_dstextab    varchar2(4000) := pr_dstextab;
    BEGIN
      if instr(pr_dstextab, ',', -1) = length(trim(pr_dstextab))   then
        vr_dstextab := substr(pr_dstextab, 1, length(trim(pr_dstextab)) - 1);
        vr_dstextab := substr(vr_dstextab, instr(vr_dstextab, ',', -1) + 1, 10);
      elsif instr(pr_dstextab, ',', -1) > 0 then
        vr_dstextab := substr(pr_dstextab, instr(pr_dstextab, ',', -1) + 1, 10);
      end if;
      return vr_dstextab;
    end;

    -- Grava no arquivo as informacoes por agencia
    PROCEDURE pc_set_linha(pr_cdarquiv IN NUMBER
                          ,pr_inpessoa IN NUMBER
                          ,pr_inputfile IN OUT NOCOPY UTL_FILE.file_type) IS
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_set_linha', pr_action => NULL);
      -- Gravas as informacoes de valores por agencia
      FOR vr_idx_agencia IN vr_arq_op_cred(pr_cdarquiv).FIRST..vr_arq_op_cred(pr_cdarquiv).LAST LOOP

         -- Verifica se existe a informacao de agencia
         IF vr_arq_op_cred(pr_cdarquiv).EXISTS(vr_idx_agencia) THEN

            -- Nao considerar o registro 999 na linha
            IF vr_idx_agencia = 999 THEN
               CONTINUE;
            END IF;

            -- Verifica se existe a informacao de tipo de pessoa
            IF vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia).EXISTS(pr_inpessoa) THEN
               IF vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia)(pr_inpessoa) > 0 THEN
                  -- Montar linha para gravar no arquivo
                  cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => pr_inputfile --> Handle do arquivo aberto
                                                ,pr_des_text => LPAD(vr_idx_agencia,3,0)||','
                                                       ||TRIM(TO_CHAR(vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia)(pr_inpessoa), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))); --> Texto para escrita
               END IF;
            END IF;
         END IF;
      END LOOP;
    END;

    -- Retorna o cabecalho do arquivo AAMMDD_OPCRED.txt
    FUNCTION fn_set_cabecalho(pr_inlinha IN VARCHAR2
                             ,pr_dtarqmv IN DATE
                             ,pr_dtarqui IN DATE
                             ,pr_origem  IN NUMBER      --> Conta Origem
                             ,pr_destino IN NUMBER      --> Conta Destino
                             ,pr_vltotal IN NUMBER      --> Soma total de todas as agencias
                             ,pr_dsconta IN VARCHAR2)   --> Descricao da conta
                             RETURN VARCHAR2 IS
    BEGIN
      RETURN pr_inlinha --> Identificacao inicial da linha
          ||TO_CHAR(pr_dtarqmv,'YYMMDD')||',' --> Data AAMMDD do Arquivo
          ||TO_CHAR(pr_dtarqui,'DDMMYY')||',' --> Data DDMMAA
          ||pr_origem||','                    --> Conta Origem
          ||pr_destino||','                   --> Conta Destino
          ||TRIM(TO_CHAR(pr_vltotal,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','
          ||'5210'||','
          ||pr_dsconta;
    END;

    PROCEDURE pc_dados_historico(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_cdhistor  IN craphis.cdhistor%TYPE
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic OUT crapcri.dscritic%TYPE
                                ) IS
    /*---------------------------------------------------------------------
      Programa : pc_dados_historico
      Sistema  : Ayllos
      Sigla    : CRPS249
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018

      Objetivo  : Buscar as informações do histórico de contabilização

      Alteração : 02/06/2018 - Criação (Paulo Penteado (GFT))
                    30/08/2018 - Substituido os OPEN do cursor cr_craphis2 por essa procedure com a idéia de centralizar
                                 a tratativa de erro quando não encontrar o histórico (Paulo Penteado GFT)

    ---------------------------------------------------------------------*/
      -- Variável de críticas
      vr_cdcritic cecred.crapcri.cdcritic%TYPE;
      vr_dscritic cecred.crapcri.dscritic%TYPE;

      -- Variavel de Exception
      vr_exc_erro EXCEPTION;

    BEGIN
      OPEN cr_craphis2(pr_cdcooper
                      ,pr_cdhistor);
      FETCH cr_craphis2 INTO rw_craphis2;
      IF cr_craphis2%NOTFOUND THEN
        CLOSE cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := pr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_erro;
      END   IF;
      CLOSE cr_craphis2;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       pr_cdcritic := 0;
           pr_dscritic := 'Erro ao obter dados do histórico '||pr_cdhistor||': '||SQLERRM;
    END;

    --
    -- Procedimento para inicialização da PL/Table de agência ao criar novo
    -- registro, garantindo que os campos terão valor zero, e não nulo.
    PROCEDURE pc_cria_agencia_pltable (pr_agencia   IN cecred.crapage.cdagenci%TYPE
                                      ,pr_cdarquiv  IN PLS_INTEGER) IS
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_cria_agencia_pltable', pr_action => NULL);
      -- Se não há o registro da agencia na tabela de memória
      if not vr_tab_agencia.exists(pr_agencia) then
        vr_tab_agencia(pr_agencia).vr_qttottrf := 0;
        vr_tab_agencia(pr_agencia).vr_qttottrfep := 0;
        vr_tab_agencia(pr_agencia).vr_qttarcmp := 0;
        vr_tab_agencia(pr_agencia).vr_vlaprjur := 0;
        vr_tab_agencia(pr_agencia).vr_aprjursr := 0;
        vr_tab_agencia(pr_agencia).vr_aprjurcr := 0;
        vr_tab_agencia(pr_agencia).vr_vltarbcb := 0;
        vr_tab_agencia(pr_agencia).vr_vltottar := 0;
        vr_tab_agencia(pr_agencia).vr_qttarpac := 0;
        vr_tab_agencia(pr_agencia).vr_vltarpac := 0;
        vr_tab_agencia(pr_agencia).vr_qttdbtot := 0;
        vr_tab_agencia(pr_agencia).vr_vltagenc := 0;
        vr_tab_agencia(pr_agencia).vr_qttarpac_001 := 0;
        vr_tab_agencia(pr_agencia).vr_qttarpac_085 := 0;
      end if;
      -- Se não foi incluído na tabela de memória
      if not vr_tab_agencia2.exists(pr_agencia) then
        vr_tab_agencia2(pr_agencia).vr_cdccuage := 0;
        vr_tab_agencia2(pr_agencia).vr_cdcxaage := 0;
      end if;

      -- Se não foi passado o ID do arquivo
      IF pr_cdarquiv IS NOT NULL THEN
         -- Verifica se existe o codigo do arquivo
         IF NOT vr_arq_op_cred.EXISTS(pr_cdarquiv) THEN
            vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(1) := 0; -- Pessoa Fisica
            vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(2) := 0; -- Pessoa Juridica
         END IF;

         -- Inicializa informacoes da agencia - Dados para contabilidade
         IF NOT vr_arq_op_cred(pr_cdarquiv).EXISTS(pr_agencia) THEN
            vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(1) := 0; -- Pessoa Fisica
            vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(2) := 0; -- Pessoa Juridica
         END IF;
      END IF;
    end;

    --Insere dados de operações contábeis
    procedure pc_grava_crapopc_bulk (pr_cdcooper in cecred.crapopc.cdcooper%type,
                                pr_dtrefere in cecred.crapopc.dtrefere%type,
                                rw_crapcdb  in tab_crapcdb_rec,
                                pr_tpregist in cecred.crapopc.tpregist%type,
                                pr_cdtipope in cecred.crapopc.cdtipope%type,
                                pr_cdprogra in cecred.crapopc.cdprogra%type) IS
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_grava_crapopc_bulk', pr_action => NULL);

      for i in 1 .. rw_crapcdb.count
      loop
        -- Ajuste de condição - Chamado 841064 - 20/02/2018
        if rw_crapcdb(i).inchqcop <> 1 then

          vr_vlcdbban := vr_vlcdbban + rw_crapcdb(i).vlcheque;
          vr_qtcdbban := vr_qtcdbban + 1;
        else
          vr_vlcdbcop := vr_vlcdbcop + rw_crapcdb(i).vlcheque;
        end if;

      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        vr_cdcritic := 9999;
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||
                       ' crapopc '  ||
                       ' cdcooper:' ||pr_cdcooper||
                       ', dtrefere:'||pr_dtrefere||
                       ', tpregist:'||pr_tpregist||
                       ', cdtipope:'||pr_cdtipope||
                       ', cdprogra:'||Lower(pr_cdprogra)||'. '||sqlerrm;
        RAISE vr_exc_saida;
    END pc_grava_crapopc_bulk;

    procedure pc_proc_lista_pessoa_ligada (pr_flgdata in boolean) IS
      vr_dsconta  varchar2(100);
      vr_ctaorig  NUMBER;
      vr_ctadest  NUMBER;
      vr_dtmvto   date;
      vr_indice_agencia  crapass.cdagenci%type;
    BEGIN
      -- Escolhe a data a utilizar
      if pr_flgdata then
        vr_dtmvto  := vr_dtmvtopr;
        vr_dsconta := '"(crps249) REVERSAO RECLASSIFICACAO SALDOS PESSOA FISICA LIGADA"';
        vr_ctaorig := 4144;
        vr_ctadest := 4140;
      else
        vr_dtmvto  := vr_dtmvtolt;
        vr_dsconta := '"(crps249) RECLASSIFICACAO SALDOS PESSOA FISICA LIGADA"';
        vr_ctaorig := 4140;
        vr_ctadest := 4144;
      end if;

      --Reclassificação dentro do mês
      vr_linhadet := fn_set_cabecalho('20', vr_dtmvtolt, vr_dtmvto, vr_ctaorig, vr_ctadest, vr_vltotplg, vr_dsconta);
      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet); --> Texto para escrita

      FOR I IN 1..2 LOOP
      BEGIN
        vr_indice_agencia := vr_tab_crapplg.first;
        -- Percorre todas as agencias
        WHILE vr_indice_agencia IS NOT NULL LOOP
          -- Se o valor de lançamentos for diferente de zero
          if vr_tab_crapplg(vr_indice_agencia).vr_vllanmto <> 0 then
            vr_linhadet := to_char(vr_tab_crapplg(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                           trim(to_char(vr_tab_crapplg(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          -- Próximo indice(agencia)
          vr_indice_agencia := vr_tab_crapplg.next(vr_indice_agencia);
        END LOOP;
      END;
      END LOOP;

    END pc_proc_lista_pessoa_ligada;


    -- Insere linhas de orçamento no arquivo
    procedure pc_proc_lista_orcamento is
      vr_ger_dsctaorc    varchar2(50);
      vr_pac_dsctaorc    varchar2(50);
      vr_dtmvto          date;
      vr_indice_agencia  crapass.cdagenci%type;
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_lista_orcamento', pr_action => NULL);
      -- Se o valor total for igual a zero
      if vr_vltotorc = 0 then
        return;
      end if;
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
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_pac_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);


      -- Inclui informações por PA
      vr_indice_agencia := vr_tab_cratorc.first;
      -- Percorre todas as agencias
      WHILE vr_indice_agencia IS NOT NULL LOOP
        -- Se o valor de lançamentos for diferente de zero
        if vr_tab_cratorc(vr_indice_agencia).vr_vllanmto <> 0 then
          vr_linhadet := to_char(vr_tab_cratorc(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                         trim(to_char(vr_tab_cratorc(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        -- Próximo indice(agencia)
        vr_indice_agencia := vr_tab_cratorc.next(vr_indice_agencia);
      END LOOP;



    END;

    -- Busca o saldo diário dos associados e insere na pl/table, calculando a soma por agência
    procedure pc_proc_saldo_dep_vista (pr_cdcooper in crapsda.cdcooper%type,
                                       pr_nrdconta in crapsda.nrdconta%type,
                                       pr_dtmvtolt in crapsda.dtmvtolt%type,
                                       pr_cdagenci in crapass.cdagenci%type) IS
      --
      vr_tot_vlliquid       number(20,2):= 0;
      vr_tot_vlutiliz       number(20,2):= 0;
      vr_tot_vlsaqblq       number(20,2):= 0;
      vr_tot_vladiant       number(20,2):= 0;
      vr_tot_vlcrdliq       number(20,2):= 0;
      vr_ger_vlstotal       number(20,2):= 0;
      vr_ass_vlstotal       number(20,2):= 0;

      -- Saldo diário dos associados
      cursor cr_crapsda (pr_cdcooper in cecred.crapsda.cdcooper%type,
                         pr_nrdconta in cecred.crapsda.nrdconta%type,
                         pr_dtmvtolt in cecred.crapsda.dtmvtolt%type) is
        select nvl(crapsda.vlsddisp, 0) vlsddisp,
               nvl(crapsda.vlsdchsl, 0) vlsdchsl,
               nvl(crapsda.vlsdbloq, 0) vlsdbloq,
               nvl(crapsda.vlsdblpr, 0) vlsdblpr,
               nvl(crapsda.vlsdblfp, 0) vlsdblfp,
               nvl(crapsda.vlsdindi, 0) vlsdindi,
               nvl(crapsda.vllimcre, 0) vllimcre,
               crapsda.dtdsdclq
          from cecred.crapsda
         where crapsda.cdcooper = pr_cdcooper
           and crapsda.nrdconta = pr_nrdconta
           and crapsda.dtmvtolt = pr_dtmvtolt;
      rw_crapsda      cr_crapsda%rowtype;

    begin
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_saldo_dep_vista', pr_action => NULL);
      -- Buscar o saldo diário dos associados
      open cr_crapsda (pr_cdcooper,
                       pr_nrdconta,
                       pr_dtmvtolt);
      fetch cr_crapsda into rw_crapsda;
      -- Se não encontrar
      if cr_crapsda%notfound then
        close cr_crapsda;
        RETURN; -- Retorna
      end if;
      close cr_crapsda;

      -- Calcula o saldo total do associado
      vr_ass_vlstotal := nvl(rw_crapsda.vlsddisp,0) + nvl(rw_crapsda.vlsdchsl,0) +
                         nvl(rw_crapsda.vlsdbloq,0) + nvl(rw_crapsda.vlsdblpr,0) +
                         nvl(rw_crapsda.vlsdblfp,0) + nvl(rw_crapsda.vlsdindi,0);
      -- Acumula o total líquido
      vr_tot_vlliquid := nvl(vr_tot_vlliquid,0) + nvl(vr_ass_vlstotal,0);

      -- Se a data em que foi passado para credito em liquidacao não é nula e é
      -- menor ou igual a data de referencia
      if rw_crapsda.dtdsdclq is not null and
         rw_crapsda.dtdsdclq <= pr_dtmvtolt then
        -- Se o valor total é negativo
        if vr_ass_vlstotal < 0 then
          vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) + nvl(rw_crapsda.vllimcre,0);
        else
          vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) - nvl(rw_crapsda.vllimcre,0);
        end if;
        --
        vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) - rw_crapsda.vllimcre;
      end if;
      -- Acumula demais totais
      if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl) < 0 then
        if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre) > 0 then
          vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl);
        elsif vr_ass_vlstotal + rw_crapsda.vllimcre > 0 then
          vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
          vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq ,0)+ (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre);
        else
          if rw_crapsda.dtdsdclq is null then
            vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
            vr_tot_vladiant := nvl(vr_tot_vladiant,0) + nvl(vr_ass_vlstotal,0) + rw_crapsda.vllimcre;
          end if;

          vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) + ((rw_crapsda.vlsdbloq + rw_crapsda.vlsdblpr + rw_crapsda.vlsdblfp) * -1);

        end if;
      end if;
      --
      vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) * -1;
      vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) * -1;
      vr_tot_vladiant := nvl(vr_tot_vladiant,0) * -1;
      vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) * -1;
      vr_ger_vlstotal := nvl(vr_tot_vlliquid,0) + nvl(vr_tot_vlutiliz,0) + nvl(vr_tot_vlsaqblq,0) +
                         nvl(vr_tot_vladiant,0) + nvl(vr_tot_vlcrdliq,0);
      --
      vr_tab_cratorc(pr_cdagenci).vr_cdagenci := pr_cdagenci;
      -- Se o valor geral for maior que zero
      if vr_ger_vlstotal > 0 THEN
        -- Guarda o valor no registro de memória
        vr_tab_cratorc(pr_cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(pr_cdagenci).vr_vllanmto, 0) + nvl(vr_ger_vlstotal,0);
        vr_vltotorc := nvl(vr_vltotorc, 0) + nvl(vr_ger_vlstotal,0);
      end if;
    end;
    --
    -- Busca o saldo diário dos grupos municipais e insere na pl/table o excedente de cada municipio
    procedure pc_proc_dep_vista_ep_ct_contb (pr_cdcooper in crapsda.cdcooper%type,
                                             pr_dtmvtolt in crapsda.dtmvtolt%type) IS
      --
      vr_tot_vlliquid       number(20,2):= 0;
      vr_tot_vlutiliz       number(20,2):= 0;
      vr_tot_vlsaqblq       number(20,2):= 0;
      vr_tot_vladiant       number(20,2):= 0;
      vr_tot_vlcrdliq       number(20,2):= 0;
      vr_ger_vlstotal       number(20,2):= 0;
      vr_ass_vlstotal       number(20,2):= 0;
      vr_cdagenci_idx       NUMBER;

      -- Saldo diário dos associados
      cursor cr_crapsda (pr_cdcooper in cecred.crapsda.cdcooper%type,
                         pr_nrdconta in cecred.crapsda.nrdconta%type,
                         pr_dtmvtolt in cecred.crapsda.dtmvtolt%type) is
        select nvl(crapsda.vlsddisp, 0) vlsddisp,
               nvl(crapsda.vlsdchsl, 0) vlsdchsl,
               nvl(crapsda.vlsdbloq, 0) vlsdbloq,
               nvl(crapsda.vlsdblpr, 0) vlsdblpr,
               nvl(crapsda.vlsdblfp, 0) vlsdblfp,
               nvl(crapsda.vlsdindi, 0) vlsdindi,
               nvl(crapsda.vllimcre, 0) vllimcre,
               crapsda.dtdsdclq
          from cecred.crapsda
         where crapsda.cdcooper = pr_cdcooper
           and crapsda.nrdconta = pr_nrdconta
           and crapsda.dtmvtolt = pr_dtmvtolt;
      rw_crapsda      cr_crapsda%rowtype;


      cursor cr_coopmunic (pr_cdcooper in cecred.crapass.cdcooper%type) is
        select tbcc_associados.cdcooper, tbcc_associados.idgrupo_municipal, nvl(crapcop.vlfgcoop,0) vlfgcoop
          from cecred.crapass, cecred.tbcc_tipo_conta tipo_conta, cecred.tbcc_associados, crapcop
         where tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo = 4
           and tbcc_associados.cdcooper = crapass.cdcooper
           and tbcc_associados.nrdconta = crapass.nrdconta
           and crapass.cdcooper = crapcop.cdcooper
           and ((crapass.cdcooper = pr_cdcooper and pr_cdcooper <> 3) or (crapass.cdcooper <> pr_cdcooper and pr_cdcooper = 3))
         group by tbcc_associados.cdcooper, tbcc_associados.idgrupo_municipal, vlfgcoop
         order by tbcc_associados.cdcooper;

      cursor cr_crapass (pr_cdcooper          in cecred.crapass.cdcooper%type,
                         pr_idgrupo_municipal in cecred.tbcc_associados.idgrupo_municipal%type) is
        select crapass.nrdconta
          from cecred.crapass, cecred.tbcc_tipo_conta tipo_conta, cecred.tbcc_associados
         where tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo = 4
           and tbcc_associados.cdcooper = crapass.cdcooper
           and tbcc_associados.nrdconta = crapass.nrdconta
           and crapass.cdcooper = pr_cdcooper
           and tbcc_associados.idgrupo_municipal = pr_idgrupo_municipal
           and crapass.dtelimin is null;

    begin
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_dep_vista_ep_ct_contb', pr_action => NULL);

      --Abre cursor de cooperativa e seus grupos municipais
      for rw_coopmunic in cr_coopmunic (pr_cdcooper) loop
        --Popula a variavel de index
        vr_cdagenci_idx := rw_coopmunic.cdcooper||lpad(rw_coopmunic.idgrupo_municipal,10,'0');
        --Abre cursor dos associados ente públicos
        for rw_crapass in cr_crapass (rw_coopmunic.cdcooper,
                                      rw_coopmunic.idgrupo_municipal) loop
          -- Buscar o saldo diário dos associados
          open cr_crapsda (rw_coopmunic.cdcooper,
                           rw_crapass.nrdconta,
                           pr_dtmvtolt);
          fetch cr_crapsda into rw_crapsda;
          -- Se não encontrar
          if cr_crapsda%notfound then
            close cr_crapsda;
            continue; -- Retorna
          end if;
          close cr_crapsda;

          -- Inicializa as variáveis dos saldos do associoado
          vr_tot_vlliquid := 0;
          vr_tot_vlutiliz := 0;
          vr_tot_vlsaqblq := 0;
          vr_tot_vladiant := 0;
          vr_tot_vlcrdliq := 0;
          -- Calcula o saldo total do associado
          vr_ass_vlstotal := nvl(rw_crapsda.vlsddisp,0) + nvl(rw_crapsda.vlsdchsl,0) +
                             nvl(rw_crapsda.vlsdbloq,0) + nvl(rw_crapsda.vlsdblpr,0) +
                             nvl(rw_crapsda.vlsdblfp,0) + nvl(rw_crapsda.vlsdindi,0);
          -- Acumula o total líquido
          vr_tot_vlliquid := nvl(vr_tot_vlliquid,0) + nvl(vr_ass_vlstotal,0);

          -- Se a data em que foi passado para credito em liquidacao não é nula e é
          -- menor ou igual a data de referencia
          if rw_crapsda.dtdsdclq is not null and
             rw_crapsda.dtdsdclq <= pr_dtmvtolt then
            -- Se o valor total é negativo
            if vr_ass_vlstotal < 0 then
              vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) + nvl(rw_crapsda.vllimcre,0);
            else
              vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) - nvl(rw_crapsda.vllimcre,0);
            end if;
            --
            vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) - rw_crapsda.vllimcre;
          end if;
          -- Acumula demais totais
          if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl) < 0 then
            if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre) > 0 then
              vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl);
            elsif vr_ass_vlstotal + rw_crapsda.vllimcre > 0 then
              vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
              vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq ,0)+ (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre);
            else
              if rw_crapsda.dtdsdclq is null then
                vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
                vr_tot_vladiant := nvl(vr_tot_vladiant,0) + nvl(vr_ass_vlstotal,0) + rw_crapsda.vllimcre;
              end if;

              vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) + ((rw_crapsda.vlsdbloq + rw_crapsda.vlsdblpr + rw_crapsda.vlsdblfp) * -1);

            end if;
          end if;
          --
          vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) * -1;
          vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) * -1;
          vr_tot_vladiant := nvl(vr_tot_vladiant,0) * -1;
          vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) * -1;
          vr_ger_vlstotal := nvl(vr_ger_vlstotal,0) + nvl(vr_tot_vlliquid,0) + nvl(vr_tot_vlutiliz,0) +
                             nvl(vr_tot_vlsaqblq,0) + nvl(vr_tot_vladiant,0) + nvl(vr_tot_vlcrdliq,0);
        end loop;-- fim loop associados
        --
        vr_tab_coopmunic(vr_cdagenci_idx).vr_cdcoopmunic := vr_cdagenci_idx;
        -- Populo o parâmetro do fundo garantidor
        vr_tab_coopmunic(vr_cdagenci_idx).vr_vlfgcoop := rw_coopmunic.vlfgcoop;
        -- Se o valor geral for maior que zero
        if vr_ger_vlstotal > 0 THEN
          -- Guarda o valor no registro de memória
          vr_tab_coopmunic(vr_cdagenci_idx).vr_vllanmto := nvl(vr_tab_coopmunic(vr_cdagenci_idx).vr_vllanmto, 0) + nvl(vr_ger_vlstotal,0);
        end if;
        vr_ger_vlstotal := 0;
      end loop; --Fim loop cooperativa e grupos municipais
    end;
    --

    PROCEDURE pc_proc_lcm_tdb(pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE
                             ,pr_tpcblmen IN VARCHAR2) IS

      -- Índice da PL/Table
      vr_indice   NUMBER;
    BEGIN
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Pagamento de multa e juros de mora da conta corrente do cooperado
      vr_tab_craphis.delete;
      vr_tab_craphis(1).cdhistor := DSCT0003.vr_cdhistordsct_pgtomultaavcc; --2683 PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
      vr_tab_craphis(2).cdhistor := DSCT0003.vr_cdhistordsct_pgtojurosavcc; --2687 PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)

      vr_indice   := vr_tab_craphis.first;
      vr_cdestrut := '55';

      WHILE vr_indice IS NOT NULL LOOP
        vr_cdhistor := vr_tab_craphis(vr_indice).cdhistor;

        pc_dados_historico(pr_cdcooper => pr_cdcooper
                          ,pr_cdhistor => vr_cdhistor
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Buscar os juros de descontos de títulos
        FOR rw_craplcm_tdb in cr_craplcm_tdb(pr_cdcooper
                                            ,pr_dtrefere
                                            ,vr_cdhistor) LOOP

            IF rw_craplcm_tdb.cdagenci = 999 THEN
              vr_linhadet := trim(vr_cdestrut)||
                             trim(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             rw_craphis2.nrctadeb||','||
                             rw_craphis2.nrctacrd||','||
                             trim(to_char(rw_craplcm_tdb.vllanmto, '99999999999990.00'))||','||
                             rw_craphis2.cdhstctb||','||
                             '"('||vr_cdhistor||') '||rw_craphis2.dsexthst||'"';
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              --
              vr_linhadet := '999,'||trim(to_char(rw_craplcm_tdb.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

              IF rw_craphis2.ingerdeb = 2 AND rw_craphis2.ingercre = 2 THEN
                 cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              END IF;
            ELSE
              IF pr_tpcblmen = 'M' THEN -- contabilização mensal
                vr_linhadet := to_char(rw_craplcm_tdb.cdccuage, 'fm000')||','||
                               trim(to_char(rw_craplcm_tdb.vllanmto, '999999990.00'));
                cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              END IF;
            END IF;
        END LOOP;
        vr_indice := vr_tab_craphis.next(vr_indice);
      END LOOP;
    END pc_proc_lcm_tdb;

    PROCEDURE pc_proc_lancbor(pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
      -- Índice da PL/Table
      vr_indice   NUMBER;
    BEGIN
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_cdestrut := '55';

      vr_tab_craphis.delete;
      vr_tab_craphis(1).cdhistor  := DSCT0003.vr_cdhistordsct_liberacred;     --2665 LIBERACAO DO CREDITO DESCONTO DE TITULO
      vr_tab_craphis(2).cdhistor  := DSCT0003.vr_cdhistordsct_rendaapropr;    --2666 RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
      vr_tab_craphis(3).cdhistor  := DSCT0003.vr_cdhistordsct_pgtoopc;        --2671 PAGTO DESCONTO DE TITULO
      vr_tab_craphis(4).cdhistor  := DSCT0003.vr_cdhistordsct_pgtocompe;      --2672 PAGTO DESCONTO TITULO VIA COMPE
      vr_tab_craphis(5).cdhistor  := DSCT0003.vr_cdhistordsct_pgtocooper;     --2673 PAGTO DESCONTO DE TITULO VIA COOPERATIVA
      vr_tab_craphis(6).cdhistor  := DSCT0003.vr_cdhistordsct_pgtoavalopc;    --2675 PAGTO DESCONTO DE TITULO AVAL
      vr_tab_craphis(7).cdhistor  := DSCT0003.vr_cdhistordsct_resgatetitdsc;  --2678 RESGATE DE TÍTULO DESCONTADO
      vr_tab_craphis(8).cdhistor  := DSCT0001.vr_cdhistordsct_resreap;        --2679 RENDA SOBRE RESGATE DE TÍTULO DESCONTADO
      vr_tab_craphis(9).cdhistor  := DSCT0003.vr_cdhistordsct_pgtomultaopc;   --2682 PAGTO DE MULTA SOBRE DESCONTO DE TITULO (operacao credito)
      vr_tab_craphis(10).cdhistor := DSCT0003.vr_cdhistordsct_pgtomultaavopc; --2684 PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
      vr_tab_craphis(11).cdhistor := DSCT0003.vr_cdhistordsct_pgtojurosopc;   --2686 PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (operacao credito)
      vr_tab_craphis(12).cdhistor := DSCT0003.vr_cdhistordsct_pgtojurosavopc; --2688 PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
      -- Prejuizo
      vr_tab_craphis(13).cdhistor := PREJ0005.vr_cdhistordsct_juros_atuali;   --2763 JUROS PREJUIZO
      vr_tab_craphis(14).cdhistor := PREJ0005.vr_cdhistordsct_multa_atraso;   --2764 MULTA
      vr_tab_craphis(15).cdhistor := PREJ0005.vr_cdhistordsct_juros_mora;     --2765 JUROS MORA
      vr_tab_craphis(16).cdhistor := PREJ0005.vr_cdhistordsct_rec_principal;  --2770 PAG.PREJUIZO PRINCIP.
      vr_tab_craphis(17).cdhistor := PREJ0005.vr_cdhistordsct_rec_jur_60;     --2771 PGTO JUROS +60
      vr_tab_craphis(18).cdhistor := PREJ0005.vr_cdhistordsct_rec_jur_atuali; --2772 PAGTO JUROS  PREJUIZO
      vr_tab_craphis(19).cdhistor := PREJ0005.vr_cdhistordsct_rec_mult_atras; --2773 PGTO MULTA ATRASO
      vr_tab_craphis(20).cdhistor := PREJ0005.vr_cdhistordsct_rec_jur_mora;   --2774 PGTO JUROS MORA
      vr_tab_craphis(21).cdhistor := PREJ0005.vr_cdhistordsct_rec_abono;      --2689 ABONO PREJUIZO
      vr_tab_craphis(22).cdhistor := PREJ0005.vr_cdhistordsct_rec_preju;      --2876 RECUPERAÇÃO DE PREJUIZO
      -- Estorno
      vr_tab_craphis(23).cdhistor := DSCT0003.vr_cdhistordsct_est_pgto;       --2811  EST.PAGAMENTO ESTORNO DE PAGAMENTO DESCONTO DE TITULO ESTORNO PGTO DESC.TIT 2671
      vr_tab_craphis(24).cdhistor := DSCT0003.vr_cdhistordsct_est_multa;      --2812  EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO ESTORNO MULTA DESC. 2682
      vr_tab_craphis(25).cdhistor := DSCT0003.vr_cdhistordsct_est_juros;      --2813  EST.JUROS ESTORNO DE PAGAMENTO JUROS MORA DESCONTO DE TITULO  ESTORNO JUROS DESC. 2686
      vr_tab_craphis(26).cdhistor := DSCT0003.vr_cdhistordsct_est_pgto_ava;   --2814  EST.PGTO AVAL ESTORNO DE PAGAMENTO DESCONTO DE TITULO AVAL  ESTORNO PGTO DESC.TIT 2675
      vr_tab_craphis(27).cdhistor := DSCT0003.vr_cdhistordsct_est_multa_ava;  --2815  EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO AVAL  ESTORNO MULTA DESC. 2684
      vr_tab_craphis(28).cdhistor := DSCT0003.vr_cdhistordsct_est_juros_ava;  --2816  EST.JUROS ESTORNO DE PGTO JUROS MORA DESCONTO DE TITULO AVAL  ESTORNO JUROS DESC. 2688
      -- Estorno Prejuizo
      vr_tab_craphis(29).cdhistor := PREJ0005.vr_cdhistordsct_est_principal;  --2775 ESTORNO PREJUIZO PRINCIPAL
      vr_tab_craphis(30).cdhistor := PREJ0005.vr_cdhistordsct_est_jur_60;     --2776 ESTORNO JUROS +60
      vr_tab_craphis(31).cdhistor := PREJ0005.vr_cdhistordsct_est_jur_prej;   --2777 ESTORNO JUROS PREJUIZO
      vr_tab_craphis(32).cdhistor := PREJ0005.vr_cdhistordsct_est_mult_atras; --2778 ESTORNO MULTA ATRASO
      vr_tab_craphis(33).cdhistor := PREJ0005.vr_cdhistordsct_est_jur_mor;    --2779 ESTORNO JUROS MORA
      vr_tab_craphis(34).cdhistor := PREJ0005.vr_cdhistordsct_est_abono;      --2690 ESTORNO ABONO
      vr_tab_craphis(35).cdhistor := PREJ0005.vr_cdhistordsct_est_preju;      --2877 ESTORNO RECUPERAÇÃO DE PREJUIZO
      --
      vr_tab_craphis(36).cdhistor := DSCT0003.vr_cdhistordsct_iofcompleoper;  --2800 DEBITO DE IOF COMPLEMENTAR NA OPERACAO

      vr_indice   := vr_tab_craphis.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_cdhistor := vr_tab_craphis(vr_indice).cdhistor;

        OPEN cr_lancborger(pr_cdcooper
                          ,pr_dtrefere
                          ,vr_cdhistor);
        FETCH cr_lancborger INTO rw_lancborger;
        IF cr_lancborger%FOUND AND (rw_lancborger.vllanmto > 0) THEN
          CLOSE cr_lancborger;

          pc_dados_historico(pr_cdcooper => pr_cdcooper
                            ,pr_cdhistor => vr_cdhistor
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Escrever linha principal com informações de data, contas, valor total e histórico
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         rw_craphis2.nrctadeb||','||
                         rw_craphis2.nrctacrd||','||
                         trim(to_char(rw_lancborger.vllanmto, '99999999999990.00'))||','||
                         rw_craphis2.cdhstctb||','||
                         '"('||vr_cdhistor||') '||rw_craphis2.dsexthst||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          -- Escrever linha detalhada conforme dados contábeis do histórico
          --   tpctbccu: Tipo de Contab. Centro Custo - Contabilizar Gerencial (0-Não, 1-Por centro de custo)
          --   ingerdeb: Gerencial a Débito  (1-Não, 2-Geral, 3-PA)
          --   ingercre: Gerencial a Crédito (1-Não, 2-Geral, 3-PA)

          IF rw_craphis2.tpctbccu = 1 THEN
            -- Conta a Debitar
            IF rw_craphis2.ingerdeb = 2 THEN
              vr_linhadet := '999,'||trim(to_char(rw_lancborger.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            ELSIF rw_craphis2.ingerdeb = 3 THEN
              FOR rw_lancbor in cr_lancborage(pr_cdcooper
                                             ,pr_dtrefere
                                             ,vr_cdhistor) LOOP
                vr_linhadet := to_char(rw_lancbor.cdccuage, 'fm000')||','||
                               trim(to_char(rw_lancbor.vllanmto, '999999990.00'));
                cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              END LOOP;
            END IF;

            -- Conta a Creditar
            IF rw_craphis2.ingercre = 2 THEN
              vr_linhadet := '999,'||trim(to_char(rw_lancborger.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            ELSIF rw_craphis2.ingercre = 3 THEN
              FOR rw_lancbor in cr_lancborage(pr_cdcooper
                                             ,pr_dtrefere
                                             ,vr_cdhistor) LOOP
                vr_linhadet := to_char(rw_lancbor.cdccuage, 'fm000')||','||
                               trim(to_char(rw_lancbor.vllanmto, '999999990.00'));
                cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              END LOOP;
            END IF;

          ELSE
            vr_linhadet := '999,'||trim(to_char(rw_lancborger.vllanmto, '999999990.00'));

            -- Conta a Debitar
            IF rw_craphis2.ingerdeb = 2 THEN
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            END IF;

            -- Conta a Creditar
            IF rw_craphis2.ingercre = 2 THEN
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            END IF;
          END IF;
        ELSE
          CLOSE cr_lancborger;
        END IF;

        vr_indice := vr_tab_craphis.next(vr_indice);
      END LOOP;
    END pc_proc_lancbor;

    -- Procedimento mensal
    procedure pc_proc_cbl_mensal (pr_cdcooper in cecred.craptab.cdcooper%type) is
      -- Juros de descontos de cheques
      cursor cr_crapljd (pr_cdcooper in cecred.crapljd.cdcooper%type,
                         pr_dtrefere in cecred.crapljd.dtrefere%type) is
        select nrdconta,
               vldjuros
          from cecred.crapljd
         where crapljd.cdcooper = pr_cdcooper
           and crapljd.dtrefere = pr_dtrefere;
      -- Juros de descontos de títulos
      cursor cr_crapljt (pr_cdcooper in cecred.crapljt.cdcooper%type,
                         pr_dtrefere in cecred.crapljt.dtrefere%type) is
        select crapljt.cdcooper,
               crapljt.nrdconta,
               crapljt.nrborder,
               crapljt.cdbandoc,
               crapljt.nrdctabb,
               crapljt.nrcnvcob,
               crapljt.nrdocmto,
               crapljt.vldjuros,
               crapljt.vlrestit,
               crapljt.dtrefere,
               crapljt.rowid
          from cecred.crapbdt
              ,cecred.crapljt
         where crapbdt.flverbor = 0
           AND crapbdt.nrborder = crapljt.nrborder
           AND crapbdt.cdcooper = crapljt.cdcooper
           AND crapljt.cdcooper = pr_cdcooper
           and crapljt.dtrefere >= pr_dtrefere;
      -- Contratos de limite de crédito
      cursor cr_craplim (pr_cdcooper in cecred.craplim.cdcooper%type,
                         pr_tpctrlim in cecred.craplim.tpctrlim%type,
                         pr_insitlim in cecred.craplim.insitlim%type) is
        SELECT ass.cdagenci, lim.vllimite
          FROM cecred.craplim lim, cecred.crapass ass
         WHERE lim.cdcooper = ass.cdcooper
           AND lim.nrdconta = ass.nrdconta
           AND lim.cdcooper = pr_cdcooper
           AND lim.tpctrlim = pr_tpctrlim
           AND lim.insitlim = pr_insitlim
         ORDER BY lim.cdcooper, ass.cdagenci;

      -- Títulos de borderô
      cursor cr_craptdb6 (pr_cdcooper in cecred.craptdb.cdcooper%type,
                          pr_nrdconta in cecred.craptdb.nrdconta%type,
                          pr_nrborder in cecred.craptdb.nrborder%type,
                          pr_cdbandoc in cecred.craptdb.cdbandoc%type,
                          pr_nrdctabb in cecred.craptdb.nrdctabb%type,
                          pr_nrcnvcob in cecred.craptdb.nrcnvcob%type,
                          pr_nrdocmto in cecred.craptdb.nrdocmto%type,
                          pr_insittit in cecred.craptdb.insittit%type) is
        select craptdb.rowid,
               craptdb.cdcooper,
               craptdb.dtdpagto,
               craptdb.cdbandoc,
               craptdb.nrdctabb,
               craptdb.nrcnvcob,
               craptdb.nrdconta,
               craptdb.nrdocmto,
               crapbdt.flverbor
          from cecred.crapbdt
              ,cecred.craptdb
         where crapbdt.nrborder = craptdb.nrborder
           AND crapbdt.cdcooper = craptdb.cdcooper
           AND craptdb.cdcooper = pr_cdcooper
           and craptdb.nrdconta = pr_nrdconta
           and craptdb.nrborder = pr_nrborder
           and craptdb.cdbandoc = pr_cdbandoc
           and craptdb.nrdctabb = pr_nrdctabb
           and craptdb.nrcnvcob = pr_nrcnvcob
           and craptdb.nrdocmto = pr_nrdocmto
           and craptdb.insittit = pr_insittit;
      rw_craptdb6     cr_craptdb6%rowtype;

      -- Informações de cotas e recursos
      cursor cr_crapcot2 (pr_cdcooper in cecred.crapcot.cdcooper%type,
                          pr_dtmvtolt in date) is
        select crapcot.vlcotant,
               crapcot.nrdconta,
               crapass.cdagenci,
               decode(to_char(pr_dtmvtolt, 'mm'),
                      '01', vlcapmes##1,  -- Janeiro
                      '02', vlcapmes##2,  -- Fevereiro
                      '03', vlcapmes##3,  -- Março
                      '04', vlcapmes##4,  -- Abril
                      '05', vlcapmes##5,  -- Maio
                      '06', vlcapmes##6,  -- Junho
                      '07', vlcapmes##7,  -- Julho
                      '08', vlcapmes##8,  -- Agosto
                      '09', vlcapmes##9,  -- Setembro
                      '10', vlcapmes##10, -- Outubro
                      '11', vlcapmes##11, -- Novembro
                      '12', vlcapmes##12) vlcapmes  -- Dezembro
          from cecred.crapcot,cecred.crapass
         where crapass.cdcooper = crapcot.cdcooper
           AND crapass.nrdconta = crapcot.nrdconta
           AND crapass.dtdemiss IS NULL
           AND crapcot.cdcooper = pr_cdcooper
           ORDER BY crapass.cdagenci;

      TYPE typ_cr_crapcot2 IS TABLE OF cr_crapcot2%ROWTYPE index by PLS_INTEGER;
      rw_crapcot2 typ_cr_crapcot2;

      -- Subscrição de capital realizado
      cursor cr_crapsdc2 (pr_cdcooper in cecred.crapsdc.cdcooper%type,
                          pr_nrdconta in cecred.crapsdc.nrdconta%type) is
        select /*+ index (crapsdc crapsdc##crapsdc2)*/
               vllanmto
          from cecred.crapsdc
         where crapsdc.cdcooper = pr_cdcooper
           and crapsdc.nrdconta = pr_nrdconta
           and crapsdc.dtdebito is null;

      -- Lançamentos de empréstimos
      cursor cr_craplem (pr_cdcooper in cecred.craplem.cdcooper%type,
                         pr_dtmvtolt in cecred.craplem.dtmvtolt%type) is
        select /*+ index (craplem craplem##craplem4)*/
               craplem.cdcooper,
               craplem.nrdconta,
               craplem.vllanmto
          from cecred.craplem
         where craplem.cdcooper = pr_cdcooper
           and craplem.dtmvtolt = pr_dtmvtolt
           and craplem.cdhistor = 120; -- SOBRAS DE EMPRESTIMOS
      -- Lançamentos em depósitos à vista
      cursor cr_craplcm3 (pr_cdcooper in cecred.craplcm.cdcooper%type,
                          pr_dtmvtolt in cecred.craplcm.dtmvtolt%type) is
        select /*+ index (craplcm craplcm##craplcm4)*/
               craplcm.nrdconta,
               craplcm.vllanmto
          from cecred.craplcm
         where craplcm.cdcooper = pr_cdcooper
           and craplcm.dtmvtolt = pr_dtmvtolt
           and craplcm.cdhistor in (2061,2062);
      -- Lançamentos de cotas/capital
      cursor cr_craplct (pr_cdcooper in cecred.craplcm.cdcooper%type,
                         pr_dtultdma in cecred.craplcm.dtmvtolt%type,
                         pr_dtmvtolt in cecred.craplcm.dtmvtolt%type,
                         pr_cdhistor in cecred.craplcm.cdhistor%type) is
        select craplct.nrdconta,
               craplct.vllanmto
          from cecred.craplct
         where craplct.cdcooper = pr_cdcooper
           and craplct.dtmvtolt > pr_dtultdma
           and craplct.dtmvtolt <= pr_dtmvtolt
           and craplct.cdhistor = pr_cdhistor;
      -- Saldos em Depositos a Vista para Pessoa Fisica
      /*
         Alterado para não pegar as contas ente público
      */
      cursor cr_crapass3 (pr_cdcooper in cecred.crapass.cdcooper%type,
                          pr_inpessoa in cecred.crapass.inpessoa%type) is
        select crapass.nrdconta,
               crapass.dtmvtolt,
               crapass.cdagenci
          from cecred.crapass, cecred.tbcc_tipo_conta tipo_conta
         where crapass.cdcooper = pr_cdcooper
           and crapass.dtelimin is null
           and crapass.inpessoa = pr_inpessoa
           and tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo <> 4;
      -- Saldos em Depositos a Vista para Ente Público por nat jur
      cursor cr_crapass4 (pr_cdcooper in cecred.crapass.cdcooper%type,
                          pr_inpessoa in cecred.crapass.inpessoa%type,
                          pr_cdgrpnat in cecred.gncdntj.cdgrpnat%type) is
        select crapass.nrdconta,
               crapass.dtmvtolt,
               crapass.cdagenci
          from cecred.crapass, cecred.tbcc_tipo_conta tipo_conta, cecred.crapjur, cecred.gncdntj
         where crapass.cdcooper = pr_cdcooper
           and crapass.dtelimin is null
           and crapass.inpessoa = pr_inpessoa
           and tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo = 4
           and crapjur.cdcooper = crapass.cdcooper
           and crapjur.nrdconta = crapass.nrdconta
           and gncdntj.cdnatjur = crapjur.natjurid
           and gncdntj.flentpub = 1
           and gncdntj.cdgrpnat = pr_cdgrpnat
           ;

      -- Saldos da conta investimento
      cursor cr_crapsli (pr_cdcooper in cecred.crapsli.cdcooper%type,
                         pr_dtultdia in cecred.crapsli.dtrefere%type) is
        select crapsli.nrdconta,
               crapsli.vlsddisp
          from cecred.crapsli
         where crapsli.cdcooper = pr_cdcooper
           and crapsli.dtrefere = pr_dtultdia;
      -- Desconto de cheques
      cursor cr_crapcdb4 (pr_cdcooper in cecred.crapcdb.cdcooper%type,
                          pr_dtmvtolt in cecred.crapcdb.dtlibera%type,
                          pr_dtmvtopr in cecred.crapcdb.dtlibera%type) is
        select /*+ index (crapcdb crapcdb##crapcdb3)*/
               crapcdb.nrdconta,
               sum(crapcdb.vlcheque) vlcheque
          from cecred.crapcdb
         where crapcdb.cdcooper = pr_cdcooper
           and crapcdb.dtlibera > pr_dtmvtolt
           and crapcdb.dtlibbdc < pr_dtmvtopr
           AND crapcdb.insitana = 1 --> Apenas aprovados
           and ( crapcdb.dtdevolu is null
                 OR
                (crapcdb.dtdevolu is not null AND
                 crapcdb.dtdevolu > pr_dtmvtolt)
                )
         group by crapcdb.nrdconta
         order by crapcdb.nrdconta;
      -- Provisão de receita com desconto de cheques
      cursor cr_crapljd2 (pr_cdcooper in cecred.crapljd.cdcooper%type,
                          pr_dtultdia in cecred.crapljd.dtrefere%type) is
        select crapljd.nrdconta,
               sum(crapljd.vldjuros) vldjuros
          from cecred.crapljd
         where crapljd.cdcooper = pr_cdcooper
           and crapljd.dtrefere > pr_dtultdia
         group by crapljd.nrdconta
         order by crapljd.nrdconta;
      -- Provisão de receita com desconto de cheques por agencia e tipo de pessoa
      CURSOR cr_crapljd_age(pr_cdcooper in cecred.crapljd.cdcooper%type,
                            pr_dtultdia in cecred.crapljd.dtrefere%type) IS
         SELECT SUM(crapljd.vldjuros) vldjuros
               ,crapass.cdagenci
               ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
           FROM cecred.crapljd
               ,cecred.crapass
          WHERE crapljd.cdcooper = crapass.cdcooper
            AND crapljd.nrdconta = crapass.nrdconta
            AND crapljd.cdcooper = pr_cdcooper
            AND crapljd.dtrefere > pr_dtultdia
          GROUP BY crapass.cdagenci
                  ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa);
      -- Desconto de títulos de borderô
      cursor cr_craptdb7 (pr_cdcooper in cecred.craptdb.cdcooper%type,
                          pr_insittit in cecred.craptdb.insittit%type) is
        select /*+ index (craptdb craptdb##craptdb2)*/
               craptdb.vltitulo,
               craptdb.dtvencto
          from cecred.craptdb
         where craptdb.cdcooper = pr_cdcooper
           and craptdb.insittit = pr_insittit;
      -- Desconto de Titulos
      cursor cr_craptdb8 (pr_cdcooper in cecred.craptdb.cdcooper%type,
                          pr_insittit in cecred.craptdb.insittit%type,
                          pr_flgregis in cecred.crapcob.flgregis%type,
                          pr_flverbor IN cecred.crapbdt.flverbor%TYPE) is
        select /*+ index (craptdb craptdb##craptdb2)*/
               crapass.cdagenci,
               SUM(CASE WHEN crapbdt.flverbor = 1 THEN
                             craptdb.vlsldtit - craptdb.vlpagmra
                        ELSE craptdb.vltitulo
                   END) vltitulo
          from cecred.crapbdt,
               cecred.crapass,
               cecred.crapcob,
               cecred.craptdb
         where craptdb.cdcooper = pr_cdcooper
           and craptdb.insittit = pr_insittit
           and crapcob.cdcooper = craptdb.cdcooper
           and crapcob.cdbandoc = craptdb.cdbandoc
           and crapcob.nrdctabb = craptdb.nrdctabb
           and crapcob.nrcnvcob = craptdb.nrcnvcob
           and crapcob.nrdconta = craptdb.nrdconta
           and crapcob.nrdocmto = craptdb.nrdocmto
           and crapcob.flgregis = pr_flgregis
           and crapass.cdcooper = crapcob.cdcooper
           and crapass.nrdconta = crapcob.nrdconta
           AND crapbdt.nrborder = craptdb.nrborder
           AND crapbdt.cdcooper = craptdb.cdcooper
           AND crapbdt.flverbor = pr_flverbor
           AND crapbdt.inprejuz = 0
         group by crapass.cdagenci
         order by crapass.cdagenci;
      -- Desconto de Titulos por agencia e tipo de pessoa
      CURSOR cr_craptdb_age(pr_cdcooper in cecred.craptdb.cdcooper%type,
                            pr_insittit in cecred.craptdb.insittit%type,
                            pr_flgregis in cecred.crapcob.flgregis%TYPE,
                            pr_flverbor IN cecred.crapbdt.flverbor%TYPE)IS
        SELECT SUM(CASE WHEN crapbdt.flverbor = 1 THEN
                             craptdb.vlsldtit - craptdb.vlpagmra
                        ELSE craptdb.vltitulo
                   END) vltitulo
              ,crapass.cdagenci
              ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
          FROM cecred.crapbdt
              ,cecred.crapcob
              ,cecred.craptdb
              ,cecred.crapass
         WHERE crapcob.cdcooper = crapass.cdcooper
           AND crapcob.nrdconta = crapass.nrdconta
           AND craptdb.cdcooper = crapass.cdcooper
           AND craptdb.nrdconta = crapass.nrdconta
           AND craptdb.cdcooper = crapcob.cdcooper
           AND craptdb.cdbandoc = crapcob.cdbandoc
           AND craptdb.nrdctabb = crapcob.nrdctabb
           AND craptdb.nrcnvcob = crapcob.nrcnvcob
           AND craptdb.nrdconta = crapcob.nrdconta
           AND craptdb.nrdocmto = crapcob.nrdocmto
           AND craptdb.cdcooper = pr_cdcooper
           AND crapcob.flgregis = pr_flgregis
           AND craptdb.insittit = pr_insittit
           AND crapbdt.nrborder = craptdb.nrborder
           AND crapbdt.cdcooper = craptdb.cdcooper
           AND crapbdt.flverbor = pr_flverbor
           AND crapbdt.inprejuz = 0
         GROUP BY crapass.cdagenci
                 ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa);
      -- Provisao de Receita com Desconto de Titulos
      cursor cr_crapljt2 (pr_cdcooper in cecred.crapljt.cdcooper%type,
                          pr_dtultdia in cecred.crapljt.dtrefere%type,
                          pr_flgregis in cecred.crapcob.flgregis%type,
                          pr_flverbor IN cecred.crapbdt.flverbor%TYPE ) is
        select crapljt.nrdconta,
               sum(crapljt.vldjuros) vldjuros
          from cecred.crapbdt,
               cecred.crapcob,
               cecred.crapljt
         where crapljt.cdcooper = pr_cdcooper
           and crapljt.dtrefere > pr_dtultdia
           and crapcob.cdcooper = crapljt.cdcooper
           and crapcob.cdbandoc = crapljt.cdbandoc
           and crapcob.nrdctabb = crapljt.nrdctabb
           and crapcob.nrcnvcob = crapljt.nrcnvcob
           and crapcob.nrdconta = crapljt.nrdconta
           and crapcob.nrdocmto = crapljt.nrdocmto
           and crapcob.flgregis = pr_flgregis
           AND crapbdt.nrborder = crapljt.nrborder
           AND crapbdt.cdcooper = crapljt.cdcooper
           AND crapbdt.flverbor = pr_flverbor
         group by crapljt.nrdconta
         order by crapljt.nrdconta;
      -- Provisao de Receita com Desconto de Titulos por Agencia e Tipo de Pessoa
      CURSOR cr_crapljt_age (pr_cdcooper IN cecred.crapljt.cdcooper%TYPE
                            ,pr_dtultdia IN cecred.crapljt.dtrefere%TYPE
                            ,pr_flgregis IN cecred.crapcob.flgregis%TYPE
                            ,pr_flverbor IN cecred.crapbdt.flverbor%TYPE) IS
         SELECT SUM(crapljt.vldjuros) vldjuros
               ,crapass.cdagenci
               ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
           FROM cecred.crapbdt,
                cecred.crapcob,
                cecred.crapljt,
                cecred.crapass
          WHERE crapcob.cdcooper = crapljt.cdcooper
            AND crapcob.cdbandoc = crapljt.cdbandoc
            AND crapcob.nrdctabb = crapljt.nrdctabb
            AND crapcob.nrcnvcob = crapljt.nrcnvcob
            AND crapcob.nrdconta = crapljt.nrdconta
            AND crapcob.nrdocmto = crapljt.nrdocmto
            AND crapcob.cdcooper = crapass.cdcooper
            AND crapcob.nrdconta = crapass.nrdconta
            AND crapljt.cdcooper = crapass.cdcooper
            AND crapljt.nrdconta = crapass.nrdconta
            AND crapljt.cdcooper = pr_cdcooper
            and crapljt.dtrefere > pr_dtultdia
            AND crapcob.flgregis = pr_flgregis
            AND crapbdt.nrborder = crapljt.nrborder
            AND crapbdt.cdcooper = crapljt.cdcooper
            AND crapbdt.flverbor = pr_flverbor
         GROUP BY crapass.cdagenci
                 ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa)
         ORDER BY crapass.cdagenci;

      --Melhorias performance - Chamado 734422
      --Juncao dos cursores cr_craprda e cr_crapass
      -- Aplicação RDCA30, RDCA60, RDCPRE e Informações do associado

      /*
        P681 - Ente Públicos
        Criado o cursor cr_craprda_sep para não trazer os entes públicos.
        Criado o cursor cr_craprda_ep para os entes públicos.
        Mantido o cursor original por ser usado em outros processos.
      */
      cursor cr_craprda (pr_cdcooper in cecred.craprda.cdcooper%type,
                         pr_tpaplica in cecred.craprda.tpaplica%TYPE,
                         pr_dtcrps659 IN cecred.tbgen_prglog.dhfim%TYPE) is
        select /*+ index (craprda craprda##craprda2)*/
               crapass.cdagenci cdagenci,
               sum(craprda.vlslfmes) vlslfmes
          from cecred.craprda AS OF TIMESTAMP pr_dtcrps659/*flashback*/, cecred.crapass
         where craprda.nrdconta = crapass.nrdconta
           and craprda.cdcooper = crapass.cdcooper
           and craprda.tpaplica = pr_tpaplica
           and crapass.cdcooper = pr_cdcooper
         group by crapass.cdagenci
         order by crapass.cdagenci;
      TYPE typ_cr_craprda IS TABLE OF cr_craprda%ROWTYPE index by binary_integer;
      rw_craprda typ_cr_craprda;
      -- PRB0046128 - Novo cursor sem o TimeStamp
      CURSOR cr_craprda_sem_ts(pr_cdcooper IN CECRED.craprda.cdcooper%TYPE
                              ,pr_inprocesso IN CONTABILIDADE.tbcontab_arq_principal.inprocesso%TYPE
                              ,pr_dtmvtoan IN CECRED.crapdat.dtmvtoan%TYPE) IS
        SELECT cdagenci
              ,NVL(SUM(vlaplicsaldomes),0) vlslfmes
          FROM CONTABILIDADE.tbcontab_arq_principal
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtoan
           AND inprocesso = pr_inprocesso
      GROUP BY cdagenci
      ORDER BY cdagenci;

      cursor cr_craprda_sep (pr_cdcooper in cecred.craprda.cdcooper%type,
                             pr_tpaplica in cecred.craprda.tpaplica%type,
                             pr_dtcrps659 IN cecred.tbgen_prglog.dhfim%TYPE) is
        select /*+ index (craprda craprda##craprda2)*/
               crapass.cdagenci cdagenci,
               sum(craprda.vlslfmes) vlslfmes
          from cecred.craprda AS OF TIMESTAMP pr_dtcrps659, cecred.crapass, cecred.tbcc_tipo_conta tipo_conta
         where craprda.nrdconta = crapass.nrdconta
           and craprda.cdcooper = crapass.cdcooper
           and tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo <> 4
           and craprda.tpaplica = pr_tpaplica
           and crapass.cdcooper = pr_cdcooper
         group by crapass.cdagenci
         order by crapass.cdagenci;
      TYPE typ_cr_craprda_sep IS TABLE OF cr_craprda_sep%ROWTYPE index by binary_integer;
      rw_craprda_sep typ_cr_craprda_sep;
      -- PRB0046128 - Novo cursor sem o TimeStamp
      CURSOR cr_craprda_sep_sem_ts(pr_cdcooper IN CECRED.craprda.cdcooper%TYPE
                                  ,pr_inprocesso IN CONTABILIDADE.tbcontab_arq_principal.inprocesso%TYPE
                                  ,pr_dtmvtoan IN CECRED.crapdat.dtmvtoan%TYPE) IS
        SELECT cdagenci
              ,NVL(SUM(vlaplicsaldomes),0) vlslfmes
          FROM CONTABILIDADE.tbcontab_arq_principal
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtoan
           AND inprocesso = pr_inprocesso
      GROUP BY cdagenci
      ORDER BY cdagenci;

      cursor cr_craprda_ep (pr_cdcooper in cecred.craprda.cdcooper%type,
                            pr_tpaplica in cecred.craprda.tpaplica%type,
                            pr_dtcrps659 IN cecred.tbgen_prglog.dhfim%TYPE) is
        select /*+ index (craprda craprda##craprda2)*/
               crapass.cdagenci cdagenci,
               sum(craprda.vlslfmes) vlslfmes
          from cecred.craprda AS OF TIMESTAMP pr_dtcrps659, cecred.crapass, tbcc_tipo_conta tipo_conta
         where craprda.nrdconta = crapass.nrdconta
           and craprda.cdcooper = crapass.cdcooper
           and tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo = 4
           and craprda.tpaplica = pr_tpaplica
           and crapass.cdcooper = pr_cdcooper
         group by crapass.cdagenci
         order by crapass.cdagenci;
      TYPE typ_cr_craprda_ep IS TABLE OF cr_craprda_ep%ROWTYPE index by PLS_INTEGER;
      rw_craprda_ep typ_cr_craprda_ep;
      -- PRB0046128 - Novo cursor sem o TimeStamp
      CURSOR cr_craprda_ep_sem_ts(pr_cdcooper   IN CECRED.craprda.cdcooper%TYPE
                                 ,pr_inprocesso IN CONTABILIDADE.tbcontab_arq_principal.inprocesso%TYPE
                                 ,pr_dtmvtoan   IN CECRED.crapdat.dtmvtoan%TYPE) IS
        SELECT cdagenci
              ,NVL(SUM(vlaplicsaldomes),0) vlslfmes
          FROM CONTABILIDADE.tbcontab_arq_principal
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtoan
           AND inprocesso = pr_inprocesso
      GROUP BY cdagenci
      ORDER BY cdagenci;

      cursor cr_craprda_ep_munic (pr_cdcooper in cecred.craprda.cdcooper%type,
                                  pr_dtcrps659 IN cecred.tbgen_prglog.dhfim%TYPE) is
        select tbcc_associados.cdcooper||lpad(tbcc_associados.idgrupo_municipal,10,'0') cdagenci,
               sum(craprda.vlslfmes) vlslfmes
          from cecred.craprda AS OF TIMESTAMP pr_dtcrps659, cecred.crapass, cecred.tbcc_tipo_conta tipo_conta, cecred.tbcc_associados
         where craprda.nrdconta = crapass.nrdconta
           and craprda.cdcooper = crapass.cdcooper
           and tipo_conta.inpessoa = crapass.inpessoa
           and tipo_conta.cdtipo_conta = crapass.cdtipcta
           and tipo_conta.cdmodalidade_tipo = 4
           and tbcc_associados.cdcooper = crapass.cdcooper
           and tbcc_associados.nrdconta = crapass.nrdconta
           and craprda.tpaplica in (7,8)
           and ((crapass.cdcooper = pr_cdcooper and pr_cdcooper <> 3) or (crapass.cdcooper <> pr_cdcooper and pr_cdcooper = 3))
         group by tbcc_associados.cdcooper||lpad(tbcc_associados.idgrupo_municipal,10,'0');
      --p681 - ente publico
      TYPE typ_cr_craprda_ep_munic IS TABLE OF cr_craprda_ep_munic%ROWTYPE index by binary_integer;
      rw_craprda_ep_munic typ_cr_craprda_ep_munic;
      --
      -- PRB0046128 - Novo cursor sem o TimeStamp
      CURSOR cr_craprda_ep_munic_sem_ts(pr_cdcooper   IN CECRED.craprda.cdcooper%TYPE
                                       ,pr_dtmvtoan   IN CECRED.crapdat.dtmvtoan%TYPE) IS
        SELECT cdagenci
              ,NVL(SUM(vlaplicsaldomes),0) vlslfmes
          FROM CONTABILIDADE.tbcontab_arq_principal
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtoan
           AND inprocesso = CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaComEPM
      GROUP BY cdagenci
      ORDER BY cdagenci;

      -- Desconto de cheques
      cursor cr_craprpp (pr_cdcooper in cecred.craprpp.cdcooper%type,
                         pr_dtslfmes in cecred.craprpp.dtslfmes%type) is
        select /*+ index (craprpp craprpp##craprpp1)*/
               craprpp.nrdconta,
               sum(craprpp.vlslfmes) vlslfmes
          from cecred.craprpp
         where craprpp.cdcooper = pr_cdcooper
           and craprpp.dtslfmes = pr_dtslfmes
           -- and craprpp.vlslfmes > 0 -- Comentado devido a erros no relatório de Razão Contábil (Renato-Supero-06/11/2015)
         group by craprpp.nrdconta
         order by craprpp.nrdconta;
      -- Subscrição de capital a realizar
      cursor cr_crapsdc3 (pr_cdcooper in cecred.crapsdc.cdcooper%type) is
        select nrdconta,
               vllanmto
          from cecred.crapsdc
         where crapsdc.cdcooper = pr_cdcooper
           and crapsdc.indebito = 0
           and crapsdc.dtdebito is null;
      -- PL/Table utilizada para agrupar descontos de títulos
      type typ_acumltit is record (vr_vltitulo      cecred.craptdb.vltitulo%type);
      -- Definição da tabela para armazenar os registros agrupados
      type typ_tab_acumltit is table of typ_acumltit index by binary_integer;
      -- Instância da tabela.
      vr_tab_acumltit        typ_tab_acumltit;
      -- Índice da PL/Table
      vr_indice              number(3);
      -- Data de referência
      vr_dtrefere            date;

    BEGIN

      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_cbl_mensal', pr_action => NULL);

      -- Apropriacao da receita de desconto de cheques ..................
      vr_tab_agencia.delete;
      vr_dtrefere := last_day(vr_dtmvtolt);
      --
      pc_cria_agencia_pltable(999,15); -- 15 - APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      -- PRB0046128 - Busca parametro para verificar se usa ou não o recurso TIMESTAMP
      vr_usarTimeStamp := FALSE;

      -- Buscar juros de descontos de cheques
      FOR rw_crapljd IN cr_crapljd (pr_cdcooper,
                                    vr_dtrefere) LOOP

        -- Buscar dados do associado
        OPEN cr_crapass (pr_cdcooper,
                         rw_crapljd.nrdconta);
          FETCH cr_crapass INTO rw_crapass;

          pc_cria_agencia_pltable(rw_crapass.cdagenci,15);
          -- Incluir nome do módulo logado
          cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
          -- Separando as informacoes em PF e PJ
          IF rw_crapass.inpessoa = 1 THEN
             vr_arq_op_cred(15)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(15)(rw_crapass.cdagenci)(1) + rw_crapljd.vldjuros;
             vr_arq_op_cred(15)(999)(1) := vr_arq_op_cred(15)(999)(1) + rw_crapljd.vldjuros;
          ELSE
             vr_arq_op_cred(15)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(15)(rw_crapass.cdagenci)(2) + rw_crapljd.vldjuros;
             vr_arq_op_cred(15)(999)(2) := vr_arq_op_cred(15)(999)(2) + rw_crapljd.vldjuros;
          END IF;
          --
          vr_tab_agencia(rw_crapass.cdagenci).vr_vlaprjur := vr_tab_agencia(rw_crapass.cdagenci).vr_vlaprjur + rw_crapljd.vldjuros;
          vr_tab_agencia(999).vr_vlaprjur := vr_tab_agencia(999).vr_vlaprjur + rw_crapljd.vldjuros;
        CLOSE cr_crapass;
      END LOOP;
      -- Cria registro de total de apropriacao de juros
      if nvl(vr_tab_agencia(999).vr_vlaprjur, 0) > 0 then
        vr_cdestrut := '55';
        -- Formar a linha de detalhes
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1641,'||
                       '7131,'||
                       trim(to_char(vr_tab_agencia(999).vr_vlaprjur, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_vlaprjur, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Cria lancamentos da apropriacao dos juros por pac
        vr_indice_agencia := vr_tab_agencia.first;
        -- Percorre todas as agencias
        while vr_indice_agencia <= 998 loop
          if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
             vr_tab_agencia(vr_indice_agencia).vr_vlaprjur > 0 then
            vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vlaprjur, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
        end loop;
      end if;
      -- Contabilizacao do saldo de limite de descontos de cheques ...........
      vr_tab_agencia(1).vr_vlaprjur := 0;
      vr_tab_limcon.DELETE;
      for rw_craplim in cr_craplim (pr_cdcooper,
                                    2, -- tpctrlim
                                    2  -- insitlim
                                     ) loop
        vr_tab_agencia(1).vr_vlaprjur := vr_tab_agencia(1).vr_vlaprjur + rw_craplim.vllimite;
        vr_tab_limcon(rw_craplim.cdagenci).cdagenci := rw_craplim.cdagenci;
        vr_tab_limcon(rw_craplim.cdagenci).valor := NVL(vr_tab_limcon(rw_craplim.cdagenci).valor,0) + rw_craplim.vllimite;
      end loop;
      --
      if vr_tab_agencia(1).vr_vlaprjur > 0 then
        vr_cdestrut := '51';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '3813,'||
                       '9184,'||
                       trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE CHEQUES."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        -- Percorre todas as agencias e grava no arquivo
        vr_indice := vr_tab_limcon.first;
        WHILE vr_indice IS NOT NULL LOOP
          vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                         TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));
          -- Grava a linha no arquivo
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro

          vr_indice := vr_tab_limcon.next(vr_indice);
        END LOOP;

        -- Reversao
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                       '9184,'||
                       '3813,'||
                       trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE CHEQUES."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        -- Percorre todas as agencias e grava no arquivo
        vr_indice := vr_tab_limcon.first;
        WHILE vr_indice IS NOT NULL LOOP
          vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                         TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));
          -- Grava a linha no arquivo
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro

          vr_indice := vr_tab_limcon.next(vr_indice);
        END LOOP;

      end if;
      -- Apropriacao da receita de desconto de titulos ..................
      vr_tab_agencia.delete;
      vr_dtrefere := last_day(vr_dtmvtolt);
      --
      pc_cria_agencia_pltable(999,12); -- 12 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO
      pc_cria_agencia_pltable(999,13); -- 13 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Buscar os juros de descontos de títulos
      for rw_crapljt in cr_crapljt (pr_cdcooper,
                                    vr_dtrefere) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapljt.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        -- Borderô de desconto de títulos
        begin
          -- Busca titulos do Bordero de desconto de titulos
          open cr_craptdb6 (pr_cdcooper,
                            rw_crapljt.nrdconta,
                            rw_crapljt.nrborder,
                            rw_crapljt.cdbandoc,
                            rw_crapljt.nrdctabb,
                            rw_crapljt.nrcnvcob,
                            rw_crapljt.nrdocmto,
                            2);
            fetch cr_craptdb6 into rw_craptdb6;
            -- Verifica se o título foi pago, para descartar o registro
            if cr_craptdb6%found then
              if ((to_char(rw_craptdb6.dtdpagto, 'yyyy') = to_char(vr_dtrefere, 'yyyy') and
                   to_char(rw_craptdb6.dtdpagto, 'mm') < to_char(vr_dtrefere, 'mm')) or
                  to_char(rw_craptdb6.dtdpagto, 'yyyy') < to_char(vr_dtrefere, 'yyyy')) then
                -- Se o titulo foi pago em meses anteriores ao vencimento (antecipado),
                -- nao contabiliza o juros que havia sido restituido
                close cr_craptdb6;
                continue;
              end if;
            elsif cr_craptdb6%notfound and
                  rw_crapljt.dtrefere > vr_dtrefere then
              -- Se o titulo nao foi pago, somente contabiliza o juros do mes atual
              close cr_craptdb6;
              continue;
            end if;
          close cr_craptdb6;
        end;
        -- Se for um titulo resgatado nao soma os juros restituidos pois eles
        -- ja foram lancados a debito na 1643 no dia que o titulo eh resgatado
        begin
          -- Borderô de desconto de títulos
          open cr_craptdb6 (pr_cdcooper,
                            rw_crapljt.nrdconta,
                            rw_crapljt.nrborder,
                            rw_crapljt.cdbandoc,
                            rw_crapljt.nrdctabb,
                            rw_crapljt.nrcnvcob,
                            rw_crapljt.nrdocmto,
                            1);
            fetch cr_craptdb6 into rw_craptdb6;
            -- Se existe borderô, procura a cobrança do borderô
            -- Senão, procura a cobrança da apropriação da receita
            if cr_craptdb6%found then
              open cr_crapcob (rw_craptdb6.cdcooper,
                               rw_craptdb6.cdbandoc,
                               rw_craptdb6.nrdctabb,
                               rw_craptdb6.nrcnvcob,
                               rw_craptdb6.nrdconta,
                               rw_craptdb6.nrdocmto);
                fetch cr_crapcob into rw_crapcob;
                -- Se naum encontrar titulo em desconto
                if cr_crapcob%notfound then
                  -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
                  vr_cdcritic := 1113;
                  vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||to_char(rw_craptdb6.rowid);
                  cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                            ,pr_nmarqlog      => 'proc_batch.log'
                                            ,pr_tpexecucao    => 1 -- Job
                                            ,pr_cdcriticidade => 1 -- Medio
                                            ,pr_cdmensagem    => vr_cdcritic
                                            ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                                || vr_cdprogra || ' --> '|| vr_dscritic);
                  close cr_craptdb6;
                  close cr_crapcob;
                  continue;
                end if;
              close cr_crapcob;
              --
              pc_cria_agencia_pltable(rw_crapass.cdagenci,12);
              pc_cria_agencia_pltable(rw_crapass.cdagenci,13);
              -- Incluir nome do módulo logado
              cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
              IF rw_crapcob.flgregis = 1 THEN
                 -- Separando as informacoes por agencia e por tipo de pessoa
                 IF rw_crapass.inpessoa = 1 THEN
                    vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros;
                    vr_arq_op_cred(13)(999)(1) := vr_arq_op_cred(13)(999)(1) + rw_crapljt.vldjuros;
                 ELSE
                    vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros;
                    vr_arq_op_cred(13)(999)(2) := vr_arq_op_cred(13)(999)(2) + rw_crapljt.vldjuros;
                 END IF;

                 vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr + rw_crapljt.vldjuros;
                 vr_tab_agencia(999).vr_aprjurcr := vr_tab_agencia(999).vr_aprjurcr + rw_crapljt.vldjuros;
              ELSE

                 -- Separando as informacoes por agencia e por tipo de pessoa
                 IF rw_crapass.inpessoa = 1 THEN
                    vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros;
                    vr_arq_op_cred(12)(999)(1) := vr_arq_op_cred(12)(999)(1) + rw_crapljt.vldjuros;
                 ELSE
                    vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros;
                    vr_arq_op_cred(12)(999)(2) := vr_arq_op_cred(12)(999)(2) + rw_crapljt.vldjuros;
                 END IF;

                 vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr + rw_crapljt.vldjuros;
                 vr_tab_agencia(999).vr_aprjursr := vr_tab_agencia(999).vr_aprjursr + rw_crapljt.vldjuros;
              END IF;
            ELSE
              -- Busca informações do cadastro de bloquetos de cobranca
              open cr_crapcob (rw_crapljt.cdcooper,
                               rw_crapljt.cdbandoc,
                               rw_crapljt.nrdctabb,
                               rw_crapljt.nrcnvcob,
                               rw_crapljt.nrdconta,
                               rw_crapljt.nrdocmto);
                fetch cr_crapcob into rw_crapcob;
                -- Se naum encontrar titulo em desconto
                if cr_crapcob%notfound then
                  -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
                  vr_cdcritic := 1113;
                  vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(crapljt) = '||to_char(rw_crapljt.rowid);
                  cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro de Negócio
                                            ,pr_nmarqlog      => 'proc_batch.log'
                                            ,pr_tpexecucao    => 1 -- Job
                                            ,pr_cdcriticidade => 1 -- Medio
                                            ,pr_cdmensagem    => vr_cdcritic
                                            ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                                || vr_cdprogra || ' --> '|| vr_dscritic);
                  close cr_craptdb6;
                  close cr_crapcob;
                  continue;
                end if;
              close cr_crapcob;
              --
              pc_cria_agencia_pltable(rw_crapass.cdagenci,12);
              pc_cria_agencia_pltable(rw_crapass.cdagenci,13);
              -- Incluir nome do módulo logado
              cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
              IF rw_crapcob.flgregis = 1 THEN

                 -- Separando as informacoes por agencia e por tipo de pessoa
                 IF rw_crapass.inpessoa = 1 THEN
                    vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                    vr_arq_op_cred(13)(999)(1) := vr_arq_op_cred(13)(999)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 ELSE
                    vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros + + rw_crapljt.vlrestit;
                    vr_arq_op_cred(13)(999)(2) := vr_arq_op_cred(13)(999)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 END IF;

                 vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 vr_tab_agencia(999).vr_aprjurcr := vr_tab_agencia(999).vr_aprjurcr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
              ELSE

                 -- Separando as informacoes por agencia e por tipo de pessoa
                 IF rw_crapass.inpessoa = 1 THEN
                    vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                    vr_arq_op_cred(12)(999)(1) := vr_arq_op_cred(12)(999)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 ELSE
                    vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                    vr_arq_op_cred(12)(999)(2) := vr_arq_op_cred(12)(999)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 END IF;

                 vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                 vr_tab_agencia(999).vr_aprjursr := vr_tab_agencia(999).vr_aprjursr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
              END IF;
            end if;
          close cr_craptdb6;
        end;
      end loop; -- Fim do loop na crapljt
      -- Cria registro de total de apropriacao de juros - sem registro
      if nvl(vr_tab_agencia(999).vr_aprjursr, 0) > 0 then
        vr_cdestrut := '55';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1643,'||
                       '7132,'||
                       trim(to_char(vr_tab_agencia(999).vr_aprjursr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_aprjursr, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Cria lancamentos da apropriacao dos juros por pac
        vr_indice_agencia := vr_tab_agencia.first;
        while vr_indice_agencia <= 998 loop
          if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
             vr_tab_agencia(vr_indice_agencia).vr_aprjursr > 0 then
            vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_aprjursr, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
        end loop;
      end if;
      -- Cria registro de total de apropriacao de juros - com registro
      if nvl(vr_tab_agencia(999).vr_aprjurcr, 0) > 0 then
        vr_cdestrut := '55';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1645,'||
                       '7132,'||
                       trim(to_char(vr_tab_agencia(999).vr_aprjurcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_aprjurcr, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Cria lancamentos da apropriacao dos juros por pac
        vr_indice_agencia := vr_tab_agencia.first;
        while vr_indice_agencia <= 998 loop
          if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
             vr_tab_agencia(vr_indice_agencia).vr_aprjurcr > 0 then
            vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_aprjurcr, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
        end loop;
      end if;

      -- lançamentos de bordero desconto de titulos
      pc_proc_lancbor(vr_dtmvtolt);

      -- Contabilizacao do saldo de limite de descontos de titulos ...........
      vr_tab_agencia(1).vr_vlaprjur := 0;
      vr_tab_limcon.DELETE;
      -- Buscar limites ativos
      for rw_craplim in cr_craplim (pr_cdcooper,
                                    3, -- tpctrlim
                                    2  -- insitlim
                                     ) loop
        vr_tab_agencia(1).vr_vlaprjur := vr_tab_agencia(1).vr_vlaprjur + rw_craplim.vllimite;
        vr_tab_limcon(rw_craplim.cdagenci).cdagenci := rw_craplim.cdagenci;
        vr_tab_limcon(rw_craplim.cdagenci).valor := NVL(vr_tab_limcon(rw_craplim.cdagenci).valor,0) + rw_craplim.vllimite;
      end loop;
      --
      if vr_tab_agencia(1).vr_vlaprjur > 0 then
        vr_cdestrut := '51';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '3815,'||
                       '9186,'||
                       trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE TITULOS."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        -- Percorre todas as agencias e grava no arquivo
        vr_indice := vr_tab_limcon.first;
        WHILE vr_indice IS NOT NULL LOOP
          vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                         TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));
          -- Grava a linha no arquivo
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro

          vr_indice := vr_tab_limcon.next(vr_indice);
        END LOOP;

        -- Reversao
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                       '9186,'||
                       '3815,'||
                       trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE TITULOS."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        -- Percorre todas as agencias e grava no arquivo
        vr_indice := vr_tab_limcon.first;
        WHILE vr_indice IS NOT NULL LOOP
          vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                         TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));
          -- Grava a linha no arquivo
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro

          vr_indice := vr_tab_limcon.next(vr_indice);
        END LOOP;

      end if;

      -- Contabilizacao para orcamento (Realizado)............................
      vr_cdcritic := 0;
      cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 1 -- Informação
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 0 -- Baixa
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Inicio da contabilizacao para o orcamento (realizado)');

      -- Capital .............................................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      -- Percorrer informacoes referentes a cotas e recursos
      OPEN cr_crapcot2 (pr_cdcooper,
                        vr_dtmvtolt);
      LOOP
        FETCH cr_crapcot2 BULK COLLECT INTO rw_crapcot2 LIMIT 5000;
        EXIT WHEN rw_crapcot2.count = 0;

        FOR i IN 1..rw_crapcot2.count LOOP

          vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_cdagenci := rw_crapcot2(i).cdagenci;
          if to_char(vr_dtmvtolt, 'yyyy') = to_char(vr_dtmvtopr, 'yyyy') then
            vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto, 0) + rw_crapcot2(i).vlcapmes;
            vr_vltotorc := vr_vltotorc + rw_crapcot2(i).vlcapmes;
          else
            vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto, 0) + rw_crapcot2(i).vlcotant;
            vr_vltotorc := vr_vltotorc + rw_crapcot2(i).vlcotant;
          end if;
          --
          for rw_crapsdc2 in cr_crapsdc2 (pr_cdcooper,
                                          rw_crapcot2(i).nrdconta) loop
            vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapcot2(i).cdagenci).vr_vllanmto, 0) + rw_crapsdc2.vllanmto;
            vr_vltotorc := vr_vltotorc + rw_crapsdc2.vllanmto;
          end loop;
        END LOOP;
        rw_crapcot2.delete;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',6112,';
      vr_dshstorc := '"(crps249) CAPITAL REALIZADO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',6112,';
      vr_dshstorc := '"(crps249) REVERSAO DO CAPITAL REALIZADO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Capital a realizar ..................................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      --
      -- Buscar registros para subscricao do capital dos associados admitidos
      for rw_crapsdc3 in cr_crapsdc3 (pr_cdcooper) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapsdc3.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapsdc3.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_crapsdc3.vllanmto;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',6122,';
      vr_dshstorc := '"(crps249) CAPITAL A REALIZAR."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',6122,';
      vr_dshstorc := '"(crps249) REVERSAO DO CAPITAL A REALIZAR."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Emprestimos 0229 ....................................................

      -- Sobras de emprestimos ...............................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      -- Percorrer lancamentos em emprestimos. (D-08)
      for rw_craplem in cr_craplem (pr_cdcooper,
                                    vr_dtmvtolt) loop
        -- Buscar dados do associado
        open cr_crapass (pr_cdcooper,
                         rw_craplem.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplem.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_craplem.vllanmto;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4191,';
      vr_dshstorc := '"(crps249) SOBRAS DE EMPRESTIMOS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4191,';
      vr_dshstorc := '"(crps249) REVERSAO DAS SOBRAS DE EMPRESTIMOS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Exclusao de cooperados .............................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      -- Percorrer lancamentos em depositos a vista
      for rw_craplcm3 in cr_craplcm3 (pr_cdcooper,
                                      vr_dtmvtolt) loop
        -- Dados do associado
        open cr_crapass (pr_cdcooper,
                         rw_craplcm3.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplcm3.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_craplcm3.vllanmto;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4113,';
      vr_dshstorc := '"(crps249) DEBITO EXCLUSAO DISPONIVEL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4113,';
      vr_dshstorc := '"(crps249) REVERSAO DEBITO EXCLUSAO DISPONIVEL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      -- Procapcred  .............................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      -- Percorrer lancamentos de cotas/capital
      for rw_craplct in cr_craplct (pr_cdcooper,
                                    vr_dtultdma,
                                    vr_dtmvtolt,
                                    930) loop
        open cr_crapass (pr_cdcooper,
                         rw_craplct.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplct.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_craplct.vllanmto;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',6114,';
      vr_dshstorc := '"(crps249) PROCAPCRED."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',6114,';
      vr_dshstorc := '"(crps249) REVERSAO PROCAPCRED."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;

      -- Saldos em Depositos a Vista para Pessoa Fisica .....................
      for rw_crapass3 in cr_crapass3 (pr_cdcooper,
                                      1) loop

        pc_proc_saldo_dep_vista (pr_cdcooper,
                                 rw_crapass3.nrdconta,
                                 vr_dtmvtolt,
                                 rw_crapass3.cdagenci);

      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4112,';
      vr_dshstorc := '"(crps249) DEPOSITO A VISTA PESSOA FISICA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4112,';
      vr_dshstorc := '"(crps249) REVERSAO DO DEPOSITO A VISTA PESSOA FISICA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;
      vr_tab_cratorc.delete;

      -- Saldos em Depositos a Vista para Pessoa Juridica ...................
      for rw_crapass3 in cr_crapass3 (pr_cdcooper,
                                      2) loop
        pc_proc_saldo_dep_vista (pr_cdcooper,
                                 rw_crapass3.nrdconta,
                                 vr_dtmvtolt,
                                 rw_crapass3.cdagenci);
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4120,';
      vr_dshstorc := '"(crps249) DEPOSITO A VISTA PESSOA JURIDICA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4120,';
      vr_dshstorc := '"(crps249) REVERSAO DO DEPOSITO A VISTA PESSOA JURIDICA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;
      vr_tab_cratorc.delete;
      -- Saldos em Depositos a Vista para Ente Público ADM Direta Muni ...................
      for rw_crapass4 in cr_crapass4 (pr_cdcooper,
                                      2,
                                      1) loop
        pc_proc_saldo_dep_vista (pr_cdcooper,
                                 rw_crapass4.nrdconta,
                                 vr_dtmvtolt,
                                 rw_crapass4.cdagenci);
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4127,';
      vr_dshstorc := '"(crps249) - DEPOSITO A VISTA ENTES PUBLICOS - ADMINISTRACAO DIRETA MUNICIPAL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4127,';
      vr_dshstorc := '"(crps249) - REVERSAO DO DEPOSITO A VISTA ENTES PUBLICOS - ADMINISTRACAO DIRETA MUNICIPAL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;
      vr_tab_cratorc.delete;
      -- Saldos em Depositos a Vista para Ente Público ADM Indireta Muni ...................
      for rw_crapass4 in cr_crapass4 (pr_cdcooper,
                                      2,
                                      2) loop
        pc_proc_saldo_dep_vista (pr_cdcooper,
                                 rw_crapass4.nrdconta,
                                 vr_dtmvtolt,
                                 rw_crapass4.cdagenci);
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4128,';
      vr_dshstorc := '"(crps249) - DEPOSITO A VISTA ENTES PUBLICOS - ADMINISTRACAO INDIRETA MUNICIPAL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4128,';
      vr_dshstorc := '"(crps249) - REVERSAO DO DEPOSITO A VISTA ENTES PUBLICOS - ADMINISTRACAO INDIRETA MUNICIPAL."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;
      vr_tab_cratorc.delete;
      -- Saldos em Depositos a Vista para Ente Público Ativ Emp Muni ...................
      for rw_crapass4 in cr_crapass4 (pr_cdcooper,
                                      2,
                                      3) loop
        pc_proc_saldo_dep_vista (pr_cdcooper,
                                 rw_crapass4.nrdconta,
                                 vr_dtmvtolt,
                                 rw_crapass4.cdagenci);
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4129,';
      vr_dshstorc := '"(crps249) - DEPOSITO A VISTA ENTES PUBLICOS - ATIVIDADES EMPRESARIAIS MUNICIPAIS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4129,';
      vr_dshstorc := '"(crps249) - REVERSAO DO DEPOSITO A VISTA ENTES PUBLICOS - ATIVIDADES EMPRESARIAIS MUNICIPAIS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;

      vr_vltotorc := 0;
      vr_tab_cratorc.delete;
      -- Saldos em Contas Investimento .......................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_crapsli in cr_crapsli (pr_cdcooper,
                                    vr_dtultdia) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapsli.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapsli.vlsddisp;
        vr_vltotorc := vr_vltotorc + rw_crapsli.vlsddisp;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4292,';
      vr_dshstorc := '"(crps249) CONTA INVESTIMENTO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4292,';
      vr_dshstorc := '"(crps249) REVERSAO DA CONTA INVESTIMENTO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Desconto de Cheques .................................................
      pc_cria_agencia_pltable(999,2);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_crapcdb4 in cr_crapcdb4 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_dtmvtopr => vr_dtmvtopr
                                      ) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapcdb4.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        pc_cria_agencia_pltable(rw_crapass.cdagenci,2);
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
        -- Separando as informacoes por agencia e tipo de pessoa
        IF rw_crapass.inpessoa = 1 THEN
           vr_arq_op_cred(2)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(2)(rw_crapass.cdagenci)(1) + rw_crapcdb4.vlcheque;
           vr_arq_op_cred(2)(999)(1) := vr_arq_op_cred(2)(999)(1) + rw_crapcdb4.vlcheque;
        ELSE
           vr_arq_op_cred(2)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(2)(rw_crapass.cdagenci)(2) + rw_crapcdb4.vlcheque;
           vr_arq_op_cred(2)(999)(2) := vr_arq_op_cred(2)(999)(2) + rw_crapcdb4.vlcheque;
        END IF;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapcdb4.vlcheque;
        vr_vltotorc := vr_vltotorc + rw_crapcdb4.vlcheque;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1641,';
      vr_dshstorc := '"(crps249) DESCONTO DE CHEQUE."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1641,';
      vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE CHEQUES."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Provisao de Receita com Desconto de Cheques .........................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      -- Percorre os lancamentos de juros de desconto de cheques
      for rw_crapljd2 in cr_crapljd2 (pr_cdcooper,
                                      vr_dtultdia) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapljd2.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljd2.vldjuros;
        vr_vltotorc := vr_vltotorc + rw_crapljd2.vldjuros;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1641,';
      vr_dshstorc := '"(crps249) RECEITA DE DESCONTO DE CHEQUE."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1641,';
      vr_dshstorc := '"(crps249) REVERSAO DA RECEITA DE DESCONTO DE CHEQUE."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- RECEITA DE DESCONTO DE CHEQUE -- Dados para contabilidade
      -- Inicializa a Pl-Table
      vr_arq_op_cred(7)(999)(1) := 0;
      vr_arq_op_cred(7)(999)(2) := 0;
      FOR rw_crapljd_age IN cr_crapljd_age(pr_cdcooper,
                                           vr_dtultdia) LOOP
         vr_arq_op_cred(7)(rw_crapljd_age.cdagenci)(rw_crapljd_age.inpessoa) := rw_crapljd_age.vldjuros;
         vr_arq_op_cred(7)(999)(rw_crapljd_age.inpessoa) := vr_arq_op_cred(7)(999)(rw_crapljd_age.inpessoa) + rw_crapljd_age.vldjuros;
      END LOOP;

      vr_dtiniexc := SYSDATE;
      if to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') then
        -- Desconto de Titulos .................................................
        for rw_craptdb7 in cr_craptdb7 (pr_cdcooper,
                                        4) loop

            -- Alteracao tarefa 34547 (Henrique)
            -- Verifica se é o ultimo dia do mes
            if rw_craptdb7.dtvencto < vr_dtmvtolt + 90 then
              vr_indice := 1;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 180 then
              vr_indice := 2;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 270 then
              vr_indice := 3;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 360 then
              vr_indice := 4;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 720 then
              vr_indice := 5;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1080 then
              vr_indice := 6;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1440 then
              vr_indice := 7;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1800 then
              vr_indice := 8;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2160 then
              vr_indice := 9;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2520 then
              vr_indice := 10;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2880 then
              vr_indice := 11;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3240 then
              vr_indice := 12;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3600 then
              vr_indice := 13;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3960 then
              vr_indice := 14;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 4320 then
              vr_indice := 15;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 4680 then
              vr_indice := 16;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 5040 then
              vr_indice := 17;
            elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 5400 then
              vr_indice := 18;
            elsif rw_craptdb7.dtvencto >= vr_dtmvtolt + 5400 then
              vr_indice := 19;
            end if;

        end loop;
      end if;
      vr_dtdurexc := to_date(to_char(SYSDATE,'sssss') - to_char(vr_dtiniexc,'sssss'),'SSSSS');

      pc_log_programa(PR_DSTIPLOG      => 'O',
                          PR_CDPROGRAMA   => vr_cdprogra ,
                          pr_cdcooper     => pr_cdcooper,
                          pr_tpexecucao   => 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia => 4,
                          pr_dsmensagem   => 'cr_craptdb7 [linha: 6845] executou em: ' || to_char(vr_dtdurexc,'hh24:mi:ss'),
                          PR_IDPRGLOG     => vr_idprglog);

      -- Desconto de título sem registro
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_craptdb8 in cr_craptdb8 (pr_cdcooper,
                                      4,
                                      0,
                                      0) loop
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_cdagenci := rw_craptdb8.cdagenci;
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto, 0) + rw_craptdb8.vltitulo;
        vr_vltotorc := vr_vltotorc + rw_craptdb8.vltitulo;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1643,';
      vr_dshstorc := '"(crps249) DESCONTO DE TITULO S/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1643,';
      vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE TITULOS S/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- DESCONTO DE TITULO S/ REGISTRO - Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(8)(999)(1) := 0;
      vr_arq_op_cred(8)(999)(2) := 0;
      FOR rw_craptdb_age IN cr_craptdb_age(pr_cdcooper
                                          ,4
                                          ,0
                                          ,0) LOOP
         vr_arq_op_cred(8)(rw_craptdb_age.cdagenci)(rw_craptdb_age.inpessoa) := rw_craptdb_age.vltitulo;
         vr_arq_op_cred(8)(999)(rw_craptdb_age.inpessoa) := vr_arq_op_cred(8)(999)(rw_craptdb_age.inpessoa) + rw_craptdb_age.vltitulo;
      END LOOP;
      -- Desconto de título com registro
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_craptdb8 in cr_craptdb8 (pr_cdcooper,
                                      4,
                                      1,
                                      0) loop
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_cdagenci := rw_craptdb8.cdagenci;
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto, 0) + rw_craptdb8.vltitulo;
        vr_vltotorc := vr_vltotorc + rw_craptdb8.vltitulo;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1645,';
      vr_dshstorc := '"(crps249) DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1645,';
      vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE TITULOS C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- DESCONTO DE TITULO C/ REGISTRO - Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(9)(999)(1) := 0;
      vr_arq_op_cred(9)(999)(2) := 0;
      FOR rw_craptdb_age IN cr_craptdb_age(pr_cdcooper
                                          ,4
                                          ,1
                                          ,0) LOOP
         vr_arq_op_cred(9)(rw_craptdb_age.cdagenci)(rw_craptdb_age.inpessoa) := rw_craptdb_age.vltitulo;
         vr_arq_op_cred(9)(999)(rw_craptdb_age.inpessoa) := vr_arq_op_cred(9)(999)(rw_craptdb_age.inpessoa) + rw_craptdb_age.vltitulo;
      END LOOP;
      -- Desconto de título com registro da versao nova do bordero
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_craptdb8 in cr_craptdb8 (pr_cdcooper,
                                      4,
                                      1,
                                      1) loop
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_cdagenci := rw_craptdb8.cdagenci;
        vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto, 0) + rw_craptdb8.vltitulo;
        vr_vltotorc := vr_vltotorc + rw_craptdb8.vltitulo;
      end loop;
      -- Lançamentos de apropriação de juros de mora do Desconto de Títulos
      FOR rw_lancboracum2 in cr_lancboracum2(pr_cdcooper
                                      ,vr_dtmvtolt
                                      ,DSCT0003.vr_cdhistordsct_apropjurmra --2668
                                      ) LOOP
        vr_tab_cratorc(rw_lancboracum2.cdagenci).vr_cdagenci := rw_lancboracum2.cdagenci;
        vr_tab_cratorc(rw_lancboracum2.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_lancboracum2.cdagenci).vr_vllanmto, 0) + rw_lancboracum2.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_lancboracum2.vllanmto;
      END LOOP;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1630,';
      vr_dshstorc := '"(crps249) DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',1630,';
      vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE TITULOS C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- DESCONTO DE TITULO C/ REGISTRO  versao nova do bordero - Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(20)(999)(1) := 0;
      vr_arq_op_cred(20)(999)(2) := 0;
      FOR rw_craptdb_age IN cr_craptdb_age(pr_cdcooper
                                          ,4
                                          ,1
                                          ,1) LOOP
         vr_arq_op_cred(20)(rw_craptdb_age.cdagenci)(rw_craptdb_age.inpessoa) := rw_craptdb_age.vltitulo;
         vr_arq_op_cred(20)(999)(rw_craptdb_age.inpessoa)                     := vr_arq_op_cred(20)(999)(rw_craptdb_age.inpessoa) + rw_craptdb_age.vltitulo;
      END LOOP;
      -- Lançamentos de apropriação de juros de mora do Desconto de Títulos
      FOR rw_lancboracum in cr_lancboracum(pr_cdcooper
                                      ,vr_dtmvtolt
                                      ,DSCT0003.vr_cdhistordsct_apropjurmra --2668
                                      ) LOOP
         vr_arq_op_cred(20)(rw_lancboracum.cdagenci)(rw_lancboracum.inpessoa) := vr_arq_op_cred(20)(rw_lancboracum.cdagenci)(rw_lancboracum.inpessoa) + rw_lancboracum.vllanmto;
         vr_arq_op_cred(20)(999)(rw_lancboracum.inpessoa)                 := vr_arq_op_cred(20)(999)(rw_lancboracum.inpessoa) + rw_lancboracum.vllanmto;
      END LOOP;
      -- Provisao de Receita com Desconto de Titulos com registro ............
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_crapljt2 in cr_crapljt2 (pr_cdcooper,
                                      vr_dtultdia,
                                      0,
                                      0) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapljt2.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljt2.vldjuros;
        vr_vltotorc := vr_vltotorc + rw_crapljt2.vldjuros;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1643,';
      vr_dshstorc := '"(crps249) RENDA DE DESCONTO DE TITULO S/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1643,';
      vr_dshstorc := '"(crps249) REVERSAO DA RENDA DE DESCONTO DE TITULO S/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Separacao por agencia e por tipo de pessoa -- Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(10)(999)(1) := 0;
      vr_arq_op_cred(10)(999)(2) := 0;
      FOR rw_crapljt_age IN cr_crapljt_age(pr_cdcooper,
                                           vr_dtultdia,
                                           0,
                                           0) LOOP
         -- 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO
         vr_arq_op_cred(10)(rw_crapljt_age.cdagenci)(rw_crapljt_age.inpessoa) := rw_crapljt_age.vldjuros;
         vr_arq_op_cred(10)(999)(rw_crapljt_age.inpessoa) := vr_arq_op_cred(10)(999)(rw_crapljt_age.inpessoa) + rw_crapljt_age.vldjuros;
      END LOOP;
      -- Provisao de Receita com Desconto de Titulos das versões antigas do bordero .........................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_crapljt2 in cr_crapljt2 (pr_cdcooper,
                                      vr_dtultdia,
                                      1,
                                      0) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapljt2.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljt2.vldjuros;
        vr_vltotorc := vr_vltotorc + rw_crapljt2.vldjuros;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1645,';
      vr_dshstorc := '"(crps249) RENDA DE DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1645,';
      vr_dshstorc := '"(crps249) REVERSAO DA RENDA DE DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Separacao por agencia e por tipo de pessoa -- Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(11)(999)(1) := 0;
      vr_arq_op_cred(11)(999)(2) := 0;
      FOR rw_crapljt_age IN cr_crapljt_age(pr_cdcooper,
                                           vr_dtultdia,
                                           1,
                                           0) LOOP
         -- 11 - RENDA DE DESCONTO DE TITULO C/ REGISTRO
         vr_arq_op_cred(11)(rw_crapljt_age.cdagenci)(rw_crapljt_age.inpessoa) := rw_crapljt_age.vldjuros;
         vr_arq_op_cred(11)(999)(rw_crapljt_age.inpessoa) := vr_arq_op_cred(11)(999)(rw_crapljt_age.inpessoa) + rw_crapljt_age.vldjuros;
      END LOOP;
      -- Provisao de Receita com Desconto de Titulos das versoes novas do bordero .........................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_crapljt2 in cr_crapljt2 (pr_cdcooper,
                                      vr_dtultdia,
                                      1,
                                      1) loop
        open cr_crapass (pr_cdcooper,
                         rw_crapljt2.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljt2.vldjuros;
        vr_vltotorc := vr_vltotorc + rw_crapljt2.vldjuros;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1630,';
      vr_dshstorc := '"(crps249) RENDA A APROPRIAR SOBRE DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := false; -- Conta do ATIVO
      vr_flgctred := true;  -- Redutora
      vr_lsctaorc := ',1630,';
      vr_dshstorc := '"(crps249) REVERSAO RENDA A APROPRIAR SOBRE DESCONTO DE TITULO C/ REGISTRO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Separacao por agencia e por tipo de pessoa -- Dados para contabilidade
      -- Inicializando a Pl-Table
      vr_arq_op_cred(19)(999)(1) := 0;
      vr_arq_op_cred(19)(999)(2) := 0;
      FOR rw_crapljt_age IN cr_crapljt_age(pr_cdcooper,
                                           vr_dtultdia,
                                           1,
                                           1) LOOP
         -- 19 - RENDA A APROPRIAR SOBRE DESCONTO DE TITULO C/ REGISTRO
         vr_arq_op_cred(19)(rw_crapljt_age.cdagenci)(rw_crapljt_age.inpessoa) := rw_crapljt_age.vldjuros;
         vr_arq_op_cred(19)(999)(rw_crapljt_age.inpessoa)                     := vr_arq_op_cred(19)(999)(rw_crapljt_age.inpessoa) + rw_crapljt_age.vldjuros;
      END LOOP;
      -- Aplicacao RDCA30 ....................................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda(pr_cdcooper
                       ,3
                       ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda bulk collect into rw_craprda limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
          end loop;
          exit when cr_craprda%rowcount <= 5000;
          rw_craprda.delete;
        end loop;
        close cr_craprda;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_sem_ts(pr_cdcooper
                              ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaAplic3
                              ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_sem_ts BULK COLLECT INTO rw_craprda LIMIT 5000;
          EXIT WHEN rw_craprda.count = 0;
          FOR i IN 1..rw_craprda.count LOOP
            vr_tab_cratorc(rw_craprda(i).cdagenci).vr_cdagenci := rw_craprda(i).cdagenci;
            vr_tab_cratorc(rw_craprda(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda(i).cdagenci).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
          END LOOP;
          rw_craprda.delete;
        END LOOP;
        CLOSE cr_craprda_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4232,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCA30."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4232,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCA30."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCA60 ....................................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda(pr_cdcooper
                       ,5
                       ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda bulk collect into rw_craprda limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
          end loop;
          exit when cr_craprda%rowcount <= 5000;
          rw_craprda.delete;
        end loop;
        close cr_craprda;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_sem_ts(pr_cdcooper
                              ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaAplic5
                              ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_sem_ts BULK COLLECT INTO rw_craprda LIMIT 5000;
          EXIT WHEN rw_craprda.count = 0;
          FOR i IN 1..rw_craprda.count LOOP
            vr_tab_cratorc(rw_craprda(i).cdagenci).vr_cdagenci := rw_craprda(i).cdagenci;
            vr_tab_cratorc(rw_craprda(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda(i).cdagenci).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
          END LOOP;
          rw_craprda.delete;
        END LOOP;
        CLOSE cr_craprda_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4237,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCA60."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4237,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCA60."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCPRE SEM ENTE PUBLICO....................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda_sep(pr_cdcooper
                           ,7
                           ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda_sep bulk collect into rw_craprda_sep limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda_sep.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda_sep(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda_sep(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda_sep(i).vlslfmes;
          end loop;
          exit when cr_craprda_sep%rowcount <= 5000;
          rw_craprda_sep.delete;
        end loop;
        close cr_craprda_sep;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_sep_sem_ts(pr_cdcooper
                                  ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaSemEPAplic7
                                  ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_sep_sem_ts BULK COLLECT INTO rw_craprda_sep LIMIT 5000;
          EXIT WHEN rw_craprda_sep.count = 0;
          FOR i IN 1..rw_craprda_sep.count LOOP
            vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_cdagenci := rw_craprda_sep(i).cdagenci;
            vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_vllanmto, 0) + rw_craprda_sep(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda_sep(i).vlslfmes;
          END LOOP;
          rw_craprda_sep.delete;
        END LOOP;
        CLOSE cr_craprda_sep_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4253,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCPRE."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4253,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPRE."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCPRE ENTE PUBLICO INICIO.................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda_ep(pr_cdcooper
                          ,7
                          ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda_ep bulk collect into rw_craprda_ep limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda_ep.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda_ep(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda_ep(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda_ep(i).vlslfmes;
          end loop;
          exit when cr_craprda_ep%rowcount <= 5000;
          rw_craprda_ep.delete;
        end loop;
        close cr_craprda_ep;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_ep_sem_ts(pr_cdcooper
                                 ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaComEPAplic7
                                 ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_ep_sem_ts BULK COLLECT INTO rw_craprda_ep LIMIT 5000;
          EXIT WHEN rw_craprda_ep.count = 0;
          FOR i IN 1..rw_craprda_ep.count LOOP
            vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_cdagenci := rw_craprda_ep(i).cdagenci;
            vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_vllanmto, 0) + rw_craprda_ep(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda_ep(i).vlslfmes;
          END LOOP;
          rw_craprda_ep.delete;
        END LOOP;
        CLOSE cr_craprda_ep_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4222,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCPRE ENTE PUBLICO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4222,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPRE ENTE PUBLICO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCPRE ENTE PUBLICO FIM....................................
      -- Magui, no mensal precisamos limpar os campos craprda.vlslfmes de
      -- aplicacoes finalizadas pelo crps495 e craps481. Nao podemos zerar
      -- la quando e o ultimo dia do mes porque senao da erro no orcado por
      -- Pac

      -- Aplicacao RDCPOS SEM ENTE PUBLICO....................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda_sep(pr_cdcooper
                           ,8
                           ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda_sep bulk collect into rw_craprda_sep limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda_sep.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda_sep(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda_sep(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda_sep(i).vlslfmes;
          end loop;
          exit when cr_craprda_sep%rowcount <= 5000;
          rw_craprda_sep.delete;
        end loop;
        close cr_craprda_sep;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_sep_sem_ts(pr_cdcooper
                                  ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaSemEPAplic8
                                  ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_sep_sem_ts BULK COLLECT INTO rw_craprda_sep LIMIT 5000;
          EXIT WHEN rw_craprda_sep.count = 0;
          FOR i IN 1..rw_craprda_sep.count LOOP
            vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_cdagenci := rw_craprda_sep(i).cdagenci;
            vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda_sep(i).cdagenci).vr_vllanmto, 0) + rw_craprda_sep(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda_sep(i).vlslfmes;
          END LOOP;
          rw_craprda_sep.delete;
        END LOOP;
        CLOSE cr_craprda_sep_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4254,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCPOS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4254,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPOS."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCPOS ENTE PUBLICO INICIO.................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
        open cr_craprda_ep(pr_cdcooper
                          ,8
                          ,vr_dtinicrps659);

        loop
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda_ep bulk collect into rw_craprda_ep limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda_ep.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda_ep(i).cdagenci;
            --
            vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
            vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda_ep(i).vlslfmes;
            vr_vltotorc := vr_vltotorc + rw_craprda_ep(i).vlslfmes;
          end loop;
          exit when cr_craprda_ep%rowcount <= 5000;
          rw_craprda_ep.delete;
        end loop;
        close cr_craprda_ep;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_ep_sem_ts(pr_cdcooper
                                 ,CONTABILIDADE.tipoTabArqPrincipal.inproc_RdaSinteticoPorAgenciaComEPAplic8
                                 ,vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_ep_sem_ts BULK COLLECT INTO rw_craprda_ep LIMIT 5000;
          EXIT WHEN rw_craprda_ep.count = 0;
          FOR i IN 1..rw_craprda_ep.count LOOP
            vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_cdagenci := rw_craprda_ep(i).cdagenci;
            vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprda_ep(i).cdagenci).vr_vllanmto, 0) + rw_craprda_ep(i).vlslfmes;

            vr_vltotorc := vr_vltotorc + rw_craprda_ep(i).vlslfmes;
          END LOOP;
          rw_craprda_ep.delete;
        END LOOP;
        CLOSE cr_craprda_ep_sem_ts;
      END IF;

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4212,';
      vr_dshstorc := '"(crps249) DEPOSITOS RDCPOS ENTE PUBLICO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4212,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPOS ENTE PUBLICO."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      -- Aplicacao RDCPOS ENTE PUBLICO FIM....................................
      -- Magui, no mensal precisamos limpar os campos craprda.vlslfmes de
      -- aplicacoes finalizadas pelo crps495 e craps481. Nao podemos zerar
      -- la quando e o ultimo dia do mes porque senao da erro no orcado por
      -- Pac

      -- Contas Contábeis Compensação - ENTE PUBLICO INICIO.................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;


      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        --Pega o valor excedente dos municipios na cooperativa informada.
        --Se for a central(3) pega todas as cooperativas afiliadas

        --Valor excedente depósitos a prazo

        open cr_craprda_ep_munic(pr_cdcooper
                                ,vr_dtinicrps659);

        LOOP
          --joga dados do cursor na variável de 5000 em 5000
          fetch cr_craprda_ep_munic bulk collect into rw_craprda_ep_munic limit 5000;

          --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
          for i in 1..rw_craprda_ep_munic.count loop
            --guarda o indexador em variável para ficar mais claro
            vr_cdagenci_index := rw_craprda_ep_munic(i).cdagenci;
            --
            vr_tab_coopmunic(vr_cdagenci_index).vr_cdcoopmunic := vr_cdagenci_index;
            vr_tab_coopmunic(vr_cdagenci_index).vr_vllanmto    := nvl(vr_tab_coopmunic(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda_ep_munic(i).vlslfmes;
          end loop;
          exit when cr_craprda_ep_munic%rowcount <= 5000;
          rw_craprda_ep_munic.delete;
        end loop;
        close cr_craprda_ep_munic;
        --
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_craprda_ep_munic_sem_ts(pr_cdcooper, vr_dtmvtolt);
        LOOP
          FETCH cr_craprda_ep_munic_sem_ts BULK COLLECT INTO rw_craprda_ep_munic LIMIT 5000;
          EXIT WHEN rw_craprda_ep_munic.count = 0;
          FOR i IN 1..rw_craprda_ep_munic.count LOOP
            vr_tab_coopmunic(rw_craprda_ep_munic(i).cdagenci).vr_cdcoopmunic := rw_craprda_ep_munic(i).cdagenci;
            vr_tab_coopmunic(rw_craprda_ep_munic(i).cdagenci).vr_vllanmto := NVL(vr_tab_coopmunic(rw_craprda_ep_munic(i).cdagenci).vr_vllanmto, 0) + rw_craprda_ep_munic(i).vlslfmes;
          END LOOP;
          rw_craprda_ep_munic.delete;
        END LOOP;
        CLOSE cr_craprda_ep_munic_sem_ts;
      END IF;

      --Valor excedente depósitos a vista
      pc_proc_dep_vista_ep_ct_contb(pr_cdcooper
                                   ,vr_dtmvtolt);
      --

      vr_tab_cratorc(999).vr_cdagenci := 999;

      vr_cdagenci_index := vr_tab_coopmunic.first;
      -- Percorre todas as cooperativas e municipios
      WHILE vr_cdagenci_index IS NOT NULL LOOP
        -- Se o valor de lançamentos for mair que o valor parametrizado do fundo garantidor (este é buscado na rotina dos depósitos a vista, cursor dos municipios)
        if vr_tab_coopmunic(vr_cdagenci_index).vr_vllanmto > vr_tab_coopmunic(vr_cdagenci_index).vr_vlfgcoop then
           vr_tab_cratorc(999).vr_vllanmto    := nvl(vr_tab_cratorc(999).vr_vllanmto, 0) + (vr_tab_coopmunic(vr_cdagenci_index).vr_vllanmto - vr_tab_coopmunic(vr_cdagenci_index).vr_vlfgcoop);
        end if;
        -- Próximo indice
        vr_cdagenci_index := vr_tab_coopmunic.next(vr_cdagenci_index);
      END LOOP;
      vr_vltotorc := nvl(vr_vltotorc,0) + nvl(vr_tab_cratorc(999).vr_vllanmto,0);

      IF nvl(vr_vltotorc,0) > 0 THEN
        --
        vr_flgrvorc := false; -- Lancamento do dia
        vr_flgctpas := true;  -- Conta do PASSIVO
        vr_flgctred := false; -- Normal
        if (pr_cdcooper <> 3) then
          vr_lsctaorc := ',3903,';
          vr_lsctacmp := '9009,';
          vr_dshstorc := '"(crps249) VALORES DE DEPOSITO A VISTA E A PRAZO DE ENTES PUBLICOS QUE FOREM EXCEDENTES AO LIMITE DE COBERTURA ASSEGURADO PELOS FUNDOS GARANTIDORES."';
        else
          vr_lsctaorc := ',3905,';
          vr_lsctacmp := '9008,';
          vr_dshstorc := '"(crps249) VALORES APLICADOS EM TITULOS PUBLICOS FEDERAIS LIVRES QUE CORRESPONDAM AOS DEPOSITOS CAPTADOS POR SUAS FILIADAS QUE FOREM EXCEDENTES AO LIMITE DE COBERTURA ASSEGURADO PELOS FUNDOS GARANTIDORES."';
        end if;
        vr_dshcporc := ',5210,';

        -- Inclui as informações no arquivo
        -- Não chamamos a procedure, como os demais, pois nas contas de compensação
        -- geramos apenas um registro de cabeçalho e um totalizador 999
        vr_linhadet := '99'||
                      trim(vr_dtmvtolt_yymmdd)||','||
                      trim(to_char(vr_dtmvtolt,'ddmmyy'))||
                      trim(vr_lsctaorc)||
                      trim(vr_lsctacmp)||
                      trim(to_char(vr_vltotorc, '99999999999990.00'))||
                      trim(vr_dshcporc)||
                      trim(vr_dshstorc);
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        --
        vr_flgrvorc := true;  -- Lancamento de reversao
        vr_flgctpas := true;  -- Conta do PASSIVO
        vr_flgctred := false; -- Normal
        if (pr_cdcooper <> 3) then
          vr_lsctaorc := ',3903,';
          vr_lsctacmp := ',9009';
          vr_dshstorc := '"(crps249) REVERSAO DE VALORES DE DEPOSITO A VISTA E A PRAZO DE ENTES PUBLICOS QUE FOREM EXCEDENTES AO LIMITE DE COBERTURA ASSEGURADO PELOS FUNDOS GARANTIDORES."';
        else
          vr_lsctaorc := ',3905,';
          vr_lsctacmp := ',9008';
          vr_dshstorc := '"(crps249) REVERSAO DE VALORES APLICADOS EM TITULOS PUBLICOS FEDERAIS LIVRES QUE CORRESPONDAM AOS DEPOSITOS CAPTADOS POR SUAS FILIADAS QUE FOREM EXCEDENTES AO LIMITE DE COBERTURA ASSEGURADO PELOS FUNDOS GARANTIDORES."';
        end if;
        vr_dshcporc := ',5210,';

        -- Inclui as informações no arquivo
        -- Não chamamos a procedure, como os demais, pois nas contas de compensação
        -- geramos apenas um registro de cabeçalho e um totalizador 999
        vr_linhadet := '99'||
                      trim(vr_dtmvtolt_yymmdd)||','||
                      trim(to_char(vr_dtmvtopr,'ddmmyy'))||
                      trim(vr_lsctacmp)||
                      trim(vr_lsctaorc)||
                      trim(to_char(vr_vltotorc, '99999999999990.00'))||
                      trim(vr_dshcporc)||
                      trim(vr_dshstorc);
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END IF;

      -- Contas Contábeis Compensação - ENTE PUBLICO FIM....................................

      -- Poupança Programada .................................................
      vr_tab_cratorc.delete;
      vr_vltotorc := 0;
      for rw_craprpp in cr_craprpp (pr_cdcooper,
                                    vr_dtmvtolt) loop
        open cr_crapass (pr_cdcooper,
                         rw_craprpp.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craprpp.vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprpp.vlslfmes;
      end loop;
      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4257,';
      vr_dshstorc := '"(crps249) DEPOSITOS POUPANCA PROGRAMADA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',4257,';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS POUPANCA PROGRAMADA."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --

      -- Aplicacoes Novos Produtos de Captacao ...............................
      FOR rw_crapcpc in cr_crapcpc LOOP
        vr_tab_cratorc.delete;
        vr_vltotorc := 0;

        -- PRB0046128 - Retirar o uso de TIMESTAMP
        IF vr_usarTimeStamp THEN
          -- PRB0046128 - Processo anterior usando TIMESTAMP
          OPEN cr_craprac(pr_cdcooper, rw_crapcpc.cdprodut, vr_dtinicrps659);

          -- Percorrer novas aplicacoes.
          --FOR rw_craprac in cr_craprac(pr_cdcooper, rw_crapcpc.cdprodut) LOOP
          LOOP
            FETCH cr_craprac BULK COLLECT INTO rw_craprac LIMIT 5000;
            EXIT WHEN rw_craprac.count = 0;
            FOR i IN 1..rw_craprac.count LOOP
              OPEN cr_crapass (pr_cdcooper,rw_craprac(i).nrdconta);
              FETCH cr_crapass into rw_crapass;
              CLOSE cr_crapass;
              --
              vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
              vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craprac(i).vlslfmes;
              vr_vltotorc := vr_vltotorc + rw_craprac(i).vlslfmes;
              --
              OPEN  cr_craphis2(pr_cdcooper, rw_crapcpc.cdhsnrap);
              FETCH cr_craphis2 INTO rw_craphis2;
              IF cr_craphis2%FOUND THEN
                vr_nrctacre := rw_craphis2.nrctacrd;
              END IF;
              CLOSE cr_craphis2;
            END LOOP;
            rw_craprac.delete;
          END LOOP;
          CLOSE cr_craprac;
          --
        ELSE
          -- PRB0046128 - Processo novo sem TIMESTAMP
          OPEN cr_craprac_sem_ts(pr_cdcooper, rw_crapcpc.cdprodut, vr_dtmvtolt);
          -- Percorrer novas aplicacoes.
          LOOP
            FETCH cr_craprac_sem_ts BULK COLLECT INTO rw_craprac_sem_ts LIMIT 5000;
            EXIT WHEN rw_craprac_sem_ts.count = 0;
            FOR i IN 1..rw_craprac_sem_ts.count LOOP
              vr_tab_cratorc(rw_craprac_sem_ts(i).cdagenci).vr_cdagenci := rw_craprac_sem_ts(i).cdagenci;
              vr_tab_cratorc(rw_craprac_sem_ts(i).cdagenci).vr_vllanmto := NVL(vr_tab_cratorc(rw_craprac_sem_ts(i).cdagenci).vr_vllanmto, 0) + rw_craprac_sem_ts(i).vlslfmes;

              vr_vltotorc := vr_vltotorc + rw_craprac_sem_ts(i).vlslfmes;
            END LOOP;
            rw_craprac_sem_ts.delete;
          END LOOP;
          CLOSE cr_craprac_sem_ts;

          OPEN cr_craphis2(pr_cdcooper, rw_crapcpc.cdhsnrap);
          FETCH cr_craphis2 INTO rw_craphis2;
          IF cr_craphis2%FOUND THEN
            vr_nrctacre := rw_craphis2.nrctacrd;
          END IF;
          CLOSE cr_craphis2;
        END IF;

        vr_flgrvorc := false; -- Lancamento do dia
        vr_flgctpas := true;  -- Conta do PASSIVO
        vr_flgctred := false; -- Normal
        vr_lsctaorc := ',' || Lpad(vr_nrctacre,4,'0') || ',';
        vr_dshstorc := '"(crps249) DEPOSITOS ' || rw_crapcpc.nmprodut || '."';
        vr_dshcporc := ',5210,';
        pc_proc_lista_orcamento;
        --
        vr_flgrvorc := true;  -- Lancamento de reversao
        vr_flgctpas := true;  -- Conta do PASSIVO
        vr_flgctred := false; -- Normal
        vr_lsctaorc := ',' || Lpad(vr_nrctacre,4,'0') || ',';
        vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS ' || rw_crapcpc.nmprodut || '."';
        vr_dshcporc := ',5210,';
        pc_proc_lista_orcamento;

         IF rw_crapcpc.cddindex = 6 AND nvl(vr_vltotorc,0) > 0 THEN
           vr_nrsldpou := '3907';
           vr_nrrevers := '9046';
           vr_dshstorc := '"SALDO DE CAPTACAO REALIZADA ATRAVES DO PRODUTO POUPANCA"';
           vr_dshstor1 := '"REVERSAO DE SALDO DE CAPTACAO REALIZADA ATRAVES DO PRODUTO POUPANCA"';

            vr_linhadet := '20'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                    trim(vr_nrsldpou)||','||
                    trim(vr_nrrevers)||','||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            vr_linhadet := '20'||
                    trim(to_char(vr_dtmvtopr,'yymmdd'))||','|| -- Alteração efetuada por Paulo Monteiro em 10/08/2021
                    trim(to_char(vr_dtmvtopr,'ddmmyy'))||','|| -- Alteração efetuada por Paulo Monteiro em 10/08/2021
                    trim(vr_nrrevers)||','||
                    trim(vr_nrsldpou)||','||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstor1);
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         END IF;

      END LOOP;

      IF cr_craprac%ISOPEN THEN
        CLOSE cr_craprac;
      END IF;

      /* Inicio de procedimento de reclassificação de
       */
      cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 1 -- Informação
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 0 -- Baixa
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Inicio do procedimento de reclassificação de Pessoas Ligadas');

      -- Aplicacoes Novos Produtos de Captacao ...............................
      vr_tab_crapplg.delete;
      vr_vltotplg := 0;

      -- PRB0046128 - Retirar o uso de TIMESTAMP
      IF vr_usarTimeStamp THEN
        -- PRB0046128 - Processo anterior usando TIMESTAMP
        OPEN cr_crapplg(pr_cdcooper, vr_prodpoup, vr_dtinicrps659);
        LOOP
          FETCH cr_crapplg BULK COLLECT INTO rw_crapplg LIMIT 5000;
          EXIT WHEN rw_crapplg.count = 0;
          FOR i IN 1..rw_crapplg.count LOOP
            --
            vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_cdagenci := rw_crapplg(i).cdagenci;
            vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_vllanmto := nvl(vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_vllanmto, 0) + rw_crapplg(i).vlslfmes;
            vr_vltotplg := vr_vltotplg + rw_crapplg(i).vlslfmes;
            --
          END LOOP;
          rw_crapplg.delete;
        END LOOP;
        CLOSE cr_crapplg;
      ELSE
        -- PRB0046128 - Processo novo sem TIMESTAMP
        OPEN cr_crapplg_sem_ts(pr_cdcooper, vr_prodpoup, vr_dtmvtolt);
        LOOP
          FETCH cr_crapplg_sem_ts BULK COLLECT INTO rw_crapplg LIMIT 5000;
          EXIT WHEN rw_crapplg.count = 0;
          FOR i IN 1..rw_crapplg.count LOOP
            vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_cdagenci := rw_crapplg(i).cdagenci;
            vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_vllanmto := NVL(vr_tab_crapplg(rw_crapplg(i).cdagenci).vr_vllanmto, 0) + rw_crapplg(i).vlslfmes;

            vr_vltotplg := vr_vltotplg + rw_crapplg(i).vlslfmes;
          END LOOP;
          rw_crapplg.delete;
        END LOOP;
        CLOSE cr_crapplg_sem_ts;
      END IF;

      if nvl(vr_vltotplg,0) <> 0 then
        --
        pc_proc_lista_pessoa_ligada(pr_flgdata => FALSE);
        --
        pc_proc_lista_pessoa_ligada(pr_flgdata => TRUE);
        --
      end if;

      vr_cdcritic := 0;
      cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 1 -- Informação
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 0 -- Baixa
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Final do procedimento de reclassificação de Pessoas Ligadas');

      -- Contabilizacao para orcamento (Realizado)............................
      vr_cdcritic := 0;
      cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 1 -- Informação
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 0 -- Baixa
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Final da contabilizacao para o orcamento (realizado)');
    end;

    -- Geracao de Arquivo AAMMDD_OP_CRED.txt - Processo mensal
    PROCEDURE pc_gera_arq_op_cred (pr_dscritic OUT VARCHAR2) IS

       -- Variaveis
       vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
       vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
       vr_index          NUMBER := 0;

       -- Variavel de Exception
       vr_exc_erro EXCEPTION;

       -- Inicializa tabela de Historicos
       PROCEDURE pc_inicia_historico_mic IS
       BEGIN
          -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
          cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_inicia_historico_mic', pr_action => NULL);
          vr_tab_historico_mic.DELETE;

          vr_tab_historico_mic(0098).nrctaori_fis := 7141;
          vr_tab_historico_mic(0098).nrctades_fis := 7073;
          vr_tab_historico_mic(0098).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(0098).nrctaori_jur := 7141;
          vr_tab_historico_mic(0098).nrctades_jur := 7073;
          vr_tab_historico_mic(0098).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(0277).nrctaori_fis := 7073;
          vr_tab_historico_mic(0277).nrctades_fis := 7141;
          vr_tab_historico_mic(0277).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(0277).nrctaori_jur := 7073;
          vr_tab_historico_mic(0277).nrctades_jur := 7141;
          vr_tab_historico_mic(0277).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(2093).nrctaori_fis := 7043;
          vr_tab_historico_mic(2093).nrctades_fis := 7076;
          vr_tab_historico_mic(2093).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(2093).nrctaori_jur := 7043;
          vr_tab_historico_mic(2093).nrctades_jur := 7076;
          vr_tab_historico_mic(2093).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(2090).nrctaori_fis := 7047;
          vr_tab_historico_mic(2090).nrctades_fis := 7079;
          vr_tab_historico_mic(2090).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(2090).nrctaori_jur := 7047;
          vr_tab_historico_mic(2090).nrctades_jur := 7079;
          vr_tab_historico_mic(2090).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(1038).nrctaori_fis := 7135;
          vr_tab_historico_mic(1038).nrctades_fis := 7082;
          vr_tab_historico_mic(1038).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1038).nrctaori_jur := 7135;
          vr_tab_historico_mic(1038).nrctades_jur := 7082;
          vr_tab_historico_mic(1038).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(1072).nrctaori_fis := 7136;
          vr_tab_historico_mic(1072).nrctades_fis := 7085;
          vr_tab_historico_mic(1072).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1072).nrctaori_jur := 7136;
          vr_tab_historico_mic(1072).nrctades_jur := 7085;
          vr_tab_historico_mic(1072).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(1713).nrctaori_fis := 7085;
          vr_tab_historico_mic(1713).nrctades_fis := 7136;
          vr_tab_historico_mic(1713).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1713).nrctaori_jur := 7085;
          vr_tab_historico_mic(1713).nrctades_jur := 7136;
          vr_tab_historico_mic(1713).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(1722).nrctaori_fis := 7085;
          vr_tab_historico_mic(1722).nrctades_fis := 7136;
          vr_tab_historico_mic(1722).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA AVAL CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1722).nrctaori_jur := 7085;
          vr_tab_historico_mic(1722).nrctades_jur := 7136;
          vr_tab_historico_mic(1722).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA AVAL CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';


          vr_tab_historico_mic(1070).nrctaori_fis := 7138;
          vr_tab_historico_mic(1070).nrctades_fis := 7088;
          vr_tab_historico_mic(1070).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1070).nrctaori_jur := 7138;
          vr_tab_historico_mic(1070).nrctades_jur := 7088;
          vr_tab_historico_mic(1070).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          --> CRAPLEM
          vr_tab_historico_mic(1076).nrctaori_fis := 7138;
          vr_tab_historico_mic(1076).nrctades_fis := 7088;
          vr_tab_historico_mic(1076).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1076).nrctaori_jur := 7138;
          vr_tab_historico_mic(1076).nrctades_jur := 7088;
          vr_tab_historico_mic(1076).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';


          vr_tab_historico_mic(1710).nrctaori_fis := 7088;
          vr_tab_historico_mic(1710).nrctades_fis := 7138;
          vr_tab_historico_mic(1710).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1710).nrctaori_jur := 7088;
          vr_tab_historico_mic(1710).nrctades_jur := 7138;
          vr_tab_historico_mic(1710).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          --> CRAPLEM
          vr_tab_historico_mic(1708).nrctaori_fis := 7088;
          vr_tab_historico_mic(1708).nrctades_fis := 7138;
          vr_tab_historico_mic(1708).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1708).nrctaori_jur := 7088;
          vr_tab_historico_mic(1708).nrctades_jur := 7138;
          vr_tab_historico_mic(1708).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

          vr_tab_historico_mic(1510).nrctaori_fis := 7085;
          vr_tab_historico_mic(1510).nrctades_fis := 7136;
          vr_tab_historico_mic(1510).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) ESTORNO JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
          vr_tab_historico_mic(1510).nrctaori_jur := 7085;
          vr_tab_historico_mic(1510).nrctades_jur := 7136;
          vr_tab_historico_mic(1510).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) ESTORNO JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

     END;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
      cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_gera_arq_op_cred', pr_action => NULL);

       -- Inicia Variavel
       pr_dscritic := NULL;

       -- Inicializa Pl-Table
       pc_inicia_historico_mic;

       -- Nome do arquivo a ser gerado
       vr_nmarqdat_ope_cred := vr_dtmvtolt_yymmdd||'_OPCRED_NOVA_CENTRAL.txt';

       -- Tenta abrir o arquivo de log em modo gravacao
       cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                               ,pr_nmarquiv => vr_nmarqdat_ope_cred --> Nome do arquivo
                               ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);        --> Erro
       IF vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
       END IF;


       vr_tab_valores_ag.DELETE;
       vr_index := 0;


       -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
       FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

          -- Historico para ESTORNO DE JUROS S/EMPR. E FINANC.
          IF rw_craprej.cdhistor = 0277 THEN

             IF UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' THEN /* EMPRESTIMO */
                -- Escrever no arquivo somente os registros que o valor for maior que zero
                IF rw_craprej.vlsdapli > 0 THEN
                   -- Monta o cabecalho da linha
                   IF rw_craprej.cdagenci = 0 THEN

                      -- Verifica se existe afrupamento por PA
                      IF vr_tab_valores_ag.COUNT() > 0 THEN

                         -- escreve a linha duplicada
                         vr_index := vr_tab_valores_ag.FIRST;
                         WHILE vr_index IS NOT NULL LOOP

                            cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                          ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

                            vr_index := vr_tab_valores_ag.NEXT(vr_index);

                         END LOOP;

                         -- limpa a table de reveraso
                         vr_tab_valores_ag.DELETE;
                      END IF;

                      IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                         -- Linha de Cabecalho
                         vr_setlinha := fn_set_cabecalho('70'
                                                        ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                        ,7116
                                                        ,7116
                                                        ,rw_craprej.vlsdapli
                                                        ,'"ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA FISICA"');
                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita

                      ELSE -- Pessoa Juridica
                         -- Linha de Cabecalho
                         vr_setlinha := fn_set_cabecalho('70'
                                                        ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                        ,7116
                                                        ,7116
                                                        ,rw_craprej.vlsdapli
                                                        ,'"ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA JURIDICA"');
                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita

                      END IF;
                   ELSE -- Monta as linhas separadas por agencia
                      vr_index := vr_tab_valores_ag.COUNT()+1;
                      vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                     ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                   END IF;
                END IF;
             END IF;

          ELSIF rw_craprej.cdhistor = 0098 THEN /* JUROS SOBRE EMPR. E FINANC */

             IF UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' THEN /* EMPRESTIMO */
                -- Escrever no arquivo somente os registros que o valor for maior que zero
                IF rw_craprej.vlsdapli > 0 THEN
                   -- Monta o cabecalho da linha
                   IF rw_craprej.cdagenci = 0 THEN

                      -- Verifica se existe agrupamento por PA
                      IF vr_tab_valores_ag.COUNT() > 0 THEN

                         -- escreve a linha duplicada
                         vr_index := vr_tab_valores_ag.FIRST;
                         WHILE vr_index IS NOT NULL LOOP

                            cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                          ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

                            vr_index := vr_tab_valores_ag.NEXT(vr_index);
                         END LOOP;

                         -- limpa a table de reveraso
                         vr_tab_valores_ag.DELETE;
                      END IF;

                   ELSE -- Monta as linhas separadas por agencia
                      vr_index := vr_tab_valores_ag.COUNT()+1;
                      vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                   ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                   END IF;
                END IF;
             END IF;

          END IF;

       END LOOP;

       -- Quando for o ultimo historico, verifica se existe agrupamento por PA
       IF vr_tab_valores_ag.COUNT() > 0 THEN

                         -- escreve a linha duplicada
                         vr_index := vr_tab_valores_ag.FIRST;
                         WHILE vr_index IS NOT NULL LOOP

                            cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

             vr_index := vr_tab_valores_ag.NEXT(vr_index);
          END LOOP;

                END IF;

       vr_tab_valores_ag.DELETE;
       vr_index := 0;

       --Separação lançamentos microcredito e operação normal.
       FOR rw_craprej IN cr_craprej4(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

         -- Escrever no arquivo somente os registros que estao nas tabelas de historico
         IF vr_tab_historico_mic.exists(rw_craprej.cdhistor) THEN

           IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha

                      -- Verifica se existe agrupamento por PA
                      IF vr_tab_valores_ag.COUNT() > 0 THEN

                         -- escreve a linha duplicada
                         vr_index := vr_tab_valores_ag.FIRST;
                         WHILE vr_index IS NOT NULL LOOP

                            cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                          ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

                            vr_index := vr_tab_valores_ag.NEXT(vr_index);
                         END LOOP;

                         -- limpa a table de reveraso
                         vr_tab_valores_ag.DELETE;

             END IF; -- fim if count()>0

                IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica

                         -- Linha de Cabecalho
                   vr_setlinha := fn_set_cabecalho('70'
                                                  ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                  ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctaori_fis
                                                  ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctades_fis
                                                        ,rw_craprej.vlsdapli
                                                  ,'"'||REPLACE(vr_tab_historico_mic(rw_craprej.cdhistor).dsrefere_fis,'pr_origem',rw_craprej.dshistor)||'"');


                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita


                ELSE -- Pessoa Juridica

                         -- Linha de Cabecalho
                   vr_setlinha := fn_set_cabecalho('70'
                                                   ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                   ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctaori_jur
                                                   ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctades_jur
                                                        ,rw_craprej.vlsdapli
                                                   ,'"'||REPLACE(vr_tab_historico_mic(rw_craprej.cdhistor).dsrefere_jur,'pr_origem',rw_craprej.dshistor)||'"');

                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita


                END IF; -- fim if tipo pessoa


                   ELSE -- Monta as linhas separadas por agencia
                      vr_index := vr_tab_valores_ag.COUNT()+1;
                      vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                   ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                      cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
           END IF; -- fim monta cabecalho da linha

         END IF; -- validacao de historico

       END LOOP;

       -- Quando for o ultimo historico, verifica se existe agrupamento por PA
       IF vr_tab_valores_ag.COUNT() > 0 THEN

          -- escreve a linha duplicada
          vr_index := vr_tab_valores_ag.FIRST;
          WHILE vr_index IS NOT NULL LOOP

             cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

             vr_index := vr_tab_valores_ag.NEXT(vr_index);
          END LOOP;

       END IF;

       vr_tab_valores_ag.DELETE;
       vr_index := 0;


       -- Fechar Arquivo>>
       BEGIN
          cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
       EXCEPTION
          WHEN OTHERS THEN
           --Inclusão na tabela de erros Oracle - Chamado 734422
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
           vr_cdcritic := 1039;
           vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_diretorio||'/'||vr_nmarqdat_ope_cred||'>: ' || SQLERRM;
          RAISE vr_exc_erro;
       END;

       -- Limpa Pl-Table
       vr_tab_historico.DELETE;
       vr_arq_op_cred.DELETE;

    EXCEPTION
       WHEN vr_exc_erro THEN
          NULL;
       WHEN OTHERS THEN
         --Inclusão na tabela de erros Oracle - Chamado 734422
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
         vr_cdcritic := 1044;
         vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' AAMMDD_OP_CRED_NOVA_CENTRAL.txt. Erro: '|| SQLERRM;
         pr_dscritic := vr_dscritic;
    END;

    --
    PROCEDURE pc_gera_arq_prejuizo (pr_dscritic OUT VARCHAR2) IS

       -- Variaveis
       vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
       vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
       vr_index          NUMBER := 0;
       vr_aux_contador   number := 0;

       -- Variavel de Exception
       vr_exc_erro EXCEPTION;

       -- Inicializa tabela de Historicos
       PROCEDURE pc_inicia_historico_prejuizo IS
       BEGIN
          -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
          cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_inicia_historico_prejuizo', pr_action => NULL);
          vr_tab_historico.DELETE;

          vr_tab_historico(0349).nrctaori_fis := 8442;
          vr_tab_historico(0349).nrctades_fis := 8442;
          vr_tab_historico(0349).dsrefere_fis := 'EMPRESTIMO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
          vr_tab_historico(0349).nrctaori_jur := 8442;
          vr_tab_historico(0349).nrctades_jur := 8442;
          vr_tab_historico(0349).dsrefere_jur := 'EMPRESTIMO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(0350).nrctaori_fis := 8442;
          vr_tab_historico(0350).nrctades_fis := 8442;
          vr_tab_historico(0350).dsrefere_fis := 'SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
          vr_tab_historico(0350).nrctaori_jur := 8442;
          vr_tab_historico(0350).nrctades_jur := 8442;
          vr_tab_historico(0350).dsrefere_jur := 'SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(1731).nrctaori_fis := 8442;
          vr_tab_historico(1731).nrctades_fis := 8442;
          vr_tab_historico(1731).dsrefere_fis := 'EMPRESTIMO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
          vr_tab_historico(1731).nrctaori_jur := 8442;
          vr_tab_historico(1731).nrctades_jur := 8442;
          vr_tab_historico(1731).dsrefere_jur := 'EMPRESTIMO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(1732).nrctaori_fis := 8442;
          vr_tab_historico(1732).nrctades_fis := 8442;
          vr_tab_historico(1732).dsrefere_fis := 'FINANCIAMENTO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
          vr_tab_historico(1732).nrctaori_jur := 8442;
          vr_tab_historico(1732).nrctades_jur := 8442;
          vr_tab_historico(1732).dsrefere_jur := 'FINANCIAMENTO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';


          vr_tab_historico(2381).nrctaori_fis := 8442;
          vr_tab_historico(2381).nrctades_fis := 8442;
          vr_tab_historico(2381).dsrefere_fis := 'TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2381).nrctaori_jur := 8442;
          vr_tab_historico(2381).nrctades_jur := 8442;
          vr_tab_historico(2381).dsrefere_jur := 'TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2396).nrctaori_fis := 8442;
          vr_tab_historico(2396).nrctades_fis := 8442;
          vr_tab_historico(2396).dsrefere_fis := 'TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2396).nrctaori_jur := 8442;
          vr_tab_historico(2396).nrctades_jur := 8442;
          vr_tab_historico(2396).dsrefere_jur := 'TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2401).nrctaori_fis := 8442;
          vr_tab_historico(2401).nrctades_fis := 8442;
          vr_tab_historico(2401).dsrefere_fis := 'TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2401).nrctaori_jur := 8442;
          vr_tab_historico(2401).nrctades_jur := 8442;
          vr_tab_historico(2401).dsrefere_jur := 'TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2878).nrctaori_fis := 8442;
          vr_tab_historico(2878).nrctades_fis := 8442;
          vr_tab_historico(2878).dsrefere_fis := 'TRANSFERENCIA EMPRESTIMO POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2878).nrctaori_jur := 8442;
          vr_tab_historico(2878).nrctades_jur := 8442;
          vr_tab_historico(2878).dsrefere_jur := 'TRANSFERENCIA EMPRESTIMO POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2885).nrctaori_fis := 8442;
          vr_tab_historico(2885).nrctades_fis := 8442;
          vr_tab_historico(2885).dsrefere_fis := 'TRANSFERENCIA FINANCIAMENTO POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2885).nrctaori_jur := 8442;
          vr_tab_historico(2885).nrctades_jur := 8442;
          vr_tab_historico(2885).dsrefere_jur := 'TRANSFERENCIA FINANCIAMENTO POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2382).nrctaori_fis := 7122;
          vr_tab_historico(2382).nrctades_fis := 7122;
          vr_tab_historico(2382).dsrefere_fis := 'REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2382).nrctaori_jur := 7122;
          vr_tab_historico(2382).nrctades_jur := 7122;
          vr_tab_historico(2382).dsrefere_jur := 'REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2397).nrctaori_fis := 7135;
          vr_tab_historico(2397).nrctades_fis := 7135;
          vr_tab_historico(2397).dsrefere_fis := 'REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2397).nrctaori_jur := 7135;
          vr_tab_historico(2397).nrctades_jur := 7135;
          vr_tab_historico(2397).dsrefere_jur := 'REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2402).nrctaori_fis := 7116;
          vr_tab_historico(2402).nrctades_fis := 7116;
          vr_tab_historico(2402).dsrefere_fis := 'REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2402).nrctaori_jur := 7116;
          vr_tab_historico(2402).nrctades_jur := 7116;
          vr_tab_historico(2402).dsrefere_jur := 'REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2406).nrctaori_fis := 7141;
          vr_tab_historico(2406).nrctades_fis := 7141;
          vr_tab_historico(2406).dsrefere_fis := 'REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2406).nrctaori_jur := 7141;
          vr_tab_historico(2406).nrctades_jur := 7141;
          vr_tab_historico(2406).dsrefere_jur := 'REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2882).nrctaori_fis := 7593;
          vr_tab_historico(2882).nrctades_fis := 7593;
          vr_tab_historico(2882).dsrefere_fis := 'REVERSAO JUROS MORA+60 EMPRESTIMO POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2882).nrctaori_jur := 7593;
          vr_tab_historico(2882).nrctades_jur := 7593;
          vr_tab_historico(2882).dsrefere_jur := 'REVERSAO JUROS MORA+60 EMPRESTIMO POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2883).nrctaori_fis := 7596;
          vr_tab_historico(2883).nrctades_fis := 7596;
          vr_tab_historico(2883).dsrefere_fis := 'REVERSAO MULTA EMPRESTIMO POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2883).nrctaori_jur := 7596;
          vr_tab_historico(2883).nrctades_jur := 7596;
          vr_tab_historico(2883).dsrefere_jur := 'REVERSAO MULTA EMPRESTIMO POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2953).nrctaori_fis := 7590;
          vr_tab_historico(2953).nrctades_fis := 7590;
          vr_tab_historico(2953).dsrefere_fis := 'REVERSAO JUR.CORRECAO+60 EMPRESTIMO POS P/PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2953).nrctaori_jur := 7590;
          vr_tab_historico(2953).nrctades_jur := 7590;
          vr_tab_historico(2953).dsrefere_jur := 'REVERSAO JUR.CORRECAO+60 EMPRESTIMO POS P/PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2954).nrctaori_fis := 7587;
          vr_tab_historico(2954).nrctades_fis := 7587;
          vr_tab_historico(2954).dsrefere_fis := 'REVERSAO JUR.REMUNER.+60 EMPRESTIMO POS P/PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2954).nrctaori_jur := 7587;
          vr_tab_historico(2954).nrctades_jur := 7587;
          vr_tab_historico(2954).dsrefere_jur := 'REVERSAO JUR.REMUNER.+60 EMPRESTIMO POS P/PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2886).nrctaori_fis := 7563;
          vr_tab_historico(2886).nrctades_fis := 7563;
          vr_tab_historico(2886).dsrefere_fis := 'REVERSAO JUROS MORA+60 FINANCIAME. POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2886).nrctaori_jur := 7563;
          vr_tab_historico(2886).nrctades_jur := 7563;
          vr_tab_historico(2886).dsrefere_jur := 'REVERSAO JUROS MORA+60 FINANCIAME. POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2887).nrctaori_fis := 7566;
          vr_tab_historico(2887).nrctades_fis := 7566;
          vr_tab_historico(2887).dsrefere_fis := 'REVERSAO MULTA FINANCIAMENTO POS P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2887).nrctaori_jur := 7566;
          vr_tab_historico(2887).nrctades_jur := 7566;
          vr_tab_historico(2887).dsrefere_jur := 'REVERSAO MULTA FINANCIAMENTO POS P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2955).nrctaori_fis := 7560;
          vr_tab_historico(2955).nrctades_fis := 7560;
          vr_tab_historico(2955).dsrefere_fis := 'REVERSAO JUR.CORRECAO+60 FINANCIAME.POS P/PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2955).nrctaori_jur := 7560;
          vr_tab_historico(2955).nrctades_jur := 7560;
          vr_tab_historico(2955).dsrefere_jur := 'REVERSAO JUR.CORRECAO+60 FINANCIAME.POS P/PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2956).nrctaori_fis := 7557;
          vr_tab_historico(2956).nrctades_fis := 7557;
          vr_tab_historico(2956).dsrefere_fis := 'REVERSAO JUR.REMUNERA+60 FINANCIAME.POS P/PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2956).nrctaori_jur := 7557;
          vr_tab_historico(2956).nrctades_jur := 7557;
          vr_tab_historico(2956).dsrefere_jur := 'REVERSAO JUR.REMUNERA+60 FINANCIAME.POS P/PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2383).nrctaori_fis := 8442;
          vr_tab_historico(2383).nrctades_fis := 8442;
          vr_tab_historico(2383).dsrefere_fis := 'ESTORNO TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2383).nrctaori_jur := 8442;
          vr_tab_historico(2383).nrctades_jur := 8442;
          vr_tab_historico(2383).dsrefere_jur := 'ESTORNO TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2398).nrctaori_fis := 8442;
          vr_tab_historico(2398).nrctades_fis := 8442;
          vr_tab_historico(2398).dsrefere_fis := 'ESTORNO TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2398).nrctaori_jur := 8442;
          vr_tab_historico(2398).nrctades_jur := 8442;
          vr_tab_historico(2398).dsrefere_jur := 'ESTORNO TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2403).nrctaori_fis := 8442;
          vr_tab_historico(2403).nrctades_fis := 8442;
          vr_tab_historico(2403).dsrefere_fis := 'ESTORNO TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2403).nrctaori_jur := 8442;
          vr_tab_historico(2403).nrctades_jur := 8442;
          vr_tab_historico(2403).dsrefere_jur := 'ESTORNO TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2384).nrctaori_fis := 7122;
          vr_tab_historico(2384).nrctades_fis := 7122;
          vr_tab_historico(2384).dsrefere_fis := 'ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2384).nrctaori_jur := 7122;
          vr_tab_historico(2384).nrctades_jur := 7122;
          vr_tab_historico(2384).dsrefere_jur := 'ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2399).nrctaori_fis := 7135;
          vr_tab_historico(2399).nrctades_fis := 7135;
          vr_tab_historico(2399).dsrefere_fis := 'ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2399).nrctaori_jur := 7135;
          vr_tab_historico(2399).nrctades_jur := 7135;
          vr_tab_historico(2399).dsrefere_jur := 'ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2404).nrctaori_fis := 7116;
          vr_tab_historico(2404).nrctades_fis := 7116;
          vr_tab_historico(2404).dsrefere_fis := 'ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2404).nrctaori_jur := 7116;
          vr_tab_historico(2404).nrctades_jur := 7116;
          vr_tab_historico(2404).dsrefere_jur := 'ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO - PESSOA JURIDICA';

          vr_tab_historico(2407).nrctaori_fis := 7141;
          vr_tab_historico(2407).nrctades_fis := 7141;
          vr_tab_historico(2407).dsrefere_fis := 'ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO - PESSOA FISICA';
          vr_tab_historico(2407).nrctaori_jur := 7141;
          vr_tab_historico(2407).nrctades_jur := 7141;
          vr_tab_historico(2407).dsrefere_jur := 'ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO - PESSOA JURIDICA';

       END;

    BEGIN
       -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
       cecred.gene0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_gera_arq_prejuizo', pr_action => NULL);

       -- Inicia Variavel
       pr_dscritic := NULL;

       -- Inicializa Pl-Table
       pc_inicia_historico_prejuizo;

       -- Nome do arquivo a ser gerado
       vr_nmarqdat_prejuizo := vr_dtmvtolt_yymmdd||'_PREJUIZO_NOVA_CENTRAL.txt';

       vr_tab_valores_ag.DELETE;
       vr_index := 0;


       -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
       FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

          -- Verifica se existe o historico na PL-Table
          IF vr_tab_historico.EXISTS(rw_craprej.cdhistor) THEN

             -- Escrever no arquivo somente os registros que o valor for maior que zero
             IF rw_craprej.vlsdapli > 0 THEN

                IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                   -- Verifica se existe agrupamento por PA
                   IF vr_tab_valores_ag.COUNT() > 0 THEN

                      -- escreve a linha duplicada
                      vr_index := vr_tab_valores_ag.FIRST;
                      WHILE vr_index IS NOT NULL LOOP

                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

                         vr_index := vr_tab_valores_ag.NEXT(vr_index);
                      END LOOP;

                      -- limpa a table de reveraso
                      vr_tab_valores_ag.DELETE;

                   END IF;

                   vr_aux_contador := vr_aux_contador +1;

                   IF vr_aux_contador = 1 THEN
                      -- Tenta abrir o arquivo de log em modo gravacao
                      cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                              ,pr_nmarquiv => vr_nmarqdat_prejuizo --> Nome do arquivo
                                              ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                              ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                              ,pr_des_erro => vr_dscritic);        --> Erro
                      IF vr_dscritic IS NOT NULL THEN
                         -- Levantar Excecao
                          RAISE vr_exc_erro;
                     END IF;
                   END IF;

                      IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                         -- Linha de Cabecalho
                      vr_setlinha := fn_set_cabecalho('50'
                                                        ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                        ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                        ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                        ,rw_craprej.vlsdapli
                                                        ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita


                      ELSE -- Pessoa Juridica
                         -- Linha de Cabecalho
                      vr_setlinha := fn_set_cabecalho('50'
                                                        ,vr_dtmvtolt
                                                        ,vr_dtmvtolt
                                                        ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                                        ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                                        ,rw_craprej.vlsdapli
                                                        ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
                         cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                       ,pr_des_text => vr_setlinha); --> Texto para escrita

                      END IF;
                ELSE -- Monta as linhas separadas por agencia
                   vr_index := vr_tab_valores_ag.COUNT()+1;
                   vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                            ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                   cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                END IF;
             END IF;
          END IF;
       END LOOP;

       -- Quando for o ultimo historico, verifica se existe agrupamento por PA
       IF vr_tab_valores_ag.COUNT() > 0 THEN

          -- escreve a linha duplicada
          vr_index := vr_tab_valores_ag.FIRST;
          WHILE vr_index IS NOT NULL LOOP

             cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita

             vr_index := vr_tab_valores_ag.NEXT(vr_index);
          END LOOP;

                      END IF;

       vr_tab_valores_ag.DELETE;

       IF vr_aux_contador > 0 THEN
         -- Fechar Arquivo
         BEGIN
            cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
         EXCEPTION
            WHEN OTHERS THEN
            --Inclusão na tabela de erros Oracle - Chamado 734422
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
            vr_cdcritic := 1039;
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_diretorio||'/'||vr_nmarqdat_prejuizo||'>: ' || SQLERRM;
            RAISE vr_exc_erro;
         END;

         vr_nmarqdat_prejuizo_nov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PREJUIZO_NOVA_CENTRAL.txt';

         -- Copia o arquivo gerado para o diretório final convertendo para DOS
         cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat_prejuizo||' > '||vr_dsdircop||'/'||vr_nmarqdat_prejuizo_nov||' 2>/dev/null',
                                     pr_typ_saida   => vr_typ_said,
                                     pr_des_saida   => vr_dscritic);
         -- Testar erro
         if vr_typ_said = 'ERR' then
           vr_cdcritic := 1040;
           cecred.gene0001.pc_print(cecred.gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat_prejuizo||': '||vr_dscritic);
         end if;

                   END IF;

       -- Limpa Pl-Table
       vr_tab_historico.DELETE;

    EXCEPTION
       WHEN vr_exc_erro THEN
          NULL;
       WHEN OTHERS THEN
         --Inclusão na tabela de erros Oracle - Chamado 734422
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
         vr_cdcritic := 1044;
         pr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' AAMMDD_PREJUIZO_NOVA_CENTRAL.txt. Erro: '|| SQLERRM;
    END;

  BEGIN

    -- Nome do programa
    vr_cdprogra := 'CRPS249';

    -- Calcular o calendario com base na data de referencia enviada
    GESTAODERISCO.obterCalendario(pr_cdcooper   => pr_cdcooper
                                 ,pr_dtrefere   => pr_dtrefere
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdcritic   => pr_cdcritic
                                 ,pr_dscritic   => pr_dscritic);
    -- Testar retorno de erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Gerar erro e roolback
      RAISE vr_exc_saida;
    END IF;

    -- nao vai ser usado
    vr_dtinicrps659 := rw_crapdat.dtmvtoan;

    -- Carrega as variáveis
    vr_dtmvtolt := rw_crapdat.dtmvtoan;

    vr_dtmvtopr := rw_crapdat.dtmvtolt;

    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => rw_crapdat.dtmvtoan -1,
                                               pr_tipo => 'A');

    vr_dtultdia := last_day(vr_dtmvtolt);
    vr_dtultdia_prxmes := last_day(vr_dtmvtopr);


    vr_dtultdma := trunc(vr_dtmvtolt,'month') -1;

    -- Buscar os dados da cooperativa
    OPEN  cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;
    --  Le tabela com as contas convenio do Banco do Brasil
    vr_lscontas := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 0);
    IF vr_lscontas IS NULL THEN
      vr_cdcritic := 393;
      RAISE vr_exc_saida;
    END IF;
    --
    vr_lsconta4 := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 4);
    IF vr_lsconta4 IS NULL THEN
      vr_cdcritic := 393;
      RAISE vr_exc_saida;
    ELSE
      vr_rel_nrdctabb := to_number(fn_ultctaconve(vr_lsconta4));
    END IF;

    vr_dtiniexc := SYSDATE;

    -- Limpa PL/Tables
    vr_tab_agencia.delete;
    vr_tab_agencia2.delete;

    vr_dtdurexc := to_date(to_char(SYSDATE,'sssss') - to_char(vr_dtiniexc,'sssss'),'SSSSS');

    -- Formata a data para criar o nome do arquivo
    vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yymmdd');

    -- Leitura das agências e criação da PL/Table
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    FOR rw_crapage in cr_crapage LOOP
      pc_cria_agencia_pltable(rw_crapage.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_tab_agencia2(rw_crapage.cdagenci).vr_cdccuage := rw_crapage.cdccuage;
      vr_tab_agencia2(rw_crapage.cdagenci).vr_cdcxaage := rw_crapage.cdcxaage;

      vr_tab_agencia3(rw_crapage.cdagenci).vr_rateio := FALSE;
    END LOOP;

    -- Busca do diretório onde ficará o arquivo
    vr_nom_diretorio := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => 'contab');

    -- Busca o diretório final para copiar arquivos
    vr_dsdircop := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

    -- Nome do arquivo a ser gerado
    vr_nmarqdat := vr_dtmvtolt_yymmdd||'_NOVA_CENTRAL.txt';

    -- Abre o arquivo para escrita
    cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                             pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                             pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                             pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                             pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      RAISE vr_exc_saida;
    END IF;
    -- Inicialização das variáveis que controlam as quebras do arquivo
    vr_cdhistor := 0;
    vr_dtrefere := 'x';
    vr_vldtotal := 0;
    vr_idfunding := 0;
    vr_idhmequit := 0;
    vr_idempgara := 0;

    -- Leitura dos rejeitados na integração
    for rw_craprej in cr_craprej (pr_cdcooper,vr_cdprogra,vr_dtmvtolt,0) loop

      IF (vr_cdhistor <> rw_craprej.cdhistor AND
          vr_vldtotal > 0)                   OR
         (vr_cdhistor = rw_craprej.cdhistor  AND
          vr_vldtotal > 0                    AND
          rw_craprej.cdagenci = 0)           THEN
        -- Incluir o total da quebra
        vr_linhadet := '999,'||trim(to_char(vr_vldtotal, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        vr_vldtotal := 0;
      end if;

      if rw_craprej.nrdocmto <> 0 then
        vr_cdageori:= rw_craprej.nrdocmto;
      else
        vr_cdageori:= rw_craprej.cdagenci;
      end if;

      -- Se mudou o historico restartar rateio
      if vr_cdhistor <> rw_craprej.cdhistor then
        vr_rateio90:= false;
        vr_rateio91:= false;
        -- zerar flag de rateio por agencia
        for rw_crapage in cr_crapage loop
          vr_tab_agencia3(rw_crapage.cdagenci).vr_rateio := FALSE;
        end loop;
      end if;

      -- Controle de quebra
      vr_cdhistor := rw_craprej.cdhistor;
      vr_dtrefere := rw_craprej.dtrefere;
      -- Inicialização de variáveis
      vr_linhadet := null;
      vr_cdestrut := null;
      vr_nrctacrd := CONTABILIDADE.obterContaContabil
                       (pr_tipo => 'C'
                       ,pr_nmestrut => UPPER(NVL(rw_craprej.dtrefere, ' '))
                       ,pr_nrdconta => rw_craprej.nrctacrd);
      vr_nrctadeb := CONTABILIDADE.obterContaContabil
                       (pr_tipo => 'D'
                       ,pr_nmestrut => UPPER(NVL(rw_craprej.dtrefere, ' '))
                       ,pr_nrdconta => rw_craprej.nrctadeb);
      --
      if UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'TARIFA' then
        continue; -- lancamentos tratados abaixo, no outro loop
      end if;
      -- De acordo com a tabela de origem, define parâmetros a serem utilizados
      if UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLCT' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM_499' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM_ESTFIN' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLPP' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLAP' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLCM' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLFT' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPTVL' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'COMPBB' then
        vr_cdestrut := '51';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'TBDSCT_LANCAMENTO_BORDERO' then
        vr_cdestrut := '50';
      elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'TBCC_PREJUIZO_DETALHE' then
        vr_cdestrut := '50';    --Rangel Decker
      end if;
      -- Salva informações no arquivo
      if rw_craprej.cdagenci = 0 then

        /* gerar lançamentos 02 e 03, para cada cdhistor (3719,3741,3739,3735,3736) --PJ23311 */
        --gerar lançamento 02 --PJ23311
        IF rw_craprej.cdhistor IN (3719,3741,3739,3735,3736,3940,4114,4247) OR
           (rw_craprej.cdhistor IN (3976,3977,3978,3979) AND vr_idfunding = 0) OR  -- quando Funding e entrar somente uma vez
           (rw_craprej.cdhistor = 4246 AND vr_idhmequit = 0) OR -- quando Home Equity e entrar somente uma vez
           (rw_craprej.cdhistor = 4273 AND vr_idempgara = 0) THEN -- quando Emprestimo Garantido e entrar somente uma vez
          IF rw_craprej.cdhistor = 3719 THEN
            vr_cdhistlct02 := 3737;
          ELSIF rw_craprej.cdhistor = 3741 THEN
            vr_cdhistlct02 := 3740;
          ELSIF rw_craprej.cdhistor = 3739 THEN
            vr_cdhistlct02 := 3738;
          ELSIF rw_craprej.cdhistor = 3735 THEN
            vr_cdhistlct02 := 3732;
          ELSIF rw_craprej.cdhistor = 3736 THEN
            vr_cdhistlct02 := 3733;
          ELSIF rw_craprej.cdhistor = 3940 THEN
            vr_cdhistlct02 := 3939;
          ELSIF rw_craprej.cdhistor IN (3976,3977,3978,3979) AND vr_idfunding = 0 THEN -- Funding e entrar somente uma vez
            vr_cdhistlct02 := 3975;
            vr_idfunding := 1;
          ELSIF rw_craprej.cdhistor = 4114 THEN -- Pro-cotista Imobiliario
            vr_cdhistlct02 := 4113;
          ELSIF (rw_craprej.cdhistor = 4246 AND vr_idhmequit = 0) THEN
            vr_cdhistlct02 := 4244;
             vr_idhmequit := 1;
          ELSIF rw_craprej.cdhistor = 4247 THEN
            vr_cdhistlct02 := 4247;
          ELSIF (rw_craprej.cdhistor = 4274 AND vr_idempgara = 0) THEN
            vr_cdhistlct02 := 4273;
            vr_idempgara := 1;
          ELSIF rw_craprej.cdhistor = 4275 THEN
            vr_cdhistlct02 := 4275;
          END IF;
          OPEN cr_craphis4 (pr_cdcooper => pr_cdcooper
                           ,pr_cdhistor => vr_cdhistlct02);
          FETCH cr_craphis4 INTO rw_craphis4;
          IF cr_craphis4%NOTFOUND THEN
            CLOSE cr_craphis4;
            vr_cdhistorl := NULL;
            vr_dshistor1 := NULL;
            vr_nrctadebl := NULL;
            vr_nrctacrdl := NULL;
          ELSE
            vr_cdhistorl := rw_craphis4.cdhistor;
            vr_dshistor1 := rw_craphis4.dsexthst;
            vr_nrctadebl := rw_craphis4.nrctadeb;
            vr_nrctacrdl := rw_craphis4.nrctacrd;
            CLOSE cr_craphis4;

            IF vr_cdhistlct02 = 3975  THEN
              OPEN cr_craphis6 (pr_cdcooper,vr_dtmvtolt);
              FETCH cr_craphis6 INTO rw_craphis6;
              CLOSE cr_craphis6;
              vr_ttl_vllanmto := rw_craphis6.vllanmto;
            ELSIF vr_cdhistlct02 IN (4244, 4273) THEN
               OPEN cr_craphisttlvlr (pr_cdcooper,rw_craprej.cdhistor,vr_dtmvtolt);
              FETCH cr_craphisttlvlr INTO rw_craphisttlvlr;
              CLOSE cr_craphisttlvlr;
              vr_ttl_vllanmto := rw_craphisttlvlr.vllanmto;
            END IF;

          END IF;

          vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_nrctadebl))||','||
                   trim(to_char(vr_nrctacrdl))||','; --||
          IF vr_cdhistlct02 IN (3975,4244,4273)  THEN
            vr_linhadet := vr_linhadet||
                           trim(to_char(vr_ttl_vllanmto, '99999999999990.00'))||',';
          ELSE
            vr_linhadet := vr_linhadet||
                           trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||',';
          END IF;
          vr_linhadet := vr_linhadet||trim(to_char(rw_craprej.cdhstctb))||','||
                   '"('||trim(to_char(vr_cdhistorl,'0000'))||
                   ') '||trim(vr_dshistor1)||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;
        --gerar lançamento 03 --PJ23311
        IF pr_cdcooper <> 3 AND vr_listou_03 = 0 THEN
          -- Cursor para buscar os históricos que poderão ser gerados este tipo de lançamento --PJ23311
          for rw_craphis5 in cr_craphis5 (pr_cdcooper,vr_dtmvtolt) LOOP
            vr_cdhistorl := NULL;
            IF rw_craphis5.cdhistor = 3719 THEN
              vr_dshistor1 := 'VALOR REF. FGTS CEF - CONCESSAO (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4937;
            ELSIF rw_craphis5.cdhistor = 3741 THEN
              vr_dshistor1 := 'VALOR REF. FGTS CEF - ABATIMENTO DO SALDO DEVEDOR (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 1828;
            ELSIF rw_craphis5.cdhistor = 3739 THEN
              vr_dshistor1 := 'VALOR REF. FGTS CEF - PAGAMENTO DE PARCELA (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4794;
            ELSIF rw_craphis5.cdhistor = 3735 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO TED VENDEDOR (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3736 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO TED INTERVENIENTE QUITANTE (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3926 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO VENDEDOR ATRAVES DE TRANSF.INTERCOOPERATIVAS (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3930 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO INTERVENIENTE QUITANTE DE TRANSF.INTRACOOPERATIVAS (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3940 THEN
              vr_dshistor1 := 'VALOR REF. FGTS CEF - CANCELAMENTO (CREDITO IMOBILIARIO)';
              vr_nrctadebl := 4937;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3976 THEN
              vr_dshistor1 := 'VALOR REF SUBSIDIO ENTRADA FUNDING FGTS CR IMOB SFH';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4838;
            ELSIF rw_craphis5.cdhistor = 3977 THEN
              vr_dshistor1 := 'VALOR REF SUBSIDIO TARIFA FUNDING FGTS CR IMOB SFH';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4839;
            ELSIF rw_craphis5.cdhistor = 3978 THEN
              vr_dshistor1 := 'VALOR REF SUBSIDIO JUROS FUNDING FGTS';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4839;
            ELSIF rw_craphis5.cdhistor = 3979 THEN
              vr_dshistor1 := 'VALOR REF RECURSO DE FUNDING FGTS CREDITO IMOBILIARIO SFH';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4652;
            ELSIF rw_craphis5.cdhistor = 3981 THEN
              vr_dshistor1 := 'PGTO OPERACAO DE FUNDING FGTS';
              vr_nrctadebl := 4652;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 3984 THEN
              vr_dshistor1 := 'JUROS OPERACAO FUNDING FGTS - CR IMOB';
              vr_nrctadebl := 8302;
              vr_nrctacrdl := 4652;
            ELSIF rw_craphis5.cdhistor = 4115 THEN
              vr_dshistor1 := 'VALOR REF RECURSO PRO-COTISTA CRED. IMOB. SFH';
              vr_nrctadebl := 1452;
              vr_nrctacrdl := 4656;
            ELSIF rw_craphis5.cdhistor = 4116 THEN
              vr_dshistor1 := 'JUROS OPERACAO CRED. IMOB. PRO-COTISTA';
              vr_nrctadebl := 8395;
              vr_nrctacrdl := 4656;
            ELSIF rw_craphis5.cdhistor = 4119 THEN
              vr_dshistor1 := 'PGTO OPERACAO CRED. IMOB. PRO-COTISTA';
              vr_nrctadebl := 4656;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 4246 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO TED INTERVENIENTE GARANTIDOR (HOME EQUITY)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 4247 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO INTERVENIENTE GARANTIDOR DE TRANSF.INTRACOOPERATIVAS (HOME EQUITY)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 4274 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO TED INTERVENIENTE GARANTIDOR (EMPRESTIMO GARANTIDOR)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            ELSIF rw_craphis5.cdhistor = 4275 THEN
              vr_dshistor1 := 'VALOR REF. LIQUIDACAO INTERVENIENTE GARANTIDOR DE TRANSF.INTRACOOPERATIVAS (EMPRESTIMO GARANTIDOR)';
              vr_nrctadebl := 4838;
              vr_nrctacrdl := 1452;
            END IF;
            vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_nrctadebl))||','||
                     trim(to_char(vr_nrctacrdl))||','||
                     trim(to_char(rw_craphis5.vllanmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis5.cdhstctb))||','||
                     '"'||trim(vr_dshistor1)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END LOOP;
          vr_listou_03 := 1;
        END IF;

        IF pr_cdcooper <> 3 AND vr_listou_04 = 0 THEN
          OPEN cr_craphis7(pr_cdcooper,vr_dtmvtolt);
               FETCH cr_craphis7 INTO rw_craphis7;

          IF cr_craphis7%NOTFOUND THEN
            CLOSE cr_craphis7;
          ELSE
            vr_dshistor1 := '(crps249) CREDITO DE ANTECIPACAO DE RECEBIVEL DE CARTAO';
            vr_nrctadebl := 1452;
            vr_nrctacrdl := 4957;
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(vr_nrctadebl))||','||
                           trim(to_char(vr_nrctacrdl))||','||
                           trim(to_char(rw_craphis7.vllanmto, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis7.cdhstctb))||','||
                           '"'||trim(vr_dshistor1)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            CLOSE cr_craphis7;
          END IF;
          vr_listou_04 := 1;
        END IF;


        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_nrctadeb))||','||
                       trim(to_char(vr_nrctacrd))||','||
                       trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craprej.cdhstctb))||','||
                       '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                       ') '||trim(rw_craprej.dsexthst)||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);


        if rw_craprej.nrctadeb = 1101 then  -- Custodia
          vr_linhadet := '001,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        end if;

        if rw_craprej.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        end if;

        if rw_craprej.ingercre = 2 then
          vr_vldtotal := rw_craprej.vllanmto;
        end if;
      ELSE

        vr_vlarrecada:= 0;

        IF rw_craprej.nrdocmto <> 0 THEN

          if vr_cdageori in(90,91) then
            -- Se ja fez pro pa 90 ou 91 não faz mais
            if vr_rateio90 = false and vr_cdageori = 90 then
              for rw_craprej_arr in cr_craprej_arr( pr_cdcooper,
                                                    vr_cdprogra,
                                                    vr_dtmvtolt,
                                                    0,
                                                    vr_cdageori,
                                                    rw_craprej.cdhistor) loop
                vr_rateio90:= true;
                vr_vlarrecada := vr_vlarrecada + rw_craprej_arr.vllanmto;
              end loop;
            end if;

            -- Se ja fez pro pa 90 ou 91 não faz mais
            if vr_rateio91 = false and vr_cdageori = 91 then
              for rw_craprej_arr in cr_craprej_arr( pr_cdcooper,
                                                    vr_cdprogra,
                                                    vr_dtmvtolt,
                                                    0,
                                                    vr_cdageori,
                                                    rw_craprej.cdhistor) loop
                vr_rateio91:= true;
                vr_vlarrecada := vr_vlarrecada + rw_craprej_arr.vllanmto;
              end loop;
            end if;
          ELSE

            if vr_tab_agencia3(vr_cdageori).vr_rateio = false THEN
              for rw_craprej_arr in cr_craprej_arr( pr_cdcooper,
                                                    vr_cdprogra,
                                                    vr_dtmvtolt,
                                                    0,
                                                    vr_cdageori,
                                                    rw_craprej.cdhistor) loop

                vr_tab_agencia3(vr_cdageori).vr_rateio := TRUE;
                vr_vlarrecada := vr_vlarrecada + rw_craprej_arr.vllanmto;
              end loop;
            END IF;
          end if;

          if vr_vlarrecada = 0 then
            continue;
          end if;

        ELSE
          vr_vlarrecada:= rw_craprej.vllanmto;
        END IF;

        if rw_craprej.ingercre = 3 or
           rw_craprej.ingerdeb = 3 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_cdageori).vr_cdccuage,'fm000')||','||
                          trim(to_char(vr_vlarrecada, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        elsif rw_craprej.tpctbcxa > 0 then
          if rw_craprej.tpctbcxa = 2 then -- POR CAIXA DEBITO
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(vr_tab_agencia2(vr_cdageori).vr_cdcxaage, 'fm0000'))||','||
                           trim(to_char(vr_nrctacrd))||','||
                           trim(to_char(vr_vlarrecada, '99999999999990.00'))||','||
                           trim(to_char(rw_craprej.cdhstctb))||','||
                           '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                           ') '||trim(rw_craprej.dsexthst)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            --
            vr_linhadet := to_char(vr_cdageori,'fm000')||','||trim(to_char(vr_vlarrecada, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            --
            if rw_craprej.ingercre = 2 then
              vr_linhadet := '999,'||trim(to_char(vr_vlarrecada, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            end if;
          end if;

          if rw_craprej.tpctbcxa = 3 then -- POR CAIXA CREDITO
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(vr_nrctadeb))||','||
                           trim(to_char(vr_tab_agencia2(vr_cdageori).vr_cdcxaage, 'fm0000'))||','||
                           trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                           trim(to_char(rw_craprej.cdhstctb))||','||
                           '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                           ') '||trim(rw_craprej.dsexthst)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            --
            if rw_craprej.ingerdeb = 2    then
              vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            end if;
            --
            vr_linhadet := to_char(vr_cdageori,'fm000')||','||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          end if;
          --
          if rw_craprej.tpctbcxa in (4, 6) then  -- POR BB A DEBITO
            vr_nrdctabb := null;
            --
            IF rw_craprej.cdhistor in (266, 971, 977, 1088, 1089, 1998, 1999, 2000, 2001, 2002, 2012, 2180
                                      ,2277 ,2278 -- Marcelo Telles Coelho - Mouts - 15/01/2018 - SD 818020
                                      ) then
               --  266 - cred. cobranca
               --  971 - cred cobr - BB
               --  977 - cred cobr - CECRED
               -- 1088 - liq apos baixa - BB
               -- 1089 - liq apos baixa - CECRED
               -- 1998 - CREDITO PAGAMENTO CONTRATO INTEGRAL
               -- 1999 - CREDITO PAGAMENTO CONTRATO ATRASO
               -- 2000 - CREDITO QUITACAO DE EMPRESTIMO
               -- 2001 - DEVOLUCAO BOLETO VENCIDO
               -- 2002 - AJUSTE CONTRATO PROCESSO EM ATRASO
               -- 2012 - AJUSTE BOLETO (EMPRESTIMO)
         -- 2180 - CRED.COB. ACORDO
               -- 2277 - CREDITO PARCIAL PREJUIZO
               -- 2278 - CREDITO LIQUIDAÇÃO PREJUIZO
              vr_nrdctabb := to_char(rw_craprej.nrctadeb);
            else
              open cr_craptab (pr_cdcooper,
                               11, --cdempres
                               'CONTAB', --tptabela
                               to_char(rw_craprej.nrdctabb),
                               rw_craprej.cdbccxlt);
                fetch cr_craptab into vr_nrdctabb;
              close cr_craptab;
            end if;
            --
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(vr_nrdctabb)||','||
                           trim(to_char(vr_nrctacrd))||','||
                           trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                           trim(to_char(rw_craprej.cdhstctb))||','||
                           '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                           ') '||trim(rw_craprej.dsexthst)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            --
            if rw_craprej.ingercre = 2 then
              vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            end if;
          end if;
          --
          if rw_craprej.tpctbcxa = 5 then  -- POR BB A CREDITO
            vr_nrdctabb := null;
            open cr_craptab (pr_cdcooper,
                             11, --cdempres
                             'CONTAB', --tptabela
                             to_char(rw_craprej.nrdctabb),
                             rw_craprej.cdbccxlt);
              fetch cr_craptab into vr_nrdctabb;
            close cr_craptab;
            --
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(vr_nrctadeb))||','||
                           trim(vr_nrdctabb)||','||
                           trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                           trim(to_char(rw_craprej.cdhstctb))||','||
                           '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                           ') '||trim(rw_craprej.dsexthst)||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            --
            if rw_craprej.ingerdeb = 2 then
              vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            end if;
          end if;
        end if;
      end if;
    end loop;
    -- Incluir o total da última quebra
    if vr_vldtotal > 0 then
      vr_linhadet := '999,'||trim(to_char(vr_vldtotal, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;

    vr_cdestrut := '55';
    -- Tratar quantidade de lancamentos para tarifa
    for rw_craprej2 in cr_craprej2 (pr_cdcooper,
                                    vr_cdprogra,
                                    vr_dtmvtolt
                                    ,0) loop

      OPEN  cr_craphis2(rw_craprej2.cdcooper
                       ,rw_craprej2.cdhistor);
      FETCH cr_craphis2 INTO rw_craphis2;
      IF cr_craphis2%NOTFOUND THEN
        CLOSE cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := rw_craprej2.cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craphis2;

      IF rw_craphis2.tpctbcxa > 3 AND
         rw_craprej2.dtrefere <> 'TARIFA' THEN
        continue; -- lancamentos por conta banco do brasil
      END IF;
      -- Desconsiderar lancamentos de tarifa de cheques cta integracao
      if pr_cdcooper <> 3 then
        if rw_craphis2.cdhistor = 50 then
          if pr_cdcooper = 2 then
            -- Identifica se conta eh Integracao
            if vr_rel_nrdctabb = rw_craprej2.nrdctabb then
              continue;
            end if;
          else
            continue;  -- BB nao cobra mais a tarifa ref. cta base
          end if;
        end if;
      end if;
      --
      vr_linhadet := null;
      vr_nrctatrd := to_char(rw_craphis2.nrctatrd);
      vr_nrctatrc := to_char(rw_craphis2.nrctatrc);
      vr_vltarifa := 0;
      vr_vltarifa_ep := 0;
      vr_vltarifa_taa := 0;
      vr_vltarifa_taa_ep := 0;
      vr_vltarifa_ib  := 0;
      vr_vltarifa_ib_ep  := 0;

      if rw_craprej2.cdagenci = 0 then
        if rw_craprej2.dtrefere = 'TARIFA' then -- por conta BB
          vr_nrdctabb := null;
          --
          open cr_craptab2 (pr_cdcooper,
                            'CONTAB',
                            to_char(rw_craprej2.nrdctabb));
            fetch cr_craptab2 into vr_nrdctabb;
          close cr_craptab2;
          --
          if nvl(vr_nrdctabb, ' ') = ' ' then
            open cr_craptab2 (pr_cdcooper,
                              'CONTAB',
                              to_char(vr_rel_nrdctabb));
              fetch cr_craptab2 into vr_nrdctabb;
            close cr_craptab2;
          end if;
          --
          if rw_craphis2.cdhistor not in (266, 971, 977, 1088, 1089) then
            --  266 - cred. cobranca
            --  971 - cred cobr - BB
            --  977 - cred cobr - CECRED
            -- 1088 - liq apos baixa - BB
            -- 1089 - liq apos baixa - CECRED
            if rw_craphis2.tpctbcxa = 4 then
              vr_nrctatrd := vr_nrdctabb;
            elsif rw_craphis2.tpctbcxa = 5 then
              vr_nrctatrc := vr_nrdctabb;
            elsif rw_craphis2.tpctbcxa = 6 then
              vr_nrctatrc := vr_nrdctabb;
            end if;
          end if;
        end if;
        -- xpto
        if rw_craprej2.nrseqdig > 0 then -- Se qtd de lançamentos para contas <> Ente Público, gera registro
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_nrctatrd))||','||
                       trim(to_char(vr_nrctatrc))||','||
                       trim(to_char(rw_craprej2.nrseqdig * rw_craprej2.vltarifa, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))||
                       ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        -- P681- Entes Públicos - Marcus Abreu
        -- Se estamos trabalhando com os dados totalizadores e temos valor de lançamentos do histórico para Entes Públicos,
        -- guardamos na estrutura de memória totalizadora, para posteriormente gerarmos no arquivo o devido cabeçalho(após este loop).
        if rw_craprej2.tpintegr > 0 then
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).cdestrut         := trim(vr_cdestrut);
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).dtmvtolt_yymmdd  := trim(vr_dtmvtolt_yymmdd);
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).dtmvtolt         := trim(to_char(vr_dtmvtolt,'ddmmyy'));
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).nrctatrd         := trim(to_char(vr_nrctatrd));
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).nrctatrc         := trim(to_char(case when vr_nrctatrc = 7255 then 7290
                                                                                             WHEN vr_nrctatrc = 7397 THEN 7398 else vr_nrctatrc end));
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).vllamnto         := trim(to_char(rw_craprej2.tpintegr * rw_craprej2.vltarifa, '99999999999990.00'));
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).cdhstctb         := trim(to_char(rw_craphis2.cdhstctb));
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor).dscontab         := '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))|| ') '||trim(rw_craphis2.dsexthst)||' EP (tarifa)"';
        end if;
      else

        vr_agencia_prox:= rw_craprej2.cdagenci;

        -- Verificar se a proxima Agencia eh igual a anterior
        IF nvl(vr_agencia_ant,0) = nvl(vr_agencia_prox,0) and
           vr_cdhistor = rw_craprej2.cdhistor THEN
          continue;
        END IF;

        vr_cdhistor := rw_craprej2.cdhistor;

        ----------------------------------------------------------------------------------------------------
        -- Verificar os registros daquele PA, ex: PA 4 tem 2 lancamentos registrados na agencia 4,
        -- 2 lancamentos registrados no PA 90 e 1 no 91, então vamos contabilizar as tarifas baseadas no
        -- PA de origem do lancamentos, se foi efetuados no IB vamos pegar a tarifa do Internet, se no
        -- TAA vamos pegar a do CASH.  O campo craprej.nrdocmto esta gravado a agencia origem do lançamento.
        -- Porem o lançamento desta tarifa deverá ser registrado na agencia do cooperado ou do terminal(TAA)
        ----------------------------------------------------------------------------------------------------


        if rw_craphis2.nmestrut = 'CRAPLFT' THEN
          FOR rw_craprej_pa IN cr_craprej_pa(rw_craprej2.cdcooper,
                           rw_craprej2.cdhistor,
                                             vr_dtmvtolt,
                                             rw_craprej2.cdagenci) LOOP
            -- cdagenci original
            IF rw_craprej_pa.nrdocmto = 90 THEN -- Internet
              OPEN cr_crabthi (pr_cdcooper,
                               rw_craprej_pa.cdhistor,
                           'INTERNET');
                FETCH cr_crabthi INTO rw_crabthi;
                IF cr_crabthi%FOUND THEN
                  vr_vltarifa_ib := rw_craprej_pa.nrseqdig * rw_crabthi.vltarifa;
                  IF rw_craprej_pa.tpintegr > 0 THEN
                    vr_vltarifa_ib_ep := rw_craprej_pa.tpintegr * rw_crabthi.vltarifa;
                  END IF;
                END IF;
              CLOSE cr_crabthi;
            ELSIF rw_craprej_pa.nrdocmto = 91 THEN -- TAA
              OPEN cr_crabthi (pr_cdcooper,
                               rw_craprej_pa.cdhistor,
                           'CASH');
                FETCH cr_crabthi INTO rw_crabthi;
                IF cr_crabthi%FOUND THEN
                  vr_vltarifa_taa := rw_craprej_pa.nrseqdig * rw_crabthi.vltarifa;
                  IF rw_craprej_pa.tpintegr > 0 THEN
                    vr_vltarifa_taa_ep := rw_craprej_pa.tpintegr * rw_crabthi.vltarifa;
                  END IF;
                END IF;
              CLOSE cr_crabthi;
            ELSE
              vr_vltarifa:= vr_vltarifa + (rw_craprej_pa.nrseqdig * rw_craprej2.vltarifa);
              IF rw_craprej_pa.tpintegr > 0 THEN
                 vr_vltarifa_ep := vr_vltarifa_ep + (rw_craprej_pa.tpintegr * rw_craprej2.vltarifa);
              END IF;
            END IF;

          END LOOP;
        else
          -- cdagenci original
          IF rw_craprej2.cdagenci = 90 THEN -- Internet
            OPEN cr_crabthi (pr_cdcooper,
                             rw_craprej2.cdhistor,
                             'INTERNET');
              FETCH cr_crabthi INTO rw_crabthi;
              IF cr_crabthi%FOUND THEN
                vr_vltarifa_ib := rw_craprej2.nrseqdig * rw_crabthi.vltarifa;
                IF rw_craprej2.tpintegr > 0 THEN
                  vr_vltarifa_ib_ep := rw_craprej2.tpintegr * rw_crabthi.vltarifa;
                END IF;
              END IF;
            CLOSE cr_crabthi;
          ELSIF rw_craprej2.cdagenci = 91 THEN -- TAA
            OPEN cr_crabthi (pr_cdcooper,
                             rw_craprej2.cdhistor,
                             'CASH');
              FETCH cr_crabthi INTO rw_crabthi;
              IF cr_crabthi%FOUND THEN
                vr_vltarifa_taa := rw_craprej2.nrseqdig * rw_crabthi.vltarifa;
                IF rw_craprej2.tpintegr > 0 THEN
                  vr_vltarifa_taa_ep := rw_craprej2.tpintegr * rw_crabthi.vltarifa;
                END IF;
              END IF;
            CLOSE cr_crabthi;
          ELSE
            vr_vltarifa:= vr_vltarifa + (rw_craprej2.nrseqdig * rw_craprej2.vltarifa);
            IF rw_craprej2.tpintegr > 0 THEN
               vr_vltarifa_ep := vr_vltarifa_ep + (rw_craprej2.tpintegr * rw_craprej2.vltarifa);
            END IF;
          END IF;
            end if;

        vr_vltarifa:= vr_vltarifa + vr_vltarifa_taa + vr_vltarifa_ib;
        vr_vltarifa_ep := vr_vltarifa_ep + vr_vltarifa_taa_ep + vr_vltarifa_ib_ep;

        if rw_craphis2.tpctbcxa in (2,3) then
          if vr_vltarifa > 0 then
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_nrctatrd))||','||
                         trim(to_char(vr_nrctatrc))||','||
                         trim(to_char(vr_vltarifa, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))||
                         ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
          -- P681- Entes Públicos - Marcus Abreu
          -- Caso o tipo seja detalhado por agência, não é feito o registro da agencia 0
          -- Logo, armazeno o cabeçalho com a agencia, para consumir posteriormente e gerar os dados para o Ente Público
          if vr_vltarifa_ep > 0 then
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).cdestrut         := trim(vr_cdestrut);
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).dtmvtolt_yymmdd  := trim(vr_dtmvtolt_yymmdd);
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).dtmvtolt         := trim(to_char(vr_dtmvtolt,'ddmmyy'));
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).nrctatrd         := trim(to_char(vr_nrctatrd));
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).nrctatrc         := trim(to_char(case when vr_nrctatrc = 7255 then 7290
                                                                                                                     WHEN vr_nrctatrc = 7397 THEN 7398 else vr_nrctatrc end));
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).vllamnto         := trim(to_char(vr_vltarifa_ep, '99999999999990.00'));
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).cdhstctb         := trim(to_char(rw_craphis2.cdhstctb));
            vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).dscontab         := '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))|| ') '||trim(rw_craphis2.dsexthst)||' EP (tarifa)"';
          end if;
        end if;
        --
        if vr_vltarifa > 0 then
        vr_linhadet := to_char(rw_craprej2.cdagenci,'fm000')||','||trim(to_char(vr_vltarifa, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;

        -- Se estamos trabalhando com os dados por agencia, e temos valor de lançamentos do histórico para Entes Públicos,
        -- guardamos na estrutura de memória da agencia, para posteriormente gerarmos no arquivo os registros detalhados (após este loop).
        if vr_vltarifa_ep > 0 then
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).agencias(rw_craprej2.cdagenci).cdagenci := to_char(rw_craprej2.cdagenci,'fm000');
          vr_tab_arr_conv_tot_ep(rw_craphis2.cdhistor||rw_craprej2.cdagenci).agencias(rw_craprej2.cdagenci).vllamnto := trim(to_char(vr_vltarifa_ep, '999999990.00'));
        end if;
        --Acumular valores de despesas de cobranca para geração de arquivo contábil
        if rw_craphis2.cdhistor = 266 and vr_contador = 0 then
          vr_contador := 1;
          for rw_craplcm9 in cr_craplcm9(pr_cdcooper,vr_dtmvtolt,rw_craphis2.cdhistor) loop
            if rw_craplcm9.inpessoa = 1 then

               if vr_tab_vlr_age_fis.EXISTS(rw_craplcm9.cdagenci) then
                 -- Soma os valores por agencia de pessoa fisica
                 vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) := vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) + (rw_craplcm9.nrseqdig * vr_vltarifa);
               else
               -- Inicializa o array com o valor inicial de pessoa fisica
                 vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) := rw_craplcm9.nrseqdig * vr_vltarifa;
               end if;
            else
              if vr_tab_vlr_age_jur.EXISTS(rw_craplcm9.cdagenci) then
                 -- Soma os valores por agencia de pessoa jurídica
                 vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) := vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) + (rw_craplcm9.nrseqdig * vr_vltarifa);
               else
               -- Inicializa o array com o valor inicial de pessoa fisica
                 vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) := rw_craplcm9.nrseqdig * vr_vltarifa;
               end if;
            end if;

            --Totalizar valores por tipo de pessoa
            if vr_tab_vlr_descbr_pes.EXISTS(rw_craplcm9.inpessoa) then
              -- Soma os valores por tipo de pessoa
              vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) := vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) +  (rw_craplcm9.nrseqdig * vr_vltarifa);
            else
              -- Inicializa o array com o valor inicial de cada tipo de pessoa
              vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) := rw_craplcm9.nrseqdig * vr_vltarifa;
            end if;
          end loop;
        end if;
      end if;
      vr_agencia_ant:= rw_craprej2.cdagenci;
    end loop;
    vr_ind_tot_ep := vr_tab_arr_conv_tot_ep.first;
    -- Percorre a tabela de memória, populada com os valores de arrecadações de convênios próprios totais e por agência,
    -- de cada histórico, para os Entes Públicos
    while vr_ind_tot_ep is not null loop
      vr_linhadet := null;
      -- Gera a linha totalizadora
      vr_linhadet := vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).cdestrut        ||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).dtmvtolt_yymmdd ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).dtmvtolt        ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).nrctatrd        ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).nrctatrc        ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).vllamnto        ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).cdhstctb        ||','||
                     vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).dscontab;
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       -- Percorre a tabela de memória dos valores por agência
       --vr_linhadet := 'Qtdade de detalhamento de agencias: ' || vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).agencias.count;
       --cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       vr_ind_age_ep := vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).agencias.first;
       while vr_ind_age_ep is not null loop
         vr_linhadet := null;
         vr_linhadet := vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).agencias(vr_ind_age_ep).cdagenci ||','||
                        vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).agencias(vr_ind_age_ep).vllamnto;
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         vr_ind_age_ep := vr_tab_arr_conv_tot_ep(vr_ind_tot_ep).agencias.next(vr_ind_age_ep);
       end loop;
       vr_ind_tot_ep := vr_tab_arr_conv_tot_ep.next(vr_ind_tot_ep);
    end loop;

    -- Plano de controle Pagfor dos arquivos de remessa (A - Arquivos CSV Nexxera > Sicredi / B - Arquivos CNAB Connect:Direct > Sicredi / C - CSV SOA > API Bancoob e TIVIT)
    vr_plnctlpf := UPPER(TRIM(cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 0, pr_cdacesso => 'PLN_CTRL_PAGFOR')));
    -- Data em que mudança no plano de controle do Pagfor entra em vigor
    vr_datctlpf := TO_DATE(TRIM(cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 0, pr_cdacesso => 'DATA_CTRL_PAGFOR')),'DD/MM/RRRR');

    -- Convênios Sicredi migrando para arrecadação através de API do Bancoob e TIVIT.
    -- DARF, DAS e GPS com código de barras precisam entrar na conciliação contábil do Bancoob, seguindo mesmo modelo da arrecadação de água, luz e telefone através de arquivos.
    -- DARF e GPS sem código da barras e demais convênios arrecadados via TIVIT entram na conciliação contábil seguindo mesmo modelo do PagFor

    IF vr_plnctlpf IN ('A','B') OR (vr_plnctlpf = 'C' AND vr_datctlpf > vr_dtmvtolt) THEN
      vr_cdhistor := 1154;
      vr_nrctacre := 1452;
      vr_nrctadeb := 4310;
      vr_cdagente := 1;
    ELSE
      vr_cdhistor := 3361;
      vr_nrctacre := 1452;
      vr_nrctadeb := 4300;
      vr_cdagente := 3;
    END IF;

    -- Armazenar pagamentos de convênios rejeitados no PAGFOR Sicredi ou TIVIT
    vr_tab_rej_sicredi_tivit.delete;
    FOR rw_rejeicoes_sicredi_tivit IN cr_rejeicoes_sicredi_tivit(pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => vr_dtmvtolt
                                                                ,pr_cdagente => vr_cdagente) LOOP
      vr_idx_rej_pagfor := TO_CHAR(LPAD(rw_rejeicoes_sicredi_tivit.cdagenci,5,'0')) || RPAD(rw_rejeicoes_sicredi_tivit.cdempres,10,'*');
      vr_tab_rej_sicredi_tivit(vr_idx_rej_pagfor) := rw_rejeicoes_sicredi_tivit.vllanmto;
      END LOOP;

    -- Obter Histórico do Agente Arrecadador
    OPEN cr_craphis2 (pr_cdcooper, vr_cdhistor);
      FETCH cr_craphis2 INTO rw_craphis2;
      IF cr_craphis2%NOTFOUND THEN
        CLOSE cr_craphis2;
        vr_cdcritic := 526;
      vr_dscritic := TO_CHAR(vr_cdhistor)||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craphis2;
      --
      vr_nrctacrd := rw_craphis2.nrctacrd;
      vr_cdestrut := '50';

    -- Convênios com código de barras
      open cr_craplft(pr_cdcooper,
                      vr_dtmvtolt,
                      rw_craphis2.cdhistor);
      loop

        --joga dados do cursor na variável de 5000 em 5000
        fetch cr_craplft bulk collect into rw_craplft limit 5000;

        --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      FOR i IN 1..rw_craplft.count LOOP

          OPEN cr_crapcon(pr_cdcooper
                         ,rw_craplft(i).cdempcon
                         ,rw_craplft(i).cdsegmto);
          FETCH cr_crapcon INTO rw_crapcon;

          -- Se não encontrou convênio
          IF cr_crapcon%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_crapcon;
          CONTINUE;
          END IF;
          -- Fechar cursor
          CLOSE cr_crapcon;

          OPEN cr_crapscn(rw_craplft(i).cdempcon, rw_craplft(i).cdsegmto);
        FETCH cr_crapscn INTO rw_crapscn;
        IF cr_crapscn%NOTFOUND THEN
          CLOSE cr_crapscn;
            OPEN cr_crapscn3(rw_craplft(i).cdempcon, rw_craplft(i).cdsegmto);
          FETCH cr_crapscn3 INTO rw_crapscn;
          IF cr_crapscn3%NOTFOUND THEN
            CLOSE cr_crapscn3;
            CONTINUE;
          END IF;
          CLOSE cr_crapscn3;
        ELSE
          CLOSE cr_crapscn;
        END IF;

        -- Para DPVAT usar conta 4336
        -- PAGFOR - DPVAT tbem irá usar a conta 4310
        -- DPVAT - Solicitado via RITM0125785, alteração para conta 4300
        IF rw_crapscn.cdempres = '85' THEN
          vr_nrctasic := 4300;
        ELSE
          vr_nrctasic := vr_nrctacrd;
        END IF;

          -- Incrementa o contador na pl/table de faturas
            vr_indice_faturas := to_char(rw_craplft(i).tpfatura, 'fm0')||to_char(rw_craplft(i).cdagenci_fatura, 'fm000');
            vr_tab_faturas(vr_indice_faturas).vr_tpfatura := rw_craplft(i).tpfatura;
            vr_tab_faturas(vr_indice_faturas).vr_cdagenci := rw_craplft(i).cdagenci_fatura;
            vr_tab_faturas(vr_indice_faturas).vr_qtlanmto := nvl(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto, 0) + rw_craplft(i).qtlanmto;

          -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
          vr_vllanmto_fat := nvl(vr_vllanmto_fat,0) + rw_craplft(i).vllanmto;

        -- Verifica se é a mesma Agência/Convênio/Segmento, se for, busca o próximo registro
        if rw_craplft(i).cdagenci = rw_craplft(i).proxima_agencia  AND
           rw_craplft(i).cdempcon = rw_craplft(i).proximo_cdempcon AND
           rw_craplft(i).cdsegmto = rw_craplft(i).proximo_cdsegmto THEN
            continue;
          end if;

          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(vr_tab_agencia2(rw_craplft(i).cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(vr_nrctasic))||','||
                         trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') '||trim(rw_crapscn.cdempres)||' - '||
                       trim(nvl(rw_crapcon.nmextcon, 'CONVENIO NAO ENCONTRADO(crapcon)'))||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craplft(i).cdagenci,'fm000')||','||trim(to_char(vr_vllanmto_fat, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --

          -- Subtrair do valor total de repasse a soma dos pagamentos rejeitados para o convênio que será listado no arquivo
          vr_idx_rej_pagfor := TO_CHAR(LPAD(rw_craplft(i).cdagenci,5,'0')) || RPAD(rw_crapscn.cdempres,10,'*');
        IF vr_tab_rej_sicredi_tivit.EXISTS(vr_idx_rej_pagfor) THEN
          vr_vllanmto_fat := vr_vllanmto_fat - vr_tab_rej_sicredi_tivit(vr_idx_rej_pagfor);
          END IF;

          IF vr_vllanmto_fat > 0 THEN
            -- ***********************************************************************
            -- PAGFOR - Historico 1154 - D-4310 / C-1452 (Cechet)
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         TO_CHAR(vr_nrctadeb)||','||TO_CHAR(vr_nrctacre)||','||
                           trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') '||trim(rw_crapscn.cdempres)||' - '||
                         trim(nvl(rw_crapcon.nmextcon, 'CONVENIO NAO ENCONTRADO(crapcon)')) || ' (REPASSE)' ||'"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            -- ***********************************************************************
            --
          END IF;

          vr_vllanmto_fat := 0;

      END LOOP;

          exit when cr_craplft%rowcount <= 5000;
        end loop;
        close cr_craplft;

    -- DARF's sem código de barras
      -- Primeiro serão lidas as DARF's com código de tributo 6106
      vr_idtributo_6106 := 1;
      loop

        vr_vllanmto_fat := 0;

      for rw_craplft2 in cr_craplft2 (pr_cdcooper,
                                      vr_dtmvtolt,
                                      0,
                                      6,
                                      rw_craphis2.cdhistor,
                                        2,
                                      vr_idtributo_6106) loop

        -- Incrementa o contador na pl/table de faturas
        vr_indice_faturas := to_char(rw_craplft2.tpfatura, 'fm0')||to_char(rw_craplft2.cdagenci_fatura, 'fm000');
        vr_tab_faturas(vr_indice_faturas).vr_tpfatura := rw_craplft2.tpfatura;
        vr_tab_faturas(vr_indice_faturas).vr_cdagenci := rw_craplft2.cdagenci_fatura;
        vr_tab_faturas(vr_indice_faturas).vr_qtlanmto := nvl(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto, 0) + rw_craplft2.qtlanmto;
          -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
          vr_vllanmto_fat := vr_vllanmto_fat + rw_craplft2.vllanmto;
        --
        open cr_crapscn2 (rw_craplft2.cdempres);
          fetch cr_crapscn2 into rw_crapscn2;
        close cr_crapscn2;

          vr_nrctasic := vr_nrctacrd;

          -- Verifica se é a mesma agência e, se for, busca o próximo registro
          if rw_craplft2.cdagenci = rw_craplft2.proxima_agencia then
            continue;
          end if;
          --

          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_tab_agencia2(rw_craplft2.cdagenci).vr_cdcxaage,'fm0000'))||','||
                         trim(to_char(vr_nrctasic))||','||
                         trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') '||trim(rw_crapscn2.cdempres)||' - '||
                         trim(rw_crapscn2.dsnomcnv)||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craplft2.cdagenci,'fm000')||','||trim(to_char(vr_vllanmto_fat, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --

          -- Subtrair do valor total de repasse a soma dos pagamentos rejeitados para o convênio que será listado no arquivo
          vr_idx_rej_pagfor := TO_CHAR(LPAD(rw_craplft2.cdagenci,5,'0')) || RPAD(rw_crapscn2.cdempres,10,'*');
        IF vr_tab_rej_sicredi_tivit.EXISTS(vr_idx_rej_pagfor) THEN
          vr_vllanmto_fat := vr_vllanmto_fat - vr_tab_rej_sicredi_tivit(vr_idx_rej_pagfor);
          END IF;

          IF vr_vllanmto_fat > 0 THEN
            -- ***********************************************************************
            -- PAGFOR - Historico 1154 - D-4310 / C-1452 (Cechet)
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         TO_CHAR(vr_nrctadeb)||','||TO_CHAR(vr_nrctacre)||','||
                           trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') '||trim(rw_crapscn2.cdempres)||' - '||
                           trim(rw_crapscn2.dsnomcnv)||' (REPASSE)"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            -- ***********************************************************************
            --
          END IF;

          vr_vllanmto_fat := 0;

        end loop;

        -- Se já obteve DARF's com código de tributo 6106 e também demais códigos sai do loop
        if vr_idtributo_6106 = 0 then
           exit;
        end if;

        -- Ja leu DARF's com tributo 6106 e altera para ler DARF's dos demais tributos
        vr_idtributo_6106 := 0;

      end loop;

    IF vr_plnctlpf IN ('A','B') OR (vr_plnctlpf = 'C' AND vr_datctlpf > vr_dtmvtolt) THEN
      -- Verifica se a cooperativa paga as guias GPS para o BB ou BANCOOB
      IF rw_crapcop.cdcrdins <> 0 THEN -- SICREDI
         vr_cdhistor := 1414;
         vr_nrctacre := 1452;
         vr_nrctadeb := 1272;
      ELSE
        IF rw_crapcop.cdcrdarr = 0 THEN
        vr_cdhistor := 458;
          vr_nrctacre := 1452;
          vr_nrctadeb := 1272;
        ELSE
        vr_cdhistor := 582;
          vr_nrctacre := 1452;
          vr_nrctadeb := 1272;
        END IF;
      END IF;
    ELSE
      vr_cdhistor := 3361;
      vr_nrctacre := 1452;
      vr_nrctadeb := 4300;
      END IF;

    -- PAGAMENTO GUIAS PREVIDENCIA .............................................
    vr_tab_agencia.delete;
    vr_vltitulo := 0;
    vr_cdestrut := '51';
      --
      if vr_cdhistor = 582 then
        open cr_crapthi(pr_cdcooper,
                        vr_cdhistor,
                        'CAIXA');
          fetch cr_crapthi into rw_crapthi;
          if cr_crapthi%notfound then
            close cr_crapthi;
            vr_cdcritic := 1041;
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||vr_cdhistor||' - crapthi';
            raise vr_exc_saida;
          end if;
        close cr_crapthi;
      end if;
      --
      if vr_cdhistor = 1414 then
        open cr_crapthi(pr_cdcooper,
                        vr_cdhistor,
                        'AIMARO');
          fetch cr_crapthi into rw_crapthi;
          if cr_crapthi%notfound then
            close cr_crapthi;
            vr_cdcritic := 1041;
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||vr_cdhistor||' - crapthi';
            raise vr_exc_saida;
          end if;
        close cr_crapthi;
      end if;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --

      for rw_gps_gerencial in cr_gps_gerencial (pr_cdcooper,
                                              vr_dtmvtolt,
                                              rw_craphis2.cdhistor) loop
        --
        vr_vltitulo := rw_gps_gerencial.vlrtotal;

        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_gps_gerencial.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd))||','||
                       trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"(' || CASE WHEN vr_cdhistor = 3361 THEN TO_CHAR(vr_cdhistor) ELSE 'crps249' END || ') GPS.  "';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_gps_gerencial.cdagenci, 'fm000')||','||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        -- Subtrair do valor total de repasse a soma dos pagamentos de GPS rejeitados
        vr_idx_rej_pagfor := TO_CHAR(LPAD(rw_gps_gerencial.cdagenci,5,'0')) || RPAD('C06',10,'*');
      IF vr_tab_rej_sicredi_tivit.EXISTS(vr_idx_rej_pagfor) THEN
        vr_vltitulo := vr_vltitulo - vr_tab_rej_sicredi_tivit(vr_idx_rej_pagfor);
        END IF;

        IF vr_vltitulo > 0 THEN
          -- ***********************************************************************
          -- PAGFOR - Historico 1414 - D-1272 / C-1452 (Cechet)
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       TO_CHAR(vr_nrctadeb)||','||TO_CHAR(vr_nrctacre)||','||
                         trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                       '"(' || CASE WHEN vr_cdhistor = 3361 THEN TO_CHAR(vr_cdhistor) ELSE 'crps249' END || ') GPS (REPASSE) "';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          -- ***********************************************************************
          --
        END IF;
      end loop;

    --*************************--
    -- Convênio Sicredi (debito automatico)
    OPEN cr_craphis2 (pr_cdcooper, 1019);
    FETCH cr_craphis2 INTO rw_craphis2;
    IF cr_craphis2%NOTFOUND THEN
      CLOSE cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '1019 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_craphis2;
    --
    vr_nrctacrd := rw_craphis2.nrctacrd;
    vr_cdestrut := '50';

    -- Debito Automatico Sicredi
    FOR rw_craplcm4 IN cr_craplcm4 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    rw_craphis2.cdhistor) LOOP

      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_nrctacrd))||','||
                     trim(to_char(rw_craplcm4.vllanmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_craplcm4.cdempres)|| ' - ' ||
                     TRIM(rw_craplcm4.dsnomcnv) || '"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      vr_linhadet := '999,' || TRIM(to_char(rw_craplcm4.vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    END LOOP;

    -- Tarifa convênio Sicredi Debito Automatico
    FOR rw_craplcm5 IN cr_craplcm5 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    rw_craphis2.cdhistor) LOOP
      OPEN cr_crapstn (rw_craplcm5.cdempres,
                       'E');
        fetch cr_crapstn into rw_crapstn;
      close cr_crapstn;

      -- Para DPVAT usar conta 4336
      IF rw_craplcm5.cdempres = '85' THEN
        vr_nrctasic := 4336;
      ELSE
        vr_nrctasic := 4332;
      END IF;
      --
      IF rw_crapstn.vltrfuni > 0 THEN
        -- Linhas para lançamentos que não sejam de Entes Públicos - início
        IF rw_craplcm5.qtlanmto > 0 THEN
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       vr_nrctasic||','||
                       '7268,'||
                       trim(to_char(rw_craplcm5.qtlanmto * rw_crapstn.vltrfuni, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_craplcm5.cdempres)|| ' - ' ||
                       TRIM(rw_craplcm5.dsnomcnv) ||
                       ' (tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          vr_linhadet := to_char(rw_craplcm5.cdagenci,'fm000')||','||trim(to_char(rw_craplcm5.qtlanmto * rw_crapstn.vltrfuni, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
        -- Linhas para lançamentos que não sejam de Entes Públicos - fim
        -- Linhas para lançamentos que sejam de Entes Públicos - início
        IF rw_craplcm5.qtlanmtoep > 0 THEN
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         vr_nrctasic||','||
                         '7294,'||
                         trim(to_char(rw_craplcm5.qtlanmtoep * rw_crapstn.vltrfuni, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                       ') '||trim(rw_craplcm5.cdempres)|| ' - ' ||
                         TRIM(rw_craplcm5.dsnomcnv) ||
                         ' EP (tarifa)"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_linhadet := to_char(rw_craplcm5.cdagenci,'fm000')||','||trim(to_char(rw_craplcm5.qtlanmtoep * rw_crapstn.vltrfuni, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;
        -- Linhas para lançamentos que sejam de Entes Públicos - fim
      end if;
    END LOOP;

    -- Despesa Sicredi (Debito Automatico)
    FOR rw_craplcm6 IN cr_craplcm6 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    rw_craphis2.cdhistor) LOOP

      open cr_crapthi2 (pr_cdcooper,
                        rw_craphis2.cdhistor);
          fetch cr_crapthi2 into rw_crapthi2;

      if cr_crapthi2%found then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctatrd))||','||
                       trim(to_char(rw_craphis2.nrctatrc))||','||
                       trim(to_char(rw_craplcm6.qtlanmto * rw_crapthi2.vltarifa, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                       ') CONTABILIZACAO DESPESA SICREDI"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        vr_linhadet := to_char(rw_craplcm6.cdagenci, 'fm000')||','||trim(to_char(rw_craplcm6.qtlanmto * rw_crapthi2.vltarifa, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        IF rw_craplcm6.qtlanmtoep > 0 THEN
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         '8509,'||
                         trim(to_char(rw_craphis2.nrctatrc))||','||
                         trim(to_char(rw_craplcm6.qtlanmtoep * rw_crapthi2.vltarifa, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') CONTABILIZACAO DESPESA SICREDI EP"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          vr_linhadet := to_char(rw_craplcm6.cdagenci, 'fm000')||','||trim(to_char(rw_craplcm6.qtlanmtoep * rw_crapthi2.vltarifa, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;
      end if;

      close cr_crapthi2;

    END LOOP;

  ---------INICIO LANÇAMENTOS INTRAFILIADAS

    --Diferente da central
    IF pr_cdcooper <> 3 THEN
      vr_cdestrut := '50';
      vr_linhadet := '';
      FOR lanc IN cr_lancamentos_intrafiliadas(pr_cdcooper, vr_dtmvtolt) LOOP
        IF lanc.cdhistor = 4145 THEN
          vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4775,'||
                       '1452,'||
                       trim(to_char(lanc.vllanmto, '99999999999990.00'))||','||
                       '5210,'||
                       '"DEBITO C/C '||lanc.nrdconta||' AILOS REF. TRANSFERENCIA INTRAFILIADAS CORE DIFER"';
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         ELSIF lanc.cdhistor = 4146 THEN
           vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1452,'||
                       '4775,'||
                       trim(to_char(lanc.vllanmto, '99999999999990.00'))||','||
                       '5210,'||
                       '"CREDITO C/C '||lanc.nrdconta||' AILOS REF. TRANSFERENCIA INTRAFILIADAS CORE DIFER"';
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         END IF;
      END LOOP;
    END IF;

  ---------FIM LANÇAMENTOS INTRAFIALIADAS

    --*************************--
    ----->>> INICIO Convenio BANCOOB <<<-----

    vr_cdestrut := '50';
    vr_cdhistor := 2515;

    -- Convênio Bancoob
    OPEN cr_craphis2 (pr_cdcooper, vr_cdhistor);
    FETCH cr_craphis2 INTO rw_craphis2;
    IF cr_craphis2%NOTFOUND THEN
      CLOSE cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '2515 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_craphis2;

    vr_tab_fat_bancoob.delete;
    vr_valores_age.delete;
    vr_tab_rej_bancoob.delete;

    -- Convênios Sicredi migrando para liquidação através de API do Bancoob.
    -- DARF, DAS e GPS com código de barras precisam entrar na conciliação contábil do Bancoob, seguindo mesmo modelo da arrecadação de água, luz e telefone através de arquivos.
    IF vr_plnctlpf = 'C'         AND
       vr_datctlpf <= vr_dtmvtolt THEN
      vr_cdempcon := 270; -- GPS
      vr_cdsegmto := 5;   -- GPS Tributo Federal

      -- PAGAMENTO GUIAS PREVIDENCIA .............................................
      -- Buscar valores de tarifa de GPS
      OPEN cr_conv_arrecad(pr_cdempcon => vr_cdempcon,   -- GPS
                           pr_cdsegmto => vr_cdsegmto);  -- Tributo Federal
      FETCH cr_conv_arrecad INTO rw_conv_arrecad;
      IF cr_conv_arrecad%NOTFOUND THEN
        CLOSE cr_conv_arrecad;
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de tarifa nao encontrado(tbconv_arrecadao). Cod. convenio 270: ' ||
                       ' | Cod. Segmento: 5 | Historico: ' || vr_cdhistor;
        -- Gera a mensagem de erro no log e não prossegue a rotina.
        cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
      ELSE
        CLOSE cr_conv_arrecad;

        vr_vllanmto_fat := 0;

        -- Lançamentos de GPS arrecadadas via API Bancoob
        FOR rw_craplgp_bancoob IN cr_craplgp_bancoob (pr_cdcooper => pr_cdcooper,
                                                      pr_dtmvtolt => vr_dtmvtolt) LOOP

          -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
          vr_vllanmto_fat := vr_vllanmto_fat + rw_craplgp_bancoob.vlrtotal;

          -- Incrementa o contador na pl/table de faturas
          vr_indice_faturas := LPAD(vr_cdempcon,5,0) || -- GPS
                               LPAD(vr_cdsegmto,5,0) || -- Tributo Federal
                               LPAD(rw_conv_arrecad.cdempres,10,0);

          vr_tab_fat_bancoob(vr_indice_faturas).cdempres := rw_conv_arrecad.cdempres;
          vr_tab_fat_bancoob(vr_indice_faturas).nmextcon := 'GPS CODIGO DE BARRAS';
          vr_tab_fat_bancoob(vr_indice_faturas).cdhistor := rw_craphis2.cdhistor;
          vr_tab_fat_bancoob(vr_indice_faturas).cdhstctb := rw_craphis2.cdhstctb;
          vr_tab_fat_bancoob(vr_indice_faturas).qtdtotal := NVL(vr_tab_fat_bancoob(vr_indice_faturas).qtdtotal, 0) + rw_craplgp_bancoob.qtlanmto + rw_craplgp_bancoob.qtlanmtoep;

          vr_idx_age := LPAD(rw_craplgp_bancoob.cdagenci_receita,5,'0');
          vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci   := rw_craplgp_bancoob.cdagenci_receita;
          vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto   := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto, 0)   + rw_craplgp_bancoob.qtlanmto;
          vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep, 0) + rw_craplgp_bancoob.qtlanmtoep;

          --> Obter valor da tarifa conforme o canal da arrecadação
          vr_vltarece := 0;
          IF rw_craplgp_bancoob.cdagenci = 90 THEN
            vr_vltarece := rw_conv_arrecad.vltarifa_internet;
          ELSIF rw_craplgp_bancoob.cdagenci = 91 THEN
            vr_vltarece := rw_conv_arrecad.vltarifa_taa;
          ELSE
            vr_vltarece := rw_conv_arrecad.vltarifa_caixa;
          END IF;

          --> Calcular total de tarifas de não Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
          vr_tab_fat_bancoob(vr_indice_faturas).vltottar := nvl(vr_tab_fat_bancoob(vr_indice_faturas).vltottar, 0) + (rw_craplgp_bancoob.qtlanmto * vr_vltarece);
          vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa, 0) + (rw_craplgp_bancoob.qtlanmto * vr_vltarece);

          --> Calcular total de tarifas de Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
          vr_tab_fat_bancoob(vr_indice_faturas).vltottarep := nvl(vr_tab_fat_bancoob(vr_indice_faturas).vltottarep, 0) + (rw_craplgp_bancoob.qtlanmtoep * vr_vltarece);
          vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep, 0) + (rw_craplgp_bancoob.qtlanmtoep * vr_vltarece);

          -- Verifica se é a mesma Agência, se for, busca o próximo registro
          IF rw_craplgp_bancoob.cdagenci = rw_craplgp_bancoob.proxima_agencia THEN
            CONTINUE;
          END IF;

          -- Antes de ir para proxima agencia, deve gerar linha no arquivo
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_tab_agencia2(rw_craplgp_bancoob.cdagenci).vr_cdcxaage,'fm0000'))||','||
                         trim(to_char(rw_craphis2.nrctacrd))||','||
                         trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') '||trim(rw_conv_arrecad.cdempres)||' - '||
                         'GPS CODIGO DE BARRAS"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craplgp_bancoob.cdagenci,'fm000')||','||
                         trim(to_char(vr_vllanmto_fat, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_vllanmto_fat := 0;

        END LOOP;
      END IF;
    END IF; -- Fim controle Arrecadação API Bancoob / TIVIT

    vr_vllanmto_fat := 0;

    -- Lançamento de faturas do convênio bancoob
    FOR rw_craplft IN cr_craplft_bancoob (pr_cdcooper => pr_cdcooper,
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_cdhistor => rw_craphis2.cdhistor) LOOP
      -- Buscar convenio
      OPEN cr_crapcon_bancoob(pr_cdcooper
                             ,rw_craplft.cdempcon
                             ,rw_craplft.cdsegmto);
      FETCH cr_crapcon_bancoob INTO rw_crapcon_bancoob;

      -- Se não encontrou convênio
      IF cr_crapcon_bancoob%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapcon_bancoob;
        CONTINUE;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapcon_bancoob;

      -- Buscar valores de tarifa
      OPEN cr_conv_arrecad(rw_craplft.cdempcon
                          ,rw_craplft.cdsegmto);
      FETCH cr_conv_arrecad INTO rw_conv_arrecad;

      -- Se não encontrou valor de tarifa
      IF cr_conv_arrecad%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_conv_arrecad;
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de tarifa nao encontrado(tbconv_arrecadacao). Cod. convenio : ' || rw_craplft.cdempcon
                    || ' | Cod. Segmento: ' || rw_craplft.cdsegmto || ' | Historico: ' || rw_craphis2.cdhistor;
        -- Gera a mensagem de erro no log e não prossegue a rotina.
        cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        -- Buscar próximo registro
        CONTINUE;
      END IF;
      -- Fechar cursor
      CLOSE cr_conv_arrecad;

      -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
      vr_vllanmto_fat := vr_vllanmto_fat + rw_craplft.vllanmto;

      -- Incrementa o contador na pl/table de faturas
      vr_indice_faturas := lpad(rw_craplft.cdempcon,5,0) ||
                           lpad(rw_craplft.cdsegmto,5,0) ||
                           lpad(rw_conv_arrecad.cdempres,10,0);

      vr_tab_fat_bancoob(vr_indice_faturas).cdempres := rw_conv_arrecad.cdempres;
      vr_tab_fat_bancoob(vr_indice_faturas).nmextcon := nvl(rw_crapcon_bancoob.nmextcon, 'CONVENIO NAO CADASTRADO (crapcon)');
      vr_tab_fat_bancoob(vr_indice_faturas).cdhistor := rw_craphis2.cdhistor;
      vr_tab_fat_bancoob(vr_indice_faturas).cdhstctb := rw_craphis2.cdhstctb;
      vr_tab_fat_bancoob(vr_indice_faturas).qtdtotal := nvl(vr_tab_fat_bancoob(vr_indice_faturas).qtdtotal, 0) + rw_craplft.qtlanmto + rw_craplft.qtlanmtoep;

      vr_idx_age := lpad(rw_craplft.cdagenci_fatura,5,'0');
      vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci   := rw_craplft.cdagenci_fatura;
      vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto   := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto, 0)   + rw_craplft.qtlanmto;
      vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep, 0) + rw_craplft.qtlanmtoep;

      --> Obter valor da tarifa conforme o canal da arrecadação
      vr_vltarece := 0;
      IF rw_craplft.cdagenci = 90 THEN
        vr_vltarece := rw_conv_arrecad.vltarifa_internet;
      ELSIF rw_craplft.cdagenci = 91 THEN
        vr_vltarece := rw_conv_arrecad.vltarifa_taa;
      ELSE
        vr_vltarece := rw_conv_arrecad.vltarifa_caixa;
      END IF;

      --> Calcular total de tarifas de não Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
      vr_tab_fat_bancoob(vr_indice_faturas).vltottar := nvl(vr_tab_fat_bancoob(vr_indice_faturas).vltottar, 0) + (rw_craplft.qtlanmto * vr_vltarece);
      vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa, 0) + (rw_craplft.qtlanmto * vr_vltarece);

      --> Calcular total de tarifas de Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
      vr_tab_fat_bancoob(vr_indice_faturas).vltottarep := nvl(vr_tab_fat_bancoob(vr_indice_faturas).vltottarep, 0) + (rw_craplft.qtlanmtoep * vr_vltarece);
      vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep := nvl(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep, 0) + (rw_craplft.qtlanmtoep * vr_vltarece);

      -- Verifica se é a mesma Agência/Convênio/Segmento, se for, busca o próximo registro
      IF rw_craplft.cdagenci = rw_craplft.proxima_agencia  AND
         rw_craplft.cdempcon = rw_craplft.proximo_cdempcon AND
         rw_craplft.cdsegmto = rw_craplft.proximo_cdsegmto THEN
        CONTINUE;
      END IF;

      -- Antes de ir para proxima agencia, deve gerar linha no arquivo
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplft.cdagenci).vr_cdcxaage,'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_conv_arrecad.cdempres)||' - '||
                     trim(nvl(rw_crapcon_bancoob.nmextcon, 'CONVENIO NAO CADASTRADO(crapcon)'))||'"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplft.cdagenci,'fm000')||','||
                     trim(to_char(vr_vllanmto_fat, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_vllanmto_fat := 0;

    END LOOP; --> Fim loop craplft

    -- Obter rejeições do pagamentos via Bancoob e subtrair a quantidade e valor do montante já calculado para os convênios e PAs
    FOR rw_rejeicoes_bancoob IN cr_rejeicoes_bancoob(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtmvtolt) LOOP

      -- Obter dados do convênio
      OPEN cr_conv_rej (rw_rejeicoes_bancoob.cdempres);
      FETCH cr_conv_rej INTO rw_conv_rej;

      IF cr_conv_rej%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Convenio rejeitado nao encontrado (tbconv_arrecadacao). Cod. Empresa Convenio : ' || rw_rejeicoes_bancoob.cdempres;
        -- Gera a mensagem de erro no log e não prossegue a rotina.
        cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        CLOSE cr_conv_rej;
      END IF;

      CLOSE cr_conv_rej;

      vr_indice_faturas := LPAD(rw_conv_rej.cdempcon,5,0) ||
                           LPAD(rw_conv_rej.cdsegmto,5,0) ||
                           LPAD(rw_conv_rej.cdempres,10,0);

      vr_idx_age := LPAD(rw_rejeicoes_bancoob.cdagenci_receita,5,'0');

      IF NOT vr_tab_fat_bancoob.EXISTS(vr_indice_faturas)                      OR
         NOT vr_tab_fat_bancoob(vr_indice_faturas).agencias.EXISTS(vr_idx_age) THEN
        CONTINUE;
      END IF;

      vr_vltarece := 0;
      IF rw_rejeicoes_bancoob.cdagenci = 90 THEN
        vr_vltarece := rw_conv_rej.vltarifa_internet;
      ELSIF rw_rejeicoes_bancoob.cdagenci = 91 THEN
        vr_vltarece := rw_conv_rej.vltarifa_taa;
      ELSE
        vr_vltarece := rw_conv_rej.vltarifa_caixa;
      END IF;

      IF rw_rejeicoes_bancoob.cdtipass = 1 THEN -- Associado Não Ente Público
        vr_tab_fat_bancoob(vr_indice_faturas).vltottar                      := NVL(vr_tab_fat_bancoob(vr_indice_faturas).vltottar, 0) - vr_vltarece;
        vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto, 0) - 1;
        vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa, 0) - vr_vltarece;
      ELSIF rw_rejeicoes_bancoob.cdtipass = 2 THEN -- Associado Ente Público ou Não Cooperado
        vr_tab_fat_bancoob(vr_indice_faturas).vltottarep                      := NVL(vr_tab_fat_bancoob(vr_indice_faturas).vltottarep, 0) - vr_vltarece;
        vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep, 0) - 1;
        vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep := NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep, 0) - vr_vltarece;
      END IF;

    END LOOP;
    -- Fim dedução rejeições

    -- Listar Valores de tarifa
    vr_cdestrut := '55';
    vr_indice_faturas := vr_tab_fat_bancoob.first;
    WHILE vr_indice_faturas IS NOT NULL LOOP

      --> gerar registro cabecalho para os Entes Públicos
      IF vr_tab_fat_bancoob(vr_indice_faturas).vltottarep > 0 THEN
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1764,' || /* conta débito */
                       '7630,' || /* conta crédito */
                       trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).vltottarep, '99999999999990.00'))||','||
                       trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).cdhstctb))||','||
                       '"('||trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).cdhistor,'0000'))||
                       ') '||trim(vr_tab_fat_bancoob(vr_indice_faturas).cdempres)||' - '||
                       trim(vr_tab_fat_bancoob(vr_indice_faturas).nmextcon)||' EP (tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;

      -- Detalhar por agência para os Entes Públicos
      vr_idx_age := vr_tab_fat_bancoob(vr_indice_faturas).agencias.first;
      WHILE vr_idx_age IS NOT NULL LOOP

        IF vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep > 0 THEN
          vr_linhadet := to_char(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci,'fm000')||','||
                         to_char(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifaep,'fm999999990.00');
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

        --> Agrupar valores por agencia
        vr_idx_age_2 := lpad(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci,5,'0');
        vr_valores_age(vr_idx_age_2).cdagenci   := vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci;
        vr_valores_age(vr_idx_age_2).qtlanmtoep := nvl(vr_valores_age(vr_idx_age_2).qtlanmtoep,0) + NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep,0);

        vr_idx_age := vr_tab_fat_bancoob(vr_indice_faturas).agencias.next(vr_idx_age);

      END LOOP;

      --> gerar registro cabecalho para não Entes Públicos
      IF vr_tab_fat_bancoob(vr_indice_faturas).vltottar > 0 THEN
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1764,' || /* conta débito */
                       '7613,' || /* conta crédito */
                       trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).vltottar, '99999999999990.00'))||','||
                       trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).cdhstctb))||','||
                       '"('||trim(to_char(vr_tab_fat_bancoob(vr_indice_faturas).cdhistor,'0000'))||
                       ') '||trim(vr_tab_fat_bancoob(vr_indice_faturas).cdempres)||' - '||
                       trim(vr_tab_fat_bancoob(vr_indice_faturas).nmextcon)||'(tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;

      -- Detalhar por agência para os Não Entes Públicos
      vr_idx_age := vr_tab_fat_bancoob(vr_indice_faturas).agencias.first;
      WHILE vr_idx_age IS NOT NULL LOOP

        IF vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa > 0 THEN
          vr_linhadet := to_char(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci,'fm000')||','||
                         to_char(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).vltarifa,'fm999999990.00');
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

        --> Agrupar valores por agencia
        vr_idx_age_2 := lpad(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci,5,'0');
        vr_valores_age(vr_idx_age_2).cdagenci := vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).cdagenci;
        vr_valores_age(vr_idx_age_2).qtlanmto := nvl(vr_valores_age(vr_idx_age_2).qtlanmto,0) + NVL(vr_tab_fat_bancoob(vr_indice_faturas).agencias(vr_idx_age).qtlanmto,0);

        vr_idx_age := vr_tab_fat_bancoob(vr_indice_faturas).agencias.next(vr_idx_age);

      END LOOP;

      vr_indice_faturas := vr_tab_fat_bancoob.next(vr_indice_faturas);

    END LOOP;

    vr_cdestrut := '55';
    IF vr_valores_age.count > 0 THEN
      vr_idx_age := vr_valores_age.first;
      WHILE vr_idx_age IS NOT NULL LOOP

        --> Gerar registro de despesa por PA para não Entes Públicos
        IF nvl(vr_valores_age(vr_idx_age).qtlanmto,0) > 0 THEN
          vr_vltardes := nvl(vr_valores_age(vr_idx_age).qtlanmto,0) * nvl(rw_crapcop.vltarbcb,0);

          IF nvl(vr_vltardes,0) > 0 THEN
            --> gerar registro cabecalho
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '8648,'||
                           '4989,'||
                           trim(to_char(vr_vltardes, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') CONTABILIZACAO DESPESA BANCOOB"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            -- Registro detalhe age
            vr_linhadet := to_char(vr_valores_age(vr_idx_age).cdagenci,'fm000')||','||
                           to_char(vr_vltardes,'fm999999990.00');
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;
        END IF;

        --> Gerar registro de despesa por PA para Entes Públicos
        IF nvl(vr_valores_age(vr_idx_age).qtlanmtoep,0) > 0 THEN
          vr_vltardes := nvl(vr_valores_age(vr_idx_age).qtlanmtoep,0) * nvl(rw_crapcop.vltarbcb,0);

          IF nvl(vr_vltardes,0) > 0 THEN
            --> gerar registro cabecalho
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '8641,'||
                           '4989,'||
                           trim(to_char(vr_vltardes, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') CONTABILIZACAO DESPESA BANCOOB EP"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            -- Registro detalhe age
            vr_linhadet := to_char(vr_valores_age(vr_idx_age).cdagenci,'fm000')||','||
                           to_char(vr_vltardes,'fm999999990.00');
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;
        END IF;

        vr_idx_age := vr_valores_age.next(vr_idx_age);
      END LOOP;
    END IF;

      --*************************--
    -- Convênio Bancoob (debito automatico)
    OPEN cr_craphis2 (pr_cdcooper, 3292);
    FETCH cr_craphis2 INTO rw_craphis2;
    IF cr_craphis2%NOTFOUND THEN
      CLOSE cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '3292 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_craphis2;
    --
    vr_nrctacrd := rw_craphis2.nrctacrd;
    vr_cdestrut := '50';

    -- Debito Automatico Bancoob
    FOR rw_craplcm10 IN cr_craplcm10 (pr_cdcooper,
                                      vr_dtmvtolt,
                                      rw_craphis2.cdhistor) LOOP

      OPEN cr_crapcon2(pr_cdcooper
                      ,rw_craplcm10.cdempres);
          FETCH cr_crapcon2 INTO rw_crapcon2;
      if cr_crapcon2%notfound then
        vr_nmextcon := 'Nao identificado crapcon';
      else
        vr_nmextcon := rw_crapcon2.nmextcon;
      end if;
      close cr_crapcon2;

      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_nrctacrd))||','||
                     trim(to_char(rw_craplcm10.vllanmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') CONVENIO BANCOOB DEBITO AUTOMATICO - '||
                     TRIM(vr_nmextcon) || '"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      vr_linhadet := '999,' || TRIM(to_char(rw_craplcm10.vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    END LOOP;

    vr_isFirst := TRUE;

    vr_qtlanmto := 0;
    vr_qtlanmtoep := 0;
    vr_cdempres := 0;

    -- Tarifa convênio Bancoob Debito Automatico
    FOR rw_craplcm11 IN cr_craplcm11(pr_cdcooper,
                                     vr_dtmvtolt,
                                     rw_craphis2.cdhistor) LOOP

      OPEN cr_crapcon2(pr_cdcooper
                      ,rw_craplcm11.cdempres);
          FETCH cr_crapcon2 INTO rw_crapcon2;
      if cr_crapcon2%notfound then
         vr_nmextcon := 'Nao identificado crapcon';
         vr_vltarifa_debaut := 0;
      else
         vr_nmextcon := rw_crapcon2.nmextcon;
         vr_vltarifa_debaut := rw_crapcon2.vltarifa_debaut;
      end if;
      close cr_crapcon2;

      OPEN cr_craplcm13 (pr_cdcooper,
                         vr_dtmvtolt,
                         rw_craphis2.cdhistor,
                         rw_craplcm11.cdempres);
           FETCH cr_craplcm13 INTO rw_craplcm13;
      if cr_craplcm13%notfound then
         vr_qtlanmto := 0;
         vr_qtlanmtoep := 0;
      else
         vr_qtlanmto := rw_craplcm13.qtlanmto;
         vr_qtlanmtoep := rw_craplcm13.qtlanmtoep;
      end if;
      close cr_craplcm13;

      --Solicitado via RITM012783, alteração de conta, de 4337 para 1764
      vr_nrctasic := 1764;

      IF  vr_cdempres <> rw_craplcm11.cdempres THEN
          vr_isFirst := TRUE;
      END IF;

      IF vr_qtlanmto > 0 THEN
         IF vr_isFirst THEN
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           vr_nrctasic||','||
                           '7613,'||
                           trim(to_char(vr_qtlanmto * vr_vltarifa_debaut, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') CONVENIO BANCOOB DEBITO AUTOMATICO - '||
                           TRIM(vr_nmextcon) ||
                           ' (tarifa)"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         end if;
         vr_linhadet := to_char(rw_craplcm11.cdagenci,'fm000')||','||trim(to_char(rw_craplcm11.qtlanmto * vr_vltarifa_debaut, '999999990.00'));
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        -- Linhas para lançamentos que sejam de Entes Públicos - início
        IF vr_qtlanmtoep > 0 THEN
           IF vr_isFirst THEN
              vr_linhadet := trim(vr_cdestrut)||
                             trim(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             vr_nrctasic||','||
                             '7630,'||
                             trim(to_char(vr_qtlanmtoep * vr_vltarifa_debaut, '99999999999990.00'))||','||
                             trim(to_char(rw_craphis2.cdhstctb))||','||
                             '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                             ') CONVENIO BANCOOB DEBITO AUTOMATICO EP - ' ||
                             TRIM(vr_nmextcon) ||
                             ' (tarifa)"';
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
           end if;
           vr_linhadet := to_char(rw_craplcm11.cdagenci,'fm000')||','||trim(to_char(rw_craplcm11.qtlanmtoep * vr_vltarifa_debaut, '999999990.00'));
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;
        -- Linhas para lançamentos que sejam de Entes Públicos - fim

        vr_cdempres := rw_craplcm11.cdempres;
        vr_isFirst := FALSE;
    END LOOP;


    vr_isFirst := TRUE;

    vr_qtlanmto := 0;
    vr_qtlanmtoep := 0;
    vr_cdempres := 0;

    OPEN cr_craplcm14 (pr_cdcooper,
                       vr_dtmvtolt,
                       rw_craphis2.cdhistor);
         FETCH cr_craplcm14 INTO rw_craplcm14;
    if cr_craplcm14%notfound then
       vr_qtlanmto := 0;
       vr_qtlanmtoep := 0;
    else
       vr_qtlanmto := rw_craplcm14.qtlanmto;
       vr_qtlanmtoep := rw_craplcm14.qtlanmtoep;
    end if;
    close cr_craplcm14;


    -- Despesa Bancoob (Debito Automatico)
    FOR rw_craplcm12 IN cr_craplcm12 (pr_cdcooper,
                                      vr_dtmvtolt,
                                      rw_craphis2.cdhistor) LOOP

      open cr_crapthi2 (pr_cdcooper,
                        rw_craphis2.cdhistor);
          fetch cr_crapthi2 into rw_crapthi2;
      if cr_crapthi2%notfound then
         vr_vltarifa_debaut := 0;
      else
         vr_vltarifa_debaut := rw_crapthi2.vltarifa;
      end if;
      close cr_crapthi2;

      IF vr_qtlanmto > 0 THEN
         IF vr_isFirst THEN
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           trim(to_char(rw_craphis2.nrctatrd))||','||
                           trim(to_char(rw_craphis2.nrctatrc))||','||
                           trim(to_char(vr_qtlanmto * vr_vltarifa_debaut, '99999999999990.00'))||','||
                           trim(to_char(rw_craphis2.cdhstctb))||','||
                           '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                           ') CONTABILIZACAO DESPESA BANCOOB - DEB. AUTOMATICO"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;
          vr_linhadet := to_char(rw_craplcm12.cdagenci, 'fm000')||','||trim(to_char(rw_craplcm12.qtlanmto * vr_vltarifa_debaut, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

        IF vr_qtlanmtoep > 0 THEN
           IF vr_isFirst THEN
              vr_linhadet := trim(vr_cdestrut)||
                             trim(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             '8641,'||
                             trim(to_char(rw_craphis2.nrctatrc))||','||
                             trim(to_char(vr_qtlanmtoep * vr_vltarifa_debaut, '99999999999990.00'))||','||
                             trim(to_char(rw_craphis2.cdhstctb))||','||
                             '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                             ') CONTABILIZACAO DESPESA BANCOOB EP - DEB. AUTOMATICO"';
              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            END IF;
            vr_linhadet := to_char(rw_craplcm12.cdagenci, 'fm000')||','||trim(to_char(rw_craplcm12.qtlanmtoep * vr_vltarifa_debaut, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

      vr_isFirst := FALSE;

    END LOOP;


    ----->>> FIM Convenio BANCOOB <<<-----



     ------->>> INICIO ARRECADACAO RECEITA FEDERAL <<<------

     vr_vllanmto_fat := 0;

     -- Lançamento de faturas do convênio rfb
     FOR rw_craplft_rfb IN cr_craplft_rfb (pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => vr_dtmvtolt) LOOP
       -- Buscar convenio
       OPEN cr_crapscn4(rw_craplft_rfb.cdempcon, rw_craplft_rfb.cdsegmto);
       FETCH cr_crapscn4 INTO rw_crapscn4;
       IF cr_crapscn4%NOTFOUND THEN
       -- Se não encontrou convênio
       -- Fechar cursor
           CLOSE cr_crapscn4;
           vr_cdcritic := 0;
           vr_dscritic := 'Convenio RFB nao encontrado(crapscn). Cod. convenio : ' || rw_craplft_rfb.cdempcon
                         || ' | Cod. Segmento: ' || rw_craplft_rfb.cdsegmto || ' | Historico: ' || rw_craplft_rfb.cdhistor;
           -- Gera a mensagem de erro no log e não prossegue a rotina.
           cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                     ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                     ,pr_nmarqlog      => 'proc_batch.log'
                                     ,pr_tpexecucao    => 1 -- Job
                                     ,pr_cdcriticidade => 1 -- Medio
                                     ,pr_cdmensagem    => vr_cdcritic
                                     ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '|| vr_dscritic);
           -- Buscar próximo registro
           CONTINUE;
       END IF;
       -- Fechar cursor
       CLOSE cr_crapscn4;

       OPEN  cr_craphis2(pr_cdcooper, rw_craplft_rfb.cdhistor);
       FETCH cr_craphis2 INTO rw_craphis2;
       CLOSE cr_craphis2;

       IF    rw_craplft_rfb.cdagenci = 90 THEN
             vr_dsorigem := 'INTERNET';
       ELSIF rw_craplft_rfb.cdagenci = 91 THEN
             vr_dsorigem := 'TAA';
       ELSE
             vr_dsorigem := 'CAIXA';
       END IF;

       OPEN  cr_crapthi (pr_cdcooper, rw_craphis2.cdhistor, vr_dsorigem);
       FETCH cr_crapthi INTO rw_crapthi;

       IF cr_crapthi%NOTFOUND THEN
          CLOSE cr_crapthi;
          vr_cdcritic := 1041;
          vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||rw_craphis.cdhistor||' - crapthi';
          -- Gera a mensagem de erro no log e não prossegue a rotina.
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de Negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        ||vr_cdprogra||' --> '||vr_dscritic);
           -- Buscar próximo registro
           CONTINUE;
       END IF;
       CLOSE cr_crapthi;

       -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
       vr_vllanmto_fat := vr_vllanmto_fat + nvl(rw_craplft_rfb.vllanmto,0) + nvl(rw_craplft_rfb.vllanmtoep,0);

       -- Incrementa o contador na pl/table de faturas
       vr_indice_faturas := LPAD(rw_craplft_rfb.cdempcon,5,0) ||
                            LPAD(rw_craplft_rfb.cdhistor,4,0);

       vr_indice_faturas_2 := LPAD(rw_craplft_rfb.cdempcon,5,0);

       vr_tab_trb_rfb(vr_indice_faturas).cdempres := rw_crapscn4.cdempres;
       vr_tab_trb_rfb(vr_indice_faturas).nmextcon := nvl(rw_crapscn4.dsnomres, 'CONVENIO NAO CADASTRADO (crapscn)');
       vr_tab_trb_rfb(vr_indice_faturas).cdhistor := rw_craplft_rfb.cdhistor;
       vr_tab_trb_rfb(vr_indice_faturas).cdhstctb := rw_craphis2.cdhstctb;
       vr_tab_trb_rfb(vr_indice_faturas).qtdtotal := nvl(vr_tab_trb_rfb(vr_indice_faturas).qtdtotal, 0) + rw_craplft_rfb.qtlanmto + rw_craplft_rfb.qtlanmtoep;
       vr_tab_trb_rfb(vr_indice_faturas).vltottrb := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottrb, 0) + rw_craplft_rfb.vllanmto;
       vr_tab_trb_rfb(vr_indice_faturas).vltottrbep := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottrbep, 0) + rw_craplft_rfb.vllanmtoep2;

       vr_tot_trb_rfb(vr_indice_faturas_2).cdempres := rw_crapscn4.cdempres;
       vr_tot_trb_rfb(vr_indice_faturas_2).nmextcon := nvl(rw_crapscn4.dsnomres, 'CONVENIO NAO CADASTRADO (crapscn)');
       vr_tot_trb_rfb(vr_indice_faturas_2).cdhistor := rw_craplft_rfb.cdhistor;
       vr_tot_trb_rfb(vr_indice_faturas_2).cdhstctb := rw_craphis2.cdhstctb;
       vr_tot_trb_rfb(vr_indice_faturas_2).qtdtotal := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).qtdtotal, 0) + rw_craplft_rfb.qtlanmto + rw_craplft_rfb.qtlanmtoep;
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottrb := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottrb, 0) + rw_craplft_rfb.vllanmto;
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottrbep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottrbep, 0) + rw_craplft_rfb.vllanmtoep2;

       vr_idx_age := lpad(rw_craplft_rfb.cdagenci_fatura,5,'0');
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).cdagenci   := rw_craplft_rfb.cdagenci_fatura;
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllamnto   := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllamnto, 0) + rw_craplft_rfb.vllanmto;
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllamntoep   := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllamntoep, 0) + rw_craplft_rfb.vllanmtoep;

       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).qtlanmto   := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).qtlanmto, 0) + rw_craplft_rfb.qtlanmto;
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).qtlanmtoep, 0) + rw_craplft_rfb.qtlanmtoep;

       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).cdagenci   := rw_craplft_rfb.cdagenci_fatura;
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllamnto   := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllamnto, 0) + rw_craplft_rfb.vllanmto;
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllamntoep   := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllamntoep, 0) + rw_craplft_rfb.vllanmtoep;

       --> Calcular total de tarifas de não Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
       vr_tab_trb_rfb(vr_indice_faturas).vltottar := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottar, 0) + (rw_craplft_rfb.qtlanmto * rw_crapthi.vltarifa);
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa, 0) + (rw_craplft_rfb.qtlanmto * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottar := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottar, 0) + (rw_craplft_rfb.qtlanmto * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifa := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifa, 0) + (rw_craplft_rfb.qtlanmto * rw_crapthi.vltarifa);

       --> Calcular total de tarifas de Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
       vr_tab_trb_rfb(vr_indice_faturas).vltottarep := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottarep, 0) + (rw_craplft_rfb.qtlanmtoep2 * rw_crapthi.vltarifa);
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep, 0) + (rw_craplft_rfb.qtlanmtoep2 * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottarep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottarep, 0) + (rw_craplft_rfb.qtlanmtoep2 * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifaep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifaep, 0) + (rw_craplft_rfb.qtlanmtoep2 * rw_crapthi.vltarifa);

       -- Verifica se é a mesma Agência/Convênio/Segmento, se for, busca o próximo registro
       IF rw_craplft_rfb.cdhistor = rw_craplft_rfb.proxima_historico AND
          rw_craplft_rfb.cdagenci = rw_craplft_rfb.proxima_agencia   AND
          rw_craplft_rfb.cdempcon = rw_craplft_rfb.proximo_cdempcon  THEN
          CONTINUE;
       END IF;

       -- Antes de ir para proxima agencia, deve gerar linha no arquivo
       vr_linhadet := trim(vr_cdestrut)||
                      trim(vr_dtmvtolt_yymmdd)||','||
                      trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                      trim(to_char(vr_tab_agencia2(rw_craplft_rfb.cdagenci).vr_cdcxaage,'fm0000'))||','||
                      trim(to_char(rw_craphis2.nrctacrd))||','||
                      trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                      trim(to_char(rw_craphis2.cdhstctb))||','||
                      '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                      ') '||trim(rw_crapscn4.cdempres)||' - '||
                      trim(nvl(rw_crapscn4.dsnomres, 'CONVENIO NAO CADASTRADO(crapsn)'))||'"';

       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

       vr_linhadet := to_char(rw_craplft_rfb.cdagenci,'fm000')||','||
                      to_char(vr_vllanmto_fat,'fm999999990.00');

       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);


       vr_vllanmto_fat := 0;

     END LOOP; --> Fim controle Arrecadação RFB


     FOR rw_rejeitado_rfb IN cr_rejeitado_rfb (pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => vr_dtmvtolt) LOOP
       -- Buscar convenio
       OPEN cr_crapscn4(rw_rejeitado_rfb.cdempcon, rw_rejeitado_rfb.cdsegmto);
       FETCH cr_crapscn4 INTO rw_crapscn4;
       IF cr_crapscn4%NOTFOUND THEN
           -- Se não encontrou convênio
           -- Fechar cursor
           CLOSE cr_crapscn4;
           vr_cdcritic := 0;
           vr_dscritic := 'Convenio RFB nao encontrado(crapscn). Cod. convenio : ' || rw_rejeitado_rfb.cdempcon
                         || ' | Cod. Segmento: ' || rw_rejeitado_rfb.cdsegmto || ' | Historico: 3466';
           -- Gera a mensagem de erro no log e não prossegue a rotina.
           cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                     ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                     ,pr_nmarqlog      => 'proc_batch.log'
                                     ,pr_tpexecucao    => 1 -- Job
                                     ,pr_cdcriticidade => 1 -- Medio
                                     ,pr_cdmensagem    => vr_cdcritic
                                     ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '|| vr_dscritic);
           -- Buscar próximo registro
           CONTINUE;
       END IF;
       -- Fechar cursor
       CLOSE cr_crapscn4;

       OPEN  cr_craphis2(pr_cdcooper, rw_rejeitado_rfb.cdhistor);
       FETCH cr_craphis2 INTO rw_craphis2;
       CLOSE cr_craphis2;

       IF    rw_rejeitado_rfb.cdagenci = 90 THEN
             vr_dsorigem := 'INTERNET';
       ELSIF rw_rejeitado_rfb.cdagenci = 91 THEN
             vr_dsorigem := 'TAA';
       ELSE
             vr_dsorigem := 'CAIXA';
       END IF;

       OPEN  cr_crapthi (pr_cdcooper, rw_craphis2.cdhistor, vr_dsorigem);
       FETCH cr_crapthi INTO rw_crapthi;

       IF cr_crapthi%NOTFOUND THEN
          CLOSE cr_crapthi;
          vr_cdcritic := 1041;
          vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||rw_craphis.cdhistor||' - crapthi';
          -- Gera a mensagem de erro no log e não prossegue a rotina.
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de Negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        ||vr_cdprogra||' --> '||vr_dscritic);
           -- Buscar próximo registro
           CONTINUE;
       END IF;
       CLOSE cr_crapthi;

       -- Incrementa o contador na pl/table de faturas
       vr_indice_faturas := LPAD(rw_rejeitado_rfb.cdempcon,5,0) ||
                            LPAD(rw_rejeitado_rfb.cdhistor,4,0);

       vr_indice_faturas_2 := LPAD(rw_rejeitado_rfb.cdempcon,5,0);

       vr_idx_age := lpad(rw_rejeitado_rfb.cdagenci_fatura,5,'0');

       vr_qtlanrej := nvl(rw_rejeitado_rfb.qtlanmto,0);
       vr_qtlanrejep := nvl(rw_rejeitado_rfb.qtlanmtoep,0);
       vr_vllanrej := nvl(rw_rejeitado_rfb.vllanmto,0);
       vr_vllanrejep := nvl(rw_rejeitado_rfb.vllanmtoep,0);

       vr_tab_trb_rfb(vr_indice_faturas).vltotrej := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltotrej,0) + vr_vllanrej;
       vr_tab_trb_rfb(vr_indice_faturas).vltotrejep := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltotrejep,0) + vr_vllanrejep;
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllanrej   := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllanrej,0) + vr_vllanrej;
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllanrejep   := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vllanrejep,0) + vr_vllanrejep;

       vr_tot_trb_rfb(vr_indice_faturas_2).vltotrej := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltotrej, 0) + vr_vllanrej;
       vr_tot_trb_rfb(vr_indice_faturas_2).vltotrejep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltotrejep, 0) + vr_vllanrejep;
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllanrej   := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllanrej, 0) + vr_vllanrej;
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllanrejep   := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vllanrejep, 0) + vr_vllanrejep;

       --> Calcular total de tarifas de não Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
       vr_tab_trb_rfb(vr_indice_faturas).vltottar := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottar, 0) - (vr_qtlanrej * rw_crapthi.vltarifa);
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa, 0) - (vr_qtlanrej * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottar := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottar, 0) - (vr_qtlanrej * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifa := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifa, 0) - (vr_qtlanrej * rw_crapthi.vltarifa);

       --> Calcular total de tarifas de Entes Públicos por cada canal, e será agrupado o valor pelo PA do cooperado ou PA do caixa
       vr_tab_trb_rfb(vr_indice_faturas).vltottarep := nvl(vr_tab_trb_rfb(vr_indice_faturas).vltottarep, 0) - (vr_qtlanrejep * rw_crapthi.vltarifa);
       vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep := nvl(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep, 0) - (vr_qtlanrejep * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).vltottarep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).vltottarep, 0) - (vr_qtlanrejep * rw_crapthi.vltarifa);
       vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifaep := nvl(vr_tot_trb_rfb(vr_indice_faturas_2).agencias(vr_idx_age).vltarifaep, 0) - (vr_qtlanrejep * rw_crapthi.vltarifa);


     END LOOP; --> Fim controle Arrecadação RFB


     --  TARIFA RFB --
     -- Listar Valores de tarifa
     vr_cdestrut := '55';
     vr_indice_faturas := vr_tab_trb_rfb.first;
     WHILE vr_indice_faturas IS NOT NULL LOOP

       --> gerar registro cabecalho para os Entes Públicos
       IF vr_tab_trb_rfb(vr_indice_faturas).vltottarep > 0 THEN
         vr_linhadet := trim(vr_cdestrut)||
                        trim(vr_dtmvtolt_yymmdd)||','||
                        trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '4790,' || /* conta débito */
                        '7380,' || /* conta crédito */
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).vltottarep, '99999999999990.00'))||','||
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).cdhstctb))||','||
                        '"('||
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).cdhistor,'0000'))||
                        ') '||trim(vr_tab_trb_rfb(vr_indice_faturas).cdempres)||' - '||
                        trim(vr_tab_trb_rfb(vr_indice_faturas).nmextcon)||' EP (tarifa)"';
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       END IF;

       -- Detalhar por agência para os Entes Públicos
       vr_idx_age := vr_tab_trb_rfb(vr_indice_faturas).agencias.first;
       WHILE vr_idx_age IS NOT NULL LOOP

         IF vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep > 0 THEN
           vr_linhadet := to_char(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).cdagenci,'fm000')||','||
                          to_char(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifaep,'fm999999990.00');
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         END IF;

         vr_idx_age := vr_tab_trb_rfb(vr_indice_faturas).agencias.next(vr_idx_age);
       END LOOP;

       --> gerar registro cabecalho para não Entes Públicos
       IF vr_tab_trb_rfb(vr_indice_faturas).vltottar > 0 THEN
         vr_linhadet := trim(vr_cdestrut)||
                        trim(vr_dtmvtolt_yymmdd)||','||
                        trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '4790,' || /* conta débito */
                        '7370,' || /* conta crédito */
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).vltottar, '99999999999990.00'))||','||
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).cdhstctb))||','||
                        '"('||
                        trim(to_char(vr_tab_trb_rfb(vr_indice_faturas).cdhistor,'0000'))||
                        ') '||trim(vr_tab_trb_rfb(vr_indice_faturas).cdempres)||' - '||
                        trim(vr_tab_trb_rfb(vr_indice_faturas).nmextcon)||'(tarifa)"';
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       END IF;

       -- Detalhar por agência para os Não Entes Públicos
       vr_idx_age := vr_tab_trb_rfb(vr_indice_faturas).agencias.first;
       WHILE vr_idx_age IS NOT NULL LOOP

         IF vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa > 0 THEN
           vr_linhadet := to_char(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).cdagenci,'fm000')||','||
                          to_char(vr_tab_trb_rfb(vr_indice_faturas).agencias(vr_idx_age).vltarifa,'fm999999990.00');
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         END IF;

         vr_idx_age := vr_tab_trb_rfb(vr_indice_faturas).agencias.next(vr_idx_age);

       END LOOP;

       vr_indice_faturas := vr_tab_trb_rfb.next(vr_indice_faturas);

     END LOOP;


     --  TOTAIS RFB --

     -- Listar Valores de tarifa
     vr_cdestrut := '55';
     OPEN  cr_craphis2(pr_cdcooper, 3464);
     FETCH cr_craphis2 INTO rw_craphis2;
     CLOSE cr_craphis2;


     vr_indice_faturas := vr_tot_trb_rfb.first;
     WHILE vr_indice_faturas IS NOT NULL LOOP

       --> gerar registro cabecalho para os Entes Públicos
       IF vr_tot_trb_rfb(vr_indice_faturas).vltottrbep -
          (nvl(vr_tot_trb_rfb(vr_indice_faturas).vltotrejep,0) +
           nvl(vr_tot_trb_rfb(vr_indice_faturas).vltottarep,0)) > 0 THEN
         vr_linhadet := trim(vr_cdestrut)||
                        trim(vr_dtmvtolt_yymmdd)||','||
                        trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '4790,' || /* conta débito */
                        '1452,' || /* conta credito */
                        trim(to_char(vr_tot_trb_rfb(vr_indice_faturas).vltottrbep -  (nvl(vr_tot_trb_rfb(vr_indice_faturas).vltotrejep,0) + nvl(vr_tot_trb_rfb(vr_indice_faturas).vltottarep,0)), '99999999999990.00'))||','||
                        trim(to_char(vr_tot_trb_rfb(vr_indice_faturas).cdhstctb))||','||
                        '"(crps249) ARRECADACAO CONVENIO '||trim(vr_tot_trb_rfb(vr_indice_faturas).cdempres)||' - '||
                        trim(vr_tot_trb_rfb(vr_indice_faturas).nmextcon)||' EP"';
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       END IF;


       --> gerar registro cabecalho para os Não Entes Públicos
       IF vr_tot_trb_rfb(vr_indice_faturas).vltottrb -
          (nvl(vr_tot_trb_rfb(vr_indice_faturas).vltotrej,0) +
           nvl(vr_tot_trb_rfb(vr_indice_faturas).vltottar,0)) > 0 THEN
         vr_linhadet := trim(vr_cdestrut)||
                        trim(vr_dtmvtolt_yymmdd)||','||
                        trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '4790,' || /* conta débito */
                        '1452,' || /* conta crédito */
                        trim(to_char(vr_tot_trb_rfb(vr_indice_faturas).vltottrb - (nvl(vr_tot_trb_rfb(vr_indice_faturas).vltotrej,0) + nvl(vr_tot_trb_rfb(vr_indice_faturas).vltottar,0)), '99999999999990.00'))||','||
                        trim(to_char(vr_tot_trb_rfb(vr_indice_faturas).cdhstctb))||','||
                        '"(crps249) ARRECADACAO CONVENIO '||trim(vr_tot_trb_rfb(vr_indice_faturas).cdempres)||' - '||
                        trim(vr_tot_trb_rfb(vr_indice_faturas).nmextcon)||'"';
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       END IF;

       vr_indice_faturas := vr_tot_trb_rfb.next(vr_indice_faturas);

     END LOOP;


     --  TARIFA REPASSE RFB --
     IF pr_cdcooper = 3 THEN

        vr_vllanmto_tar := 0;

        -- Lançamento de faturas do convênio rfb
        FOR rw_tarifa_central IN cr_tarifa_central (pr_dtmvtolt => vr_dtmvtolt) LOOP

            -- Buscar convenio
            OPEN cr_crapscn4(rw_tarifa_central.cdempcon, rw_tarifa_central.cdsegmto);
            FETCH cr_crapscn4 INTO rw_crapscn4;
            IF cr_crapscn4%NOTFOUND THEN
            -- Se não encontrou convênio
            -- Fechar cursor
                CLOSE cr_crapscn4;
                vr_cdcritic := 0;
                vr_dscritic := 'Convenio RFB nao encontrado(crapscn). Cod. convenio : ' || rw_tarifa_central.cdempcon
                              || ' | Cod. Segmento: ' || rw_tarifa_central.cdsegmto || ' | Historico: ' || rw_tarifa_central.cdhistor;
                -- Gera a mensagem de erro no log e não prossegue a rotina.
                cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                          ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                          ,pr_nmarqlog      => 'proc_batch.log'
                                          ,pr_tpexecucao    => 1 -- Job
                                          ,pr_cdcriticidade => 1 -- Medio
                                          ,pr_cdmensagem    => vr_cdcritic
                                          ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '|| vr_dscritic);
                -- Buscar próximo registro
                CONTINUE;
            END IF;
            -- Fechar cursor
            CLOSE cr_crapscn4;

            -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
            vr_vllanmto_tar := vr_vllanmto_tar + nvl(rw_tarifa_central.vltarifa,0);

             -- Verifica se é a mesma Agência/Convênio/Segmento, se for, busca o próximo registro
            IF rw_tarifa_central.cdempcon = rw_tarifa_central.proximo_cdempcon AND
               rw_tarifa_central.cdsegmto = rw_tarifa_central.proximo_cdsegmto THEN
               CONTINUE;
            END IF;

            IF vr_vllanmto_tar > 0 THEN

               vr_cdestrut := 50;
               vr_linhadet := trim(vr_cdestrut)||
                              trim(vr_dtmvtolt_yymmdd)||','||
                              trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                              '1889,' || /* conta débito */
                              '4790,' || /* conta crédito */
                              trim(to_char(nvl(vr_vllanmto_tar,0), '99999999999990.00'))||','||
                              '5210,' ||
                              '"TARIFA REPASSE CONVENIO '||trim(rw_crapscn4.dsnomres)||' COOP. FILIADAS - A RECEBER"';

               cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            END IF;

            vr_vllanmto_tar := 0;

        END LOOP;
     END IF;

    ------->>> TERMINO ARRECADACAO RECEITA FEDERAL <<<------



    ------->>> INICIO ARRECADACAO CONSORCIOS <<<------
    -- Comeca valer apos 25/09/2020
    IF vr_dtmvtolt > to_date('25/09/2020','dd/mm/rrrr') THEN
      vr_cdestrut:=50;
      FOR rw_craplcm_cns IN cr_craplcm_cns (pr_cdcooper => pr_cdcooper,
                                            pr_dtmvtolt => vr_dtmvtolt) LOOP
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       rw_craplcm_cns.nrctatrd||','||
                       '1452,'||
                       trim(to_char(rw_craplcm_cns.vllanmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craplcm_cns.cdhstctb))||','||
                       rw_craplcm_cns.dshistor;
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END LOOP;
    END IF;
    ----->>> FIM ARRECADACAO CONSORCIOS <<<------

    ----->>> INICIO SEGURO PRESTAMISTA <<<-------

      vr_flgseguro_prest:=0;

      -- Linha cabecalho
      FOR rw_craplcm_prst_1 IN cr_craplcm_prst_1 (pr_cdcooper => pr_cdcooper,
                                                  pr_dtmvtolt => vr_dtmvtolt) LOOP

         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm_prst_1.linha_titulo);

         vr_vlrtotal_estorno_prestamista:= rw_craplcm_prst_1.vllanmto;

         vr_flgseguro_prest:= 1;

         OPEN cr_craphis2(pr_cdcooper => pr_cdcooper,
                          pr_cdhistor => rw_craplcm_prst_1.cdhistor);
         FETCH cr_craphis2 INTO rw_craphis2;
         CLOSE cr_craphis2;
      END LOOP;

       -- Linha agencia
      FOR rw_craplcm_prst_2 IN cr_craplcm_prst_2 (pr_cdcooper => pr_cdcooper,
                                                  pr_dtmvtolt => vr_dtmvtolt) LOOP
        IF rw_craphis2.ingerdeb = 3 THEN -- Se Gerencial a Débito = 3-PA, imprime quebra por PA
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm_prst_2.linha_pa);
        END IF;
        vr_flgseguro_prest:= 1;
      END LOOP;


      IF vr_flgseguro_prest = 1 THEN
        IF rw_craphis2.ingercre = 2 THEN -- Se Gerencial a Crédito = 2-Geral, imprime 999 com totalizador
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, '999,'|| trim(to_char(vr_vlrtotal_estorno_prestamista, '99999999999990.00')));
        END IF;
      END IF;


      FOR rw_inadimplentes IN cr_inadimplentes(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => vr_dtmvtopr) LOOP
        --imprime cabeçalho
        IF NVL(rw_inadimplentes.total,0) > 0 THEN
           cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_inadimplentes.linha_titulo);
        END IF;

        FOR rw_inadimplentes_pa IN cr_inadimplentes_pa(pr_cdcooper => pr_cdcooper,
                                                       pr_dtmvtolt => vr_dtmvtopr) LOOP
          --imprime rateio por PA
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_inadimplentes_pa.linha_pa);

        END LOOP;

      END LOOP;

      --- Entrar somente na cooperativa 3 (historicos: 3044, 3045, 3046)
        IF pr_cdcooper = 3 THEN
          FOR rw_craplcm_cnv085 IN cr_craplcm_cnv085 (pr_dtmvtolt => vr_dtmvtolt) LOOP
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm_cnv085.linha);
          END LOOP;
        END IF;
      --- Fim da cooperativa 3 (historicos: 3044, 3045, 3046)

      -- Inicio historico 3049 credito do repasse do convenio na cooperativa
        FOR rw_craplcm_repasse_cnv085 IN cr_craplcm_repasse_cnv085 ( pr_cdcooper => pr_cdcooper
                                                                    ,pr_dtmvtolt => vr_dtmvtolt) LOOP
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm_repasse_cnv085.linha);
          -- Gerencial
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, '999,'||trim(to_char(rw_craplcm_repasse_cnv085.vllanmto, '99999999999990.00')));
        END LOOP;
      -- Fim historico 3049

    --Gravacao dos lancamentos contabeis SEP                       -- (P513 - Saque e Pague)
    IF pr_cdcooper <> 3 THEN

      --Lancamentos do dia, ate 21:45h - historicos: 2936,2937,2938
      FOR rw_craplcm_sep1 in cr_craplcm_sep1 (pr_cdcooper => pr_cdcooper ,
                                              pr_dtmvtolt => vr_dtmvtolt) LOOP
        vr_vllanmto := rw_craplcm_sep1.vllanmto;
        vr_cdestrut := '50';
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craplcm_sep1.nrctadeb))||','||
                       trim(to_char(rw_craplcm_sep1.nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '999999990.00'))||','||
                       trim(to_char(rw_craplcm_sep1.cdhstctb))||','||
                       '"(' || trim(to_char(rw_craplcm_sep1.cdhistor,'0000')) ||') '||
                       trim(rw_craplcm_sep1.dsexthst)||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_vllanmto, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END LOOP;

      --Lancamentos do dia, apos 21:45h - historicos: 2967,2968,2969
      FOR rw_craplcm_sep2 in cr_craplcm_sep2 (pr_cdcooper => pr_cdcooper ,
                                              pr_dtmvtolt => vr_dtmvtolt) LOOP
        vr_vllanmto := rw_craplcm_sep2.vllanmto;
        vr_cdestrut := '50';
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craplcm_sep2.nrctadeb))||','||
                       trim(to_char(rw_craplcm_sep2.nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '999999990.00'))||','||
                       trim(to_char(rw_craplcm_sep2.cdhstctb))||','||
                       '"(' || trim(to_char(rw_craplcm_sep2.cdhistor,'0000')) ||') '||
                       trim(rw_craplcm_sep2.dsexthst)||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_vllanmto, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END LOOP;

      -- Lancamentos do dia anterior, apos 21:45h - historicos: 2967,2968,2969
      -- A pesquisa dos lancamentos eh feito com dtmvtoan, mas no arquivo devemos enviar como dtmvtolt
      FOR rw_craplcm_sep3 in cr_craplcm_sep3 (pr_cdcooper => pr_cdcooper ,
                                              pr_dtmvtoan => vr_dtmvtoan) LOOP
        vr_vllanmto := rw_craplcm_sep3.vllanmto;
        vr_cdestrut := '50';
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(to_char(vr_dtmvtolt,'YYMMDD'))||','||
                       trim(to_char(vr_dtmvtolt,'DDMMYY'))||','||
                       trim(to_char(rw_craplcm_sep3.nrctadeb))||','||
                       trim(to_char(rw_craplcm_sep3.nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '999999990.00'))||','||
                       trim(to_char(rw_craplcm_sep3.cdhstctb))||','||
                       '"' || trim(rw_craplcm_sep3.dsexthst)||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END LOOP;

      -- Lançamentos SEP da cooperativa na central - historicos: 2939,2940,2941               --(P513 - Saque e Pague)
      FOR rw_craphis3 IN cr_craphis3  LOOP
        FOR rw_craplcm_sep5 IN cr_craplcm_sep5(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtolt
                                              ,pr_cdhistor => rw_craphis3.cdhistor)  LOOP
          vr_cdestrut := '50';
          vr_vllanmto := rw_craplcm_sep5.vllanmto;

          IF  rw_craplcm_sep5.cdhistor = 2939 THEN
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '4957'||','||
                           '1452'||','||
                           trim(to_char(vr_vllanmto, '999999990.00'))||','||
                           '5210'||','||
                           '"(crps249) '|| trim(rw_craplcm_sep5.dsexthst)||' ('||trim(to_char(rw_craplcm_sep5.cdhistor,'0000'))||')"';

          ELSE    --(cdhistor = 2940,2941)
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '1452'||','||
                           '4957'||','||
                           trim(to_char(vr_vllanmto, '999999990.00'))||','||
                           '5210'||','||
                           '"(crps249) '|| trim(rw_craplcm_sep5.dsexthst)||' ('||trim(to_char(rw_craplcm_sep5.cdhistor,'0000'))||')"';
          END IF;
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        END LOOP;
    END LOOP;
    ELSE  --(pr_cdcooper = 3)
      --lancamentos SEP das cooperativas na central - historicos: 2939,2940,2941
      FOR rw_craplcm_sep4 in cr_craplcm_sep4 (pr_dtmvtolt => vr_dtmvtolt) LOOP
        vr_vllanmto := rw_craplcm_sep4.vllanmto;
        vr_cdestrut := '50';
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craplcm_sep4.nrctadeb))||','||
                       trim(to_char(rw_craplcm_sep4.nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '999999990.00'))||','||
                       trim(to_char(rw_craplcm_sep4.cdhstctb))||','||
                       '"('||trim(to_char(rw_craplcm_sep4.cdhistor,'0000'))||') '||
                       trim(rw_craplcm_sep4.dsexthst)||'"';

        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END LOOP;

    END IF;
    -- (Fim P513 - Saque e Pague)

    -- Inicio PIX
    IF pr_cdcooper = 3 THEN
      vr_cdestrut := '50';
      vr_cdhstctb := '5210';

      -- Lancamentos PIX a repassar em DU+1
      -- pr_repasse - Indica se deve buscar os repasses - 0 = Não / 1 = Sim
      FOR rw_craplcm_pix IN cr_craplcm_pix(pr_repasse => 0,
                                           pr_dtmvtolt => vr_dtmvtolt) LOOP
        --
        vr_vllanmto := rw_craplcm_pix.vllanmto;
        vr_complinhadet := rw_craplcm_pix.detalhe;
        vr_nrctadeb := 1459;
        vr_nrctacrd := 4299;
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_nrctadeb))||','||
                       trim(to_char(vr_nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '99999999999990.00'))||','||
                       trim(vr_cdhstctb)||','||
                       trim(vr_complinhadet);
        --
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
      END LOOP;

      -- Lancamentos PIX repasse ref data anterior
      -- pr_repasse - Indica se deve buscar os repasses - 0 = Não / 1 = Sim
      FOR rw_craplcm_pix IN cr_craplcm_pix(pr_repasse => 1,
                                           pr_dtmvtolt => vr_dtmvtoan) LOOP
        --
        vr_vllanmto := rw_craplcm_pix.vllanmto;
        vr_complinhadet := rw_craplcm_pix.detalhe;
        vr_nrctadeb := 4299;
        vr_nrctacrd := 1459;
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_nrctadeb))||','||
                       trim(to_char(vr_nrctacrd))||','||
                       trim(to_char(vr_vllanmto, '99999999999990.00'))||','||
                       trim(vr_cdhstctb)||','||
                       trim(vr_complinhadet);
        --
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
      END LOOP;
    END IF;
    -- Fim PIX

    vr_cdestrut := '51';
    -- Subscricao de capital para novos socios .................................
    vr_vlcapsub := 0;
    for rw_crapsdc in cr_crapsdc_LT (pr_cdcooper,
                                  vr_dtmvtolt) loop
      vr_vlcapsub := vr_vlcapsub + rw_crapsdc.vllanmto;
    end loop;
    --
    if vr_vlcapsub > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '6122,'||
                     '6112,'||
                     trim(to_char(vr_vlcapsub, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUBSCRICAO INICIAL."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcapsub, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Reversao da subscricao de capital para socios demitidos/cancelamentos
    vr_vlcapsub := 0;
    for rw_crapsdc in cr_crapsdc (pr_cdcooper,
                                  vr_dtmvtolt,
                                  2) loop
      vr_vlcapsub := vr_vlcapsub + rw_crapsdc.vllanmto;
    end loop;
    --
    if vr_vlcapsub > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '6112,'||
                     '6122,'||
                     trim(to_char(vr_vlcapsub, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO DA SUBSCRICAO INICIAL - DEMITIDOS/CANCELAMENTO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcapsub, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Cheques em custodia .....................................................
    -- Entradas de cheques em custodia do dia
    vr_vlcstcop := 0;
    vr_vlcstout := 0;
    for rw_crapcst in cr_crapcst (pr_cdcooper,
                                  vr_dtmvtolt) loop
      if rw_crapcst.nrdconta = 85448 then
        vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
      else
        vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
      end if;
    end loop;
    --
    if vr_vlcstout > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3482,'||
                     '9143,'||
                     trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CUSTODIA OUTROS ASSOCIADOS."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcstcop > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3481,'||
                     '9142,'||
                     trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CUSTODIA COOPER."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Liberacao de cheques em custodia do dia
    vr_vlcstcop := 0;
    vr_vlcstout := 0;
    for rw_crapcst in cr_crapcst2 (pr_cdcooper,
                                   vr_dtmvtoan,
                                   vr_dtmvtolt) loop
      if rw_crapcst.nrdconta = 85448 then
        vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
      else
        vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
      end if;
    end loop;
    --
    if vr_vlcstout > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9143,'||
                     '3482,'||
                     trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIBERACAO CUSTODIA OUTROS ASSOCIADOS."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcstcop > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9142,'||
                     '3481,'||
                     trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIBERACAO CUSTODIA COOPER."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Resgates de cheques em custodia do dia / transf. para desconto de cheques
    vr_vlcstcop := 0;
    vr_vlcstout := 0;
    vr_vlcdbban := 0;
    vr_vlcdbcop := 0;

    for rw_crapcst in cr_crapcst3 (pr_cdcooper,
                                   vr_dtmvtolt) loop
      if rw_crapcst.insitchq = 5 then  -- Cheque descontado
        if rw_crapcst.nrdconta = 85448 then
          vr_vlcdbcop := vr_vlcdbcop + rw_crapcst.vlcheque;
        else
          vr_vlcdbban := vr_vlcdbban + rw_crapcst.vlcheque;
        end if;
      else
        if rw_crapcst.nrdconta = 85448 then
          vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
        else
          vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
        end if;
      end if;
    end loop;
    --
    if vr_vlcstout > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9143,'||
                     '3482,'||
                     trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE CUSTODIA OUTROS ASSOCIADOS."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcstcop > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9142,'||
                     '3481,'||
                     trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE CUSTODIA COOPER."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcdbban > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9143,'||
                     '3482,'||
                     trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CUSTODIA TRANSFERIDA PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcdbcop > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9142,'||
                     '3481,'||
                     trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CUSTODIA TRANSFERIDA PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Titulos compensaveis ....................................................
    open cr_craptab (pr_cdcooper,
                     0, --cdempres
                     'GENERI', --tptabela
                     'TITCTARIFA', --cdacesso
                     1); --tpregist
      fetch cr_craptab into rw_craptab.dstextab;
      if cr_craptab%notfound then
        vr_vltarifa := 0;
      else
        vr_vltarifa := to_number(rw_craptab.dstextab);
      end if;
    close cr_craptab;
    --
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_craptit in cr_craptit (pr_cdcooper,
                                  vr_dtmvtolt,
                                  0) loop
      pc_cria_agencia_pltable(rw_craptit.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_vltitulo := rw_craptit.vldpagto;
      vr_tab_agencia(rw_craptit.cdagenci).vr_qttottrf := rw_craptit.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit.qttottrf;
      --
      open cr_crapage2(pr_cdcooper,
                       rw_craptit.cdagenci);
        fetch cr_crapage2 into rw_crapage2;
        if cr_crapage2%notfound then
          close cr_crapage2;
          vr_cdcritic := 962;
          RAISE vr_exc_saida;
        else
          if rw_crapage2.cdbantit = 1 then  -- Banco do Brasil
            vr_cdhistor := 713;
          elsif rw_crapage2.cdbantit = 756 then -- Bancoob
            vr_cdhistor := 546;
          elsif rw_crapage2.cdbantit = rw_crapcop.cdbcoctl then
            vr_cdhistor := 824;
          end if;
          --
          open cr_craphis2 (pr_cdcooper,
                            vr_cdhistor);
            fetch cr_craphis2 into rw_craphis2;
            if cr_craphis2%notfound then
              close cr_craphis2;
              vr_cdcritic := 526;
              vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
              raise vr_exc_saida;
            end if;
          close cr_craphis2;
        end if;
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_craptit.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd,'0000'))||','||
                       trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) NOSSA REMESSA."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_craptit.cdagenci, 'fm000')||','||trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      close cr_crapage2;
    end loop;  -- Fim do loop craptit

    -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE COM FLOAT
    -- MOVIMENTA CONTA 4972
    -- MOVIMENTA CONTA 4957 - Boleto de emprestimo (Projeto 210)
    -- MOVIMENTA CONTA 4954 - Boleto de desconto de titulos (Projeto 403 - Paulo Penteado GFT)
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    FOR rw_craptit4 in cr_craptit4 (pr_cdcooper,
                                    vr_dtmvtolt) LOOP

      pc_cria_agencia_pltable(rw_craptit4.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      vr_vltitulo := rw_craptit4.vldpagto;
      vr_tab_agencia(rw_craptit4.cdagenci).vr_qttottrf := rw_craptit4.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit4.qttottrf;
      --
      IF rw_craptit4.dsorgarq = 'EMPRESTIMO' THEN
        vr_linhadet := TRIM(vr_cdestrut)||
                       TRIM(vr_dtmvtolt_yymmdd)||','||
                       TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       TRIM(to_char(vr_tab_agencia2(rw_craptit4.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       '4957,'|| -- Conta pendência da singular
                       TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO EMPRESTIMO ' || rw_craptit4.nrconven || '"';

      ELSIF rw_craptit4.dsorgarq = 'DESCONTO DE TITULO' THEN
        vr_linhadet := TRIM(vr_cdestrut)||
                       TRIM(vr_dtmvtolt_yymmdd)||','||
                       TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       TRIM(to_char(vr_tab_agencia2(rw_craptit4.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       '4957,'|| -- Conta pendência da singular
                       TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO DESCONTO DE TITULO ' || rw_craptit4.nrconven || '"';

      ELSE
        vr_linhadet := TRIM(vr_cdestrut)||
                       TRIM(vr_dtmvtolt_yymmdd)||','||
                       TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       TRIM(to_char(vr_tab_agencia2(rw_craptit4.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       '4972,'|| -- Conta pendência da singular
                       TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO ' || rw_craptit4.nrconven || '"';
      END IF;
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craptit4.cdagenci, 'fm000')||','||TRIM(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    END LOOP;  -- Fim do loop craptit4

    -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE - DESCONTADOS
    -- MOVIMENTA CONTA 4954
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    FOR rw_craptit5 in cr_craptit5 (pr_cdcooper,
                                    vr_dtmvtolt) LOOP
      pc_cria_agencia_pltable(rw_craptit5.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      vr_vltitulo := rw_craptit5.vldpagto;
      vr_tab_agencia(rw_craptit5.cdagenci).vr_qttottrf := rw_craptit5.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit5.qttottrf;
      --
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     TRIM(to_char(vr_tab_agencia2(rw_craptit5.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     '4954,'|| -- Conta pendência da singular
                     TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUA REMESSA - CONVENIO ' || rw_craptit5.nrconven || '"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craptit5.cdagenci, 'fm000')||','||TRIM(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;  -- Fim do loop craptit5

    -----------------------------Titulos Cooperativa-----------------------
    open cr_craphis2 (pr_cdcooper,
                      751);
      fetch cr_craphis2 into rw_craphis2;
    close cr_craphis2;
    --
    open cr_craptab (pr_cdcooper,
                     0, --cdempres
                     'GENERI', --tptabela
                     'TITCTARIFA', --cdacesso
                     1); --tpregist
      fetch cr_craptab into rw_craptab.dstextab;
      if cr_craptab%notfound then
        vr_vltarifa := 0;
      else
        vr_vltarifa := to_number(rw_craptab.dstextab);
      end if;
    close cr_craptab;
    --
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    FOR rw_craptit3 in cr_craptit3 (pr_cdcooper,
                                    vr_dtmvtolt) LOOP
      pc_cria_agencia_pltable(rw_craptit3.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      vr_vltitulo := rw_craptit3.vldpagto;
      vr_tab_agencia(rw_craptit3.cdagenci).vr_qttottrf := rw_craptit3.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit3.qttottrf;
      --
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     TRIM(to_char(vr_tab_agencia2(rw_craptit3.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     '4954,'||
                     TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) NOSSA REMESSA."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craptit3.cdagenci, 'fm000')||','||trim(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;  -- Fim do loop craptit3

    -- Desconto de cheques .....................................................
    vr_cdestrut := '51';
    vr_vlcdbtot := 0;
    vr_vlcdbjur := 0;
    -- Entradas de desconto de cheques no dia
    for rw_crapbdc in cr_crapbdc (pr_cdcooper,
                                  vr_dtmvtolt) loop
      for rw_crapcdb in cr_crapcdb (pr_cdcooper,
                                    rw_crapbdc.nrborder) loop
        vr_vlcdbtot := vr_vlcdbtot + rw_crapcdb.vlcheque;
        vr_vlcdbjur := vr_vlcdbjur + (rw_crapcdb.vlcheque - rw_crapcdb.vlliquid);
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      end loop;
    end loop;
    --
    if vr_vlcdbtot > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1641,'||
                     '4954,'||
                     trim(to_char(vr_vlcdbtot, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CHEQUE RECEBIDO PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbtot, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1641,'||
                     trim(to_char(vr_vlcdbjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RECEITA DE CHEQUE RECEBIDO PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbjur, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3483,'||
                     '9144,'||
                     trim(to_char(vr_vlcdbtot, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CHEQUE RECEBIDO PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    vr_vlcdbban := 0;
    vr_qtcdbban := 0;
    vr_vlcdbcop := 0;
    -- Liberacao de cheques descontados do dia -- envio para a COMPE  ...........
    open cr_crapcdb2(pr_cdcooper,
                                   vr_dtmvtoan,
                     vr_dtmvtolt);
    loop
      fetch cr_crapcdb2 bulk collect into rw_crapcdb limit 5000;
      exit when rw_crapcdb.COUNT = 0;

      -- Grava dados operacionais contábeis
      pc_grava_crapopc_bulk(pr_cdcooper,
                       vr_dtmvtolt,
                       rw_crapcdb,
                       1, -- tpregist = 1 desconto de cheques
                       2, -- cdtipope = 2 liquidacao cheque recebido para desconto
                       vr_cdprogra);

      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    end loop;
    close cr_crapcdb2;
    --

    if vr_vlcdbban > 0 then  -- Cheques de outros bancos
      open cr_crapage2(pr_cdcooper,
                       1);
        fetch cr_crapage2 into rw_crapage2;
        if cr_crapage2%notfound then
          close cr_crapage2;
          vr_cdcritic := 962;
          raise vr_exc_saida;
        else
          if rw_crapage2.cdbanchq = 1 then  -- Banco do Brasil
            vr_cdhistor := 731;
            vr_qtcdbban := 0;
          elsif rw_crapage2.cdbanchq = 756 then -- Bancoob
            vr_cdhistor := 547;
          elsif rw_crapage2.cdbanchq = rw_crapcop.cdbcoctl then
            vr_cdhistor := 466;
          else
            vr_cdhistor := 0;
          end if;
          --
          open cr_craphis2 (pr_cdcooper,
                            vr_cdhistor);
            fetch cr_craphis2 into rw_craphis2;
            if cr_craphis2%notfound then
              close cr_craphis2;
              vr_cdcritic := 526;
              vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
              RAISE vr_exc_saida;
            end if;
          close cr_craphis2;
        end if;
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb,'0000'))||','||
                       '1641,'||
                       trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '9144,'||
                       '3483,'||
                       trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      close cr_crapage2;
    end if;
    -- Lancamento de Tarifa - CHEQUE DESCONTO BANCOOB ........................
    if vr_qtcdbban > 0 then  -- Cheques de outros bancos
      -- Busca a tarifa
      open cr_craphis2 (pr_cdcooper,
                        547);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := '547 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      open cr_crapthi(pr_cdcooper,
                      547,
                      'AIMARO');
        fetch cr_crapthi into rw_crapthi;
        if cr_crapthi%notfound then
          close cr_crapthi;
          vr_cdcritic := 1041;
          vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 547 - crapthi';
          -- Gera a mensagem de erro no log e não prossegue a rotina.
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_dscritic);
          -- Troca de return por raise - Chamado 832035 - 16/01/2018
          --return;
          RAISE vr_exc_saida;
        end if;
      close cr_crapthi;
      --
      if rw_crapthi.vltarifa > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctatrd))||','||
                       trim(to_char(rw_craphis2.nrctatrc))||','||
                       trim(to_char(vr_qtcdbban * rw_crapthi.vltarifa, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO (tarifa)."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '001,'||trim(to_char(vr_qtcdbban * rw_crapthi.vltarifa, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    --
    if vr_vlcdbcop > 0 then  -- Cheques da Cooperativa
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4958,'||
                     '1641,'||
                     trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbcop, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9144,'||
                     '3483,'||
                     trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Resgate de cheques descontados no dia ..................................
    vr_vlcdbban := 0;
    vr_vlcdbcop := 0;
    --
    for rw_crapcdb in cr_crapcdb3 (pr_cdcooper,
                                   vr_dtmvtolt) loop
      vr_vlcdbban := vr_vlcdbban + rw_crapcdb.vlcheque;
      vr_vlcdbcop := vr_vlcdbcop + (rw_crapcdb.vlliqdev - rw_crapcdb.vlliquid);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
    --
    if vr_vlcdbban > 0 then  -- Valor do cheque descontado
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1641,'||
                     trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9144,'||
                     '3483,'||
                     trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_vlcdbcop > 0 then

      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1641,'||
                     '4954,'||
                     trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                     '2425,'||
                     '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbcop, '99999999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- Desconto de titulos ......................................................
    vr_cdestrut := '51';
    vr_vltdbtot := 0;
    vr_vltdbjur := 0;
    vr_tdbtotsr := 0;
    vr_tdbjursr := 0;
    vr_tdbtotcr := 0;
    vr_tdbjurcr := 0;
    -- Entradas de desconto de titulos no dia.
    -- Existem situacoes que o bordero eh liquidado no mesmo dia de sua liberacao,
    -- principalmente por pagamentos antecipados, porem pode ser liquidado com o
    -- resgate de titulos, neste caso os titulos resgatados nao sao considerados
    for rw_crapbdt in cr_crapbdt (pr_cdcooper,
                                  vr_dtmvtolt) loop

      for rw_craptdb in cr_craptdb (pr_cdcooper,
                                    rw_crapbdt.nrdconta,
                                    rw_crapbdt.nrborder) loop
        vr_vltdbtot := vr_vltdbtot + rw_craptdb.vltitulo;
        vr_vltdbjur := vr_vltdbjur + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        --
        if rw_craptdb.flgregis = 1 /* true */ then
          vr_tdbtotcr := vr_tdbtotcr + rw_craptdb.vltitulo;
          vr_tdbjurcr := vr_tdbjurcr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        else
          vr_tdbtotsr := vr_tdbtotsr + rw_craptdb.vltitulo;
          vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        end if;
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      end loop;
    end loop;
    --
    if vr_vltdbtot > 0 then
      -- total de titulos descontados sem registro
      if vr_tdbtotsr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1643,'||
                       '4954,'||
                       trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1643,'||
                       trim(to_char(vr_tdbjursr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RENDA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbjursr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      -- total de titulos descontados com registro
      if vr_tdbtotcr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1645,'||
                       '4954,'||
                       trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1645,'||
                       trim(to_char(vr_tdbjurcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RENDA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbjurcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      end if;
    --
    vr_vltdbtot := 0;
    vr_tdbtotsr := 0;
    vr_tdbjursr := 0;
    vr_tdbtotcr_001 := 0;
    vr_tdbtotcr_085 := 0;
    vr_tdbjurcr_001 := 0;
    vr_tdbjurcr_085 := 0;
    vr_qttdbtot := 0;
    vr_qtdtdbsr := 0;
    vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                               vr_dtmvtoan - 1,
                                               'A');
    -- Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
    -- Lancar a liquidacao de titulos recebidos via COMPE com D+1, sendo assim
    -- ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
    -- data atual - Pedido da contabilidade
    -- *** somente titulos do Banco do Brasil -> credito D+1 (Rafael) ***
    -- Obs.: a movimentacao contabil abaixo refere-se aos titulos descontados
    -- da cooperativa, com excecao dos titulos migrados. (Rafael)

    vr_tab_agencia.delete;
    for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                   vr_dtrefere,
                                   vr_dtmvtoan,
                                   1) loop

      open cr_crapcob (rw_craptdb.cdcooper,
                       rw_craptdb.cdbandoc,
                       rw_craptdb.nrdctabb,
                       rw_craptdb.nrcnvcob,
                       rw_craptdb.nrdconta,
                       rw_craptdb.nrdocmto);
        fetch cr_crapcob into rw_crapcob;
        -- Se não encontrar registros
        if cr_crapcob%notfound then
          close cr_crapcob; -- Fecha o cursor
          continue; -- Próximo registro
        end if;
      close cr_crapcob;
      -- Alteração no progress feita pelo Rafael Cechet, alterado no Oracle por Daniel (Supero)
      open cr_crapcco (pr_cdcooper,
                       rw_crapcob.nrcnvcob);
        fetch cr_crapcco into rw_crapcco;
        if cr_crapcco%notfound then
          CLOSE cr_crapcco;
          continue;
        end if;
      close cr_crapcco;

      if  rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        continue;
      end if;

      -- Fim da alteração
      -- Pago pela COMPE
      if rw_crapcob.indpagto = 0 then
        vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
        vr_qttdbtot := vr_qttdbtot + 1;
        -- Buscar a agência
        open cr_crapass (pr_cdcooper,
                         rw_crapcob.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        -- Acumula valores
        pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
        --
        if rw_crapcob.flgregis = 1 then -- true
          vr_tdbtotcr_001 := vr_tdbtotcr_001 + rw_crapcob.vldpagto;
          vr_tdbjurcr_001 := vr_tdbjurcr_001 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
          vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 + 1;
          vr_qtdtdbcr_001 := vr_qtdtdbcr_001 + 1;
        else
          vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
          vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
          if rw_crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') then -- IF incluído na alteração do Rafael Cechet
            vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac + 1;
            vr_qtdtdbsr := vr_qtdtdbsr + 1;
          end if;
        end if;
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      end if;
    end loop;
    --
    if vr_vltdbtot > 0 then
      if vr_tdbtotsr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1172,'||
                       '1643,'||
                       trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Busca a tarifa
        open cr_craphis2 (pr_cdcooper,
                          266);
          fetch cr_craphis2 into rw_craphis2;
          if cr_craphis2%notfound then
            close cr_craphis2;
            vr_cdcritic := 526;
            vr_dscritic := '266 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
            raise vr_exc_saida;
          end if;
        close cr_craphis2;
        --
        open cr_crapthi(pr_cdcooper,
                        266,  -- CREDITO DE COBRANCA BANCO DO BRASIL
                        'AIMARO');
          fetch cr_crapthi into rw_crapthi;
          if cr_crapthi%notfound then
            close cr_crapthi;
            vr_cdcritic := 1041;
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 266 - crapthi';
            -- Gera a mensagem de erro no log e não prossegue a rotina.
            cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                      ,pr_nmarqlog      => 'proc_batch.log'
                                      ,pr_tpexecucao    => 1 -- Job
                                      ,pr_cdcriticidade => 1 -- Medio
                                      ,pr_cdmensagem    => vr_cdcritic
                                      ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '|| vr_dscritic);
            -- Troca de return por raise - Chamado 832035 - 16/01/2018
            --return;
            RAISE vr_exc_saida;
          end if;
        close cr_crapthi;
        --
        vr_linhadet := '55'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctatrd))||','||
                       trim(to_char(rw_craphis2.nrctatrc))||','||
                       trim(to_char(vr_qtdtdbsr * rw_crapthi.vltarifa, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                       ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Cria lançamentos por agência
        vr_indice_agencia := vr_tab_agencia.first;
        while vr_indice_agencia <= 998 loop
          if vr_tab_agencia(vr_indice_agencia).vr_qttarpac > 0 then
            vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarpac * rw_crapthi.vltarifa, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
        end loop;
      end if;
      --
      if vr_tdbtotcr_001 > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1257,'||
                       '1645,'||
                       trim(to_char(vr_tdbtotcr_001, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO VIA BANCO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_001, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;

    --
    vr_tdbtotsr := 0;
    vr_qttdbtot := 0;
    vr_vltdbtot := 0;
    vr_tdbjursr := 0;
    vr_tdbtotcr_001 := 0;
    vr_tdbjurcr_001 := 0;
    vr_tdbtotcr_085 := 0;
    vr_tdbjurcr_085 := 0;

    vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                               vr_dtmvtoan - 1,
                                               'A');

   --  Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
   --  Lancar a liquidacao de titulos recebidos via COMPE com D+1, sendo assim
   --  ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
   --  data atual - Pedido da contabilidade
   --  *** somente titulos do Banco do Brasil -> credito D+1 (Rafael) ***
   for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                  vr_dtrefere,
                                  vr_dtmvtoan,
                                  1) loop

     OPEN cr_crapcob (pr_cdcooper => rw_craptdb.cdcooper,
                      pr_cdbandoc => rw_craptdb.cdbandoc,
                      pr_nrdctabb => rw_craptdb.nrdctabb,
                      pr_nrcnvcob => rw_craptdb.nrcnvcob,
                      pr_nrdconta => rw_craptdb.nrdconta,
                      pr_nrdocmto => rw_craptdb.nrdocmto);

     FETCH cr_crapcob INTO rw_crapcob;

     IF  cr_crapcob%notfound  THEN
       CLOSE cr_crapcob;
       CONTINUE;
     END IF;

     CLOSE cr_crapcob;

     OPEN cr_crapcco (pr_cdcooper => pr_cdcooper,
                      pr_nrcnvcob => rw_crapcob.nrcnvcob);

     FETCH cr_crapcco INTO rw_crapcco;

     IF  cr_crapcco%notfound  THEN
       CLOSE cr_crapcco;
       CONTINUE;
     END IF;

     CLOSE cr_crapcco;

     IF rw_crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN
       CONTINUE;
     END IF;

     --  Pago pela COMPE
     IF  rw_crapcob.indpagto = 0  THEN

       vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
       vr_qttdbtot := vr_qttdbtot + 1;

       -- Buscar a agência
       open cr_crapass (pr_cdcooper,
                        rw_crapcob.nrdconta);

       fetch cr_crapass into rw_crapass;

       close cr_crapass;

       -- Cobranca registrada
       IF  rw_crapcob.flgregis = 1   THEN
         vr_tdbtotcr_001 := vr_tdbtotcr_001 + rw_crapcob.vldpagto;
         vr_tdbjurcr_001 := vr_tdbjurcr_001 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
         -- Acumula valores
         pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
         -- Incluir nome do módulo logado
         cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
         vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 + 1;
         vr_qtdtdbcr_001 := vr_qtdtdbcr_001 + 1;
       ELSE
         vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
         vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
       END IF;

       -- Incluir nome do módulo logado
       cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
     END IF;

   end loop;  -- Fim loop craptdb

   if  vr_vltdbtot > 0  then

     if  vr_tdbtotsr > 0  then
       vr_linhadet := trim(vr_cdestrut)||
                      trim(vr_dtmvtolt_yymmdd)||','||
                      trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                      '1839,'||
                      '1643,'||
                      trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                      '5210,'||
                      '"(crps249) LIQUIDACAO DE TITULO MIGRADO RECEBIDO PARA DESCONTO S/ REGISTRO"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;

     if vr_tdbtotcr_001 > 0  then
        vr_linhadet := trim(vr_cdestrut)||
                      trim(vr_dtmvtolt_yymmdd)||','||
                      trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                      '1839,'||
                      '1645,'||
                      trim(to_char(vr_tdbtotcr_001, '99999999999990.00'))||','||
                      '5210,'||
                      '"(crps249) LIQUIDACAO DE TITULO MIGRADO RECEBIDO PARA DESCONTO C/ REGISTRO VIA BANCO"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
       vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_001, '99999999999990.00'));
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;
   end if;

   vr_vltdbtot := 0;

    -- Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
    -- Lancar a liquidacao de titulos recebidos via COMPE com D+0, sendo assim
    -- ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
    -- data atual - Pedido da contabilidade
    -- *** somente titulos da compe 085 (Rafael) ***
    --
    vr_tab_agencia.delete;
    for rw_craptdb in cr_craptdb3 (pr_cdcooper,
                                   vr_dtmvtolt) loop
      open cr_crapcob (rw_craptdb.cdcooper,
                       85 /* cdbandoc */,
                       rw_craptdb.nrdctabb,
                       rw_craptdb.nrcnvcob,
                       rw_craptdb.nrdconta,
                       rw_craptdb.nrdocmto);
        fetch cr_crapcob into rw_crapcob;
        -- Se não encontrar registros
        if cr_crapcob%notfound then
          close cr_crapcob; -- Fecha o cursor
          continue; -- Próximo registro
        end if;
      close cr_crapcob;

      -- Pago pela COMPE
      if rw_crapcob.indpagto = 0 then
        vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
        vr_qttdbtot := vr_qttdbtot + 1;
        -- Buscar a agência
        open cr_crapass (pr_cdcooper,
                         rw_crapcob.nrdconta);
          fetch cr_crapass into rw_crapass;
        close cr_crapass;
        -- Acumula valores
        pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
        --
        vr_tdbtotcr_085 := vr_tdbtotcr_085 + rw_crapcob.vldpagto;
        vr_tdbjurcr_085 := vr_tdbjurcr_085 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_085 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_085 + 1;
        vr_qtdtdbcr_085 := vr_qtdtdbcr_085 + 1;
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      end if;
    end loop;
    --
    if vr_vltdbtot > 0 then
      if vr_tdbtotcr_085 > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1455,'||
                       '1645,'||
                       trim(to_char(vr_tdbtotcr_085, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO VIA COMPE."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_085, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    --
    vr_vltdbtot := 0;
    vr_tdbtotcr := 0;
    vr_tdbtotsr := 0;
    -- Liberacao de titulos pagos no dia -
    -- Pagos pelo SACADO - via CAIXA indpagto = 1
    -- INTERNET pac 90 indpagto = 3
    -- TAA pac 91 indpagto = 4
    --
    for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                   vr_dtmvtoan,
                                   vr_dtmvtolt,
                                   null) loop
      open cr_crapcob (rw_craptdb.cdcooper,
                       rw_craptdb.cdbandoc,
                       rw_craptdb.nrdctabb,
                       rw_craptdb.nrcnvcob,
                       rw_craptdb.nrdconta,
                       rw_craptdb.nrdocmto);
        fetch cr_crapcob into rw_crapcob;
        --
        if cr_crapcob%notfound then
          close cr_crapcob;
          -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
          vr_cdcritic := 1113;
          vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_dscritic);
          continue;
        end if;
      close cr_crapcob;

      -- Pago pelo CAIXA, pela INTERNET (pac 90) ou TAA (pac 91)
      if rw_crapcob.indpagto in (1, 3, 4) then
        vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;

        if rw_crapcob.flgregis = 1 then -- true
          vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vldpagto;
        else
          vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
        end if;
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      end if;
    end loop;
    --
    if vr_vltdbtot > 0 then
      if vr_tdbtotsr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1643,'||
                       trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      if vr_tdbtotcr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1645,'||
                       trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    --
    vr_vltdbtot := 0;
    vr_tdbtotcr := 0;
    vr_tdbtotsr := 0;
    -- Liberacao de titulos vencidos - Pagos pelo CEDENTE .............
    vr_dtrefere := fn_calcula_data(pr_cdcooper,
                                   vr_dtmvtoan);
    for rw_craptdb in cr_craptdb4 (pr_cdcooper
                                  ,vr_dtmvtolt) loop

      open cr_crapcob (rw_craptdb.cdcooper,
                       rw_craptdb.cdbandoc,
                       rw_craptdb.nrdctabb,
                       rw_craptdb.nrcnvcob,
                       rw_craptdb.nrdconta,
                       rw_craptdb.nrdocmto);
        fetch cr_crapcob into rw_crapcob;
        --
        if cr_crapcob%notfound then
          close cr_crapcob;
          -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
          vr_cdcritic := 1113;
          vr_dscritic := 'Pagos pelo cedente '||cecred.gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_dscritic);
          continue;
        end if;
      close cr_crapcob;
      -- No caso de fim de semana e feriado, nao pega os titulos que ja foram
      -- pegos no dia anterior a ontem
      if vr_dtrefere <> vr_dtmvtoan and
         rw_craptdb.dtvencto = vr_dtrefere then
        continue;
      end if;

      vr_vltdbtot := vr_vltdbtot + rw_crapcob.vltitulo;
      if rw_crapcob.flgregis = 1 then -- true
          vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vltitulo;
      else
        vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vltitulo;
      end if;
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
    --
    if vr_vltdbtot > 0 then
      if vr_tdbtotsr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4957,'||
                       '1643,'||
                       trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) DEBITO DE TITULO DESCONTADO VENCIDO E NAO PAGO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      if vr_tdbtotcr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4957,'||
                       '1645,'||
                       trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) DEBITO DE TITULO DESCONTADO VENCIDO E NAO PAGO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    --
    vr_vltdbtot := 0;
    vr_vltdbjur := 0;
    vr_tdbtotsr := 0;
    vr_tdbtotcr := 0;
    vr_tdbjursr := 0;
    vr_tdbjurcr := 0;
    -- Nao considera os resgates efetuados no mesmo dia da liberacao pois nao eh
    -- considerada entrada do titulo em desconto
    for rw_craptdb in cr_craptdb5 (pr_cdcooper,
                                   vr_dtmvtolt) loop

      open cr_crapcob (rw_craptdb.cdcooper,
                       rw_craptdb.cdbandoc,
                       rw_craptdb.nrdctabb,
                       rw_craptdb.nrcnvcob,
                       rw_craptdb.nrdconta,
                       rw_craptdb.nrdocmto);
        fetch cr_crapcob into rw_crapcob;
        --
        if cr_crapcob%notfound then
          close cr_crapcob;
          -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
          vr_cdcritic := 1113;
          vr_dscritic := 'Nao eh considerada '||cecred.gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_dscritic);
          continue;
        end if;
      close cr_crapcob;

      vr_vltdbtot := vr_vltdbtot + rw_craptdb.vltitulo;
      vr_vltdbjur := vr_vltdbjur + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
      --
      vr_vltdbtot := vr_vltdbtot + rw_crapcob.vltitulo;
      if rw_crapcob.flgregis = 1 /* true */ then
        vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vltitulo;
        vr_tdbjurcr := vr_tdbjurcr + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
      else
        vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vltitulo;
        vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
      end if;

      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
    --
    if vr_vltdbtot > 0 then
      if vr_tdbtotsr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1643,'||
                       trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      if vr_tdbtotcr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4954,'||
                       '1645,'||
                       trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    --
    if vr_vltdbjur > 0 then
      if vr_tdbjursr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1643,'||
                       '4954,'||
                       trim(to_char(vr_tdbjursr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbjursr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      if vr_tdbjurcr > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1645,'||
                       '4954,'||
                       trim(to_char(vr_tdbjurcr, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := '999,'||trim(to_char(vr_tdbjurcr, '99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;

    IF to_char(vr_dtmvtolt, 'mm') = to_char(vr_dtmvtopr, 'mm') THEN
      pc_proc_lancbor(vr_dtmvtolt);
    END IF;

    -- COBRANCA REGISTRADA .....................................................
    vr_cdhistbb := 0;
    -- Incluir no arquivo as informações consistentes
    for rw_crapret in cr_crapret (pr_cdcooper,
                                  vr_dtmvtolt) loop
      if rw_crapret.cdhistbb <> vr_cdhistbb and
         rw_crapret.vltarcus_tot + rw_crapret.vloutdes_tot > 0 then
        open cr_craphis2 (pr_cdcooper,
                          rw_crapret.cdhistbb);
          fetch cr_craphis2 into rw_craphis2;
          --
          vr_linhadet := '55'||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(rw_craphis2.nrctadeb,'0000'))||','||
                         trim(to_char(rw_craphis2.nrctacrd,'0000'))||','||
                         trim(to_char(rw_crapret.vltarcus_tot + rw_crapret.vloutdes_tot, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        close cr_craphis2;
      end if;
      --
      if rw_crapret.vltarcus + rw_crapret.vloutdes > 0 then
        vr_linhadet := to_char(rw_crapret.cdagenci, 'fm000')||','||
                       trim(to_char(rw_crapret.vltarcus + rw_crapret.vloutdes, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      vr_cdhistbb := rw_crapret.cdhistbb;
    end loop;
    -- Gerar inconsistência para os registros de cobrança cujo associado não está cadastrado
    for rw_crapret2 in cr_crapret2 (pr_cdcooper,
                                    vr_dtmvtolt) loop
      -- busca a agência
      vr_cdcritic := 1042;
      vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' na Cob. Registrada crapret - ROWID(crapret) = '||rw_crapret2.rowid;
      cecred.btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 1 -- Medio
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '|| vr_dscritic);
    end loop;

    -- PROCESSAR LANÇAMENTOS DOS TITULOS 085 CREDITADOS AOS COOPERADOS
    -- MOVIMENTA CONTA 4957 - Boleto de emprestimo (Projeto 210)
    -- MOVIMENTA CONTA 4954 - Boleto de desconto de titulo (Projeto 403 - Paulo Penteado GFT )
    for rw_crapret3 in cr_crapret3 (pr_cdcooper => pr_cdcooper,
                                    pr_dtocorre => vr_dtmvtolt) loop

      IF rw_crapret3.dsorgarq = 'EMPRESTIMO' THEN
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1455,'|| -- Cecred COMPE (D)
                       '4957,'|| -- Conta pendência da singular (C)
                       trim(to_char(rw_crapret3.vlrpagto, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO EMPRESTIMO ' || to_char(rw_crapret3.nrcnvcob) || '"';

      ELSIF rw_crapret3.dsorgarq = 'DESCONTO DE TITULO' THEN
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1455,'|| -- Cecred COMPE (D)
                       '4957,'|| -- Conta pendência da singular (C)
                       trim(to_char(rw_crapret3.vlrpagto, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO DESCONTO DE TITULO ' || to_char(rw_crapret3.nrcnvcob) || '"';

      ELSE
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '1455,'|| -- Cecred COMPE (D)
                       '4972,'|| -- Conta pendência da singular (C)
                       trim(to_char(rw_crapret3.vlrpagto, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) SUA REMESSA - CONVENIO ' || to_char(rw_crapret3.nrcnvcob) || '"';
      END IF;

      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    end loop;  -- Fim do loop crapret3

    --  ACERTO FINANCEIRO BB (entre singulares - migracao Alto Vale, Acredi) ............
    if pr_cdcooper = 1 or
       pr_cdcooper = 2 then
      for rw_crapafi in cr_crapafi (pr_cdcooper,
                                    vr_dtmvtolt) loop

        -- Se o valor dos lançamentos for maior que zero
        IF rw_crapafi.vlafitot > 0  THEN

          -- Obter coperativa de destino
          OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

          FETCH cr_crapcop INTO rw_crapcop_2;

          CLOSE cr_crapcop;

          IF rw_crapafi.cdhistor = 266 THEN
            -- credito de cobranca sem registro
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '1172,'||
                           '4990,'||
                           trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                           '5210,'||
                           '"(crps249) VALORES A REPASSAR ' || rw_crapcop_2.nmrescop || ' - LIQUIDACAO COBRANCA S/REGISTRO."';
          ELSE
            -- credito de cobranca registrada
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '1257,'||
                           '4990,'||
                           trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                           '5210,'||
                           '"(crps249) VALORES A REPASSAR VIACREDI AV - LIQUIDACAO COBRANCA C/REGISTRO."';
          END IF;

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        END IF;

      END LOOP;

      -- Limpar a PL / TABLE
      vr_tab_hist_cob.DELETE;

      -- Debito de Tarifa - Cobranca com e sem registro
      FOR rw_histori IN cr_histori (pr_cdcooper => pr_cdcooper) LOOP

        IF  rw_histori.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN

          vr_indice_hist_cob := to_char(rw_histori.cdhistor,'00000') || to_char(rw_histori.nrdctabb,'000000000000') || to_char(rw_histori.flgregis);

          IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
            vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistor;
            vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
            vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
          END IF;
        END IF;
      END LOOP;
      -- P681 - Entes Publicos - Marcus Abreu
      -- Realiza o mesmo loop acima, mas com o cursor buscando somente os historicos especificos para o Ente Publico
      -- Quando já não existirem na tabela de memoria, adiciona-os para consumir posteriormente
      FOR rw_histori IN cr_historiep (pr_cdcooper => pr_cdcooper) LOOP
        IF  rw_histori.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN
          vr_indice_hist_cob := to_char(rw_histori.cdhistep,'00000') || to_char(rw_histori.nrdctabb,'000000000000') || to_char(rw_histori.flgregis);
          IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
            vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistep;
            vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
            vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
          END IF;

        END IF;

      END LOOP;

      -- Percorrer a tabela com os debitos de tarifa de cobranca
      vr_indice_hist_cob := vr_tab_hist_cob.FIRST;

      LOOP

        EXIT WHEN vr_indice_hist_cob IS NULL;

        -- Debito de Tarifa - com e sem registro
        FOR rw_crapafi IN cr_crapafi3 (pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => vr_dtmvtolt,
                                       pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                       pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP

          IF  rw_crapafi.vlafitot > 0  THEN
            -- Obter coperativa de destino
            OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

            FETCH cr_crapcop INTO rw_crapcop_2;

            CLOSE cr_crapcop;

            -- Cobranca com registro
            IF  vr_tab_hist_cob(vr_indice_hist_cob).flgregis = 1  THEN
              vr_linhadet := trim(vr_cdestrut)||
                             trim(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             '1839,'||
                             '1257,'||
                             trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                             '5210,'||
                             '"(crps249) VALORES A RECEBER ' || rw_crapcop_2.nmrescop ||' - ('||to_char(rw_crapafi.cdhistor)||') TARIFA COBRANCA C/REGISTRO."';
            ELSE
              -- debito de tarifa - cobranca sem registro
              vr_linhadet := trim(vr_cdestrut)||
                             trim(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             '1839,'||
                             '1172,'||
                             trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                             '5210,'||
                             '"(crps249) VALORES A RECEBER '|| rw_crapcop_2.nmrescop  ||
                             ' - ('||to_char(rw_crapafi.cdhistor)||')'||
                             ' - TARIFA COBRANCA S/REGISTRO."';
            END IF;
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;

        END LOOP;
        vr_indice_hist_cob := vr_tab_hist_cob.NEXT(vr_indice_hist_cob);

      END LOOP;
    END IF;
    --
    if pr_cdcooper = 16  or
       pr_cdcooper = 1  then

      vr_cdhistor := 0;
      vr_vlafideb := 0;

      vr_tab_hist_cob.delete;
      vr_tab_agencia.delete;

      -- Debito de Tarifa - Cobranca com e sem Registro
      FOR rw_histori IN cr_histori (pr_cdcooper => pr_cdcooper) LOOP

        IF  rw_histori.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

          vr_indice_hist_cob := trim(to_char(rw_histori.cdhistor,'00000')) || trim(to_char(rw_histori.nrdctabb,'000000000000')) || trim(to_char(rw_histori.flgregis));

          IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
            vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistor;
            vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
            vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
          END IF;

        END IF;

      END LOOP;
      -- P681 - Entes Publicos - Marcus Abreu
      -- Realiza o mesmo loop acima, mas com o cursor buscando somente os historicos especificos para o Ente Publico
      -- Quando já não existirem na tabela de memoria, adiciona-os para consumir posteriormente
      FOR rw_histori IN cr_historiep (pr_cdcooper => pr_cdcooper) LOOP
        IF  rw_histori.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
          vr_indice_hist_cob := trim(to_char(rw_histori.cdhistep,'00000')) || trim(to_char(rw_histori.nrdctabb,'000000000000')) || trim(to_char(rw_histori.flgregis));
          IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
            vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistep;
            vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
            vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
          END IF;
        END IF;
      END LOOP;

      -- Percorrer a tabela com os debitos de tarifa de cobranca
      vr_indice_hist_cob := vr_tab_hist_cob.FIRST;
      vr_tab_agencia.delete;

      LOOP

        EXIT WHEN vr_indice_hist_cob IS NULL;

        -- Debito de Tarifa - com e sem registro
        FOR rw_crapafi IN cr_crapafi2 (pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => vr_dtmvtolt,
                                       pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                       pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP

          -- acumular os valores por historico
          vr_vlafideb := vr_vlafideb + rw_crapafi.vllanmto;

          -- acuuula por PA
          pc_cria_agencia_pltable(rw_crapafi.cdagenci,NULL);
          -- Incluir nome do módulo logado
          cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
          vr_tab_agencia(rw_crapafi.cdagenci).vr_vltarpac := vr_tab_agencia(rw_crapafi.cdagenci).vr_vltarpac + rw_crapafi.vllanmto;

          -- Se tem valor e for o ultimo do historico
          IF  rw_crapafi.qtdreg = rw_crapafi.nrseqreg  THEN
            IF  vr_vlafideb > 0  THEN
              -- Obter coperativa de destino
              OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

              FETCH cr_crapcop INTO rw_crapcop_2;

              CLOSE cr_crapcop;

              -- Cobranca com registro
              IF  vr_tab_hist_cob(vr_indice_hist_cob).flgregis = 1 THEN
                 vr_tipocob := '(' || vr_tab_hist_cob(vr_indice_hist_cob).cdhistor || ') - TARIFA COBRANCA C/REGISTRO';
              ELSE
                -- Cobranca sem registro
                 vr_tipocob := '(' || vr_tab_hist_cob(vr_indice_hist_cob).cdhistor || ') - TARIFA COBRANCA S/REGISTRO';
              END IF;

              -- Montar linha
              vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         '8309,'||
                         '4990,'||
                         trim(to_char(vr_vlafideb, '99999999999990.00'))||','||
                         '5210,'||
                         '"(crps249) VALORES A REPASSAR ' || rw_crapcop_2.nmrescop  || ' - '||vr_tipocob||'."';

              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

              vr_indice_agencia := vr_tab_agencia.first;
              while vr_indice_agencia <= 998 loop
                if vr_tab_agencia(vr_indice_agencia).vr_vltarpac > 0 then
                  vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                                 trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltarpac, '999999990.00'));
                  cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
                end if;
                vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
              end loop;

              vr_vlafideb := 0;
            END IF;
            vr_tab_agencia.delete;
          END IF;

        END LOOP;

        FOR rw_crapafi4 IN cr_crapafi4(pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => vr_dtmvtolt,
                                       pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                       pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP

          IF rw_crapafi4.inpessoa = 1 then

             IF vr_tab_vlr_age_fis.EXISTS(rw_crapafi4.cdagenci) THEN
               -- Soma os valores por agencia de pessoa fisica
               vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) := vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) + rw_crapafi4.vllanmto;

             ELSE
             -- Inicializa o array com o valor inicial de pessoa fisica
               vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) := rw_crapafi4.vllanmto;
             END IF;

          ELSE
            IF vr_tab_vlr_age_jur.EXISTS(rw_crapafi4.cdagenci) THEN
               -- Soma os valores por agencia de pessoa jurídica
               vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) := vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) + rw_crapafi4.vllanmto;

             ELSE
             -- Inicializa o array com o valor inicial de pessoa fisica
               vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) := rw_crapafi4.vllanmto;
             END IF;

          END IF;

          --Totalizar valores por tipo de pessoa
          IF vr_tab_vlr_descbr_pes.EXISTS(rw_crapafi4.inpessoa) THEN
            -- Soma os valores por tipo de pessoa
            vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) := vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) + rw_crapafi4.vllanmto;
          ELSE
            -- Inicializa o array com o valor inicial de cada tipo de pessoa
            vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) := rw_crapafi4.vllanmto;
          END IF;
        END LOOP;


        vr_indice_hist_cob := vr_tab_hist_cob.NEXT(vr_indice_hist_cob);

      END LOOP;

    end if;

    -- IPTU ....................................................................
    vr_cdestrut := '51';
    -- Anterior -- 130
    -- Prefeitura Municipal Blumenau
    open cr_crapthi(pr_cdcooper,
                    373,
                    'AIMARO');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 373 - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
    --
    vr_vltarifa := rw_crapthi.vltarifa;
    --
    open cr_craphis2 (pr_cdcooper,
                      373);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '373 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_craptit2 in cr_craptit2 (pr_cdcooper,
                                    vr_dtmvtolt) loop
      pc_cria_agencia_pltable(rw_craptit2.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_vltitulo := rw_craptit2.vldpagto;
      vr_tab_agencia(rw_craptit2.cdagenci).vr_qttottrf := rw_craptit2.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit2.qttottrf;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craptit2.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) IPTU."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
    -- Cria registro de total de tarifa de iptu
    if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_agencia(999).vr_qttottrf, '99999999999990.00'))||','||
                     '5210,'||
                     '"RECEBIMENTO DE IPTU - LOTE 21 (tarifa)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lançamentos de tarifa de iptu por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarpac * vr_vltarifa, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- COBAN ...................................................................
    vr_tab_agencia.delete;
    vr_vltitulo := 0;
    vr_cdestrut := '51';
    --
    open cr_crapthi(pr_cdcooper,
                    750,
                    'AIMARO');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 750 - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
    --
    open cr_craphis2 (pr_cdcooper,
                      750);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '750 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_crapcbb in cr_crapcbb (pr_cdcooper,
                                  vr_dtmvtolt) loop
      pc_cria_agencia_pltable(rw_crapcbb.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_vltitulo := rw_crapcbb.valorpag;
      -- Acumula os valores de Entes Públicos por agência e na totalizadora 999
      vr_tab_agencia(rw_crapcbb.cdagenci).vr_qttottrfep := rw_crapcbb.qttottrfep;
      vr_tab_agencia(999).vr_qttottrfep := vr_tab_agencia(999).vr_qttottrfep + rw_crapcbb.qttottrfep;
      -- Acumula os valores dos demais (não Entes Públicos) por agência e na totalizadora 999
      vr_tab_agencia(rw_crapcbb.cdagenci).vr_qttottrf := rw_crapcbb.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_crapcbb.qttottrf;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_crapcbb.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"(crps249) COBAN."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_crapcbb.cdagenci, 'fm000')||','||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;
    -- Cria registro de total de tarifa de coban (Não Entes Públicos)
    if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_agencia(999).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"COBAN (tarifa)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lançamentos de tarifa de coban por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- Cria registro de total de tarifa de coban (Entes Públicos)
    if nvl(vr_tab_agencia(999).vr_qttottrfep, 0) > 0 then
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     '7298,'||
                     trim(to_char(vr_tab_agencia(999).vr_qttottrfep * rw_crapthi.vltarifa, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"COBAN ENTE PUBLICO (tarifa)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lançamentos de tarifa de coban por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_qttottrfep > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttottrfep * rw_crapthi.vltarifa, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- COBAN  - RECEBIMENTO INSS................................................
    vr_tab_agencia.delete;
    vr_vltitulo := 0;
    vr_cdestrut := '51';
    --
    open cr_crapthi(pr_cdcooper,
                    459,
                    'AIMARO');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 459 - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
    --
    --
    open cr_craphis2 (pr_cdcooper,
                      459);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '459 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_crapcbb in cr_crapcbb2 (pr_cdcooper,
                                   vr_dtmvtolt) loop
      pc_cria_agencia_pltable(rw_crapcbb.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_vltitulo := rw_crapcbb.valorpag;
      vr_tab_agencia(rw_crapcbb.cdagenci).vr_qttottrf := rw_crapcbb.qttottrf;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_crapcbb.qttottrf;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_tab_agencia2(rw_crapcbb.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"(crps249) INSS COBAN."';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_crapcbb.cdagenci, 'fm000')||','||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;
    -- Cria registro de total de tarifa de coban
    if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_agencia(999).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"COBAN INSS (tarifa)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lançamentos de tarifa de coban por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- BANCOOB - RECEBIMENTO INSS................................................
    vr_vlpioneiro := 0;
    vr_vlcartao := 0;
    vr_vlrecibo := 0;
    vr_vloutros := 0;
    vr_tab_agencia.delete;
    -- Valores das taxas a serem recebidas
    open cr_craptab (pr_cdcooper,
                     0, --cdempres
                     'GENERI', --tptabela
                     'TARINSBCOB', --cdacesso
                     0); --tpregist
      fetch cr_craptab into rw_craptab.dstextab;
      if cr_craptab%found then
        vr_vlpioneiro := to_number(substr(rw_craptab.dstextab, 1, 9));
        vr_vlcartao := to_number(substr(rw_craptab.dstextab, 11, 9));
        vr_vlrecibo := to_number(substr(rw_craptab.dstextab, 31, 9));
        vr_vloutros := to_number(substr(rw_craptab.dstextab, 21, 9));
      end if;
    close cr_craptab;
    --
    open cr_craphis2 (pr_cdcooper,
                      580); -- SAQUE DO BENEFICIO DO INSS
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '580 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_crapage in cr_crapage loop
      pc_cria_agencia_pltable(rw_crapage.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Verifica se eh PAC pioneiro
      if rw_crapage.tpagenci = 1   then
        vr_flgpione := true;
      else
        vr_flgpione := false;
      end if;
      -- Total de pagamentos do PAC
      vr_vltitulo := 0;
      -- Creditos pagos
      for rw_craplpi in cr_craplpi (pr_cdcooper,
                                    vr_dtmvtolt,
                                    rw_crapage.cdagenci) loop
        vr_vltitulo := vr_vltitulo + rw_craplpi.vllanmto;
        vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf := vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf + 1;
        vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + 1;
        --
        if vr_flgpione then
          -- PAC pioneiro
          vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlpioneiro;
          vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlpioneiro;
        elsif rw_craplpi.tppagben = 1 then
          -- Pago com Cartao
          vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlcartao;
          vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlcartao;
        elsif rw_craplpi.tppagben = 2 then
          -- Pago com Recibo
          vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlrecibo;
          vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlcartao;
        end if;
      end loop;
      -- As tarifas de creditos em conta corrente sao contabilizadas aqui por
      -- causa da diferenciacao no caso de PAC PIONEIRO, por isso o campo
      -- craphis.vltarifa nao possui o valor da tarifa de credito em conta
      for rw_craplcm in cr_craplcm (pr_cdcooper,
                                    vr_dtmvtolt,
                                    rw_crapage.cdagenci) loop
        vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf := vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf + 1;
        vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + 1;
        --
        if vr_flgpione then
          -- PAC pioneiro
          vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlpioneiro;
          vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlpioneiro;
        else
          -- Outros
          vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vloutros;
          vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vloutros;
        end if;
      end loop;
      -- Se o PAC teve lancamentos
      if vr_vltitulo > 0 then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(vr_tab_agencia2(rw_crapage.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                       '"(crps249)INSS BANCOOB."';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_crapage.cdagenci, 'fm000')||','||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop; -- Fim do FOR EACH crapage
    -- Cria registro de total de tarifa do bancoob
    if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 and
       nvl(vr_tab_agencia(999).vr_vltarbcb, 0) > 0 then
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_agencia(999).vr_vltarbcb, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"INSS BANCOOB (tarifa)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lancamentos de tarifa de INSS BANCOOB por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_vltarbcb > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltarbcb, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;

    --  Cria os lancamentos da conta investimento  -  Edson
    for rw_craplci in cr_craplci (pr_cdcooper,
                                  vr_dtmvtolt) loop
      open cr_craphis2 (pr_cdcooper,
                        rw_craplci.cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := rw_craplci.cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      if rw_craplci.cdhistor = 487 then
        if rw_craphis2.tpctbcxa = 2 then -- POR CAIXA DEBITO
          vr_linhadet := '50'||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_tab_agencia2(rw_craplci.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(rw_craphis2.nrctacrd))||','||
                         trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"CONTA '||trim(rw_craplci.nrdconta)||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craplci.cdagenci, 'fm000')||','||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          if rw_craphis2.ingercre = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        elsif rw_craphis2.tpctbcxa = 3 then -- POR CAIXA CREDITO
          vr_linhadet := '50'||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(rw_craphis2.nrctadeb))||','||
                         trim(to_char(vr_tab_agencia2(rw_craplci.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"CONTA '||trim(rw_craplci.nrdconta)||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craplci.cdagenci, 'fm000')||','||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          if rw_craphis2.ingerdeb = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        end if;
      else
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(rw_craphis2.nrctacrd))||','||
                       trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CONTA '||trim(rw_craplci.nrdconta)||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 or
           rw_craphis2.ingercre = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
    end loop;
    -- Cria os lancamentos do boletim de caixa  -  Edson
    for rw_craplcx in cr_craplcx (pr_cdcooper,
                                  vr_dtmvtolt) loop
      open cr_craphis2 (pr_cdcooper,
                        rw_craplcx.cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := rw_craplcx.cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      if rw_craphis2.tpctbcxa = 2 then -- POR CAIXA DEBITO
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplcx.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd))||','||
                       trim(to_char(rw_craplcx.vldocmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CX. '||trim(to_char(rw_craplcx.nrdcaixa))||
                       ' ('||trim(to_char(rw_craplcx.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||
                       ' '||trim(substr(rw_craplcx.dsdcompl,1,79))||'"';
        if length(vr_linhadet) > 150 then
          vr_linhadet := substr(vr_linhadet, 1, 149)||'"';
        end if;
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingercre = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        elsif rw_craphis2.ingercre = 3 then
          vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      elsif rw_craphis2.tpctbcxa = 3 then -- POR CAIXA CREDITO
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplcx.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craplcx.vldocmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CX. '||trim(to_char(rw_craplcx.nrdcaixa))||
                       ' ('||trim(to_char(rw_craplcx.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||
                       ' '||trim(substr(rw_craplcx.dsdcompl,1,79))||'"';
        if length(vr_linhadet) > 150 then
          vr_linhadet := substr(vr_linhadet, 1, 149)||'"';
        end if;
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        elsif rw_craphis2.ingercre = 3 then
          vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        --
        vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- Lancamentos dos cashes dispensers  -  Edson
    for rw_crapstf in cr_crapstf (pr_cdcooper,
                                  vr_dtmvtolt) loop
      open cr_craptfn (pr_cdcooper,
                       rw_crapstf.nrterfin);
        fetch cr_craptfn into rw_craptfn;
      close cr_craptfn;
      -- Leitura do log de operacao do dia
      for rw_craplfn in cr_craplfn (pr_cdcooper,
                                    rw_crapstf.dtmvtolt,
                                    rw_crapstf.nrterfin) loop
        open cr_crapope (pr_cdcooper,
                         rw_craplfn.cdoperad);
          fetch cr_crapope into rw_crapope;
        close cr_crapope;
        -- Contabilizacao do SUPRIMENTO DO CASH
        if rw_craplfn.vlsuprim > 0 then
          open cr_craphis2 (pr_cdcooper,
                            705);
            fetch cr_craphis2 into rw_craphis2;
            if cr_craphis2%notfound then
              close cr_craphis2;
              vr_cdcritic := 526;
              vr_dscritic := '705 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
              raise vr_exc_saida;
            end if;
          close cr_craphis2;
          --
          vr_linhadet := '50'||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_tab_agencia2(rw_craptfn.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(rw_craphis2.nrctacrd))||','||
                         trim(to_char(rw_craplfn.vlsuprim, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"CASH '||to_char(rw_craptfn.cdagenci)||
                         '/'||to_char(rw_craptfn.nrterfin)||
                         ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                         ') '||trim(rw_craphis2.dshistor)||
                         ' EFETUADO POR '||rw_crapope.nmoperad||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(rw_craptfn.cdagenci, 'fm000')||','||trim(to_char(rw_craplfn.vlsuprim, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          if rw_craphis2.ingercre = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craplfn.vlsuprim, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        end if;
        -- Contabilizacao do RECOLHIMENTO DO CASH
        if rw_craplfn.vlrecolh > 0 then
          open cr_craphis2 (pr_cdcooper,
                            706);
            fetch cr_craphis2 into rw_craphis2;
            if cr_craphis2%notfound then
              close cr_craphis2;
              vr_cdcritic := 526;
              vr_dscritic := '706 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
              raise vr_exc_saida;
            end if;
          close cr_craphis2;
          --
          vr_linhadet := '50'||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(rw_craphis2.nrctadeb))||','||
                         trim(to_char(vr_tab_agencia2(rw_craptfn.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(rw_craplfn.vlrecolh, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"CASH '||to_char(rw_craptfn.cdagenci)||
                         '/'||to_char(rw_craptfn.nrterfin)||
                         ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                         ') '||trim(rw_craphis2.dshistor)||
                         ' EFETUADO POR '||rw_crapope.nmoperad||'"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          if rw_craphis2.ingerdeb = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craplfn.vlrecolh, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          --
          vr_linhadet := to_char(rw_craptfn.cdagenci, 'fm000')||','||trim(to_char(rw_craplfn.vlrecolh, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end loop;
    end loop;
    -- Contabilizacao da COMP. ELETRONICA ..... (Edson 11/04/2001)..............
    for rw_craplot in cr_craplot (pr_cdcooper,
                                  vr_dtmvtolt) loop
      if rw_craplot.vlcompel <> 0 then
        open cr_crapage2(pr_cdcooper,
                         rw_craplot.cdagenci);
          fetch cr_crapage2 into rw_crapage2;
          if cr_crapage2%notfound then
            close cr_crapage2;
            vr_cdcritic := 962;
            raise vr_exc_saida;
          else
            if rw_crapage2.cdbanchq = 1 then   -- Banco do Brasil
              vr_cdhistor := 731;
            elsif rw_crapage2.cdbanchq = 756 then -- Bancoob
              vr_cdhistor := 547;
            elsif rw_crapage2.cdbanchq = rw_crapcop.cdbcoctl then
              vr_cdhistor := 466;
            end if;
            --
            open cr_craphis2 (pr_cdcooper,
                              vr_cdhistor);
              fetch cr_craphis2 into rw_craphis2;
              if cr_craphis2%notfound then
                close cr_craphis2;
                vr_cdcritic := 526;
                vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
                raise vr_exc_saida;
              end if;
            close cr_craphis2;
          end if;
        close cr_crapage2;
        --
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplot.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craplot.vlcompel, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CX. '||to_char(rw_craplot.nrdcaixa)||
                       ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||
                       ' - '||trim(to_char(rw_craplot.qtcompel, '999G990'))||'"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplot.vlcompel, '999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        --
        vr_linhadet := to_char(rw_craplot.cdagenci, 'fm000')||','||trim(to_char(rw_craplot.vlcompel, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- *****  Incluir lancamento de tarifa para o historico 547  *****
    vr_tab_agencia.delete;
    pc_cria_agencia_pltable(999,NULL);
    -- Incluir nome do módulo logado
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    for rw_craplot in cr_craplot (pr_cdcooper,
                                  vr_dtmvtolt) loop
      if rw_craplot.qtcompel > 0 then
        open cr_crapage2(pr_cdcooper,
                         rw_craplot.cdagenci);
          fetch cr_crapage2 into rw_crapage2;
          if cr_crapage2%notfound then
            close cr_crapage2;
            vr_cdcritic := 962;
            vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic);
            raise vr_exc_saida;
          else
            if rw_crapage2.cdbanchq = 756 then -- Bancoob
              pc_cria_agencia_pltable(rw_craplot.cdagenci,NULL);
              -- Incluir nome do módulo logado
              cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
              vr_tab_agencia(rw_craplot.cdagenci).vr_qttarcmp := vr_tab_agencia(rw_craplot.cdagenci).vr_qttarcmp + rw_craplot.qtcompel;
              vr_tab_agencia(999).vr_qttarcmp := vr_tab_agencia(999).vr_qttarcmp + rw_craplot.qtcompel;
            end if;
            --
          end if;
        close cr_crapage2;
      end if;
    end loop;
    -- Lancamento de Tarifa  -  CHEQUE CAIXA BANCOOB ........................
    if nvl(vr_tab_agencia(999).vr_qttarcmp, 0) > 0 then

      open cr_crapthi(pr_cdcooper,
                      547,
                      'AIMARO');
        fetch cr_crapthi into rw_crapthi;
        if cr_crapthi%notfound then
          close cr_crapthi;
          vr_cdcritic := 1041;
          vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 547 - crapthi';
          raise vr_exc_saida;
        end if;
      close cr_crapthi;
      --
      open cr_craphis2 (pr_cdcooper,
                        547); -- CHEQUE BANCOOB (CAPTURA ELETRONICA)
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := '547 - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      if rw_crapthi.vltarifa > 0 then
        vr_cdestrut := '50';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctatrd))||','||
                       trim(to_char(rw_craphis2.nrctatrc))||','||
                       trim(to_char(rw_crapthi.vltarifa, '999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||' - '||
                       trim(to_char(vr_tab_agencia(999).vr_qttarcmp, '999g990'))||' (tarifa)"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        -- Indice da primeira agencia
        vr_indice_agencia := vr_tab_agencia.first;
        -- Percorrer todas as agencias
        while vr_indice_agencia <= 998 loop
          if vr_tab_agencia(vr_indice_agencia).vr_qttarcmp > 0 then
            vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarcmp * rw_crapthi.vltarifa, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
          vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
        end loop;
      end if;
    end if;
    -- CONTA SALARIO - Recebimento do Credito via Arquivo ......................
    vr_cdhistor := 560;
    vr_vltitulo := 0;
    vr_tab_agencia.delete;
    --
    for rw_craplcs in cr_craplcs (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
      pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
      vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
    end loop;
    --
    if vr_vltitulo > 0 then
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') CREDITO DA FOLHA VIA ARQUIVO - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
          if rw_craphis2.ingercre = 3 or
             rw_craphis2.ingerdeb = 3 then
            vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    -- CONTA SALARIO - Recebimento do Credito via Caixa On-Line ................
    vr_cdhistor := 561;
    --
    for rw_craplcs in cr_craplcs (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
      vr_vltitulo := rw_craplcs.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplcs.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') CREDITO DA FOLHA VIA CAIXA ONLINE - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 3 or
         rw_craphis2.ingerdeb = 3 then
        vr_linhadet := to_char(rw_craplcs.cdagenci, 'fm000')||','||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      elsif rw_craphis2.ingercre = 2 or
            rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- CONTA SALARIO - Rejeção da mensagem de TEC Salário na cabine SPB ......................
    vr_cdhistor := 1755;
    vr_vltitulo := 0;
    vr_tab_agencia.delete;
    --
    for rw_craplcs in cr_craplcs (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
      pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
      vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
    end loop;
    --
    if vr_vltitulo > 0 then
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') REJEICAO/DEVOLUCAO CREDITO DA FOLHA - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
          if rw_craphis2.ingercre = 3 or
             rw_craphis2.ingerdeb = 3 then
            vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;

    -- CONTA SALARIO - Envio de TED para o BAnco do BRAsil................
    vr_cdhistor := 562;
    vr_vltitulo := 0;
    vr_tab_agencia.delete;
    --
    for rw_craplcs in cr_craplcs (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
      pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
      -- Incluir nome do módulo logado
      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
      vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
    end loop;
    --
    if vr_vltitulo > 0 then
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') ENVIO DE TED - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
          if rw_craphis2.ingercre = 3 or
             rw_craphis2.ingerdeb = 3 then
            vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                           trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          end if;
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
    -- CONTA SALARIO - Envio de TED para a nossa IF  ................
    vr_cdhistor := 827;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') ENVIO DE TED - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;

    -- CONTA SALARIO - Re-Envio de TEC rejeitada na cabine do SPB  ................
    vr_cdhistor := 1758;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') RE-ENVIO DE TEC REJEITADA - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;

    -- CONTA SALARIO - Devolucao de TEC Rejeitada na cabine do SPB  ................
    vr_cdhistor := 1937;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') DEVOLUCAO DE TEC REJEITADA - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;

    -- 887 - TEC REJEITADA ................
    vr_cdhistor := 887;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') ENVIO DE TEC - REJEITADA"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- 801 - TEC DEVOLVIDA ................
    vr_cdhistor := 801;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') ENVIO DE TEC - DEVOLVIDA"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- CONTA SALARIO - Transferencia TEC SALARIO entre cooperativas .........
    vr_cdhistor := 1018;
    vr_vltitulo := 0;
    --
    for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor) loop
      vr_vltitulo := rw_craplcs2.vllanmto;
      --
      open cr_craphis2 (pr_cdcooper,
                        vr_cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := vr_cdhistor||' - '||cecred.gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vltitulo, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||vr_cdhistor||') TRANSF. ENTRE COOPERATIVAS - CONTA SALARIO"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 or
         rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||
                       trim(to_char(vr_vltitulo, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
    -- SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA
    vr_cdhistor := 918;
    vr_vllanmto := 0;
    --
    for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) loop
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1452,'||
                     trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(vr_vllanmto, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '(crps249) "SAQUE TAA COMPARTILHADO OUTRA COOP"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                     trim(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;
    -- ESTORNO SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA
    vr_cdhistor := 920;
    vr_vllanmto := 0;
    --
    for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) loop
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                     '1452,'||
                     trim(to_char(vr_vllanmto, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '(crps249) "ESTORNO SAQUE TAA COMPARTILHADO OUTRA COOP"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                     trim(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;

    -- SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA - ATMR
    vr_cdhistor := 3460;
    vr_vllanmto := 0;
    --
    for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) loop
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1452,'||
                     trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(vr_vllanmto, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '(crps249) "SAQUE ATMR COMPARTILHADO OUTRA COOP"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                     trim(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;
    -- ESTORNO SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA - ATMR
    vr_cdhistor := 3461;
    vr_vllanmto := 0;
    --
    for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) loop
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                     '1452,'||
                     trim(to_char(vr_vllanmto, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '(crps249) "ESTORNO SAQUE ATMR COMPARTILHADO OUTRA COOP"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                     trim(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end loop;

   -- DEMETRIUS
   -- SAQUE DE CAPITAL E DEPOSITOS DE COOPERADOS DEMITIDOS
    vr_vllanmto := 0;
    --
    for rw_craplcm in cr_craplcm21 (pr_cdcooper,
                                    vr_dtmvtolt)loop
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      --
      open cr_craphis2 (pr_cdcooper,
                        rw_craplcm.cdhistor);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := rw_craplcm.cdhistor||' - '||cecred.gene0001.fn_busca_critica(526);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      vr_cdestrut := '50';
      case rw_craplcm.cdhistor
        when 2063 then
          vr_complinhadet := '"(2063) SAQUE DEPOSITO CONTA ENCERRADA PF"';
        when 2064 then
          vr_complinhadet := '"(2064) SAQUE DEPOSITO CONTA ENCERRADA PJ"';
        when 2081 then
          vr_complinhadet := '"(2081) SAQUE CAPITAL DISPONIVEL PF"';
        when 2082 then
          vr_complinhadet := '"(2082) SAQUE CAPITAL DISPONIVEL PJ"';
        when 4034 then
          vr_complinhadet := '"(4034) ESTORNO SAQUE CAPITAL DISPONIVEL PF VIA PIX"';
        when 4035 then
          vr_complinhadet := '"(4035) ESTORNO SAQUE CAPITAL DISPONIVEL PJ VIA PIX"';
        when 4036 then
          vr_complinhadet := '"(4036) ESTORNO SAQUE CAPITAL DISPONIVEL SOBRAS PF VIA PIX"';
        when 4037 then
          vr_complinhadet := '"(4037) ESTORNO SAQUE CAPITAL DISPONIVEL SOBRAS PJ VIA PIX"';
        when 4038 then
          vr_complinhadet := '"(4038) ESTORNO SAQUE DEPOSITO CONTA ENCERRADA PF VIA PIX"';
        when 4039 then
          vr_complinhadet := '"(4039) ESTORNO SAQUE DEPOSITO CONTA ENCERRADA PJ VIA PIX"';
        when 4040 then
          vr_complinhadet := '"(4040) ESTORNO SAQUE DEP CONTA ENCER SOBRAS PF VIA PIX"';
        else --4041
          vr_complinhadet := '"(4041) ESTORNO SAQUE DEP CONTA ENCER SOBRAS PJ VIA PIX"';
      end case;
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(vr_vllanmto, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     vr_complinhadet;
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craplcm.cdhistor in (2063,2064,4038,4039,4040,4041) then
        vr_linhadet := to_char(rw_craplcm.cdagenci, 'fm000')||','||
                       trim(to_char(vr_vllanmto, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;

    -- PROVISAO JUROS CHEQUE ESPECIAL
    vr_cdhistor := 38;
    vr_vllanmto := 0;
    OPEN cr_craplcm_tot(pr_cdcooper => pr_cdcooper
                       ,pr_cdhistor => vr_cdhistor
                       ,pr_dtmvtolt => vr_dtmvtolt);

    FETCH cr_craplcm_tot INTO rw_craplcm_tot;

    -- Fecha cursor
    CLOSE cr_craplcm_tot;

    IF rw_craplcm_tot.vllanmto > 0 THEN

    -- Cabecalho
    vr_cdestrut := 50;
    vr_linhadet := trim(vr_cdestrut)||
                   trim(to_char(vr_dtmvtoan,'yymmdd'))||','||
                   trim(to_char(vr_dtmvtoan,'ddmmyy'))||','||
                   '1802,'||
                   '7118,'||
                   TRIM(TO_CHAR(rw_craplcm_tot.vllanmto,'99999999999990.00')) || ',' ||
                     '5210,'||
                   '"(crps249) PROVISAO JUROS CH. ESPECIAL."';

    cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    -- Leitura de lançamentos por PA
    OPEN cr_craplcm8(pr_cdcooper => pr_cdcooper
                    ,pr_cdhistor => vr_cdhistor
                    ,pr_dtmvtolt => vr_dtmvtolt);

    LOOP

      FETCH cr_craplcm8 INTO rw_craplcm8;

      -- Sai do loop quando chegar ao final dos registros da consulta
      EXIT WHEN cr_craplcm8%NOTFOUND;

      -- Escreve valor por PA no arquivo
      -- Colocada condicao pois estava gerando erro no RADAR
      IF rw_craplcm8.vllanmto <> 0 THEN
         cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm8.cdagenci || ',' || TRIM(TO_CHAR(rw_craplcm8.vllanmto,'99999999999990.00')));
      END IF;

    END LOOP;

    -- Fecha cursor
    CLOSE cr_craplcm8;


    -- Inicializando a Pl-Table
    vr_arq_op_cred(14)(999)(1) := 0;
    vr_arq_op_cred(14)(999)(2) := 0;

    -- Separando as informacoes de PROVISAO JUROS CH. ESPECIAL por agencia e tipo de pessoa
    FOR rw_craplcm_age IN cr_craplcm_age(pr_cdcooper => pr_cdcooper
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_dtmvtolt => vr_dtmvtolt) LOOP

       vr_arq_op_cred(14)(rw_craplcm_age.cdagenci)(rw_craplcm_age.inpessoa) := rw_craplcm_age.vllanmto;
       vr_arq_op_cred(14)(999)(rw_craplcm_age.inpessoa) := vr_arq_op_cred(14)(999)(rw_craplcm_age.inpessoa) + rw_craplcm_age.vllanmto;

    END LOOP;

    IF vr_arq_op_cred(14)(999)(1) > 0 THEN
        -- Monta cabacalho - Arq 14 - PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
          vr_linhadet := fn_set_cabecalho('70',vr_dtmvtoan,vr_dtmvtoan,7118,7118,vr_arq_op_cred(14)(999)(1),'"PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA"');
        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                      ,pr_des_text => vr_linhadet); --> Texto para escrita

        /* Deve ser duplicado as linhas separadas por PA */
        pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                    ,pr_inpessoa => 1
                    ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

        pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                    ,pr_inpessoa => 1
                    ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

     END IF;

       IF vr_arq_op_cred(14)(999)(2) > 0 THEN
        -- Monta cabacalho - Arq 14 - PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
          vr_linhadet := fn_set_cabecalho('70',vr_dtmvtoan,vr_dtmvtoan,7118,7704,vr_arq_op_cred(14)(999)(2),'"PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA"');
        cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                      ,pr_des_text => vr_linhadet); --> Texto para escrita

        /* Deve ser duplicado as linhas separadas por PA */
        pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                    ,pr_inpessoa => 2
                    ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

        pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                    ,pr_inpessoa => 2
                    ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
        -- Incluir nome do módulo logado
        cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

     END IF;

     /* RITM0058093 */
     --Histor 38
     vr_agencia_mei.delete;
     vr_total_mei := 0;

     FOR rw_craplcm_age_mei IN cr_craplcm_age_mei(pr_cdcooper => pr_cdcooper
                                                 ,pr_cdhistor => vr_cdhistor
                                                 ,pr_dtmvtolt => vr_dtmvtolt) LOOP
       vr_agencia_mei(rw_craplcm_age_mei.cdagenci) := rw_craplcm_age_mei.vllanmto;
       vr_total_mei := vr_total_mei + rw_craplcm_age_mei.vllanmto;
     END LOOP;

     IF vr_total_mei > 0 THEN
       -- Linha de Cabecalho
       vr_linhadet := fn_set_cabecalho('70'
                                      ,vr_dtmvtoan
                                      ,vr_dtmvtoan
                                      ,7704
                                      ,7702
                                      ,vr_total_mei
                                      ,'"PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA - MEI"');

       cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                     ,pr_des_text => vr_linhadet); --> Texto para escrita

       FOR i IN 1..2 LOOP
         -- escreve a linha duplicada
         vr_index := vr_agencia_mei.FIRST;
         WHILE vr_index IS NOT NULL LOOP
           cecred.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                         ,pr_des_text => LPAD(vr_index,3,0)||','
                                                       ||TRIM(TO_CHAR(vr_agencia_mei(vr_index), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))); --> Texto para escrita

           vr_index := vr_agencia_mei.NEXT(vr_index);
         END LOOP;
       END LOOP;
     END IF;
     /* RITM0058093 */
    END IF;
    -- LIBERACAO CONTRATO DE FINAME BNDES"
    vr_cdhistor := 1529;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) LOOP

      -- 50141211,111214,1632,4451,34000000.00,5210,"LIBERACAO CONTRATO DE FINAME BNDES"
      -- 999,34000000.00
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1432,'||
                     '4451,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"LIBERACAO CONTRATO DE FINAME BNDES"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      --vr_linhadet := '999,'||
      --               TRIM(to_char(vr_vllanmto, '999999990.00'));
      --cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;

    -- ESTORNO LIBERACAO CONTRATO DE FINAME BNDES
    vr_cdhistor := 1530;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) LOOP

      -- 50141211,111214,4451,1632,15000000.00,5210,"ESTORNO LIBERACAO CONTRATO DE FINAME BNDES"
      -- 999,15000000.00
      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4451,'||
                     '1432,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"ESTORNO LIBERACAO CONTRATO DE FINAME BNDES"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      --vr_linhadet := '999,'||
      --               TRIM(to_char(vr_vllanmto, '999999990.00'));
      --cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;


    -- JUROS SOBRE CONTRATO DE FINAME BNDES
    vr_cdhistor := 1531;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) LOOP

      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1432,'||
                     '1631,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"JUROS SOBRE CONTRATO DE FINAME BNDES"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --Gerencial
      vr_linhadet := '999,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;

    -- ESTORNO DE JUROS SOBRE CONTRATO DE FINAME BNDES
    vr_cdhistor := 1532;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) LOOP

      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1631,'||
                     '1432,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"ESTORNO DE JUROS SOBRE CONTRATO DE FINAME BNDES"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --Gerencial
      vr_linhadet := '999,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;


    -- PAGAMENTO PARCELA FINAME
    vr_cdhistor := 1806;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor) LOOP

      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1631,'||
                     '1432,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"Ajuste ref. PAGAMENTO PARCELA DE VALOR PRINCIPAL - FINAME BNDES"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --Gerencial
      vr_linhadet := '001,'||
                    TRIM(to_char(vr_vllanmto, '999999990.00'));
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;

    -- AJUSTE IOF FINAME CENTRAL
    IF pr_cdcooper = 3 THEN
      vr_cdhistor := 2323;
      vr_vllanmto := 0;
      --
      FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                     vr_dtmvtolt,
                                     vr_cdhistor) LOOP

        vr_vllanmto := rw_craplcm.vllanmto;
        --
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                       TRIM(vr_dtmvtolt_yymmdd)||','||
                       TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4532,'||
                       '7281,'||
                       TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                       '5210,'||
                       '"AJUSTE REF. (2323) IOF S/ CONTA CORRENTE (PRINCIPAL E ADICIONAL) LANCADO INDEVIDAMENTE PELO SISTEMA AIMARO"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --Gerencial
        vr_linhadet := '999,'||
                      TRIM(to_char(vr_vllanmto, '999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END LOOP;
    END IF;

    /*Novos historicos de repasses de Pequenas Empresas do repassador BNDES PRJ0024210*/
    IF pr_cdcooper <> 3 THEN

      vr_vllanmto  := 0;

      /* HISTORICO 3999 REPLICAR PARA FILIADA OS LANCAMENTOS PARA A CENTRAL*/
      OPEN cr_bndes_peqemp (pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => vr_dtmvtolt,
                        pr_tpmovcontabil => 1);
      FETCH cr_bndes_peqemp INTO rw_bndes_peqemp;

      IF cr_bndes_peqemp%FOUND THEN
        vr_vllanmto := rw_bndes_peqemp.vllanmto;

        vr_cdestrut := '50';
        vr_linhadet :=  TRIM(vr_cdestrut)||
                        TRIM(vr_dtmvtolt_yymmdd)||','||
                        TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '1452,'||
                        '4835,'||
                        TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                        '5210,'||
                        '"REPASSE DE BNDES PEQUENAS EMPRESAS"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;

      CLOSE cr_bndes_peqemp;

      /* HISTORICO 4001,4005,4006 REPLICAR PARA FILIADA OS LANCAMENTOS PARA A CENTRAL*/
      OPEN cr_bndes_peqemp (pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => vr_dtmvtolt,
                        pr_tpmovcontabil => 2);
      FETCH cr_bndes_peqemp INTO rw_bndes_peqemp;

      IF cr_bndes_peqemp%FOUND THEN
        vr_vllanmto := rw_bndes_peqemp.vllanmto;

        vr_cdestrut := '50';
        vr_linhadet :=  TRIM(vr_cdestrut)||
                        TRIM(vr_dtmvtolt_yymmdd)||','||
                        TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '4835,'||
                        '1452,'||
                        TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                        '5210,'||
                        '"PAGAMENTO DE OPERACAO DE REPASSE BNDES PEQUENAS EMPRESAS"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;

      CLOSE cr_bndes_peqemp;

      /* HISTORICO 4009,4010,4011 REPLICAR PARA FILIADA OS LANCAMENTOS PARA A CENTRAL*/
      OPEN cr_bndes_peqemp (pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => vr_dtmvtolt,
                        pr_tpmovcontabil => 3);
      FETCH cr_bndes_peqemp INTO rw_bndes_peqemp;

      IF cr_bndes_peqemp%FOUND THEN
        vr_vllanmto := rw_bndes_peqemp.vllanmto;

        vr_cdestrut := '50';
        vr_linhadet :=  TRIM(vr_cdestrut)||
                        TRIM(vr_dtmvtolt_yymmdd)||','||
                        TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                        '1452,'||
                        '4835,'||
                        TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                        '5210,'||
                        '"ESTORNO DE PGTO DE REPASSE BNDES PEQUENAS EMPRESAS"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;

      CLOSE cr_bndes_peqemp;

    END IF;

    -- Melhoria 324 - Contas de Compensação - Transferencia para prejuizo - Jean (Mout´S) 10/08/2017
     -- Transferencia para prejuizo Emprestimos PP
    vr_cdhistor := 2381;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   1) LOOP -- Emprestimo

      vr_vllanmto := rw_craplcm.vllanmto;
      --

     END LOOP;

    vr_cdhistor := 2385;

    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo

      vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
      --

     END LOOP;

     if nvl(vr_vllanmto,0) > 0  then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Emprestimo PP"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

     end if;
     --
     -- ESTORNO TRANSFERENCIA PREJUIZO - Emprestimo PP
     -- 2383 - EST. PREJUIZO TR
    vr_cdhistor := 2383;
    vr_vllanmto := 0;
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   1) LOOP -- Emprestimo

      vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
    END LOOP;

    if nvl(vr_vllanmto,0) > 0  then
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9261,'||
                     '3962,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno Transferencia Prejuizo - Emprestimo PP "';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

     END IF;

    -- Transferencia para prejuizo Emprestimo PP  - Juros + 60
    vr_cdhistor := 2382;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   1) LOOP -- Emprestimo

      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3866,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Juros + 60 (Emp PP)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END LOOP;
     --
     -- ESTORNO TRANSFERENCIA PREJUIZO - Juros + 60 (Emp PP)
     vr_cdhistor := 2384;
     vr_vllanmto := 0;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                    1) LOOP -- Emprestimo

       vr_vllanmto := rw_craplcm.vllanmto;
        --
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                      TRIM(vr_dtmvtolt_yymmdd)||','||
                      TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                      '3866,'||
                       '3962,'||
                      TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                      '5210,'||
                      '"(crps249) Estorno Transferencia Prejuizo - Juros + 60 (Emp PP)"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END LOOP;

    -- Transferencia para prejuizo Emprestimo TR
    vr_cdhistor := 2401;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo

      vr_vllanmto := rw_craplcm.vllanmto;
      --

     END LOOP;


    vr_cdhistor := 2405;

    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo

      vr_vllanmto := vr_vllanmto +  rw_craplcm.vllanmto;
      --

     END LOOP;

     if nvl(vr_vllanmto ,0 ) > 0 then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Emprestimo TR"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;

     /*PJ298.2.2 - POS*/
     -- Transferencia para prejuizo Emprestimo POS
     vr_cdhistor := 2878;
     vr_vllanmto := 0;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                    0) LOOP -- Emprestimo
       vr_vllanmto := rw_craplcm.vllanmto;
       --
     END LOOP;

     vr_cdhistor := 2884;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                    0) LOOP -- Emprestimo
       vr_vllanmto := vr_vllanmto +  rw_craplcm.vllanmto;
       --
     END LOOP;

     if nvl(vr_vllanmto ,0 ) > 0 then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Emprestimo POS"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;
     /*PJ298.2.2 - POS*/

     --
     -- ESTORNO TRANSFERENCIA PREJUIZO - Emprestimo TR
     --
     vr_cdhistor := 2403;
     vr_vllanmto := 0;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                    0) LOOP -- Emprestimo

       vr_vllanmto := vr_vllanmto +  rw_craplcm.vllanmto;
       --

      END LOOP;

      if nvl(vr_vllanmto ,0 ) > 0 then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9261,'||
                     '3962,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno Transferencia Prejuizo - Emprestimo TR"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    --
    -- Transferencia para prejuizo Emprestimo TR - Juros + 60
    vr_cdhistor := 2402;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo/Fin TR

      vr_vllanmto := rw_craplcm.vllanmto;
      --

     END LOOP;

     vr_cdhistor := 2406;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                   0) LOOP -- Emprestimo/Fin TR

       vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
       --

     END LOOP;

    if nvl(vr_vllanmto,0) >0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3866,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Juros + 60 (TR)"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --

    -- ESTORNO TRANSFERENCIA PREJUIZO - Juros + 60 (TR)
    vr_cdhistor := 2404;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo/Fin TR

      vr_vllanmto := rw_craplcm.vllanmto;
      --

     END LOOP;

     vr_cdhistor := 2407;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                    vr_dtmvtolt,
                                    vr_cdhistor,
                                   0) LOOP -- Emprestimo/Fin TR

       vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
       --

     END LOOP;

    if nvl(vr_vllanmto,0) >0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3866,'||
                     '3962,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno Transferencia Prejuizo - Juros + 60 (TR))"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
     --Rangel Decker
     open cr_principal (pr_cdcooper,
                      vr_dtmvtolt);
      fetch cr_principal into rw_principal;
      -- Se não encontrar
      if cr_principal%notfound then
        close cr_principal;
        RETURN; -- Retorna
      else
       vr_vllanmto := vr_vllanmto + rw_principal.vllanmto;
      end if;
      close cr_principal;


     if nvl(vr_vllanmto,0) > 0  then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

     end if;

   vr_vllanmto := 0;

   open cr_juros60 (pr_cdcooper,
                      vr_dtmvtolt);

      fetch cr_juros60 into rw_juros60;
      -- Se não encontrar
      if cr_juros60%notfound then
        close cr_juros60;
        RETURN; -- Retorna
      else
       vr_vllanmto := vr_vllanmto + rw_juros60.vllanmto;
      end if;
      close cr_juros60;


     if nvl(vr_vllanmto,0) > 0  then
        vr_cdestrut := '50';
        vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3866,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO JUROS +60 C/C P/ PREJUIZO"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

     end if;


     -- Transferencia para prejuizo Financiamento PP
    vr_cdhistor := 2396;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento

      vr_vllanmto := rw_craplcm.vllanmto;
      --
    END LOOP;

    vr_cdhistor := 2400;
   -- vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento

      vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
      --

     END LOOP;

    if nvl(vr_vllanmto ,0 ) > 0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Financiamento PP"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;
    --

    -- PJ298.2.2 - POS
    -- Transferencia para prejuizo Financiamento PP
    vr_cdhistor := 2885;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento
      vr_vllanmto := rw_craplcm.vllanmto;
    END LOOP;

    vr_cdhistor := 2888;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento
      vr_vllanmto := vr_vllanmto + rw_craplcm.vllanmto;
    END LOOP;

    if nvl(vr_vllanmto ,0 ) > 0 then
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Financiamento POS"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- PJ298.2.2 - POS

    -- ESTORNO TRANSFERENCIA PREJUIZO - Financiamento PP
    vr_cdhistor := 2398;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento

      vr_vllanmto := rw_craplcm.vllanmto;
      --
    END LOOP;

    if nvl(vr_vllanmto ,0 ) > 0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9261,'||
                     '3962,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno Transferencia Prejuizo - Financiamento PP"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;

    -- Transferencia para prejuizo Emprestimo PP  - Juros + 60
    vr_cdhistor := 2397;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   2) LOOP -- Emprestimo

      vr_vllanmto := rw_craplcm.vllanmto;
      --
      vr_cdestrut := '50';
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3866,'||
                     TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Juros + 60 (Fin PP)"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END LOOP;
     --
     -- Estorno Transferencia Prejuizo - Juros + 60 (Fin PP)
     --
     vr_cdhistor := 2399;
     vr_vllanmto := 0;
     --
     FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Emprestimo

       vr_vllanmto := rw_craplcm.vllanmto;
       --
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                      TRIM(vr_dtmvtolt_yymmdd)||','||
                      TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                      '3866,'||
                      '3962,'||
                      TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                      '5210,'||
                      '"(crps249) Estorno Transferencia Prejuizo - Juros + 60 (Fin PP)"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END LOOP;

     -- Transferencia para prejuizo Financiamento TR
    vr_cdhistor := 2408;
    vr_vllanmto := 0;
    --
  /*  FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento*/
    FOR rw_craplcm_prej IN cr_craplcm_prej (pr_cdcooper,
                                            vr_dtmvtolt,
                                            vr_cdhistor) LOOP

      vr_vllanmto := rw_craplcm_prej.vllanmto;
      --

    END LOOP;


    vr_cdhistor := 2412;
   -- vr_vllanmto := 0;
    --
   /* FOR rw_craplcm IN cr_craplem2 (pr_cdcooper,
                                   vr_dtmvtolt,
                                   vr_cdhistor,
                                   0) LOOP -- Financiamento*/
    FOR rw_craplcm_prej IN cr_craplcm_prej (pr_cdcooper,
                                            vr_dtmvtolt,
                                            vr_cdhistor) LOOP

      vr_vllanmto := vr_vllanmto + rw_craplcm_prej.vllanmto;
      --

    END LOOP;
    vr_vllanmto := abs(vr_vllanmto);


    if nvl(vr_vllanmto,0) > 0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Conta Corrente"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;

    --> PAGAMENTO DE PREJUIZO
    vr_cdhistor := 384;
    vr_vllanmto := 0;
    vr_val_age_gen.delete;
    --
    FOR rw_tbprejuizo_det IN cr_tbprejuizo_det (pr_cdcooper => pr_cdcooper,
                                                pr_dtmvtolt => vr_dtmvtolt,
                                                pr_cdhistor => vr_cdhistor) LOOP -- Financiamento

      vr_vllanmto := vr_vllanmto + rw_tbprejuizo_det.vllanmto;
      --
      vr_idx_age_2 := rw_tbprejuizo_det.cdagenci;
      vr_val_age_gen(vr_idx_age_2).cdagenci := lpad(rw_tbprejuizo_det.cdagenci,3,0);
      vr_val_age_gen(vr_idx_age_2).vllamnto := nvl(vr_val_age_gen(vr_idx_age_2).vllamnto,0) + rw_tbprejuizo_det.vllanmto;
      vr_val_age_gen(vr_idx_age_2).qtlanmto := nvl(vr_val_age_gen(vr_idx_age_2).qtlanmto,0) + rw_tbprejuizo_det.qtlanmto;

     END LOOP;
    vr_vllanmto := abs(vr_vllanmto);


    IF nvl(vr_vllanmto,0) > 0 THEN

       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4112,'||
                     '7195,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) COMPLEMENTO HIST (0384) PAGAMENTO PREJUIZO - CONTA CORRENTE EM PREJUIZO"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

       vr_linhadet := '999,' || TRIM(to_char(vr_vllanmto, '999999990.00'));
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

     END IF;

     vr_idx_age_2 := vr_val_age_gen.first;
     WHILE vr_idx_age_2 IS NOT NULL LOOP

       vr_linhadet := to_char(vr_val_age_gen(vr_idx_age_2).cdagenci,'fm000')||',' ||
                      TRIM(to_char(vr_val_age_gen(vr_idx_age_2).vllamnto, '999999990.00'));
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

       vr_idx_age_2 := vr_val_age_gen.next(vr_idx_age_2);
     END LOOP;

     --> Fim PAGAMENTO DE PREJUIZO

     --> Inicio TRANSFERENCIA / PAGAMENTO / ESTORNO PREJUIZO DESCONTO DE TITULOS
     -- Transferencia para prejuizo desconto de titulo principal
     vr_cdhistor := PREJ0005.vr_cdhistordsct_principal; --2754
     vr_vllanmto := 0;
     --
     FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero (pr_cdcooper,
                                             vr_dtmvtolt,
                                             vr_cdhistor) LOOP
       vr_vllanmto := vr_vllanmto + rw_tbdsct_lancamento_bordero.vllanmto;
       --
     END LOOP;

     IF nvl(vr_vllanmto,0) > 0 THEN
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Desconto de Titulo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END IF;

     -- Transferencia para prejuizo desconto de titulo juros +60
     vr_vllanmto := 0;
     vr_cdhistor := PREJ0005.vr_cdhistordsct_juros_60_rem; --2755 +60 apropriacao
     --
     FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero (pr_cdcooper,
                                             vr_dtmvtolt,
                                             vr_cdhistor) LOOP
       vr_vllanmto := vr_vllanmto + rw_tbdsct_lancamento_bordero.vllanmto;
       --
     END LOOP;

     IF nvl(vr_vllanmto,0) > 0 THEN
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '9261,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Transferencia Prejuizo - Desconto de Titulo - Juros + 60"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END IF;

     -- Pagamento prejuizo desconto de titulo principal
     vr_cdhistor := PREJ0005.vr_cdhistordsct_rec_preju; -- 2876 equivalente ao histórico 2386 da lcm
     vr_vllanmto := 0;
     --
     FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero (pr_cdcooper,
                                             vr_dtmvtolt,
                                             vr_cdhistor) LOOP
       vr_vllanmto := vr_vllanmto + rw_tbdsct_lancamento_bordero.vllanmto;
       --
     END LOOP;

     IF nvl(vr_vllanmto,0) > 0 THEN
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3865,'||
                     '3962,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Pagamento Prejuizo Principal - Desconto de Titulo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END IF;

     -- Estorno do pagamento prejuizo desconto de titulo principal
     vr_cdhistor := PREJ0005.vr_cdhistordsct_est_preju; -- 2877 equivalente ao histórico 2387 da lcm
     vr_vllanmto := 0;
     --
     FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero (pr_cdcooper,
                                             vr_dtmvtolt,
                                             vr_cdhistor) LOOP
       vr_vllanmto := vr_vllanmto + rw_tbdsct_lancamento_bordero.vllanmto;
       --
     END LOOP;

     IF nvl(vr_vllanmto,0) > 0 THEN
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3865,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno de Pagamento Prejuizo - Desconto de Titulo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END IF;
     --> Fim TRANSFERENCIA / PAGAMENTO / ESTORNO PREJUIZO DESCONTO DE TITULOS

   /*vr_cdhistor := 2386;
    vr_vllanmto := 0;
    --
    FOR rw_craplcm_prej IN cr_craplcm_prej (pr_cdcooper,
                                            vr_dtmvtolt,
                                            vr_cdhistor) LOOP -- Financiamento

      vr_vllanmto := vr_vllanmto + rw_craplcm_prej.vllanmto;
      --

     END LOOP;
    vr_vllanmto := abs(vr_vllanmto);


    if nvl(vr_vllanmto,0) > 0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3865,'||
                     '3962,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Pagamento Prejuizo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;
     */

    --> contabilizar a partir da lem, pois em caso de prejuizo de CC não haverá lanc na conta
    vr_cdhistor := 2701;
     vr_vllanmto := 0;
     --
    FOR rw_craplcm_prej IN cr_craplem2 (pr_cdcooper,
                                             vr_dtmvtolt,
                                        vr_cdhistor,
                                        0) LOOP

      vr_vllanmto := vr_vllanmto + rw_craplcm_prej.vllanmto;
      --

     END LOOP;
    vr_vllanmto := abs(vr_vllanmto);


    if nvl(vr_vllanmto,0) > 0 then
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3865,'||
                     '3962,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Pagamento Prejuizo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     end if;

     --> contabilizar a partir da lem, pois em caso de prejuizo de CC não haverá lanc na conta
     vr_cdhistor := 2702;
     vr_vllanmto := 0;
     --
     FOR rw_craplcm_prej IN cr_craplem2 (pr_cdcooper,
                                         vr_dtmvtolt,
                                         vr_cdhistor,
                                         0) LOOP -- Financiamento

       vr_vllanmto := vr_vllanmto + rw_craplcm_prej.vllanmto;
       --
     END LOOP;
     vr_vllanmto := abs(vr_vllanmto);
     IF nvl(vr_vllanmto,0) > 0 THEN
       vr_cdestrut := '50';
       vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3962,'||
                     '3865,'||
                     TRIM(to_char(abs(vr_vllanmto), '999999990.00'))||','||
                     '5210,'||
                     '"(crps249) Estorno de Pagamento Prejuizo"';
       cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     END IF;

    --  Fim da contabilizacao da COMP. ELETRONICA ...............................

    -- RECEITA RECARGA DE CELULAR ..............................................

    FOR inpes IN 1..2 LOOP
    FOR rw_operadora IN cr_operadora(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_inpessoa => inpes) LOOP

        IF rw_operadora.vl_receita > 0 THEN

          vr_index := rw_operadora.cdoperadora;

          if vr_tab_recarga_cel_ope.exists(vr_index) then
             vr_tab_recarga_cel_ope(vr_index).vlreceita :=  vr_tab_recarga_cel_ope(vr_index).vlreceita +  rw_operadora.vl_receita;
          else
             vr_tab_recarga_cel_ope(vr_index).vlreceita :=  rw_operadora.vl_receita;
             vr_tab_recarga_cel_ope(vr_index).nmoperadora := rw_operadora.nmoperadora;
          end if;

          if rw_operadora.inpessoa = 1 then
            vr_receita_cel_pf := nvl(vr_receita_cel_pf,0) + rw_operadora.vl_receita;
          else
            vr_receita_cel_pj := nvl(vr_receita_cel_pj,0) + rw_operadora.vl_receita;
          end if;

        END IF;

      END LOOP;
    END LOOP;

    --

    vr_chave := vr_tab_recarga_cel_ope.first;
    WHILE vr_chave IS NOT NULL LOOP

        /* Linha 1 - Cabecalho*/
        vr_cdestrut := '55';
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '4340,'||
                       '7543,'||
                      trim(to_char(vr_tab_recarga_cel_ope(vr_chave).vlreceita, '999999990.00'))||','||
                       '5210,'||
                       '"(crps249) RECEITA RECARGA DE CELULAR - ' ||
                      vr_tab_recarga_cel_ope(vr_chave).nmoperadora || '"';

      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      --
      --Gera gerencial por operadora
      FOR rw_operadora in cr_operadora(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_inpessoa => 0) LOOP

        IF rw_operadora.cdoperadora = vr_chave THEN
          vr_linhadet := to_char(rw_operadora.cdagenci, 'fm000')|| ',' ||
                         trim(to_char(rw_operadora.vl_receita,'999999990.00'));

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

        --
      END LOOP;

      vr_chave := vr_tab_recarga_cel_ope.next(vr_chave);
      --
    END LOOP;

    vr_chave    := NULL;
    --
    IF vr_receita_cel_pf > 0 THEN

      /* Linha 1 - Cabecalho*/

      vr_cdestrut := '55';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '7543,'||
                     '7543,'||
                     trim(to_char(vr_receita_cel_pf, '999999990.00'))||','||
                     '5210,'||
                     '"RECEITA RECARGA DE CELULAR - PESSOA FISICA"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      FOR I IN 1..2 LOOP

        FOR rw_recargas in cr_recargas(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => vr_dtmvtolt
                                         ,pr_inpessoa => 1) LOOP

            vr_linhadet := to_char(rw_recargas.cdagenci, 'fm000')|| ',' ||
                           trim(to_char(rw_recargas.vl_receita,'999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        END LOOP;
        END LOOP;

      END IF;
    --
    IF vr_receita_cel_pj > 0 THEN

      /* Linha 1 - Cabecalho*/
      vr_cdestrut := '55';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '7543,'||
                     '7543,'||
                     trim(to_char(vr_receita_cel_pj, '999999990.00'))||','||
                     '5210,'||
                     '"RECEITA RECARGA DE CELULAR - PESSOA JURIDICA"';
      cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      FOR I IN 1..2 LOOP

        FOR rw_recargas in cr_recargas(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_inpessoa => 2) LOOP

            vr_linhadet := to_char(rw_recargas.cdagenci, 'fm000')|| ',' ||
                           trim(to_char(rw_recargas.vl_receita,'999999990.00'));
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        END LOOP;

    END LOOP;

    END IF;
    -- Fim RECEITA RECARGA DE CELULAR ...........................................

    --
    IF pr_cdcooper = 3 THEN
      --
      OPEN cr_finieptb(pr_cdcooper
                      ,vr_dtmvtolt
                      );
      --
      LOOP
        --
        FETCH cr_finieptb INTO rw_finieptb;
        EXIT WHEN cr_finieptb%NOTFOUND;
        --
        CASE
          WHEN rw_finieptb.cdhistor = 2622 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (1425)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (4887)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) LIQUIDAÇÃO DE BOLETO EM CARTORIO"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_finieptb.cdhistor = 2663 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (?)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (?)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) DEVOLUCAO LIQUIDACAO BOLETO EM CART. TED REM. STR"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_finieptb.cdhistor = 2734 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (?)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (?)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) DEVOLUCAO RECEBIDAS. TED REM. STR"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --

          WHEN rw_finieptb.cdhistor = 2642 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (4888)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (1425)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) PAGAMENTO DE CUSTAS E DESPESAS CARTORARIAS"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_finieptb.cdhistor = 2646 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (4889)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (1425)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) PAGAMENTO DE TARIFA IEPTB - PROTESTO DE TITULO"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_finieptb.cdhistor = 2917 THEN -- liq de boleto em cartorio via DOC
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (1423)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (4887)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) LIQUIDACAO DE BOLETO EM CARTORIO - VIA DOC"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
                  WHEN rw_finieptb.cdhistor = 3005 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (4957)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (4887)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) LIQUIDAÇÃO DE BOLETO EM CARTORIO - VIA TRANSFERENCIA"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_finieptb.cdhistor = 3007 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           to_char(rw_finieptb.nrctadeb) || ',' || -- (4887)
                           to_char(rw_finieptb.nrctacrd) || ',' || -- (4957)
                           TRIM(to_char(nvl(rw_finieptb.vllanmto, 0),'fm99999999999990.00')) || ',' ||
                           to_char(rw_finieptb.cdhstctb) || ',' ||
                           '"(crps249) DEVOLUÇÃO LIQUIDAÇÃO DE BOLETO EM CARTORIO - VIA TRANSFERENCIA"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
        END CASE;
        --
      END LOOP;
      --
      CLOSE cr_finieptb;
      --

      /* Incluido ajuste provisao mensal historico 38 */
      IF to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') THEN
        FOR rw_prov_mes_38 IN cr_prov_mes_38(pr_cdcooper
                                            ,to_date('01'||to_char(vr_dtmvtolt,'MMRRRR'),'DDMMRRRR')
                                            ,vr_dtultdia) LOOP
          vr_cdestrut := 50;
          vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd) || ',' ||
                         trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                         '1802,' ||
                         '7281,' ||
                           TRIM(to_char(nvl(rw_prov_mes_38.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                         '5210,' ||
                         '"(crps249) PROVISAO JUROS CHEQUE ESPECIAL"';
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END LOOP;
      END IF;
      /* Fim provisao mensal historico 38 */
      --
    ELSE -- pr_cdcooper <> 3 (todas as cooperativas diferente da central)
      --
      OPEN cr_lanipetb(pr_cdcooper
                      ,vr_dtmvtolt
                      );
      --
      LOOP
        --
        FETCH cr_lanipetb INTO rw_lanipetb;
        EXIT WHEN cr_lanipetb%NOTFOUND;
        --
        CASE
          WHEN rw_lanipetb.cdhistor = 2635 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '4888,' ||
                           '1455,' ||
                           TRIM(to_char(nvl(rw_lanipetb.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) REPASSE DE CUSTAS E DESPESAS CARTORARIAS"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_lanipetb.cdhistor = 2637 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '4888,' ||
                           '1455,' ||
                           TRIM(to_char(nvl(rw_lanipetb.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) REPASSE MANUAL DE CUSTAS E DESPESAS CARTORARIAS"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_lanipetb.cdhistor = 2639 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '1455,' ||
                           '4888,' ||
                           TRIM(to_char(nvl(rw_lanipetb.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) ESTORNO DE REPASSE DE CUSTAS E DESPESAS CARTORARIAS"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
        END CASE;
        --
      END LOOP;
      --
      CLOSE cr_lanipetb;
      --
      OPEN cr_lanipetb2(pr_cdcooper
                       ,vr_dtmvtolt
                      );
      --
      vr_isFirst := TRUE;
      --
      LOOP
        --
        FETCH cr_lanipetb2 INTO rw_lanipetb2;
        EXIT WHEN cr_lanipetb2%NOTFOUND;
        --
        IF vr_isFirst THEN
          --
        vr_cdestrut := 50;
        vr_linhadet := trim(vr_cdestrut) ||
                       trim(vr_dtmvtolt_yymmdd) || ',' ||
                       trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                       '8125,' ||
                       '1455,' ||
                         TRIM(to_char(nvl(rw_lanipetb2.vltarifa_ieptb_total, 0), 'fm99999999999990.00')) || ',' ||
                       '5210,' ||
                       '"(crps249) REPASSE DE TARIFA IEPTB - PROTESTO TITULO"';
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
          vr_isFirst := FALSE;
          --
        END IF;
        --
        vr_linhadet := lpad(rw_lanipetb2.cdagenci, 3, '0' ) || ',' ||
                       TRIM(to_char(nvl(rw_lanipetb2.vltarifa_ieptb, 0), 'fm99999999999990.00'));
        --
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
      END LOOP;
      CLOSE cr_lanipetb2;

      OPEN cr_lanpronampe(pr_cdcooper
                      ,vr_dtmvtolt
                      );
      --
      LOOP
        --
        FETCH cr_lanpronampe INTO rw_lanpronampe;
        EXIT WHEN cr_lanpronampe%NOTFOUND;
        --
        CASE
          WHEN rw_lanpronampe.cdhistor = 3786 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '1452,' ||
                           '4877,' ||
                           TRIM(to_char(nvl(rw_lanpronampe.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) VALOR REF. CREDITO FUNDO GARANTIDOR - HONRA OPERACOES DE PRONAMPE"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
          WHEN rw_lanpronampe.cdhistor = 3777 THEN
            --
            vr_cdestrut := 50;
            vr_linhadet := trim(vr_cdestrut) ||
                           trim(vr_dtmvtolt_yymmdd) || ',' ||
                           trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '4877,' ||
                           '1452,' ||
                           TRIM(to_char(nvl(rw_lanpronampe.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) VALOR REF. PAGAMENTO DE OPERACAO HONRADA PELO FUNDO GARANTIDOR DO PRONAMPE - FGO"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            --
        END CASE;
        --
      END LOOP;
      --
      CLOSE cr_lanpronampe;

      OPEN cr_lanpeac(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => vr_dtmvtolt);
      LOOP
        FETCH cr_lanpeac
          INTO rw_lanpeac;
        EXIT WHEN cr_lanpeac%NOTFOUND;

        CASE
          WHEN rw_lanpeac.cdhistor = 3908 THEN
            vr_cdestrut := 50;
            vr_linhadet := TRIM(vr_cdestrut) ||
                           TRIM(vr_dtmvtolt_yymmdd) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '1452,' ||
                           '4875,' ||
                           TRIM(to_char(nvl(rw_lanpeac.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) VALOR REF. CREDITO FUNDO GARANTIDOR - HONRA OPERACOES DE PEAC"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          WHEN rw_lanpeac.cdhistor = 3909 THEN
            vr_cdestrut := 50;
            vr_linhadet := TRIM(vr_cdestrut) ||
                           TRIM(vr_dtmvtolt_yymmdd) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                           '4875,' ||
                           '1452,' ||
                           TRIM(to_char(nvl(rw_lanpeac.vllanmto, 0), 'fm99999999999990.00')) || ',' ||
                           '5210,' ||
                           '"(crps249) VALOR REF. PAGAMENTO DE OPERACAO HONRADA PELO FUNDO GARANTIDOR DO PEAC - FGI"';
            cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END CASE;
      END LOOP;
      CLOSE cr_lanpeac;

    END IF;

    /* PRJ0023580 - Lancamentos bloqueio PIX */
    --Somente na virada mensal
    IF to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') THEN
      for rw_bloqueio_pix in cr_bloqueio_pix(pr_cdcooper) loop
        vr_tab_bloqueio_pix(rw_bloqueio_pix.inpessoa||rw_bloqueio_pix.cdagenci).inpessoa := rw_bloqueio_pix.inpessoa;
        vr_tab_bloqueio_pix(rw_bloqueio_pix.inpessoa||rw_bloqueio_pix.cdagenci).cdagenci := rw_bloqueio_pix.cdagenci;
        vr_tab_bloqueio_pix(rw_bloqueio_pix.inpessoa||rw_bloqueio_pix.cdagenci).vlbloqueado := rw_bloqueio_pix.vlbloqueado;
        vr_tab_bloqueio_pix(rw_bloqueio_pix.inpessoa||rw_bloqueio_pix.cdagenci).vltotal := rw_bloqueio_pix.vltotal;
        vr_tab_bloqueio_pix(rw_bloqueio_pix.inpessoa||rw_bloqueio_pix.cdagenci).row_number := rw_bloqueio_pix.row_number;
      end loop;

      --LANCAMENTO
      vr_index_bloqueio_pix := vr_tab_bloqueio_pix.first;

      while vr_index_bloqueio_pix is not null loop
        if vr_tab_bloqueio_pix(vr_index_bloqueio_pix).row_number = 1 AND
           nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0) > 0 THEN
          vr_cdestrut := 99;
          vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd) || ',' ||
                         trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                         case when vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa = 'PF' then '4107,' else '4108,' end ||
                         ',' ||
                         TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00')) || ',' ||
                         '5210,' ||
                         '"(crps249) RATEIO BLOQUEIO PIX - '||vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_linhadet := lpad(999, 3, '0' ) || ',' ||TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd) || ',' ||
                         trim(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' ||
                         ',' ||
                         case when vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa = 'PF' then '4107,' else '4108,' end ||
                         TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00')) || ',' ||
                         '5210,' ||
                         '"(crps249) RATEIO BLOQUEIO PIX - '||vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        END IF;

        vr_linhadet := lpad(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).cdagenci, 3, '0' ) || ',' ||TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vlbloqueado, 0), 'fm99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        vr_index_bloqueio_pix := vr_tab_bloqueio_pix.next(vr_index_bloqueio_pix);
      end loop;

      --REVERSAO
      vr_index_bloqueio_pix := vr_tab_bloqueio_pix.first;

      while vr_index_bloqueio_pix is not null loop
        if vr_tab_bloqueio_pix(vr_index_bloqueio_pix).row_number = 1 AND
           nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0) > 0 THEN
          vr_cdestrut := 99;
          vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd) || ',' ||
                         trim(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                         ',' ||
                         case when vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa = 'PF' then '4107,' else '4108,' end ||
                         TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00')) || ',' ||
                         '5210,' ||
                         '"(crps249) REVERSAO RATEIO BLOQUEIO PIX - '||vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_linhadet := lpad(999, 3, '0' ) || ',' ||TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00'));
          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          vr_linhadet := trim(vr_cdestrut) ||
                         trim(vr_dtmvtolt_yymmdd) || ',' ||
                         trim(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                         case when vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa = 'PF' then '4107,' else '4108,' end ||
                         ',' ||
                         TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vltotal, 0), 'fm99999999999990.00')) || ',' ||
                         '5210,' ||
                         '"(crps249) REVERSAO RATEIO BLOQUEIO PIX - '||vr_tab_bloqueio_pix(vr_index_bloqueio_pix).inpessoa||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;

        vr_linhadet := lpad(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).cdagenci, 3, '0' ) || ',' ||TRIM(to_char(nvl(vr_tab_bloqueio_pix(vr_index_bloqueio_pix).vlbloqueado, 0), 'fm99999999999990.00'));
        cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        vr_index_bloqueio_pix := vr_tab_bloqueio_pix.next(vr_index_bloqueio_pix);
      end loop;
    END IF;

    ------------------------------  Contabilizacao mensal ------------------------------
    IF to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') THEN

      pc_proc_cbl_mensal(pr_cdcooper);

      cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    END IF;

    -------------------------------- OPCRED ------------------------------
    IF pr_cdcooper <> 3 THEN
      pc_gera_arq_op_cred (vr_dscritic);
    END IF;

    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    IF vr_dscritic IS NOT NULL THEN
       vr_cdcritic := 0;
       RAISE vr_exc_saida;
    END IF;

    vr_nmarqdat_ope_cred_nov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_OPCRED_NOVA_CENTRAL.txt';

    cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat_ope_cred||' > '||vr_dsdircop||'/'||vr_nmarqdat_ope_cred_nov||' 2>/dev/null',
                                pr_typ_saida   => vr_typ_said,
                                pr_des_saida   => vr_dscritic);
    if vr_typ_said = 'ERR' then
       vr_cdcritic := 1040;
       cecred.gene0001.pc_print(cecred.gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat_ope_cred||': '||vr_dscritic);
    end if;

    ------------------------------ PREJUIZO ------------------------------
    IF pr_cdcooper <> 3 THEN
      pc_gera_arq_prejuizo(vr_dscritic);
    END IF;

    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    IF vr_dscritic IS NOT NULL THEN
       vr_cdcritic := 0;
       RAISE vr_exc_saida;
    END IF;

    cecred.gene0001.pc_fecha_arquivo(vr_arquivo_txt);

    ------------------------------ PRINCIPAL ------------------------------
    vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_NOVA_CENTRAL.txt';
    cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                pr_typ_saida   => vr_typ_said,
                                pr_des_saida   => vr_dscritic);
    if vr_typ_said = 'ERR' then
       vr_cdcritic := 1040;
       cecred.gene0001.pc_print(cecred.gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
    end if;

    --
    COMMIT;
    --
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        cecred.btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);

      END IF;

      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := cecred.gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar
      ROLLBACK;
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 734422
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END gerarRelatoriosContabeisTbriscoRis;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    
    gerarRelatoriosContabeisTbriscoRis(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtrefere => vr_dtrefere
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
