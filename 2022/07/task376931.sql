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
  v_dados(v_dados.last()).vr_vllanmto := 62.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 541290;
  v_dados(v_dados.last()).vr_nrctremp := 120522;
  v_dados(v_dados.last()).vr_vllanmto := 66.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 604313;
  v_dados(v_dados.last()).vr_nrctremp := 122031;
  v_dados(v_dados.last()).vr_vllanmto := 72.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 454788;
  v_dados(v_dados.last()).vr_nrctremp := 129483;
  v_dados(v_dados.last()).vr_vllanmto := 54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 11550;
  v_dados(v_dados.last()).vr_nrctremp := 132265;
  v_dados(v_dados.last()).vr_vllanmto := 122.77;
  v_dados(v_dados.last()).vr_cdhistor := 3919;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 487287;
  v_dados(v_dados.last()).vr_nrctremp := 144637;
  v_dados(v_dados.last()).vr_vllanmto := 32.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 497509;
  v_dados(v_dados.last()).vr_nrctremp := 152048;
  v_dados(v_dados.last()).vr_vllanmto := 48.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 730610;
  v_dados(v_dados.last()).vr_nrctremp := 174655;
  v_dados(v_dados.last()).vr_vllanmto := 117.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 115207;
  v_dados(v_dados.last()).vr_nrctremp := 178532;
  v_dados(v_dados.last()).vr_vllanmto := 60.22;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 456551;
  v_dados(v_dados.last()).vr_nrctremp := 180168;
  v_dados(v_dados.last()).vr_vllanmto := 25.76;
  v_dados(v_dados.last()).vr_cdhistor := 1037;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 708496;
  v_dados(v_dados.last()).vr_nrctremp := 206254;
  v_dados(v_dados.last()).vr_vllanmto := 19.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 11;
  v_dados(v_dados.last()).vr_nrdconta := 610720;
  v_dados(v_dados.last()).vr_nrctremp := 210535;
  v_dados(v_dados.last()).vr_vllanmto := 170.42;
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
