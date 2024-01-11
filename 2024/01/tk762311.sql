DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto  varchar(3);
  vr_tab_erro  cecred.GENE0001.typ_tab_erro;
  vr_conta_dev cecred.crapepr.nrdconta%TYPE;

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE,
    vr_nrparepr cecred.craplem.nrparepr%TYPE);

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
  v_dados(v_dados.last()).vr_nrdconta := 8837813;
  v_dados(v_dados.last()).vr_nrctremp := 2955566;
  v_dados(v_dados.last()).vr_vllanmto := 596.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11251891;
  v_dados(v_dados.last()).vr_nrctremp := 3919578;
  v_dados(v_dados.last()).vr_vllanmto := 13558.09;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10400354;
  v_dados(v_dados.last()).vr_nrctremp := 5541382;
  v_dados(v_dados.last()).vr_vllanmto := 167.82;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13979655;
  v_dados(v_dados.last()).vr_nrctremp := 5682898;
  v_dados(v_dados.last()).vr_vllanmto := 96.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1101897;
  v_dados(v_dados.last()).vr_nrctremp := 344567;
  v_dados(v_dados.last()).vr_vllanmto := 11.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14173905;
  v_dados(v_dados.last()).vr_nrctremp := 71977;
  v_dados(v_dados.last()).vr_vllanmto := 21.7;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14192020;
  v_dados(v_dados.last()).vr_nrctremp := 80677;
  v_dados(v_dados.last()).vr_vllanmto := 116.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 252590;
  v_dados(v_dados.last()).vr_nrctremp := 72458;
  v_dados(v_dados.last()).vr_vllanmto := 233.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501743;
  v_dados(v_dados.last()).vr_nrctremp := 20100309;
  v_dados(v_dados.last()).vr_vllanmto := 92.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 530689;
  v_dados(v_dados.last()).vr_nrctremp := 21100201;
  v_dados(v_dados.last()).vr_vllanmto := 786.28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503185;
  v_dados(v_dados.last()).vr_nrctremp := 21100212;
  v_dados(v_dados.last()).vr_vllanmto := 270.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505757;
  v_dados(v_dados.last()).vr_nrctremp := 21100228;
  v_dados(v_dados.last()).vr_vllanmto := 905.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506087;
  v_dados(v_dados.last()).vr_nrctremp := 21300025;
  v_dados(v_dados.last()).vr_vllanmto := 950.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 155098;
  v_dados(v_dados.last()).vr_nrctremp := 14109;
  v_dados(v_dados.last()).vr_vllanmto := 1004.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 729205;
  v_dados(v_dados.last()).vr_nrctremp := 170533;
  v_dados(v_dados.last()).vr_vllanmto := 1.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 670324;
  v_dados(v_dados.last()).vr_nrctremp := 167935;
  v_dados(v_dados.last()).vr_vllanmto := 58.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277541;
  v_dados(v_dados.last()).vr_nrctremp := 203879;
  v_dados(v_dados.last()).vr_vllanmto := 61.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 294691;
  v_dados(v_dados.last()).vr_nrctremp := 213808;
  v_dados(v_dados.last()).vr_vllanmto := 52.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316792;
  v_dados(v_dados.last()).vr_nrctremp := 217300;
  v_dados(v_dados.last()).vr_vllanmto := 285.63;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663980;
  v_dados(v_dados.last()).vr_nrctremp := 245306;
  v_dados(v_dados.last()).vr_vllanmto := 15045.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663980;
  v_dados(v_dados.last()).vr_nrctremp := 305326;
  v_dados(v_dados.last()).vr_vllanmto := 2924.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 83771;
  v_dados(v_dados.last()).vr_nrctremp := 42933;
  v_dados(v_dados.last()).vr_vllanmto := 91.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  v_dados(v_dados.last()).vr_nrparepr := 0;

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
                                           pr_nrparepr => v_dados(x).vr_nrparepr,
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
