DECLARE
  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000);

  CURSOR cr_craplcm IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,a.cdagenci
          ,a.cdbccxlt
          ,a.cdoperad
          ,a.dtmvtolt
          ,a.nrdolote
          ,a.cdhistor
          ,a.cdorigem
          ,a.vllanmto
          ,a.nrparepr
          ,c.vlpreemp
          ,c.txjuremp
          ,c.nrctremp
      FROM craplcm a
          ,crapepr c
     WHERE a.cdcooper = c.cdcooper
       AND a.nrdconta = c.nrdconta
       AND TRIM(REPLACE(a.cdpesqbb, '.', '')) = c.nrctremp
       AND a.cdcooper = 13
       AND a.nrdconta = 156680
       AND a.nrparepr IN (1, 2)
       AND a.nrdocmto IN (4, 5)
       AND a.cdhistor = 3089
     GROUP BY a.cdcooper
             ,a.nrdconta
             ,a.cdagenci
             ,a.cdbccxlt
             ,a.cdoperad
             ,a.dtmvtolt
             ,a.nrdolote
             ,a.cdhistor
             ,a.cdorigem
             ,a.vllanmto
             ,a.nrparepr
             ,c.vlpreemp
             ,c.txjuremp
             ,c.nrctremp;

BEGIN

  FOR rw_craplcm IN cr_craplcm LOOP
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper,
                                    pr_dtmvtolt => rw_craplcm.dtmvtolt,
                                    pr_cdagenci => rw_craplcm.cdagenci,
                                    pr_cdbccxlt => rw_craplcm.cdbccxlt,
                                    pr_cdoperad => rw_craplcm.cdoperad,
                                    pr_cdpactra => rw_craplcm.cdagenci,
                                    pr_tplotmov => 5,
                                    pr_nrdolote => rw_craplcm.nrdolote,
                                    pr_nrdconta => rw_craplcm.nrdconta,
                                    pr_cdhistor => 1044,
                                    pr_nrctremp => rw_craplcm.nrctremp,
                                    pr_vllanmto => rw_craplcm.vllanmto,
                                    pr_dtpagemp => rw_craplcm.dtmvtolt,
                                    pr_txjurepr => rw_craplcm.txjuremp,
                                    pr_vlpreemp => rw_craplcm.vlpreemp,
                                    pr_nrsequni => rw_craplcm.nrparepr,
                                    pr_nrparepr => rw_craplcm.nrparepr,
                                    pr_flgincre => TRUE,
                                    pr_flgcredi => TRUE,
                                    pr_nrseqava => 0,
                                    pr_cdorigem => 5,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
  
  END LOOP;

  COMMIT;

END;
