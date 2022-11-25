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
    v_dados(v_dados.last()).vr_nrdconta := 6683045;
    v_dados(v_dados.last()).vr_nrctremp := 3919366;
    v_dados(v_dados.last()).vr_vllanmto := 534.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7282311;
    v_dados(v_dados.last()).vr_nrctremp := 2855130;
    v_dados(v_dados.last()).vr_vllanmto := 2.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7886560;
    v_dados(v_dados.last()).vr_nrctremp := 2955666;
    v_dados(v_dados.last()).vr_vllanmto := .25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8923574;
    v_dados(v_dados.last()).vr_nrctremp := 4534970;
    v_dados(v_dados.last()).vr_vllanmto := 6.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9029052;
    v_dados(v_dados.last()).vr_nrctremp := 5467538;
    v_dados(v_dados.last()).vr_vllanmto := 3932.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 5533545;
    v_dados(v_dados.last()).vr_vllanmto := 5621.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 5533545;
    v_dados(v_dados.last()).vr_vllanmto := 5621.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9067485;
    v_dados(v_dados.last()).vr_nrctremp := 4505051;
    v_dados(v_dados.last()).vr_vllanmto := 3796.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10848029;
    v_dados(v_dados.last()).vr_nrctremp := 4290074;
    v_dados(v_dados.last()).vr_vllanmto := 4.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11116617;
    v_dados(v_dados.last()).vr_nrctremp := 5413304;
    v_dados(v_dados.last()).vr_vllanmto := 157.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203528;
    v_dados(v_dados.last()).vr_nrctremp := 2732832;
    v_dados(v_dados.last()).vr_vllanmto := 71.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11449098;
    v_dados(v_dados.last()).vr_nrctremp := 4540377;
    v_dados(v_dados.last()).vr_vllanmto := 8.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11862300;
    v_dados(v_dados.last()).vr_nrctremp := 4539802;
    v_dados(v_dados.last()).vr_vllanmto := 2373.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124684;
    v_dados(v_dados.last()).vr_nrctremp := 4695113;
    v_dados(v_dados.last()).vr_vllanmto := 7.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80068685;
    v_dados(v_dados.last()).vr_nrctremp := 2955843;
    v_dados(v_dados.last()).vr_vllanmto := 18.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2079836;
    v_dados(v_dados.last()).vr_nrctremp := 2955119;
    v_dados(v_dados.last()).vr_vllanmto := 113.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 4165540;
    v_dados(v_dados.last()).vr_vllanmto := 4467.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 3990203;
    v_dados(v_dados.last()).vr_vllanmto := 2772.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2297060;
    v_dados(v_dados.last()).vr_nrctremp := 3889867;
    v_dados(v_dados.last()).vr_vllanmto := 172.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2604116;
    v_dados(v_dados.last()).vr_nrctremp := 1956725;
    v_dados(v_dados.last()).vr_vllanmto := 234.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3183076;
    v_dados(v_dados.last()).vr_nrctremp := 5221443;
    v_dados(v_dados.last()).vr_vllanmto := 7618.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3672077;
    v_dados(v_dados.last()).vr_nrctremp := 2955116;
    v_dados(v_dados.last()).vr_vllanmto := 65.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3791670;
    v_dados(v_dados.last()).vr_nrctremp := 2955168;
    v_dados(v_dados.last()).vr_vllanmto := 291.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6155057;
    v_dados(v_dados.last()).vr_nrctremp := 4520425;
    v_dados(v_dados.last()).vr_vllanmto := 2874.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6819346;
    v_dados(v_dados.last()).vr_nrctremp := 2955100;
    v_dados(v_dados.last()).vr_vllanmto := 375.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7206895;
    v_dados(v_dados.last()).vr_nrctremp := 4568549;
    v_dados(v_dados.last()).vr_vllanmto := 102.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7652704;
    v_dados(v_dados.last()).vr_nrctremp := 2955374;
    v_dados(v_dados.last()).vr_vllanmto := 224.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7928041;
    v_dados(v_dados.last()).vr_nrctremp := 4044684;
    v_dados(v_dados.last()).vr_vllanmto := 979.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8033498;
    v_dados(v_dados.last()).vr_nrctremp := 4606131;
    v_dados(v_dados.last()).vr_vllanmto := 525.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8120374;
    v_dados(v_dados.last()).vr_nrctremp := 2956126;
    v_dados(v_dados.last()).vr_vllanmto := 31.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8294615;
    v_dados(v_dados.last()).vr_nrctremp := 2955246;
    v_dados(v_dados.last()).vr_vllanmto := 40.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8739005;
    v_dados(v_dados.last()).vr_nrctremp := 2955812;
    v_dados(v_dados.last()).vr_vllanmto := 164.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8762473;
    v_dados(v_dados.last()).vr_nrctremp := 4500533;
    v_dados(v_dados.last()).vr_vllanmto := 14.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8791317;
    v_dados(v_dados.last()).vr_nrctremp := 2955664;
    v_dados(v_dados.last()).vr_vllanmto := 139.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8810079;
    v_dados(v_dados.last()).vr_nrctremp := 2955393;
    v_dados(v_dados.last()).vr_vllanmto := 179.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8811679;
    v_dados(v_dados.last()).vr_nrctremp := 2955449;
    v_dados(v_dados.last()).vr_vllanmto := 89.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194711;
    v_dados(v_dados.last()).vr_nrctremp := 3255466;
    v_dados(v_dados.last()).vr_vllanmto := 186.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9233962;
    v_dados(v_dados.last()).vr_nrctremp := 2958985;
    v_dados(v_dados.last()).vr_vllanmto := 135.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569871;
    v_dados(v_dados.last()).vr_nrctremp := 4855726;
    v_dados(v_dados.last()).vr_vllanmto := 5.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9663274;
    v_dados(v_dados.last()).vr_nrctremp := 2955693;
    v_dados(v_dados.last()).vr_vllanmto := 88.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9710604;
    v_dados(v_dados.last()).vr_nrctremp := 4164602;
    v_dados(v_dados.last()).vr_vllanmto := 237.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9762574;
    v_dados(v_dados.last()).vr_nrctremp := 2955848;
    v_dados(v_dados.last()).vr_vllanmto := 26.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9808299;
    v_dados(v_dados.last()).vr_nrctremp := 2956029;
    v_dados(v_dados.last()).vr_vllanmto := 236.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9819436;
    v_dados(v_dados.last()).vr_nrctremp := 5308137;
    v_dados(v_dados.last()).vr_vllanmto := 5677.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875638;
    v_dados(v_dados.last()).vr_nrctremp := 4626907;
    v_dados(v_dados.last()).vr_vllanmto := 466.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9877916;
    v_dados(v_dados.last()).vr_nrctremp := 2835102;
    v_dados(v_dados.last()).vr_vllanmto := 164.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10099468;
    v_dados(v_dados.last()).vr_nrctremp := 4728864;
    v_dados(v_dados.last()).vr_vllanmto := 167.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10148795;
    v_dados(v_dados.last()).vr_nrctremp := 4740173;
    v_dados(v_dados.last()).vr_vllanmto := 81.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10234225;
    v_dados(v_dados.last()).vr_nrctremp := 2123037;
    v_dados(v_dados.last()).vr_vllanmto := 182.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10492844;
    v_dados(v_dados.last()).vr_nrctremp := 2955447;
    v_dados(v_dados.last()).vr_vllanmto := 190.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10493425;
    v_dados(v_dados.last()).vr_nrctremp := 1987643;
    v_dados(v_dados.last()).vr_vllanmto := 813.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10883398;
    v_dados(v_dados.last()).vr_nrctremp := 5965555;
    v_dados(v_dados.last()).vr_vllanmto := 469.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11191945;
    v_dados(v_dados.last()).vr_nrctremp := 4887457;
    v_dados(v_dados.last()).vr_vllanmto := 2640;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11505184;
    v_dados(v_dados.last()).vr_nrctremp := 4486388;
    v_dados(v_dados.last()).vr_vllanmto := 601.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11618191;
    v_dados(v_dados.last()).vr_nrctremp := 5198619;
    v_dados(v_dados.last()).vr_vllanmto := 267.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 4072763;
    v_dados(v_dados.last()).vr_vllanmto := 1434.35;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12403148;
    v_dados(v_dados.last()).vr_nrctremp := 4605745;
    v_dados(v_dados.last()).vr_vllanmto := 647.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12508551;
    v_dados(v_dados.last()).vr_nrctremp := 4527754;
    v_dados(v_dados.last()).vr_vllanmto := 826.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12602787;
    v_dados(v_dados.last()).vr_nrctremp := 3889300;
    v_dados(v_dados.last()).vr_vllanmto := 133.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12694541;
    v_dados(v_dados.last()).vr_nrctremp := 4533400;
    v_dados(v_dados.last()).vr_vllanmto := 2519.95;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4107091;
    v_dados(v_dados.last()).vr_vllanmto := 167.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12954101;
    v_dados(v_dados.last()).vr_nrctremp := 4169225;
    v_dados(v_dados.last()).vr_vllanmto := 35.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12962066;
    v_dados(v_dados.last()).vr_nrctremp := 5086577;
    v_dados(v_dados.last()).vr_vllanmto := 21.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13189425;
    v_dados(v_dados.last()).vr_nrctremp := 4506686;
    v_dados(v_dados.last()).vr_vllanmto := 25.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142350;
    v_dados(v_dados.last()).vr_nrctremp := 5237759;
    v_dados(v_dados.last()).vr_vllanmto := 9873.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80091288;
    v_dados(v_dados.last()).vr_nrctremp := 2145249;
    v_dados(v_dados.last()).vr_vllanmto := 1325.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093663;
    v_dados(v_dados.last()).vr_nrctremp := 2956255;
    v_dados(v_dados.last()).vr_vllanmto := 1153.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098258;
    v_dados(v_dados.last()).vr_nrctremp := 1892259;
    v_dados(v_dados.last()).vr_vllanmto := 245.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80148530;
    v_dados(v_dados.last()).vr_nrctremp := 2705824;
    v_dados(v_dados.last()).vr_vllanmto := 25.35;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80333796;
    v_dados(v_dados.last()).vr_nrctremp := 4330729;
    v_dados(v_dados.last()).vr_vllanmto := 144.98;
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
