DECLARE

  vr_dtrefere         DATE := to_date('01/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('31/08/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

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

  vr_nom_arquivo VARCHAR2(100);
  vr_des_xml     CLOB;
  vr_dstexto     VARCHAR2(32700);
  vr_nom_direto  VARCHAR2(400);
  
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
  vr_dtultdia            cecred.crapdat.dtultdia%type;
  vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
  
  
  rw_crapdat datascooperativa;
  

  
  FUNCTION fn_verifica_conta_migracao(par_cdcooper IN cecred.craptco.cdcooper%TYPE
                                     ,par_nrdconta IN cecred.craptco.nrdconta%TYPE
                                     ,par_dtrefere IN DATE) RETURN BOOLEAN IS

  vr_return BOOLEAN := FALSE;

  CURSOR cr_craptco(par_cdcooper IN cecred.craptco.cdcooper%TYPE
                   ,par_cdcopant IN cecred.craptco.cdcopant%TYPE
                   ,par_nrdconta IN cecred.craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM cecred.craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3;
  rw_craptco cr_craptco%ROWTYPE;

  CURSOR cr_craptco_acredi(par_cdcooper IN cecred.craptco.cdcooper%TYPE
                          ,par_cdcopant IN cecred.craptco.cdcopant%TYPE
                          ,par_nrdconta IN cecred.craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM cecred.craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3
       AND (craptco.cdageant = 2 OR craptco.cdageant = 4 OR
           craptco.cdageant = 6 OR craptco.cdageant = 7 OR
           craptco.cdageant = 11);
  rw_craptco_acredi cr_craptco_acredi%ROWTYPE;


  BEGIN

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


  FUNCTION fn_normaliza_jurosa60(par_cdcooper IN cecred.crapris.cdcooper%TYPE
                                ,par_nrdconta IN cecred.crapris.nrdconta%TYPE
                                ,par_dtrefere IN DATE
                                ,par_cdmodali IN cecred.crapris.cdmodali%TYPE
                                ,par_nrctremp IN cecred.crapris.nrctremp%TYPE
                                ,par_nrseqctr IN cecred.crapris.nrseqctr%TYPE
                                ,par_vldjuros IN OUT cecred.crapvri.vldivida%TYPE)
  RETURN NUMBER IS

    CURSOR cr_crapvri_jur(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                         ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                         ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE
                         ,pr_cdmodali IN cecred.crapris.cdmodali%TYPE
                         ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN cecred.crapris.nrseqctr%TYPE) IS
      SELECT v.cdvencto
            ,v.cdcooper
            ,v.vldivida
        FROM gestaoderisco.tbrisco_crapvri v
       WHERE v.cdcooper = pr_cdcooper
         AND v.nrdconta = pr_nrdconta
         AND v.dtrefere = pr_dtrefere
         AND v.cdmodali = pr_cdmodali
         AND v.nrctremp = pr_nrctremp
         AND v.nrseqctr = pr_nrseqctr
         AND v.cdvencto >= 230
         AND v.cdvencto <= 290;


    vr_vldiva60 NUMBER := 0;

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

PROCEDURE pc_calcula_juros_60_tdb(par_cdcooper IN cecred.crapris.cdcooper%TYPE
                                ,par_dtrefere IN cecred.crapris.dtrefere%TYPE
                                ,par_totrendap OUT typ_decimal_pfpj
                                ,par_totjurmra OUT typ_decimal_pfpj
                                ,par_rendaapropr OUT typ_arr_decimal_pfpj    
                                ,par_apropjurmra OUT typ_arr_decimal_pfpj    
                                ) IS
  vr_index PLS_INTEGER;

    CURSOR cr_tdb60 IS

      SELECT ROUND(SUM((x.dtvencto - x.dtvenmin60 + 1) * txdiaria *
                       vltitulo)
                  ,2) AS vljurrec, 
             cdcooper,
             cdagenci,
             inpessoa,
             SUM(vljura60) AS vljurmor 
        FROM (SELECT UNIQUE tdb.vljura60,
                     tdb.nrdconta,
                     tdb.nrborder,
                     tdb.dtlibbdt,
                     tdb.dtvencto,
                     (tdb.dtvencto - tdb.dtlibbdt) AS qtd_dias, 
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
                FROM cecred.craptdb tdb
               INNER JOIN (SELECT cdcooper,
                                 nrdconta,
                                 nrborder,
                                 MIN(dtvencto) dtvenmin
                            FROM cecred.craptdb
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
      IF rw_tdb60.inpessoa = 1 THEN 
        par_totrendap.valorpf := par_totrendap.valorpf + rw_tdb60.vljurrec;
        IF par_rendaapropr.exists(rw_tdb60.cdagenci) THEN
          par_rendaapropr(rw_tdb60.cdagenci).valorpf := NVL(par_rendaapropr(rw_tdb60.cdagenci).valorpf,0) + rw_tdb60.vljurrec;
        ELSE
          par_rendaapropr(rw_tdb60.cdagenci).valorpf := rw_tdb60.vljurrec;
        END IF;
      ELSE 
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
      IF rw_jur60.inpessoa = 1 THEN 
        par_totjurmra.valorpf := par_totjurmra.valorpf + rw_jur60.vljura60;
        IF par_apropjurmra.exists(rw_jur60.cdagenci) THEN
          par_apropjurmra(rw_jur60.cdagenci).valorpf := NVL(par_apropjurmra(rw_jur60.cdagenci).valorpf,0) + rw_jur60.vljura60;
        ELSE
          par_apropjurmra(rw_jur60.cdagenci).valorpf := rw_jur60.vljura60;
        END IF;
      ELSE 
        par_totjurmra.valorpj := par_totjurmra.valorpj + rw_jur60.vljura60;
        IF par_apropjurmra.exists(rw_jur60.cdagenci) THEN
          par_apropjurmra(rw_jur60.cdagenci).valorpj := NVL(par_apropjurmra(rw_jur60.cdagenci).valorpj,0) + rw_jur60.vljura60;
        ELSE
          par_apropjurmra(rw_jur60.cdagenci).valorpj := rw_jur60.vljura60;
        END IF;
      END IF;
    END LOOP;

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

  PROCEDURE pc_calcula_juros_60k(par_cdcooper IN cecred.crapris.cdcooper%TYPE
                                ,par_dtrefere IN cecred.crapris.dtrefere%TYPE
                                ,par_cdmodali IN cecred.crapris.cdmodali%TYPE
                                ,par_dtinicio IN cecred.crapris.dtinictr%TYPE
                                ,pr_tabvljur1 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur2 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur3 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur4 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur5 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur6 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur7 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur8 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur9 IN OUT typ_arr_decimal_pfpj    
                                ,pr_tabvljur10 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur11 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur12 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur13 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur14 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur15 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur16 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur17 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur18 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur19 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur20 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur21 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur22 IN OUT typ_arr_decimal_pfpj   
                                ,pr_tabvljur23 IN OUT typ_arr_decimal_pfpj   
                                ,pr_vlrjuros  OUT typ_decimal_pfpj           
                                ,pr_finjuros  OUT typ_decimal_pfpj           
                                ,pr_vlrjuros2 OUT typ_decimal_pfpj           
                                ,pr_finjuros2 OUT typ_decimal_pfpj           
                                ,pr_vlrjuros3 OUT typ_decimal_pfpj           
                                ,pr_vlrjuros6 OUT typ_decimal_pfpj           
                                ,pr_finjuros6 OUT typ_decimal_pfpj           
                                ,pr_vlmrapar6 OUT typ_decimal_pfpj           
                                ,pr_fimrapar6 OUT typ_decimal_pfpj           
                                ,pr_vljuremu6 OUT typ_decimal_pfpj           
                                ,pr_fijuremu6 OUT typ_decimal_pfpj           
                                ,pr_vljurcor6 OUT typ_decimal_pfpj           
                                ,pr_fijurcor6 OUT typ_decimal_pfpj           
                                ,pr_vljurmta6 OUT typ_decimal_pfpj           
                                ,pr_fijurmta6 OUT typ_decimal_pfpj           
                                ,pr_vlmrapar2 OUT typ_decimal_pfpj           
                                ,pr_fimrapar2 OUT typ_decimal_pfpj           
                                ,pr_vljuropp2 OUT typ_decimal_pfpj           
                                ,pr_fijuropp2 OUT typ_decimal_pfpj           
                                ,pr_vlmultpp2 OUT typ_decimal_pfpj           
                                ,pr_fimultpp2 OUT typ_decimal_pfpj           
                                ,pr_vljurcor2 OUT typ_decimal_pfpj           
                                ,pr_fijurcor2 OUT typ_decimal_pfpj           
                                ,pr_juros38_df OUT typ_decimal_pfpj          
                                ,pr_juros38_da OUT typ_decimal_pfpj          
                                ,pr_taxas37    OUT typ_decimal_pfpj          
                                ,pr_juros57    OUT typ_decimal_pfpj          
                                ,pr_tabvljuros38_df IN OUT typ_arr_decimal_pfpj  
                                ,pr_tabvljuros38_da IN OUT typ_arr_decimal_pfpj  
                                ,pr_tabvltaxas37    IN OUT typ_arr_decimal_pfpj  
                                ,pr_tabvljuros57    IN OUT typ_arr_decimal_pfpj  
                                ) IS



    CURSOR cr_crapvri_jur(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                         ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                         ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE
                         ,pr_cdmodali IN cecred.crapris.cdmodali%TYPE
                         ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE
                         ,pr_nrseqctr IN cecred.crapris.nrseqctr%TYPE) IS
      SELECT v.cdvencto
            ,v.cdcooper
            ,v.vldivida
        FROM gestaoderisco.tbrisco_crapvri v
       WHERE v.cdcooper = pr_cdcooper
         AND v.dtrefere = pr_dtrefere
         AND v.nrdconta = pr_nrdconta
         AND v.cdmodali = pr_cdmodali
         AND v.nrctremp = pr_nrctremp
         AND v.nrseqctr = pr_nrseqctr
         AND v.cdvencto >= 230
         AND v.cdvencto <= 290;
    rw_crapvri_jur cr_crapvri_jur%ROWTYPE;

    CURSOR cr_craplem(pr_cdcooper     IN cecred.crapris.cdcooper%TYPE
                     ,pr_nrdconta     IN cecred.crapris.nrdconta%TYPE
                     ,vr_diascalc    IN INTEGER
                     ,pr_tel_dtrefere cecred.craplem.dtmvtolt%TYPE
                     ,par_dtinicio    IN cecred.craplem.dtmvtolt%TYPE
                     ,pr_nrctremp     IN cecred.crapris.nrctremp%TYPE) IS
      SELECT craplem.vllanmto
        FROM cecred.craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.dtmvtolt >= pr_tel_dtrefere - vr_diascalc
         AND craplem.dtmvtolt >= par_dtinicio
         AND craplem.dtmvtolt <= pr_tel_dtrefere
         AND craplem.cdhistor = 98
         AND craplem.nrdocmto = pr_nrctremp;


    CURSOR cr_crapris_jur(par_cdcooper IN cecred.crapris.cdcooper%TYPE
                         ,par_dtrefere IN cecred.crapris.dtrefere%TYPE
                         ,par_cdmodali IN cecred.crapris.cdmodali%TYPE) IS
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
            ,nvl(j.vlmrapar60, 0) + nvl(j.vljurmorpp, 0) vlmrapar60 
            , nvl(j.vljurparpp, 0) vljuremu60 
            ,nvl(j.vljurcor60, 0) + nvl(j.vljurcorpp, 0) vljurcor60 
            ,nvl(j.vljurantpp, 0) vljurantpp 
            ,nvl(j.vljurparpp, 0) vljurparpp 
            ,nvl(j.vljurmorpp, 0) vljurmorpp 
            ,nvl(j.vljurmulpp, 0) vljurmulpp 
            ,nvl(j.vljurcorpp, 0) vljurcorpp 
            ,nvl(j.vljura60, 0) vljura60
        FROM gestaoderisco.tbrisco_crapris ris
            ,cecred.crapepr epr
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
            ,cecred.crapass a
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

    
    CURSOR cr_cessao (pr_cdcooper cecred.crapepr.cdcooper%TYPE,
                      pr_nrdconta cecred.crapepr.nrdconta%TYPE,
                      pr_nrctremp cecred.crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM cecred.tbcrd_cessao_credito ces
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

    vr_cdcritic cecred.crapcri.cdcritic%TYPE;
    vr_dscritic cecred.crapcri.dscritic%TYPE;

    
    CURSOR cr_conta_negativa (pr_cdcooper IN cecred.crapris.cdcooper%TYPE) IS
      SELECT ris.nrdconta
           , DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa 
           , ass.cdagenci
           , ris.qtdiaatr qtdiaatr
           , ris.vldivida
           , ris.dtinictr
           , sld.vljuresp 
           , null tpregtrb
        FROM cecred.crapass ass
           , gestaoderisco.tbrisco_crapris ris
           , cecred.crapsld sld
           , GESTAODERISCO.vw_historico_juros_adp j
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta  = ass.nrdconta
         and ris.inpessoa <> 2
         AND ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere  = par_dtrefere
         AND ris.cdmodali  = 101
         AND ris.qtdiaatr >= 60
         AND ris.innivris <  10 
         AND sld.cdcooper = ass.cdcooper
         AND sld.nrdconta = ass.nrdconta
         AND j.cdcooper = ris.cdcooper
         AND j.nrdconta = ris.nrdconta
         AND j.dtmvtolt = ris.dtrefere
         AND j.vljura60adp > 0
      union
      SELECT ris.nrdconta
           , DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa 
           , ass.cdagenci
           , ris.qtdiaatr qtdiaatr
           , ris.vldivida
           , ris.dtinictr
           , sld.vljuresp 
           , jur.tpregtrb
        FROM cecred.crapjur jur
           , cecred.crapass ass
           , gestaoderisco.tbrisco_crapris ris
           , cecred.crapsld sld
           , GESTAODERISCO.vw_historico_juros_adp j
       WHERE jur.cdcooper = ris.cdcooper
         and jur.nrdconta = ris.nrdconta
         and ris.cdcooper = ass.cdcooper
         AND ris.nrdconta  = ass.nrdconta
         and ris.inpessoa  = 2
         AND ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere  = par_dtrefere
         AND ris.cdmodali  = 101
         AND ris.qtdiaatr >= 60
         AND ris.innivris <  10 
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

        
        vr_vljurctr := fn_normaliza_jurosa60(rw_crapris_jur.cdcooper,
                                             rw_crapris_jur.nrdconta,
                                             rw_crapris_jur.dtrefere,
                                             rw_crapris_jur.cdmodali,
                                             rw_crapris_jur.nrctremp,
                                             rw_crapris_jur.nrseqctr,
                                             vr_vljurctr);
        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_vlrjuros.valorpf := pr_vlrjuros.valorpf + vr_vljurctr;

            IF pr_tabvljur1.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf,0) +  vr_vljurctr;
            ELSE
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpf := vr_vljurctr;
            END IF;
          ELSE 
            pr_vlrjuros.valorpj := pr_vlrjuros.valorpj + vr_vljurctr;

            IF pr_tabvljur1.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj,0) +  vr_vljurctr;
            ELSE
              pr_tabvljur1(rw_crapris_jur.cdagenci).valorpj := vr_vljurctr;
            END IF;
          END IF;

        ELSE  

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_finjuros.valorpf := pr_finjuros.valorpf + vr_vljurctr;

            IF pr_tabvljur2.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf,0) + vr_vljurctr;
            ELSE
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpf := vr_vljurctr;
            END IF;

          ELSE 
            pr_finjuros.valorpj := pr_finjuros.valorpj + vr_vljurctr;

            IF pr_tabvljur2.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj,0) + vr_vljurctr;
            ELSE
              pr_tabvljur2(rw_crapris_jur.cdagenci).valorpj := vr_vljurctr;
            END IF;
          END IF;

        END IF;

      ELSIF rw_crapris_jur.tpemprst = 1 THEN  

        vr_fleprces := 0;

        OPEN cr_cessao (pr_cdcooper => rw_crapris_jur.cdcooper,
                        pr_nrdconta => rw_crapris_jur.nrdconta,
                        pr_nrctremp => rw_crapris_jur.nrctremp);
        FETCH cr_cessao INTO vr_fleprces;
        CLOSE cr_cessao;

        
        IF vr_fleprces = 1 THEN
          
          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_vlrjuros3.valorpf := pr_vlrjuros3.valorpf + NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); 

            
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60 + nvl(rw_crapris_jur.vljurmulpp,0); 
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); 
            END IF;
          ELSE 
            pr_vlrjuros3.valorpj := pr_vlrjuros3.valorpj + NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); 

            
            IF pr_tabvljur5.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60 + nvl(rw_crapris_jur.vljurmulpp,0); 
            ELSE
              pr_tabvljur5(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0) + nvl(rw_crapris_jur.vljurmulpp,0); 
            END IF;
          END IF;
        END IF;

        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_vlrjuros2.valorpf := pr_vlrjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar2.valorpf := pr_vlmrapar2.valorpf + nvl(rw_crapris_jur.vljurmorpp,0); 
            pr_vljuropp2.valorpf := pr_vljuropp2.valorpf + nvl(rw_crapris_jur.vljurparpp,0) ;  
            pr_vlmultpp2.valorpf := pr_vlmultpp2.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); 
            pr_vljurcor2.valorpf := pr_vljurcor2.valorpf + nvl(rw_crapris_jur.vljurcorpp,0); 

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmorpp; 
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurparpp ;  
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp; 
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcorpp; 
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmorpp,0); 
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurparpp,0) ;  
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmulpp,0); 
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurcorpp,0); 
            END IF;
          ELSE 
            pr_vlrjuros2.valorpj := pr_vlrjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar2.valorpj := pr_vlmrapar2.valorpj + nvl(rw_crapris_jur.vljurmorpp,0); 
            pr_vljuropp2.valorpj := pr_vljuropp2.valorpj + nvl(rw_crapris_jur.vljurparpp,0) ;  
            pr_vlmultpp2.valorpj := pr_vlmultpp2.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); 
            pr_vljurcor2.valorpj := pr_vljurcor2.valorpj + nvl(rw_crapris_jur.vljurcorpp,0); 

            IF pr_tabvljur3.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmorpp; 
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurparpp ;  
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp; 
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcorpp; 
            ELSE
              pr_tabvljur3(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur14(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmorpp,0); 
              pr_tabvljur16(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurparpp,0) ;  
              pr_tabvljur18(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmulpp,0); 
              pr_tabvljur20(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurcorpp,0); 
            END IF;

          END IF;

        ELSE

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_finjuros2.valorpf := pr_finjuros2.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar2.valorpf := pr_fimrapar2.valorpf + nvl(rw_crapris_jur.vljurmorpp,0); 
            pr_fijuropp2.valorpf := pr_fijuropp2.valorpf + nvl(rw_crapris_jur.vljurparpp,0) ;  
            pr_fimultpp2.valorpf := pr_fimultpp2.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); 
            pr_fijurcor2.valorpf := pr_fijurcor2.valorpf + nvl(rw_crapris_jur.vljurcorpp,0); 

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmorpp; 
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurparpp ;  
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp; 
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcorpp; 
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmorpp,0); 
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurparpp,0) ;  
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurmulpp,0); 
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljurcorpp,0); 
            END IF;
          ELSE  
            pr_finjuros2.valorpj := pr_finjuros2.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar2.valorpj := pr_fimrapar2.valorpj + nvl(rw_crapris_jur.vljurmorpp,0); 
            pr_fijuropp2.valorpj := pr_fijuropp2.valorpj + nvl(rw_crapris_jur.vljurparpp,0) ;  
            pr_fimultpp2.valorpj := pr_fimultpp2.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); 
            pr_fijurcor2.valorpj := pr_fijurcor2.valorpj + nvl(rw_crapris_jur.vljurcorpp,0); 

            IF pr_tabvljur4.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmorpp; 
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurparpp ;  
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp; 
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcorpp; 
            ELSE
              pr_tabvljur4(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur15(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmorpp,0); 
              pr_tabvljur17(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurparpp,0) ;  
              pr_tabvljur19(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurmulpp,0); 
              pr_tabvljur21(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljurcorpp,0); 
            END IF;
          END IF;

        END IF;

      ELSIF rw_crapris_jur.tpemprst = 2 THEN  

        
        IF par_cdmodali = 299 THEN

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_vlrjuros6.valorpf := pr_vlrjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar6.valorpf := pr_vlmrapar6.valorpf + nvl(rw_crapris_jur.vlmrapar60,0); 
            pr_vljuremu6.valorpf := pr_vljuremu6.valorpf + nvl(rw_crapris_jur.vljuremu60,0); 
            pr_vljurcor6.valorpf := pr_vljurcor6.valorpf + nvl(rw_crapris_jur.vljurcor60,0); 
            pr_vljurmta6.valorpf := pr_vljurmta6.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); 

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vlmrapar60; 
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljuremu60;
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcor60;
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vlmrapar60,0); 
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljuremu60,0);
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurcor60,0);
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurmulpp,0);
      END IF;
          ELSE 
            pr_vlrjuros6.valorpj := pr_vlrjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_vlmrapar6.valorpj := pr_vlmrapar6.valorpj + nvl(rw_crapris_jur.vlmrapar60,0); 
            pr_vljuremu6.valorpj := pr_vljuremu6.valorpj + nvl(rw_crapris_jur.vljuremu60,0); 
            pr_vljurcor6.valorpj := pr_vljurcor6.valorpj + nvl(rw_crapris_jur.vljurcor60,0); 
            pr_vljurmta6.valorpj := pr_vljurmta6.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); 

            IF pr_tabvljur6.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vlmrapar60; 
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljuremu60;
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcor60;
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur6(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur8(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vlmrapar60,0); 
              pr_tabvljur10(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljuremu60,0);
              pr_tabvljur12(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurcor60,0);
              pr_tabvljur22(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurmulpp,0);
            END IF;

          END IF;

        ELSE 

          IF rw_crapris_jur.inpessoa = 1 THEN 

            pr_finjuros6.valorpf := pr_finjuros6.valorpf + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar6.valorpf := pr_fimrapar6.valorpf + nvl(rw_crapris_jur.vlmrapar60,0); 
            pr_fijuremu6.valorpf := pr_fijuremu6.valorpf + nvl(rw_crapris_jur.vljuremu60,0); 
            pr_fijurcor6.valorpf := pr_fijurcor6.valorpf + nvl(rw_crapris_jur.vljurcor60,0); 
            pr_vljurmta6.valorpf := pr_vljurmta6.valorpf + nvl(rw_crapris_jur.vljurmulpp,0); 

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljura60;
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vlmrapar60; 
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljuremu60;
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurcor60;
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf := nvl(pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpf := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vlmrapar60,0); 
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljuremu60,0);
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurcor60,0);
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpf := nvl(rw_crapris_jur.vljurmulpp,0);
            END IF;
          ELSE  
            pr_finjuros6.valorpj := pr_finjuros6.valorpj + NVL(rw_crapris_jur.vljura60,0);
            pr_fimrapar6.valorpj := pr_fimrapar6.valorpj + nvl(rw_crapris_jur.vlmrapar60,0); 
            pr_fijuremu6.valorpj := pr_fijuremu6.valorpj + nvl(rw_crapris_jur.vljuremu60,0); 
            pr_fijurcor6.valorpj := pr_fijurcor6.valorpj + nvl(rw_crapris_jur.vljurcor60,0); 
            pr_fijurmta6.valorpj := pr_fijurmta6.valorpj + nvl(rw_crapris_jur.vljurmulpp,0); 

            IF pr_tabvljur7.exists(rw_crapris_jur.cdagenci) THEN
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljura60;
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vlmrapar60; 
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljuremu60;
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurcor60;
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj := nvl(pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj,0) + rw_crapris_jur.vljurmulpp;
            ELSE
              pr_tabvljur7(rw_crapris_jur.cdagenci).valorpj := NVL(rw_crapris_jur.vljura60,0);
              pr_tabvljur9(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vlmrapar60,0); 
              pr_tabvljur11(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljuremu60,0);
              pr_tabvljur13(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurcor60,0);
              pr_tabvljur23(rw_crapris_jur.cdagenci).valorpj := nvl(rw_crapris_jur.vljurmulpp,0);
            END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;

     
    IF par_cdmodali = 999 THEN
        FOR  rw_conta_negativa in cr_conta_negativa(pr_cdcooper =>par_cdcooper) LOOP
          
          cecred.TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => par_cdcooper
                                                         , pr_nrdconta => rw_conta_negativa.nrdconta
                                                         , pr_dtlimite => par_dtrefere
                                                         , pr_qtdiaatr => rw_conta_negativa.qtdiaatr 
                                                         , pr_tppesqui => 2 
                                                         , pr_vlsld59d => vr_vlsld59d
                                                         , pr_vlju6037 => vr_vlju6037
                                                         , pr_vlju6038 => vr_vlju6038
                                                         , pr_vlju6057 => vr_vlju6057
                                                         , pr_cdcritic => vr_cdcritic
                                                         , pr_dscritic => vr_dscritic);

           IF rw_conta_negativa.vljuresp > 0 THEN  
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

           IF vr_vlju6037 > 0 THEN  
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

           IF vr_vlju6038 > 0 THEN  
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

           IF vr_vlju6057 > 0 THEN  
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

  PROCEDURE pc_risco_k(pr_cdcooper   IN cecred.crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_retfile   OUT VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS
    CURSOR cr_crapris(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                     ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE) IS
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
            ,nvl(j.vljurantpp,0) vljurantpp
            ,null tpregtrb
            ,ris.nracordo
        FROM gestaoderisco.tbrisco_crapris ris
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
            ,cecred.crapass a
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
            ,nvl(j.vljurantpp,0) vljurantpp
            ,jur.tpregtrb
            ,ris.nracordo
        FROM cecred.crapjur jur
           , gestaoderisco.tbrisco_crapris ris
           , GESTAODERISCO.tbrisco_juros_emprestimo j
           , cecred.crapass a
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
    
    CURSOR cr_crapris_249(pr_cdcooper in cecred.crapris.cdcooper%TYPE
                         ,pr_dtultdia in cecred.crapris.dtrefere%TYPE
                         ,pr_cdorigem in cecred.crapris.cdorigem%TYPE
                         ,pr_cdmodali in cecred.crapris.cdmodali%TYPE
                         ,pr_tpemprst IN cecred.crapepr.tpemprst%TYPE) IS
      SELECT a.cdagenci
            ,(SUM(v.vldivida) + ROUND(AVG(nvl(j.vljura60, 0)),2)) saldo_devedor
        FROM gestaoderisco.tbrisco_crapris r
            ,cecred.crapass a  
            ,cecred.crapepr e
            ,gestaoderisco.tbrisco_crapvri v
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
       WHERE r.cdcooper = a.cdcooper
         AND r.nrdconta = a.nrdconta
         AND r.cdcooper = pr_cdcooper
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
         AND r.cdcooper = j.cdcooper(+) 
         AND r.nrdconta = j.nrdconta(+) 
         AND r.nrctremp = j.nrctremp(+) 
         AND r.dtrefere = j.dtrefere(+) 
         AND v.cdvencto BETWEEN 110 AND 290 
         AND NOT EXISTS (SELECT 1
                           FROM cecred.crapebn b
                          WHERE b.cdcooper = r.cdcooper
                            AND b.nrdconta = r.nrdconta
                            AND b.nrctremp = r.nrctremp)
         AND NOT EXISTS (SELECT 1
                           FROM cecred.tbcrd_cessao_credito ces
                          WHERE ces.cdcooper = r.cdcooper
                            AND ces.nrdconta = r.nrdconta
                            AND ces.nrctremp = r.nrctremp)
         GROUP BY (a.cdagenci) 
         ORDER BY nvl(a.cdagenci,0) ASC;
    TYPE typ_cr_crapris_249 IS TABLE OF cr_crapris_249%ROWTYPE index by PLS_INTEGER;
    rw_crapris_249 typ_cr_crapris_249; 
    
    CURSOR cr_crapris_lnu(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                         ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE
                          ,pr_cdmodali  IN cecred.crapris.cdmodali%TYPE
                          ,pr_cdmodali2 IN cecred.crapris.cdmodali%TYPE DEFAULT NULL) IS
      SELECT ris.cdcooper
            ,ris.dtrefere
            ,ris.vldivida
            ,ris.nrdconta
            ,ris.inpessoa
        FROM gestaoderisco.tbrisco_crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.inddocto = 3
         AND ris.cdmodali IN (pr_cdmodali, NVL(pr_cdmodali2,0));

    CURSOR cr_crapvri(pr_cdcooper IN cecred.crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN cecred.crapvri.dtrefere%TYPE
                     ,pr_cdmodali IN cecred.crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN cecred.crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN cecred.crapvri.nrseqctr%TYPE
                     ,pr_vldivida IN NUMBER) IS
      SELECT m.cdvencto,
             m.cdcooper,
             m.nrdconta,
             m.dtrefere,
             m.cdmodali,
             m.nrctremp,
             m.nrseqctr,
             ROUND(m.vldivida + jura60_vencimento, 2) vldivida
        FROM (SELECT x.cdvencto,
                     x.vldivida,
                     x.cdcooper,
                     x.nrdconta,
                     x.dtrefere,
                     x.cdmodali,
                     x.nrctremp,
                     x.nrseqctr,
                     CASE
                       WHEN x.vljura60 > 0 THEN
                        (x.vldivida / pr_vldivida) * x.vljura60
                       ELSE
                        0
                     END jura60_vencimento
                FROM (SELECT v.cdvencto,
                             v.vldivida,
                             v.cdcooper,
                             v.nrdconta,
                             v.dtrefere,
                             v.cdmodali,
                             v.nrctremp,
                             v.nrseqctr,
                             NVL(j.vljura60, 0) vljura60
                        FROM gestaoderisco.tbrisco_crapvri            v,
                             gestaoderisco.vw_operacoes_risco_juros60 j
                       WHERE v.cdcooper = pr_cdcooper
                         AND v.nrdconta = pr_nrdconta
                         AND v.dtrefere = pr_dtrefere
                         AND v.cdmodali = pr_cdmodali
                         AND v.nrctremp = pr_nrctremp
                         AND v.nrseqctr = pr_nrseqctr
                         AND v.cdcooper = j.cdcooper(+)
                         AND v.nrdconta = j.nrdconta(+)
                         AND v.nrctremp = j.nrctremp(+)
                         AND v.dtrefere = j.dtmvtolt(+)
                       ORDER BY v.nrdconta, v.nrctremp) x) m;

    CURSOR cr_crabvri(pr_cdcooper IN cecred.crapvri.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapvri.nrdconta%TYPE
                     ,pr_dtrefere IN cecred.crapvri.dtrefere%TYPE
                     ,pr_cdmodali IN cecred.crapvri.cdmodali%TYPE
                     ,pr_nrctremp IN cecred.crapvri.nrctremp%TYPE
                     ,pr_nrseqctr IN cecred.crapvri.nrseqctr%TYPE) IS
      SELECT vri.cdcooper
        FROM gestaoderisco.tbrisco_crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.nrdconta = pr_nrdconta
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr
         AND vri.cdvencto > 205;
    rw_crabvri cr_crabvri%ROWTYPE;

    CURSOR cr_crapepr(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
      SELECT crapepr.tpemprst
        FROM cecred.crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    CURSOR cr_crapage(pr_cdcooper IN cecred.crapage.cdcooper%TYPE) IS
      SELECT crapage.cdagenci
            ,crapage.cdccuage
        FROM cecred.crapage
       WHERE crapage.cdcooper = pr_cdcooper;

    CURSOR cr_craptab(par_cdcooper IN cecred.craptab.cdcooper%TYPE) IS
      SELECT craptab.dstextab
        FROM cecred.craptab
       WHERE craptab.cdcooper = par_cdcooper
         AND UPPER(craptab.nmsistem) = 'CRED'
         AND UPPER(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 00
         AND UPPER(craptab.cdacesso) = 'PROVISAOCL';

    CURSOR cr_tabmicro(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE) IS
        SELECT age.cdagenci
              ,lcr.dsorgrec
          FROM cecred.craplcr lcr
              ,(select cdagenci from cecred.crapage where cdcooper = pr_cdcooper
                union
                select 999 from dual) age
         WHERE lcr.cdcooper = pr_cdcooper
           AND lcr.cdusolcr = 1
           AND lcr.dsorgrec <> ' '
           GROUP BY age.cdagenci,lcr.dsorgrec
           ORDER BY age.cdagenci,lcr.dsorgrec ASC;
    rw_tabmicro cr_tabmicro%ROWTYPE;

    CURSOR cr_craplcr(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
        SELECT lcr.cdusolcr
              ,lcr.dsorgrec
          FROM cecred.craplcr lcr
              ,cecred.crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    CURSOR cr_crapris_60(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                        ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE
                        ,pr_cdcopant IN cecred.craptco.cdcopant%TYPE
                        ,pr_dtincorp IN cecred.crapdat.dtmvtolt%TYPE) IS
        SELECT ris.inpessoa
               ,ris.innivris
               ,SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)) vljura60
          FROM gestaoderisco.tbrisco_crapris ris, GESTAODERISCO.tbrisco_juros_emprestimo j
         WHERE ris.cdcooper = pr_cdcooper 
           AND ris.dtrefere = pr_dtrefere 
           AND ris.cdcooper = j.cdcooper(+) 
           AND ris.nrdconta = j.nrdconta(+)
           AND ris.nrctremp = j.nrctremp(+)
           AND ris.dtrefere = j.dtrefere(+)
           AND ris.inddocto = 1           
           AND (NOT EXISTS (SELECT 1
                              FROM cecred.craptco t
                             WHERE t.cdcooper = ris.cdcooper
                               AND t.nrdconta = ris.nrdconta
                               AND t.cdcopant = pr_cdcopant) OR
               pr_dtrefere > pr_dtincorp)
          GROUP BY ris.inpessoa
                  ,ris.innivris
          HAVING SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)) > 0 
          ORDER BY ris.inpessoa
                  ,ris.innivris;
    rw_crapris_60 cr_crapris_60%ROWTYPE;

    CURSOR cr_crapebn(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
      SELECT crapebn.nrctremp
        FROM cecred.crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctremp;
    rw_crapebn cr_crapebn%ROWTYPE;
    
    CURSOR cr_crapebn_desconsid_microcred(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                            ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                            ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM cecred.crapebn
       WHERE crapebn.cdcooper = pr_cdcooper
         AND crapebn.nrdconta = pr_nrdconta
         AND crapebn.nrctremp = pr_nrctremp
         AND crapebn.indescrisc = 1;

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

    CURSOR cr_cessao (pr_cdcooper cecred.crapepr.cdcooper%TYPE,
                      pr_nrdconta cecred.crapepr.nrdconta%TYPE,
                      pr_nrctremp cecred.crapepr.nrctremp%TYPE) IS
      SELECT 1
        FROM cecred.tbcrd_cessao_credito ces
       WHERE ces.cdcooper = pr_cdcooper
         AND ces.nrdconta = pr_nrdconta
         AND ces.nrctremp = pr_nrctremp;

     CURSOR cr_saldo_opera (pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,
                            pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                            pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) is
      SELECT nvl(ROUND(SUM(vldivida),2),0)
        FROM gestaoderisco.tbrisco_crapris r
           , cecred.CRAPEPR
       WHERE r.cdcooper = pr_cdcooper 
         AND r.dtrefere = pr_dtrefere 
         AND crapepr.cdlcremp = pr_cdlcremp 
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.inddocto = 1 
         AND r.innivris <= 9; 

     CURSOR cr_saldo_opera_pronampe1(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                     pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                     pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS
      SELECT NVL(ROUND(SUM(vldivida),2),0)
        FROM gestaoderisco.tbrisco_crapris r
           , cecred.CRAPEPR
       WHERE r.cdcooper = pr_cdcooper 
         AND r.dtrefere = pr_dtrefere 
         AND crapepr.cdlcremp = pr_cdlcremp 
         AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.inddocto = 1 
         AND r.innivris <= 9; 

     CURSOR cr_saldo_opera_pronampe2(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                     pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                     pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS
      SELECT NVL(ROUND(SUM(vldivida),2),0)
        FROM gestaoderisco.tbrisco_crapris r
           , cecred.CRAPEPR
       WHERE r.cdcooper = pr_cdcooper 
         AND r.dtrefere = pr_dtrefere 
         AND crapepr.cdlcremp = pr_cdlcremp 
         AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
         AND r.cdcooper = crapepr.cdcooper
         AND r.nrdconta = crapepr.nrdconta
         AND r.nrctremp = crapepr.nrctremp
         AND r.inddocto = 1 
         AND r.innivris <= 9; 

     CURSOR cr_juros_60  (pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,
                          pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                          pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) is 
      SELECT nvl(ROUND(SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)),2),0)
          FROM gestaoderisco.tbrisco_crapris r
             , CRAPEPR e
             , GESTAODERISCO.tbrisco_juros_emprestimo j
         WHERE r.cdcooper  = pr_cdcooper 
           AND r.dtrefere  = pr_dtrefere 
           AND e.cdlcremp  = pr_cdlcremp 
           AND r.cdcooper  = e.cdcooper
           AND r.nrdconta  = e.nrdconta
           AND r.nrctremp  = e.nrctremp
           AND r.cdcooper = j.cdcooper(+) 
           AND r.nrdconta = j.nrdconta(+)
           AND r.nrctremp = j.nrctremp(+)
           AND r.dtrefere = j.dtrefere(+)
           AND r.inddocto  = 1 
           AND r.innivris  <= 9;

     CURSOR cr_juros_60_pronampe1(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                  pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                  pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS 
       SELECT NVL(ROUND(SUM(nvl(j.vljura60,0) + nvl(j.vljurantpp,0)),2),0)
         FROM gestaoderisco.tbrisco_crapris r
            , cecred.crapepr
            , GESTAODERISCO.tbrisco_juros_emprestimo j
        WHERE r.cdcooper  = pr_cdcooper 
          AND r.dtrefere  = pr_dtrefere 
          AND crapepr.cdlcremp  = pr_cdlcremp 
          AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
          AND r.cdcooper  = crapepr.cdcooper
          AND r.nrdconta  = crapepr.nrdconta
          AND r.nrctremp  = crapepr.nrctremp
          AND r.cdcooper = j.cdcooper(+) 
          AND r.nrdconta = j.nrdconta(+)
          AND r.nrctremp = j.nrctremp(+)
          AND r.dtrefere = j.dtrefere(+)
          AND r.inddocto  = 1 
          AND r.innivris  <= 9;
     
     CURSOR cr_juros_60_pronampe2(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                  pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                  pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS 
       SELECT NVL(ROUND(SUM(j.vljura60 + j.vljurantpp),2),0)
         FROM gestaoderisco.tbrisco_crapris r
            , cecred.crapepr
            , GESTAODERISCO.tbrisco_juros_emprestimo j
        WHERE r.cdcooper  = pr_cdcooper 
          AND r.dtrefere  = pr_dtrefere 
          AND crapepr.cdlcremp  = pr_cdlcremp
          AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
          AND r.cdcooper  = crapepr.cdcooper
          AND r.nrdconta  = crapepr.nrdconta
          AND r.nrctremp  = crapepr.nrctremp
          AND r.cdcooper = j.cdcooper(+) 
          AND r.nrdconta = j.nrdconta(+)
          AND r.nrctremp = j.nrctremp(+)
          AND r.dtrefere = j.dtrefere(+)
          AND r.inddocto  = 1 
          AND r.innivris  <= 9;

     CURSOR cr_prov_perdas (pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,
                            pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                            pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) is
     SELECT nvl(ROUND(SUM(v_provisao_perda),2),0) FROM 
    (SELECT  r.innivris,
    ROUND((r.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
      FROM gestaoderisco.tbrisco_crapris r
         , cecred.CRAPEPR,
       (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, substr(craptab.dstextab, 12, 2) innivris
            FROM cecred.CRAPTAB
           WHERE craptab.cdcooper = pr_cdcooper
             AND UPPER(craptab.nmsistem) = 'CRED'
             AND UPPER(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres = 00
             AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO  
     WHERE  r.cdcooper = pr_cdcooper 
       AND r.dtrefere = pr_dtrefere 
       AND crapepr.cdlcremp = pr_cdlcremp 
       AND r.cdcooper = crapepr.cdcooper
       AND r.nrdconta = crapepr.nrdconta
       AND r.nrctremp = crapepr.nrctremp
       AND r.inddocto  = 1 
       AND r.innivris <= 9 
       AND r.innivris = n_risco.innivris);

    CURSOR cr_prov_perdas_pronampe1(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                    pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                    pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS          
     SELECT NVL(ROUND(SUM(v_provisao_perda),2),0) FROM 
    (SELECT r.innivris,
            ROUND((r.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
       FROM gestaoderisco.tbrisco_crapris r
          , cecred.CRAPEPR,
            (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, SUBSTR(craptab.dstextab, 12, 2) innivris
               FROM cecred.CRAPTAB
              WHERE craptab.cdcooper = pr_cdcooper
                AND UPPER(craptab.nmsistem) = 'CRED'
                AND UPPER(craptab.tptabela) = 'GENERI'
                AND craptab.cdempres = 00
                AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO
      WHERE r.cdcooper = pr_cdcooper 
        AND r.dtrefere = pr_dtrefere 
        AND crapepr.cdlcremp = pr_cdlcremp 
        AND TRUNC(crapepr.dtmvtolt) <= TO_DATE('31/12/2020','DD/MM/YYYY')
        AND r.cdcooper = crapepr.cdcooper
        AND r.nrdconta = crapepr.nrdconta
        AND r.nrctremp = crapepr.nrctremp
        AND r.inddocto  = 1 
        AND r.innivris <= 9 
        AND r.innivris = n_risco.innivris);

    CURSOR cr_prov_perdas_pronampe2(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE,         
                                    pr_dtrefere IN cecred.crapris.dtrefere%TYPE,
                                    pr_cdlcremp IN cecred.crapepr.cdlcremp%TYPE) IS          
     SELECT NVL(ROUND(SUM(v_provisao_perda),2),0) FROM 
    (SELECT r.innivris,
            ROUND((r.vldivida) * (n_risco.percentu)/100,2) v_provisao_perda
       FROM gestaoderisco.tbrisco_crapris r
          , cecred.CRAPEPR,
            (SELECT SUBSTR(craptab.dstextab, 1, 6) percentu, SUBSTR(craptab.dstextab, 12, 2) innivris
               FROM cecred.CRAPTAB
              WHERE craptab.cdcooper = pr_cdcooper
                AND UPPER(craptab.nmsistem) = 'CRED'
                AND UPPER(craptab.tptabela) = 'GENERI'
                AND craptab.cdempres = 00
                AND UPPER(craptab.cdacesso) = 'PROVISAOCL') N_RISCO  
      WHERE r.cdcooper = pr_cdcooper 
        AND r.dtrefere = pr_dtrefere 
        AND crapepr.cdlcremp = pr_cdlcremp 
        AND TRUNC(crapepr.dtmvtolt) >= TO_DATE('01/01/2021','DD/MM/YYYY')
        AND r.cdcooper = crapepr.cdcooper
        AND r.nrdconta = crapepr.nrdconta
        AND r.nrctremp = crapepr.nrctremp
        AND r.inddocto  = 1 
        AND r.innivris <= 9 
        AND r.innivris = n_risco.innivris);

    cursor cr_craplcr_6901(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                          ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE) is
      select aux.innivris
           , sum(aux.vldivida_normal) vldivida_normal
           , sum(aux.vldivida_vencida) vldivida_vencida
           , sum(vljura60_pf) + sum(vljurantpp_pf) vljuros_pf
           , sum(vljura60_pj) + sum(vljurantpp_pj) vljuros_pj
        from (select c.innivris
                   , (sum(c.vldivida) + SUM(nvl(j.vljura60,0)) + SUM(nvl(j.vljurantpp,0))) vldivida_normal
                   , 0 vldivida_vencida
                   , sum(case a.inpessoa when 1 then nvl(j.vljura60,0) else 0 end) vljura60_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljura60,0) end) vljura60_pj
                   , sum(case a.inpessoa when 1 then nvl(j.vljurantpp,0) else 0 end) vljurantpp_pf
                   , sum(case a.inpessoa when 1 then 0 else nvl(j.vljurantpp,0) end) vljurantpp_pj
                from cecred.crapass a
                   , cecred.crapepr e
                   , gestaoderisco.tbrisco_crapris c
                   , GESTAODERISCO.tbrisco_juros_emprestimo j
               where not exists (select 1
                                   from gestaoderisco.tbrisco_crapvri v
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
               from cecred.crapass a
                   , cecred.crapepr e
                   , gestaoderisco.tbrisco_crapris c
                   , GESTAODERISCO.tbrisco_juros_emprestimo j
               where exists (select 1
                               from gestaoderisco.tbrisco_crapvri v
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
      
    CURSOR cr_crapsda(pr_cdcooper  IN cecred.crapass.cdcooper%TYPE
                     ,pr_nrdconta  IN cecred.crapass.nrdconta%TYPE
                     ,pr_dtmvtolt  IN cecred.crapdat.dtmvtolt%TYPE) IS
      SELECT nvl(s.vlsdbloq,0) + nvl(s.vlsdblpr,0) + nvl(s.vlsdblfp,0) vlbloque
        FROM cecred.crapsda s
            ,cecred.crapass a
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta
         AND s.dtmvtolt = pr_dtmvtolt
         AND a.cdcooper = s.cdcooper
         AND a.nrdconta = s.nrdconta;
    rw_crapsda cr_crapsda%ROWTYPE;
      
    vr_exc_erro          EXCEPTION;
    vr_file_erro         EXCEPTION;

    vr_nrmaxpas          INTEGER := 0;
    rw_crapdat           cecred.btch0001.cr_crapdat%ROWTYPE;

    vr_dircon VARCHAR2(200);
    vr_arqcon VARCHAR2(200);


    vr_price_atr CONSTANT VARCHAR2(3) := 'ATR'; 
    vr_price_pre CONSTANT VARCHAR2(3) := 'PRE'; 

    vr_price_pf CONSTANT VARCHAR2(1) := '1'; 
    vr_price_pj CONSTANT VARCHAR2(1) := '2'; 

    vr_price_deb CONSTANT VARCHAR2(1) := 'D'; 
    vr_price_cre CONSTANT VARCHAR2(1) := 'C'; 

    TYPE typ_reg_contas IS
       RECORD(nrdconta NUMBER);      

    TYPE typ_tab_descricao IS TABLE OF typ_reg_contas INDEX BY VARCHAR2(45);

    TYPE typ_tab_debcre IS TABLE OF typ_tab_descricao INDEX BY VARCHAR2(1);

    TYPE typ_tab_pessoa IS TABLE OF typ_tab_debcre INDEX BY VARCHAR2(1);

    TYPE typ_tab_produto IS TABLE OF typ_tab_pessoa INDEX BY VARCHAR2(3);
    vr_tab_contas        typ_tab_produto;

    TYPE typ_tab_microtrpre IS TABLE OF typ_decimal INDEX BY VARCHAR2(53);
    TYPE typ_tab_dsorgrec   IS TABLE OF typ_tab_microtrpre INDEX BY VARCHAR2(4);
    vr_tab_microcredito        typ_tab_dsorgrec;

    vr_tab_microcredito_desconsid   typ_tab_dsorgrec;

    vr_pacvljur_1        typ_arr_decimal_pfpj;
    vr_pacvljur_2        typ_arr_decimal_pfpj;
    vr_pacvljur_3        typ_arr_decimal_pfpj;
    vr_pacvljur_4        typ_arr_decimal_pfpj;
    vr_pacvljur_5        typ_arr_decimal_pfpj;
    vr_pacvljur_6        typ_arr_decimal_pfpj;
    vr_pacvljur_7        typ_arr_decimal_pfpj;
    vr_pacvljur_8        typ_arr_decimal_pfpj; 
    vr_pacvljur_9        typ_arr_decimal_pfpj; 
    vr_pacvljur_10       typ_arr_decimal_pfpj; 
    vr_pacvljur_11       typ_arr_decimal_pfpj; 
    vr_pacvljur_12       typ_arr_decimal_pfpj; 
    vr_pacvljur_13       typ_arr_decimal_pfpj; 
    vr_pacvljur_14        typ_arr_decimal_pfpj;
    vr_pacvljur_15        typ_arr_decimal_pfpj;
    vr_pacvljur_16        typ_arr_decimal_pfpj;
    vr_pacvljur_17        typ_arr_decimal_pfpj;
    vr_pacvljur_18        typ_arr_decimal_pfpj;
    vr_pacvljur_19        typ_arr_decimal_pfpj;

    vr_pacvljur_20        typ_arr_decimal_pfpj;
    vr_pacvljur_21        typ_arr_decimal_pfpj;
    vr_pacvljur_22        typ_arr_decimal_pfpj;
    vr_pacvljur_23        typ_arr_decimal_pfpj; 

    vr_vldjuros          typ_decimal_pfpj;
    vr_finjuros          typ_decimal_pfpj;
    vr_vldjuros2         typ_decimal_pfpj;
    vr_finjuros2         typ_decimal_pfpj;
    vr_vlmrapar2         typ_decimal_pfpj; 
    vr_fimrapar2         typ_decimal_pfpj; 
    vr_vljuropp2         typ_decimal_pfpj; 
    vr_fijuropp2         typ_decimal_pfpj; 
    vr_vlmultpp2         typ_decimal_pfpj; 
    vr_fimultpp2         typ_decimal_pfpj; 
    vr_vldjuros6         typ_decimal_pfpj;
    vr_finjuros6         typ_decimal_pfpj;
    vr_vlmrapar6         typ_decimal_pfpj; 
    vr_fimrapar6         typ_decimal_pfpj; 
    vr_vljuremu6         typ_decimal_pfpj; 
    vr_fijuremu6         typ_decimal_pfpj; 
    vr_vljurcor6         typ_decimal_pfpj; 
    vr_fijurcor6         typ_decimal_pfpj; 
    vr_vljurmta6         typ_decimal_pfpj; 
    vr_fijurmta6         typ_decimal_pfpj; 

    vr_vldjuros3         typ_decimal_pfpj;

    vr_vldjur_calc       typ_decimal_pfpj;
    vr_finjur_calc       typ_decimal_pfpj;
    vr_vldjur_calc2      typ_decimal_pfpj;
    vr_finjur_calc2      typ_decimal_pfpj;
    vr_vlmrap_calc2      typ_decimal_pfpj; 
    vr_fimrap_calc2      typ_decimal_pfpj; 
    vr_vljuro_calc2      typ_decimal_pfpj; 
    vr_fijuro_calc2      typ_decimal_pfpj; 
    vr_vlmult_calc2      typ_decimal_pfpj; 
    vr_fimult_calc2      typ_decimal_pfpj; 
    vr_vljuco_calc2      typ_decimal_pfpj; 
    vr_fijuco_calc2      typ_decimal_pfpj; 
    vr_vldjur_calc3      typ_decimal_pfpj;
    vr_vldjur_calc6      typ_decimal_pfpj;
    vr_finjur_calc6      typ_decimal_pfpj;
    vr_vlmrapar_calc6    typ_decimal_pfpj; 
    vr_fimrapar_calc6    typ_decimal_pfpj; 
    vr_vljuremu_calc6    typ_decimal_pfpj; 
    vr_fijuremu_calc6    typ_decimal_pfpj; 
    vr_vljurcor_calc6    typ_decimal_pfpj; 
    vr_fijurcor_calc6    typ_decimal_pfpj; 

    vr_vljurmta_calc6    typ_decimal_pfpj; 
    vr_fijurmta_calc6    typ_decimal_pfpj; 

    vr_juros38df_calc    typ_decimal_pfpj;
    vr_juros38da_calc    typ_decimal_pfpj;
    vr_taxas37_calc      typ_decimal_pfpj;
    vr_juros57_calc      typ_decimal_pfpj;

    vr_juros38df          typ_decimal_pfpj;
    vr_juros38da          typ_decimal_pfpj;
    vr_taxas37            typ_decimal_pfpj;
    vr_juros57            typ_decimal_pfpj;

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
    
    vr_vlag0101          typ_arr_decimal_pfpj;
    vr_vlag0101_1722_v   typ_arr_decimal_pfpj;
    vr_vlag0201          typ_arr_decimal_pfpj;
    vr_vlag0201_1722_v   typ_arr_decimal_pfpj;
    vr_vlag0299_1613     typ_arr_decimal_pfpj;
    vr_vlag1724          typ_arr_decimal_pfpj;  
    vr_vlag1724_bdt      typ_arr_decimal_pfpj;

    vr_vlag0101_1611     typ_arr_decimal;
    vr_vlag0201_1622     typ_arr_decimal;
    vr_vlag1721          typ_arr_decimal; 
    vr_vlag1721_imob     typ_arr_decimal; 
    vr_vlag1723          typ_arr_decimal; 
    vr_vlag1723_imob     typ_arr_decimal; 
    vr_vlag1731_1        typ_arr_decimal; 
    vr_vlag1731_2        typ_arr_decimal; 
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


    vr_vldespes_pj_pos     NUMBER := 0;
    vr_vldespes_pf_pos     NUMBER := 0;
    vr_vldevedo_pf_v_pos   NUMBER := 0;
    vr_vldevedo_pj_v_pos   NUMBER := 0;
    vr_vlag1731_1_pos    typ_arr_decimal;
    vr_vlag1731_2_pos    typ_arr_decimal;

    vr_rel1721_v_pos       NUMBER := 0;
    vr_rel1721_pos         NUMBER := 0;

    vr_rel1723_pos         NUMBER := 0;
    vr_rel1723_v_pos       NUMBER := 0;
    vr_vlag1721_pos        typ_arr_decimal; 
    vr_vlag1723_pos        typ_arr_decimal; 


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
    vr_rendaapropr   typ_arr_decimal_pfpj ; 
    vr_apropjurmra   typ_arr_decimal_pfpj ; 

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
    vr_vldevedo          typ_vldcctab;  
    vr_vldevepj          typ_vldcctab;  
    vr_vldespes          typ_vldcctab;  
    vr_vldesppj          typ_vldcctab;  
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


    vr_cdprogra          CONSTANT cecred.crapprg.cdprogra%TYPE := 'RISCO';
    vr_cdcritic          PLS_INTEGER;
    vr_dscritic          VARCHAR2(4000);
    vr_contacon          INTEGER;
    vr_nrdcctab_c        VARCHAR(15);
    vr_dtrefere          DATE;

    vr_ind_arquivo       utl_file.file_type;
    vr_utlfileh          VARCHAR2(4000);
    vr_nmarquiv          VARCHAR2(100);
    vr_dscomando         VARCHAR2(4000);

    vr_typ_saida         VARCHAR2(4000);

    vr_dtincorp cecred.crapdat.dtmvtolt%TYPE;
    vr_cdcopant cecred.craptco.cdcopant%TYPE;

    vr_valjur60          NUMBER := 0;
    vr_dsjur60           VARCHAR2(10) := 'JUROS 60 ';
    vr_jurchave2         VARCHAR(53);

    vr_datacorte_1902    DATE;
    vr_cdmodali          cecred.crapris.cdmodali%TYPE;
    vr_cdmodali2         cecred.crapris.cdmodali%TYPE;

    vr_total_jur60       NUMBER := 0; 
    vr_total_jur60_r     NUMBER := 0; 

    vr_saldo_opera       NUMBER := 0; 
    vr_saldo_opera_r     NUMBER := 0; 

    vr_prov_perdas       NUMBER := 0; 
    vr_prov_perdas_r     NUMBER := 0; 

    vr_flverbor cecred.crapbdt.flverbor%TYPE;
    vr_desconsid_microcredito     NUMBER := 0;

    vr_vltotorc            cecred.crapsdc.vllanmto%type;
    vr_flgctpas            boolean; 
    vr_flgctred            boolean; 
    vr_flgrvorc            boolean; 
    vr_dshcporc            varchar2(100);
    vr_lsctaorc            varchar2(100);
    vr_dtmvtolt_yymmdd     varchar2(6);
    vr_dshstorc            varchar2(240);
    

    type typ_cratorc is record (vr_cdagenci  cecred.crapass.cdagenci%type,
                                vr_vllanmto  cecred.crapsdc.vllanmto%type);
    type typ_tab_cratorc is table of typ_cratorc index by binary_integer;
    vr_tab_cratorc         typ_tab_cratorc;
    
    PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
    BEGIN
      cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
    END;


    procedure pc_proc_lista_orcamento is
      vr_ger_dsctaorc    varchar2(50);
      vr_pac_dsctaorc    varchar2(50);
      vr_dtmvto          date;
      vr_indice_agencia  cecred.crapass.cdagenci%type;
    BEGIN

      if vr_vltotorc = 0 THEN
        return;
      end IF;
      if vr_flgctpas then  
        if vr_flgctred then 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else  
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        else  
          if vr_flgrvorc then 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else  
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        end if;
      else  
        if vr_flgctred then 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else  
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        else  
          if vr_flgrvorc then  
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else  
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        end if;
      end if;

      if vr_flgrvorc then
        vr_dtmvto := vr_dtmvtopr;
      else
        vr_dtmvto := vr_dtmvtolt;
      end if;

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
      
      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_pac_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);

      pc_gravar_linha(vr_linhadet);
      
      vr_indice_agencia := vr_tab_cratorc.first;
      WHILE vr_indice_agencia IS NOT NULL LOOP
        if vr_tab_cratorc(vr_indice_agencia).vr_vllanmto <> 0 then
          vr_linhadet := to_char(vr_tab_cratorc(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                         trim(to_char(vr_tab_cratorc(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_cratorc.next(vr_indice_agencia);
      END LOOP;
      
    END;
  BEGIN
    vr_dtrefere := to_date(pr_dtrefere, 'dd/mm/YY');
    
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
      vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
      RAISE vr_exc_erro;
    END IF;
    

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


    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('2').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('2').nrdconta := 3321;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('2').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('2').nrdconta := 3321;
    
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('3').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('3').nrdconta := 3333;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('3').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('3').nrdconta := 3333;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('4').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('4').nrdconta := 3343;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('4').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('4').nrdconta := 3343;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('5').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('5').nrdconta := 3353;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('5').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('5').nrdconta := 3353;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('6').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('6').nrdconta := 3363;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('6').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('6').nrdconta := 3363;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('7').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('7').nrdconta := 3373;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('7').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('7').nrdconta := 3373;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('8').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('8').nrdconta := 3383;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('8').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('8').nrdconta := 3383;

    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)('9').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)('9').nrdconta := 3393;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_deb)('9').nrdconta := 9302;
    vr_tab_contas(vr_price_atr)(vr_price_pj)(vr_price_cre)('9').nrdconta := 3393;


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


    FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
      vr_contador                         := substr(rw_craptab.dstextab, 12, 2);
      vr_rel_dsdrisco(vr_contador).dsc    := TRIM(substr(rw_craptab.dstextab, 8, 3));
      vr_rel_percentu(vr_contador).valor  := substr(rw_craptab.dstextab, 1, 6);
    END LOOP;

    FOR rw_tabmicro IN cr_tabmicro(pr_cdcooper) LOOP
        vr_arrchave1 := vr_price_pre||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_arrchave1 := vr_price_pre||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_arrchave1 := vr_price_atr||vr_price_pf;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_arrchave1 := vr_price_atr||vr_price_pj;
        vr_arrchave2 := (LPAD(rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).dsc   := '';

        vr_jurchave2 := (LPAD(vr_dsjur60||rw_tabmicro.dsorgrec,50,' ')||LPAD(rw_tabmicro.cdagenci,3,0));
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).dsc   := '';

        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).valor := 0;
        vr_tab_microcredito_desconsid(vr_arrchave1)(vr_jurchave2).dsc   := '';

    END LOOP;

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
      

      IF rw_crapris.cdorigem = 1 THEN
        vr_vldivida := vr_vldivida + nvl(rw_crapris.vljura60,0);
      END IF;

      vr_valjur60 := nvl(rw_crapris.vljura60,0) + nvl(rw_crapris.vljurantpp,0);
      vr_flsomjur := 0;

      FOR rw_crapvri IN cr_crapvri(pr_cdcooper,
                                   rw_crapris.nrdconta,
                                   rw_crapris.dtrefere,
                                   rw_crapris.cdmodali,
                                   rw_crapris.nrctremp,
                                   rw_crapris.nrseqctr,
                                   rw_crapris.vldivida) LOOP

        vr_contador := 0;
        vr_flsoavto := TRUE;

        IF  rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vldivida := vr_vldivida + NVL(rw_crapvri.vldivida,0);
        ELSIF rw_crapvri.cdvencto IN (310,320,330) THEN 
          vr_vlprejuz_conta := vr_vlprejuz_conta + NVL(rw_crapvri.vldivida,0);
        END IF;

        IF rw_crapris.cdmodali = 0101 AND
           rw_crapris.innivris = 10   THEN
          vr_vldivida := 0;
        END IF;

        IF  rw_crapvri.cdvencto BETWEEN 110 AND 205 THEN 

          OPEN cr_crabvri(pr_cdcooper,
                          rw_crapvri.nrdconta,
                          rw_crapvri.dtrefere,
                          rw_crapvri.cdmodali,
                          rw_crapvri.nrctremp,
                          rw_crapvri.nrseqctr);
          FETCH cr_crabvri INTO rw_crabvri;
          IF cr_crabvri%FOUND THEN
            vr_flsoavto := FALSE;
          END IF;
          CLOSE cr_crabvri;
        END IF;

        IF rw_crapris.innivris IN (1,2) THEN
          vr_contador := rw_crapris.innivris;
        ELSIF rw_crapvri.cdvencto BETWEEN 110 AND 205 AND vr_flsoavto AND 
              nvl(rw_crapris.nracordo,0) = 0 THEN

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

        IF vr_rel_vldivida.exists(vr_contador) THEN
          vr_rel_vldivida(vr_contador).valor := nvl(vr_rel_vldivida(vr_contador).valor, 0) + rw_crapvri.vldivida;
        ELSE
          vr_rel_vldivida(vr_contador).valor := rw_crapvri.vldivida;
        END IF;

        IF rw_crapvri.cdvencto IN (310,320,330) THEN
          CONTINUE; 
        END IF;


        IF vr_vldevedo.exists(vr_contador) THEN
          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapvri.vldivida;
        ELSE
          vr_vldevedo(vr_contador) := rw_crapvri.vldivida;
        END IF;
        
        IF rw_crapris.cdmodali = 101 AND 
           vr_flsomjur = 0 AND
           rw_crapris.vljura60 > 0 
           THEN

          vr_flsomjur := 1;

          vr_vldevedo(vr_contador) := nvl(vr_vldevedo(vr_contador), 0) + rw_crapris.vljura60;   
          vr_rel_vldivida(vr_contador).valor := vr_rel_vldivida(vr_contador).valor + rw_crapris.vljura60;
        END IF;
      END LOOP;  


      vr_contador := rw_crapris.innivris;

      IF vr_vlprejuz_conta = (rw_crapris.vldivida + nvl(rw_crapris.vljura60, 0) + nvl(rw_crapris.vljurantpp, 0)) THEN
        CONTINUE;
      END IF;

      IF vr_rel_percentu.exists(vr_contador) THEN
         vr_vlpercen := vr_rel_percentu(vr_contador).valor / 100;
      ELSE
        vr_vlpercen := 0;
      END IF;

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

      vr_vlpreatr := round((rw_crapris.vldivida *  vr_vlpercen), 2); 
      GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => rw_crapris.cdcooper,
                                               pr_nrdconta => rw_crapris.nrdconta,
                                               pr_nrctremp => rw_crapris.nrctremp,
                                               pr_cdmodali => rw_crapris.cdmodali,
                                               pr_vlpreatr => vr_vlpreatr,
                                               pr_dscritic => vr_dscritic);

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
      IF rw_crapris.cdorigem = 3 THEN

        OPEN cr_crapepr(rw_crapris.cdcooper,
                        rw_crapris.nrdconta,
                        rw_crapris.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;

        IF cr_crapepr%NOTFOUND THEN

          OPEN cr_crapebn(rw_crapris.cdcooper,
                          rw_crapris.nrdconta,
                          rw_crapris.nrctremp);

          FETCH cr_crapebn INTO rw_crapebn;

          IF cr_crapebn%NOTFOUND THEN

            OPEN cr_imob(rw_crapris.cdcooper,
                         rw_crapris.nrdconta,
                         rw_crapris.nrctremp);

            FETCH cr_imob INTO rw_imob;

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

        CLOSE cr_crapepr;

        OPEN cr_cessao (pr_cdcooper => rw_crapris.cdcooper,
                        pr_nrdconta => rw_crapris.nrdconta,
                        pr_nrctremp => rw_crapris.nrctremp);
        FETCH cr_cessao INTO vr_fleprces;
        CLOSE cr_cessao;

      END IF;

      IF  vr_fleprces = 1 THEN
        IF rw_crapris.inpessoa = 1 THEN

          IF rw_crapepr.tpemprst = 1 THEN

            vr_rel1760_pre   := vr_rel1760_pre   + vr_vlpreatr;
            vr_rel1760_v_pre := vr_rel1760_v_pre + vr_vldivida;

            IF vr_vlag1760_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1760_pre(rw_crapris.cdagenci).valor := vr_vlag1760_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1760_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            vr_rel1721_pre   := vr_rel1721_pre   + vr_vlpreatr;
            IF vr_vlag1721_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlag1721_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          END IF;
        ELSE 
          IF rw_crapepr.tpemprst = 1 THEN

            vr_rel1761_pre   := vr_rel1761_pre + vr_vlpreatr;
            vr_rel1761_v_pre := vr_rel1761_v_pre + vr_vldivida;

            IF vr_vlag1761_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1761_pre(rw_crapris.cdagenci).valor := vr_vlag1761_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1761_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

            vr_rel1723_pre   := vr_rel1723_pre + vr_vlpreatr;
            IF vr_vlag1723_pre.exists(rw_crapris.cdagenci) THEN
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlag1723_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
            ELSE
              vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
            END IF;

          END IF;
        END IF;
      ELSE  


        IF  rw_crapris.cdorigem = 3 AND rw_crapris.cdmodali = 0299 THEN
          IF rw_crapris.inpessoa = 1 THEN
            IF rw_crapepr.tpemprst = 0 THEN

              vr_rel1721   := vr_rel1721   + vr_vlpreatr;
              vr_rel1721_v := vr_rel1721_v + vr_vldivida;

              IF vr_vlag1721.exists(rw_crapris.cdagenci) THEN
                vr_vlag1721(rw_crapris.cdagenci).valor := vr_vlag1721(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1721(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

            ELSIF rw_crapepr.tpemprst = 1 THEN

              vr_rel1721_pre   := vr_rel1721_pre   + vr_vlpreatr;
              vr_rel1721_v_pre := vr_rel1721_v_pre + vr_vldivida;

              IF vr_vlag1721_pre.exists(rw_crapris.cdagenci) THEN
                vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlag1721_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1721_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

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

          ELSE 
            IF rw_crapepr.tpemprst = 0 THEN

              vr_rel1723   := vr_rel1723   + vr_vlpreatr;
              vr_rel1723_v := vr_rel1723_v + vr_vldivida;

              IF vr_vlag1723.exists(rw_crapris.cdagenci) THEN
                vr_vlag1723(rw_crapris.cdagenci).valor := vr_vlag1723(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1723(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

            ELSIF rw_crapepr.tpemprst = 1 THEN

              vr_rel1723_pre   := vr_rel1723_pre + vr_vlpreatr;
              vr_rel1723_v_pre := vr_rel1723_v_pre + vr_vldivida;

              IF vr_vlag1723_pre.exists(rw_crapris.cdagenci) THEN
                vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlag1723_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1723_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

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
        END IF;  


        IF  rw_crapris.cdorigem = 3 AND rw_crapris.cdmodali = 0499 THEN

          OPEN cr_craplcr(rw_crapris.cdcooper,
                          rw_crapris.nrdconta,
                          rw_crapris.nrctremp);
          FETCH cr_craplcr INTO rw_craplcr;
          CLOSE cr_craplcr;

        vr_desconsid_microcredito := 0;
        OPEN cr_crapebn_desconsid_microcred(rw_crapris.cdcooper,
                               rw_crapris.nrdconta,
                               rw_crapris.nrctremp);
        FETCH cr_crapebn_desconsid_microcred INTO vr_desconsid_microcredito;
        CLOSE cr_crapebn_desconsid_microcred;

          IF rw_crapris.inpessoa = 1 THEN
            IF rw_crapepr.tpemprst = 0 THEN

              vr_rel1731_1   := vr_rel1731_1   + vr_vlpreatr;
              vr_rel1731_1_v := vr_rel1731_1_v + vr_vldivida;

              IF vr_vlag1731_1.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_1(rw_crapris.cdagenci).valor := vr_vlag1731_1(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_1(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;


              IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                IF rw_craplcr.dsorgrec <> 'MICROCREDITO PNMPO CAIXA' OR pr_cdcooper <> 3 THEN
                  vr_arrchave1 := vr_price_atr||vr_price_pf;
                  vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
                  vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));


                  vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;

                  vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
                  vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;


               IF vr_desconsid_microcredito = 1 THEN
                 vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
                END IF;
              END IF;

            
            ELSIF rw_crapepr.tpemprst = 1 THEN

              vr_rel1731_1_pre   := vr_rel1731_1_pre   + vr_vlpreatr;
              vr_rel1731_1_v_pre := vr_rel1731_1_v_pre + vr_vldivida;

              IF vr_vlag1731_1_pre.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_1_pre(rw_crapris.cdagenci).valor := vr_vlag1731_1_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_1_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

              
              IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                 vr_arrchave1 := vr_price_pre||vr_price_pf;
                 vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
                 vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));

                 
                 vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
                 
                 vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
                 vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;

               
               IF vr_desconsid_microcredito = 1 THEN
                 vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
              END IF;

            
            ELSIF rw_crapepr.tpemprst = 2 THEN

              vr_vldespes_pf_pos   := vr_vldespes_pf_pos   + vr_vlpreatr;
              vr_vldevedo_pf_v_pos := vr_vldevedo_pf_v_pos + vr_vldivida;

              IF vr_vlag1731_1_pos.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_1_pos(rw_crapris.cdagenci).valor := vr_vlag1731_1_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_1_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

            END IF;

          ELSE  

            
            OPEN cr_crapebn(rw_crapris.cdcooper,
                            rw_crapris.nrdconta,
                            rw_crapris.nrctremp);

            FETCH cr_crapebn INTO rw_crapebn;

            
            IF cr_crapebn%NOTFOUND THEN
              CLOSE cr_crapebn;

            
            IF rw_crapepr.tpemprst = 0 THEN

              vr_rel1731_2   := vr_rel1731_2   + vr_vlpreatr;
              vr_rel1731_2_v := vr_rel1731_2_v + vr_vldivida;

              IF vr_vlag1731_2.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_2(rw_crapris.cdagenci).valor := vr_vlag1731_2(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_2(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

              
              IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                IF rw_craplcr.dsorgrec <> 'MICROCREDITO PNMPO CAIXA' OR pr_cdcooper <> 3 THEN
                  vr_arrchave1 := vr_price_atr||vr_price_pj;
                  vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
                  vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));

               
                  vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               
                  vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
                  vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;

               
               IF vr_desconsid_microcredito = 1 THEN
                  vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
                END IF;
              END IF;
              
            ELSIF rw_crapepr.tpemprst = 1 THEN 

              vr_rel1731_2_pre   := vr_rel1731_2_pre   + vr_vlpreatr;
              vr_rel1731_2_v_pre := vr_rel1731_2_v_pre + vr_vldivida;

              IF vr_vlag1731_2_pre.exists(rw_crapris.cdagenci) THEN
                vr_vlag1731_2_pre(rw_crapris.cdagenci).valor := vr_vlag1731_2_pre(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlag1731_2_pre(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

              
              IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                 vr_arrchave1 := vr_price_pre||vr_price_pj;
                 vr_arrchave2 := (LPAD(rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));
                 vr_jurchave2 := (LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||LPAD(rw_crapris.cdagenci,3,0));

                 
                 vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                 vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
                 
                 vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito(vr_arrchave1)(LPAD(vr_dsjur60||rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_valjur60;
                 vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor := vr_tab_microcredito(vr_arrchave1)(vr_jurchave2).valor + vr_valjur60;

               
               IF vr_desconsid_microcredito = 1 THEN
                  vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor := vr_tab_microcredito_desconsid(vr_arrchave1)(LPAD(rw_craplcr.dsorgrec,50,' ')||'999').valor + vr_vldivida;
                  vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor := vr_tab_microcredito_desconsid(vr_arrchave1)(vr_arrchave2).valor + vr_vldivida;
               END IF;
              END IF;

              
              ELSIF rw_crapepr.tpemprst = 2 THEN 

                vr_vldespes_pj_pos   := vr_vldespes_pj_pos   + vr_vlpreatr;
                vr_vldevedo_pj_v_pos := vr_vldevedo_pj_v_pos + vr_vldivida;

                IF vr_vlag1731_2_pos.exists(rw_crapris.cdagenci) THEN
                  vr_vlag1731_2_pos(rw_crapris.cdagenci).valor := vr_vlag1731_2_pos(rw_crapris.cdagenci).valor + vr_vlpreatr;
                ELSE
                  vr_vlag1731_2_pos(rw_crapris.cdagenci).valor := vr_vlpreatr;
                END IF;

              END IF;

            ELSE 
              CLOSE cr_crapebn;
              vr_vlempatr_bndes_2 := vr_vlempatr_bndes_2 + vr_vlpreatr;

              IF vr_vlatrage_bndes_2.exists(rw_crapris.cdagenci) THEN
                vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor := vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlatrage_bndes_2(rw_crapris.cdagenci).valor := vr_vlpreatr;
              END IF;

            END IF; 
          END IF; 
        END IF;  

      END IF; 
      IF rw_crapris.cdorigem IN (2,4,5) THEN 
        vr_flverbor := 0;
        IF rw_crapris.cdorigem = 5 THEN
          BEGIN
            SELECT bdt.flverbor
            INTO   vr_flverbor
            FROM   cecred.crapbdt bdt
            WHERE  bdt.nrdconta = rw_crapris.nrdconta
            AND    bdt.nrborder = rw_crapris.nrctremp
            AND    bdt.cdcooper = rw_crapris.cdcooper;
          EXCEPTION
            WHEN OTHERS THEN
              vr_flverbor := 0;
          END;
        END IF;

        IF vr_flverbor = 1 THEN
        
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

      
      IF rw_crapris.cdorigem = 1 THEN
      
        IF rw_crapris.cdmodali = 0201 THEN
      
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

          ELSE  
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

        ELSE  

          IF vr_vldivida_sldblq <> 0 THEN  

            
             
            IF rw_crapris.inpessoa = 1 THEN 
              vr_rel1613_0299_v.valorpf := vr_rel1613_0299_v.valorpf + vr_vldivida_sldblq;

              IF vr_vlag0299_1613.exists(rw_crapris.cdagenci) THEN
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpf := NVL(vr_vlag0299_1613(rw_crapris.cdagenci).valorpf,0) +
                                                                 vr_vldivida_sldblq;
              ELSE
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpf := vr_vldivida_sldblq;
              END IF;

            ELSE  
              vr_rel1613_0299_v.valorpj := vr_rel1613_0299_v.valorpj + vr_vldivida_sldblq;

              IF vr_vlag0299_1613.exists(rw_crapris.cdagenci) THEN
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpj := NVL(vr_vlag0299_1613(rw_crapris.cdagenci).valorpj,0) +
                                                                 vr_vldivida_sldblq;
              ELSE
                vr_vlag0299_1613(rw_crapris.cdagenci).valorpj := vr_vldivida_sldblq;
              END IF;
            END IF;

          END IF;

          
          IF rw_crapris.inpessoa = 1 THEN 

            
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

          ELSE  

            
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
      
      
      IF rw_crapris.inpessoa = 1 THEN  
        IF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFH' AND rw_crapris.cdmodali IN (901,902,903,990)  THEN 
          
          vr_vlatr_imobi_sfh_pf   := vr_vlatr_imobi_sfh_pf + vr_vlpreatr;
          vr_vlatr_imobi_v_sfh_pf := vr_vlatr_imobi_v_sfh_pf + vr_vldivida;          

          
          IF vr_vlatrage_imob_sfh_pf.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfh_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;      
          END IF;  

        ELSIF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFI' AND rw_crapris.cdmodali IN (901,902,903,990) THEN 
          
          vr_vlatr_imobi_sfi_pf   := vr_vlatr_imobi_sfi_pf + vr_vlpreatr;
          vr_vlatr_imobi_v_sfi_pf := vr_vlatr_imobi_v_sfi_pf + vr_vldivida;             

          
          IF vr_vlatrage_imob_sfi_pf.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfi_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;      
          END IF;  
                  
        ELSIF rw_crapris.cdorigem = 3 AND 
              rw_crapris.cdmodali = 0211 AND 
              rw_imob.modelo_aquisicao_completo IS NOT NULL AND 
              TRIM(rw_crapris.dsinfaux) = 'IMOBILIARIO' THEN 
             
              vr_vlatr_imobi_home_equity_pf   := vr_vlatr_imobi_home_equity_pf + vr_vlpreatr;
              vr_vlatr_imobi_v_home_equity_pf := vr_vlatr_imobi_v_home_equity_pf + vr_vldivida;             

              
              IF vr_vlatrage_imob_home_equity_pf.exists(rw_crapris.cdagenci) THEN
                vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor := vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor + vr_vlpreatr;
              ELSE
                vr_vlatrage_imob_home_equity_pf(rw_crapris.cdagenci).valor := vr_vlpreatr;      
              END IF;  
        END IF;
      ELSE 
        IF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFH' AND rw_crapris.cdmodali IN (901,902,903,990) THEN 
          
          vr_vlatr_imobi_sfh_pj   := vr_vlatr_imobi_sfh_pj + vr_vlpreatr;
          vr_vlatr_imobi_v_sfh_pj := vr_vlatr_imobi_v_sfh_pj + vr_vldivida;   
          
          
          IF vr_vlatrage_imob_sfh_pj.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfh_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;      
          END IF;  

        ELSIF rw_crapris.cdorigem = 3 AND rw_imob.modelo_aquisicao = 'SFI' AND rw_crapris.cdmodali IN (901,902,903,990) THEN
          
          vr_vlatr_imobi_sfi_pj   := vr_vlatr_imobi_sfi_pj + vr_vlpreatr;
          vr_vlatr_imobi_v_sfi_pj := vr_vlatr_imobi_v_sfi_pj + vr_vldivida;   
          
          IF vr_vlatrage_imob_sfi_pj.exists(rw_crapris.cdagenci) THEN
            vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_vlatrage_imob_sfi_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;      
          END IF;  
                  
        END IF;          
      END IF;
      
      
      IF rw_crapris.cdorigem = 3 AND 
         rw_imob.modelo_aquisicao = 'SFI' AND 
         rw_crapris.cdmodali = 902 AND
         INSTR(rw_imob.modelo_aquisicao_completo,'TERRENO') > 0 THEN
      
        vr_vlatr_imobi_terreno_pf_pj   := vr_vlatr_imobi_terreno_pf_pj + vr_vlpreatr;
        vr_vlatr_imobi_v_terreno_pf_pj := vr_vlatr_imobi_v_terreno_pf_pj + vr_vldivida;             

      
        IF vr_vlatrage_imob_terreno_pf_pj.exists(rw_crapris.cdagenci) THEN
           vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor := vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor + vr_vlpreatr;
        ELSE
           vr_vlatrage_imob_terreno_pf_pj(rw_crapris.cdagenci).valor := vr_vlpreatr;      
        END IF;
      END IF;  
      
      
    END LOOP; 

    
    gestaoderisco.buscaDataCorteLimite1902(pr_cdcooper => pr_cdcooper,
                                           pr_dtdcorte => vr_datacorte_1902,
                                           pr_dscritic => vr_dscritic);
    
    IF vr_dtrefere >= vr_datacorte_1902 THEN
    
      vr_cdmodali := 1902;
      vr_cdmodali2 := 1909; 
    ELSE
      vr_cdmodali := 1901;
    END IF;

    
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
    vr_vlmrapar2.valorpf := 0; 
    vr_vlmrapar2.valorpj := 0; 
    vr_fimrapar2.valorpf := 0; 
    vr_fimrapar2.valorpj := 0; 
    vr_vljuropp2.valorpf := 0; 
    vr_vljuropp2.valorpj := 0; 
    vr_fijuropp2.valorpf := 0; 
    vr_fijuropp2.valorpj := 0; 
    vr_vlmultpp2.valorpf := 0; 
    vr_vlmultpp2.valorpj := 0; 
    vr_fimultpp2.valorpf := 0; 
    vr_fimultpp2.valorpj := 0; 
    vr_finjuros.valorpf  := 0;
    vr_finjuros.valorpj  := 0;
    vr_finjuros2.valorpf := 0;
    vr_finjuros2.valorpj := 0;
    vr_vldjuros6.valorpf := 0;
    vr_vldjuros6.valorpj := 0;
    vr_finjuros6.valorpf := 0;
    vr_finjuros6.valorpj := 0;
    vr_vlmrapar6.valorpf := 0;
    vr_vlmrapar6.valorpj := 0;
    vr_fimrapar6.valorpf := 0;
    vr_fimrapar6.valorpj := 0;
    vr_vljuremu6.valorpf := 0;
    vr_vljuremu6.valorpj := 0;
    vr_fijuremu6.valorpf := 0;
    vr_fijuremu6.valorpj := 0;
    vr_vljurcor6.valorpf := 0;
    vr_vljurcor6.valorpj := 0;
    vr_fijurcor6.valorpf := 0;
    vr_fijurcor6.valorpj := 0;

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
                          ,pr_tabvljur1 => vr_pacvljur_1     
                          ,pr_tabvljur2 => vr_pacvljur_2     
                          ,pr_tabvljur3 => vr_pacvljur_3     
                          ,pr_tabvljur4 => vr_pacvljur_4     
                          ,pr_tabvljur5 => vr_pacvljur_5     
                          ,pr_tabvljur6 => vr_pacvljur_6     
                          ,pr_tabvljur7 => vr_pacvljur_7     
                          ,pr_tabvljur8 => vr_pacvljur_8     
                          ,pr_tabvljur9 => vr_pacvljur_9     
                          ,pr_tabvljur10 => vr_pacvljur_10   
                          ,pr_tabvljur11 => vr_pacvljur_11   
                          ,pr_tabvljur12 => vr_pacvljur_12   
                          ,pr_tabvljur13 => vr_pacvljur_13   
                          ,pr_tabvljur14 => vr_pacvljur_14   
                          ,pr_tabvljur15 => vr_pacvljur_15   
                          ,pr_tabvljur16 => vr_pacvljur_16   
                          ,pr_tabvljur17 => vr_pacvljur_17   
                          ,pr_tabvljur18 => vr_pacvljur_18   
                          ,pr_tabvljur19 => vr_pacvljur_19   

                          ,pr_tabvljur20 => vr_pacvljur_20   
                          ,pr_tabvljur21 => vr_pacvljur_21   
                          ,pr_tabvljur22 => vr_pacvljur_22   
                          ,pr_tabvljur23 => vr_pacvljur_23   

                          ,pr_vlrjuros  => vr_vldjur_calc    
                          ,pr_finjuros  => vr_finjur_calc    
                          ,pr_vlrjuros2 => vr_vldjur_calc2   
                          ,pr_finjuros2 => vr_finjur_calc2   
                          ,pr_vlrjuros3 => vr_vldjur_calc3   
                          ,pr_vlrjuros6 => vr_vldjur_calc6   
                          ,pr_finjuros6 => vr_finjur_calc6   
                          ,pr_vlmrapar6 => vr_vlmrapar_calc6 
                          ,pr_fimrapar6 => vr_fimrapar_calc6 
                          ,pr_vljuremu6 => vr_vljuremu_calc6 
                          ,pr_fijuremu6 => vr_fijuremu_calc6 
                          ,pr_vljurcor6 => vr_vljurcor_calc6 
                          ,pr_fijurcor6 => vr_fijurcor_calc6 

                          ,pr_vljurmta6 => vr_vljurmta_calc6 
                          ,pr_fijurmta6 => vr_fijurmta_calc6 

                          ,pr_vlmrapar2 => vr_vlmrap_calc2   
                          ,pr_fimrapar2 => vr_fimrap_calc2   
                          ,pr_vljuropp2 => vr_vljuro_calc2   
                          ,pr_fijuropp2 => vr_fijuro_calc2   
                          ,pr_vlmultpp2 => vr_vlmult_calc2   
                          ,pr_fimultpp2 => vr_fimult_calc2   
                          ,pr_vljurcor2 => vr_vljuco_calc2          
                          ,pr_fijurcor2 => vr_fijuco_calc2           
                          ,pr_juros38_df => vr_juros38df_calc   
                          ,pr_juros38_da => vr_juros38da_calc   
                          ,pr_taxas37   => vr_taxas37_calc      
                          ,pr_juros57    => vr_juros57_calc     
                          ,pr_tabvljuros38_df => vr_tabvljuros38df 
                          ,pr_tabvljuros38_da => vr_tabvljuros38da 
                          ,pr_tabvltaxas37 => vr_tabvltaxas37      
                          ,pr_tabvljuros57 => vr_tabvljuros57);    

    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;

    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; 
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; 
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; 
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; 
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; 
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; 
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; 
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; 
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; 
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; 
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; 
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; 
    
    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;
    vr_vlmrapar6.valorpf := vr_vlmrapar6.valorpf + vr_vlmrapar_calc6.valorpf; 
    vr_vlmrapar6.valorpj := vr_vlmrapar6.valorpj + vr_vlmrapar_calc6.valorpj; 
    vr_fimrapar6.valorpf := vr_fimrapar6.valorpf + vr_fimrapar_calc6.valorpf; 
    vr_fimrapar6.valorpj := vr_fimrapar6.valorpj + vr_fimrapar_calc6.valorpj; 
    vr_vljuremu6.valorpf := vr_vljuremu6.valorpf + vr_vljuremu_calc6.valorpf; 
    vr_vljuremu6.valorpj := vr_vljuremu6.valorpj + vr_vljuremu_calc6.valorpj; 
    vr_fijuremu6.valorpf := vr_fijuremu6.valorpf + vr_fijuremu_calc6.valorpf; 
    vr_fijuremu6.valorpj := vr_fijuremu6.valorpj + vr_fijuremu_calc6.valorpj; 
    vr_vljurcor6.valorpf := vr_vljurcor6.valorpf + vr_vljurcor_calc6.valorpf; 
    vr_vljurcor6.valorpj := vr_vljurcor6.valorpj + vr_vljurcor_calc6.valorpj; 
    vr_fijurcor6.valorpf := vr_fijurcor6.valorpf + vr_fijurcor_calc6.valorpf; 
    vr_fijurcor6.valorpj := vr_fijurcor6.valorpj + vr_fijurcor_calc6.valorpj; 

    vr_vljurmta6.valorpf := vr_vljurmta6.valorpf + vr_vljurmta_calc6.valorpf; 
    vr_vljurmta6.valorpj := vr_vljurmta6.valorpj + vr_vljurmta_calc6.valorpj; 
    vr_fijurmta6.valorpf := vr_fijurmta6.valorpf + vr_fijurmta_calc6.valorpf; 
    vr_fijurmta6.valorpj := vr_fijurmta6.valorpj + vr_fijurmta_calc6.valorpj; 

    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

    pc_calcula_juros_60k( par_cdcooper => pr_cdcooper
                         ,par_dtrefere => vr_dtrefere
                         ,par_cdmodali => 499
                         ,par_dtinicio => vr_dtinicio
                         ,pr_tabvljur1 => vr_pacvljur_1     
                         ,pr_tabvljur2 => vr_pacvljur_2     
                         ,pr_tabvljur3 => vr_pacvljur_3     
                         ,pr_tabvljur4 => vr_pacvljur_4     
                         ,pr_tabvljur5 => vr_pacvljur_5     
                         ,pr_tabvljur6 => vr_pacvljur_6     
                         ,pr_tabvljur7 => vr_pacvljur_7     
                         ,pr_tabvljur8 => vr_pacvljur_8     
                         ,pr_tabvljur9 => vr_pacvljur_9     
                         ,pr_tabvljur10 => vr_pacvljur_10   
                         ,pr_tabvljur11 => vr_pacvljur_11   
                         ,pr_tabvljur12 => vr_pacvljur_12   
                         ,pr_tabvljur13 => vr_pacvljur_13   
                         ,pr_tabvljur14 => vr_pacvljur_14   
                         ,pr_tabvljur15 => vr_pacvljur_15   
                         ,pr_tabvljur16 => vr_pacvljur_16   
                         ,pr_tabvljur17 => vr_pacvljur_17   
                         ,pr_tabvljur18 => vr_pacvljur_18   
                         ,pr_tabvljur19 => vr_pacvljur_19   

                         ,pr_tabvljur20 => vr_pacvljur_20   
                         ,pr_tabvljur21 => vr_pacvljur_21   
                         ,pr_tabvljur22 => vr_pacvljur_22   
                         ,pr_tabvljur23 => vr_pacvljur_23   

                         ,pr_vlrjuros  => vr_vldjur_calc    
                         ,pr_finjuros  => vr_finjur_calc    
                         ,pr_vlrjuros2 => vr_vldjur_calc2     
                         ,pr_finjuros2 => vr_finjur_calc2     
                         ,pr_vlrjuros3 => vr_vldjur_calc3     
                         ,pr_vlrjuros6 => vr_vldjur_calc6     
                         ,pr_finjuros6 => vr_finjur_calc6     
                         ,pr_vlmrapar6 => vr_vlmrapar_calc6   
                         ,pr_fimrapar6 => vr_fimrapar_calc6   
                         ,pr_vljuremu6 => vr_vljuremu_calc6   
                         ,pr_fijuremu6 => vr_fijuremu_calc6   
                         ,pr_vljurcor6 => vr_vljurcor_calc6   
                         ,pr_fijurcor6 => vr_fijurcor_calc6   

                         ,pr_vljurmta6 => vr_vljurmta_calc6 
                         ,pr_fijurmta6 => vr_fijurmta_calc6 

                         ,pr_vlmrapar2 => vr_vlmrap_calc2   
                         ,pr_fimrapar2 => vr_fimrap_calc2   
                         ,pr_vljuropp2 => vr_vljuro_calc2   
                         ,pr_fijuropp2 => vr_fijuro_calc2   
                         ,pr_vlmultpp2 => vr_vlmult_calc2   
                         ,pr_fimultpp2 => vr_fimult_calc2   
                         ,pr_vljurcor2 => vr_vljuco_calc2     
                         ,pr_fijurcor2 => vr_fijuco_calc2           
                         ,pr_juros38_df  => vr_juros38df_calc 
                         ,pr_juros38_da  => vr_juros38da_calc 
                         ,pr_taxas37     => vr_taxas37_calc   
                         ,pr_juros57     => vr_juros57_calc   
                         ,pr_tabvljuros38_df => vr_tabvljuros38df 
                         ,pr_tabvljuros38_da => vr_tabvljuros38da 
                         ,pr_tabvltaxas37 => vr_tabvltaxas37    
                         ,pr_tabvljuros57 => vr_tabvljuros57);    


    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;

    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; 
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; 
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; 
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; 
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; 
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; 
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; 
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; 
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; 
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; 
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; 
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; 

    vr_vldjuros6.valorpf := vr_vldjuros6.valorpf + vr_vldjur_calc6.valorpf;
    vr_vldjuros6.valorpj := vr_vldjuros6.valorpj + vr_vldjur_calc6.valorpj;
    vr_finjuros6.valorpf := vr_finjuros6.valorpf + vr_finjur_calc6.valorpf;
    vr_finjuros6.valorpj := vr_finjuros6.valorpj + vr_finjur_calc6.valorpj;
    vr_vlmrapar6.valorpf := vr_vlmrapar6.valorpf + vr_vlmrapar_calc6.valorpf; 
    vr_vlmrapar6.valorpj := vr_vlmrapar6.valorpj + vr_vlmrapar_calc6.valorpj; 
    vr_fimrapar6.valorpf := vr_fimrapar6.valorpf + vr_fimrapar_calc6.valorpf; 
    vr_fimrapar6.valorpj := vr_fimrapar6.valorpj + vr_fimrapar_calc6.valorpj; 
    vr_vljuremu6.valorpf := vr_vljuremu6.valorpf + vr_vljuremu_calc6.valorpf; 
    vr_vljuremu6.valorpj := vr_vljuremu6.valorpj + vr_vljuremu_calc6.valorpj; 
    vr_fijuremu6.valorpf := vr_fijuremu6.valorpf + vr_fijuremu_calc6.valorpf; 
    vr_fijuremu6.valorpj := vr_fijuremu6.valorpj + vr_fijuremu_calc6.valorpj; 
    vr_vljurcor6.valorpf := vr_vljurcor6.valorpf + vr_vljurcor_calc6.valorpf; 
    vr_vljurcor6.valorpj := vr_vljurcor6.valorpj + vr_vljurcor_calc6.valorpj; 
    vr_fijurcor6.valorpf := vr_fijurcor6.valorpf + vr_fijurcor_calc6.valorpf; 
    vr_fijurcor6.valorpj := vr_fijurcor6.valorpj + vr_fijurcor_calc6.valorpj; 

    vr_vljurmta6.valorpf := vr_vljurmta6.valorpf + vr_vljurmta_calc6.valorpf; 
    vr_vljurmta6.valorpj := vr_vljurmta6.valorpj + vr_vljurmta_calc6.valorpj; 
    vr_fijurmta6.valorpf := vr_fijurmta6.valorpf + vr_fijurmta_calc6.valorpf; 
    vr_fijurmta6.valorpj := vr_fijurmta6.valorpj + vr_fijurmta_calc6.valorpj; 

    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

    pc_calcula_juros_60k (par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_cdmodali => 999              
                          ,par_dtinicio => vr_dtinicio
                          ,pr_tabvljur1 => vr_pacvljur_1    
                          ,pr_tabvljur2 => vr_pacvljur_2    
                          ,pr_tabvljur3 => vr_pacvljur_3    
                          ,pr_tabvljur4 => vr_pacvljur_4    
                          ,pr_tabvljur5 => vr_pacvljur_5    
                          ,pr_tabvljur6 => vr_pacvljur_6    
                          ,pr_tabvljur7 => vr_pacvljur_7    
                          ,pr_tabvljur8 => vr_pacvljur_8    
                          ,pr_tabvljur9 => vr_pacvljur_9    
                          ,pr_tabvljur10 => vr_pacvljur_10  
                          ,pr_tabvljur11 => vr_pacvljur_11  
                          ,pr_tabvljur12 => vr_pacvljur_12  
                          ,pr_tabvljur13 => vr_pacvljur_13  
                          ,pr_tabvljur14 => vr_pacvljur_14  
                          ,pr_tabvljur15 => vr_pacvljur_15  
                          ,pr_tabvljur16 => vr_pacvljur_16  
                          ,pr_tabvljur17 => vr_pacvljur_17  
                          ,pr_tabvljur18 => vr_pacvljur_18   
                          ,pr_tabvljur19 => vr_pacvljur_19   

                          ,pr_tabvljur20 => vr_pacvljur_20   
                          ,pr_tabvljur21 => vr_pacvljur_21   
                          ,pr_tabvljur22 => vr_pacvljur_22   
                          ,pr_tabvljur23 => vr_pacvljur_23   

                          ,pr_vlrjuros  => vr_vldjur_calc    
                          ,pr_finjuros  => vr_finjur_calc    
                          ,pr_vlrjuros2 => vr_vldjur_calc2   
                          ,pr_finjuros2 => vr_finjur_calc2   
                          ,pr_vlrjuros3 => vr_vldjur_calc3   
                          ,pr_vlrjuros6 => vr_vldjur_calc6   
                          ,pr_finjuros6 => vr_finjur_calc6  
                          ,pr_vlmrapar6 => vr_vlmrapar_calc6 
                          ,pr_fimrapar6 => vr_fimrapar_calc6 
                          ,pr_vljuremu6 => vr_vljuremu_calc6 
                          ,pr_fijuremu6 => vr_fijuremu_calc6 
                          ,pr_vljurcor6 => vr_vljurcor_calc6 
                          ,pr_fijurcor6 => vr_fijurcor_calc6 

                          ,pr_vljurmta6 => vr_vljurmta_calc6 
                          ,pr_fijurmta6 => vr_fijurmta_calc6 

                          ,pr_vlmrapar2 => vr_vlmrap_calc2   
                          ,pr_fimrapar2 => vr_fimrap_calc2   
                          ,pr_vljuropp2 => vr_vljuro_calc2   
                          ,pr_fijuropp2 => vr_fijuro_calc2   
                          ,pr_vlmultpp2 => vr_vlmult_calc2   
                          ,pr_fimultpp2 => vr_fimult_calc2   
                          ,pr_vljurcor2 => vr_vljuco_calc2   
                          ,pr_fijurcor2 => vr_fijuco_calc2   
                          ,pr_juros38_df   => vr_juros38df_calc 
                          ,pr_juros38_da   => vr_juros38da_calc 
                          ,pr_taxas37   => vr_taxas37_calc      
                          ,pr_juros57    => vr_juros57_calc     
                          ,pr_tabvljuros38_df => vr_tabvljuros38df 
                          ,pr_tabvljuros38_da => vr_tabvljuros38da 
                          ,pr_tabvltaxas37 => vr_tabvltaxas37      
                          ,pr_tabvljuros57 => vr_tabvljuros57);    


    vr_vldjuros.valorpf  := vr_vldjuros.valorpf  + vr_vldjur_calc.valorpf;
    vr_vldjuros.valorpj  := vr_vldjuros.valorpj  + vr_vldjur_calc.valorpj;
    vr_vldjuros2.valorpf := vr_vldjuros2.valorpf + vr_vldjur_calc2.valorpf;
    vr_vldjuros2.valorpj := vr_vldjuros2.valorpj + vr_vldjur_calc2.valorpj;
    vr_finjuros.valorpf  := vr_finjuros.valorpf  + vr_finjur_calc.valorpf;
    vr_finjuros.valorpj  := vr_finjuros.valorpj  + vr_finjur_calc.valorpj;
    vr_finjuros2.valorpf := vr_finjuros2.valorpf + vr_finjur_calc2.valorpf;
    vr_finjuros2.valorpj := vr_finjuros2.valorpj + vr_finjur_calc2.valorpj;

    
    vr_vlmrapar2.valorpf := vr_vlmrapar2.valorpf + vr_vlmrap_calc2.valorpf; 
    vr_vlmrapar2.valorpj := vr_vlmrapar2.valorpj + vr_vlmrap_calc2.valorpj; 
    vr_fimrapar2.valorpf := vr_fimrapar2.valorpf + vr_fimrap_calc2.valorpf; 
    vr_fimrapar2.valorpj := vr_fimrapar2.valorpj + vr_fimrap_calc2.valorpj; 
    vr_vljuropp2.valorpf := vr_vljuropp2.valorpf + vr_vljuro_calc2.valorpf; 
    vr_vljuropp2.valorpj := vr_vljuropp2.valorpj + vr_vljuro_calc2.valorpj; 
    vr_fijuropp2.valorpf := vr_fijuropp2.valorpf + vr_fijuro_calc2.valorpf; 
    vr_fijuropp2.valorpj := vr_fijuropp2.valorpj + vr_fijuro_calc2.valorpj; 
    vr_vlmultpp2.valorpf := vr_vlmultpp2.valorpf + vr_vlmult_calc2.valorpf; 
    vr_vlmultpp2.valorpj := vr_vlmultpp2.valorpj + vr_vlmult_calc2.valorpj; 
    vr_fimultpp2.valorpf := vr_fimultpp2.valorpf + vr_fimult_calc2.valorpf; 
    vr_fimultpp2.valorpj := vr_fimultpp2.valorpj + vr_fimult_calc2.valorpj; 

    vr_vldjuros3.valorpf := vr_vldjuros3.valorpf + vr_vldjur_calc3.valorpf;
    vr_vldjuros3.valorpj := vr_vldjuros3.valorpj + vr_vldjur_calc3.valorpj;

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


    pc_calcula_juros_60_tdb( par_cdcooper => pr_cdcooper
                          ,par_dtrefere => vr_dtrefere
                          ,par_totrendap => vr_totrendap
                          ,par_totjurmra => vr_totjurmra
                          ,par_rendaapropr => vr_rendaapropr 
                          ,par_apropjurmra => vr_apropjurmra     
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
    
    vr_vldevedo(19) := vr_rel1724_v.valorpf;
    vr_vldespes(19) := vr_rel1724.valorpf;
    vr_vldevepj(19) := vr_rel1724_v.valorpj;
    vr_vldesppj(19) := vr_rel1724.valorpj;
    
    vr_vldevedo(20) := vr_rel1731_1_v;
    vr_vldespes(20) := vr_rel1731_1;
    vr_vldevedo(21) := vr_rel1731_2_v;
    vr_vldespes(21) := vr_rel1731_2;
    
    vr_vldevedo(22) := vr_rel1722_0201_v.valorpf;  
    vr_vldevepj(22) := vr_rel1722_0201_v.valorpj;  
    vr_vldespes(22) := vr_rel1722_0201.valorpf;
    vr_vldesppj(22) := vr_rel1722_0201.valorpj;
    vr_vldevedo(24) := vr_rel1722_0101_v.valorpf;
    vr_vldevepj(24) := vr_rel1722_0101_v.valorpj;
    vr_vldespes(24) := vr_rel1722_0101.valorpf;
    vr_vldesppj(24) := vr_rel1722_0101.valorpj;
    

    
    vr_vldevedo(25) := vr_rel1722_0201_v.valorpf;  
    vr_vldevepj(25) := vr_rel1722_0201_v.valorpj;  
    vr_vldespes(25) := vr_rel1722_0201.valorpf;
    vr_vldesppj(25) := vr_rel1722_0201.valorpj;
    vr_vldevedo(27) := vr_rel1722_0101_v.valorpf;
    vr_vldevepj(27) := vr_rel1722_0101_v.valorpj;
    vr_vldespes(27) := vr_rel1722_0101.valorpf;
    vr_vldesppj(27) := vr_rel1722_0101.valorpj;
    
    vr_vldevedo(28) := vr_rel1721_v_pre;
    vr_vldespes(28) := vr_rel1721_pre;
    vr_vldevedo(29) := vr_rel1723_v_pre;
    vr_vldespes(29) := vr_rel1723_pre;
    vr_vldevedo(30) := vr_rel1731_1_v_pre;
    vr_vldespes(30) := vr_rel1731_1_pre;
    vr_vldevedo(31) := vr_rel1731_2_v_pre;
    vr_vldespes(31) := vr_rel1731_2_pre;
    vr_vldespes(32) := vr_vlempatr_bndes_2;

    
    vr_vldevedo(33) := vr_rel1760_v_pre;
    vr_vldespes(33) := vr_rel1760_pre;
    vr_vldevedo(34) := vr_rel1761_v_pre;
    vr_vldespes(34) := vr_rel1761_pre;

    
    vr_vldevedo(35) := vr_rel1721_v_pos; 
    vr_vldespes(35) := vr_rel1721_pos;   
    vr_vldevedo(36) := vr_rel1723_v_pos; 
    vr_vldespes(36) := vr_rel1723_pos;   

    vr_vldevedo(37) := vr_vldevedo_pf_v_pos;
    vr_vldespes(37) := vr_vldespes_pf_pos;
    vr_vldevedo(38) := vr_vldevedo_pj_v_pos;
    vr_vldespes(38) := vr_vldespes_pj_pos;

    vr_vldespes(39) := vr_vlatr_imobi_sfh_pf;
    vr_vldevedo(39) := vr_vlatr_imobi_v_sfh_pf;
    
    vr_vldespes(40) := vr_vlatr_imobi_sfi_pf;
    vr_vldevedo(40) := vr_vlatr_imobi_v_sfi_pf;

    vr_vldespes(41) := vr_vlatr_imobi_sfh_pj;
    vr_vldevedo(41) := vr_vlatr_imobi_v_sfh_pj;
    
    vr_vldespes(42) := vr_vlatr_imobi_sfi_pj;
    vr_vldevedo(42) := vr_vlatr_imobi_v_sfi_pj;

    vr_vldespes(43) := vr_vlatr_imobi_home_equity_pf;   
    vr_vldevedo(43) := vr_vlatr_imobi_v_home_equity_pf; 

    vr_vldespes(44) := vr_rel1721_imob; 
    vr_vldevedo(44) := vr_rel1721_v_imob; 
    
    vr_vldespes(45) := vr_rel1723_imob; 
    vr_vldevedo(45) := vr_rel1723_v_imob; 

    vr_vldespes(46) := vr_vlatr_imobi_terreno_pf_pj; 
    vr_vldevedo(46) := vr_vlatr_imobi_v_terreno_pf_pj; 

    vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => (vr_dtrefere + 1)
                                              ,pr_tipo      => 'P' );           


    vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => vr_dtrefere
                                              ,pr_tipo      => 'A' );     


    vr_con_dtmvtolt := '70' ||
                       to_char(vr_dtmvtolt, 'yy') ||
                       to_char(vr_dtmvtolt, 'mm') ||
                       to_char(vr_dtmvtolt, 'dd');
    vr_con_dtmvtopr := '70' ||
                       to_char(vr_dtmvtopr, 'yy') ||
                       to_char(vr_dtmvtopr, 'mm') ||
                       to_char(vr_dtmvtopr, 'dd');


    vr_utlfileh := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/contab') ;

    
    vr_nmarquiv := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO_NOVA_CENTRAL.TMP';
    pr_retfile  := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO_NOVA_CENTRAL.txt';

    
    cecred.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh       
                            ,pr_nmarquiv => vr_nmarquiv       
                            ,pr_tipabert => 'W'               
                            ,pr_utlfileh => vr_ind_arquivo    
                            ,pr_des_erro => vr_dscritic);     

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_file_erro;
    END IF;

    
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_nrmaxpas := rw_crapage.cdagenci;
      vr_cdccuage(rw_crapage.cdagenci).dsc := rw_crapage.cdccuage;
    END LOOP;

    
    vr_ttlanmto        := 0;
    vr_ttlanmto_risco  := 0;
    vr_ttlanmto_divida := 0; 

    
    IF rw_crapdat.dtmvtolt IS NULL THEN
      vr_cdcritic := 1;
    
      vr_dscritic := cecred.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper, pr_ind_tipo_log => 1 
                                , pr_des_log => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                ' - ' || vr_cdprogra ||
                                                ' -> ' || vr_dscritic);
    ELSE
      
      vr_dtmovime := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                ,pr_dtmvtolt  => rw_crapdat.dtultdia
                                                ,pr_tipo      => 'A'
                                                ,pr_excultdia => TRUE);
    END IF;

    vr_con_dtmovime := '70' ||
                       to_char(vr_dtmovime, 'yy') ||
                       to_char(vr_dtmovime, 'mm') ||
                       to_char(vr_dtmovime, 'dd');

    

    IF vr_juros38da.valorpf <> 0   THEN
    
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

    IF vr_juros38da.valorpj <> 0  THEN
    
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

    IF vr_juros38da.valormei <> 0 THEN

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

    IF vr_juros38df.valorpf <> 0  THEN

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

    IF vr_juros38df.valorpj <> 0  THEN
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

    IF vr_juros38df.valormei <> 0  THEN

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

    IF vr_taxas37.valorpf <> 0  THEN

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

    
    IF vr_taxas37.valorpj <> 0  THEN
    
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

    
    IF vr_juros57.valorpf <> 0  THEN
    
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

    
    IF vr_juros57.valorpj <> 0  THEN
    
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

    
    IF vr_vldjuros.valorpf <> 0 THEN
    
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',7116,1621,' ||
                     TRIM(to_char(vr_vldjuros.valorpf, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) juros a apropriar EMPRESTIMOS EM ATRASO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF  vr_pacvljur_1.exists(vr_contador)
        AND vr_pacvljur_1(vr_contador).valorpf <> 0 THEN
          
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
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_16.exists(vr_contador) AND
           vr_pacvljur_16(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_16(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;

      
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
      
      FOR vr_contador IN vr_cdccuage.first .. vr_cdccuage.last LOOP
        IF vr_pacvljur_9.exists(vr_contador) AND
           vr_pacvljur_9(vr_contador).valorpj <> 0 THEN
          vr_linhadet := TRIM(to_char(vr_cdccuage(vr_contador).dsc, '009')) || ',' ||
                         TRIM(to_char(vr_pacvljur_9(vr_contador).valorpj, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);

        END IF;
      END LOOP;
    END IF;
    
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

      
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpf , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      
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
      
      pc_gravar_linha(vr_linhadet);

      
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

      
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0201_v.valorpj , '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);

      
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
      
      pc_gravar_linha(vr_linhadet);

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

    IF vr_rel1722_0201_v.valormei <> 0 THEN
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     ',1544,1546,' ||
                     TRIM(to_char(vr_rel1722_0201_v.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA - MEI"';
      
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

      
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) ||
                     ',1546,1544,' ||
                     TRIM(to_char(vr_rel1722_0201_v.valormei, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) SALDO CHEQUE ESPECIAL UTILIZADO PESSOA JURIDICA - MEI"';

      
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

      
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,1613,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      
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

      
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',4112,1613,' ||
                     TRIM(to_char(vr_rel1613_0299_v.valorpj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) SAQUE SOBRE DEPOSITO BLOQUEADO PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      
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

      
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpf, '99999999999990.00'));

      pc_gravar_linha(vr_linhadet);

      
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                     vr_contacon || ',1611,' ||
                     TRIM(to_char((vr_rel1722_0101_v.valorpf - vr_rel1613_0299_v.valorpf), '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA FISICA"';

      pc_gravar_linha(vr_linhadet);

      
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

      
      vr_linhadet := '999,' || TRIM(to_char(vr_rel1722_0101_v.valorpj, '99999999999990.00'));

      pc_gravar_linha(vr_linhadet);

      
      vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                     TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                     vr_contacon || ',1611,' ||
                     TRIM(to_char((vr_rel1722_0101_v.valorpj - vr_rel1613_0299_v.valorpj), '99999999999990.00')) ||
                     ',1434,' || '"(risco) ADIANTAMENTO A DEPOSITANTES PESSOA JURIDICA"';

      pc_gravar_linha(vr_linhadet);

      
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

    
    IF vr_vldespes(24) <> 0 THEN

      vr_vllanmto := vr_vldespes(24);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

      
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

    IF vr_vldesppj(24) <> 0 THEN

      vr_vllanmto := vr_vldesppj(24);
      vr_ttlanmto := vr_ttlanmto + vr_vllanmto;

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

  IF vr_tab_microcredito.EXISTS(vr_price_atr||vr_price_pf) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pf).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := '1';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
                vr_relmicro_atr_pf := vr_tab_microcredito(vr_price_atr||vr_price_pf)(vr_arrchave2||'999').valor;

                
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_atr||vr_price_pf) THEN
                  vr_relmicro_atr_pf_descris := vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pf)(vr_arrchave2||'999').valor;
                  vr_relmicro_atr_pf := vr_relmicro_atr_pf - vr_relmicro_atr_pf_descris;
                END IF;

               
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

  IF vr_tab_microcredito.EXISTS(vr_price_pre||vr_price_pf) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pf).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := 'PF';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
                vr_relmicro_pre_pf := vr_tab_microcredito(vr_price_pre||vr_price_pf)(vr_arrchave2||'999').valor;

                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_pre||vr_price_pf) THEN
                  vr_relmicro_pre_pf_descris := vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pf)(vr_arrchave2||'999').valor;
                  vr_relmicro_pre_pf := vr_relmicro_pre_pf - vr_relmicro_pre_pf_descris;
                END IF;

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

   IF vr_tab_microcredito.EXISTS(vr_price_atr||vr_price_pj) THEN
     vr_contador1 := vr_tab_microcredito(vr_price_atr||vr_price_pj).first;
     IF vr_contador1 <> ' ' THEN
        vr_arrchave2 := '1';
        WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
                vr_relmicro_atr_pj := vr_tab_microcredito(vr_price_atr||vr_price_pj)(vr_arrchave2||'999').valor;

                
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_atr||vr_price_pj) THEN
                  vr_relmicro_atr_pj_descris := vr_tab_microcredito_desconsid(vr_price_atr||vr_price_pj)(vr_arrchave2||'999').valor;
                  vr_relmicro_atr_pj := vr_relmicro_atr_pj - vr_relmicro_atr_pj_descris;
                END IF;

               
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

  
  IF vr_tab_microcredito.EXISTS(vr_price_pre||vr_price_pj) THEN
    vr_contador1 := vr_tab_microcredito(vr_price_pre||vr_price_pj).first;
    IF vr_contador1 <> ' ' THEN
       vr_arrchave2 := 'PF';
       WHILE vr_contador1 IS NOT NULL LOOP
             IF TRIM(vr_arrchave2) <> TRIM(substr(vr_contador1,0,50)) THEN
                vr_arrchave2 := substr(vr_contador1,0,50);
                vr_relmicro_pre_pj := vr_tab_microcredito(vr_price_pre||vr_price_pj)(vr_arrchave2||'999').valor;

                
                IF vr_tab_microcredito_desconsid.EXISTS(vr_price_pre||vr_price_pj) THEN
                  vr_relmicro_pre_pj_descris := vr_tab_microcredito_desconsid(vr_price_pre||vr_price_pj)(vr_arrchave2||'999').valor;
                  vr_relmicro_pre_pj := vr_relmicro_pre_pj - vr_relmicro_pre_pj_descris;
                END IF;

               
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
   

    vr_nrdcctab(1) := '3311.9302';  
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
    vr_nrdcctab(17):= '8442.5584'; 
    vr_nrdcctab(18):= '8442.1723'; 
    vr_nrdcctab(19):= '8442.1724'; 
    vr_nrdcctab(20):= '8442.1731'; 
    vr_nrdcctab(21):= '8442.1731'; 
    vr_nrdcctab(22):= '8442.1722'; 
    vr_nrdcctab(23):= '8442.1722'; 
    vr_nrdcctab(24):= '8442.1722'; 
    vr_nrdcctab(25):= '1622.4112'; 
    vr_nrdcctab(26):= '1613.4112'; 
    vr_nrdcctab(27):= '1611.4112'; 
    vr_nrdcctab(28):= '3987.9292'; 
    vr_nrdcctab(29):= '3988.9292'; 

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
    

    
    IF  vr_vllmtepj <> 0 THEN

      vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(28),'.',',') || ',';

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepj, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA JURIDICA"';
      pc_gravar_linha(vr_linhadet);

      
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
    
    IF  vr_vllmtepf <> 0 THEN
      vr_nrdcctab_c := ',' || REPLACE(vr_nrdcctab(29),'.',',') || ',';

      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) ||
                     TRIM(vr_nrdcctab_c) ||
                     TRIM(to_char(vr_vllmtepf, '99999999999990.00')) ||
                     ',1434,' || '"(risco) LIMITE CHEQUE ESPECIAL NAO UTILIZADO PESSOA FISICA"';
      pc_gravar_linha(vr_linhadet);

      
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

    vr_cdcopant := 0;
    vr_dtincorp := NULL;
    IF (pr_cdcooper = 09) THEN 
       vr_cdcopant := 17; 
       vr_dtincorp := to_date('31/12/2016','DD/MM/RRRR'); 
    END IF;

    FOR rw_crapris_60 IN cr_crapris_60(pr_cdcooper
                                      ,vr_dtrefere
                                      ,vr_cdcopant
                                      ,vr_dtincorp) LOOP

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

        vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                       TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_cre)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       vr_tab_contas(vr_price_atr)(vr_price_pf)(vr_price_deb)(to_char(rw_crapris_60.innivris)).nrdconta || ',' ||
                       TRIM(to_char(rw_crapris_60.vljura60, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) CLASSIFICACAO DO RISCO"';

                       pc_gravar_linha(vr_linhadet);
    END LOOP;


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
       vr_saldo_opera:= 0;
       OPEN cr_saldo_opera_pronampe1(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600); 
       FETCH cr_saldo_opera_pronampe1 INTO vr_saldo_opera;
       CLOSE cr_saldo_opera_pronampe1;   
       
       IF  vr_saldo_opera > 0 THEN
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3939,9984,'||        
                          TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||        
                         ',5210,'||
                         '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);                         
           
                  
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3939,'||
                           TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);  
       END IF;
       
       vr_saldo_opera:= 0;
       OPEN cr_saldo_opera_pronampe2(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600); 
       FETCH cr_saldo_opera_pronampe2 INTO vr_saldo_opera;
       CLOSE cr_saldo_opera_pronampe2;
       
       
       IF  vr_saldo_opera > 0 THEN
       
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3956,9984,'||        
                          TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||        
                         ',5210,'||
                         '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);                         
           
                  
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3956,'||
                           TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);  
       END IF; 
       

       
       vr_saldo_opera:= 0;
       vr_saldo_opera_r:=0;
       IF pr_cdcooper = 13 THEN 
         
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
          
          vr_saldo_opera_r:=vr_saldo_opera_r + vr_saldo_opera;
          
          IF vr_saldo_opera_r > 0 THEN
              
              vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                             TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3947,9984,'||
                             TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                             ',5210,'||
                             '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS - PESE"';

              pc_gravar_linha(vr_linhadet);  

              
              vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                             TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3947,'||
                             TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||        
                             ',5210,'||
                             '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

              pc_gravar_linha(vr_linhadet);
          END IF;  
      ELSE
         
         OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_saldo_opera
           INTO vr_saldo_opera;
          CLOSE cr_saldo_opera;   
          
          IF vr_saldo_opera > 0 THEN
              
              vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                             TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3947,9984,'||
                             TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                             ',5210,'||
                             '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS - PESE"';
              
              pc_gravar_linha(vr_linhadet);

              
              vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                             TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3947,'||
                             TRIM(to_char(vr_saldo_opera, '99999999999990.00')) ||
                             ',5210,'||
                             '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

              pc_gravar_linha(vr_linhadet);  
         END IF;  
      END IF;

        vr_saldo_opera := 0;
        OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                             pr_dtrefere => vr_dtrefere,
                             pr_cdlcremp => 4600);
        FETCH cr_saldo_opera
         INTO vr_saldo_opera;
        CLOSE cr_saldo_opera;   
        
        vr_saldo_opera_R:=vr_saldo_opera;

        OPEN cr_saldo_opera (pr_cdcooper => pr_cdcooper,
                             pr_dtrefere => vr_dtrefere,
                             pr_cdlcremp => 5600);
        FETCH cr_saldo_opera
         INTO vr_saldo_opera;         
        CLOSE cr_saldo_opera; 
        
        vr_saldo_opera_r:= vr_saldo_opera_r + vr_saldo_opera;
        
        IF vr_saldo_opera_r > 0 THEN 
            
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '3943,9984,'||
                           TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC - FGI"';

            pc_gravar_linha(vr_linhadet);

           
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '9984,3943,'||
                           TRIM(to_char(vr_saldo_opera_r, '99999999999990.00')) ||
                          ',5210,'||
                          '"REVERSAO OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);
        END IF ; 
   
       vr_total_jur60:= 0;
       OPEN cr_juros_60_pronampe1(pr_cdcooper => pr_cdcooper,
                                  pr_dtrefere => vr_dtrefere,
                                  pr_cdlcremp => 2600); 
       FETCH cr_juros_60_pronampe1 INTO vr_total_jur60;
       CLOSE cr_juros_60_pronampe1;
       
       IF vr_total_jur60 > 0 THEN       
           
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3939,'||        
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||        
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);  
           
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3939,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);  
       END IF; 
       
       vr_total_jur60:= 0;
       OPEN cr_juros_60_pronampe2(pr_cdcooper => pr_cdcooper,
                                  pr_dtrefere => vr_dtrefere,
                                  pr_cdlcremp => 2600); 
       FETCH cr_juros_60_pronampe2 INTO vr_total_jur60;
       CLOSE cr_juros_60_pronampe2;
       
       IF vr_total_jur60 > 0 THEN       
           
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3956,'||        
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||        
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);  
           
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3956,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);  
       END IF; 

       vr_total_jur60:= 0;
       vr_total_jur60_r:=0;
       IF pr_cdcooper = 13 THEN 

         OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1600);
         FETCH cr_juros_60
          INTO vr_total_jur60;
         CLOSE cr_juros_60;
         
         vr_total_jur60_r:=vr_total_jur60;

         OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 1601);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        
        vr_total_jur60_r:=vr_total_jur60_r + vr_total_jur60;

        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1602);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60; 
        
        vr_total_jur60_r:= vr_total_jur60_r + vr_total_jur60;
       
        IF vr_total_jur60_r > 0 THEN
            
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3947,'||        
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||        
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
            
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3947,9984,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
        END IF; 

      ELSE
        
        vr_total_jur60:= 0;
        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                          pr_dtrefere => vr_dtrefere,
                          pr_cdlcremp => 1600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        
        IF vr_total_jur60 > 0 THEN
            
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3947,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
           
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3947,9984,'||
                           TRIM(to_char(vr_total_jur60, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';

            pc_gravar_linha(vr_linhadet);
        END IF; 
      END IF;
       
       vr_total_jur60 := 0;
       vr_total_jur60_r:=0;
       OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                         pr_dtrefere => vr_dtrefere,
                         pr_cdlcremp => 4600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;
        
        vr_total_jur60_r:=vr_total_jur60;
        OPEN cr_juros_60 (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 5600);
        FETCH cr_juros_60
         INTO vr_total_jur60;
        CLOSE cr_juros_60;

        
        vr_total_jur60_r:= vr_total_jur60_r +vr_total_jur60;
        
       IF vr_total_jur60_r > 0 THEN
            
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3943,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||
                           ',5210,'||
                           '"RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);

           
           vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3943,9984,'||
                           TRIM(to_char(vr_total_jur60_r, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO RENDAS A APROPRIAR OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

            pc_gravar_linha(vr_linhadet);
       END IF; 

       vr_prov_perdas:= 0;
       OPEN cr_prov_perdas_pronampe1(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600); 
       FETCH cr_prov_perdas_pronampe1 INTO vr_prov_perdas;
       CLOSE cr_prov_perdas_pronampe1;


       IF vr_prov_perdas > 0 THEN 
           
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3941,'||        
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||        
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);                         
            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3941,9984,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE I"';
            
            pc_gravar_linha(vr_linhadet);          
       END IF; 
       
       vr_prov_perdas:= 0;
       OPEN cr_prov_perdas_pronampe2(pr_cdcooper => pr_cdcooper,
                                     pr_dtrefere => vr_dtrefere,
                                     pr_cdlcremp => 2600); 
       FETCH cr_prov_perdas_pronampe2 INTO vr_prov_perdas;
       CLOSE cr_prov_perdas_pronampe2;

    
       IF vr_prov_perdas > 0 THEN 
           
           vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                          TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3973,'||        
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||        
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);                         

            vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                           TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3973,9984,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||        
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA NACIONAL DE APOIO AS MICROEMPRESAS E EMPRESAS DE PEQUENO PORTE - PRONAMPE II"';
            
            pc_gravar_linha(vr_linhadet);
       END IF; 
       
       vr_prov_perdas:= 0;
       vr_prov_perdas_r:=0;
       IF pr_cdcooper = 13 THEN 

          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;
          
          vr_prov_perdas_r:= vr_prov_perdas;
          
          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_cdlcremp => 1601);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;   
          
           vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;

          OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_cdlcremp => 1602);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas; 

          
          vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;
          
          IF vr_prov_perdas_r > 0 THEN
                
                vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                               TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3949,'||
                               TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||        
                               ',5210,'||
                               '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
                
                pc_gravar_linha(vr_linhadet);  
                             
             
               vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                              TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3949,9984,'||
                              TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||        
                               ',5210,'||
                               '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
              
                pc_gravar_linha(vr_linhadet);
          END IF; 
      ELSE
      
         OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                              pr_dtrefere => vr_dtrefere,
                              pr_cdlcremp => 1600);
          FETCH cr_prov_perdas
           INTO vr_prov_perdas;
          CLOSE cr_prov_perdas;
    
     
        IF vr_prov_perdas > 0 THEN          
            
            vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                           TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3949,'||
                           TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
            
            pc_gravar_linha(vr_linhadet);                           

           vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                          TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3949,9984,'||
                          TRIM(to_char(vr_prov_perdas, '99999999999990.00')) ||
                           ',5210,'||
                           '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE SUPORTE A EMPREGOS – PESE"';
          
            pc_gravar_linha(vr_linhadet);
        END IF; 
      END IF;

      
      vr_prov_perdas := 0;
      OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 4600);
      FETCH cr_prov_perdas
       INTO vr_prov_perdas;
      CLOSE cr_prov_perdas;   
      
      vr_prov_perdas_R:=vr_prov_perdas;
      OPEN cr_prov_perdas (pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => vr_dtrefere,
                           pr_cdlcremp => 5600);
      FETCH cr_prov_perdas
       INTO vr_prov_perdas;
      CLOSE cr_prov_perdas; 

      
      vr_prov_perdas_r:= vr_prov_perdas_r + vr_prov_perdas;
      
      IF vr_prov_perdas_r > 0 THEN
          
          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(vr_dtmvtolt, 'ddmmyy')) || ',' || '9984,3945,'||
                         TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                         ',5210,'||
                         '"PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

          pc_gravar_linha(vr_linhadet);

         
         vr_linhadet := TRIM(vr_con_dtmvtopr) || ',' ||
                        TRIM(to_char(vr_dtmvtopr, 'ddmmyy')) || ',' || '3945,9984,'||
                        TRIM(to_char(vr_prov_perdas_r, '99999999999990.00')) ||
                        ',5210,'||
                        '"REVERSAO PROVISAO DAS OPERACOES DE CREDITO CONFORME INSTRUCAO NORMATIVA BCB 89 2021 PROGRAMA EMERGENCIAL DE ACESSO A CRÉDITO - PEAC – FGI"';

          pc_gravar_linha(vr_linhadet); 
     END IF; 

    
    vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yymmdd');
    
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
        
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 0) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;                
    
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;


    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 0) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;   
                               
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    
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
      
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);
      
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '1621,'||
                     '1662,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO SALDO FINANCIAMENTOS."';

      pc_gravar_linha(vr_linhadet);
      
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);

    end if;

    
    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 1) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;   
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    cecred.gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 1) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;   
        
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;


    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 2) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;   
    
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 2) LOOP
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0);
    END LOOP;   
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    

    cecred.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    
    vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                              || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

    
    cecred.GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    
     vr_dircon := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => vc_cdtodascooperativas
                                           ,pr_cdacesso => vc_cdacesso);
     vr_arqcon := to_char(vr_dtmvtolt, 'yy') ||
                  to_char(vr_dtmvtolt, 'mm') ||
                  to_char(vr_dtmvtolt, 'dd') ||
                  '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                  '_RISCO_NOVA_CENTRAL.txt';

      
     vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                                vr_dircon||'/novacentral/'||vr_arqcon||' 2>/dev/null';

    
    cecred.GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

    
    cecred.GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN

        RAISE vr_exc_erro;

    END IF;

    vr_nom_direto := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl');

    vr_nom_arquivo := 'crrl321_nova_central.lst';

    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    cecred.gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto,
                        '<?xml version="1.0" encoding="utf-8"?><crrl321>');

    FOR vr_contador IN 1..27 LOOP


      IF  vr_contador NOT IN (20,21,23,26) THEN


        IF vr_contador IN (19,22,24,25,27) THEN
          
          vr_vltotdev := NVL(vr_vldevedo(vr_contador),0) + NVL(vr_vldevepj(vr_contador),0);
          vr_vltotdes := NVL(vr_vldespes(vr_contador),0) + NVL(vr_vldesppj(vr_contador),0);

          
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vltotdev,'fm999G999G999G990D00')||'</vldevedo>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vltotdes,'fm999G999G999G990D00')||'</vldespes>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');
        ELSE
          
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vldevedo(vr_contador),'fm999G999G999G990D00')||'</vldevedo>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vldespes(vr_contador),'fm999G999G999G990D00')||'</vldespes>');
          cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');
        END IF;

      END IF;

      IF vr_contador = 21  THEN
        
        vr_vldevedo(vr_contador) := vr_vldevedo(vr_contador) + vr_vldevedo(20);
        vr_vldespes(vr_contador) := vr_vldespes(vr_contador) + vr_vldespes(20);

        
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(vr_contador)||'</nrdcctab>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vldevedo(vr_contador),'fm999G999G999G990D00')||'</vldevedo>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_vldespes(vr_contador),'fm999G999G999G990D00')||'</vldespes>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      ELSIF vr_contador = 16 THEN 

        
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(28)||'</nrdcctab>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vllmtepj,'fm999G999G999G990D00')||'</vldevedo>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(0,'fm999G999G999G990D00')||'</vldespes>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>'||vr_nrdcctab(29)||'</nrdcctab>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_vllmtepf,'fm999G999G999G990D00')||'</vldevedo>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(0,'fm999G999G999G990D00')||'</vldespes>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto Risco</nrdcctab>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo/>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_ttlanmto_risco,'fm999G999G999G990D00')||'</vldespes>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      ELSIF vr_contador = 22 THEN   
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto Prov.</nrdcctab>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo/>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes>'||to_char(vr_ttlanmto,'fm999G999G999G990D00')||'</vldespes>');
        cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');

      END IF;
    END LOOP;


    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<registro>');
    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<nrdcctab>Total Lancto CONTA</nrdcctab>');
    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldevedo>'||to_char(vr_ttlanmto_divida,'fm999G999G999G990D00')||'</vldevedo>');
    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<vldespes/>');
    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registro>');


    cecred.gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl321>',true);


    cecred.gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                 
                               ,pr_cdprogra  => vr_cdprogra                 
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         
                               ,pr_dsxml     => vr_des_xml                  
                               ,pr_dsxmlnode => '/crrl321/registro'         
                               ,pr_dsjasper  => 'crrl321.jasper'            
                               ,pr_dsparams  => NULL                        
                               ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo
                               ,pr_qtcoluna  => 234                         
                               ,pr_sqcabrel  => NULL                        
                               ,pr_cdrelato  => 321                         
                               ,pr_flg_impri => 'N'                         
                               ,pr_nmformul  => '234dh'                     
                               ,pr_nrcopias  => 1                           
                               ,pr_flg_gerar => 'N'                         
                               ,pr_des_erro  => vr_dscritic);               

    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      
      pr_dscritic := 'Erro em RISC0001_nova_central.pc_risco_k: ' || SQLERRM;
      cecred.pc_internal_exception (pr_cdcooper => 3
                                   ,pr_compleme => pr_dscritic);

  END pc_risco_k;
  

BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP

    pc_risco_k(pr_cdcooper => rw_crapcop.cdcooper
              ,pr_dtrefere => to_char(vr_dtrefere_ris, 'DD/MM/RRRR')
              ,pr_retfile  => vr_retfile
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
