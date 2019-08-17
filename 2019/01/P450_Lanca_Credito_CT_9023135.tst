PL/SQL Developer Test script 3.0
15
-- Created on 17/01/2019 by T0031667 
declare 
  vr_cdcritic NUMBER;
	vr_dscritic VARCHAR(2000);
begin
  -- Test statements here
  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => 1
	                            , pr_nrdconta => 9023135
															, pr_cdoperad => 1
															, pr_vlrlanc  => 51.30
															, pr_dtmvtolt => TRUNC(SYSDATE)
															, pr_cdcritic => vr_cdcritic
															, pr_dscritic => vr_dscritic);
	COMMIT;
end;
0
0
