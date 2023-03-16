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
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13068512;
  v_dados(v_dados.last()).vr_nrctremp := 4428289;
  v_dados(v_dados.last()).vr_vllanmto := 2795.79;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80147194;
  v_dados(v_dados.last()).vr_nrctremp := 2040841;
  v_dados(v_dados.last()).vr_vllanmto := 2012.94;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80012248;
  v_dados(v_dados.last()).vr_nrctremp := 2491868;
  v_dados(v_dados.last()).vr_vllanmto := 1989.67;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9082530;
  v_dados(v_dados.last()).vr_nrctremp := 2955578;
  v_dados(v_dados.last()).vr_vllanmto := 1410.07;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12710091;
  v_dados(v_dados.last()).vr_nrctremp := 3935842;
  v_dados(v_dados.last()).vr_vllanmto := 594.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13006703;
  v_dados(v_dados.last()).vr_nrctremp := 4696585;
  v_dados(v_dados.last()).vr_vllanmto := 590.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8652007;
  v_dados(v_dados.last()).vr_nrctremp := 2507442;
  v_dados(v_dados.last()).vr_vllanmto := 447.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11850108;
  v_dados(v_dados.last()).vr_nrctremp := 4127932;
  v_dados(v_dados.last()).vr_vllanmto := 356.7;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389404;
  v_dados(v_dados.last()).vr_nrctremp := 4250955;
  v_dados(v_dados.last()).vr_vllanmto := 325.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8624780;
  v_dados(v_dados.last()).vr_nrctremp := 5555185;
  v_dados(v_dados.last()).vr_vllanmto := 274.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10230602;
  v_dados(v_dados.last()).vr_nrctremp := 4472925;
  v_dados(v_dados.last()).vr_vllanmto := 266.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13155997;
  v_dados(v_dados.last()).vr_nrctremp := 4701450;
  v_dados(v_dados.last()).vr_vllanmto := 264.34;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12891185;
  v_dados(v_dados.last()).vr_nrctremp := 4090475;
  v_dados(v_dados.last()).vr_vllanmto := 211.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14526077;
  v_dados(v_dados.last()).vr_nrctremp := 5895954;
  v_dados(v_dados.last()).vr_vllanmto := 210.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10325727;
  v_dados(v_dados.last()).vr_nrctremp := 4829682;
  v_dados(v_dados.last()).vr_vllanmto := 174.26;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10325727;
  v_dados(v_dados.last()).vr_nrctremp := 5821028;
  v_dados(v_dados.last()).vr_vllanmto := 139.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8684413;
  v_dados(v_dados.last()).vr_nrctremp := 5323281;
  v_dados(v_dados.last()).vr_vllanmto := 125.45;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7669437;
  v_dados(v_dados.last()).vr_nrctremp := 2507640;
  v_dados(v_dados.last()).vr_vllanmto := 95.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10845933;
  v_dados(v_dados.last()).vr_nrctremp := 5501714;
  v_dados(v_dados.last()).vr_vllanmto := 95.02;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11629410;
  v_dados(v_dados.last()).vr_nrctremp := 4924495;
  v_dados(v_dados.last()).vr_vllanmto := 34.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9958070;
  v_dados(v_dados.last()).vr_nrctremp := 5848326;
  v_dados(v_dados.last()).vr_vllanmto := 31.29;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11286024;
  v_dados(v_dados.last()).vr_nrctremp := 5397806;
  v_dados(v_dados.last()).vr_vllanmto := .88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11453680;
  v_dados(v_dados.last()).vr_nrctremp := 4189966;
  v_dados(v_dados.last()).vr_vllanmto := 15.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9868925;
  v_dados(v_dados.last()).vr_nrctremp := 3230862;
  v_dados(v_dados.last()).vr_vllanmto := 15.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12501514;
  v_dados(v_dados.last()).vr_nrctremp := 5189367;
  v_dados(v_dados.last()).vr_vllanmto := 22.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6334423;
  v_dados(v_dados.last()).vr_nrctremp := 2955764;
  v_dados(v_dados.last()).vr_vllanmto := 24.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12699195;
  v_dados(v_dados.last()).vr_nrctremp := 5916746;
  v_dados(v_dados.last()).vr_vllanmto := 32.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11675837;
  v_dados(v_dados.last()).vr_nrctremp := 4866685;
  v_dados(v_dados.last()).vr_vllanmto := 48.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3961630;
  v_dados(v_dados.last()).vr_nrctremp := 4984115;
  v_dados(v_dados.last()).vr_vllanmto := 54.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80346871;
  v_dados(v_dados.last()).vr_nrctremp := 2024567;
  v_dados(v_dados.last()).vr_vllanmto := 67.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9193081;
  v_dados(v_dados.last()).vr_nrctremp := 2102720;
  v_dados(v_dados.last()).vr_vllanmto := 78.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10515844;
  v_dados(v_dados.last()).vr_nrctremp := 5378422;
  v_dados(v_dados.last()).vr_vllanmto := 138.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12898651;
  v_dados(v_dados.last()).vr_nrctremp := 4188743;
  v_dados(v_dados.last()).vr_vllanmto := 169.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12019178;
  v_dados(v_dados.last()).vr_nrctremp := 3430704;
  v_dados(v_dados.last()).vr_vllanmto := 195.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8177589;
  v_dados(v_dados.last()).vr_nrctremp := 3837514;
  v_dados(v_dados.last()).vr_vllanmto := 336.68;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80170781;
  v_dados(v_dados.last()).vr_nrctremp := 3472408;
  v_dados(v_dados.last()).vr_vllanmto := 389.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9381910;
  v_dados(v_dados.last()).vr_nrctremp := 5690508;
  v_dados(v_dados.last()).vr_vllanmto := 399.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 431.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80337074;
  v_dados(v_dados.last()).vr_nrctremp := 2955519;
  v_dados(v_dados.last()).vr_vllanmto := 467.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80012248;
  v_dados(v_dados.last()).vr_nrctremp := 4068844;
  v_dados(v_dados.last()).vr_vllanmto := 474.12;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12084824;
  v_dados(v_dados.last()).vr_nrctremp := 5872763;
  v_dados(v_dados.last()).vr_vllanmto := 4251.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13011600;
  v_dados(v_dados.last()).vr_nrctremp := 5349520;
  v_dados(v_dados.last()).vr_vllanmto := 4927.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11806222;
  v_dados(v_dados.last()).vr_nrctremp := 4245131;
  v_dados(v_dados.last()).vr_vllanmto := 10188.6;
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
