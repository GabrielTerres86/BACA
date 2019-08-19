PL/SQL Developer Test script 3.0
488
-- Created on 21/03/2019 by T0031667 
declare  
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_dtmvtolt DATE
                   , pr_cdagenci NUMBER
                   , pr_cdbccxlt NUMBER
                   , pr_nrdolote NUMBER
                   , pr_nrdctabb NUMBER) IS 
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplcm
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = pr_dtmvtolt
     AND cdagenci = pr_cdagenci
     AND cdbccxlt = pr_cdbccxlt
     AND nrdctabb = pr_nrdctabb;
     
  vr_nrdocmto NUMBER;  
  vr_incrineg INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;   
BEGIN
  :RESULT := 'Erro';
  
  /*******************************************
  * CREDCREA - Conta 239950 - Contrato 19005 *
  *******************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 7
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 239950);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 239950
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 93.38
                                   , pr_nrdctabb => 239950 
                                   , pr_cdcooper => 7
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 7
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 239950);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 239950
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 93.38
                                   , pr_nrdctabb => 239950 
                                   , pr_cdpesqbb => '19.005'
                                   , pr_cdcooper => 7
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 93.38
   WHERE cdcooper = 7
     AND nrdconta = 239950
     AND nrctremp = 19005;
     
  /*******************************************
  * CIVIA - Conta 81434 - Contrato 19881     *
  *******************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 13
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 81434);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 81434
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 40.24
                                   , pr_nrdctabb => 81434 
                                   , pr_cdcooper => 13
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 13
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 81434);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 81434
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 40.24
                                   , pr_nrdctabb => 81434 
                                   , pr_cdpesqbb => '19.881'
                                   , pr_cdcooper => 13
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 40.24
   WHERE cdcooper = 13
     AND nrdconta = 81434
     AND nrctremp = 19881;
     
  /**********************************************
  * VIACREDI - Conta 6585833 - Contrato 1050801 *
  **********************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 6585833);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 6585833
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 4.52
                                   , pr_nrdctabb => 6585833 
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 6585833);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 6585833
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 4.52
                                   , pr_nrdctabb => 6585833 
                                   , pr_cdpesqbb => '1.050.801'
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 4.52
   WHERE cdcooper = 1
     AND nrdconta = 6585833
     AND nrctremp = 1050801;
     
  /**********************************************
  * VIACREDI - Conta 9088695 - Contrato 1157970 *
  **********************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 9088695);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 9088695
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 43.57
                                   , pr_nrdctabb => 9088695 
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 9088695);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 9088695
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 43.57
                                   , pr_nrdctabb => 9088695 
                                   , pr_cdpesqbb => '1.157.970'
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 43.57
   WHERE cdcooper = 1
     AND nrdconta = 9088695
     AND nrctremp = 1157970;
     
  /**********************************************
  * VIACREDI - Conta 6695400 - Contrato 1077111 *
  **********************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 6695400);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 6695400
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 10.45
                                   , pr_nrdctabb => 6695400 
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 1
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 6695400);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 6695400
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 10.45
                                   , pr_nrdctabb => 6695400 
                                   , pr_cdpesqbb => '1.077.111'
                                   , pr_cdcooper => 1
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 10.45
   WHERE cdcooper = 1
     AND nrdconta = 6695400
     AND nrctremp = 1077111;
     
  /**********************************************
  * ALTOVALE - Conta 296040 - Contrato 75482    *
  **********************************************/
  OPEN cr_nrdocmto(pr_cdcooper => 16
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 2228
                 , pr_nrdctabb => 296040);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 2228
                                   , pr_nrdconta => 296040
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 362
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 0.59
                                   , pr_nrdctabb => 296040 
                                   , pr_cdcooper => 16
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  OPEN cr_nrdocmto(pr_cdcooper => 16
                 , pr_dtmvtolt => TRUNC(SYSDATE)
                 , pr_cdagenci => 1
                 , pr_cdbccxlt => 100
                 , pr_nrdolote => 8457
                 , pr_nrdctabb => 296040);
  FETCH cr_nrdocmto INTO vr_nrdocmto;
  CLOSE cr_nrdocmto;
  
  lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => TRUNC(SYSDATE)
                                   , pr_cdagenci => 1
                                   , pr_cdbccxlt => 100
                                   , pr_nrdolote => 8457
                                   , pr_nrdconta => 296040
                                   , pr_nrdocmto => vr_nrdocmto
                                   , pr_cdhistor => 2317
                                   , pr_nrseqdig => 1
                                   , pr_vllanmto => 0.59
                                   , pr_nrdctabb => 296040 
                                   , pr_cdpesqbb => '75.482'
                                   , pr_cdcooper => 16
                                   , pr_cdoperad => '1'
                                   , pr_incrineg => vr_incrineg
                                   , pr_tplotmov => 1
                                   , pr_inprolot => 1
                                   , pr_tab_retorno => vr_tab_retorno
                                   , pr_cdcritic => :pr_cdcritic
                                   , pr_dscritic => :pr_dscritic);
                                   
  IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN 
    RETURN;
  END IF;
  
  UPDATE crapepr epr
     SET epr.vlpiofpr = epr.vlpiofpr + 0.59
   WHERE cdcooper = 16
     AND nrdconta = 296040
     AND nrctremp = 75482;
     
  /*********************************************
  * VIACREDI - Conta 6904440 - Contrato 981991 *
  *********************************************/
  UPDATE crapepr epr
     SET epr.vlpgjmpr = 25.52
   WHERE cdcooper = 1
     AND nrdconta = 6904440
     AND nrctremp = 981991; 
  
  /*********************************************
  * CIVIA - Conta 253523 - Contrato 14414      *
  *********************************************/ 
  UPDATE crapepr epr
     SET epr.vlpgjmpr = 68.54
   WHERE cdcooper = 13
     AND nrdconta = 243523
     AND nrctremp = 14414; 
     
  COMMIT;
  
  :RESULT:= 'Sucesso';
end;
2
pr_cdcritic
0
5
pr_dscritic
0
5
0
