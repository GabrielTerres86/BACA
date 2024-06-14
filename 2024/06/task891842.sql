DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto  varchar(3);
  vr_tab_erro  cecred.GENE0001.typ_tab_erro;
  vr_conta_dev cecred.crapepr.nrdconta%TYPE;

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE,
    vr_nrparepr cecred.craplem.nrparepr%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
	
  UPDATE CECRED.CRAPEPR
     SET INLIQUID = 1
		,VLSDEVED = 0.0000000000
		,VLSDVCTR = 0.00
		,VLSDEVAT = 0.0000000000
		,QTPREPAG = 24
		,QTPRECAL = 24				
   WHERE CDCOOPER = 13
     AND NRDCONTA = 281069
     AND NRCTREMP = 289581;
	 
  UPDATE CECRED.CRAPPEP
     SET DTULTPAG = TO_DATE('09/05/2024', 'DD/MM/YYYY') 
		,VLPAGPAR = 256.00
		,INLIQUID = 1
		,VLSDVPAR = 0.00
		,VLSDVATU = 0.0000000000
   WHERE CDCOOPER = 13
     AND NRDCONTA = 281069
     AND NRCTREMP = 289581
	 AND NRPAREPR IN (11,12,13)
     AND INLIQUID = 0;  	
		

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 255.77;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 11;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 252.20;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 12;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 248.79;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 13;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 245.32;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 14;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 241.90;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 15;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 238.64;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 16;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 235.31;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 17;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 232.13;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 18;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 228.89;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 19;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 225.70;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 20;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 222.85;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 21;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 219.74;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 22;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 216.78;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 23;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 281069;
  v_dados(v_dados.last()).vr_nrctremp := 289581;
  v_dados(v_dados.last()).vr_vllanmto := 213.75;
  v_dados(v_dados.last()).vr_cdhistor := 3027;
  v_dados(v_dados.last()).vr_nrparepr := 24;
      
  

  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP
  
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => v_dados(x).vr_cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => rw_crapass.cdagenci,
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600031,
                                           pr_nrdconta => v_dados(x).vr_nrdconta,
                                           pr_cdhistor => v_dados(x).vr_cdhistor,
                                           pr_nrctremp => v_dados(x).vr_nrctremp,
                                           pr_vllanmto => v_dados(x).vr_vllanmto,
                                           pr_dtpagemp => rw_crapdat.dtmvtolt,
                                           pr_txjurepr => 0,
                                           pr_vlpreemp => 0,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => v_dados(x).vr_nrparepr,
                                           pr_flgincre => FALSE,
                                           pr_flgcredi => FALSE,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 5,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
