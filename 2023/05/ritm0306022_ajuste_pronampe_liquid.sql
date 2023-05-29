declare 
  vr_cdcritic      cecred.crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  rw_crapdat       cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto      varchar(3);
  vr_tab_erro      cecred.GENE0001.typ_tab_erro;
  
  vr_cdcooper      cecred.crapcop.cdcooper%TYPE := 12;
  vr_nrdconta      cecred.crapass.nrdconta%TYPE;
  vr_nrctremp      cecred.craplem.nrctremp%TYPE;
  vr_vlmrapar      cecred.crappep.vlmrapar%type; 
  vr_vlmtapar      cecred.crappep.vlmtapar%TYPE; 
  vr_vlpagpar      cecred.crappep.vlpagpar%TYPE; 
  vr_vllanmto      cecred.craplem.vllanmto%TYPE;
  vr_cdhistor      cecred.craplem.cdhistor%TYPE;
  vr_vlsprojt	   cecred.crapepr.vlsprojt%TYPE;
  vr_vlparepr	   cecred.crappep.vlparepr%TYPE;

  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;
  
  vr_nrdconta := 566;
  vr_nrctremp := 60028;
  vr_vllanmto := 57314.20;
  vr_vlsprojt := 57314.20;
  vr_vlparepr := 2044.46;
  vr_cdhistor := 3273;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;
  
  cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => vr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => rw_crapass.cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => 1
                                         ,pr_cdpactra => rw_crapass.cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600031
                                         ,pr_nrdconta => vr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_nrctremp => vr_nrctremp
                                         ,pr_vllanmto => vr_vllanmto
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => FALSE
                                         ,pr_flgcredi => FALSE
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 5
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  BEGIN
    UPDATE cecred.crappep c
       SET vlsdvpar = vr_vlparepr, 
           vlsdvatu = vr_vlparepr, 
           vlpagmra = 0,
           vlpagmta = 0,
           inliquid = 0,  
           vlpagpar = 0, 
           vldespar = 0,
           dtultpag = null
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp;
       
 
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN

    UPDATE cecred.crapepr crapepr
       SET crapepr.vlsdeved = vr_vllanmto,
           crapepr.vlsprojt = vr_vlsprojt,
           crapepr.inliquid = 0,
		   crapepr.dtliquid = null
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  vr_nrdconta := 174939;
  vr_nrctremp := 59734;
  vr_vllanmto := 129460.75;
  vr_vlsprojt := 129460.75;
  vr_vlparepr := 4456.96;
  vr_cdhistor := 3273;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;
  
  cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => vr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => rw_crapass.cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => 1
                                         ,pr_cdpactra => rw_crapass.cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600031
                                         ,pr_nrdconta => vr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_nrctremp => vr_nrctremp
                                         ,pr_vllanmto => vr_vllanmto
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => FALSE
                                         ,pr_flgcredi => FALSE
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 5
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  

  BEGIN
    UPDATE cecred.crappep c
       SET vlsdvpar = vr_vlparepr, 
           vlsdvatu = vr_vlparepr, 
           vlpagmra = 0,
           vlpagmta = 0,
           inliquid = 0,  
           vlpagpar = 0, 
           vldespar = 0,
           dtultpag = null
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
	   AND c.nrparepr > 9;
       
 
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN

    UPDATE cecred.crapepr crapepr
       SET crapepr.vlsdeved = vr_vllanmto,
           crapepr.vlsprojt = vr_vlsprojt,
           crapepr.inliquid = 0,
		   crapepr.dtliquid = null,
		   crapepr.qtprepag = 9
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  vr_nrdconta := 198170;
  vr_nrctremp := 59780;
  vr_vllanmto := 33242.23;
  vr_vlsprojt := 33242.23;
  vr_vlparepr := 1185.95;
  vr_cdhistor := 3273;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;
  
  cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => vr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => rw_crapass.cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => 1
                                         ,pr_cdpactra => rw_crapass.cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600031
                                         ,pr_nrdconta => vr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_nrctremp => vr_nrctremp
                                         ,pr_vllanmto => vr_vllanmto
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => FALSE
                                         ,pr_flgcredi => FALSE
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 5
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  

  BEGIN
    UPDATE cecred.crappep c
       SET vlsdvpar = vr_vlparepr, 
           vlsdvatu = vr_vlparepr, 
           vlpagmra = 0,
           vlpagmta = 0,
           inliquid = 0,  
           vlpagpar = 0, 
           vldespar = 0,
           dtultpag = null
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp;
       
 
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN

    UPDATE cecred.crapepr crapepr
       SET crapepr.vlsdeved = vr_vllanmto,
           crapepr.vlsprojt = vr_vlsprojt,
           crapepr.inliquid = 0,
		   crapepr.dtliquid = null
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_APPLICATION_ERROR(-20500, vr_dscritic || ' - ' || SQLERRM);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, vr_dscritic || ' - ' || SQLERRM);
    ROLLBACK;
END;
