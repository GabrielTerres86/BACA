PL/SQL Developer Test script 3.0
40
-- Created on 26/03/2019 by T0031667 
declare 
  -- Local variables here
  i integer;
begin
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 2581078
                              , pr_vlrlanc  => 470.05
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF trim(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 4056868
                              , pr_vlrlanc  => 688.15
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF trim(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8940150
                              , pr_vlrlanc  => 331.47
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF trim(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  COMMIT;
end;
0
0
