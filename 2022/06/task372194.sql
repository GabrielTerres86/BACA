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
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 834688;
  v_dados(v_dados.last()).vr_nrctremp := 264344;
  v_dados(v_dados.last()).vr_vllanmto := 127.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 839140;
  v_dados(v_dados.last()).vr_nrctremp := 265168;
  v_dados(v_dados.last()).vr_vllanmto := 82.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 839132;
  v_dados(v_dados.last()).vr_nrctremp := 265217;
  v_dados(v_dados.last()).vr_vllanmto := 155.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 844780;
  v_dados(v_dados.last()).vr_nrctremp := 266343;
  v_dados(v_dados.last()).vr_vllanmto := 63.26;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 846210;
  v_dados(v_dados.last()).vr_nrctremp := 266676;
  v_dados(v_dados.last()).vr_vllanmto := 39;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 768715;
  v_dados(v_dados.last()).vr_nrctremp := 267263;
  v_dados(v_dados.last()).vr_vllanmto := 1986.97;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 866547;
  v_dados(v_dados.last()).vr_nrctremp := 271760;
  v_dados(v_dados.last()).vr_vllanmto := 82.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 870447;
  v_dados(v_dados.last()).vr_nrctremp := 273372;
  v_dados(v_dados.last()).vr_vllanmto := 134.88;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 884367;
  v_dados(v_dados.last()).vr_nrctremp := 276947;
  v_dados(v_dados.last()).vr_vllanmto := 95.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 891134;
  v_dados(v_dados.last()).vr_nrctremp := 277529;
  v_dados(v_dados.last()).vr_vllanmto := 117.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 848050;
  v_dados(v_dados.last()).vr_nrctremp := 278327;
  v_dados(v_dados.last()).vr_vllanmto := 103.91;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 895253;
  v_dados(v_dados.last()).vr_nrctremp := 278555;
  v_dados(v_dados.last()).vr_vllanmto := 83.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 890499;
  v_dados(v_dados.last()).vr_nrctremp := 279292;
  v_dados(v_dados.last()).vr_vllanmto := 72.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 914711;
  v_dados(v_dados.last()).vr_nrctremp := 283184;
  v_dados(v_dados.last()).vr_vllanmto := 75.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 932167;
  v_dados(v_dados.last()).vr_nrctremp := 289034;
  v_dados(v_dados.last()).vr_vllanmto := 12.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 950475;
  v_dados(v_dados.last()).vr_nrctremp := 294242;
  v_dados(v_dados.last()).vr_vllanmto := 19.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 961116;
  v_dados(v_dados.last()).vr_nrctremp := 297576;
  v_dados(v_dados.last()).vr_vllanmto := 103.37;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 858072;
  v_dados(v_dados.last()).vr_nrctremp := 299588;
  v_dados(v_dados.last()).vr_vllanmto := 205.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 832510;
  v_dados(v_dados.last()).vr_nrctremp := 301017;
  v_dados(v_dados.last()).vr_vllanmto := 24.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 880019;
  v_dados(v_dados.last()).vr_nrctremp := 302476;
  v_dados(v_dados.last()).vr_vllanmto := 23.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 504831;
  v_dados(v_dados.last()).vr_nrctremp := 303314;
  v_dados(v_dados.last()).vr_vllanmto := 21.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 409960;
  v_dados(v_dados.last()).vr_nrctremp := 303878;
  v_dados(v_dados.last()).vr_vllanmto := 183.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 14.13;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1006460;
  v_dados(v_dados.last()).vr_nrctremp := 312077;
  v_dados(v_dados.last()).vr_vllanmto := 50.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1006126;
  v_dados(v_dados.last()).vr_nrctremp := 312481;
  v_dados(v_dados.last()).vr_vllanmto := 51.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 574899;
  v_dados(v_dados.last()).vr_nrctremp := 312653;
  v_dados(v_dados.last()).vr_vllanmto := 26.89;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 835358;
  v_dados(v_dados.last()).vr_nrctremp := 313093;
  v_dados(v_dados.last()).vr_vllanmto := 15.75;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575186;
  v_dados(v_dados.last()).vr_nrctremp := 314780;
  v_dados(v_dados.last()).vr_vllanmto := 23.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1019570;
  v_dados(v_dados.last()).vr_nrctremp := 315729;
  v_dados(v_dados.last()).vr_vllanmto := 19.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 597805;
  v_dados(v_dados.last()).vr_nrctremp := 318959;
  v_dados(v_dados.last()).vr_vllanmto := 38.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 763497;
  v_dados(v_dados.last()).vr_nrctremp := 320569;
  v_dados(v_dados.last()).vr_vllanmto := 60.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1035673;
  v_dados(v_dados.last()).vr_nrctremp := 320862;
  v_dados(v_dados.last()).vr_vllanmto := 36.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 931195;
  v_dados(v_dados.last()).vr_nrctremp := 321057;
  v_dados(v_dados.last()).vr_vllanmto := 43.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 615455;
  v_dados(v_dados.last()).vr_nrctremp := 321708;
  v_dados(v_dados.last()).vr_vllanmto := 932.07;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1040189;
  v_dados(v_dados.last()).vr_nrctremp := 322113;
  v_dados(v_dados.last()).vr_vllanmto := 245.57;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1040561;
  v_dados(v_dados.last()).vr_nrctremp := 322257;
  v_dados(v_dados.last()).vr_vllanmto := 33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 930938;
  v_dados(v_dados.last()).vr_nrctremp := 322349;
  v_dados(v_dados.last()).vr_vllanmto := 33.61;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 588610;
  v_dados(v_dados.last()).vr_nrctremp := 325682;
  v_dados(v_dados.last()).vr_vllanmto := 17.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1050745;
  v_dados(v_dados.last()).vr_nrctremp := 327015;
  v_dados(v_dados.last()).vr_vllanmto := 62.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 958883;
  v_dados(v_dados.last()).vr_nrctremp := 329872;
  v_dados(v_dados.last()).vr_vllanmto := 11.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 877786;
  v_dados(v_dados.last()).vr_nrctremp := 331618;
  v_dados(v_dados.last()).vr_vllanmto := 29.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1068865;
  v_dados(v_dados.last()).vr_nrctremp := 331620;
  v_dados(v_dados.last()).vr_vllanmto := 16.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1069217;
  v_dados(v_dados.last()).vr_nrctremp := 338555;
  v_dados(v_dados.last()).vr_vllanmto := 84.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1090607;
  v_dados(v_dados.last()).vr_nrctremp := 339567;
  v_dados(v_dados.last()).vr_vllanmto := 17.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1094157;
  v_dados(v_dados.last()).vr_nrctremp := 341025;
  v_dados(v_dados.last()).vr_vllanmto := 14.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1119605;
  v_dados(v_dados.last()).vr_nrctremp := 352146;
  v_dados(v_dados.last()).vr_vllanmto := 607.66;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 608475;
  v_dados(v_dados.last()).vr_nrctremp := 353441;
  v_dados(v_dados.last()).vr_vllanmto := 47.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1125664;
  v_dados(v_dados.last()).vr_nrctremp := 354805;
  v_dados(v_dados.last()).vr_vllanmto := 24.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1130781;
  v_dados(v_dados.last()).vr_nrctremp := 356325;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 736767;
  v_dados(v_dados.last()).vr_nrctremp := 358645;
  v_dados(v_dados.last()).vr_vllanmto := 13.58;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 874655;
  v_dados(v_dados.last()).vr_nrctremp := 359656;
  v_dados(v_dados.last()).vr_vllanmto := 447.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 764248;
  v_dados(v_dados.last()).vr_nrctremp := 360328;
  v_dados(v_dados.last()).vr_vllanmto := 6653.94;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

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
