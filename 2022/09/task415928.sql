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
    v_dados(v_dados.last()).vr_nrdconta := 14958;
    v_dados(v_dados.last()).vr_nrctremp := 118515;
    v_dados(v_dados.last()).vr_vllanmto := 435.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133795;
    v_dados(v_dados.last()).vr_vllanmto := 1650.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 168225;
    v_dados(v_dados.last()).vr_vllanmto := 2786.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15458;
    v_dados(v_dados.last()).vr_nrctremp := 133792;
    v_dados(v_dados.last()).vr_vllanmto := 15302.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394734;
    v_dados(v_dados.last()).vr_nrctremp := 72344;
    v_dados(v_dados.last()).vr_vllanmto := 7568.11;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18180;
    v_dados(v_dados.last()).vr_nrctremp := 140475;
    v_dados(v_dados.last()).vr_vllanmto := 26.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25518;
    v_dados(v_dados.last()).vr_nrctremp := 111541;
    v_dados(v_dados.last()).vr_vllanmto := 26.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 41599;
    v_dados(v_dados.last()).vr_nrctremp := 178620;
    v_dados(v_dados.last()).vr_vllanmto := 3177.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 77895;
    v_dados(v_dados.last()).vr_nrctremp := 75192;
    v_dados(v_dados.last()).vr_vllanmto := 106.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93378;
    v_dados(v_dados.last()).vr_nrctremp := 84031;
    v_dados(v_dados.last()).vr_vllanmto := 1927.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93564;
    v_dados(v_dados.last()).vr_nrctremp := 91623;
    v_dados(v_dados.last()).vr_vllanmto := 136.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 237108;
    v_dados(v_dados.last()).vr_nrctremp := 86776;
    v_dados(v_dados.last()).vr_vllanmto := 3655.2;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 96245;
    v_dados(v_dados.last()).vr_nrctremp := 171345;
    v_dados(v_dados.last()).vr_vllanmto := 2143.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532673;
    v_dados(v_dados.last()).vr_nrctremp := 98962;
    v_dados(v_dados.last()).vr_vllanmto := 2123.31;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396990;
    v_dados(v_dados.last()).vr_nrctremp := 80320;
    v_dados(v_dados.last()).vr_vllanmto := 2089.37;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 132009;
    v_dados(v_dados.last()).vr_vllanmto := 1650.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 144134;
    v_dados(v_dados.last()).vr_vllanmto := 5928.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 143813;
    v_dados(v_dados.last()).vr_vllanmto := 4775.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 110402;
    v_dados(v_dados.last()).vr_vllanmto := 1022.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 20923;
    v_dados(v_dados.last()).vr_nrctremp := 82841;
    v_dados(v_dados.last()).vr_vllanmto := 1607.14;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78786;
    v_dados(v_dados.last()).vr_nrctremp := 80159;
    v_dados(v_dados.last()).vr_vllanmto := 1549.89;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 361372;
    v_dados(v_dados.last()).vr_nrctremp := 84317;
    v_dados(v_dados.last()).vr_vllanmto := 1488.64;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143782;
    v_dados(v_dados.last()).vr_nrctremp := 111511;
    v_dados(v_dados.last()).vr_vllanmto := 16593.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78319;
    v_dados(v_dados.last()).vr_vllanmto := 630.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 104920;
    v_dados(v_dados.last()).vr_vllanmto := 915.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394033;
    v_dados(v_dados.last()).vr_nrctremp := 90907;
    v_dados(v_dados.last()).vr_vllanmto := 1204.42;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78322;
    v_dados(v_dados.last()).vr_vllanmto := 4642.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 104597;
    v_dados(v_dados.last()).vr_vllanmto := 5228.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150215;
    v_dados(v_dados.last()).vr_nrctremp := 52249;
    v_dados(v_dados.last()).vr_vllanmto := 16.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152455;
    v_dados(v_dados.last()).vr_nrctremp := 120690;
    v_dados(v_dados.last()).vr_vllanmto := 756.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 95795;
    v_dados(v_dados.last()).vr_vllanmto := 595.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273465;
    v_dados(v_dados.last()).vr_nrctremp := 52180;
    v_dados(v_dados.last()).vr_vllanmto := 537.86;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163716;
    v_dados(v_dados.last()).vr_nrctremp := 81143;
    v_dados(v_dados.last()).vr_vllanmto := 435.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 106540;
    v_dados(v_dados.last()).vr_vllanmto := 20.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 180556;
    v_dados(v_dados.last()).vr_nrctremp := 54036;
    v_dados(v_dados.last()).vr_vllanmto := 7130.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 56753;
    v_dados(v_dados.last()).vr_vllanmto := 966.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 70190;
    v_dados(v_dados.last()).vr_vllanmto := 920.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 91363;
    v_dados(v_dados.last()).vr_vllanmto := 408.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350745;
    v_dados(v_dados.last()).vr_nrctremp := 157549;
    v_dados(v_dados.last()).vr_vllanmto := 235.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192350;
    v_dados(v_dados.last()).vr_nrctremp := 112063;
    v_dados(v_dados.last()).vr_vllanmto := 6778.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214710;
    v_dados(v_dados.last()).vr_nrctremp := 53208;
    v_dados(v_dados.last()).vr_vllanmto := 28.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 503584;
    v_dados(v_dados.last()).vr_nrctremp := 102245;
    v_dados(v_dados.last()).vr_vllanmto := 193.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187402;
    v_dados(v_dados.last()).vr_nrctremp := 118241;
    v_dados(v_dados.last()).vr_vllanmto := 187.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288535;
    v_dados(v_dados.last()).vr_nrctremp := 98543;
    v_dados(v_dados.last()).vr_vllanmto := 166.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379093;
    v_dados(v_dados.last()).vr_nrctremp := 102367;
    v_dados(v_dados.last()).vr_vllanmto := 162.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 113595;
    v_dados(v_dados.last()).vr_vllanmto := 142.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 80312;
    v_dados(v_dados.last()).vr_vllanmto := 132.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 92189;
    v_dados(v_dados.last()).vr_vllanmto := 128.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 673552;
    v_dados(v_dados.last()).vr_nrctremp := 166691;
    v_dados(v_dados.last()).vr_vllanmto := 116.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 198994;
    v_dados(v_dados.last()).vr_nrctremp := 97404;
    v_dados(v_dados.last()).vr_vllanmto := 104.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 241172;
    v_dados(v_dados.last()).vr_nrctremp := 53833;
    v_dados(v_dados.last()).vr_vllanmto := 1414.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670324;
    v_dados(v_dados.last()).vr_nrctremp := 167935;
    v_dados(v_dados.last()).vr_vllanmto := 99.77;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 60470;
    v_dados(v_dados.last()).vr_vllanmto := 97.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 46531;
    v_dados(v_dados.last()).vr_nrctremp := 116188;
    v_dados(v_dados.last()).vr_vllanmto := 91.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 78969;
    v_dados(v_dados.last()).vr_vllanmto := 2392.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 367389;
    v_dados(v_dados.last()).vr_nrctremp := 59342;
    v_dados(v_dados.last()).vr_vllanmto := 75.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120219;
    v_dados(v_dados.last()).vr_nrctremp := 189095;
    v_dados(v_dados.last()).vr_vllanmto := 75.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284220;
    v_dados(v_dados.last()).vr_nrctremp := 102835;
    v_dados(v_dados.last()).vr_vllanmto := 72.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150304;
    v_dados(v_dados.last()).vr_nrctremp := 59164;
    v_dados(v_dados.last()).vr_vllanmto := 65.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 164635;
    v_dados(v_dados.last()).vr_vllanmto := 65.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 136699;
    v_dados(v_dados.last()).vr_vllanmto := 59.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 78967;
    v_dados(v_dados.last()).vr_vllanmto := 2059.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 246190;
    v_dados(v_dados.last()).vr_nrctremp := 110103;
    v_dados(v_dados.last()).vr_vllanmto := 576.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178888;
    v_dados(v_dados.last()).vr_nrctremp := 66402;
    v_dados(v_dados.last()).vr_vllanmto := 52.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 73958;
    v_dados(v_dados.last()).vr_vllanmto := 51.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 142019;
    v_dados(v_dados.last()).vr_vllanmto := 42.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 108901;
    v_dados(v_dados.last()).vr_nrctremp := 122595;
    v_dados(v_dados.last()).vr_vllanmto := 42.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 85063;
    v_dados(v_dados.last()).vr_vllanmto := 38.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 193159;
    v_dados(v_dados.last()).vr_vllanmto := 38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249416;
    v_dados(v_dados.last()).vr_nrctremp := 206603;
    v_dados(v_dados.last()).vr_vllanmto := 36.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 321877;
    v_dados(v_dados.last()).vr_nrctremp := 116163;
    v_dados(v_dados.last()).vr_vllanmto := 35.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185876;
    v_dados(v_dados.last()).vr_nrctremp := 147388;
    v_dados(v_dados.last()).vr_vllanmto := 32.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247170;
    v_dados(v_dados.last()).vr_nrctremp := 136469;
    v_dados(v_dados.last()).vr_vllanmto := 1854.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 159595;
    v_dados(v_dados.last()).vr_vllanmto := 23.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 248789;
    v_dados(v_dados.last()).vr_nrctremp := 138349;
    v_dados(v_dados.last()).vr_vllanmto := 53.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 252760;
    v_dados(v_dados.last()).vr_nrctremp := 89649;
    v_dados(v_dados.last()).vr_vllanmto := 4672.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544809;
    v_dados(v_dados.last()).vr_nrctremp := 104688;
    v_dados(v_dados.last()).vr_vllanmto := 20.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92410;
    v_dados(v_dados.last()).vr_nrctremp := 170991;
    v_dados(v_dados.last()).vr_vllanmto := 18.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 261122;
    v_dados(v_dados.last()).vr_nrctremp := 146561;
    v_dados(v_dados.last()).vr_vllanmto := 3142.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 420441;
    v_dados(v_dados.last()).vr_nrctremp := 176584;
    v_dados(v_dados.last()).vr_vllanmto := 4.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136050;
    v_dados(v_dados.last()).vr_nrctremp := 168149;
    v_dados(v_dados.last()).vr_vllanmto := 3.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132847;
    v_dados(v_dados.last()).vr_vllanmto := 3.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 236632;
    v_dados(v_dados.last()).vr_nrctremp := 142523;
    v_dados(v_dados.last()).vr_vllanmto := .39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172618;
    v_dados(v_dados.last()).vr_nrctremp := 87115;
    v_dados(v_dados.last()).vr_vllanmto := .05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 167193;
    v_dados(v_dados.last()).vr_nrctremp := 139399;
    v_dados(v_dados.last()).vr_vllanmto := .18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 360333;
    v_dados(v_dados.last()).vr_nrctremp := 175913;
    v_dados(v_dados.last()).vr_vllanmto := .98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 60658;
    v_dados(v_dados.last()).vr_nrctremp := 148221;
    v_dados(v_dados.last()).vr_vllanmto := 1.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480568;
    v_dados(v_dados.last()).vr_nrctremp := 173188;
    v_dados(v_dados.last()).vr_vllanmto := 4.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 624276;
    v_dados(v_dados.last()).vr_nrctremp := 170255;
    v_dados(v_dados.last()).vr_vllanmto := 7.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 269247;
    v_dados(v_dados.last()).vr_nrctremp := 104701;
    v_dados(v_dados.last()).vr_vllanmto := 15.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146625;
    v_dados(v_dados.last()).vr_nrctremp := 96582;
    v_dados(v_dados.last()).vr_vllanmto := 19.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 113777;
    v_dados(v_dados.last()).vr_vllanmto := 20.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71105;
    v_dados(v_dados.last()).vr_vllanmto := 21.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 23.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 386545;
    v_dados(v_dados.last()).vr_nrctremp := 51508;
    v_dados(v_dados.last()).vr_vllanmto := 25.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90000;
    v_dados(v_dados.last()).vr_nrctremp := 129809;
    v_dados(v_dados.last()).vr_vllanmto := 25.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158259;
    v_dados(v_dados.last()).vr_nrctremp := 78313;
    v_dados(v_dados.last()).vr_vllanmto := 25.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263664;
    v_dados(v_dados.last()).vr_nrctremp := 84416;
    v_dados(v_dados.last()).vr_vllanmto := 4431.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 614424;
    v_dados(v_dados.last()).vr_nrctremp := 136928;
    v_dados(v_dados.last()).vr_vllanmto := 27.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279072;
    v_dados(v_dados.last()).vr_nrctremp := 111148;
    v_dados(v_dados.last()).vr_vllanmto := 1045.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 15539;
    v_dados(v_dados.last()).vr_nrctremp := 83098;
    v_dados(v_dados.last()).vr_vllanmto := 29.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 67072;
    v_dados(v_dados.last()).vr_vllanmto := 31.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 299090;
    v_dados(v_dados.last()).vr_nrctremp := 117044;
    v_dados(v_dados.last()).vr_vllanmto := 31.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103608;
    v_dados(v_dados.last()).vr_nrctremp := 150645;
    v_dados(v_dados.last()).vr_vllanmto := 33.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95400;
    v_dados(v_dados.last()).vr_nrctremp := 118820;
    v_dados(v_dados.last()).vr_vllanmto := 33.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 33.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 33.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188158;
    v_dados(v_dados.last()).vr_nrctremp := 79186;
    v_dados(v_dados.last()).vr_vllanmto := 35.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 368008;
    v_dados(v_dados.last()).vr_nrctremp := 202776;
    v_dados(v_dados.last()).vr_vllanmto := 35.52;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 498815;
    v_dados(v_dados.last()).vr_nrctremp := 84901;
    v_dados(v_dados.last()).vr_vllanmto := 35.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 169277;
    v_dados(v_dados.last()).vr_nrctremp := 82388;
    v_dados(v_dados.last()).vr_vllanmto := 36.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192929;
    v_dados(v_dados.last()).vr_nrctremp := 52884;
    v_dados(v_dados.last()).vr_vllanmto := 36.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266450;
    v_dados(v_dados.last()).vr_nrctremp := 87972;
    v_dados(v_dados.last()).vr_vllanmto := 37.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 87898;
    v_dados(v_dados.last()).vr_vllanmto := 37.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66940;
    v_dados(v_dados.last()).vr_nrctremp := 142854;
    v_dados(v_dados.last()).vr_vllanmto := 38.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 39.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 355771;
    v_dados(v_dados.last()).vr_nrctremp := 144078;
    v_dados(v_dados.last()).vr_vllanmto := 40.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149039;
    v_dados(v_dados.last()).vr_nrctremp := 88625;
    v_dados(v_dados.last()).vr_vllanmto := 41.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 42.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 282936;
    v_dados(v_dados.last()).vr_nrctremp := 109758;
    v_dados(v_dados.last()).vr_vllanmto := 53.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102229;
    v_dados(v_dados.last()).vr_nrctremp := 95094;
    v_dados(v_dados.last()).vr_vllanmto := 43.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521256;
    v_dados(v_dados.last()).vr_nrctremp := 92946;
    v_dados(v_dados.last()).vr_vllanmto := 44.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 450200;
    v_dados(v_dados.last()).vr_nrctremp := 65949;
    v_dados(v_dados.last()).vr_vllanmto := 47.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284874;
    v_dados(v_dados.last()).vr_nrctremp := 157311;
    v_dados(v_dados.last()).vr_vllanmto := 415.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 443972;
    v_dados(v_dados.last()).vr_nrctremp := 73022;
    v_dados(v_dados.last()).vr_vllanmto := 49.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 49.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561886;
    v_dados(v_dados.last()).vr_nrctremp := 113419;
    v_dados(v_dados.last()).vr_vllanmto := 50.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 350664;
    v_dados(v_dados.last()).vr_nrctremp := 125552;
    v_dados(v_dados.last()).vr_vllanmto := 51.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168491;
    v_dados(v_dados.last()).vr_nrctremp := 92472;
    v_dados(v_dados.last()).vr_vllanmto := 54.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 56.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 124982;
    v_dados(v_dados.last()).vr_nrctremp := 71546;
    v_dados(v_dados.last()).vr_vllanmto := 58.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214981;
    v_dados(v_dados.last()).vr_nrctremp := 71663;
    v_dados(v_dados.last()).vr_vllanmto := 59.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := 59.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186902;
    v_dados(v_dados.last()).vr_nrctremp := 92977;
    v_dados(v_dados.last()).vr_vllanmto := 60;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545805;
    v_dados(v_dados.last()).vr_nrctremp := 105319;
    v_dados(v_dados.last()).vr_vllanmto := 63.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 572314;
    v_dados(v_dados.last()).vr_nrctremp := 179477;
    v_dados(v_dados.last()).vr_vllanmto := 63.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 65.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95532;
    v_dados(v_dados.last()).vr_nrctremp := 68569;
    v_dados(v_dados.last()).vr_vllanmto := 66.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 132885;
    v_dados(v_dados.last()).vr_vllanmto := 1323.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 98825;
    v_dados(v_dados.last()).vr_vllanmto := 69.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92690;
    v_dados(v_dados.last()).vr_nrctremp := 58634;
    v_dados(v_dados.last()).vr_vllanmto := 69.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294691;
    v_dados(v_dados.last()).vr_nrctremp := 181157;
    v_dados(v_dados.last()).vr_vllanmto := 4890.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 126926;
    v_dados(v_dados.last()).vr_nrctremp := 57415;
    v_dados(v_dados.last()).vr_vllanmto := 73.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379301;
    v_dados(v_dados.last()).vr_nrctremp := 52196;
    v_dados(v_dados.last()).vr_vllanmto := 76.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526118;
    v_dados(v_dados.last()).vr_nrctremp := 96688;
    v_dados(v_dados.last()).vr_vllanmto := 80.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 75102;
    v_dados(v_dados.last()).vr_vllanmto := 84.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419869;
    v_dados(v_dados.last()).vr_nrctremp := 55947;
    v_dados(v_dados.last()).vr_vllanmto := 86.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421200;
    v_dados(v_dados.last()).vr_nrctremp := 56187;
    v_dados(v_dados.last()).vr_vllanmto := 88.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129410;
    v_dados(v_dados.last()).vr_nrctremp := 158870;
    v_dados(v_dados.last()).vr_vllanmto := 96.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303348;
    v_dados(v_dados.last()).vr_nrctremp := 75300;
    v_dados(v_dados.last()).vr_vllanmto := 1808.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 101.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 102.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 105.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := 106.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 106.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452211;
    v_dados(v_dados.last()).vr_nrctremp := 66716;
    v_dados(v_dados.last()).vr_vllanmto := 106.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 108.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426610;
    v_dados(v_dados.last()).vr_nrctremp := 80116;
    v_dados(v_dados.last()).vr_vllanmto := 109.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 285072;
    v_dados(v_dados.last()).vr_nrctremp := 83786;
    v_dados(v_dados.last()).vr_vllanmto := 116.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120618;
    v_dados(v_dados.last()).vr_nrctremp := 104378;
    v_dados(v_dados.last()).vr_vllanmto := 116.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 209066;
    v_dados(v_dados.last()).vr_nrctremp := 56508;
    v_dados(v_dados.last()).vr_vllanmto := 116.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78107;
    v_dados(v_dados.last()).vr_nrctremp := 87139;
    v_dados(v_dados.last()).vr_vllanmto := 128.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170453;
    v_dados(v_dados.last()).vr_nrctremp := 59887;
    v_dados(v_dados.last()).vr_vllanmto := 134.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 340561;
    v_dados(v_dados.last()).vr_nrctremp := 69746;
    v_dados(v_dados.last()).vr_vllanmto := 146.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185000;
    v_dados(v_dados.last()).vr_nrctremp := 115337;
    v_dados(v_dados.last()).vr_vllanmto := 157.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441376;
    v_dados(v_dados.last()).vr_nrctremp := 62504;
    v_dados(v_dados.last()).vr_vllanmto := 158.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 67514;
    v_dados(v_dados.last()).vr_vllanmto := 166.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 329169;
    v_dados(v_dados.last()).vr_nrctremp := 51807;
    v_dados(v_dados.last()).vr_vllanmto := 170.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544167;
    v_dados(v_dados.last()).vr_nrctremp := 104635;
    v_dados(v_dados.last()).vr_vllanmto := 188.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 194.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 215104;
    v_dados(v_dados.last()).vr_nrctremp := 112556;
    v_dados(v_dados.last()).vr_vllanmto := 196.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 52428;
    v_dados(v_dados.last()).vr_vllanmto := 479.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 84085;
    v_dados(v_dados.last()).vr_nrctremp := 51903;
    v_dados(v_dados.last()).vr_vllanmto := 210.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 214.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 87963;
    v_dados(v_dados.last()).vr_nrctremp := 64353;
    v_dados(v_dados.last()).vr_vllanmto := 219.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 53589;
    v_dados(v_dados.last()).vr_vllanmto := 227.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 249.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 467448;
    v_dados(v_dados.last()).vr_nrctremp := 73978;
    v_dados(v_dados.last()).vr_vllanmto := 260.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187194;
    v_dados(v_dados.last()).vr_nrctremp := 56891;
    v_dados(v_dados.last()).vr_vllanmto := 264.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541036;
    v_dados(v_dados.last()).vr_nrctremp := 103157;
    v_dados(v_dados.last()).vr_vllanmto := 282.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 328375;
    v_dados(v_dados.last()).vr_nrctremp := 58256;
    v_dados(v_dados.last()).vr_vllanmto := 697.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382302;
    v_dados(v_dados.last()).vr_nrctremp := 68878;
    v_dados(v_dados.last()).vr_vllanmto := 201.88;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 388181;
    v_dados(v_dados.last()).vr_nrctremp := 143312;
    v_dados(v_dados.last()).vr_vllanmto := 40.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93289;
    v_dados(v_dados.last()).vr_nrctremp := 51375;
    v_dados(v_dados.last()).vr_vllanmto := 445.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392740;
    v_dados(v_dados.last()).vr_nrctremp := 87679;
    v_dados(v_dados.last()).vr_vllanmto := 69.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395528;
    v_dados(v_dados.last()).vr_nrctremp := 53113;
    v_dados(v_dados.last()).vr_vllanmto := 928.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182702;
    v_dados(v_dados.last()).vr_nrctremp := 53514;
    v_dados(v_dados.last()).vr_vllanmto := 1086.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425230;
    v_dados(v_dados.last()).vr_nrctremp := 56888;
    v_dados(v_dados.last()).vr_vllanmto := 1154.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 464910;
    v_dados(v_dados.last()).vr_nrctremp := 164242;
    v_dados(v_dados.last()).vr_vllanmto := 2783.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480991;
    v_dados(v_dados.last()).vr_nrctremp := 78627;
    v_dados(v_dados.last()).vr_vllanmto := 213.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 485217;
    v_dados(v_dados.last()).vr_nrctremp := 198869;
    v_dados(v_dados.last()).vr_vllanmto := 3842.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541311;
    v_dados(v_dados.last()).vr_nrctremp := 179454;
    v_dados(v_dados.last()).vr_vllanmto := 356.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 549860;
    v_dados(v_dados.last()).vr_nrctremp := 107888;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 615366;
    v_dados(v_dados.last()).vr_nrctremp := 138297;
    v_dados(v_dados.last()).vr_vllanmto := 84.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 636673;
    v_dados(v_dados.last()).vr_nrctremp := 146471;
    v_dados(v_dados.last()).vr_vllanmto := 484.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 639168;
    v_dados(v_dados.last()).vr_nrctremp := 171074;
    v_dados(v_dados.last()).vr_vllanmto := 322.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670464;
    v_dados(v_dados.last()).vr_nrctremp := 182028;
    v_dados(v_dados.last()).vr_vllanmto := 644.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 709859;
    v_dados(v_dados.last()).vr_nrctremp := 71494;
    v_dados(v_dados.last()).vr_vllanmto := 59.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

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
