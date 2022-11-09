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
    v_dados(v_dados.last()).vr_nrdconta := 80214118;
    v_dados(v_dados.last()).vr_nrctremp := 2956035;
    v_dados(v_dados.last()).vr_vllanmto := 9190.42;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10777113;
    v_dados(v_dados.last()).vr_nrctremp := 2711935;
    v_dados(v_dados.last()).vr_vllanmto := 6703.4;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9563571;
    v_dados(v_dados.last()).vr_nrctremp := 2956027;
    v_dados(v_dados.last()).vr_vllanmto := 4586.23;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12665193;
    v_dados(v_dados.last()).vr_nrctremp := 4054130;
    v_dados(v_dados.last()).vr_vllanmto := 3289.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8652007;
    v_dados(v_dados.last()).vr_nrctremp := 2507442;
    v_dados(v_dados.last()).vr_vllanmto := 2878.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80336272;
    v_dados(v_dados.last()).vr_nrctremp := 3067399;
    v_dados(v_dados.last()).vr_vllanmto := 2424.96;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8655529;
    v_dados(v_dados.last()).vr_nrctremp := 5131105;
    v_dados(v_dados.last()).vr_vllanmto := 2242.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2953412;
    v_dados(v_dados.last()).vr_nrctremp := 5060611;
    v_dados(v_dados.last()).vr_vllanmto := 2086.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8837813;
    v_dados(v_dados.last()).vr_nrctremp := 2955566;
    v_dados(v_dados.last()).vr_vllanmto := 1194.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037550;
    v_dados(v_dados.last()).vr_nrctremp := 2158838;
    v_dados(v_dados.last()).vr_vllanmto := 1182.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11675837;
    v_dados(v_dados.last()).vr_nrctremp := 4866685;
    v_dados(v_dados.last()).vr_vllanmto := 866.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6935915;
    v_dados(v_dados.last()).vr_nrctremp := 2991942;
    v_dados(v_dados.last()).vr_vllanmto := 850.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10448799;
    v_dados(v_dados.last()).vr_nrctremp := 1922621;
    v_dados(v_dados.last()).vr_vllanmto := 735.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2099195;
    v_dados(v_dados.last()).vr_nrctremp := 2883655;
    v_dados(v_dados.last()).vr_vllanmto := 617.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710091;
    v_dados(v_dados.last()).vr_nrctremp := 3935842;
    v_dados(v_dados.last()).vr_vllanmto := 557.44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80340873;
    v_dados(v_dados.last()).vr_nrctremp := 2955797;
    v_dados(v_dados.last()).vr_vllanmto := 538.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3042979;
    v_dados(v_dados.last()).vr_nrctremp := 571640154;
    v_dados(v_dados.last()).vr_vllanmto := 514.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10349898;
    v_dados(v_dados.last()).vr_nrctremp := 2118569;
    v_dados(v_dados.last()).vr_vllanmto := 444.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14949482;
    v_dados(v_dados.last()).vr_nrctremp := 5691194;
    v_dados(v_dados.last()).vr_vllanmto := 440.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6525610;
    v_dados(v_dados.last()).vr_nrctremp := 2891921;
    v_dados(v_dados.last()).vr_vllanmto := 435.3;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11251891;
    v_dados(v_dados.last()).vr_nrctremp := 3919578;
    v_dados(v_dados.last()).vr_vllanmto := 425.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3077446;
    v_dados(v_dados.last()).vr_nrctremp := 3619639;
    v_dados(v_dados.last()).vr_vllanmto := 419.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10179569;
    v_dados(v_dados.last()).vr_nrctremp := 2967816;
    v_dados(v_dados.last()).vr_vllanmto := 418.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7613466;
    v_dados(v_dados.last()).vr_nrctremp := 1979043;
    v_dados(v_dados.last()).vr_vllanmto := 391.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11766522;
    v_dados(v_dados.last()).vr_nrctremp := 2988271;
    v_dados(v_dados.last()).vr_vllanmto := 370.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716200;
    v_dados(v_dados.last()).vr_nrctremp := 5256443;
    v_dados(v_dados.last()).vr_vllanmto := 357.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11586915;
    v_dados(v_dados.last()).vr_nrctremp := 2909668;
    v_dados(v_dados.last()).vr_vllanmto := 356.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6928110;
    v_dados(v_dados.last()).vr_nrctremp := 3158672;
    v_dados(v_dados.last()).vr_vllanmto := 354.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12964077;
    v_dados(v_dados.last()).vr_nrctremp := 5318470;
    v_dados(v_dados.last()).vr_vllanmto := 350.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9638997;
    v_dados(v_dados.last()).vr_nrctremp := 4527665;
    v_dados(v_dados.last()).vr_vllanmto := 336.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80093159;
    v_dados(v_dados.last()).vr_nrctremp := 1886421;
    v_dados(v_dados.last()).vr_vllanmto := 334.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4038142;
    v_dados(v_dados.last()).vr_nrctremp := 5108831;
    v_dados(v_dados.last()).vr_vllanmto := 334.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10654445;
    v_dados(v_dados.last()).vr_nrctremp := 3046625;
    v_dados(v_dados.last()).vr_vllanmto := 325.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14074320;
    v_dados(v_dados.last()).vr_nrctremp := 5086593;
    v_dados(v_dados.last()).vr_vllanmto := 319.4;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101062;
    v_dados(v_dados.last()).vr_nrctremp := 2955278;
    v_dados(v_dados.last()).vr_vllanmto := 318.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 2955350;
    v_dados(v_dados.last()).vr_vllanmto := 313.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9191674;
    v_dados(v_dados.last()).vr_nrctremp := 5119775;
    v_dados(v_dados.last()).vr_vllanmto := 294.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7310595;
    v_dados(v_dados.last()).vr_nrctremp := 5146936;
    v_dados(v_dados.last()).vr_vllanmto := 282.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80170781;
    v_dados(v_dados.last()).vr_nrctremp := 3472408;
    v_dados(v_dados.last()).vr_vllanmto := 268.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12115819;
    v_dados(v_dados.last()).vr_nrctremp := 5092728;
    v_dados(v_dados.last()).vr_vllanmto := 267.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873632;
    v_dados(v_dados.last()).vr_nrctremp := 4085979;
    v_dados(v_dados.last()).vr_vllanmto := 265.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12870307;
    v_dados(v_dados.last()).vr_nrctremp := 4155657;
    v_dados(v_dados.last()).vr_vllanmto := 261.3;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7533640;
    v_dados(v_dados.last()).vr_nrctremp := 3927171;
    v_dados(v_dados.last()).vr_vllanmto := 259.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10006001;
    v_dados(v_dados.last()).vr_nrctremp := 3077352;
    v_dados(v_dados.last()).vr_vllanmto := 244.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8840598;
    v_dados(v_dados.last()).vr_nrctremp := 2955363;
    v_dados(v_dados.last()).vr_vllanmto := 244.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7521537;
    v_dados(v_dados.last()).vr_nrctremp := 2955842;
    v_dados(v_dados.last()).vr_vllanmto := 243.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13068512;
    v_dados(v_dados.last()).vr_nrctremp := 4428289;
    v_dados(v_dados.last()).vr_vllanmto := 242.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12026786;
    v_dados(v_dados.last()).vr_nrctremp := 3231886;
    v_dados(v_dados.last()).vr_vllanmto := 237.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12509680;
    v_dados(v_dados.last()).vr_nrctremp := 4175452;
    v_dados(v_dados.last()).vr_vllanmto := 235.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9193120;
    v_dados(v_dados.last()).vr_nrctremp := 4390840;
    v_dados(v_dados.last()).vr_vllanmto := 231.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2752336;
    v_dados(v_dados.last()).vr_nrctremp := 3884678;
    v_dados(v_dados.last()).vr_vllanmto := 228.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9082530;
    v_dados(v_dados.last()).vr_nrctremp := 2955578;
    v_dados(v_dados.last()).vr_vllanmto := 223.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690392;
    v_dados(v_dados.last()).vr_nrctremp := 4139534;
    v_dados(v_dados.last()).vr_vllanmto := 223.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8034656;
    v_dados(v_dados.last()).vr_nrctremp := 5097439;
    v_dados(v_dados.last()).vr_vllanmto := 222.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12891185;
    v_dados(v_dados.last()).vr_nrctremp := 4090475;
    v_dados(v_dados.last()).vr_vllanmto := 216.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9415130;
    v_dados(v_dados.last()).vr_nrctremp := 2955637;
    v_dados(v_dados.last()).vr_vllanmto := 209.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190449;
    v_dados(v_dados.last()).vr_nrctremp := 3932307;
    v_dados(v_dados.last()).vr_vllanmto := 204.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80277829;
    v_dados(v_dados.last()).vr_nrctremp := 3087767;
    v_dados(v_dados.last()).vr_vllanmto := 202.4;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8465886;
    v_dados(v_dados.last()).vr_nrctremp := 3885563;
    v_dados(v_dados.last()).vr_vllanmto := 200.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9659293;
    v_dados(v_dados.last()).vr_nrctremp := 2955761;
    v_dados(v_dados.last()).vr_vllanmto := 200.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8513384;
    v_dados(v_dados.last()).vr_nrctremp := 1882819;
    v_dados(v_dados.last()).vr_vllanmto := 198.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7069774;
    v_dados(v_dados.last()).vr_nrctremp := 5137090;
    v_dados(v_dados.last()).vr_vllanmto := 197.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10278630;
    v_dados(v_dados.last()).vr_nrctremp := 4778376;
    v_dados(v_dados.last()).vr_vllanmto := 196.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9153055;
    v_dados(v_dados.last()).vr_nrctremp := 5132046;
    v_dados(v_dados.last()).vr_vllanmto := 195.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8276412;
    v_dados(v_dados.last()).vr_nrctremp := 2956155;
    v_dados(v_dados.last()).vr_vllanmto := 195.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690392;
    v_dados(v_dados.last()).vr_nrctremp := 3897211;
    v_dados(v_dados.last()).vr_vllanmto := 193.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712643;
    v_dados(v_dados.last()).vr_nrctremp := 3098270;
    v_dados(v_dados.last()).vr_vllanmto := 192.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576167;
    v_dados(v_dados.last()).vr_vllanmto := 190.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9734325;
    v_dados(v_dados.last()).vr_nrctremp := 4598794;
    v_dados(v_dados.last()).vr_vllanmto := 186.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14134489;
    v_dados(v_dados.last()).vr_nrctremp := 5076253;
    v_dados(v_dados.last()).vr_vllanmto := 186.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9569731;
    v_dados(v_dados.last()).vr_nrctremp := 4583142;
    v_dados(v_dados.last()).vr_vllanmto := 182.57;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13184270;
    v_dados(v_dados.last()).vr_nrctremp := 4313478;
    v_dados(v_dados.last()).vr_vllanmto := 181.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10615474;
    v_dados(v_dados.last()).vr_nrctremp := 5136571;
    v_dados(v_dados.last()).vr_vllanmto := 181.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078602;
    v_dados(v_dados.last()).vr_nrctremp := 3520144;
    v_dados(v_dados.last()).vr_vllanmto := 180.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9783792;
    v_dados(v_dados.last()).vr_nrctremp := 2955856;
    v_dados(v_dados.last()).vr_vllanmto := 174.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12690562;
    v_dados(v_dados.last()).vr_nrctremp := 3897149;
    v_dados(v_dados.last()).vr_vllanmto := 169.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 5076020;
    v_dados(v_dados.last()).vr_vllanmto := 166.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10851925;
    v_dados(v_dados.last()).vr_nrctremp := 5141026;
    v_dados(v_dados.last()).vr_vllanmto := 166.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12801658;
    v_dados(v_dados.last()).vr_nrctremp := 5077570;
    v_dados(v_dados.last()).vr_vllanmto := 164.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3761240;
    v_dados(v_dados.last()).vr_nrctremp := 4898751;
    v_dados(v_dados.last()).vr_vllanmto := 158.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13641107;
    v_dados(v_dados.last()).vr_nrctremp := 5043888;
    v_dados(v_dados.last()).vr_vllanmto := 157.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12907227;
    v_dados(v_dados.last()).vr_nrctremp := 5649748;
    v_dados(v_dados.last()).vr_vllanmto := 148.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10251138;
    v_dados(v_dados.last()).vr_nrctremp := 5345929;
    v_dados(v_dados.last()).vr_vllanmto := 148.55;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80099920;
    v_dados(v_dados.last()).vr_nrctremp := 5085776;
    v_dados(v_dados.last()).vr_vllanmto := 148.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065067;
    v_dados(v_dados.last()).vr_nrctremp := 5120902;
    v_dados(v_dados.last()).vr_vllanmto := 147.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10403655;
    v_dados(v_dados.last()).vr_nrctremp := 2955266;
    v_dados(v_dados.last()).vr_vllanmto := 147.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695226;
    v_dados(v_dados.last()).vr_vllanmto := 145.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13639080;
    v_dados(v_dados.last()).vr_nrctremp := 5104902;
    v_dados(v_dados.last()).vr_vllanmto := 143.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9068252;
    v_dados(v_dados.last()).vr_nrctremp := 5249586;
    v_dados(v_dados.last()).vr_vllanmto := 142.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12762067;
    v_dados(v_dados.last()).vr_nrctremp := 4020012;
    v_dados(v_dados.last()).vr_vllanmto := 140.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12465321;
    v_dados(v_dados.last()).vr_nrctremp := 3936331;
    v_dados(v_dados.last()).vr_vllanmto := 140.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8289077;
    v_dados(v_dados.last()).vr_nrctremp := 3293193;
    v_dados(v_dados.last()).vr_vllanmto := 140.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11044039;
    v_dados(v_dados.last()).vr_nrctremp := 4344288;
    v_dados(v_dados.last()).vr_vllanmto := 138.86;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2871068;
    v_dados(v_dados.last()).vr_nrctremp := 4414121;
    v_dados(v_dados.last()).vr_vllanmto := 138.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10800824;
    v_dados(v_dados.last()).vr_nrctremp := 3684745;
    v_dados(v_dados.last()).vr_vllanmto := 137.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10847103;
    v_dados(v_dados.last()).vr_nrctremp := 4190567;
    v_dados(v_dados.last()).vr_vllanmto := 135;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212202;
    v_dados(v_dados.last()).vr_nrctremp := 3420248;
    v_dados(v_dados.last()).vr_vllanmto := 133.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11779608;
    v_dados(v_dados.last()).vr_nrctremp := 2979926;
    v_dados(v_dados.last()).vr_vllanmto := 133.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9726543;
    v_dados(v_dados.last()).vr_nrctremp := 4389334;
    v_dados(v_dados.last()).vr_vllanmto := 125.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12582565;
    v_dados(v_dados.last()).vr_nrctremp := 3986201;
    v_dados(v_dados.last()).vr_vllanmto := 124.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12111791;
    v_dados(v_dados.last()).vr_nrctremp := 3296814;
    v_dados(v_dados.last()).vr_vllanmto := 123.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3013529;
    v_dados(v_dados.last()).vr_nrctremp := 4615616;
    v_dados(v_dados.last()).vr_vllanmto := 123.47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576196;
    v_dados(v_dados.last()).vr_vllanmto := 120.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12594750;
    v_dados(v_dados.last()).vr_nrctremp := 3807129;
    v_dados(v_dados.last()).vr_vllanmto := 117.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7882564;
    v_dados(v_dados.last()).vr_nrctremp := 2955931;
    v_dados(v_dados.last()).vr_vllanmto := 113.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80334768;
    v_dados(v_dados.last()).vr_nrctremp := 3858963;
    v_dados(v_dados.last()).vr_vllanmto := 113.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80193501;
    v_dados(v_dados.last()).vr_nrctremp := 3813432;
    v_dados(v_dados.last()).vr_vllanmto := 109.24;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80101089;
    v_dados(v_dados.last()).vr_nrctremp := 3549323;
    v_dados(v_dados.last()).vr_vllanmto := 108.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80173870;
    v_dados(v_dados.last()).vr_nrctremp := 2955468;
    v_dados(v_dados.last()).vr_vllanmto := 108.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10609377;
    v_dados(v_dados.last()).vr_nrctremp := 2005092;
    v_dados(v_dados.last()).vr_vllanmto := 104.03;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80098592;
    v_dados(v_dados.last()).vr_nrctremp := 2955632;
    v_dados(v_dados.last()).vr_vllanmto := 104.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7434928;
    v_dados(v_dados.last()).vr_nrctremp := 2955176;
    v_dados(v_dados.last()).vr_vllanmto := 103.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356703;
    v_dados(v_dados.last()).vr_nrctremp := 2956154;
    v_dados(v_dados.last()).vr_vllanmto := 103.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421230;
    v_dados(v_dados.last()).vr_vllanmto := 102.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11093293;
    v_dados(v_dados.last()).vr_nrctremp := 3646338;
    v_dados(v_dados.last()).vr_vllanmto := 99.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2124726;
    v_dados(v_dados.last()).vr_nrctremp := 3851551;
    v_dados(v_dados.last()).vr_vllanmto := 98.3;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12891185;
    v_dados(v_dados.last()).vr_nrctremp := 4349609;
    v_dados(v_dados.last()).vr_vllanmto := 98.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11484080;
    v_dados(v_dados.last()).vr_nrctremp := 4741094;
    v_dados(v_dados.last()).vr_vllanmto := 96.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12572713;
    v_dados(v_dados.last()).vr_nrctremp := 3795640;
    v_dados(v_dados.last()).vr_vllanmto := 95.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760102;
    v_dados(v_dados.last()).vr_nrctremp := 3965764;
    v_dados(v_dados.last()).vr_vllanmto := 95.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8684413;
    v_dados(v_dados.last()).vr_nrctremp := 5323281;
    v_dados(v_dados.last()).vr_vllanmto := 95.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7813317;
    v_dados(v_dados.last()).vr_nrctremp := 2955328;
    v_dados(v_dados.last()).vr_vllanmto := 94.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7374763;
    v_dados(v_dados.last()).vr_nrctremp := 4178604;
    v_dados(v_dados.last()).vr_vllanmto := 93.83;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12450316;
    v_dados(v_dados.last()).vr_nrctremp := 3647430;
    v_dados(v_dados.last()).vr_vllanmto := 93.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617008;
    v_dados(v_dados.last()).vr_nrctremp := 3827456;
    v_dados(v_dados.last()).vr_vllanmto := 92.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13344048;
    v_dados(v_dados.last()).vr_nrctremp := 4462768;
    v_dados(v_dados.last()).vr_vllanmto := 91.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80090842;
    v_dados(v_dados.last()).vr_nrctremp := 5204912;
    v_dados(v_dados.last()).vr_vllanmto := 90.85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80358179;
    v_dados(v_dados.last()).vr_nrctremp := 2955616;
    v_dados(v_dados.last()).vr_vllanmto := 88.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230448;
    v_dados(v_dados.last()).vr_nrctremp := 3435628;
    v_dados(v_dados.last()).vr_vllanmto := 87.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2984628;
    v_dados(v_dados.last()).vr_nrctremp := 4935932;
    v_dados(v_dados.last()).vr_vllanmto := 86.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12390917;
    v_dados(v_dados.last()).vr_nrctremp := 5060921;
    v_dados(v_dados.last()).vr_vllanmto := 86.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476651;
    v_dados(v_dados.last()).vr_nrctremp := 4558023;
    v_dados(v_dados.last()).vr_vllanmto := 85.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10065903;
    v_dados(v_dados.last()).vr_nrctremp := 4529120;
    v_dados(v_dados.last()).vr_vllanmto := 84.53;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8171645;
    v_dados(v_dados.last()).vr_nrctremp := 4644755;
    v_dados(v_dados.last()).vr_vllanmto := 84.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2944227;
    v_dados(v_dados.last()).vr_nrctremp := 4953363;
    v_dados(v_dados.last()).vr_vllanmto := 84.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958174;
    v_dados(v_dados.last()).vr_nrctremp := 4140877;
    v_dados(v_dados.last()).vr_vllanmto := 83.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817678;
    v_dados(v_dados.last()).vr_nrctremp := 4256682;
    v_dados(v_dados.last()).vr_vllanmto := 82.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12362778;
    v_dados(v_dados.last()).vr_nrctremp := 3742862;
    v_dados(v_dados.last()).vr_vllanmto := 80.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12274135;
    v_dados(v_dados.last()).vr_nrctremp := 3706648;
    v_dados(v_dados.last()).vr_vllanmto := 77.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10206345;
    v_dados(v_dados.last()).vr_nrctremp := 4035306;
    v_dados(v_dados.last()).vr_vllanmto := 76.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12381020;
    v_dados(v_dados.last()).vr_nrctremp := 5103175;
    v_dados(v_dados.last()).vr_vllanmto := 76.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10275860;
    v_dados(v_dados.last()).vr_nrctremp := 4241038;
    v_dados(v_dados.last()).vr_vllanmto := 75.09;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12584541;
    v_dados(v_dados.last()).vr_nrctremp := 3808261;
    v_dados(v_dados.last()).vr_vllanmto := 74.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8290440;
    v_dados(v_dados.last()).vr_nrctremp := 2011067;
    v_dados(v_dados.last()).vr_vllanmto := 74.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8719705;
    v_dados(v_dados.last()).vr_nrctremp := 4222466;
    v_dados(v_dados.last()).vr_vllanmto := 72.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10889833;
    v_dados(v_dados.last()).vr_nrctremp := 4581853;
    v_dados(v_dados.last()).vr_vllanmto := 70.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11834021;
    v_dados(v_dados.last()).vr_nrctremp := 4407237;
    v_dados(v_dados.last()).vr_vllanmto := 70.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13925920;
    v_dados(v_dados.last()).vr_nrctremp := 5125957;
    v_dados(v_dados.last()).vr_vllanmto := 69.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12350990;
    v_dados(v_dados.last()).vr_nrctremp := 3996044;
    v_dados(v_dados.last()).vr_vllanmto := 68.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12670642;
    v_dados(v_dados.last()).vr_nrctremp := 3877832;
    v_dados(v_dados.last()).vr_vllanmto := 68.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8907315;
    v_dados(v_dados.last()).vr_nrctremp := 3627786;
    v_dados(v_dados.last()).vr_vllanmto := 67.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80431135;
    v_dados(v_dados.last()).vr_nrctremp := 1901589;
    v_dados(v_dados.last()).vr_vllanmto := 66.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11889195;
    v_dados(v_dados.last()).vr_nrctremp := 3521680;
    v_dados(v_dados.last()).vr_vllanmto := 66.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3637271;
    v_dados(v_dados.last()).vr_nrctremp := 4876229;
    v_dados(v_dados.last()).vr_vllanmto := 66.13;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3628280;
    v_dados(v_dados.last()).vr_nrctremp := 3965338;
    v_dados(v_dados.last()).vr_vllanmto := 64.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078793;
    v_dados(v_dados.last()).vr_nrctremp := 4301243;
    v_dados(v_dados.last()).vr_vllanmto := 62.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12620491;
    v_dados(v_dados.last()).vr_nrctremp := 3830907;
    v_dados(v_dados.last()).vr_vllanmto := 62.15;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12560448;
    v_dados(v_dados.last()).vr_nrctremp := 3815662;
    v_dados(v_dados.last()).vr_vllanmto := 61.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10940650;
    v_dados(v_dados.last()).vr_nrctremp := 4639145;
    v_dados(v_dados.last()).vr_vllanmto := 60.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9583211;
    v_dados(v_dados.last()).vr_nrctremp := 3639619;
    v_dados(v_dados.last()).vr_vllanmto := 59.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8518904;
    v_dados(v_dados.last()).vr_nrctremp := 2057865;
    v_dados(v_dados.last()).vr_vllanmto := 57.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12873853;
    v_dados(v_dados.last()).vr_nrctremp := 4082058;
    v_dados(v_dados.last()).vr_vllanmto := 57.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10896384;
    v_dados(v_dados.last()).vr_nrctremp := 4357704;
    v_dados(v_dados.last()).vr_vllanmto := 57.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939478;
    v_dados(v_dados.last()).vr_vllanmto := 56.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10657673;
    v_dados(v_dados.last()).vr_nrctremp := 3167828;
    v_dados(v_dados.last()).vr_vllanmto := 56.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10886176;
    v_dados(v_dados.last()).vr_nrctremp := 3174348;
    v_dados(v_dados.last()).vr_vllanmto := 54.39;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80434720;
    v_dados(v_dados.last()).vr_nrctremp := 4705785;
    v_dados(v_dados.last()).vr_vllanmto := 53.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820408;
    v_dados(v_dados.last()).vr_nrctremp := 3838282;
    v_dados(v_dados.last()).vr_vllanmto := 53.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12055042;
    v_dados(v_dados.last()).vr_nrctremp := 3238779;
    v_dados(v_dados.last()).vr_vllanmto := 53.75;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12349909;
    v_dados(v_dados.last()).vr_nrctremp := 3549289;
    v_dados(v_dados.last()).vr_vllanmto := 53.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898899;
    v_dados(v_dados.last()).vr_nrctremp := 5098127;
    v_dados(v_dados.last()).vr_vllanmto := 53.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3088171;
    v_dados(v_dados.last()).vr_vllanmto := 53.33;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 3170921;
    v_dados(v_dados.last()).vr_vllanmto := 53.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11109742;
    v_dados(v_dados.last()).vr_nrctremp := 2028302;
    v_dados(v_dados.last()).vr_vllanmto := 52.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9519947;
    v_dados(v_dados.last()).vr_nrctremp := 5962529;
    v_dados(v_dados.last()).vr_vllanmto := 52.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7668058;
    v_dados(v_dados.last()).vr_nrctremp := 4183670;
    v_dados(v_dados.last()).vr_vllanmto := 51.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12488968;
    v_dados(v_dados.last()).vr_nrctremp := 3695197;
    v_dados(v_dados.last()).vr_vllanmto := 50.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11750200;
    v_dados(v_dados.last()).vr_nrctremp := 3931873;
    v_dados(v_dados.last()).vr_vllanmto := 49.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6365639;
    v_dados(v_dados.last()).vr_nrctremp := 4185048;
    v_dados(v_dados.last()).vr_vllanmto := 49.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10640622;
    v_dados(v_dados.last()).vr_nrctremp := 4784340;
    v_dados(v_dados.last()).vr_vllanmto := 49.4;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12504998;
    v_dados(v_dados.last()).vr_nrctremp := 4229059;
    v_dados(v_dados.last()).vr_vllanmto := 48.19;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12595373;
    v_dados(v_dados.last()).vr_nrctremp := 4753507;
    v_dados(v_dados.last()).vr_vllanmto := 47.85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2909421;
    v_dados(v_dados.last()).vr_nrctremp := 4055454;
    v_dados(v_dados.last()).vr_vllanmto := 47.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12519421;
    v_dados(v_dados.last()).vr_nrctremp := 3726006;
    v_dados(v_dados.last()).vr_vllanmto := 47.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14068184;
    v_dados(v_dados.last()).vr_nrctremp := 5022566;
    v_dados(v_dados.last()).vr_vllanmto := 46.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9517766;
    v_dados(v_dados.last()).vr_nrctremp := 3855948;
    v_dados(v_dados.last()).vr_vllanmto := 46.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741741;
    v_dados(v_dados.last()).vr_nrctremp := 4570333;
    v_dados(v_dados.last()).vr_vllanmto := 46.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12293407;
    v_dados(v_dados.last()).vr_nrctremp := 3938066;
    v_dados(v_dados.last()).vr_vllanmto := 46.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1705660;
    v_dados(v_dados.last()).vr_nrctremp := 4310541;
    v_dados(v_dados.last()).vr_vllanmto := 46.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10919597;
    v_dados(v_dados.last()).vr_nrctremp := 4141182;
    v_dados(v_dados.last()).vr_vllanmto := 45.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11951605;
    v_dados(v_dados.last()).vr_nrctremp := 4745153;
    v_dados(v_dados.last()).vr_vllanmto := 45.18;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9884955;
    v_dados(v_dados.last()).vr_nrctremp := 3253959;
    v_dados(v_dados.last()).vr_vllanmto := 45.16;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10465537;
    v_dados(v_dados.last()).vr_nrctremp := 4476841;
    v_dados(v_dados.last()).vr_vllanmto := 44.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10256881;
    v_dados(v_dados.last()).vr_nrctremp := 5319811;
    v_dados(v_dados.last()).vr_vllanmto := 44.67;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12744786;
    v_dados(v_dados.last()).vr_nrctremp := 4024341;
    v_dados(v_dados.last()).vr_vllanmto := 44.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10443576;
    v_dados(v_dados.last()).vr_nrctremp := 4660368;
    v_dados(v_dados.last()).vr_vllanmto := 43.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10885471;
    v_dados(v_dados.last()).vr_nrctremp := 4712416;
    v_dados(v_dados.last()).vr_vllanmto := 43.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739103;
    v_dados(v_dados.last()).vr_nrctremp := 4441023;
    v_dados(v_dados.last()).vr_vllanmto := 43.68;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13244051;
    v_dados(v_dados.last()).vr_nrctremp := 4366155;
    v_dados(v_dados.last()).vr_vllanmto := 43.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10677542;
    v_dados(v_dados.last()).vr_nrctremp := 3986642;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10735224;
    v_dados(v_dados.last()).vr_nrctremp := 3701725;
    v_dados(v_dados.last()).vr_vllanmto := 42.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4829674;
    v_dados(v_dados.last()).vr_vllanmto := 42.4;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11204800;
    v_dados(v_dados.last()).vr_nrctremp := 4349266;
    v_dados(v_dados.last()).vr_vllanmto := 42.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2158078;
    v_dados(v_dados.last()).vr_nrctremp := 3383008;
    v_dados(v_dados.last()).vr_vllanmto := 41.85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12737640;
    v_dados(v_dados.last()).vr_nrctremp := 4038250;
    v_dados(v_dados.last()).vr_vllanmto := 41.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10077928;
    v_dados(v_dados.last()).vr_nrctremp := 5159124;
    v_dados(v_dados.last()).vr_vllanmto := 41.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11396733;
    v_dados(v_dados.last()).vr_nrctremp := 3897105;
    v_dados(v_dados.last()).vr_vllanmto := 40.9;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194460;
    v_dados(v_dados.last()).vr_nrctremp := 2114224;
    v_dados(v_dados.last()).vr_vllanmto := 40.31;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12487937;
    v_dados(v_dados.last()).vr_nrctremp := 3703633;
    v_dados(v_dados.last()).vr_vllanmto := 39.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7860609;
    v_dados(v_dados.last()).vr_nrctremp := 5009730;
    v_dados(v_dados.last()).vr_vllanmto := 39.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14134489;
    v_dados(v_dados.last()).vr_nrctremp := 5076228;
    v_dados(v_dados.last()).vr_vllanmto := 39.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12141534;
    v_dados(v_dados.last()).vr_nrctremp := 5130609;
    v_dados(v_dados.last()).vr_vllanmto := 38.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9633316;
    v_dados(v_dados.last()).vr_nrctremp := 4343361;
    v_dados(v_dados.last()).vr_vllanmto := 38.59;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9868925;
    v_dados(v_dados.last()).vr_nrctremp := 3230862;
    v_dados(v_dados.last()).vr_vllanmto := 38.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9190945;
    v_dados(v_dados.last()).vr_nrctremp := 1956430;
    v_dados(v_dados.last()).vr_vllanmto := 37.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8904375;
    v_dados(v_dados.last()).vr_nrctremp := 4874504;
    v_dados(v_dados.last()).vr_vllanmto := 37.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12520365;
    v_dados(v_dados.last()).vr_nrctremp := 3726902;
    v_dados(v_dados.last()).vr_vllanmto := 37.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13009389;
    v_dados(v_dados.last()).vr_nrctremp := 4348153;
    v_dados(v_dados.last()).vr_vllanmto := 36.87;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12869856;
    v_dados(v_dados.last()).vr_nrctremp := 5070594;
    v_dados(v_dados.last()).vr_vllanmto := 36.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7568266;
    v_dados(v_dados.last()).vr_nrctremp := 4375900;
    v_dados(v_dados.last()).vr_vllanmto := 35.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12029823;
    v_dados(v_dados.last()).vr_nrctremp := 4577555;
    v_dados(v_dados.last()).vr_vllanmto := 35.74;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8273332;
    v_dados(v_dados.last()).vr_nrctremp := 4648247;
    v_dados(v_dados.last()).vr_vllanmto := 35.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10092366;
    v_dados(v_dados.last()).vr_nrctremp := 4521572;
    v_dados(v_dados.last()).vr_vllanmto := 35.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13240072;
    v_dados(v_dados.last()).vr_nrctremp := 4378452;
    v_dados(v_dados.last()).vr_vllanmto := 35.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11035528;
    v_dados(v_dados.last()).vr_nrctremp := 4777035;
    v_dados(v_dados.last()).vr_vllanmto := 35.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10645292;
    v_dados(v_dados.last()).vr_nrctremp := 4312871;
    v_dados(v_dados.last()).vr_vllanmto := 34.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12700860;
    v_dados(v_dados.last()).vr_nrctremp := 3939431;
    v_dados(v_dados.last()).vr_vllanmto := 34.52;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80249469;
    v_dados(v_dados.last()).vr_nrctremp := 3075184;
    v_dados(v_dados.last()).vr_vllanmto := 34.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12182249;
    v_dados(v_dados.last()).vr_nrctremp := 3389755;
    v_dados(v_dados.last()).vr_vllanmto := 34.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12420085;
    v_dados(v_dados.last()).vr_nrctremp := 3621331;
    v_dados(v_dados.last()).vr_vllanmto := 33.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11806222;
    v_dados(v_dados.last()).vr_nrctremp := 4245131;
    v_dados(v_dados.last()).vr_vllanmto := 33.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12543004;
    v_dados(v_dados.last()).vr_nrctremp := 3869309;
    v_dados(v_dados.last()).vr_vllanmto := 33.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12324841;
    v_dados(v_dados.last()).vr_nrctremp := 4822507;
    v_dados(v_dados.last()).vr_vllanmto := 32.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773766;
    v_dados(v_dados.last()).vr_nrctremp := 4350017;
    v_dados(v_dados.last()).vr_vllanmto := 32.6;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12669016;
    v_dados(v_dados.last()).vr_nrctremp := 3876683;
    v_dados(v_dados.last()).vr_vllanmto := 32.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8164509;
    v_dados(v_dados.last()).vr_nrctremp := 4193531;
    v_dados(v_dados.last()).vr_vllanmto := 32.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389080;
    v_dados(v_dados.last()).vr_nrctremp := 3584084;
    v_dados(v_dados.last()).vr_vllanmto := 32.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10317694;
    v_dados(v_dados.last()).vr_nrctremp := 4677944;
    v_dados(v_dados.last()).vr_vllanmto := 31.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13096702;
    v_dados(v_dados.last()).vr_nrctremp := 4346981;
    v_dados(v_dados.last()).vr_vllanmto := 31.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11941650;
    v_dados(v_dados.last()).vr_nrctremp := 3140966;
    v_dados(v_dados.last()).vr_vllanmto := 30.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13523252;
    v_dados(v_dados.last()).vr_nrctremp := 4564654;
    v_dados(v_dados.last()).vr_vllanmto := 30.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12392820;
    v_dados(v_dados.last()).vr_nrctremp := 3586887;
    v_dados(v_dados.last()).vr_vllanmto := 30.46;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10571760;
    v_dados(v_dados.last()).vr_nrctremp := 4167462;
    v_dados(v_dados.last()).vr_vllanmto := 30.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12422320;
    v_dados(v_dados.last()).vr_nrctremp := 3615395;
    v_dados(v_dados.last()).vr_vllanmto := 29.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14169320;
    v_dados(v_dados.last()).vr_nrctremp := 5104679;
    v_dados(v_dados.last()).vr_vllanmto := 29.49;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9543490;
    v_dados(v_dados.last()).vr_nrctremp := 4391966;
    v_dados(v_dados.last()).vr_vllanmto := 29.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2710374;
    v_dados(v_dados.last()).vr_nrctremp := 4391409;
    v_dados(v_dados.last()).vr_vllanmto := 28.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12558010;
    v_dados(v_dados.last()).vr_nrctremp := 3763615;
    v_dados(v_dados.last()).vr_vllanmto := 28.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9973877;
    v_dados(v_dados.last()).vr_nrctremp := 4705248;
    v_dados(v_dados.last()).vr_vllanmto := 28.78;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12378917;
    v_dados(v_dados.last()).vr_nrctremp := 3577859;
    v_dados(v_dados.last()).vr_vllanmto := 28.62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12100595;
    v_dados(v_dados.last()).vr_nrctremp := 3288682;
    v_dados(v_dados.last()).vr_vllanmto := 28.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12949353;
    v_dados(v_dados.last()).vr_nrctremp := 4148318;
    v_dados(v_dados.last()).vr_vllanmto := 28.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14700344;
    v_dados(v_dados.last()).vr_nrctremp := 5571768;
    v_dados(v_dados.last()).vr_vllanmto := 28.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9346155;
    v_dados(v_dados.last()).vr_nrctremp := 5782934;
    v_dados(v_dados.last()).vr_vllanmto := 27.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13763890;
    v_dados(v_dados.last()).vr_nrctremp := 4739175;
    v_dados(v_dados.last()).vr_vllanmto := 27.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80066810;
    v_dados(v_dados.last()).vr_nrctremp := 5793704;
    v_dados(v_dados.last()).vr_vllanmto := 27.76;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11785837;
    v_dados(v_dados.last()).vr_nrctremp := 4974493;
    v_dados(v_dados.last()).vr_vllanmto := 27.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12711586;
    v_dados(v_dados.last()).vr_nrctremp := 5748667;
    v_dados(v_dados.last()).vr_vllanmto := 27.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9958070;
    v_dados(v_dados.last()).vr_nrctremp := 5848326;
    v_dados(v_dados.last()).vr_vllanmto := 26.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12239470;
    v_dados(v_dados.last()).vr_nrctremp := 3436180;
    v_dados(v_dados.last()).vr_vllanmto := 26.2;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7765002;
    v_dados(v_dados.last()).vr_nrctremp := 5020530;
    v_dados(v_dados.last()).vr_vllanmto := 25.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7204612;
    v_dados(v_dados.last()).vr_nrctremp := 4750120;
    v_dados(v_dados.last()).vr_vllanmto := 25.65;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3961630;
    v_dados(v_dados.last()).vr_nrctremp := 4984115;
    v_dados(v_dados.last()).vr_vllanmto := 25.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028243;
    v_dados(v_dados.last()).vr_nrctremp := 4270455;
    v_dados(v_dados.last()).vr_vllanmto := 25.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80362419;
    v_dados(v_dados.last()).vr_nrctremp := 4762997;
    v_dados(v_dados.last()).vr_vllanmto := 24.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13209248;
    v_dados(v_dados.last()).vr_nrctremp := 4499591;
    v_dados(v_dados.last()).vr_vllanmto := 24.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9210750;
    v_dados(v_dados.last()).vr_nrctremp := 4338371;
    v_dados(v_dados.last()).vr_vllanmto := 24.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683352;
    v_dados(v_dados.last()).vr_nrctremp := 4624468;
    v_dados(v_dados.last()).vr_vllanmto := 24.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475165;
    v_dados(v_dados.last()).vr_nrctremp := 3675184;
    v_dados(v_dados.last()).vr_vllanmto := 24.26;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9316841;
    v_dados(v_dados.last()).vr_nrctremp := 2955712;
    v_dados(v_dados.last()).vr_vllanmto := 24.22;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9158790;
    v_dados(v_dados.last()).vr_nrctremp := 3072259;
    v_dados(v_dados.last()).vr_vllanmto := 23.97;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601179;
    v_dados(v_dados.last()).vr_nrctremp := 5736851;
    v_dados(v_dados.last()).vr_vllanmto := 23.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8176493;
    v_dados(v_dados.last()).vr_nrctremp := 3618471;
    v_dados(v_dados.last()).vr_vllanmto := 23.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8675678;
    v_dados(v_dados.last()).vr_nrctremp := 4060220;
    v_dados(v_dados.last()).vr_vllanmto := 23.56;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6155677;
    v_dados(v_dados.last()).vr_nrctremp := 4638991;
    v_dados(v_dados.last()).vr_vllanmto := 23.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12300349;
    v_dados(v_dados.last()).vr_nrctremp := 3504428;
    v_dados(v_dados.last()).vr_vllanmto := 23.14;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413640;
    v_dados(v_dados.last()).vr_nrctremp := 3977580;
    v_dados(v_dados.last()).vr_vllanmto := 23.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7519796;
    v_dados(v_dados.last()).vr_nrctremp := 2955918;
    v_dados(v_dados.last()).vr_vllanmto := 22.98;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13132504;
    v_dados(v_dados.last()).vr_nrctremp := 4346910;
    v_dados(v_dados.last()).vr_vllanmto := 22.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425770;
    v_dados(v_dados.last()).vr_nrctremp := 3620293;
    v_dados(v_dados.last()).vr_vllanmto := 22.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12790079;
    v_dados(v_dados.last()).vr_nrctremp := 4349720;
    v_dados(v_dados.last()).vr_vllanmto := 22.88;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898899;
    v_dados(v_dados.last()).vr_nrctremp := 4097203;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13006703;
    v_dados(v_dados.last()).vr_nrctremp := 4696585;
    v_dados(v_dados.last()).vr_vllanmto := 20.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13314084;
    v_dados(v_dados.last()).vr_nrctremp := 4413621;
    v_dados(v_dados.last()).vr_vllanmto := 20.09;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7797320;
    v_dados(v_dados.last()).vr_nrctremp := 3869609;
    v_dados(v_dados.last()).vr_vllanmto := 20.04;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12651443;
    v_dados(v_dados.last()).vr_nrctremp := 4950509;
    v_dados(v_dados.last()).vr_vllanmto := 19.91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10568689;
    v_dados(v_dados.last()).vr_nrctremp := 5546017;
    v_dados(v_dados.last()).vr_vllanmto := 19.89;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8637733;
    v_dados(v_dados.last()).vr_nrctremp := 4101609;
    v_dados(v_dados.last()).vr_vllanmto := 19.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725190;
    v_dados(v_dados.last()).vr_nrctremp := 4846648;
    v_dados(v_dados.last()).vr_vllanmto := 19.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13175289;
    v_dados(v_dados.last()).vr_nrctremp := 5125079;
    v_dados(v_dados.last()).vr_vllanmto := 19.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10605843;
    v_dados(v_dados.last()).vr_nrctremp := 4164558;
    v_dados(v_dados.last()).vr_vllanmto := 19.35;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3026450;
    v_dados(v_dados.last()).vr_nrctremp := 4642781;
    v_dados(v_dados.last()).vr_vllanmto := 19.34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4016041;
    v_dados(v_dados.last()).vr_nrctremp := 4413361;
    v_dados(v_dados.last()).vr_vllanmto := 19.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9274456;
    v_dados(v_dados.last()).vr_nrctremp := 4881776;
    v_dados(v_dados.last()).vr_vllanmto := 19.07;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9199420;
    v_dados(v_dados.last()).vr_nrctremp := 4699390;
    v_dados(v_dados.last()).vr_vllanmto := 19.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10204547;
    v_dados(v_dados.last()).vr_nrctremp := 4635900;
    v_dados(v_dados.last()).vr_vllanmto := 18.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12127426;
    v_dados(v_dados.last()).vr_nrctremp := 3319430;
    v_dados(v_dados.last()).vr_vllanmto := 18.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10682333;
    v_dados(v_dados.last()).vr_nrctremp := 3189310;
    v_dados(v_dados.last()).vr_vllanmto := 18.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9194371;
    v_dados(v_dados.last()).vr_nrctremp := 3700170;
    v_dados(v_dados.last()).vr_vllanmto := 18.42;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12809918;
    v_dados(v_dados.last()).vr_nrctremp := 5361272;
    v_dados(v_dados.last()).vr_vllanmto := 18.32;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6927670;
    v_dados(v_dados.last()).vr_nrctremp := 2955243;
    v_dados(v_dados.last()).vr_vllanmto := 18.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12360082;
    v_dados(v_dados.last()).vr_nrctremp := 3555694;
    v_dados(v_dados.last()).vr_vllanmto := 18.08;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12601977;
    v_dados(v_dados.last()).vr_nrctremp := 4029953;
    v_dados(v_dados.last()).vr_vllanmto := 18.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6880924;
    v_dados(v_dados.last()).vr_nrctremp := 3859002;
    v_dados(v_dados.last()).vr_vllanmto := 17.95;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2811030;
    v_dados(v_dados.last()).vr_nrctremp := 4751728;
    v_dados(v_dados.last()).vr_vllanmto := 17.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12717304;
    v_dados(v_dados.last()).vr_nrctremp := 3995442;
    v_dados(v_dados.last()).vr_vllanmto := 17.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12313670;
    v_dados(v_dados.last()).vr_nrctremp := 3508051;
    v_dados(v_dados.last()).vr_vllanmto := 17.54;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11453680;
    v_dados(v_dados.last()).vr_nrctremp := 4189966;
    v_dados(v_dados.last()).vr_vllanmto := 17.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10752188;
    v_dados(v_dados.last()).vr_nrctremp := 4616770;
    v_dados(v_dados.last()).vr_vllanmto := 17.39;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13028847;
    v_dados(v_dados.last()).vr_nrctremp := 4256265;
    v_dados(v_dados.last()).vr_vllanmto := 17.27;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80060242;
    v_dados(v_dados.last()).vr_nrctremp := 2214162;
    v_dados(v_dados.last()).vr_vllanmto := 17.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2540495;
    v_dados(v_dados.last()).vr_nrctremp := 4699203;
    v_dados(v_dados.last()).vr_vllanmto := 17.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9519947;
    v_dados(v_dados.last()).vr_nrctremp := 4492928;
    v_dados(v_dados.last()).vr_vllanmto := 17.1;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12610178;
    v_dados(v_dados.last()).vr_nrctremp := 5812142;
    v_dados(v_dados.last()).vr_vllanmto := 16.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12397253;
    v_dados(v_dados.last()).vr_nrctremp := 3600273;
    v_dados(v_dados.last()).vr_vllanmto := 16.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7986726;
    v_dados(v_dados.last()).vr_nrctremp := 5427406;
    v_dados(v_dados.last()).vr_vllanmto := 16.58;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8613010;
    v_dados(v_dados.last()).vr_nrctremp := 5775082;
    v_dados(v_dados.last()).vr_vllanmto := 16.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12417742;
    v_dados(v_dados.last()).vr_nrctremp := 3614655;
    v_dados(v_dados.last()).vr_vllanmto := 16.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13155997;
    v_dados(v_dados.last()).vr_nrctremp := 4701450;
    v_dados(v_dados.last()).vr_vllanmto := 16.06;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3500713;
    v_dados(v_dados.last()).vr_nrctremp := 4377724;
    v_dados(v_dados.last()).vr_vllanmto := 15.85;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12947920;
    v_dados(v_dados.last()).vr_nrctremp := 4462306;
    v_dados(v_dados.last()).vr_vllanmto := 15.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10980113;
    v_dados(v_dados.last()).vr_nrctremp := 1893344;
    v_dados(v_dados.last()).vr_vllanmto := 15.63;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11820004;
    v_dados(v_dados.last()).vr_nrctremp := 4617074;
    v_dados(v_dados.last()).vr_vllanmto := 15.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6635369;
    v_dados(v_dados.last()).vr_nrctremp := 4627413;
    v_dados(v_dados.last()).vr_vllanmto := 15.5;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13011600;
    v_dados(v_dados.last()).vr_nrctremp := 5349520;
    v_dados(v_dados.last()).vr_vllanmto := 15.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11357096;
    v_dados(v_dados.last()).vr_nrctremp := 5247177;
    v_dados(v_dados.last()).vr_vllanmto := 15.37;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13131044;
    v_dados(v_dados.last()).vr_nrctremp := 4275417;
    v_dados(v_dados.last()).vr_vllanmto := 15.36;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10534083;
    v_dados(v_dados.last()).vr_nrctremp := 4745410;
    v_dados(v_dados.last()).vr_vllanmto := 15.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11759631;
    v_dados(v_dados.last()).vr_nrctremp := 4832937;
    v_dados(v_dados.last()).vr_vllanmto := 15.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710563;
    v_dados(v_dados.last()).vr_nrctremp := 4075169;
    v_dados(v_dados.last()).vr_vllanmto := 15.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13666053;
    v_dados(v_dados.last()).vr_nrctremp := 4852622;
    v_dados(v_dados.last()).vr_vllanmto := 15.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80100830;
    v_dados(v_dados.last()).vr_nrctremp := 4564808;
    v_dados(v_dados.last()).vr_vllanmto := 15.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13306138;
    v_dados(v_dados.last()).vr_nrctremp := 4901939;
    v_dados(v_dados.last()).vr_vllanmto := 15.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13725580;
    v_dados(v_dados.last()).vr_nrctremp := 4885820;
    v_dados(v_dados.last()).vr_vllanmto := 15.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12183890;
    v_dados(v_dados.last()).vr_nrctremp := 3393615;
    v_dados(v_dados.last()).vr_vllanmto := 15.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12833797;
    v_dados(v_dados.last()).vr_nrctremp := 4181782;
    v_dados(v_dados.last()).vr_vllanmto := 15.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8456445;
    v_dados(v_dados.last()).vr_nrctremp := 4438913;
    v_dados(v_dados.last()).vr_vllanmto := 15.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11009993;
    v_dados(v_dados.last()).vr_nrctremp := 4901511;
    v_dados(v_dados.last()).vr_vllanmto := 16.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1927337;
    v_dados(v_dados.last()).vr_nrctremp := 5139328;
    v_dados(v_dados.last()).vr_vllanmto := 16.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7364695;
    v_dados(v_dados.last()).vr_nrctremp := 5172208;
    v_dados(v_dados.last()).vr_vllanmto := 16.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13335464;
    v_dados(v_dados.last()).vr_nrctremp := 4617398;
    v_dados(v_dados.last()).vr_vllanmto := 16.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11195541;
    v_dados(v_dados.last()).vr_nrctremp := 4604839;
    v_dados(v_dados.last()).vr_vllanmto := 16.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605658;
    v_dados(v_dados.last()).vr_vllanmto := 16.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12258431;
    v_dados(v_dados.last()).vr_nrctremp := 3455167;
    v_dados(v_dados.last()).vr_vllanmto := 16.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021490;
    v_dados(v_dados.last()).vr_nrctremp := 3421257;
    v_dados(v_dados.last()).vr_vllanmto := 16.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11887745;
    v_dados(v_dados.last()).vr_nrctremp := 3941325;
    v_dados(v_dados.last()).vr_vllanmto := 16.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11888784;
    v_dados(v_dados.last()).vr_nrctremp := 5311993;
    v_dados(v_dados.last()).vr_vllanmto := 16.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8479631;
    v_dados(v_dados.last()).vr_nrctremp := 5565614;
    v_dados(v_dados.last()).vr_vllanmto := 16.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658343;
    v_dados(v_dados.last()).vr_vllanmto := 16.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13455435;
    v_dados(v_dados.last()).vr_nrctremp := 4674078;
    v_dados(v_dados.last()).vr_vllanmto := 17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11149167;
    v_dados(v_dados.last()).vr_nrctremp := 2071534;
    v_dados(v_dados.last()).vr_vllanmto := 17.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12109282;
    v_dados(v_dados.last()).vr_nrctremp := 3297031;
    v_dados(v_dados.last()).vr_vllanmto := 17.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058466;
    v_dados(v_dados.last()).vr_nrctremp := 5438376;
    v_dados(v_dados.last()).vr_vllanmto := 17.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13246003;
    v_dados(v_dados.last()).vr_nrctremp := 4375937;
    v_dados(v_dados.last()).vr_vllanmto := 17.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2182955;
    v_dados(v_dados.last()).vr_nrctremp := 4076508;
    v_dados(v_dados.last()).vr_vllanmto := 17.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12898651;
    v_dados(v_dados.last()).vr_nrctremp := 4188743;
    v_dados(v_dados.last()).vr_vllanmto := 17.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8058717;
    v_dados(v_dados.last()).vr_nrctremp := 3990688;
    v_dados(v_dados.last()).vr_vllanmto := 17.35;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13124129;
    v_dados(v_dados.last()).vr_nrctremp := 4502808;
    v_dados(v_dados.last()).vr_vllanmto := 17.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11768614;
    v_dados(v_dados.last()).vr_nrctremp := 3305760;
    v_dados(v_dados.last()).vr_vllanmto := 17.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9322817;
    v_dados(v_dados.last()).vr_nrctremp := 4747166;
    v_dados(v_dados.last()).vr_vllanmto := 17.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10249168;
    v_dados(v_dados.last()).vr_nrctremp := 5311587;
    v_dados(v_dados.last()).vr_vllanmto := 17.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8060266;
    v_dados(v_dados.last()).vr_nrctremp := 4800878;
    v_dados(v_dados.last()).vr_vllanmto := 17.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13536290;
    v_dados(v_dados.last()).vr_nrctremp := 4708727;
    v_dados(v_dados.last()).vr_vllanmto := 18.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12141275;
    v_dados(v_dados.last()).vr_nrctremp := 5019971;
    v_dados(v_dados.last()).vr_vllanmto := 18.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13681192;
    v_dados(v_dados.last()).vr_nrctremp := 5436358;
    v_dados(v_dados.last()).vr_vllanmto := 19.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12389404;
    v_dados(v_dados.last()).vr_nrctremp := 4250955;
    v_dados(v_dados.last()).vr_vllanmto := 19.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11175834;
    v_dados(v_dados.last()).vr_nrctremp := 5574582;
    v_dados(v_dados.last()).vr_vllanmto := 19.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80234216;
    v_dados(v_dados.last()).vr_nrctremp := 4997069;
    v_dados(v_dados.last()).vr_vllanmto := 19.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12706477;
    v_dados(v_dados.last()).vr_nrctremp := 4016118;
    v_dados(v_dados.last()).vr_vllanmto := 19.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9956484;
    v_dados(v_dados.last()).vr_nrctremp := 3775596;
    v_dados(v_dados.last()).vr_vllanmto := 19.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13855549;
    v_dados(v_dados.last()).vr_nrctremp := 4814043;
    v_dados(v_dados.last()).vr_vllanmto := 19.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13110519;
    v_dados(v_dados.last()).vr_nrctremp := 4375141;
    v_dados(v_dados.last()).vr_vllanmto := 19.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12364690;
    v_dados(v_dados.last()).vr_nrctremp := 3572209;
    v_dados(v_dados.last()).vr_vllanmto := 19.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12813826;
    v_dados(v_dados.last()).vr_nrctremp := 4097768;
    v_dados(v_dados.last()).vr_vllanmto := 19.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13389408;
    v_dados(v_dados.last()).vr_nrctremp := 4639193;
    v_dados(v_dados.last()).vr_vllanmto := 19.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6389643;
    v_dados(v_dados.last()).vr_nrctremp := 4754021;
    v_dados(v_dados.last()).vr_vllanmto := 19.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2038650;
    v_dados(v_dados.last()).vr_nrctremp := 3664319;
    v_dados(v_dados.last()).vr_vllanmto := 19.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12462888;
    v_dados(v_dados.last()).vr_nrctremp := 4022402;
    v_dados(v_dados.last()).vr_vllanmto := 20.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10099468;
    v_dados(v_dados.last()).vr_nrctremp := 5308286;
    v_dados(v_dados.last()).vr_vllanmto := 20.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10961887;
    v_dados(v_dados.last()).vr_nrctremp := 5622318;
    v_dados(v_dados.last()).vr_vllanmto := 20.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3864626;
    v_dados(v_dados.last()).vr_nrctremp := 3730749;
    v_dados(v_dados.last()).vr_vllanmto := 21.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12146870;
    v_dados(v_dados.last()).vr_nrctremp := 4251082;
    v_dados(v_dados.last()).vr_vllanmto := 21.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875638;
    v_dados(v_dados.last()).vr_nrctremp := 5414111;
    v_dados(v_dados.last()).vr_vllanmto := 21.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3521109;
    v_dados(v_dados.last()).vr_nrctremp := 5592146;
    v_dados(v_dados.last()).vr_vllanmto := 21.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13279424;
    v_dados(v_dados.last()).vr_nrctremp := 4389259;
    v_dados(v_dados.last()).vr_vllanmto := 21.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12923419;
    v_dados(v_dados.last()).vr_nrctremp := 4741564;
    v_dados(v_dados.last()).vr_vllanmto := 21.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11763744;
    v_dados(v_dados.last()).vr_nrctremp := 4513090;
    v_dados(v_dados.last()).vr_vllanmto := 22.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8078793;
    v_dados(v_dados.last()).vr_nrctremp := 4002953;
    v_dados(v_dados.last()).vr_vllanmto := 22.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10424393;
    v_dados(v_dados.last()).vr_nrctremp := 5501295;
    v_dados(v_dados.last()).vr_vllanmto := 22.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9352562;
    v_dados(v_dados.last()).vr_nrctremp := 5027319;
    v_dados(v_dados.last()).vr_vllanmto := 22.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12170194;
    v_dados(v_dados.last()).vr_nrctremp := 5448447;
    v_dados(v_dados.last()).vr_vllanmto := 23.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7864825;
    v_dados(v_dados.last()).vr_nrctremp := 4564568;
    v_dados(v_dados.last()).vr_vllanmto := 23.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12632643;
    v_dados(v_dados.last()).vr_nrctremp := 4194374;
    v_dados(v_dados.last()).vr_vllanmto := 23.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9666869;
    v_dados(v_dados.last()).vr_nrctremp := 5196774;
    v_dados(v_dados.last()).vr_vllanmto := 23.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13342509;
    v_dados(v_dados.last()).vr_nrctremp := 4463416;
    v_dados(v_dados.last()).vr_vllanmto := 23.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12568457;
    v_dados(v_dados.last()).vr_nrctremp := 3774764;
    v_dados(v_dados.last()).vr_vllanmto := 23.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11773367;
    v_dados(v_dados.last()).vr_nrctremp := 3170781;
    v_dados(v_dados.last()).vr_vllanmto := 24.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11875283;
    v_dados(v_dados.last()).vr_nrctremp := 4559125;
    v_dados(v_dados.last()).vr_vllanmto := 24.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2183315;
    v_dados(v_dados.last()).vr_nrctremp := 3907302;
    v_dados(v_dados.last()).vr_vllanmto := 25.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10636048;
    v_dados(v_dados.last()).vr_nrctremp := 4839172;
    v_dados(v_dados.last()).vr_vllanmto := 25.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80367780;
    v_dados(v_dados.last()).vr_nrctremp := 2077526;
    v_dados(v_dados.last()).vr_vllanmto := 25.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13217526;
    v_dados(v_dados.last()).vr_nrctremp := 4692786;
    v_dados(v_dados.last()).vr_vllanmto := 25.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12501514;
    v_dados(v_dados.last()).vr_nrctremp := 5189367;
    v_dados(v_dados.last()).vr_vllanmto := 26.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466162;
    v_dados(v_dados.last()).vr_vllanmto := 26.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10531769;
    v_dados(v_dados.last()).vr_nrctremp := 4414552;
    v_dados(v_dados.last()).vr_vllanmto := 26.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10140425;
    v_dados(v_dados.last()).vr_nrctremp := 3852530;
    v_dados(v_dados.last()).vr_vllanmto := 26.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12548650;
    v_dados(v_dados.last()).vr_nrctremp := 3753649;
    v_dados(v_dados.last()).vr_vllanmto := 26.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3968944;
    v_dados(v_dados.last()).vr_nrctremp := 4606072;
    v_dados(v_dados.last()).vr_vllanmto := 27.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12311170;
    v_dados(v_dados.last()).vr_nrctremp := 3502234;
    v_dados(v_dados.last()).vr_vllanmto := 27.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11468610;
    v_dados(v_dados.last()).vr_nrctremp := 4779849;
    v_dados(v_dados.last()).vr_vllanmto := 27.87;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12897400;
    v_dados(v_dados.last()).vr_nrctremp := 4617687;
    v_dados(v_dados.last()).vr_vllanmto := 28.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13087525;
    v_dados(v_dados.last()).vr_nrctremp := 4375284;
    v_dados(v_dados.last()).vr_vllanmto := 29.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11267690;
    v_dados(v_dados.last()).vr_nrctremp := 4693624;
    v_dados(v_dados.last()).vr_vllanmto := 29.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13225146;
    v_dados(v_dados.last()).vr_nrctremp := 4950218;
    v_dados(v_dados.last()).vr_vllanmto := 29.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12413887;
    v_dados(v_dados.last()).vr_nrctremp := 4535597;
    v_dados(v_dados.last()).vr_vllanmto := 29.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10827200;
    v_dados(v_dados.last()).vr_nrctremp := 3008250;
    v_dados(v_dados.last()).vr_vllanmto := 30.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11286024;
    v_dados(v_dados.last()).vr_nrctremp := 5397806;
    v_dados(v_dados.last()).vr_vllanmto := 30.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12847089;
    v_dados(v_dados.last()).vr_nrctremp := 4651191;
    v_dados(v_dados.last()).vr_vllanmto := 30.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116967;
    v_dados(v_dados.last()).vr_nrctremp := 4348356;
    v_dados(v_dados.last()).vr_vllanmto := 30.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12474444;
    v_dados(v_dados.last()).vr_nrctremp := 4592182;
    v_dados(v_dados.last()).vr_vllanmto := 30.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10491970;
    v_dados(v_dados.last()).vr_nrctremp := 4253223;
    v_dados(v_dados.last()).vr_vllanmto := 30.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12103721;
    v_dados(v_dados.last()).vr_nrctremp := 3289303;
    v_dados(v_dados.last()).vr_vllanmto := 31.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11754079;
    v_dados(v_dados.last()).vr_nrctremp := 5034347;
    v_dados(v_dados.last()).vr_vllanmto := 32.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9744711;
    v_dados(v_dados.last()).vr_nrctremp := 4046030;
    v_dados(v_dados.last()).vr_vllanmto := 32.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6087370;
    v_dados(v_dados.last()).vr_nrctremp := 4428207;
    v_dados(v_dados.last()).vr_vllanmto := 32.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80346871;
    v_dados(v_dados.last()).vr_nrctremp := 2024567;
    v_dados(v_dados.last()).vr_vllanmto := 32.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12581151;
    v_dados(v_dados.last()).vr_nrctremp := 4557907;
    v_dados(v_dados.last()).vr_vllanmto := 32.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13145088;
    v_dados(v_dados.last()).vr_nrctremp := 4430603;
    v_dados(v_dados.last()).vr_vllanmto := 32.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13316419;
    v_dados(v_dados.last()).vr_nrctremp := 4575351;
    v_dados(v_dados.last()).vr_vllanmto := 33.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266578;
    v_dados(v_dados.last()).vr_nrctremp := 4829270;
    v_dados(v_dados.last()).vr_vllanmto := 33.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12591424;
    v_dados(v_dados.last()).vr_nrctremp := 3799822;
    v_dados(v_dados.last()).vr_vllanmto := 33.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8311170;
    v_dados(v_dados.last()).vr_nrctremp := 5356236;
    v_dados(v_dados.last()).vr_vllanmto := 34.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582933;
    v_dados(v_dados.last()).vr_nrctremp := 4605498;
    v_dados(v_dados.last()).vr_vllanmto := 35.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80141501;
    v_dados(v_dados.last()).vr_nrctremp := 5314168;
    v_dados(v_dados.last()).vr_vllanmto := 35.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13584227;
    v_dados(v_dados.last()).vr_nrctremp := 4658300;
    v_dados(v_dados.last()).vr_vllanmto := 37.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3183076;
    v_dados(v_dados.last()).vr_nrctremp := 5369358;
    v_dados(v_dados.last()).vr_vllanmto := 37.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8084840;
    v_dados(v_dados.last()).vr_nrctremp := 4569856;
    v_dados(v_dados.last()).vr_vllanmto := 37.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198424;
    v_dados(v_dados.last()).vr_nrctremp := 4466185;
    v_dados(v_dados.last()).vr_vllanmto := 38.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9433171;
    v_dados(v_dados.last()).vr_nrctremp := 4559377;
    v_dados(v_dados.last()).vr_vllanmto := 39.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13133039;
    v_dados(v_dados.last()).vr_nrctremp := 4273075;
    v_dados(v_dados.last()).vr_vllanmto := 40.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119478;
    v_dados(v_dados.last()).vr_nrctremp := 4265318;
    v_dados(v_dados.last()).vr_vllanmto := 41.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116967;
    v_dados(v_dados.last()).vr_nrctremp := 4305664;
    v_dados(v_dados.last()).vr_vllanmto := 41.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12739090;
    v_dados(v_dados.last()).vr_nrctremp := 4102671;
    v_dados(v_dados.last()).vr_vllanmto := 41.94;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8638047;
    v_dados(v_dados.last()).vr_nrctremp := 4604082;
    v_dados(v_dados.last()).vr_vllanmto := 43.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13343602;
    v_dados(v_dados.last()).vr_nrctremp := 4702720;
    v_dados(v_dados.last()).vr_vllanmto := 43.62;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12425737;
    v_dados(v_dados.last()).vr_nrctremp := 3860454;
    v_dados(v_dados.last()).vr_vllanmto := 43.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80241247;
    v_dados(v_dados.last()).vr_nrctremp := 2046910;
    v_dados(v_dados.last()).vr_vllanmto := 44.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12383708;
    v_dados(v_dados.last()).vr_nrctremp := 3578578;
    v_dados(v_dados.last()).vr_vllanmto := 44.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10432515;
    v_dados(v_dados.last()).vr_nrctremp := 4783814;
    v_dados(v_dados.last()).vr_vllanmto := 45.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12957461;
    v_dados(v_dados.last()).vr_nrctremp := 4349766;
    v_dados(v_dados.last()).vr_vllanmto := 45.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11262818;
    v_dados(v_dados.last()).vr_nrctremp := 4925150;
    v_dados(v_dados.last()).vr_vllanmto := 46.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10831150;
    v_dados(v_dados.last()).vr_nrctremp := 4571633;
    v_dados(v_dados.last()).vr_vllanmto := 46.24;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10245537;
    v_dados(v_dados.last()).vr_nrctremp := 2952113;
    v_dados(v_dados.last()).vr_vllanmto := 46.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9626352;
    v_dados(v_dados.last()).vr_nrctremp := 4898022;
    v_dados(v_dados.last()).vr_vllanmto := 47.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12288195;
    v_dados(v_dados.last()).vr_nrctremp := 4761996;
    v_dados(v_dados.last()).vr_vllanmto := 47.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12950750;
    v_dados(v_dados.last()).vr_nrctremp := 4224701;
    v_dados(v_dados.last()).vr_vllanmto := 47.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717351;
    v_dados(v_dados.last()).vr_nrctremp := 4014142;
    v_dados(v_dados.last()).vr_vllanmto := 48.86;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13029568;
    v_dados(v_dados.last()).vr_nrctremp := 4201717;
    v_dados(v_dados.last()).vr_vllanmto := 49.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12325570;
    v_dados(v_dados.last()).vr_nrctremp := 3599984;
    v_dados(v_dados.last()).vr_vllanmto := 49.38;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 773565;
    v_dados(v_dados.last()).vr_nrctremp := 4922540;
    v_dados(v_dados.last()).vr_vllanmto := 49.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12371297;
    v_dados(v_dados.last()).vr_nrctremp := 4139299;
    v_dados(v_dados.last()).vr_vllanmto := 49.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12741450;
    v_dados(v_dados.last()).vr_nrctremp := 4226847;
    v_dados(v_dados.last()).vr_vllanmto := 50.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13298216;
    v_dados(v_dados.last()).vr_nrctremp := 4662710;
    v_dados(v_dados.last()).vr_vllanmto := 51.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8177589;
    v_dados(v_dados.last()).vr_nrctremp := 3837514;
    v_dados(v_dados.last()).vr_vllanmto := 51.63;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8496293;
    v_dados(v_dados.last()).vr_nrctremp := 4694140;
    v_dados(v_dados.last()).vr_vllanmto := 52.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13665464;
    v_dados(v_dados.last()).vr_nrctremp := 4912942;
    v_dados(v_dados.last()).vr_vllanmto := 52.47;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12731498;
    v_dados(v_dados.last()).vr_nrctremp := 4141397;
    v_dados(v_dados.last()).vr_vllanmto := 53.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12785369;
    v_dados(v_dados.last()).vr_nrctremp := 4083531;
    v_dados(v_dados.last()).vr_vllanmto := 54.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10663452;
    v_dados(v_dados.last()).vr_nrctremp := 5158755;
    v_dados(v_dados.last()).vr_vllanmto := 55.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10816186;
    v_dados(v_dados.last()).vr_nrctremp := 5216299;
    v_dados(v_dados.last()).vr_vllanmto := 57.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2940523;
    v_dados(v_dados.last()).vr_nrctremp := 4193769;
    v_dados(v_dados.last()).vr_vllanmto := 58.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13413775;
    v_dados(v_dados.last()).vr_nrctremp := 4665968;
    v_dados(v_dados.last()).vr_vllanmto := 59.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10283439;
    v_dados(v_dados.last()).vr_nrctremp := 2042069;
    v_dados(v_dados.last()).vr_vllanmto := 61.36;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13768689;
    v_dados(v_dados.last()).vr_nrctremp := 4969255;
    v_dados(v_dados.last()).vr_vllanmto := 62.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80069665;
    v_dados(v_dados.last()).vr_nrctremp := 4053802;
    v_dados(v_dados.last()).vr_vllanmto := 62.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11905344;
    v_dados(v_dados.last()).vr_nrctremp := 3101408;
    v_dados(v_dados.last()).vr_vllanmto := 62.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716200;
    v_dados(v_dados.last()).vr_nrctremp := 3996934;
    v_dados(v_dados.last()).vr_vllanmto := 62.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12701521;
    v_dados(v_dados.last()).vr_nrctremp := 3997739;
    v_dados(v_dados.last()).vr_vllanmto := 63.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3820840;
    v_dados(v_dados.last()).vr_nrctremp := 3399162;
    v_dados(v_dados.last()).vr_vllanmto := 63.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2296667;
    v_dados(v_dados.last()).vr_nrctremp := 4423623;
    v_dados(v_dados.last()).vr_vllanmto := 63.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11691700;
    v_dados(v_dados.last()).vr_nrctremp := 3235912;
    v_dados(v_dados.last()).vr_vllanmto := 64.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9474021;
    v_dados(v_dados.last()).vr_nrctremp := 4661418;
    v_dados(v_dados.last()).vr_vllanmto := 64.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475408;
    v_dados(v_dados.last()).vr_nrctremp := 3680350;
    v_dados(v_dados.last()).vr_vllanmto := 64.7;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12019178;
    v_dados(v_dados.last()).vr_nrctremp := 3430704;
    v_dados(v_dados.last()).vr_vllanmto := 65.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035734;
    v_dados(v_dados.last()).vr_nrctremp := 3434461;
    v_dados(v_dados.last()).vr_vllanmto := 68.03;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13545418;
    v_dados(v_dados.last()).vr_nrctremp := 4576219;
    v_dados(v_dados.last()).vr_vllanmto := 69.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12953563;
    v_dados(v_dados.last()).vr_nrctremp := 4243776;
    v_dados(v_dados.last()).vr_vllanmto := 70.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13440241;
    v_dados(v_dados.last()).vr_nrctremp := 4672702;
    v_dados(v_dados.last()).vr_vllanmto := 71.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10253769;
    v_dados(v_dados.last()).vr_nrctremp := 5312374;
    v_dados(v_dados.last()).vr_vllanmto := 72.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80012248;
    v_dados(v_dados.last()).vr_nrctremp := 4068844;
    v_dados(v_dados.last()).vr_vllanmto := 73.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11909757;
    v_dados(v_dados.last()).vr_nrctremp := 5534576;
    v_dados(v_dados.last()).vr_vllanmto := 74.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80214479;
    v_dados(v_dados.last()).vr_nrctremp := 4921364;
    v_dados(v_dados.last()).vr_vllanmto := 75.18;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9356380;
    v_dados(v_dados.last()).vr_nrctremp := 4642262;
    v_dados(v_dados.last()).vr_vllanmto := 75.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12278653;
    v_dados(v_dados.last()).vr_nrctremp := 4912772;
    v_dados(v_dados.last()).vr_vllanmto := 76.42;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9064397;
    v_dados(v_dados.last()).vr_nrctremp := 4784897;
    v_dados(v_dados.last()).vr_vllanmto := 76.64;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12825212;
    v_dados(v_dados.last()).vr_nrctremp := 4576380;
    v_dados(v_dados.last()).vr_vllanmto := 77.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717947;
    v_dados(v_dados.last()).vr_nrctremp := 3005429;
    v_dados(v_dados.last()).vr_vllanmto := 78.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11619554;
    v_dados(v_dados.last()).vr_nrctremp := 2984552;
    v_dados(v_dados.last()).vr_vllanmto := 78.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13481622;
    v_dados(v_dados.last()).vr_nrctremp := 4650705;
    v_dados(v_dados.last()).vr_vllanmto := 83.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12725480;
    v_dados(v_dados.last()).vr_nrctremp := 4202145;
    v_dados(v_dados.last()).vr_vllanmto := 85.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8304440;
    v_dados(v_dados.last()).vr_nrctremp := 4879513;
    v_dados(v_dados.last()).vr_vllanmto := 87.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7187068;
    v_dados(v_dados.last()).vr_nrctremp := 4810669;
    v_dados(v_dados.last()).vr_vllanmto := 88.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11629410;
    v_dados(v_dados.last()).vr_nrctremp := 4924495;
    v_dados(v_dados.last()).vr_vllanmto := 89.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752916;
    v_dados(v_dados.last()).vr_nrctremp := 4073735;
    v_dados(v_dados.last()).vr_vllanmto := 91.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80145345;
    v_dados(v_dados.last()).vr_nrctremp := 2955719;
    v_dados(v_dados.last()).vr_vllanmto := 95.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9784217;
    v_dados(v_dados.last()).vr_nrctremp := 2728553;
    v_dados(v_dados.last()).vr_vllanmto := 96.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12706523;
    v_dados(v_dados.last()).vr_nrctremp := 4160235;
    v_dados(v_dados.last()).vr_vllanmto := 96.81;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11656948;
    v_dados(v_dados.last()).vr_nrctremp := 3404940;
    v_dados(v_dados.last()).vr_vllanmto := 99.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12752827;
    v_dados(v_dados.last()).vr_nrctremp := 3960181;
    v_dados(v_dados.last()).vr_vllanmto := 104.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12518581;
    v_dados(v_dados.last()).vr_nrctremp := 5165015;
    v_dados(v_dados.last()).vr_vllanmto := 105.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12419940;
    v_dados(v_dados.last()).vr_nrctremp := 3618344;
    v_dados(v_dados.last()).vr_vllanmto := 108.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12143200;
    v_dados(v_dados.last()).vr_nrctremp := 4857588;
    v_dados(v_dados.last()).vr_vllanmto := 115.57;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12557889;
    v_dados(v_dados.last()).vr_nrctremp := 3762595;
    v_dados(v_dados.last()).vr_vllanmto := 119.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13581155;
    v_dados(v_dados.last()).vr_nrctremp := 4921029;
    v_dados(v_dados.last()).vr_vllanmto := 122.79;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12123730;
    v_dados(v_dados.last()).vr_nrctremp := 3315152;
    v_dados(v_dados.last()).vr_vllanmto := 126.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9355146;
    v_dados(v_dados.last()).vr_nrctremp := 2728862;
    v_dados(v_dados.last()).vr_vllanmto := 126.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80337074;
    v_dados(v_dados.last()).vr_nrctremp := 2955519;
    v_dados(v_dados.last()).vr_vllanmto := 129.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8861579;
    v_dados(v_dados.last()).vr_nrctremp := 3067139;
    v_dados(v_dados.last()).vr_vllanmto := 129.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9612696;
    v_dados(v_dados.last()).vr_nrctremp := 2913350;
    v_dados(v_dados.last()).vr_vllanmto := 135.57;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9389989;
    v_dados(v_dados.last()).vr_nrctremp := 2023895;
    v_dados(v_dados.last()).vr_vllanmto := 135.86;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12981877;
    v_dados(v_dados.last()).vr_nrctremp := 5200658;
    v_dados(v_dados.last()).vr_vllanmto := 137.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80147194;
    v_dados(v_dados.last()).vr_nrctremp := 2040841;
    v_dados(v_dados.last()).vr_vllanmto := 141.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10360581;
    v_dados(v_dados.last()).vr_nrctremp := 4521812;
    v_dados(v_dados.last()).vr_vllanmto := 153.75;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80346790;
    v_dados(v_dados.last()).vr_nrctremp := 2502227;
    v_dados(v_dados.last()).vr_vllanmto := 177.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7178565;
    v_dados(v_dados.last()).vr_nrctremp := 4556663;
    v_dados(v_dados.last()).vr_vllanmto := 185.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9990100;
    v_dados(v_dados.last()).vr_nrctremp := 2784147;
    v_dados(v_dados.last()).vr_vllanmto := 211.71;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623160;
    v_dados(v_dados.last()).vr_nrctremp := 3060112;
    v_dados(v_dados.last()).vr_vllanmto := 213.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2415119;
    v_dados(v_dados.last()).vr_nrctremp := 4440402;
    v_dados(v_dados.last()).vr_vllanmto := 218.02;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9683097;
    v_dados(v_dados.last()).vr_nrctremp := 2955793;
    v_dados(v_dados.last()).vr_vllanmto := 254.65;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11057300;
    v_dados(v_dados.last()).vr_nrctremp := 3653854;
    v_dados(v_dados.last()).vr_vllanmto := 335.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 3023875;
    v_dados(v_dados.last()).vr_vllanmto := 382.5;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9768076;
    v_dados(v_dados.last()).vr_nrctremp := 5068501;
    v_dados(v_dados.last()).vr_vllanmto := 402.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9363297;
    v_dados(v_dados.last()).vr_nrctremp := 2998837;
    v_dados(v_dados.last()).vr_vllanmto := 428.12;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9325743;
    v_dados(v_dados.last()).vr_nrctremp := 2073818;
    v_dados(v_dados.last()).vr_vllanmto := 552.23;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10819967;
    v_dados(v_dados.last()).vr_nrctremp := 3159652;
    v_dados(v_dados.last()).vr_vllanmto := 742.14;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11379014;
    v_dados(v_dados.last()).vr_nrctremp := 5061942;
    v_dados(v_dados.last()).vr_vllanmto := 1417.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2515938;
    v_dados(v_dados.last()).vr_nrctremp := 3969605;
    v_dados(v_dados.last()).vr_vllanmto := 1457.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8043124;
    v_dados(v_dados.last()).vr_nrctremp := 3024875;
    v_dados(v_dados.last()).vr_vllanmto := 1646.04;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10745319;
    v_dados(v_dados.last()).vr_nrctremp := 2955382;
    v_dados(v_dados.last()).vr_vllanmto := 2238.31;
    v_dados(v_dados.last()).vr_cdhistor := 1041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80476260;
    v_dados(v_dados.last()).vr_nrctremp := 2816090;
    v_dados(v_dados.last()).vr_vllanmto := 2642.10;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11991062;
    v_dados(v_dados.last()).vr_nrctremp := 3174399;
    v_dados(v_dados.last()).vr_vllanmto := 5177.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10400354;
    v_dados(v_dados.last()).vr_nrctremp := 5541382;
    v_dados(v_dados.last()).vr_vllanmto := 5384.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9349049;
    v_dados(v_dados.last()).vr_nrctremp := 3142973;
    v_dados(v_dados.last()).vr_vllanmto := 6159.09;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10338306;
    v_dados(v_dados.last()).vr_nrctremp := 3042647;
    v_dados(v_dados.last()).vr_vllanmto := 1390.59;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12319090;
    v_dados(v_dados.last()).vr_nrctremp := 3515151;
    v_dados(v_dados.last()).vr_vllanmto := 1345.92;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12166103;
    v_dados(v_dados.last()).vr_nrctremp := 3369926;
    v_dados(v_dados.last()).vr_vllanmto := 2295.41;
    v_dados(v_dados.last()).vr_cdhistor := 1040;


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
