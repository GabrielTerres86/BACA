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
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 41874;
    v_dados(v_dados.last()).vr_nrctremp := 9016;
    v_dados(v_dados.last()).vr_vllanmto := 141.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 18074;
    v_dados(v_dados.last()).vr_nrctremp := 9153;
    v_dados(v_dados.last()).vr_vllanmto := 19.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 49271;
    v_dados(v_dados.last()).vr_nrctremp := 9375;
    v_dados(v_dados.last()).vr_vllanmto := 121.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 38970;
    v_dados(v_dados.last()).vr_nrctremp := 9548;
    v_dados(v_dados.last()).vr_vllanmto := 59.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 41319;
    v_dados(v_dados.last()).vr_nrctremp := 9656;
    v_dados(v_dados.last()).vr_vllanmto := 210.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 43680;
    v_dados(v_dados.last()).vr_nrctremp := 9739;
    v_dados(v_dados.last()).vr_vllanmto := 33.72;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 29297;
    v_dados(v_dados.last()).vr_nrctremp := 9905;
    v_dados(v_dados.last()).vr_vllanmto := 110.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 29327;
    v_dados(v_dados.last()).vr_nrctremp := 10358;
    v_dados(v_dados.last()).vr_vllanmto := 142.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 25364;
    v_dados(v_dados.last()).vr_nrctremp := 10711;
    v_dados(v_dados.last()).vr_vllanmto := 131.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 8680;
    v_dados(v_dados.last()).vr_nrctremp := 11015;
    v_dados(v_dados.last()).vr_vllanmto := 277.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;


  
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
