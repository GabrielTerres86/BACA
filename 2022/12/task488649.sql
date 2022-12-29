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
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 8214;
    v_dados(v_dados.last()).vr_nrctremp := 17228;
    v_dados(v_dados.last()).vr_vllanmto := 10.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 34371;
    v_dados(v_dados.last()).vr_nrctremp := 17890;
    v_dados(v_dados.last()).vr_vllanmto := 250.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 3700;
    v_dados(v_dados.last()).vr_nrctremp := 25233;
    v_dados(v_dados.last()).vr_vllanmto := 144.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 41297;
    v_dados(v_dados.last()).vr_nrctremp := 31491;
    v_dados(v_dados.last()).vr_vllanmto := 30.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 276936;
    v_dados(v_dados.last()).vr_nrctremp := 31614;
    v_dados(v_dados.last()).vr_vllanmto := 186.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 293709;
    v_dados(v_dados.last()).vr_nrctremp := 39515;
    v_dados(v_dados.last()).vr_vllanmto := 159.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 111732;
    v_dados(v_dados.last()).vr_nrctremp := 42365;
    v_dados(v_dados.last()).vr_vllanmto := 100.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 231320;
    v_dados(v_dados.last()).vr_nrctremp := 44198;
    v_dados(v_dados.last()).vr_vllanmto := 31.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 281522;
    v_dados(v_dados.last()).vr_nrctremp := 53271;
    v_dados(v_dados.last()).vr_vllanmto := 20.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 271616;
    v_dados(v_dados.last()).vr_nrctremp := 53436;
    v_dados(v_dados.last()).vr_vllanmto := 179.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 303909;
    v_dados(v_dados.last()).vr_nrctremp := 59340;
    v_dados(v_dados.last()).vr_vllanmto := 116.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349682;
    v_dados(v_dados.last()).vr_nrctremp := 60356;
    v_dados(v_dados.last()).vr_vllanmto := 54.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 56170;
    v_dados(v_dados.last()).vr_nrctremp := 61634;
    v_dados(v_dados.last()).vr_vllanmto := 75.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14163829;
    v_dados(v_dados.last()).vr_nrctremp := 62203;
    v_dados(v_dados.last()).vr_vllanmto := 94.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 286575;
    v_dados(v_dados.last()).vr_nrctremp := 63200;
    v_dados(v_dados.last()).vr_vllanmto := 64.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14334712;
    v_dados(v_dados.last()).vr_nrctremp := 64441;
    v_dados(v_dados.last()).vr_vllanmto := 54.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14394545;
    v_dados(v_dados.last()).vr_nrctremp := 65338;
    v_dados(v_dados.last()).vr_vllanmto := 29.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 303089;
    v_dados(v_dados.last()).vr_nrctremp := 68808;
    v_dados(v_dados.last()).vr_vllanmto := 26.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348589;
    v_dados(v_dados.last()).vr_nrctremp := 70045;
    v_dados(v_dados.last()).vr_vllanmto := 67.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14516950;
    v_dados(v_dados.last()).vr_nrctremp := 71862;
    v_dados(v_dados.last()).vr_vllanmto := 19.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 255211;
    v_dados(v_dados.last()).vr_nrctremp := 79618;
    v_dados(v_dados.last()).vr_vllanmto := 271.38;
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
