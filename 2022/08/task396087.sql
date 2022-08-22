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
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 159.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2604116;
    v_dados(v_dados.last()).vr_nrctremp := 1956725;
    v_dados(v_dados.last()).vr_vllanmto := 132.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10609377;
    v_dados(v_dados.last()).vr_nrctremp := 2005092;
    v_dados(v_dados.last()).vr_vllanmto := 89.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193081;
    v_dados(v_dados.last()).vr_nrctremp := 2102720;
    v_dados(v_dados.last()).vr_vllanmto := 48.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10245537;
    v_dados(v_dados.last()).vr_nrctremp := 2952113;
    v_dados(v_dados.last()).vr_vllanmto := 44.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6927670;
    v_dados(v_dados.last()).vr_nrctremp := 2955243;
    v_dados(v_dados.last()).vr_vllanmto := 28.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 564.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10777113;
    v_dados(v_dados.last()).vr_nrctremp := 2711935;
    v_dados(v_dados.last()).vr_vllanmto := 23.52;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 2732832;
    v_dados(v_dados.last()).vr_vllanmto := 49.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7813317;
    v_dados(v_dados.last()).vr_nrctremp := 2955328;
    v_dados(v_dados.last()).vr_vllanmto := 35.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 2855130;
    v_dados(v_dados.last()).vr_vllanmto := 25.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 101.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9191046;
    v_dados(v_dados.last()).vr_nrctremp := 2955838;
    v_dados(v_dados.last()).vr_vllanmto := 57.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6819346;
    v_dados(v_dados.last()).vr_nrctremp := 2955100;
    v_dados(v_dados.last()).vr_vllanmto := 65.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3791670;
    v_dados(v_dados.last()).vr_nrctremp := 2955168;
    v_dados(v_dados.last()).vr_vllanmto := 141.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11703458;
    v_dados(v_dados.last()).vr_nrctremp := 3009568;
    v_dados(v_dados.last()).vr_vllanmto := 2521.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10403655;
    v_dados(v_dados.last()).vr_nrctremp := 2955266;
    v_dados(v_dados.last()).vr_vllanmto := 84.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101062;
    v_dados(v_dados.last()).vr_nrctremp := 2955278;
    v_dados(v_dados.last()).vr_vllanmto := 151.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11656948;
    v_dados(v_dados.last()).vr_nrctremp := 3404940;
    v_dados(v_dados.last()).vr_vllanmto := 114.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 86.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8810079;
    v_dados(v_dados.last()).vr_nrctremp := 2955393;
    v_dados(v_dados.last()).vr_vllanmto := 72.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10492844;
    v_dados(v_dados.last()).vr_nrctremp := 2955447;
    v_dados(v_dados.last()).vr_vllanmto := 62.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8811679;
    v_dados(v_dados.last()).vr_nrctremp := 2955449;
    v_dados(v_dados.last()).vr_vllanmto := 89.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476988;
    v_dados(v_dados.last()).vr_nrctremp := 2955465;
    v_dados(v_dados.last()).vr_vllanmto := 158.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80173870;
    v_dados(v_dados.last()).vr_nrctremp := 2955468;
    v_dados(v_dados.last()).vr_vllanmto := 52.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10308466;
    v_dados(v_dados.last()).vr_nrctremp := 2955488;
    v_dados(v_dados.last()).vr_vllanmto := 113.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8837813;
    v_dados(v_dados.last()).vr_nrctremp := 2955566;
    v_dados(v_dados.last()).vr_vllanmto := 228.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8791317;
    v_dados(v_dados.last()).vr_nrctremp := 2955664;
    v_dados(v_dados.last()).vr_vllanmto := 68.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9659293;
    v_dados(v_dados.last()).vr_nrctremp := 2955761;
    v_dados(v_dados.last()).vr_vllanmto := 70.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8739005;
    v_dados(v_dados.last()).vr_nrctremp := 2955812;
    v_dados(v_dados.last()).vr_vllanmto := 164.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078602;
    v_dados(v_dados.last()).vr_nrctremp := 3520144;
    v_dados(v_dados.last()).vr_vllanmto := 116.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7521537;
    v_dados(v_dados.last()).vr_nrctremp := 2955842;
    v_dados(v_dados.last()).vr_vllanmto := 101.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9762574;
    v_dados(v_dados.last()).vr_nrctremp := 2955848;
    v_dados(v_dados.last()).vr_vllanmto := 26.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4087763;
    v_dados(v_dados.last()).vr_nrctremp := 2955861;
    v_dados(v_dados.last()).vr_vllanmto := 73.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10671110;
    v_dados(v_dados.last()).vr_nrctremp := 2956018;
    v_dados(v_dados.last()).vr_vllanmto := 47.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9808299;
    v_dados(v_dados.last()).vr_nrctremp := 2956029;
    v_dados(v_dados.last()).vr_vllanmto := 236.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093663;
    v_dados(v_dados.last()).vr_nrctremp := 2956255;
    v_dados(v_dados.last()).vr_vllanmto := 236.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9233962;
    v_dados(v_dados.last()).vr_nrctremp := 2958985;
    v_dados(v_dados.last()).vr_vllanmto := 48.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752827;
    v_dados(v_dados.last()).vr_nrctremp := 3960181;
    v_dados(v_dados.last()).vr_vllanmto := 76.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 102.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10006001;
    v_dados(v_dados.last()).vr_nrctremp := 3077352;
    v_dados(v_dados.last()).vr_vllanmto := 133.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9349049;
    v_dados(v_dados.last()).vr_nrctremp := 3142973;
    v_dados(v_dados.last()).vr_vllanmto := 993.22;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6928110;
    v_dados(v_dados.last()).vr_nrctremp := 3158672;
    v_dados(v_dados.last()).vr_vllanmto := 88.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3167828;
    v_dados(v_dados.last()).vr_vllanmto := 22.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194711;
    v_dados(v_dados.last()).vr_nrctremp := 3255466;
    v_dados(v_dados.last()).vr_vllanmto := 186.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6880924;
    v_dados(v_dados.last()).vr_nrctremp := 3313425;
    v_dados(v_dados.last()).vr_vllanmto := 34.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8637733;
    v_dados(v_dados.last()).vr_nrctremp := 4101609;
    v_dados(v_dados.last()).vr_vllanmto := 47.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230448;
    v_dados(v_dados.last()).vr_nrctremp := 3435628;
    v_dados(v_dados.last()).vr_vllanmto := 24.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80170781;
    v_dados(v_dados.last()).vr_nrctremp := 3472408;
    v_dados(v_dados.last()).vr_vllanmto := 51.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8656126;
    v_dados(v_dados.last()).vr_nrctremp := 4130394;
    v_dados(v_dados.last()).vr_vllanmto := 46.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12349909;
    v_dados(v_dados.last()).vr_nrctremp := 3549289;
    v_dados(v_dados.last()).vr_vllanmto := 32.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 125.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11093293;
    v_dados(v_dados.last()).vr_nrctremp := 3646338;
    v_dados(v_dados.last()).vr_vllanmto := 46.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12450316;
    v_dados(v_dados.last()).vr_nrctremp := 3647430;
    v_dados(v_dados.last()).vr_vllanmto := 40.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10800824;
    v_dados(v_dados.last()).vr_nrctremp := 3684745;
    v_dados(v_dados.last()).vr_vllanmto := 91.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 20.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 23.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11218142;
    v_dados(v_dados.last()).vr_nrctremp := 3732464;
    v_dados(v_dados.last()).vr_vllanmto := 35.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 3742862;
    v_dados(v_dados.last()).vr_vllanmto := 27.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 3808261;
    v_dados(v_dados.last()).vr_vllanmto := 23.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 16.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12560448;
    v_dados(v_dados.last()).vr_nrctremp := 3815662;
    v_dados(v_dados.last()).vr_vllanmto := 19.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617008;
    v_dados(v_dados.last()).vr_nrctremp := 3827456;
    v_dados(v_dados.last()).vr_vllanmto := 29.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11083050;
    v_dados(v_dados.last()).vr_nrctremp := 3837073;
    v_dados(v_dados.last()).vr_vllanmto := 56.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820408;
    v_dados(v_dados.last()).vr_nrctremp := 3838282;
    v_dados(v_dados.last()).vr_vllanmto := 28.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2124726;
    v_dados(v_dados.last()).vr_nrctremp := 3851551;
    v_dados(v_dados.last()).vr_vllanmto := 42.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9517766;
    v_dados(v_dados.last()).vr_nrctremp := 3855948;
    v_dados(v_dados.last()).vr_vllanmto := 60.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2752336;
    v_dados(v_dados.last()).vr_nrctremp := 3884678;
    v_dados(v_dados.last()).vr_vllanmto := 350.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 32.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 73.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533640;
    v_dados(v_dados.last()).vr_nrctremp := 3927171;
    v_dados(v_dados.last()).vr_vllanmto := 77.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710091;
    v_dados(v_dados.last()).vr_nrctremp := 3935842;
    v_dados(v_dados.last()).vr_vllanmto := 28.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12465321;
    v_dados(v_dados.last()).vr_nrctremp := 3936331;
    v_dados(v_dados.last()).vr_vllanmto := 23.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4048164;
    v_dados(v_dados.last()).vr_nrctremp := 3936549;
    v_dados(v_dados.last()).vr_vllanmto := 18.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12293407;
    v_dados(v_dados.last()).vr_nrctremp := 3938066;
    v_dados(v_dados.last()).vr_vllanmto := 30.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10866515;
    v_dados(v_dados.last()).vr_nrctremp := 4249800;
    v_dados(v_dados.last()).vr_vllanmto := 25.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3628280;
    v_dados(v_dados.last()).vr_nrctremp := 3965338;
    v_dados(v_dados.last()).vr_vllanmto := 22.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 28.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10206345;
    v_dados(v_dados.last()).vr_nrctremp := 4035306;
    v_dados(v_dados.last()).vr_vllanmto := 36.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2909421;
    v_dados(v_dados.last()).vr_nrctremp := 4055454;
    v_dados(v_dados.last()).vr_vllanmto := 17.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11464747;
    v_dados(v_dados.last()).vr_nrctremp := 4338788;
    v_dados(v_dados.last()).vr_vllanmto := 21.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739090;
    v_dados(v_dados.last()).vr_nrctremp := 4102671;
    v_dados(v_dados.last()).vr_vllanmto := 63.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12561762;
    v_dados(v_dados.last()).vr_nrctremp := 4109959;
    v_dados(v_dados.last()).vr_vllanmto := 93.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4016041;
    v_dados(v_dados.last()).vr_nrctremp := 4413361;
    v_dados(v_dados.last()).vr_vllanmto := 41.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 23.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12949353;
    v_dados(v_dados.last()).vr_nrctremp := 4148318;
    v_dados(v_dados.last()).vr_vllanmto := 19.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 4164558;
    v_dados(v_dados.last()).vr_vllanmto := 42.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9710604;
    v_dados(v_dados.last()).vr_nrctremp := 4164602;
    v_dados(v_dados.last()).vr_vllanmto := 47.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10571760;
    v_dados(v_dados.last()).vr_nrctremp := 4167462;
    v_dados(v_dados.last()).vr_vllanmto := 64.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12954101;
    v_dados(v_dados.last()).vr_nrctremp := 4169225;
    v_dados(v_dados.last()).vr_vllanmto := 35.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6365639;
    v_dados(v_dados.last()).vr_nrctremp := 4185048;
    v_dados(v_dados.last()).vr_vllanmto := 41.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4201717;
    v_dados(v_dados.last()).vr_vllanmto := 20.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12725480;
    v_dados(v_dados.last()).vr_nrctremp := 4202145;
    v_dados(v_dados.last()).vr_vllanmto := 31.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12756466;
    v_dados(v_dados.last()).vr_nrctremp := 4210230;
    v_dados(v_dados.last()).vr_vllanmto := 30.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12950750;
    v_dados(v_dados.last()).vr_nrctremp := 4224701;
    v_dados(v_dados.last()).vr_vllanmto := 21.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9519947;
    v_dados(v_dados.last()).vr_nrctremp := 4492928;
    v_dados(v_dados.last()).vr_vllanmto := 138.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11862300;
    v_dados(v_dados.last()).vr_nrctremp := 4539802;
    v_dados(v_dados.last()).vr_vllanmto := 2377.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12474444;
    v_dados(v_dados.last()).vr_nrctremp := 4592182;
    v_dados(v_dados.last()).vr_vllanmto := 30.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 20.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065661;
    v_dados(v_dados.last()).vr_nrctremp := 4267714;
    v_dados(v_dados.last()).vr_vllanmto := 22.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1705660;
    v_dados(v_dados.last()).vr_nrctremp := 4310541;
    v_dados(v_dados.last()).vr_vllanmto := 112.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10645292;
    v_dados(v_dados.last()).vr_nrctremp := 4312871;
    v_dados(v_dados.last()).vr_vllanmto := 25.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9210750;
    v_dados(v_dados.last()).vr_nrctremp := 4338371;
    v_dados(v_dados.last()).vr_vllanmto := 66.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6942032;
    v_dados(v_dados.last()).vr_nrctremp := 4649636;
    v_dados(v_dados.last()).vr_vllanmto := 19.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12957461;
    v_dados(v_dados.last()).vr_nrctremp := 4349766;
    v_dados(v_dados.last()).vr_vllanmto := 43.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13110519;
    v_dados(v_dados.last()).vr_nrctremp := 4375141;
    v_dados(v_dados.last()).vr_vllanmto := 34.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 32.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 82.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11834021;
    v_dados(v_dados.last()).vr_nrctremp := 4407237;
    v_dados(v_dados.last()).vr_vllanmto := 32.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10442391;
    v_dados(v_dados.last()).vr_nrctremp := 4693678;
    v_dados(v_dados.last()).vr_vllanmto := 16.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 44.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2296667;
    v_dados(v_dados.last()).vr_nrctremp := 4423623;
    v_dados(v_dados.last()).vr_vllanmto := 42.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13177630;
    v_dados(v_dados.last()).vr_nrctremp := 4428083;
    v_dados(v_dados.last()).vr_vllanmto := 19.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6087370;
    v_dados(v_dados.last()).vr_nrctremp := 4428207;
    v_dados(v_dados.last()).vr_vllanmto := 21.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13145088;
    v_dados(v_dados.last()).vr_nrctremp := 4430603;
    v_dados(v_dados.last()).vr_vllanmto := 33.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 41.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10465537;
    v_dados(v_dados.last()).vr_nrctremp := 4476841;
    v_dados(v_dados.last()).vr_vllanmto := 16.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11505184;
    v_dados(v_dados.last()).vr_nrctremp := 4486388;
    v_dados(v_dados.last()).vr_vllanmto := 58.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10265651;
    v_dados(v_dados.last()).vr_nrctremp := 4717159;
    v_dados(v_dados.last()).vr_vllanmto := 41.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 52.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10092366;
    v_dados(v_dados.last()).vr_nrctremp := 4521572;
    v_dados(v_dados.last()).vr_vllanmto := 34.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12508551;
    v_dados(v_dados.last()).vr_nrctremp := 4527754;
    v_dados(v_dados.last()).vr_vllanmto := 826.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10148795;
    v_dados(v_dados.last()).vr_nrctremp := 4740173;
    v_dados(v_dados.last()).vr_vllanmto := 20.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476651;
    v_dados(v_dados.last()).vr_nrctremp := 4558023;
    v_dados(v_dados.last()).vr_vllanmto := 44.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6788580;
    v_dados(v_dados.last()).vr_nrctremp := 4566950;
    v_dados(v_dados.last()).vr_vllanmto := 19.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741741;
    v_dados(v_dados.last()).vr_nrctremp := 4570333;
    v_dados(v_dados.last()).vr_vllanmto := 45.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573117;
    v_dados(v_dados.last()).vr_vllanmto := 18.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9406352;
    v_dados(v_dados.last()).vr_nrctremp := 4576551;
    v_dados(v_dados.last()).vr_vllanmto := 37.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 21.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10889833;
    v_dados(v_dados.last()).vr_nrctremp := 4581853;
    v_dados(v_dados.last()).vr_vllanmto := 57.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11615770;
    v_dados(v_dados.last()).vr_nrctremp := 4589257;
    v_dados(v_dados.last()).vr_vllanmto := 24.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10432515;
    v_dados(v_dados.last()).vr_nrctremp := 4783814;
    v_dados(v_dados.last()).vr_vllanmto := 27.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 26.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 77.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683352;
    v_dados(v_dados.last()).vr_nrctremp := 4624468;
    v_dados(v_dados.last()).vr_vllanmto := 46.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356380;
    v_dados(v_dados.last()).vr_nrctremp := 4642262;
    v_dados(v_dados.last()).vr_vllanmto := 40.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11629410;
    v_dados(v_dados.last()).vr_nrctremp := 4924495;
    v_dados(v_dados.last()).vr_vllanmto := 81.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11908637;
    v_dados(v_dados.last()).vr_nrctremp := 4650401;
    v_dados(v_dados.last()).vr_vllanmto := 29.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13481622;
    v_dados(v_dados.last()).vr_nrctremp := 4650705;
    v_dados(v_dados.last()).vr_vllanmto := 39.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10443576;
    v_dados(v_dados.last()).vr_nrctremp := 4660368;
    v_dados(v_dados.last()).vr_vllanmto := 27.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13440241;
    v_dados(v_dados.last()).vr_nrctremp := 4672702;
    v_dados(v_dados.last()).vr_vllanmto := 39.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11786345;
    v_dados(v_dados.last()).vr_nrctremp := 4680798;
    v_dados(v_dados.last()).vr_vllanmto := 26.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11379014;
    v_dados(v_dados.last()).vr_nrctremp := 5061942;
    v_dados(v_dados.last()).vr_vllanmto := 2372.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80434720;
    v_dados(v_dados.last()).vr_nrctremp := 4705785;
    v_dados(v_dados.last()).vr_vllanmto := 116.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9547479;
    v_dados(v_dados.last()).vr_nrctremp := 2155460;
    v_dados(v_dados.last()).vr_vllanmto := 317.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11951605;
    v_dados(v_dados.last()).vr_nrctremp := 4745153;
    v_dados(v_dados.last()).vr_vllanmto := 28.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8822905;
    v_dados(v_dados.last()).vr_nrctremp := 4746205;
    v_dados(v_dados.last()).vr_vllanmto := 38.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4077008;
    v_dados(v_dados.last()).vr_nrctremp := 4746811;
    v_dados(v_dados.last()).vr_vllanmto := 17.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12288195;
    v_dados(v_dados.last()).vr_nrctremp := 4761996;
    v_dados(v_dados.last()).vr_vllanmto := 17.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80362419;
    v_dados(v_dados.last()).vr_nrctremp := 4762997;
    v_dados(v_dados.last()).vr_vllanmto := 34.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11035528;
    v_dados(v_dados.last()).vr_nrctremp := 4777035;
    v_dados(v_dados.last()).vr_vllanmto := 35.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9877916;
    v_dados(v_dados.last()).vr_nrctremp := 2835102;
    v_dados(v_dados.last()).vr_vllanmto := 26.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12324841;
    v_dados(v_dados.last()).vr_nrctremp := 4822507;
    v_dados(v_dados.last()).vr_vllanmto := 22.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4829674;
    v_dados(v_dados.last()).vr_vllanmto := 59.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9274456;
    v_dados(v_dados.last()).vr_nrctremp := 4881776;
    v_dados(v_dados.last()).vr_vllanmto := 21.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3761240;
    v_dados(v_dados.last()).vr_nrctremp := 4898751;
    v_dados(v_dados.last()).vr_vllanmto := 199.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12278653;
    v_dados(v_dados.last()).vr_nrctremp := 4912772;
    v_dados(v_dados.last()).vr_vllanmto := 31.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13581155;
    v_dados(v_dados.last()).vr_nrctremp := 4921029;
    v_dados(v_dados.last()).vr_vllanmto := 34.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 773565;
    v_dados(v_dados.last()).vr_nrctremp := 4922540;
    v_dados(v_dados.last()).vr_vllanmto := 18.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80193501;
    v_dados(v_dados.last()).vr_nrctremp := 3813432;
    v_dados(v_dados.last()).vr_vllanmto := 64.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13768689;
    v_dados(v_dados.last()).vr_nrctremp := 4969255;
    v_dados(v_dados.last()).vr_vllanmto := 30.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80234216;
    v_dados(v_dados.last()).vr_nrctremp := 4997069;
    v_dados(v_dados.last()).vr_vllanmto := 16.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13923595;
    v_dados(v_dados.last()).vr_nrctremp := 5022137;
    v_dados(v_dados.last()).vr_vllanmto := 137.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11754079;
    v_dados(v_dados.last()).vr_nrctremp := 5034347;
    v_dados(v_dados.last()).vr_vllanmto := 16.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12504998;
    v_dados(v_dados.last()).vr_nrctremp := 4229059;
    v_dados(v_dados.last()).vr_vllanmto := 93.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084035;
    v_dados(v_dados.last()).vr_vllanmto := 1978.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084047;
    v_dados(v_dados.last()).vr_vllanmto := 4782.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5084058;
    v_dados(v_dados.last()).vr_vllanmto := 7174.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4038142;
    v_dados(v_dados.last()).vr_nrctremp := 5108831;
    v_dados(v_dados.last()).vr_vllanmto := 23.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8655529;
    v_dados(v_dados.last()).vr_nrctremp := 5131105;
    v_dados(v_dados.last()).vr_vllanmto := 119.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1927337;
    v_dados(v_dados.last()).vr_nrctremp := 5139328;
    v_dados(v_dados.last()).vr_vllanmto := 16.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11618191;
    v_dados(v_dados.last()).vr_nrctremp := 5198619;
    v_dados(v_dados.last()).vr_vllanmto := 267.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80090842;
    v_dados(v_dados.last()).vr_nrctremp := 5204912;
    v_dados(v_dados.last()).vr_vllanmto := 90.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5237759;
    v_dados(v_dados.last()).vr_vllanmto := 9873.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6300570;
    v_dados(v_dados.last()).vr_nrctremp := 5336438;
    v_dados(v_dados.last()).vr_vllanmto := 23.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 133.31;
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
