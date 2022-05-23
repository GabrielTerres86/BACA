declare
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE,
      vr_cdhistor cecred.craplem.cdhistor%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados        t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
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
    v_dados(v_dados.last()).vr_vllanmto := 29.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 371157;
    v_dados(v_dados.last()).vr_nrctremp := 108485;
    v_dados(v_dados.last()).vr_vllanmto := 58.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 729582;
    v_dados(v_dados.last()).vr_nrctremp := 120631;
    v_dados(v_dados.last()).vr_vllanmto := 2.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 729582;
    v_dados(v_dados.last()).vr_nrctremp := 120631;
    v_dados(v_dados.last()).vr_vllanmto := 107.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 454788;
    v_dados(v_dados.last()).vr_nrctremp := 129483;
    v_dados(v_dados.last()).vr_vllanmto := 73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 11550;
    v_dados(v_dados.last()).vr_nrctremp := 132265;
    v_dados(v_dados.last()).vr_vllanmto := 139.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 533530;
    v_dados(v_dados.last()).vr_nrctremp := 146931;
    v_dados(v_dados.last()).vr_vllanmto := 127.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 686530;
    v_dados(v_dados.last()).vr_nrctremp := 157030;
    v_dados(v_dados.last()).vr_vllanmto := 21.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 610720;
    v_dados(v_dados.last()).vr_nrctremp := 162126;
    v_dados(v_dados.last()).vr_vllanmto := 1296.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 747092;
    v_dados(v_dados.last()).vr_nrctremp := 165757;
    v_dados(v_dados.last()).vr_vllanmto := 170.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 747092;
    v_dados(v_dados.last()).vr_nrctremp := 165757;
    v_dados(v_dados.last()).vr_vllanmto := 163.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 701793;
    v_dados(v_dados.last()).vr_nrctremp := 167131;
    v_dados(v_dados.last()).vr_vllanmto := 35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 608394;
    v_dados(v_dados.last()).vr_nrctremp := 167331;
    v_dados(v_dados.last()).vr_vllanmto := 4.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 617458;
    v_dados(v_dados.last()).vr_nrctremp := 169526;
    v_dados(v_dados.last()).vr_vllanmto := 514.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 730610;
    v_dados(v_dados.last()).vr_nrctremp := 174655;
    v_dados(v_dados.last()).vr_vllanmto := 114.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 340790;
    v_dados(v_dados.last()).vr_nrctremp := 176369;
    v_dados(v_dados.last()).vr_vllanmto := 504.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 874892;
    v_dados(v_dados.last()).vr_nrctremp := 182061;
    v_dados(v_dados.last()).vr_vllanmto := 823.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 313270;
    v_dados(v_dados.last()).vr_nrctremp := 190811;
    v_dados(v_dados.last()).vr_vllanmto := 145.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 133264;
    v_dados(v_dados.last()).vr_nrctremp := 197299;
    v_dados(v_dados.last()).vr_vllanmto := 392.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14103176;
    v_dados(v_dados.last()).vr_nrctremp := 197303;
    v_dados(v_dados.last()).vr_vllanmto := 501.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14090880;
    v_dados(v_dados.last()).vr_nrctremp := 199550;
    v_dados(v_dados.last()).vr_vllanmto := 768.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 4227;
    v_dados(v_dados.last()).vr_nrctremp := 201567;
    v_dados(v_dados.last()).vr_vllanmto := 126.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 832170;
    v_dados(v_dados.last()).vr_nrctremp := 202073;
    v_dados(v_dados.last()).vr_vllanmto := 723.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 685801;
    v_dados(v_dados.last()).vr_nrctremp := 210213;
    v_dados(v_dados.last()).vr_vllanmto := 976.78;
    v_dados(v_dados.last()).vr_cdhistor := 3917;



  
  FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      OPEN btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
  
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => v_dados(x).vr_cdcooper,
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
