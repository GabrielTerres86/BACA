-- Created on 02/10/2020 by T0032717 
DECLARE 
 
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
BEGIN
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => 5);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  empr0001.pc_cria_lancamento_lem(pr_cdcooper => 5
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => 1
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600029
                                 ,pr_nrdconta => 93289
                                 ,pr_cdhistor => 2391 -- abono
                                 ,pr_nrctremp => 10459
                                 ,pr_vllanmto => 1456.34
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
                                 ,pr_flgincre => TRUE 
                                 ,pr_flgcredi => FALSE  
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 7 -- batch
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
       
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;
