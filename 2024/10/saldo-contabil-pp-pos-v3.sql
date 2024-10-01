DECLARE

  vr_cdcooper   NUMBER := 8;
  vr_vlmtapar   NUMBER := 0;
  vr_vlmrapar   NUMBER := 0;
  vr_vliofcpl   NUMBER := 0;
  vr_vljurmes   NUMBER := 0;
  pr_vljurcor   NUMBER;
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;
  vr_jura60     VARCHAR2(3) := 'NAO';
  vr_vljurmes59 NUMBER;
  vr_vljurmes60 NUMBER;

  CURSOR cr_contrato(pr_cdcooper crapepr.cdcooper%TYPE) IS
    SELECT epr.cdcooper, epr.nrdconta, epr.nrctremp, lcr.dsoperac,
           asso.cdagenci
      FROM crapepr epr
     INNER JOIN craplcr lcr
        ON epr.cdcooper = lcr.cdcooper
           AND epr.cdlcremp = lcr.cdlcremp
     INNER JOIN crapass asso
        ON epr.cdcooper = asso.cdcooper
           AND epr.nrdconta = asso.nrdconta
     WHERE epr.cdcooper = pr_cdcooper
           AND epr.tpemprst = 1
           AND epr.inliquid = 0
           AND epr.inprejuz = 0;

  CURSOR cr_juro_60(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE
                   ,pr_dtrefere IN cecred.crapdat.dtmvtoan%TYPE) IS
    SELECT e.cdcooper, e.nrdconta, e.nrctremp, e.vljura60, e.qtdiaatr,e.vljurantpp
      FROM gestaoderisco.tbrisco_juros_emprestimo e
     WHERE e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.nrctremp = pr_nrctremp
           AND e.dtrefere = pr_dtrefere;
  rw_juro_60 cr_juro_60%ROWTYPE;

  PROCEDURE obterValorAtraso(pr_cdcooper   IN crapepr.cdcooper%TYPE
                            ,pr_nrdconta   IN crapepr.nrdconta%TYPE
                            ,pr_nrctremp   IN crapepr.nrctremp%TYPE
                            ,pr_vlmtapar   OUT NUMBER
                            ,pr_vlmrapar   OUT NUMBER
                            ,pr_vliofcpl   OUT NUMBER
                            ,pr_vljurmes   OUT NUMBER
                            ,pr_vljurcor   OUT NUMBER
                            ,pr_vljurmes59 OUT NUMBER
                            ,pr_vljurmes60 OUT NUMBER) IS
  
    rw_crapdat             BTCH0001.cr_crapdat%ROWTYPE;
    vr_tab_pgto_parcel_pp  empr0001.typ_tab_pgto_parcel;
    vr_tab_calculado_pp    empr0001.typ_tab_calculado;
    vr_tab_pgto_parcel_pos EMPR0011.typ_tab_parcelas;
    vr_tab_calculado_pos   EMPR0011.typ_tab_calculado;
    vr_cdcritic            crapcri.cdcritic%TYPE;
    vr_des_reto            VARCHAR(4000);
    vr_dscritic            VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_tab_pgto_parc empr0001.typ_tab_pgto_parcel;
    vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
    vr_dtmvtoan      crapdat.dtmvtoan%TYPE;
    vr_vlmtapar      NUMBER := 0;
    vr_vlmrapar      NUMBER := 0;
    vr_vliofcpl      NUMBER := 0;
    vr_vljurmes      NUMBER;
    vr_diarefju      INTEGER;
    vr_mesrefju      INTEGER;
    vr_anorefju      INTEGER;
    vr_vljurcor      NUMBER;
    vr_mora_deb      NUMBER;
    vr_mora_cred     NUMBER;
    vr_vlmoralanc    NUMBER;
    vr_vljurmes59    NUMBER;
    vr_vljurmes60    NUMBER;
  
    CURSOR cr_mora_pos_deb(pr_cdcooper crapepr.cdcooper%TYPE
                          ,pr_nrdconta crapepr.nrdconta%TYPE
                          ,pr_nrctremp crapepr.nrctremp%TYPE
                          ,pr_dtmvtolt crapepr.dtmvtolt%TYPE
                          ,pr_cdhistor craphis.cdhistor%TYPE) IS
      SELECT SUM(lem.vllanmto) vllanmto
        FROM craplem lem
       WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND cdhistor = pr_cdhistor
             AND
             nrparepr IN (SELECT nrparepr
                            FROM crappep a
                           WHERE cdcooper = lem.cdcooper
                                 AND nrdconta = lem.nrdconta
                                 AND nrctremp = lem.nrctremp
                                 AND inliquid = 0
                                 AND a.dtvencto < pr_dtmvtolt);
    rw_mora_pos_deb cr_mora_pos_deb%ROWTYPE;
  
    CURSOR cr_mora_pos_cred(pr_cdcooper crapepr.cdcooper%TYPE
                           ,pr_nrdconta crapepr.nrdconta%TYPE
                           ,pr_nrctremp crapepr.nrctremp%TYPE
                           ,pr_dtmvtolt crapepr.dtmvtolt%TYPE
                           ,pr_cdhistor craphis.cdhistor%TYPE) IS
      SELECT SUM(lem.vllanmto) vllanmto
        FROM craplem lem
       WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND cdhistor = pr_cdhistor
             AND
             nrparepr IN (SELECT nrparepr
                            FROM crappep a
                           WHERE cdcooper = lem.cdcooper
                                 AND nrdconta = lem.nrdconta
                                 AND nrctremp = lem.nrctremp
                                 AND inliquid = 0
                                 AND a.dtvencto < pr_dtmvtolt);
    rw_mora_pos_cred cr_mora_pos_cred%ROWTYPE;
  
    CURSOR cr_parc_min(pr_cdcooper crapepr.cdcooper%TYPE
                      ,pr_nrdconta crapepr.nrdconta%TYPE
                      ,pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT MIN(p.dtvencto) dtvencto
        FROM crappep p
       WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND inliquid = 0;
    rw_parc_min cr_parc_min%ROWTYPE;
  
    CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT a.tpemprst, a.diarefju, a.mesrefju, a.anorefju, b.dsoperac
        FROM crapepr a
       INNER JOIN craplcr b
          ON a.cdcooper = b.cdcooper
             AND a.cdlcremp = b.cdlcremp
       WHERE a.cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
  
    CURSOR cr_crappep(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE
                     ,pr_dtmvtolt crapepr.dtmvtolt%TYPE) IS
      SELECT a.cdcooper, a.nrdconta, a.nrctremp, a.nrparepr, b.tpemprst,
             b.cdagenci, b.dtmvtolt, b.cdlcremp, b.vlemprst, b.txmensal,
             b.dtdpagto, b.vlsprojt, qttolatr
        FROM crappep a
       INNER JOIN crapepr b
          ON a.cdcooper = b.cdcooper
             AND a.nrdconta = b.nrdconta
             AND a.nrctremp = b.nrctremp
       WHERE a.cdcooper = pr_cdcooper
             AND a.nrdconta = pr_nrdconta
             AND a.nrctremp = pr_nrctremp
             AND a.inliquid = 0
             AND a.dtvencto < pr_dtmvtolt;
  
    PROCEDURE obterJurosCorrecaoPos(pr_cdcooper IN crapdat.cdcooper%TYPE
                                   ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_flgbatch IN BOOLEAN DEFAULT FALSE
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_dtlibera IN crawepr.dtlibera%TYPE
                                   ,pr_vlrdtaxa IN NUMBER
                                   ,pr_dtvencto IN crappep.dtvencto%TYPE
                                   ,pr_insitpar IN PLS_INTEGER DEFAULT NULL
                                   ,pr_vlsprojt IN NUMBER
                                   ,pr_ehmensal IN BOOLEAN
                                   ,pr_dtrefcor IN crapepr.dtrefcor%TYPE
                                   ,pr_vljurcor OUT NUMBER
                                   ,pr_qtdiacal OUT craplem.qtdiacal%TYPE
                                   ,pr_vltaxprd OUT craplem.vltaxprd%TYPE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
    
      DECLARE
        CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE
                               ,pr_nrdconta IN craplem.nrdconta%TYPE
                               ,pr_nrctremp IN craplem.nrctremp%TYPE
                               ,pr_dtinicio IN DATE
                               ,pr_dtfim    IN DATE) IS
          SELECT SUM(vllanmto) vllanmto
            FROM craplem
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND cdhistor IN (2344, 2345)
                 AND dtmvtolt > pr_dtinicio
                 AND dtmvtolt <= pr_dtfim;
      
        CURSOR cr_craplem_pago_total(pr_cdcooper IN craplem.cdcooper%TYPE
                                    ,pr_nrdconta IN craplem.nrdconta%TYPE
                                    ,pr_nrctremp IN craplem.nrctremp%TYPE
                                    ,pr_dtinicio IN DATE
                                    ,pr_dtfim    IN DATE) IS
          SELECT SUM(craplem.vllanmto) vllanmto
            FROM craplem
            JOIN crappep
              ON crappep.cdcooper = craplem.cdcooper
                 AND crappep.nrdconta = craplem.nrdconta
                 AND crappep.nrctremp = craplem.nrctremp
                 AND crappep.nrparepr = craplem.nrparepr
                 AND crappep.vldespar > 0
                 AND crappep.inliquid = 1
           WHERE craplem.cdcooper = pr_cdcooper
                 AND craplem.nrdconta = pr_nrdconta
                 AND craplem.nrctremp = pr_nrctremp
                 AND craplem.cdhistor IN (2331, 2330, 2335, 2334)
                 AND craplem.dtmvtolt > pr_dtinicio
                 AND craplem.dtmvtolt <= pr_dtfim;
      
        CURSOR cr_craplem_pago_parcial(pr_cdcooper IN craplem.cdcooper%TYPE
                                      ,pr_nrdconta IN craplem.nrdconta%TYPE
                                      ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
          SELECT SUM(craplem.vllanmto) vllanmto
            FROM craplem
            JOIN crappep
              ON crappep.cdcooper = craplem.cdcooper
                 AND crappep.nrdconta = craplem.nrdconta
                 AND crappep.nrctremp = craplem.nrctremp
                 AND crappep.nrparepr = craplem.nrparepr
                 AND crappep.vldespar > 0
                 AND crappep.inliquid = 0
           WHERE craplem.cdcooper = pr_cdcooper
                 AND craplem.nrdconta = pr_nrdconta
                 AND craplem.nrctremp = pr_nrctremp
                 AND craplem.cdhistor IN (2331, 2330, 2335, 2334);
      
        vr_qtdedias       PLS_INTEGER;
        vr_taxa_periodo   NUMBER(25, 8);
        vr_vlpago_total   NUMBER(25, 2);
        vr_vlpago_parcial NUMBER(25, 2);
        vr_vljuros_mensal craplem.vllanmto%TYPE := 0;
        vr_data_final     DATE;
        vr_data_inicial   DATE;
        vr_dtvencto_calc  DATE;
      
        vr_exc_erro EXCEPTION;
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(4000);
      BEGIN
        IF pr_dtrefcor IS NOT NULL THEN
          vr_data_inicial := pr_dtrefcor;
        ELSE
          vr_data_inicial := pr_dtlibera;
        END IF;
      
        IF pr_insitpar = 1 THEN
          vr_data_final := pr_dtvencto;
        ELSIF pr_insitpar = 3 THEN
          vr_data_final := pr_dtmvtolt;
        ELSIF pr_ehmensal THEN
          vr_data_final := last_day(pr_dtmvtolt);
        END IF;
      
        empr0011.pc_calcula_qtd_dias_uteis(pr_cdcooper => pr_cdcooper,
                                           pr_flgbatch => pr_flgbatch,
                                           pr_dtefetiv => pr_dtlibera,
                                           pr_datainicial => vr_data_inicial,
                                           pr_datafinal => vr_data_final,
                                           pr_qtdiaute => vr_qtdedias,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
      
        IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        vr_taxa_periodo := ROUND(POWER((1 + (pr_vlrdtaxa / 100)),
                                       (vr_qtdedias / 252)) - 1, 8);
        IF vr_taxa_periodo <= 0 THEN
          RETURN;
        END IF;
      
        vr_dtvencto_calc := TO_DATE(TO_CHAR(pr_dtvencto, 'DD') || '/' ||
                                    TO_CHAR(pr_dtmvtolt, 'MM/RRRR'),
                                    'DD/MM/RRRR');
        IF vr_dtvencto_calc > pr_dtmvtoan AND vr_dtvencto_calc <= pr_dtmvtolt THEN
          vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc, -1);
        ELSIF vr_dtvencto_calc > pr_dtmvtolt THEN
          vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc, -1);
        END IF;
        vr_dtvencto_calc := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                        pr_dtmvtolt => vr_dtvencto_calc,
                                                        pr_tipo => 'P');
      
        vr_vljuros_mensal := 0;
        OPEN cr_craplem_juros(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => pr_nrctremp,
                              pr_dtinicio => vr_dtvencto_calc,
                              pr_dtfim => pr_dtmvtolt);
        FETCH cr_craplem_juros
          INTO vr_vljuros_mensal;
        CLOSE cr_craplem_juros;
      
        vr_vlpago_total := 0;
        OPEN cr_craplem_pago_total(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_dtinicio => vr_dtvencto_calc,
                                   pr_dtfim => pr_dtmvtolt);
        FETCH cr_craplem_pago_total
          INTO vr_vlpago_total;
        CLOSE cr_craplem_pago_total;
      
        vr_vlpago_parcial := 0;
        OPEN cr_craplem_pago_parcial(pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nrctremp => pr_nrctremp);
        FETCH cr_craplem_pago_parcial
          INTO vr_vlpago_parcial;
        CLOSE cr_craplem_pago_parcial;
      
        pr_vljurcor := (NVL(pr_vlsprojt, 0) + NVL(vr_vljuros_mensal, 0) -
                       NVL(vr_vlpago_total, 0) - NVL(vr_vlpago_parcial, 0)) *
                       vr_taxa_periodo;
      
        pr_qtdiacal := vr_qtdedias;
        pr_vltaxprd := vr_taxa_periodo;
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          IF NVL(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          pr_cdcritic := NVL(vr_cdcritic, 0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_cdcritic := NVL(vr_cdcritic, 0);
          pr_dscritic := 'Erro na procedure obterJurosCorrecaoPos: ' ||
                         SQLERRM;
      END;
    
    END obterJurosCorrecaoPos;
  
    PROCEDURE obterJurosPP(pr_cdcooper   IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE
                          ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                          ,pr_flnormal   IN BOOLEAN
                          ,pr_dtvencto   IN crapdat.dtmvtolt%TYPE
                          ,pr_ehmensal   IN BOOLEAN
                          ,pr_dtdpagto   IN crapdat.dtmvtolt%TYPE
                          ,pr_vljurmes   OUT NUMBER
                          ,pr_vljurmes59 OUT NUMBER
                          ,pr_vljurmes60 OUT NUMBER
                          ,pr_diarefju   OUT INTEGER
                          ,pr_mesrefju   OUT INTEGER
                          ,pr_anorefju   OUT INTEGER
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE
                          ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS
    BEGIN
    
      DECLARE
        vr_diavtolt    INTEGER;
        vr_mesvtolt    INTEGER;
        vr_anovtolt    INTEGER;
        vr_qtdiajur    NUMBER;
        vr_potencia    NUMBER(30, 10);
        vr_valor       NUMBER;
        vr_dtrefjur    DATE;
        vr_qtdiaatraso NUMBER := 0;
        vr_datajuros59 DATE;
        pr_diarefju59  INTEGER;
        pr_mesrefju59  INTEGER;
        pr_anorefju59  INTEGER;
        vr_qtdiajur59  NUMBER;
        vr_valor59     NUMBER;
        vr_potencia59  NUMBER(30, 10);
        vr_vljurmes59  NUMBER := 0;
        vr_diavtolt59  INTEGER;
        vr_mesvtolt59  INTEGER;
        vr_anovtolt59  INTEGER;
      
        pr_diarefju60 INTEGER;
        pr_mesrefju60 INTEGER;
        pr_anorefju60 INTEGER;
        vr_qtdiajur60 NUMBER;
        vr_valor60    NUMBER;
        vr_potencia60 NUMBER(30, 10);
        vr_vljurmes60 NUMBER := 0;
        vr_diavtolt60 INTEGER;
        vr_mesvtolt60 INTEGER;
        vr_anovtolt60 INTEGER;
      
        vr_index_crawepr VARCHAR2(30);
      
        CURSOR cr_crappep_minvecto(pr_cdcooper IN crappep.cdcooper%TYPE
                                  ,pr_nrdconta IN crappep.nrdconta%TYPE
                                  ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
          SELECT MIN(a.dtvencto) dtvencto
            FROM crappep a
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND inliquid = 0;
        rw_crappep_minvecto cr_crappep_minvecto%ROWTYPE;
      
        CURSOR cr_crapepr_lanjur(pr_cdcooper IN crapepr.cdcooper%TYPE
                                ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT crapepr.cdlcremp, crapepr.inprejuz, crapepr.diarefju,
                 crapepr.mesrefju, crapepr.anorefju, crapepr.vlsdeved,
                 crapepr.txjuremp, crapepr.vlpreemp
            FROM crapepr
           WHERE crapepr.cdcooper = pr_cdcooper
                 AND crapepr.nrdconta = pr_nrdconta
                 AND crapepr.nrctremp = pr_nrctremp;
        rw_crapepr_lanjur cr_crapepr_lanjur%ROWTYPE;
      
        CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT crawepr.cdlcremp, crawepr.vlpreemp, crawepr.dtlibera,
                 crawepr.tpemprst, crawepr.idcobope
            FROM crawepr
           WHERE crawepr.cdcooper = pr_cdcooper
                 AND crawepr.nrdconta = pr_nrdconta
                 AND crawepr.nrctremp = pr_nrctremp;
        rw_crawepr cr_crawepr%ROWTYPE;
      
        CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                         ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
          SELECT craplcr.cdlcremp, craplcr.dsoperac
            FROM craplcr
           WHERE craplcr.cdcooper = pr_cdcooper
                 AND craplcr.cdlcremp = pr_cdlcremp;
        rw_craplcr cr_craplcr%ROWTYPE;
      
        CURSOR cr_crawepr_carga(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN crappep.nrdconta%TYPE
                               ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
          SELECT crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp,
                 crawepr.dtlibera, crawepr.tpemprst
            FROM crawepr
           WHERE crawepr.cdcooper = pr_cdcooper
                 AND crawepr.nrdconta = pr_nrdconta
                 AND crawepr.nrctremp = pr_nrctremp;
      
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
      
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;
        vr_tab_crawepr empr0001.typ_tab_crawepr;
      
      BEGIN
        BEGIN
        
          ---- 59 e 60 ---
          OPEN cr_crappep_minvecto(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp);
          FETCH cr_crappep_minvecto
            INTO rw_crappep_minvecto;
          IF cr_crappep_minvecto%FOUND THEN
            IF rw_crappep_minvecto.dtvencto < pr_dtmvtolt THEN
              vr_qtdiaatraso := pr_dtmvtolt - rw_crappep_minvecto.dtvencto;
            END IF;
          END IF;
          CLOSE cr_crappep_minvecto;
          IF vr_qtdiaatraso > 1 THEN
            IF vr_qtdiaatraso > 59 THEN
              vr_datajuros59 := rw_crappep_minvecto.dtvencto + 59;
            ELSE
              vr_datajuros59 := rw_crappep_minvecto.dtvencto + vr_qtdiaatraso;
            END IF;
          END IF;
        
          --------------
        
          OPEN cr_crapepr_lanjur(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp);
          FETCH cr_crapepr_lanjur
            INTO rw_crapepr_lanjur;
          IF cr_crapepr_lanjur%NOTFOUND THEN
            CLOSE cr_crapepr_lanjur;
            vr_cdcritic := 55;
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_crapepr_lanjur;
        
          FOR rw_crawepr IN cr_crawepr_carga(pr_cdcooper => pr_cdcooper,
                                             pr_nrdconta => pr_nrdconta,
                                             pr_nrctremp => pr_nrctremp) LOOP
            vr_index_crawepr := lpad(rw_crawepr.cdcooper, 10, '0') ||
                                lpad(rw_crawepr.nrdconta, 10, '0') ||
                                lpad(rw_crawepr.nrctremp, 10, '0');
            vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
            vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;
          END LOOP;
        
          vr_index_crawepr := lpad(pr_cdcooper, 10, '0') ||
                              lpad(pr_nrdconta, 10, '0') ||
                              lpad(pr_nrctremp, 10, '0');
          IF NOT vr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
            vr_cdcritic := 510;
            RAISE vr_exc_saida;
          ELSE
            rw_crawepr.dtlibera := vr_tab_crawepr(vr_index_crawepr).dtlibera;
          END IF;
        
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                          pr_cdlcremp => rw_crapepr_lanjur.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          IF cr_craplcr%NOTFOUND THEN
            CLOSE cr_craplcr;
            vr_cdcritic := 55;
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_craplcr;
        
          --Dia/Mes/Ano Referencia
          IF rw_crapepr_lanjur.diarefju <> 0 AND
             rw_crapepr_lanjur.mesrefju <> 0 AND
             rw_crapepr_lanjur.anorefju <> 0 THEN
            --Setar Dia/mes?ano
            vr_diavtolt := rw_crapepr_lanjur.diarefju;
            vr_mesvtolt := rw_crapepr_lanjur.mesrefju;
            vr_anovtolt := rw_crapepr_lanjur.anorefju;
          ELSE
            --Setar dia/mes/ano
            vr_diavtolt := to_number(to_char(rw_crawepr.dtlibera, 'DD'));
            vr_mesvtolt := to_number(to_char(rw_crawepr.dtlibera, 'MM'));
            vr_anovtolt := to_number(to_char(rw_crawepr.dtlibera, 'YYYY'));
          END IF;
        
          IF pr_flnormal THEN
            vr_dtrefjur := pr_dtvencto;
          ELSE
            vr_dtrefjur := pr_dtmvtolt;
          END IF;
        
          IF rw_crawepr.dtlibera > pr_dtmvtolt THEN
            RAISE vr_exc_saida;
          END IF;
        
          --Retornar Dia/mes/ano de referencia
          pr_diarefju := to_number(to_char(vr_dtrefjur, 'DD'));
          pr_mesrefju := to_number(to_char(vr_dtrefjur, 'MM'));
          pr_anorefju := to_number(to_char(vr_dtrefjur, 'YYYY'));
        
          --Calcular Quantidade dias
          EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal,
                                   pr_dtdpagto => to_char(pr_dtdpagto, 'DD'),
                                   pr_diarefju => vr_diavtolt,
                                   pr_mesrefju => vr_mesvtolt,
                                   pr_anorefju => vr_anovtolt,
                                   pr_diafinal => pr_diarefju,
                                   pr_mesfinal => pr_mesrefju,
                                   pr_anofinal => pr_anorefju,
                                   pr_qtdedias => vr_qtdiajur);
        
          vr_valor    := 1 + (rw_crapepr_lanjur.txjuremp / 100);
          vr_potencia := POWER(vr_valor, vr_qtdiajur);
        
          pr_vljurmes := rw_crapepr_lanjur.vlsdeved * (vr_potencia - 1);
        
          IF pr_vljurmes <= 0 THEN
            pr_vljurmes := 0;
            RAISE vr_exc_saida;
          END IF;
        
          -------************* 59 ******************--------
          IF vr_datajuros59 >
             to_date(vr_diavtolt || '/' || vr_mesvtolt || '/' || vr_anovtolt,
                     'dd/mm/yyyy') THEN
          
            IF vr_datajuros59 < pr_dtmvtolt THEN
            
              vr_diavtolt59 := vr_diavtolt;
              vr_mesvtolt59 := vr_mesvtolt;
              vr_anovtolt59 := vr_anovtolt;
            
              --Retornar Dia/mes/ano de referencia
              pr_diarefju59 := to_number(to_char(vr_datajuros59, 'DD'));
              pr_mesrefju59 := to_number(to_char(vr_datajuros59, 'MM'));
              pr_anorefju59 := to_number(to_char(vr_datajuros59, 'YYYY'));
            
              --Calcular Quantidade dias
              EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal,
                                       pr_dtdpagto => to_char(pr_dtdpagto, 'DD'),
                                       pr_diarefju => vr_diavtolt59,
                                       pr_mesrefju => vr_mesvtolt59,
                                       pr_anorefju => vr_anovtolt59,
                                       pr_diafinal => pr_diarefju59,
                                       pr_mesfinal => pr_mesrefju59,
                                       pr_anofinal => pr_anorefju59,
                                       pr_qtdedias => vr_qtdiajur59);
            
              vr_valor59    := 1 + (rw_crapepr_lanjur.txjuremp / 100);
              vr_potencia59 := POWER(vr_valor59, vr_qtdiajur59);
              vr_vljurmes59 := rw_crapepr_lanjur.vlsdeved *
                               (vr_potencia59 - 1);
            
              IF vr_vljurmes59 <= 0 THEN
                pr_vljurmes59 := 0;
                RAISE vr_exc_saida;
              END IF;
              -------************* 59 ******************--------
            
              -------************* 60 ******************--------
            
              IF NVL(vr_vljurmes59, 0) > 0 THEN
                vr_diavtolt60 := to_number(to_char(vr_datajuros59, 'DD'));
                vr_mesvtolt60 := to_number(to_char(vr_datajuros59, 'MM'));
                vr_anovtolt60 := to_number(to_char(vr_datajuros59, 'YYYY'));
              ELSE
                vr_diavtolt60 := vr_diavtolt;
                vr_mesvtolt60 := vr_mesvtolt;
                vr_anovtolt60 := vr_anovtolt;
              END IF;
            
              --Retornar Dia/mes/ano de referencia
              pr_diarefju60 := pr_diarefju;
              pr_mesrefju60 := pr_mesrefju;
              pr_anorefju60 := pr_anorefju;
            
              --Calcular Quantidade dias
              EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal,
                                       pr_dtdpagto => to_char(pr_dtdpagto, 'DD'),
                                       pr_diarefju => vr_diavtolt60,
                                       pr_mesrefju => vr_mesvtolt60,
                                       pr_anorefju => vr_anovtolt60,
                                       pr_diafinal => pr_diarefju60,
                                       pr_mesfinal => pr_mesrefju60,
                                       pr_anofinal => pr_anorefju60,
                                       pr_qtdedias => vr_qtdiajur60);
            
              vr_valor60    := 1 + (rw_crapepr_lanjur.txjuremp / 100);
              vr_potencia60 := POWER(vr_valor60, vr_qtdiajur60);
              vr_vljurmes60 := (rw_crapepr_lanjur.vlsdeved +
                               nvl(vr_vljurmes59, 0)) * (vr_potencia60 - 1);
            
              IF vr_vljurmes60 <= 0 THEN
                pr_vljurmes60 := 0;
                RAISE vr_exc_saida;
              END IF;
            ELSE
              vr_vljurmes59 := pr_vljurmes;
            END IF;
            -------************* 60 ******************--------
          END IF;
        
          pr_vljurmes59 := NVL(vr_vljurmes59, 0);
          pr_vljurmes60 := NVL(vr_vljurmes60, 0);
        
        EXCEPTION
          WHEN vr_exc_saida THEN
            NULL;
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
        END;
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic := nvl(vr_cdcritic, 0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro não tratado na empr0001.obterJurosPP. ' ||
                         SQLERRM;
        
      END;
    END obterJurosPP;
  
    PROCEDURE obterValorJurosRemPos(pr_cdcooper IN crapdat.cdcooper%TYPE
                                   ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_dtvencto IN crappep.dtvencto%TYPE
                                   ,pr_diarefju IN OUT crapepr.diarefju%TYPE
                                   ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE
                                   ,pr_anorefju IN OUT crapepr.anorefju%TYPE
                                   ,pr_vljuremu OUT NUMBER
                                   ,pr_vljurcor OUT NUMBER
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
    
      DECLARE
        CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE
                               ,pr_nrdconta IN craplem.nrdconta%TYPE
                               ,pr_nrctremp IN craplem.nrctremp%TYPE
                               ,pr_dtinicio IN DATE
                               ,pr_dtfim    IN DATE) IS
          SELECT SUM(vllanmto) vllanmto
            FROM craplem
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND cdhistor IN (2342, 2343)
                 AND dtmvtolt > pr_dtinicio
                 AND dtmvtolt <= pr_dtfim;
      
        CURSOR cr_craplem_pago_total(pr_cdcooper IN craplem.cdcooper%TYPE
                                    ,pr_nrdconta IN craplem.nrdconta%TYPE
                                    ,pr_nrctremp IN craplem.nrctremp%TYPE
                                    ,pr_dtinicio IN DATE
                                    ,pr_dtfim    IN DATE) IS
          SELECT SUM(craplem.vllanmto) vllanmto
            FROM craplem
            JOIN crappep
              ON crappep.cdcooper = craplem.cdcooper
                 AND crappep.nrdconta = craplem.nrdconta
                 AND crappep.nrctremp = craplem.nrctremp
                 AND crappep.nrparepr = craplem.nrparepr
                 AND crappep.vldespar > 0
                 AND crappep.inliquid = 1
           WHERE craplem.cdcooper = pr_cdcooper
                 AND craplem.nrdconta = pr_nrdconta
                 AND craplem.nrctremp = pr_nrctremp
                 AND craplem.cdhistor IN (2331, 2330, 2335, 2334)
                 AND craplem.dtmvtolt > pr_dtinicio
                 AND craplem.dtmvtolt <= pr_dtfim;
      
        CURSOR cr_craplem_pago_parcial(pr_cdcooper IN craplem.cdcooper%TYPE
                                      ,pr_nrdconta IN craplem.nrdconta%TYPE
                                      ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
          SELECT SUM(craplem.vllanmto) vllanmto
            FROM craplem
            JOIN crappep
              ON crappep.cdcooper = craplem.cdcooper
                 AND crappep.nrdconta = craplem.nrdconta
                 AND crappep.nrctremp = craplem.nrctremp
                 AND crappep.nrparepr = craplem.nrparepr
                 AND crappep.vldespar > 0
                 AND crappep.inliquid = 0
           WHERE craplem.cdcooper = pr_cdcooper
                 AND craplem.nrdconta = pr_nrdconta
                 AND craplem.nrctremp = pr_nrctremp
                 AND craplem.cdhistor IN (2331, 2330, 2335, 2334);
      
        CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT b.dtlibera, a.vlsprojt,
                 round((POWER(1 + (NVL(a.txmensal, 0) / 100), (1 / 30)) - 1),
                        7) txdiaria, dtrefcor
            FROM crapepr a
           INNER JOIN crawepr b
              ON a.cdcooper = b.cdcooper
                 AND a.nrdconta = a.nrdconta
                 AND a.nrctremp = b.nrctremp
           WHERE a.cdcooper = pr_cdcooper
                 AND a.nrdconta = pr_nrdconta
                 AND a.nrctremp = pr_nrctremp;
        rw_crapepr cr_crapepr%ROWTYPE;
      
        CURSOR cr_taxa_parc(pr_cdcooper IN crapepr.cdcooper%TYPE
                           ,pr_nrdconta IN crapepr.nrdconta%TYPE
                           ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT vltaxatu
            FROM crappep a
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND inliquid = 0
                 AND nrparepr = (SELECT MIN(nrparepr)
                                   FROM crappep
                                  WHERE cdcooper = a.cdcooper
                                        AND nrdconta = a.nrdconta
                                        AND nrctremp = a.nrctremp
                                        AND inliquid = 0);
        rw_taxa_parc cr_taxa_parc%ROWTYPE;
      
        vr_diavtolt       INTEGER;
        vr_mesvtolt       INTEGER;
        vr_anovtolt       INTEGER;
        vr_qtdedias       PLS_INTEGER;
        vr_vljuros_mensal craplem.vllanmto%TYPE := 0;
        vr_data_final     DATE;
        vr_dtvencto_calc  DATE;
        vr_vlpago_total   NUMBER(25, 2);
        vr_vlpago_parcial NUMBER(25, 2);
        vr_flmensal       BOOLEAN;
        vr_insitpar       NUMBER;
        vr_vljurcor       NUMBER(25, 2);
        vr_taxa_periodo   NUMBER(25, 8);
        vr_qtdiacal       NUMBER;
        rw_crapdat        BTCH0001.cr_crapdat%ROWTYPE;
        vr_cdcritic       crapcri.cdcritic%TYPE;
      
      BEGIN
      
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;
      
        vr_flmensal := (TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <>
                       TO_CHAR(rw_crapdat.dtmvtopr, 'MM'));
      
        IF pr_dtvencto > rw_crapdat.dtmvtoan AND
           pr_dtvencto <= rw_crapdat.dtmvtolt THEN
          vr_insitpar := 1;
        ELSIF pr_dtvencto > rw_crapdat.dtmvtolt THEN
          vr_insitpar := 3;
        ELSE
          vr_insitpar := 3;
        END IF;
      
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta, pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crapepr;
        CLOSE cr_crapepr;
      
        IF pr_diarefju <> 0 AND pr_mesrefju <> 0 AND pr_anorefju <> 0 THEN
          vr_diavtolt := pr_diarefju;
          vr_mesvtolt := pr_mesrefju;
          vr_anovtolt := pr_anorefju;
        ELSE
          vr_diavtolt := to_number(to_char(rw_crapepr.dtlibera, 'DD'));
          vr_mesvtolt := to_number(to_char(rw_crapepr.dtlibera, 'MM'));
          vr_anovtolt := to_number(to_char(rw_crapepr.dtlibera, 'YYYY'));
        END IF;
      
        IF vr_insitpar = 1 THEN
          vr_data_final := pr_dtvencto;
        ELSIF vr_insitpar = 3 THEN
          vr_data_final := pr_dtmvtolt;
        
        ELSIF vr_flmensal THEN
          vr_data_final := last_day(pr_dtmvtolt);
        END IF;
      
        pr_diarefju := to_number(to_char(vr_data_final, 'DD'));
        pr_mesrefju := to_number(to_char(vr_data_final, 'MM'));
        pr_anorefju := to_number(to_char(vr_data_final, 'YYYY'));
      
        EMPR0001.pc_calc_dias360(pr_ehmensal => vr_flmensal,
                                 pr_dtdpagto => to_char(pr_dtvencto, 'DD'),
                                 pr_diarefju => vr_diavtolt,
                                 pr_mesrefju => vr_mesvtolt,
                                 pr_anorefju => vr_anovtolt,
                                 pr_diafinal => pr_diarefju,
                                 pr_mesfinal => pr_mesrefju,
                                 pr_anofinal => pr_anorefju,
                                 pr_qtdedias => vr_qtdedias);
      
        IF vr_qtdedias <= 0 THEN
          pr_vljuremu := 0;
          RETURN;
        END IF;
      
        vr_dtvencto_calc := TO_DATE(TO_CHAR(pr_dtvencto, 'DD') || '/' ||
                                    TO_CHAR(pr_dtmvtolt, 'MM/RRRR'),
                                    'DD/MM/RRRR');
        IF vr_dtvencto_calc > pr_dtmvtoan AND vr_dtvencto_calc <= pr_dtmvtolt THEN
          vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc, -1);
        ELSIF vr_dtvencto_calc > pr_dtmvtolt THEN
          vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc, -1);
        END IF;
      
        vr_dtvencto_calc := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                        pr_dtmvtolt => vr_dtvencto_calc,
                                                        pr_tipo => 'P');
      
        vr_vljuros_mensal := 0;
        OPEN cr_craplem_juros(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => pr_nrctremp,
                              pr_dtinicio => vr_dtvencto_calc,
                              pr_dtfim => pr_dtmvtolt);
        FETCH cr_craplem_juros
          INTO vr_vljuros_mensal;
        CLOSE cr_craplem_juros;
      
        vr_vlpago_total := 0;
        OPEN cr_craplem_pago_total(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_dtinicio => vr_dtvencto_calc,
                                   pr_dtfim => pr_dtmvtolt);
        FETCH cr_craplem_pago_total
          INTO vr_vlpago_total;
        CLOSE cr_craplem_pago_total;
      
        vr_vlpago_parcial := 0;
        OPEN cr_craplem_pago_parcial(pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nrctremp => pr_nrctremp);
        FETCH cr_craplem_pago_parcial
          INTO vr_vlpago_parcial;
        CLOSE cr_craplem_pago_parcial;
      
        pr_vljuremu := (NVL(rw_crapepr.vlsprojt, 0) +
                       NVL(vr_vljuros_mensal, 0) - NVL(vr_vlpago_total, 0) -
                       NVL(vr_vlpago_parcial, 0)) *
                       NVL((POWER(1 + rw_crapepr.txdiaria, vr_qtdedias) - 1),
                           0);
      
        pr_vljuremu := round(pr_vljuremu, 2);
      
        IF pr_vljuremu <= 0 THEN
          pr_vljuremu := 0;
        END IF;
      
        OPEN cr_taxa_parc(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrctremp => pr_nrctremp);
        FETCH cr_taxa_parc
          INTO rw_taxa_parc;
        CLOSE cr_taxa_parc;
      
        obterJurosCorrecaoPos(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtoan => vr_dtmvtoan,
                              pr_dtmvtolt => vr_dtmvtolt, pr_flgbatch => FALSE,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => pr_nrctremp,
                              pr_dtlibera => rw_crapepr.dtlibera,
                              pr_vlrdtaxa => nvl(rw_taxa_parc.vltaxatu, 0),
                              pr_dtvencto => pr_dtvencto,
                              pr_insitpar => vr_insitpar,
                              pr_vlsprojt => rw_crapepr.vlsprojt,
                              pr_ehmensal => vr_flmensal,
                              pr_dtrefcor => rw_crapepr.dtrefcor,
                              pr_vljurcor => vr_vljurcor,
                              pr_qtdiacal => vr_qtdiacal,
                              pr_vltaxprd => vr_taxa_periodo,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
      
        pr_vljurcor := nvl(vr_vljurcor, 0);
      
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := NVL(vr_cdcritic, 0);
          pr_dscritic := 'Erro na procedure obterValorJurosRemPos: ' ||
                         SQLERRM;
      END;
    
    END obterValorJurosRemPos;
  
  BEGIN
  
    OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH CECRED.BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE CECRED.BTCH0001.cr_crapdat;
  
    vr_dtmvtolt := rw_crapdat.dtmvtolt;
    vr_dtmvtoan := rw_crapdat.dtmvtoan;
  
    OPEN cr_crapepr(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crapepr
      INTO rw_crapepr;
    CLOSE cr_crapepr;
  
    FOR rw_parcela IN cr_crappep(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp,
                                 pr_dtmvtolt => vr_dtmvtolt) LOOP
    
      IF rw_parcela.tpemprst = 1 THEN
        vr_tab_pgto_parcel_pp.DELETE;
        vr_tab_calculado_pp.DELETE;
        vr_tab_pgto_parc.DELETE;
      
        CECRED.empr0001.pc_busca_pgto_parcelas(pr_cdcooper => rw_parcela.cdcooper,
                                               pr_cdagenci => rw_parcela.cdagenci,
                                               pr_nrdcaixa => 0,
                                               pr_cdoperad => '1',
                                               pr_nmdatela => NULL,
                                               pr_idorigem => 5,
                                               pr_nrdconta => rw_parcela.nrdconta,
                                               pr_idseqttl => 1,
                                               pr_dtmvtolt => vr_dtmvtolt,
                                               pr_flgerlog => 'S',
                                               pr_nrctremp => rw_parcela.nrctremp,
                                               pr_dtmvtoan => vr_dtmvtoan,
                                               pr_nrparepr => rw_parcela.nrparepr,
                                               pr_des_reto => vr_des_reto,
                                               pr_tab_erro => vr_tab_erro,
                                               pr_tab_pgto_parcel => vr_tab_pgto_parcel_pp,
                                               pr_tab_calculado => vr_tab_calculado_pp);
      
        IF (NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      
        IF vr_tab_pgto_parcel_pp.COUNT = 0 THEN
          CONTINUE;
        END IF;
      
      ELSIF rw_parcela.tpemprst = 2 THEN
      
        vr_tab_pgto_parcel_pos.DELETE;
        vr_tab_calculado_pos.DELETE;
        vr_tab_pgto_parc.DELETE;
      
        CECRED.EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => rw_parcela.cdcooper,
                                                pr_cdprogra => NULL,
                                                pr_dtmvtolt => vr_dtmvtolt,
                                                pr_dtmvtoan => vr_dtmvtoan,
                                                pr_nrdconta => rw_parcela.nrdconta,
                                                pr_nrctremp => rw_parcela.nrctremp,
                                                pr_dtefetiv => rw_parcela.dtmvtolt,
                                                pr_cdlcremp => rw_parcela.cdlcremp,
                                                pr_vlemprst => rw_parcela.vlemprst,
                                                pr_txmensal => rw_parcela.txmensal,
                                                pr_dtdpagto => rw_parcela.dtdpagto,
                                                pr_vlsprojt => rw_parcela.vlsprojt,
                                                pr_qttolatr => rw_parcela.qttolatr,
                                                pr_tab_parcelas => vr_tab_pgto_parcel_pos,
                                                pr_tab_calculado => vr_tab_calculado_pos,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
      
        IF (NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      
        IF vr_tab_pgto_parcel_pos.COUNT = 0 THEN
          CONTINUE;
        END IF;
      END IF;
    
      IF rw_parcela.tpemprst = 1 THEN
        FOR idx IN vr_tab_pgto_parcel_pp.FIRST .. vr_tab_pgto_parcel_pp.LAST LOOP
        
          vr_vlmtapar := vr_vlmtapar +
                         nvl(vr_tab_pgto_parcel_pp(idx).vlmtapar, 0);
          vr_vlmrapar := vr_vlmrapar +
                         nvl(vr_tab_pgto_parcel_pp(idx).vlmrapar, 0);
          vr_vliofcpl := vr_vliofcpl +
                         nvl(vr_tab_pgto_parcel_pp(idx).vliofcpl, 0);
        
        END LOOP;
      
      ELSIF rw_parcela.tpemprst = 2 THEN
        FOR idx IN vr_tab_pgto_parcel_pos.FIRST .. vr_tab_pgto_parcel_pos.LAST LOOP
        
          IF vr_tab_pgto_parcel_pos(idx).dtvencto < vr_dtmvtolt AND vr_tab_pgto_parcel_pos(idx)
             .nrparepr = rw_parcela.nrparepr THEN
          
            vr_vlmtapar := vr_vlmtapar +
                           nvl(vr_tab_pgto_parcel_pos(idx).vlmtapar, 0);
            vr_vlmrapar := vr_vlmrapar +
                           nvl(vr_tab_pgto_parcel_pos(idx).vlmrapar, 0);
            vr_vliofcpl := vr_vliofcpl +
                           nvl(vr_tab_pgto_parcel_pos(idx).vliofcpl, 0);
          
          END IF;
        
        END LOOP;
      END IF;
    END LOOP;
  
    IF nvl(rw_crapepr.tpemprst, 0) = 1 THEN
      -- PP
    
      obterJurosPP(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta,
                   pr_nrctremp => pr_nrctremp, pr_dtmvtolt => vr_dtmvtolt,
                   pr_flnormal => FALSE, pr_dtvencto => NULL,
                   pr_ehmensal => FALSE, pr_dtdpagto => vr_dtmvtolt,
                   -- VERIFICAR *****
                   pr_vljurmes => vr_vljurmes, pr_vljurmes59 => vr_vljurmes59,
                   pr_vljurmes60 => vr_vljurmes60, pr_diarefju => vr_diarefju,
                   pr_mesrefju => vr_mesrefju, pr_anorefju => vr_anorefju,
                   pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
    
    ELSIF nvl(rw_crapepr.tpemprst, 0) = 2 THEN
      -- POS
    
      IF rw_crapepr.dsoperac = 'EMPRESTIMO' THEN
        vr_mora_deb  := 2346;
        vr_mora_cred := 2371;
      ELSIF rw_crapepr.dsoperac = 'FINANCIAMENTO' THEN
        vr_mora_deb  := 2347;
        vr_mora_cred := 2373;
      ELSE
        vr_mora_deb  := 2346;
        vr_mora_cred := 2371;
      END IF;
    
      OPEN cr_mora_pos_deb(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrctremp => pr_nrctremp,
                           pr_dtmvtolt => vr_dtmvtolt,
                           pr_cdhistor => vr_mora_deb);
      FETCH cr_mora_pos_deb
        INTO rw_mora_pos_deb;
      CLOSE cr_mora_pos_deb;
    
      OPEN cr_mora_pos_cred(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_dtmvtolt => vr_dtmvtolt,
                            pr_cdhistor => vr_mora_cred);
      FETCH cr_mora_pos_cred
        INTO rw_mora_pos_cred;
      CLOSE cr_mora_pos_cred;
    
      vr_vlmoralanc := NVL(rw_mora_pos_deb.vllanmto, 0) -
                       NVL(rw_mora_pos_cred.vllanmto, 0);
    
      vr_vlmrapar := vr_vlmrapar - vr_vlmoralanc;
    
      OPEN cr_parc_min(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => pr_nrctremp);
      FETCH cr_parc_min
        INTO rw_parc_min;
      CLOSE cr_parc_min;
    
      obterValorJurosRemPos(pr_cdcooper => pr_cdcooper,
                            pr_dtmvtoan => vr_dtmvtoan,
                            pr_dtmvtolt => vr_dtmvtolt,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_dtvencto => rw_parc_min.dtvencto,
                            pr_diarefju => rw_crapepr.diarefju,
                            pr_mesrefju => rw_crapepr.mesrefju,
                            pr_anorefju => rw_crapepr.anorefju,
                            pr_vljuremu => vr_vljurmes,
                            pr_vljurcor => vr_vljurcor,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic);
    END IF;
  
    pr_vlmtapar   := nvl(vr_vlmtapar, 0);
    pr_vlmrapar   := nvl(vr_vlmrapar, 0);
    pr_vliofcpl   := nvl(vr_vliofcpl, 0);
    pr_vljurmes   := round(nvl(vr_vljurmes, 0), 2);
    pr_vljurcor   := nvl(vr_vljurcor, 0);
    pr_vljurmes59 := round(nvl(vr_vljurmes59, 0), 2);
    pr_vljurmes60 := round(nvl(vr_vljurmes60, 0), 2);
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      cecred.pc_internal_exception(pr_cdcooper, vr_dscritic);
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper);
  END obterValorAtraso;

BEGIN

  dbms_output.enable(NULL);

  OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.BTCH0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE CECRED.BTCH0001.cr_crapdat;

  dbms_output.put_line('COOPERATIVA;PA;CONTA;CONTRATO;PRODUTO;VL MULTA;VL MORA;VL IOF ATRS;VL JUROS REM.;VL JUROS 59;VL JUROS 60;VL JUROS 60 ANTIGO;JUROS CORRECAO;JUROS +60;DIAS ATRASO');

  FOR rw_contrato IN cr_contrato(pr_cdcooper => vr_cdcooper) LOOP
  
    vr_jura60 := 'NAO';
  
    OPEN cr_juro_60(pr_cdcooper => rw_contrato.cdcooper,
                    pr_nrdconta => rw_contrato.nrdconta,
                    pr_nrctremp => rw_contrato.nrctremp,
                    pr_dtrefere => rw_crapdat.dtmvtoan);
    FETCH cr_juro_60
      INTO rw_juro_60;
    CLOSE cr_juro_60;
    IF NVL(rw_juro_60.vljura60, 0) > 0 THEN
      vr_jura60 := 'SIM';
    END IF;
  
    obterValorAtraso(pr_cdcooper => rw_contrato.cdcooper,
                     pr_nrdconta => rw_contrato.nrdconta,
                     pr_nrctremp => rw_contrato.nrctremp,
                     pr_vlmtapar => vr_vlmtapar, pr_vlmrapar => vr_vlmrapar,
                     pr_vliofcpl => vr_vliofcpl, pr_vljurmes => vr_vljurmes,
                     pr_vljurcor => pr_vljurcor,
                     pr_vljurmes59 => vr_vljurmes59,
                     pr_vljurmes60 => vr_vljurmes60);
  
    dbms_output.put_line(rw_contrato.cdcooper || ';' || 
                         rw_contrato.cdagenci || ';' ||
                         rw_contrato.nrdconta || ';' || 
                         rw_contrato.nrctremp || ';' ||
                         rw_contrato.dsoperac || ';' || 
                         vr_vlmtapar || ';' ||
                         vr_vlmrapar || ';' || 
                         vr_vliofcpl || ';' ||
                         vr_vljurmes || ';' || 
                         vr_vljurmes59 || ';' ||
                         vr_vljurmes60 || ';' ||
                         rw_juro_60.vljurantpp || ';' ||
                         pr_vljurcor || ';' ||
                         vr_jura60 || ';' || 
                         nvl(rw_juro_60.qtdiaatr, 0));
  
  END LOOP;

END;
