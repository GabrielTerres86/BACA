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
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 42005;
	v_dados(v_dados.last()).vr_nrctremp := 40111;
	v_dados(v_dados.last()).vr_vllanmto := 215.5;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 49611;
	v_dados(v_dados.last()).vr_nrctremp := 66529;
	v_dados(v_dados.last()).vr_vllanmto := 55.18;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 78522;
	v_dados(v_dados.last()).vr_nrctremp := 42184;
	v_dados(v_dados.last()).vr_vllanmto := 96.78;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 83771;
	v_dados(v_dados.last()).vr_nrctremp := 42933;
	v_dados(v_dados.last()).vr_vllanmto := 91.6;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 103756;
	v_dados(v_dados.last()).vr_nrctremp := 41507;
	v_dados(v_dados.last()).vr_vllanmto := 152.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 151955;
	v_dados(v_dados.last()).vr_nrctremp := 52908;
	v_dados(v_dados.last()).vr_vllanmto := 71.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 159441;
	v_dados(v_dados.last()).vr_nrctremp := 51159;
	v_dados(v_dados.last()).vr_vllanmto := 48.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 159565;
	v_dados(v_dados.last()).vr_nrctremp := 40202;
	v_dados(v_dados.last()).vr_vllanmto := 37.4;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 176940;
	v_dados(v_dados.last()).vr_nrctremp := 75175;
	v_dados(v_dados.last()).vr_vllanmto := 32.02;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 197564;
	v_dados(v_dados.last()).vr_nrctremp := 41524;
	v_dados(v_dados.last()).vr_vllanmto := 50.64;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 202444;
	v_dados(v_dados.last()).vr_nrctremp := 50641;
	v_dados(v_dados.last()).vr_vllanmto := 55.92;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 224723;
	v_dados(v_dados.last()).vr_nrctremp := 35191;
	v_dados(v_dados.last()).vr_vllanmto := 171.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 229059;
	v_dados(v_dados.last()).vr_nrctremp := 35468;
	v_dados(v_dados.last()).vr_vllanmto := 115.54;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 332461;
	v_dados(v_dados.last()).vr_nrctremp := 45846;
	v_dados(v_dados.last()).vr_vllanmto := 462.7;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 332585;
	v_dados(v_dados.last()).vr_nrctremp := 57979;
	v_dados(v_dados.last()).vr_vllanmto := 100.56;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 333425;
	v_dados(v_dados.last()).vr_nrctremp := 51196;
	v_dados(v_dados.last()).vr_vllanmto := 216.34;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 333484;
	v_dados(v_dados.last()).vr_nrctremp := 72966;
	v_dados(v_dados.last()).vr_vllanmto := 50.3;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 338370;
	v_dados(v_dados.last()).vr_nrctremp := 43589;
	v_dados(v_dados.last()).vr_vllanmto := 36.27;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 14;
	v_dados(v_dados.last()).vr_nrdconta := 360929;
	v_dados(v_dados.last()).vr_nrctremp := 62245;
	v_dados(v_dados.last()).vr_vllanmto := 74.62;
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
