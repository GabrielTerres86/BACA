declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  
  TYPE dados_typ IS RECORD(
      vr_cdcooper crapcop.cdcooper%TYPE,
      vr_nrdconta crapass.nrdconta%TYPE,
      vr_nrctremp craplem.nrctremp%TYPE,
      vr_vllanmto craplem.vllanmto%TYPE,
      vr_cdhistor craplem.cdhistor%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados        t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
BEGIN
  
  
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 2259;
  v_dados(v_dados.last()).vr_nrctremp := 15256;
  v_dados(v_dados.last()).vr_vllanmto := 364.13;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 6750;
  v_dados(v_dados.last()).vr_nrctremp := 15266;
  v_dados(v_dados.last()).vr_vllanmto := 178.38;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 41432;
  v_dados(v_dados.last()).vr_nrctremp := 15601;
  v_dados(v_dados.last()).vr_vllanmto := 210.69;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 8214;
  v_dados(v_dados.last()).vr_nrctremp := 17228;
  v_dados(v_dados.last()).vr_vllanmto := 506.52;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 34371;
  v_dados(v_dados.last()).vr_nrctremp := 17890;
  v_dados(v_dados.last()).vr_vllanmto := 301.91;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 238953;
  v_dados(v_dados.last()).vr_nrctremp := 18275;
  v_dados(v_dados.last()).vr_vllanmto := 450.1;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 57908;
  v_dados(v_dados.last()).vr_nrctremp := 21011;
  v_dados(v_dados.last()).vr_vllanmto := 183.45;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 62782;
  v_dados(v_dados.last()).vr_nrctremp := 21358;
  v_dados(v_dados.last()).vr_vllanmto := 332.99;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 87521;
  v_dados(v_dados.last()).vr_nrctremp := 21945;
  v_dados(v_dados.last()).vr_vllanmto := 36.28;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 49662;
  v_dados(v_dados.last()).vr_nrctremp := 21947;
  v_dados(v_dados.last()).vr_vllanmto := 399.79;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 154164;
  v_dados(v_dados.last()).vr_nrctremp := 23600;
  v_dados(v_dados.last()).vr_vllanmto := 16.66;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 21997;
  v_dados(v_dados.last()).vr_nrctremp := 24455;
  v_dados(v_dados.last()).vr_vllanmto := 264.96;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 34738;
  v_dados(v_dados.last()).vr_nrctremp := 24502;
  v_dados(v_dados.last()).vr_vllanmto := 23011.32;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 884;
  v_dados(v_dados.last()).vr_nrctremp := 24536;
  v_dados(v_dados.last()).vr_vllanmto := 1471.41;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 3700;
  v_dados(v_dados.last()).vr_nrctremp := 25233;
  v_dados(v_dados.last()).vr_vllanmto := 340.24;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 27243;
  v_dados(v_dados.last()).vr_nrctremp := 25283;
  v_dados(v_dados.last()).vr_vllanmto := 303.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 6742;
  v_dados(v_dados.last()).vr_nrctremp := 26288;
  v_dados(v_dados.last()).vr_vllanmto := 352.42;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 31070;
  v_dados(v_dados.last()).vr_nrctremp := 27398;
  v_dados(v_dados.last()).vr_vllanmto := 186.33;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 141372;
  v_dados(v_dados.last()).vr_nrctremp := 27934;
  v_dados(v_dados.last()).vr_vllanmto := 339.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 9636;
  v_dados(v_dados.last()).vr_nrctremp := 28411;
  v_dados(v_dados.last()).vr_vllanmto := 125.92;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 36200;
  v_dados(v_dados.last()).vr_nrctremp := 28417;
  v_dados(v_dados.last()).vr_vllanmto := 250.83;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 270113;
  v_dados(v_dados.last()).vr_nrctremp := 29401;
  v_dados(v_dados.last()).vr_vllanmto := 151.43;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 73717;
  v_dados(v_dados.last()).vr_nrctremp := 30177;
  v_dados(v_dados.last()).vr_vllanmto := 186.2;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 41297;
  v_dados(v_dados.last()).vr_nrctremp := 31491;
  v_dados(v_dados.last()).vr_vllanmto := 190.33;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 276936;
  v_dados(v_dados.last()).vr_nrctremp := 31614;
  v_dados(v_dados.last()).vr_vllanmto := 246.63;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 231320;
  v_dados(v_dados.last()).vr_nrctremp := 44198;
  v_dados(v_dados.last()).vr_vllanmto := 23.47;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 278009;
  v_dados(v_dados.last()).vr_nrctremp := 48716;
  v_dados(v_dados.last()).vr_vllanmto := 49.96;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 269026;
  v_dados(v_dados.last()).vr_nrctremp := 50698;
  v_dados(v_dados.last()).vr_vllanmto := 139.07;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 196312;
  v_dados(v_dados.last()).vr_nrctremp := 52265;
  v_dados(v_dados.last()).vr_vllanmto := 140.23;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 199036;
  v_dados(v_dados.last()).vr_nrctremp := 55710;
  v_dados(v_dados.last()).vr_vllanmto := 177.8;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 351830;
  v_dados(v_dados.last()).vr_nrctremp := 61604;
  v_dados(v_dados.last()).vr_vllanmto := 474.74;
  v_dados(v_dados.last()).vr_cdhistor := 3917;
  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 5;
  v_dados(v_dados.last()).vr_nrdconta := 14163829;
  v_dados(v_dados.last()).vr_nrctremp := 62203;
  v_dados(v_dados.last()).vr_vllanmto := 322.31;
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
