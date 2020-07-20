declare
    --
    -- Ajuste de saldo de contas com movimentos gerados indevidamente em prejuizo
    --
    CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                     , pr_nrdconta NUMBER) IS
    SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
      FROM craplem
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = TRUNC(SYSDATE)
       AND cdagenci = 1
       AND cdbccxlt = 100
       AND nrdolote = 600029
       AND nrdconta = pr_nrdconta
    ;

    CURSOR cr_nrseqdig(pr_cdcooper NUMBER) IS
    SELECT nvl(MAX(nrseqdig), 0) + 1 nrseqdig
      FROM craplem
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = TRUNC(SYSDATE)
       AND cdagenci = 1
       AND cdbccxlt = 100
       AND nrdolote = 600029
    ;
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 9938;
    pr_nrctremp   NUMBER                := 737469;
    pr_dtmvtolt   DATE;
    vr_nrdocmto  NUMBER(18);
    vr_nrseqdig  NUMBER(18);
    vr_cdhistor  NUMBER(18);
    vr_vlpago    NUMBER(18,4);
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    vr_exc_saida  EXCEPTION;
  -------------------------------------
  BEGIN

    FOR rw_craplem IN
    (SELECT cdcooper
          , nrdconta
          , nrctremp
          , cdagenci
          , cdbccxlt
          , nrdolote
          , cdhistor
          , vllanmto
          , cdorigem
          , progress_recid
       FROM craplem
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrctremp
        AND dtmvtolt = to_date('03/06/2020', 'DD/MM/YYYY')
        AND cdhistor IN (2701, 2388, 2390, 2473, 2389, 2475)
    ) LOOP
      OPEN cr_nrdocmto(rw_craplem.cdcooper
                     , rw_craplem.nrdconta);
      FETCH cr_nrdocmto INTO vr_nrdocmto;
      CLOSE cr_nrdocmto;

      OPEN cr_nrseqdig(rw_craplem.cdcooper);
      FETCH cr_nrseqdig INTO vr_nrseqdig;
      CLOSE cr_nrseqdig;

      IF rw_craplem.cdhistor = 2701 THEN
        vr_cdhistor := 2702;
      ELSIF rw_craplem.cdhistor = 2388 THEN
        vr_cdhistor := 2392;
      ELSIF rw_craplem.cdhistor = 2390 THEN
        vr_cdhistor := 2394;
      ELSIF rw_craplem.cdhistor = 2473 THEN
        vr_cdhistor := 2474;
      ELSIF rw_craplem.cdhistor = 2389 THEN
        vr_cdhistor := 2393;
      ELSIF rw_craplem.cdhistor = 2475 THEN
        vr_cdhistor := 2476;
      END IF;

      INSERT INTO craplem (
          dtmvtolt
        , cdagenci
        , cdbccxlt
        , nrdolote
        , nrdconta
        , nrdocmto
        , cdhistor
        , nrseqdig
        , nrctremp
        , vllanmto
        , dtpagemp
        , dthrtran
        , cdorigem
        , cdcooper
      )
      VALUES (
          trunc(SYSDATE)
        , rw_craplem.cdagenci
        , rw_craplem.cdbccxlt
        , rw_craplem.nrdolote
        , rw_craplem.nrdconta
        , vr_nrdocmto
        , vr_cdhistor
        , vr_nrseqdig
        , rw_craplem.nrctremp
        , rw_craplem.vllanmto
        , TRUNC(SYSDATE)
        , SYSDATE
        , rw_craplem.cdorigem
        , rw_craplem.cdcooper
      );

      UPDATE craplem
         SET dtestorn = trunc(SYSDATE)
       WHERE progress_recid = rw_craplem.progress_recid;

      IF rw_craplem.cdhistor = 2701 THEN
        UPDATE crapepr e
           SET vlsdprej = vlsdprej + rw_craplem.vllanmto
             , inliquid = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = rw_craplem.nrctremp;
      END IF;
    END LOOP rw_craplem;
    --

    BEGIN
      SELECT dtmvtolt
        INTO pr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
    END;
    --
      -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(pr_dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

    commit;
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
     pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  END;