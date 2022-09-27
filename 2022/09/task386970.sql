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
    v_dados(v_dados.last()).vr_nrdconta := 207497;
    v_dados(v_dados.last()).vr_nrctremp := 51194;
    v_dados(v_dados.last()).vr_vllanmto := 64.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273465;
    v_dados(v_dados.last()).vr_nrctremp := 52180;
    v_dados(v_dados.last()).vr_vllanmto := 22.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160954;
    v_dados(v_dados.last()).vr_nrctremp := 55722;
    v_dados(v_dados.last()).vr_vllanmto := 74.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419834;
    v_dados(v_dados.last()).vr_nrctremp := 55980;
    v_dados(v_dados.last()).vr_vllanmto := 53.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186244;
    v_dados(v_dados.last()).vr_nrctremp := 58233;
    v_dados(v_dados.last()).vr_vllanmto := 21.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 38.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150215;
    v_dados(v_dados.last()).vr_nrctremp := 52249;
    v_dados(v_dados.last()).vr_vllanmto := 574.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 53589;
    v_dados(v_dados.last()).vr_vllanmto := 285;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 271276;
    v_dados(v_dados.last()).vr_nrctremp := 53665;
    v_dados(v_dados.last()).vr_vllanmto := 57.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 7145;
    v_dados(v_dados.last()).vr_nrctremp := 54314;
    v_dados(v_dados.last()).vr_vllanmto := 2428.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170615;
    v_dados(v_dados.last()).vr_nrctremp := 54514;
    v_dados(v_dados.last()).vr_vllanmto := 28.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215414;
    v_dados(v_dados.last()).vr_nrctremp := 61817;
    v_dados(v_dados.last()).vr_vllanmto := 539.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 63749;
    v_dados(v_dados.last()).vr_vllanmto := 38.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145947;
    v_dados(v_dados.last()).vr_nrctremp := 56091;
    v_dados(v_dados.last()).vr_vllanmto := 94.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421200;
    v_dados(v_dados.last()).vr_nrctremp := 56187;
    v_dados(v_dados.last()).vr_vllanmto := 108.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100161;
    v_dados(v_dados.last()).vr_nrctremp := 56319;
    v_dados(v_dados.last()).vr_vllanmto := 33.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 209066;
    v_dados(v_dados.last()).vr_nrctremp := 56508;
    v_dados(v_dados.last()).vr_vllanmto := 148.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 209.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 56753;
    v_dados(v_dados.last()).vr_vllanmto := 241.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90247;
    v_dados(v_dados.last()).vr_nrctremp := 64692;
    v_dados(v_dados.last()).vr_vllanmto := 21.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 241.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323519;
    v_dados(v_dados.last()).vr_nrctremp := 73280;
    v_dados(v_dados.last()).vr_vllanmto := 15.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 293822;
    v_dados(v_dados.last()).vr_nrctremp := 57792;
    v_dados(v_dados.last()).vr_vllanmto := 89.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 57983;
    v_dados(v_dados.last()).vr_vllanmto := 480.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 80312;
    v_dados(v_dados.last()).vr_vllanmto := 155.42;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 58256;
    v_dados(v_dados.last()).vr_vllanmto := 45.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298875;
    v_dados(v_dados.last()).vr_nrctremp := 58507;
    v_dados(v_dados.last()).vr_vllanmto := 94.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92690;
    v_dados(v_dados.last()).vr_nrctremp := 58634;
    v_dados(v_dados.last()).vr_vllanmto := 68.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92665;
    v_dados(v_dados.last()).vr_nrctremp := 59179;
    v_dados(v_dados.last()).vr_vllanmto := 175.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 44.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344222;
    v_dados(v_dados.last()).vr_nrctremp := 83334;
    v_dados(v_dados.last()).vr_vllanmto := 55.94;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163066;
    v_dados(v_dados.last()).vr_nrctremp := 61364;
    v_dados(v_dados.last()).vr_vllanmto := 76.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161284;
    v_dados(v_dados.last()).vr_nrctremp := 84769;
    v_dados(v_dados.last()).vr_vllanmto := 18.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185981;
    v_dados(v_dados.last()).vr_nrctremp := 61901;
    v_dados(v_dados.last()).vr_vllanmto := 31.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62072;
    v_dados(v_dados.last()).vr_vllanmto := 64.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 142611;
    v_dados(v_dados.last()).vr_nrctremp := 86099;
    v_dados(v_dados.last()).vr_vllanmto := 32.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218847;
    v_dados(v_dados.last()).vr_nrctremp := 63998;
    v_dados(v_dados.last()).vr_vllanmto := 45.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153265;
    v_dados(v_dados.last()).vr_nrctremp := 64028;
    v_dados(v_dados.last()).vr_vllanmto := 18.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91572;
    v_dados(v_dados.last()).vr_vllanmto := 23.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 95415;
    v_dados(v_dados.last()).vr_vllanmto := 23.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 65227;
    v_dados(v_dados.last()).vr_vllanmto := 810.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155934;
    v_dados(v_dados.last()).vr_nrctremp := 66219;
    v_dados(v_dados.last()).vr_vllanmto := 2592.8;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 239968;
    v_dados(v_dados.last()).vr_nrctremp := 66273;
    v_dados(v_dados.last()).vr_vllanmto := 482.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 67514;
    v_dados(v_dados.last()).vr_vllanmto := 177.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 21539;
    v_dados(v_dados.last()).vr_nrctremp := 95890;
    v_dados(v_dados.last()).vr_vllanmto := 545.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95532;
    v_dados(v_dados.last()).vr_nrctremp := 68569;
    v_dados(v_dados.last()).vr_vllanmto := 66.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190250;
    v_dados(v_dados.last()).vr_nrctremp := 70702;
    v_dados(v_dados.last()).vr_vllanmto := 15.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 69.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 197.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 71878;
    v_dados(v_dados.last()).vr_vllanmto := 4047.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172804;
    v_dados(v_dados.last()).vr_nrctremp := 72476;
    v_dados(v_dados.last()).vr_vllanmto := 16809.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 97404;
    v_dados(v_dados.last()).vr_vllanmto := 83.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 111.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258598;
    v_dados(v_dados.last()).vr_nrctremp := 98532;
    v_dados(v_dados.last()).vr_vllanmto := 41.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503584;
    v_dados(v_dados.last()).vr_nrctremp := 102245;
    v_dados(v_dados.last()).vr_vllanmto := 223.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 74654;
    v_dados(v_dados.last()).vr_vllanmto := 43.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 75102;
    v_dados(v_dados.last()).vr_vllanmto := 91.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 77895;
    v_dados(v_dados.last()).vr_nrctremp := 75192;
    v_dados(v_dados.last()).vr_vllanmto := 33.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267414;
    v_dados(v_dados.last()).vr_nrctremp := 76198;
    v_dados(v_dados.last()).vr_vllanmto := 22.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172855;
    v_dados(v_dados.last()).vr_nrctremp := 76273;
    v_dados(v_dados.last()).vr_vllanmto := 30.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188158;
    v_dados(v_dados.last()).vr_nrctremp := 79186;
    v_dados(v_dados.last()).vr_vllanmto := 38.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186139;
    v_dados(v_dados.last()).vr_nrctremp := 79508;
    v_dados(v_dados.last()).vr_vllanmto := 29.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426610;
    v_dados(v_dados.last()).vr_nrctremp := 80116;
    v_dados(v_dados.last()).vr_vllanmto := 119.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424218;
    v_dados(v_dados.last()).vr_nrctremp := 103005;
    v_dados(v_dados.last()).vr_vllanmto := 52.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 82142;
    v_dados(v_dados.last()).vr_vllanmto := 37.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319260;
    v_dados(v_dados.last()).vr_nrctremp := 82744;
    v_dados(v_dados.last()).vr_vllanmto := 21.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := 65.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83098;
    v_dados(v_dados.last()).vr_vllanmto := 30.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 104655;
    v_dados(v_dados.last()).vr_vllanmto := 100.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83766;
    v_dados(v_dados.last()).vr_vllanmto := 105.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83772;
    v_dados(v_dados.last()).vr_vllanmto := 16.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93378;
    v_dados(v_dados.last()).vr_nrctremp := 84031;
    v_dados(v_dados.last()).vr_vllanmto := 1927.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361372;
    v_dados(v_dados.last()).vr_nrctremp := 84317;
    v_dados(v_dados.last()).vr_vllanmto := 649.04;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350729;
    v_dados(v_dados.last()).vr_nrctremp := 105102;
    v_dados(v_dados.last()).vr_vllanmto := 60.44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498815;
    v_dados(v_dados.last()).vr_nrctremp := 84901;
    v_dados(v_dados.last()).vr_vllanmto := 56.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419206;
    v_dados(v_dados.last()).vr_nrctremp := 85355;
    v_dados(v_dados.last()).vr_vllanmto := 23.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144231;
    v_dados(v_dados.last()).vr_nrctremp := 86096;
    v_dados(v_dados.last()).vr_vllanmto := 221.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 344192;
    v_dados(v_dados.last()).vr_nrctremp := 106118;
    v_dados(v_dados.last()).vr_vllanmto := 143.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 87115;
    v_dados(v_dados.last()).vr_vllanmto := 31.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192902;
    v_dados(v_dados.last()).vr_nrctremp := 87507;
    v_dados(v_dados.last()).vr_vllanmto := 145.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 90393;
    v_dados(v_dados.last()).vr_vllanmto := 255.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107625;
    v_dados(v_dados.last()).vr_vllanmto := 105.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 10766;
    v_dados(v_dados.last()).vr_nrctremp := 91531;
    v_dados(v_dados.last()).vr_vllanmto := 20.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107626;
    v_dados(v_dados.last()).vr_vllanmto := 54.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 91932;
    v_dados(v_dados.last()).vr_vllanmto := 34.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 276260;
    v_dados(v_dados.last()).vr_nrctremp := 107629;
    v_dados(v_dados.last()).vr_vllanmto := 23.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 92218;
    v_dados(v_dados.last()).vr_vllanmto := 32.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 245437;
    v_dados(v_dados.last()).vr_nrctremp := 92577;
    v_dados(v_dados.last()).vr_vllanmto := 44.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78166;
    v_dados(v_dados.last()).vr_nrctremp := 107659;
    v_dados(v_dados.last()).vr_vllanmto := 33.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 164615;
    v_dados(v_dados.last()).vr_nrctremp := 92827;
    v_dados(v_dados.last()).vr_vllanmto := 107.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521140;
    v_dados(v_dados.last()).vr_nrctremp := 92843;
    v_dados(v_dados.last()).vr_vllanmto := 49.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521256;
    v_dados(v_dados.last()).vr_nrctremp := 92946;
    v_dados(v_dados.last()).vr_vllanmto := 61.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186902;
    v_dados(v_dados.last()).vr_nrctremp := 92977;
    v_dados(v_dados.last()).vr_vllanmto := 68.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 93695;
    v_dados(v_dados.last()).vr_vllanmto := 28529.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 94244;
    v_dados(v_dados.last()).vr_vllanmto := 37.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94900;
    v_dados(v_dados.last()).vr_vllanmto := 20.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94999;
    v_dados(v_dados.last()).vr_vllanmto := 35.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 95094;
    v_dados(v_dados.last()).vr_vllanmto := 44.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524905;
    v_dados(v_dados.last()).vr_nrctremp := 95213;
    v_dados(v_dados.last()).vr_vllanmto := 103.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 113015;
    v_dados(v_dados.last()).vr_vllanmto := 26.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288861;
    v_dados(v_dados.last()).vr_nrctremp := 95562;
    v_dados(v_dados.last()).vr_vllanmto := 36.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := 595.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116163;
    v_dados(v_dados.last()).vr_vllanmto := 39.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 96352;
    v_dados(v_dados.last()).vr_vllanmto := 118.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168564;
    v_dados(v_dados.last()).vr_nrctremp := 96542;
    v_dados(v_dados.last()).vr_vllanmto := 31.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146625;
    v_dados(v_dados.last()).vr_nrctremp := 96582;
    v_dados(v_dados.last()).vr_vllanmto := 20.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 111.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526118;
    v_dados(v_dados.last()).vr_nrctremp := 96688;
    v_dados(v_dados.last()).vr_vllanmto := 88.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 97211;
    v_dados(v_dados.last()).vr_vllanmto := 173.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116166;
    v_dados(v_dados.last()).vr_vllanmto := 23.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 88480;
    v_dados(v_dados.last()).vr_nrctremp := 97562;
    v_dados(v_dados.last()).vr_vllanmto := 30.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280844;
    v_dados(v_dados.last()).vr_nrctremp := 116694;
    v_dados(v_dados.last()).vr_vllanmto := 45.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187402;
    v_dados(v_dados.last()).vr_nrctremp := 118241;
    v_dados(v_dados.last()).vr_vllanmto := 146.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154466;
    v_dados(v_dados.last()).vr_nrctremp := 99993;
    v_dados(v_dados.last()).vr_vllanmto := 868.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484067;
    v_dados(v_dados.last()).vr_nrctremp := 100800;
    v_dados(v_dados.last()).vr_vllanmto := 394.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182958;
    v_dados(v_dados.last()).vr_nrctremp := 101588;
    v_dados(v_dados.last()).vr_vllanmto := 130.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 122595;
    v_dados(v_dados.last()).vr_vllanmto := 49.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187372;
    v_dados(v_dados.last()).vr_nrctremp := 102721;
    v_dados(v_dados.last()).vr_vllanmto := 17.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 134611;
    v_dados(v_dados.last()).vr_vllanmto := 842.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202576;
    v_dados(v_dados.last()).vr_nrctremp := 104041;
    v_dados(v_dados.last()).vr_vllanmto := 72.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120618;
    v_dados(v_dados.last()).vr_nrctremp := 104378;
    v_dados(v_dados.last()).vr_vllanmto := 122.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 469661;
    v_dados(v_dados.last()).vr_nrctremp := 135698;
    v_dados(v_dados.last()).vr_vllanmto := 44.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104701;
    v_dados(v_dados.last()).vr_vllanmto := 32.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 383007;
    v_dados(v_dados.last()).vr_nrctremp := 104758;
    v_dados(v_dados.last()).vr_vllanmto := 96.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355771;
    v_dados(v_dados.last()).vr_nrctremp := 144078;
    v_dados(v_dados.last()).vr_vllanmto := 94.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350745;
    v_dados(v_dados.last()).vr_nrctremp := 157549;
    v_dados(v_dados.last()).vr_vllanmto := 183.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202657;
    v_dados(v_dados.last()).vr_nrctremp := 163091;
    v_dados(v_dados.last()).vr_vllanmto := 19.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 164635;
    v_dados(v_dados.last()).vr_vllanmto := 75.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199788;
    v_dados(v_dados.last()).vr_nrctremp := 164878;
    v_dados(v_dados.last()).vr_vllanmto := 143.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548138;
    v_dados(v_dados.last()).vr_nrctremp := 106976;
    v_dados(v_dados.last()).vr_vllanmto := 74.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 211524;
    v_dados(v_dados.last()).vr_nrctremp := 107457;
    v_dados(v_dados.last()).vr_vllanmto := 90.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 608203;
    v_dados(v_dados.last()).vr_nrctremp := 172851;
    v_dados(v_dados.last()).vr_vllanmto := 29.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136352;
    v_dados(v_dados.last()).vr_nrctremp := 187976;
    v_dados(v_dados.last()).vr_vllanmto := 423.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 117137;
    v_dados(v_dados.last()).vr_nrctremp := 192908;
    v_dados(v_dados.last()).vr_vllanmto := 445.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277754;
    v_dados(v_dados.last()).vr_nrctremp := 197943;
    v_dados(v_dados.last()).vr_vllanmto := 585.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 107679;
    v_dados(v_dados.last()).vr_vllanmto := 26.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 109298;
    v_dados(v_dados.last()).vr_vllanmto := 1058.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350672;
    v_dados(v_dados.last()).vr_nrctremp := 50375;
    v_dados(v_dados.last()).vr_vllanmto := 124.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553905;
    v_dados(v_dados.last()).vr_nrctremp := 110020;
    v_dados(v_dados.last()).vr_vllanmto := 20.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110555;
    v_dados(v_dados.last()).vr_vllanmto := 62.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 174874;
    v_dados(v_dados.last()).vr_nrctremp := 51025;
    v_dados(v_dados.last()).vr_vllanmto := 90.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215104;
    v_dados(v_dados.last()).vr_nrctremp := 112556;
    v_dados(v_dados.last()).vr_vllanmto := 68.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 112687;
    v_dados(v_dados.last()).vr_vllanmto := 16.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 384461;
    v_dados(v_dados.last()).vr_nrctremp := 51220;
    v_dados(v_dados.last()).vr_vllanmto := 142.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 386545;
    v_dados(v_dados.last()).vr_nrctremp := 51508;
    v_dados(v_dados.last()).vr_vllanmto := 173.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561886;
    v_dados(v_dados.last()).vr_nrctremp := 113419;
    v_dados(v_dados.last()).vr_vllanmto := 73.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318515;
    v_dados(v_dados.last()).vr_nrctremp := 113422;
    v_dados(v_dados.last()).vr_vllanmto := 26.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 113777;
    v_dados(v_dados.last()).vr_vllanmto := 35.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95257;
    v_dados(v_dados.last()).vr_nrctremp := 114045;
    v_dados(v_dados.last()).vr_vllanmto := 54.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114640;
    v_dados(v_dados.last()).vr_vllanmto := 38.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115869;
    v_dados(v_dados.last()).vr_vllanmto := 52.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187194;
    v_dados(v_dados.last()).vr_nrctremp := 56891;
    v_dados(v_dados.last()).vr_vllanmto := 1044.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 223913;
    v_dados(v_dados.last()).vr_nrctremp := 57290;
    v_dados(v_dados.last()).vr_vllanmto := 79.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87963;
    v_dados(v_dados.last()).vr_nrctremp := 64353;
    v_dados(v_dados.last()).vr_vllanmto := 204.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 504220;
    v_dados(v_dados.last()).vr_nrctremp := 118177;
    v_dados(v_dados.last()).vr_vllanmto := 52.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 243477;
    v_dados(v_dados.last()).vr_nrctremp := 68277;
    v_dados(v_dados.last()).vr_vllanmto := 65.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 315834;
    v_dados(v_dados.last()).vr_nrctremp := 118574;
    v_dados(v_dados.last()).vr_vllanmto := 216.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 119046;
    v_dados(v_dados.last()).vr_vllanmto := 15.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186740;
    v_dados(v_dados.last()).vr_nrctremp := 119858;
    v_dados(v_dados.last()).vr_vllanmto := 2387.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 122406;
    v_dados(v_dados.last()).vr_vllanmto := 1244.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 73958;
    v_dados(v_dados.last()).vr_vllanmto := 50.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 81.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202665;
    v_dados(v_dados.last()).vr_nrctremp := 123568;
    v_dados(v_dados.last()).vr_vllanmto := 24.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 301469;
    v_dados(v_dados.last()).vr_nrctremp := 123630;
    v_dados(v_dados.last()).vr_vllanmto := 34.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 274364;
    v_dados(v_dados.last()).vr_nrctremp := 124281;
    v_dados(v_dados.last()).vr_vllanmto := 35.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350664;
    v_dados(v_dados.last()).vr_nrctremp := 125552;
    v_dados(v_dados.last()).vr_vllanmto := 67.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 125819;
    v_dados(v_dados.last()).vr_vllanmto := 44.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 125901;
    v_dados(v_dados.last()).vr_vllanmto := 105.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91995;
    v_dados(v_dados.last()).vr_nrctremp := 126548;
    v_dados(v_dados.last()).vr_vllanmto := 35.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349798;
    v_dados(v_dados.last()).vr_nrctremp := 127767;
    v_dados(v_dados.last()).vr_vllanmto := 35.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 100.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31682;
    v_dados(v_dados.last()).vr_nrctremp := 91212;
    v_dados(v_dados.last()).vr_vllanmto := 35.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90000;
    v_dados(v_dados.last()).vr_nrctremp := 129809;
    v_dados(v_dados.last()).vr_vllanmto := 29.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129898;
    v_dados(v_dados.last()).vr_vllanmto := 4881.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141925;
    v_dados(v_dados.last()).vr_nrctremp := 129899;
    v_dados(v_dados.last()).vr_vllanmto := 585.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 181218;
    v_dados(v_dados.last()).vr_nrctremp := 131509;
    v_dados(v_dados.last()).vr_vllanmto := 20.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 107620;
    v_dados(v_dados.last()).vr_nrctremp := 132064;
    v_dados(v_dados.last()).vr_vllanmto := 39.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289426;
    v_dados(v_dados.last()).vr_nrctremp := 132284;
    v_dados(v_dados.last()).vr_vllanmto := 18.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 605190;
    v_dados(v_dados.last()).vr_nrctremp := 132874;
    v_dados(v_dados.last()).vr_vllanmto := 43.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 121.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 225029;
    v_dados(v_dados.last()).vr_nrctremp := 133193;
    v_dados(v_dados.last()).vr_vllanmto := 1010.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322865;
    v_dados(v_dados.last()).vr_nrctremp := 133461;
    v_dados(v_dados.last()).vr_vllanmto := 34.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 34.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 607916;
    v_dados(v_dados.last()).vr_nrctremp := 134133;
    v_dados(v_dados.last()).vr_vllanmto := 2498.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103861;
    v_dados(v_dados.last()).vr_nrctremp := 134554;
    v_dados(v_dados.last()).vr_vllanmto := 38.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319864;
    v_dados(v_dados.last()).vr_nrctremp := 91954;
    v_dados(v_dados.last()).vr_vllanmto := 137.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 431133;
    v_dados(v_dados.last()).vr_nrctremp := 135052;
    v_dados(v_dados.last()).vr_vllanmto := 26.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483923;
    v_dados(v_dados.last()).vr_nrctremp := 92602;
    v_dados(v_dados.last()).vr_vllanmto := 67.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 216305;
    v_dados(v_dados.last()).vr_nrctremp := 97595;
    v_dados(v_dados.last()).vr_vllanmto := 49.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135768;
    v_dados(v_dados.last()).vr_vllanmto := 61.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93122;
    v_dados(v_dados.last()).vr_nrctremp := 136111;
    v_dados(v_dados.last()).vr_vllanmto := 1101.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 59.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 44.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256757;
    v_dados(v_dados.last()).vr_nrctremp := 137189;
    v_dados(v_dados.last()).vr_vllanmto := 19.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 138297;
    v_dados(v_dados.last()).vr_vllanmto := 84.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := 26.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277193;
    v_dados(v_dados.last()).vr_nrctremp := 139562;
    v_dados(v_dados.last()).vr_vllanmto := 555.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66877;
    v_dados(v_dados.last()).vr_nrctremp := 139636;
    v_dados(v_dados.last()).vr_vllanmto := 1439.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 16.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334936;
    v_dados(v_dados.last()).vr_nrctremp := 139875;
    v_dados(v_dados.last()).vr_vllanmto := 17.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18180;
    v_dados(v_dados.last()).vr_nrctremp := 140475;
    v_dados(v_dados.last()).vr_vllanmto := 26.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142242;
    v_dados(v_dados.last()).vr_vllanmto := 18.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545805;
    v_dados(v_dados.last()).vr_nrctremp := 105319;
    v_dados(v_dados.last()).vr_vllanmto := 55.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66940;
    v_dados(v_dados.last()).vr_nrctremp := 142854;
    v_dados(v_dados.last()).vr_vllanmto := 46.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143897;
    v_dados(v_dados.last()).vr_vllanmto := 17.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 105708;
    v_dados(v_dados.last()).vr_vllanmto := 33.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 244937;
    v_dados(v_dados.last()).vr_nrctremp := 106384;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248312;
    v_dados(v_dados.last()).vr_nrctremp := 146804;
    v_dados(v_dados.last()).vr_vllanmto := 21.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 20.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25887;
    v_dados(v_dados.last()).vr_nrctremp := 148839;
    v_dados(v_dados.last()).vr_vllanmto := 16.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641790;
    v_dados(v_dados.last()).vr_nrctremp := 148852;
    v_dados(v_dados.last()).vr_vllanmto := 22.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 149849;
    v_dados(v_dados.last()).vr_vllanmto := 1483.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66605;
    v_dados(v_dados.last()).vr_nrctremp := 150339;
    v_dados(v_dados.last()).vr_vllanmto := 60.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103608;
    v_dados(v_dados.last()).vr_nrctremp := 150645;
    v_dados(v_dados.last()).vr_vllanmto := 42.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277231;
    v_dados(v_dados.last()).vr_nrctremp := 151600;
    v_dados(v_dados.last()).vr_vllanmto := 631.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 151838;
    v_dados(v_dados.last()).vr_vllanmto := 699.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 649899;
    v_dados(v_dados.last()).vr_nrctremp := 153142;
    v_dados(v_dados.last()).vr_vllanmto := 22.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109428;
    v_dados(v_dados.last()).vr_nrctremp := 154257;
    v_dados(v_dados.last()).vr_vllanmto := 18.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105295;
    v_dados(v_dados.last()).vr_nrctremp := 109809;
    v_dados(v_dados.last()).vr_vllanmto := 15.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 664030;
    v_dados(v_dados.last()).vr_nrctremp := 161218;
    v_dados(v_dados.last()).vr_vllanmto := 16.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 439827;
    v_dados(v_dados.last()).vr_nrctremp := 161852;
    v_dados(v_dados.last()).vr_vllanmto := 1070.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 162545;
    v_dados(v_dados.last()).vr_vllanmto := 4880.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 203.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662380;
    v_dados(v_dados.last()).vr_nrctremp := 163482;
    v_dados(v_dados.last()).vr_vllanmto := 59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464910;
    v_dados(v_dados.last()).vr_nrctremp := 164242;
    v_dados(v_dados.last()).vr_vllanmto := 318.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112758;
    v_dados(v_dados.last()).vr_vllanmto := 34.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 25.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 539759;
    v_dados(v_dados.last()).vr_nrctremp := 165854;
    v_dados(v_dados.last()).vr_vllanmto := 611.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 672130;
    v_dados(v_dados.last()).vr_nrctremp := 166378;
    v_dados(v_dados.last()).vr_vllanmto := 36.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 49.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 221546;
    v_dados(v_dados.last()).vr_nrctremp := 135155;
    v_dados(v_dados.last()).vr_vllanmto := 28.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92410;
    v_dados(v_dados.last()).vr_nrctremp := 170991;
    v_dados(v_dados.last()).vr_vllanmto := 20.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 236632;
    v_dados(v_dados.last()).vr_nrctremp := 142523;
    v_dados(v_dados.last()).vr_vllanmto := 48.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 128333;
    v_dados(v_dados.last()).vr_nrctremp := 174807;
    v_dados(v_dados.last()).vr_vllanmto := 28.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 178572;
    v_dados(v_dados.last()).vr_vllanmto := 180.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 461610;
    v_dados(v_dados.last()).vr_nrctremp := 145393;
    v_dados(v_dados.last()).vr_vllanmto := 117.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 572314;
    v_dados(v_dados.last()).vr_nrctremp := 179477;
    v_dados(v_dados.last()).vr_vllanmto := 54.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 407003;
    v_dados(v_dados.last()).vr_nrctremp := 180030;
    v_dados(v_dados.last()).vr_vllanmto := 31.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199974;
    v_dados(v_dados.last()).vr_nrctremp := 180108;
    v_dados(v_dados.last()).vr_vllanmto := 5138.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 183180;
    v_dados(v_dados.last()).vr_vllanmto := 485.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 374334;
    v_dados(v_dados.last()).vr_nrctremp := 184706;
    v_dados(v_dados.last()).vr_vllanmto := 21.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 187057;
    v_dados(v_dados.last()).vr_vllanmto := 16.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 582042;
    v_dados(v_dados.last()).vr_nrctremp := 166819;
    v_dados(v_dados.last()).vr_vllanmto := 51.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 189015;
    v_dados(v_dados.last()).vr_vllanmto := 325.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120219;
    v_dados(v_dados.last()).vr_nrctremp := 189095;
    v_dados(v_dados.last()).vr_vllanmto := 17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199974;
    v_dados(v_dados.last()).vr_nrctremp := 191853;
    v_dados(v_dados.last()).vr_vllanmto := 495.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136050;
    v_dados(v_dados.last()).vr_nrctremp := 168149;
    v_dados(v_dados.last()).vr_vllanmto := 28.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 193141;
    v_dados(v_dados.last()).vr_vllanmto := 92.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185531;
    v_dados(v_dados.last()).vr_nrctremp := 195405;
    v_dados(v_dados.last()).vr_vllanmto := 5334.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 689947;
    v_dados(v_dados.last()).vr_nrctremp := 179402;
    v_dados(v_dados.last()).vr_vllanmto := 26.92;
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
