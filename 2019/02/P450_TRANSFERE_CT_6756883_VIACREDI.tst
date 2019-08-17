PL/SQL Developer Test script 3.0
18
-- Created on 06/02/2019 by T0031667 
declare 
  -- Local variables here
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR(2000);
begin
  -- Test statements here
  PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => 1
                                , pr_nrdconta => 6756883
                                , pr_cdoperad => 1
                                , pr_vllanmto => 1954.00
                                , pr_dtmvtolt => TRUNC(SYSDATE)
                                , pr_versaldo => 0
                                , pr_atsldlib => 0
                                , pr_cdcritic => vr_cdcritic
                                , pr_dscritic => vr_dscritic);
  COMMIT;
end;
0
0
