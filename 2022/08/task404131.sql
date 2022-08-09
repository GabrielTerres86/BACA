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
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 20923;
    v_dados(v_dados.last()).vr_nrctremp := 82841;
    v_dados(v_dados.last()).vr_vllanmto := 1123.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 59512;
    v_dados(v_dados.last()).vr_vllanmto := 12195.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 88711;
    v_dados(v_dados.last()).vr_vllanmto := 20616.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96245;
    v_dados(v_dados.last()).vr_nrctremp := 102741;
    v_dados(v_dados.last()).vr_vllanmto := 3.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142670;
    v_dados(v_dados.last()).vr_nrctremp := 103431;
    v_dados(v_dados.last()).vr_vllanmto := 1.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143790;
    v_dados(v_dados.last()).vr_nrctremp := 56730;
    v_dados(v_dados.last()).vr_vllanmto := .34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143790;
    v_dados(v_dados.last()).vr_nrctremp := 56730;
    v_dados(v_dados.last()).vr_vllanmto := .07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151181;
    v_dados(v_dados.last()).vr_nrctremp := 104054;
    v_dados(v_dados.last()).vr_vllanmto := .17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152455;
    v_dados(v_dados.last()).vr_nrctremp := 120690;
    v_dados(v_dados.last()).vr_vllanmto := 7.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152455;
    v_dados(v_dados.last()).vr_nrctremp := 120690;
    v_dados(v_dados.last()).vr_vllanmto := 756.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155934;
    v_dados(v_dados.last()).vr_nrctremp := 66219;
    v_dados(v_dados.last()).vr_vllanmto := 34379.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 61665;
    v_dados(v_dados.last()).vr_vllanmto := .36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 61665;
    v_dados(v_dados.last()).vr_vllanmto := .66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161110;
    v_dados(v_dados.last()).vr_nrctremp := 103295;
    v_dados(v_dados.last()).vr_vllanmto := 18806.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161110;
    v_dados(v_dados.last()).vr_nrctremp := 103296;
    v_dados(v_dados.last()).vr_vllanmto := 1501.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161349;
    v_dados(v_dados.last()).vr_nrctremp := 59104;
    v_dados(v_dados.last()).vr_vllanmto := 10085.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := .52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := 595.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163716;
    v_dados(v_dados.last()).vr_nrctremp := 81143;
    v_dados(v_dados.last()).vr_vllanmto := .41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167924;
    v_dados(v_dados.last()).vr_nrctremp := 94867;
    v_dados(v_dados.last()).vr_vllanmto := 4.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187747;
    v_dados(v_dados.last()).vr_nrctremp := 101671;
    v_dados(v_dados.last()).vr_vllanmto := .4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 91363;
    v_dados(v_dados.last()).vr_vllanmto := .46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 91363;
    v_dados(v_dados.last()).vr_vllanmto := 408.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 211036;
    v_dados(v_dados.last()).vr_nrctremp := 95812;
    v_dados(v_dados.last()).vr_vllanmto := 6.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214710;
    v_dados(v_dados.last()).vr_nrctremp := 53208;
    v_dados(v_dados.last()).vr_vllanmto := 28.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 226327;
    v_dados(v_dados.last()).vr_nrctremp := 70203;
    v_dados(v_dados.last()).vr_vllanmto := .17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237108;
    v_dados(v_dados.last()).vr_nrctremp := 86776;
    v_dados(v_dados.last()).vr_vllanmto := 1875.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275050;
    v_dados(v_dados.last()).vr_nrctremp := 75298;
    v_dados(v_dados.last()).vr_vllanmto := 6123.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 320935;
    v_dados(v_dados.last()).vr_nrctremp := 114943;
    v_dados(v_dados.last()).vr_vllanmto := .51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325520;
    v_dados(v_dados.last()).vr_nrctremp := 56731;
    v_dados(v_dados.last()).vr_vllanmto := 2485.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 330248;
    v_dados(v_dados.last()).vr_nrctremp := 100747;
    v_dados(v_dados.last()).vr_vllanmto := .23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355607;
    v_dados(v_dados.last()).vr_nrctremp := 65807;
    v_dados(v_dados.last()).vr_vllanmto := 64107.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361372;
    v_dados(v_dados.last()).vr_nrctremp := 84317;
    v_dados(v_dados.last()).vr_vllanmto := 876.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394033;
    v_dados(v_dados.last()).vr_nrctremp := 90907;
    v_dados(v_dados.last()).vr_vllanmto := 1106.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394734;
    v_dados(v_dados.last()).vr_nrctremp := 72344;
    v_dados(v_dados.last()).vr_vllanmto := 6892.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396990;
    v_dados(v_dados.last()).vr_nrctremp := 80320;
    v_dados(v_dados.last()).vr_vllanmto := 1856.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 61407;
    v_dados(v_dados.last()).vr_vllanmto := .54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 81229;
    v_dados(v_dados.last()).vr_vllanmto := 4.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 100924;
    v_dados(v_dados.last()).vr_vllanmto := 1.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 139833;
    v_dados(v_dados.last()).vr_vllanmto := 1.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 139833;
    v_dados(v_dados.last()).vr_vllanmto := 3.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 515566;
    v_dados(v_dados.last()).vr_nrctremp := 131305;
    v_dados(v_dados.last()).vr_vllanmto := 2.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524808;
    v_dados(v_dados.last()).vr_nrctremp := 98536;
    v_dados(v_dados.last()).vr_vllanmto := .05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 248.24;
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
