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
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 635316;
  v_dados(v_dados.last()).vr_nrctremp := 134348;
  v_dados(v_dados.last()).vr_vllanmto := 24.31;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 635316;
  v_dados(v_dados.last()).vr_nrctremp := 134348;
  v_dados(v_dados.last()).vr_vllanmto := 133.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 635359;
  v_dados(v_dados.last()).vr_nrctremp := 134355;
  v_dados(v_dados.last()).vr_vllanmto := 24.31;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 635359;
  v_dados(v_dados.last()).vr_nrctremp := 134355;
  v_dados(v_dados.last()).vr_vllanmto := 133.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 645206;
  v_dados(v_dados.last()).vr_nrctremp := 136896;
  v_dados(v_dados.last()).vr_vllanmto := 35.34;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 645206;
  v_dados(v_dados.last()).vr_nrctremp := 136896;
  v_dados(v_dados.last()).vr_vllanmto := 33.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551511;
  v_dados(v_dados.last()).vr_nrctremp := 137831;
  v_dados(v_dados.last()).vr_vllanmto := 72.22;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551511;
  v_dados(v_dados.last()).vr_nrctremp := 137831;
  v_dados(v_dados.last()).vr_vllanmto := 21.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 644331;
  v_dados(v_dados.last()).vr_nrctremp := 138745;
  v_dados(v_dados.last()).vr_vllanmto := 29.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 644331;
  v_dados(v_dados.last()).vr_nrctremp := 138745;
  v_dados(v_dados.last()).vr_vllanmto := 27.44;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 283258;
  v_dados(v_dados.last()).vr_nrctremp := 139298;
  v_dados(v_dados.last()).vr_vllanmto := 2511.15;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382493;
  v_dados(v_dados.last()).vr_nrctremp := 139419;
  v_dados(v_dados.last()).vr_vllanmto := 150.52;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382493;
  v_dados(v_dados.last()).vr_nrctremp := 139419;
  v_dados(v_dados.last()).vr_vllanmto := 45.81;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 215643;
  v_dados(v_dados.last()).vr_nrctremp := 139828;
  v_dados(v_dados.last()).vr_vllanmto := 80.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 215643;
  v_dados(v_dados.last()).vr_nrctremp := 139828;
  v_dados(v_dados.last()).vr_vllanmto := 38.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 658499;
  v_dados(v_dados.last()).vr_nrctremp := 139889;
  v_dados(v_dados.last()).vr_vllanmto := 26.14;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 665479;
  v_dados(v_dados.last()).vr_nrctremp := 141277;
  v_dados(v_dados.last()).vr_vllanmto := 38.1;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 665479;
  v_dados(v_dados.last()).vr_nrctremp := 141277;
  v_dados(v_dados.last()).vr_vllanmto := 21.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 258911;
  v_dados(v_dados.last()).vr_nrctremp := 141638;
  v_dados(v_dados.last()).vr_vllanmto := 54.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 258911;
  v_dados(v_dados.last()).vr_nrctremp := 141638;
  v_dados(v_dados.last()).vr_vllanmto := 49.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 671410;
  v_dados(v_dados.last()).vr_nrctremp := 142333;
  v_dados(v_dados.last()).vr_vllanmto := 53.81;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 671410;
  v_dados(v_dados.last()).vr_nrctremp := 142333;
  v_dados(v_dados.last()).vr_vllanmto := 50.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 331163;
  v_dados(v_dados.last()).vr_nrctremp := 142651;
  v_dados(v_dados.last()).vr_vllanmto := 30.67;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 331163;
  v_dados(v_dados.last()).vr_nrctremp := 142651;
  v_dados(v_dados.last()).vr_vllanmto := 28.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 489468;
  v_dados(v_dados.last()).vr_nrctremp := 142748;
  v_dados(v_dados.last()).vr_vllanmto := 495.63;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 298026;
  v_dados(v_dados.last()).vr_nrctremp := 143630;
  v_dados(v_dados.last()).vr_vllanmto := 723.25;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 453870;
  v_dados(v_dados.last()).vr_nrctremp := 159533;
  v_dados(v_dados.last()).vr_vllanmto := 159.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551031;
  v_dados(v_dados.last()).vr_nrctremp := 159572;
  v_dados(v_dados.last()).vr_vllanmto := 22.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 551031;
  v_dados(v_dados.last()).vr_nrctremp := 159572;
  v_dados(v_dados.last()).vr_vllanmto := 169.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382361;
  v_dados(v_dados.last()).vr_nrctremp := 159604;
  v_dados(v_dados.last()).vr_vllanmto := 1230.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 530085;
  v_dados(v_dados.last()).vr_nrctremp := 159619;
  v_dados(v_dados.last()).vr_vllanmto := 129.33;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 530085;
  v_dados(v_dados.last()).vr_nrctremp := 159619;
  v_dados(v_dados.last()).vr_vllanmto := 14.87;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 277819;
  v_dados(v_dados.last()).vr_nrctremp := 159656;
  v_dados(v_dados.last()).vr_vllanmto := 387.23;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 277819;
  v_dados(v_dados.last()).vr_nrctremp := 159656;
  v_dados(v_dados.last()).vr_vllanmto := 38.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241318;
  v_dados(v_dados.last()).vr_nrctremp := 159666;
  v_dados(v_dados.last()).vr_vllanmto := 29.86;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241318;
  v_dados(v_dados.last()).vr_nrctremp := 159666;
  v_dados(v_dados.last()).vr_vllanmto := 28.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 161226;
  v_dados(v_dados.last()).vr_vllanmto := 36.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 161226;
  v_dados(v_dados.last()).vr_vllanmto := 33.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 408620;
  v_dados(v_dados.last()).vr_nrctremp := 161884;
  v_dados(v_dados.last()).vr_vllanmto := 34.35;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 408620;
  v_dados(v_dados.last()).vr_nrctremp := 161884;
  v_dados(v_dados.last()).vr_vllanmto := 32.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 474207;
  v_dados(v_dados.last()).vr_nrctremp := 163299;
  v_dados(v_dados.last()).vr_vllanmto := 59.17;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 474207;
  v_dados(v_dados.last()).vr_nrctremp := 163299;
  v_dados(v_dados.last()).vr_vllanmto := 23.24;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 463833;
  v_dados(v_dados.last()).vr_nrctremp := 163999;
  v_dados(v_dados.last()).vr_vllanmto := 89.54;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 267252;
  v_dados(v_dados.last()).vr_nrctremp := 164600;
  v_dados(v_dados.last()).vr_vllanmto := 20.25;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 267252;
  v_dados(v_dados.last()).vr_nrctremp := 164600;
  v_dados(v_dados.last()).vr_vllanmto := 15.48;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 278254;
  v_dados(v_dados.last()).vr_nrctremp := 166419;
  v_dados(v_dados.last()).vr_vllanmto := 74.38;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 278254;
  v_dados(v_dados.last()).vr_nrctremp := 166419;
  v_dados(v_dados.last()).vr_vllanmto := 51.89;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 528633;
  v_dados(v_dados.last()).vr_nrctremp := 166485;
  v_dados(v_dados.last()).vr_vllanmto := 420.29;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 351644;
  v_dados(v_dados.last()).vr_nrctremp := 168423;
  v_dados(v_dados.last()).vr_vllanmto := 30.32;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 351644;
  v_dados(v_dados.last()).vr_nrctremp := 168423;
  v_dados(v_dados.last()).vr_vllanmto := 28.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 710229;
  v_dados(v_dados.last()).vr_nrctremp := 170226;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 710229;
  v_dados(v_dados.last()).vr_nrctremp := 170226;
  v_dados(v_dados.last()).vr_vllanmto := 22.53;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382558;
  v_dados(v_dados.last()).vr_nrctremp := 180912;
  v_dados(v_dados.last()).vr_vllanmto := 54.52;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382558;
  v_dados(v_dados.last()).vr_nrctremp := 180912;
  v_dados(v_dados.last()).vr_vllanmto := 51.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 498564;
  v_dados(v_dados.last()).vr_nrctremp := 190026;
  v_dados(v_dados.last()).vr_vllanmto := 9.11;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 741019;
  v_dados(v_dados.last()).vr_nrctremp := 199372;
  v_dados(v_dados.last()).vr_vllanmto := 40.63;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 741019;
  v_dados(v_dados.last()).vr_nrctremp := 199372;
  v_dados(v_dados.last()).vr_vllanmto := 104.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 166782;
  v_dados(v_dados.last()).vr_nrctremp := 200024;
  v_dados(v_dados.last()).vr_vllanmto := 1482.93;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 219185;
  v_dados(v_dados.last()).vr_nrctremp := 212721;
  v_dados(v_dados.last()).vr_vllanmto := 89.85;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 219185;
  v_dados(v_dados.last()).vr_nrctremp := 212721;
  v_dados(v_dados.last()).vr_vllanmto := 84.18;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 265420;
  v_dados(v_dados.last()).vr_nrctremp := 216943;
  v_dados(v_dados.last()).vr_vllanmto := 64.66;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 265420;
  v_dados(v_dados.last()).vr_nrctremp := 216943;
  v_dados(v_dados.last()).vr_vllanmto := 4.6;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 725889;
  v_dados(v_dados.last()).vr_nrctremp := 231820;
  v_dados(v_dados.last()).vr_vllanmto := 49.94;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 725889;
  v_dados(v_dados.last()).vr_nrctremp := 231820;
  v_dados(v_dados.last()).vr_vllanmto := 110.56;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 765937;
  v_dados(v_dados.last()).vr_nrctremp := 237607;
  v_dados(v_dados.last()).vr_vllanmto := 1.01;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 765937;
  v_dados(v_dados.last()).vr_nrctremp := 237607;
  v_dados(v_dados.last()).vr_vllanmto := 138.41;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 317470;
  v_dados(v_dados.last()).vr_nrctremp := 237871;
  v_dados(v_dados.last()).vr_vllanmto := 41.39;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 317470;
  v_dados(v_dados.last()).vr_nrctremp := 237871;
  v_dados(v_dados.last()).vr_vllanmto := 38.74;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 792446;
  v_dados(v_dados.last()).vr_nrctremp := 237922;
  v_dados(v_dados.last()).vr_vllanmto := 54.07;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 792446;
  v_dados(v_dados.last()).vr_nrctremp := 237922;
  v_dados(v_dados.last()).vr_vllanmto := 50.55;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 824062;
  v_dados(v_dados.last()).vr_nrctremp := 240965;
  v_dados(v_dados.last()).vr_vllanmto := 79.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 824062;
  v_dados(v_dados.last()).vr_nrctremp := 240965;
  v_dados(v_dados.last()).vr_vllanmto := 74.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 665673;
  v_dados(v_dados.last()).vr_nrctremp := 241641;
  v_dados(v_dados.last()).vr_vllanmto := 68.47;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 665673;
  v_dados(v_dados.last()).vr_nrctremp := 241641;
  v_dados(v_dados.last()).vr_vllanmto := 64.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 326844;
  v_dados(v_dados.last()).vr_nrctremp := 244242;
  v_dados(v_dados.last()).vr_vllanmto := .16;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 306410;
  v_dados(v_dados.last()).vr_nrctremp := 260595;
  v_dados(v_dados.last()).vr_vllanmto := 34.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 306410;
  v_dados(v_dados.last()).vr_nrctremp := 260595;
  v_dados(v_dados.last()).vr_vllanmto := 88.08;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 299081;
  v_dados(v_dados.last()).vr_nrctremp := 273053;
  v_dados(v_dados.last()).vr_vllanmto := 2449.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 246743;
  v_dados(v_dados.last()).vr_nrctremp := 273301;
  v_dados(v_dados.last()).vr_vllanmto := 69.92;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 246743;
  v_dados(v_dados.last()).vr_nrctremp := 273301;
  v_dados(v_dados.last()).vr_vllanmto := 64.39;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 590894;
  v_dados(v_dados.last()).vr_nrctremp := 276937;
  v_dados(v_dados.last()).vr_vllanmto := 49.3;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 590894;
  v_dados(v_dados.last()).vr_nrctremp := 276937;
  v_dados(v_dados.last()).vr_vllanmto := 104.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 291404;
  v_dados(v_dados.last()).vr_vllanmto := 346.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 291404;
  v_dados(v_dados.last()).vr_vllanmto := 324.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 34290;
  v_dados(v_dados.last()).vr_nrctremp := 294652;
  v_dados(v_dados.last()).vr_vllanmto := 150.05;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 34290;
  v_dados(v_dados.last()).vr_nrctremp := 294652;
  v_dados(v_dados.last()).vr_vllanmto := 205.94;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241199;
  v_dados(v_dados.last()).vr_nrctremp := 296059;
  v_dados(v_dados.last()).vr_vllanmto := .76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241199;
  v_dados(v_dados.last()).vr_nrctremp := 296059;
  v_dados(v_dados.last()).vr_vllanmto := 45.48;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 241199;
  v_dados(v_dados.last()).vr_nrctremp := 296059;
  v_dados(v_dados.last()).vr_vllanmto := 61.63;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 296165;
  v_dados(v_dados.last()).vr_vllanmto := 87.57;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 296165;
  v_dados(v_dados.last()).vr_vllanmto := 165.73;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 325147;
  v_dados(v_dados.last()).vr_nrctremp := 302246;
  v_dados(v_dados.last()).vr_vllanmto := 133.7;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 325147;
  v_dados(v_dados.last()).vr_nrctremp := 302246;
  v_dados(v_dados.last()).vr_vllanmto := 124.98;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 905194;
  v_dados(v_dados.last()).vr_nrctremp := 304728;
  v_dados(v_dados.last()).vr_vllanmto := 2072.64;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 352837;
  v_dados(v_dados.last()).vr_nrctremp := 306870;
  v_dados(v_dados.last()).vr_vllanmto := 154.74;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 352837;
  v_dados(v_dados.last()).vr_nrctremp := 306870;
  v_dados(v_dados.last()).vr_vllanmto := 144.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 792446;
  v_dados(v_dados.last()).vr_nrctremp := 312059;
  v_dados(v_dados.last()).vr_vllanmto := 72.52;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 792446;
  v_dados(v_dados.last()).vr_nrctremp := 312059;
  v_dados(v_dados.last()).vr_vllanmto := 67.76;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 753793;
  v_dados(v_dados.last()).vr_nrctremp := 323121;
  v_dados(v_dados.last()).vr_vllanmto := 114.74;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 753793;
  v_dados(v_dados.last()).vr_nrctremp := 323121;
  v_dados(v_dados.last()).vr_vllanmto := 107.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 888206;
  v_dados(v_dados.last()).vr_nrctremp := 324337;
  v_dados(v_dados.last()).vr_vllanmto := 119.93;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 888206;
  v_dados(v_dados.last()).vr_nrctremp := 324337;
  v_dados(v_dados.last()).vr_vllanmto := 6.85;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 888206;
  v_dados(v_dados.last()).vr_nrctremp := 324337;
  v_dados(v_dados.last()).vr_vllanmto := 188.25;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 888206;
  v_dados(v_dados.last()).vr_nrctremp := 324337;
  v_dados(v_dados.last()).vr_vllanmto := 178.07;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 24.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := .21;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 213.57;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 56.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 900591;
  v_dados(v_dados.last()).vr_nrctremp := 326107;
  v_dados(v_dados.last()).vr_vllanmto := 77.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 943320;
  v_dados(v_dados.last()).vr_nrctremp := 330956;
  v_dados(v_dados.last()).vr_vllanmto := 77.17;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 943320;
  v_dados(v_dados.last()).vr_nrctremp := 330956;
  v_dados(v_dados.last()).vr_vllanmto := 117.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 230227;
  v_dados(v_dados.last()).vr_nrctremp := 331584;
  v_dados(v_dados.last()).vr_vllanmto := 4260.94;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 399507;
  v_dados(v_dados.last()).vr_nrctremp := 332932;
  v_dados(v_dados.last()).vr_vllanmto := 78.45;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 399507;
  v_dados(v_dados.last()).vr_nrctremp := 332932;
  v_dados(v_dados.last()).vr_vllanmto := 73.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 365319;
  v_dados(v_dados.last()).vr_nrctremp := 335566;
  v_dados(v_dados.last()).vr_vllanmto := 14.1;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 365319;
  v_dados(v_dados.last()).vr_nrctremp := 335566;
  v_dados(v_dados.last()).vr_vllanmto := 32.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 365319;
  v_dados(v_dados.last()).vr_nrctremp := 335566;
  v_dados(v_dados.last()).vr_vllanmto := 76.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 500747;
  v_dados(v_dados.last()).vr_nrctremp := 337041;
  v_dados(v_dados.last()).vr_vllanmto := 75.98;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 500747;
  v_dados(v_dados.last()).vr_nrctremp := 337041;
  v_dados(v_dados.last()).vr_vllanmto := 71.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 704520;
  v_dados(v_dados.last()).vr_nrctremp := 338005;
  v_dados(v_dados.last()).vr_vllanmto := 67.3;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 704520;
  v_dados(v_dados.last()).vr_nrctremp := 338005;
  v_dados(v_dados.last()).vr_vllanmto := 123.9;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 6432123;
  v_dados(v_dados.last()).vr_nrctremp := 339944;
  v_dados(v_dados.last()).vr_vllanmto := 6.93;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 6432123;
  v_dados(v_dados.last()).vr_nrctremp := 339944;
  v_dados(v_dados.last()).vr_vllanmto := 26.73;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 6432123;
  v_dados(v_dados.last()).vr_nrctremp := 339944;
  v_dados(v_dados.last()).vr_vllanmto := 24.11;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3144410;
  v_dados(v_dados.last()).vr_nrctremp := 343116;
  v_dados(v_dados.last()).vr_vllanmto := 23.83;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3144410;
  v_dados(v_dados.last()).vr_nrctremp := 343116;
  v_dados(v_dados.last()).vr_vllanmto := 106.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3144410;
  v_dados(v_dados.last()).vr_nrctremp := 343116;
  v_dados(v_dados.last()).vr_vllanmto := 117;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 51136;
  v_dados(v_dados.last()).vr_nrctremp := 343259;
  v_dados(v_dados.last()).vr_vllanmto := 83.07;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 51136;
  v_dados(v_dados.last()).vr_nrctremp := 343259;
  v_dados(v_dados.last()).vr_vllanmto := 95;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 956635;
  v_dados(v_dados.last()).vr_nrctremp := 343825;
  v_dados(v_dados.last()).vr_vllanmto := 15.65;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 956635;
  v_dados(v_dados.last()).vr_nrctremp := 343825;
  v_dados(v_dados.last()).vr_vllanmto := 18.79;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 959685;
  v_dados(v_dados.last()).vr_nrctremp := 346966;
  v_dados(v_dados.last()).vr_vllanmto := 753.49;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 753262;
  v_dados(v_dados.last()).vr_nrctremp := 347080;
  v_dados(v_dados.last()).vr_vllanmto := 4046.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 528633;
  v_dados(v_dados.last()).vr_nrctremp := 350074;
  v_dados(v_dados.last()).vr_vllanmto := 212.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 528633;
  v_dados(v_dados.last()).vr_nrctremp := 350074;
  v_dados(v_dados.last()).vr_vllanmto := 198.82;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 112690;
  v_dados(v_dados.last()).vr_nrctremp := 351378;
  v_dados(v_dados.last()).vr_vllanmto := 80.61;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 112690;
  v_dados(v_dados.last()).vr_nrctremp := 351378;
  v_dados(v_dados.last()).vr_vllanmto := 75.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 353154;
  v_dados(v_dados.last()).vr_vllanmto := 11.39;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 353154;
  v_dados(v_dados.last()).vr_vllanmto := 57.26;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 893870;
  v_dados(v_dados.last()).vr_nrctremp := 353154;
  v_dados(v_dados.last()).vr_vllanmto := 53.49;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 245399;
  v_dados(v_dados.last()).vr_nrctremp := 357781;
  v_dados(v_dados.last()).vr_vllanmto := 8.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 245399;
  v_dados(v_dados.last()).vr_nrctremp := 357781;
  v_dados(v_dados.last()).vr_vllanmto := 46.59;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 245399;
  v_dados(v_dados.last()).vr_nrctremp := 357781;
  v_dados(v_dados.last()).vr_vllanmto := 85.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 369403;
  v_dados(v_dados.last()).vr_nrctremp := 358297;
  v_dados(v_dados.last()).vr_vllanmto := 115.88;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 962074;
  v_dados(v_dados.last()).vr_nrctremp := 360299;
  v_dados(v_dados.last()).vr_vllanmto := 47.46;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 962074;
  v_dados(v_dados.last()).vr_nrctremp := 360299;
  v_dados(v_dados.last()).vr_vllanmto := 60.72;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977993;
  v_dados(v_dados.last()).vr_nrctremp := 363403;
  v_dados(v_dados.last()).vr_vllanmto := 72.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977993;
  v_dados(v_dados.last()).vr_nrctremp := 363403;
  v_dados(v_dados.last()).vr_vllanmto := 95.45;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 264946;
  v_dados(v_dados.last()).vr_nrctremp := 365118;
  v_dados(v_dados.last()).vr_vllanmto := 2.9;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 264946;
  v_dados(v_dados.last()).vr_nrctremp := 365118;
  v_dados(v_dados.last()).vr_vllanmto := 11.24;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 264946;
  v_dados(v_dados.last()).vr_nrctremp := 365118;
  v_dados(v_dados.last()).vr_vllanmto := 15.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 982180;
  v_dados(v_dados.last()).vr_nrctremp := 367658;
  v_dados(v_dados.last()).vr_vllanmto := 54.74;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 982180;
  v_dados(v_dados.last()).vr_nrctremp := 367658;
  v_dados(v_dados.last()).vr_vllanmto := 58.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 905194;
  v_dados(v_dados.last()).vr_nrctremp := 373651;
  v_dados(v_dados.last()).vr_vllanmto := 4719.32;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 986950;
  v_dados(v_dados.last()).vr_nrctremp := 373726;
  v_dados(v_dados.last()).vr_vllanmto := 90.47;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 986950;
  v_dados(v_dados.last()).vr_nrctremp := 373726;
  v_dados(v_dados.last()).vr_vllanmto := 81.61;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 521809;
  v_dados(v_dados.last()).vr_nrctremp := 374531;
  v_dados(v_dados.last()).vr_vllanmto := 51.36;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 521809;
  v_dados(v_dados.last()).vr_nrctremp := 374531;
  v_dados(v_dados.last()).vr_vllanmto := 48.07;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 989886;
  v_dados(v_dados.last()).vr_nrctremp := 377163;
  v_dados(v_dados.last()).vr_vllanmto := 74.77;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 989886;
  v_dados(v_dados.last()).vr_nrctremp := 377163;
  v_dados(v_dados.last()).vr_vllanmto := 67.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 255670;
  v_dados(v_dados.last()).vr_nrctremp := 379562;
  v_dados(v_dados.last()).vr_vllanmto := .61;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 255670;
  v_dados(v_dados.last()).vr_nrctremp := 379562;
  v_dados(v_dados.last()).vr_vllanmto := 56.2;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 255670;
  v_dados(v_dados.last()).vr_nrctremp := 379562;
  v_dados(v_dados.last()).vr_vllanmto := 70.59;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 588776;
  v_dados(v_dados.last()).vr_nrctremp := 383196;
  v_dados(v_dados.last()).vr_vllanmto := 85.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 588776;
  v_dados(v_dados.last()).vr_nrctremp := 383196;
  v_dados(v_dados.last()).vr_vllanmto := 79.59;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 761419;
  v_dados(v_dados.last()).vr_nrctremp := 383549;
  v_dados(v_dados.last()).vr_vllanmto := 79.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 761419;
  v_dados(v_dados.last()).vr_nrctremp := 383549;
  v_dados(v_dados.last()).vr_vllanmto := 71.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3001385;
  v_dados(v_dados.last()).vr_nrctremp := 384400;
  v_dados(v_dados.last()).vr_vllanmto := 55.46;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3001385;
  v_dados(v_dados.last()).vr_nrctremp := 384400;
  v_dados(v_dados.last()).vr_vllanmto := 55.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1981765;
  v_dados(v_dados.last()).vr_nrctremp := 384467;
  v_dados(v_dados.last()).vr_vllanmto := 311.13;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1981765;
  v_dados(v_dados.last()).vr_nrctremp := 384467;
  v_dados(v_dados.last()).vr_vllanmto := 285.12;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2292947;
  v_dados(v_dados.last()).vr_nrctremp := 387313;
  v_dados(v_dados.last()).vr_vllanmto := 212.15;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2292947;
  v_dados(v_dados.last()).vr_nrctremp := 387313;
  v_dados(v_dados.last()).vr_vllanmto := 198.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 996068;
  v_dados(v_dados.last()).vr_nrctremp := 387439;
  v_dados(v_dados.last()).vr_vllanmto := 85.4;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 996068;
  v_dados(v_dados.last()).vr_nrctremp := 387439;
  v_dados(v_dados.last()).vr_vllanmto := 113.98;
  v_dados(v_dados.last()).vr_cdhistor := 3917;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2367068;
  v_dados(v_dados.last()).vr_nrctremp := 388222;
  v_dados(v_dados.last()).vr_vllanmto := 169.22;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 2367068;
  v_dados(v_dados.last()).vr_nrctremp := 388222;
  v_dados(v_dados.last()).vr_vllanmto := 158.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3512304;
  v_dados(v_dados.last()).vr_nrctremp := 392805;
  v_dados(v_dados.last()).vr_vllanmto := 151.91;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 3512304;
  v_dados(v_dados.last()).vr_nrctremp := 392805;
  v_dados(v_dados.last()).vr_vllanmto := 141.92;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1003933;
  v_dados(v_dados.last()).vr_nrctremp := 395877;
  v_dados(v_dados.last()).vr_vllanmto := 124.76;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1003933;
  v_dados(v_dados.last()).vr_nrctremp := 395877;
  v_dados(v_dados.last()).vr_vllanmto := 120.64;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977101;
  v_dados(v_dados.last()).vr_nrctremp := 396529;
  v_dados(v_dados.last()).vr_vllanmto := 77.16;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 977101;
  v_dados(v_dados.last()).vr_nrctremp := 396529;
  v_dados(v_dados.last()).vr_vllanmto := 72.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 956635;
  v_dados(v_dados.last()).vr_nrctremp := 412491;
  v_dados(v_dados.last()).vr_vllanmto := 22.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 984388;
  v_dados(v_dados.last()).vr_nrctremp := 418171;
  v_dados(v_dados.last()).vr_vllanmto := 157.66;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 984388;
  v_dados(v_dados.last()).vr_nrctremp := 418171;
  v_dados(v_dados.last()).vr_vllanmto := 151.23;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382361;
  v_dados(v_dados.last()).vr_nrctremp := 422610;
  v_dados(v_dados.last()).vr_vllanmto := 156.25;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 382361;
  v_dados(v_dados.last()).vr_nrctremp := 422610;
  v_dados(v_dados.last()).vr_vllanmto := 131.42;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 978140;
  v_dados(v_dados.last()).vr_nrctremp := 425132;
  v_dados(v_dados.last()).vr_vllanmto := 80.92;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 978140;
  v_dados(v_dados.last()).vr_nrctremp := 425132;
  v_dados(v_dados.last()).vr_vllanmto := 75.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1026100;
  v_dados(v_dados.last()).vr_nrctremp := 425701;
  v_dados(v_dados.last()).vr_vllanmto := 131.56;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 1026100;
  v_dados(v_dados.last()).vr_nrctremp := 425701;
  v_dados(v_dados.last()).vr_vllanmto := 115.27;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14302683;
  v_dados(v_dados.last()).vr_nrctremp := 426361;
  v_dados(v_dados.last()).vr_vllanmto := 19.82;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 14302683;
  v_dados(v_dados.last()).vr_nrctremp := 426361;
  v_dados(v_dados.last()).vr_vllanmto := 18.58;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 858129;
  v_dados(v_dados.last()).vr_nrctremp := 429569;
  v_dados(v_dados.last()).vr_vllanmto := 30.12;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 858129;
  v_dados(v_dados.last()).vr_nrctremp := 429569;
  v_dados(v_dados.last()).vr_vllanmto := 27.21;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 173266;
  v_dados(v_dados.last()).vr_nrctremp := 429603;
  v_dados(v_dados.last()).vr_vllanmto := 24.86;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 173266;
  v_dados(v_dados.last()).vr_nrctremp := 429603;
  v_dados(v_dados.last()).vr_vllanmto := 19.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 10537;
  v_dados(v_dados.last()).vr_nrctremp := 430335;
  v_dados(v_dados.last()).vr_vllanmto := 6.97;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 658499;
  v_dados(v_dados.last()).vr_nrctremp := 430853;
  v_dados(v_dados.last()).vr_vllanmto := 65.32;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 658499;
  v_dados(v_dados.last()).vr_nrctremp := 430853;
  v_dados(v_dados.last()).vr_vllanmto := 57.19;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 16;
  v_dados(v_dados.last()).vr_nrdconta := 166782;
  v_dados(v_dados.last()).vr_nrctremp := 444577;
  v_dados(v_dados.last()).vr_vllanmto := 13.9;
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
