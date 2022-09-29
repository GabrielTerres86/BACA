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
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 65234;
    v_dados(v_dados.last()).vr_nrctremp := 47787;
    v_dados(v_dados.last()).vr_vllanmto := 225.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 4138;
    v_dados(v_dados.last()).vr_nrctremp := 48281;
    v_dados(v_dados.last()).vr_vllanmto := 5652.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 3980;
    v_dados(v_dados.last()).vr_nrctremp := 48808;
    v_dados(v_dados.last()).vr_vllanmto := 163.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 26360;
    v_dados(v_dados.last()).vr_nrctremp := 53020;
    v_dados(v_dados.last()).vr_vllanmto := 4648.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 387630;
    v_dados(v_dados.last()).vr_nrctremp := 60080;
    v_dados(v_dados.last()).vr_vllanmto := 11.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 294284;
    v_dados(v_dados.last()).vr_nrctremp := 60161;
    v_dados(v_dados.last()).vr_vllanmto := 64.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 404322;
    v_dados(v_dados.last()).vr_nrctremp := 68438;
    v_dados(v_dados.last()).vr_vllanmto := 13.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 401099;
    v_dados(v_dados.last()).vr_nrctremp := 71273;
    v_dados(v_dados.last()).vr_vllanmto := 177.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14122413;
    v_dados(v_dados.last()).vr_nrctremp := 71285;
    v_dados(v_dados.last()).vr_vllanmto := 1650;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14096960;
    v_dados(v_dados.last()).vr_nrctremp := 71290;
    v_dados(v_dados.last()).vr_vllanmto := 23.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14096960;
    v_dados(v_dados.last()).vr_nrctremp := 71325;
    v_dados(v_dados.last()).vr_vllanmto := 3.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14129469;
    v_dados(v_dados.last()).vr_nrctremp := 71369;
    v_dados(v_dados.last()).vr_vllanmto := 1.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14125463;
    v_dados(v_dados.last()).vr_nrctremp := 71769;
    v_dados(v_dados.last()).vr_vllanmto := 3.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14173905;
    v_dados(v_dados.last()).vr_nrctremp := 71977;
    v_dados(v_dados.last()).vr_vllanmto := .19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14147114;
    v_dados(v_dados.last()).vr_nrctremp := 72132;
    v_dados(v_dados.last()).vr_vllanmto := 16746.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14187370;
    v_dados(v_dados.last()).vr_nrctremp := 72166;
    v_dados(v_dados.last()).vr_vllanmto := 11.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14162342;
    v_dados(v_dados.last()).vr_nrctremp := 72250;
    v_dados(v_dados.last()).vr_vllanmto := 2.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14142864;
    v_dados(v_dados.last()).vr_nrctremp := 72252;
    v_dados(v_dados.last()).vr_vllanmto := .26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14142864;
    v_dados(v_dados.last()).vr_nrctremp := 72256;
    v_dados(v_dados.last()).vr_vllanmto := 1.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14128837;
    v_dados(v_dados.last()).vr_nrctremp := 72264;
    v_dados(v_dados.last()).vr_vllanmto := 17.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 72380;
    v_dados(v_dados.last()).vr_vllanmto := 115.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14206668;
    v_dados(v_dados.last()).vr_nrctremp := 72479;
    v_dados(v_dados.last()).vr_vllanmto := 1740.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14204118;
    v_dados(v_dados.last()).vr_nrctremp := 72923;
    v_dados(v_dados.last()).vr_vllanmto := 1.85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14163098;
    v_dados(v_dados.last()).vr_nrctremp := 73243;
    v_dados(v_dados.last()).vr_vllanmto := 6.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14202778;
    v_dados(v_dados.last()).vr_nrctremp := 73399;
    v_dados(v_dados.last()).vr_vllanmto := 10.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14302861;
    v_dados(v_dados.last()).vr_nrctremp := 73405;
    v_dados(v_dados.last()).vr_vllanmto := 6.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14096960;
    v_dados(v_dados.last()).vr_nrctremp := 73531;
    v_dados(v_dados.last()).vr_vllanmto := 83.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14316650;
    v_dados(v_dados.last()).vr_nrctremp := 73594;
    v_dados(v_dados.last()).vr_vllanmto := 431.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14283581;
    v_dados(v_dados.last()).vr_nrctremp := 73679;
    v_dados(v_dados.last()).vr_vllanmto := 9.79;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14333929;
    v_dados(v_dados.last()).vr_nrctremp := 73920;
    v_dados(v_dados.last()).vr_vllanmto := 6.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14227517;
    v_dados(v_dados.last()).vr_nrctremp := 73967;
    v_dados(v_dados.last()).vr_vllanmto := 4.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14254085;
    v_dados(v_dados.last()).vr_nrctremp := 74207;
    v_dados(v_dados.last()).vr_vllanmto := .97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14287048;
    v_dados(v_dados.last()).vr_nrctremp := 74325;
    v_dados(v_dados.last()).vr_vllanmto := 5.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14377055;
    v_dados(v_dados.last()).vr_nrctremp := 74414;
    v_dados(v_dados.last()).vr_vllanmto := 2787.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14376920;
    v_dados(v_dados.last()).vr_nrctremp := 74431;
    v_dados(v_dados.last()).vr_vllanmto := 10.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14300133;
    v_dados(v_dados.last()).vr_nrctremp := 74775;
    v_dados(v_dados.last()).vr_vllanmto := 2.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14377233;
    v_dados(v_dados.last()).vr_nrctremp := 74779;
    v_dados(v_dados.last()).vr_vllanmto := 8.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14418940;
    v_dados(v_dados.last()).vr_nrctremp := 75101;
    v_dados(v_dados.last()).vr_vllanmto := 17.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14419041;
    v_dados(v_dados.last()).vr_nrctremp := 75119;
    v_dados(v_dados.last()).vr_vllanmto := 17.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14377055;
    v_dados(v_dados.last()).vr_nrctremp := 75320;
    v_dados(v_dados.last()).vr_vllanmto := 12449.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 90115;
    v_dados(v_dados.last()).vr_nrctremp := 76006;
    v_dados(v_dados.last()).vr_vllanmto := 29.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14510030;
    v_dados(v_dados.last()).vr_nrctremp := 76281;
    v_dados(v_dados.last()).vr_vllanmto := 1.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14207699;
    v_dados(v_dados.last()).vr_nrctremp := 76417;
    v_dados(v_dados.last()).vr_vllanmto := 1.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14545454;
    v_dados(v_dados.last()).vr_nrctremp := 76693;
    v_dados(v_dados.last()).vr_vllanmto := 10.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14555859;
    v_dados(v_dados.last()).vr_nrctremp := 76944;
    v_dados(v_dados.last()).vr_vllanmto := 33.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14568624;
    v_dados(v_dados.last()).vr_nrctremp := 77093;
    v_dados(v_dados.last()).vr_vllanmto := 4.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14122413;
    v_dados(v_dados.last()).vr_nrctremp := 77157;
    v_dados(v_dados.last()).vr_vllanmto := 2366.57;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14193612;
    v_dados(v_dados.last()).vr_nrctremp := 77993;
    v_dados(v_dados.last()).vr_vllanmto := 4.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14760045;
    v_dados(v_dados.last()).vr_nrctremp := 79867;
    v_dados(v_dados.last()).vr_vllanmto := 3.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 441481;
    v_dados(v_dados.last()).vr_nrctremp := 79983;
    v_dados(v_dados.last()).vr_vllanmto := 14.22;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14797658;
    v_dados(v_dados.last()).vr_nrctremp := 80671;
    v_dados(v_dados.last()).vr_vllanmto := 15.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14192020;
    v_dados(v_dados.last()).vr_nrctremp := 80677;
    v_dados(v_dados.last()).vr_vllanmto := 31.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 14786885;
    v_dados(v_dados.last()).vr_nrctremp := 81413;
    v_dados(v_dados.last()).vr_vllanmto := 60.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 441937;
    v_dados(v_dados.last()).vr_nrctremp := 81748;
    v_dados(v_dados.last()).vr_vllanmto := 3.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 446025;
    v_dados(v_dados.last()).vr_nrctremp := 83056;
    v_dados(v_dados.last()).vr_vllanmto := 14.86;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 15024652;
    v_dados(v_dados.last()).vr_nrctremp := 84100;
    v_dados(v_dados.last()).vr_vllanmto := 14.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 15045536;
    v_dados(v_dados.last()).vr_nrctremp := 84301;
    v_dados(v_dados.last()).vr_vllanmto := 7.93;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 15107892;
    v_dados(v_dados.last()).vr_nrctremp := 85413;
    v_dados(v_dados.last()).vr_vllanmto := 2.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;



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
