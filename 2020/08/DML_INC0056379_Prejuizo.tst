PL/SQL Developer Test script 3.0
37
DECLARE

  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;
  vr_exc_erro  EXCEPTION;
  
BEGIN

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(:pr_cdcooper);
  FETCH btch0001.cr_crapdat
  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  -- Call the procedure
  prej0003.pc_gera_transf_cta_prj(pr_cdcooper => :pr_cdcooper,
                                  pr_nrdconta => :pr_nrdconta,
                                  pr_cdoperad => :pr_cdoperad,
                                  pr_vllanmto => :pr_vllanmto,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                  pr_versaldo => :pr_versaldo,
                                  pr_atsldlib => :pr_atsldlib,
                                  pr_dsoperac => :pr_dsoperac,
                                  pr_cdcritic => :pr_cdcritic,
                                  pr_dscritic => :pr_dscritic);
                                  
  IF :pr_cdcritic > 0 OR
     :pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;
  
EXCEPTION      
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,:pr_cdcrititc ||'-'|| :pr_dscritic);
END;
11
pr_cdcooper
1
6
4
pr_nrdconta
1
113557
4
pr_cdoperad
1
1
5
pr_vllanmto
1
7,35
4
pr_dtmvtolt
0
-12
pr_versaldo
1
1
4
pr_atsldlib
1
0
4
pr_dsoperac
1
Ajuste Contabil - INC0056379
5
pr_cdcritic
1
0
3
pr_dscritic
0
5
pr_cdcrititc
0
5
0
