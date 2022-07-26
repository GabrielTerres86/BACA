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
  v_dados(v_dados.last()).vr_nrdconta := 635316;
  v_dados(v_dados.last()).vr_nrctremp := 134348;
  v_dados(v_dados.last()).vr_vllanmto := 108.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 635359;
  v_dados(v_dados.last()).vr_nrctremp := 134355;
  v_dados(v_dados.last()).vr_vllanmto := 108.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551031;
  v_dados(v_dados.last()).vr_nrctremp := 159572;
  v_dados(v_dados.last()).vr_vllanmto := 148.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241318;
  v_dados(v_dados.last()).vr_nrctremp := 159666;
  v_dados(v_dados.last()).vr_vllanmto := 194.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 161226;
  v_dados(v_dados.last()).vr_vllanmto := 58.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 741019;
  v_dados(v_dados.last()).vr_nrctremp := 199372;
  v_dados(v_dados.last()).vr_vllanmto := 59.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 265420;
  v_dados(v_dados.last()).vr_nrctremp := 216943;
  v_dados(v_dados.last()).vr_vllanmto := 75.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 244242;
  v_dados(v_dados.last()).vr_vllanmto := .32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 590894;
  v_dados(v_dados.last()).vr_nrctremp := 276937;
  v_dados(v_dados.last()).vr_vllanmto := 26.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241199;
  v_dados(v_dados.last()).vr_nrctremp := 296059;
  v_dados(v_dados.last()).vr_vllanmto := 10.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 753793;
  v_dados(v_dados.last()).vr_nrctremp := 323121;
  v_dados(v_dados.last()).vr_vllanmto := 133.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 888206;
  v_dados(v_dados.last()).vr_nrctremp := 324337;
  v_dados(v_dados.last()).vr_vllanmto := 187.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 12.49;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1003933;
  v_dados(v_dados.last()).vr_nrctremp := 395877;
  v_dados(v_dados.last()).vr_vllanmto := 20.69;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382361;
  v_dados(v_dados.last()).vr_nrctremp := 422610;
  v_dados(v_dados.last()).vr_vllanmto := 24.6;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 166782;
  v_dados(v_dados.last()).vr_nrctremp := 444577;
  v_dados(v_dados.last()).vr_vllanmto := 11.12;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 34290;
  v_dados(v_dados.last()).vr_nrctremp := 294652;
  v_dados(v_dados.last()).vr_vllanmto := 84.39;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 245399;
  v_dados(v_dados.last()).vr_nrctremp := 357781;
  v_dados(v_dados.last()).vr_vllanmto := 39.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 704520;
  v_dados(v_dados.last()).vr_nrctremp := 338005;
  v_dados(v_dados.last()).vr_vllanmto := 52.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1003933;
  v_dados(v_dados.last()).vr_nrctremp := 395877;
  v_dados(v_dados.last()).vr_vllanmto := 19.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 369403;
  v_dados(v_dados.last()).vr_nrctremp := 358297;
  v_dados(v_dados.last()).vr_vllanmto := 26.84;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977993;
  v_dados(v_dados.last()).vr_nrctremp := 363403;
  v_dados(v_dados.last()).vr_vllanmto := 30.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 665479;
  v_dados(v_dados.last()).vr_nrctremp := 141277;
  v_dados(v_dados.last()).vr_vllanmto := 33.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 246743;
  v_dados(v_dados.last()).vr_nrctremp := 273301;
  v_dados(v_dados.last()).vr_vllanmto := 318.68;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 943320;
  v_dados(v_dados.last()).vr_nrctremp := 330956;
  v_dados(v_dados.last()).vr_vllanmto := 38.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 161226;
  v_dados(v_dados.last()).vr_vllanmto := 67;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 590894;
  v_dados(v_dados.last()).vr_nrctremp := 276937;
  v_dados(v_dados.last()).vr_vllanmto := 27.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3144410;
  v_dados(v_dados.last()).vr_nrctremp := 343116;
  v_dados(v_dados.last()).vr_vllanmto := 42.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 265420;
  v_dados(v_dados.last()).vr_nrctremp := 216943;
  v_dados(v_dados.last()).vr_vllanmto := 97.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 277819;
  v_dados(v_dados.last()).vr_nrctremp := 159656;
  v_dados(v_dados.last()).vr_vllanmto := 187.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 45.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 264946;
  v_dados(v_dados.last()).vr_nrctremp := 365118;
  v_dados(v_dados.last()).vr_vllanmto := 497.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 215643;
  v_dados(v_dados.last()).vr_nrctremp := 139828;
  v_dados(v_dados.last()).vr_vllanmto := 66.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 278254;
  v_dados(v_dados.last()).vr_nrctremp := 166419;
  v_dados(v_dados.last()).vr_vllanmto := 224.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551031;
  v_dados(v_dados.last()).vr_nrctremp := 159572;
  v_dados(v_dados.last()).vr_vllanmto := 159.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 765937;
  v_dados(v_dados.last()).vr_nrctremp := 237607;
  v_dados(v_dados.last()).vr_vllanmto := 85.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382493;
  v_dados(v_dados.last()).vr_nrctremp := 139419;
  v_dados(v_dados.last()).vr_vllanmto := 107.09;
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
