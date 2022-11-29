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
    v_dados(v_dados.last()).vr_nrdconta := 8214;
    v_dados(v_dados.last()).vr_nrctremp := 17228;
    v_dados(v_dados.last()).vr_vllanmto := 396.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 21997;
    v_dados(v_dados.last()).vr_nrctremp := 24455;
    v_dados(v_dados.last()).vr_vllanmto := 234.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 36200;
    v_dados(v_dados.last()).vr_nrctremp := 28417;
    v_dados(v_dados.last()).vr_vllanmto := 79.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 278920;
    v_dados(v_dados.last()).vr_nrctremp := 32677;
    v_dados(v_dados.last()).vr_vllanmto := 129.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 278009;
    v_dados(v_dados.last()).vr_nrctremp := 48716;
    v_dados(v_dados.last()).vr_vllanmto := 52.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 271616;
    v_dados(v_dados.last()).vr_nrctremp := 53436;
    v_dados(v_dados.last()).vr_vllanmto := 84.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 200557;
    v_dados(v_dados.last()).vr_nrctremp := 55968;
    v_dados(v_dados.last()).vr_vllanmto := 20.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 133540;
    v_dados(v_dados.last()).vr_nrctremp := 56102;
    v_dados(v_dados.last()).vr_vllanmto := 18.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348260;
    v_dados(v_dados.last()).vr_nrctremp := 59665;
    v_dados(v_dados.last()).vr_vllanmto := 40.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 257427;
    v_dados(v_dados.last()).vr_nrctremp := 59721;
    v_dados(v_dados.last()).vr_vllanmto := 16.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348805;
    v_dados(v_dados.last()).vr_nrctremp := 59754;
    v_dados(v_dados.last()).vr_vllanmto := 33.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348465;
    v_dados(v_dados.last()).vr_nrctremp := 59850;
    v_dados(v_dados.last()).vr_vllanmto := 21.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349402;
    v_dados(v_dados.last()).vr_nrctremp := 59957;
    v_dados(v_dados.last()).vr_vllanmto := 4.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 349682;
    v_dados(v_dados.last()).vr_nrctremp := 60356;
    v_dados(v_dados.last()).vr_vllanmto := 5.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 351830;
    v_dados(v_dados.last()).vr_nrctremp := 61604;
    v_dados(v_dados.last()).vr_vllanmto := 34.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348759;
    v_dados(v_dados.last()).vr_nrctremp := 63209;
    v_dados(v_dados.last()).vr_vllanmto := 17.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 340243;
    v_dados(v_dados.last()).vr_nrctremp := 77563;
    v_dados(v_dados.last()).vr_vllanmto := 17.42;
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
