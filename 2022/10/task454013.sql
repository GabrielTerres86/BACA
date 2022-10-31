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
    v_dados(v_dados.last()).vr_vllanmto := 229.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 155.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 13581;
    v_dados(v_dados.last()).vr_vllanmto := 5799.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127582;
    v_dados(v_dados.last()).vr_nrctremp := 13745;
    v_dados(v_dados.last()).vr_vllanmto := 63.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 203.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141941;
    v_dados(v_dados.last()).vr_nrctremp := 20085;
    v_dados(v_dados.last()).vr_vllanmto := 126.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166898;
    v_dados(v_dados.last()).vr_nrctremp := 20193;
    v_dados(v_dados.last()).vr_vllanmto := 39.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 68.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 99.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 177075;
    v_dados(v_dados.last()).vr_nrctremp := 21289;
    v_dados(v_dados.last()).vr_vllanmto := 353.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142867;
    v_dados(v_dados.last()).vr_nrctremp := 21554;
    v_dados(v_dados.last()).vr_vllanmto := 39.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152080;
    v_dados(v_dados.last()).vr_nrctremp := 21626;
    v_dados(v_dados.last()).vr_vllanmto := 134.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85065;
    v_dados(v_dados.last()).vr_nrctremp := 22767;
    v_dados(v_dados.last()).vr_vllanmto := 205.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103845;
    v_dados(v_dados.last()).vr_nrctremp := 25269;
    v_dados(v_dados.last()).vr_vllanmto := 226.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 151017;
    v_dados(v_dados.last()).vr_nrctremp := 25746;
    v_dados(v_dados.last()).vr_vllanmto := 45.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48410;
    v_dados(v_dados.last()).vr_nrctremp := 26327;
    v_dados(v_dados.last()).vr_vllanmto := 88.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 29025;
    v_dados(v_dados.last()).vr_nrctremp := 26466;
    v_dados(v_dados.last()).vr_vllanmto := 105.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49484;
    v_dados(v_dados.last()).vr_nrctremp := 27912;
    v_dados(v_dados.last()).vr_vllanmto := 43.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77542;
    v_dados(v_dados.last()).vr_nrctremp := 29750;
    v_dados(v_dados.last()).vr_vllanmto := 62.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 68543;
    v_dados(v_dados.last()).vr_nrctremp := 29888;
    v_dados(v_dados.last()).vr_vllanmto := 27.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 100.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187810;
    v_dados(v_dados.last()).vr_nrctremp := 33278;
    v_dados(v_dados.last()).vr_vllanmto := 77.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186449;
    v_dados(v_dados.last()).vr_nrctremp := 33515;
    v_dados(v_dados.last()).vr_vllanmto := 27.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 23.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121100;
    v_dados(v_dados.last()).vr_nrctremp := 33812;
    v_dados(v_dados.last()).vr_vllanmto := 20.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200255;
    v_dados(v_dados.last()).vr_nrctremp := 34029;
    v_dados(v_dados.last()).vr_vllanmto := 31.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 93734;
    v_dados(v_dados.last()).vr_nrctremp := 34131;
    v_dados(v_dados.last()).vr_vllanmto := 73.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 47.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 92.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166561;
    v_dados(v_dados.last()).vr_nrctremp := 36045;
    v_dados(v_dados.last()).vr_vllanmto := 32.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166693;
    v_dados(v_dados.last()).vr_nrctremp := 36303;
    v_dados(v_dados.last()).vr_vllanmto := 45.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 216410;
    v_dados(v_dados.last()).vr_nrctremp := 36991;
    v_dados(v_dados.last()).vr_vllanmto := 17.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 198960;
    v_dados(v_dados.last()).vr_nrctremp := 38243;
    v_dados(v_dados.last()).vr_vllanmto := 25.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138193;
    v_dados(v_dados.last()).vr_nrctremp := 38343;
    v_dados(v_dados.last()).vr_vllanmto := 34.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 38465;
    v_dados(v_dados.last()).vr_vllanmto := 30.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 27634;
    v_dados(v_dados.last()).vr_nrctremp := 38561;
    v_dados(v_dados.last()).vr_vllanmto := 17.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67415;
    v_dados(v_dados.last()).vr_nrctremp := 38778;
    v_dados(v_dados.last()).vr_vllanmto := 22.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125008;
    v_dados(v_dados.last()).vr_nrctremp := 38850;
    v_dados(v_dados.last()).vr_vllanmto := 18.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 211630;
    v_dados(v_dados.last()).vr_nrctremp := 39120;
    v_dados(v_dados.last()).vr_vllanmto := 16.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 179566;
    v_dados(v_dados.last()).vr_nrctremp := 39528;
    v_dados(v_dados.last()).vr_vllanmto := 31.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117463;
    v_dados(v_dados.last()).vr_nrctremp := 40166;
    v_dados(v_dados.last()).vr_vllanmto := 32.14;
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
