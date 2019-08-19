PL/SQL Developer Test script 3.0
102
-- Created on 01/04/2019 by T0031667 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => 1
                              , pr_nrdconta => 2581078
                              , pr_vlrlanc  => 1384.62
                              , pr_dtmvtolt => TRUNC(SYSDATE)
                              , pr_cdcritic => :pr_cdcritic
                              , pr_dscritic => :pr_dscritic);
                              
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
    RETURN;
  END IF;
  
  -- Conta 6729983 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (13067, 13068, 13069);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 8405.00
   WHERE cdcooper = 1
     AND nrdconta = 6729983;
     
  -- Conta 7696620 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (12361, 12474);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 300.00
   WHERE cdcooper = 1
     AND nrdconta = 7696620;   
     
  -- Conta 6051200 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (8445, 8481, 8562);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 1649.98
   WHERE cdcooper = 1
     AND nrdconta = 6051200;
     
  -- Conta 2765756 / Viacredi Alto Vale
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (10471, 10812);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 1600.00
   WHERE cdcooper = 16
     AND nrdconta = 2765756;
     
  -- Conta 8493898 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (8014, 8015, 8016, 8512, 8513, 8514);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 699.40
   WHERE cdcooper = 1
     AND nrdconta = 8493898;
     
  -- Conta 7769946 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (8017,8018,8019,8020,8021,8022,8515,8516,8517,8518,8519,8520,
                      15143,15144,15145,15146,15147,15148);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (1521.04 + 760.52)
   WHERE cdcooper = 1
     AND nrdconta = 7769946;
     
     
  -- Conta 54976 / Credcrea
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto = 14736;
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 9.90
   WHERE cdcooper = 7
     AND nrdconta = 54976;
     
  -- Conta 8811539 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto = 15149;
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 119.90
   WHERE cdcooper = 1
     AND nrdconta = 8811539;
     
  -- Conta 7235690 / Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto = 4898;
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 45.44
   WHERE cdcooper = 1
     AND nrdconta = 8811539;   
     
  COMMIT;
end;
2
pr_cdcritic
0
5
pr_dscritic
0
5
0
