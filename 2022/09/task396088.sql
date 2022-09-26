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
  v_dados(v_dados.last()).vr_nrdconta := 80093159;
  v_dados(v_dados.last()).vr_nrctremp := 1886421;
  v_dados(v_dados.last()).vr_vllanmto := 171.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10448799;
  v_dados(v_dados.last()).vr_nrctremp := 1922621;
  v_dados(v_dados.last()).vr_vllanmto := 137.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80147194;
  v_dados(v_dados.last()).vr_nrctremp := 2040841;
  v_dados(v_dados.last()).vr_vllanmto := 82.43;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10283439;
  v_dados(v_dados.last()).vr_nrctremp := 2042069;
  v_dados(v_dados.last()).vr_vllanmto := 24.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9193081;
  v_dados(v_dados.last()).vr_nrctremp := 2102720;
  v_dados(v_dados.last()).vr_vllanmto := 65.34;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10349898;
  v_dados(v_dados.last()).vr_nrctremp := 2118569;
  v_dados(v_dados.last()).vr_vllanmto := 97.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9547479;
  v_dados(v_dados.last()).vr_nrctremp := 2155460;
  v_dados(v_dados.last()).vr_vllanmto := 82.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6037550;
  v_dados(v_dados.last()).vr_nrctremp := 2158838;
  v_dados(v_dados.last()).vr_vllanmto := 164.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80060242;
  v_dados(v_dados.last()).vr_nrctremp := 2214162;
  v_dados(v_dados.last()).vr_vllanmto := 139.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8652007;
  v_dados(v_dados.last()).vr_nrctremp := 2507442;
  v_dados(v_dados.last()).vr_vllanmto := 332.81;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7669437;
  v_dados(v_dados.last()).vr_nrctremp := 2507640;
  v_dados(v_dados.last()).vr_vllanmto := 138.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4050061;
  v_dados(v_dados.last()).vr_nrctremp := 2595397;
  v_dados(v_dados.last()).vr_vllanmto := 383.72;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11203528;
  v_dados(v_dados.last()).vr_nrctremp := 2732832;
  v_dados(v_dados.last()).vr_vllanmto := 45.5;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80476260;
  v_dados(v_dados.last()).vr_nrctremp := 2816090;
  v_dados(v_dados.last()).vr_vllanmto := 1890.96;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11586915;
  v_dados(v_dados.last()).vr_nrctremp := 2909668;
  v_dados(v_dados.last()).vr_vllanmto := 77.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9612696;
  v_dados(v_dados.last()).vr_nrctremp := 2913350;
  v_dados(v_dados.last()).vr_vllanmto := 805.86;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10245537;
  v_dados(v_dados.last()).vr_nrctremp := 2952113;
  v_dados(v_dados.last()).vr_vllanmto := 25.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7434928;
  v_dados(v_dados.last()).vr_nrctremp := 2955176;
  v_dados(v_dados.last()).vr_vllanmto := 55.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80101062;
  v_dados(v_dados.last()).vr_nrctremp := 2955278;
  v_dados(v_dados.last()).vr_vllanmto := 124.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10605843;
  v_dados(v_dados.last()).vr_nrctremp := 2955350;
  v_dados(v_dados.last()).vr_vllanmto := 70.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80173870;
  v_dados(v_dados.last()).vr_nrctremp := 2955468;
  v_dados(v_dados.last()).vr_vllanmto := 42.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8837813;
  v_dados(v_dados.last()).vr_nrctremp := 2955566;
  v_dados(v_dados.last()).vr_vllanmto := 187.47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9415130;
  v_dados(v_dados.last()).vr_nrctremp := 2955637;
  v_dados(v_dados.last()).vr_vllanmto := 95.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9683097;
  v_dados(v_dados.last()).vr_nrctremp := 2955793;
  v_dados(v_dados.last()).vr_vllanmto := 45.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80340873;
  v_dados(v_dados.last()).vr_nrctremp := 2955797;
  v_dados(v_dados.last()).vr_vllanmto := 288.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7521537;
  v_dados(v_dados.last()).vr_nrctremp := 2955842;
  v_dados(v_dados.last()).vr_vllanmto := 83.34;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8276412;
  v_dados(v_dados.last()).vr_nrctremp := 2956155;
  v_dados(v_dados.last()).vr_vllanmto := 46.69;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9233962;
  v_dados(v_dados.last()).vr_nrctremp := 2958985;
  v_dados(v_dados.last()).vr_vllanmto := 44.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10179569;
  v_dados(v_dados.last()).vr_nrctremp := 2967816;
  v_dados(v_dados.last()).vr_vllanmto := 135.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11779608;
  v_dados(v_dados.last()).vr_nrctremp := 2979926;
  v_dados(v_dados.last()).vr_vllanmto := 57.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6935915;
  v_dados(v_dados.last()).vr_nrctremp := 2991942;
  v_dados(v_dados.last()).vr_vllanmto := 362.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11717947;
  v_dados(v_dados.last()).vr_nrctremp := 3005429;
  v_dados(v_dados.last()).vr_vllanmto := 136.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10827200;
  v_dados(v_dados.last()).vr_nrctremp := 3008250;
  v_dados(v_dados.last()).vr_vllanmto := 36.19;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11703458;
  v_dados(v_dados.last()).vr_nrctremp := 3009568;
  v_dados(v_dados.last()).vr_vllanmto := 2909.65;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11776340;
  v_dados(v_dados.last()).vr_nrctremp := 3032948;
  v_dados(v_dados.last()).vr_vllanmto := 11.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8462461;
  v_dados(v_dados.last()).vr_nrctremp := 3041554;
  v_dados(v_dados.last()).vr_vllanmto := 53.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10338306;
  v_dados(v_dados.last()).vr_nrctremp := 3042647;
  v_dados(v_dados.last()).vr_vllanmto := 751.55;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80249469;
  v_dados(v_dados.last()).vr_nrctremp := 3075184;
  v_dados(v_dados.last()).vr_vllanmto := 45.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10682333;
  v_dados(v_dados.last()).vr_nrctremp := 3088171;
  v_dados(v_dados.last()).vr_vllanmto := 21.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11712643;
  v_dados(v_dados.last()).vr_nrctremp := 3098270;
  v_dados(v_dados.last()).vr_vllanmto := 93.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10657673;
  v_dados(v_dados.last()).vr_nrctremp := 3167828;
  v_dados(v_dados.last()).vr_vllanmto := 15.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9868925;
  v_dados(v_dados.last()).vr_nrctremp := 3230862;
  v_dados(v_dados.last()).vr_vllanmto := 31.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11807113;
  v_dados(v_dados.last()).vr_nrctremp := 3252824;
  v_dados(v_dados.last()).vr_vllanmto := 40.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9884955;
  v_dados(v_dados.last()).vr_nrctremp := 3253959;
  v_dados(v_dados.last()).vr_vllanmto := 54.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12074233;
  v_dados(v_dados.last()).vr_nrctremp := 3255681;
  v_dados(v_dados.last()).vr_vllanmto := 52.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12103721;
  v_dados(v_dados.last()).vr_nrctremp := 3289303;
  v_dados(v_dados.last()).vr_vllanmto := 29.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8289077;
  v_dados(v_dados.last()).vr_nrctremp := 3293193;
  v_dados(v_dados.last()).vr_vllanmto := 74.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12111791;
  v_dados(v_dados.last()).vr_nrctremp := 3296814;
  v_dados(v_dados.last()).vr_vllanmto := 134.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6880924;
  v_dados(v_dados.last()).vr_nrctremp := 3313425;
  v_dados(v_dados.last()).vr_vllanmto := 23.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12166103;
  v_dados(v_dados.last()).vr_nrctremp := 3369926;
  v_dados(v_dados.last()).vr_vllanmto := 809.34;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2158078;
  v_dados(v_dados.last()).vr_nrctremp := 3383008;
  v_dados(v_dados.last()).vr_vllanmto := 29.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11656948;
  v_dados(v_dados.last()).vr_nrctremp := 3404940;
  v_dados(v_dados.last()).vr_vllanmto := 65.94;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12021490;
  v_dados(v_dados.last()).vr_nrctremp := 3421230;
  v_dados(v_dados.last()).vr_vllanmto := 48.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12230448;
  v_dados(v_dados.last()).vr_nrctremp := 3435628;
  v_dados(v_dados.last()).vr_vllanmto := 29.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12239470;
  v_dados(v_dados.last()).vr_nrctremp := 3436180;
  v_dados(v_dados.last()).vr_vllanmto := 51.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80476260;
  v_dados(v_dados.last()).vr_nrctremp := 3458595;
  v_dados(v_dados.last()).vr_vllanmto := 30.96;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80170781;
  v_dados(v_dados.last()).vr_nrctremp := 3472408;
  v_dados(v_dados.last()).vr_vllanmto := 33.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12300349;
  v_dados(v_dados.last()).vr_nrctremp := 3504420;
  v_dados(v_dados.last()).vr_vllanmto := 15.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12349909;
  v_dados(v_dados.last()).vr_nrctremp := 3549289;
  v_dados(v_dados.last()).vr_vllanmto := 58.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80101089;
  v_dados(v_dados.last()).vr_nrctremp := 3549323;
  v_dados(v_dados.last()).vr_vllanmto := 69.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12360082;
  v_dados(v_dados.last()).vr_nrctremp := 3555694;
  v_dados(v_dados.last()).vr_vllanmto := 29.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12383708;
  v_dados(v_dados.last()).vr_nrctremp := 3578578;
  v_dados(v_dados.last()).vr_vllanmto := 33.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12424579;
  v_dados(v_dados.last()).vr_nrctremp := 3618246;
  v_dados(v_dados.last()).vr_vllanmto := 17.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3077446;
  v_dados(v_dados.last()).vr_nrctremp := 3619639;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12420085;
  v_dados(v_dados.last()).vr_nrctremp := 3621331;
  v_dados(v_dados.last()).vr_vllanmto := 30.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8907315;
  v_dados(v_dados.last()).vr_nrctremp := 3627786;
  v_dados(v_dados.last()).vr_vllanmto := 38.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11093293;
  v_dados(v_dados.last()).vr_nrctremp := 3646338;
  v_dados(v_dados.last()).vr_vllanmto := 26.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12450316;
  v_dados(v_dados.last()).vr_nrctremp := 3647430;
  v_dados(v_dados.last()).vr_vllanmto := 59.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11057300;
  v_dados(v_dados.last()).vr_nrctremp := 3653854;
  v_dados(v_dados.last()).vr_vllanmto := 51.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12305804;
  v_dados(v_dados.last()).vr_nrctremp := 3656154;
  v_dados(v_dados.last()).vr_vllanmto := 24.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12488968;
  v_dados(v_dados.last()).vr_nrctremp := 3695226;
  v_dados(v_dados.last()).vr_vllanmto := 28.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12487937;
  v_dados(v_dados.last()).vr_nrctremp := 3703633;
  v_dados(v_dados.last()).vr_vllanmto := 29.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12362778;
  v_dados(v_dados.last()).vr_nrctremp := 3742862;
  v_dados(v_dados.last()).vr_vllanmto := 79.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12558010;
  v_dados(v_dados.last()).vr_nrctremp := 3763615;
  v_dados(v_dados.last()).vr_vllanmto := 21.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12572713;
  v_dados(v_dados.last()).vr_nrctremp := 3795640;
  v_dados(v_dados.last()).vr_vllanmto := 32.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8111383;
  v_dados(v_dados.last()).vr_nrctremp := 3805450;
  v_dados(v_dados.last()).vr_vllanmto := 16.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12560448;
  v_dados(v_dados.last()).vr_nrctremp := 3815662;
  v_dados(v_dados.last()).vr_vllanmto := 24.7;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12617008;
  v_dados(v_dados.last()).vr_nrctremp := 3827456;
  v_dados(v_dados.last()).vr_vllanmto := 36.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12595080;
  v_dados(v_dados.last()).vr_nrctremp := 3836849;
  v_dados(v_dados.last()).vr_vllanmto := 28.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3820408;
  v_dados(v_dados.last()).vr_nrctremp := 3838282;
  v_dados(v_dados.last()).vr_vllanmto := 44.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2124726;
  v_dados(v_dados.last()).vr_nrctremp := 3851551;
  v_dados(v_dados.last()).vr_vllanmto := 64.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12637106;
  v_dados(v_dados.last()).vr_nrctremp := 3868680;
  v_dados(v_dados.last()).vr_vllanmto := 21.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12543004;
  v_dados(v_dados.last()).vr_nrctremp := 3869309;
  v_dados(v_dados.last()).vr_vllanmto := 31.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7797320;
  v_dados(v_dados.last()).vr_nrctremp := 3869609;
  v_dados(v_dados.last()).vr_vllanmto := 46.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12669016;
  v_dados(v_dados.last()).vr_nrctremp := 3876683;
  v_dados(v_dados.last()).vr_vllanmto := 22.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12670642;
  v_dados(v_dados.last()).vr_nrctremp := 3877832;
  v_dados(v_dados.last()).vr_vllanmto := 22.34;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8465886;
  v_dados(v_dados.last()).vr_nrctremp := 3885563;
  v_dados(v_dados.last()).vr_vllanmto := 49.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12634344;
  v_dados(v_dados.last()).vr_nrctremp := 3891425;
  v_dados(v_dados.last()).vr_vllanmto := 12.86;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12690562;
  v_dados(v_dados.last()).vr_nrctremp := 3897149;
  v_dados(v_dados.last()).vr_vllanmto := 45.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12690392;
  v_dados(v_dados.last()).vr_nrctremp := 3897211;
  v_dados(v_dados.last()).vr_vllanmto := 16.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7533640;
  v_dados(v_dados.last()).vr_nrctremp := 3927171;
  v_dados(v_dados.last()).vr_vllanmto := 58.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9190449;
  v_dados(v_dados.last()).vr_nrctremp := 3932307;
  v_dados(v_dados.last()).vr_vllanmto := 46.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12465321;
  v_dados(v_dados.last()).vr_nrctremp := 3936331;
  v_dados(v_dados.last()).vr_vllanmto := 40.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12700860;
  v_dados(v_dados.last()).vr_nrctremp := 3939478;
  v_dados(v_dados.last()).vr_vllanmto := 23.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12752827;
  v_dados(v_dados.last()).vr_nrctremp := 3960181;
  v_dados(v_dados.last()).vr_vllanmto := 83.76;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3628280;
  v_dados(v_dados.last()).vr_nrctremp := 3965338;
  v_dados(v_dados.last()).vr_vllanmto := 10.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12582565;
  v_dados(v_dados.last()).vr_nrctremp := 3986201;
  v_dados(v_dados.last()).vr_vllanmto := 53.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8058717;
  v_dados(v_dados.last()).vr_nrctremp := 3990688;
  v_dados(v_dados.last()).vr_vllanmto := 55.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12762067;
  v_dados(v_dados.last()).vr_nrctremp := 4020012;
  v_dados(v_dados.last()).vr_vllanmto := 31.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10206345;
  v_dados(v_dados.last()).vr_nrctremp := 4035306;
  v_dados(v_dados.last()).vr_vllanmto := 21.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80012248;
  v_dados(v_dados.last()).vr_nrctremp := 4068844;
  v_dados(v_dados.last()).vr_vllanmto := 25.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12752916;
  v_dados(v_dados.last()).vr_nrctremp := 4073735;
  v_dados(v_dados.last()).vr_vllanmto := 31.86;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12873853;
  v_dados(v_dados.last()).vr_nrctremp := 4082058;
  v_dados(v_dados.last()).vr_vllanmto := 66.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12813826;
  v_dados(v_dados.last()).vr_nrctremp := 4097768;
  v_dados(v_dados.last()).vr_vllanmto := 10.69;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12958174;
  v_dados(v_dados.last()).vr_nrctremp := 4140877;
  v_dados(v_dados.last()).vr_vllanmto := 26.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10571760;
  v_dados(v_dados.last()).vr_nrctremp := 4167462;
  v_dados(v_dados.last()).vr_vllanmto := 50.54;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12509680;
  v_dados(v_dados.last()).vr_nrctremp := 4175452;
  v_dados(v_dados.last()).vr_vllanmto := 52.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7374763;
  v_dados(v_dados.last()).vr_nrctremp := 4178604;
  v_dados(v_dados.last()).vr_vllanmto := 19.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12833797;
  v_dados(v_dados.last()).vr_nrctremp := 4181782;
  v_dados(v_dados.last()).vr_vllanmto := 21.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12756466;
  v_dados(v_dados.last()).vr_nrctremp := 4210230;
  v_dados(v_dados.last()).vr_vllanmto := 18.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13029568;
  v_dados(v_dados.last()).vr_nrctremp := 4212320;
  v_dados(v_dados.last()).vr_vllanmto := 13.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12113743;
  v_dados(v_dados.last()).vr_nrctremp := 4221205;
  v_dados(v_dados.last()).vr_vllanmto := 25.39;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 8719705;
  v_dados(v_dados.last()).vr_nrctremp := 4222466;
  v_dados(v_dados.last()).vr_vllanmto := 11.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12950750;
  v_dados(v_dados.last()).vr_nrctremp := 4224701;
  v_dados(v_dados.last()).vr_vllanmto := 12.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12741450;
  v_dados(v_dados.last()).vr_nrctremp := 4226847;
  v_dados(v_dados.last()).vr_vllanmto := 10.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10275860;
  v_dados(v_dados.last()).vr_nrctremp := 4241038;
  v_dados(v_dados.last()).vr_vllanmto := 11.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11806222;
  v_dados(v_dados.last()).vr_nrctremp := 4245131;
  v_dados(v_dados.last()).vr_vllanmto := 27.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12389404;
  v_dados(v_dados.last()).vr_nrctremp := 4250955;
  v_dados(v_dados.last()).vr_vllanmto := 17.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12817678;
  v_dados(v_dados.last()).vr_nrctremp := 4256682;
  v_dados(v_dados.last()).vr_vllanmto := 22.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13065661;
  v_dados(v_dados.last()).vr_nrctremp := 4267714;
  v_dados(v_dados.last()).vr_vllanmto := 11.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 1705660;
  v_dados(v_dados.last()).vr_nrctremp := 4310541;
  v_dados(v_dados.last()).vr_vllanmto := 28.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13184270;
  v_dados(v_dados.last()).vr_nrctremp := 4313478;
  v_dados(v_dados.last()).vr_vllanmto := 96.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13202502;
  v_dados(v_dados.last()).vr_nrctremp := 4330143;
  v_dados(v_dados.last()).vr_vllanmto := 14.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11044039;
  v_dados(v_dados.last()).vr_nrctremp := 4344288;
  v_dados(v_dados.last()).vr_vllanmto := 48.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10896384;
  v_dados(v_dados.last()).vr_nrctremp := 4357704;
  v_dados(v_dados.last()).vr_vllanmto := 26.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2296667;
  v_dados(v_dados.last()).vr_nrctremp := 4423623;
  v_dados(v_dados.last()).vr_vllanmto := 26.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13177630;
  v_dados(v_dados.last()).vr_nrctremp := 4428083;
  v_dados(v_dados.last()).vr_vllanmto := 10.29;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 2415119;
  v_dados(v_dados.last()).vr_nrctremp := 4440402;
  v_dados(v_dados.last()).vr_vllanmto := 33.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10226745;
  v_dados(v_dados.last()).vr_nrctremp := 4440559;
  v_dados(v_dados.last()).vr_vllanmto := 30.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12739103;
  v_dados(v_dados.last()).vr_nrctremp := 4441023;
  v_dados(v_dados.last()).vr_vllanmto := 24.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12089613;
  v_dados(v_dados.last()).vr_nrctremp := 4445918;
  v_dados(v_dados.last()).vr_vllanmto := 40.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13344048;
  v_dados(v_dados.last()).vr_nrctremp := 4462768;
  v_dados(v_dados.last()).vr_vllanmto := 24.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13342509;
  v_dados(v_dados.last()).vr_nrctremp := 4463416;
  v_dados(v_dados.last()).vr_vllanmto := 10.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13209248;
  v_dados(v_dados.last()).vr_nrctremp := 4499591;
  v_dados(v_dados.last()).vr_vllanmto := 13.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13137433;
  v_dados(v_dados.last()).vr_nrctremp := 4499682;
  v_dados(v_dados.last()).vr_vllanmto := 34.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9501096;
  v_dados(v_dados.last()).vr_nrctremp := 4531209;
  v_dados(v_dados.last()).vr_vllanmto := 10.99;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80476651;
  v_dados(v_dados.last()).vr_nrctremp := 4558023;
  v_dados(v_dados.last()).vr_vllanmto := 11.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11875283;
  v_dados(v_dados.last()).vr_nrctremp := 4559125;
  v_dados(v_dados.last()).vr_vllanmto := 15.72;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13545418;
  v_dados(v_dados.last()).vr_nrctremp := 4576167;
  v_dados(v_dados.last()).vr_vllanmto := 192.23;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11615770;
  v_dados(v_dados.last()).vr_nrctremp := 4589257;
  v_dados(v_dados.last()).vr_vllanmto := 50.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9734325;
  v_dados(v_dados.last()).vr_nrctremp := 4598794;
  v_dados(v_dados.last()).vr_vllanmto := 11.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3013529;
  v_dados(v_dados.last()).vr_nrctremp := 4615616;
  v_dados(v_dados.last()).vr_vllanmto := 108.03;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 6155677;
  v_dados(v_dados.last()).vr_nrctremp := 4638991;
  v_dados(v_dados.last()).vr_vllanmto := 13.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3026450;
  v_dados(v_dados.last()).vr_nrctremp := 4642781;
  v_dados(v_dados.last()).vr_vllanmto := 16.21;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13659030;
  v_dados(v_dados.last()).vr_nrctremp := 4663143;
  v_dados(v_dados.last()).vr_vllanmto := 10.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13455435;
  v_dados(v_dados.last()).vr_nrctremp := 4674078;
  v_dados(v_dados.last()).vr_vllanmto := 367.61;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9199420;
  v_dados(v_dados.last()).vr_nrctremp := 4699446;
  v_dados(v_dados.last()).vr_vllanmto := 11.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9973877;
  v_dados(v_dados.last()).vr_nrctremp := 4705248;
  v_dados(v_dados.last()).vr_vllanmto := 15.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13763890;
  v_dados(v_dados.last()).vr_nrctremp := 4739175;
  v_dados(v_dados.last()).vr_vllanmto := 10.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11951605;
  v_dados(v_dados.last()).vr_nrctremp := 4745153;
  v_dados(v_dados.last()).vr_vllanmto := 21.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80069665;
  v_dados(v_dados.last()).vr_nrctremp := 4829674;
  v_dados(v_dados.last()).vr_vllanmto := 14.88;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10636048;
  v_dados(v_dados.last()).vr_nrctremp := 4839172;
  v_dados(v_dados.last()).vr_vllanmto := 14.04;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13725190;
  v_dados(v_dados.last()).vr_nrctremp := 4846648;
  v_dados(v_dados.last()).vr_vllanmto := 21.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12143200;
  v_dados(v_dados.last()).vr_nrctremp := 4857588;
  v_dados(v_dados.last()).vr_vllanmto := 20.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9608710;
  v_dados(v_dados.last()).vr_nrctremp := 4871992;
  v_dados(v_dados.last()).vr_vllanmto := 10.81;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 3637271;
  v_dados(v_dados.last()).vr_nrctremp := 4876229;
  v_dados(v_dados.last()).vr_vllanmto := 26.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9274456;
  v_dados(v_dados.last()).vr_nrctremp := 4881776;
  v_dados(v_dados.last()).vr_vllanmto := 21.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 11009993;
  v_dados(v_dados.last()).vr_nrctremp := 4901511;
  v_dados(v_dados.last()).vr_vllanmto := 15.41;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13581155;
  v_dados(v_dados.last()).vr_nrctremp := 4921029;
  v_dados(v_dados.last()).vr_vllanmto := 10.9;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80214479;
  v_dados(v_dados.last()).vr_nrctremp := 4921364;
  v_dados(v_dados.last()).vr_vllanmto := 38.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 80234216;
  v_dados(v_dados.last()).vr_nrctremp := 4997069;
  v_dados(v_dados.last()).vr_vllanmto := 26.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7765002;
  v_dados(v_dados.last()).vr_nrctremp := 5020530;
  v_dados(v_dados.last()).vr_vllanmto := 17.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 13437275;
  v_dados(v_dados.last()).vr_nrctremp := 5043613;
  v_dados(v_dados.last()).vr_vllanmto := 329.06;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9768076;
  v_dados(v_dados.last()).vr_nrctremp := 5068501;
  v_dados(v_dados.last()).vr_vllanmto := 360.56;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 4038142;
  v_dados(v_dados.last()).vr_nrctremp := 5108831;
  v_dados(v_dados.last()).vr_vllanmto := 63.44;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10065067;
  v_dados(v_dados.last()).vr_nrctremp := 5120902;
  v_dados(v_dados.last()).vr_vllanmto := 13.93;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10782524;
  v_dados(v_dados.last()).vr_nrctremp := 5126283;
  v_dados(v_dados.last()).vr_vllanmto := 21.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 7206895;
  v_dados(v_dados.last()).vr_nrctremp := 5170845;
  v_dados(v_dados.last()).vr_vllanmto := 18.53;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9666869;
  v_dados(v_dados.last()).vr_nrctremp := 5196774;
  v_dados(v_dados.last()).vr_vllanmto := 11.49;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 12981877;
  v_dados(v_dados.last()).vr_nrctremp := 5200658;
  v_dados(v_dados.last()).vr_vllanmto := 132.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10816186;
  v_dados(v_dados.last()).vr_nrctremp := 5216299;
  v_dados(v_dados.last()).vr_vllanmto := 34.48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 9819436;
  v_dados(v_dados.last()).vr_nrctremp := 5308137;
  v_dados(v_dados.last()).vr_vllanmto := 5677.08;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 1;
  v_dados(v_dados.last()).vr_nrdconta := 10010246;
  v_dados(v_dados.last()).vr_nrctremp := 5427207;
  v_dados(v_dados.last()).vr_vllanmto := 35.67;
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
