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
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 134562;
	v_dados(v_dados.last()).vr_nrctremp := 74454;
	v_dados(v_dados.last()).vr_vllanmto := 17.36;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 179310;
	v_dados(v_dados.last()).vr_nrctremp := 70893;
	v_dados(v_dados.last()).vr_vllanmto := 77.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 252590;
	v_dados(v_dados.last()).vr_nrctremp := 72458;
	v_dados(v_dados.last()).vr_vllanmto := 233.76;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 260657;
	v_dados(v_dados.last()).vr_nrctremp := 70818;
	v_dados(v_dados.last()).vr_vllanmto := 99.64;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 276324;
	v_dados(v_dados.last()).vr_nrctremp := 59493;
	v_dados(v_dados.last()).vr_vllanmto := 132.68;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 387606;
	v_dados(v_dados.last()).vr_nrctremp := 73300;
	v_dados(v_dados.last()).vr_vllanmto := 117.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 403903;
	v_dados(v_dados.last()).vr_nrctremp := 55860;
	v_dados(v_dados.last()).vr_vllanmto := 381.32;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 404136;
	v_dados(v_dados.last()).vr_nrctremp := 58419;
	v_dados(v_dados.last()).vr_vllanmto := 329.92;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 423912;
	v_dados(v_dados.last()).vr_nrctremp := 56496;
	v_dados(v_dados.last()).vr_vllanmto := 364.68;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 447722;
	v_dados(v_dados.last()).vr_nrctremp := 69016;
	v_dados(v_dados.last()).vr_vllanmto := 117.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 475785;
	v_dados(v_dados.last()).vr_nrctremp := 66151;
	v_dados(v_dados.last()).vr_vllanmto := 72.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 506087;
	v_dados(v_dados.last()).vr_nrctremp := 21300025;
	v_dados(v_dados.last()).vr_vllanmto := 246.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 506133;
	v_dados(v_dados.last()).vr_nrctremp := 21300033;
	v_dados(v_dados.last()).vr_vllanmto := 15.48;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 516040;
	v_dados(v_dados.last()).vr_nrctremp := 21100121;
	v_dados(v_dados.last()).vr_vllanmto := 67.84;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 518425;
	v_dados(v_dados.last()).vr_nrctremp := 21100046;
	v_dados(v_dados.last()).vr_vllanmto := 126.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 9;
	v_dados(v_dados.last()).vr_nrdconta := 522481;
	v_dados(v_dados.last()).vr_nrctremp := 19100457;
	v_dados(v_dados.last()).vr_vllanmto := 22.52;
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
