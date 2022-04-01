DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_said EXCEPTION;
  vr_des_reto VARCHAR(100);
  vr_tab_erro GENE0001.typ_tab_erro;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper NUMBER := 1;
  vr_nrdconta NUMBER := 2050706;
  vr_nrctremp NUMBER := 250253;
  vr_cdagenci NUMBER := 51;
  vr_vllanmto craplem.vllanmto%TYPE := 277695.26;

  vr_txmensal crapepr.txmensal%TYPE := 1.8;
  vr_cdhistor craplem.cdhistor%TYPE := 2403;

BEGIN
   OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  UPDATE crapepr e
     SET e.inliquid = 0
        ,e.vlsdeved = vr_vllanmto
        ,e.vlsdevat = vr_vllanmto
        ,e.txmensal = vr_txmensal
        ,e.qtmesdec = TRUNC(months_between(SYSDATE,e.dtmvtolt))
   WHERE e.cdcooper = vr_cdcooper
     AND e.nrdconta = vr_nrdconta 
     AND e.nrctremp = vr_nrctremp;

  PREJ0001.pc_transfere_epr_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                       ,pr_cdagenci => vr_cdagenci
                                       ,pr_nrdcaixa => 100
                                       ,pr_cdoperad => 1
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_nrctremp => vr_nrctremp
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);
         
  IF vr_des_reto <> 'OK' THEN
    vr_dscritic := 'Erro na transferencia para prejuizo: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
    RAISE vr_exc_said;
  END IF;

  vr_nrctremp := 230031;
  vr_vllanmto := 239385.25;

  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => vr_cdagenci
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600031
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_cdhistor => vr_cdhistor
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
                                 ,pr_flgincre => FALSE
                                 ,pr_flgcredi => FALSE
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 5
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_said;
  END IF;

  UPDATE crapepr e
     SET e.vlsdeved = 0
        ,e.vlsdprej = 0
        ,e.vlsdevat = 0
        ,e.txmensal = 0
   WHERE e.cdcooper = vr_cdcooper
     AND e.nrdconta = vr_nrdconta 
     AND e.nrctremp = vr_nrctremp;

  COMMIT;

EXCEPTION
  WHEN vr_exc_said THEN
    RAISE_application_error(-20500,vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
