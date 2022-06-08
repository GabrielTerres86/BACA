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
  v_dados(v_dados.last()).vr_nrdconta := 4138;
  v_dados(v_dados.last()).vr_nrctremp := 48281;
  v_dados(v_dados.last()).vr_vllanmto := 27.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 4138;
  v_dados(v_dados.last()).vr_nrctremp := 48281;
  v_dados(v_dados.last()).vr_vllanmto := 120.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 3980;
  v_dados(v_dados.last()).vr_nrctremp := 48808;
  v_dados(v_dados.last()).vr_vllanmto := 39.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 3980;
  v_dados(v_dados.last()).vr_nrctremp := 48808;
  v_dados(v_dados.last()).vr_vllanmto := 142.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 294284;
  v_dados(v_dados.last()).vr_nrctremp := 60161;
  v_dados(v_dados.last()).vr_vllanmto := 277.19;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 294284;
  v_dados(v_dados.last()).vr_nrctremp := 60161;
  v_dados(v_dados.last()).vr_vllanmto := 1099.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 13883054;
  v_dados(v_dados.last()).vr_nrctremp := 67899;
  v_dados(v_dados.last()).vr_vllanmto := 43.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 29513;
  v_dados(v_dados.last()).vr_nrctremp := 71135;
  v_dados(v_dados.last()).vr_vllanmto := 288.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 401099;
  v_dados(v_dados.last()).vr_nrctremp := 71273;
  v_dados(v_dados.last()).vr_vllanmto := 32.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14096960;
  v_dados(v_dados.last()).vr_nrctremp := 71325;
  v_dados(v_dados.last()).vr_vllanmto := 5.18;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14136651;
  v_dados(v_dados.last()).vr_nrctremp := 71457;
  v_dados(v_dados.last()).vr_vllanmto := 193.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14132842;
  v_dados(v_dados.last()).vr_nrctremp := 71479;
  v_dados(v_dados.last()).vr_vllanmto := 6.29;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14166313;
  v_dados(v_dados.last()).vr_nrctremp := 71878;
  v_dados(v_dados.last()).vr_vllanmto := 188.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14120186;
  v_dados(v_dados.last()).vr_nrctremp := 71940;
  v_dados(v_dados.last()).vr_vllanmto := 129.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14173905;
  v_dados(v_dados.last()).vr_nrctremp := 71978;
  v_dados(v_dados.last()).vr_vllanmto := 126.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14173905;
  v_dados(v_dados.last()).vr_nrctremp := 71979;
  v_dados(v_dados.last()).vr_vllanmto := 23.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14164116;
  v_dados(v_dados.last()).vr_nrctremp := 72047;
  v_dados(v_dados.last()).vr_vllanmto := 179.69;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14186047;
  v_dados(v_dados.last()).vr_nrctremp := 72163;
  v_dados(v_dados.last()).vr_vllanmto := 81.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14187370;
  v_dados(v_dados.last()).vr_nrctremp := 72166;
  v_dados(v_dados.last()).vr_vllanmto := 362.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 428540;
  v_dados(v_dados.last()).vr_nrctremp := 72177;
  v_dados(v_dados.last()).vr_vllanmto := 253.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14162342;
  v_dados(v_dados.last()).vr_nrctremp := 72250;
  v_dados(v_dados.last()).vr_vllanmto := 58.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 392740;
  v_dados(v_dados.last()).vr_nrctremp := 72380;
  v_dados(v_dados.last()).vr_vllanmto := 761;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14204118;
  v_dados(v_dados.last()).vr_nrctremp := 72423;
  v_dados(v_dados.last()).vr_vllanmto := 44.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14226367;
  v_dados(v_dados.last()).vr_nrctremp := 72504;
  v_dados(v_dados.last()).vr_vllanmto := 129.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227789;
  v_dados(v_dados.last()).vr_nrctremp := 72609;
  v_dados(v_dados.last()).vr_vllanmto := 136.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14166313;
  v_dados(v_dados.last()).vr_nrctremp := 73261;
  v_dados(v_dados.last()).vr_vllanmto := 1051.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14221110;
  v_dados(v_dados.last()).vr_nrctremp := 73386;
  v_dados(v_dados.last()).vr_vllanmto := 2.63;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14299739;
  v_dados(v_dados.last()).vr_nrctremp := 73390;
  v_dados(v_dados.last()).vr_vllanmto := 5.33;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73417;
  v_dados(v_dados.last()).vr_vllanmto := 7.67;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73418;
  v_dados(v_dados.last()).vr_vllanmto := 7.35;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73423;
  v_dados(v_dados.last()).vr_vllanmto := 3.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14165783;
  v_dados(v_dados.last()).vr_nrctremp := 73491;
  v_dados(v_dados.last()).vr_vllanmto := 5.06;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14316650;
  v_dados(v_dados.last()).vr_nrctremp := 73594;
  v_dados(v_dados.last()).vr_vllanmto := 10.19;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14143836;
  v_dados(v_dados.last()).vr_nrctremp := 73693;
  v_dados(v_dados.last()).vr_vllanmto := 763.62;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14116235;
  v_dados(v_dados.last()).vr_nrctremp := 73832;
  v_dados(v_dados.last()).vr_vllanmto := 5.21;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73967;
  v_dados(v_dados.last()).vr_vllanmto := 6.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14227517;
  v_dados(v_dados.last()).vr_nrctremp := 73968;
  v_dados(v_dados.last()).vr_vllanmto := 4.28;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14363097;
  v_dados(v_dados.last()).vr_nrctremp := 74228;
  v_dados(v_dados.last()).vr_vllanmto := 3.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14333651;
  v_dados(v_dados.last()).vr_nrctremp := 74286;
  v_dados(v_dados.last()).vr_vllanmto := 11.76;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14376776;
  v_dados(v_dados.last()).vr_nrctremp := 74391;
  v_dados(v_dados.last()).vr_vllanmto := 4.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14377055;
  v_dados(v_dados.last()).vr_nrctremp := 74414;
  v_dados(v_dados.last()).vr_vllanmto := 3.01;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 26760;
  v_dados(v_dados.last()).vr_nrctremp := 75347;
  v_dados(v_dados.last()).vr_vllanmto := 16.27;
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
