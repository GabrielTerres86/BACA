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
    v_dados(v_dados.last()).vr_nrdconta := 87521;
    v_dados(v_dados.last()).vr_nrctremp := 21945;
    v_dados(v_dados.last()).vr_vllanmto := 60.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 27243;
    v_dados(v_dados.last()).vr_nrctremp := 25283;
    v_dados(v_dados.last()).vr_vllanmto := 153.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 6742;
    v_dados(v_dados.last()).vr_nrctremp := 26288;
    v_dados(v_dados.last()).vr_vllanmto := 184.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 36200;
    v_dados(v_dados.last()).vr_nrctremp := 28417;
    v_dados(v_dados.last()).vr_vllanmto := 172.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 278920;
    v_dados(v_dados.last()).vr_nrctremp := 32677;
    v_dados(v_dados.last()).vr_vllanmto := 5.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 281522;
    v_dados(v_dados.last()).vr_nrctremp := 33910;
    v_dados(v_dados.last()).vr_vllanmto := 129.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 231320;
    v_dados(v_dados.last()).vr_nrctremp := 44198;
    v_dados(v_dados.last()).vr_vllanmto := 23.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 278009;
    v_dados(v_dados.last()).vr_nrctremp := 48716;
    v_dados(v_dados.last()).vr_vllanmto := 52.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 274860;
    v_dados(v_dados.last()).vr_nrctremp := 50147;
    v_dados(v_dados.last()).vr_vllanmto := 784.96;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 281522;
    v_dados(v_dados.last()).vr_nrctremp := 53271;
    v_dados(v_dados.last()).vr_vllanmto := 14.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 143448;
    v_dados(v_dados.last()).vr_nrctremp := 53905;
    v_dados(v_dados.last()).vr_vllanmto := 124.39;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 200557;
    v_dados(v_dados.last()).vr_nrctremp := 55968;
    v_dados(v_dados.last()).vr_vllanmto := 3.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 274860;
    v_dados(v_dados.last()).vr_nrctremp := 56139;
    v_dados(v_dados.last()).vr_vllanmto := 2024.16;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348732;
    v_dados(v_dados.last()).vr_nrctremp := 59739;
    v_dados(v_dados.last()).vr_vllanmto := 38.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348465;
    v_dados(v_dados.last()).vr_nrctremp := 59850;
    v_dados(v_dados.last()).vr_vllanmto := 34.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349194;
    v_dados(v_dados.last()).vr_nrctremp := 59874;
    v_dados(v_dados.last()).vr_vllanmto := 18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349402;
    v_dados(v_dados.last()).vr_nrctremp := 59957;
    v_dados(v_dados.last()).vr_vllanmto := 32.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349682;
    v_dados(v_dados.last()).vr_nrctremp := 60356;
    v_dados(v_dados.last()).vr_vllanmto := 33.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 56170;
    v_dados(v_dados.last()).vr_nrctremp := 61634;
    v_dados(v_dados.last()).vr_vllanmto := 49.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14163829;
    v_dados(v_dados.last()).vr_nrctremp := 62203;
    v_dados(v_dados.last()).vr_vllanmto := 57.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 286575;
    v_dados(v_dados.last()).vr_nrctremp := 63200;
    v_dados(v_dados.last()).vr_vllanmto := 19.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14394545;
    v_dados(v_dados.last()).vr_nrctremp := 65338;
    v_dados(v_dados.last()).vr_vllanmto := 16.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14541840;
    v_dados(v_dados.last()).vr_nrctremp := 67648;
    v_dados(v_dados.last()).vr_vllanmto := 5878.16;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14629895;
    v_dados(v_dados.last()).vr_nrctremp := 69129;
    v_dados(v_dados.last()).vr_vllanmto := 12.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348589;
    v_dados(v_dados.last()).vr_nrctremp := 70045;
    v_dados(v_dados.last()).vr_vllanmto := 8.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 269026;
    v_dados(v_dados.last()).vr_nrctremp := 72607;
    v_dados(v_dados.last()).vr_vllanmto := 26.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 147753;
    v_dados(v_dados.last()).vr_nrctremp := 79615;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 190349;
    v_dados(v_dados.last()).vr_nrctremp := 80775;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;


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
