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
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355607;
    v_dados(v_dados.last()).vr_nrctremp := 65807;
    v_dados(v_dados.last()).vr_vllanmto := 8217.42;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 2391.35;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148164;
    v_dados(v_dados.last()).vr_nrctremp := 54351;
    v_dados(v_dados.last()).vr_vllanmto := 1084.05;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 59512;
    v_dados(v_dados.last()).vr_vllanmto := 2317.56;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553964;
    v_dados(v_dados.last()).vr_nrctremp := 157739;
    v_dados(v_dados.last()).vr_vllanmto := 1413.98;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187194;
    v_dados(v_dados.last()).vr_nrctremp := 56891;
    v_dados(v_dados.last()).vr_vllanmto := 1096.83;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368920;
    v_dados(v_dados.last()).vr_nrctremp := 66349;
    v_dados(v_dados.last()).vr_vllanmto := 883.75;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394734;
    v_dados(v_dados.last()).vr_nrctremp := 72344;
    v_dados(v_dados.last()).vr_vllanmto := 875.31;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379093;
    v_dados(v_dados.last()).vr_nrctremp := 102367;
    v_dados(v_dados.last()).vr_vllanmto := 524.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 20923;
    v_dados(v_dados.last()).vr_nrctremp := 82841;
    v_dados(v_dados.last()).vr_vllanmto := 508.1;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94730;
    v_dados(v_dados.last()).vr_nrctremp := 107538;
    v_dados(v_dados.last()).vr_vllanmto := 330.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214710;
    v_dados(v_dados.last()).vr_nrctremp := 53208;
    v_dados(v_dados.last()).vr_vllanmto := 28.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 376744;
    v_dados(v_dados.last()).vr_nrctremp := 78331;
    v_dados(v_dados.last()).vr_vllanmto := 176.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 418978;
    v_dados(v_dados.last()).vr_nrctremp := 97572;
    v_dados(v_dados.last()).vr_vllanmto := 12464.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 165.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 386545;
    v_dados(v_dados.last()).vr_nrctremp := 51508;
    v_dados(v_dados.last()).vr_vllanmto := 153.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319864;
    v_dados(v_dados.last()).vr_nrctremp := 91954;
    v_dados(v_dados.last()).vr_vllanmto := 146.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 140.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 52428;
    v_dados(v_dados.last()).vr_vllanmto := 131.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150215;
    v_dados(v_dados.last()).vr_nrctremp := 52249;
    v_dados(v_dados.last()).vr_vllanmto := 118.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 67514;
    v_dados(v_dados.last()).vr_vllanmto := 116.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109380;
    v_dados(v_dados.last()).vr_nrctremp := 54347;
    v_dados(v_dados.last()).vr_vllanmto := 114.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149322;
    v_dados(v_dados.last()).vr_nrctremp := 59821;
    v_dados(v_dados.last()).vr_vllanmto := 113.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 112.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 418285;
    v_dados(v_dados.last()).vr_nrctremp := 55603;
    v_dados(v_dados.last()).vr_vllanmto := 105.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186201;
    v_dados(v_dados.last()).vr_nrctremp := 71865;
    v_dados(v_dados.last()).vr_vllanmto := 105.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269921;
    v_dados(v_dados.last()).vr_nrctremp := 53607;
    v_dados(v_dados.last()).vr_vllanmto := 103.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484067;
    v_dados(v_dados.last()).vr_nrctremp := 100800;
    v_dados(v_dados.last()).vr_vllanmto := 394.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 209066;
    v_dados(v_dados.last()).vr_nrctremp := 56508;
    v_dados(v_dados.last()).vr_vllanmto := 82.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120170;
    v_dados(v_dados.last()).vr_nrctremp := 78341;
    v_dados(v_dados.last()).vr_vllanmto := 82.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138711;
    v_dados(v_dados.last()).vr_nrctremp := 84334;
    v_dados(v_dados.last()).vr_vllanmto := 81.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382302;
    v_dados(v_dados.last()).vr_nrctremp := 68878;
    v_dados(v_dados.last()).vr_vllanmto := 80.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379301;
    v_dados(v_dados.last()).vr_nrctremp := 52196;
    v_dados(v_dados.last()).vr_vllanmto := 75.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192902;
    v_dados(v_dados.last()).vr_nrctremp := 87507;
    v_dados(v_dados.last()).vr_vllanmto := 74.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 97211;
    v_dados(v_dados.last()).vr_vllanmto := 71.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441961;
    v_dados(v_dados.last()).vr_nrctremp := 85071;
    v_dados(v_dados.last()).vr_vllanmto := 70.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 223913;
    v_dados(v_dados.last()).vr_nrctremp := 57290;
    v_dados(v_dados.last()).vr_vllanmto := 68.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145947;
    v_dados(v_dados.last()).vr_nrctremp := 56091;
    v_dados(v_dados.last()).vr_vllanmto := 67.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421200;
    v_dados(v_dados.last()).vr_nrctremp := 56187;
    v_dados(v_dados.last()).vr_vllanmto := 63.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419869;
    v_dados(v_dados.last()).vr_nrctremp := 55947;
    v_dados(v_dados.last()).vr_vllanmto := 62.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303348;
    v_dados(v_dados.last()).vr_nrctremp := 75300;
    v_dados(v_dados.last()).vr_vllanmto := 61.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 65692;
    v_dados(v_dados.last()).vr_nrctremp := 87320;
    v_dados(v_dados.last()).vr_vllanmto := 57.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 126926;
    v_dados(v_dados.last()).vr_nrctremp := 57415;
    v_dados(v_dados.last()).vr_vllanmto := 56.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293822;
    v_dados(v_dados.last()).vr_nrctremp := 57792;
    v_dados(v_dados.last()).vr_vllanmto := 55.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120618;
    v_dados(v_dados.last()).vr_nrctremp := 104378;
    v_dados(v_dados.last()).vr_vllanmto := 52.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78743;
    v_dados(v_dados.last()).vr_nrctremp := 92507;
    v_dados(v_dados.last()).vr_vllanmto := 76.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 86096;
    v_dados(v_dados.last()).vr_vllanmto := 48.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95532;
    v_dados(v_dados.last()).vr_nrctremp := 68569;
    v_dados(v_dados.last()).vr_vllanmto := 48.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 511986;
    v_dados(v_dados.last()).vr_nrctremp := 185743;
    v_dados(v_dados.last()).vr_vllanmto := 47.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 53664;
    v_dados(v_dados.last()).vr_vllanmto := 44.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 72425;
    v_dados(v_dados.last()).vr_vllanmto := 1017.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325520;
    v_dados(v_dados.last()).vr_nrctremp := 56731;
    v_dados(v_dados.last()).vr_vllanmto := 735.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154466;
    v_dados(v_dados.last()).vr_nrctremp := 99993;
    v_dados(v_dados.last()).vr_vllanmto := 41.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150304;
    v_dados(v_dados.last()).vr_nrctremp := 59164;
    v_dados(v_dados.last()).vr_vllanmto := 40.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526118;
    v_dados(v_dados.last()).vr_nrctremp := 96688;
    v_dados(v_dados.last()).vr_vllanmto := 39.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161039;
    v_dados(v_dados.last()).vr_nrctremp := 58666;
    v_dados(v_dados.last()).vr_vllanmto := 1446.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315788;
    v_dados(v_dados.last()).vr_nrctremp := 79006;
    v_dados(v_dados.last()).vr_vllanmto := 37.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524123;
    v_dados(v_dados.last()).vr_nrctremp := 94749;
    v_dados(v_dados.last()).vr_vllanmto := 36.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18180;
    v_dados(v_dados.last()).vr_nrctremp := 140475;
    v_dados(v_dados.last()).vr_vllanmto := 26.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 98825;
    v_dados(v_dados.last()).vr_vllanmto := 34.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 34.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216305;
    v_dados(v_dados.last()).vr_nrctremp := 97595;
    v_dados(v_dados.last()).vr_vllanmto := 34.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 33294;
    v_dados(v_dados.last()).vr_nrctremp := 116931;
    v_dados(v_dados.last()).vr_vllanmto := 33.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214981;
    v_dados(v_dados.last()).vr_nrctremp := 71663;
    v_dados(v_dados.last()).vr_vllanmto := 33.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 271276;
    v_dados(v_dados.last()).vr_nrctremp := 53665;
    v_dados(v_dados.last()).vr_vllanmto := 33.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 96390;
    v_dados(v_dados.last()).vr_vllanmto := 32.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 499072;
    v_dados(v_dados.last()).vr_nrctremp := 124981;
    v_dados(v_dados.last()).vr_vllanmto := 31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169404;
    v_dados(v_dados.last()).vr_nrctremp := 51795;
    v_dados(v_dados.last()).vr_vllanmto := 30.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83766;
    v_dados(v_dados.last()).vr_vllanmto := 30.5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213365;
    v_dados(v_dados.last()).vr_nrctremp := 125577;
    v_dados(v_dados.last()).vr_vllanmto := 28.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187747;
    v_dados(v_dados.last()).vr_nrctremp := 101671;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 91171;
    v_dados(v_dados.last()).vr_vllanmto := 31.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192929;
    v_dados(v_dados.last()).vr_nrctremp := 52884;
    v_dados(v_dados.last()).vr_vllanmto := 26.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240273;
    v_dados(v_dados.last()).vr_nrctremp := 105139;
    v_dados(v_dados.last()).vr_vllanmto := 26.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 74654;
    v_dados(v_dados.last()).vr_vllanmto := 26.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 71878;
    v_dados(v_dados.last()).vr_vllanmto := 24.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170097;
    v_dados(v_dados.last()).vr_nrctremp := 84009;
    v_dados(v_dados.last()).vr_vllanmto := 24.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := 23.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 372021;
    v_dados(v_dados.last()).vr_nrctremp := 108178;
    v_dados(v_dados.last()).vr_vllanmto := 23.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188158;
    v_dados(v_dados.last()).vr_nrctremp := 79186;
    v_dados(v_dados.last()).vr_vllanmto := 22.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 67072;
    v_dados(v_dados.last()).vr_vllanmto := 22.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112758;
    v_dados(v_dados.last()).vr_vllanmto := 21.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 58256;
    v_dados(v_dados.last()).vr_vllanmto := 21.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 718319;
    v_dados(v_dados.last()).vr_nrctremp := 186780;
    v_dados(v_dados.last()).vr_vllanmto := 21.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266450;
    v_dados(v_dados.last()).vr_nrctremp := 87972;
    v_dados(v_dados.last()).vr_vllanmto := 20.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136816;
    v_dados(v_dados.last()).vr_nrctremp := 116222;
    v_dados(v_dados.last()).vr_vllanmto := 1279.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 471046;
    v_dados(v_dados.last()).vr_nrctremp := 185937;
    v_dados(v_dados.last()).vr_vllanmto := 19.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 184919;
    v_dados(v_dados.last()).vr_vllanmto := 19.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170356;
    v_dados(v_dados.last()).vr_nrctremp := 65618;
    v_dados(v_dados.last()).vr_vllanmto := 18.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 87898;
    v_dados(v_dados.last()).vr_vllanmto := 18.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 187057;
    v_dados(v_dados.last()).vr_vllanmto := 18.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 16373;
    v_dados(v_dados.last()).vr_nrctremp := 107060;
    v_dados(v_dados.last()).vr_vllanmto := 17.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149039;
    v_dados(v_dados.last()).vr_nrctremp := 88625;
    v_dados(v_dados.last()).vr_vllanmto := 17.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275298;
    v_dados(v_dados.last()).vr_nrctremp := 111162;
    v_dados(v_dados.last()).vr_vllanmto := 20.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186139;
    v_dados(v_dados.last()).vr_nrctremp := 79508;
    v_dados(v_dados.last()).vr_vllanmto := 16.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215104;
    v_dados(v_dados.last()).vr_nrctremp := 112556;
    v_dados(v_dados.last()).vr_vllanmto := 15.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166987;
    v_dados(v_dados.last()).vr_nrctremp := 63352;
    v_dados(v_dados.last()).vr_vllanmto := 14.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202665;
    v_dados(v_dados.last()).vr_nrctremp := 123568;
    v_dados(v_dados.last()).vr_vllanmto := 13.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 76961;
    v_dados(v_dados.last()).vr_nrctremp := 93710;
    v_dados(v_dados.last()).vr_vllanmto := 13.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91572;
    v_dados(v_dados.last()).vr_vllanmto := 13.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 557153;
    v_dados(v_dados.last()).vr_nrctremp := 111077;
    v_dados(v_dados.last()).vr_vllanmto := 13.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71105;
    v_dados(v_dados.last()).vr_vllanmto := 12.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 122406;
    v_dados(v_dados.last()).vr_vllanmto := 1244.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 134910;
    v_dados(v_dados.last()).vr_nrctremp := 187662;
    v_dados(v_dados.last()).vr_vllanmto := 11.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395714;
    v_dados(v_dados.last()).vr_nrctremp := 185957;
    v_dados(v_dados.last()).vr_vllanmto := 11.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 138297;
    v_dados(v_dados.last()).vr_vllanmto := 84.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 8222;
    v_dados(v_dados.last()).vr_nrctremp := 183493;
    v_dados(v_dados.last()).vr_vllanmto := 10.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 107679;
    v_dados(v_dados.last()).vr_vllanmto := 10.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 64450;
    v_dados(v_dados.last()).vr_vllanmto := 10.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95400;
    v_dados(v_dados.last()).vr_nrctremp := 118820;
    v_dados(v_dados.last()).vr_vllanmto := 10.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 117044;
    v_dados(v_dados.last()).vr_vllanmto := 10.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 105708;
    v_dados(v_dados.last()).vr_vllanmto := 9.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 125901;
    v_dados(v_dados.last()).vr_vllanmto := 9.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544167;
    v_dados(v_dados.last()).vr_nrctremp := 104635;
    v_dados(v_dados.last()).vr_vllanmto := 9.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544809;
    v_dados(v_dados.last()).vr_nrctremp := 104688;
    v_dados(v_dados.last()).vr_vllanmto := 8.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553905;
    v_dados(v_dados.last()).vr_nrctremp := 110020;
    v_dados(v_dados.last()).vr_vllanmto := 8.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59382;
    v_dados(v_dados.last()).vr_nrctremp := 86033;
    v_dados(v_dados.last()).vr_vllanmto := 8.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267414;
    v_dados(v_dados.last()).vr_nrctremp := 76198;
    v_dados(v_dados.last()).vr_vllanmto := 7.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 140029;
    v_dados(v_dados.last()).vr_vllanmto := 638.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187372;
    v_dados(v_dados.last()).vr_nrctremp := 102721;
    v_dados(v_dados.last()).vr_vllanmto := 6.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334936;
    v_dados(v_dados.last()).vr_nrctremp := 139875;
    v_dados(v_dados.last()).vr_vllanmto := 6.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288640;
    v_dados(v_dados.last()).vr_nrctremp := 55992;
    v_dados(v_dados.last()).vr_vllanmto := 5.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185426;
    v_dados(v_dados.last()).vr_nrctremp := 112115;
    v_dados(v_dados.last()).vr_vllanmto := 4.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107620;
    v_dados(v_dados.last()).vr_nrctremp := 132064;
    v_dados(v_dados.last()).vr_vllanmto := 4.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 2.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183334;
    v_dados(v_dados.last()).vr_nrctremp := 64957;
    v_dados(v_dados.last()).vr_vllanmto := 10.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 200395;
    v_dados(v_dados.last()).vr_nrctremp := 165875;
    v_dados(v_dados.last()).vr_vllanmto := 10.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := 10.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276464;
    v_dados(v_dados.last()).vr_nrctremp := 134609;
    v_dados(v_dados.last()).vr_vllanmto := 10.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 106412;
    v_dados(v_dados.last()).vr_vllanmto := 10.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185426;
    v_dados(v_dados.last()).vr_nrctremp := 86080;
    v_dados(v_dados.last()).vr_vllanmto := 10.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 444057;
    v_dados(v_dados.last()).vr_nrctremp := 156882;
    v_dados(v_dados.last()).vr_vllanmto := 10.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 137047;
    v_dados(v_dados.last()).vr_vllanmto := 10.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131375;
    v_dados(v_dados.last()).vr_vllanmto := 10.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 135957;
    v_dados(v_dados.last()).vr_vllanmto := 10.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148215;
    v_dados(v_dados.last()).vr_vllanmto := 10.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 109238;
    v_dados(v_dados.last()).vr_vllanmto := 10.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524808;
    v_dados(v_dados.last()).vr_nrctremp := 95190;
    v_dados(v_dados.last()).vr_vllanmto := 10.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288624;
    v_dados(v_dados.last()).vr_nrctremp := 155423;
    v_dados(v_dados.last()).vr_vllanmto := 10.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268151;
    v_dados(v_dados.last()).vr_nrctremp := 118237;
    v_dados(v_dados.last()).vr_vllanmto := 10.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83094;
    v_dados(v_dados.last()).vr_vllanmto := 10.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248355;
    v_dados(v_dados.last()).vr_nrctremp := 75999;
    v_dados(v_dados.last()).vr_vllanmto := 10.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 148322;
    v_dados(v_dados.last()).vr_vllanmto := 10.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189693;
    v_dados(v_dados.last()).vr_nrctremp := 116390;
    v_dados(v_dados.last()).vr_vllanmto := 10.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185957;
    v_dados(v_dados.last()).vr_nrctremp := 74163;
    v_dados(v_dados.last()).vr_vllanmto := 10.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59307;
    v_dados(v_dados.last()).vr_nrctremp := 182948;
    v_dados(v_dados.last()).vr_vllanmto := 10.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 330248;
    v_dados(v_dados.last()).vr_nrctremp := 172256;
    v_dados(v_dados.last()).vr_vllanmto := 11.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 50957;
    v_dados(v_dados.last()).vr_vllanmto := 11.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14224259;
    v_dados(v_dados.last()).vr_nrctremp := 176904;
    v_dados(v_dados.last()).vr_vllanmto := 11.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 96071;
    v_dados(v_dados.last()).vr_vllanmto := 11.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129860;
    v_dados(v_dados.last()).vr_nrctremp := 139883;
    v_dados(v_dados.last()).vr_vllanmto := 11.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 177469;
    v_dados(v_dados.last()).vr_vllanmto := 11.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 164930;
    v_dados(v_dados.last()).vr_vllanmto := 11.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 65227;
    v_dados(v_dados.last()).vr_vllanmto := 810.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92681;
    v_dados(v_dados.last()).vr_nrctremp := 52581;
    v_dados(v_dados.last()).vr_vllanmto := 11.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 126586;
    v_dados(v_dados.last()).vr_nrctremp := 81747;
    v_dados(v_dados.last()).vr_vllanmto := 11.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102822;
    v_dados(v_dados.last()).vr_nrctremp := 163575;
    v_dados(v_dados.last()).vr_vllanmto := 11.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 105430;
    v_dados(v_dados.last()).vr_vllanmto := 11.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100080;
    v_dados(v_dados.last()).vr_nrctremp := 182022;
    v_dados(v_dados.last()).vr_vllanmto := 11.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149764;
    v_dados(v_dados.last()).vr_nrctremp := 96325;
    v_dados(v_dados.last()).vr_vllanmto := 11.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116432;
    v_dados(v_dados.last()).vr_nrctremp := 168836;
    v_dados(v_dados.last()).vr_vllanmto := 11.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 138689;
    v_dados(v_dados.last()).vr_vllanmto := 11.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116166;
    v_dados(v_dados.last()).vr_vllanmto := 11.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 658057;
    v_dados(v_dados.last()).vr_nrctremp := 168054;
    v_dados(v_dados.last()).vr_vllanmto := 11.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 133611;
    v_dados(v_dados.last()).vr_vllanmto := 12.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360961;
    v_dados(v_dados.last()).vr_nrctremp := 84145;
    v_dados(v_dados.last()).vr_vllanmto := 12.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 108200;
    v_dados(v_dados.last()).vr_vllanmto := 12.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 109603;
    v_dados(v_dados.last()).vr_vllanmto := 12.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141054;
    v_dados(v_dados.last()).vr_nrctremp := 114755;
    v_dados(v_dados.last()).vr_vllanmto := 12.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161640;
    v_dados(v_dados.last()).vr_nrctremp := 136155;
    v_dados(v_dados.last()).vr_vllanmto := 12.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166200;
    v_dados(v_dados.last()).vr_nrctremp := 126085;
    v_dados(v_dados.last()).vr_vllanmto := 13.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142611;
    v_dados(v_dados.last()).vr_nrctremp := 86099;
    v_dados(v_dados.last()).vr_vllanmto := 13.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 70325;
    v_dados(v_dados.last()).vr_vllanmto := 13.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 635669;
    v_dados(v_dados.last()).vr_nrctremp := 146059;
    v_dados(v_dados.last()).vr_vllanmto := 13.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138711;
    v_dados(v_dados.last()).vr_nrctremp := 158857;
    v_dados(v_dados.last()).vr_vllanmto := 13.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159182;
    v_dados(v_dados.last()).vr_nrctremp := 112574;
    v_dados(v_dados.last()).vr_vllanmto := 13.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215902;
    v_dados(v_dados.last()).vr_nrctremp := 98010;
    v_dados(v_dados.last()).vr_vllanmto := 13.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166472;
    v_dados(v_dados.last()).vr_nrctremp := 169114;
    v_dados(v_dados.last()).vr_vllanmto := 13.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191930;
    v_dados(v_dados.last()).vr_nrctremp := 42594;
    v_dados(v_dados.last()).vr_vllanmto := 13.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 64692;
    v_dados(v_dados.last()).vr_vllanmto := 13.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 558052;
    v_dados(v_dados.last()).vr_nrctremp := 112094;
    v_dados(v_dados.last()).vr_vllanmto := 13.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66540;
    v_dados(v_dados.last()).vr_nrctremp := 106736;
    v_dados(v_dados.last()).vr_vllanmto := 13.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 104920;
    v_dados(v_dados.last()).vr_vllanmto := 13.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344222;
    v_dados(v_dados.last()).vr_nrctremp := 83334;
    v_dados(v_dados.last()).vr_vllanmto := 13.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 515566;
    v_dados(v_dados.last()).vr_nrctremp := 173640;
    v_dados(v_dados.last()).vr_vllanmto := 14.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 28649;
    v_dados(v_dados.last()).vr_nrctremp := 133663;
    v_dados(v_dados.last()).vr_vllanmto := 14.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 127597;
    v_dados(v_dados.last()).vr_vllanmto := 14.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 143435;
    v_dados(v_dados.last()).vr_vllanmto := 14.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361194;
    v_dados(v_dados.last()).vr_nrctremp := 85780;
    v_dados(v_dados.last()).vr_vllanmto := 14.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 64955;
    v_dados(v_dados.last()).vr_nrctremp := 98020;
    v_dados(v_dados.last()).vr_vllanmto := 14.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 181049;
    v_dados(v_dados.last()).vr_vllanmto := 14.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331317;
    v_dados(v_dados.last()).vr_nrctremp := 178836;
    v_dados(v_dados.last()).vr_vllanmto := 14.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452360;
    v_dados(v_dados.last()).vr_nrctremp := 115139;
    v_dados(v_dados.last()).vr_vllanmto := 14.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 116691;
    v_dados(v_dados.last()).vr_vllanmto := 14.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140758;
    v_dados(v_dados.last()).vr_vllanmto := 14.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 111433;
    v_dados(v_dados.last()).vr_vllanmto := 14.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258539;
    v_dados(v_dados.last()).vr_nrctremp := 180651;
    v_dados(v_dados.last()).vr_vllanmto := 14.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107629;
    v_dados(v_dados.last()).vr_vllanmto := 14.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 128010;
    v_dados(v_dados.last()).vr_vllanmto := 14.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10928;
    v_dados(v_dados.last()).vr_nrctremp := 166219;
    v_dados(v_dados.last()).vr_vllanmto := 14.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549991;
    v_dados(v_dados.last()).vr_nrctremp := 117327;
    v_dados(v_dados.last()).vr_vllanmto := 15.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141372;
    v_dados(v_dados.last()).vr_nrctremp := 143891;
    v_dados(v_dados.last()).vr_vllanmto := 15.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 96330;
    v_dados(v_dados.last()).vr_vllanmto := 15.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 101150;
    v_dados(v_dados.last()).vr_vllanmto := 15.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 489824;
    v_dados(v_dados.last()).vr_nrctremp := 159225;
    v_dados(v_dados.last()).vr_vllanmto := 15.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 174998;
    v_dados(v_dados.last()).vr_nrctremp := 113161;
    v_dados(v_dados.last()).vr_vllanmto := 15.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 373567;
    v_dados(v_dados.last()).vr_nrctremp := 135191;
    v_dados(v_dados.last()).vr_vllanmto := 15.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184390;
    v_dados(v_dados.last()).vr_nrctremp := 59839;
    v_dados(v_dados.last()).vr_vllanmto := 15.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503533;
    v_dados(v_dados.last()).vr_nrctremp := 181189;
    v_dados(v_dados.last()).vr_vllanmto := 15.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 160976;
    v_dados(v_dados.last()).vr_vllanmto := 15.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 108448;
    v_dados(v_dados.last()).vr_vllanmto := 15.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 109298;
    v_dados(v_dados.last()).vr_vllanmto := 1058.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368857;
    v_dados(v_dados.last()).vr_nrctremp := 141765;
    v_dados(v_dados.last()).vr_vllanmto := 15.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163716;
    v_dados(v_dados.last()).vr_nrctremp := 177009;
    v_dados(v_dados.last()).vr_vllanmto := 15.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80361;
    v_dados(v_dados.last()).vr_vllanmto := 15.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54519;
    v_dados(v_dados.last()).vr_vllanmto := 15.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219312;
    v_dados(v_dados.last()).vr_nrctremp := 90673;
    v_dados(v_dados.last()).vr_vllanmto := 16.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 105034;
    v_dados(v_dados.last()).vr_vllanmto := 16.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350672;
    v_dados(v_dados.last()).vr_nrctremp := 80334;
    v_dados(v_dados.last()).vr_vllanmto := 16.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 165366;
    v_dados(v_dados.last()).vr_vllanmto := 16.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108561;
    v_dados(v_dados.last()).vr_nrctremp := 172972;
    v_dados(v_dados.last()).vr_vllanmto := 16.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 77444;
    v_dados(v_dados.last()).vr_vllanmto := 16.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 147274;
    v_dados(v_dados.last()).vr_vllanmto := 16.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148103;
    v_dados(v_dados.last()).vr_vllanmto := 16.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 76570;
    v_dados(v_dados.last()).vr_nrctremp := 85654;
    v_dados(v_dados.last()).vr_vllanmto := 16.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191833;
    v_dados(v_dados.last()).vr_nrctremp := 111117;
    v_dados(v_dados.last()).vr_vllanmto := 16.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 7722;
    v_dados(v_dados.last()).vr_nrctremp := 134120;
    v_dados(v_dados.last()).vr_vllanmto := 16.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239011;
    v_dados(v_dados.last()).vr_nrctremp := 96087;
    v_dados(v_dados.last()).vr_vllanmto := 16.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319929;
    v_dados(v_dados.last()).vr_nrctremp := 96594;
    v_dados(v_dados.last()).vr_vllanmto := 16.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151455;
    v_dados(v_dados.last()).vr_vllanmto := 16.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 113424;
    v_dados(v_dados.last()).vr_vllanmto := 16.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 136637;
    v_dados(v_dados.last()).vr_vllanmto := 16.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153141;
    v_dados(v_dados.last()).vr_nrctremp := 57245;
    v_dados(v_dados.last()).vr_vllanmto := 16.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96423;
    v_dados(v_dados.last()).vr_nrctremp := 96511;
    v_dados(v_dados.last()).vr_vllanmto := 16.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207497;
    v_dados(v_dados.last()).vr_nrctremp := 160961;
    v_dados(v_dados.last()).vr_vllanmto := 16.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 84854;
    v_dados(v_dados.last()).vr_vllanmto := 17.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180815;
    v_dados(v_dados.last()).vr_nrctremp := 118016;
    v_dados(v_dados.last()).vr_vllanmto := 17.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135085;
    v_dados(v_dados.last()).vr_vllanmto := 17.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280585;
    v_dados(v_dados.last()).vr_nrctremp := 132320;
    v_dados(v_dados.last()).vr_vllanmto := 17.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319260;
    v_dados(v_dados.last()).vr_nrctremp := 82744;
    v_dados(v_dados.last()).vr_vllanmto := 17.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 76427;
    v_dados(v_dados.last()).vr_vllanmto := 17.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 110402;
    v_dados(v_dados.last()).vr_vllanmto := 17.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 236632;
    v_dados(v_dados.last()).vr_nrctremp := 142523;
    v_dados(v_dados.last()).vr_vllanmto := 17.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227900;
    v_dados(v_dados.last()).vr_nrctremp := 65953;
    v_dados(v_dados.last()).vr_vllanmto := 17.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484326;
    v_dados(v_dados.last()).vr_nrctremp := 79098;
    v_dados(v_dados.last()).vr_vllanmto := 17.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92665;
    v_dados(v_dados.last()).vr_nrctremp := 59179;
    v_dados(v_dados.last()).vr_vllanmto := 17.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 79897;
    v_dados(v_dados.last()).vr_vllanmto := 17.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240389;
    v_dados(v_dados.last()).vr_nrctremp := 147131;
    v_dados(v_dados.last()).vr_vllanmto := 17.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92690;
    v_dados(v_dados.last()).vr_nrctremp := 58634;
    v_dados(v_dados.last()).vr_vllanmto := 17.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318728;
    v_dados(v_dados.last()).vr_nrctremp := 52932;
    v_dados(v_dados.last()).vr_vllanmto := 17.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 112941;
    v_dados(v_dados.last()).vr_nrctremp := 112912;
    v_dados(v_dados.last()).vr_vllanmto := 17.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 166641;
    v_dados(v_dados.last()).vr_vllanmto := 17.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445347;
    v_dados(v_dados.last()).vr_nrctremp := 68188;
    v_dados(v_dados.last()).vr_vllanmto := 17.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42056;
    v_dados(v_dados.last()).vr_nrctremp := 129502;
    v_dados(v_dados.last()).vr_vllanmto := 18.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80080;
    v_dados(v_dados.last()).vr_nrctremp := 173704;
    v_dados(v_dados.last()).vr_vllanmto := 18.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 139562;
    v_dados(v_dados.last()).vr_vllanmto := 555.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 95415;
    v_dados(v_dados.last()).vr_vllanmto := 18.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350672;
    v_dados(v_dados.last()).vr_nrctremp := 50375;
    v_dados(v_dados.last()).vr_vllanmto := 18.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 244953;
    v_dados(v_dados.last()).vr_nrctremp := 163634;
    v_dados(v_dados.last()).vr_vllanmto := 18.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 320935;
    v_dados(v_dados.last()).vr_nrctremp := 172922;
    v_dados(v_dados.last()).vr_vllanmto := 18.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163767;
    v_dados(v_dados.last()).vr_nrctremp := 87851;
    v_dados(v_dados.last()).vr_vllanmto := 18.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 546780;
    v_dados(v_dados.last()).vr_nrctremp := 105989;
    v_dados(v_dados.last()).vr_vllanmto := 18.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 639168;
    v_dados(v_dados.last()).vr_nrctremp := 171074;
    v_dados(v_dados.last()).vr_vllanmto := 18.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 168225;
    v_dados(v_dados.last()).vr_vllanmto := 18.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112749;
    v_dados(v_dados.last()).vr_vllanmto := 18.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 176605;
    v_dados(v_dados.last()).vr_nrctremp := 54432;
    v_dados(v_dados.last()).vr_vllanmto := 18.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 167151;
    v_dados(v_dados.last()).vr_vllanmto := 18.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 124874;
    v_dados(v_dados.last()).vr_vllanmto := 18.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66427;
    v_dados(v_dados.last()).vr_nrctremp := 153753;
    v_dados(v_dados.last()).vr_vllanmto := 18.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100161;
    v_dados(v_dados.last()).vr_nrctremp := 56312;
    v_dados(v_dados.last()).vr_vllanmto := 18.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 117048;
    v_dados(v_dados.last()).vr_nrctremp := 164922;
    v_dados(v_dados.last()).vr_vllanmto := 18.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 113015;
    v_dados(v_dados.last()).vr_vllanmto := 18.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 138713;
    v_dados(v_dados.last()).vr_vllanmto := 18.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 226327;
    v_dados(v_dados.last()).vr_nrctremp := 172961;
    v_dados(v_dados.last()).vr_vllanmto := 18.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287296;
    v_dados(v_dados.last()).vr_nrctremp := 180065;
    v_dados(v_dados.last()).vr_vllanmto := 18.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215937;
    v_dados(v_dados.last()).vr_nrctremp := 116906;
    v_dados(v_dados.last()).vr_vllanmto := 18.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62065;
    v_dados(v_dados.last()).vr_vllanmto := 18.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484067;
    v_dados(v_dados.last()).vr_nrctremp := 181993;
    v_dados(v_dados.last()).vr_vllanmto := 18.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129574;
    v_dados(v_dados.last()).vr_vllanmto := 19.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 133375;
    v_dados(v_dados.last()).vr_vllanmto := 19.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188344;
    v_dados(v_dados.last()).vr_nrctremp := 82654;
    v_dados(v_dados.last()).vr_vllanmto := 19.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184470;
    v_dados(v_dados.last()).vr_nrctremp := 175964;
    v_dados(v_dados.last()).vr_vllanmto := 19.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156022;
    v_dados(v_dados.last()).vr_vllanmto := 19.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188336;
    v_dados(v_dados.last()).vr_nrctremp := 90899;
    v_dados(v_dados.last()).vr_vllanmto := 19.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142387;
    v_dados(v_dados.last()).vr_nrctremp := 180576;
    v_dados(v_dados.last()).vr_vllanmto := 19.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148318;
    v_dados(v_dados.last()).vr_nrctremp := 107844;
    v_dados(v_dados.last()).vr_vllanmto := 19.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 101693;
    v_dados(v_dados.last()).vr_vllanmto := 19.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 167789;
    v_dados(v_dados.last()).vr_vllanmto := 19.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549991;
    v_dados(v_dados.last()).vr_nrctremp := 108446;
    v_dados(v_dados.last()).vr_vllanmto := 19.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 157416;
    v_dados(v_dados.last()).vr_vllanmto := 19.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 57797;
    v_dados(v_dados.last()).vr_nrctremp := 122310;
    v_dados(v_dados.last()).vr_vllanmto := 19.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91359;
    v_dados(v_dados.last()).vr_nrctremp := 97584;
    v_dados(v_dados.last()).vr_vllanmto := 19.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 124814;
    v_dados(v_dados.last()).vr_vllanmto := 19.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183334;
    v_dados(v_dados.last()).vr_nrctremp := 172593;
    v_dados(v_dados.last()).vr_vllanmto := 19.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131382;
    v_dados(v_dados.last()).vr_vllanmto := 19.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 132287;
    v_dados(v_dados.last()).vr_vllanmto := 19.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614610;
    v_dados(v_dados.last()).vr_nrctremp := 136420;
    v_dados(v_dados.last()).vr_vllanmto := 19.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258636;
    v_dados(v_dados.last()).vr_nrctremp := 165420;
    v_dados(v_dados.last()).vr_vllanmto := 19.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169277;
    v_dados(v_dados.last()).vr_nrctremp := 82388;
    v_dados(v_dados.last()).vr_vllanmto := 19.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 683655;
    v_dados(v_dados.last()).vr_nrctremp := 177942;
    v_dados(v_dados.last()).vr_vllanmto := 19.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 132748;
    v_dados(v_dados.last()).vr_vllanmto := 20.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186511;
    v_dados(v_dados.last()).vr_nrctremp := 90119;
    v_dados(v_dados.last()).vr_vllanmto := 20.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170879;
    v_dados(v_dados.last()).vr_nrctremp := 51225;
    v_dados(v_dados.last()).vr_vllanmto := 20.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325538;
    v_dados(v_dados.last()).vr_nrctremp := 181051;
    v_dados(v_dados.last()).vr_vllanmto := 20.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 61230;
    v_dados(v_dados.last()).vr_vllanmto := 20.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290246;
    v_dados(v_dados.last()).vr_nrctremp := 96871;
    v_dados(v_dados.last()).vr_vllanmto := 20.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328014;
    v_dados(v_dados.last()).vr_nrctremp := 111588;
    v_dados(v_dados.last()).vr_vllanmto := 20.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 74878;
    v_dados(v_dados.last()).vr_vllanmto := 20.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 99961;
    v_dados(v_dados.last()).vr_vllanmto := 20.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 590126;
    v_dados(v_dados.last()).vr_nrctremp := 179585;
    v_dados(v_dados.last()).vr_vllanmto := 20.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 172784;
    v_dados(v_dados.last()).vr_vllanmto := 20.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 154072;
    v_dados(v_dados.last()).vr_vllanmto := 21.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193577;
    v_dados(v_dados.last()).vr_nrctremp := 70791;
    v_dados(v_dados.last()).vr_vllanmto := 21.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186244;
    v_dados(v_dados.last()).vr_nrctremp := 58233;
    v_dados(v_dados.last()).vr_vllanmto := 21.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 75381;
    v_dados(v_dados.last()).vr_vllanmto := 21.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66532;
    v_dados(v_dados.last()).vr_nrctremp := 103293;
    v_dados(v_dados.last()).vr_vllanmto := 21.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190047;
    v_dados(v_dados.last()).vr_nrctremp := 158758;
    v_dados(v_dados.last()).vr_vllanmto := 21.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424218;
    v_dados(v_dados.last()).vr_nrctremp := 103005;
    v_dados(v_dados.last()).vr_vllanmto := 21.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 472611;
    v_dados(v_dados.last()).vr_nrctremp := 74772;
    v_dados(v_dados.last()).vr_vllanmto := 21.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 390402;
    v_dados(v_dados.last()).vr_nrctremp := 166820;
    v_dados(v_dados.last()).vr_vllanmto := 21.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 121304;
    v_dados(v_dados.last()).vr_nrctremp := 99096;
    v_dados(v_dados.last()).vr_vllanmto := 21.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541311;
    v_dados(v_dados.last()).vr_nrctremp := 179454;
    v_dados(v_dados.last()).vr_vllanmto := 21.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 151600;
    v_dados(v_dados.last()).vr_vllanmto := 21.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143898;
    v_dados(v_dados.last()).vr_vllanmto := 21.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 369845;
    v_dados(v_dados.last()).vr_nrctremp := 179448;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137855;
    v_dados(v_dados.last()).vr_nrctremp := 51945;
    v_dados(v_dados.last()).vr_vllanmto := 21.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 128007;
    v_dados(v_dados.last()).vr_vllanmto := 21.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149931;
    v_dados(v_dados.last()).vr_vllanmto := 21.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 80719;
    v_dados(v_dados.last()).vr_vllanmto := 21.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 123544;
    v_dados(v_dados.last()).vr_nrctremp := 51374;
    v_dados(v_dados.last()).vr_vllanmto := 21.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83095;
    v_dados(v_dados.last()).vr_vllanmto := 21.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175609;
    v_dados(v_dados.last()).vr_nrctremp := 51504;
    v_dados(v_dados.last()).vr_vllanmto := 21.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 62992;
    v_dados(v_dados.last()).vr_vllanmto := 22.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315788;
    v_dados(v_dados.last()).vr_nrctremp := 170807;
    v_dados(v_dados.last()).vr_vllanmto := 22.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329932;
    v_dados(v_dados.last()).vr_nrctremp := 74940;
    v_dados(v_dados.last()).vr_vllanmto := 22.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124982;
    v_dados(v_dados.last()).vr_nrctremp := 71546;
    v_dados(v_dados.last()).vr_vllanmto := 22.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 151553;
    v_dados(v_dados.last()).vr_vllanmto := 22.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 178572;
    v_dados(v_dados.last()).vr_vllanmto := 22.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 343196;
    v_dados(v_dados.last()).vr_nrctremp := 132444;
    v_dados(v_dados.last()).vr_vllanmto := 22.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170453;
    v_dados(v_dados.last()).vr_nrctremp := 59887;
    v_dados(v_dados.last()).vr_vllanmto := 22.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 568350;
    v_dados(v_dados.last()).vr_nrctremp := 153429;
    v_dados(v_dados.last()).vr_vllanmto := 22.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280836;
    v_dados(v_dados.last()).vr_nrctremp := 144049;
    v_dados(v_dados.last()).vr_vllanmto := 22.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 181735;
    v_dados(v_dados.last()).vr_vllanmto := 22.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 112834;
    v_dados(v_dados.last()).vr_vllanmto := 22.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186244;
    v_dados(v_dados.last()).vr_nrctremp := 136437;
    v_dados(v_dados.last()).vr_vllanmto := 23.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274321;
    v_dados(v_dados.last()).vr_nrctremp := 167857;
    v_dados(v_dados.last()).vr_vllanmto := 23.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279714;
    v_dados(v_dados.last()).vr_nrctremp := 60093;
    v_dados(v_dados.last()).vr_vllanmto := 23.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87963;
    v_dados(v_dados.last()).vr_nrctremp := 64353;
    v_dados(v_dados.last()).vr_vllanmto := 23.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172855;
    v_dados(v_dados.last()).vr_nrctremp := 76273;
    v_dados(v_dados.last()).vr_vllanmto := 23.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216909;
    v_dados(v_dados.last()).vr_nrctremp := 133869;
    v_dados(v_dados.last()).vr_vllanmto := 23.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273821;
    v_dados(v_dados.last()).vr_nrctremp := 81164;
    v_dados(v_dados.last()).vr_vllanmto := 23.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 122595;
    v_dados(v_dados.last()).vr_vllanmto := 23.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647616;
    v_dados(v_dados.last()).vr_nrctremp := 159935;
    v_dados(v_dados.last()).vr_vllanmto := 23.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144843;
    v_dados(v_dados.last()).vr_nrctremp := 179507;
    v_dados(v_dados.last()).vr_vllanmto := 23.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 106036;
    v_dados(v_dados.last()).vr_vllanmto := 23.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191434;
    v_dados(v_dados.last()).vr_nrctremp := 164271;
    v_dados(v_dados.last()).vr_vllanmto := 23.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 437832;
    v_dados(v_dados.last()).vr_nrctremp := 177937;
    v_dados(v_dados.last()).vr_vllanmto := 23.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275298;
    v_dados(v_dados.last()).vr_nrctremp := 135529;
    v_dados(v_dados.last()).vr_vllanmto := 24.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 62996;
    v_dados(v_dados.last()).vr_vllanmto := 24.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187020;
    v_dados(v_dados.last()).vr_nrctremp := 137318;
    v_dados(v_dados.last()).vr_vllanmto := 24.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 150316;
    v_dados(v_dados.last()).vr_vllanmto := 24.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107743;
    v_dados(v_dados.last()).vr_vllanmto := 24.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368857;
    v_dados(v_dados.last()).vr_nrctremp := 58093;
    v_dados(v_dados.last()).vr_vllanmto := 24.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 117419;
    v_dados(v_dados.last()).vr_vllanmto := 24.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128314;
    v_dados(v_dados.last()).vr_vllanmto := 24.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 75913;
    v_dados(v_dados.last()).vr_vllanmto := 24.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150657;
    v_dados(v_dados.last()).vr_nrctremp := 99262;
    v_dados(v_dados.last()).vr_vllanmto := 24.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 224162;
    v_dados(v_dados.last()).vr_nrctremp := 116605;
    v_dados(v_dados.last()).vr_vllanmto := 24.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146397;
    v_dados(v_dados.last()).vr_vllanmto := 24.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279714;
    v_dados(v_dados.last()).vr_nrctremp := 118764;
    v_dados(v_dados.last()).vr_vllanmto := 24.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175455;
    v_dados(v_dados.last()).vr_nrctremp := 121287;
    v_dados(v_dados.last()).vr_vllanmto := 24.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 153126;
    v_dados(v_dados.last()).vr_vllanmto := 24.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166480;
    v_dados(v_dados.last()).vr_nrctremp := 63527;
    v_dados(v_dados.last()).vr_vllanmto := 24.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247618;
    v_dados(v_dados.last()).vr_nrctremp := 98519;
    v_dados(v_dados.last()).vr_vllanmto := 24.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 83082;
    v_dados(v_dados.last()).vr_vllanmto := 24.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 384461;
    v_dados(v_dados.last()).vr_nrctremp := 51220;
    v_dados(v_dados.last()).vr_vllanmto := 24.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144096;
    v_dados(v_dados.last()).vr_nrctremp := 111301;
    v_dados(v_dados.last()).vr_vllanmto := 24.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 128092;
    v_dados(v_dados.last()).vr_vllanmto := 25.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 147396;
    v_dados(v_dados.last()).vr_vllanmto := 25.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137032;
    v_dados(v_dados.last()).vr_vllanmto := 25.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 55878;
    v_dados(v_dados.last()).vr_vllanmto := 25.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 55907;
    v_dados(v_dados.last()).vr_vllanmto := 25.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135081;
    v_dados(v_dados.last()).vr_vllanmto := 25.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131371;
    v_dados(v_dados.last()).vr_vllanmto := 25.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158305;
    v_dados(v_dados.last()).vr_nrctremp := 57412;
    v_dados(v_dados.last()).vr_vllanmto := 25.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419206;
    v_dados(v_dados.last()).vr_nrctremp := 85355;
    v_dados(v_dados.last()).vr_vllanmto := 25.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 163884;
    v_dados(v_dados.last()).vr_vllanmto := 25.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214256;
    v_dados(v_dados.last()).vr_nrctremp := 180558;
    v_dados(v_dados.last()).vr_vllanmto := 25.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144843;
    v_dados(v_dados.last()).vr_nrctremp := 56356;
    v_dados(v_dados.last()).vr_vllanmto := 25.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175633;
    v_dados(v_dados.last()).vr_nrctremp := 104048;
    v_dados(v_dados.last()).vr_vllanmto := 25.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192546;
    v_dados(v_dados.last()).vr_nrctremp := 169910;
    v_dados(v_dados.last()).vr_vllanmto := 25.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 112049;
    v_dados(v_dados.last()).vr_vllanmto := 25.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163830;
    v_dados(v_dados.last()).vr_nrctremp := 181382;
    v_dados(v_dados.last()).vr_vllanmto := 26.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106405;
    v_dados(v_dados.last()).vr_vllanmto := 26.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268240;
    v_dados(v_dados.last()).vr_nrctremp := 139413;
    v_dados(v_dados.last()).vr_vllanmto := 26.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 119334;
    v_dados(v_dados.last()).vr_vllanmto := 26.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22560;
    v_dados(v_dados.last()).vr_nrctremp := 84128;
    v_dados(v_dados.last()).vr_vllanmto := 26.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 607916;
    v_dados(v_dados.last()).vr_nrctremp := 134133;
    v_dados(v_dados.last()).vr_vllanmto := 26.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 182237;
    v_dados(v_dados.last()).vr_vllanmto := 26.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 122251;
    v_dados(v_dados.last()).vr_vllanmto := 26.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 159595;
    v_dados(v_dados.last()).vr_vllanmto := 26.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170119;
    v_dados(v_dados.last()).vr_nrctremp := 119673;
    v_dados(v_dados.last()).vr_vllanmto := 26.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 359238;
    v_dados(v_dados.last()).vr_nrctremp := 175854;
    v_dados(v_dados.last()).vr_vllanmto := 26.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184470;
    v_dados(v_dados.last()).vr_nrctremp := 81390;
    v_dados(v_dados.last()).vr_vllanmto := 26.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 91932;
    v_dados(v_dados.last()).vr_vllanmto := 26.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 157608;
    v_dados(v_dados.last()).vr_vllanmto := 26.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264105;
    v_dados(v_dados.last()).vr_nrctremp := 89948;
    v_dados(v_dados.last()).vr_vllanmto := 26.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 161178;
    v_dados(v_dados.last()).vr_vllanmto := 26.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 87115;
    v_dados(v_dados.last()).vr_vllanmto := 27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 106540;
    v_dados(v_dados.last()).vr_vllanmto := 20.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91531;
    v_dados(v_dados.last()).vr_vllanmto := 27.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 84402;
    v_dados(v_dados.last()).vr_vllanmto := 27.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 244937;
    v_dados(v_dados.last()).vr_nrctremp := 106384;
    v_dados(v_dados.last()).vr_vllanmto := 27.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83772;
    v_dados(v_dados.last()).vr_vllanmto := 27.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316237;
    v_dados(v_dados.last()).vr_nrctremp := 77074;
    v_dados(v_dados.last()).vr_vllanmto := 27.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 430374;
    v_dados(v_dados.last()).vr_nrctremp := 105597;
    v_dados(v_dados.last()).vr_vllanmto := 26.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54514;
    v_dados(v_dados.last()).vr_vllanmto := 27.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 117422;
    v_dados(v_dados.last()).vr_vllanmto := 27.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 103276;
    v_dados(v_dados.last()).vr_vllanmto := 27.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145742;
    v_dados(v_dados.last()).vr_nrctremp := 162708;
    v_dados(v_dados.last()).vr_vllanmto := 27.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131172;
    v_dados(v_dados.last()).vr_nrctremp := 115379;
    v_dados(v_dados.last()).vr_vllanmto := 28.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149764;
    v_dados(v_dados.last()).vr_nrctremp := 73063;
    v_dados(v_dados.last()).vr_vllanmto := 28.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242985;
    v_dados(v_dados.last()).vr_nrctremp := 132628;
    v_dados(v_dados.last()).vr_vllanmto := 28.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141760;
    v_dados(v_dados.last()).vr_vllanmto := 28.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 112397;
    v_dados(v_dados.last()).vr_vllanmto := 28.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 130201;
    v_dados(v_dados.last()).vr_vllanmto := 28.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 142392;
    v_dados(v_dados.last()).vr_vllanmto := 28.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 87679;
    v_dados(v_dados.last()).vr_vllanmto := 28.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188123;
    v_dados(v_dados.last()).vr_nrctremp := 102857;
    v_dados(v_dados.last()).vr_vllanmto := 28.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93564;
    v_dados(v_dados.last()).vr_nrctremp := 91623;
    v_dados(v_dados.last()).vr_vllanmto := 28.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66699;
    v_dados(v_dados.last()).vr_nrctremp := 158790;
    v_dados(v_dados.last()).vr_vllanmto := 28.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 148826;
    v_dados(v_dados.last()).vr_vllanmto := 28.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 29.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91480;
    v_dados(v_dados.last()).vr_nrctremp := 143547;
    v_dados(v_dados.last()).vr_vllanmto := 29.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 154805;
    v_dados(v_dados.last()).vr_vllanmto := 29.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 63749;
    v_dados(v_dados.last()).vr_vllanmto := 29.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 105102;
    v_dados(v_dados.last()).vr_vllanmto := 29.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78107;
    v_dados(v_dados.last()).vr_nrctremp := 87139;
    v_dados(v_dados.last()).vr_vllanmto := 29.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286540;
    v_dados(v_dados.last()).vr_nrctremp := 181564;
    v_dados(v_dados.last()).vr_vllanmto := 29.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199770;
    v_dados(v_dados.last()).vr_nrctremp := 176779;
    v_dados(v_dados.last()).vr_vllanmto := 29.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 182764;
    v_dados(v_dados.last()).vr_vllanmto := 29.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199974;
    v_dados(v_dados.last()).vr_nrctremp := 180108;
    v_dados(v_dados.last()).vr_vllanmto := 5138.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128445;
    v_dados(v_dados.last()).vr_vllanmto := 29.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 400599;
    v_dados(v_dados.last()).vr_nrctremp := 73411;
    v_dados(v_dados.last()).vr_vllanmto := 29.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292060;
    v_dados(v_dados.last()).vr_nrctremp := 133164;
    v_dados(v_dados.last()).vr_vllanmto := 29.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 222348;
    v_dados(v_dados.last()).vr_nrctremp := 84303;
    v_dados(v_dados.last()).vr_vllanmto := 29.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 311863;
    v_dados(v_dados.last()).vr_nrctremp := 135708;
    v_dados(v_dados.last()).vr_vllanmto := 29.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 177334;
    v_dados(v_dados.last()).vr_vllanmto := 29.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 30.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 135397;
    v_dados(v_dados.last()).vr_vllanmto := 30.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 84202;
    v_dados(v_dados.last()).vr_vllanmto := 30.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 123312;
    v_dados(v_dados.last()).vr_vllanmto := 30.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 138280;
    v_dados(v_dados.last()).vr_vllanmto := 30.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425770;
    v_dados(v_dados.last()).vr_nrctremp := 57128;
    v_dados(v_dados.last()).vr_vllanmto := 30.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110736;
    v_dados(v_dados.last()).vr_vllanmto := 30.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 505587;
    v_dados(v_dados.last()).vr_nrctremp := 179776;
    v_dados(v_dados.last()).vr_vllanmto := 30.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219428;
    v_dados(v_dados.last()).vr_nrctremp := 108998;
    v_dados(v_dados.last()).vr_vllanmto := 30.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92487;
    v_dados(v_dados.last()).vr_nrctremp := 140770;
    v_dados(v_dados.last()).vr_vllanmto := 30.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673480;
    v_dados(v_dados.last()).vr_nrctremp := 166905;
    v_dados(v_dados.last()).vr_vllanmto := 31.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263125;
    v_dados(v_dados.last()).vr_nrctremp := 181387;
    v_dados(v_dados.last()).vr_vllanmto := 31.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298980;
    v_dados(v_dados.last()).vr_nrctremp := 155781;
    v_dados(v_dados.last()).vr_vllanmto := 31.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 399922;
    v_dados(v_dados.last()).vr_nrctremp := 55401;
    v_dados(v_dados.last()).vr_vllanmto := 31.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264768;
    v_dados(v_dados.last()).vr_nrctremp := 72541;
    v_dados(v_dados.last()).vr_vllanmto := 31.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 76848;
    v_dados(v_dados.last()).vr_vllanmto := 31.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277568;
    v_dados(v_dados.last()).vr_nrctremp := 71879;
    v_dados(v_dados.last()).vr_vllanmto := 31.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124282;
    v_dados(v_dados.last()).vr_vllanmto := 31.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 81658;
    v_dados(v_dados.last()).vr_vllanmto := 32.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145980;
    v_dados(v_dados.last()).vr_vllanmto := 32.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105295;
    v_dados(v_dados.last()).vr_nrctremp := 109809;
    v_dados(v_dados.last()).vr_vllanmto := 32.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288624;
    v_dados(v_dados.last()).vr_nrctremp := 147269;
    v_dados(v_dados.last()).vr_vllanmto := 29.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185876;
    v_dados(v_dados.last()).vr_nrctremp := 147388;
    v_dados(v_dados.last()).vr_vllanmto := 32.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 116694;
    v_dados(v_dados.last()).vr_vllanmto := 32.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129899;
    v_dados(v_dados.last()).vr_vllanmto := 32.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146625;
    v_dados(v_dados.last()).vr_nrctremp := 96582;
    v_dados(v_dados.last()).vr_vllanmto := 32.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 469661;
    v_dados(v_dados.last()).vr_nrctremp := 135698;
    v_dados(v_dados.last()).vr_vllanmto := 32.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351830;
    v_dados(v_dados.last()).vr_nrctremp := 56500;
    v_dados(v_dados.last()).vr_vllanmto := 33.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247170;
    v_dados(v_dados.last()).vr_nrctremp := 136469;
    v_dados(v_dados.last()).vr_vllanmto := 33.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139845;
    v_dados(v_dados.last()).vr_vllanmto := 33.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 111086;
    v_dados(v_dados.last()).vr_vllanmto := 33.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328014;
    v_dados(v_dados.last()).vr_nrctremp := 100186;
    v_dados(v_dados.last()).vr_vllanmto := 33.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42056;
    v_dados(v_dados.last()).vr_nrctremp := 129501;
    v_dados(v_dados.last()).vr_vllanmto := 33.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 57983;
    v_dados(v_dados.last()).vr_vllanmto := 480.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 117990;
    v_dados(v_dados.last()).vr_vllanmto := 33.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112687;
    v_dados(v_dados.last()).vr_vllanmto := 33.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 78237;
    v_dados(v_dados.last()).vr_vllanmto := 33.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 149104;
    v_dados(v_dados.last()).vr_vllanmto := 33.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218294;
    v_dados(v_dados.last()).vr_nrctremp := 64242;
    v_dados(v_dados.last()).vr_vllanmto := 33.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 101565;
    v_dados(v_dados.last()).vr_vllanmto := 34.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464910;
    v_dados(v_dados.last()).vr_nrctremp := 164242;
    v_dados(v_dados.last()).vr_vllanmto := 34.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144045;
    v_dados(v_dados.last()).vr_nrctremp := 158391;
    v_dados(v_dados.last()).vr_vllanmto := 34.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483923;
    v_dados(v_dados.last()).vr_nrctremp := 92602;
    v_dados(v_dados.last()).vr_vllanmto := 34.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150657;
    v_dados(v_dados.last()).vr_nrctremp := 99264;
    v_dados(v_dados.last()).vr_vllanmto := 34.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 104221;
    v_dados(v_dados.last()).vr_nrctremp := 133190;
    v_dados(v_dados.last()).vr_vllanmto := 34.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140600;
    v_dados(v_dados.last()).vr_nrctremp := 113764;
    v_dados(v_dados.last()).vr_vllanmto := 34.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 155016;
    v_dados(v_dados.last()).vr_vllanmto := 34.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115868;
    v_dados(v_dados.last()).vr_vllanmto := 34.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107626;
    v_dados(v_dados.last()).vr_vllanmto := 34.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 70702;
    v_dados(v_dados.last()).vr_vllanmto := 35.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 8141;
    v_dados(v_dados.last()).vr_nrctremp := 134605;
    v_dados(v_dados.last()).vr_vllanmto := 28.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 164635;
    v_dados(v_dados.last()).vr_vllanmto := 35.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268135;
    v_dados(v_dados.last()).vr_nrctremp := 70210;
    v_dados(v_dados.last()).vr_vllanmto := 35.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624470;
    v_dados(v_dados.last()).vr_nrctremp := 140410;
    v_dados(v_dados.last()).vr_vllanmto := 35.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 77895;
    v_dados(v_dados.last()).vr_nrctremp := 75192;
    v_dados(v_dados.last()).vr_vllanmto := 35.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360961;
    v_dados(v_dados.last()).vr_nrctremp := 151569;
    v_dados(v_dados.last()).vr_vllanmto := 35.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144118;
    v_dados(v_dados.last()).vr_nrctremp := 131588;
    v_dados(v_dados.last()).vr_vllanmto := 35.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323519;
    v_dados(v_dados.last()).vr_nrctremp := 73280;
    v_dados(v_dados.last()).vr_vllanmto := 35.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142353;
    v_dados(v_dados.last()).vr_vllanmto := 35.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 118012;
    v_dados(v_dados.last()).vr_vllanmto := 36.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145190;
    v_dados(v_dados.last()).vr_nrctremp := 138246;
    v_dados(v_dados.last()).vr_vllanmto := 36.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 151838;
    v_dados(v_dados.last()).vr_vllanmto := 36.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467367;
    v_dados(v_dados.last()).vr_nrctremp := 149121;
    v_dados(v_dados.last()).vr_vllanmto := 36.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190047;
    v_dados(v_dados.last()).vr_nrctremp := 158762;
    v_dados(v_dados.last()).vr_vllanmto := 36.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 134311;
    v_dados(v_dados.last()).vr_vllanmto := 36.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149469;
    v_dados(v_dados.last()).vr_vllanmto := 36.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167924;
    v_dados(v_dados.last()).vr_nrctremp := 175204;
    v_dados(v_dados.last()).vr_vllanmto := 36.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483320;
    v_dados(v_dados.last()).vr_nrctremp := 78389;
    v_dados(v_dados.last()).vr_vllanmto := 36.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156029;
    v_dados(v_dados.last()).vr_vllanmto := 36.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 607533;
    v_dados(v_dados.last()).vr_nrctremp := 133553;
    v_dados(v_dados.last()).vr_vllanmto := 36.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135810;
    v_dados(v_dados.last()).vr_nrctremp := 133666;
    v_dados(v_dados.last()).vr_vllanmto := 37.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 413607;
    v_dados(v_dados.last()).vr_nrctremp := 163237;
    v_dados(v_dados.last()).vr_vllanmto := 37.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146013;
    v_dados(v_dados.last()).vr_nrctremp := 88685;
    v_dados(v_dados.last()).vr_vllanmto := 37.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159212;
    v_dados(v_dados.last()).vr_nrctremp := 99937;
    v_dados(v_dados.last()).vr_vllanmto := 37.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92240;
    v_dados(v_dados.last()).vr_nrctremp := 131646;
    v_dados(v_dados.last()).vr_vllanmto := 37.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179752;
    v_dados(v_dados.last()).vr_nrctremp := 157779;
    v_dados(v_dados.last()).vr_vllanmto := 37.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237396;
    v_dados(v_dados.last()).vr_nrctremp := 147484;
    v_dados(v_dados.last()).vr_vllanmto := 37.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 96421;
    v_dados(v_dados.last()).vr_vllanmto := 37.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 145861;
    v_dados(v_dados.last()).vr_vllanmto := 38.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278742;
    v_dados(v_dados.last()).vr_nrctremp := 83075;
    v_dados(v_dados.last()).vr_vllanmto := 38.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329169;
    v_dados(v_dados.last()).vr_nrctremp := 51807;
    v_dados(v_dados.last()).vr_vllanmto := 38.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 82142;
    v_dados(v_dados.last()).vr_vllanmto := 38.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367885;
    v_dados(v_dados.last()).vr_nrctremp := 101325;
    v_dados(v_dados.last()).vr_vllanmto := 38.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199788;
    v_dados(v_dados.last()).vr_nrctremp := 164878;
    v_dados(v_dados.last()).vr_vllanmto := 39.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 104655;
    v_dados(v_dados.last()).vr_vllanmto := 39.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 123120;
    v_dados(v_dados.last()).vr_vllanmto := 39.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371700;
    v_dados(v_dados.last()).vr_nrctremp := 94933;
    v_dados(v_dados.last()).vr_vllanmto := 39.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110590;
    v_dados(v_dados.last()).vr_vllanmto := 39.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298875;
    v_dados(v_dados.last()).vr_nrctremp := 58507;
    v_dados(v_dados.last()).vr_vllanmto := 39.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 144508;
    v_dados(v_dados.last()).vr_vllanmto := 39.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 552860;
    v_dados(v_dados.last()).vr_nrctremp := 175145;
    v_dados(v_dados.last()).vr_vllanmto := 39.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156540;
    v_dados(v_dados.last()).vr_nrctremp := 120078;
    v_dados(v_dados.last()).vr_vllanmto := 40.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141054;
    v_dados(v_dados.last()).vr_nrctremp := 114747;
    v_dados(v_dados.last()).vr_vllanmto := 40.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 416665;
    v_dados(v_dados.last()).vr_nrctremp := 55346;
    v_dados(v_dados.last()).vr_vllanmto := 40.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 66402;
    v_dados(v_dados.last()).vr_vllanmto := 40.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112689;
    v_dados(v_dados.last()).vr_vllanmto := 40.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 570001;
    v_dados(v_dados.last()).vr_nrctremp := 136709;
    v_dados(v_dados.last()).vr_vllanmto := 40.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298123;
    v_dados(v_dados.last()).vr_nrctremp := 158837;
    v_dados(v_dados.last()).vr_vllanmto := 40.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179752;
    v_dados(v_dados.last()).vr_nrctremp := 151796;
    v_dados(v_dados.last()).vr_vllanmto := 40.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 112938;
    v_dados(v_dados.last()).vr_vllanmto := 40.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 129804;
    v_dados(v_dados.last()).vr_vllanmto := 40.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 605190;
    v_dados(v_dados.last()).vr_nrctremp := 132874;
    v_dados(v_dados.last()).vr_vllanmto := 40.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445347;
    v_dados(v_dados.last()).vr_nrctremp := 63834;
    v_dados(v_dados.last()).vr_vllanmto := 40.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387657;
    v_dados(v_dados.last()).vr_nrctremp := 119327;
    v_dados(v_dados.last()).vr_vllanmto := 40.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80608;
    v_dados(v_dados.last()).vr_nrctremp := 61297;
    v_dados(v_dados.last()).vr_vllanmto := 40.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 92218;
    v_dados(v_dados.last()).vr_vllanmto := 40.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 492817;
    v_dados(v_dados.last()).vr_nrctremp := 82433;
    v_dados(v_dados.last()).vr_vllanmto := 41.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189154;
    v_dados(v_dados.last()).vr_nrctremp := 92177;
    v_dados(v_dados.last()).vr_vllanmto := 41.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 170255;
    v_dados(v_dados.last()).vr_vllanmto := 41.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267716;
    v_dados(v_dados.last()).vr_nrctremp := 180089;
    v_dados(v_dados.last()).vr_vllanmto := 41.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 135746;
    v_dados(v_dados.last()).vr_vllanmto := 41.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 444499;
    v_dados(v_dados.last()).vr_nrctremp := 90846;
    v_dados(v_dados.last()).vr_vllanmto := 41.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 137039;
    v_dados(v_dados.last()).vr_vllanmto := 41.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287296;
    v_dados(v_dados.last()).vr_nrctremp := 161269;
    v_dados(v_dados.last()).vr_vllanmto := 41.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13498;
    v_dados(v_dados.last()).vr_nrctremp := 64928;
    v_dados(v_dados.last()).vr_vllanmto := 41.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240540;
    v_dados(v_dados.last()).vr_nrctremp := 95357;
    v_dados(v_dados.last()).vr_vllanmto := 41.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 63814;
    v_dados(v_dados.last()).vr_vllanmto := 41.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 73958;
    v_dados(v_dados.last()).vr_vllanmto := 41.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252212;
    v_dados(v_dados.last()).vr_nrctremp := 140398;
    v_dados(v_dados.last()).vr_vllanmto := 41.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321907;
    v_dados(v_dados.last()).vr_nrctremp := 162583;
    v_dados(v_dados.last()).vr_vllanmto := 42.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 490695;
    v_dados(v_dados.last()).vr_nrctremp := 179989;
    v_dados(v_dados.last()).vr_vllanmto := 42.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140765;
    v_dados(v_dados.last()).vr_vllanmto := 42.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 169989;
    v_dados(v_dados.last()).vr_vllanmto := 42.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 142634;
    v_dados(v_dados.last()).vr_vllanmto := 42.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129410;
    v_dados(v_dados.last()).vr_nrctremp := 158870;
    v_dados(v_dados.last()).vr_vllanmto := 42.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129089;
    v_dados(v_dados.last()).vr_vllanmto := 42.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94900;
    v_dados(v_dados.last()).vr_vllanmto := 43.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149465;
    v_dados(v_dados.last()).vr_vllanmto := 43.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278157;
    v_dados(v_dados.last()).vr_nrctremp := 168697;
    v_dados(v_dados.last()).vr_vllanmto := 43.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316237;
    v_dados(v_dados.last()).vr_nrctremp := 76421;
    v_dados(v_dados.last()).vr_vllanmto := 43.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 76694;
    v_dados(v_dados.last()).vr_vllanmto := 43.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116050;
    v_dados(v_dados.last()).vr_nrctremp := 79995;
    v_dados(v_dados.last()).vr_vllanmto := 43.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 138828;
    v_dados(v_dados.last()).vr_vllanmto := 43.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188310;
    v_dados(v_dados.last()).vr_nrctremp := 59272;
    v_dados(v_dados.last()).vr_vllanmto := 43.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140902;
    v_dados(v_dados.last()).vr_nrctremp := 59646;
    v_dados(v_dados.last()).vr_vllanmto := 43.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 85063;
    v_dados(v_dados.last()).vr_vllanmto := 43.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293695;
    v_dados(v_dados.last()).vr_nrctremp := 165346;
    v_dados(v_dados.last()).vr_vllanmto := 44.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240273;
    v_dados(v_dados.last()).vr_nrctremp := 176388;
    v_dados(v_dados.last()).vr_vllanmto := 44.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135810;
    v_dados(v_dados.last()).vr_nrctremp := 114621;
    v_dados(v_dados.last()).vr_vllanmto := 44.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141372;
    v_dados(v_dados.last()).vr_nrctremp := 143883;
    v_dados(v_dados.last()).vr_vllanmto := 44.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 165854;
    v_dados(v_dados.last()).vr_vllanmto := 44.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 113595;
    v_dados(v_dados.last()).vr_vllanmto := 44.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95141;
    v_dados(v_dados.last()).vr_nrctremp := 128642;
    v_dados(v_dados.last()).vr_vllanmto := 44.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167495;
    v_dados(v_dados.last()).vr_nrctremp := 179350;
    v_dados(v_dados.last()).vr_vllanmto := 45.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 133043;
    v_dados(v_dados.last()).vr_nrctremp := 178154;
    v_dados(v_dados.last()).vr_vllanmto := 45.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83098;
    v_dados(v_dados.last()).vr_vllanmto := 45.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185370;
    v_dados(v_dados.last()).vr_nrctremp := 143454;
    v_dados(v_dados.last()).vr_vllanmto := 45.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78778;
    v_dados(v_dados.last()).vr_nrctremp := 106214;
    v_dados(v_dados.last()).vr_vllanmto := 45.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132850;
    v_dados(v_dados.last()).vr_vllanmto := 45.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303771;
    v_dados(v_dados.last()).vr_nrctremp := 128054;
    v_dados(v_dados.last()).vr_vllanmto := 45.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 162345;
    v_dados(v_dados.last()).vr_nrctremp := 106041;
    v_dados(v_dados.last()).vr_vllanmto := 45.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182826;
    v_dados(v_dados.last()).vr_nrctremp := 96500;
    v_dados(v_dados.last()).vr_vllanmto := 45.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96245;
    v_dados(v_dados.last()).vr_nrctremp := 171345;
    v_dados(v_dados.last()).vr_vllanmto := 46.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 609447;
    v_dados(v_dados.last()).vr_nrctremp := 139009;
    v_dados(v_dados.last()).vr_vllanmto := 46.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442240;
    v_dados(v_dados.last()).vr_nrctremp := 158922;
    v_dados(v_dados.last()).vr_vllanmto := 46.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180777;
    v_dados(v_dados.last()).vr_nrctremp := 153278;
    v_dados(v_dados.last()).vr_vllanmto := 46.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150550;
    v_dados(v_dados.last()).vr_nrctremp := 113707;
    v_dados(v_dados.last()).vr_vllanmto := 46.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269913;
    v_dados(v_dados.last()).vr_nrctremp := 68956;
    v_dados(v_dados.last()).vr_vllanmto := 46.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181617;
    v_dados(v_dados.last()).vr_nrctremp := 178592;
    v_dados(v_dados.last()).vr_vllanmto := 46.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264768;
    v_dados(v_dados.last()).vr_nrctremp := 102540;
    v_dados(v_dados.last()).vr_vllanmto := 46.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 46458;
    v_dados(v_dados.last()).vr_vllanmto := 46.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287113;
    v_dados(v_dados.last()).vr_nrctremp := 56588;
    v_dados(v_dados.last()).vr_vllanmto := 46.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 474649;
    v_dados(v_dados.last()).vr_nrctremp := 116129;
    v_dados(v_dados.last()).vr_vllanmto := 46.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160954;
    v_dados(v_dados.last()).vr_nrctremp := 55722;
    v_dados(v_dados.last()).vr_vllanmto := 46.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44164;
    v_dados(v_dados.last()).vr_nrctremp := 55210;
    v_dados(v_dados.last()).vr_vllanmto := 47.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 53636;
    v_dados(v_dados.last()).vr_vllanmto := 47.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66672;
    v_dados(v_dados.last()).vr_nrctremp := 179795;
    v_dados(v_dados.last()).vr_vllanmto := 47.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 134812;
    v_dados(v_dados.last()).vr_vllanmto := 47.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 492639;
    v_dados(v_dados.last()).vr_nrctremp := 161075;
    v_dados(v_dados.last()).vr_vllanmto := 47.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 131369;
    v_dados(v_dados.last()).vr_vllanmto := 47.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172022;
    v_dados(v_dados.last()).vr_nrctremp := 109022;
    v_dados(v_dados.last()).vr_vllanmto := 47.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 414433;
    v_dados(v_dados.last()).vr_nrctremp := 54746;
    v_dados(v_dados.last()).vr_vllanmto := 47.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371580;
    v_dados(v_dados.last()).vr_nrctremp := 120210;
    v_dados(v_dados.last()).vr_vllanmto := 47.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670324;
    v_dados(v_dados.last()).vr_nrctremp := 167935;
    v_dados(v_dados.last()).vr_vllanmto := 47.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 439827;
    v_dados(v_dados.last()).vr_nrctremp := 161852;
    v_dados(v_dados.last()).vr_vllanmto := 47.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 62268;
    v_dados(v_dados.last()).vr_vllanmto := 47.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 177493;
    v_dados(v_dados.last()).vr_vllanmto := 48.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 128698;
    v_dados(v_dados.last()).vr_vllanmto := 48.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44164;
    v_dados(v_dados.last()).vr_nrctremp := 89193;
    v_dados(v_dados.last()).vr_vllanmto := 48.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104586;
    v_dados(v_dados.last()).vr_vllanmto := 48.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 144134;
    v_dados(v_dados.last()).vr_vllanmto := 48.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149205;
    v_dados(v_dados.last()).vr_vllanmto := 48.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190136;
    v_dados(v_dados.last()).vr_nrctremp := 117890;
    v_dados(v_dados.last()).vr_vllanmto := 48.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 160694;
    v_dados(v_dados.last()).vr_vllanmto := 48.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318639;
    v_dados(v_dados.last()).vr_nrctremp := 58849;
    v_dados(v_dados.last()).vr_vllanmto := 48.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 94244;
    v_dados(v_dados.last()).vr_vllanmto := 49.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 165521;
    v_dados(v_dados.last()).vr_vllanmto := 49.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 422339;
    v_dados(v_dados.last()).vr_nrctremp := 110088;
    v_dados(v_dados.last()).vr_vllanmto := 49.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 112505;
    v_dados(v_dados.last()).vr_vllanmto := 49.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9490;
    v_dados(v_dados.last()).vr_nrctremp := 144368;
    v_dados(v_dados.last()).vr_vllanmto := 49.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142387;
    v_dados(v_dados.last()).vr_nrctremp := 182021;
    v_dados(v_dados.last()).vr_vllanmto := 50.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 164160;
    v_dados(v_dados.last()).vr_nrctremp := 164893;
    v_dados(v_dados.last()).vr_vllanmto := 50.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14224259;
    v_dados(v_dados.last()).vr_nrctremp := 176905;
    v_dados(v_dados.last()).vr_vllanmto := 50.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 153499;
    v_dados(v_dados.last()).vr_vllanmto := 50.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146021;
    v_dados(v_dados.last()).vr_nrctremp := 90526;
    v_dados(v_dados.last()).vr_vllanmto := 50.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641790;
    v_dados(v_dados.last()).vr_nrctremp := 148852;
    v_dados(v_dados.last()).vr_vllanmto := 50.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170119;
    v_dados(v_dados.last()).vr_nrctremp := 72763;
    v_dados(v_dados.last()).vr_vllanmto := 50.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 465836;
    v_dados(v_dados.last()).vr_nrctremp := 72026;
    v_dados(v_dados.last()).vr_vllanmto := 50.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124334;
    v_dados(v_dados.last()).vr_vllanmto := 50.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 630080;
    v_dados(v_dados.last()).vr_nrctremp := 157110;
    v_dados(v_dados.last()).vr_vllanmto := 51.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96121;
    v_dados(v_dados.last()).vr_nrctremp := 66693;
    v_dados(v_dados.last()).vr_vllanmto := 51.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132187;
    v_dados(v_dados.last()).vr_nrctremp := 91180;
    v_dados(v_dados.last()).vr_vllanmto := 51.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288942;
    v_dados(v_dados.last()).vr_nrctremp := 165100;
    v_dados(v_dados.last()).vr_vllanmto := 51.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114636;
    v_dados(v_dados.last()).vr_vllanmto := 51.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242136;
    v_dados(v_dados.last()).vr_nrctremp := 58349;
    v_dados(v_dados.last()).vr_vllanmto := 51.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59688;
    v_dados(v_dados.last()).vr_vllanmto := 51.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103691;
    v_dados(v_dados.last()).vr_nrctremp := 96084;
    v_dados(v_dados.last()).vr_vllanmto := 51.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 516384;
    v_dados(v_dados.last()).vr_nrctremp := 94406;
    v_dados(v_dados.last()).vr_vllanmto := 51.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 130951;
    v_dados(v_dados.last()).vr_vllanmto := 52.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 138460;
    v_dados(v_dados.last()).vr_vllanmto := 52.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191833;
    v_dados(v_dados.last()).vr_nrctremp := 111115;
    v_dados(v_dados.last()).vr_vllanmto := 52.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 340561;
    v_dados(v_dados.last()).vr_nrctremp := 69746;
    v_dados(v_dados.last()).vr_vllanmto := 52.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148504;
    v_dados(v_dados.last()).vr_nrctremp := 54228;
    v_dados(v_dados.last()).vr_vllanmto := 52.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 482510;
    v_dados(v_dados.last()).vr_nrctremp := 180159;
    v_dados(v_dados.last()).vr_vllanmto := 52.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278157;
    v_dados(v_dados.last()).vr_nrctremp := 61458;
    v_dados(v_dados.last()).vr_vllanmto := 52.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 162609;
    v_dados(v_dados.last()).vr_vllanmto := 52.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90824;
    v_dados(v_dados.last()).vr_nrctremp := 73327;
    v_dados(v_dados.last()).vr_vllanmto := 52.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 79380;
    v_dados(v_dados.last()).vr_vllanmto := 52.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 160898;
    v_dados(v_dados.last()).vr_vllanmto := 52.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 146804;
    v_dados(v_dados.last()).vr_vllanmto := 52.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170305;
    v_dados(v_dados.last()).vr_nrctremp := 122762;
    v_dados(v_dados.last()).vr_vllanmto := 52.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 53.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 285072;
    v_dados(v_dados.last()).vr_nrctremp := 98107;
    v_dados(v_dados.last()).vr_vllanmto := 53.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 70313;
    v_dados(v_dados.last()).vr_vllanmto := 53.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 111312;
    v_dados(v_dados.last()).vr_vllanmto := 53.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 474649;
    v_dados(v_dados.last()).vr_nrctremp := 74805;
    v_dados(v_dados.last()).vr_vllanmto := 53.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 89779;
    v_dados(v_dados.last()).vr_vllanmto := 53.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141976;
    v_dados(v_dados.last()).vr_nrctremp := 109534;
    v_dados(v_dados.last()).vr_vllanmto := 53.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524310;
    v_dados(v_dados.last()).vr_nrctremp := 94882;
    v_dados(v_dados.last()).vr_vllanmto := 53.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 241784;
    v_dados(v_dados.last()).vr_nrctremp := 84479;
    v_dados(v_dados.last()).vr_vllanmto := 53.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322865;
    v_dados(v_dados.last()).vr_nrctremp := 133461;
    v_dados(v_dados.last()).vr_vllanmto := 53.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 354996;
    v_dados(v_dados.last()).vr_nrctremp := 81005;
    v_dados(v_dados.last()).vr_vllanmto := 53.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328227;
    v_dados(v_dados.last()).vr_nrctremp := 136480;
    v_dados(v_dados.last()).vr_vllanmto := 53.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185574;
    v_dados(v_dados.last()).vr_nrctremp := 105662;
    v_dados(v_dados.last()).vr_vllanmto := 54.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268240;
    v_dados(v_dados.last()).vr_nrctremp := 139411;
    v_dados(v_dados.last()).vr_vllanmto := 54.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163171;
    v_dados(v_dados.last()).vr_nrctremp := 106698;
    v_dados(v_dados.last()).vr_vllanmto := 54.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188336;
    v_dados(v_dados.last()).vr_nrctremp := 153815;
    v_dados(v_dados.last()).vr_vllanmto := 54.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 416606;
    v_dados(v_dados.last()).vr_nrctremp := 179261;
    v_dados(v_dados.last()).vr_vllanmto := 54.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 108981;
    v_dados(v_dados.last()).vr_vllanmto := 54.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 150930;
    v_dados(v_dados.last()).vr_vllanmto := 54.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 115337;
    v_dados(v_dados.last()).vr_vllanmto := 54.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292060;
    v_dados(v_dados.last()).vr_nrctremp := 133165;
    v_dados(v_dados.last()).vr_vllanmto := 55.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148101;
    v_dados(v_dados.last()).vr_vllanmto := 55.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 87965;
    v_dados(v_dados.last()).vr_vllanmto := 55.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 119253;
    v_dados(v_dados.last()).vr_vllanmto := 55.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 176584;
    v_dados(v_dados.last()).vr_vllanmto := 55.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265381;
    v_dados(v_dados.last()).vr_nrctremp := 162693;
    v_dados(v_dados.last()).vr_vllanmto := 56.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 137990;
    v_dados(v_dados.last()).vr_vllanmto := 56.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 487090;
    v_dados(v_dados.last()).vr_nrctremp := 135114;
    v_dados(v_dados.last()).vr_vllanmto := 57.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190217;
    v_dados(v_dados.last()).vr_nrctremp := 105065;
    v_dados(v_dados.last()).vr_vllanmto := 57.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 486256;
    v_dados(v_dados.last()).vr_nrctremp := 80327;
    v_dados(v_dados.last()).vr_vllanmto := 57.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 486230;
    v_dados(v_dados.last()).vr_nrctremp := 81443;
    v_dados(v_dados.last()).vr_vllanmto := 57.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 97404;
    v_dados(v_dados.last()).vr_vllanmto := 57.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78319;
    v_dados(v_dados.last()).vr_vllanmto := 57.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 96326;
    v_dados(v_dados.last()).vr_vllanmto := 57.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 105022;
    v_dados(v_dados.last()).vr_vllanmto := 57.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80250;
    v_dados(v_dados.last()).vr_nrctremp := 139169;
    v_dados(v_dados.last()).vr_vllanmto := 57.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 649899;
    v_dados(v_dados.last()).vr_nrctremp := 153142;
    v_dados(v_dados.last()).vr_vllanmto := 57.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 79379;
    v_dados(v_dados.last()).vr_vllanmto := 58.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 364037;
    v_dados(v_dados.last()).vr_nrctremp := 148552;
    v_dados(v_dados.last()).vr_vllanmto := 58.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186740;
    v_dados(v_dados.last()).vr_nrctremp := 119858;
    v_dados(v_dados.last()).vr_vllanmto := 58.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545368;
    v_dados(v_dados.last()).vr_nrctremp := 108116;
    v_dados(v_dados.last()).vr_vllanmto := 58.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153605;
    v_dados(v_dados.last()).vr_nrctremp := 85830;
    v_dados(v_dados.last()).vr_vllanmto := 58.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256757;
    v_dados(v_dados.last()).vr_nrctremp := 137189;
    v_dados(v_dados.last()).vr_vllanmto := 59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109428;
    v_dados(v_dados.last()).vr_nrctremp := 154257;
    v_dados(v_dados.last()).vr_vllanmto := 59.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185760;
    v_dados(v_dados.last()).vr_nrctremp := 134538;
    v_dados(v_dados.last()).vr_vllanmto := 59.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355771;
    v_dados(v_dados.last()).vr_nrctremp := 144078;
    v_dados(v_dados.last()).vr_vllanmto := 59.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 51281;
    v_dados(v_dados.last()).vr_vllanmto := 59.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95044;
    v_dados(v_dados.last()).vr_nrctremp := 70093;
    v_dados(v_dados.last()).vr_vllanmto := 59.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 116408;
    v_dados(v_dados.last()).vr_vllanmto := 59.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133557;
    v_dados(v_dados.last()).vr_vllanmto := 59.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 141142;
    v_dados(v_dados.last()).vr_vllanmto := 60.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137559;
    v_dados(v_dados.last()).vr_vllanmto := 60.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 110909;
    v_dados(v_dados.last()).vr_vllanmto := 60.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185272;
    v_dados(v_dados.last()).vr_nrctremp := 139153;
    v_dados(v_dados.last()).vr_vllanmto := 60.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 118810;
    v_dados(v_dados.last()).vr_vllanmto := 60.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183202;
    v_dados(v_dados.last()).vr_nrctremp := 134829;
    v_dados(v_dados.last()).vr_vllanmto := 60.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139402;
    v_dados(v_dados.last()).vr_vllanmto := 60.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 150785;
    v_dados(v_dados.last()).vr_vllanmto := 60.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216771;
    v_dados(v_dados.last()).vr_nrctremp := 112211;
    v_dados(v_dados.last()).vr_vllanmto := 60.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146395;
    v_dados(v_dados.last()).vr_vllanmto := 60.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425230;
    v_dados(v_dados.last()).vr_nrctremp := 56888;
    v_dados(v_dados.last()).vr_vllanmto := 60.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284220;
    v_dados(v_dados.last()).vr_nrctremp := 102835;
    v_dados(v_dados.last()).vr_vllanmto := 61.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 461610;
    v_dados(v_dados.last()).vr_nrctremp := 145393;
    v_dados(v_dados.last()).vr_vllanmto := 61.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155420;
    v_dados(v_dados.last()).vr_vllanmto := 61.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91391;
    v_dados(v_dados.last()).vr_nrctremp := 80583;
    v_dados(v_dados.last()).vr_vllanmto := 61.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 104597;
    v_dados(v_dados.last()).vr_vllanmto := 61.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 61.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146021;
    v_dados(v_dados.last()).vr_nrctremp := 90524;
    v_dados(v_dados.last()).vr_vllanmto := 62.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 224162;
    v_dados(v_dados.last()).vr_nrctremp := 116604;
    v_dados(v_dados.last()).vr_vllanmto := 62.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 301469;
    v_dados(v_dados.last()).vr_nrctremp := 123630;
    v_dados(v_dados.last()).vr_vllanmto := 62.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277754;
    v_dados(v_dados.last()).vr_nrctremp := 161321;
    v_dados(v_dados.last()).vr_vllanmto := 773.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182702;
    v_dados(v_dados.last()).vr_nrctremp := 53514;
    v_dados(v_dados.last()).vr_vllanmto := 62.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240419;
    v_dados(v_dados.last()).vr_nrctremp := 114886;
    v_dados(v_dados.last()).vr_vllanmto := 62.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 123277;
    v_dados(v_dados.last()).vr_nrctremp := 172864;
    v_dados(v_dados.last()).vr_vllanmto := 62.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 684660;
    v_dados(v_dados.last()).vr_nrctremp := 176178;
    v_dados(v_dados.last()).vr_vllanmto := 62.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 543144;
    v_dados(v_dados.last()).vr_nrctremp := 128653;
    v_dados(v_dados.last()).vr_vllanmto := 63.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322890;
    v_dados(v_dados.last()).vr_nrctremp := 147538;
    v_dados(v_dados.last()).vr_vllanmto := 63.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26700;
    v_dados(v_dados.last()).vr_nrctremp := 52820;
    v_dados(v_dados.last()).vr_vllanmto := 63.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71512;
    v_dados(v_dados.last()).vr_vllanmto := 63.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 174443;
    v_dados(v_dados.last()).vr_vllanmto := 63.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94951;
    v_dados(v_dados.last()).vr_nrctremp := 140766;
    v_dados(v_dados.last()).vr_vllanmto := 63.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144053;
    v_dados(v_dados.last()).vr_nrctremp := 102361;
    v_dados(v_dados.last()).vr_vllanmto := 64.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 511870;
    v_dados(v_dados.last()).vr_nrctremp := 162284;
    v_dados(v_dados.last()).vr_vllanmto := 64.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186902;
    v_dados(v_dados.last()).vr_nrctremp := 92977;
    v_dados(v_dados.last()).vr_vllanmto := 64.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294144;
    v_dados(v_dados.last()).vr_nrctremp := 177413;
    v_dados(v_dados.last()).vr_vllanmto := 64.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280836;
    v_dados(v_dados.last()).vr_nrctremp := 144048;
    v_dados(v_dados.last()).vr_vllanmto := 65.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 147680;
    v_dados(v_dados.last()).vr_vllanmto := 65.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185485;
    v_dados(v_dados.last()).vr_nrctremp := 58844;
    v_dados(v_dados.last()).vr_vllanmto := 65.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 268712;
    v_dados(v_dados.last()).vr_nrctremp := 68804;
    v_dados(v_dados.last()).vr_vllanmto := 65.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 443972;
    v_dados(v_dados.last()).vr_nrctremp := 73022;
    v_dados(v_dados.last()).vr_vllanmto := 66.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 412481;
    v_dados(v_dados.last()).vr_nrctremp := 97843;
    v_dados(v_dados.last()).vr_vllanmto := 66.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 103395;
    v_dados(v_dados.last()).vr_vllanmto := 66.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 86810;
    v_dados(v_dados.last()).vr_vllanmto := 66.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94692;
    v_dados(v_dados.last()).vr_nrctremp := 79826;
    v_dados(v_dados.last()).vr_vllanmto := 66.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 608203;
    v_dados(v_dados.last()).vr_nrctremp := 172851;
    v_dados(v_dados.last()).vr_vllanmto := 66.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 380032;
    v_dados(v_dados.last()).vr_nrctremp := 171257;
    v_dados(v_dados.last()).vr_vllanmto := 66.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248789;
    v_dados(v_dados.last()).vr_nrctremp := 138349;
    v_dados(v_dados.last()).vr_vllanmto := 53.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93122;
    v_dados(v_dados.last()).vr_nrctremp := 136111;
    v_dados(v_dados.last()).vr_vllanmto := 1101.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 132284;
    v_dados(v_dados.last()).vr_vllanmto := 66.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91995;
    v_dados(v_dados.last()).vr_nrctremp := 126548;
    v_dados(v_dados.last()).vr_vllanmto := 66.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 164345;
    v_dados(v_dados.last()).vr_vllanmto := 66.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129693;
    v_dados(v_dados.last()).vr_vllanmto := 67.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184349;
    v_dados(v_dados.last()).vr_nrctremp := 146087;
    v_dados(v_dados.last()).vr_vllanmto := 67.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188204;
    v_dados(v_dados.last()).vr_nrctremp := 65655;
    v_dados(v_dados.last()).vr_vllanmto := 67.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145319;
    v_dados(v_dados.last()).vr_nrctremp := 114005;
    v_dados(v_dados.last()).vr_vllanmto := 67.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90000;
    v_dados(v_dados.last()).vr_nrctremp := 129809;
    v_dados(v_dados.last()).vr_vllanmto := 67.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156540;
    v_dados(v_dados.last()).vr_nrctremp := 120079;
    v_dados(v_dados.last()).vr_vllanmto := 67.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 151150;
    v_dados(v_dados.last()).vr_vllanmto := 68.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170097;
    v_dados(v_dados.last()).vr_nrctremp := 55565;
    v_dados(v_dados.last()).vr_vllanmto := 68.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107625;
    v_dados(v_dados.last()).vr_vllanmto := 68.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351881;
    v_dados(v_dados.last()).vr_nrctremp := 158736;
    v_dados(v_dados.last()).vr_vllanmto := 68.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138231;
    v_dados(v_dados.last()).vr_nrctremp := 63482;
    v_dados(v_dados.last()).vr_vllanmto := 68.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133795;
    v_dados(v_dados.last()).vr_vllanmto := 68.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 68.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168564;
    v_dados(v_dados.last()).vr_nrctremp := 96542;
    v_dados(v_dados.last()).vr_vllanmto := 68.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350893;
    v_dados(v_dados.last()).vr_nrctremp := 146914;
    v_dados(v_dados.last()).vr_vllanmto := 68.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360333;
    v_dados(v_dados.last()).vr_nrctremp := 175913;
    v_dados(v_dados.last()).vr_vllanmto := 68.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 135380;
    v_dados(v_dados.last()).vr_vllanmto := 69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151453;
    v_dados(v_dados.last()).vr_vllanmto := 69.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 324400;
    v_dados(v_dados.last()).vr_nrctremp := 124236;
    v_dados(v_dados.last()).vr_vllanmto := 70.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 92189;
    v_dados(v_dados.last()).vr_vllanmto := 70.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 253057;
    v_dados(v_dados.last()).vr_nrctremp := 94143;
    v_dados(v_dados.last()).vr_vllanmto := 70.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 501786;
    v_dados(v_dados.last()).vr_nrctremp := 86925;
    v_dados(v_dados.last()).vr_vllanmto := 70.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107662;
    v_dados(v_dados.last()).vr_nrctremp := 59838;
    v_dados(v_dados.last()).vr_vllanmto := 70.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 261122;
    v_dados(v_dados.last()).vr_nrctremp := 146561;
    v_dados(v_dados.last()).vr_vllanmto := 70.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382302;
    v_dados(v_dados.last()).vr_nrctremp := 101411;
    v_dados(v_dados.last()).vr_vllanmto := 70.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 70.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 297194;
    v_dados(v_dados.last()).vr_nrctremp := 74771;
    v_dados(v_dados.last()).vr_vllanmto := 70.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 135118;
    v_dados(v_dados.last()).vr_vllanmto := 71.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146013;
    v_dados(v_dados.last()).vr_nrctremp := 154533;
    v_dados(v_dados.last()).vr_vllanmto := 71.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424145;
    v_dados(v_dados.last()).vr_nrctremp := 56667;
    v_dados(v_dados.last()).vr_vllanmto := 71.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219428;
    v_dados(v_dados.last()).vr_nrctremp := 108994;
    v_dados(v_dados.last()).vr_vllanmto := 71.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90891;
    v_dados(v_dados.last()).vr_nrctremp := 179280;
    v_dados(v_dados.last()).vr_vllanmto := 71.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294691;
    v_dados(v_dados.last()).vr_nrctremp := 181157;
    v_dados(v_dados.last()).vr_vllanmto := 71.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 162673;
    v_dados(v_dados.last()).vr_vllanmto := 71.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91251;
    v_dados(v_dados.last()).vr_nrctremp := 51354;
    v_dados(v_dados.last()).vr_vllanmto := 71.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187143;
    v_dados(v_dados.last()).vr_nrctremp := 132407;
    v_dados(v_dados.last()).vr_vllanmto := 71.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161799;
    v_dados(v_dados.last()).vr_nrctremp := 97735;
    v_dados(v_dados.last()).vr_vllanmto := 71.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 119046;
    v_dados(v_dados.last()).vr_vllanmto := 71.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420883;
    v_dados(v_dados.last()).vr_nrctremp := 147127;
    v_dados(v_dados.last()).vr_vllanmto := 72.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 95094;
    v_dados(v_dados.last()).vr_vllanmto := 72.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91227;
    v_dados(v_dados.last()).vr_nrctremp := 66497;
    v_dados(v_dados.last()).vr_vllanmto := 72.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59382;
    v_dados(v_dados.last()).vr_nrctremp := 86032;
    v_dados(v_dados.last()).vr_vllanmto := 72.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206504;
    v_dados(v_dados.last()).vr_nrctremp := 92512;
    v_dados(v_dados.last()).vr_vllanmto := 72.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315834;
    v_dados(v_dados.last()).vr_nrctremp := 118574;
    v_dados(v_dados.last()).vr_vllanmto := 72.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135769;
    v_dados(v_dados.last()).vr_vllanmto := 72.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 80312;
    v_dados(v_dados.last()).vr_vllanmto := 72.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419834;
    v_dados(v_dados.last()).vr_nrctremp := 55980;
    v_dados(v_dados.last()).vr_vllanmto := 73.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202576;
    v_dados(v_dados.last()).vr_nrctremp := 104041;
    v_dados(v_dados.last()).vr_vllanmto := 73.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192660;
    v_dados(v_dados.last()).vr_nrctremp := 174123;
    v_dados(v_dados.last()).vr_vllanmto := 73.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163473;
    v_dados(v_dados.last()).vr_nrctremp := 180227;
    v_dados(v_dados.last()).vr_vllanmto := 73.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353507;
    v_dados(v_dados.last()).vr_nrctremp := 155363;
    v_dados(v_dados.last()).vr_vllanmto := 73.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288322;
    v_dados(v_dados.last()).vr_nrctremp := 106632;
    v_dados(v_dados.last()).vr_vllanmto := 73.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62072;
    v_dados(v_dados.last()).vr_vllanmto := 74.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91782;
    v_dados(v_dados.last()).vr_nrctremp := 178838;
    v_dados(v_dados.last()).vr_vllanmto := 74.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 149849;
    v_dados(v_dados.last()).vr_vllanmto := 74.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 104829;
    v_dados(v_dados.last()).vr_vllanmto := 74.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214450;
    v_dados(v_dados.last()).vr_nrctremp := 100349;
    v_dados(v_dados.last()).vr_vllanmto := 74.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 162545;
    v_dados(v_dados.last()).vr_vllanmto := 74.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124311;
    v_dados(v_dados.last()).vr_nrctremp := 142173;
    v_dados(v_dados.last()).vr_vllanmto := 74.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193810;
    v_dados(v_dados.last()).vr_nrctremp := 147432;
    v_dados(v_dados.last()).vr_vllanmto := 74.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 69400;
    v_dados(v_dados.last()).vr_nrctremp := 61857;
    v_dados(v_dados.last()).vr_vllanmto := 74.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 60470;
    v_dados(v_dados.last()).vr_vllanmto := 74.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 105884;
    v_dados(v_dados.last()).vr_vllanmto := 75.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252514;
    v_dados(v_dados.last()).vr_nrctremp := 172328;
    v_dados(v_dados.last()).vr_vllanmto := 75.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 134129;
    v_dados(v_dados.last()).vr_vllanmto := 75.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295515;
    v_dados(v_dados.last()).vr_nrctremp := 57927;
    v_dados(v_dados.last()).vr_vllanmto := 75.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155419;
    v_dados(v_dados.last()).vr_vllanmto := 76.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91243;
    v_dados(v_dados.last()).vr_nrctremp := 111299;
    v_dados(v_dados.last()).vr_vllanmto := 76.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13226;
    v_dados(v_dados.last()).vr_nrctremp := 115394;
    v_dados(v_dados.last()).vr_vllanmto := 76.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187917;
    v_dados(v_dados.last()).vr_nrctremp := 87916;
    v_dados(v_dados.last()).vr_vllanmto := 77.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78166;
    v_dados(v_dados.last()).vr_nrctremp := 107659;
    v_dados(v_dados.last()).vr_vllanmto := 77.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18910;
    v_dados(v_dados.last()).vr_nrctremp := 179306;
    v_dados(v_dados.last()).vr_vllanmto := 77.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 101770;
    v_dados(v_dados.last()).vr_nrctremp := 56372;
    v_dados(v_dados.last()).vr_vllanmto := 77.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614610;
    v_dados(v_dados.last()).vr_nrctremp := 157203;
    v_dados(v_dados.last()).vr_vllanmto := 77.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 178449;
    v_dados(v_dados.last()).vr_vllanmto := 77.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275972;
    v_dados(v_dados.last()).vr_nrctremp := 58367;
    v_dados(v_dados.last()).vr_vllanmto := 77.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 102651;
    v_dados(v_dados.last()).vr_vllanmto := 78.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267627;
    v_dados(v_dados.last()).vr_nrctremp := 52677;
    v_dados(v_dados.last()).vr_vllanmto := 78.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 23388;
    v_dados(v_dados.last()).vr_nrctremp := 59749;
    v_dados(v_dados.last()).vr_vllanmto := 78.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 434183;
    v_dados(v_dados.last()).vr_nrctremp := 58723;
    v_dados(v_dados.last()).vr_vllanmto := 78.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 113422;
    v_dados(v_dados.last()).vr_vllanmto := 78.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155955;
    v_dados(v_dados.last()).vr_vllanmto := 79.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 64834;
    v_dados(v_dados.last()).vr_vllanmto := 79.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 114018;
    v_dados(v_dados.last()).vr_vllanmto := 79.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479446;
    v_dados(v_dados.last()).vr_nrctremp := 81657;
    v_dados(v_dados.last()).vr_vllanmto := 79.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319236;
    v_dados(v_dados.last()).vr_nrctremp := 153326;
    v_dados(v_dados.last()).vr_vllanmto := 79.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323004;
    v_dados(v_dados.last()).vr_nrctremp := 149276;
    v_dados(v_dados.last()).vr_vllanmto := 79.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159972;
    v_dados(v_dados.last()).vr_nrctremp := 147219;
    v_dados(v_dados.last()).vr_vllanmto := 79.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78131;
    v_dados(v_dados.last()).vr_nrctremp := 160897;
    v_dados(v_dados.last()).vr_vllanmto := 79.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190985;
    v_dados(v_dados.last()).vr_nrctremp := 144153;
    v_dados(v_dados.last()).vr_vllanmto := 80.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 113777;
    v_dados(v_dados.last()).vr_vllanmto := 80.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156025;
    v_dados(v_dados.last()).vr_vllanmto := 80.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78322;
    v_dados(v_dados.last()).vr_vllanmto := 80.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137561;
    v_dados(v_dados.last()).vr_vllanmto := 80.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267414;
    v_dados(v_dados.last()).vr_nrctremp := 76193;
    v_dados(v_dados.last()).vr_vllanmto := 80.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 151743;
    v_dados(v_dados.last()).vr_vllanmto := 80.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 162602;
    v_dados(v_dados.last()).vr_vllanmto := 80.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215414;
    v_dados(v_dados.last()).vr_nrctremp := 61817;
    v_dados(v_dados.last()).vr_vllanmto := 80.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 454419;
    v_dados(v_dados.last()).vr_nrctremp := 67569;
    v_dados(v_dados.last()).vr_vllanmto := 80.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445100;
    v_dados(v_dados.last()).vr_nrctremp := 63764;
    v_dados(v_dados.last()).vr_vllanmto := 81.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647527;
    v_dados(v_dados.last()).vr_nrctremp := 152360;
    v_dados(v_dados.last()).vr_vllanmto := 81.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673552;
    v_dados(v_dados.last()).vr_nrctremp := 166691;
    v_dados(v_dados.last()).vr_vllanmto := 81.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207497;
    v_dados(v_dados.last()).vr_nrctremp := 51194;
    v_dados(v_dados.last()).vr_vllanmto := 81.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 121973;
    v_dados(v_dados.last()).vr_vllanmto := 81.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145708;
    v_dados(v_dados.last()).vr_vllanmto := 81.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132810;
    v_dados(v_dados.last()).vr_nrctremp := 129063;
    v_dados(v_dados.last()).vr_vllanmto := 82.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 175474;
    v_dados(v_dados.last()).vr_vllanmto := 82.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78140;
    v_dados(v_dados.last()).vr_nrctremp := 159388;
    v_dados(v_dados.last()).vr_vllanmto := 82.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 53200;
    v_dados(v_dados.last()).vr_vllanmto := 82.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425680;
    v_dados(v_dados.last()).vr_nrctremp := 164917;
    v_dados(v_dados.last()).vr_vllanmto := 82.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90360;
    v_dados(v_dados.last()).vr_nrctremp := 71345;
    v_dados(v_dados.last()).vr_vllanmto := 82.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180777;
    v_dados(v_dados.last()).vr_nrctremp := 153272;
    v_dados(v_dados.last()).vr_vllanmto := 82.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349780;
    v_dados(v_dados.last()).vr_nrctremp := 153608;
    v_dados(v_dados.last()).vr_vllanmto := 82.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 312550;
    v_dados(v_dados.last()).vr_nrctremp := 105658;
    v_dados(v_dados.last()).vr_vllanmto := 82.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142670;
    v_dados(v_dados.last()).vr_nrctremp := 161255;
    v_dados(v_dados.last()).vr_vllanmto := 82.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539155;
    v_dados(v_dados.last()).vr_nrctremp := 173100;
    v_dados(v_dados.last()).vr_vllanmto := 83.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534633;
    v_dados(v_dados.last()).vr_nrctremp := 99621;
    v_dados(v_dados.last()).vr_vllanmto := 83.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 261580;
    v_dados(v_dados.last()).vr_nrctremp := 50935;
    v_dados(v_dados.last()).vr_vllanmto := 83.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534633;
    v_dados(v_dados.last()).vr_nrctremp := 172767;
    v_dados(v_dados.last()).vr_vllanmto := 84.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 70386;
    v_dados(v_dados.last()).vr_nrctremp := 138212;
    v_dados(v_dados.last()).vr_vllanmto := 84.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91480;
    v_dados(v_dados.last()).vr_nrctremp := 143020;
    v_dados(v_dados.last()).vr_vllanmto := 85.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136956;
    v_dados(v_dados.last()).vr_nrctremp := 115239;
    v_dados(v_dados.last()).vr_vllanmto := 85.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462110;
    v_dados(v_dados.last()).vr_nrctremp := 69670;
    v_dados(v_dados.last()).vr_vllanmto := 85.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 42404;
    v_dados(v_dados.last()).vr_nrctremp := 53091;
    v_dados(v_dados.last()).vr_vllanmto := 85.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 286745;
    v_dados(v_dados.last()).vr_nrctremp := 60515;
    v_dados(v_dados.last()).vr_vllanmto := 85.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 308030;
    v_dados(v_dados.last()).vr_nrctremp := 136035;
    v_dados(v_dados.last()).vr_vllanmto := 85.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175099;
    v_dados(v_dados.last()).vr_nrctremp := 54426;
    v_dados(v_dados.last()).vr_vllanmto := 86.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140600;
    v_dados(v_dados.last()).vr_nrctremp := 113744;
    v_dados(v_dados.last()).vr_vllanmto := 86.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107397;
    v_dados(v_dados.last()).vr_vllanmto := 87.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 95562;
    v_dados(v_dados.last()).vr_vllanmto := 87.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 626368;
    v_dados(v_dados.last()).vr_nrctremp := 150466;
    v_dados(v_dados.last()).vr_vllanmto := 87.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163066;
    v_dados(v_dados.last()).vr_nrctremp := 61364;
    v_dados(v_dados.last()).vr_vllanmto := 88.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137031;
    v_dados(v_dados.last()).vr_vllanmto := 88.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292303;
    v_dados(v_dados.last()).vr_nrctremp := 150969;
    v_dados(v_dados.last()).vr_vllanmto := 88.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 472611;
    v_dados(v_dados.last()).vr_nrctremp := 74229;
    v_dados(v_dados.last()).vr_vllanmto := 88.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166480;
    v_dados(v_dados.last()).vr_nrctremp := 73952;
    v_dados(v_dados.last()).vr_vllanmto := 88.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 125887;
    v_dados(v_dados.last()).vr_vllanmto := 88.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 176806;
    v_dados(v_dados.last()).vr_vllanmto := 89.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156396;
    v_dados(v_dados.last()).vr_nrctremp := 160564;
    v_dados(v_dados.last()).vr_vllanmto := 89.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 66273;
    v_dados(v_dados.last()).vr_vllanmto := 482.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435783;
    v_dados(v_dados.last()).vr_nrctremp := 59124;
    v_dados(v_dados.last()).vr_vllanmto := 90.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96229;
    v_dados(v_dados.last()).vr_nrctremp := 150075;
    v_dados(v_dados.last()).vr_vllanmto := 90.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9482;
    v_dados(v_dados.last()).vr_nrctremp := 166510;
    v_dados(v_dados.last()).vr_vllanmto := 91.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521140;
    v_dados(v_dados.last()).vr_nrctremp := 92843;
    v_dados(v_dados.last()).vr_vllanmto := 91.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91715;
    v_dados(v_dados.last()).vr_nrctremp := 151598;
    v_dados(v_dados.last()).vr_vllanmto := 91.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103608;
    v_dados(v_dados.last()).vr_nrctremp := 150645;
    v_dados(v_dados.last()).vr_vllanmto := 91.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124281;
    v_dados(v_dados.last()).vr_vllanmto := 91.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479080;
    v_dados(v_dados.last()).vr_nrctremp := 112509;
    v_dados(v_dados.last()).vr_vllanmto := 92.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445118;
    v_dados(v_dados.last()).vr_nrctremp := 63763;
    v_dados(v_dados.last()).vr_vllanmto := 92.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 73133;
    v_dados(v_dados.last()).vr_vllanmto := 92.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 92.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 200123;
    v_dados(v_dados.last()).vr_nrctremp := 66254;
    v_dados(v_dados.last()).vr_vllanmto := 92.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187801;
    v_dados(v_dados.last()).vr_nrctremp := 51898;
    v_dados(v_dados.last()).vr_vllanmto := 92.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 127079;
    v_dados(v_dados.last()).vr_vllanmto := 93.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161284;
    v_dados(v_dados.last()).vr_nrctremp := 64423;
    v_dados(v_dados.last()).vr_vllanmto := 93.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349445;
    v_dados(v_dados.last()).vr_nrctremp := 103359;
    v_dados(v_dados.last()).vr_vllanmto := 93.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 664030;
    v_dados(v_dados.last()).vr_nrctremp := 161218;
    v_dados(v_dados.last()).vr_vllanmto := 93.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493368;
    v_dados(v_dados.last()).vr_nrctremp := 153995;
    v_dados(v_dados.last()).vr_vllanmto := 93.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14613;
    v_dados(v_dados.last()).vr_nrctremp := 153842;
    v_dados(v_dados.last()).vr_vllanmto := 94.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 109024;
    v_dados(v_dados.last()).vr_vllanmto := 130.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 155954;
    v_dados(v_dados.last()).vr_vllanmto := 94.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382833;
    v_dados(v_dados.last()).vr_nrctremp := 163160;
    v_dados(v_dados.last()).vr_vllanmto := 95.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 50956;
    v_dados(v_dados.last()).vr_vllanmto := 95.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 84199;
    v_dados(v_dados.last()).vr_vllanmto := 95.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215937;
    v_dados(v_dados.last()).vr_nrctremp := 112915;
    v_dados(v_dados.last()).vr_vllanmto := 96.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184381;
    v_dados(v_dados.last()).vr_nrctremp := 55326;
    v_dados(v_dados.last()).vr_vllanmto := 96.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137375;
    v_dados(v_dados.last()).vr_nrctremp := 174416;
    v_dados(v_dados.last()).vr_vllanmto := 96.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 371696;
    v_dados(v_dados.last()).vr_nrctremp := 94932;
    v_dados(v_dados.last()).vr_vllanmto := 98.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498815;
    v_dados(v_dados.last()).vr_nrctremp := 84901;
    v_dados(v_dados.last()).vr_vllanmto := 98.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 69400;
    v_dados(v_dados.last()).vr_nrctremp := 143506;
    v_dados(v_dados.last()).vr_vllanmto := 99.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256544;
    v_dados(v_dados.last()).vr_nrctremp := 58944;
    v_dados(v_dados.last()).vr_vllanmto := 99.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138207;
    v_dados(v_dados.last()).vr_nrctremp := 51622;
    v_dados(v_dados.last()).vr_vllanmto := 101.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201146;
    v_dados(v_dados.last()).vr_nrctremp := 137625;
    v_dados(v_dados.last()).vr_vllanmto := 101.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 522457;
    v_dados(v_dados.last()).vr_nrctremp := 107491;
    v_dados(v_dados.last()).vr_vllanmto := 101.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524905;
    v_dados(v_dados.last()).vr_nrctremp := 95213;
    v_dados(v_dados.last()).vr_vllanmto := 101.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104701;
    v_dados(v_dados.last()).vr_vllanmto := 101.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344192;
    v_dados(v_dados.last()).vr_nrctremp := 106118;
    v_dados(v_dados.last()).vr_vllanmto := 101.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 134597;
    v_dados(v_dados.last()).vr_vllanmto := 101.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106404;
    v_dados(v_dados.last()).vr_vllanmto := 102.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131873;
    v_dados(v_dados.last()).vr_nrctremp := 80177;
    v_dados(v_dados.last()).vr_vllanmto := 102.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353817;
    v_dados(v_dados.last()).vr_nrctremp := 178467;
    v_dados(v_dados.last()).vr_vllanmto := 103.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 661074;
    v_dados(v_dados.last()).vr_nrctremp := 160149;
    v_dados(v_dados.last()).vr_vllanmto := 103.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 45152;
    v_dados(v_dados.last()).vr_nrctremp := 163726;
    v_dados(v_dados.last()).vr_vllanmto := 103.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 173754;
    v_dados(v_dados.last()).vr_nrctremp := 94320;
    v_dados(v_dados.last()).vr_vllanmto := 103.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 135224;
    v_dados(v_dados.last()).vr_nrctremp := 165806;
    v_dados(v_dados.last()).vr_vllanmto := 103.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144576;
    v_dados(v_dados.last()).vr_nrctremp := 110582;
    v_dados(v_dados.last()).vr_vllanmto := 104.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450200;
    v_dados(v_dados.last()).vr_nrctremp := 65949;
    v_dados(v_dados.last()).vr_vllanmto := 105.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163775;
    v_dados(v_dados.last()).vr_nrctremp := 173181;
    v_dados(v_dados.last()).vr_vllanmto := 105.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150401;
    v_dados(v_dados.last()).vr_nrctremp := 171894;
    v_dados(v_dados.last()).vr_vllanmto := 105.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129860;
    v_dados(v_dados.last()).vr_nrctremp := 167295;
    v_dados(v_dados.last()).vr_vllanmto := 105.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62068;
    v_dados(v_dados.last()).vr_vllanmto := 105.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545775;
    v_dados(v_dados.last()).vr_nrctremp := 105332;
    v_dados(v_dados.last()).vr_vllanmto := 105.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 410047;
    v_dados(v_dados.last()).vr_nrctremp := 157762;
    v_dados(v_dados.last()).vr_vllanmto := 105.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 56753;
    v_dados(v_dados.last()).vr_vllanmto := 106.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 106.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187615;
    v_dados(v_dados.last()).vr_nrctremp := 172942;
    v_dados(v_dados.last()).vr_vllanmto := 106.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94999;
    v_dados(v_dados.last()).vr_vllanmto := 106.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124332;
    v_dados(v_dados.last()).vr_vllanmto := 106.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367885;
    v_dados(v_dados.last()).vr_nrctremp := 135319;
    v_dados(v_dados.last()).vr_vllanmto := 107.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92290;
    v_dados(v_dados.last()).vr_nrctremp := 176032;
    v_dados(v_dados.last()).vr_vllanmto := 107.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 79857;
    v_dados(v_dados.last()).vr_vllanmto := 107.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 46531;
    v_dados(v_dados.last()).vr_nrctremp := 116188;
    v_dados(v_dados.last()).vr_vllanmto := 107.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132187;
    v_dados(v_dados.last()).vr_nrctremp := 113349;
    v_dados(v_dados.last()).vr_vllanmto := 108.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186805;
    v_dados(v_dados.last()).vr_nrctremp := 63844;
    v_dados(v_dados.last()).vr_vllanmto := 109.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154547;
    v_dados(v_dados.last()).vr_nrctremp := 103971;
    v_dados(v_dados.last()).vr_vllanmto := 109.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 206725;
    v_dados(v_dados.last()).vr_nrctremp := 101292;
    v_dados(v_dados.last()).vr_vllanmto := 109.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181218;
    v_dados(v_dados.last()).vr_nrctremp := 131509;
    v_dados(v_dados.last()).vr_vllanmto := 109.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 689947;
    v_dados(v_dados.last()).vr_nrctremp := 179402;
    v_dados(v_dados.last()).vr_vllanmto := 109.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361194;
    v_dados(v_dados.last()).vr_nrctremp := 85779;
    v_dados(v_dados.last()).vr_vllanmto := 110.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 506893;
    v_dados(v_dados.last()).vr_nrctremp := 88226;
    v_dados(v_dados.last()).vr_vllanmto := 110.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9377;
    v_dados(v_dados.last()).vr_nrctremp := 170013;
    v_dados(v_dados.last()).vr_vllanmto := 110.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 257214;
    v_dados(v_dados.last()).vr_nrctremp := 146417;
    v_dados(v_dados.last()).vr_vllanmto := 110.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := 110.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 145982;
    v_dados(v_dados.last()).vr_vllanmto := 111.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464511;
    v_dados(v_dados.last()).vr_nrctremp := 70772;
    v_dados(v_dados.last()).vr_vllanmto := 111.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 383007;
    v_dados(v_dados.last()).vr_nrctremp := 104758;
    v_dados(v_dados.last()).vr_vllanmto := 112.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66940;
    v_dados(v_dados.last()).vr_nrctremp := 142854;
    v_dados(v_dados.last()).vr_vllanmto := 113.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 112773;
    v_dados(v_dados.last()).vr_vllanmto := 113.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214990;
    v_dados(v_dados.last()).vr_nrctremp := 133412;
    v_dados(v_dados.last()).vr_vllanmto := 114;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180661;
    v_dados(v_dados.last()).vr_nrctremp := 51500;
    v_dados(v_dados.last()).vr_vllanmto := 114.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323004;
    v_dados(v_dados.last()).vr_nrctremp := 148733;
    v_dados(v_dados.last()).vr_vllanmto := 114.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 177890;
    v_dados(v_dados.last()).vr_nrctremp := 52933;
    v_dados(v_dados.last()).vr_vllanmto := 115.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 617482;
    v_dados(v_dados.last()).vr_nrctremp := 137775;
    v_dados(v_dados.last()).vr_vllanmto := 115.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 103963;
    v_dados(v_dados.last()).vr_vllanmto := 115.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462020;
    v_dados(v_dados.last()).vr_nrctremp := 144951;
    v_dados(v_dados.last()).vr_vllanmto := 115.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 125819;
    v_dados(v_dados.last()).vr_vllanmto := 116.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350664;
    v_dados(v_dados.last()).vr_nrctremp := 125552;
    v_dados(v_dados.last()).vr_vllanmto := 116.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247618;
    v_dados(v_dados.last()).vr_nrctremp := 98518;
    v_dados(v_dados.last()).vr_vllanmto := 117.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 245437;
    v_dados(v_dados.last()).vr_nrctremp := 92577;
    v_dados(v_dados.last()).vr_vllanmto := 117.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445550;
    v_dados(v_dados.last()).vr_nrctremp := 113391;
    v_dados(v_dados.last()).vr_vllanmto := 118.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 50075;
    v_dados(v_dados.last()).vr_nrctremp := 177866;
    v_dados(v_dados.last()).vr_vllanmto := 118.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 56744;
    v_dados(v_dados.last()).vr_vllanmto := 118.78;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71757;
    v_dados(v_dados.last()).vr_nrctremp := 136891;
    v_dados(v_dados.last()).vr_vllanmto := 118.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189499;
    v_dados(v_dados.last()).vr_nrctremp := 122002;
    v_dados(v_dados.last()).vr_vllanmto := 119.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170488;
    v_dados(v_dados.last()).vr_nrctremp := 149204;
    v_dados(v_dados.last()).vr_vllanmto := 119.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66826;
    v_dados(v_dados.last()).vr_nrctremp := 162870;
    v_dados(v_dados.last()).vr_vllanmto := 119.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 296201;
    v_dados(v_dados.last()).vr_nrctremp := 108368;
    v_dados(v_dados.last()).vr_vllanmto := 120.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 164001;
    v_dados(v_dados.last()).vr_vllanmto := 121.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133792;
    v_dados(v_dados.last()).vr_vllanmto := 121.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149927;
    v_dados(v_dados.last()).vr_vllanmto := 121.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395773;
    v_dados(v_dados.last()).vr_nrctremp := 53179;
    v_dados(v_dados.last()).vr_vllanmto := 122.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350745;
    v_dados(v_dados.last()).vr_nrctremp := 157549;
    v_dados(v_dados.last()).vr_vllanmto := 122.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 672130;
    v_dados(v_dados.last()).vr_nrctremp := 166378;
    v_dados(v_dados.last()).vr_vllanmto := 122.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 435007;
    v_dados(v_dados.last()).vr_nrctremp := 162711;
    v_dados(v_dados.last()).vr_vllanmto := 122.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266906;
    v_dados(v_dados.last()).vr_nrctremp := 60166;
    v_dados(v_dados.last()).vr_vllanmto := 122.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272116;
    v_dados(v_dados.last()).vr_nrctremp := 146978;
    v_dados(v_dados.last()).vr_vllanmto := 122.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 152069;
    v_dados(v_dados.last()).vr_vllanmto := 122.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142242;
    v_dados(v_dados.last()).vr_vllanmto := 123.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 130923;
    v_dados(v_dados.last()).vr_nrctremp := 150081;
    v_dados(v_dados.last()).vr_vllanmto := 124.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289485;
    v_dados(v_dados.last()).vr_nrctremp := 134062;
    v_dados(v_dados.last()).vr_vllanmto := 124.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 96352;
    v_dados(v_dados.last()).vr_vllanmto := 125.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349798;
    v_dados(v_dados.last()).vr_nrctremp := 127767;
    v_dados(v_dados.last()).vr_vllanmto := 125.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144045;
    v_dados(v_dados.last()).vr_nrctremp := 158389;
    v_dados(v_dados.last()).vr_vllanmto := 125.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92029;
    v_dados(v_dados.last()).vr_nrctremp := 123921;
    v_dados(v_dados.last()).vr_vllanmto := 126.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66877;
    v_dados(v_dados.last()).vr_nrctremp := 139636;
    v_dados(v_dados.last()).vr_vllanmto := 126.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503584;
    v_dados(v_dados.last()).vr_nrctremp := 102245;
    v_dados(v_dados.last()).vr_vllanmto := 127.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 134546;
    v_dados(v_dados.last()).vr_nrctremp := 133160;
    v_dados(v_dados.last()).vr_vllanmto := 127.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183202;
    v_dados(v_dados.last()).vr_nrctremp := 134827;
    v_dados(v_dados.last()).vr_vllanmto := 127.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143367;
    v_dados(v_dados.last()).vr_nrctremp := 66735;
    v_dados(v_dados.last()).vr_vllanmto := 128.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 573957;
    v_dados(v_dados.last()).vr_nrctremp := 119378;
    v_dados(v_dados.last()).vr_vllanmto := 129.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 431133;
    v_dados(v_dados.last()).vr_nrctremp := 135052;
    v_dados(v_dados.last()).vr_vllanmto := 130.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 117009;
    v_dados(v_dados.last()).vr_vllanmto := 130.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168491;
    v_dados(v_dados.last()).vr_nrctremp := 92472;
    v_dados(v_dados.last()).vr_vllanmto := 130.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95257;
    v_dados(v_dados.last()).vr_nrctremp := 114045;
    v_dados(v_dados.last()).vr_vllanmto := 131.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673854;
    v_dados(v_dados.last()).vr_nrctremp := 167201;
    v_dados(v_dados.last()).vr_vllanmto := 131.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 131.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288535;
    v_dados(v_dados.last()).vr_nrctremp := 98543;
    v_dados(v_dados.last()).vr_vllanmto := 131.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := 131.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141207;
    v_dados(v_dados.last()).vr_vllanmto := 132.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 133373;
    v_dados(v_dados.last()).vr_vllanmto := 132.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143897;
    v_dados(v_dados.last()).vr_vllanmto := 132.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145742;
    v_dados(v_dados.last()).vr_nrctremp := 162707;
    v_dados(v_dados.last()).vr_vllanmto := 132.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 343196;
    v_dados(v_dados.last()).vr_nrctremp := 132150;
    v_dados(v_dados.last()).vr_vllanmto := 133.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187500;
    v_dados(v_dados.last()).vr_nrctremp := 85157;
    v_dados(v_dados.last()).vr_vllanmto := 133.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66869;
    v_dados(v_dados.last()).vr_nrctremp := 165825;
    v_dados(v_dados.last()).vr_vllanmto := 134.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288730;
    v_dados(v_dados.last()).vr_nrctremp := 80332;
    v_dados(v_dados.last()).vr_vllanmto := 134.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 21539;
    v_dados(v_dados.last()).vr_nrctremp := 95890;
    v_dados(v_dados.last()).vr_vllanmto := 134.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67245;
    v_dados(v_dados.last()).vr_nrctremp := 164725;
    v_dados(v_dados.last()).vr_vllanmto := 136.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292206;
    v_dados(v_dados.last()).vr_nrctremp := 170286;
    v_dados(v_dados.last()).vr_vllanmto := 136.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 164615;
    v_dados(v_dados.last()).vr_nrctremp := 92827;
    v_dados(v_dados.last()).vr_vllanmto := 136.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 7145;
    v_dados(v_dados.last()).vr_nrctremp := 54314;
    v_dados(v_dados.last()).vr_vllanmto := 136.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 121365;
    v_dados(v_dados.last()).vr_vllanmto := 137.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 165756;
    v_dados(v_dados.last()).vr_vllanmto := 137.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189499;
    v_dados(v_dados.last()).vr_nrctremp := 121998;
    v_dados(v_dados.last()).vr_vllanmto := 137.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 106976;
    v_dados(v_dados.last()).vr_vllanmto := 139.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329169;
    v_dados(v_dados.last()).vr_nrctremp := 51801;
    v_dados(v_dados.last()).vr_vllanmto := 140.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 683221;
    v_dados(v_dados.last()).vr_nrctremp := 174820;
    v_dados(v_dados.last()).vr_vllanmto := 141.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 128858;
    v_dados(v_dados.last()).vr_vllanmto := 141.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290785;
    v_dados(v_dados.last()).vr_nrctremp := 50930;
    v_dados(v_dados.last()).vr_vllanmto := 145.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193518;
    v_dados(v_dados.last()).vr_nrctremp := 91698;
    v_dados(v_dados.last()).vr_vllanmto := 145.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184586;
    v_dados(v_dados.last()).vr_nrctremp := 136806;
    v_dados(v_dados.last()).vr_vllanmto := 146.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 487090;
    v_dados(v_dados.last()).vr_nrctremp := 135302;
    v_dados(v_dados.last()).vr_vllanmto := 146.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207195;
    v_dados(v_dados.last()).vr_nrctremp := 129934;
    v_dados(v_dados.last()).vr_vllanmto := 147.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298980;
    v_dados(v_dados.last()).vr_nrctremp := 137319;
    v_dados(v_dados.last()).vr_vllanmto := 147.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192694;
    v_dados(v_dados.last()).vr_nrctremp := 175750;
    v_dados(v_dados.last()).vr_vllanmto := 147.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 99991;
    v_dados(v_dados.last()).vr_vllanmto := 147.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25887;
    v_dados(v_dados.last()).vr_nrctremp := 148839;
    v_dados(v_dados.last()).vr_vllanmto := 148.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 227137;
    v_dados(v_dados.last()).vr_nrctremp := 140763;
    v_dados(v_dados.last()).vr_vllanmto := 148.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521256;
    v_dados(v_dados.last()).vr_nrctremp := 92946;
    v_dados(v_dados.last()).vr_vllanmto := 148.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 219550;
    v_dados(v_dados.last()).vr_nrctremp := 74936;
    v_dados(v_dados.last()).vr_vllanmto := 149.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278238;
    v_dados(v_dados.last()).vr_nrctremp := 65409;
    v_dados(v_dados.last()).vr_vllanmto := 149.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188344;
    v_dados(v_dados.last()).vr_nrctremp := 82650;
    v_dados(v_dados.last()).vr_vllanmto := 149.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96423;
    v_dados(v_dados.last()).vr_nrctremp := 63486;
    v_dados(v_dados.last()).vr_vllanmto := 150.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133556;
    v_dados(v_dados.last()).vr_vllanmto := 150.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 278114;
    v_dados(v_dados.last()).vr_nrctremp := 167193;
    v_dados(v_dados.last()).vr_vllanmto := 151.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 562092;
    v_dados(v_dados.last()).vr_nrctremp := 141171;
    v_dados(v_dados.last()).vr_vllanmto := 160.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145319;
    v_dados(v_dados.last()).vr_nrctremp := 113718;
    v_dados(v_dados.last()).vr_vllanmto := 153.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87939;
    v_dados(v_dados.last()).vr_nrctremp := 107291;
    v_dados(v_dados.last()).vr_vllanmto := 154.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274321;
    v_dados(v_dados.last()).vr_nrctremp := 166688;
    v_dados(v_dados.last()).vr_vllanmto := 155.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 123153;
    v_dados(v_dados.last()).vr_nrctremp := 143679;
    v_dados(v_dados.last()).vr_vllanmto := 2271.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129898;
    v_dados(v_dados.last()).vr_vllanmto := 156.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 157830;
    v_dados(v_dados.last()).vr_nrctremp := 78266;
    v_dados(v_dados.last()).vr_vllanmto := 157.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 407003;
    v_dados(v_dados.last()).vr_nrctremp := 180030;
    v_dados(v_dados.last()).vr_vllanmto := 157.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 33472;
    v_dados(v_dados.last()).vr_nrctremp := 172807;
    v_dados(v_dados.last()).vr_vllanmto := 158.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 255300;
    v_dados(v_dados.last()).vr_nrctremp := 57141;
    v_dados(v_dados.last()).vr_vllanmto := 159.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 629090;
    v_dados(v_dados.last()).vr_nrctremp := 171164;
    v_dados(v_dados.last()).vr_vllanmto := 159.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 616346;
    v_dados(v_dados.last()).vr_nrctremp := 137941;
    v_dados(v_dados.last()).vr_vllanmto := 162.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136050;
    v_dados(v_dados.last()).vr_nrctremp := 168147;
    v_dados(v_dados.last()).vr_vllanmto := 162.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 175455;
    v_dados(v_dados.last()).vr_nrctremp := 167766;
    v_dados(v_dados.last()).vr_vllanmto := 162.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143294;
    v_dados(v_dados.last()).vr_nrctremp := 106135;
    v_dados(v_dados.last()).vr_vllanmto := 162.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295159;
    v_dados(v_dados.last()).vr_nrctremp := 72190;
    v_dados(v_dados.last()).vr_vllanmto := 162.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66800;
    v_dados(v_dados.last()).vr_nrctremp := 138302;
    v_dados(v_dados.last()).vr_vllanmto := 165.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 547620;
    v_dados(v_dados.last()).vr_nrctremp := 106526;
    v_dados(v_dados.last()).vr_vllanmto := 165.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66605;
    v_dados(v_dados.last()).vr_nrctremp := 150339;
    v_dados(v_dados.last()).vr_vllanmto := 165.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493341;
    v_dados(v_dados.last()).vr_nrctremp := 142973;
    v_dados(v_dados.last()).vr_vllanmto := 3270.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103861;
    v_dados(v_dados.last()).vr_nrctremp := 134554;
    v_dados(v_dados.last()).vr_vllanmto := 167.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187402;
    v_dados(v_dados.last()).vr_nrctremp := 118241;
    v_dados(v_dados.last()).vr_vllanmto := 168.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276286;
    v_dados(v_dados.last()).vr_nrctremp := 176821;
    v_dados(v_dados.last()).vr_vllanmto := 168.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541567;
    v_dados(v_dados.last()).vr_nrctremp := 162515;
    v_dados(v_dados.last()).vr_vllanmto := 169.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142565;
    v_dados(v_dados.last()).vr_nrctremp := 157479;
    v_dados(v_dados.last()).vr_vllanmto := 170.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541303;
    v_dados(v_dados.last()).vr_nrctremp := 103125;
    v_dados(v_dados.last()).vr_vllanmto := 170.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240982;
    v_dados(v_dados.last()).vr_nrctremp := 176802;
    v_dados(v_dados.last()).vr_vllanmto := 171.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44423;
    v_dados(v_dados.last()).vr_nrctremp := 117780;
    v_dados(v_dados.last()).vr_vllanmto := 171.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143367;
    v_dados(v_dados.last()).vr_nrctremp := 91148;
    v_dados(v_dados.last()).vr_vllanmto := 171.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92428;
    v_dados(v_dados.last()).vr_nrctremp := 94314;
    v_dados(v_dados.last()).vr_vllanmto := 173.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 32123;
    v_dados(v_dados.last()).vr_nrctremp := 105763;
    v_dados(v_dados.last()).vr_vllanmto := 173.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539791;
    v_dados(v_dados.last()).vr_nrctremp := 102357;
    v_dados(v_dados.last()).vr_vllanmto := 174.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 174.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114640;
    v_dados(v_dados.last()).vr_vllanmto := 175.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132847;
    v_dados(v_dados.last()).vr_vllanmto := 176.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 177.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 291854;
    v_dados(v_dados.last()).vr_nrctremp := 162601;
    v_dados(v_dados.last()).vr_vllanmto := 179.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185477;
    v_dados(v_dados.last()).vr_nrctremp := 168703;
    v_dados(v_dados.last()).vr_vllanmto := 181.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110555;
    v_dados(v_dados.last()).vr_vllanmto := 182.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 182.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 72476;
    v_dados(v_dados.last()).vr_vllanmto := 182.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115869;
    v_dados(v_dados.last()).vr_vllanmto := 182.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 285072;
    v_dados(v_dados.last()).vr_nrctremp := 83786;
    v_dados(v_dados.last()).vr_vllanmto := 183.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289086;
    v_dados(v_dados.last()).vr_nrctremp := 179357;
    v_dados(v_dados.last()).vr_vllanmto := 184.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 189.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 189.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188620;
    v_dados(v_dados.last()).vr_nrctremp := 90707;
    v_dados(v_dados.last()).vr_vllanmto := 190.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 173188;
    v_dados(v_dados.last()).vr_vllanmto := 190.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426610;
    v_dados(v_dados.last()).vr_nrctremp := 80116;
    v_dados(v_dados.last()).vr_vllanmto := 194.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120073;
    v_dados(v_dados.last()).vr_nrctremp := 157080;
    v_dados(v_dados.last()).vr_vllanmto := 195.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 128333;
    v_dados(v_dados.last()).vr_nrctremp := 174807;
    v_dados(v_dados.last()).vr_vllanmto := 196.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561886;
    v_dados(v_dados.last()).vr_nrctremp := 113419;
    v_dados(v_dados.last()).vr_vllanmto := 197.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 652881;
    v_dados(v_dados.last()).vr_nrctremp := 171328;
    v_dados(v_dados.last()).vr_vllanmto := 203.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 134611;
    v_dados(v_dados.last()).vr_vllanmto := 204.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192350;
    v_dados(v_dados.last()).vr_nrctremp := 112063;
    v_dados(v_dados.last()).vr_vllanmto := 205.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192520;
    v_dados(v_dados.last()).vr_nrctremp := 165359;
    v_dados(v_dados.last()).vr_vllanmto := 206.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 151738;
    v_dados(v_dados.last()).vr_vllanmto := 209.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142921;
    v_dados(v_dados.last()).vr_nrctremp := 75052;
    v_dados(v_dados.last()).vr_vllanmto := 211.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172022;
    v_dados(v_dados.last()).vr_nrctremp := 109017;
    v_dados(v_dados.last()).vr_vllanmto := 214.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 177881;
    v_dados(v_dados.last()).vr_nrctremp := 177822;
    v_dados(v_dados.last()).vr_vllanmto := 215.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 123203;
    v_dados(v_dados.last()).vr_vllanmto := 215.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91189;
    v_dados(v_dados.last()).vr_nrctremp := 84902;
    v_dados(v_dados.last()).vr_vllanmto := 217.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 115984;
    v_dados(v_dados.last()).vr_vllanmto := 218.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68616;
    v_dados(v_dados.last()).vr_nrctremp := 178194;
    v_dados(v_dados.last()).vr_vllanmto := 219.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 219.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 257214;
    v_dados(v_dados.last()).vr_nrctremp := 145047;
    v_dados(v_dados.last()).vr_vllanmto := 221.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 223.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 85561;
    v_dados(v_dados.last()).vr_nrctremp := 176254;
    v_dados(v_dados.last()).vr_vllanmto := 225.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68039;
    v_dados(v_dados.last()).vr_nrctremp := 51124;
    v_dados(v_dados.last()).vr_vllanmto := 228.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319880;
    v_dados(v_dados.last()).vr_nrctremp := 171064;
    v_dados(v_dados.last()).vr_vllanmto := 230.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215864;
    v_dados(v_dados.last()).vr_nrctremp := 57728;
    v_dados(v_dados.last()).vr_vllanmto := 232.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 111511;
    v_dados(v_dados.last()).vr_vllanmto := 233.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116530;
    v_dados(v_dados.last()).vr_nrctremp := 67611;
    v_dados(v_dados.last()).vr_vllanmto := 234.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92410;
    v_dados(v_dados.last()).vr_nrctremp := 170991;
    v_dados(v_dados.last()).vr_vllanmto := 235.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 90393;
    v_dados(v_dados.last()).vr_vllanmto := 238;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116491;
    v_dados(v_dados.last()).vr_nrctremp := 114060;
    v_dados(v_dados.last()).vr_vllanmto := 241.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441376;
    v_dados(v_dados.last()).vr_nrctremp := 62504;
    v_dados(v_dados.last()).vr_vllanmto := 242.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148221;
    v_dados(v_dados.last()).vr_vllanmto := 245.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135768;
    v_dados(v_dados.last()).vr_vllanmto := 245.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 582042;
    v_dados(v_dados.last()).vr_nrctremp := 166819;
    v_dados(v_dados.last()).vr_vllanmto := 248.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 178763;
    v_dados(v_dados.last()).vr_vllanmto := 254.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 255.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154547;
    v_dados(v_dados.last()).vr_nrctremp := 104777;
    v_dados(v_dados.last()).vr_vllanmto := 255.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188433;
    v_dados(v_dados.last()).vr_nrctremp := 176875;
    v_dados(v_dados.last()).vr_vllanmto := 257.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154512;
    v_dados(v_dados.last()).vr_nrctremp := 112081;
    v_dados(v_dados.last()).vr_vllanmto := 258.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167495;
    v_dados(v_dados.last()).vr_nrctremp := 179272;
    v_dados(v_dados.last()).vr_vllanmto := 262.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31275;
    v_dados(v_dados.last()).vr_nrctremp := 162267;
    v_dados(v_dados.last()).vr_vllanmto := 267.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 270.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662380;
    v_dados(v_dados.last()).vr_nrctremp := 163482;
    v_dados(v_dados.last()).vr_vllanmto := 270.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 101588;
    v_dados(v_dados.last()).vr_vllanmto := 272.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 573027;
    v_dados(v_dados.last()).vr_nrctremp := 121298;
    v_dados(v_dados.last()).vr_vllanmto := 275.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90964;
    v_dados(v_dados.last()).vr_nrctremp := 151867;
    v_dados(v_dados.last()).vr_vllanmto := 238.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189693;
    v_dados(v_dados.last()).vr_nrctremp := 116388;
    v_dados(v_dados.last()).vr_vllanmto := 281.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 84085;
    v_dados(v_dados.last()).vr_nrctremp := 51903;
    v_dados(v_dados.last()).vr_vllanmto := 281.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150550;
    v_dados(v_dados.last()).vr_nrctremp := 146498;
    v_dados(v_dados.last()).vr_vllanmto := 283.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264032;
    v_dados(v_dados.last()).vr_nrctremp := 107394;
    v_dados(v_dados.last()).vr_vllanmto := 284.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 211524;
    v_dados(v_dados.last()).vr_nrctremp := 107457;
    v_dados(v_dados.last()).vr_vllanmto := 286.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 93695;
    v_dados(v_dados.last()).vr_vllanmto := 28529.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 52277;
    v_dados(v_dados.last()).vr_vllanmto := 323.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 142019;
    v_dados(v_dados.last()).vr_vllanmto := 332.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 572314;
    v_dados(v_dados.last()).vr_nrctremp := 179477;
    v_dados(v_dados.last()).vr_vllanmto := 337.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 339.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 13897;
    v_dados(v_dados.last()).vr_nrctremp := 110414;
    v_dados(v_dados.last()).vr_vllanmto := 344.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 677132;
    v_dados(v_dados.last()).vr_nrctremp := 170004;
    v_dados(v_dados.last()).vr_vllanmto := 354.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 88711;
    v_dados(v_dados.last()).vr_vllanmto := 361.48;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 685739;
    v_dados(v_dados.last()).vr_nrctremp := 176567;
    v_dados(v_dados.last()).vr_vllanmto := 368.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 143813;
    v_dados(v_dados.last()).vr_vllanmto := 380.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141976;
    v_dados(v_dados.last()).vr_nrctremp := 109459;
    v_dados(v_dados.last()).vr_vllanmto := 383.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

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
