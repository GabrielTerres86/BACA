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
    v_dados(v_dados.last()).vr_nrdconta := 292770;
    v_dados(v_dados.last()).vr_nrctremp := 51071;
    v_dados(v_dados.last()).vr_vllanmto := 361.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90638;
    v_dados(v_dados.last()).vr_nrctremp := 54281;
    v_dados(v_dados.last()).vr_vllanmto := 150.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 228079;
    v_dados(v_dados.last()).vr_nrctremp := 54753;
    v_dados(v_dados.last()).vr_vllanmto := .8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143790;
    v_dados(v_dados.last()).vr_nrctremp := 56730;
    v_dados(v_dados.last()).vr_vllanmto := .07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 56.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153141;
    v_dados(v_dados.last()).vr_nrctremp := 57245;
    v_dados(v_dados.last()).vr_vllanmto := 1.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161349;
    v_dados(v_dados.last()).vr_nrctremp := 59104;
    v_dados(v_dados.last()).vr_vllanmto := 10982.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 226424;
    v_dados(v_dados.last()).vr_nrctremp := 59283;
    v_dados(v_dados.last()).vr_vllanmto := .86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367389;
    v_dados(v_dados.last()).vr_nrctremp := 59342;
    v_dados(v_dados.last()).vr_vllanmto := 37.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 59512;
    v_dados(v_dados.last()).vr_vllanmto := 14173.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 23388;
    v_dados(v_dados.last()).vr_nrctremp := 59749;
    v_dados(v_dados.last()).vr_vllanmto := 19.67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184950;
    v_dados(v_dados.last()).vr_nrctremp := 60076;
    v_dados(v_dados.last()).vr_vllanmto := 2077.13;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 60113;
    v_dados(v_dados.last()).vr_vllanmto := 2.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 84.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292770;
    v_dados(v_dados.last()).vr_nrctremp := 65537;
    v_dados(v_dados.last()).vr_vllanmto := 10.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355607;
    v_dados(v_dados.last()).vr_nrctremp := 65807;
    v_dados(v_dados.last()).vr_vllanmto := 71286.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155934;
    v_dados(v_dados.last()).vr_nrctremp := 66219;
    v_dados(v_dados.last()).vr_vllanmto := 36428.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368920;
    v_dados(v_dados.last()).vr_nrctremp := 66349;
    v_dados(v_dados.last()).vr_vllanmto := 130.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360287;
    v_dados(v_dados.last()).vr_nrctremp := 66651;
    v_dados(v_dados.last()).vr_vllanmto := 82.45;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186201;
    v_dados(v_dados.last()).vr_nrctremp := 71865;
    v_dados(v_dados.last()).vr_vllanmto := 55.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394734;
    v_dados(v_dados.last()).vr_nrctremp := 72344;
    v_dados(v_dados.last()).vr_vllanmto := 7568.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 85.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 31.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198030;
    v_dados(v_dados.last()).vr_nrctremp := 74436;
    v_dados(v_dados.last()).vr_vllanmto := 1.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 275050;
    v_dados(v_dados.last()).vr_nrctremp := 75298;
    v_dados(v_dados.last()).vr_vllanmto := 6714.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316776;
    v_dados(v_dados.last()).vr_nrctremp := 78219;
    v_dados(v_dados.last()).vr_vllanmto := 4.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 376744;
    v_dados(v_dados.last()).vr_nrctremp := 78331;
    v_dados(v_dados.last()).vr_vllanmto := 63.52;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480991;
    v_dados(v_dados.last()).vr_nrctremp := 78627;
    v_dados(v_dados.last()).vr_vllanmto := 213.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78786;
    v_dados(v_dados.last()).vr_nrctremp := 80159;
    v_dados(v_dados.last()).vr_vllanmto := 383.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396990;
    v_dados(v_dados.last()).vr_nrctremp := 80320;
    v_dados(v_dados.last()).vr_vllanmto := 2089.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 338044;
    v_dados(v_dados.last()).vr_nrctremp := 81032;
    v_dados(v_dados.last()).vr_vllanmto := 6.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462160;
    v_dados(v_dados.last()).vr_nrctremp := 81229;
    v_dados(v_dados.last()).vr_vllanmto := 5.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180130;
    v_dados(v_dados.last()).vr_nrctremp := 82659;
    v_dados(v_dados.last()).vr_vllanmto := .26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 20923;
    v_dados(v_dados.last()).vr_nrctremp := 82841;
    v_dados(v_dados.last()).vr_vllanmto := 1607.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22560;
    v_dados(v_dados.last()).vr_nrctremp := 84128;
    v_dados(v_dados.last()).vr_vllanmto := 25.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361372;
    v_dados(v_dados.last()).vr_nrctremp := 84317;
    v_dados(v_dados.last()).vr_vllanmto := 1488.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237108;
    v_dados(v_dados.last()).vr_nrctremp := 86776;
    v_dados(v_dados.last()).vr_vllanmto := 1827.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 501786;
    v_dados(v_dados.last()).vr_nrctremp := 86925;
    v_dados(v_dados.last()).vr_vllanmto := 25.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78298;
    v_dados(v_dados.last()).vr_nrctremp := 88711;
    v_dados(v_dados.last()).vr_vllanmto := 19776.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394033;
    v_dados(v_dados.last()).vr_nrctremp := 90907;
    v_dados(v_dados.last()).vr_vllanmto := 1204.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31682;
    v_dados(v_dados.last()).vr_nrctremp := 91212;
    v_dados(v_dados.last()).vr_vllanmto := 6.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167924;
    v_dados(v_dados.last()).vr_nrctremp := 94867;
    v_dados(v_dados.last()).vr_vllanmto := 6.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240540;
    v_dados(v_dados.last()).vr_nrctremp := 95357;
    v_dados(v_dados.last()).vr_vllanmto := 8.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 319929;
    v_dados(v_dados.last()).vr_nrctremp := 96594;
    v_dados(v_dados.last()).vr_vllanmto := 1.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256013;
    v_dados(v_dados.last()).vr_nrctremp := 96840;
    v_dados(v_dados.last()).vr_vllanmto := 20.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 64955;
    v_dados(v_dados.last()).vr_nrctremp := 98020;
    v_dados(v_dados.last()).vr_vllanmto := 14.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524808;
    v_dados(v_dados.last()).vr_nrctremp := 98536;
    v_dados(v_dados.last()).vr_vllanmto := .05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 1.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 212849;
    v_dados(v_dados.last()).vr_nrctremp := 99450;
    v_dados(v_dados.last()).vr_vllanmto := 1.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103349;
    v_dados(v_dados.last()).vr_nrctremp := 100759;
    v_dados(v_dados.last()).vr_vllanmto := 3.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 436534;
    v_dados(v_dados.last()).vr_nrctremp := 100797;
    v_dados(v_dados.last()).vr_vllanmto := 14.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379093;
    v_dados(v_dados.last()).vr_nrctremp := 102367;
    v_dados(v_dados.last()).vr_vllanmto := 594.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188123;
    v_dados(v_dados.last()).vr_nrctremp := 102857;
    v_dados(v_dados.last()).vr_vllanmto := 6.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161110;
    v_dados(v_dados.last()).vr_nrctremp := 103295;
    v_dados(v_dados.last()).vr_vllanmto := 18620.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161110;
    v_dados(v_dados.last()).vr_nrctremp := 103296;
    v_dados(v_dados.last()).vr_vllanmto := 1220.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 110594;
    v_dados(v_dados.last()).vr_vllanmto := 1.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110737;
    v_dados(v_dados.last()).vr_vllanmto := 1.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334685;
    v_dados(v_dados.last()).vr_nrctremp := 111025;
    v_dados(v_dados.last()).vr_vllanmto := 66.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 111158;
    v_dados(v_dados.last()).vr_vllanmto := 1.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 112941;
    v_dados(v_dados.last()).vr_nrctremp := 112912;
    v_dados(v_dados.last()).vr_vllanmto := 7.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180815;
    v_dados(v_dados.last()).vr_nrctremp := 118018;
    v_dados(v_dados.last()).vr_vllanmto := 2.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 571628;
    v_dados(v_dados.last()).vr_nrctremp := 118254;
    v_dados(v_dados.last()).vr_vllanmto := 1.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 119113;
    v_dados(v_dados.last()).vr_vllanmto := .82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152455;
    v_dados(v_dados.last()).vr_nrctremp := 120690;
    v_dados(v_dados.last()).vr_vllanmto := 756.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 51.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 103.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 134641;
    v_dados(v_dados.last()).vr_vllanmto := 1.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 135118;
    v_dados(v_dados.last()).vr_vllanmto := 15.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 135478;
    v_dados(v_dados.last()).vr_vllanmto := .92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328227;
    v_dados(v_dados.last()).vr_nrctremp := 136480;
    v_dados(v_dados.last()).vr_vllanmto := 11.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299227;
    v_dados(v_dados.last()).vr_nrctremp := 136637;
    v_dados(v_dados.last()).vr_vllanmto := 3.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 136699;
    v_dados(v_dados.last()).vr_vllanmto := 77.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184586;
    v_dados(v_dados.last()).vr_nrctremp := 136806;
    v_dados(v_dados.last()).vr_vllanmto := 22.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71757;
    v_dados(v_dados.last()).vr_nrctremp := 136891;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 42.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137031;
    v_dados(v_dados.last()).vr_vllanmto := 29.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172421;
    v_dados(v_dados.last()).vr_nrctremp := 137032;
    v_dados(v_dados.last()).vr_vllanmto := 5.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350605;
    v_dados(v_dados.last()).vr_nrctremp := 137039;
    v_dados(v_dados.last()).vr_vllanmto := 8.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 137047;
    v_dados(v_dados.last()).vr_vllanmto := 2.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256757;
    v_dados(v_dados.last()).vr_nrctremp := 137189;
    v_dados(v_dados.last()).vr_vllanmto := 13.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187020;
    v_dados(v_dados.last()).vr_nrctremp := 137318;
    v_dados(v_dados.last()).vr_vllanmto := 6.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137559;
    v_dados(v_dados.last()).vr_vllanmto := 17.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137561;
    v_dados(v_dados.last()).vr_vllanmto := 16.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 617482;
    v_dados(v_dados.last()).vr_nrctremp := 137775;
    v_dados(v_dados.last()).vr_vllanmto := 36.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 616346;
    v_dados(v_dados.last()).vr_nrctremp := 137941;
    v_dados(v_dados.last()).vr_vllanmto := 35.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318248;
    v_dados(v_dados.last()).vr_nrctremp := 137990;
    v_dados(v_dados.last()).vr_vllanmto := 12.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 30.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 70386;
    v_dados(v_dados.last()).vr_nrctremp := 138212;
    v_dados(v_dados.last()).vr_vllanmto := 21.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145190;
    v_dados(v_dados.last()).vr_nrctremp := 138246;
    v_dados(v_dados.last()).vr_vllanmto := 7.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 138280;
    v_dados(v_dados.last()).vr_vllanmto := 6.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66800;
    v_dados(v_dados.last()).vr_nrctremp := 138302;
    v_dados(v_dados.last()).vr_vllanmto := 39.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129127;
    v_dados(v_dados.last()).vr_nrctremp := 138460;
    v_dados(v_dados.last()).vr_vllanmto := 18.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 302996;
    v_dados(v_dados.last()).vr_nrctremp := 138689;
    v_dados(v_dados.last()).vr_vllanmto := 2.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 442054;
    v_dados(v_dados.last()).vr_nrctremp := 138713;
    v_dados(v_dados.last()).vr_vllanmto := 3.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 138828;
    v_dados(v_dados.last()).vr_vllanmto := 10.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 609447;
    v_dados(v_dados.last()).vr_nrctremp := 139009;
    v_dados(v_dados.last()).vr_vllanmto := 10.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185272;
    v_dados(v_dados.last()).vr_nrctremp := 139153;
    v_dados(v_dados.last()).vr_vllanmto := 19.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := 28.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139402;
    v_dados(v_dados.last()).vr_vllanmto := 13.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 497819;
    v_dados(v_dados.last()).vr_nrctremp := 139587;
    v_dados(v_dados.last()).vr_vllanmto := 56.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 139833;
    v_dados(v_dados.last()).vr_vllanmto := 3.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 27.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 334936;
    v_dados(v_dados.last()).vr_nrctremp := 139875;
    v_dados(v_dados.last()).vr_vllanmto := 2.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129860;
    v_dados(v_dados.last()).vr_nrctremp := 139883;
    v_dados(v_dados.last()).vr_vllanmto := 10.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252212;
    v_dados(v_dados.last()).vr_nrctremp := 140398;
    v_dados(v_dados.last()).vr_vllanmto := 9.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242080;
    v_dados(v_dados.last()).vr_nrctremp := 141207;
    v_dados(v_dados.last()).vr_vllanmto := 25.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368857;
    v_dados(v_dados.last()).vr_nrctremp := 141765;
    v_dados(v_dados.last()).vr_vllanmto := 2.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143897;
    v_dados(v_dados.last()).vr_vllanmto := 22.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190985;
    v_dados(v_dados.last()).vr_nrctremp := 144153;
    v_dados(v_dados.last()).vr_vllanmto := 12.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 461610;
    v_dados(v_dados.last()).vr_nrctremp := 145393;
    v_dados(v_dados.last()).vr_vllanmto := 11.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145708;
    v_dados(v_dados.last()).vr_vllanmto := 12.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145998;
    v_dados(v_dados.last()).vr_nrctremp := 145980;
    v_dados(v_dados.last()).vr_vllanmto := 4.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 635669;
    v_dados(v_dados.last()).vr_nrctremp := 146059;
    v_dados(v_dados.last()).vr_vllanmto := 2.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146395;
    v_dados(v_dados.last()).vr_vllanmto := 13.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146397;
    v_dados(v_dados.last()).vr_vllanmto := 5.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 257214;
    v_dados(v_dados.last()).vr_nrctremp := 146417;
    v_dados(v_dados.last()).vr_vllanmto := 23.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 52507;
    v_dados(v_dados.last()).vr_nrctremp := 146859;
    v_dados(v_dados.last()).vr_vllanmto := 9.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350893;
    v_dados(v_dados.last()).vr_nrctremp := 146914;
    v_dados(v_dados.last()).vr_vllanmto := 10.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272116;
    v_dados(v_dados.last()).vr_nrctremp := 146978;
    v_dados(v_dados.last()).vr_vllanmto := 18.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420883;
    v_dados(v_dados.last()).vr_nrctremp := 147127;
    v_dados(v_dados.last()).vr_vllanmto := 8.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 159972;
    v_dados(v_dados.last()).vr_nrctremp := 147219;
    v_dados(v_dados.last()).vr_vllanmto := 12.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 147274;
    v_dados(v_dados.last()).vr_vllanmto := 2.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193810;
    v_dados(v_dados.last()).vr_nrctremp := 147432;
    v_dados(v_dados.last()).vr_vllanmto := 11.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237396;
    v_dados(v_dados.last()).vr_nrctremp := 147484;
    v_dados(v_dados.last()).vr_vllanmto := 6.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322890;
    v_dados(v_dados.last()).vr_nrctremp := 147538;
    v_dados(v_dados.last()).vr_vllanmto := 6.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 147680;
    v_dados(v_dados.last()).vr_vllanmto := 11.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148103;
    v_dados(v_dados.last()).vr_vllanmto := 2.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148215;
    v_dados(v_dados.last()).vr_vllanmto := 8.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 364037;
    v_dados(v_dados.last()).vr_nrctremp := 148552;
    v_dados(v_dados.last()).vr_vllanmto := 8.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467367;
    v_dados(v_dados.last()).vr_nrctremp := 149121;
    v_dados(v_dados.last()).vr_vllanmto := 5.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323004;
    v_dados(v_dados.last()).vr_nrctremp := 149276;
    v_dados(v_dados.last()).vr_vllanmto := 11.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149469;
    v_dados(v_dados.last()).vr_vllanmto := 5.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246662;
    v_dados(v_dados.last()).vr_nrctremp := 149547;
    v_dados(v_dados.last()).vr_vllanmto := .95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149927;
    v_dados(v_dados.last()).vr_vllanmto := 17.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149931;
    v_dados(v_dados.last()).vr_vllanmto := 3.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22187;
    v_dados(v_dados.last()).vr_nrctremp := 149937;
    v_dados(v_dados.last()).vr_vllanmto := 2.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96229;
    v_dados(v_dados.last()).vr_nrctremp := 150075;
    v_dados(v_dados.last()).vr_vllanmto := 13.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 130923;
    v_dados(v_dados.last()).vr_nrctremp := 150081;
    v_dados(v_dados.last()).vr_vllanmto := 2.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 150316;
    v_dados(v_dados.last()).vr_vllanmto := 2.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 626368;
    v_dados(v_dados.last()).vr_nrctremp := 150466;
    v_dados(v_dados.last()).vr_vllanmto := 11.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103608;
    v_dados(v_dados.last()).vr_nrctremp := 150645;
    v_dados(v_dados.last()).vr_vllanmto := 15.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 638315;
    v_dados(v_dados.last()).vr_nrctremp := 151150;
    v_dados(v_dados.last()).vr_vllanmto := 2.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151453;
    v_dados(v_dados.last()).vr_vllanmto := 15.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360961;
    v_dados(v_dados.last()).vr_nrctremp := 151569;
    v_dados(v_dados.last()).vr_vllanmto := 5.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 151743;
    v_dados(v_dados.last()).vr_vllanmto := 12.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 155016;
    v_dados(v_dados.last()).vr_vllanmto := .32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 353507;
    v_dados(v_dados.last()).vr_nrctremp := 155363;
    v_dados(v_dados.last()).vr_vllanmto := 1.2;
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
