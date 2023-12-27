DECLARE
  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat CECRED.BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM CECRED.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_lancamentos IS 
   SELECT l.cdcooper
       , l.nrdconta
       , l.nrctremp
       , NVL((SUM(CASE WHEN l.cdhistor IN (2383, 2384, 2398, 2399) THEN l.vllanmto ELSE 0 END) - 
              SUM(CASE WHEN l.cdhistor IN (4459) THEN l.vllanmto ELSE 0 END)),0) vllanto_hists
    FROM cecred.craplem l
    JOIN cecred.crapepr e ON (e.cdcooper=l.cdcooper AND e.nrdconta=l.nrdconta AND e.nrctremp=l.nrctremp)
   WHERE l.dtmvtolt >= TO_DATE('19/12/2023','DD/MM/YYYY')
     AND l.cdhistor IN (2383, 2384, 2398, 2399, 4459)
     AND e.tpemprst = 1
   GROUP BY l.cdcooper, l.nrdconta, l.nrctremp
     UNION
   SELECT l.cdcooper
       , l.nrdconta
       , l.nrctremp
       , NVL((SUM(CASE WHEN l.cdhistor IN (2384, 2399) THEN l.vllanmto ELSE 0 END) - 
              SUM(CASE WHEN l.cdhistor IN (4459) THEN l.vllanmto ELSE 0 END)),0) vllanto_hists
    FROM cecred.craplem l
    JOIN cecred.crapepr e ON (e.cdcooper=l.cdcooper AND e.nrdconta=l.nrdconta AND e.nrctremp=l.nrctremp)
   WHERE l.dtmvtolt >= TO_DATE('19/12/2023','DD/MM/YYYY')
     AND l.cdhistor IN (2384, 2399, 4459)
     AND e.tpemprst = 2
   GROUP BY l.cdcooper, l.nrdconta, l.nrctremp; 
     
BEGIN

  OPEN CECRED.btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH CECRED.btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE CECRED.btch0001.cr_crapdat;
  
  FOR rw_lancamentos IN cr_lancamentos LOOP
 
     OPEN cr_crapass(pr_cdcooper => rw_lancamentos.cdcooper, pr_nrdconta => rw_lancamentos.nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     CLOSE cr_crapass;

     empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_lancamentos.cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_crapass.cdagenci
                                   ,pr_cdbccxlt => 100
                                   ,pr_cdoperad => 1
                                   ,pr_cdpactra => rw_crapass.cdagenci
                                   ,pr_tplotmov => 5
                                   ,pr_nrdolote => 600029
                                   ,pr_nrdconta => rw_lancamentos.nrdconta
                                   ,pr_cdhistor => 4459
                                   ,pr_nrctremp => rw_lancamentos.nrctremp
                                   ,pr_vllanmto => rw_lancamentos.vllanto_hists
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => 0
                                   ,pr_vlpreemp => 0
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => false
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
     END IF;

     COMMIT;      
   END LOOP;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
