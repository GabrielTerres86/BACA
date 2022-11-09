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
    v_dados(v_dados.last()).vr_vllanmto := 117.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 4138;
    v_dados(v_dados.last()).vr_nrctremp := 48281;
    v_dados(v_dados.last()).vr_vllanmto := 148.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 31038;
    v_dados(v_dados.last()).vr_nrctremp := 49365;
    v_dados(v_dados.last()).vr_vllanmto := 178.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 26409;
    v_dados(v_dados.last()).vr_nrctremp := 53610;
    v_dados(v_dados.last()).vr_vllanmto := 242.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 21393;
    v_dados(v_dados.last()).vr_nrctremp := 54463;
    v_dados(v_dados.last()).vr_vllanmto := 582.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 399027;
    v_dados(v_dados.last()).vr_nrctremp := 57944;
    v_dados(v_dados.last()).vr_vllanmto := 104.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 294284;
    v_dados(v_dados.last()).vr_nrctremp := 60161;
    v_dados(v_dados.last()).vr_vllanmto := 3113.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 157783;
    v_dados(v_dados.last()).vr_nrctremp := 60831;
    v_dados(v_dados.last()).vr_vllanmto := 43.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 266981;
    v_dados(v_dados.last()).vr_nrctremp := 61314;
    v_dados(v_dados.last()).vr_vllanmto := 404;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 302791;
    v_dados(v_dados.last()).vr_nrctremp := 63319;
    v_dados(v_dados.last()).vr_vllanmto := 30.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 132195;
    v_dados(v_dados.last()).vr_nrctremp := 63733;
    v_dados(v_dados.last()).vr_vllanmto := 41.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 63983;
    v_dados(v_dados.last()).vr_nrctremp := 64151;
    v_dados(v_dados.last()).vr_vllanmto := 5766.76;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 265918;
    v_dados(v_dados.last()).vr_nrctremp := 64501;
    v_dados(v_dados.last()).vr_vllanmto := 33.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 65234;
    v_dados(v_dados.last()).vr_nrctremp := 64983;
    v_dados(v_dados.last()).vr_vllanmto := 57.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 292109;
    v_dados(v_dados.last()).vr_nrctremp := 66672;
    v_dados(v_dados.last()).vr_vllanmto := 16.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 427497;
    v_dados(v_dados.last()).vr_nrctremp := 68493;
    v_dados(v_dados.last()).vr_vllanmto := 26.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 29513;
    v_dados(v_dados.last()).vr_nrctremp := 71135;
    v_dados(v_dados.last()).vr_vllanmto := 288.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14132834;
    v_dados(v_dados.last()).vr_nrctremp := 71406;
    v_dados(v_dados.last()).vr_vllanmto := 32.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14136651;
    v_dados(v_dados.last()).vr_nrctremp := 71457;
    v_dados(v_dados.last()).vr_vllanmto := 157.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14166313;
    v_dados(v_dados.last()).vr_nrctremp := 71878;
    v_dados(v_dados.last()).vr_vllanmto := 188.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14173905;
    v_dados(v_dados.last()).vr_nrctremp := 71978;
    v_dados(v_dados.last()).vr_vllanmto := 257.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14173905;
    v_dados(v_dados.last()).vr_nrctremp := 71979;
    v_dados(v_dados.last()).vr_vllanmto := 47.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14164116;
    v_dados(v_dados.last()).vr_nrctremp := 72047;
    v_dados(v_dados.last()).vr_vllanmto := 169.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14186047;
    v_dados(v_dados.last()).vr_nrctremp := 72163;
    v_dados(v_dados.last()).vr_vllanmto := 81.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14187370;
    v_dados(v_dados.last()).vr_nrctremp := 72166;
    v_dados(v_dados.last()).vr_vllanmto := 420.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 72380;
    v_dados(v_dados.last()).vr_vllanmto := 67.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14204118;
    v_dados(v_dados.last()).vr_nrctremp := 72423;
    v_dados(v_dados.last()).vr_vllanmto := 50.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14227789;
    v_dados(v_dados.last()).vr_nrctremp := 72609;
    v_dados(v_dados.last()).vr_vllanmto := 160.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14166313;
    v_dados(v_dados.last()).vr_nrctremp := 73261;
    v_dados(v_dados.last()).vr_vllanmto := 2145.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14227517;
    v_dados(v_dados.last()).vr_nrctremp := 73422;
    v_dados(v_dados.last()).vr_vllanmto := 176.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14301067;
    v_dados(v_dados.last()).vr_nrctremp := 73482;
    v_dados(v_dados.last()).vr_vllanmto := 48.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14283581;
    v_dados(v_dados.last()).vr_nrctremp := 73679;
    v_dados(v_dados.last()).vr_vllanmto := 25.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14346109;
    v_dados(v_dados.last()).vr_nrctremp := 73941;
    v_dados(v_dados.last()).vr_vllanmto := 34.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14348390;
    v_dados(v_dados.last()).vr_nrctremp := 74050;
    v_dados(v_dados.last()).vr_vllanmto := 34.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14299976;
    v_dados(v_dados.last()).vr_nrctremp := 75318;
    v_dados(v_dados.last()).vr_vllanmto := 68.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 26760;
    v_dados(v_dados.last()).vr_nrctremp := 75347;
    v_dados(v_dados.last()).vr_vllanmto := 16.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 90115;
    v_dados(v_dados.last()).vr_nrctremp := 76006;
    v_dados(v_dados.last()).vr_vllanmto := 41.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14510448;
    v_dados(v_dados.last()).vr_nrctremp := 76355;
    v_dados(v_dados.last()).vr_vllanmto := 20.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14285886;
    v_dados(v_dados.last()).vr_nrctremp := 77187;
    v_dados(v_dados.last()).vr_vllanmto := 15.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14797658;
    v_dados(v_dados.last()).vr_nrctremp := 80671;
    v_dados(v_dados.last()).vr_vllanmto := 19.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14786885;
    v_dados(v_dados.last()).vr_nrctremp := 81413;
    v_dados(v_dados.last()).vr_vllanmto := 52.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 15035816;
    v_dados(v_dados.last()).vr_nrctremp := 84268;
    v_dados(v_dados.last()).vr_vllanmto := 2416.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 15132170;
    v_dados(v_dados.last()).vr_nrctremp := 85404;
    v_dados(v_dados.last()).vr_vllanmto := 21.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;


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
