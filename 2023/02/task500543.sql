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
	v_dados(v_dados.last()).vr_nrdconta := 604313;
	v_dados(v_dados.last()).vr_nrctremp := 122031;
	v_dados(v_dados.last()).vr_vllanmto := 229.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 487287;
	v_dados(v_dados.last()).vr_nrctremp := 144637;
	v_dados(v_dados.last()).vr_vllanmto := 327.98;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 726028;
	v_dados(v_dados.last()).vr_nrctremp := 158732;
	v_dados(v_dados.last()).vr_vllanmto := 250.8;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 729205;
	v_dados(v_dados.last()).vr_nrctremp := 170533;
	v_dados(v_dados.last()).vr_vllanmto := 90.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 340790;
	v_dados(v_dados.last()).vr_nrctremp := 176369;
	v_dados(v_dados.last()).vr_vllanmto := 157.51;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 5371;
	v_dados(v_dados.last()).vr_nrctremp := 179380;
	v_dados(v_dados.last()).vr_vllanmto := 278.14;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 506370;
	v_dados(v_dados.last()).vr_nrctremp := 179782;
	v_dados(v_dados.last()).vr_vllanmto := 82.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 456551;
	v_dados(v_dados.last()).vr_nrctremp := 180168;
	v_dados(v_dados.last()).vr_vllanmto := 256.64;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 311537;
	v_dados(v_dados.last()).vr_nrctremp := 190709;
	v_dados(v_dados.last()).vr_vllanmto := 138.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 424536;
	v_dados(v_dados.last()).vr_nrctremp := 204085;
	v_dados(v_dados.last()).vr_vllanmto := 231.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 589977;
	v_dados(v_dados.last()).vr_nrctremp := 208448;
	v_dados(v_dados.last()).vr_vllanmto := 267.52;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 823023;
	v_dados(v_dados.last()).vr_nrctremp := 213460;
	v_dados(v_dados.last()).vr_vllanmto := 67.49;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 581216;
	v_dados(v_dados.last()).vr_nrctremp := 214762;
	v_dados(v_dados.last()).vr_vllanmto := 71.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 726028;
	v_dados(v_dados.last()).vr_nrctremp := 224860;
	v_dados(v_dados.last()).vr_vllanmto := 696.84;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 920380;
	v_dados(v_dados.last()).vr_nrctremp := 225064;
	v_dados(v_dados.last()).vr_vllanmto := 41.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 662186;
	v_dados(v_dados.last()).vr_nrctremp := 225275;
	v_dados(v_dados.last()).vr_vllanmto := 177.56;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 729582;
	v_dados(v_dados.last()).vr_nrctremp := 237608;
	v_dados(v_dados.last()).vr_vllanmto := 310.48;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 959367;
	v_dados(v_dados.last()).vr_nrctremp := 249604;
	v_dados(v_dados.last()).vr_vllanmto := 229.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 15015246;
	v_dados(v_dados.last()).vr_nrctremp := 250563;
	v_dados(v_dados.last()).vr_vllanmto := 143.36;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 402176;
	v_dados(v_dados.last()).vr_nrctremp := 254349;
	v_dados(v_dados.last()).vr_vllanmto := 42.62;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 541290;
	v_dados(v_dados.last()).vr_nrctremp := 255205;
	v_dados(v_dados.last()).vr_vllanmto := 15.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 829366;
	v_dados(v_dados.last()).vr_nrctremp := 261350;
	v_dados(v_dados.last()).vr_vllanmto := 59.14;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 14130971;
	v_dados(v_dados.last()).vr_nrctremp := 261505;
	v_dados(v_dados.last()).vr_vllanmto := 36.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 626376;
	v_dados(v_dados.last()).vr_nrctremp := 263358;
	v_dados(v_dados.last()).vr_vllanmto := 20.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 688665;
	v_dados(v_dados.last()).vr_nrctremp := 268198;
	v_dados(v_dados.last()).vr_vllanmto := 15.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 15416313;
	v_dados(v_dados.last()).vr_nrctremp := 269786;
	v_dados(v_dados.last()).vr_vllanmto := 17.46;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 605131;
	v_dados(v_dados.last()).vr_nrctremp := 274079;
	v_dados(v_dados.last()).vr_vllanmto := 578.12;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 934402;
	v_dados(v_dados.last()).vr_nrctremp := 278165;
	v_dados(v_dados.last()).vr_vllanmto := 39.9;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 11;
	v_dados(v_dados.last()).vr_nrdconta := 15335267;
	v_dados(v_dados.last()).vr_nrctremp := 282858;
	v_dados(v_dados.last()).vr_vllanmto := 90.12;
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
