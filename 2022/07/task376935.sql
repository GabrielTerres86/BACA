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
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 387606;
  v_dados(v_dados.last()).vr_nrctremp := 51788;
  v_dados(v_dados.last()).vr_vllanmto := 124.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 397083;
  v_dados(v_dados.last()).vr_nrctremp := 51918;
  v_dados(v_dados.last()).vr_vllanmto := 124.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 339199;
  v_dados(v_dados.last()).vr_nrctremp := 52014;
  v_dados(v_dados.last()).vr_vllanmto := 124.28;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 297283;
  v_dados(v_dados.last()).vr_nrctremp := 54417;
  v_dados(v_dados.last()).vr_vllanmto := 13.32;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 423912;
  v_dados(v_dados.last()).vr_nrctremp := 56496;
  v_dados(v_dados.last()).vr_vllanmto := 51.62;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 206750;
  v_dados(v_dados.last()).vr_nrctremp := 57881;
  v_dados(v_dados.last()).vr_vllanmto := 18.66;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 404136;
  v_dados(v_dados.last()).vr_nrctremp := 58419;
  v_dados(v_dados.last()).vr_vllanmto := 31.46;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 404136;
  v_dados(v_dados.last()).vr_nrctremp := 58419;
  v_dados(v_dados.last()).vr_vllanmto := 56.22;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 276324;
  v_dados(v_dados.last()).vr_nrctremp := 59493;
  v_dados(v_dados.last()).vr_vllanmto := 20.38;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 528641;
  v_dados(v_dados.last()).vr_nrctremp := 20100365;
  v_dados(v_dados.last()).vr_vllanmto := 21.48;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 504769;
  v_dados(v_dados.last()).vr_nrctremp := 20100374;
  v_dados(v_dados.last()).vr_vllanmto := 17.15;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 514640;
  v_dados(v_dados.last()).vr_nrctremp := 20100508;
  v_dados(v_dados.last()).vr_vllanmto := 27.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 519650;
  v_dados(v_dados.last()).vr_nrctremp := 20100538;
  v_dados(v_dados.last()).vr_vllanmto := 40.24;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 511293;
  v_dados(v_dados.last()).vr_nrctremp := 20100547;
  v_dados(v_dados.last()).vr_vllanmto := 25.9;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 502987;
  v_dados(v_dados.last()).vr_nrctremp := 20100614;
  v_dados(v_dados.last()).vr_vllanmto := 16.12;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 502995;
  v_dados(v_dados.last()).vr_nrctremp := 20100622;
  v_dados(v_dados.last()).vr_vllanmto := 31.36;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 521434;
  v_dados(v_dados.last()).vr_nrctremp := 20100626;
  v_dados(v_dados.last()).vr_vllanmto := 18.16;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 521434;
  v_dados(v_dados.last()).vr_nrctremp := 20100626;
  v_dados(v_dados.last()).vr_vllanmto := 23.79;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 522988;
  v_dados(v_dados.last()).vr_nrctremp := 20100629;
  v_dados(v_dados.last()).vr_vllanmto := 17.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 530786;
  v_dados(v_dados.last()).vr_nrctremp := 20100634;
  v_dados(v_dados.last()).vr_vllanmto := 26.93;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 514500;
  v_dados(v_dados.last()).vr_nrctremp := 20100648;
  v_dados(v_dados.last()).vr_vllanmto := 35.78;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 517194;
  v_dados(v_dados.last()).vr_nrctremp := 20200024;
  v_dados(v_dados.last()).vr_vllanmto := 45.43;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501239;
  v_dados(v_dados.last()).vr_nrctremp := 20200572;
  v_dados(v_dados.last()).vr_vllanmto := 172.04;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 500917;
  v_dados(v_dados.last()).vr_nrctremp := 20300019;
  v_dados(v_dados.last()).vr_vllanmto := 286.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 500917;
  v_dados(v_dados.last()).vr_nrctremp := 20300019;
  v_dados(v_dados.last()).vr_vllanmto := 286.97;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505803;
  v_dados(v_dados.last()).vr_nrctremp := 20300049;
  v_dados(v_dados.last()).vr_vllanmto := 19.06;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505102;
  v_dados(v_dados.last()).vr_nrctremp := 21100007;
  v_dados(v_dados.last()).vr_vllanmto := 71.12;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501948;
  v_dados(v_dados.last()).vr_nrctremp := 21100009;
  v_dados(v_dados.last()).vr_vllanmto := 19.73;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 526991;
  v_dados(v_dados.last()).vr_nrctremp := 21100037;
  v_dados(v_dados.last()).vr_vllanmto := 187.33;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 518425;
  v_dados(v_dados.last()).vr_nrctremp := 21100046;
  v_dados(v_dados.last()).vr_vllanmto := 22.57;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 518425;
  v_dados(v_dados.last()).vr_nrctremp := 21100046;
  v_dados(v_dados.last()).vr_vllanmto := 36.04;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 522830;
  v_dados(v_dados.last()).vr_nrctremp := 21100047;
  v_dados(v_dados.last()).vr_vllanmto := 47.59;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 528889;
  v_dados(v_dados.last()).vr_nrctremp := 21100057;
  v_dados(v_dados.last()).vr_vllanmto := 19.2;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 526401;
  v_dados(v_dados.last()).vr_nrctremp := 21100090;
  v_dados(v_dados.last()).vr_vllanmto := 25.3;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 504297;
  v_dados(v_dados.last()).vr_nrctremp := 21100102;
  v_dados(v_dados.last()).vr_vllanmto := 27.8;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 526096;
  v_dados(v_dados.last()).vr_nrctremp := 21100115;
  v_dados(v_dados.last()).vr_vllanmto := 38.89;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503665;
  v_dados(v_dados.last()).vr_nrctremp := 21100124;
  v_dados(v_dados.last()).vr_vllanmto := 20.96;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503665;
  v_dados(v_dados.last()).vr_nrctremp := 21100124;
  v_dados(v_dados.last()).vr_vllanmto := 15.7;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 527610;
  v_dados(v_dados.last()).vr_nrctremp := 21100135;
  v_dados(v_dados.last()).vr_vllanmto := 24.35;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 527610;
  v_dados(v_dados.last()).vr_nrctremp := 21100135;
  v_dados(v_dados.last()).vr_vllanmto := 35.01;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 522023;
  v_dados(v_dados.last()).vr_nrctremp := 21100140;
  v_dados(v_dados.last()).vr_vllanmto := 18.17;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 522023;
  v_dados(v_dados.last()).vr_nrctremp := 21100140;
  v_dados(v_dados.last()).vr_vllanmto := 26.7;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505277;
  v_dados(v_dados.last()).vr_nrctremp := 21100150;
  v_dados(v_dados.last()).vr_vllanmto := 51.03;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 504521;
  v_dados(v_dados.last()).vr_nrctremp := 21100152;
  v_dados(v_dados.last()).vr_vllanmto := 276.17;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 525820;
  v_dados(v_dados.last()).vr_nrctremp := 21100180;
  v_dados(v_dados.last()).vr_vllanmto := 19.39;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 525820;
  v_dados(v_dados.last()).vr_nrctremp := 21100180;
  v_dados(v_dados.last()).vr_vllanmto := 19.67;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 504327;
  v_dados(v_dados.last()).vr_nrctremp := 21100187;
  v_dados(v_dados.last()).vr_vllanmto := 14.71;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 530689;
  v_dados(v_dados.last()).vr_nrctremp := 21100201;
  v_dados(v_dados.last()).vr_vllanmto := 34.98;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503185;
  v_dados(v_dados.last()).vr_nrctremp := 21100212;
  v_dados(v_dados.last()).vr_vllanmto := 17.4;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 531111;
  v_dados(v_dados.last()).vr_nrctremp := 21100231;
  v_dados(v_dados.last()).vr_vllanmto := 13.13;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 532037;
  v_dados(v_dados.last()).vr_nrctremp := 21200014;
  v_dados(v_dados.last()).vr_vllanmto := 259.99;
  v_dados(v_dados.last()).vr_cdhistor := 3919;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 532177;
  v_dados(v_dados.last()).vr_nrctremp := 21200016;
  v_dados(v_dados.last()).vr_vllanmto := 35.37;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 532177;
  v_dados(v_dados.last()).vr_nrctremp := 21200016;
  v_dados(v_dados.last()).vr_vllanmto := 35.62;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503126;
  v_dados(v_dados.last()).vr_nrctremp := 21200019;
  v_dados(v_dados.last()).vr_vllanmto := 32.64;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 503126;
  v_dados(v_dados.last()).vr_nrctremp := 21200019;
  v_dados(v_dados.last()).vr_vllanmto := 33.1;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 501255;
  v_dados(v_dados.last()).vr_nrctremp := 21200088;
  v_dados(v_dados.last()).vr_vllanmto := 2.42;
  v_dados(v_dados.last()).vr_cdhistor := 3918;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 533530;
  v_dados(v_dados.last()).vr_nrctremp := 21300015;
  v_dados(v_dados.last()).vr_vllanmto := 12.16;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 505358;
  v_dados(v_dados.last()).vr_nrctremp := 21300027;
  v_dados(v_dados.last()).vr_vllanmto := 11.31;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506133;
  v_dados(v_dados.last()).vr_nrctremp := 21300028;
  v_dados(v_dados.last()).vr_vllanmto := 55.68;
  v_dados(v_dados.last()).vr_cdhistor := 1037;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506133;
  v_dados(v_dados.last()).vr_nrctremp := 21300028;
  v_dados(v_dados.last()).vr_vllanmto := 11.03;
  v_dados(v_dados.last()).vr_cdhistor := 3883;

  v_dados.extend();
  v_dados(v_dados.last()).vr_cdcooper := 9;
  v_dados(v_dados.last()).vr_nrdconta := 506613;
  v_dados(v_dados.last()).vr_nrctremp := 21300039;
  v_dados(v_dados.last()).vr_vllanmto := 14.04;
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
