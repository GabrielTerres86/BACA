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
    v_dados(v_dados.last()).vr_vllanmto := 5070.42;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 68039;
    v_dados(v_dados.last()).vr_nrctremp := 51124;
    v_dados(v_dados.last()).vr_vllanmto := 42.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 384461;
    v_dados(v_dados.last()).vr_nrctremp := 51220;
    v_dados(v_dados.last()).vr_vllanmto := 161.73;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 93289;
    v_dados(v_dados.last()).vr_nrctremp := 51375;
    v_dados(v_dados.last()).vr_vllanmto := 228.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 386545;
    v_dados(v_dados.last()).vr_nrctremp := 51508;
    v_dados(v_dados.last()).vr_vllanmto := 181.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138207;
    v_dados(v_dados.last()).vr_nrctremp := 51622;
    v_dados(v_dados.last()).vr_vllanmto := 211.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 84085;
    v_dados(v_dados.last()).vr_nrctremp := 51903;
    v_dados(v_dados.last()).vr_vllanmto := 234.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 379301;
    v_dados(v_dados.last()).vr_nrctremp := 52196;
    v_dados(v_dados.last()).vr_vllanmto := 90.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192929;
    v_dados(v_dados.last()).vr_nrctremp := 52884;
    v_dados(v_dados.last()).vr_vllanmto := 49.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 53200;
    v_dados(v_dados.last()).vr_vllanmto := 54.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 182702;
    v_dados(v_dados.last()).vr_nrctremp := 53514;
    v_dados(v_dados.last()).vr_vllanmto := 112.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 53589;
    v_dados(v_dados.last()).vr_vllanmto := 13640.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 271276;
    v_dados(v_dados.last()).vr_nrctremp := 53665;
    v_dados(v_dados.last()).vr_vllanmto := 62.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419869;
    v_dados(v_dados.last()).vr_nrctremp := 55947;
    v_dados(v_dados.last()).vr_vllanmto := 116.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288640;
    v_dados(v_dados.last()).vr_nrctremp := 55992;
    v_dados(v_dados.last()).vr_vllanmto := 10.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 421200;
    v_dados(v_dados.last()).vr_nrctremp := 56187;
    v_dados(v_dados.last()).vr_vllanmto := 119.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 100161;
    v_dados(v_dados.last()).vr_nrctremp := 56319;
    v_dados(v_dados.last()).vr_vllanmto := 37.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 326941;
    v_dados(v_dados.last()).vr_nrctremp := 56659;
    v_dados(v_dados.last()).vr_vllanmto := 230.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187194;
    v_dados(v_dados.last()).vr_nrctremp := 56891;
    v_dados(v_dados.last()).vr_vllanmto := 86.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267015;
    v_dados(v_dados.last()).vr_nrctremp := 57081;
    v_dados(v_dados.last()).vr_vllanmto := 75.43;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 323292;
    v_dados(v_dados.last()).vr_nrctremp := 57149;
    v_dados(v_dados.last()).vr_vllanmto := 266.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 223913;
    v_dados(v_dados.last()).vr_nrctremp := 57290;
    v_dados(v_dados.last()).vr_vllanmto := 547.2;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92690;
    v_dados(v_dados.last()).vr_nrctremp := 58634;
    v_dados(v_dados.last()).vr_vllanmto := 75.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150304;
    v_dados(v_dados.last()).vr_nrctremp := 59164;
    v_dados(v_dados.last()).vr_vllanmto := 80.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 59689;
    v_dados(v_dados.last()).vr_vllanmto := 48.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149322;
    v_dados(v_dados.last()).vr_nrctremp := 59821;
    v_dados(v_dados.last()).vr_vllanmto := 175.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170453;
    v_dados(v_dados.last()).vr_nrctremp := 59887;
    v_dados(v_dados.last()).vr_vllanmto := 4.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 265187;
    v_dados(v_dados.last()).vr_nrctremp := 60113;
    v_dados(v_dados.last()).vr_vllanmto := 4.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26590;
    v_dados(v_dados.last()).vr_nrctremp := 61342;
    v_dados(v_dados.last()).vr_vllanmto := 114.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161667;
    v_dados(v_dados.last()).vr_nrctremp := 62065;
    v_dados(v_dados.last()).vr_vllanmto := 18.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138231;
    v_dados(v_dados.last()).vr_nrctremp := 63482;
    v_dados(v_dados.last()).vr_vllanmto := 758.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186805;
    v_dados(v_dados.last()).vr_nrctremp := 63844;
    v_dados(v_dados.last()).vr_vllanmto := 119.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185957;
    v_dados(v_dados.last()).vr_nrctremp := 64228;
    v_dados(v_dados.last()).vr_vllanmto := 232.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 382981;
    v_dados(v_dados.last()).vr_nrctremp := 64450;
    v_dados(v_dados.last()).vr_vllanmto := 22.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 64834;
    v_dados(v_dados.last()).vr_vllanmto := 554.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292770;
    v_dados(v_dados.last()).vr_nrctremp := 65537;
    v_dados(v_dados.last()).vr_vllanmto := 1983.79;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91227;
    v_dados(v_dados.last()).vr_nrctremp := 66497;
    v_dados(v_dados.last()).vr_vllanmto := 2489.19;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 452211;
    v_dados(v_dados.last()).vr_nrctremp := 66716;
    v_dados(v_dados.last()).vr_vllanmto := 127.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156850;
    v_dados(v_dados.last()).vr_nrctremp := 67072;
    v_dados(v_dados.last()).vr_vllanmto := 34.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116530;
    v_dados(v_dados.last()).vr_nrctremp := 67611;
    v_dados(v_dados.last()).vr_vllanmto := 441.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445347;
    v_dados(v_dados.last()).vr_nrctremp := 68188;
    v_dados(v_dados.last()).vr_vllanmto := 56.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95532;
    v_dados(v_dados.last()).vr_nrctremp := 68569;
    v_dados(v_dados.last()).vr_vllanmto := 74.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 178896;
    v_dados(v_dados.last()).vr_nrctremp := 71105;
    v_dados(v_dados.last()).vr_vllanmto := 34.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151394;
    v_dados(v_dados.last()).vr_nrctremp := 71606;
    v_dados(v_dados.last()).vr_vllanmto := 79.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78727;
    v_dados(v_dados.last()).vr_nrctremp := 71631;
    v_dados(v_dados.last()).vr_vllanmto := 219.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 277568;
    v_dados(v_dados.last()).vr_nrctremp := 71879;
    v_dados(v_dados.last()).vr_vllanmto := 25.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 26670;
    v_dados(v_dados.last()).vr_nrctremp := 73346;
    v_dados(v_dados.last()).vr_vllanmto := 125.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 73958;
    v_dados(v_dados.last()).vr_vllanmto := 83.81;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 466026;
    v_dados(v_dados.last()).vr_nrctremp := 74654;
    v_dados(v_dados.last()).vr_vllanmto := 49.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 408042;
    v_dados(v_dados.last()).vr_nrctremp := 74837;
    v_dados(v_dados.last()).vr_vllanmto := 62.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 75102;
    v_dados(v_dados.last()).vr_vllanmto := 105.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 152960;
    v_dados(v_dados.last()).vr_nrctremp := 75349;
    v_dados(v_dados.last()).vr_vllanmto := 20.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 316776;
    v_dados(v_dados.last()).vr_nrctremp := 78219;
    v_dados(v_dados.last()).vr_vllanmto := 224.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 78319;
    v_dados(v_dados.last()).vr_vllanmto := 630.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 483320;
    v_dados(v_dados.last()).vr_nrctremp := 78389;
    v_dados(v_dados.last()).vr_vllanmto := 27.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186139;
    v_dados(v_dados.last()).vr_nrctremp := 79508;
    v_dados(v_dados.last()).vr_vllanmto := 33.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94692;
    v_dados(v_dados.last()).vr_nrctremp := 79826;
    v_dados(v_dados.last()).vr_vllanmto := 124.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80361;
    v_dados(v_dados.last()).vr_vllanmto := 23.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188662;
    v_dados(v_dados.last()).vr_nrctremp := 80612;
    v_dados(v_dados.last()).vr_vllanmto := 14.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 155578;
    v_dados(v_dados.last()).vr_nrctremp := 80740;
    v_dados(v_dados.last()).vr_vllanmto := 14.82;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288241;
    v_dados(v_dados.last()).vr_nrctremp := 83070;
    v_dados(v_dados.last()).vr_vllanmto := 76.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83766;
    v_dados(v_dados.last()).vr_vllanmto := 123.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179922;
    v_dados(v_dados.last()).vr_nrctremp := 83772;
    v_dados(v_dados.last()).vr_vllanmto := 18.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 170097;
    v_dados(v_dados.last()).vr_nrctremp := 84009;
    v_dados(v_dados.last()).vr_vllanmto := 39.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 22560;
    v_dados(v_dados.last()).vr_nrctremp := 84128;
    v_dados(v_dados.last()).vr_vllanmto := 3276.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 375160;
    v_dados(v_dados.last()).vr_nrctremp := 85045;
    v_dados(v_dados.last()).vr_vllanmto := 6.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 85063;
    v_dados(v_dados.last()).vr_vllanmto := 62.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 419206;
    v_dados(v_dados.last()).vr_nrctremp := 85355;
    v_dados(v_dados.last()).vr_vllanmto := 27.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153605;
    v_dados(v_dados.last()).vr_nrctremp := 85830;
    v_dados(v_dados.last()).vr_vllanmto := 81.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 59382;
    v_dados(v_dados.last()).vr_nrctremp := 86033;
    v_dados(v_dados.last()).vr_vllanmto := 18.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 86810;
    v_dados(v_dados.last()).vr_vllanmto := 143.63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 65692;
    v_dados(v_dados.last()).vr_nrctremp := 87320;
    v_dados(v_dados.last()).vr_vllanmto := 131.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192902;
    v_dados(v_dados.last()).vr_nrctremp := 87507;
    v_dados(v_dados.last()).vr_vllanmto := 169.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137812;
    v_dados(v_dados.last()).vr_nrctremp := 87898;
    v_dados(v_dados.last()).vr_vllanmto := 55.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266450;
    v_dados(v_dados.last()).vr_nrctremp := 87972;
    v_dados(v_dados.last()).vr_vllanmto := 49.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149039;
    v_dados(v_dados.last()).vr_nrctremp := 88625;
    v_dados(v_dados.last()).vr_vllanmto := 67.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 89779;
    v_dados(v_dados.last()).vr_vllanmto := 2331.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 127809;
    v_dados(v_dados.last()).vr_nrctremp := 90393;
    v_dados(v_dados.last()).vr_vllanmto := 302.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188620;
    v_dados(v_dados.last()).vr_nrctremp := 90707;
    v_dados(v_dados.last()).vr_vllanmto := 125.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 132187;
    v_dados(v_dados.last()).vr_nrctremp := 91180;
    v_dados(v_dados.last()).vr_vllanmto := 48.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 193518;
    v_dados(v_dados.last()).vr_nrctremp := 91698;
    v_dados(v_dados.last()).vr_vllanmto := 95.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139629;
    v_dados(v_dados.last()).vr_nrctremp := 91932;
    v_dados(v_dados.last()).vr_vllanmto := 40.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 92218;
    v_dados(v_dados.last()).vr_vllanmto := 528.29;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 168491;
    v_dados(v_dados.last()).vr_nrctremp := 92472;
    v_dados(v_dados.last()).vr_vllanmto := 87.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 521140;
    v_dados(v_dados.last()).vr_nrctremp := 92843;
    v_dados(v_dados.last()).vr_vllanmto := 60.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 186902;
    v_dados(v_dados.last()).vr_nrctremp := 92977;
    v_dados(v_dados.last()).vr_vllanmto := 80.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287024;
    v_dados(v_dados.last()).vr_nrctremp := 94244;
    v_dados(v_dados.last()).vr_vllanmto := 44.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 173754;
    v_dados(v_dados.last()).vr_nrctremp := 94320;
    v_dados(v_dados.last()).vr_vllanmto := 68.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524310;
    v_dados(v_dados.last()).vr_nrctremp := 94882;
    v_dados(v_dados.last()).vr_vllanmto := 62.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143030;
    v_dados(v_dados.last()).vr_nrctremp := 94999;
    v_dados(v_dados.last()).vr_vllanmto := 43.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 524905;
    v_dados(v_dados.last()).vr_nrctremp := 95213;
    v_dados(v_dados.last()).vr_vllanmto := 417.73;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139505;
    v_dados(v_dados.last()).vr_nrctremp := 95415;
    v_dados(v_dados.last()).vr_vllanmto := 128.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154520;
    v_dados(v_dados.last()).vr_nrctremp := 96390;
    v_dados(v_dados.last()).vr_vllanmto := 321.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192503;
    v_dados(v_dados.last()).vr_nrctremp := 96427;
    v_dados(v_dados.last()).vr_vllanmto := 8.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146625;
    v_dados(v_dados.last()).vr_nrctremp := 96582;
    v_dados(v_dados.last()).vr_vllanmto := 24.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270466;
    v_dados(v_dados.last()).vr_nrctremp := 96648;
    v_dados(v_dados.last()).vr_vllanmto := 133.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 256013;
    v_dados(v_dados.last()).vr_nrctremp := 96840;
    v_dados(v_dados.last()).vr_vllanmto := 1605.81;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 97211;
    v_dados(v_dados.last()).vr_vllanmto := 209.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 88480;
    v_dados(v_dados.last()).vr_nrctremp := 97562;
    v_dados(v_dados.last()).vr_vllanmto := 36.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 64955;
    v_dados(v_dados.last()).vr_nrctremp := 98020;
    v_dados(v_dados.last()).vr_vllanmto := 77.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 532940;
    v_dados(v_dados.last()).vr_nrctremp := 98825;
    v_dados(v_dados.last()).vr_vllanmto := 87.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 201308;
    v_dados(v_dados.last()).vr_nrctremp := 99812;
    v_dados(v_dados.last()).vr_vllanmto := 57.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 99991;
    v_dados(v_dados.last()).vr_vllanmto := 14385.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 214450;
    v_dados(v_dados.last()).vr_nrctremp := 100349;
    v_dados(v_dados.last()).vr_vllanmto := 81.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 601063;
    v_dados(v_dados.last()).vr_nrctremp := 101565;
    v_dados(v_dados.last()).vr_vllanmto := 14.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187372;
    v_dados(v_dados.last()).vr_nrctremp := 102721;
    v_dados(v_dados.last()).vr_vllanmto := 21.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 284220;
    v_dados(v_dados.last()).vr_nrctremp := 102835;
    v_dados(v_dados.last()).vr_vllanmto := 117.01;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188123;
    v_dados(v_dados.last()).vr_nrctremp := 102857;
    v_dados(v_dados.last()).vr_vllanmto := 1020.37;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541036;
    v_dados(v_dados.last()).vr_nrctremp := 103157;
    v_dados(v_dados.last()).vr_vllanmto := 629.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202576;
    v_dados(v_dados.last()).vr_nrctremp := 104041;
    v_dados(v_dados.last()).vr_vllanmto := 88.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 120618;
    v_dados(v_dados.last()).vr_nrctremp := 104378;
    v_dados(v_dados.last()).vr_vllanmto := 2055.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544809;
    v_dados(v_dados.last()).vr_nrctremp := 104688;
    v_dados(v_dados.last()).vr_vllanmto := 20.41;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 545805;
    v_dados(v_dados.last()).vr_nrctremp := 105319;
    v_dados(v_dados.last()).vr_vllanmto := 67.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 207144;
    v_dados(v_dados.last()).vr_nrctremp := 105430;
    v_dados(v_dados.last()).vr_vllanmto := 12.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331490;
    v_dados(v_dados.last()).vr_nrctremp := 105708;
    v_dados(v_dados.last()).vr_vllanmto := 56.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 304778;
    v_dados(v_dados.last()).vr_nrctremp := 106301;
    v_dados(v_dados.last()).vr_vllanmto := 10.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 270075;
    v_dados(v_dados.last()).vr_nrctremp := 106404;
    v_dados(v_dados.last()).vr_vllanmto := 42.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548685;
    v_dados(v_dados.last()).vr_nrctremp := 107679;
    v_dados(v_dados.last()).vr_vllanmto := 32.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 108448;
    v_dados(v_dados.last()).vr_vllanmto := 1627.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 108966;
    v_dados(v_dados.last()).vr_vllanmto := 585.93;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105295;
    v_dados(v_dados.last()).vr_nrctremp := 109809;
    v_dados(v_dados.last()).vr_vllanmto := 33.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 553905;
    v_dados(v_dados.last()).vr_nrctremp := 110020;
    v_dados(v_dados.last()).vr_vllanmto := 25.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163872;
    v_dados(v_dados.last()).vr_nrctremp := 110555;
    v_dados(v_dados.last()).vr_vllanmto := 82.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160318;
    v_dados(v_dados.last()).vr_nrctremp := 110736;
    v_dados(v_dados.last()).vr_vllanmto := 13.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 110909;
    v_dados(v_dados.last()).vr_vllanmto := 22.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 557153;
    v_dados(v_dados.last()).vr_nrctremp := 111077;
    v_dados(v_dados.last()).vr_vllanmto := 46.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172871;
    v_dados(v_dados.last()).vr_nrctremp := 112049;
    v_dados(v_dados.last()).vr_vllanmto := 11.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 391549;
    v_dados(v_dados.last()).vr_nrctremp := 112758;
    v_dados(v_dados.last()).vr_vllanmto := 15.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192228;
    v_dados(v_dados.last()).vr_nrctremp := 112938;
    v_dados(v_dados.last()).vr_vllanmto := 17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 113777;
    v_dados(v_dados.last()).vr_vllanmto := 46.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95257;
    v_dados(v_dados.last()).vr_nrctremp := 114045;
    v_dados(v_dados.last()).vr_vllanmto := 70.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 447510;
    v_dados(v_dados.last()).vr_nrctremp := 114640;
    v_dados(v_dados.last()).vr_vllanmto := 52.06;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 136956;
    v_dados(v_dados.last()).vr_nrctremp := 115239;
    v_dados(v_dados.last()).vr_vllanmto := 57.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 318612;
    v_dados(v_dados.last()).vr_nrctremp := 115869;
    v_dados(v_dados.last()).vr_vllanmto := 70.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 224162;
    v_dados(v_dados.last()).vr_nrctremp := 116605;
    v_dados(v_dados.last()).vr_vllanmto := 7.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 179043;
    v_dados(v_dados.last()).vr_nrctremp := 117292;
    v_dados(v_dados.last()).vr_vllanmto := 6.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 272361;
    v_dados(v_dados.last()).vr_nrctremp := 117990;
    v_dados(v_dados.last()).vr_vllanmto := 19.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 571628;
    v_dados(v_dados.last()).vr_nrctremp := 118254;
    v_dados(v_dados.last()).vr_vllanmto := 2.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 279714;
    v_dados(v_dados.last()).vr_nrctremp := 118764;
    v_dados(v_dados.last()).vr_vllanmto := 9.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 95400;
    v_dados(v_dados.last()).vr_nrctremp := 118820;
    v_dados(v_dados.last()).vr_vllanmto := 46.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 387746;
    v_dados(v_dados.last()).vr_nrctremp := 119046;
    v_dados(v_dados.last()).vr_vllanmto := 21.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 119113;
    v_dados(v_dados.last()).vr_vllanmto := 388.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 119334;
    v_dados(v_dados.last()).vr_vllanmto := 13.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247642;
    v_dados(v_dados.last()).vr_nrctremp := 121365;
    v_dados(v_dados.last()).vr_vllanmto := 45.57;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 578509;
    v_dados(v_dados.last()).vr_nrctremp := 123053;
    v_dados(v_dados.last()).vr_vllanmto := 110.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 301469;
    v_dados(v_dados.last()).vr_nrctremp := 123630;
    v_dados(v_dados.last()).vr_vllanmto := 46.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92029;
    v_dados(v_dados.last()).vr_nrctremp := 123921;
    v_dados(v_dados.last()).vr_vllanmto := 97.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171921;
    v_dados(v_dados.last()).vr_nrctremp := 124334;
    v_dados(v_dados.last()).vr_vllanmto := 15.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131792;
    v_dados(v_dados.last()).vr_nrctremp := 125819;
    v_dados(v_dados.last()).vr_vllanmto := 60.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 125901;
    v_dados(v_dados.last()).vr_vllanmto := 213.96;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 349798;
    v_dados(v_dados.last()).vr_nrctremp := 127767;
    v_dados(v_dados.last()).vr_vllanmto := 56.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 247596;
    v_dados(v_dados.last()).vr_nrctremp := 128314;
    v_dados(v_dados.last()).vr_vllanmto := 8.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146471;
    v_dados(v_dados.last()).vr_nrctremp := 129089;
    v_dados(v_dados.last()).vr_vllanmto := 17.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 392413;
    v_dados(v_dados.last()).vr_nrctremp := 129492;
    v_dados(v_dados.last()).vr_vllanmto := 19.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129690;
    v_dados(v_dados.last()).vr_vllanmto := 80.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190357;
    v_dados(v_dados.last()).vr_nrctremp := 129693;
    v_dados(v_dados.last()).vr_vllanmto := 19.44;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561860;
    v_dados(v_dados.last()).vr_nrctremp := 129804;
    v_dados(v_dados.last()).vr_vllanmto := 18.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 242985;
    v_dados(v_dados.last()).vr_nrctremp := 132628;
    v_dados(v_dados.last()).vr_vllanmto := 18.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 584959;
    v_dados(v_dados.last()).vr_nrctremp := 132748;
    v_dados(v_dados.last()).vr_vllanmto := 26.17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240133;
    v_dados(v_dados.last()).vr_nrctremp := 132847;
    v_dados(v_dados.last()).vr_vllanmto := 56.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 133121;
    v_dados(v_dados.last()).vr_vllanmto := 173.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149632;
    v_dados(v_dados.last()).vr_nrctremp := 133556;
    v_dados(v_dados.last()).vr_vllanmto := 46.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 150991;
    v_dados(v_dados.last()).vr_nrctremp := 133605;
    v_dados(v_dados.last()).vr_vllanmto := 52.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 325791;
    v_dados(v_dados.last()).vr_nrctremp := 134294;
    v_dados(v_dados.last()).vr_vllanmto := .19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267023;
    v_dados(v_dados.last()).vr_nrctremp := 134311;
    v_dados(v_dados.last()).vr_vllanmto := 8.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 103861;
    v_dados(v_dados.last()).vr_nrctremp := 134554;
    v_dados(v_dados.last()).vr_vllanmto := 67.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 561142;
    v_dados(v_dados.last()).vr_nrctremp := 134641;
    v_dados(v_dados.last()).vr_vllanmto := 11.25;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 479276;
    v_dados(v_dados.last()).vr_nrctremp := 135085;
    v_dados(v_dados.last()).vr_vllanmto := 15.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 487090;
    v_dados(v_dados.last()).vr_nrctremp := 135114;
    v_dados(v_dados.last()).vr_vllanmto := 27.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 231592;
    v_dados(v_dados.last()).vr_nrctremp := 135397;
    v_dados(v_dados.last()).vr_vllanmto := 7.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273724;
    v_dados(v_dados.last()).vr_nrctremp := 135478;
    v_dados(v_dados.last()).vr_vllanmto := .86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135768;
    v_dados(v_dados.last()).vr_vllanmto := 94.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 153397;
    v_dados(v_dados.last()).vr_nrctremp := 135769;
    v_dados(v_dados.last()).vr_vllanmto := 17.42;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 161640;
    v_dados(v_dados.last()).vr_nrctremp := 136155;
    v_dados(v_dados.last()).vr_vllanmto := 32.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 136699;
    v_dados(v_dados.last()).vr_vllanmto := .66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 570001;
    v_dados(v_dados.last()).vr_nrctremp := 136709;
    v_dados(v_dados.last()).vr_vllanmto := 100.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 455849;
    v_dados(v_dados.last()).vr_nrctremp := 136760;
    v_dados(v_dados.last()).vr_vllanmto := 132.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184586;
    v_dados(v_dados.last()).vr_nrctremp := 136806;
    v_dados(v_dados.last()).vr_vllanmto := 52.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 94722;
    v_dados(v_dados.last()).vr_nrctremp := 137035;
    v_dados(v_dados.last()).vr_vllanmto := 62.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 131091;
    v_dados(v_dados.last()).vr_nrctremp := 137047;
    v_dados(v_dados.last()).vr_vllanmto := 1106.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 147990;
    v_dados(v_dados.last()).vr_nrctremp := 137561;
    v_dados(v_dados.last()).vr_vllanmto := 20.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 138194;
    v_dados(v_dados.last()).vr_vllanmto := 109.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 138280;
    v_dados(v_dados.last()).vr_vllanmto := 219.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66800;
    v_dados(v_dados.last()).vr_nrctremp := 138302;
    v_dados(v_dados.last()).vr_vllanmto := 82.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 609447;
    v_dados(v_dados.last()).vr_nrctremp := 139009;
    v_dados(v_dados.last()).vr_vllanmto := 34.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 139843;
    v_dados(v_dados.last()).vr_vllanmto := 27.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171824;
    v_dados(v_dados.last()).vr_nrctremp := 142019;
    v_dados(v_dados.last()).vr_vllanmto := 21.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 264920;
    v_dados(v_dados.last()).vr_nrctremp := 142242;
    v_dados(v_dados.last()).vr_vllanmto := 31.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 80349;
    v_dados(v_dados.last()).vr_nrctremp := 142392;
    v_dados(v_dados.last()).vr_vllanmto := 21.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66940;
    v_dados(v_dados.last()).vr_nrctremp := 142854;
    v_dados(v_dados.last()).vr_vllanmto := 672.61;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143928;
    v_dados(v_dados.last()).vr_nrctremp := 143898;
    v_dados(v_dados.last()).vr_vllanmto := 5.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190985;
    v_dados(v_dados.last()).vr_nrctremp := 144153;
    v_dados(v_dados.last()).vr_vllanmto := 32.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534013;
    v_dados(v_dados.last()).vr_nrctremp := 145861;
    v_dados(v_dados.last()).vr_vllanmto := 25.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187860;
    v_dados(v_dados.last()).vr_nrctremp := 146397;
    v_dados(v_dados.last()).vr_vllanmto := 5.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240389;
    v_dados(v_dados.last()).vr_nrctremp := 147131;
    v_dados(v_dados.last()).vr_vllanmto := 3.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146153;
    v_dados(v_dados.last()).vr_nrctremp := 147274;
    v_dados(v_dados.last()).vr_vllanmto := 32.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185876;
    v_dados(v_dados.last()).vr_nrctremp := 147388;
    v_dados(v_dados.last()).vr_vllanmto := 157.43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 147569;
    v_dados(v_dados.last()).vr_vllanmto := 93.72;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188557;
    v_dados(v_dados.last()).vr_nrctremp := 148101;
    v_dados(v_dados.last()).vr_vllanmto := 16.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141496;
    v_dados(v_dados.last()).vr_nrctremp := 148322;
    v_dados(v_dados.last()).vr_vllanmto := 1.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187984;
    v_dados(v_dados.last()).vr_nrctremp := 148826;
    v_dados(v_dados.last()).vr_vllanmto := 5.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 25887;
    v_dados(v_dados.last()).vr_nrctremp := 148839;
    v_dados(v_dados.last()).vr_vllanmto := 32.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 641790;
    v_dados(v_dados.last()).vr_nrctremp := 148852;
    v_dados(v_dados.last()).vr_vllanmto := 36.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 213578;
    v_dados(v_dados.last()).vr_nrctremp := 149465;
    v_dados(v_dados.last()).vr_vllanmto := 9.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149927;
    v_dados(v_dados.last()).vr_vllanmto := 186.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 266744;
    v_dados(v_dados.last()).vr_nrctremp := 149931;
    v_dados(v_dados.last()).vr_vllanmto := 33.38;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66605;
    v_dados(v_dados.last()).vr_nrctremp := 150339;
    v_dados(v_dados.last()).vr_vllanmto := 98.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 292303;
    v_dados(v_dados.last()).vr_nrctremp := 150969;
    v_dados(v_dados.last()).vr_vllanmto := 19.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172448;
    v_dados(v_dados.last()).vr_nrctremp := 151455;
    v_dados(v_dados.last()).vr_vllanmto := 3.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 649899;
    v_dados(v_dados.last()).vr_nrctremp := 153142;
    v_dados(v_dados.last()).vr_vllanmto := 36.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 109428;
    v_dados(v_dados.last()).vr_nrctremp := 154257;
    v_dados(v_dados.last()).vr_vllanmto := 32.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 249505;
    v_dados(v_dados.last()).vr_nrctremp := 155016;
    v_dados(v_dados.last()).vr_vllanmto := 10.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 160431;
    v_dados(v_dados.last()).vr_nrctremp := 155420;
    v_dados(v_dados.last()).vr_vllanmto := 11.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 151980;
    v_dados(v_dados.last()).vr_nrctremp := 155930;
    v_dados(v_dados.last()).vr_vllanmto := 197.36;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 156022;
    v_dados(v_dados.last()).vr_vllanmto := 3.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 444057;
    v_dados(v_dados.last()).vr_nrctremp := 156882;
    v_dados(v_dados.last()).vr_vllanmto := 15.58;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129410;
    v_dados(v_dados.last()).vr_nrctremp := 158870;
    v_dados(v_dados.last()).vr_vllanmto := 104.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287806;
    v_dados(v_dados.last()).vr_nrctremp := 159595;
    v_dados(v_dados.last()).vr_vllanmto := 37.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647616;
    v_dados(v_dados.last()).vr_nrctremp := 159935;
    v_dados(v_dados.last()).vr_vllanmto := 6.13;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662569;
    v_dados(v_dados.last()).vr_nrctremp := 160854;
    v_dados(v_dados.last()).vr_vllanmto := 8.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 160976;
    v_dados(v_dados.last()).vr_vllanmto := 266.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 31275;
    v_dados(v_dados.last()).vr_nrctremp := 162267;
    v_dados(v_dados.last()).vr_vllanmto := 37.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 202657;
    v_dados(v_dados.last()).vr_nrctremp := 163091;
    v_dados(v_dados.last()).vr_vllanmto := 16.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 413607;
    v_dados(v_dados.last()).vr_nrctremp := 163237;
    v_dados(v_dados.last()).vr_vllanmto := 17.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 662380;
    v_dados(v_dados.last()).vr_nrctremp := 163482;
    v_dados(v_dados.last()).vr_vllanmto := 115.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 102822;
    v_dados(v_dados.last()).vr_nrctremp := 163575;
    v_dados(v_dados.last()).vr_vllanmto := 19.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 163884;
    v_dados(v_dados.last()).vr_vllanmto := 2.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 164001;
    v_dados(v_dados.last()).vr_vllanmto := 7899.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 191434;
    v_dados(v_dados.last()).vr_nrctremp := 164271;
    v_dados(v_dados.last()).vr_vllanmto := 51.73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 137804;
    v_dados(v_dados.last()).vr_nrctremp := 164345;
    v_dados(v_dados.last()).vr_vllanmto := 15.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199788;
    v_dados(v_dados.last()).vr_nrctremp := 164878;
    v_dados(v_dados.last()).vr_vllanmto := 49.99;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 117048;
    v_dados(v_dados.last()).vr_nrctremp := 164922;
    v_dados(v_dados.last()).vr_vllanmto := 1721.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 289094;
    v_dados(v_dados.last()).vr_nrctremp := 164930;
    v_dados(v_dados.last()).vr_vllanmto := 197.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 507210;
    v_dados(v_dados.last()).vr_nrctremp := 165366;
    v_dados(v_dados.last()).vr_vllanmto := 1.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 258636;
    v_dados(v_dados.last()).vr_nrctremp := 165420;
    v_dados(v_dados.last()).vr_vllanmto := 14.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9482;
    v_dados(v_dados.last()).vr_nrctremp := 166510;
    v_dados(v_dados.last()).vr_vllanmto := 41.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 582042;
    v_dados(v_dados.last()).vr_nrctremp := 166819;
    v_dados(v_dados.last()).vr_vllanmto := 40.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 390402;
    v_dados(v_dados.last()).vr_nrctremp := 166820;
    v_dados(v_dados.last()).vr_vllanmto := 67.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 167151;
    v_dados(v_dados.last()).vr_vllanmto := 6.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 427420;
    v_dados(v_dados.last()).vr_nrctremp := 167789;
    v_dados(v_dados.last()).vr_vllanmto := 7.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 670324;
    v_dados(v_dados.last()).vr_nrctremp := 167935;
    v_dados(v_dados.last()).vr_vllanmto := 75.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 166472;
    v_dados(v_dados.last()).vr_nrctremp := 169114;
    v_dados(v_dados.last()).vr_vllanmto := 5.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192546;
    v_dados(v_dados.last()).vr_nrctremp := 169910;
    v_dados(v_dados.last()).vr_vllanmto := 9.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 9377;
    v_dados(v_dados.last()).vr_nrctremp := 170013;
    v_dados(v_dados.last()).vr_vllanmto := 4397.09;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92410;
    v_dados(v_dados.last()).vr_nrctremp := 170991;
    v_dados(v_dados.last()).vr_vllanmto := 67.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 330248;
    v_dados(v_dados.last()).vr_nrctremp := 172256;
    v_dados(v_dados.last()).vr_vllanmto := .5;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 320935;
    v_dados(v_dados.last()).vr_nrctremp := 172922;
    v_dados(v_dados.last()).vr_vllanmto := 19.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 396770;
    v_dados(v_dados.last()).vr_nrctremp := 174032;
    v_dados(v_dados.last()).vr_vllanmto := 12.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185930;
    v_dados(v_dados.last()).vr_nrctremp := 174443;
    v_dados(v_dados.last()).vr_vllanmto := 7.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 128333;
    v_dados(v_dados.last()).vr_nrctremp := 174807;
    v_dados(v_dados.last()).vr_vllanmto := 64.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 528234;
    v_dados(v_dados.last()).vr_nrctremp := 175474;
    v_dados(v_dados.last()).vr_vllanmto := 17.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192694;
    v_dados(v_dados.last()).vr_nrctremp := 175750;
    v_dados(v_dados.last()).vr_vllanmto := 6.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184470;
    v_dados(v_dados.last()).vr_nrctremp := 175964;
    v_dados(v_dados.last()).vr_vllanmto := 12.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92290;
    v_dados(v_dados.last()).vr_nrctremp := 176032;
    v_dados(v_dados.last()).vr_vllanmto := 14.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 240273;
    v_dados(v_dados.last()).vr_nrctremp := 176388;
    v_dados(v_dados.last()).vr_vllanmto := 9.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 199770;
    v_dados(v_dados.last()).vr_nrctremp := 176779;
    v_dados(v_dados.last()).vr_vllanmto := 36.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188433;
    v_dados(v_dados.last()).vr_nrctremp := 176875;
    v_dados(v_dados.last()).vr_vllanmto := 39.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 177334;
    v_dados(v_dados.last()).vr_vllanmto := 1.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 331317;
    v_dados(v_dados.last()).vr_nrctremp := 178836;
    v_dados(v_dados.last()).vr_vllanmto := 68.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 416606;
    v_dados(v_dados.last()).vr_nrctremp := 179261;
    v_dados(v_dados.last()).vr_vllanmto := 17.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 90891;
    v_dados(v_dados.last()).vr_nrctremp := 179280;
    v_dados(v_dados.last()).vr_vllanmto := 23.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 156680;
    v_dados(v_dados.last()).vr_nrctremp := 179391;
    v_dados(v_dados.last()).vr_vllanmto := 20.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 369845;
    v_dados(v_dados.last()).vr_nrctremp := 179448;
    v_dados(v_dados.last()).vr_vllanmto := 79.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144843;
    v_dados(v_dados.last()).vr_nrctremp := 179507;
    v_dados(v_dados.last()).vr_vllanmto := 1.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66672;
    v_dados(v_dados.last()).vr_nrctremp := 179795;
    v_dados(v_dados.last()).vr_vllanmto := 41.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 407003;
    v_dados(v_dados.last()).vr_nrctremp := 180030;
    v_dados(v_dados.last()).vr_vllanmto := 6.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 210960;
    v_dados(v_dados.last()).vr_nrctremp := 180317;
    v_dados(v_dados.last()).vr_vllanmto := 83.64;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 92630;
    v_dados(v_dados.last()).vr_nrctremp := 182139;
    v_dados(v_dados.last()).vr_vllanmto := 24.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 172626;
    v_dados(v_dados.last()).vr_nrctremp := 182237;
    v_dados(v_dados.last()).vr_vllanmto := 8.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 218847;
    v_dados(v_dados.last()).vr_nrctremp := 182279;
    v_dados(v_dados.last()).vr_vllanmto := 9.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66923;
    v_dados(v_dados.last()).vr_nrctremp := 184535;
    v_dados(v_dados.last()).vr_vllanmto := 27.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 699527;
    v_dados(v_dados.last()).vr_nrctremp := 184840;
    v_dados(v_dados.last()).vr_vllanmto := .61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 280836;
    v_dados(v_dados.last()).vr_nrctremp := 184891;
    v_dados(v_dados.last()).vr_vllanmto := .63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187429;
    v_dados(v_dados.last()).vr_nrctremp := 184919;
    v_dados(v_dados.last()).vr_vllanmto := 54.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145319;
    v_dados(v_dados.last()).vr_nrctremp := 185084;
    v_dados(v_dados.last()).vr_vllanmto := 1.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 267627;
    v_dados(v_dados.last()).vr_nrctremp := 185088;
    v_dados(v_dados.last()).vr_vllanmto := 2.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 493376;
    v_dados(v_dados.last()).vr_nrctremp := 185097;
    v_dados(v_dados.last()).vr_vllanmto := 2.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 317250;
    v_dados(v_dados.last()).vr_nrctremp := 185176;
    v_dados(v_dados.last()).vr_vllanmto := 2977.67;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 488100;
    v_dados(v_dados.last()).vr_nrctremp := 185705;
    v_dados(v_dados.last()).vr_vllanmto := 8.3;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 351881;
    v_dados(v_dados.last()).vr_nrctremp := 185810;
    v_dados(v_dados.last()).vr_vllanmto := 1.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 148164;
    v_dados(v_dados.last()).vr_nrctremp := 185898;
    v_dados(v_dados.last()).vr_vllanmto := 1.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 478512;
    v_dados(v_dados.last()).vr_nrctremp := 185911;
    v_dados(v_dados.last()).vr_vllanmto := .39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 484075;
    v_dados(v_dados.last()).vr_nrctremp := 185948;
    v_dados(v_dados.last()).vr_vllanmto := 10.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 395714;
    v_dados(v_dados.last()).vr_nrctremp := 185957;
    v_dados(v_dados.last()).vr_vllanmto := 20.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 287784;
    v_dados(v_dados.last()).vr_nrctremp := 186334;
    v_dados(v_dados.last()).vr_vllanmto := 1.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 462020;
    v_dados(v_dados.last()).vr_nrctremp := 186376;
    v_dados(v_dados.last()).vr_vllanmto := 1.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 186936;
    v_dados(v_dados.last()).vr_vllanmto := 292.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139025;
    v_dados(v_dados.last()).vr_nrctremp := 187057;
    v_dados(v_dados.last()).vr_vllanmto := 6.85;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 134910;
    v_dados(v_dados.last()).vr_nrctremp := 187662;
    v_dados(v_dados.last()).vr_vllanmto := 242.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184993;
    v_dados(v_dados.last()).vr_nrctremp := 187699;
    v_dados(v_dados.last()).vr_vllanmto := .87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 146218;
    v_dados(v_dados.last()).vr_nrctremp := 187720;
    v_dados(v_dados.last()).vr_vllanmto := 5423.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 526738;
    v_dados(v_dados.last()).vr_nrctremp := 189539;
    v_dados(v_dados.last()).vr_vllanmto := 12.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 295876;
    v_dados(v_dados.last()).vr_nrctremp := 189633;
    v_dados(v_dados.last()).vr_vllanmto := .39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 445916;
    v_dados(v_dados.last()).vr_nrctremp := 189820;
    v_dados(v_dados.last()).vr_vllanmto := .37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 290246;
    v_dados(v_dados.last()).vr_nrctremp := 190157;
    v_dados(v_dados.last()).vr_vllanmto := 1602.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 516902;
    v_dados(v_dados.last()).vr_nrctremp := 190439;
    v_dados(v_dados.last()).vr_vllanmto := 19.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 71730;
    v_dados(v_dados.last()).vr_nrctremp := 191099;
    v_dados(v_dados.last()).vr_vllanmto := 12.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 636673;
    v_dados(v_dados.last()).vr_nrctremp := 191259;
    v_dados(v_dados.last()).vr_vllanmto := 1.32;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647527;
    v_dados(v_dados.last()).vr_nrctremp := 191578;
    v_dados(v_dados.last()).vr_vllanmto := 20.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 608203;
    v_dados(v_dados.last()).vr_nrctremp := 192597;
    v_dados(v_dados.last()).vr_vllanmto := 14.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647845;
    v_dados(v_dados.last()).vr_nrctremp := 192882;
    v_dados(v_dados.last()).vr_vllanmto := 12.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 188336;
    v_dados(v_dados.last()).vr_nrctremp := 192883;
    v_dados(v_dados.last()).vr_vllanmto := 4.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 654485;
    v_dados(v_dados.last()).vr_nrctremp := 193159;
    v_dados(v_dados.last()).vr_vllanmto := 33.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 105015;
    v_dados(v_dados.last()).vr_nrctremp := 193497;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 425621;
    v_dados(v_dados.last()).vr_nrctremp := 193973;
    v_dados(v_dados.last()).vr_vllanmto := 15.2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 389552;
    v_dados(v_dados.last()).vr_nrctremp := 194086;
    v_dados(v_dados.last()).vr_vllanmto := 1241.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14516829;
    v_dados(v_dados.last()).vr_nrctremp := 194220;
    v_dados(v_dados.last()).vr_vllanmto := .19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14626705;
    v_dados(v_dados.last()).vr_nrctremp := 194258;
    v_dados(v_dados.last()).vr_vllanmto := .38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 189499;
    v_dados(v_dados.last()).vr_nrctremp := 194649;
    v_dados(v_dados.last()).vr_vllanmto := .2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 91936;
    v_dados(v_dados.last()).vr_nrctremp := 194880;
    v_dados(v_dados.last()).vr_vllanmto := 7.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116955;
    v_dados(v_dados.last()).vr_nrctremp := 195008;
    v_dados(v_dados.last()).vr_vllanmto := 11.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 184381;
    v_dados(v_dados.last()).vr_nrctremp := 195543;
    v_dados(v_dados.last()).vr_vllanmto := 19.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 298760;
    v_dados(v_dados.last()).vr_nrctremp := 196024;
    v_dados(v_dados.last()).vr_vllanmto := 11.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 625566;
    v_dados(v_dados.last()).vr_nrctremp := 196091;
    v_dados(v_dados.last()).vr_vllanmto := 23.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 647462;
    v_dados(v_dados.last()).vr_nrctremp := 196522;
    v_dados(v_dados.last()).vr_vllanmto := 706.44;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 596876;
    v_dados(v_dados.last()).vr_nrctremp := 196849;
    v_dados(v_dados.last()).vr_vllanmto := 15.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 116955;
    v_dados(v_dados.last()).vr_nrctremp := 197410;
    v_dados(v_dados.last()).vr_vllanmto := 11.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 273309;
    v_dados(v_dados.last()).vr_nrctremp := 197758;
    v_dados(v_dados.last()).vr_vllanmto := 5.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14531879;
    v_dados(v_dados.last()).vr_nrctremp := 197880;
    v_dados(v_dados.last()).vr_vllanmto := 12.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 65897;
    v_dados(v_dados.last()).vr_nrctremp := 197885;
    v_dados(v_dados.last()).vr_vllanmto := 20.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14723220;
    v_dados(v_dados.last()).vr_nrctremp := 198279;
    v_dados(v_dados.last()).vr_vllanmto := 1.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 288624;
    v_dados(v_dados.last()).vr_nrctremp := 198849;
    v_dados(v_dados.last()).vr_vllanmto := 14.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 190098;
    v_dados(v_dados.last()).vr_nrctremp := 199010;
    v_dados(v_dados.last()).vr_vllanmto := 23202.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 183334;
    v_dados(v_dados.last()).vr_nrctremp := 199073;
    v_dados(v_dados.last()).vr_vllanmto := .67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 163384;
    v_dados(v_dados.last()).vr_nrctremp := 199142;
    v_dados(v_dados.last()).vr_vllanmto := 12.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 577120;
    v_dados(v_dados.last()).vr_nrctremp := 199246;
    v_dados(v_dados.last()).vr_vllanmto := 4.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 692409;
    v_dados(v_dados.last()).vr_nrctremp := 199651;
    v_dados(v_dados.last()).vr_vllanmto := 8.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 335959;
    v_dados(v_dados.last()).vr_nrctremp := 200395;
    v_dados(v_dados.last()).vr_vllanmto := 11.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 408298;
    v_dados(v_dados.last()).vr_nrctremp := 200556;
    v_dados(v_dados.last()).vr_vllanmto := 9.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352624;
    v_dados(v_dados.last()).vr_nrctremp := 200841;
    v_dados(v_dados.last()).vr_vllanmto := 35.05;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322407;
    v_dados(v_dados.last()).vr_nrctremp := 201246;
    v_dados(v_dados.last()).vr_vllanmto := 1.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14719380;
    v_dados(v_dados.last()).vr_nrctremp := 201748;
    v_dados(v_dados.last()).vr_vllanmto := .85;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 352179;
    v_dados(v_dados.last()).vr_nrctremp := 201849;
    v_dados(v_dados.last()).vr_vllanmto := 1761.9;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 8222;
    v_dados(v_dados.last()).vr_nrctremp := 203419;
    v_dados(v_dados.last()).vr_vllanmto := 2.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 303348;
    v_dados(v_dados.last()).vr_nrctremp := 205922;
    v_dados(v_dados.last()).vr_vllanmto := 1.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 534633;
    v_dados(v_dados.last()).vr_nrctremp := 205949;
    v_dados(v_dados.last()).vr_vllanmto := .66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145637;
    v_dados(v_dados.last()).vr_nrctremp := 206068;
    v_dados(v_dados.last()).vr_vllanmto := 5.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 322369;
    v_dados(v_dados.last()).vr_nrctremp := 206130;
    v_dados(v_dados.last()).vr_vllanmto := 2.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 141275;
    v_dados(v_dados.last()).vr_nrctremp := 206153;
    v_dados(v_dados.last()).vr_vllanmto := 1.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 140856;
    v_dados(v_dados.last()).vr_nrctremp := 206169;
    v_dados(v_dados.last()).vr_vllanmto := 3.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14923807;
    v_dados(v_dados.last()).vr_nrctremp := 207282;
    v_dados(v_dados.last()).vr_vllanmto := .61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294519;
    v_dados(v_dados.last()).vr_nrctremp := 207368;
    v_dados(v_dados.last()).vr_vllanmto := 6.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 66613;
    v_dados(v_dados.last()).vr_nrctremp := 207517;
    v_dados(v_dados.last()).vr_vllanmto := 9.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 139874;
    v_dados(v_dados.last()).vr_nrctremp := 207742;
    v_dados(v_dados.last()).vr_vllanmto := 16.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 297313;
    v_dados(v_dados.last()).vr_nrctremp := 208259;
    v_dados(v_dados.last()).vr_vllanmto := .2;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 552488;
    v_dados(v_dados.last()).vr_nrctremp := 208642;
    v_dados(v_dados.last()).vr_vllanmto := 14.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187160;
    v_dados(v_dados.last()).vr_nrctremp := 208680;
    v_dados(v_dados.last()).vr_vllanmto := 22.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 480517;
    v_dados(v_dados.last()).vr_nrctremp := 209089;
    v_dados(v_dados.last()).vr_vllanmto := 2.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14967995;
    v_dados(v_dados.last()).vr_nrctremp := 209246;
    v_dados(v_dados.last()).vr_vllanmto := .53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 89842;
    v_dados(v_dados.last()).vr_nrctremp := 209320;
    v_dados(v_dados.last()).vr_vllanmto := 4.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 185760;
    v_dados(v_dados.last()).vr_nrctremp := 210457;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 171069;
    v_dados(v_dados.last()).vr_nrctremp := 210482;
    v_dados(v_dados.last()).vr_vllanmto := 1.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 144762;
    v_dados(v_dados.last()).vr_nrctremp := 210563;
    v_dados(v_dados.last()).vr_vllanmto := 6.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 517399;
    v_dados(v_dados.last()).vr_nrctremp := 210631;
    v_dados(v_dados.last()).vr_vllanmto := 3.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 187895;
    v_dados(v_dados.last()).vr_nrctremp := 211130;
    v_dados(v_dados.last()).vr_vllanmto := .65;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 138711;
    v_dados(v_dados.last()).vr_nrctremp := 211239;
    v_dados(v_dados.last()).vr_vllanmto := 7.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 14985780;
    v_dados(v_dados.last()).vr_nrctremp := 212408;
    v_dados(v_dados.last()).vr_vllanmto := 1.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 200395;
    v_dados(v_dados.last()).vr_nrctremp := 212424;
    v_dados(v_dados.last()).vr_vllanmto := 1.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 154130;
    v_dados(v_dados.last()).vr_nrctremp := 212429;
    v_dados(v_dados.last()).vr_vllanmto := .18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 652610;
    v_dados(v_dados.last()).vr_nrctremp := 212819;
    v_dados(v_dados.last()).vr_vllanmto := 2.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 129046;
    v_dados(v_dados.last()).vr_nrctremp := 212830;
    v_dados(v_dados.last()).vr_vllanmto := 3587.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 294691;
    v_dados(v_dados.last()).vr_nrctremp := 213808;
    v_dados(v_dados.last()).vr_vllanmto := 10.51;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 192350;
    v_dados(v_dados.last()).vr_nrctremp := 213885;
    v_dados(v_dados.last()).vr_vllanmto := 21.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 394025;
    v_dados(v_dados.last()).vr_nrctremp := 214397;
    v_dados(v_dados.last()).vr_vllanmto := 1.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 149535;
    v_dados(v_dados.last()).vr_nrctremp := 214746;
    v_dados(v_dados.last()).vr_vllanmto := 3.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 158518;
    v_dados(v_dados.last()).vr_nrctremp := 215328;
    v_dados(v_dados.last()).vr_vllanmto := .54;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426415;
    v_dados(v_dados.last()).vr_nrctremp := 215819;
    v_dados(v_dados.last()).vr_vllanmto := .63;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 541311;
    v_dados(v_dados.last()).vr_nrctremp := 216296;
    v_dados(v_dados.last()).vr_vllanmto := 3.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 263664;
    v_dados(v_dados.last()).vr_nrctremp := 216534;
    v_dados(v_dados.last()).vr_vllanmto := 1.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 485217;
    v_dados(v_dados.last()).vr_nrctremp := 216544;
    v_dados(v_dados.last()).vr_vllanmto := 19.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 18651;
    v_dados(v_dados.last()).vr_nrctremp := 216720;
    v_dados(v_dados.last()).vr_vllanmto := .86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 679933;
    v_dados(v_dados.last()).vr_nrctremp := 222286;
    v_dados(v_dados.last()).vr_vllanmto := 26.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 471828;
    v_dados(v_dados.last()).vr_nrctremp := 223818;
    v_dados(v_dados.last()).vr_vllanmto := .16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 495310;
    v_dados(v_dados.last()).vr_nrctremp := 224216;
    v_dados(v_dados.last()).vr_vllanmto := .12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 78638;
    v_dados(v_dados.last()).vr_nrctremp := 225615;
    v_dados(v_dados.last()).vr_vllanmto := 4.11;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 552860;
    v_dados(v_dados.last()).vr_nrctremp := 226915;
    v_dados(v_dados.last()).vr_vllanmto := .17;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 620793;
    v_dados(v_dados.last()).vr_nrctremp := 229681;
    v_dados(v_dados.last()).vr_vllanmto := .75;
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
