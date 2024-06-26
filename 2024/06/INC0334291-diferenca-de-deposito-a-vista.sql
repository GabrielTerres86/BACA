DECLARE
  CURSOR cr_epr IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,pep.nrparepr
          ,epr.cdagenci
          ,epr.cdbccxlt
          ,epr.dtmvtolt
          ,cp.cdoperad
          ,epr.nrdolote
          ,cp.vlpagpar
          ,epr.cdorigem
          ,epr.inliquid
          ,epr.dtliquid
      FROM cecred.crapepr epr
     INNER JOIN cecred.crappep pep
        ON pep.cdcooper = epr.cdcooper
       AND pep.nrdconta = epr.nrdconta
       AND pep.nrctremp = epr.nrctremp
      LEFT JOIN cecred.tbepr_consig_parcelas_tmp cpt
        ON cpt.cdcooper = pep.cdcooper
       AND cpt.nrdconta = pep.nrdconta
       AND cpt.nrctremp = pep.nrctremp
       AND cpt.nrparcela = pep.nrparepr
       AND TRUNC(cpt.dtmovimento) = TRUNC(pep.dtultpag)
      LEFT JOIN cecred.tbepr_consignado_pagamento cp
        ON cp.cdcooper = pep.cdcooper
       AND cp.nrdconta = pep.nrdconta
       AND cp.nrctremp = pep.nrctremp
       AND cp.nrparepr = pep.nrparepr
       AND cp.instatus = 2
     WHERE epr.tpemprst = 1
       AND epr.tpdescto = 2
       AND TRUNC(pep.dtultpag) = TRUNC(TO_DATE('09/05/2024', 'dd/mm/yyyy'))
       AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) in
           ((16, 934402, 672757),
            (16, 994413, 632972),
            (1, 3143880, 6839964),
            (1, 7505272, 7873471))
  AND NOT EXISTS(
    SELECT 1
      FROM cecred.craplem lem
     WHERE lem.cdcooper = pep.cdcooper
       AND lem.nrdconta = pep.nrdconta
       AND lem.nrctremp = pep.nrctremp
       AND lem.nrparepr = pep.nrparepr)
     ORDER BY epr.cdcooper
             ,epr.nrdconta
             ,epr.nrctremp
             ,pep.nrparepr;


  CURSOR cr_liquidado IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.cdagenci
          ,epr.cdbccxlt
          ,epr.dtmvtolt
          ,epr.nrdolote
          ,epr.cdorigem
          ,epr.inliquid
          ,epr.dtliquid
      FROM cecred.crapepr epr
     WHERE epr.tpemprst = 1
       AND epr.tpdescto = 2
       AND epr.inliquid = 1
       AND epr.dtliquid IS NOT NULL
       AND epr.inprejuz = 0
       AND epr.dtprejuz IS NULL
       AND epr.vlsdeved = 0.00
       AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) in
           ((16, 934402, 672757),
            (16, 994413, 632972),
            (1, 3143880, 6839964),
            (1, 7505272, 7873471))
  AND EXISTS(
    SELECT 1
      FROM cecred.crappep pep
     WHERE pep.cdcooper = epr.cdcooper
       AND pep.nrdconta = epr.nrdconta
       AND pep.nrctremp = epr.nrctremp
       AND TRUNC(pep.dtultpag) = TRUNC(TO_DATE('09/05/2024', 'dd/mm/yyyy')))
     ORDER BY epr.cdcooper
             ,epr.nrdconta
             ,epr.nrctremp;


  vr_cdhistor craplem.cdhistor%TYPE;
  vr_vllanmto cecred.craplem.vllanmto%TYPE := 0;

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(32767);

  vr_cdcooper cecred.crapepr.cdcooper%TYPE := NULL;
  vr_nrdconta cecred.crapepr.nrdconta%TYPE := NULL;
  vr_nrctremp cecred.crapepr.nrctremp%TYPE := NULL;

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  vr_cdcooper := 0;
  vr_nrdconta := 0;
  FOR rw_epr IN cr_epr LOOP
  
    IF vr_cdcooper <> rw_epr.cdcooper THEN
    
      OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => rw_epr.cdcooper);
      FETCH cecred.btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE cecred.btch0001.cr_crapdat;
    
      vr_cdcooper := rw_epr.cdcooper;
    
    END IF;
  
    IF NOT (vr_nrdconta = rw_epr.nrdconta AND vr_cdcooper = rw_epr.cdcooper) THEN
    
      OPEN cr_crapass(pr_cdcooper => rw_epr.cdcooper, pr_nrdconta => rw_epr.nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
    
      vr_nrdconta := rw_epr.nrdconta;
    
    END IF;
  
    cecred.empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_epr.cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => rw_crapass.cdagenci,
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600031,
                                           pr_nrdconta => rw_epr.nrdconta,
                                           pr_cdhistor => 1044,
                                           pr_nrctremp => rw_epr.nrctremp,
                                           pr_vllanmto => rw_epr.vlpagpar,
                                           pr_dtpagemp => rw_crapdat.dtmvtolt,
                                           pr_txjurepr => 0,
                                           pr_vlpreemp => 0,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => rw_epr.nrparepr,
                                           pr_flgincre => FALSE,
                                           pr_flgcredi => FALSE,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 5,
                                           pr_qtdiacal => 0,
                                           pr_vltaxprd => 0,
                                           pr_nrautdoc => 0,
                                           pr_nrdoclcm => 0,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  
    DBMS_OUTPUT.PUT_LINE('Codigo Erro: ' || vr_cdcritic || ', Descricao Erro: ' || vr_dscritic);
  
  END LOOP;

  vr_cdcooper := 0;
  vr_nrdconta := 0;

  FOR rw_liquidado IN cr_liquidado LOOP
  
    vr_vllanmto := credito.obtersaldocontratoliquidadoconsignado(pr_cdcooper => rw_liquidado.cdcooper,
                                                                 pr_nrdconta => rw_liquidado.nrdconta,
                                                                 pr_nrctremp => rw_liquidado.nrctremp);
  
    IF vr_vllanmto <> 0 THEN
    
      IF vr_cdcooper <> rw_liquidado.cdcooper THEN
      
        OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => rw_liquidado.cdcooper);
        FETCH cecred.btch0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE cecred.btch0001.cr_crapdat;
      
        vr_cdcooper := rw_liquidado.cdcooper;
      
      END IF;
    
      IF NOT (vr_nrdconta = rw_liquidado.nrdconta AND vr_cdcooper = rw_liquidado.cdcooper) THEN
      
        OPEN cr_crapass(pr_cdcooper => rw_liquidado.cdcooper, pr_nrdconta => rw_liquidado.nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;
        CLOSE cr_crapass;
      
        vr_nrdconta := rw_liquidado.nrdconta;
      
      END IF;
    
      IF NVL(vr_vllanmto, 0) < 0 THEN
        vr_cdhistor := 3918;
        vr_vllanmto := vr_vllanmto * -1;
      ELSIF NVL(vr_vllanmto, 0) > 0 THEN
        vr_cdhistor := 3919;
      END IF;
    
      cecred.empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_liquidado.cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_crapass.cdagenci,
                                             pr_cdbccxlt => 100,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_crapass.cdagenci,
                                             pr_tplotmov => 5,
                                             pr_nrdolote => 600031,
                                             pr_nrdconta => rw_liquidado.nrdconta,
                                             pr_cdhistor => vr_cdhistor,
                                             pr_nrctremp => rw_liquidado.nrctremp,
                                             pr_vllanmto => vr_vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => 0,
                                             pr_vlpreemp => 0,
                                             pr_nrsequni => 0,
                                             pr_nrparepr => 0,
                                             pr_flgincre => FALSE,
                                             pr_flgcredi => FALSE,
                                             pr_nrseqava => 0,
                                             pr_cdorigem => 5,
                                             pr_qtdiacal => 0,
                                             pr_vltaxprd => 0,
                                             pr_nrautdoc => 0,
                                             pr_nrdoclcm => 0,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
