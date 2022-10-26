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
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 371157;
    v_dados(v_dados.last()).vr_nrctremp := 108485;
    v_dados(v_dados.last()).vr_vllanmto := 128.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 541290;
    v_dados(v_dados.last()).vr_nrctremp := 120522;
    v_dados(v_dados.last()).vr_vllanmto := 146.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 604313;
    v_dados(v_dados.last()).vr_nrctremp := 122031;
    v_dados(v_dados.last()).vr_vllanmto := 94.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 11550;
    v_dados(v_dados.last()).vr_nrctremp := 132265;
    v_dados(v_dados.last()).vr_vllanmto := 355.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 149220;
    v_dados(v_dados.last()).vr_vllanmto := 90.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 258334;
    v_dados(v_dados.last()).vr_nrctremp := 160195;
    v_dados(v_dados.last()).vr_vllanmto := 228.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 275913;
    v_dados(v_dados.last()).vr_nrctremp := 162805;
    v_dados(v_dados.last()).vr_vllanmto := 62.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 340790;
    v_dados(v_dados.last()).vr_nrctremp := 176369;
    v_dados(v_dados.last()).vr_vllanmto := 81.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 456551;
    v_dados(v_dados.last()).vr_nrctremp := 180168;
    v_dados(v_dados.last()).vr_vllanmto := 81.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 691240;
    v_dados(v_dados.last()).vr_nrctremp := 189595;
    v_dados(v_dados.last()).vr_vllanmto := 40.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 311537;
    v_dados(v_dados.last()).vr_nrctremp := 190709;
    v_dados(v_dados.last()).vr_vllanmto := 27.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14103176;
    v_dados(v_dados.last()).vr_nrctremp := 197303;
    v_dados(v_dados.last()).vr_vllanmto := 63.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 832170;
    v_dados(v_dados.last()).vr_nrctremp := 202073;
    v_dados(v_dados.last()).vr_vllanmto := 18.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 424536;
    v_dados(v_dados.last()).vr_nrctremp := 204085;
    v_dados(v_dados.last()).vr_vllanmto := 57.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 589977;
    v_dados(v_dados.last()).vr_nrctremp := 208448;
    v_dados(v_dados.last()).vr_vllanmto := 70.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 656470;
    v_dados(v_dados.last()).vr_nrctremp := 213344;
    v_dados(v_dados.last()).vr_vllanmto := 261.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 823023;
    v_dados(v_dados.last()).vr_nrctremp := 213460;
    v_dados(v_dados.last()).vr_vllanmto := 22.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 701793;
    v_dados(v_dados.last()).vr_nrctremp := 224854;
    v_dados(v_dados.last()).vr_vllanmto := 17.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 662186;
    v_dados(v_dados.last()).vr_nrctremp := 225275;
    v_dados(v_dados.last()).vr_vllanmto := 17.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 729582;
    v_dados(v_dados.last()).vr_nrctremp := 237608;
    v_dados(v_dados.last()).vr_vllanmto := 565.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 921980;
    v_dados(v_dados.last()).vr_nrctremp := 243042;
    v_dados(v_dados.last()).vr_vllanmto := 2953.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 15351165;
    v_dados(v_dados.last()).vr_nrctremp := 270989;
    v_dados(v_dados.last()).vr_vllanmto := 614.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14968185;
    v_dados(v_dados.last()).vr_nrctremp := 272632;
    v_dados(v_dados.last()).vr_vllanmto := 863.7;
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
