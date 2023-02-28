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
	v_dados(v_dados.last()).vr_nrdconta := 131318;
	v_dados(v_dados.last()).vr_nrctremp := 85648;
	v_dados(v_dados.last()).vr_vllanmto := 29.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 293709;
	v_dados(v_dados.last()).vr_nrctremp := 39515;
	v_dados(v_dados.last()).vr_vllanmto := 316.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 36200;
	v_dados(v_dados.last()).vr_nrctremp := 28417;
	v_dados(v_dados.last()).vr_vllanmto := 211.62;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 349682;
	v_dados(v_dados.last()).vr_nrctremp := 60356;
	v_dados(v_dados.last()).vr_vllanmto := 101.74;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 14430177;
	v_dados(v_dados.last()).vr_nrctremp := 65975;
	v_dados(v_dados.last()).vr_vllanmto := 52.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 340170;
	v_dados(v_dados.last()).vr_nrctremp := 77673;
	v_dados(v_dados.last()).vr_vllanmto := 28.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 303089;
	v_dados(v_dados.last()).vr_nrctremp := 68808;
	v_dados(v_dados.last()).vr_vllanmto := 52.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 257427;
	v_dados(v_dados.last()).vr_nrctremp := 59721;
	v_dados(v_dados.last()).vr_vllanmto := 153.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 190349;
	v_dados(v_dados.last()).vr_nrctremp := 80775;
	v_dados(v_dados.last()).vr_vllanmto := 78.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 21997;
	v_dados(v_dados.last()).vr_nrctremp := 24455;
	v_dados(v_dados.last()).vr_vllanmto := 528.52;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 39039;
	v_dados(v_dados.last()).vr_nrctremp := 76410;
	v_dados(v_dados.last()).vr_vllanmto := 81.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 271616;
	v_dados(v_dados.last()).vr_nrctremp := 53436;
	v_dados(v_dados.last()).vr_vllanmto := 429.28;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 348759;
	v_dados(v_dados.last()).vr_nrctremp := 63209;
	v_dados(v_dados.last()).vr_vllanmto := 58.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 281522;
	v_dados(v_dados.last()).vr_nrctremp := 53271;
	v_dados(v_dados.last()).vr_vllanmto := 40.04;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 303909;
	v_dados(v_dados.last()).vr_nrctremp := 59340;
	v_dados(v_dados.last()).vr_vllanmto := 31.06;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 276936;
	v_dados(v_dados.last()).vr_nrctremp := 31614;
	v_dados(v_dados.last()).vr_vllanmto := 376.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 5;
	v_dados(v_dados.last()).vr_nrdconta := 351830;
	v_dados(v_dados.last()).vr_nrctremp := 61604;
	v_dados(v_dados.last()).vr_vllanmto := 249.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

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
