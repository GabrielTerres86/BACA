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
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 326844;
    v_dados(v_dados.last()).vr_nrctremp := 161226;
    v_dados(v_dados.last()).vr_vllanmto := 81.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 351644;
    v_dados(v_dados.last()).vr_nrctremp := 168423;
    v_dados(v_dados.last()).vr_vllanmto := 97.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 265420;
    v_dados(v_dados.last()).vr_nrctremp := 216943;
    v_dados(v_dados.last()).vr_vllanmto := 130.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 725889;
    v_dados(v_dados.last()).vr_nrctremp := 231820;
    v_dados(v_dados.last()).vr_vllanmto := 46.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 317470;
    v_dados(v_dados.last()).vr_nrctremp := 237871;
    v_dados(v_dados.last()).vr_vllanmto := 71.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 306410;
    v_dados(v_dados.last()).vr_nrctremp := 260595;
    v_dados(v_dados.last()).vr_vllanmto := 97.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 34290;
    v_dados(v_dados.last()).vr_nrctremp := 294652;
    v_dados(v_dados.last()).vr_vllanmto := 137.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 943320;
    v_dados(v_dados.last()).vr_nrctremp := 330956;
    v_dados(v_dados.last()).vr_vllanmto := 73.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 6432123;
    v_dados(v_dados.last()).vr_nrctremp := 339944;
    v_dados(v_dados.last()).vr_vllanmto := 28.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 3144410;
    v_dados(v_dados.last()).vr_nrctremp := 343116;
    v_dados(v_dados.last()).vr_vllanmto := 85.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 51136;
    v_dados(v_dados.last()).vr_nrctremp := 343259;
    v_dados(v_dados.last()).vr_vllanmto := 56.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 245399;
    v_dados(v_dados.last()).vr_nrctremp := 357781;
    v_dados(v_dados.last()).vr_vllanmto := 82.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 369403;
    v_dados(v_dados.last()).vr_nrctremp := 358297;
    v_dados(v_dados.last()).vr_vllanmto := 83.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 977993;
    v_dados(v_dados.last()).vr_nrctremp := 363403;
    v_dados(v_dados.last()).vr_vllanmto := 52.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 255670;
    v_dados(v_dados.last()).vr_nrctremp := 379562;
    v_dados(v_dados.last()).vr_vllanmto := 89.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 3001385;
    v_dados(v_dados.last()).vr_nrctremp := 384400;
    v_dados(v_dados.last()).vr_vllanmto := 30.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1981765;
    v_dados(v_dados.last()).vr_nrctremp := 384467;
    v_dados(v_dados.last()).vr_vllanmto := 154.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1003933;
    v_dados(v_dados.last()).vr_nrctremp := 395877;
    v_dados(v_dados.last()).vr_vllanmto := 64.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1026100;
    v_dados(v_dados.last()).vr_nrctremp := 425701;
    v_dados(v_dados.last()).vr_vllanmto := 53.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 858129;
    v_dados(v_dados.last()).vr_nrctremp := 429569;
    v_dados(v_dados.last()).vr_vllanmto := 34.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 278254;
    v_dados(v_dados.last()).vr_nrctremp := 484987;
    v_dados(v_dados.last()).vr_vllanmto := 35.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 795879;
    v_dados(v_dados.last()).vr_nrctremp := 544463;
    v_dados(v_dados.last()).vr_vllanmto := 82.98;
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
