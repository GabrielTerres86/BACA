PL/SQL Developer Test script 3.0
17
-- Created on 14/01/2019 by T0031667 
declare 
  -- Local variables here
  i integer;
	vr_cdcritic NUMBER;
	vr_dscritic VARCHAR2(2000);
begin
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
	                            , pr_nrdconta => 7334206 
															, pr_cdoperad => 1
															, pr_vlrlanc => 1837.42
															, pr_dtmvtolt => trunc(SYSDATE)
															, pr_cdcritic => vr_cdcritic
															, pr_dscritic => vr_dscritic);
															
	COMMIT;
end;
0
0
