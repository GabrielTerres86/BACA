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
    v_dados(v_dados.last()).vr_nrdconta := 839140;
    v_dados(v_dados.last()).vr_nrctremp := 265168;
    v_dados(v_dados.last()).vr_vllanmto := 107.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 833983;
    v_dados(v_dados.last()).vr_nrctremp := 265725;
    v_dados(v_dados.last()).vr_vllanmto := 2204.03;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 858200;
    v_dados(v_dados.last()).vr_nrctremp := 269473;
    v_dados(v_dados.last()).vr_vllanmto := 51.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 862339;
    v_dados(v_dados.last()).vr_nrctremp := 270573;
    v_dados(v_dados.last()).vr_vllanmto := 81.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 866547;
    v_dados(v_dados.last()).vr_nrctremp := 271760;
    v_dados(v_dados.last()).vr_vllanmto := 111.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 884367;
    v_dados(v_dados.last()).vr_nrctremp := 276947;
    v_dados(v_dados.last()).vr_vllanmto := 133.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 891134;
    v_dados(v_dados.last()).vr_nrctremp := 277529;
    v_dados(v_dados.last()).vr_vllanmto := 159.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 895253;
    v_dados(v_dados.last()).vr_nrctremp := 278555;
    v_dados(v_dados.last()).vr_vllanmto := 97.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 890499;
    v_dados(v_dados.last()).vr_nrctremp := 279292;
    v_dados(v_dados.last()).vr_vllanmto := 102.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 909165;
    v_dados(v_dados.last()).vr_nrctremp := 281596;
    v_dados(v_dados.last()).vr_vllanmto := 92.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 858072;
    v_dados(v_dados.last()).vr_nrctremp := 299588;
    v_dados(v_dados.last()).vr_vllanmto := 128.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 788066;
    v_dados(v_dados.last()).vr_nrctremp := 301304;
    v_dados(v_dados.last()).vr_vllanmto := 44.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 880019;
    v_dados(v_dados.last()).vr_nrctremp := 302476;
    v_dados(v_dados.last()).vr_vllanmto := 36.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 770876;
    v_dados(v_dados.last()).vr_nrctremp := 303009;
    v_dados(v_dados.last()).vr_vllanmto := 190.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 504831;
    v_dados(v_dados.last()).vr_nrctremp := 303314;
    v_dados(v_dados.last()).vr_vllanmto := 32.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 409960;
    v_dados(v_dados.last()).vr_nrctremp := 303878;
    v_dados(v_dados.last()).vr_vllanmto := 285.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 987905;
    v_dados(v_dados.last()).vr_nrctremp := 311566;
    v_dados(v_dados.last()).vr_vllanmto := 1156.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 574899;
    v_dados(v_dados.last()).vr_nrctremp := 312653;
    v_dados(v_dados.last()).vr_vllanmto := 74.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 835358;
    v_dados(v_dados.last()).vr_nrctremp := 313093;
    v_dados(v_dados.last()).vr_vllanmto := 42.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1019570;
    v_dados(v_dados.last()).vr_nrctremp := 315729;
    v_dados(v_dados.last()).vr_vllanmto := 56.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 597805;
    v_dados(v_dados.last()).vr_nrctremp := 318959;
    v_dados(v_dados.last()).vr_vllanmto := 106.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 908290;
    v_dados(v_dados.last()).vr_nrctremp := 320031;
    v_dados(v_dados.last()).vr_vllanmto := 265.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1035673;
    v_dados(v_dados.last()).vr_nrctremp := 320862;
    v_dados(v_dados.last()).vr_vllanmto := 27.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 831581;
    v_dados(v_dados.last()).vr_nrctremp := 320894;
    v_dados(v_dados.last()).vr_vllanmto := 25.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1040189;
    v_dados(v_dados.last()).vr_nrctremp := 322113;
    v_dados(v_dados.last()).vr_vllanmto := 19.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1031481;
    v_dados(v_dados.last()).vr_nrctremp := 323479;
    v_dados(v_dados.last()).vr_vllanmto := 18.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 923770;
    v_dados(v_dados.last()).vr_nrctremp := 325369;
    v_dados(v_dados.last()).vr_vllanmto := 28.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 958883;
    v_dados(v_dados.last()).vr_nrctremp := 329872;
    v_dados(v_dados.last()).vr_vllanmto := 51.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 877786;
    v_dados(v_dados.last()).vr_nrctremp := 331618;
    v_dados(v_dados.last()).vr_vllanmto := 136.76;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 887382;
    v_dados(v_dados.last()).vr_nrctremp := 334227;
    v_dados(v_dados.last()).vr_vllanmto := 32.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 663778;
    v_dados(v_dados.last()).vr_nrctremp := 336241;
    v_dados(v_dados.last()).vr_vllanmto := 162.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1090607;
    v_dados(v_dados.last()).vr_nrctremp := 339567;
    v_dados(v_dados.last()).vr_vllanmto := 86.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1101897;
    v_dados(v_dados.last()).vr_nrctremp := 344567;
    v_dados(v_dados.last()).vr_vllanmto := 51.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1104870;
    v_dados(v_dados.last()).vr_nrctremp := 344916;
    v_dados(v_dados.last()).vr_vllanmto := 21.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1106880;
    v_dados(v_dados.last()).vr_nrctremp := 345685;
    v_dados(v_dados.last()).vr_vllanmto := 18.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1099434;
    v_dados(v_dados.last()).vr_nrctremp := 348550;
    v_dados(v_dados.last()).vr_vllanmto := 64.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 608475;
    v_dados(v_dados.last()).vr_nrctremp := 353441;
    v_dados(v_dados.last()).vr_vllanmto := 63.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 569062;
    v_dados(v_dados.last()).vr_nrctremp := 364414;
    v_dados(v_dados.last()).vr_vllanmto := 16.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 643017;
    v_dados(v_dados.last()).vr_nrctremp := 367176;
    v_dados(v_dados.last()).vr_vllanmto := 46.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 14646846;
    v_dados(v_dados.last()).vr_nrctremp := 371966;
    v_dados(v_dados.last()).vr_vllanmto := 16.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 457736;
    v_dados(v_dados.last()).vr_nrctremp := 373587;
    v_dados(v_dados.last()).vr_vllanmto := 22.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 601470;
    v_dados(v_dados.last()).vr_nrctremp := 376735;
    v_dados(v_dados.last()).vr_vllanmto := 18.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1156462;
    v_dados(v_dados.last()).vr_nrctremp := 384151;
    v_dados(v_dados.last()).vr_vllanmto := 188.64;
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
