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
  v_dados(v_dados.last()).vr_nrdconta := 9377;
  v_dados(v_dados.last()).vr_nrctremp := 170013;
  v_dados(v_dados.last()).vr_vllanmto := 21.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 9482;
  v_dados(v_dados.last()).vr_nrctremp := 166510;
  v_dados(v_dados.last()).vr_vllanmto := 27.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26590;
  v_dados(v_dados.last()).vr_nrctremp := 61342;
  v_dados(v_dados.last()).vr_vllanmto := 152.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 26670;
  v_dados(v_dados.last()).vr_nrctremp := 73346;
  v_dados(v_dados.last()).vr_vllanmto := 116.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 33294;
  v_dados(v_dados.last()).vr_nrctremp := 116931;
  v_dados(v_dados.last()).vr_vllanmto := 79.71;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 64955;
  v_dados(v_dados.last()).vr_nrctremp := 98020;
  v_dados(v_dados.last()).vr_vllanmto := 51.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 65692;
  v_dados(v_dados.last()).vr_nrctremp := 87320;
  v_dados(v_dados.last()).vr_vllanmto := 118.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66605;
  v_dados(v_dados.last()).vr_nrctremp := 150339;
  v_dados(v_dados.last()).vr_vllanmto := 73.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66613;
  v_dados(v_dados.last()).vr_nrctremp := 207517;
  v_dados(v_dados.last()).vr_vllanmto := 317.55;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 66940;
  v_dados(v_dados.last()).vr_nrctremp := 142854;
  v_dados(v_dados.last()).vr_vllanmto := 53.49;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 67261;
  v_dados(v_dados.last()).vr_nrctremp := 138194;
  v_dados(v_dados.last()).vr_vllanmto := 88.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 76961;
  v_dados(v_dados.last()).vr_nrctremp := 93710;
  v_dados(v_dados.last()).vr_vllanmto := 33.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 77895;
  v_dados(v_dados.last()).vr_nrctremp := 75192;
  v_dados(v_dados.last()).vr_vllanmto := 230.41;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 78727;
  v_dados(v_dados.last()).vr_nrctremp := 71631;
  v_dados(v_dados.last()).vr_vllanmto := 204.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 84085;
  v_dados(v_dados.last()).vr_nrctremp := 51903;
  v_dados(v_dados.last()).vr_vllanmto := 222.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 88480;
  v_dados(v_dados.last()).vr_nrctremp := 97562;
  v_dados(v_dados.last()).vr_vllanmto := 32.95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 90000;
  v_dados(v_dados.last()).vr_nrctremp := 129809;
  v_dados(v_dados.last()).vr_vllanmto := 33.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 91995;
  v_dados(v_dados.last()).vr_nrctremp := 126548;
  v_dados(v_dados.last()).vr_vllanmto := 39.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92029;
  v_dados(v_dados.last()).vr_nrctremp := 123921;
  v_dados(v_dados.last()).vr_vllanmto := 81.65;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92240;
  v_dados(v_dados.last()).vr_nrctremp := 131646;
  v_dados(v_dados.last()).vr_vllanmto := 959.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92665;
  v_dados(v_dados.last()).vr_nrctremp := 59179;
  v_dados(v_dados.last()).vr_vllanmto := 175.84;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 92690;
  v_dados(v_dados.last()).vr_nrctremp := 58634;
  v_dados(v_dados.last()).vr_vllanmto := 71.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 93289;
  v_dados(v_dados.last()).vr_nrctremp := 51375;
  v_dados(v_dados.last()).vr_vllanmto := 427.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 94722;
  v_dados(v_dados.last()).vr_nrctremp := 137035;
  v_dados(v_dados.last()).vr_vllanmto := 51.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 95257;
  v_dados(v_dados.last()).vr_nrctremp := 114045;
  v_dados(v_dados.last()).vr_vllanmto := 60;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 95532;
  v_dados(v_dados.last()).vr_nrctremp := 68569;
  v_dados(v_dados.last()).vr_vllanmto := 69.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 100161;
  v_dados(v_dados.last()).vr_nrctremp := 56319;
  v_dados(v_dados.last()).vr_vllanmto := 35.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 102822;
  v_dados(v_dados.last()).vr_nrctremp := 163575;
  v_dados(v_dados.last()).vr_vllanmto := 14.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 103861;
  v_dados(v_dados.last()).vr_nrctremp := 134554;
  v_dados(v_dados.last()).vr_vllanmto := 76.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 105295;
  v_dados(v_dados.last()).vr_nrctremp := 109809;
  v_dados(v_dados.last()).vr_vllanmto := 29.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116491;
  v_dados(v_dados.last()).vr_nrctremp := 114060;
  v_dados(v_dados.last()).vr_vllanmto := 106.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 116530;
  v_dados(v_dados.last()).vr_nrctremp := 67611;
  v_dados(v_dados.last()).vr_vllanmto := 408.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 120618;
  v_dados(v_dados.last()).vr_nrctremp := 104378;
  v_dados(v_dados.last()).vr_vllanmto := 132.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 126926;
  v_dados(v_dados.last()).vr_nrctremp := 57415;
  v_dados(v_dados.last()).vr_vllanmto := 46.02;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 127809;
  v_dados(v_dados.last()).vr_nrctremp := 90393;
  v_dados(v_dados.last()).vr_vllanmto := 271.33;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129860;
  v_dados(v_dados.last()).vr_nrctremp := 139883;
  v_dados(v_dados.last()).vr_vllanmto := 16.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 129860;
  v_dados(v_dados.last()).vr_nrctremp := 155283;
  v_dados(v_dados.last()).vr_vllanmto := 14.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 130923;
  v_dados(v_dados.last()).vr_nrctremp := 150081;
  v_dados(v_dados.last()).vr_vllanmto := 14.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 131792;
  v_dados(v_dados.last()).vr_nrctremp := 125819;
  v_dados(v_dados.last()).vr_vllanmto := 49.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136050;
  v_dados(v_dados.last()).vr_nrctremp := 168147;
  v_dados(v_dados.last()).vr_vllanmto := 10.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 136352;
  v_dados(v_dados.last()).vr_nrctremp := 187976;
  v_dados(v_dados.last()).vr_vllanmto := 401.9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 138207;
  v_dados(v_dados.last()).vr_nrctremp := 51622;
  v_dados(v_dados.last()).vr_vllanmto := 199.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143030;
  v_dados(v_dados.last()).vr_nrctremp := 94900;
  v_dados(v_dados.last()).vr_vllanmto := 21.7;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 143782;
  v_dados(v_dados.last()).vr_nrctremp := 111511;
  v_dados(v_dados.last()).vr_vllanmto := 16576.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 144053;
  v_dados(v_dados.last()).vr_nrctremp := 102361;
  v_dados(v_dados.last()).vr_vllanmto := 46.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145947;
  v_dados(v_dados.last()).vr_nrctremp := 56091;
  v_dados(v_dados.last()).vr_vllanmto := 97.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 145998;
  v_dados(v_dados.last()).vr_nrctremp := 145708;
  v_dados(v_dados.last()).vr_vllanmto := 14.7;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146153;
  v_dados(v_dados.last()).vr_nrctremp := 136699;
  v_dados(v_dados.last()).vr_vllanmto := 442.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146153;
  v_dados(v_dados.last()).vr_nrctremp := 147274;
  v_dados(v_dados.last()).vr_vllanmto := 21.95;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146218;
  v_dados(v_dados.last()).vr_nrctremp := 53589;
  v_dados(v_dados.last()).vr_vllanmto := 294.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146471;
  v_dados(v_dados.last()).vr_nrctremp := 129089;
  v_dados(v_dados.last()).vr_vllanmto := 14.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 146625;
  v_dados(v_dados.last()).vr_nrctremp := 96582;
  v_dados(v_dados.last()).vr_vllanmto := 22.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149039;
  v_dados(v_dados.last()).vr_nrctremp := 88625;
  v_dados(v_dados.last()).vr_vllanmto := 60.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 149632;
  v_dados(v_dados.last()).vr_nrctremp := 133556;
  v_dados(v_dados.last()).vr_vllanmto := 36.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150215;
  v_dados(v_dados.last()).vr_nrctremp := 52249;
  v_dados(v_dados.last()).vr_vllanmto := 574.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150304;
  v_dados(v_dados.last()).vr_nrctremp := 59164;
  v_dados(v_dados.last()).vr_vllanmto := 103.8;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150550;
  v_dados(v_dados.last()).vr_nrctremp := 146498;
  v_dados(v_dados.last()).vr_vllanmto := 45.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 150991;
  v_dados(v_dados.last()).vr_nrctremp := 133605;
  v_dados(v_dados.last()).vr_vllanmto := 40.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153397;
  v_dados(v_dados.last()).vr_nrctremp := 135768;
  v_dados(v_dados.last()).vr_vllanmto := 72.65;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 153397;
  v_dados(v_dados.last()).vr_nrctremp := 135769;
  v_dados(v_dados.last()).vr_vllanmto := 13.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154466;
  v_dados(v_dados.last()).vr_nrctremp := 99993;
  v_dados(v_dados.last()).vr_vllanmto := 868.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154520;
  v_dados(v_dados.last()).vr_nrctremp := 96390;
  v_dados(v_dados.last()).vr_vllanmto := 282.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 154601;
  v_dados(v_dados.last()).vr_nrctremp := 58949;
  v_dados(v_dados.last()).vr_vllanmto := 139.35;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 156540;
  v_dados(v_dados.last()).vr_nrctremp := 120078;
  v_dados(v_dados.last()).vr_vllanmto := 25.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 158305;
  v_dados(v_dados.last()).vr_nrctremp := 57412;
  v_dados(v_dados.last()).vr_vllanmto := 25.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 160318;
  v_dados(v_dados.last()).vr_nrctremp := 110736;
  v_dados(v_dados.last()).vr_vllanmto := 11.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 161110;
  v_dados(v_dados.last()).vr_nrctremp := 103295;
  v_dados(v_dados.last()).vr_vllanmto := 486.23;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 161110;
  v_dados(v_dados.last()).vr_nrctremp := 103296;
  v_dados(v_dados.last()).vr_vllanmto := 48.01;
  v_dados(v_dados.last()).vr_cdhistor := 1041;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163384;
  v_dados(v_dados.last()).vr_nrctremp := 95795;
  v_dados(v_dados.last()).vr_vllanmto := 595.43;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 163767;
  v_dados(v_dados.last()).vr_nrctremp := 87851;
  v_dados(v_dados.last()).vr_vllanmto := 16.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 169277;
  v_dados(v_dados.last()).vr_nrctremp := 82388;
  v_dados(v_dados.last()).vr_vllanmto := 41.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 170305;
  v_dados(v_dados.last()).vr_nrctremp := 122762;
  v_dados(v_dados.last()).vr_vllanmto := 24.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 171824;
  v_dados(v_dados.last()).vr_nrctremp := 110909;
  v_dados(v_dados.last()).vr_vllanmto := 19.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172618;
  v_dados(v_dados.last()).vr_nrctremp := 62996;
  v_dados(v_dados.last()).vr_vllanmto := 28.02;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 172618;
  v_dados(v_dados.last()).vr_nrctremp := 87115;
  v_dados(v_dados.last()).vr_vllanmto := 33.12;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 174874;
  v_dados(v_dados.last()).vr_nrctremp := 51025;
  v_dados(v_dados.last()).vr_vllanmto := 184.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 178896;
  v_dados(v_dados.last()).vr_nrctremp := 71105;
  v_dados(v_dados.last()).vr_vllanmto := 31.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179922;
  v_dados(v_dados.last()).vr_nrctremp := 83766;
  v_dados(v_dados.last()).vr_vllanmto := 111.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179922;
  v_dados(v_dados.last()).vr_nrctremp := 83772;
  v_dados(v_dados.last()).vr_vllanmto := 16.91;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 179922;
  v_dados(v_dados.last()).vr_nrctremp := 196857;
  v_dados(v_dados.last()).vr_vllanmto := 11.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 182702;
  v_dados(v_dados.last()).vr_nrctremp := 53514;
  v_dados(v_dados.last()).vr_vllanmto := 394.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 182958;
  v_dados(v_dados.last()).vr_nrctremp := 103395;
  v_dados(v_dados.last()).vr_vllanmto := 22.26;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185000;
  v_dados(v_dados.last()).vr_nrctremp := 56753;
  v_dados(v_dados.last()).vr_vllanmto := 1406.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185272;
  v_dados(v_dados.last()).vr_nrctremp := 139153;
  v_dados(v_dados.last()).vr_vllanmto := 26.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185760;
  v_dados(v_dados.last()).vr_nrctremp := 134538;
  v_dados(v_dados.last()).vr_vllanmto := 29.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 185876;
  v_dados(v_dados.last()).vr_nrctremp := 147388;
  v_dados(v_dados.last()).vr_vllanmto := 28.34;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186201;
  v_dados(v_dados.last()).vr_nrctremp := 71865;
  v_dados(v_dados.last()).vr_vllanmto := 76.58;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 186902;
  v_dados(v_dados.last()).vr_nrctremp := 92977;
  v_dados(v_dados.last()).vr_vllanmto := 72.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187194;
  v_dados(v_dados.last()).vr_nrctremp := 56891;
  v_dados(v_dados.last()).vr_vllanmto := 69.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187402;
  v_dados(v_dados.last()).vr_nrctremp := 118241;
  v_dados(v_dados.last()).vr_vllanmto := 197.64;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 151743;
  v_dados(v_dados.last()).vr_vllanmto := 36.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 162673;
  v_dados(v_dados.last()).vr_vllanmto := 21.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187429;
  v_dados(v_dados.last()).vr_nrctremp := 184919;
  v_dados(v_dados.last()).vr_vllanmto := 18.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 187984;
  v_dados(v_dados.last()).vr_nrctremp := 139843;
  v_dados(v_dados.last()).vr_vllanmto := 20.1;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188557;
  v_dados(v_dados.last()).vr_nrctremp := 112687;
  v_dados(v_dados.last()).vr_vllanmto := 17.67;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 188620;
  v_dados(v_dados.last()).vr_nrctremp := 90707;
  v_dados(v_dados.last()).vr_vllanmto := 113.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192228;
  v_dados(v_dados.last()).vr_nrctremp := 112938;
  v_dados(v_dados.last()).vr_vllanmto := 14.47;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192503;
  v_dados(v_dados.last()).vr_nrctremp := 53664;
  v_dados(v_dados.last()).vr_vllanmto := 73.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 192902;
  v_dados(v_dados.last()).vr_nrctremp := 87507;
  v_dados(v_dados.last()).vr_vllanmto := 153.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193518;
  v_dados(v_dados.last()).vr_nrctremp := 91698;
  v_dados(v_dados.last()).vr_vllanmto := 86.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 193810;
  v_dados(v_dados.last()).vr_nrctremp := 147432;
  v_dados(v_dados.last()).vr_vllanmto := 39.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 198994;
  v_dados(v_dados.last()).vr_nrctremp := 92189;
  v_dados(v_dados.last()).vr_vllanmto := 95.03;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 198994;
  v_dados(v_dados.last()).vr_nrctremp := 113015;
  v_dados(v_dados.last()).vr_vllanmto := 35.43;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 201146;
  v_dados(v_dados.last()).vr_nrctremp := 137625;
  v_dados(v_dados.last()).vr_vllanmto := 49.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 201308;
  v_dados(v_dados.last()).vr_nrctremp := 99812;
  v_dados(v_dados.last()).vr_vllanmto := 51.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 202576;
  v_dados(v_dados.last()).vr_nrctremp := 104041;
  v_dados(v_dados.last()).vr_vllanmto := 77.54;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 202657;
  v_dados(v_dados.last()).vr_nrctremp := 163091;
  v_dados(v_dados.last()).vr_vllanmto := 23.8;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 202665;
  v_dados(v_dados.last()).vr_nrctremp := 123568;
  v_dados(v_dados.last()).vr_vllanmto := 89.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 207144;
  v_dados(v_dados.last()).vr_nrctremp := 105430;
  v_dados(v_dados.last()).vr_vllanmto := 10.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 209066;
  v_dados(v_dados.last()).vr_nrctremp := 56508;
  v_dados(v_dados.last()).vr_vllanmto := 154.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 211524;
  v_dados(v_dados.last()).vr_nrctremp := 107457;
  v_dados(v_dados.last()).vr_vllanmto := 99.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 214450;
  v_dados(v_dados.last()).vr_nrctremp := 100349;
  v_dados(v_dados.last()).vr_vllanmto := 71.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 216305;
  v_dados(v_dados.last()).vr_nrctremp := 97595;
  v_dados(v_dados.last()).vr_vllanmto := 26.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 218847;
  v_dados(v_dados.last()).vr_nrctremp := 63998;
  v_dados(v_dados.last()).vr_vllanmto := 45.71;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 219312;
  v_dados(v_dados.last()).vr_nrctremp := 90673;
  v_dados(v_dados.last()).vr_vllanmto := 193.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 222348;
  v_dados(v_dados.last()).vr_nrctremp := 84303;
  v_dados(v_dados.last()).vr_vllanmto := 89.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 223913;
  v_dados(v_dados.last()).vr_nrctremp := 57290;
  v_dados(v_dados.last()).vr_vllanmto := 73.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240133;
  v_dados(v_dados.last()).vr_nrctremp := 132847;
  v_dados(v_dados.last()).vr_vllanmto := 44.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 240990;
  v_dados(v_dados.last()).vr_nrctremp := 125145;
  v_dados(v_dados.last()).vr_vllanmto := 21.37;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 242985;
  v_dados(v_dados.last()).vr_nrctremp := 132628;
  v_dados(v_dados.last()).vr_vllanmto := 14.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 245437;
  v_dados(v_dados.last()).vr_nrctremp := 92577;
  v_dados(v_dados.last()).vr_vllanmto := 47.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 247596;
  v_dados(v_dados.last()).vr_nrctremp := 59689;
  v_dados(v_dados.last()).vr_vllanmto := 45.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 264032;
  v_dados(v_dados.last()).vr_nrctremp := 107397;
  v_dados(v_dados.last()).vr_vllanmto := 33.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 267414;
  v_dados(v_dados.last()).vr_nrctremp := 76198;
  v_dados(v_dados.last()).vr_vllanmto := 23.52;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 268135;
  v_dados(v_dados.last()).vr_nrctremp := 70210;
  v_dados(v_dados.last()).vr_vllanmto := 103.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 270075;
  v_dados(v_dados.last()).vr_nrctremp := 106404;
  v_dados(v_dados.last()).vr_vllanmto := 36.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 270466;
  v_dados(v_dados.last()).vr_nrctremp := 96648;
  v_dados(v_dados.last()).vr_vllanmto := 118.61;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 271276;
  v_dados(v_dados.last()).vr_nrctremp := 53665;
  v_dados(v_dados.last()).vr_vllanmto := 59.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 272361;
  v_dados(v_dados.last()).vr_nrctremp := 117990;
  v_dados(v_dados.last()).vr_vllanmto := 16.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 276260;
  v_dados(v_dados.last()).vr_nrctremp := 107625;
  v_dados(v_dados.last()).vr_vllanmto := 144.19;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 276260;
  v_dados(v_dados.last()).vr_nrctremp := 107626;
  v_dados(v_dados.last()).vr_vllanmto := 73.63;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 276260;
  v_dados(v_dados.last()).vr_nrctremp := 107629;
  v_dados(v_dados.last()).vr_vllanmto := 31.6;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 277193;
  v_dados(v_dados.last()).vr_nrctremp := 122406;
  v_dados(v_dados.last()).vr_vllanmto := 1244.8;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 285072;
  v_dados(v_dados.last()).vr_nrctremp := 83786;
  v_dados(v_dados.last()).vr_vllanmto := 157.99;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 288241;
  v_dados(v_dados.last()).vr_nrctremp := 83070;
  v_dados(v_dados.last()).vr_vllanmto := 69.49;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 288322;
  v_dados(v_dados.last()).vr_nrctremp := 106632;
  v_dados(v_dados.last()).vr_vllanmto := 94.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289426;
  v_dados(v_dados.last()).vr_nrctremp := 130202;
  v_dados(v_dados.last()).vr_vllanmto := 575.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289426;
  v_dados(v_dados.last()).vr_nrctremp := 132284;
  v_dados(v_dados.last()).vr_vllanmto := 21.14;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 289426;
  v_dados(v_dados.last()).vr_nrctremp := 147397;
  v_dados(v_dados.last()).vr_vllanmto := 694.13;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 295876;
  v_dados(v_dados.last()).vr_nrctremp := 117419;
  v_dados(v_dados.last()).vr_vllanmto := 11.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 321877;
  v_dados(v_dados.last()).vr_nrctremp := 116163;
  v_dados(v_dados.last()).vr_vllanmto := 36.73;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 321877;
  v_dados(v_dados.last()).vr_nrctremp := 116166;
  v_dados(v_dados.last()).vr_vllanmto := 21.66;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 322890;
  v_dados(v_dados.last()).vr_nrctremp := 147538;
  v_dados(v_dados.last()).vr_vllanmto := 20.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 323292;
  v_dados(v_dados.last()).vr_nrctremp := 57149;
  v_dados(v_dados.last()).vr_vllanmto := 250.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 325520;
  v_dados(v_dados.last()).vr_nrctremp := 56731;
  v_dados(v_dados.last()).vr_vllanmto := 1835.87;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 326941;
  v_dados(v_dados.last()).vr_nrctremp := 56659;
  v_dados(v_dados.last()).vr_vllanmto := 216.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 328375;
  v_dados(v_dados.last()).vr_nrctremp := 58256;
  v_dados(v_dados.last()).vr_vllanmto := 46.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 329169;
  v_dados(v_dados.last()).vr_nrctremp := 51807;
  v_dados(v_dados.last()).vr_vllanmto := 173.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 344192;
  v_dados(v_dados.last()).vr_nrctremp := 106118;
  v_dados(v_dados.last()).vr_vllanmto := 143.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 350745;
  v_dados(v_dados.last()).vr_nrctremp := 157549;
  v_dados(v_dados.last()).vr_vllanmto := 247.78;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 352624;
  v_dados(v_dados.last()).vr_nrctremp := 65227;
  v_dados(v_dados.last()).vr_vllanmto := 810.89;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 354996;
  v_dados(v_dados.last()).vr_nrctremp := 81005;
  v_dados(v_dados.last()).vr_vllanmto := 75.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 355771;
  v_dados(v_dados.last()).vr_nrctremp := 144078;
  v_dados(v_dados.last()).vr_vllanmto := 126.5;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 379301;
  v_dados(v_dados.last()).vr_nrctremp := 52196;
  v_dados(v_dados.last()).vr_vllanmto := 62.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382302;
  v_dados(v_dados.last()).vr_nrctremp := 101411;
  v_dados(v_dados.last()).vr_vllanmto := 27.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 382981;
  v_dados(v_dados.last()).vr_nrctremp := 64450;
  v_dados(v_dados.last()).vr_vllanmto := 21.03;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 391549;
  v_dados(v_dados.last()).vr_nrctremp := 112758;
  v_dados(v_dados.last()).vr_vllanmto := 21.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 392413;
  v_dados(v_dados.last()).vr_nrctremp := 129492;
  v_dados(v_dados.last()).vr_vllanmto := 20;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 408042;
  v_dados(v_dados.last()).vr_nrctremp := 74837;
  v_dados(v_dados.last()).vr_vllanmto := 62.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 412481;
  v_dados(v_dados.last()).vr_nrctremp := 97843;
  v_dados(v_dados.last()).vr_vllanmto := 68.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 416606;
  v_dados(v_dados.last()).vr_nrctremp := 179261;
  v_dados(v_dados.last()).vr_vllanmto := 10.05;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 416665;
  v_dados(v_dados.last()).vr_nrctremp := 55346;
  v_dados(v_dados.last()).vr_vllanmto := 220.86;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 418978;
  v_dados(v_dados.last()).vr_nrctremp := 97572;
  v_dados(v_dados.last()).vr_vllanmto := 1954.06;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 418978;
  v_dados(v_dados.last()).vr_nrctremp := 98664;
  v_dados(v_dados.last()).vr_vllanmto := 66.01;
  v_dados(v_dados.last()).vr_cdhistor := 1040;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 419206;
  v_dados(v_dados.last()).vr_nrctremp := 85355;
  v_dados(v_dados.last()).vr_vllanmto := 24.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 419869;
  v_dados(v_dados.last()).vr_nrctremp := 55947;
  v_dados(v_dados.last()).vr_vllanmto := 109.56;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 421200;
  v_dados(v_dados.last()).vr_nrctremp := 56187;
  v_dados(v_dados.last()).vr_vllanmto := 112.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 424218;
  v_dados(v_dados.last()).vr_nrctremp := 103005;
  v_dados(v_dados.last()).vr_vllanmto := 70.03;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 426610;
  v_dados(v_dados.last()).vr_nrctremp := 80116;
  v_dados(v_dados.last()).vr_vllanmto := 125.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 435007;
  v_dados(v_dados.last()).vr_nrctremp := 162711;
  v_dados(v_dados.last()).vr_vllanmto := 28.85;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 441376;
  v_dados(v_dados.last()).vr_nrctremp := 62504;
  v_dados(v_dados.last()).vr_vllanmto := 216.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 442054;
  v_dados(v_dados.last()).vr_nrctremp := 118810;
  v_dados(v_dados.last()).vr_vllanmto := 20.68;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 445347;
  v_dados(v_dados.last()).vr_nrctremp := 68188;
  v_dados(v_dados.last()).vr_vllanmto := 52.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 455849;
  v_dados(v_dados.last()).vr_nrctremp := 136760;
  v_dados(v_dados.last()).vr_vllanmto := 101.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 461610;
  v_dados(v_dados.last()).vr_nrctremp := 145393;
  v_dados(v_dados.last()).vr_vllanmto := 38.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 462020;
  v_dados(v_dados.last()).vr_nrctremp := 144951;
  v_dados(v_dados.last()).vr_vllanmto := 60.97;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 466026;
  v_dados(v_dados.last()).vr_nrctremp := 74654;
  v_dados(v_dados.last()).vr_vllanmto := 45.61;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 466026;
  v_dados(v_dados.last()).vr_nrctremp := 82142;
  v_dados(v_dados.last()).vr_vllanmto := 39.65;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 469661;
  v_dados(v_dados.last()).vr_nrctremp := 135698;
  v_dados(v_dados.last()).vr_vllanmto := 59.29;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 474649;
  v_dados(v_dados.last()).vr_nrctremp := 116129;
  v_dados(v_dados.last()).vr_vllanmto := 16.75;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 483923;
  v_dados(v_dados.last()).vr_nrctremp := 92602;
  v_dados(v_dados.last()).vr_vllanmto := 143.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 484067;
  v_dados(v_dados.last()).vr_nrctremp := 100800;
  v_dados(v_dados.last()).vr_vllanmto := 394.58;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 486256;
  v_dados(v_dados.last()).vr_nrctremp := 80327;
  v_dados(v_dados.last()).vr_vllanmto := 96.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 493376;
  v_dados(v_dados.last()).vr_nrctremp := 103276;
  v_dados(v_dados.last()).vr_vllanmto := 16.29;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 503584;
  v_dados(v_dados.last()).vr_nrctremp := 102245;
  v_dados(v_dados.last()).vr_vllanmto := 204.71;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 505587;
  v_dados(v_dados.last()).vr_nrctremp := 179776;
  v_dados(v_dados.last()).vr_vllanmto := 196.07;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 506893;
  v_dados(v_dados.last()).vr_nrctremp := 125887;
  v_dados(v_dados.last()).vr_vllanmto := 21.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 511870;
  v_dados(v_dados.last()).vr_nrctremp := 185230;
  v_dados(v_dados.last()).vr_vllanmto := 190.4;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 517399;
  v_dados(v_dados.last()).vr_nrctremp := 181024;
  v_dados(v_dados.last()).vr_vllanmto := 80.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521140;
  v_dados(v_dados.last()).vr_nrctremp := 92843;
  v_dados(v_dados.last()).vr_vllanmto := 53.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 521256;
  v_dados(v_dados.last()).vr_nrctremp := 92946;
  v_dados(v_dados.last()).vr_vllanmto := 65.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 522457;
  v_dados(v_dados.last()).vr_nrctremp := 107491;
  v_dados(v_dados.last()).vr_vllanmto := 47.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 524905;
  v_dados(v_dados.last()).vr_nrctremp := 95213;
  v_dados(v_dados.last()).vr_vllanmto := 110.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 526118;
  v_dados(v_dados.last()).vr_nrctremp := 96688;
  v_dados(v_dados.last()).vr_vllanmto := 95.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 528234;
  v_dados(v_dados.last()).vr_nrctremp := 97211;
  v_dados(v_dados.last()).vr_vllanmto := 185.59;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 532940;
  v_dados(v_dados.last()).vr_nrctremp := 128698;
  v_dados(v_dados.last()).vr_vllanmto := 24.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 541036;
  v_dados(v_dados.last()).vr_nrctremp := 103157;
  v_dados(v_dados.last()).vr_vllanmto := 194.21;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 544809;
  v_dados(v_dados.last()).vr_nrctremp := 104688;
  v_dados(v_dados.last()).vr_vllanmto := 10.07;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 548685;
  v_dados(v_dados.last()).vr_nrctremp := 172784;
  v_dados(v_dados.last()).vr_vllanmto := 17.57;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 557153;
  v_dados(v_dados.last()).vr_nrctremp := 111077;
  v_dados(v_dados.last()).vr_vllanmto := 40.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561142;
  v_dados(v_dados.last()).vr_nrctremp := 134641;
  v_dados(v_dados.last()).vr_vllanmto := 10.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561860;
  v_dados(v_dados.last()).vr_nrctremp := 129804;
  v_dados(v_dados.last()).vr_vllanmto := 14.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 561886;
  v_dados(v_dados.last()).vr_nrctremp := 113419;
  v_dados(v_dados.last()).vr_vllanmto := 80.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 572314;
  v_dados(v_dados.last()).vr_nrctremp := 179477;
  v_dados(v_dados.last()).vr_vllanmto := 42.51;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 573957;
  v_dados(v_dados.last()).vr_nrctremp := 119378;
  v_dados(v_dados.last()).vr_vllanmto := 31.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 578509;
  v_dados(v_dados.last()).vr_nrctremp := 123053;
  v_dados(v_dados.last()).vr_vllanmto := 91.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 590126;
  v_dados(v_dados.last()).vr_nrctremp := 179585;
  v_dados(v_dados.last()).vr_vllanmto := 285.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 601063;
  v_dados(v_dados.last()).vr_nrctremp := 101565;
  v_dados(v_dados.last()).vr_vllanmto := 12.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 606243;
  v_dados(v_dados.last()).vr_nrctremp := 176305;
  v_dados(v_dados.last()).vr_vllanmto := 64.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 607533;
  v_dados(v_dados.last()).vr_nrctremp := 133553;
  v_dados(v_dados.last()).vr_vllanmto := 11.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 626368;
  v_dados(v_dados.last()).vr_nrctremp := 150466;
  v_dados(v_dados.last()).vr_vllanmto := 40.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 629090;
  v_dados(v_dados.last()).vr_nrctremp := 171164;
  v_dados(v_dados.last()).vr_vllanmto := 48.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 638315;
  v_dados(v_dados.last()).vr_nrctremp := 151150;
  v_dados(v_dados.last()).vr_vllanmto := 10.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 641790;
  v_dados(v_dados.last()).vr_nrctremp := 148852;
  v_dados(v_dados.last()).vr_vllanmto := 27.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 664030;
  v_dados(v_dados.last()).vr_nrctremp := 161218;
  v_dados(v_dados.last()).vr_vllanmto := 22.3;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 673480;
  v_dados(v_dados.last()).vr_nrctremp := 166905;
  v_dados(v_dados.last()).vr_vllanmto := 20.77;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 677132;
  v_dados(v_dados.last()).vr_nrctremp := 170004;
  v_dados(v_dados.last()).vr_vllanmto := 11.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 678856;
  v_dados(v_dados.last()).vr_nrctremp := 171515;
  v_dados(v_dados.last()).vr_vllanmto := 9;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 13;
  v_dados(v_dados.last()).vr_nrdconta := 685739;
  v_dados(v_dados.last()).vr_nrctremp := 176567;
  v_dados(v_dados.last()).vr_vllanmto := 120.76;
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
