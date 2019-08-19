PL/SQL Developer Test script 3.0
122
-- Created on 27/02/2019 by T0031667 
declare 
  -- Local variables here
  i integer;
BEGIN
  :RESULT:= 'Erro';
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8271895
                              , pr_vlrlanc => 81.32
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8271895
                              , pr_vlrlanc => 286.51
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 2699249
                              , pr_vlrlanc => 2588.47
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 13
                              , pr_nrdconta => 49077
                              , pr_vlrlanc => 691.78
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8014574
                              , pr_vlrlanc => 347.53
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 7081693
                              , pr_vlrlanc => 166.69
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8731560
                              , pr_vlrlanc => 842.89
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 13
                              , pr_nrdconta => 400866
                              , pr_vlrlanc => 2733.76
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8874980
                              , pr_vlrlanc => 53.28
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  prej0003.pc_gera_debt_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 8874980
                              , pr_vlrlanc => 77.68
                              , pr_dtmvtolt => TRUNC(SYSDATE) 
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF nvl(:pr_cdcritic, 0) > 0 OR TRIM(:pr_dscritic) IS NOT NULL THEN
    RETURN;
  END IF;
  
  COMMIT;
  
  :RESULT:= 'Sucesso';
end;
0
0
