declare
  vr_cdcritic  cecred.crapcri.cdcritic%TYPE;
  vr_dscritic  VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat   cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto  varchar(3);
  vr_tab_erro  cecred.GENE0001.typ_tab_erro;
  
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE,
      vr_cdhistor cecred.craplem.cdhistor%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
BEGIN
  

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76848;
    v_dados(v_dados.last()).vr_nrctremp := 11015;
    v_dados(v_dados.last()).vr_vllanmto := 21.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76848;
    v_dados(v_dados.last()).vr_nrctremp := 11015;
    v_dados(v_dados.last()).vr_vllanmto := 19.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76368;
    v_dados(v_dados.last()).vr_nrctremp := 11017;
    v_dados(v_dados.last()).vr_vllanmto := 75.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76368;
    v_dados(v_dados.last()).vr_nrctremp := 11017;
    v_dados(v_dados.last()).vr_vllanmto := 152.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67253;
    v_dados(v_dados.last()).vr_nrctremp := 11077;
    v_dados(v_dados.last()).vr_vllanmto := 1580.97;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86100;
    v_dados(v_dados.last()).vr_nrctremp := 11110;
    v_dados(v_dados.last()).vr_vllanmto := 66.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86100;
    v_dados(v_dados.last()).vr_nrctremp := 11110;
    v_dados(v_dados.last()).vr_vllanmto := 62.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 64220;
    v_dados(v_dados.last()).vr_nrctremp := 11136;
    v_dados(v_dados.last()).vr_vllanmto := 58.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 64220;
    v_dados(v_dados.last()).vr_nrctremp := 11136;
    v_dados(v_dados.last()).vr_vllanmto := 54.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20290;
    v_dados(v_dados.last()).vr_nrctremp := 11604;
    v_dados(v_dados.last()).vr_vllanmto := 39.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20290;
    v_dados(v_dados.last()).vr_nrctremp := 11604;
    v_dados(v_dados.last()).vr_vllanmto := 159.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123986;
    v_dados(v_dados.last()).vr_nrctremp := 11731;
    v_dados(v_dados.last()).vr_vllanmto := 18.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123986;
    v_dados(v_dados.last()).vr_nrctremp := 11731;
    v_dados(v_dados.last()).vr_vllanmto := 193.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77380;
    v_dados(v_dados.last()).vr_nrctremp := 11756;
    v_dados(v_dados.last()).vr_vllanmto := 89.6;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77380;
    v_dados(v_dados.last()).vr_nrctremp := 11756;
    v_dados(v_dados.last()).vr_vllanmto := 85.95;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67415;
    v_dados(v_dados.last()).vr_nrctremp := 11817;
    v_dados(v_dados.last()).vr_vllanmto := 150.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 90.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 225.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 4588;
    v_dados(v_dados.last()).vr_nrctremp := 12269;
    v_dados(v_dados.last()).vr_vllanmto := .47;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 4588;
    v_dados(v_dados.last()).vr_nrctremp := 12269;
    v_dados(v_dados.last()).vr_vllanmto := 10.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84298;
    v_dados(v_dados.last()).vr_nrctremp := 12426;
    v_dados(v_dados.last()).vr_vllanmto := 13.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84298;
    v_dados(v_dados.last()).vr_nrctremp := 12426;
    v_dados(v_dados.last()).vr_vllanmto := 12.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67393;
    v_dados(v_dados.last()).vr_nrctremp := 12480;
    v_dados(v_dados.last()).vr_vllanmto := 48.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67393;
    v_dados(v_dados.last()).vr_nrctremp := 12480;
    v_dados(v_dados.last()).vr_vllanmto := 45.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117579;
    v_dados(v_dados.last()).vr_nrctremp := 12692;
    v_dados(v_dados.last()).vr_vllanmto := 26.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117579;
    v_dados(v_dados.last()).vr_nrctremp := 12692;
    v_dados(v_dados.last()).vr_vllanmto := 25.6;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 83976;
    v_dados(v_dados.last()).vr_nrctremp := 12702;
    v_dados(v_dados.last()).vr_vllanmto := 80.71;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145890;
    v_dados(v_dados.last()).vr_nrctremp := 12747;
    v_dados(v_dados.last()).vr_vllanmto := 30.45;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145890;
    v_dados(v_dados.last()).vr_nrctremp := 12747;
    v_dados(v_dados.last()).vr_vllanmto := 52.27;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 109207;
    v_dados(v_dados.last()).vr_nrctremp := 12749;
    v_dados(v_dados.last()).vr_vllanmto := 48.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67334;
    v_dados(v_dados.last()).vr_nrctremp := 12867;
    v_dados(v_dados.last()).vr_vllanmto := 105.1;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67334;
    v_dados(v_dados.last()).vr_nrctremp := 12867;
    v_dados(v_dados.last()).vr_vllanmto := 164.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85588;
    v_dados(v_dados.last()).vr_nrctremp := 13038;
    v_dados(v_dados.last()).vr_vllanmto := 4924.51;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76449;
    v_dados(v_dados.last()).vr_nrctremp := 13040;
    v_dados(v_dados.last()).vr_vllanmto := 57.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76449;
    v_dados(v_dados.last()).vr_nrctremp := 13040;
    v_dados(v_dados.last()).vr_vllanmto := 74.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125288;
    v_dados(v_dados.last()).vr_nrctremp := 13126;
    v_dados(v_dados.last()).vr_vllanmto := 9.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 156337;
    v_dados(v_dados.last()).vr_nrctremp := 13135;
    v_dados(v_dados.last()).vr_vllanmto := 37.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 156337;
    v_dados(v_dados.last()).vr_nrctremp := 13135;
    v_dados(v_dados.last()).vr_vllanmto := 306.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49743;
    v_dados(v_dados.last()).vr_nrctremp := 13139;
    v_dados(v_dados.last()).vr_vllanmto := 47.48;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49743;
    v_dados(v_dados.last()).vr_nrctremp := 13139;
    v_dados(v_dados.last()).vr_vllanmto := 47.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127671;
    v_dados(v_dados.last()).vr_nrctremp := 13164;
    v_dados(v_dados.last()).vr_vllanmto := 43.59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127671;
    v_dados(v_dados.last()).vr_nrctremp := 13164;
    v_dados(v_dados.last()).vr_vllanmto := 40.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108898;
    v_dados(v_dados.last()).vr_nrctremp := 13288;
    v_dados(v_dados.last()).vr_vllanmto := 132.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142328;
    v_dados(v_dados.last()).vr_nrctremp := 13396;
    v_dados(v_dados.last()).vr_vllanmto := 27.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142328;
    v_dados(v_dados.last()).vr_nrctremp := 13396;
    v_dados(v_dados.last()).vr_vllanmto := 12.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 13581;
    v_dados(v_dados.last()).vr_vllanmto := 107.59;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67261;
    v_dados(v_dados.last()).vr_nrctremp := 13581;
    v_dados(v_dados.last()).vr_vllanmto := 42.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 52795;
    v_dados(v_dados.last()).vr_nrctremp := 13619;
    v_dados(v_dados.last()).vr_vllanmto := 183.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 52795;
    v_dados(v_dados.last()).vr_nrctremp := 13619;
    v_dados(v_dados.last()).vr_vllanmto := 83.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127582;
    v_dados(v_dados.last()).vr_nrctremp := 13745;
    v_dados(v_dados.last()).vr_vllanmto := 13.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125067;
    v_dados(v_dados.last()).vr_nrctremp := 13806;
    v_dados(v_dados.last()).vr_vllanmto := 104.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125067;
    v_dados(v_dados.last()).vr_nrctremp := 13806;
    v_dados(v_dados.last()).vr_vllanmto := 34.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 155098;
    v_dados(v_dados.last()).vr_nrctremp := 14109;
    v_dados(v_dados.last()).vr_vllanmto := 20.23;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 155098;
    v_dados(v_dados.last()).vr_nrctremp := 14109;
    v_dados(v_dados.last()).vr_vllanmto := 23.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 14113;
    v_dados(v_dados.last()).vr_vllanmto := 65.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48712;
    v_dados(v_dados.last()).vr_nrctremp := 14142;
    v_dados(v_dados.last()).vr_vllanmto := 92.9;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48712;
    v_dados(v_dados.last()).vr_nrctremp := 14142;
    v_dados(v_dados.last()).vr_vllanmto := 86.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143324;
    v_dados(v_dados.last()).vr_nrctremp := 14165;
    v_dados(v_dados.last()).vr_vllanmto := 19.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143324;
    v_dados(v_dados.last()).vr_nrctremp := 14165;
    v_dados(v_dados.last()).vr_vllanmto := 18.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143316;
    v_dados(v_dados.last()).vr_nrctremp := 14623;
    v_dados(v_dados.last()).vr_vllanmto := 94.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143200;
    v_dados(v_dados.last()).vr_nrctremp := 14633;
    v_dados(v_dados.last()).vr_vllanmto := 672.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 113417;
    v_dados(v_dados.last()).vr_nrctremp := 14651;
    v_dados(v_dados.last()).vr_vllanmto := 197.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 113417;
    v_dados(v_dados.last()).vr_nrctremp := 14651;
    v_dados(v_dados.last()).vr_vllanmto := 184.9;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20206;
    v_dados(v_dados.last()).vr_nrctremp := 14702;
    v_dados(v_dados.last()).vr_vllanmto := 54.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20206;
    v_dados(v_dados.last()).vr_nrctremp := 14702;
    v_dados(v_dados.last()).vr_vllanmto := 49.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 79359;
    v_dados(v_dados.last()).vr_nrctremp := 14930;
    v_dados(v_dados.last()).vr_vllanmto := 224.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 79359;
    v_dados(v_dados.last()).vr_nrctremp := 14930;
    v_dados(v_dados.last()).vr_vllanmto := 12.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104396;
    v_dados(v_dados.last()).vr_nrctremp := 15101;
    v_dados(v_dados.last()).vr_vllanmto := 59.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104396;
    v_dados(v_dados.last()).vr_nrctremp := 15101;
    v_dados(v_dados.last()).vr_vllanmto := 166.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 101397;
    v_dados(v_dados.last()).vr_nrctremp := 15349;
    v_dados(v_dados.last()).vr_vllanmto := 212.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 101397;
    v_dados(v_dados.last()).vr_nrctremp := 15349;
    v_dados(v_dados.last()).vr_vllanmto := 198.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 119717;
    v_dados(v_dados.last()).vr_nrctremp := 15448;
    v_dados(v_dados.last()).vr_vllanmto := 86.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 119717;
    v_dados(v_dados.last()).vr_nrctremp := 15448;
    v_dados(v_dados.last()).vr_vllanmto := 80.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 107824;
    v_dados(v_dados.last()).vr_nrctremp := 15704;
    v_dados(v_dados.last()).vr_vllanmto := 16.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 107824;
    v_dados(v_dados.last()).vr_nrctremp := 15704;
    v_dados(v_dados.last()).vr_vllanmto := 15.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73458;
    v_dados(v_dados.last()).vr_nrctremp := 15889;
    v_dados(v_dados.last()).vr_vllanmto := 66.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73458;
    v_dados(v_dados.last()).vr_nrctremp := 15889;
    v_dados(v_dados.last()).vr_vllanmto := 60.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 42641;
    v_dados(v_dados.last()).vr_nrctremp := 15890;
    v_dados(v_dados.last()).vr_vllanmto := 156.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 42641;
    v_dados(v_dados.last()).vr_nrctremp := 15890;
    v_dados(v_dados.last()).vr_vllanmto := 217.7;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108766;
    v_dados(v_dados.last()).vr_nrctremp := 15928;
    v_dados(v_dados.last()).vr_vllanmto := 23.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108766;
    v_dados(v_dados.last()).vr_nrctremp := 15928;
    v_dados(v_dados.last()).vr_vllanmto := 21.98;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147893;
    v_dados(v_dados.last()).vr_nrctremp := 15952;
    v_dados(v_dados.last()).vr_vllanmto := 71.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147893;
    v_dados(v_dados.last()).vr_nrctremp := 15952;
    v_dados(v_dados.last()).vr_vllanmto := 66.58;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 56987;
    v_dados(v_dados.last()).vr_nrctremp := 15962;
    v_dados(v_dados.last()).vr_vllanmto := 23.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 56987;
    v_dados(v_dados.last()).vr_nrctremp := 15962;
    v_dados(v_dados.last()).vr_vllanmto := 28.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 161381;
    v_dados(v_dados.last()).vr_nrctremp := 16004;
    v_dados(v_dados.last()).vr_vllanmto := 6.94;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75612;
    v_dados(v_dados.last()).vr_nrctremp := 16144;
    v_dados(v_dados.last()).vr_vllanmto := 26.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75612;
    v_dados(v_dados.last()).vr_nrctremp := 16144;
    v_dados(v_dados.last()).vr_vllanmto := 25.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 132942;
    v_dados(v_dados.last()).vr_nrctremp := 16386;
    v_dados(v_dados.last()).vr_vllanmto := 110.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139483;
    v_dados(v_dados.last()).vr_nrctremp := 16472;
    v_dados(v_dados.last()).vr_vllanmto := 12.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 5.05;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 320.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103675;
    v_dados(v_dados.last()).vr_nrctremp := 16530;
    v_dados(v_dados.last()).vr_vllanmto := 73.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103675;
    v_dados(v_dados.last()).vr_nrctremp := 16530;
    v_dados(v_dados.last()).vr_vllanmto := 68.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142395;
    v_dados(v_dados.last()).vr_nrctremp := 16565;
    v_dados(v_dados.last()).vr_vllanmto := 5.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142395;
    v_dados(v_dados.last()).vr_nrctremp := 16565;
    v_dados(v_dados.last()).vr_vllanmto := 16.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 106739;
    v_dados(v_dados.last()).vr_nrctremp := 16580;
    v_dados(v_dados.last()).vr_vllanmto := 816.89;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 106739;
    v_dados(v_dados.last()).vr_nrctremp := 16580;
    v_dados(v_dados.last()).vr_vllanmto := 62.36;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48950;
    v_dados(v_dados.last()).vr_nrctremp := 16706;
    v_dados(v_dados.last()).vr_vllanmto := 8023.12;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 61522;
    v_dados(v_dados.last()).vr_nrctremp := 16727;
    v_dados(v_dados.last()).vr_vllanmto := 87.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 61522;
    v_dados(v_dados.last()).vr_nrctremp := 16727;
    v_dados(v_dados.last()).vr_vllanmto := 224.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20303;
    v_dados(v_dados.last()).vr_nrctremp := 16962;
    v_dados(v_dados.last()).vr_vllanmto := 5064.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 17006;
    v_dados(v_dados.last()).vr_vllanmto := 22.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75906;
    v_dados(v_dados.last()).vr_nrctremp := 17006;
    v_dados(v_dados.last()).vr_vllanmto := 21.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141046;
    v_dados(v_dados.last()).vr_nrctremp := 17045;
    v_dados(v_dados.last()).vr_vllanmto := 11.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141046;
    v_dados(v_dados.last()).vr_nrctremp := 17045;
    v_dados(v_dados.last()).vr_vllanmto := 10.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94919;
    v_dados(v_dados.last()).vr_nrctremp := 17046;
    v_dados(v_dados.last()).vr_vllanmto := 17.18;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129119;
    v_dados(v_dados.last()).vr_nrctremp := 17075;
    v_dados(v_dados.last()).vr_vllanmto := 40.95;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129119;
    v_dados(v_dados.last()).vr_nrctremp := 17075;
    v_dados(v_dados.last()).vr_vllanmto := 37.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121720;
    v_dados(v_dados.last()).vr_nrctremp := 17476;
    v_dados(v_dados.last()).vr_vllanmto := 33.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121720;
    v_dados(v_dados.last()).vr_nrctremp := 17476;
    v_dados(v_dados.last()).vr_vllanmto := 64.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142964;
    v_dados(v_dados.last()).vr_nrctremp := 17691;
    v_dados(v_dados.last()).vr_vllanmto := 105.25;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142964;
    v_dados(v_dados.last()).vr_nrctremp := 17691;
    v_dados(v_dados.last()).vr_vllanmto := 98.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104027;
    v_dados(v_dados.last()).vr_nrctremp := 17842;
    v_dados(v_dados.last()).vr_vllanmto := 5543.74;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143553;
    v_dados(v_dados.last()).vr_nrctremp := 17894;
    v_dados(v_dados.last()).vr_vllanmto := 115.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143553;
    v_dados(v_dados.last()).vr_nrctremp := 17894;
    v_dados(v_dados.last()).vr_vllanmto := 67.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 167061;
    v_dados(v_dados.last()).vr_nrctremp := 18163;
    v_dados(v_dados.last()).vr_vllanmto := 57.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143677;
    v_dados(v_dados.last()).vr_nrctremp := 18206;
    v_dados(v_dados.last()).vr_vllanmto := 109.27;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143677;
    v_dados(v_dados.last()).vr_nrctremp := 18206;
    v_dados(v_dados.last()).vr_vllanmto := 104.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 18215;
    v_dados(v_dados.last()).vr_vllanmto := 52.44;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 18215;
    v_dados(v_dados.last()).vr_vllanmto := 49.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112569;
    v_dados(v_dados.last()).vr_nrctremp := 18397;
    v_dados(v_dados.last()).vr_vllanmto := 6483.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110043;
    v_dados(v_dados.last()).vr_nrctremp := 19059;
    v_dados(v_dados.last()).vr_vllanmto := 102.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110043;
    v_dados(v_dados.last()).vr_nrctremp := 19059;
    v_dados(v_dados.last()).vr_vllanmto := 95.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76910;
    v_dados(v_dados.last()).vr_nrctremp := 19065;
    v_dados(v_dados.last()).vr_vllanmto := 21.69;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76910;
    v_dados(v_dados.last()).vr_nrctremp := 19065;
    v_dados(v_dados.last()).vr_vllanmto := 16.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 149101;
    v_dados(v_dados.last()).vr_nrctremp := 19244;
    v_dados(v_dados.last()).vr_vllanmto := 19.61;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165298;
    v_dados(v_dados.last()).vr_nrctremp := 19286;
    v_dados(v_dados.last()).vr_vllanmto := 13.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165298;
    v_dados(v_dados.last()).vr_nrctremp := 19286;
    v_dados(v_dados.last()).vr_vllanmto := 12.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110833;
    v_dados(v_dados.last()).vr_nrctremp := 19761;
    v_dados(v_dados.last()).vr_vllanmto := 19.15;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110833;
    v_dados(v_dados.last()).vr_nrctremp := 19761;
    v_dados(v_dados.last()).vr_vllanmto := 440.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128244;
    v_dados(v_dados.last()).vr_nrctremp := 20022;
    v_dados(v_dados.last()).vr_vllanmto := 24.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128244;
    v_dados(v_dados.last()).vr_nrctremp := 20022;
    v_dados(v_dados.last()).vr_vllanmto := 326.11;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128244;
    v_dados(v_dados.last()).vr_nrctremp := 20022;
    v_dados(v_dados.last()).vr_vllanmto := 23.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141941;
    v_dados(v_dados.last()).vr_nrctremp := 20085;
    v_dados(v_dados.last()).vr_vllanmto := 8.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141941;
    v_dados(v_dados.last()).vr_nrctremp := 20085;
    v_dados(v_dados.last()).vr_vllanmto := 77.92;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166898;
    v_dados(v_dados.last()).vr_nrctremp := 20193;
    v_dados(v_dados.last()).vr_vllanmto := 40.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166898;
    v_dados(v_dados.last()).vr_nrctremp := 20193;
    v_dados(v_dados.last()).vr_vllanmto := 71.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165450;
    v_dados(v_dados.last()).vr_nrctremp := 20342;
    v_dados(v_dados.last()).vr_vllanmto := 19.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165450;
    v_dados(v_dados.last()).vr_nrctremp := 20342;
    v_dados(v_dados.last()).vr_vllanmto := 18.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 47457;
    v_dados(v_dados.last()).vr_nrctremp := 20383;
    v_dados(v_dados.last()).vr_vllanmto := 36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 47457;
    v_dados(v_dados.last()).vr_nrctremp := 20383;
    v_dados(v_dados.last()).vr_vllanmto := 33.8;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129100;
    v_dados(v_dados.last()).vr_nrctremp := 20657;
    v_dados(v_dados.last()).vr_vllanmto := 37.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129100;
    v_dados(v_dados.last()).vr_nrctremp := 20657;
    v_dados(v_dados.last()).vr_vllanmto := 35.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 74900;
    v_dados(v_dados.last()).vr_nrctremp := 20692;
    v_dados(v_dados.last()).vr_vllanmto := 37.36;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 74900;
    v_dados(v_dados.last()).vr_nrctremp := 20692;
    v_dados(v_dados.last()).vr_vllanmto := 40.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73130;
    v_dados(v_dados.last()).vr_nrctremp := 20750;
    v_dados(v_dados.last()).vr_vllanmto := 52.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73130;
    v_dados(v_dados.last()).vr_nrctremp := 20750;
    v_dados(v_dados.last()).vr_vllanmto := 116.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 109134;
    v_dados(v_dados.last()).vr_nrctremp := 20782;
    v_dados(v_dados.last()).vr_vllanmto := 49.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 109134;
    v_dados(v_dados.last()).vr_nrctremp := 20782;
    v_dados(v_dados.last()).vr_vllanmto := 269.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 107239;
    v_dados(v_dados.last()).vr_nrctremp := 20794;
    v_dados(v_dados.last()).vr_vllanmto := 25.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 107239;
    v_dados(v_dados.last()).vr_nrctremp := 20794;
    v_dados(v_dados.last()).vr_vllanmto := 13.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164291;
    v_dados(v_dados.last()).vr_nrctremp := 20796;
    v_dados(v_dados.last()).vr_vllanmto := 9.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164291;
    v_dados(v_dados.last()).vr_nrctremp := 20796;
    v_dados(v_dados.last()).vr_vllanmto := 83.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 12.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 121.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86177;
    v_dados(v_dados.last()).vr_nrctremp := 20920;
    v_dados(v_dados.last()).vr_vllanmto := 266.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86177;
    v_dados(v_dados.last()).vr_nrctremp := 20920;
    v_dados(v_dados.last()).vr_vllanmto := 255.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 63.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 227.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 177075;
    v_dados(v_dados.last()).vr_nrctremp := 21289;
    v_dados(v_dados.last()).vr_vllanmto := 522.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 177075;
    v_dados(v_dados.last()).vr_nrctremp := 21289;
    v_dados(v_dados.last()).vr_vllanmto := 487.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 72931;
    v_dados(v_dados.last()).vr_nrctremp := 21381;
    v_dados(v_dados.last()).vr_vllanmto := 50.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 72931;
    v_dados(v_dados.last()).vr_nrctremp := 21381;
    v_dados(v_dados.last()).vr_vllanmto := 47.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139351;
    v_dados(v_dados.last()).vr_nrctremp := 21530;
    v_dados(v_dados.last()).vr_vllanmto := 1.22;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142867;
    v_dados(v_dados.last()).vr_nrctremp := 21554;
    v_dados(v_dados.last()).vr_vllanmto := 12.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142867;
    v_dados(v_dados.last()).vr_nrctremp := 21554;
    v_dados(v_dados.last()).vr_vllanmto := 41.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73156;
    v_dados(v_dados.last()).vr_nrctremp := 21589;
    v_dados(v_dados.last()).vr_vllanmto := 14.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73156;
    v_dados(v_dados.last()).vr_nrctremp := 21589;
    v_dados(v_dados.last()).vr_vllanmto := 15.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143227;
    v_dados(v_dados.last()).vr_nrctremp := 21595;
    v_dados(v_dados.last()).vr_vllanmto := 100.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143227;
    v_dados(v_dados.last()).vr_nrctremp := 21595;
    v_dados(v_dados.last()).vr_vllanmto := 96.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152080;
    v_dados(v_dados.last()).vr_nrctremp := 21626;
    v_dados(v_dados.last()).vr_vllanmto := 56.08;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152080;
    v_dados(v_dados.last()).vr_nrctremp := 21626;
    v_dados(v_dados.last()).vr_vllanmto := 122.15;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154415;
    v_dados(v_dados.last()).vr_nrctremp := 22046;
    v_dados(v_dados.last()).vr_vllanmto := 154.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154415;
    v_dados(v_dados.last()).vr_nrctremp := 22046;
    v_dados(v_dados.last()).vr_vllanmto := 144.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 169927;
    v_dados(v_dados.last()).vr_nrctremp := 22132;
    v_dados(v_dados.last()).vr_vllanmto := 3.04;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 171069;
    v_dados(v_dados.last()).vr_nrctremp := 22201;
    v_dados(v_dados.last()).vr_vllanmto := 18.91;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 171069;
    v_dados(v_dados.last()).vr_nrctremp := 22201;
    v_dados(v_dados.last()).vr_vllanmto := 21.44;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138983;
    v_dados(v_dados.last()).vr_nrctremp := 22247;
    v_dados(v_dados.last()).vr_vllanmto := 59.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138983;
    v_dados(v_dados.last()).vr_nrctremp := 22247;
    v_dados(v_dados.last()).vr_vllanmto := 70.06;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 161381;
    v_dados(v_dados.last()).vr_nrctremp := 22300;
    v_dados(v_dados.last()).vr_vllanmto := 11.77;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140473;
    v_dados(v_dados.last()).vr_nrctremp := 22520;
    v_dados(v_dados.last()).vr_vllanmto := 10.83;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140473;
    v_dados(v_dados.last()).vr_nrctremp := 22520;
    v_dados(v_dados.last()).vr_vllanmto := 10.95;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166650;
    v_dados(v_dados.last()).vr_nrctremp := 22713;
    v_dados(v_dados.last()).vr_vllanmto := 53.03;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166650;
    v_dados(v_dados.last()).vr_nrctremp := 22713;
    v_dados(v_dados.last()).vr_vllanmto := 49.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85065;
    v_dados(v_dados.last()).vr_nrctremp := 22767;
    v_dados(v_dados.last()).vr_vllanmto := 49.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85065;
    v_dados(v_dados.last()).vr_nrctremp := 22767;
    v_dados(v_dados.last()).vr_vllanmto := 83.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77020;
    v_dados(v_dados.last()).vr_nrctremp := 22884;
    v_dados(v_dados.last()).vr_vllanmto := 2067.8;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 35157;
    v_dados(v_dados.last()).vr_nrctremp := 22916;
    v_dados(v_dados.last()).vr_vllanmto := 34.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 35157;
    v_dados(v_dados.last()).vr_nrctremp := 22916;
    v_dados(v_dados.last()).vr_vllanmto := 32.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127752;
    v_dados(v_dados.last()).vr_nrctremp := 23368;
    v_dados(v_dados.last()).vr_vllanmto := 135.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127752;
    v_dados(v_dados.last()).vr_nrctremp := 23368;
    v_dados(v_dados.last()).vr_vllanmto := 127.07;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166499;
    v_dados(v_dados.last()).vr_nrctremp := 23514;
    v_dados(v_dados.last()).vr_vllanmto := 16.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166499;
    v_dados(v_dados.last()).vr_nrctremp := 23514;
    v_dados(v_dados.last()).vr_vllanmto := 21.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 161527;
    v_dados(v_dados.last()).vr_nrctremp := 23566;
    v_dados(v_dados.last()).vr_vllanmto := 20.5;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 161527;
    v_dados(v_dados.last()).vr_nrctremp := 23566;
    v_dados(v_dados.last()).vr_vllanmto := 41.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168831;
    v_dados(v_dados.last()).vr_nrctremp := 23887;
    v_dados(v_dados.last()).vr_vllanmto := 10.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168831;
    v_dados(v_dados.last()).vr_nrctremp := 23887;
    v_dados(v_dados.last()).vr_vllanmto := 11.64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67709;
    v_dados(v_dados.last()).vr_nrctremp := 23940;
    v_dados(v_dados.last()).vr_vllanmto := 66.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67709;
    v_dados(v_dados.last()).vr_nrctremp := 23940;
    v_dados(v_dados.last()).vr_vllanmto := 62.21;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 46469;
    v_dados(v_dados.last()).vr_nrctremp := 24157;
    v_dados(v_dados.last()).vr_vllanmto := 50.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 176907;
    v_dados(v_dados.last()).vr_nrctremp := 24267;
    v_dados(v_dados.last()).vr_vllanmto := 86.34;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 176907;
    v_dados(v_dados.last()).vr_nrctremp := 24267;
    v_dados(v_dados.last()).vr_vllanmto := 82.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125873;
    v_dados(v_dados.last()).vr_nrctremp := 24290;
    v_dados(v_dados.last()).vr_vllanmto := 54.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 125873;
    v_dados(v_dados.last()).vr_nrctremp := 24290;
    v_dados(v_dados.last()).vr_vllanmto := 50.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 24327;
    v_dados(v_dados.last()).vr_vllanmto := 48.49;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143103;
    v_dados(v_dados.last()).vr_nrctremp := 24327;
    v_dados(v_dados.last()).vr_vllanmto := 45.39;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49956;
    v_dados(v_dados.last()).vr_nrctremp := 24468;
    v_dados(v_dados.last()).vr_vllanmto := 58.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67296;
    v_dados(v_dados.last()).vr_nrctremp := 24476;
    v_dados(v_dados.last()).vr_vllanmto := 153.08;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67296;
    v_dados(v_dados.last()).vr_nrctremp := 24476;
    v_dados(v_dados.last()).vr_vllanmto := 143.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166634;
    v_dados(v_dados.last()).vr_nrctremp := 24549;
    v_dados(v_dados.last()).vr_vllanmto := 30.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166634;
    v_dados(v_dados.last()).vr_nrctremp := 24549;
    v_dados(v_dados.last()).vr_vllanmto := 19.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94943;
    v_dados(v_dados.last()).vr_nrctremp := 24595;
    v_dados(v_dados.last()).vr_vllanmto := 158.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94943;
    v_dados(v_dados.last()).vr_nrctremp := 24595;
    v_dados(v_dados.last()).vr_vllanmto := 11.84;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 89664;
    v_dados(v_dados.last()).vr_nrctremp := 25086;
    v_dados(v_dados.last()).vr_vllanmto := 60.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 89664;
    v_dados(v_dados.last()).vr_nrctremp := 25086;
    v_dados(v_dados.last()).vr_vllanmto := 56.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103845;
    v_dados(v_dados.last()).vr_nrctremp := 25269;
    v_dados(v_dados.last()).vr_vllanmto := 112.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103845;
    v_dados(v_dados.last()).vr_nrctremp := 25269;
    v_dados(v_dados.last()).vr_vllanmto := 183.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 151017;
    v_dados(v_dados.last()).vr_nrctremp := 25746;
    v_dados(v_dados.last()).vr_vllanmto := 27.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 151017;
    v_dados(v_dados.last()).vr_nrctremp := 25746;
    v_dados(v_dados.last()).vr_vllanmto := 52.79;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 80772;
    v_dados(v_dados.last()).vr_nrctremp := 25808;
    v_dados(v_dados.last()).vr_vllanmto := 172.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 80772;
    v_dados(v_dados.last()).vr_nrctremp := 25808;
    v_dados(v_dados.last()).vr_vllanmto := 161.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 83682;
    v_dados(v_dados.last()).vr_nrctremp := 26001;
    v_dados(v_dados.last()).vr_vllanmto := 35.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 83682;
    v_dados(v_dados.last()).vr_nrctremp := 26001;
    v_dados(v_dados.last()).vr_vllanmto := 69.12;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183946;
    v_dados(v_dados.last()).vr_nrctremp := 26040;
    v_dados(v_dados.last()).vr_vllanmto := 9.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183946;
    v_dados(v_dados.last()).vr_nrctremp := 26040;
    v_dados(v_dados.last()).vr_vllanmto := 82.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73075;
    v_dados(v_dados.last()).vr_nrctremp := 26046;
    v_dados(v_dados.last()).vr_vllanmto := 14.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73075;
    v_dados(v_dados.last()).vr_nrctremp := 26046;
    v_dados(v_dados.last()).vr_vllanmto := 13.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110043;
    v_dados(v_dados.last()).vr_nrctremp := 26160;
    v_dados(v_dados.last()).vr_vllanmto := 117.72;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 110043;
    v_dados(v_dados.last()).vr_nrctremp := 26160;
    v_dados(v_dados.last()).vr_vllanmto := 110.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48410;
    v_dados(v_dados.last()).vr_nrctremp := 26327;
    v_dados(v_dados.last()).vr_vllanmto := 67.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48410;
    v_dados(v_dados.last()).vr_nrctremp := 26327;
    v_dados(v_dados.last()).vr_vllanmto := 21.21;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73164;
    v_dados(v_dados.last()).vr_nrctremp := 26413;
    v_dados(v_dados.last()).vr_vllanmto := 5.31;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73164;
    v_dados(v_dados.last()).vr_nrctremp := 26413;
    v_dados(v_dados.last()).vr_vllanmto := 13.81;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 29025;
    v_dados(v_dados.last()).vr_nrctremp := 26466;
    v_dados(v_dados.last()).vr_vllanmto := 187.56;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187917;
    v_dados(v_dados.last()).vr_nrctremp := 27006;
    v_dados(v_dados.last()).vr_vllanmto := 26.04;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187917;
    v_dados(v_dados.last()).vr_nrctremp := 27006;
    v_dados(v_dados.last()).vr_vllanmto := 8.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112763;
    v_dados(v_dados.last()).vr_nrctremp := 27051;
    v_dados(v_dados.last()).vr_vllanmto := 24.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112763;
    v_dados(v_dados.last()).vr_nrctremp := 27051;
    v_dados(v_dados.last()).vr_vllanmto := 21.75;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165506;
    v_dados(v_dados.last()).vr_nrctremp := 27071;
    v_dados(v_dados.last()).vr_vllanmto := 88.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165506;
    v_dados(v_dados.last()).vr_nrctremp := 27071;
    v_dados(v_dados.last()).vr_vllanmto := 79.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142786;
    v_dados(v_dados.last()).vr_nrctremp := 27174;
    v_dados(v_dados.last()).vr_vllanmto := 67.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142786;
    v_dados(v_dados.last()).vr_nrctremp := 27174;
    v_dados(v_dados.last()).vr_vllanmto := 79.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129879;
    v_dados(v_dados.last()).vr_nrctremp := 27177;
    v_dados(v_dados.last()).vr_vllanmto := 19.62;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129879;
    v_dados(v_dados.last()).vr_nrctremp := 27177;
    v_dados(v_dados.last()).vr_vllanmto := 17.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 111210;
    v_dados(v_dados.last()).vr_nrctremp := 27222;
    v_dados(v_dados.last()).vr_vllanmto := 33.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 111210;
    v_dados(v_dados.last()).vr_nrctremp := 27222;
    v_dados(v_dados.last()).vr_vllanmto := 93.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168831;
    v_dados(v_dados.last()).vr_nrctremp := 27304;
    v_dados(v_dados.last()).vr_vllanmto := 7.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186961;
    v_dados(v_dados.last()).vr_nrctremp := 27369;
    v_dados(v_dados.last()).vr_vllanmto := 46.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186961;
    v_dados(v_dados.last()).vr_nrctremp := 27369;
    v_dados(v_dados.last()).vr_vllanmto := 42.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142824;
    v_dados(v_dados.last()).vr_nrctremp := 27383;
    v_dados(v_dados.last()).vr_vllanmto := 177.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142824;
    v_dados(v_dados.last()).vr_nrctremp := 27383;
    v_dados(v_dados.last()).vr_vllanmto := 166;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 126322;
    v_dados(v_dados.last()).vr_nrctremp := 27516;
    v_dados(v_dados.last()).vr_vllanmto := 17.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183962;
    v_dados(v_dados.last()).vr_nrctremp := 27699;
    v_dados(v_dados.last()).vr_vllanmto := 49.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183962;
    v_dados(v_dados.last()).vr_nrctremp := 27699;
    v_dados(v_dados.last()).vr_vllanmto := 78.54;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49484;
    v_dados(v_dados.last()).vr_nrctremp := 27912;
    v_dados(v_dados.last()).vr_vllanmto := 78.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49484;
    v_dados(v_dados.last()).vr_nrctremp := 27912;
    v_dados(v_dados.last()).vr_vllanmto := 137.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165867;
    v_dados(v_dados.last()).vr_nrctremp := 27952;
    v_dados(v_dados.last()).vr_vllanmto := 16.06;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 91081;
    v_dados(v_dados.last()).vr_nrctremp := 27991;
    v_dados(v_dados.last()).vr_vllanmto := 10439.95;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128228;
    v_dados(v_dados.last()).vr_nrctremp := 28289;
    v_dados(v_dados.last()).vr_vllanmto := 146.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128228;
    v_dados(v_dados.last()).vr_nrctremp := 28289;
    v_dados(v_dados.last()).vr_vllanmto := 136.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166480;
    v_dados(v_dados.last()).vr_nrctremp := 28356;
    v_dados(v_dados.last()).vr_vllanmto := 7.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164321;
    v_dados(v_dados.last()).vr_nrctremp := 28487;
    v_dados(v_dados.last()).vr_vllanmto := 27.96;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164321;
    v_dados(v_dados.last()).vr_nrctremp := 28487;
    v_dados(v_dados.last()).vr_vllanmto := 25.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133418;
    v_dados(v_dados.last()).vr_nrctremp := 28512;
    v_dados(v_dados.last()).vr_vllanmto := 34.26;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133418;
    v_dados(v_dados.last()).vr_nrctremp := 28512;
    v_dados(v_dados.last()).vr_vllanmto := 31.02;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73148;
    v_dados(v_dados.last()).vr_nrctremp := 28670;
    v_dados(v_dados.last()).vr_vllanmto := 89.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73148;
    v_dados(v_dados.last()).vr_nrctremp := 28670;
    v_dados(v_dados.last()).vr_vllanmto := 83.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104990;
    v_dados(v_dados.last()).vr_nrctremp := 28692;
    v_dados(v_dados.last()).vr_vllanmto := 59;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104990;
    v_dados(v_dados.last()).vr_nrctremp := 28692;
    v_dados(v_dados.last()).vr_vllanmto := 53.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187712;
    v_dados(v_dados.last()).vr_nrctremp := 28752;
    v_dados(v_dados.last()).vr_vllanmto := 9.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166570;
    v_dados(v_dados.last()).vr_nrctremp := 29031;
    v_dados(v_dados.last()).vr_vllanmto := 114.76;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 146196;
    v_dados(v_dados.last()).vr_nrctremp := 29064;
    v_dados(v_dados.last()).vr_vllanmto := 97.21;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 146196;
    v_dados(v_dados.last()).vr_nrctremp := 29064;
    v_dados(v_dados.last()).vr_vllanmto := 106.71;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183695;
    v_dados(v_dados.last()).vr_nrctremp := 29350;
    v_dados(v_dados.last()).vr_vllanmto := 42.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 134112;
    v_dados(v_dados.last()).vr_nrctremp := 29427;
    v_dados(v_dados.last()).vr_vllanmto := 12.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 134112;
    v_dados(v_dados.last()).vr_nrctremp := 29427;
    v_dados(v_dados.last()).vr_vllanmto := 10.91;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 5797;
    v_dados(v_dados.last()).vr_nrctremp := 29441;
    v_dados(v_dados.last()).vr_vllanmto := 261.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 5797;
    v_dados(v_dados.last()).vr_nrctremp := 29441;
    v_dados(v_dados.last()).vr_vllanmto := 325.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49794;
    v_dados(v_dados.last()).vr_nrctremp := 29556;
    v_dados(v_dados.last()).vr_vllanmto := 12.35;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77542;
    v_dados(v_dados.last()).vr_nrctremp := 29750;
    v_dados(v_dados.last()).vr_vllanmto := 91.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77542;
    v_dados(v_dados.last()).vr_nrctremp := 29750;
    v_dados(v_dados.last()).vr_vllanmto := 82.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 72966;
    v_dados(v_dados.last()).vr_nrctremp := 29759;
    v_dados(v_dados.last()).vr_vllanmto := 160.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 72966;
    v_dados(v_dados.last()).vr_nrctremp := 29759;
    v_dados(v_dados.last()).vr_vllanmto := 18.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 180874;
    v_dados(v_dados.last()).vr_nrctremp := 29859;
    v_dados(v_dados.last()).vr_vllanmto := 28.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 180874;
    v_dados(v_dados.last()).vr_nrctremp := 29859;
    v_dados(v_dados.last()).vr_vllanmto := 60.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94706;
    v_dados(v_dados.last()).vr_nrctremp := 29860;
    v_dados(v_dados.last()).vr_vllanmto := 18.48;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94706;
    v_dados(v_dados.last()).vr_nrctremp := 29860;
    v_dados(v_dados.last()).vr_vllanmto := 17.31;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 68543;
    v_dados(v_dados.last()).vr_nrctremp := 29888;
    v_dados(v_dados.last()).vr_vllanmto := 21.61;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 68543;
    v_dados(v_dados.last()).vr_nrctremp := 29888;
    v_dados(v_dados.last()).vr_vllanmto := 36.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84840;
    v_dados(v_dados.last()).vr_nrctremp := 30015;
    v_dados(v_dados.last()).vr_vllanmto := 144.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84840;
    v_dados(v_dados.last()).vr_nrctremp := 30015;
    v_dados(v_dados.last()).vr_vllanmto := 134.47;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190713;
    v_dados(v_dados.last()).vr_nrctremp := 30270;
    v_dados(v_dados.last()).vr_vllanmto := 118.57;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190713;
    v_dados(v_dados.last()).vr_nrctremp := 30270;
    v_dados(v_dados.last()).vr_vllanmto := 113.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 90662;
    v_dados(v_dados.last()).vr_nrctremp := 30402;
    v_dados(v_dados.last()).vr_vllanmto := 11.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86347;
    v_dados(v_dados.last()).vr_nrctremp := 30531;
    v_dados(v_dados.last()).vr_vllanmto := 176.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86347;
    v_dados(v_dados.last()).vr_nrctremp := 30531;
    v_dados(v_dados.last()).vr_vllanmto := 133.35;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128090;
    v_dados(v_dados.last()).vr_nrctremp := 30674;
    v_dados(v_dados.last()).vr_vllanmto := 26.1;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128090;
    v_dados(v_dados.last()).vr_nrctremp := 30674;
    v_dados(v_dados.last()).vr_vllanmto := 63.59;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 163007;
    v_dados(v_dados.last()).vr_nrctremp := 30697;
    v_dados(v_dados.last()).vr_vllanmto := 73.32;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 163007;
    v_dados(v_dados.last()).vr_nrctremp := 30697;
    v_dados(v_dados.last()).vr_vllanmto := 66.18;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154415;
    v_dados(v_dados.last()).vr_nrctremp := 30714;
    v_dados(v_dados.last()).vr_vllanmto := 8.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 30840;
    v_dados(v_dados.last()).vr_vllanmto := 119.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127612;
    v_dados(v_dados.last()).vr_nrctremp := 30937;
    v_dados(v_dados.last()).vr_vllanmto := 65.13;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127612;
    v_dados(v_dados.last()).vr_nrctremp := 30937;
    v_dados(v_dados.last()).vr_vllanmto := 60.41;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 155314;
    v_dados(v_dados.last()).vr_nrctremp := 30952;
    v_dados(v_dados.last()).vr_vllanmto := 12.55;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 155314;
    v_dados(v_dados.last()).vr_nrctremp := 30952;
    v_dados(v_dados.last()).vr_vllanmto := 64.86;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 204196;
    v_dados(v_dados.last()).vr_nrctremp := 31039;
    v_dados(v_dados.last()).vr_vllanmto := 39.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 204196;
    v_dados(v_dados.last()).vr_nrctremp := 31039;
    v_dados(v_dados.last()).vr_vllanmto := 36.97;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166588;
    v_dados(v_dados.last()).vr_nrctremp := 31512;
    v_dados(v_dados.last()).vr_vllanmto := 8.58;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49727;
    v_dados(v_dados.last()).vr_nrctremp := 31567;
    v_dados(v_dados.last()).vr_vllanmto := 22.33;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49727;
    v_dados(v_dados.last()).vr_nrctremp := 31567;
    v_dados(v_dados.last()).vr_vllanmto := 20.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104990;
    v_dados(v_dados.last()).vr_nrctremp := 31621;
    v_dados(v_dados.last()).vr_vllanmto := 66.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104990;
    v_dados(v_dados.last()).vr_nrctremp := 31621;
    v_dados(v_dados.last()).vr_vllanmto := 62.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116661;
    v_dados(v_dados.last()).vr_nrctremp := 31685;
    v_dados(v_dados.last()).vr_vllanmto := 45.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116661;
    v_dados(v_dados.last()).vr_nrctremp := 31685;
    v_dados(v_dados.last()).vr_vllanmto := 58.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 347.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 290.12;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166545;
    v_dados(v_dados.last()).vr_nrctremp := 32681;
    v_dados(v_dados.last()).vr_vllanmto := 34.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166545;
    v_dados(v_dados.last()).vr_nrctremp := 32681;
    v_dados(v_dados.last()).vr_vllanmto := 31.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 47694;
    v_dados(v_dados.last()).vr_nrctremp := 32701;
    v_dados(v_dados.last()).vr_vllanmto := 15.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 47694;
    v_dados(v_dados.last()).vr_nrctremp := 32701;
    v_dados(v_dados.last()).vr_vllanmto := 22.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67750;
    v_dados(v_dados.last()).vr_nrctremp := 32724;
    v_dados(v_dados.last()).vr_vllanmto := 48.91;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67750;
    v_dados(v_dados.last()).vr_nrctremp := 32724;
    v_dados(v_dados.last()).vr_vllanmto := 82.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77038;
    v_dados(v_dados.last()).vr_nrctremp := 32862;
    v_dados(v_dados.last()).vr_vllanmto := 39.82;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77038;
    v_dados(v_dados.last()).vr_nrctremp := 32862;
    v_dados(v_dados.last()).vr_vllanmto := 36.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184039;
    v_dados(v_dados.last()).vr_nrctremp := 32925;
    v_dados(v_dados.last()).vr_vllanmto := 23.75;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184039;
    v_dados(v_dados.last()).vr_nrctremp := 32925;
    v_dados(v_dados.last()).vr_vllanmto := 21.55;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183989;
    v_dados(v_dados.last()).vr_nrctremp := 33015;
    v_dados(v_dados.last()).vr_vllanmto := 9.11;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183989;
    v_dados(v_dados.last()).vr_nrctremp := 33015;
    v_dados(v_dados.last()).vr_vllanmto := 11.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186155;
    v_dados(v_dados.last()).vr_nrctremp := 33276;
    v_dados(v_dados.last()).vr_vllanmto := 91.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187810;
    v_dados(v_dados.last()).vr_nrctremp := 33278;
    v_dados(v_dados.last()).vr_vllanmto := 41.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 187810;
    v_dados(v_dados.last()).vr_nrctremp := 33278;
    v_dados(v_dados.last()).vr_vllanmto := 37.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186449;
    v_dados(v_dados.last()).vr_nrctremp := 33515;
    v_dados(v_dados.last()).vr_vllanmto := 78.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186449;
    v_dados(v_dados.last()).vr_nrctremp := 33515;
    v_dados(v_dados.last()).vr_vllanmto := 72.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 25.63;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 23.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166863;
    v_dados(v_dados.last()).vr_nrctremp := 33682;
    v_dados(v_dados.last()).vr_vllanmto := 27.45;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166863;
    v_dados(v_dados.last()).vr_nrctremp := 33682;
    v_dados(v_dados.last()).vr_vllanmto := 26.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186686;
    v_dados(v_dados.last()).vr_nrctremp := 33692;
    v_dados(v_dados.last()).vr_vllanmto := 359.16;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194719;
    v_dados(v_dados.last()).vr_nrctremp := 33742;
    v_dados(v_dados.last()).vr_vllanmto := 29.82;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133078;
    v_dados(v_dados.last()).vr_nrctremp := 33797;
    v_dados(v_dados.last()).vr_vllanmto := 153.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133078;
    v_dados(v_dados.last()).vr_nrctremp := 33797;
    v_dados(v_dados.last()).vr_vllanmto := 192.67;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121100;
    v_dados(v_dados.last()).vr_nrctremp := 33812;
    v_dados(v_dados.last()).vr_vllanmto := 133.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121100;
    v_dados(v_dados.last()).vr_nrctremp := 33812;
    v_dados(v_dados.last()).vr_vllanmto := 130.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 14974;
    v_dados(v_dados.last()).vr_nrctremp := 34026;
    v_dados(v_dados.last()).vr_vllanmto := 25.96;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200255;
    v_dados(v_dados.last()).vr_nrctremp := 34029;
    v_dados(v_dados.last()).vr_vllanmto := 16.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200255;
    v_dados(v_dados.last()).vr_nrctremp := 34029;
    v_dados(v_dados.last()).vr_vllanmto := 22.46;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 93734;
    v_dados(v_dados.last()).vr_nrctremp := 34131;
    v_dados(v_dados.last()).vr_vllanmto := 37.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 93734;
    v_dados(v_dados.last()).vr_nrctremp := 34131;
    v_dados(v_dados.last()).vr_vllanmto := 54.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 94.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 101.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 34580;
    v_dados(v_dados.last()).vr_vllanmto := 32.09;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 34580;
    v_dados(v_dados.last()).vr_vllanmto := 64.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 66.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 957.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115983;
    v_dados(v_dados.last()).vr_nrctremp := 34783;
    v_dados(v_dados.last()).vr_vllanmto := 28.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115983;
    v_dados(v_dados.last()).vr_nrctremp := 34783;
    v_dados(v_dados.last()).vr_vllanmto := 27.01;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172545;
    v_dados(v_dados.last()).vr_nrctremp := 34826;
    v_dados(v_dados.last()).vr_vllanmto := 45.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172545;
    v_dados(v_dados.last()).vr_nrctremp := 34826;
    v_dados(v_dados.last()).vr_vllanmto := 65.13;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116327;
    v_dados(v_dados.last()).vr_nrctremp := 34883;
    v_dados(v_dados.last()).vr_vllanmto := 31.67;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116327;
    v_dados(v_dados.last()).vr_nrctremp := 34883;
    v_dados(v_dados.last()).vr_vllanmto := 34.24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152978;
    v_dados(v_dados.last()).vr_nrctremp := 34887;
    v_dados(v_dados.last()).vr_vllanmto := 97.07;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139556;
    v_dados(v_dados.last()).vr_nrctremp := 35001;
    v_dados(v_dados.last()).vr_vllanmto := 42.89;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139556;
    v_dados(v_dados.last()).vr_nrctremp := 35001;
    v_dados(v_dados.last()).vr_vllanmto := 41.26;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142581;
    v_dados(v_dados.last()).vr_nrctremp := 35077;
    v_dados(v_dados.last()).vr_vllanmto := 582.29;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142581;
    v_dados(v_dados.last()).vr_nrctremp := 35077;
    v_dados(v_dados.last()).vr_vllanmto := 543.99;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127388;
    v_dados(v_dados.last()).vr_nrctremp := 35170;
    v_dados(v_dados.last()).vr_vllanmto := 104.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127388;
    v_dados(v_dados.last()).vr_nrctremp := 35170;
    v_dados(v_dados.last()).vr_vllanmto := 114.94;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 137170;
    v_dados(v_dados.last()).vr_nrctremp := 35173;
    v_dados(v_dados.last()).vr_vllanmto := 52.98;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 11169;
    v_dados(v_dados.last()).vr_nrctremp := 35191;
    v_dados(v_dados.last()).vr_vllanmto := 72.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 11169;
    v_dados(v_dados.last()).vr_nrctremp := 35191;
    v_dados(v_dados.last()).vr_vllanmto := 73.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 65242;
    v_dados(v_dados.last()).vr_nrctremp := 35501;
    v_dados(v_dados.last()).vr_vllanmto := 91.76;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 65242;
    v_dados(v_dados.last()).vr_nrctremp := 35501;
    v_dados(v_dados.last()).vr_vllanmto := 85.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164224;
    v_dados(v_dados.last()).vr_nrctremp := 35597;
    v_dados(v_dados.last()).vr_vllanmto := 12.02;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164224;
    v_dados(v_dados.last()).vr_nrctremp := 35597;
    v_dados(v_dados.last()).vr_vllanmto := 10.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200450;
    v_dados(v_dados.last()).vr_nrctremp := 35953;
    v_dados(v_dados.last()).vr_vllanmto := 11.19;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200450;
    v_dados(v_dados.last()).vr_nrctremp := 35953;
    v_dados(v_dados.last()).vr_vllanmto := 21.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75671;
    v_dados(v_dados.last()).vr_nrctremp := 36022;
    v_dados(v_dados.last()).vr_vllanmto := 115.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 75671;
    v_dados(v_dados.last()).vr_nrctremp := 36022;
    v_dados(v_dados.last()).vr_vllanmto := 107.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 148270;
    v_dados(v_dados.last()).vr_nrctremp := 36043;
    v_dados(v_dados.last()).vr_vllanmto := 9.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166561;
    v_dados(v_dados.last()).vr_nrctremp := 36045;
    v_dados(v_dados.last()).vr_vllanmto := 46.88;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166561;
    v_dados(v_dados.last()).vr_nrctremp := 36045;
    v_dados(v_dados.last()).vr_vllanmto := 54.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138380;
    v_dados(v_dados.last()).vr_nrctremp := 36177;
    v_dados(v_dados.last()).vr_vllanmto := 42.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138380;
    v_dados(v_dados.last()).vr_nrctremp := 36177;
    v_dados(v_dados.last()).vr_vllanmto := 38.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 105708;
    v_dados(v_dados.last()).vr_nrctremp := 36187;
    v_dados(v_dados.last()).vr_vllanmto := 204.01;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 105708;
    v_dados(v_dados.last()).vr_nrctremp := 36187;
    v_dados(v_dados.last()).vr_vllanmto := 190.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 210153;
    v_dados(v_dados.last()).vr_nrctremp := 36199;
    v_dados(v_dados.last()).vr_vllanmto := 771.43;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166693;
    v_dados(v_dados.last()).vr_nrctremp := 36303;
    v_dados(v_dados.last()).vr_vllanmto := 62.41;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166693;
    v_dados(v_dados.last()).vr_nrctremp := 36303;
    v_dados(v_dados.last()).vr_vllanmto := 75.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 220035;
    v_dados(v_dados.last()).vr_nrctremp := 36437;
    v_dados(v_dados.last()).vr_vllanmto := 324.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 220035;
    v_dados(v_dados.last()).vr_nrctremp := 36437;
    v_dados(v_dados.last()).vr_vllanmto := 42.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129313;
    v_dados(v_dados.last()).vr_nrctremp := 36634;
    v_dados(v_dados.last()).vr_vllanmto := 151.52;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129313;
    v_dados(v_dados.last()).vr_nrctremp := 36634;
    v_dados(v_dados.last()).vr_vllanmto := 115.83;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 210498;
    v_dados(v_dados.last()).vr_nrctremp := 36741;
    v_dados(v_dados.last()).vr_vllanmto := 182.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 210498;
    v_dados(v_dados.last()).vr_nrctremp := 36741;
    v_dados(v_dados.last()).vr_vllanmto := 170.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 216410;
    v_dados(v_dados.last()).vr_nrctremp := 36991;
    v_dados(v_dados.last()).vr_vllanmto := 76.2;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 216410;
    v_dados(v_dados.last()).vr_nrctremp := 36991;
    v_dados(v_dados.last()).vr_vllanmto := 74.81;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147753;
    v_dados(v_dados.last()).vr_nrctremp := 37039;
    v_dados(v_dados.last()).vr_vllanmto := 204.77;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147753;
    v_dados(v_dados.last()).vr_nrctremp := 37039;
    v_dados(v_dados.last()).vr_vllanmto := 17.28;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194743;
    v_dados(v_dados.last()).vr_nrctremp := 37044;
    v_dados(v_dados.last()).vr_vllanmto := 68.06;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194743;
    v_dados(v_dados.last()).vr_nrctremp := 37044;
    v_dados(v_dados.last()).vr_vllanmto := 63.45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184047;
    v_dados(v_dados.last()).vr_nrctremp := 37243;
    v_dados(v_dados.last()).vr_vllanmto := 28.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184047;
    v_dados(v_dados.last()).vr_nrctremp := 37243;
    v_dados(v_dados.last()).vr_vllanmto := 26.96;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 19747;
    v_dados(v_dados.last()).vr_nrctremp := 37312;
    v_dados(v_dados.last()).vr_vllanmto := 89.7;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 19747;
    v_dados(v_dados.last()).vr_nrctremp := 37312;
    v_dados(v_dados.last()).vr_vllanmto := 83.87;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141631;
    v_dados(v_dados.last()).vr_nrctremp := 37342;
    v_dados(v_dados.last()).vr_vllanmto := 28.92;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141631;
    v_dados(v_dados.last()).vr_nrctremp := 37342;
    v_dados(v_dados.last()).vr_vllanmto := 26.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166715;
    v_dados(v_dados.last()).vr_nrctremp := 37808;
    v_dados(v_dados.last()).vr_vllanmto := 4.37;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172707;
    v_dados(v_dados.last()).vr_nrctremp := 37810;
    v_dados(v_dados.last()).vr_vllanmto := 32.84;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172707;
    v_dados(v_dados.last()).vr_nrctremp := 37810;
    v_dados(v_dados.last()).vr_vllanmto := 30.82;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104639;
    v_dados(v_dados.last()).vr_nrctremp := 37880;
    v_dados(v_dados.last()).vr_vllanmto := 151.98;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104639;
    v_dados(v_dados.last()).vr_nrctremp := 37880;
    v_dados(v_dados.last()).vr_vllanmto := 142.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123609;
    v_dados(v_dados.last()).vr_nrctremp := 37896;
    v_dados(v_dados.last()).vr_vllanmto := 127.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123609;
    v_dados(v_dados.last()).vr_nrctremp := 37896;
    v_dados(v_dados.last()).vr_vllanmto := 119.29;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115908;
    v_dados(v_dados.last()).vr_nrctremp := 37902;
    v_dados(v_dados.last()).vr_vllanmto := 70.53;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115908;
    v_dados(v_dados.last()).vr_nrctremp := 37902;
    v_dados(v_dados.last()).vr_vllanmto := 60.68;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 198960;
    v_dados(v_dados.last()).vr_nrctremp := 38243;
    v_dados(v_dados.last()).vr_vllanmto := 406.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 212636;
    v_dados(v_dados.last()).vr_nrctremp := 38270;
    v_dados(v_dados.last()).vr_vllanmto := 77.77;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166502;
    v_dados(v_dados.last()).vr_nrctremp := 38272;
    v_dados(v_dados.last()).vr_vllanmto := 72.27;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168157;
    v_dados(v_dados.last()).vr_nrctremp := 38278;
    v_dados(v_dados.last()).vr_vllanmto := 31.38;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138193;
    v_dados(v_dados.last()).vr_nrctremp := 38343;
    v_dados(v_dados.last()).vr_vllanmto := 215.53;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112569;
    v_dados(v_dados.last()).vr_nrctremp := 38348;
    v_dados(v_dados.last()).vr_vllanmto := 719.38;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 112569;
    v_dados(v_dados.last()).vr_nrctremp := 38348;
    v_dados(v_dados.last()).vr_vllanmto := 689.7;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 80470;
    v_dados(v_dados.last()).vr_nrctremp := 38357;
    v_dados(v_dados.last()).vr_vllanmto := 55.43;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 80470;
    v_dados(v_dados.last()).vr_nrctremp := 38357;
    v_dados(v_dados.last()).vr_vllanmto := 49.72;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190039;
    v_dados(v_dados.last()).vr_nrctremp := 38452;
    v_dados(v_dados.last()).vr_vllanmto := 84.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190039;
    v_dados(v_dados.last()).vr_nrctremp := 38452;
    v_dados(v_dados.last()).vr_vllanmto := 80.23;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 38465;
    v_dados(v_dados.last()).vr_vllanmto := 82.97;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 38465;
    v_dados(v_dados.last()).vr_vllanmto := 77.34;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 210153;
    v_dados(v_dados.last()).vr_nrctremp := 38485;
    v_dados(v_dados.last()).vr_vllanmto := 72.05;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 210153;
    v_dados(v_dados.last()).vr_nrctremp := 38485;
    v_dados(v_dados.last()).vr_vllanmto := 63.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49719;
    v_dados(v_dados.last()).vr_nrctremp := 38508;
    v_dados(v_dados.last()).vr_vllanmto := 29.68;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49719;
    v_dados(v_dados.last()).vr_nrctremp := 38508;
    v_dados(v_dados.last()).vr_vllanmto := 28.09;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 134090;
    v_dados(v_dados.last()).vr_nrctremp := 38519;
    v_dados(v_dados.last()).vr_vllanmto := 117.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 134090;
    v_dados(v_dados.last()).vr_nrctremp := 38519;
    v_dados(v_dados.last()).vr_vllanmto := 110.49;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 27634;
    v_dados(v_dados.last()).vr_nrctremp := 38561;
    v_dados(v_dados.last()).vr_vllanmto := 144.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 27634;
    v_dados(v_dados.last()).vr_nrctremp := 38561;
    v_dados(v_dados.last()).vr_vllanmto := 135.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20303;
    v_dados(v_dados.last()).vr_nrctremp := 38565;
    v_dados(v_dados.last()).vr_vllanmto := 174.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20303;
    v_dados(v_dados.last()).vr_nrctremp := 38565;
    v_dados(v_dados.last()).vr_vllanmto := 162.74;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166472;
    v_dados(v_dados.last()).vr_nrctremp := 38594;
    v_dados(v_dados.last()).vr_vllanmto := 37.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166472;
    v_dados(v_dados.last()).vr_nrctremp := 38594;
    v_dados(v_dados.last()).vr_vllanmto := 34.89;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139521;
    v_dados(v_dados.last()).vr_nrctremp := 38619;
    v_dados(v_dados.last()).vr_vllanmto := 48.07;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139521;
    v_dados(v_dados.last()).vr_nrctremp := 38619;
    v_dados(v_dados.last()).vr_vllanmto := 44.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85588;
    v_dados(v_dados.last()).vr_nrctremp := 38737;
    v_dados(v_dados.last()).vr_vllanmto := 11.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67415;
    v_dados(v_dados.last()).vr_nrctremp := 38778;
    v_dados(v_dados.last()).vr_vllanmto := 24.64;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104027;
    v_dados(v_dados.last()).vr_nrctremp := 38875;
    v_dados(v_dados.last()).vr_vllanmto := 14.23;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20672;
    v_dados(v_dados.last()).vr_nrctremp := 38936;
    v_dados(v_dados.last()).vr_vllanmto := 13.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127582;
    v_dados(v_dados.last()).vr_nrctremp := 13745;
    v_dados(v_dados.last()).vr_vllanmto := .34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 42641;
    v_dados(v_dados.last()).vr_nrctremp := 15890;
    v_dados(v_dados.last()).vr_vllanmto := 121.28;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 167061;
    v_dados(v_dados.last()).vr_nrctremp := 18163;
    v_dados(v_dados.last()).vr_vllanmto := 40.4;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143677;
    v_dados(v_dados.last()).vr_nrctremp := 18206;
    v_dados(v_dados.last()).vr_vllanmto := 1530.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20672;
    v_dados(v_dados.last()).vr_nrctremp := 19384;
    v_dados(v_dados.last()).vr_vllanmto := 57.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143227;
    v_dados(v_dados.last()).vr_nrctremp := 21595;
    v_dados(v_dados.last()).vr_vllanmto := 1303.8;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 138274;
    v_dados(v_dados.last()).vr_nrctremp := 22949;
    v_dados(v_dados.last()).vr_vllanmto := 138.12;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 88153;
    v_dados(v_dados.last()).vr_nrctremp := 26420;
    v_dados(v_dados.last()).vr_vllanmto := 148.78;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 5797;
    v_dados(v_dados.last()).vr_nrctremp := 29441;
    v_dados(v_dados.last()).vr_vllanmto := 23.46;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 84840;
    v_dados(v_dados.last()).vr_nrctremp := 30015;
    v_dados(v_dados.last()).vr_vllanmto := 18.47;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127612;
    v_dados(v_dados.last()).vr_nrctremp := 30937;
    v_dados(v_dados.last()).vr_vllanmto := 9.73;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 40.74;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 2.99;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 121100;
    v_dados(v_dados.last()).vr_nrctremp := 33812;
    v_dados(v_dados.last()).vr_vllanmto := 17.87;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 93734;
    v_dados(v_dados.last()).vr_nrctremp := 34131;
    v_dados(v_dados.last()).vr_vllanmto := 14.39;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 34580;
    v_dados(v_dados.last()).vr_vllanmto := 13.17;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172545;
    v_dados(v_dados.last()).vr_nrctremp := 34826;
    v_dados(v_dados.last()).vr_vllanmto := 13.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152978;
    v_dados(v_dados.last()).vr_nrctremp := 34887;
    v_dados(v_dados.last()).vr_vllanmto := 9.8;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 148270;
    v_dados(v_dados.last()).vr_nrctremp := 36043;
    v_dados(v_dados.last()).vr_vllanmto := 1.24;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166693;
    v_dados(v_dados.last()).vr_nrctremp := 36303;
    v_dados(v_dados.last()).vr_vllanmto := 6.56;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140996;
    v_dados(v_dados.last()).vr_nrctremp := 13386;
    v_dados(v_dados.last()).vr_vllanmto := 615.75;
    v_dados(v_dados.last()).vr_cdhistor := 1040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 143367;
    v_dados(v_dados.last()).vr_nrctremp := 14164;
    v_dados(v_dados.last()).vr_vllanmto := 393.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 15757;
    v_dados(v_dados.last()).vr_vllanmto := 608.78;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152749;
    v_dados(v_dados.last()).vr_nrctremp := 17436;
    v_dados(v_dados.last()).vr_vllanmto := 118.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 105090;
    v_dados(v_dados.last()).vr_nrctremp := 17740;
    v_dados(v_dados.last()).vr_vllanmto := 170.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48038;
    v_dados(v_dados.last()).vr_nrctremp := 17883;
    v_dados(v_dados.last()).vr_vllanmto := 1.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166820;
    v_dados(v_dados.last()).vr_nrctremp := 18867;
    v_dados(v_dados.last()).vr_vllanmto := 253.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76910;
    v_dados(v_dados.last()).vr_nrctremp := 19065;
    v_dados(v_dados.last()).vr_vllanmto := 5.29;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76910;
    v_dados(v_dados.last()).vr_nrctremp := 19065;
    v_dados(v_dados.last()).vr_vllanmto := 16.28;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128244;
    v_dados(v_dados.last()).vr_nrctremp := 20022;
    v_dados(v_dados.last()).vr_vllanmto := .91;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141895;
    v_dados(v_dados.last()).vr_nrctremp := 20181;
    v_dados(v_dados.last()).vr_vllanmto := 2.71;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165450;
    v_dados(v_dados.last()).vr_nrctremp := 20342;
    v_dados(v_dados.last()).vr_vllanmto := 2.16;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 169854;
    v_dados(v_dados.last()).vr_nrctremp := 20352;
    v_dados(v_dados.last()).vr_vllanmto := 45.26;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 123358;
    v_dados(v_dados.last()).vr_nrctremp := 20419;
    v_dados(v_dados.last()).vr_vllanmto := .45;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 91952;
    v_dados(v_dados.last()).vr_nrctremp := 20906;
    v_dados(v_dados.last()).vr_vllanmto := 836.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154890;
    v_dados(v_dados.last()).vr_nrctremp := 21489;
    v_dados(v_dados.last()).vr_vllanmto := 63.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 148318;
    v_dados(v_dados.last()).vr_nrctremp := 21603;
    v_dados(v_dados.last()).vr_vllanmto := 119.54;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140554;
    v_dados(v_dados.last()).vr_nrctremp := 21866;
    v_dados(v_dados.last()).vr_vllanmto := 66.85;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 169927;
    v_dados(v_dados.last()).vr_nrctremp := 22132;
    v_dados(v_dados.last()).vr_vllanmto := .34;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 169927;
    v_dados(v_dados.last()).vr_nrctremp := 22132;
    v_dados(v_dados.last()).vr_vllanmto := 5.66;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 48038;
    v_dados(v_dados.last()).vr_nrctremp := 22133;
    v_dados(v_dados.last()).vr_vllanmto := 7.15;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140473;
    v_dados(v_dados.last()).vr_nrctremp := 22520;
    v_dados(v_dados.last()).vr_vllanmto := 1.66;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 140473;
    v_dados(v_dados.last()).vr_nrctremp := 22520;
    v_dados(v_dados.last()).vr_vllanmto := 26.14;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 25048;
    v_dados(v_dados.last()).vr_vllanmto := 69.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184063;
    v_dados(v_dados.last()).vr_nrctremp := 28875;
    v_dados(v_dados.last()).vr_vllanmto := 42.14;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184063;
    v_dados(v_dados.last()).vr_nrctremp := 28875;
    v_dados(v_dados.last()).vr_vllanmto := 20.69;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190713;
    v_dados(v_dados.last()).vr_nrctremp := 30270;
    v_dados(v_dados.last()).vr_vllanmto := 5.3;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190713;
    v_dados(v_dados.last()).vr_nrctremp := 30270;
    v_dados(v_dados.last()).vr_vllanmto := 16.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 163007;
    v_dados(v_dados.last()).vr_nrctremp := 30697;
    v_dados(v_dados.last()).vr_vllanmto := 7.71;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 163007;
    v_dados(v_dados.last()).vr_nrctremp := 30697;
    v_dados(v_dados.last()).vr_vllanmto := 23.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154415;
    v_dados(v_dados.last()).vr_nrctremp := 30714;
    v_dados(v_dados.last()).vr_vllanmto := .81;
    v_dados(v_dados.last()).vr_cdhistor := 1037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154415;
    v_dados(v_dados.last()).vr_nrctremp := 30714;
    v_dados(v_dados.last()).vr_vllanmto := 2.61;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 32159;
    v_dados(v_dados.last()).vr_vllanmto := 535.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183989;
    v_dados(v_dados.last()).vr_nrctremp := 33015;
    v_dados(v_dados.last()).vr_vllanmto := .24;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 183989;
    v_dados(v_dados.last()).vr_nrctremp := 33015;
    v_dados(v_dados.last()).vr_vllanmto := 1.1;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 7.69;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 2.66;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127388;
    v_dados(v_dados.last()).vr_nrctremp := 35170;
    v_dados(v_dados.last()).vr_vllanmto := 7.23;
    v_dados(v_dados.last()).vr_cdhistor := 1037;


  
  FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
      FETCH cecred.btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE cecred.btch0001.cr_crapdat;
      OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
  
      cecred.EMPR0001.pc_cria_lancamento_lem( pr_cdcooper => v_dados(x).vr_cdcooper,
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
end;
