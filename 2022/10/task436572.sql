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
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 76368;
    v_dados(v_dados.last()).vr_nrctremp := 11017;
    v_dados(v_dados.last()).vr_vllanmto := .43;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 20290;
    v_dados(v_dados.last()).vr_nrctremp := 11604;
    v_dados(v_dados.last()).vr_vllanmto := 222.6;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77380;
    v_dados(v_dados.last()).vr_nrctremp := 11756;
    v_dados(v_dados.last()).vr_vllanmto := 1.79;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 120499;
    v_dados(v_dados.last()).vr_nrctremp := 12216;
    v_dados(v_dados.last()).vr_vllanmto := 169.39;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

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
    v_dados(v_dados.last()).vr_vllanmto := 156.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108898;
    v_dados(v_dados.last()).vr_nrctremp := 13288;
    v_dados(v_dados.last()).vr_vllanmto := 2914.52;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147893;
    v_dados(v_dados.last()).vr_nrctremp := 15952;
    v_dados(v_dados.last()).vr_vllanmto := 8.85;
    v_dados(v_dados.last()).vr_cdhistor := 3917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 103748;
    v_dados(v_dados.last()).vr_nrctremp := 16479;
    v_dados(v_dados.last()).vr_vllanmto := 230.21;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 106739;
    v_dados(v_dados.last()).vr_nrctremp := 16580;
    v_dados(v_dados.last()).vr_vllanmto := 879.25;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152749;
    v_dados(v_dados.last()).vr_nrctremp := 17436;
    v_dados(v_dados.last()).vr_vllanmto := 118.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 165298;
    v_dados(v_dados.last()).vr_nrctremp := 19286;
    v_dados(v_dados.last()).vr_vllanmto := 32.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128244;
    v_dados(v_dados.last()).vr_nrctremp := 20022;
    v_dados(v_dados.last()).vr_vllanmto := 14.51;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129100;
    v_dados(v_dados.last()).vr_nrctremp := 20657;
    v_dados(v_dados.last()).vr_vllanmto := 30.46;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73130;
    v_dados(v_dados.last()).vr_nrctremp := 20750;
    v_dados(v_dados.last()).vr_vllanmto := 84.17;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164291;
    v_dados(v_dados.last()).vr_nrctremp := 20796;
    v_dados(v_dados.last()).vr_vllanmto := 66.48;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145122;
    v_dados(v_dados.last()).vr_nrctremp := 20797;
    v_dados(v_dados.last()).vr_vllanmto := 79.69;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 86177;
    v_dados(v_dados.last()).vr_nrctremp := 20920;
    v_dados(v_dados.last()).vr_vllanmto := .73;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108804;
    v_dados(v_dados.last()).vr_nrctremp := 21233;
    v_dados(v_dados.last()).vr_vllanmto := 127.49;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 154890;
    v_dados(v_dados.last()).vr_nrctremp := 21489;
    v_dados(v_dados.last()).vr_vllanmto := 63.93;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142867;
    v_dados(v_dados.last()).vr_nrctremp := 21554;
    v_dados(v_dados.last()).vr_vllanmto := 38.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152080;
    v_dados(v_dados.last()).vr_nrctremp := 21626;
    v_dados(v_dados.last()).vr_vllanmto := 127.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85065;
    v_dados(v_dados.last()).vr_nrctremp := 22767;
    v_dados(v_dados.last()).vr_vllanmto := 77.92;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 128481;
    v_dados(v_dados.last()).vr_nrctremp := 25048;
    v_dados(v_dados.last()).vr_vllanmto := 69.01;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 151017;
    v_dados(v_dados.last()).vr_nrctremp := 25746;
    v_dados(v_dados.last()).vr_vllanmto := 8.04;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 83682;
    v_dados(v_dados.last()).vr_nrctremp := 26001;
    v_dados(v_dados.last()).vr_vllanmto := 64.72;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 73164;
    v_dados(v_dados.last()).vr_nrctremp := 26413;
    v_dados(v_dados.last()).vr_vllanmto := 86.3;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 29025;
    v_dados(v_dados.last()).vr_nrctremp := 26466;
    v_dados(v_dados.last()).vr_vllanmto := 97.93;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164321;
    v_dados(v_dados.last()).vr_nrctremp := 28487;
    v_dados(v_dados.last()).vr_vllanmto := 41.02;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184063;
    v_dados(v_dados.last()).vr_nrctremp := 28875;
    v_dados(v_dados.last()).vr_vllanmto := 62.83;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 5797;
    v_dados(v_dados.last()).vr_nrctremp := 29441;
    v_dados(v_dados.last()).vr_vllanmto := .64;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77542;
    v_dados(v_dados.last()).vr_nrctremp := 29750;
    v_dados(v_dados.last()).vr_vllanmto := 86.56;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116661;
    v_dados(v_dados.last()).vr_nrctremp := 31685;
    v_dados(v_dados.last()).vr_vllanmto := 45.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141623;
    v_dados(v_dados.last()).vr_nrctremp := 31901;
    v_dados(v_dados.last()).vr_vllanmto := 31.52;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 47694;
    v_dados(v_dados.last()).vr_nrctremp := 32701;
    v_dados(v_dados.last()).vr_vllanmto := .62;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 77038;
    v_dados(v_dados.last()).vr_nrctremp := 32862;
    v_dados(v_dados.last()).vr_vllanmto := 294.34;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184039;
    v_dados(v_dados.last()).vr_nrctremp := 32925;
    v_dados(v_dados.last()).vr_vllanmto := 45.32;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139050;
    v_dados(v_dados.last()).vr_nrctremp := 33535;
    v_dados(v_dados.last()).vr_vllanmto := 8.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 194719;
    v_dados(v_dados.last()).vr_nrctremp := 33742;
    v_dados(v_dados.last()).vr_vllanmto := 40.4;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 133078;
    v_dados(v_dados.last()).vr_nrctremp := 33797;
    v_dados(v_dados.last()).vr_vllanmto := 549.45;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 200255;
    v_dados(v_dados.last()).vr_nrctremp := 34029;
    v_dados(v_dados.last()).vr_vllanmto := 35.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 71145;
    v_dados(v_dados.last()).vr_nrctremp := 34416;
    v_dados(v_dados.last()).vr_vllanmto := 63.51;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 108286;
    v_dados(v_dados.last()).vr_nrctremp := 34780;
    v_dados(v_dados.last()).vr_vllanmto := 6.12;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 172545;
    v_dados(v_dados.last()).vr_nrctremp := 34826;
    v_dados(v_dados.last()).vr_vllanmto := 62.4;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 152978;
    v_dados(v_dados.last()).vr_nrctremp := 34887;
    v_dados(v_dados.last()).vr_vllanmto := 87.27;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 142581;
    v_dados(v_dados.last()).vr_nrctremp := 35077;
    v_dados(v_dados.last()).vr_vllanmto := 176.5;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127388;
    v_dados(v_dados.last()).vr_nrctremp := 35170;
    v_dados(v_dados.last()).vr_vllanmto := 74.25;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 164224;
    v_dados(v_dados.last()).vr_nrctremp := 35597;
    v_dados(v_dados.last()).vr_vllanmto := 4.08;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 166561;
    v_dados(v_dados.last()).vr_nrctremp := 36045;
    v_dados(v_dados.last()).vr_vllanmto := 36.51;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 216410;
    v_dados(v_dados.last()).vr_nrctremp := 36991;
    v_dados(v_dados.last()).vr_vllanmto := 30.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 184047;
    v_dados(v_dados.last()).vr_nrctremp := 37243;
    v_dados(v_dados.last()).vr_vllanmto := 37.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115908;
    v_dados(v_dados.last()).vr_nrctremp := 37902;
    v_dados(v_dados.last()).vr_vllanmto := 215.33;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 198960;
    v_dados(v_dados.last()).vr_nrctremp := 38243;
    v_dados(v_dados.last()).vr_vllanmto := 72.19;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94960;
    v_dados(v_dados.last()).vr_nrctremp := 38465;
    v_dados(v_dados.last()).vr_vllanmto := 37.55;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 49719;
    v_dados(v_dados.last()).vr_nrctremp := 38508;
    v_dados(v_dados.last()).vr_vllanmto := 31.31;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 85588;
    v_dados(v_dados.last()).vr_nrctremp := 38737;
    v_dados(v_dados.last()).vr_vllanmto := 36.68;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 67415;
    v_dados(v_dados.last()).vr_nrctremp := 38778;
    v_dados(v_dados.last()).vr_vllanmto := 51.33;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 196657;
    v_dados(v_dados.last()).vr_nrctremp := 39031;
    v_dados(v_dados.last()).vr_vllanmto := 50.99;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 104043;
    v_dados(v_dados.last()).vr_nrctremp := 39048;
    v_dados(v_dados.last()).vr_vllanmto := 34.88;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168238;
    v_dados(v_dados.last()).vr_nrctremp := 39496;
    v_dados(v_dados.last()).vr_vllanmto := 19.05;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 179566;
    v_dados(v_dados.last()).vr_nrctremp := 39528;
    v_dados(v_dados.last()).vr_vllanmto := 31.22;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 131601;
    v_dados(v_dados.last()).vr_nrctremp := 39667;
    v_dados(v_dados.last()).vr_vllanmto := 21.53;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 94943;
    v_dados(v_dados.last()).vr_nrctremp := 39670;
    v_dados(v_dados.last()).vr_vllanmto := 1330.66;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 127574;
    v_dados(v_dados.last()).vr_nrctremp := 39898;
    v_dados(v_dados.last()).vr_vllanmto := 5.62;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 147753;
    v_dados(v_dados.last()).vr_nrctremp := 39965;
    v_dados(v_dados.last()).vr_vllanmto := 3.65;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 115479;
    v_dados(v_dados.last()).vr_nrctremp := 40121;
    v_dados(v_dados.last()).vr_vllanmto := 4.76;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 186961;
    v_dados(v_dados.last()).vr_nrctremp := 40136;
    v_dados(v_dados.last()).vr_vllanmto := 256.84;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 117463;
    v_dados(v_dados.last()).vr_nrctremp := 40166;
    v_dados(v_dados.last()).vr_vllanmto := 8.84;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 4294;
    v_dados(v_dados.last()).vr_nrctremp := 40170;
    v_dados(v_dados.last()).vr_vllanmto := 12.03;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 168572;
    v_dados(v_dados.last()).vr_nrctremp := 40256;
    v_dados(v_dados.last()).vr_vllanmto := 12.16;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 105155;
    v_dados(v_dados.last()).vr_nrctremp := 40603;
    v_dados(v_dados.last()).vr_vllanmto := 3.17;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 237930;
    v_dados(v_dados.last()).vr_nrctremp := 40622;
    v_dados(v_dados.last()).vr_vllanmto := 1.14;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 14925044;
    v_dados(v_dados.last()).vr_nrctremp := 40646;
    v_dados(v_dados.last()).vr_vllanmto := 7.41;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 132012;
    v_dados(v_dados.last()).vr_nrctremp := 40674;
    v_dados(v_dados.last()).vr_vllanmto := 1321.48;
    v_dados(v_dados.last()).vr_cdhistor := 3918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 141046;
    v_dados(v_dados.last()).vr_nrctremp := 40952;
    v_dados(v_dados.last()).vr_vllanmto := 1652.92;
    v_dados(v_dados.last()).vr_cdhistor := 3919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 15030032;
    v_dados(v_dados.last()).vr_nrctremp := 41069;
    v_dados(v_dados.last()).vr_vllanmto := 4.37;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 239445;
    v_dados(v_dados.last()).vr_nrctremp := 41131;
    v_dados(v_dados.last()).vr_vllanmto := 4.6;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 129879;
    v_dados(v_dados.last()).vr_nrctremp := 41211;
    v_dados(v_dados.last()).vr_vllanmto := 1.11;
    v_dados(v_dados.last()).vr_cdhistor := 3883;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 171069;
    v_dados(v_dados.last()).vr_nrctremp := 41213;
    v_dados(v_dados.last()).vr_vllanmto := .65;
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
