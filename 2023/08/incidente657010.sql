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
  v_dados(v_dados.last()).vr_nrdconta := 499196;
  v_dados(v_dados.last()).vr_nrctremp := 359792;
  v_dados(v_dados.last()).vr_vllanmto := 52.36;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575046;
  v_dados(v_dados.last()).vr_nrctremp := 383395;
  v_dados(v_dados.last()).vr_vllanmto := 76.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 575186;
  v_dados(v_dados.last()).vr_nrctremp := 314780;
  v_dados(v_dados.last()).vr_vllanmto := 28;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 771511;
  v_dados(v_dados.last()).vr_nrctremp := 367096;
  v_dados(v_dados.last()).vr_vllanmto := 2624.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 809560;
  v_dados(v_dados.last()).vr_nrctremp := 381601;
  v_dados(v_dados.last()).vr_vllanmto := 66.18;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 839140;
  v_dados(v_dados.last()).vr_nrctremp := 265168;
  v_dados(v_dados.last()).vr_vllanmto := 95.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 908290;
  v_dados(v_dados.last()).vr_nrctremp := 320031;
  v_dados(v_dados.last()).vr_vllanmto := 121.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 934283;
  v_dados(v_dados.last()).vr_nrctremp := 353980;
  v_dados(v_dados.last()).vr_vllanmto := 921.68;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 987905;
  v_dados(v_dados.last()).vr_nrctremp := 311566;
  v_dados(v_dados.last()).vr_vllanmto := 841.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 989231;
  v_dados(v_dados.last()).vr_nrctremp := 307718;
  v_dados(v_dados.last()).vr_vllanmto := 74.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1033360;
  v_dados(v_dados.last()).vr_nrctremp := 354959;
  v_dados(v_dados.last()).vr_vllanmto := 28.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1034634;
  v_dados(v_dados.last()).vr_nrctremp := 320181;
  v_dados(v_dados.last()).vr_vllanmto := 150.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1069217;
  v_dados(v_dados.last()).vr_nrctremp := 338555;
  v_dados(v_dados.last()).vr_vllanmto := 230.05;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1090607;
  v_dados(v_dados.last()).vr_nrctremp := 339567;
  v_dados(v_dados.last()).vr_vllanmto := 79.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 1156462;
  v_dados(v_dados.last()).vr_nrctremp := 384151;
  v_dados(v_dados.last()).vr_vllanmto := 194.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 14786036;
  v_dados(v_dados.last()).vr_nrctremp := 378156;
  v_dados(v_dados.last()).vr_vllanmto := 95.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16227085;
  v_dados(v_dados.last()).vr_nrctremp := 441354;
  v_dados(v_dados.last()).vr_vllanmto := 29.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 2;
  v_dados(v_dados.last()).vr_nrdconta := 16616294;
  v_dados(v_dados.last()).vr_nrctremp := 453566;
  v_dados(v_dados.last()).vr_vllanmto := 60.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 90530;
  v_dados(v_dados.last()).vr_nrctremp := 494717;
  v_dados(v_dados.last()).vr_vllanmto := 2359.6;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 532169;
  v_dados(v_dados.last()).vr_nrctremp := 632666;
  v_dados(v_dados.last()).vr_vllanmto := 21.33;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 708321;
  v_dados(v_dados.last()).vr_nrctremp := 638930;
  v_dados(v_dados.last()).vr_vllanmto := 21.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 792446;
  v_dados(v_dados.last()).vr_nrctremp := 237922;
  v_dados(v_dados.last()).vr_vllanmto := 6125.18;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1026100;
  v_dados(v_dados.last()).vr_nrctremp := 425701;
  v_dados(v_dados.last()).vr_vllanmto := 16.98;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1981765;
  v_dados(v_dados.last()).vr_nrctremp := 384467;
  v_dados(v_dados.last()).vr_vllanmto := 261.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2922851;
  v_dados(v_dados.last()).vr_nrctremp := 555897;
  v_dados(v_dados.last()).vr_vllanmto := 38.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14559161;
  v_dados(v_dados.last()).vr_nrctremp := 564202;
  v_dados(v_dados.last()).vr_vllanmto := 53.87;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 22560;
  v_dados(v_dados.last()).vr_nrctremp := 222572;
  v_dados(v_dados.last()).vr_vllanmto := 65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 31682;
  v_dados(v_dados.last()).vr_nrctremp := 91212;
  v_dados(v_dados.last()).vr_vllanmto := 129.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 59382;
  v_dados(v_dados.last()).vr_nrctremp := 264260;
  v_dados(v_dados.last()).vr_vllanmto := 119.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 61751;
  v_dados(v_dados.last()).vr_nrctremp := 202617;
  v_dados(v_dados.last()).vr_vllanmto := 143.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 94730;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 64.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 101770;
  v_dados(v_dados.last()).vr_nrctremp := 56372;
  v_dados(v_dados.last()).vr_vllanmto := 49.69;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116491;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 232.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 125024;
  v_dados(v_dados.last()).vr_nrctremp := 261341;
  v_dados(v_dados.last()).vr_vllanmto := 14.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 128333;
  v_dados(v_dados.last()).vr_nrctremp := 174807;
  v_dados(v_dados.last()).vr_vllanmto := 167.67;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129410;
  v_dados(v_dados.last()).vr_nrctremp := 158870;
  v_dados(v_dados.last()).vr_vllanmto := 250.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 132187;
  v_dados(v_dados.last()).vr_nrctremp := 113349;
  v_dados(v_dados.last()).vr_vllanmto := 207.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 956.87;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149764;
  v_dados(v_dados.last()).vr_nrctremp := 96325;
  v_dados(v_dados.last()).vr_vllanmto := 61.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156272;
  v_dados(v_dados.last()).vr_nrctremp := 210406;
  v_dados(v_dados.last()).vr_vllanmto := 65.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186805;
  v_dados(v_dados.last()).vr_nrctremp := 63844;
  v_dados(v_dados.last()).vr_vllanmto := 68.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 248312;
  v_dados(v_dados.last()).vr_nrctremp := 146804;
  v_dados(v_dados.last()).vr_vllanmto := 1936.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 199788;
  v_dados(v_dados.last()).vr_nrctremp := 164878;
  v_dados(v_dados.last()).vr_vllanmto := 1403.12;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264920;
  v_dados(v_dados.last()).vr_nrctremp := 142353;
  v_dados(v_dados.last()).vr_vllanmto := 73.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 273309;
  v_dados(v_dados.last()).vr_nrctremp := 197758;
  v_dados(v_dados.last()).vr_vllanmto := 55.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 291854;
  v_dados(v_dados.last()).vr_nrctremp := 162601;
  v_dados(v_dados.last()).vr_vllanmto := 212.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 316237;
  v_dados(v_dados.last()).vr_nrctremp := 76421;
  v_dados(v_dados.last()).vr_vllanmto := 37.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 320935;
  v_dados(v_dados.last()).vr_nrctremp := 231053;
  v_dados(v_dados.last()).vr_vllanmto := 1710.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328014;
  v_dados(v_dados.last()).vr_nrctremp := 281073;
  v_dados(v_dados.last()).vr_vllanmto := 12.8;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 330248;
  v_dados(v_dados.last()).vr_nrctremp := 172256;
  v_dados(v_dados.last()).vr_vllanmto := 293.92;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 329380;
  v_dados(v_dados.last()).vr_nrctremp := 250868;
  v_dados(v_dados.last()).vr_vllanmto := 36.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 329380;
  v_dados(v_dados.last()).vr_nrctremp := 262742;
  v_dados(v_dados.last()).vr_vllanmto := 18.49;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 344192;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 98.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 354325;
  v_dados(v_dados.last()).vr_nrctremp := 241840;
  v_dados(v_dados.last()).vr_vllanmto := 34.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 360961;
  v_dados(v_dados.last()).vr_nrctremp := 151569;
  v_dados(v_dados.last()).vr_vllanmto := 15.75;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 376744;
  v_dados(v_dados.last()).vr_nrctremp := 78331;
  v_dados(v_dados.last()).vr_vllanmto := 59.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 383007;
  v_dados(v_dados.last()).vr_nrctremp := 104758;
  v_dados(v_dados.last()).vr_vllanmto := 109.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 186376;
  v_dados(v_dados.last()).vr_vllanmto := 359.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 517399;
  v_dados(v_dados.last()).vr_nrctremp := 262464;
  v_dados(v_dados.last()).vr_vllanmto := 16.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524123;
  v_dados(v_dados.last()).vr_nrctremp := 94749;
  v_dados(v_dados.last()).vr_vllanmto := 454.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524905;
  v_dados(v_dados.last()).vr_nrctremp := 95213;
  v_dados(v_dados.last()).vr_vllanmto := 155.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 106976;
  v_dados(v_dados.last()).vr_vllanmto := 45.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548138;
  v_dados(v_dados.last()).vr_nrctremp := 128092;
  v_dados(v_dados.last()).vr_vllanmto := 1995.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 563498;
  v_dados(v_dados.last()).vr_nrctremp := 198125;
  v_dados(v_dados.last()).vr_vllanmto := 87.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 565849;
  v_dados(v_dados.last()).vr_nrctremp := 228840;
  v_dados(v_dados.last()).vr_vllanmto := 1601.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 577120;
  v_dados(v_dados.last()).vr_nrctremp := 199246;
  v_dados(v_dados.last()).vr_vllanmto := 111.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 589934;
  v_dados(v_dados.last()).vr_nrctremp := 275806;
  v_dados(v_dados.last()).vr_vllanmto := 107.3;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 598410;
  v_dados(v_dados.last()).vr_nrctremp := 172974;
  v_dados(v_dados.last()).vr_vllanmto := 510.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 610895;
  v_dados(v_dados.last()).vr_nrctremp := 227415;
  v_dados(v_dados.last()).vr_vllanmto := 167.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 614610;
  v_dados(v_dados.last()).vr_nrctremp := 210061;
  v_dados(v_dados.last()).vr_vllanmto := 1786.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 625566;
  v_dados(v_dados.last()).vr_nrctremp := 196091;
  v_dados(v_dados.last()).vr_vllanmto := 10.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 661686;
  v_dados(v_dados.last()).vr_nrctremp := 191756;
  v_dados(v_dados.last()).vr_vllanmto := 796.4;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 654485;
  v_dados(v_dados.last()).vr_nrctremp := 193159;
  v_dados(v_dados.last()).vr_vllanmto := 33.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 663930;
  v_dados(v_dados.last()).vr_nrctremp := 304608;
  v_dados(v_dados.last()).vr_vllanmto := 13.81;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 673854;
  v_dados(v_dados.last()).vr_nrctremp := 167201;
  v_dados(v_dados.last()).vr_vllanmto := 2669.2;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 683221;
  v_dados(v_dados.last()).vr_nrctremp := 174820;
  v_dados(v_dados.last()).vr_vllanmto := 1703.98;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 685739;
  v_dados(v_dados.last()).vr_nrctremp := 176567;
  v_dados(v_dados.last()).vr_vllanmto := 4246.51;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 694762;
  v_dados(v_dados.last()).vr_nrctremp := 246342;
  v_dados(v_dados.last()).vr_vllanmto := 12.14;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 701564;
  v_dados(v_dados.last()).vr_nrctremp := 267305;
  v_dados(v_dados.last()).vr_vllanmto := 20.14;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14792656;
  v_dados(v_dados.last()).vr_nrctremp := 234156;
  v_dados(v_dados.last()).vr_vllanmto := 118.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14771675;
  v_dados(v_dados.last()).vr_nrctremp := 240186;
  v_dados(v_dados.last()).vr_vllanmto := 2166.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14818213;
  v_dados(v_dados.last()).vr_nrctremp := 202999;
  v_dados(v_dados.last()).vr_vllanmto := 14.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 209246;
  v_dados(v_dados.last()).vr_vllanmto := 12.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 238463;
  v_dados(v_dados.last()).vr_vllanmto := 37.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 14967995;
  v_dados(v_dados.last()).vr_nrctremp := 267064;
  v_dados(v_dados.last()).vr_vllanmto := 56.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15440125;
  v_dados(v_dados.last()).vr_nrctremp := 240660;
  v_dados(v_dados.last()).vr_vllanmto := 191.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15759407;
  v_dados(v_dados.last()).vr_nrctremp := 246571;
  v_dados(v_dados.last()).vr_vllanmto := 32.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15685233;
  v_dados(v_dados.last()).vr_nrctremp := 266075;
  v_dados(v_dados.last()).vr_vllanmto := 36.77;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15710530;
  v_dados(v_dados.last()).vr_nrctremp := 288622;
  v_dados(v_dados.last()).vr_vllanmto := 78.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 15940349;
  v_dados(v_dados.last()).vr_nrctremp := 254682;
  v_dados(v_dados.last()).vr_vllanmto := 69.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16553810;
  v_dados(v_dados.last()).vr_nrctremp := 280291;
  v_dados(v_dados.last()).vr_vllanmto := 231.21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 16465512;
  v_dados(v_dados.last()).vr_nrctremp := 278758;
  v_dados(v_dados.last()).vr_vllanmto := 39.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 214558;
  v_dados(v_dados.last()).vr_nrctremp := 49549;
  v_dados(v_dados.last()).vr_vllanmto := 100.76;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 445940;
  v_dados(v_dados.last()).vr_nrctremp := 82037;
  v_dados(v_dados.last()).vr_vllanmto := 102.24;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14113449;
  v_dados(v_dados.last()).vr_nrctremp := 78452;
  v_dados(v_dados.last()).vr_vllanmto := 27.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14140888;
  v_dados(v_dados.last()).vr_nrctremp := 106454;
  v_dados(v_dados.last()).vr_vllanmto := 22.54;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14285703;
  v_dados(v_dados.last()).vr_nrctremp := 74338;
  v_dados(v_dados.last()).vr_vllanmto := 54.21;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14254085;
  v_dados(v_dados.last()).vr_nrctremp := 74207;
  v_dados(v_dados.last()).vr_vllanmto := 20;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14254085;
  v_dados(v_dados.last()).vr_nrctremp := 76257;
  v_dados(v_dados.last()).vr_vllanmto := 111.11;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14317311;
  v_dados(v_dados.last()).vr_nrctremp := 74294;
  v_dados(v_dados.last()).vr_vllanmto := 83.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 14531607;
  v_dados(v_dados.last()).vr_nrctremp := 85668;
  v_dados(v_dados.last()).vr_vllanmto := 169.65;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15046125;
  v_dados(v_dados.last()).vr_nrctremp := 107538;
  v_dados(v_dados.last()).vr_vllanmto := 77.56;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15245861;
  v_dados(v_dados.last()).vr_nrctremp := 86919;
  v_dados(v_dados.last()).vr_vllanmto := 149.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15894304;
  v_dados(v_dados.last()).vr_nrctremp := 95251;
  v_dados(v_dados.last()).vr_vllanmto := 44.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 7;
  v_dados(v_dados.last()).vr_nrdconta := 15903915;
  v_dados(v_dados.last()).vr_nrctremp := 97640;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73130;
  v_dados(v_dados.last()).vr_nrctremp := 20750;
  v_dados(v_dados.last()).vr_vllanmto := 275.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 82643;
  v_dados(v_dados.last()).vr_nrctremp := 44923;
  v_dados(v_dados.last()).vr_vllanmto := 44.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 83682;
  v_dados(v_dados.last()).vr_nrctremp := 26001;
  v_dados(v_dados.last()).vr_vllanmto := 2918.21;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 86100;
  v_dados(v_dados.last()).vr_nrctremp := 11110;
  v_dados(v_dados.last()).vr_vllanmto := 22.84;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 119946;
  v_dados(v_dados.last()).vr_nrctremp := 46001;
  v_dados(v_dados.last()).vr_vllanmto := 19.93;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 125873;
  v_dados(v_dados.last()).vr_nrctremp := 24290;
  v_dados(v_dados.last()).vr_vllanmto := 49.54;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 127582;
  v_dados(v_dados.last()).vr_nrctremp := 13745;
  v_dados(v_dados.last()).vr_vllanmto := 238.09;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128228;
  v_dados(v_dados.last()).vr_nrctremp := 45777;
  v_dados(v_dados.last()).vr_vllanmto := 47.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 129313;
  v_dados(v_dados.last()).vr_nrctremp := 36634;
  v_dados(v_dados.last()).vr_vllanmto := 168.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 136280;
  v_dados(v_dados.last()).vr_nrctremp := 39751;
  v_dados(v_dados.last()).vr_vllanmto := 134.49;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 137170;
  v_dados(v_dados.last()).vr_nrctremp := 35173;
  v_dados(v_dados.last()).vr_vllanmto := 2588.67;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 142824;
  v_dados(v_dados.last()).vr_nrctremp := 27383;
  v_dados(v_dados.last()).vr_vllanmto := 7859.14;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 154415;
  v_dados(v_dados.last()).vr_nrctremp := 22046;
  v_dados(v_dados.last()).vr_vllanmto := 90.96;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166898;
  v_dados(v_dados.last()).vr_nrctremp := 20193;
  v_dados(v_dados.last()).vr_vllanmto := 68.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184063;
  v_dados(v_dados.last()).vr_nrctremp := 39142;
  v_dados(v_dados.last()).vr_vllanmto := 285.25;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 209775;
  v_dados(v_dados.last()).vr_nrctremp := 46471;
  v_dados(v_dados.last()).vr_vllanmto := 19.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 227838;
  v_dados(v_dados.last()).vr_nrctremp := 41623;
  v_dados(v_dados.last()).vr_vllanmto := 19.52;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 228923;
  v_dados(v_dados.last()).vr_nrctremp := 45377;
  v_dados(v_dados.last()).vr_vllanmto := 92.5;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 15988198;
  v_dados(v_dados.last()).vr_nrctremp := 44283;
  v_dados(v_dados.last()).vr_vllanmto := 2490.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 50024;
  v_dados(v_dados.last()).vr_nrctremp := 41489;
  v_dados(v_dados.last()).vr_vllanmto := 132.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 258369;
  v_dados(v_dados.last()).vr_nrctremp := 87709;
  v_dados(v_dados.last()).vr_vllanmto := 26.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 335690;
  v_dados(v_dados.last()).vr_nrctremp := 77871;
  v_dados(v_dados.last()).vr_vllanmto := 2291.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 14718537;
  v_dados(v_dados.last()).vr_nrctremp := 101639;
  v_dados(v_dados.last()).vr_vllanmto := 18.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 14;
  v_dados(v_dados.last()).vr_nrdconta := 15827607;
  v_dados(v_dados.last()).vr_nrctremp := 107083;
  v_dados(v_dados.last()).vr_vllanmto := 13.4;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3220710;
  v_dados(v_dados.last()).vr_nrctremp := 5348578;
  v_dados(v_dados.last()).vr_vllanmto := 208.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4045645;
  v_dados(v_dados.last()).vr_nrctremp := 4815888;
  v_dados(v_dados.last()).vr_vllanmto := 777.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6819567;
  v_dados(v_dados.last()).vr_nrctremp := 5783710;
  v_dados(v_dados.last()).vr_vllanmto := 2683.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7178565;
  v_dados(v_dados.last()).vr_nrctremp := 4556663;
  v_dados(v_dados.last()).vr_vllanmto := 714.28;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7669437;
  v_dados(v_dados.last()).vr_nrctremp := 2507640;
  v_dados(v_dados.last()).vr_vllanmto := 91.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7914857;
  v_dados(v_dados.last()).vr_nrctremp := 4673930;
  v_dados(v_dados.last()).vr_vllanmto := 67.36;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7966199;
  v_dados(v_dados.last()).vr_nrctremp := 6072351;
  v_dados(v_dados.last()).vr_vllanmto := 13.35;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8034656;
  v_dados(v_dados.last()).vr_nrctremp := 5097439;
  v_dados(v_dados.last()).vr_vllanmto := 130.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8652007;
  v_dados(v_dados.last()).vr_nrctremp := 2507442;
  v_dados(v_dados.last()).vr_vllanmto := 37.47;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8646813;
  v_dados(v_dados.last()).vr_nrctremp := 4510788;
  v_dados(v_dados.last()).vr_vllanmto := 42.03;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8646813;
  v_dados(v_dados.last()).vr_nrctremp := 5436214;
  v_dados(v_dados.last()).vr_vllanmto := 15.79;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9084720;
  v_dados(v_dados.last()).vr_nrctremp := 5566176;
  v_dados(v_dados.last()).vr_vllanmto := 26.12;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9210750;
  v_dados(v_dados.last()).vr_nrctremp := 4338371;
  v_dados(v_dados.last()).vr_vllanmto := 1181.88;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9194371;
  v_dados(v_dados.last()).vr_nrctremp := 3700170;
  v_dados(v_dados.last()).vr_vllanmto := 86.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9348808;
  v_dados(v_dados.last()).vr_nrctremp := 5959615;
  v_dados(v_dados.last()).vr_vllanmto := 29.53;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9543490;
  v_dados(v_dados.last()).vr_nrctremp := 4391966;
  v_dados(v_dados.last()).vr_vllanmto := 85.88;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9666869;
  v_dados(v_dados.last()).vr_nrctremp := 5196774;
  v_dados(v_dados.last()).vr_vllanmto := 47.66;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9660143;
  v_dados(v_dados.last()).vr_nrctremp := 4680083;
  v_dados(v_dados.last()).vr_vllanmto := 169.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9688854;
  v_dados(v_dados.last()).vr_nrctremp := 4934407;
  v_dados(v_dados.last()).vr_vllanmto := 31.13;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9875638;
  v_dados(v_dados.last()).vr_nrctremp := 5414111;
  v_dados(v_dados.last()).vr_vllanmto := 44.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9868925;
  v_dados(v_dados.last()).vr_nrctremp := 3230862;
  v_dados(v_dados.last()).vr_vllanmto := 35.65;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10306749;
  v_dados(v_dados.last()).vr_nrctremp := 5679750;
  v_dados(v_dados.last()).vr_vllanmto := 141.45;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10412670;
  v_dados(v_dados.last()).vr_nrctremp := 4140383;
  v_dados(v_dados.last()).vr_vllanmto := 210.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10317694;
  v_dados(v_dados.last()).vr_nrctremp := 5587986;
  v_dados(v_dados.last()).vr_vllanmto := 80.92;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10675515;
  v_dados(v_dados.last()).vr_nrctremp := 6524795;
  v_dados(v_dados.last()).vr_vllanmto := 15.96;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10885471;
  v_dados(v_dados.last()).vr_nrctremp := 4712416;
  v_dados(v_dados.last()).vr_vllanmto := 1484.66;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10748873;
  v_dados(v_dados.last()).vr_nrctremp := 4640120;
  v_dados(v_dados.last()).vr_vllanmto := 45.57;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10888314;
  v_dados(v_dados.last()).vr_nrctremp := 6266710;
  v_dados(v_dados.last()).vr_vllanmto := 132.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11310480;
  v_dados(v_dados.last()).vr_nrctremp := 6025921;
  v_dados(v_dados.last()).vr_vllanmto := 16.3;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11369248;
  v_dados(v_dados.last()).vr_nrctremp := 3542693;
  v_dados(v_dados.last()).vr_vllanmto := 40.6;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11433779;
  v_dados(v_dados.last()).vr_nrctremp := 5257224;
  v_dados(v_dados.last()).vr_vllanmto := 18.14;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11476516;
  v_dados(v_dados.last()).vr_nrctremp := 6277831;
  v_dados(v_dados.last()).vr_vllanmto := 18.26;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11576537;
  v_dados(v_dados.last()).vr_nrctremp := 4674681;
  v_dados(v_dados.last()).vr_vllanmto := 41.74;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11776340;
  v_dados(v_dados.last()).vr_nrctremp := 3032948;
  v_dados(v_dados.last()).vr_vllanmto := 2248.73;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11773669;
  v_dados(v_dados.last()).vr_nrctremp := 6577307;
  v_dados(v_dados.last()).vr_vllanmto := 208.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11934425;
  v_dados(v_dados.last()).vr_nrctremp := 4573086;
  v_dados(v_dados.last()).vr_vllanmto := 107.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11934425;
  v_dados(v_dados.last()).vr_nrctremp := 4573101;
  v_dados(v_dados.last()).vr_vllanmto := 35.79;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11934425;
  v_dados(v_dados.last()).vr_nrctremp := 4573117;
  v_dados(v_dados.last()).vr_vllanmto := 324.44;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12184390;
  v_dados(v_dados.last()).vr_nrctremp := 4879593;
  v_dados(v_dados.last()).vr_vllanmto := 2261.14;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12127426;
  v_dados(v_dados.last()).vr_nrctremp := 3319430;
  v_dados(v_dados.last()).vr_vllanmto := 115.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12189227;
  v_dados(v_dados.last()).vr_nrctremp := 6289728;
  v_dados(v_dados.last()).vr_vllanmto := 10.33;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12202681;
  v_dados(v_dados.last()).vr_nrctremp := 5753900;
  v_dados(v_dados.last()).vr_vllanmto := 252.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12292095;
  v_dados(v_dados.last()).vr_nrctremp := 5828078;
  v_dados(v_dados.last()).vr_vllanmto := 178.7;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12359980;
  v_dados(v_dados.last()).vr_nrctremp := 5290818;
  v_dados(v_dados.last()).vr_vllanmto := 24.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12425770;
  v_dados(v_dados.last()).vr_nrctremp := 3620293;
  v_dados(v_dados.last()).vr_vllanmto := 9395.16;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12445959;
  v_dados(v_dados.last()).vr_nrctremp := 5622328;
  v_dados(v_dados.last()).vr_vllanmto := 416.5;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 967.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12651443;
  v_dados(v_dados.last()).vr_nrctremp := 4950509;
  v_dados(v_dados.last()).vr_vllanmto := 30.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12710563;
  v_dados(v_dados.last()).vr_nrctremp := 4117414;
  v_dados(v_dados.last()).vr_vllanmto := 22.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12714666;
  v_dados(v_dados.last()).vr_nrctremp := 5916802;
  v_dados(v_dados.last()).vr_vllanmto := 47.86;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739103;
  v_dados(v_dados.last()).vr_nrctremp := 5231445;
  v_dados(v_dados.last()).vr_vllanmto := 1393.48;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12873632;
  v_dados(v_dados.last()).vr_nrctremp := 4085979;
  v_dados(v_dados.last()).vr_vllanmto := 247.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12907227;
  v_dados(v_dados.last()).vr_nrctremp := 5649748;
  v_dados(v_dados.last()).vr_vllanmto := 148.65;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13119478;
  v_dados(v_dados.last()).vr_nrctremp := 4265318;
  v_dados(v_dados.last()).vr_vllanmto := 3930.78;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13820710;
  v_dados(v_dados.last()).vr_nrctremp := 6324934;
  v_dados(v_dados.last()).vr_vllanmto := 92.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13739425;
  v_dados(v_dados.last()).vr_nrctremp := 5531174;
  v_dados(v_dados.last()).vr_vllanmto := 1416.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14289822;
  v_dados(v_dados.last()).vr_nrctremp := 6105999;
  v_dados(v_dados.last()).vr_vllanmto := 118.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 14419394;
  v_dados(v_dados.last()).vr_nrctremp := 5573717;
  v_dados(v_dados.last()).vr_vllanmto := 10.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 15264734;
  v_dados(v_dados.last()).vr_nrctremp := 6627036;
  v_dados(v_dados.last()).vr_vllanmto := 14.86;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80273262;
  v_dados(v_dados.last()).vr_nrctremp := 5897168;
  v_dados(v_dados.last()).vr_vllanmto := 25.21;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80170781;
  v_dados(v_dados.last()).vr_nrctremp := 3472408;
  v_dados(v_dados.last()).vr_vllanmto := 7292.67;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80334768;
  v_dados(v_dados.last()).vr_nrctremp := 3858963;
  v_dados(v_dados.last()).vr_vllanmto := 34.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80337074;
  v_dados(v_dados.last()).vr_nrctremp := 2955519;
  v_dados(v_dados.last()).vr_vllanmto := 14.64;
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
