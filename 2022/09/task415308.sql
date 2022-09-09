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
    v_dados(v_dados.last()).vr_nrdconta := 20800;
    v_dados(v_dados.last()).vr_nrctremp := 52227;
    v_dados(v_dados.last()).vr_vllanmto := 12.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;
	
	v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 26409;
    v_dados(v_dados.last()).vr_nrctremp := 53610;
    v_dados(v_dados.last()).vr_vllanmto := 132.70;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 65234;
    v_dados(v_dados.last()).vr_nrctremp := 64983;
    v_dados(v_dados.last()).vr_vllanmto := 18.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 90115;
    v_dados(v_dados.last()).vr_nrctremp := 76006;
    v_dados(v_dados.last()).vr_vllanmto := 41.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 266981;
    v_dados(v_dados.last()).vr_nrctremp := 61314;
    v_dados(v_dados.last()).vr_vllanmto := 37.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 294284;
    v_dados(v_dados.last()).vr_nrctremp := 60161;
    v_dados(v_dados.last()).vr_vllanmto := 65.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 399027;
    v_dados(v_dados.last()).vr_nrctremp := 57944;
    v_dados(v_dados.last()).vr_vllanmto := 63.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 438936;
    v_dados(v_dados.last()).vr_nrctremp := 75964;
    v_dados(v_dados.last()).vr_vllanmto := 14.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14125463;
    v_dados(v_dados.last()).vr_nrctremp := 71769;
    v_dados(v_dados.last()).vr_vllanmto := 14.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14132834;
    v_dados(v_dados.last()).vr_nrctremp := 71406;
    v_dados(v_dados.last()).vr_vllanmto := 32.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14164116;
    v_dados(v_dados.last()).vr_nrctremp := 72047;
    v_dados(v_dados.last()).vr_vllanmto := 12.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14202778;
    v_dados(v_dados.last()).vr_nrctremp := 73399;
    v_dados(v_dados.last()).vr_vllanmto := 12.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14204118;
    v_dados(v_dados.last()).vr_nrctremp := 72423;
    v_dados(v_dados.last()).vr_vllanmto := 14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14227517;
    v_dados(v_dados.last()).vr_nrctremp := 73422;
    v_dados(v_dados.last()).vr_vllanmto := 176.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14299976;
    v_dados(v_dados.last()).vr_nrctremp := 75318;
    v_dados(v_dados.last()).vr_vllanmto := 68.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14376920;
    v_dados(v_dados.last()).vr_nrctremp := 74431;
    v_dados(v_dados.last()).vr_vllanmto := 10.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14462338;
    v_dados(v_dados.last()).vr_nrctremp := 75529;
    v_dados(v_dados.last()).vr_vllanmto := 13.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14786885;
    v_dados(v_dados.last()).vr_nrctremp := 81413;
    v_dados(v_dados.last()).vr_vllanmto := 33.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14797658;
    v_dados(v_dados.last()).vr_nrctremp := 80671;
    v_dados(v_dados.last()).vr_vllanmto := 18.85;
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
