DECLARE

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
BEGIN
  
  DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => 1
                                         ,pr_nrdconta => 6584519
                                         ,pr_nrborder => 558863
                                         ,pr_dtmvtolt => to_date('29/05/2019','DD/MM/RRRR')
                                         ,pr_cdbandoc => 85
                                         ,pr_nrdctabb => 10120
                                         ,pr_nrcnvcob => 10120
                                         ,pr_nrdocmto => 5541
                                         ,pr_nrtitulo => 6
                                         ,pr_cdorigem => 7
                                         ,pr_cdhistor => 2668
                                         ,pr_vllanmto => 10.50
                                         ,pr_dscritic => vr_dscritic);

  -- Condicao para verificar se houve critica
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro! ' || vr_dscritic);
    RETURN;
  END IF;
  
  SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat where cdcooper = 1;
  
  -- devolução 362
  DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => vr_dtmvtolt
                             ,pr_cdagenci => 26
                             ,pr_cdbccxlt => 100
                             ,pr_nrdconta => 6584519
                             ,pr_vllanmto => 4.97--2.21
                             ,pr_cdhistor => 362
                             ,pr_cdcooper => 1
                             ,pr_cdoperad => '1'
                             ,pr_nrborder => 558863
                             ,pr_cdpactra => 0
                             ,pr_nrdocmto => 5541
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
  -- Condicao para verificar se houve critica
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro! ' || vr_dscritic);
    RETURN;
  END IF;
  
  -- devolução 325
  DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => vr_dtmvtolt
                             ,pr_cdagenci => 26
                             ,pr_cdbccxlt => 100
                             ,pr_nrdconta => 6584519
                             ,pr_vllanmto => 0.20
                             ,pr_cdhistor => 325
                             ,pr_cdcooper => 1
                             ,pr_cdoperad => '1'
                             ,pr_nrborder => 558863
                             ,pr_cdpactra => 0
                             ,pr_nrdocmto => 5541
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
  -- Condicao para verificar se houve critica
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('erro! ' || vr_dscritic);
    RETURN;
  END IF;
  
  UPDATE craptdb SET vlpagiof = 0.33, vlmratit = 10.5, vlpagmra = 10.5 where cdcooper = 1 and nrdconta = 6584519 and nrborder = 558863 and nrdocmto = 5541;
  
  COMMIT;
END;
/*
/

select * from craptdb where cdcooper = 1 and nrdconta = 6584519 and nrborder = 558863 and nrdocmto = 5541;
select * from tbdsct_lancamento_bordero where cdcooper = 1 and nrdconta = 6584519 and nrborder = 558863 and nrdocmto = 5541;
select * from craplcm where cdcooper = 1 and nrdconta = 6584519 and cdhistor IN (325,362) and dtmvtolt = (select dtmvtolt from crapdat where cdcooper = 1) and nrdocmto = 5541;

BEGIN
 ROLLBACK;
END;
*/
