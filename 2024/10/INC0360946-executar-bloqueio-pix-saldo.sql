DECLARE
  vr_cdcooper   CONSTANT NUMBER := 16;
  vr_nrdconta   CONSTANT NUMBER := 18301720;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(2000);
  vr_vllanpnd   NUMBER := 2728.70;
BEGIN 
  
  OPEN  btch0001.cr_crapdat(vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  CONTACORRENTE.controleBloqueioPix(pr_dtmvtolt => btch0001.rw_crapdat.dtmvtolt
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_cdbccxlt => 85
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrdocmto => 115001
                                   ,pr_nrdctabb => 18301720
                                   ,pr_vllanpnd => vr_vllanpnd
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
  
  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao executar rotina de bloqueio: '||vr_cdcritic||' - '||vr_dscritic);
  END IF;
  
  COMMIT;
  
END;
