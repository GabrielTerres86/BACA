PL/SQL Developer Test script 3.0
13
-- Created on 15/02/2019 by T0031667 
declare 
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
begin
  -- Test statements here
  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => 16
                              , pr_nrdconta => 57142
                              , pr_vlrlanc => 260.00
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
end;
0
0
