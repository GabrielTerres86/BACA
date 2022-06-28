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
  v_dados(v_dados.last()).vr_nrdconta := 120219;
  v_dados(v_dados.last()).vr_nrctremp := 137617;
  v_dados(v_dados.last()).vr_vllanmto := 15223.84;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149896;
  v_dados(v_dados.last()).vr_nrctremp := 118072;
  v_dados(v_dados.last()).vr_vllanmto := 11225.29;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 395838;
  v_dados(v_dados.last()).vr_nrctremp := 53229;
  v_dados(v_dados.last()).vr_vllanmto := 10836.77;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 134910;
  v_dados(v_dados.last()).vr_nrctremp := 104926;
  v_dados(v_dados.last()).vr_vllanmto := 10404.83;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 148164;
  v_dados(v_dados.last()).vr_nrctremp := 181745;
  v_dados(v_dados.last()).vr_vllanmto := 9911.72;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 396770;
  v_dados(v_dados.last()).vr_nrctremp := 53402;
  v_dados(v_dados.last()).vr_vllanmto := 6486.16;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 636673;
  v_dados(v_dados.last()).vr_nrctremp := 146471;
  v_dados(v_dados.last()).vr_vllanmto := 484.88;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 252760;
  v_dados(v_dados.last()).vr_nrctremp := 89649;
  v_dados(v_dados.last()).vr_vllanmto := 4672.62;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 263664;
  v_dados(v_dados.last()).vr_nrctremp := 84416;
  v_dados(v_dados.last()).vr_vllanmto := 4431.72;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 41599;
  v_dados(v_dados.last()).vr_nrctremp := 178620;
  v_dados(v_dados.last()).vr_vllanmto := 3177.69;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 246190;
  v_dados(v_dados.last()).vr_nrctremp := 78969;
  v_dados(v_dados.last()).vr_vllanmto := 2392.49;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 246190;
  v_dados(v_dados.last()).vr_nrctremp := 78967;
  v_dados(v_dados.last()).vr_vllanmto := 2059.01;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 93378;
  v_dados(v_dados.last()).vr_nrctremp := 84031;
  v_dados(v_dados.last()).vr_vllanmto := 1927.83;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 678856;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 1734.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 139025;
  v_dados(v_dados.last()).vr_nrctremp := 132009;
  v_dados(v_dados.last()).vr_vllanmto := 1650.01;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 241172;
  v_dados(v_dados.last()).vr_nrctremp := 53833;
  v_dados(v_dados.last()).vr_vllanmto := 1414.88;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289094;
  v_dados(v_dados.last()).vr_nrctremp := 132885;
  v_dados(v_dados.last()).vr_vllanmto := 1323.76;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 215570;
  v_dados(v_dados.last()).vr_nrctremp := 142885;
  v_dados(v_dados.last()).vr_vllanmto := 1307.22;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 35270;
  v_dados(v_dados.last()).vr_nrctremp := 175671;
  v_dados(v_dados.last()).vr_vllanmto := 1173.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 279072;
  v_dados(v_dados.last()).vr_nrctremp := 111148;
  v_dados(v_dados.last()).vr_vllanmto := 1045.29;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 395528;
  v_dados(v_dados.last()).vr_nrctremp := 53113;
  v_dados(v_dados.last()).vr_vllanmto := 928.1;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 70190;
  v_dados(v_dados.last()).vr_vllanmto := 920.3;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 670464;
  v_dados(v_dados.last()).vr_nrctremp := 182028;
  v_dados(v_dados.last()).vr_vllanmto := 644.77;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 284874;
  v_dados(v_dados.last()).vr_nrctremp := 157311;
  v_dados(v_dados.last()).vr_vllanmto := 415.19;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 606243;
  v_dados(v_dados.last()).vr_nrctremp := 176305;
  v_dados(v_dados.last()).vr_vllanmto := 629.05;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146153;
  v_dados(v_dados.last()).vr_nrctremp := 136699;
  v_dados(v_dados.last()).vr_vllanmto := 595.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 598410;
  v_dados(v_dados.last()).vr_nrctremp := 172974;
  v_dados(v_dados.last()).vr_vllanmto := 595.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 246190;
  v_dados(v_dados.last()).vr_nrctremp := 110103;
  v_dados(v_dados.last()).vr_vllanmto := 576.21;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150967;
  v_dados(v_dados.last()).vr_nrctremp := 175748;
  v_dados(v_dados.last()).vr_vllanmto := 565.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146218;
  v_dados(v_dados.last()).vr_nrctremp := 70375;
  v_dados(v_dados.last()).vr_vllanmto := 524.89;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149896;
  v_dados(v_dados.last()).vr_nrctremp := 118073;
  v_dados(v_dados.last()).vr_vllanmto := 521.87;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 167924;
  v_dados(v_dados.last()).vr_nrctremp := 175206;
  v_dados(v_dados.last()).vr_vllanmto := 536.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160644;
  v_dados(v_dados.last()).vr_nrctremp := 65833;
  v_dados(v_dados.last()).vr_vllanmto := 529.39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143480;
  v_dados(v_dados.last()).vr_nrctremp := 161123;
  v_dados(v_dados.last()).vr_vllanmto := 513.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 541036;
  v_dados(v_dados.last()).vr_nrctremp := 103157;
  v_dados(v_dados.last()).vr_vllanmto := 456.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 701564;
  v_dados(v_dados.last()).vr_nrctremp := 159245;
  v_dados(v_dados.last()).vr_vllanmto := 406.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 96389;
  v_dados(v_dados.last()).vr_vllanmto := 405.77;
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
