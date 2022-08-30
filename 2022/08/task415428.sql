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
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20290;
    v_dados(v_dados.last()).vr_nrctremp := 11604;
    v_dados(v_dados.last()).vr_vllanmto := 215.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 142.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145890;
    v_dados(v_dados.last()).vr_nrctremp := 12747;
    v_dados(v_dados.last()).vr_vllanmto := 56.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 109207;
    v_dados(v_dados.last()).vr_nrctremp := 12749;
    v_dados(v_dados.last()).vr_vllanmto := 48.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142328;
    v_dados(v_dados.last()).vr_nrctremp := 13396;
    v_dados(v_dados.last()).vr_vllanmto := 40.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 182.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 106739;
    v_dados(v_dados.last()).vr_nrctremp := 16580;
    v_dados(v_dados.last()).vr_vllanmto := 879.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 17006;
    v_dados(v_dados.last()).vr_vllanmto := 4.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152749;
    v_dados(v_dados.last()).vr_nrctremp := 17436;
    v_dados(v_dados.last()).vr_vllanmto := 118.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 105090;
    v_dados(v_dados.last()).vr_nrctremp := 17740;
    v_dados(v_dados.last()).vr_vllanmto := 1519.38;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110833;
    v_dados(v_dados.last()).vr_nrctremp := 19761;
    v_dados(v_dados.last()).vr_vllanmto := 225.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 169854;
    v_dados(v_dados.last()).vr_nrctremp := 20352;
    v_dados(v_dados.last()).vr_vllanmto := 45.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164291;
    v_dados(v_dados.last()).vr_nrctremp := 20796;
    v_dados(v_dados.last()).vr_vllanmto := 63.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 59.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86177;
    v_dados(v_dados.last()).vr_nrctremp := 20920;
    v_dados(v_dados.last()).vr_vllanmto := 61.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 83.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 177075;
    v_dados(v_dados.last()).vr_nrctremp := 21289;
    v_dados(v_dados.last()).vr_vllanmto := 296.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154890;
    v_dados(v_dados.last()).vr_nrctremp := 21489;
    v_dados(v_dados.last()).vr_vllanmto := 63.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142867;
    v_dados(v_dados.last()).vr_nrctremp := 21554;
    v_dados(v_dados.last()).vr_vllanmto := 34.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94943;
    v_dados(v_dados.last()).vr_nrctremp := 24595;
    v_dados(v_dados.last()).vr_vllanmto := 170.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 25048;
    v_dados(v_dados.last()).vr_vllanmto := 69.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103845;
    v_dados(v_dados.last()).vr_nrctremp := 25269;
    v_dados(v_dados.last()).vr_vllanmto := 186.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48410;
    v_dados(v_dados.last()).vr_nrctremp := 26327;
    v_dados(v_dados.last()).vr_vllanmto := .26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73164;
    v_dados(v_dados.last()).vr_nrctremp := 26413;
    v_dados(v_dados.last()).vr_vllanmto := 70.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 126322;
    v_dados(v_dados.last()).vr_nrctremp := 27516;
    v_dados(v_dados.last()).vr_vllanmto := 38.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165867;
    v_dados(v_dados.last()).vr_nrctremp := 27952;
    v_dados(v_dados.last()).vr_vllanmto := 16.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133418;
    v_dados(v_dados.last()).vr_nrctremp := 28512;
    v_dados(v_dados.last()).vr_vllanmto := .01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184063;
    v_dados(v_dados.last()).vr_nrctremp := 28875;
    v_dados(v_dados.last()).vr_vllanmto := 62.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166570;
    v_dados(v_dados.last()).vr_nrctremp := 29031;
    v_dados(v_dados.last()).vr_vllanmto := 114.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 5797;
    v_dados(v_dados.last()).vr_nrctremp := 29441;
    v_dados(v_dados.last()).vr_vllanmto := 79.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 72966;
    v_dados(v_dados.last()).vr_nrctremp := 29759;
    v_dados(v_dados.last()).vr_vllanmto := 178.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94706;
    v_dados(v_dados.last()).vr_nrctremp := 29860;
    v_dados(v_dados.last()).vr_vllanmto := 18.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84840;
    v_dados(v_dados.last()).vr_nrctremp := 30015;
    v_dados(v_dados.last()).vr_vllanmto := 30.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 155314;
    v_dados(v_dados.last()).vr_nrctremp := 30952;
    v_dados(v_dados.last()).vr_vllanmto := 16.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77038;
    v_dados(v_dados.last()).vr_nrctremp := 32862;
    v_dados(v_dados.last()).vr_vllanmto := 47.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184039;
    v_dados(v_dados.last()).vr_nrctremp := 32925;
    v_dados(v_dados.last()).vr_vllanmto := 78.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186449;
    v_dados(v_dados.last()).vr_nrctremp := 33515;
    v_dados(v_dados.last()).vr_vllanmto := 16.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 16.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194719;
    v_dados(v_dados.last()).vr_nrctremp := 33742;
    v_dados(v_dados.last()).vr_vllanmto := 72.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133078;
    v_dados(v_dados.last()).vr_nrctremp := 33797;
    v_dados(v_dados.last()).vr_vllanmto := 250.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 14974;
    v_dados(v_dados.last()).vr_nrctremp := 34026;
    v_dados(v_dados.last()).vr_vllanmto := 25.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200255;
    v_dados(v_dados.last()).vr_nrctremp := 34029;
    v_dados(v_dados.last()).vr_vllanmto := 22.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 104.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172545;
    v_dados(v_dados.last()).vr_nrctremp := 34826;
    v_dados(v_dados.last()).vr_vllanmto := 39.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152978;
    v_dados(v_dados.last()).vr_nrctremp := 34887;
    v_dados(v_dados.last()).vr_vllanmto := 87.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194743;
    v_dados(v_dados.last()).vr_nrctremp := 37044;
    v_dados(v_dados.last()).vr_vllanmto := 39.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141631;
    v_dados(v_dados.last()).vr_nrctremp := 37342;
    v_dados(v_dados.last()).vr_vllanmto := 689.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 212636;
    v_dados(v_dados.last()).vr_nrctremp := 38270;
    v_dados(v_dados.last()).vr_vllanmto := .44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49719;
    v_dados(v_dados.last()).vr_nrctremp := 38508;
    v_dados(v_dados.last()).vr_vllanmto := 21.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 131601;
    v_dados(v_dados.last()).vr_nrctremp := 39667;
    v_dados(v_dados.last()).vr_vllanmto := 33.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 106739;
    v_dados(v_dados.last()).vr_nrctremp := 40157;
    v_dados(v_dados.last()).vr_vllanmto := 15.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117463;
    v_dados(v_dados.last()).vr_nrctremp := 40166;
    v_dados(v_dados.last()).vr_vllanmto := 24.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

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
