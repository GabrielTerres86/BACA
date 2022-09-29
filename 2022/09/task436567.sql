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
    v_dados(v_dados.last()).vr_nrdconta := 781126;
    v_dados(v_dados.last()).vr_nrctremp := 273012;
    v_dados(v_dados.last()).vr_vllanmto := 102.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 870447;
    v_dados(v_dados.last()).vr_nrctremp := 273372;
    v_dados(v_dados.last()).vr_vllanmto := 2224.29;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 884367;
    v_dados(v_dados.last()).vr_nrctremp := 276947;
    v_dados(v_dados.last()).vr_vllanmto := 151.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 891134;
    v_dados(v_dados.last()).vr_nrctremp := 277529;
    v_dados(v_dados.last()).vr_vllanmto := 166.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 890499;
    v_dados(v_dados.last()).vr_nrctremp := 279292;
    v_dados(v_dados.last()).vr_vllanmto := 116.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 914711;
    v_dados(v_dados.last()).vr_nrctremp := 283184;
    v_dados(v_dados.last()).vr_vllanmto := 114.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 950475;
    v_dados(v_dados.last()).vr_nrctremp := 294242;
    v_dados(v_dados.last()).vr_vllanmto := 40.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 961116;
    v_dados(v_dados.last()).vr_nrctremp := 297576;
    v_dados(v_dados.last()).vr_vllanmto := 157.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 832510;
    v_dados(v_dados.last()).vr_nrctremp := 301017;
    v_dados(v_dados.last()).vr_vllanmto := .14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 770876;
    v_dados(v_dados.last()).vr_nrctremp := 303009;
    v_dados(v_dados.last()).vr_vllanmto := 60.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 504831;
    v_dados(v_dados.last()).vr_nrctremp := 303314;
    v_dados(v_dados.last()).vr_vllanmto := 21.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 409960;
    v_dados(v_dados.last()).vr_nrctremp := 303878;
    v_dados(v_dados.last()).vr_vllanmto := 160.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 760030;
    v_dados(v_dados.last()).vr_nrctremp := 312388;
    v_dados(v_dados.last()).vr_vllanmto := 28.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 574899;
    v_dados(v_dados.last()).vr_nrctremp := 312653;
    v_dados(v_dados.last()).vr_vllanmto := 69.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 835358;
    v_dados(v_dados.last()).vr_nrctremp := 313093;
    v_dados(v_dados.last()).vr_vllanmto := 56.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 597805;
    v_dados(v_dados.last()).vr_nrctremp := 318959;
    v_dados(v_dados.last()).vr_vllanmto := 30.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 908290;
    v_dados(v_dados.last()).vr_nrctremp := 320031;
    v_dados(v_dados.last()).vr_vllanmto := 297.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1035673;
    v_dados(v_dados.last()).vr_nrctremp := 320862;
    v_dados(v_dados.last()).vr_vllanmto := 46.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 936057;
    v_dados(v_dados.last()).vr_nrctremp := 322439;
    v_dados(v_dados.last()).vr_vllanmto := 32.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 654850;
    v_dados(v_dados.last()).vr_nrctremp := 324574;
    v_dados(v_dados.last()).vr_vllanmto := 771.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 966835;
    v_dados(v_dados.last()).vr_nrctremp := 328953;
    v_dados(v_dados.last()).vr_vllanmto := 7.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 958883;
    v_dados(v_dados.last()).vr_nrctremp := 329872;
    v_dados(v_dados.last()).vr_vllanmto := 66.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1064053;
    v_dados(v_dados.last()).vr_nrctremp := 331471;
    v_dados(v_dados.last()).vr_vllanmto := 22.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 877786;
    v_dados(v_dados.last()).vr_nrctremp := 331618;
    v_dados(v_dados.last()).vr_vllanmto := 49.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 682993;
    v_dados(v_dados.last()).vr_nrctremp := 333984;
    v_dados(v_dados.last()).vr_vllanmto := 19.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1079115;
    v_dados(v_dados.last()).vr_nrctremp := 335834;
    v_dados(v_dados.last()).vr_vllanmto := 19.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1069217;
    v_dados(v_dados.last()).vr_nrctremp := 338555;
    v_dados(v_dados.last()).vr_vllanmto := 141.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 913227;
    v_dados(v_dados.last()).vr_nrctremp := 339446;
    v_dados(v_dados.last()).vr_vllanmto := 6.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1094157;
    v_dados(v_dados.last()).vr_nrctremp := 341025;
    v_dados(v_dados.last()).vr_vllanmto := 26.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1101897;
    v_dados(v_dados.last()).vr_nrctremp := 344567;
    v_dados(v_dados.last()).vr_vllanmto := 77.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1014935;
    v_dados(v_dados.last()).vr_nrctremp := 348292;
    v_dados(v_dados.last()).vr_vllanmto := 7.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 697370;
    v_dados(v_dados.last()).vr_nrctremp := 352338;
    v_dados(v_dados.last()).vr_vllanmto := 3.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 608475;
    v_dados(v_dados.last()).vr_nrctremp := 353441;
    v_dados(v_dados.last()).vr_vllanmto := 90.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 934283;
    v_dados(v_dados.last()).vr_nrctremp := 353980;
    v_dados(v_dados.last()).vr_vllanmto := 50.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1130781;
    v_dados(v_dados.last()).vr_nrctremp := 356325;
    v_dados(v_dados.last()).vr_vllanmto := 30.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 736767;
    v_dados(v_dados.last()).vr_nrctremp := 358645;
    v_dados(v_dados.last()).vr_vllanmto := 24.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 585068;
    v_dados(v_dados.last()).vr_nrctremp := 359290;
    v_dados(v_dados.last()).vr_vllanmto := 1.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 874655;
    v_dados(v_dados.last()).vr_nrctremp := 359656;
    v_dados(v_dados.last()).vr_vllanmto := 45.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 499196;
    v_dados(v_dados.last()).vr_nrctremp := 359792;
    v_dados(v_dados.last()).vr_vllanmto := 12.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14466244;
    v_dados(v_dados.last()).vr_nrctremp := 363449;
    v_dados(v_dados.last()).vr_vllanmto := 9.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14466953;
    v_dados(v_dados.last()).vr_nrctremp := 364021;
    v_dados(v_dados.last()).vr_vllanmto := 8.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 967416;
    v_dados(v_dados.last()).vr_nrctremp := 366847;
    v_dados(v_dados.last()).vr_vllanmto := 15.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 643017;
    v_dados(v_dados.last()).vr_nrctremp := 367176;
    v_dados(v_dados.last()).vr_vllanmto := 64.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14592657;
    v_dados(v_dados.last()).vr_nrctremp := 370196;
    v_dados(v_dados.last()).vr_vllanmto := 3.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 913227;
    v_dados(v_dados.last()).vr_nrctremp := 370804;
    v_dados(v_dados.last()).vr_vllanmto := 4.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 601470;
    v_dados(v_dados.last()).vr_nrctremp := 376735;
    v_dados(v_dados.last()).vr_vllanmto := 41.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14762226;
    v_dados(v_dados.last()).vr_nrctremp := 376972;
    v_dados(v_dados.last()).vr_vllanmto := 7.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 658626;
    v_dados(v_dados.last()).vr_nrctremp := 377378;
    v_dados(v_dados.last()).vr_vllanmto := 1630.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1080946;
    v_dados(v_dados.last()).vr_nrctremp := 377942;
    v_dados(v_dados.last()).vr_vllanmto := 17.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14698722;
    v_dados(v_dados.last()).vr_nrctremp := 379118;
    v_dados(v_dados.last()).vr_vllanmto := 91.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 800961;
    v_dados(v_dados.last()).vr_nrctremp := 385817;
    v_dados(v_dados.last()).vr_vllanmto := 27.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 583766;
    v_dados(v_dados.last()).vr_nrctremp := 385867;
    v_dados(v_dados.last()).vr_vllanmto := 4.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 745243;
    v_dados(v_dados.last()).vr_nrctremp := 386838;
    v_dados(v_dados.last()).vr_vllanmto := 4.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 870447;
    v_dados(v_dados.last()).vr_nrctremp := 394379;
    v_dados(v_dados.last()).vr_vllanmto := 221.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 654850;
    v_dados(v_dados.last()).vr_nrctremp := 404455;
    v_dados(v_dados.last()).vr_vllanmto := 2.92;
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
