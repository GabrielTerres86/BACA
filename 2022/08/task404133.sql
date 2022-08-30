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
  v_dados(v_dados.last()).vr_nrdconta := 66494;
  v_dados(v_dados.last()).vr_nrctremp := 10676;
  v_dados(v_dados.last()).vr_vllanmto := 997.93;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 20290;
  v_dados(v_dados.last()).vr_nrctremp := 11604;
  v_dados(v_dados.last()).vr_vllanmto := 172.92;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 120499;
  v_dados(v_dados.last()).vr_nrctremp := 12216;
  v_dados(v_dados.last()).vr_vllanmto := 158.27;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 4588;
  v_dados(v_dados.last()).vr_nrctremp := 12269;
  v_dados(v_dados.last()).vr_vllanmto := 9.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 109207;
  v_dados(v_dados.last()).vr_nrctremp := 12749;
  v_dados(v_dados.last()).vr_vllanmto := 48.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 76449;
  v_dados(v_dados.last()).vr_nrctremp := 13040;
  v_dados(v_dados.last()).vr_vllanmto := 76.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 156337;
  v_dados(v_dados.last()).vr_nrctremp := 13135;
  v_dados(v_dados.last()).vr_vllanmto := 615.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 127582;
  v_dados(v_dados.last()).vr_nrctremp := 13745;
  v_dados(v_dados.last()).vr_vllanmto := 14.46;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 145122;
  v_dados(v_dados.last()).vr_nrctremp := 14113;
  v_dados(v_dados.last()).vr_vllanmto := 65.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143324;
  v_dados(v_dados.last()).vr_nrctremp := 14165;
  v_dados(v_dados.last()).vr_vllanmto := 16.86;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 79359;
  v_dados(v_dados.last()).vr_nrctremp := 14930;
  v_dados(v_dados.last()).vr_vllanmto := 237.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 119717;
  v_dados(v_dados.last()).vr_nrctremp := 15448;
  v_dados(v_dados.last()).vr_vllanmto := 174.8;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 42641;
  v_dados(v_dados.last()).vr_nrctremp := 15890;
  v_dados(v_dados.last()).vr_vllanmto := 201.48;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 56987;
  v_dados(v_dados.last()).vr_nrctremp := 15962;
  v_dados(v_dados.last()).vr_vllanmto := 58.96;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 103748;
  v_dados(v_dados.last()).vr_nrctremp := 16479;
  v_dados(v_dados.last()).vr_vllanmto := 212.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 106739;
  v_dados(v_dados.last()).vr_nrctremp := 16580;
  v_dados(v_dados.last()).vr_vllanmto := 879.25;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152749;
  v_dados(v_dados.last()).vr_nrctremp := 17436;
  v_dados(v_dados.last()).vr_vllanmto := 118.34;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 167061;
  v_dados(v_dados.last()).vr_nrctremp := 18163;
  v_dados(v_dados.last()).vr_vllanmto := 284.04;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 143677;
  v_dados(v_dados.last()).vr_nrctremp := 18206;
  v_dados(v_dados.last()).vr_vllanmto := 9.67;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166820;
  v_dados(v_dados.last()).vr_nrctremp := 18867;
  v_dados(v_dados.last()).vr_vllanmto := 1017.79;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128244;
  v_dados(v_dados.last()).vr_nrctremp := 20022;
  v_dados(v_dados.last()).vr_vllanmto := .08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 141941;
  v_dados(v_dados.last()).vr_nrctremp := 20085;
  v_dados(v_dados.last()).vr_vllanmto := 121.05;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 141895;
  v_dados(v_dados.last()).vr_nrctremp := 20181;
  v_dados(v_dados.last()).vr_vllanmto := 2.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 129100;
  v_dados(v_dados.last()).vr_nrctremp := 20657;
  v_dados(v_dados.last()).vr_vllanmto := 58.97;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73130;
  v_dados(v_dados.last()).vr_nrctremp := 20750;
  v_dados(v_dados.last()).vr_vllanmto := 83.91;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 107239;
  v_dados(v_dados.last()).vr_nrctremp := 20794;
  v_dados(v_dados.last()).vr_vllanmto := 10.72;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 145122;
  v_dados(v_dados.last()).vr_nrctremp := 20797;
  v_dados(v_dados.last()).vr_vllanmto := 71.85;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 91952;
  v_dados(v_dados.last()).vr_nrctremp := 20906;
  v_dados(v_dados.last()).vr_vllanmto := 836.31;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 86177;
  v_dados(v_dados.last()).vr_nrctremp := 20920;
  v_dados(v_dados.last()).vr_vllanmto := 252.82;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108804;
  v_dados(v_dados.last()).vr_nrctremp := 21233;
  v_dados(v_dados.last()).vr_vllanmto := 113.2;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 154890;
  v_dados(v_dados.last()).vr_nrctremp := 21489;
  v_dados(v_dados.last()).vr_vllanmto := 63.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152080;
  v_dados(v_dados.last()).vr_nrctremp := 21626;
  v_dados(v_dados.last()).vr_vllanmto := 102.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 140554;
  v_dados(v_dados.last()).vr_nrctremp := 21866;
  v_dados(v_dados.last()).vr_vllanmto := 66.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 48038;
  v_dados(v_dados.last()).vr_nrctremp := 22133;
  v_dados(v_dados.last()).vr_vllanmto := 7.15;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 138274;
  v_dados(v_dados.last()).vr_nrctremp := 22949;
  v_dados(v_dados.last()).vr_vllanmto := 102.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166499;
  v_dados(v_dados.last()).vr_nrctremp := 23514;
  v_dados(v_dados.last()).vr_vllanmto := 71.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 46469;
  v_dados(v_dados.last()).vr_nrctremp := 24157;
  v_dados(v_dados.last()).vr_vllanmto := .49;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 176907;
  v_dados(v_dados.last()).vr_nrctremp := 24267;
  v_dados(v_dados.last()).vr_vllanmto := 52.59;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 125873;
  v_dados(v_dados.last()).vr_nrctremp := 24290;
  v_dados(v_dados.last()).vr_vllanmto := 22.2;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49956;
  v_dados(v_dados.last()).vr_nrctremp := 24468;
  v_dados(v_dados.last()).vr_vllanmto := 58.78;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166634;
  v_dados(v_dados.last()).vr_nrctremp := 24549;
  v_dados(v_dados.last()).vr_vllanmto := 50.08;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128481;
  v_dados(v_dados.last()).vr_nrctremp := 25048;
  v_dados(v_dados.last()).vr_vllanmto := 69.01;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 88153;
  v_dados(v_dados.last()).vr_nrctremp := 26420;
  v_dados(v_dados.last()).vr_vllanmto := 179.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 187917;
  v_dados(v_dados.last()).vr_nrctremp := 27006;
  v_dados(v_dados.last()).vr_vllanmto := 53.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166480;
  v_dados(v_dados.last()).vr_nrctremp := 28356;
  v_dados(v_dados.last()).vr_vllanmto := 7.84;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 73148;
  v_dados(v_dados.last()).vr_nrctremp := 28670;
  v_dados(v_dados.last()).vr_vllanmto := 50.68;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 104990;
  v_dados(v_dados.last()).vr_nrctremp := 28692;
  v_dados(v_dados.last()).vr_vllanmto := 484.65;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184063;
  v_dados(v_dados.last()).vr_nrctremp := 28875;
  v_dados(v_dados.last()).vr_vllanmto := 62.83;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49794;
  v_dados(v_dados.last()).vr_nrctremp := 29556;
  v_dados(v_dados.last()).vr_vllanmto := 20.11;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77542;
  v_dados(v_dados.last()).vr_nrctremp := 29750;
  v_dados(v_dados.last()).vr_vllanmto := 70.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 72966;
  v_dados(v_dados.last()).vr_nrctremp := 29759;
  v_dados(v_dados.last()).vr_vllanmto := 178.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 84840;
  v_dados(v_dados.last()).vr_nrctremp := 30015;
  v_dados(v_dados.last()).vr_vllanmto := 60.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 90662;
  v_dados(v_dados.last()).vr_nrctremp := 30402;
  v_dados(v_dados.last()).vr_vllanmto := 36.73;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 104990;
  v_dados(v_dados.last()).vr_nrctremp := 31621;
  v_dados(v_dados.last()).vr_vllanmto := 411.03;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 77038;
  v_dados(v_dados.last()).vr_nrctremp := 32862;
  v_dados(v_dados.last()).vr_vllanmto := 99.52;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 184039;
  v_dados(v_dados.last()).vr_nrctremp := 32925;
  v_dados(v_dados.last()).vr_vllanmto := 45.32;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 139050;
  v_dados(v_dados.last()).vr_nrctremp := 33535;
  v_dados(v_dados.last()).vr_vllanmto := 19.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166863;
  v_dados(v_dados.last()).vr_nrctremp := 33682;
  v_dados(v_dados.last()).vr_vllanmto := 35.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 133078;
  v_dados(v_dados.last()).vr_nrctremp := 33797;
  v_dados(v_dados.last()).vr_vllanmto := 356.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 128481;
  v_dados(v_dados.last()).vr_nrctremp := 34580;
  v_dados(v_dados.last()).vr_vllanmto := 47.18;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 108286;
  v_dados(v_dados.last()).vr_nrctremp := 34780;
  v_dados(v_dados.last()).vr_vllanmto := 79.41;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 152978;
  v_dados(v_dados.last()).vr_nrctremp := 34887;
  v_dados(v_dados.last()).vr_vllanmto := 87.27;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 166561;
  v_dados(v_dados.last()).vr_nrctremp := 36045;
  v_dados(v_dados.last()).vr_vllanmto := 26.55;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 220035;
  v_dados(v_dados.last()).vr_nrctremp := 36437;
  v_dados(v_dados.last()).vr_vllanmto := 366.31;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 147753;
  v_dados(v_dados.last()).vr_nrctremp := 37039;
  v_dados(v_dados.last()).vr_vllanmto := 222.05;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 198960;
  v_dados(v_dados.last()).vr_nrctremp := 38243;
  v_dados(v_dados.last()).vr_vllanmto := 100.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 80470;
  v_dados(v_dados.last()).vr_nrctremp := 38357;
  v_dados(v_dados.last()).vr_vllanmto := 10.16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 94960;
  v_dados(v_dados.last()).vr_nrctremp := 38465;
  v_dados(v_dados.last()).vr_vllanmto := 22.78;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 210153;
  v_dados(v_dados.last()).vr_nrctremp := 38485;
  v_dados(v_dados.last()).vr_vllanmto := 7.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 49719;
  v_dados(v_dados.last()).vr_nrctremp := 38508;
  v_dados(v_dados.last()).vr_vllanmto := 19.95;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 139521;
  v_dados(v_dados.last()).vr_nrctremp := 38619;
  v_dados(v_dados.last()).vr_vllanmto := 15.4;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 85588;
  v_dados(v_dados.last()).vr_nrctremp := 38737;
  v_dados(v_dados.last()).vr_vllanmto := 15.53;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 104043;
  v_dados(v_dados.last()).vr_nrctremp := 39048;
  v_dados(v_dados.last()).vr_vllanmto := 13.09;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 10;
  v_dados(v_dados.last()).vr_nrdconta := 179566;
  v_dados(v_dados.last()).vr_nrctremp := 39528;
  v_dados(v_dados.last()).vr_vllanmto := 14.17;
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
