DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro cecred.GENE0001.typ_tab_erro;

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE);

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

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 65234;
	v_dados(v_dados.last()).vr_nrctremp := 47787;
	v_dados(v_dados.last()).vr_vllanmto := 531.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 387630;
	v_dados(v_dados.last()).vr_nrctremp := 60080;
	v_dados(v_dados.last()).vr_vllanmto := 29.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 392740;
	v_dados(v_dados.last()).vr_nrctremp := 72380;
	v_dados(v_dados.last()).vr_vllanmto := 388.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 398675;
	v_dados(v_dados.last()).vr_nrctremp := 60300;
	v_dados(v_dados.last()).vr_vllanmto := 332.95;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 404322;
	v_dados(v_dados.last()).vr_nrctremp := 68438;
	v_dados(v_dados.last()).vr_vllanmto := 41.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 427497;
	v_dados(v_dados.last()).vr_nrctremp := 68493;
	v_dados(v_dados.last()).vr_vllanmto := 393.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 439843;
	v_dados(v_dados.last()).vr_nrctremp := 76500;
	v_dados(v_dados.last()).vr_vllanmto := 76.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 441350;
	v_dados(v_dados.last()).vr_nrctremp := 78548;
	v_dados(v_dados.last()).vr_vllanmto := 31.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 441481;
	v_dados(v_dados.last()).vr_nrctremp := 79983;
	v_dados(v_dados.last()).vr_vllanmto := 54.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 441937;
	v_dados(v_dados.last()).vr_nrctremp := 81748;
	v_dados(v_dados.last()).vr_vllanmto := 17.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 445940;
	v_dados(v_dados.last()).vr_nrctremp := 82037;
	v_dados(v_dados.last()).vr_vllanmto := 54.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14096960;
	v_dados(v_dados.last()).vr_nrctremp := 73531;
	v_dados(v_dados.last()).vr_vllanmto := 141.77;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14116243;
	v_dados(v_dados.last()).vr_nrctremp := 84510;
	v_dados(v_dados.last()).vr_vllanmto := 44.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14125463;
	v_dados(v_dados.last()).vr_nrctremp := 71769;
	v_dados(v_dados.last()).vr_vllanmto := 90.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14129469;
	v_dados(v_dados.last()).vr_nrctremp := 71369;
	v_dados(v_dados.last()).vr_vllanmto := 35.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14136651;
	v_dados(v_dados.last()).vr_nrctremp := 71457;
	v_dados(v_dados.last()).vr_vllanmto := 122.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14139375;
	v_dados(v_dados.last()).vr_nrctremp := 71958;
	v_dados(v_dados.last()).vr_vllanmto := 18.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14143836;
	v_dados(v_dados.last()).vr_nrctremp := 82239;
	v_dados(v_dados.last()).vr_vllanmto := 35.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14173905;
	v_dados(v_dados.last()).vr_nrctremp := 71977;
	v_dados(v_dados.last()).vr_vllanmto := 21.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14192020;
	v_dados(v_dados.last()).vr_nrctremp := 80677;
	v_dados(v_dados.last()).vr_vllanmto := 116.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14202778;
	v_dados(v_dados.last()).vr_nrctremp := 73399;
	v_dados(v_dados.last()).vr_vllanmto := 94.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14203324;
	v_dados(v_dados.last()).vr_nrctremp := 72406;
	v_dados(v_dados.last()).vr_vllanmto := 68.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14227789;
	v_dados(v_dados.last()).vr_nrctremp := 72609;
	v_dados(v_dados.last()).vr_vllanmto := 79.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14254395;
	v_dados(v_dados.last()).vr_nrctremp := 80713;
	v_dados(v_dados.last()).vr_vllanmto := 87.66;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14269970;
	v_dados(v_dados.last()).vr_nrctremp := 76985;
	v_dados(v_dados.last()).vr_vllanmto := 61.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14283581;
	v_dados(v_dados.last()).vr_nrctremp := 73679;
	v_dados(v_dados.last()).vr_vllanmto := 98.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14333929;
	v_dados(v_dados.last()).vr_nrctremp := 73920;
	v_dados(v_dados.last()).vr_vllanmto := 57.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14418940;
	v_dados(v_dados.last()).vr_nrctremp := 75101;
	v_dados(v_dados.last()).vr_vllanmto := 66.03;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14419041;
	v_dados(v_dados.last()).vr_nrctremp := 75119;
	v_dados(v_dados.last()).vr_vllanmto := 113.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14462338;
	v_dados(v_dados.last()).vr_nrctremp := 75529;
	v_dados(v_dados.last()).vr_vllanmto := 116.94;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14568624;
	v_dados(v_dados.last()).vr_nrctremp := 77093;
	v_dados(v_dados.last()).vr_vllanmto := 40.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14580969;
	v_dados(v_dados.last()).vr_nrctremp := 81253;
	v_dados(v_dados.last()).vr_vllanmto := 61.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14770040;
	v_dados(v_dados.last()).vr_nrctremp := 80843;
	v_dados(v_dados.last()).vr_vllanmto := 61.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 14791943;
	v_dados(v_dados.last()).vr_nrctremp := 81208;
	v_dados(v_dados.last()).vr_vllanmto := 18.22;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15024652;
	v_dados(v_dados.last()).vr_nrctremp := 84100;
	v_dados(v_dados.last()).vr_vllanmto := 86.3;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15131769;
	v_dados(v_dados.last()).vr_nrctremp := 85670;
	v_dados(v_dados.last()).vr_vllanmto := 296.58;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15173828;
	v_dados(v_dados.last()).vr_nrctremp := 86099;
	v_dados(v_dados.last()).vr_vllanmto := 58.92;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15200345;
	v_dados(v_dados.last()).vr_nrctremp := 86276;
	v_dados(v_dados.last()).vr_vllanmto := 17.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15239314;
	v_dados(v_dados.last()).vr_nrctremp := 86949;
	v_dados(v_dados.last()).vr_vllanmto := 50.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15257320;
	v_dados(v_dados.last()).vr_nrctremp := 87202;
	v_dados(v_dados.last()).vr_vllanmto := 25.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15300420;
	v_dados(v_dados.last()).vr_nrctremp := 88058;
	v_dados(v_dados.last()).vr_vllanmto := 33.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15301990;
	v_dados(v_dados.last()).vr_nrctremp := 87717;
	v_dados(v_dados.last()).vr_vllanmto := 52.36;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 7;
	v_dados(v_dados.last()).vr_nrdconta := 15501574;
	v_dados(v_dados.last()).vr_nrctremp := 90272;
	v_dados(v_dados.last()).vr_vllanmto := 16.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;


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
                                           pr_nrparepr => 0,
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
