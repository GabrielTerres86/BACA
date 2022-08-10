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
    v_dados(v_dados.last()).vr_nrdconta := 773565;
    v_dados(v_dados.last()).vr_nrctremp := 4922540;
    v_dados(v_dados.last()).vr_vllanmto := 11.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10827200;
    v_dados(v_dados.last()).vr_nrctremp := 3008250;
    v_dados(v_dados.last()).vr_vllanmto := 91.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2158078;
    v_dados(v_dados.last()).vr_nrctremp := 3383008;
    v_dados(v_dados.last()).vr_vllanmto := 41.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2099195;
    v_dados(v_dados.last()).vr_nrctremp := 2883655;
    v_dados(v_dados.last()).vr_vllanmto := 189.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2183315;
    v_dados(v_dados.last()).vr_nrctremp := 3907302;
    v_dados(v_dados.last()).vr_vllanmto := 53.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2540495;
    v_dados(v_dados.last()).vr_nrctremp := 4699203;
    v_dados(v_dados.last()).vr_vllanmto := 19.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2757222;
    v_dados(v_dados.last()).vr_nrctremp := 4899377;
    v_dados(v_dados.last()).vr_vllanmto := 11.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741741;
    v_dados(v_dados.last()).vr_nrctremp := 4570333;
    v_dados(v_dados.last()).vr_vllanmto := 56.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2752336;
    v_dados(v_dados.last()).vr_nrctremp := 3884678;
    v_dados(v_dados.last()).vr_vllanmto := 152.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2811030;
    v_dados(v_dados.last()).vr_nrctremp := 4751728;
    v_dados(v_dados.last()).vr_vllanmto := 34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 51.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2909421;
    v_dados(v_dados.last()).vr_nrctremp := 4055454;
    v_dados(v_dados.last()).vr_vllanmto := 14.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3026450;
    v_dados(v_dados.last()).vr_nrctremp := 4642781;
    v_dados(v_dados.last()).vr_vllanmto := 89.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 139.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 139.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3628280;
    v_dados(v_dados.last()).vr_nrctremp := 3965338;
    v_dados(v_dados.last()).vr_vllanmto := 24.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3637271;
    v_dados(v_dados.last()).vr_nrctremp := 4876229;
    v_dados(v_dados.last()).vr_vllanmto := 58.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820408;
    v_dados(v_dados.last()).vr_nrctremp := 3838282;
    v_dados(v_dados.last()).vr_vllanmto := 54.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3721124;
    v_dados(v_dados.last()).vr_nrctremp := 4816442;
    v_dados(v_dados.last()).vr_vllanmto := 38.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4038142;
    v_dados(v_dados.last()).vr_nrctremp := 5108831;
    v_dados(v_dados.last()).vr_vllanmto := 53.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037550;
    v_dados(v_dados.last()).vr_nrctremp := 2158838;
    v_dados(v_dados.last()).vr_vllanmto := 191.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6365639;
    v_dados(v_dados.last()).vr_nrctremp := 4185048;
    v_dados(v_dados.last()).vr_vllanmto := 52.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6300570;
    v_dados(v_dados.last()).vr_nrctremp := 5336438;
    v_dados(v_dados.last()).vr_vllanmto := 19.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6635369;
    v_dados(v_dados.last()).vr_nrctremp := 4627413;
    v_dados(v_dados.last()).vr_vllanmto := 15.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6819346;
    v_dados(v_dados.last()).vr_nrctremp := 2955100;
    v_dados(v_dados.last()).vr_vllanmto := 309.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6669697;
    v_dados(v_dados.last()).vr_nrctremp := 5300474;
    v_dados(v_dados.last()).vr_vllanmto := 12.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6683045;
    v_dados(v_dados.last()).vr_nrctremp := 3919366;
    v_dados(v_dados.last()).vr_vllanmto := 131.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6928110;
    v_dados(v_dados.last()).vr_nrctremp := 3158672;
    v_dados(v_dados.last()).vr_vllanmto := 93.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6935915;
    v_dados(v_dados.last()).vr_nrctremp := 2991942;
    v_dados(v_dados.last()).vr_vllanmto := 513.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7178565;
    v_dados(v_dados.last()).vr_nrctremp := 4556663;
    v_dados(v_dados.last()).vr_vllanmto := 165.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7129599;
    v_dados(v_dados.last()).vr_nrctremp := 4444549;
    v_dados(v_dados.last()).vr_vllanmto := 30.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7204612;
    v_dados(v_dados.last()).vr_nrctremp := 4750120;
    v_dados(v_dados.last()).vr_vllanmto := 27.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7206895;
    v_dados(v_dados.last()).vr_nrctremp := 5170845;
    v_dados(v_dados.last()).vr_vllanmto := 21.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7310595;
    v_dados(v_dados.last()).vr_nrctremp := 5146936;
    v_dados(v_dados.last()).vr_vllanmto := 35.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533640;
    v_dados(v_dados.last()).vr_nrctremp := 3927171;
    v_dados(v_dados.last()).vr_vllanmto := 84.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7797320;
    v_dados(v_dados.last()).vr_nrctremp := 3869609;
    v_dados(v_dados.last()).vr_vllanmto := 58.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7668058;
    v_dados(v_dados.last()).vr_nrctremp := 4183670;
    v_dados(v_dados.last()).vr_vllanmto := 62.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7669437;
    v_dados(v_dados.last()).vr_nrctremp := 2507640;
    v_dados(v_dados.last()).vr_vllanmto := 31.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7709374;
    v_dados(v_dados.last()).vr_nrctremp := 2955656;
    v_dados(v_dados.last()).vr_vllanmto := 29.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7813317;
    v_dados(v_dados.last()).vr_nrctremp := 2955328;
    v_dados(v_dados.last()).vr_vllanmto := 68.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7928041;
    v_dados(v_dados.last()).vr_nrctremp := 4044684;
    v_dados(v_dados.last()).vr_vllanmto := 979.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8033498;
    v_dados(v_dados.last()).vr_nrctremp := 4606131;
    v_dados(v_dados.last()).vr_vllanmto := 10.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 53.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8273332;
    v_dados(v_dados.last()).vr_nrctremp := 4648247;
    v_dados(v_dados.last()).vr_vllanmto := 25.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8276412;
    v_dados(v_dados.last()).vr_nrctremp := 2956155;
    v_dados(v_dados.last()).vr_vllanmto := 55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8304440;
    v_dados(v_dados.last()).vr_nrctremp := 4879513;
    v_dados(v_dados.last()).vr_vllanmto := 39.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8713529;
    v_dados(v_dados.last()).vr_nrctremp := 2661058;
    v_dados(v_dados.last()).vr_vllanmto := 60.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8462461;
    v_dados(v_dados.last()).vr_nrctremp := 3041554;
    v_dados(v_dados.last()).vr_vllanmto := 40.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 60.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 14.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683352;
    v_dados(v_dados.last()).vr_nrctremp := 4624468;
    v_dados(v_dados.last()).vr_vllanmto := 56.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8719705;
    v_dados(v_dados.last()).vr_nrctremp := 4222466;
    v_dados(v_dados.last()).vr_vllanmto := 42.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8762473;
    v_dados(v_dados.last()).vr_nrctremp := 4500533;
    v_dados(v_dados.last()).vr_vllanmto := 10.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8791317;
    v_dados(v_dados.last()).vr_nrctremp := 2955664;
    v_dados(v_dados.last()).vr_vllanmto := 72.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8904375;
    v_dados(v_dados.last()).vr_nrctremp := 4874504;
    v_dados(v_dados.last()).vr_vllanmto := 39.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8837813;
    v_dados(v_dados.last()).vr_nrctremp := 2955566;
    v_dados(v_dados.last()).vr_vllanmto := 239.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861056;
    v_dados(v_dados.last()).vr_nrctremp := 4660846;
    v_dados(v_dados.last()).vr_vllanmto := 26.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8907315;
    v_dados(v_dados.last()).vr_nrctremp := 3627786;
    v_dados(v_dados.last()).vr_vllanmto := 48.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8928029;
    v_dados(v_dados.last()).vr_nrctremp := 4702686;
    v_dados(v_dados.last()).vr_vllanmto := 15.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 4505051;
    v_dados(v_dados.last()).vr_vllanmto := 49.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9068252;
    v_dados(v_dados.last()).vr_nrctremp := 5249586;
    v_dados(v_dados.last()).vr_vllanmto := 12.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190945;
    v_dados(v_dados.last()).vr_nrctremp := 1956430;
    v_dados(v_dados.last()).vr_vllanmto := 69.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9084720;
    v_dados(v_dados.last()).vr_nrctremp := 5566176;
    v_dados(v_dados.last()).vr_vllanmto := 11.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190449;
    v_dados(v_dados.last()).vr_nrctremp := 3932307;
    v_dados(v_dados.last()).vr_vllanmto := 101.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9192751;
    v_dados(v_dados.last()).vr_nrctremp := 3066854;
    v_dados(v_dados.last()).vr_vllanmto := 126.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 43.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193537;
    v_dados(v_dados.last()).vr_nrctremp := 2956223;
    v_dados(v_dados.last()).vr_vllanmto := 59.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9274456;
    v_dados(v_dados.last()).vr_nrctremp := 4881776;
    v_dados(v_dados.last()).vr_vllanmto := 29.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9380051;
    v_dados(v_dados.last()).vr_nrctremp := 4343440;
    v_dados(v_dados.last()).vr_vllanmto := 14.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2023895;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9638997;
    v_dados(v_dados.last()).vr_nrctremp := 4527665;
    v_dados(v_dados.last()).vr_vllanmto := 86.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569871;
    v_dados(v_dados.last()).vr_nrctremp := 4855726;
    v_dados(v_dados.last()).vr_vllanmto := 14.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9663274;
    v_dados(v_dados.last()).vr_nrctremp := 2955693;
    v_dados(v_dados.last()).vr_vllanmto := 88.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9676902;
    v_dados(v_dados.last()).vr_nrctremp := 4729697;
    v_dados(v_dados.last()).vr_vllanmto := 16.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 37.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 23.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 65.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9877916;
    v_dados(v_dados.last()).vr_nrctremp := 2835102;
    v_dados(v_dados.last()).vr_vllanmto := 67;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10010246;
    v_dados(v_dados.last()).vr_nrctremp := 5427207;
    v_dados(v_dados.last()).vr_vllanmto := 11.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := 26.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065903;
    v_dados(v_dados.last()).vr_nrctremp := 4529120;
    v_dados(v_dados.last()).vr_vllanmto := 12.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10066020;
    v_dados(v_dados.last()).vr_nrctremp := 5157236;
    v_dados(v_dados.last()).vr_vllanmto := 10.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10245537;
    v_dados(v_dados.last()).vr_nrctremp := 2952113;
    v_dados(v_dados.last()).vr_vllanmto := 24.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10148795;
    v_dados(v_dados.last()).vr_nrctremp := 4740173;
    v_dados(v_dados.last()).vr_vllanmto := 74.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10179569;
    v_dados(v_dados.last()).vr_nrctremp := 2967816;
    v_dados(v_dados.last()).vr_vllanmto := 168.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10253769;
    v_dados(v_dados.last()).vr_nrctremp := 5312374;
    v_dados(v_dados.last()).vr_vllanmto := 72.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10265651;
    v_dados(v_dados.last()).vr_nrctremp := 4717159;
    v_dados(v_dados.last()).vr_vllanmto := 36.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 54.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10308466;
    v_dados(v_dados.last()).vr_nrctremp := 2955488;
    v_dados(v_dados.last()).vr_vllanmto := 114.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10349898;
    v_dados(v_dados.last()).vr_nrctremp := 2118569;
    v_dados(v_dados.last()).vr_vllanmto := 196.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10317694;
    v_dados(v_dados.last()).vr_nrctremp := 4677944;
    v_dados(v_dados.last()).vr_vllanmto := 40.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10355898;
    v_dados(v_dados.last()).vr_nrctremp := 4746635;
    v_dados(v_dados.last()).vr_vllanmto := 11.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10400354;
    v_dados(v_dados.last()).vr_nrctremp := 5541382;
    v_dados(v_dados.last()).vr_vllanmto := 11.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10403655;
    v_dados(v_dados.last()).vr_nrctremp := 2955266;
    v_dados(v_dados.last()).vr_vllanmto := 88.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10412697;
    v_dados(v_dados.last()).vr_nrctremp := 4651714;
    v_dados(v_dados.last()).vr_vllanmto := 43.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 164.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10465537;
    v_dados(v_dados.last()).vr_nrctremp := 4476841;
    v_dados(v_dados.last()).vr_vllanmto := 19.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10492844;
    v_dados(v_dados.last()).vr_nrctremp := 2955447;
    v_dados(v_dados.last()).vr_vllanmto := 128.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10615474;
    v_dados(v_dados.last()).vr_nrctremp := 5136571;
    v_dados(v_dados.last()).vr_vllanmto := 12.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 90.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10609377;
    v_dados(v_dados.last()).vr_nrctremp := 2005092;
    v_dados(v_dados.last()).vr_vllanmto := 92.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10640622;
    v_dados(v_dados.last()).vr_nrctremp := 4784340;
    v_dados(v_dados.last()).vr_vllanmto := 31.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10645292;
    v_dados(v_dados.last()).vr_nrctremp := 4312871;
    v_dados(v_dados.last()).vr_vllanmto := 28.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3189310;
    v_dados(v_dados.last()).vr_vllanmto := 19.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10735224;
    v_dados(v_dados.last()).vr_nrctremp := 3701725;
    v_dados(v_dados.last()).vr_vllanmto := 54.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10752188;
    v_dados(v_dados.last()).vr_nrctremp := 4616770;
    v_dados(v_dados.last()).vr_vllanmto := 32.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5216299;
    v_dados(v_dados.last()).vr_vllanmto := 31.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5575486;
    v_dados(v_dados.last()).vr_vllanmto := 11.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10847103;
    v_dados(v_dados.last()).vr_nrctremp := 4190567;
    v_dados(v_dados.last()).vr_vllanmto := 86.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10866515;
    v_dados(v_dados.last()).vr_nrctremp := 4249800;
    v_dados(v_dados.last()).vr_vllanmto := 40.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10896384;
    v_dados(v_dados.last()).vr_nrctremp := 4357704;
    v_dados(v_dados.last()).vr_vllanmto := 36.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10919597;
    v_dados(v_dados.last()).vr_nrctremp := 4141182;
    v_dados(v_dados.last()).vr_vllanmto := 51.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10950842;
    v_dados(v_dados.last()).vr_nrctremp := 5554395;
    v_dados(v_dados.last()).vr_vllanmto := 12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11009993;
    v_dados(v_dados.last()).vr_nrctremp := 4901511;
    v_dados(v_dados.last()).vr_vllanmto := 19.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 2732832;
    v_dados(v_dados.last()).vr_vllanmto := 51.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 137.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 136.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11401990;
    v_dados(v_dados.last()).vr_nrctremp := 5159727;
    v_dados(v_dados.last()).vr_vllanmto := 13.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11357096;
    v_dados(v_dados.last()).vr_nrctremp := 5247177;
    v_dados(v_dados.last()).vr_vllanmto := 15.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11505184;
    v_dados(v_dados.last()).vr_nrctremp := 4486388;
    v_dados(v_dados.last()).vr_vllanmto := 254.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 106.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11615770;
    v_dados(v_dados.last()).vr_nrctremp := 4589257;
    v_dados(v_dados.last()).vr_vllanmto := 98.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11776340;
    v_dados(v_dados.last()).vr_nrctremp := 3032948;
    v_dados(v_dados.last()).vr_vllanmto := 13.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 3170921;
    v_dados(v_dados.last()).vr_vllanmto := 68.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11779608;
    v_dados(v_dados.last()).vr_nrctremp := 2979926;
    v_dados(v_dados.last()).vr_vllanmto := 66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11785837;
    v_dados(v_dados.last()).vr_nrctremp := 4974493;
    v_dados(v_dados.last()).vr_vllanmto := 10.02;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11786345;
    v_dados(v_dados.last()).vr_nrctremp := 4680798;
    v_dados(v_dados.last()).vr_vllanmto := 32.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11806222;
    v_dados(v_dados.last()).vr_nrctremp := 4245131;
    v_dados(v_dados.last()).vr_vllanmto := 52.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11820004;
    v_dados(v_dados.last()).vr_nrctremp := 4617074;
    v_dados(v_dados.last()).vr_vllanmto := 15.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11834021;
    v_dados(v_dados.last()).vr_nrctremp := 4407237;
    v_dados(v_dados.last()).vr_vllanmto := 37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11909757;
    v_dados(v_dados.last()).vr_nrctremp := 5534576;
    v_dados(v_dados.last()).vr_vllanmto := 17.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11921005;
    v_dados(v_dados.last()).vr_nrctremp := 4170514;
    v_dados(v_dados.last()).vr_vllanmto := 65.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11934425;
    v_dados(v_dados.last()).vr_nrctremp := 4573117;
    v_dados(v_dados.last()).vr_vllanmto := 24.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421230;
    v_dados(v_dados.last()).vr_vllanmto := 59.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3231886;
    v_dados(v_dados.last()).vr_vllanmto := 88.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12027413;
    v_dados(v_dados.last()).vr_nrctremp := 3988033;
    v_dados(v_dados.last()).vr_vllanmto := 12.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 25.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12392820;
    v_dados(v_dados.last()).vr_nrctremp := 3586887;
    v_dados(v_dados.last()).vr_vllanmto := 40.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12582565;
    v_dados(v_dados.last()).vr_nrctremp := 3986201;
    v_dados(v_dados.last()).vr_vllanmto := 70.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12239470;
    v_dados(v_dados.last()).vr_nrctremp := 3436180;
    v_dados(v_dados.last()).vr_vllanmto := 61.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 115.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212202;
    v_dados(v_dados.last()).vr_nrctremp := 3420248;
    v_dados(v_dados.last()).vr_vllanmto := 61.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 3706648;
    v_dados(v_dados.last()).vr_vllanmto := 55.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12278653;
    v_dados(v_dados.last()).vr_nrctremp := 4912772;
    v_dados(v_dados.last()).vr_vllanmto := 10.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12293407;
    v_dados(v_dados.last()).vr_nrctremp := 3938066;
    v_dados(v_dados.last()).vr_vllanmto := 60.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12305804;
    v_dados(v_dados.last()).vr_nrctremp := 3656154;
    v_dados(v_dados.last()).vr_vllanmto := 31.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12319090;
    v_dados(v_dados.last()).vr_nrctremp := 3515151;
    v_dados(v_dados.last()).vr_vllanmto := 29549.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12333263;
    v_dados(v_dados.last()).vr_nrctremp := 5350282;
    v_dados(v_dados.last()).vr_vllanmto := 21.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12349909;
    v_dados(v_dados.last()).vr_nrctremp := 3549289;
    v_dados(v_dados.last()).vr_vllanmto := 69.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12350990;
    v_dados(v_dados.last()).vr_nrctremp := 3996044;
    v_dados(v_dados.last()).vr_vllanmto := 76.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12361283;
    v_dados(v_dados.last()).vr_nrctremp := 4016461;
    v_dados(v_dados.last()).vr_vllanmto := 23.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12383708;
    v_dados(v_dados.last()).vr_nrctremp := 3578578;
    v_dados(v_dados.last()).vr_vllanmto := 41.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413640;
    v_dados(v_dados.last()).vr_nrctremp := 3977580;
    v_dados(v_dados.last()).vr_vllanmto := 75.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413887;
    v_dados(v_dados.last()).vr_nrctremp := 4535597;
    v_dados(v_dados.last()).vr_vllanmto := 12.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425770;
    v_dados(v_dados.last()).vr_nrctremp := 3620293;
    v_dados(v_dados.last()).vr_vllanmto := 31.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12462888;
    v_dados(v_dados.last()).vr_nrctremp := 4022402;
    v_dados(v_dados.last()).vr_vllanmto := 36.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12465321;
    v_dados(v_dados.last()).vr_nrctremp := 3936331;
    v_dados(v_dados.last()).vr_vllanmto := 50.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475408;
    v_dados(v_dados.last()).vr_nrctremp := 3680350;
    v_dados(v_dados.last()).vr_vllanmto := 38.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 34.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12550884;
    v_dados(v_dados.last()).vr_nrctremp := 3756384;
    v_dados(v_dados.last()).vr_vllanmto := 14.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 3795640;
    v_dados(v_dados.last()).vr_vllanmto := 42.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595080;
    v_dados(v_dados.last()).vr_nrctremp := 3836849;
    v_dados(v_dados.last()).vr_vllanmto := 37.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595373;
    v_dados(v_dados.last()).vr_nrctremp := 4753507;
    v_dados(v_dados.last()).vr_vllanmto := 22.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12602787;
    v_dados(v_dados.last()).vr_nrctremp := 3889300;
    v_dados(v_dados.last()).vr_vllanmto := 133.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637106;
    v_dados(v_dados.last()).vr_nrctremp := 3868680;
    v_dados(v_dados.last()).vr_vllanmto := 28.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 4049377;
    v_dados(v_dados.last()).vr_vllanmto := 14.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 3897149;
    v_dados(v_dados.last()).vr_vllanmto := 55.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877832;
    v_dados(v_dados.last()).vr_vllanmto := 27.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12701521;
    v_dados(v_dados.last()).vr_nrctremp := 3997739;
    v_dados(v_dados.last()).vr_vllanmto := 46.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12720828;
    v_dados(v_dados.last()).vr_nrctremp := 3995814;
    v_dados(v_dados.last()).vr_vllanmto := 21.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12724009;
    v_dados(v_dados.last()).vr_nrctremp := 3932359;
    v_dados(v_dados.last()).vr_vllanmto := 10.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12953563;
    v_dados(v_dados.last()).vr_nrctremp := 4243776;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4038250;
    v_dados(v_dados.last()).vr_vllanmto := 87.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739090;
    v_dados(v_dados.last()).vr_nrctremp := 4102671;
    v_dados(v_dados.last()).vr_vllanmto := 78.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4107091;
    v_dados(v_dados.last()).vr_vllanmto := 83.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4226847;
    v_dados(v_dados.last()).vr_vllanmto := 17.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760102;
    v_dados(v_dados.last()).vr_nrctremp := 3965764;
    v_dados(v_dados.last()).vr_vllanmto := 34.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 39.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12809918;
    v_dados(v_dados.last()).vr_nrctremp := 5361272;
    v_dados(v_dados.last()).vr_vllanmto := 18.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097768;
    v_dados(v_dados.last()).vr_vllanmto := 15.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12823350;
    v_dados(v_dados.last()).vr_nrctremp := 4463112;
    v_dados(v_dados.last()).vr_vllanmto := 12.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898899;
    v_dados(v_dados.last()).vr_nrctremp := 4097203;
    v_dados(v_dados.last()).vr_vllanmto := 18.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12923419;
    v_dados(v_dados.last()).vr_nrctremp := 4741564;
    v_dados(v_dados.last()).vr_vllanmto := 11.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 32.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12998052;
    v_dados(v_dados.last()).vr_nrctremp := 4346665;
    v_dados(v_dados.last()).vr_vllanmto := 17.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13023020;
    v_dados(v_dados.last()).vr_nrctremp := 4301698;
    v_dados(v_dados.last()).vr_vllanmto := 14.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4252218;
    v_dados(v_dados.last()).vr_vllanmto := 12.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13244051;
    v_dados(v_dados.last()).vr_nrctremp := 4366155;
    v_dados(v_dados.last()).vr_vllanmto := 21.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 13.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13133039;
    v_dados(v_dados.last()).vr_nrctremp := 4273075;
    v_dados(v_dados.last()).vr_vllanmto := 25.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13137433;
    v_dados(v_dados.last()).vr_nrctremp := 4499682;
    v_dados(v_dados.last()).vr_vllanmto := 17.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13145088;
    v_dados(v_dados.last()).vr_nrctremp := 4430603;
    v_dados(v_dados.last()).vr_vllanmto := 17.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13177630;
    v_dados(v_dados.last()).vr_nrctremp := 4428083;
    v_dados(v_dados.last()).vr_vllanmto := 18.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13184270;
    v_dados(v_dados.last()).vr_nrctremp := 4313478;
    v_dados(v_dados.last()).vr_vllanmto := 131.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209248;
    v_dados(v_dados.last()).vr_nrctremp := 4499591;
    v_dados(v_dados.last()).vr_vllanmto := 25.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13246003;
    v_dados(v_dados.last()).vr_nrctremp := 4375937;
    v_dados(v_dados.last()).vr_vllanmto := 77.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13309323;
    v_dados(v_dados.last()).vr_nrctremp := 5535370;
    v_dados(v_dados.last()).vr_vllanmto := 11824.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13314084;
    v_dados(v_dados.last()).vr_nrctremp := 4413621;
    v_dados(v_dados.last()).vr_vllanmto := 17.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13316419;
    v_dados(v_dados.last()).vr_nrctremp := 4575351;
    v_dados(v_dados.last()).vr_vllanmto := 17.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13389408;
    v_dados(v_dados.last()).vr_nrctremp := 4639193;
    v_dados(v_dados.last()).vr_vllanmto := 20.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13440241;
    v_dados(v_dados.last()).vr_nrctremp := 4672702;
    v_dados(v_dados.last()).vr_vllanmto := 14.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13768689;
    v_dados(v_dados.last()).vr_nrctremp := 4969255;
    v_dados(v_dados.last()).vr_vllanmto := 16.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13923595;
    v_dados(v_dados.last()).vr_nrctremp := 5022137;
    v_dados(v_dados.last()).vr_vllanmto := 37.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13925920;
    v_dados(v_dados.last()).vr_nrctremp := 5125957;
    v_dados(v_dados.last()).vr_vllanmto := 20.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4829674;
    v_dados(v_dados.last()).vr_vllanmto := 75.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093159;
    v_dados(v_dados.last()).vr_nrctremp := 1886421;
    v_dados(v_dados.last()).vr_vllanmto := 204.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80099920;
    v_dados(v_dados.last()).vr_nrctremp := 5085776;
    v_dados(v_dados.last()).vr_vllanmto := 12.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80140939;
    v_dados(v_dados.last()).vr_nrctremp := 5042593;
    v_dados(v_dados.last()).vr_vllanmto := 13.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80173870;
    v_dados(v_dados.last()).vr_nrctremp := 2955468;
    v_dados(v_dados.last()).vr_vllanmto := 55.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80214479;
    v_dados(v_dados.last()).vr_nrctremp := 4921364;
    v_dados(v_dados.last()).vr_vllanmto := 89.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80277829;
    v_dados(v_dados.last()).vr_nrctremp := 3087767;
    v_dados(v_dados.last()).vr_vllanmto := 82.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80333796;
    v_dados(v_dados.last()).vr_nrctremp := 4330729;
    v_dados(v_dados.last()).vr_vllanmto := 144.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80430716;
    v_dados(v_dados.last()).vr_nrctremp := 5338450;
    v_dados(v_dados.last()).vr_vllanmto := 2348.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476988;
    v_dados(v_dados.last()).vr_nrctremp := 2955465;
    v_dados(v_dados.last()).vr_vllanmto := 166.18;
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
