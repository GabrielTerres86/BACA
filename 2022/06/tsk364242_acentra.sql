declare
  vr_cdcritic  cecred.crapcri.cdcritic%TYPE;
  vr_dscritic  VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto  varchar(3);
  vr_tab_erro  cecred.GENE0001.typ_tab_erro;
  
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE,
      vr_cdhistor cecred.craplem.cdhistor%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
BEGIN
  

    
    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 6750;
    v_dados(v_dados.last()).vr_nrctremp := 15266;
    v_dados(v_dados.last()).vr_vllanmto := 103.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 8214;
    v_dados(v_dados.last()).vr_nrctremp := 17228;
    v_dados(v_dados.last()).vr_vllanmto := 348.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 87521;
    v_dados(v_dados.last()).vr_nrctremp := 21945;
    v_dados(v_dados.last()).vr_vllanmto := 52.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 154164;
    v_dados(v_dados.last()).vr_nrctremp := 23600;
    v_dados(v_dados.last()).vr_vllanmto := 69.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 34738;
    v_dados(v_dados.last()).vr_nrctremp := 24502;
    v_dados(v_dados.last()).vr_vllanmto := 534.69;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 153826;
    v_dados(v_dados.last()).vr_nrctremp := 25877;
    v_dados(v_dados.last()).vr_vllanmto := 129.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 73717;
    v_dados(v_dados.last()).vr_nrctremp := 30177;
    v_dados(v_dados.last()).vr_vllanmto := 128.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 41297;
    v_dados(v_dados.last()).vr_nrctremp := 31491;
    v_dados(v_dados.last()).vr_vllanmto := 157.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 276936;
    v_dados(v_dados.last()).vr_nrctremp := 31614;
    v_dados(v_dados.last()).vr_vllanmto := 94.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 281522;
    v_dados(v_dados.last()).vr_nrctremp := 33910;
    v_dados(v_dados.last()).vr_vllanmto := 71.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 284530;
    v_dados(v_dados.last()).vr_nrctremp := 35258;
    v_dados(v_dados.last()).vr_vllanmto := 36.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 278327;
    v_dados(v_dados.last()).vr_nrctremp := 37906;
    v_dados(v_dados.last()).vr_vllanmto := 38.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 293709;
    v_dados(v_dados.last()).vr_nrctremp := 39515;
    v_dados(v_dados.last()).vr_vllanmto := 79.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 271616;
    v_dados(v_dados.last()).vr_nrctremp := 53436;
    v_dados(v_dados.last()).vr_vllanmto := 66.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 286575;
    v_dados(v_dados.last()).vr_nrctremp := 55893;
    v_dados(v_dados.last()).vr_vllanmto := 24.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348589;
    v_dados(v_dados.last()).vr_nrctremp := 59671;
    v_dados(v_dados.last()).vr_vllanmto := 126.59;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 348465;
    v_dados(v_dados.last()).vr_nrctremp := 59850;
    v_dados(v_dados.last()).vr_vllanmto := 17.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 306118;
    v_dados(v_dados.last()).vr_nrctremp := 60779;
    v_dados(v_dados.last()).vr_vllanmto := 18.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 56170;
    v_dados(v_dados.last()).vr_nrctremp := 61634;
    v_dados(v_dados.last()).vr_vllanmto := 11.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 14163829;
    v_dados(v_dados.last()).vr_nrctremp := 62203;
    v_dados(v_dados.last()).vr_vllanmto := 32.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;


  
  FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
      FETCH cecred.btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE cecred.btch0001.cr_crapdat;
      OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
  
      cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => v_dados(x).vr_cdcooper,
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
end;
